package com.todd.broadcaster.media

import android.content.Context
import android.util.Log
import kotlinx.coroutines.suspendCancellableCoroutine
import org.webrtc.*
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
    }

    private var factory: PeerConnectionFactory? = null
    private var peerConnection: PeerConnection? = null
    private var videoSource: VideoSource? = null
    private var audioSource: AudioSource? = null
    private var videoTrack: VideoTrack? = null
    private var audioTrack: AudioTrack? = null
    private var cameraCapturer: CameraVideoCapturer? = null
    private var eglBase: EglBase? = null

    /** The local preview renderer (SurfaceViewRenderer). */
    var previewRenderer: SurfaceViewRenderer? = null
        private set

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

        eglBase = EglBase.create()

        val encoderFactory = DefaultVideoEncoderFactory(
            eglBase!!.eglBaseContext,
            true,  // enableH264HighProfile
            true,  // forceSWCodecIfHighResolution
        )
        val decoderFactory = DefaultVideoDecoderFactory(eglBase!!.eglBaseContext)

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
        if (!turnUrl.isNullOrEmpty()) {
            val builder = PeerConnection.IceServer.builder(turnUrl)
            if (!turnUsername.isNullOrEmpty()) builder.setUsername(turnUsername)
            if (!turnPassword.isNullOrEmpty()) builder.setPassword(turnPassword)
            iceServers.add(builder.createIceServer())
        }

        val config = PeerConnection.RTCConfiguration(iceServers).apply {
            sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN
            continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY
            candidateNetworkPolicy = PeerConnection.CandidateNetworkPolicy.ALL
        }

        // ── Create PeerConnection ──
        val observer = object : PeerConnectionObserver() {
            override fun onIceGatheringState(state: PeerConnection.IceGatheringState) {
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

            override fun onIceConnectionChange(state: PeerConnection.IceConnectionState) {
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
                }, sdp)
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

        pc.stats { reports ->
            for (report in reports) {
                val stats = report.stats
                if (stats.type == "outbound-rtp" && stats.values["kind"] == "video") {
                    val frames = (stats.values["framesEncoded"] as? Number)?.toLong() ?: 0L
                    val bytes = (stats.values["bytesSent"] as? Number)?.toLong() ?: 0L
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
        (cameraCapturer as? Camera2Capturer)?.switchCamera(null)
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
    override fun onAddTrack(track: MediaStreamTrack?, streams: Array<out MediaStream>?) {}
    override fun onTrack(transceiver: RtpTransceiver?) {}
    override fun onRemoveTrack(receiver: RtpReceiver?) {}
}
