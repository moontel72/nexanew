package com.todd.broadcaster.whip

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class IngestUrlTest {

    private val fullUrl =
        "https://studio.traceodd.com/api/v1/whip/ingest/" +
            "d4683c95-0d0f-4f92-b0eb-c9635c3b7899/Cam-04" +
            "?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.payload.sig"

    @Test
    fun `parses full ingest url into base room camera and token`() {
        val c = IngestUrl.parse(fullUrl)
        assertEquals("https://studio.traceodd.com", c?.baseUrl)
        assertEquals("d4683c95-0d0f-4f92-b0eb-c9635c3b7899", c?.roomId)
        assertEquals("Cam-04", c?.cameraId)
        assertEquals("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.payload.sig", c?.token)
    }

    @Test
    fun `base url is cut before the whip ingest marker`() {
        val c = IngestUrl.parse(fullUrl)
        assertEquals("https://studio.traceodd.com", c?.baseUrl)
    }

    @Test
    fun `accepts trailing slash on camera segment`() {
        val c = IngestUrl.parse(fullUrl.replace("Cam-04?", "Cam-04/?"))
        assertEquals("Cam-04", c?.cameraId)
    }

    @Test
    fun `accepts extra query parameters after token`() {
        val withExtra = fullUrl + "&foo=bar"
        assertEquals("Cam-04", IngestUrl.parse(withExtra)?.cameraId)
        assertEquals(
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.payload.sig",
            IngestUrl.parse(withExtra)?.token
        )
    }

    @Test
    fun `rejects strings without the whip ingest marker`() {
        assertNull(IngestUrl.parse("https://studio.traceodd.com"))
        assertNull(IngestUrl.parse(""))
    }

    @Test
    fun `rejects urls missing room camera or token`() {
        assertNull(
            IngestUrl.parse("https://studio.traceodd.com/api/v1/whip/ingest/room-only?token=abc")
        )
        assertNull(
            IngestUrl.parse(
                "https://studio.traceodd.com/api/v1/whip/ingest/room/cam-no-token"
            )
        )
    }
}
