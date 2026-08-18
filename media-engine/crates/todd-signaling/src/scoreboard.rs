//! Cricket Manager score synchronizer.
//!
//! Polls the TraceOdd Cricket Manager REST feed
//! (`{CRICKET_MANAGER_URL}/api/v1/cricket/live/{match_id}`) and caches the
//! latest ball-by-ball state in [`ScoreboardHub`]. The Studio UI reads the
//! cached state over `GET /api/v1/cricket/live/{match_id}` and receives
//! pushes over `GET /api/v1/cricket/ws`.
//!
//! The manager's JSON shape is still being finalized on the cloud side, so
//! [`map_ball_by_ball`] is the single place to adapt the response. Unknown
//! fields are ignored; missing fields fall back to broadcast-safe defaults.

use std::sync::Arc;
use std::time::Duration;

use dashmap::DashMap;
use serde::{Deserialize, Serialize};

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

/// Minimal view of the settings needed by the sync task. Keeps the module
/// free of a hard dependency on the full `Settings` struct and makes the
/// polling behaviour unit-testable.
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

/// Thread-safe cache of the latest score per match id.
pub struct ScoreboardHub {
    scores: DashMap<String, BallByBallState>,
}

impl ScoreboardHub {
    pub fn new() -> Self {
        Self {
            scores: DashMap::new(),
        }
    }

    pub fn get(&self, match_id: &str) -> Option<BallByBallState> {
        self.scores.get(match_id).map(|entry| entry.value().clone())
    }

    /// All cached matches, sorted by match id for stable output.
    pub fn all(&self) -> Vec<BallByBallState> {
        let mut states: Vec<BallByBallState> =
            self.scores.iter().map(|entry| entry.value().clone()).collect();
        states.sort_by(|a, b| a.match_id.cmp(&b.match_id));
        states
    }

    pub fn upsert(&self, state: BallByBallState) {
        self.scores.insert(state.match_id.clone(), state);
    }
}

/// Spawns the poller and returns the shared hub.
pub fn spawn_sync(settings: ScoreboardSettings, client: reqwest::Client) -> Arc<ScoreboardHub> {
    let hub = Arc::new(ScoreboardHub::new());
    let hub_for_task = Arc::clone(&hub);
    tokio::spawn(async move {
        poll_loop(settings, client, hub_for_task).await;
    });
    hub
}

async fn poll_loop(settings: ScoreboardSettings, client: reqwest::Client, hub: Arc<ScoreboardHub>) {
    let interval = Duration::from_millis(settings.poll_ms.max(500));
    let mut ticker = tokio::time::interval(interval);
    // The first tick fires immediately; skip the initial sleep.
    ticker.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

    loop {
        ticker.tick().await;
        for match_id in &settings.match_ids {
            match fetch_match(&client, &settings.base_url, match_id).await {
                Ok(state) => hub.upsert(state),
                Err(e) => {
                    tracing::warn!(match_id, error = %e, "cricket score sync failed; keeping last known score");
                }
            }
        }
    }
}

async fn fetch_match(
    client: &reqwest::Client,
    base_url: &str,
    match_id: &str,
) -> Result<BallByBallState, String> {
    let url = format!("{base_url}/api/v1/cricket/live/{match_id}");
    let resp = client
        .get(&url)
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
                    ManagerBall::Object { result: Some("W".to_string()) },
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
}
