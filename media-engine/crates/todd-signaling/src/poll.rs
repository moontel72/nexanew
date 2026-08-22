//! Spectator polling hub — Phase 5 fan engagement.
//!
//! Per-room polls with live vote aggregation. Votes are accepted on a
//! public endpoint (same trust boundary as the telemetry feed — they are
//! broadcast-grade public engagement data, not control-plane state) and
//! every change is fanned out to director panels as a `poll_changed`
//! control event so the animated lower-third updates in real time.

use std::sync::Arc;

use dashmap::DashMap;
use serde::Serialize;

/// One answer option with its live tally.
#[derive(Debug, Clone, Serialize)]
pub struct PollOption {
    pub label: String,
    pub votes: u64,
}

/// Full poll state for one room.
#[derive(Debug, Clone, Serialize)]
pub struct PollState {
    pub question: String,
    pub options: Vec<PollOption>,
    pub active: bool,
    pub updated_at_ms: i64,
}

pub struct PollHub {
    polls: DashMap<String, PollState>,
}

impl PollHub {
    pub fn new() -> Self {
        Self {
            polls: DashMap::new(),
        }
    }

    /// Creates or replaces a room's poll (votes reset).
    pub fn set(&self, room_id: &str, question: String, options: Vec<String>) -> PollState {
        let state = PollState {
            question,
            options: options
                .into_iter()
                .map(|label| PollOption { label, votes: 0 })
                .collect(),
            active: true,
            updated_at_ms: now_ms(),
        };
        self.polls.insert(room_id.to_string(), state.clone());
        state
    }

    /// Registers one vote. `option` is the option index; out-of-range
    /// votes are ignored. Returns the updated state (or None for an
    /// unknown/inactive poll).
    pub fn vote(&self, room_id: &str, option: usize) -> Option<PollState> {
        let mut entry = self.polls.get_mut(room_id)?;
        if !entry.active {
            return None;
        }
        let target = entry.options.get_mut(option)?;
        target.votes += 1;
        entry.updated_at_ms = now_ms();
        Some(entry.clone())
    }

    pub fn get(&self, room_id: &str) -> Option<PollState> {
        self.polls.get(room_id).map(|entry| entry.value().clone())
    }

    pub fn clear(&self, room_id: &str) {
        self.polls.remove(room_id);
    }

    /// All live polls (room_id, state) — used by the control snapshot.
    pub fn all(&self) -> Vec<(String, PollState)> {
        let mut polls: Vec<(String, PollState)> = self
            .polls
            .iter()
            .map(|entry| (entry.key().clone(), entry.value().clone()))
            .collect();
        polls.sort_by(|a, b| a.0.cmp(&b.0));
        polls
    }
}

fn now_ms() -> i64 {
    chrono::Utc::now().timestamp_millis()
}

/// Control-plane wrapper: poll state paired with its room (serde contract
/// shared with the TypeScript client).
#[derive(Debug, Clone, Serialize)]
pub struct PollSnapshot {
    pub room_id: String,
    #[serde(flatten)]
    pub poll: PollState,
}

pub fn snapshot_entries(hub: &Arc<PollHub>) -> Vec<PollSnapshot> {
    hub.all()
        .into_iter()
        .map(|(room_id, poll)| PollSnapshot { room_id, poll })
        .collect()
}
