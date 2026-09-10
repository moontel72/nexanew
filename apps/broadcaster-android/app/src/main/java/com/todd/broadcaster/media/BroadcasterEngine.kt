package com.todd.broadcaster.media

import android.content.Context
import android.util.Log
import kotlinx.coroutines.suspendCancellableCoroutine
import org.webrtc.*
import org.webrtc.audio.JavaAudioDeviceModule
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume

/**
 * Core WebRTC engine for the Todd Broadcaster.
 *
 * Manages the PeerConnection lifecycle: factory initialization, camera/audio
 * capture, SDP offer creation (full ICE gather), answer application, and
 * connection state monitoring.
 *
 * This replaces the Flutter flutter_webrtc plugin with direct access to
 * libwebrtc's Java API, giving explicit control over:
 * - MediaCodec hardware encoder parameters (via HardwareVideoEncoderFactory)
 * - ICE gathering (full-gather, non-trickle, matching the Rust engine)
 * - Codec preference (H264 first for maximum compatibility)
 * - Connection state callbacks
 */
class BroadcasterEngine(private val context: Context) {

    companion object {
        private const val TAG = "BroadcasterEngine"
        private const val ICE_GATHER_TIMEOUT_MS = 10_000L
        private const val DEFAULT_STUN = "stun:stun.l.google.com:19302"

        /** Media server's own STUN/TURN host (coturn on the VPS). */
        private const val SELF_STUN = "stun:135.181.46.27:3478"
    }

    private var factory: PeerConnectionFactory? = null
    private var peerConnection: PeerConnection? = null
    private var videoSource: VideoSource? = null
    private var audioSource: AudioSource? = null
    private var videoTrack: VideoTrack? = null
    private var audioTrack: AudioTrack? = null
    private var cameraCapturer: CameraVideoCapturer? = null
    private var eglBase: EglBase? = null

    /** Fixed open-loop video bitrate, matched to the UI profile (Larix-style). */
    private var videoBitrateBps = 800_000

    /** The local preview renderer (SurfaceViewRenderer). */
    var previewRenderer: SurfaceViewRenderer? = null

    /** True once camera capture and tracks are running (offer can be created). */
    val isPreviewRunning: Boolean
        get() = videoTrack != null && cameraCapturer != null

    /** Connection state callback. */
    var onConnectionState: ((PeerConnection.PeerConnectionState) -> Unit)? = null

    /** ICE gathering complete callback with the full SDP. */
    var onIceGatheringComplete: ((String) -> Unit)? = null

    /**
     * Initializes the WebRTC PeerConnectionFactory.
     * Must be called once before any other method.
     */
    fun initialize() {
        val options = PeerConnectionFactory.InitializationOptions.builder(context)
            .setEnableInternalTracer(false)
            .setFieldTrials("")
            .createInitializationOptions()
        PeerConnectionFactory.initialize(options)

        // Native WebRTC logs (encoder/BWE/pacing) → logcat for field debugging.
        // Must come AFTER PeerConnectionFactory.initialize(): the native
        // library is only loaded there, and Logging JNI crashes before it.
        Logging.enableLogToDebugOutput(Logging.Severity.LS_INFO)

        eglBase = EglBase.create()

        // ── Encoder factory: prefer hardware H.264 ──
        // DefaultVideoEncoderFactory(enableH264HighProfile=true) drops
        // Baseline-only hardware H.264 encoders (common on Samsung J-series),
        // leaving VP8 — which runs in software on these phones and stalls.
        // enableH264HighProfile=false keeps Baseline H.264; the wrapper below
        // then restricts the offer to H.264 so negotiation never lands on VP8.
        val delegate = DefaultVideoEncoderFactory(
            eglBase!!.eglBaseContext,
            true,  // enableIntelVp8Encoder (x86-only; no effect on ARM phones)
            false, // enableH264HighProfile=false → Baseline H.264 accepted
        )
        val encoderFactory = H264PreferredEncoderFactory(delegate)
        val decoderFactory = DefaultVideoDecoderFactory(eglBase!!.eglBaseContext)

        Log.i(
            TAG,
            "Available video encoders: " +
                encoderFactory.getSupportedCodecs().joinToString { c -> "${c.name} $c" }
        )

        factory = PeerConnectionFactory.builder()
            .setVideoEncoderFactory(encoderFactory)
            .setVideoDecoderFactory(decoderFactory)
            .setAudioDeviceModule(JavaAudioDeviceModule.builder(context)
                .setUseHardwareAcousticEchoCanceler(true)
                .setUseHardwareNoiseSuppressor(true)
                .createAudioDeviceModule())
            .createPeerConnectionFactory()

        Log.i(TAG, "PeerConnectionFactory initialized")
    }

    /**
     * Starts camera capture and creates video/audio tracks.
     *
     * @param width     Capture width.
     * @param height    Capture height.
     * @param fps       Target frame rate.
     * @param facingMode "environment" (rear) or "user" (front).
     */
    fun startCapture(
        width: Int,
        height: Int,
        fps: Int,
        facingMode: String = "environment",
    ) {
        val f = factory ?: throw IllegalStateException("Not initialized")

        videoBitrateBps =
            (EncoderConfig.PROFILES.firstOrNull { it.width == width && it.height == height }
                ?.bitrateKbps ?: 800) * 1000
        Log.i(TAG, "Capture ${width}x${height}@${fps}fps → ${videoBitrateBps / 1000} kbps fixed")

        // ── Camera ──
        val enumerator = Camera2Enumerator(context)
        val deviceNames = enumerator.deviceNames
        val targetDevice = deviceNames.firstOrNull { name ->
            if (facingMode == "user") enumerator.isFrontFacing(name)
            else enumerator.isBackFacing(name)
        } ?: deviceNames.firstOrNull()
        ?: throw IllegalStateException("No camera available")

        Log.i(TAG, "Using camera: $targetDevice (${width}x${height}@${fps}fps)")

        cameraCapturer = enumerator.createCapturer(targetDevice, null)
        val surfaceTextureHelper = SurfaceTextureHelper.create(
            "CaptureThread", eglBase!!.eglBaseContext
        )
        videoSource = f.createVideoSource(false)
        cameraCapturer!!.initialize(surfaceTextureHelper, context, videoSource!!.capturerObserver)
        cameraCapturer!!.startCapture(width, height, fps)

        videoTrack = f.createVideoTrack("video0", videoSource)

        // ── Audio ──
        val audioConstraints = MediaConstraints().apply {
            mandatory.add(MediaConstraints.KeyValuePair("googEchoCancellation", "true"))
            mandatory.add(MediaConstraints.KeyValuePair("googNoiseSuppression", "true"))
            mandatory.add(MediaConstraints.KeyValuePair("googAutoGainControl", "true"))
        }
        audioSource = f.createAudioSource(audioConstraints)
        audioTrack = f.createAudioTrack("audio0", audioSource)

        // ── Preview ──
        previewRenderer?.let { renderer ->
            renderer.init(eglBase!!.eglBaseContext, null)
            renderer.setMirror(false)
            videoTrack?.addSink(renderer)
        }

        Log.i(TAG, "Camera capture started")
    }

    /**
     * Removes congestion-control feedback negotiation (transport-cc, goog-remb)
     * from an SDP so the sender runs open-loop at the fixed profile bitrate.
     */
    private fun stripCongestionControl(sdp: String): String {
        val kept = sdp.split("\r\n", "\n").filterNot { raw ->
            val l = raw.trim()
            (l.startsWith("a=rtcp-fb:") && (l.contains("transport-cc") || l.contains("goog-remb"))) ||
                (l.startsWith("a=extmap:") && (l.contains("transport-wide-cc") || l.contains("goog-remb")))
        }
        return kept.joinToString("\r\n")
    }

    /**
     * Pins the video sender to the profile bitrate (min = max). The engine
     * sends no congestion feedback, so without this libwebrtc starves video
     * to ~30 kbps (the "video starts 30 s late then trickles" symptom).
     */
    private fun applyFixedVideoBitrate(pc: PeerConnection) {
        val sender = pc.senders.firstOrNull { it.track()?.kind() == "video" } ?: return
        val params = sender.parameters
        val enc = params.encodings.firstOrNull() ?: return
        enc.minBitrateBps = videoBitrateBps
        enc.maxBitrateBps = videoBitrateBps
        if (sender.setParameters(params)) {
            Log.i(TAG, "Video sender pinned to ${videoBitrateBps / 1000} kbps (open-loop)")
        }
    }

    /**
     * Creates a PeerConnection, adds audio+video tracks, creates an SDP
     * offer with full ICE gathering, and returns the complete offer SDP.
     *
     * @param stunUrl STUN server URL (e.g. "stun:stun.l.google.com:19302").
     * @param turnUrl Optional TURN server URL.
     * @param turnUsername Optional TURN username.
     * @param turnPassword Optional TURN password.
     * @return The complete SDP offer string with all ICE candidates.
     */
    suspend fun createOffer(
        stunUrl: String = DEFAULT_STUN,
        turnUrl: String? = null,
        turnUsername: String? = null,
        turnPassword: String? = null,
    ): String = suspendCancellableCoroutine { cont ->
        val f = factory ?: throw IllegalStateException("Not initialized")

        // ── ICE servers ──
        val iceServers = mutableListOf<PeerConnection.IceServer>()
        val effectiveStun = stunUrl.ifEmpty { DEFAULT_STUN }
        iceServers.add(PeerConnection.IceServer.builder(effectiveStun).createIceServer())
        // Google STUN is blocked on some carrier/CGNAT networks — also ask the
        // media server's own STUN (same host as the TURN relay below).
        iceServers.add(PeerConnection.IceServer.builder(SELF_STUN).createIceServer())
        if (!turnUrl.isNullOrEmpty()) {
            // Carrier CGNATs often drop LARGE UDP packets while small ones
            // pass (observed: audio ~70 B flows, video ~1200 B never arrives).
            // Offer BOTH transports: libwebrtc then picks UDP first and falls
            // back to the TCP relay when the UDP path starves/dies.
            val base = turnUrl.trim().trimEnd('/')
            val variants = if (base.contains("?transport=")) {
                listOf(base)
            } else {
                listOf("$base?transport=udp", "$base?transport=tcp")
            }
            for (url in variants) {
                val builder = PeerConnection.IceServer.builder(url)
                if (!turnUsername.isNullOrEmpty()) builder.setUsername(turnUsername)
                if (!turnPassword.isNullOrEmpty()) builder.setPassword(turnPassword)
                iceServers.add(builder.createIceServer())
            }
        }

        val config = PeerConnection.RTCConfiguration(iceServers).apply {
            sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN
            continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY
            candidateNetworkPolicy = PeerConnection.CandidateNetworkPolicy.ALL
            // Use ALL transport types (host + srflx + relay) instead of
            // RELAY-only.  Forcing RELAY caused every session to die after
            // ~6 s when the coturn TCP relay path collapsed (consent
            // freshness STUN timeout).  ALL lets libwebrtc try direct and
            // server-reflexive candidates first — the engine has a public
            // IP so srflx often works even behind carrier CGNAT — and fall
            // back to the TURN relay only when no direct path survives.
            if (!turnUrl.isNullOrEmpty()) {
                iceTransportsType = PeerConnection.IceTransportsType.ALL
            }
        }

        // ── Create PeerConnection ──
        val observer = object : PeerConnectionObserver() {
            override fun onIceGatheringChange(state: PeerConnection.IceGatheringState?) {
                Log.d(TAG, "ICE gathering state: $state")
                if (state == PeerConnection.IceGatheringState.COMPLETE) {
                    val sdp = peerConnection?.localDescription?.description ?: ""
                    Log.i(TAG, "ICE gathering complete — offer ready (${sdp.length} chars)")
                    if (cont.isActive) cont.resume(sdp)
                }
            }

            override fun onConnectionChange(state: PeerConnection.PeerConnectionState) {
                Log.i(TAG, "PeerConnection state: $state")
                onConnectionState?.invoke(state)
            }

            override fun onIceConnectionChange(state: PeerConnection.IceConnectionState?) {
                Log.d(TAG, "ICE connection state: $state")
            }
        }

        peerConnection = f.createPeerConnection(config, observer)
            ?: throw IllegalStateException("PeerConnection creation failed")

        // ── Add tracks ──
        val vt = videoTrack ?: throw IllegalStateException("No video track")
        val at = audioTrack ?: throw IllegalStateException("No audio track")
        peerConnection!!.addTrack(vt)
        peerConnection!!.addTrack(at)

        // The media engine sends no congestion feedback; libwebrtc's estimator
        // then starves video to ~30 kbps. Run open-loop at the profile bitrate.
        applyFixedVideoBitrate(peerConnection!!)

        // ── Codec preference: H264 first ──
        // The DefaultVideoEncoderFactory already prefers hardware H264 when available.
        // We log the transceiver setup for debugging; the engine will negotiate
        // H264 in the SDP offer automatically based on the encoder factory capabilities.
        peerConnection!!.transceivers.forEach { transceiver ->
            if (transceiver.mediaType == MediaStreamTrack.MediaType.MEDIA_TYPE_VIDEO) {
                Log.i(TAG, "Video transceiver configured — H264 preferred via encoder factory")
            }
        }

        // ── Create offer ──
        val constraints = MediaConstraints().apply {
            mandatory.add(MediaConstraints.KeyValuePair("OfferToReceiveAudio", "false"))
            mandatory.add(MediaConstraints.KeyValuePair("OfferToReceiveVideo", "false"))
        }

        peerConnection!!.createOffer(object : SdpObserver {
            override fun onCreateSuccess(sdp: SessionDescription?) {
                if (sdp == null) {
                    if (cont.isActive) cont.resume("")
                    return
                }
                // Strip congestion-feedback negotiation (transport-cc / goog-remb)
                // from the offer: the engine never answers it, and negotiating it
                // starves the libwebrtc sender to ~30 kbps. Open-loop = the fixed
                // bitrate applied in applyFixedVideoBitrate().
                val cleanSdp = SessionDescription(
                    sdp.type,
                    stripCongestionControl(sdp.description),
                )
                peerConnection!!.setLocalDescription(object : SdpObserver {
                    override fun onCreateSuccess(p0: SessionDescription?) {}
                    override fun onSetSuccess() {
                        Log.d(TAG, "Local description set — waiting for ICE gather")
                        // ICE gathering will trigger the resume via the observer
                        // Safety timeout
                        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                            if (cont.isActive) {
                                val sdpStr = peerConnection?.localDescription?.description ?: ""
                                Log.w(TAG, "ICE gather timeout — using partial SDP")
                                cont.resume(sdpStr)
                            }
                        }, ICE_GATHER_TIMEOUT_MS)
                    }
                    override fun onCreateFailure(p0: String?) {
                        Log.e(TAG, "setLocalDescription failed: $p0")
                        if (cont.isActive) cont.resume("")
                    }
                    override fun onSetFailure(p0: String?) {
                        Log.e(TAG, "setLocalDescription failed: $p0")
                        if (cont.isActive) cont.resume("")
                    }
                }, cleanSdp)
            }
            override fun onCreateFailure(error: String?) {
                Log.e(TAG, "createOffer failed: $error")
                if (cont.isActive) cont.resume("")
            }
            override fun onSetSuccess() {}
            override fun onSetFailure(p0: String?) {}
        }, constraints)
    }

    /**
     * Applies the SDP answer received from the WHIP POST.
     */
    fun setAnswer(answerSdp: String) {
        val pc = peerConnection ?: return
        pc.setRemoteDescription(object : SdpObserver {
            override fun onCreateSuccess(p0: SessionDescription?) {}
            override fun onSetSuccess() {
                Log.i(TAG, "Remote description (answer) set — media path opening")
            }
            override fun onCreateFailure(p0: String?) {}
            override fun onSetFailure(p0: String?) {
                Log.e(TAG, "setRemoteDescription failed: $p0")
            }
        }, SessionDescription(SessionDescription.Type.ANSWER, answerSdp))
    }

    /**
     * Returns outbound video stats for the watchdog.
     * Returns (framesEncoded, bytesSent) or null if unavailable.
     */
    fun getVideoStats(): Pair<Long, Long>? {
        val pc = peerConnection ?: return null
        val latch = CountDownLatch(1)
        var result: Pair<Long, Long>? = null

        pc.getStats { report ->
            for (stats in report.statsMap.values) {
                if (stats.type == "outbound-rtp" && stats.members["kind"] == "video") {
                    val frames = (stats.members["framesEncoded"] as? Number)?.toLong() ?: 0L
                    val bytes = (stats.members["bytesSent"] as? Number)?.toLong() ?: 0L
                    result = Pair(frames, bytes)
                }
            }
            latch.countDown()
        }

        latch.await(2, TimeUnit.SECONDS)
        return result
    }

    /**
     * Switches between front and rear cameras.
     */
    fun switchCamera() {
        cameraCapturer?.switchCamera(null)
    }

    /**
     * Toggles the torch (flashlight) on the current camera.
     */
    fun setTorch(enabled: Boolean) {
        // Camera2Capturer doesn't expose torch control directly.
        // A custom Camera2Capturer subclass would be needed for torch.
        Log.w(TAG, "Torch control not yet implemented in native engine")
    }

    /**
     * Releases all resources: camera, tracks, PeerConnection, factory.
     */
    fun release() {
        Log.i(TAG, "Releasing BroadcasterEngine")
        cameraCapturer?.stopCapture()
        cameraCapturer = null
        videoTrack?.dispose()
        audioTrack?.dispose()
        videoSource?.dispose()
        audioSource?.dispose()
        peerConnection?.close()
        peerConnection?.dispose()
        peerConnection = null
        previewRenderer?.release()
        previewRenderer = null
        factory?.dispose()
        factory = null
        eglBase?.release()
        eglBase = null
    }
}

/**
 * Video encoder factory that offers ONLY H.264 when the device has any
 * hardware H.264 encoder. Low-end phones (Samsung J-series) typically lack a
 * hardware VP8 encoder; unrestricted negotiation then lands on software VP8,
 * which stalls and emits almost no frames. Falls back to the delegate's full
 * codec list when no H.264 encoder exists.
 */
private class H264PreferredEncoderFactory(
    private val delegate: VideoEncoderFactory,
) : VideoEncoderFactory {
    override fun createEncoder(info: VideoCodecInfo): VideoEncoder? = delegate.createEncoder(info)

    override fun getSupportedCodecs(): Array<VideoCodecInfo> {
        val all = delegate.getSupportedCodecs()
        val h264 = all.filter { it.name.equals("H264", ignoreCase = true) }
        return if (h264.isNotEmpty()) h264.toTypedArray() else all
    }
}

/**
 * Base PeerConnection.Observer with no-op defaults.
 * Subclasses override only the callbacks they care about.
 */
abstract class PeerConnectionObserver : PeerConnection.Observer {
    override fun onSignalingChange(state: PeerConnection.SignalingState?) {}
    override fun onIceConnectionChange(state: PeerConnection.IceConnectionState?) {}
    override fun onIceConnectionReceivingChange(receiving: Boolean) {}
    override fun onIceGatheringChange(state: PeerConnection.IceGatheringState?) {}
    override fun onIceCandidate(candidate: IceCandidate?) {}
    override fun onIceCandidatesRemoved(candidates: Array<out IceCandidate>?) {}
    override fun onAddStream(stream: MediaStream?) {}
    override fun onRemoveStream(stream: MediaStream?) {}
    override fun onDataChannel(dc: DataChannel?) {}
    override fun onRenegotiationNeeded() {}
    override fun onAddTrack(receiver: RtpReceiver?, streams: Array<out MediaStream>?) {}
    override fun onTrack(transceiver: RtpTransceiver?) {}
    override fun onRemoveTrack(receiver: RtpReceiver?) {}
}
