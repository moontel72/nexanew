package com.todd.broadcaster.telemetry

import android.util.Log
import kotlinx.coroutines.*
import okhttp3.*
import java.util.concurrent.TimeUnit

/**
 * WebSocket telemetry client that pushes device health snapshots to the
 * Rust media engine at regular intervals.
 *
 * Matches the Flutter app's DeviceTelemetry behavior:
 * - Connects to ws://{host}/api/v1/telemetry/ws?token={token}
 * - Sends JSON health snapshots every 5 seconds
 * - Auto-reconnects on disconnect with exponential backoff
 * - Silently ignores send failures (telemetry is best-effort)
 */
class DeviceTelemetry(
    private val baseUrl: String,
    private val token: String,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob()),
) {
    companion object {
        private const val TAG = "DeviceTelemetry"
        private const val HEALTH_INTERVAL_MS = 5_000L
        private const val MAX_RECONNECT_DELAY_MS = 30_000L
    }

    private var webSocket: WebSocket? = null
    private var healthJob: Job? = null
    private var reconnectAttempts = 0
    private var currentHealth: DeviceHealth? = null

    private val httpClient = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(0, TimeUnit.MINUTES)  // WebSocket keeps alive indefinitely
        .writeTimeout(10, TimeUnit.SECONDS)
        .build()

    /**
     * Opens the telemetry WebSocket and starts periodic health pushes.
     */
    fun start() {
        val wsUrl = buildWsUrl()
        Log.i(TAG, "Connecting telemetry WS → $wsUrl")

        val request = Request.Builder()
            .url(wsUrl)
            .build()

        webSocket = httpClient.newWebSocket(request, object : WebSocketListener() {
            override fun onOpen(webSocket: WebSocket, response: Response) {
                Log.i(TAG, "Telemetry WS connected")
                reconnectAttempts = 0
                startHealthPush()
            }

            override fun onMessage(webSocket: WebSocket, text: String) {
                // Engine may send ack or commands; ignore for now
                Log.d(TAG, "WS message: $text")
            }

            override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
                Log.i(TAG, "Telemetry WS closed: $code $reason")
                stopHealthPush()
                scheduleReconnect()
            }

            override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                Log.w(TAG, "Telemetry WS failure: ${t.message}")
                stopHealthPush()
                scheduleReconnect()
            }
        })
    }

    /**
     * Updates the health snapshot that will be sent on the next tick.
     */
    fun updateHealth(health: DeviceHealth) {
        currentHealth = health
    }

    /**
     * Stops the telemetry WS and cancels all background work.
     */
    fun stop() {
        Log.i(TAG, "Stopping telemetry")
        stopHealthPush()
        webSocket?.close(1000, "Client disconnect")
        webSocket = null
        scope.cancel()
    }

    private fun buildWsUrl(): String {
        var url = baseUrl.trim()
        // Strip any path pasted into the URL
        val marker = "/api/v1/whip/ingest/"
        val idx = url.indexOf(marker)
        if (idx != -1) url = url.substring(0, idx)
        while (url.endsWith("/")) url = url.dropLast(1)

        // Convert http(s) to ws(s)
        url = url.replace("https://", "wss://")
        url = url.replace("http://", "ws://")

        return "$url/api/v1/telemetry/ws?token=$token"
    }

    private fun startHealthPush() {
        healthJob?.cancel()
        healthJob = scope.launch {
            while (isActive) {
                val health = currentHealth
                if (health != null) {
                    val json = health.toJson()
                    webSocket?.send(json)
                    Log.v(TAG, "Health pushed: phase=${health.phase} fps=${health.fps}")
                }
                delay(HEALTH_INTERVAL_MS)
            }
        }
    }

    private fun stopHealthPush() {
        healthJob?.cancel()
        healthJob = null
    }

    private fun scheduleReconnect() {
        if (reconnectAttempts > 10) {
            Log.w(TAG, "Max reconnect attempts reached — giving up")
            return
        }
        val delayMs = minOf(
            (1000L * (1 shl reconnectAttempts)),
            MAX_RECONNECT_DELAY_MS
        )
        reconnectAttempts++
        Log.d(TAG, "Reconnecting in ${delayMs}ms (attempt $reconnectAttempts)")
        scope.launch {
            delay(delayMs)
            start()
        }
    }
}
