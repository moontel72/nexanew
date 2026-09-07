package com.todd.broadcaster.telemetry

import android.os.Build

/**
 * Device health snapshot for the telemetry WebSocket.
 * Mirrors the Flutter app's DeviceHealth model.
 */
data class DeviceHealth(
    val cameraId: String,
    val phase: String,         // "idle", "connecting", "live", "error"
    val connected: Boolean,
    val audioMuted: Boolean,
    val videoFrozen: Boolean,
    val uplinkKbps: Double?,
    val fps: Double?,
    val framesEncoded: Long,
    val framesSent: Long,
    val bytesSent: Long,
    val iceConnectionState: String,
    val signalingState: String,
    val deviceModel: String,
    val androidVersion: String,
    val sdkVersion: String,
    val timestamp: Long,
) {
    companion object {
        fun empty(cameraId: String): DeviceHealth = DeviceHealth(
            cameraId = cameraId,
            phase = "idle",
            connected = false,
            audioMuted = false,
            videoFrozen = false,
            uplinkKbps = null,
            fps = null,
            framesEncoded = 0,
            framesSent = 0,
            bytesSent = 0,
            iceConnectionState = "new",
            signalingState = "stable",
            deviceModel = "${Build.MANUFACTURER} ${Build.MODEL}",
            androidVersion = Build.VERSION.RELEASE,
            sdkVersion = "native-1.0.0",
            timestamp = System.currentTimeMillis(),
        )
    }

    fun toJson(): String {
        return """
        {
            "cameraId": "$cameraId",
            "phase": "$phase",
            "connected": $connected,
            "audioMuted": $audioMuted,
            "videoFrozen": $videoFrozen,
            "uplinkKbps": ${uplinkKbps ?: "null"},
            "fps": ${fps ?: "null"},
            "framesEncoded": $framesEncoded,
            "framesSent": $framesSent,
            "bytesSent": $bytesSent,
            "iceConnectionState": "$iceConnectionState",
            "signalingState": "$signalingState",
            "deviceModel": "$deviceModel",
            "androidVersion": "$androidVersion",
            "sdkVersion": "$sdkVersion",
            "timestamp": $timestamp
        }
        """.trimIndent()
    }
}
