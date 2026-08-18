//! Browser-based WHIP/WHEP test page (dev tool).
//!
//! Served at GET /whiptest only when `DEV_TEST_PAGE=1`. It lives on the
//! Studio's own origin, so the page's fetch() calls are same-origin and
//! need no CORS configuration — the fastest possible way to validate the
//! full pipeline (camera/screen → WHIP → engine → WHEP → browser) with
//! zero third-party tools. This page is the stepping stone toward the
//! full T-Odd Studio UI (Tauri/Web).

use axum::response::Html;

/// The single-file page is embedded at compile time. Keep it in sync with
/// `web/whiptest.html`.
pub async fn whiptest_page() -> Html<&'static str> {
    Html(include_str!("../../../../web/whiptest.html"))
}
