package com.todd.broadcaster.media

import android.media.MediaCodecInfo
import android.os.Build

/**
 * Device-tuned encoder parameters for hardware H264 encoding.
 *
 * Low-end devices (Samsung Galaxy J-series, older MediaTek chipsets) have
 * MediaCodec implementations that silently stall or produce zero frames
 * when configured with aggressive parameters. These settings prioritize
 * reliability over quality:
 *
 * - Baseline profile (maximum decoder compatibility)
 * - Level 3.1 (720p@30fps ceiling)
 * - 2-second keyframe interval (fast recovery for WHEP viewers)
 * - CBR bitrate mode (constant bitrate for streaming — avoids VBR spikes
 *   that overwhelm low-end encoders)
 * - Color format: surface (hardware-accelerated, no CPU copy)
 */
object EncoderConfig {

    /** H264 profile: Constrained Baseline for maximum compatibility. */
    const val H264_PROFILE = MediaCodecInfo.CodecProfileLevel.AVCProfileBaseline

    /** H264 level: 3.1 supports up to 720p@30fps. */
    const val H264_LEVEL = MediaCodecInfo.CodecProfileLevel.AVCLevel31

    /**
     * Keyframe interval in seconds. 2s means the encoder inserts an IDR
     * every 2 seconds. This is critical for WHEP viewers joining mid-stream:
     * they can start rendering within 2s instead of waiting for the next
     * natural IDR (which could be 10s+ on some encoders).
     */
    const val KEYFRAME_INTERVAL_SEC = 2

    /**
     * Bitrate mode: constant bitrate. VBR causes burst spikes that
     * overwhelm low-end encoders and saturate the uplink.
     */
    const val BITRATE_MODE = MediaCodecInfo.EncoderCapabilities.BITRATE_MODE_CBR

    /**
     * I-frame interval as a ratio. Some encoders use KEY_FRAME_INTERVAL
     * (seconds), others use I_FRAME_INTERVAL (same value). We set both.
     */
    const val I_FRAME_INTERVAL = 2

    /**
     * Whether to use surface input (hardware-accelerated, zero-copy from
     * camera to encoder). This is the fastest path and avoids CPU frame
     * copies that cause latency on low-end devices.
     */
    const val USE_SURFACE_INPUT = true

    /**
     * Default capture profiles offered in the UI.
     * (label, width, height, bitrateKbps)
     */
    data class Profile(
        val label: String,
        val width: Int,
        val height: Int,
        val bitrateKbps: Int,
    )

    val PROFILES = listOf(
        Profile("360p", 640, 360, 500),
        Profile("480p", 854, 480, 800),
        Profile("720p", 1280, 720, 2500),
        Profile("1080p", 1920, 1080, 4500),
    )

    val DEFAULT_PROFILE = PROFILES[1] // 480p — stable on low-end devices

    /**
     * Returns the best color format for hardware encoding on this device.
     * Surface input (API 23+) is preferred; falls back to YUV420 semi-planar.
     */
    fun preferredColorFormat(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface
        } else {
            MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar
        }
    }

    /**
     * Returns true if this device is known to have a problematic hardware
     * encoder that needs extra tuning (longer warmup, lower initial bitrate).
     */
    fun isLowEndDevice(): Boolean {
        val model = Build.MODEL.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        // Samsung J-series, Galaxy Grand, Galaxy Core
        if (manufacturer.contains("samsung") &&
            (model.contains("j5") || model.contains("j7") ||
             model.contains("j2") || model.contains("j1") ||
             model.contains("grand") || model.contains("core"))) {
            return true
        }
        return false
    }
}
