package com.todd.broadcaster.whip

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.concurrent.TimeUnit

/**
 * WHIP (WebRTC-HTTP Ingest Protocol) client.
 *
 * Sends the complete SDP offer (with all ICE candidates gathered) to the
 * Rust media engine via HTTP POST and parses the 201 response containing
 * the SDP answer + Location header for session teardown.
 *
 * This is a non-trickle implementation matching the engine's expectations:
 * the offer must contain all ICE candidates before posting.
 */
class WhipClient(
    private val baseUrl: String,
) {
    companion object {
        private const val TAG = "WhipClient"
        private val SDP_MEDIA_TYPE = "application/sdp".toMediaType()
    }

    private val httpClient = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(15, TimeUnit.SECONDS)
        .build()

    /**
     * Posts a WHIP offer to the engine and returns the result.
     *
     * @param roomId   The room identifier.
     * @param cameraId The camera slot identifier.
     * @param token    The ingest bearer token.
     * @param offerSdp The complete SDP offer (with all ICE candidates).
     * @return [WhipResult.Success] with the session, or [WhipResult.Failure].
     */
    suspend fun connect(
        roomId: String,
        cameraId: String,
        token: String,
        offerSdp: String,
    ): WhipResult = withContext(Dispatchers.IO) {
        val normalizedBase = normalizeBaseUrl(baseUrl)
        val url = "$normalizedBase/api/v1/whip/ingest/$roomId/$cameraId?token=$token"

        Log.d(TAG, "WHIP POST → $normalizedBase/api/v1/whip/ingest/$roomId/$cameraId")

        val request = Request.Builder()
            .url(url)
            .post(offerSdp.toRequestBody(SDP_MEDIA_TYPE))
            .header("Content-Type", "application/sdp")
            .apply {
                if (token.isNotEmpty()) {
                    header("Authorization", "Bearer $token")
                }
            }
            .build()

        try {
            val response = httpClient.newCall(request).execute()
            val body = response.body.string()

            if (response.code == 201) {
                val location = response.header("Location")
                Log.i(TAG, "WHIP ingest accepted (201) — resource=$location")
                WhipResult.Success(
                    WhipSession(
                        resourceUrl = location,
                        token = token,
                        answerSdp = body,
                    )
                )
            } else {
                val hint = hintFor(response.code)
                Log.w(TAG, "WHIP ingest rejected (${response.code}): $hint — $body")
                WhipResult.Failure(
                    statusCode = response.code,
                    message = "WHIP rejected (${response.code}): $hint",
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "WHIP POST failed: ${e.message}", e)
            WhipResult.Failure(
                statusCode = 0,
                message = "Network error: ${e.message ?: "unknown"}",
            )
        }
    }

    /**
     * Sends a DELETE to the WHIP resource URL to cleanly tear down the
     * session. Best-effort: errors are silently ignored so the caller
     * can proceed with local teardown regardless.
     */
    suspend fun disconnect(session: WhipSession) = withContext(Dispatchers.IO) {
        val url = session.resourceUrl ?: return@withContext
        try {
            val request = Request.Builder()
                .url(url)
                .delete()
                .apply {
                    if (session.token.isNotEmpty()) {
                        header("Authorization", "Bearer ${session.token}")
                    }
                }
                .build()
            httpClient.newCall(request).execute().close()
            Log.d(TAG, "WHIP DELETE → $url")
        } catch (e: Exception) {
            Log.w(TAG, "WHIP DELETE failed (ignored): ${e.message}")
        }
    }

    /**
     * Maps a rejected ingest status code to an actionable hint for the
     * operator. Mirrors the Flutter app's `_hintFor` logic.
     */
    private fun hintFor(statusCode: Int): String = when (statusCode) {
        401 -> "ingest token expired or invalid — generate a fresh one in the Studio"
        403 -> "token is scoped to a different room/camera"
        404 -> "room or camera not found — verify the WHIP URL"
        409 -> "camera slot occupied — wait for previous session to close"
        429 -> "too many attempts — wait a moment"
        else -> "check the engine base URL and connectivity"
    }

    /**
     * Strips any trailing path segments pasted into the base URL field
     * (e.g. the operator pastes the full ingest URL instead of just the origin).
     */
    private fun normalizeBaseUrl(raw: String): String {
        var url = raw.trim()
        val marker = "/api/v1/whip/ingest/"
        val idx = url.indexOf(marker)
        if (idx != -1) {
            url = url.substring(0, idx)
        }
        while (url.endsWith("/")) {
            url = url.dropLast(1)
        }
        return url
    }
}
