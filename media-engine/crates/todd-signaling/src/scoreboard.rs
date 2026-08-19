//! Cricket Manager score synchronizer.
//!
//! Polls the TraceOdd Cricket Manager REST feed
//! (`{CRICKET_MANAGER_URL}/api/v1/cricket/live/{match_id}`) and caches the
//! latest ball-by-ball state in [`ScoreboardHub`]. The Studio UI reads the
//! cached state over `GET /api/v1/cricket/live/{match_id}` and receives
//! pushes over `GET /api/v1/cricket/ws`.
//!
//! The match list, poll interval and API token are **runtime
//! configurable** (see [`ScoreboardHub::update_config`]) instead of being
//! fixed to the environment at startup; the env values only seed the
//! initial configuration.
//!
//! The manager's JSON shape is still being finalized on the cloud side, so
//! [`map_ball_by_ball`] is the single place to adapt the response. Unknown
//! fields are ignored; missing fields fall back to broadcast-safe defaults.

use std::sync::Arc;
use std::time::{Duration, Instant};

use dashmap::DashMap;
use serde::{Deserialize, Serialize};
use todd_common::error::AppError;
use tokio::sync::RwLock;

/// Broadcast lower-third state for one match. Mirrors the Studio UI's
/// `BallByBallState` TypeScript type (snake_case JSON).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BallByBallState {
    pub match_id: String,
    pub batting_team: String,
    pub bowling_team: String,
    pub runs: u32,
    pub wickets: u32,
    pub overs: f64,
    pub run_rate: f64,
    pub batter_on_strike: String,
    pub batter_non_strike: String,
    pub bowler: String,
    pub recent_balls: Vec<String>,
    pub updated_at_ms: i64,
}

/// Minimal view of the environment-driven settings used to seed the
/// initial sync configuration. Keeps the module free of a hard dependency
/// on the full `Settings` struct and makes the mapping unit-testable.
#[derive(Debug, Clone)]
pub struct ScoreboardSettings {
    pub base_url: String,
    pub match_ids: Vec<String>,
    pub poll_ms: u64,
}

impl ScoreboardSettings {
    pub fn new(base_url: String, match_ids: Vec<String>, poll_ms: u64) -> Self {
        Self {
            base_url: base_url.trim_end_matches('/').to_string(),
            match_ids,
            poll_ms,
        }
    }

    /// Seeds the runtime configuration. A match added via env has no
    /// separate label yet, so the label mirrors the match id until a
    /// director customizes it through `PUT /api/v1/cricket/config`.
    fn into_config(self) -> ScoreboardConfig {
        ScoreboardConfig {
            base_url: self.base_url,
            match_configs: self
                .match_ids
                .into_iter()
                .map(|match_id| CricketMatchConfig {
                    label: match_id.clone(),
                    match_id,
                })
                .collect(),
            poll_ms: self.poll_ms,
            api_token: None,
        }
    }
}

/// One match the poller keeps synced.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CricketMatchConfig {
    /// Stable identifier in the Cricket Manager.
    pub match_id: String,
    /// Director-facing name shown in the Studio settings panel.
    #[serde(default)]
    pub label: String,
}

/// Health of the sync for one match.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum MatchSyncState {
    /// Never fetched successfully yet.
    Pending,
    /// Last poll succeeded.
    Synced,
    /// Last poll failed; the previous score (if any) is still shown.
    Error,
}

/// Sync status of one match, reported in the config view.
#[derive(Debug, Clone, Serialize)]
pub struct MatchSyncStatus {
    pub match_id: String,
    pub state: MatchSyncState,
    /// Timestamp (ms) of the last successful fetch, when one exists.
    #[serde(default)]
    pub last_ok_at_ms: Option<i64>,
    /// Message of the last failed fetch, when one exists.
    #[serde(default)]
    pub last_error: Option<String>,
}

/// Read model served by `GET /api/v1/cricket/config` and broadcast on the
/// control-plane WebSocket. The API token itself is never echoed back —
/// only whether one is configured.
#[derive(Debug, Clone, Serialize)]
pub struct CricketConfigView {
    /// Manager origin the engine polls (deployment config, read-only).
    pub base_url: String,
    pub match_configs: Vec<CricketMatchConfig>,
    pub poll_ms: u64,
    pub api_token_set: bool,
    pub sync: Vec<MatchSyncStatus>,
}

/// Body of `PUT /api/v1/cricket/config`. Omitted fields keep their
/// current value; `match_configs` is always replaced wholesale (send the
/// full list).
#[derive(Debug, Clone, Default, Deserialize)]
pub struct CricketConfigUpdate {
    #[serde(default)]
    pub match_configs: Vec<CricketMatchConfig>,
    #[serde(default)]
    pub poll_ms: Option<u64>,
    #[serde(default)]
    pub api_token: Option<String>,
}

/// Runtime sync configuration, mutated by the config endpoint.
#[derive(Debug, Clone)]
pub struct ScoreboardConfig {
    pub base_url: String,
    pub match_configs: Vec<CricketMatchConfig>,
    pub poll_ms: u64,
    pub api_token: Option<String>,
}

/// Flexible manager response. `recent_balls` can arrive as an array of
/// objects or plain strings; keep parsing tolerant.
#[derive(Debug, Clone, Deserialize)]
pub struct ManagerResponse {
    pub match_id: String,
    #[serde(default)]
    pub innings: Option<ManagerInnings>,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct ManagerInnings {
    #[serde(default)]
    pub batting_team: Option<String>,
    #[serde(default)]
    pub bowling_team: Option<String>,
    #[serde(default)]
    pub score: Option<u32>,
    #[serde(default)]
    pub wickets: Option<u32>,
    #[serde(default)]
    pub balls: Option<u32>,
    #[serde(default)]
    pub batter_on_strike: Option<String>,
    #[serde(default)]
    pub batter_non_strike: Option<String>,
    #[serde(default)]
    pub bowler: Option<String>,
    #[serde(default)]
    pub recent_balls: Option<Vec<ManagerBall>>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(untagged)]
pub enum ManagerBall {
    Str(String),
    Object { result: Option<String> },
}

impl ManagerBall {
    fn result(&self) -> String {
        match self {
            ManagerBall::Str(s) => s.clone(),
            ManagerBall::Object { result } => result.clone().unwrap_or_else(|| "·".to_string()),
        }
    }
}

fn map_ball_by_ball(raw: ManagerResponse) -> BallByBallState {
    let inn = raw.innings.unwrap_or_default();
    let balls = inn.balls.unwrap_or(0);
    let score = inn.score.unwrap_or(0);
    BallByBallState {
        match_id: raw.match_id,
        batting_team: inn.batting_team.unwrap_or_else(|| "Batting".to_string()),
        bowling_team: inn.bowling_team.unwrap_or_else(|| "Bowling".to_string()),
        runs: score,
        wickets: inn.wickets.unwrap_or(0),
        overs: f64::from(balls) / 6.0,
        run_rate: if balls > 0 {
            f64::from(score) / (f64::from(balls) / 6.0)
        } else {
            0.0
        },
        batter_on_strike: inn.batter_on_strike.unwrap_or_else(|| "—".to_string()),
        batter_non_strike: inn.batter_non_strike.unwrap_or_else(|| "—".to_string()),
        bowler: inn.bowler.unwrap_or_else(|| "—".to_string()),
        recent_balls: inn
            .recent_balls
            .unwrap_or_default()
            .iter()
            .map(ManagerBall::result)
            .collect(),
        updated_at_ms: chrono::Utc::now().timestamp_millis(),
    }
}

/// Lower bound the poll interval can be configured to. Anything faster
/// hammers the manager origin for no broadcast benefit.
const MIN_POLL_MS: u64 = 500;

/// Thread-safe cache of the latest score per match id plus the runtime
/// sync configuration and per-match health.
pub struct ScoreboardHub {
    scores: DashMap<String, BallByBallState>,
    config: RwLock<ScoreboardConfig>,
    sync: DashMap<String, MatchSyncStatus>,
}

impl ScoreboardHub {
    pub fn new(config: ScoreboardConfig) -> Self {
        Self {
            scores: DashMap::new(),
            config: RwLock::new(config),
            sync: DashMap::new(),
        }
    }

    pub fn get(&self, match_id: &str) -> Option<BallByBallState> {
        self.scores.get(match_id).map(|entry| entry.value().clone())
    }

    /// All cached matches, sorted by match id for stable output.
    pub fn all(&self) -> Vec<BallByBallState> {
        let mut states: Vec<BallByBallState> = self
            .scores
            .iter()
            .map(|entry| entry.value().clone())
            .collect();
        states.sort_by(|a, b| a.match_id.cmp(&b.match_id));
        states
    }

    pub fn upsert(&self, state: BallByBallState) {
        self.scores.insert(state.match_id.clone(), state);
    }

    /// Records the outcome of one poll round for a match.
    pub fn record_sync(&self, match_id: &str, result: Result<(), String>) {
        let now = chrono::Utc::now().timestamp_millis();
        match result {
            Ok(()) => {
                self.sync.insert(
                    match_id.to_string(),
                    MatchSyncStatus {
                        match_id: match_id.to_string(),
                        state: MatchSyncState::Synced,
                        last_ok_at_ms: Some(now),
                        last_error: None,
                    },
                );
            }
            Err(message) => {
                // A failed poll keeps the last successful timestamp so the
                // UI can show how stale the displayed score is.
                let last_ok_at_ms = self
                    .sync
                    .get(match_id)
                    .and_then(|entry| entry.value().last_ok_at_ms);
                self.sync.insert(
                    match_id.to_string(),
                    MatchSyncStatus {
                        match_id: match_id.to_string(),
                        state: MatchSyncState::Error,
                        last_ok_at_ms,
                        last_error: Some(message),
                    },
                );
            }
        }
    }

    /// Read model for the config endpoints and the control-plane feed.
    pub async fn config_view(&self) -> CricketConfigView {
        let config = self.config.read().await.clone();
        let sync = config
            .match_configs
            .iter()
            .map(|match_config| {
                self.sync
                    .get(&match_config.match_id)
                    .map(|entry| entry.value().clone())
                    .unwrap_or_else(|| MatchSyncStatus {
                        match_id: match_config.match_id.clone(),
                        state: MatchSyncState::Pending,
                        last_ok_at_ms: None,
                        last_error: None,
                    })
            })
            .collect();
        CricketConfigView {
            base_url: config.base_url,
            match_configs: config.match_configs,
            poll_ms: config.poll_ms,
            api_token_set: config.api_token.is_some(),
            sync,
        }
    }

    /// Snapshot of the runtime config for the poller task.
    pub async fn current_config(&self) -> ScoreboardConfig {
        self.config.read().await.clone()
    }

    /// Applies a runtime config update and returns the resulting view.
    pub async fn update_config(
        &self,
        update: CricketConfigUpdate,
    ) -> Result<CricketConfigView, AppError> {
        for match_config in &update.match_configs {
            if match_config.match_id.trim().is_empty() {
                return Err(AppError::BadRequest(
                    "match_configs entries require a non-empty match_id".to_string(),
                ));
            }
        }

        let mut config = self.config.write().await;
        if let Some(poll_ms) = update.poll_ms {
            if poll_ms < MIN_POLL_MS {
                return Err(AppError::BadRequest(format!(
                    "poll_ms must be at least {MIN_POLL_MS}"
                )));
            }
            config.poll_ms = poll_ms;
        }
        if let Some(token) = update.api_token {
            // An explicit empty string clears the configured token.
            config.api_token = if token.trim().is_empty() {
                None
            } else {
                Some(token)
            };
        }
        config.match_configs = update.match_configs;

        // Drop health entries of matches that are no longer synced.
        let ids: Vec<String> = config
            .match_configs
            .iter()
            .map(|match_config| match_config.match_id.clone())
            .collect();
        drop(config);
        self.sync
            .retain(|match_id, _| ids.iter().any(|id| id == match_id));

        Ok(self.config_view().await)
    }
}

/// Spawns the poller and returns the shared hub.
pub fn spawn_sync(settings: ScoreboardSettings, client: reqwest::Client) -> Arc<ScoreboardHub> {
    let hub = Arc::new(ScoreboardHub::new(settings.into_config()));
    let hub_for_task = Arc::clone(&hub);
    tokio::spawn(async move {
        poll_loop(client, hub_for_task).await;
    });
    hub
}

async fn poll_loop(client: reqwest::Client, hub: Arc<ScoreboardHub>) {
    loop {
        // Read the config every round so runtime updates (match list,
        // poll interval, token) take effect without a restart.
        let config = hub.current_config().await;
        let started = Instant::now();

        for match_config in &config.match_configs {
            match fetch_match(
                &client,
                &config.base_url,
                &match_config.match_id,
                config.api_token.as_deref(),
            )
            .await
            {
                Ok(state) => {
                    hub.record_sync(&match_config.match_id, Ok(()));
                    hub.upsert(state);
                }
                Err(message) => {
                    hub.record_sync(&match_config.match_id, Err(message.clone()));
                    tracing::warn!(
                        match_id = %match_config.match_id,
                        error = %message,
                        "cricket score sync failed; keeping last known score"
                    );
                }
            }
        }

        let interval = Duration::from_millis(config.poll_ms.max(MIN_POLL_MS));
        let wait = interval.saturating_sub(started.elapsed());
        tokio::time::sleep(wait).await;
    }
}

async fn fetch_match(
    client: &reqwest::Client,
    base_url: &str,
    match_id: &str,
    api_token: Option<&str>,
) -> Result<BallByBallState, String> {
    let url = format!("{base_url}/api/v1/cricket/live/{match_id}");
    let mut request = client.get(&url);
    if let Some(token) = api_token {
        // Single adaptation point for the manager auth contract: the
        // token is sent as a bearer credential. Adjust here if the cloud
        // side settles on a different scheme.
        request = request.bearer_auth(token);
    }
    let resp = request
        .send()
        .await
        .map_err(|e| e.to_string())?
        .error_for_status()
        .map_err(|e| e.to_string())?;
    let raw: ManagerResponse = resp.json().await.map_err(|e| e.to_string())?;
    Ok(map_ball_by_ball(raw))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn maps_manager_response_with_defaults() {
        let state = map_ball_by_ball(ManagerResponse {
            match_id: "demo".to_string(),
            innings: Some(ManagerInnings {
                batting_team: Some("Tigers".to_string()),
                bowling_team: Some("Falcons".to_string()),
                score: Some(128),
                wickets: Some(4),
                balls: Some(86),
                batter_on_strike: Some("R. Khan".to_string()),
                batter_non_strike: Some("A. Singh".to_string()),
                bowler: Some("M. Patel".to_string()),
                recent_balls: Some(vec![
                    ManagerBall::Str("4".to_string()),
                    ManagerBall::Object {
                        result: Some("W".to_string()),
                    },
                ]),
            }),
        });
        assert_eq!(state.runs, 128);
        assert_eq!(state.wickets, 4);
        assert_eq!(state.overs, 86.0 / 6.0);
        assert_eq!(state.recent_balls, vec!["4", "W"]);
    }

    #[test]
    fn maps_empty_response_safely() {
        let state = map_ball_by_ball(ManagerResponse {
            match_id: "demo".to_string(),
            innings: None,
        });
        assert_eq!(state.batting_team, "Batting");
        assert_eq!(state.runs, 0);
        assert!(state.recent_balls.is_empty());
    }

    #[test]
    fn settings_seed_config_with_label_fallback() {
        let settings = ScoreboardSettings::new(
            "https://manager.example/".to_string(),
            vec!["m-1".to_string()],
            3000,
        );
        let config = settings.into_config();
        assert_eq!(config.base_url, "https://manager.example");
        assert_eq!(config.poll_ms, 3000);
        assert_eq!(config.match_configs.len(), 1);
        assert_eq!(config.match_configs[0].match_id, "m-1");
        assert_eq!(config.match_configs[0].label, "m-1");
        assert!(config.api_token.is_none());
    }

    #[tokio::test]
    async fn config_update_replaces_matches_and_validates() {
        let hub = ScoreboardHub::new(
            ScoreboardSettings::new(
                "https://manager.example".to_string(),
                vec!["m-1".to_string()],
                3000,
            )
            .into_config(),
        );

        let view = hub.config_view().await;
        assert_eq!(view.match_configs.len(), 1);
        assert!(!view.api_token_set);
        assert_eq!(view.sync[0].state, MatchSyncState::Pending);

        let update = CricketConfigUpdate {
            match_configs: vec![
                CricketMatchConfig {
                    match_id: "m-2".to_string(),
                    label: "Final".to_string(),
                },
                CricketMatchConfig {
                    match_id: "m-3".to_string(),
                    label: "m-3".to_string(),
                },
            ],
            poll_ms: Some(1200),
            api_token: Some("secret-token".to_string()),
        };
        let view = hub.update_config(update).await.unwrap();
        assert_eq!(view.match_configs.len(), 2);
        assert_eq!(view.poll_ms, 1200);
        assert!(view.api_token_set);

        // Too-fast poll intervals are rejected.
        let bad = CricketConfigUpdate {
            poll_ms: Some(10),
            ..CricketConfigUpdate::default()
        };
        assert!(hub.update_config(bad).await.is_err());

        // Empty-string token clears the configured one.
        let clear = CricketConfigUpdate {
            match_configs: vec![CricketMatchConfig {
                match_id: "m-2".to_string(),
                label: "Final".to_string(),
            }],
            api_token: Some("".to_string()),
            ..CricketConfigUpdate::default()
        };
        let view = hub.update_config(clear).await.unwrap();
        assert!(!view.api_token_set);
        assert_eq!(view.match_configs.len(), 1);
    }

    #[tokio::test]
    async fn sync_status_tracks_failures_without_losing_last_ok() {
        let hub = ScoreboardHub::new(
            ScoreboardSettings::new(
                "https://manager.example".to_string(),
                vec!["m-1".to_string()],
                3000,
            )
            .into_config(),
        );

        hub.record_sync("m-1", Ok(()));
        let view = hub.config_view().await;
        assert_eq!(view.sync[0].state, MatchSyncState::Synced);
        assert!(view.sync[0].last_ok_at_ms.is_some());

        hub.record_sync("m-1", Err("boom".to_string()));
        let view = hub.config_view().await;
        assert_eq!(view.sync[0].state, MatchSyncState::Error);
        assert_eq!(view.sync[0].last_error.as_deref(), Some("boom"));
        // Last successful fetch time is preserved across failures.
        assert!(view.sync[0].last_ok_at_ms.is_some());
    }
}
