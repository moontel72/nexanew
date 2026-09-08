package com.todd.broadcaster

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.text.Editable
import android.text.TextWatcher
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
import com.todd.broadcaster.whip.IngestUrl
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
        private const val KEY_PERM_EXPLAINED = "perm_explained"
        private const val KEY_BASE_URL = "base_url"
        private const val KEY_ROOM_ID = "room_id"
        private const val KEY_CAMERA_ID = "camera_id"
        private const val KEY_TOKEN = "token"
        private const val KEY_STUN = "stun_url"
        private const val KEY_TURN_URL = "turn_url"
        private const val KEY_TURN_USER = "turn_user"
        private const val KEY_TURN_PASS = "turn_pass"
        private const val KEY_PROFILE_IDX = "profile_idx"
        private const val KEY_FPS = "fps"
        private const val WATCHDOG_INTERVAL_MS = 15_000L
        private const val MAX_WATCHDOG_RESTARTS = 3
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
    private var noProgressChecks = 0
    private var lastCheckFrames = -1L
    private var lastCheckBytes = -1L
    private var phase = "idle"

    // ── Config ──
    private var baseUrl = ""
    private var roomId = ""
    private var cameraId = ""
    private var token = ""
    private var stunUrl = "stun:stun.l.google.com:19302"
    private var turnUrl = ""
    private var turnUser = ""
    private var turnPass = ""
    private var profileIdx = EncoderConfig.PROFILES.indexOf(EncoderConfig.DEFAULT_PROFILE)
    private var fps = EncoderConfig.DEFAULT_FPS

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(R.layout.activity_main)

        bindViews()
        loadConfig()
        // initEngine() MUST run before requestPermissions(): when camera/mic are
        // already granted, requestPermissions() invokes onPermissionsGranted()
        // synchronously, which early-returns if the engine isn't initialized yet —
        // so startCapture() never runs and isPreviewRunning stays false (the
        // "Camera preview chalu nahi" notice on every launch after the first).
        initEngine()
        requestPermissions()
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
        // Camera + microphone only. POST_NOTIFICATIONS is NOT declared in the
        // manifest, so requesting it silently denies and would block the
        // whole core flow with a misleading "permissions required" toast.
        val needed = listOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
        ).filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (needed.isEmpty()) {
            onPermissionsGranted()
            return
        }

        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        val alreadyExplained = prefs.getBoolean(KEY_PERM_EXPLAINED, false)
        if (!alreadyExplained) {
            prefs.edit().putBoolean(KEY_PERM_EXPLAINED, true).apply()
            // One-time explainer: the system dialogs read "video"/"audio", so
            // name the real permissions (Camera/Microphone) before they appear.
            AlertDialog.Builder(this)
                .setTitle("Permissions Required")
                .setMessage(
                    "Broadcaster app ko 2 permissions chahiye:\n\n" +
                        "1. Camera — video capture ke liye\n" +
                        "2. Microphone — audio record ke liye\n\n" +
                        "Aane wale system dialogs mein dono ke liye ALLOW dabayen."
                )
                .setCancelable(false)
                .setPositiveButton("Continue") { _, _ ->
                    ActivityCompat.requestPermissions(this, needed.toTypedArray(), PERMISSION_REQUEST_CODE)
                }
                .show()
        } else {
            ActivityCompat.requestPermissions(this, needed.toTypedArray(), PERMISSION_REQUEST_CODE)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != PERMISSION_REQUEST_CODE) return

        val camGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED
        val micGranted = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
        if (camGranted && micGranted) {
            onPermissionsGranted()
            return
        }

        // A denied permission whose system dialog will no longer reappear
        // ("Don't ask again") can only be fixed from Android Settings.
        val denied = listOf(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)
            .filter {
                ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
            }
        val permanentlyBlocked = denied.any {
            !ActivityCompat.shouldShowRequestPermissionRationale(this, it)
        }

        if (permanentlyBlocked) {
            AlertDialog.Builder(this)
                .setTitle("Permissions Blocked")
                .setMessage(
                    "Android Settings se Camera aur Microphone permissions allow karen, " +
                        "phir app dobara kholen."
                )
                .setPositiveButton("Open Settings") { _, _ ->
                    startActivity(
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
                    )
                }
                .setNegativeButton("Cancel", null)
                .show()
        } else {
            Toast.makeText(this, "Camera aur Microphone permissions zaroori hain", Toast.LENGTH_LONG).show()
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
            engine.startCapture(profile.width, profile.height, fps, "environment")
            Log.i(TAG, "Camera preview started (${profile.label} @ ${fps}fps)")
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

        // Camera preview must be running (started right after permissions are
        // granted). Without it createOffer fails with "no video track".
        if (!engine.isPreviewRunning) {
            showNotice("Camera preview chalu nahi — Settings mein Camera & Microphone allow kar ke app restart karen")
            return
        }

        updatePhase("connecting")
        btnGoLive.visibility = View.GONE
        btnStop.visibility = View.VISIBLE

        lifecycleScope.launch {
            // ── Step 1: Create SDP offer with full ICE gather ──
            showNotice("Gathering ICE candidates...")
            val offerSdp = try {
                engine.createOffer(
                    stunUrl = stunUrl,
                    turnUrl = turnUrl.ifBlank { null },
                    turnUsername = turnUser.ifBlank { null },
                    turnPassword = turnPass.ifBlank { null },
                )
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
                    noProgressChecks = 0
                    lastCheckFrames = -1L
                    lastCheckBytes = -1L
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

        // ── Stall detection: restart only on NO progress across three
        // consecutive checks (~45 s). Some encoders take up to ~30 s to emit
        // their first frame; killing the session on the first slow check
        // starves them forever (the observed 41 s restart loop).
        val progressed = framesEncoded > lastCheckFrames || bytesSent > lastCheckBytes
        lastCheckFrames = framesEncoded
        lastCheckBytes = bytesSent
        if (progressed) {
            noProgressChecks = 0
        } else {
            noProgressChecks++
            Log.w(
                TAG,
                "No encoder progress (check $noProgressChecks/3): " +
                    "$framesEncoded frames, ${videoKbps?.toInt() ?: 0} kbps"
            )
            if (noProgressChecks >= 3) {
                noProgressChecks = 0
                handleVideoStall("No video progress for 45s")
            }
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
        val etFullUrl = dialogView.findViewById<EditText>(R.id.et_full_url)
        val etBaseUrl = dialogView.findViewById<EditText>(R.id.et_base_url)
        val etRoomId = dialogView.findViewById<EditText>(R.id.et_room_id)
        val etCameraId = dialogView.findViewById<EditText>(R.id.et_camera_id)
        val etToken = dialogView.findViewById<EditText>(R.id.et_token)
        val etStun = dialogView.findViewById<EditText>(R.id.et_stun)
        val etTurnUrl = dialogView.findViewById<EditText>(R.id.et_turn_url)
        val etTurnUser = dialogView.findViewById<EditText>(R.id.et_turn_user)
        val etTurnPass = dialogView.findViewById<EditText>(R.id.et_turn_pass)
        val spinnerFps = dialogView.findViewById<Spinner>(R.id.spinner_fps)
        val spinnerProfile = dialogView.findViewById<Spinner>(R.id.spinner_profile)

        // Populate
        etBaseUrl.setText(baseUrl)
        etRoomId.setText(roomId)
        etCameraId.setText(cameraId)
        etToken.setText(token)
        etStun.setText(stunUrl)
        etTurnUrl.setText(turnUrl)
        etTurnUser.setText(turnUser)
        etTurnPass.setText(turnPass)

        // Paste the full ingest URL → fields below fill in live.
        etFullUrl.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                val parsed = IngestUrl.parse(s?.toString().orEmpty())
                if (parsed != null) {
                    etBaseUrl.setText(parsed.baseUrl)
                    etRoomId.setText(parsed.roomId)
                    etCameraId.setText(parsed.cameraId)
                    etToken.setText(parsed.token)
                }
            }
        })

        val profileLabels = EncoderConfig.PROFILES.map { it.label }.toTypedArray()
        spinnerProfile.adapter = ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, profileLabels)
        spinnerProfile.setSelection(profileIdx)

        val fpsLabels = EncoderConfig.FPS_OPTIONS.map { it.label }.toTypedArray()
        spinnerFps.adapter = ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, fpsLabels)
        spinnerFps.setSelection(EncoderConfig.FPS_OPTIONS.indexOfFirst { it.fps == fps }.coerceAtLeast(0))

        AlertDialog.Builder(this)
            .setTitle("Broadcaster Config")
            .setView(dialogView)
            .setPositiveButton("Save") { _, _ ->
                val fullUrl = etFullUrl.text.toString().trim()
                // A pasted full WHIP ingest URL wins over the manual fields:
                // it carries the base URL, room, camera and token in one string.
                // Shape: https://host/api/v1/whip/ingest/{room}/{camera}?token={jwt}
                val parsed = if (fullUrl.isNotEmpty()) IngestUrl.parse(fullUrl) else null
                if (fullUrl.isNotEmpty() && parsed == null) {
                    Toast.makeText(
                        this,
                        "Full WHIP URL parse nahi hui — fields manually bharen",
                        Toast.LENGTH_LONG
                    ).show()
                }
                baseUrl = parsed?.baseUrl ?: etBaseUrl.text.toString().trim()
                roomId = parsed?.roomId ?: etRoomId.text.toString().trim()
                cameraId = parsed?.cameraId ?: etCameraId.text.toString().trim()
                token = parsed?.token ?: etToken.text.toString().trim()
                stunUrl = etStun.text.toString().trim().ifEmpty { "stun:stun.l.google.com:19302" }
                turnUrl = etTurnUrl.text.toString().trim()
                turnUser = etTurnUser.text.toString().trim()
                turnPass = etTurnPass.text.toString().trim()
                fps = EncoderConfig.FPS_OPTIONS[spinnerFps.selectedItemPosition].fps
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
        turnUrl = prefs.getString(KEY_TURN_URL, "") ?: ""
        turnUser = prefs.getString(KEY_TURN_USER, "") ?: ""
        turnPass = prefs.getString(KEY_TURN_PASS, "") ?: ""
        profileIdx = prefs.getInt(KEY_PROFILE_IDX, EncoderConfig.PROFILES.indexOf(EncoderConfig.DEFAULT_PROFILE))
        fps = prefs.getInt(KEY_FPS, EncoderConfig.DEFAULT_FPS)
        if (EncoderConfig.FPS_OPTIONS.none { it.fps == fps }) fps = EncoderConfig.DEFAULT_FPS
    }

    private fun saveConfig() {
        getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().apply {
            putString(KEY_BASE_URL, baseUrl)
            putString(KEY_ROOM_ID, roomId)
            putString(KEY_CAMERA_ID, cameraId)
            putString(KEY_TOKEN, token)
            putString(KEY_STUN, stunUrl)
            putString(KEY_TURN_URL, turnUrl)
            putString(KEY_TURN_USER, turnUser)
            putString(KEY_TURN_PASS, turnPass)
            putInt(KEY_PROFILE_IDX, profileIdx)
            putInt(KEY_FPS, fps)
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
