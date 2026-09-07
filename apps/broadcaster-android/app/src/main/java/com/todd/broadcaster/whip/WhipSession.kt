package com.todd.broadcaster.whip

/**
 * A live WHIP ingest session: the PeerConnection reference plus the
 * resource URL from the 201 Location header (for DELETE on teardown).
 */
data class WhipSession(
    val resourceUrl: String?,
    val token: String,
    val answerSdp: String,
)

/**
 * Result of a WHIP POST attempt.
 */
sealed class WhipResult {
    data class Success(val session: WhipSession) : WhipResult()
    data class Failure(val statusCode: Int, val message: String) : WhipResult()
}
