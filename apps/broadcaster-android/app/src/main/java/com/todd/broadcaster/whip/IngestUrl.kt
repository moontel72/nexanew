package com.todd.broadcaster.whip

/**
 * Parsed components of a full WHIP ingest URL.
 *
 * Shape (as shared by the director):
 *   https://studio.traceodd.com/api/v1/whip/ingest/{room}/{camera}?token={jwt}
 *
 * The base URL is everything before "/api/v1/whip/ingest/", the room and
 * camera are the next two path segments, and the token is the value of the
 * "token" query parameter after the "?".
 */
data class IngestCredentials(
    val baseUrl: String,
    val roomId: String,
    val cameraId: String,
    val token: String,
)

object IngestUrl {

    private const val MARKER = "/api/v1/whip/ingest/"

    /**
     * Splits a full ingest URL (as pasted from the director / Studio) into
     * base URL, room id, camera id and token. Returns null when the string
     * does not have the expected WHIP ingest shape.
     */
    fun parse(fullUrl: String): IngestCredentials? {
        val url = fullUrl.trim()
        val markerIdx = url.indexOf(MARKER)
        if (markerIdx == -1) return null

        val base = url.substring(0, markerIdx).trimEnd('/')
        var rest = url.substring(markerIdx + MARKER.length)

        // Token lives in the query string after "?"; the "?" also marks the
        // end of the camera path segment.
        var token = ""
        val queryIdx = rest.indexOf('?')
        if (queryIdx != -1) {
            val query = rest.substring(queryIdx + 1)
            rest = rest.substring(0, queryIdx)
            token = query
                .split('&')
                .firstOrNull { it.startsWith("token=") }
                ?.substring("token=".length)
                ?.trim()
                ?: ""
        }

        val parts = rest.trim('/').split('/')
        if (parts.size != 2 || parts.any { it.isBlank() } || token.isEmpty()) {
            return null
        }
        return IngestCredentials(
            baseUrl = base,
            roomId = parts[0],
            cameraId = parts[1],
            token = token,
        )
    }
}
