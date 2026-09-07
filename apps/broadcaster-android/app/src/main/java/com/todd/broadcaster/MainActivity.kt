package com.todd.broadcaster

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.WindowManager
import android.widget.*
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.todd.broadcaster.media.BroadcasterEngine
import com.todd.broadcaster.media.EncoderConfig
import com.todd.broadcaster.telemetry.DeviceHealth
import com.todd.broadcaster.telemetry.DeviceTelemetry
import com.todd.broadcaster.whip.WhipClient
import com.todd.broadcaster.whip.WhipResult
import com.todd.broadcaster.whip.WhipSession
import kotlinx.coroutines.*
import org.webrtc.PeerConnection
import org.webrtc.SurfaceViewRenderer
import java.util.Timer
import java.util.TimerTask

/**
 * Main activity for the Todd Broadcaster.
 *
 * Lifecycle:
 * 1. Request camera + audio permissions
 * 2. Show config dialog (base URL, room, camera, token)
 * 3. Initialize WebRTC engine + start camera preview
 * 4. On "Go Live": create offer → WHIP POST → set answer → media flows
 * 5. Periodic watchdog monitors encoder health (frames + bitrate)
 * 6. On "Stop": DELETE WHIP resource → release engine
 */
class MainActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "MainActivity"
        private const val PERMISSION_REQUEST_CODE = 1001
        private const val PREFS_NAME = "todd_broadcaster_prefs"
        private const val KEY_BASE_URL = "base_url"
        private const val KEY_ROOM_ID = "room_id"
        private const val KEY_CAMERA_ID = "camera_id"
        private const val KEY_TOKEN = "token"
        private const val KEY_STUN = "stun_url"
        private const val KEY_PROFILE_IDX = "profile_idx"
        private const val WATCHDOG_INTERVAL_MS = 15_000L
        private const val MAX_WATCHDOG_RESTARTS = 3
        private const val MIN_HEALTHY_BITRATE_KBPS = 50.0
    }

    // ── Views ──
    private lateinit var previewRenderer: SurfaceViewRenderer
    private lateinit var statusOverlay: FrameLayout
    private lateinit var statusChip: TextView
    private lateinit var healthStrip: TextView
    private lateinit var noticeBanner: TextView
    private lateinit var controlBar: LinearLayout
    private lateinit var btnGoLive: Button
    private lateinit var btnStop: Button
    private lateinit var btnMute: ImageButton
    private lateinit var btnSwitchCam: ImageButton
    private lateinit var btnConfig: ImageButton
    private lateinit var tvFps: TextView
    private lateinit var tvBitrate: TextView

    // ── Engine ──
    private lateinit var engine: BroadcasterEngine
    private var whipClient: WhipClient? = null
    private var whipSession: WhipSession? = null
    private var telemetry: DeviceTelemetry? = null

    // ── State ──
    private var isLive = false
    private var isMuted = false
    private var watchdogTimer: Timer? = null
    private var watchdogRestarts = 0
    private var lastBytesSent = 0L
    private var lastBytesSentAt = 0L
    private var phase = "idle"

    // ── Config ──
    private var baseUrl = ""
    private var roomId = ""
    private var cameraId = ""
    private var token = ""
    private var stunUrl = "stun:stun.l.google.com:19302"
    private var profileIdx = EncoderConfig.PROFILES.indexOf(EncoderConfig.DEFAULT_PROFILE)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(R.layout.activity_main)

        bindViews()
        loadConfig()
        requestPermissions()
        initEngine()
    }

    private fun bindViews() {
        previewRenderer = findViewById(R.id.preview_renderer)
        statusOverlay = findViewById(R.id.status_overlay)
        statusChip = findViewById(R.id.status_chip)
        healthStrip = findViewById(R.id.health_strip)
        noticeBanner = findViewById(R.id.notice_banner)
        controlBar = findViewById(R.id.control_bar)
        btnGoLive = findViewById(R.id.btn_go_live)
        btnStop = findViewById(R.id.btn_stop)
        btnMute = findViewById(R.id.btn_mute)
        btnSwitchCam = findViewById(R.id.btn_switch_cam)
        btnConfig = findViewById(R.id.btn_config)
        tvFps = findViewById(R.id.tv_fps)
        tvBitrate = findViewById(R.id.tv_bitrate)

        btnGoLive.setOnClickListener { startBroadcast() }
        btnStop.setOnClickListener { stopBroadcast() }
        btnMute.setOnClickListener { toggleMute() }
        btnSwitchCam.setOnClickListener { engine.switchCamera() }
        btnConfig.setOnClickListener { showConfigDialog() }

        // Initial UI state
        updatePhase("idle")
        btnStop.visibility = View.GONE
    }

    // ── Permissions ──

    private fun requestPermissions() {
        val perms = mutableListOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            perms.add(Manifest.permission.POST_NOTIFICATIONS)
        }
        val needed = perms.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (needed.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, needed.toTypedArray(), PERMISSION_REQUEST_CODE)
        } else {
            onPermissionsGranted()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                onPermissionsGranted()
            } else {
                Toast.makeText(this, "Camera and microphone permissions are required", Toast.LENGTH_LONG).show()
            }
        }
    }

    // ── Engine init ──

    private fun initEngine() {
        engine = BroadcasterEngine(this)
        engine.initialize()
        engine.previewRenderer = previewRenderer
    }

    private fun onPermissionsGranted() {
        if (!::engine.isInitialized) return
        val profile = EncoderConfig.PROFILES[profileIdx]
        try {
            engine.startCapture(profile.width, profile.height, 30, "environment")
            Log.i(TAG, "Camera preview started (${profile.label})")
        } catch (e: Exception) {
            Log.e(TAG, "Camera start failed: ${e.message}", e)
            showNotice("Camera error: ${e.message}")
        }
    }

    // ── Broadcast lifecycle ──

    private fun startBroadcast() {
        if (baseUrl.isBlank() || roomId.isBlank() || cameraId.isBlank() || token.isBlank()) {
            showConfigDialog()
            return
        }

        updatePhase("connecting")
        btnGoLive.visibility = View.GONE
        btnStop.visibility = View.VISIBLE

        lifecycleScope.launch {
            // ── Step 1: Create SDP offer with full ICE gather ──
            showNotice("Gathering ICE candidates...")
            val offerSdp = try {
                engine.createOffer(stunUrl = stunUrl)
            } catch (e: Exception) {
                Log.e(TAG, "Offer creation failed: ${e.message}", e)
                showNotice("Offer failed: ${e.message}")
                updatePhase("error")
                return@launch
            }

            if (offerSdp.isBlank()) {
                showNotice("ICE gather timed out — check network")
                updatePhase("error")
                return@launch
            }

            // ── Step 2: WHIP POST ──
            showNotice("Connecting to engine...")
            whipClient = WhipClient(baseUrl)
            val result = whipClient!!.connect(roomId, cameraId, token, offerSdp)

            when (result) {
                is WhipResult.Success -> {
                    whipSession = result.session
                    Log.i(TAG, "WHIP accepted — setting answer")

                    // ── Step 3: Apply SDP answer ──
                    engine.setAnswer(result.session.answerSdp)

                    // ── Step 4: Start telemetry ──
                    telemetry = DeviceTelemetry(baseUrl, token)
                    telemetry!!.start()

                    isLive = true
                    watchdogRestarts = 0
                    lastBytesSent = 0L
                    lastBytesSentAt = 0L
                    updatePhase("live")
                    showNotice("")
                    startWatchdog()

                    Log.i(TAG, "Broadcast LIVE — ${EncoderConfig.PROFILES[profileIdx].label}")
                }
                is WhipResult.Failure -> {
                    Log.w(TAG, "WHIP rejected: ${result.message}")
                    showNotice(result.message)
                    updatePhase("error")
                    btnGoLive.visibility = View.VISIBLE
                    btnStop.visibility = View.GONE
                }
            }
        }
    }

    private fun stopBroadcast() {
        Log.i(TAG, "Stopping broadcast")
        isLive = false
        updatePhase("idle")
        stopWatchdog()

        lifecycleScope.launch {
            // Send WHIP DELETE
            whipSession?.let { session ->
                whipClient?.disconnect(session)
            }
            whipSession = null

            // Stop telemetry
            telemetry?.stop()
            telemetry = null
        }

        btnGoLive.visibility = View.VISIBLE
        btnStop.visibility = View.GONE
        showNotice("")
    }

    private fun toggleMute() {
        isMuted = !isMuted
        btnMute.setImageResource(
            if (isMuted) R.drawable.ic_mic_off
            else R.drawable.ic_mic
        )
    }

    // ── Watchdog ──

    private fun startWatchdog() {
        stopWatchdog()
        watchdogTimer = Timer().apply {
            scheduleAtFixedRate(object : TimerTask() {
                override fun run() {
                    runOnUiThread { checkEncoderHealth() }
                }
            }, WATCHDOG_INTERVAL_MS, WATCHDOG_INTERVAL_MS)
        }
    }

    private fun stopWatchdog() {
        watchdogTimer?.cancel()
        watchdogTimer = null
    }

    private fun checkEncoderHealth() {
        if (!isLive) return

        val stats = engine.getVideoStats() ?: return
        val (framesEncoded, bytesSent) = stats

        // ── Bitrate calculation ──
        val now = System.currentTimeMillis()
        val videoKbps = if (lastBytesSentAt > 0 && bytesSent > lastBytesSent) {
            val elapsedSec = (now - lastBytesSentAt) / 1000.0
            if (elapsedSec > 0) ((bytesSent - lastBytesSent) * 8.0 / 1000.0) / elapsedSec else null
        } else null
        lastBytesSent = bytesSent
        lastBytesSentAt = now

        // ── Update health strip ──
        val profile = EncoderConfig.PROFILES[profileIdx]
        healthStrip.text = "${profile.label} | ${videoKbps?.toInt() ?: 0} kbps | $framesEncoded frames"
        tvBitrate.text = "${videoKbps?.toInt() ?: 0} kbps"
        tvFps.text = "enc: $framesEncoded"

        // ── Push telemetry ──
        val health = DeviceHealth(
            cameraId = cameraId,
            phase = phase,
            connected = isLive,
            audioMuted = isMuted,
            videoFrozen = framesEncoded == 0L,
            uplinkKbps = videoKbps,
            fps = null, // WebRTC stats don't always provide FPS
            framesEncoded = framesEncoded,
            framesSent = framesEncoded,
            bytesSent = bytesSent,
            iceConnectionState = "connected",
            signalingState = "stable",
            deviceModel = "${Build.MANUFACTURER} ${Build.MODEL}",
            androidVersion = Build.VERSION.RELEASE,
            sdkVersion = "native-1.0.0",
            timestamp = now,
        )
        telemetry?.updateHealth(health)

        // ── Stall detection ──
        if (framesEncoded == 0L) {
            handleVideoStall("Encoder produced 0 frames")
        } else if (videoKbps != null && videoKbps < MIN_HEALTHY_BITRATE_KBPS) {
            handleVideoStall("Video bitrate too low: ${videoKbps.toInt()} kbps")
        }
    }

    private fun handleVideoStall(reason: String) {
        Log.w(TAG, "Video stall detected: $reason")
        showNotice("⚠ Video stalled: $reason")

        if (watchdogRestarts < MAX_WATCHDOG_RESTARTS) {
            watchdogRestarts++
            Log.i(TAG, "Auto-restart attempt $watchdogRestarts/$MAX_WATCHDOG_RESTARTS")
            showNotice("Restarting encoder (attempt $watchdogRestarts)...")

            lifecycleScope.launch {
                stopBroadcast()
                delay(1000)
                startBroadcast()
            }
        } else {
            showNotice("⚠ Video stalled after $MAX_WATCHDOG_RESTARTS restarts — manual restart required")
            noticeBanner.setBackgroundColor(0xFFEF4444.toInt())
        }
    }

    // ── Config dialog ──

    private fun showConfigDialog() {
        val dialogView = layoutInflater.inflate(R.layout.dialog_config, null)
        val etBaseUrl = dialogView.findViewById<EditText>(R.id.et_base_url)
        val etRoomId = dialogView.findViewById<EditText>(R.id.et_room_id)
        val etCameraId = dialogView.findViewById<EditText>(R.id.et_camera_id)
        val etToken = dialogView.findViewById<EditText>(R.id.et_token)
        val etStun = dialogView.findViewById<EditText>(R.id.et_stun)
        val spinnerProfile = dialogView.findViewById<Spinner>(R.id.spinner_profile)

        // Populate
        etBaseUrl.setText(baseUrl)
        etRoomId.setText(roomId)
        etCameraId.setText(cameraId)
        etToken.setText(token)
        etStun.setText(stunUrl)

        val profileLabels = EncoderConfig.PROFILES.map { it.label }.toTypedArray()
        spinnerProfile.adapter = ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, profileLabels)
        spinnerProfile.setSelection(profileIdx)

        AlertDialog.Builder(this)
            .setTitle("Broadcaster Config")
            .setView(dialogView)
            .setPositiveButton("Save") { _, _ ->
                baseUrl = etBaseUrl.text.toString().trim()
                roomId = etRoomId.text.toString().trim()
                cameraId = etCameraId.text.toString().trim()
                token = etToken.text.toString().trim()
                stunUrl = etStun.text.toString().trim().ifEmpty { "stun:stun.l.google.com:19302" }
                profileIdx = spinnerProfile.selectedItemPosition
                saveConfig()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun loadConfig() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        baseUrl = prefs.getString(KEY_BASE_URL, "") ?: ""
        roomId = prefs.getString(KEY_ROOM_ID, "") ?: ""
        cameraId = prefs.getString(KEY_CAMERA_ID, "") ?: ""
        token = prefs.getString(KEY_TOKEN, "") ?: ""
        stunUrl = prefs.getString(KEY_STUN, "stun:stun.l.google.com:19302") ?: "stun:stun.l.google.com:19302"
        profileIdx = prefs.getInt(KEY_PROFILE_IDX, EncoderConfig.PROFILES.indexOf(EncoderConfig.DEFAULT_PROFILE))
    }

    private fun saveConfig() {
        getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().apply {
            putString(KEY_BASE_URL, baseUrl)
            putString(KEY_ROOM_ID, roomId)
            putString(KEY_CAMERA_ID, cameraId)
            putString(KEY_TOKEN, token)
            putString(KEY_STUN, stunUrl)
            putInt(KEY_PROFILE_IDX, profileIdx)
            apply()
        }
    }

    // ── UI helpers ──

    private fun updatePhase(newPhase: String) {
        phase = newPhase
        statusChip.text = when (newPhase) {
            "idle" -> "Ready"
            "connecting" -> "Connecting..."
            "live" -> "LIVE"
            "error" -> "Error"
            else -> newPhase
        }
        statusChip.setBackgroundColor(when (newPhase) {
            "idle" -> 0xFF6B7280.toInt()     // gray
            "connecting" -> 0xFFF59E0B.toInt() // amber
            "live" -> 0xFFEF4444.toInt()       // red
            "error" -> 0xFFDC2626.toInt()      // dark red
            else -> 0xFF6B7280.toInt()
        })
    }

    private fun showNotice(message: String) {
        if (message.isBlank()) {
            noticeBanner.visibility = View.GONE
        } else {
            noticeBanner.visibility = View.VISIBLE
            noticeBanner.text = message
        }
    }

    // ── Lifecycle ──

    override fun onDestroy() {
        super.onDestroy()
        stopBroadcast()
        engine.release()
    }
}
