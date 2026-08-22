//! Innings highlight playlist — Phase 5 automated highlight generation.
//!
//! A background collector: every auto-tagged replay (boundary / wicket /
//! catch / milestone, created by the Phase 3 auto-replay pipeline) is
//! recorded into an ordered playlist the director and downstream
//! exporters can read. Entries are kept in memory (bounded) and pushed
//! to director panels as `highlight_added` control events.

use serde::Serialize;
use tokio::sync::RwLock;

#[derive(Debug, Clone, Serialize)]
pub struct HighlightEntry {
    pub replay_id: String,
    /// "four" | "six" | "wicket" | "catch" | "milestone"
    pub event: String,
    pub match_id: Option<String>,
    pub created_at_ms: u64,
}

pub struct Highlights {
    /// Newest first.
    entries: RwLock<Vec<HighlightEntry>>,
}

const MAX_ENTRIES: usize = 200;

impl Highlights {
    pub fn new() -> Self {
        Self {
            entries: RwLock::new(Vec::new()),
        }
    }

    /// Records one auto-tagged clip and returns the stored entry.
    pub async fn record(&self, entry: HighlightEntry) -> HighlightEntry {
        let mut entries = self.entries.write().await;
        entries.insert(0, entry.clone());
        entries.truncate(MAX_ENTRIES);
        entry
    }

    pub async fn list(&self) -> Vec<HighlightEntry> {
        self.entries.read().await.clone()
    }
}
