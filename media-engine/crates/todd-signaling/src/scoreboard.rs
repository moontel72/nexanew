//! Cricket scoreboard sync for the Studio control plane.
//!
//! Phase 1 unified realtime engine — dual transport:
//!   1. PUSH (primary): subscribes to Laravel Reverb `cricket.match.{id}`
//!      channels. Scoring/context events arrive in sub-100ms and trigger
//!      one canonical REST refresh per event (push = change signal,
//!      REST = authoritative state — same mapping as before).
//!   2. POLL (watchdog): the old timer loop stays as a degraded-mode
//!      fallback. A match is only polled when no push arrived within the
//!      watchdog window, so healthy push traffic costs zero polling.
//!
//! The active-match context ("which match is the manager operating") is
//! the single source of truth mirrored here: `match.context.selected`
//! events flip `active_match_id`, auto-register unknown matches, and are
//! broadcast to director panels through the control plane.

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use chrono::Utc;
use dashmap::DashMap;
use serde::{Deserialize, Serialize};
use tokio::sync::RwLock;

use crate::reverb::{ReverbClient, ReverbEvent};
use crate::routes::control_ws::{ControlEvent, ControlHub};
use todd_common::error::AppError;

/// Live ball-by-ball state for one match, as shown on the Studio
/// lower-third.
#[derive(Debug, Clone, Serialize)]
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
    /// Optional override for the Reverb WebSocket base (defaults to the
    /// base_url host with `/app/{key}` appended — resolved at runtime).
    pub ws_url: Option<String>,
}

impl ScoreboardSettings {
    pub fn new(
        base_url: String,
        match_ids: Vec<String>,
        poll_ms: u64,
        ws_url: Option<String>,
    ) -> Self {
        Self {
            base_url: base_url.trim_end_matches('/').to_string(),
            match_ids,
            poll_ms,
            ws_url: ws_url.map(|v| v.trim_end_matches('/').to_string()),
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

/// One match the engine keeps synced.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CricketMatchConfig {
    pub match_id: String,
    #[serde(default)]
    pub label: String,
}

/// Per-match sync health state.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum MatchSyncState {
    Pending,
    Synced,
    Error,
}

/// Which transport delivered the last successful sync.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum SyncTransport {
    #[default]
    Pending,
    Push,
    Poll,
}

#[derive(Debug, Clone, Serialize)]
pub struct MatchSyncStatus {
    pub match_id: String,
    pub state: MatchSyncState,
    pub transport: SyncTransport,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub last_ok_at_ms: Option<i64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub last_error: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct CricketConfigView {
    pub base_url: String,
    pub match_configs: Vec<CricketMatchConfig>,
    pub poll_ms: u64,
    pub api_token_set: bool,
    pub sync: Vec<MatchSyncStatus>,
    /// Match the manager currently operates (from `match.context.selected`).
    pub active_match_id: Option<String>,
    /// True while the Reverb push socket is connected.
    pub push_connected: bool,
}

/// Runtime-updatable sync configuration (`PUT /api/v1/cricket/config`).
#[derive(Debug, Clone, Default, Deserialize)]
pub struct CricketConfigUpdate {
    #[serde(default)]
    pub match_configs: Vec<CricketMatchConfig>,
    #[serde(default)]
    pub poll_ms: Option<u64>,
    #[serde(default)]
    pub api_token: Option<String>,
}

#[derive(Debug, Clone)]
struct ScoreboardConfig {
    base_url: String,
    match_configs: Vec<CricketMatchConfig>,
    poll_ms: u64,
    api_token: Option<String>,
}

/// Wire shape of `GET /api/v1/cricket/live/{match_id}` (Laravel).
#[derive(Debug, Deserialize)]
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
        updated_at_ms: Utc::now().timestamp_millis(),
    }
}

/// Lower bound the poll interval can be configured to. Anything faster
/// hammers the manager origin for no broadcast benefit.
const MIN_POLL_MS: u64 = 500;

/// Push freshness window: a match is skipped by the watchdog poller while
/// its last push event is younger than this (2× poll interval, ≥ 2s).
fn watchdog_window_ms(poll_ms: u64) -> i64 {
    (poll_ms * 2).max(2_000) as i64
}

/// Reverb connection details resolved at runtime from the manager's
/// public `realtime-config` endpoint — nothing hardcoded.
#[derive(Debug, Clone)]
struct RealtimeConfig {
    key: String,
    path: String,
}

fn now_ms() -> i64 {
    Utc::now().timestamp_millis()
}

/// Thread-safe cache of the latest score per match id, the runtime sync
/// configuration, per-match health, and the shared active-match context.
pub struct ScoreboardHub {
    scores: DashMap<String, BallByBallState>,
    config: RwLock<ScoreboardConfig>,
    sync: DashMap<String, MatchSyncStatus>,
    active_match: RwLock<Option<String>>,
    last_push_at: DashMap<String, i64>,
    push_connected: AtomicBool,
}

impl ScoreboardHub {
    pub fn new(config: ScoreboardConfig) -> Self {
        Self {
            scores: DashMap::new(),
            config: RwLock::new(config),
            sync: DashMap::new(),
            active_match: RwLock::new(None),
            last_push_at: DashMap::new(),
            push_connected: AtomicBool::new(false),
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

    /// Records the outcome of one sync round for a match, including which
    /// transport delivered it.
    pub fn record_sync(
        &self,
        match_id: &str,
        result: Result<(), String>,
        transport: SyncTransport,
    ) {
        let now = now_ms();
        match result {
            Ok(()) => {
                self.sync.insert(
                    match_id.to_string(),
                    MatchSyncStatus {
                        match_id: match_id.to_string(),
                        state: MatchSyncState::Synced,
                        transport,
                        last_ok_at_ms: Some(now),
                        last_error: None,
                    },
                );
            }
            Err(message) => {
                // A failed round keeps the last successful timestamp so the
                // UI can show how stale the displayed score is.
                let last_ok_at_ms = self
                    .sync
                    .get(match_id)
                    .and_then(|entry| entry.value().last_ok_at_ms);
                let transport = self
                    .sync
                    .get(match_id)
                    .map(|entry| entry.value().transport)
                    .unwrap_or(SyncTransport::Pending);
                self.sync.insert(
                    match_id.to_string(),
                    MatchSyncStatus {
                        match_id: match_id.to_string(),
                        state: MatchSyncState::Error,
                        transport,
                        last_ok_at_ms,
                        last_error: Some(message),
                    },
                );
            }
        }
    }

    /// The match the manager is currently operating (shared context).
    pub async fn active_match_id(&self) -> Option<String> {
        self.active_match.read().await.clone()
    }

    /// Flips the active match context (from `match.context.selected`).
    pub async fn set_active_match(&self, match_id: &str) {
        *self.active_match.write().await = Some(match_id.to_string());
    }

    /// Registers a match that arrived via the push context event but is
    /// not configured yet. Returns true when the config changed.
    pub async fn auto_add_match(&self, match_id: &str) -> bool {
        let mut config = self.config.write().await;
        if config.match_configs.iter().any(|m| m.match_id == match_id) {
            return false;
        }
        config.match_configs.push(CricketMatchConfig {
            match_id: match_id.to_string(),
            label: "Selected in Manager".to_string(),
        });
        true
    }

    /// Marks the last push timestamp (drives the poller's skip logic).
    pub fn touch_push(&self, match_id: &str) {
        self.last_push_at.insert(match_id.to_string(), now_ms());
    }

    fn last_push_age_ms(&self, match_id: &str) -> Option<i64> {
        self.last_push_at
            .get(match_id)
            .map(|entry| now_ms().saturating_sub(*entry.value()))
    }

    pub fn set_push_connected(&self, connected: bool) {
        self.push_connected.store(connected, Ordering::Relaxed);
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
                        transport: SyncTransport::Pending,
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
            active_match_id: self.active_match_id().await,
            push_connected: self.push_connected.load(Ordering::Relaxed),
        }
    }

    /// Snapshot of the runtime config for the sync tasks.
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

/// Spawns the push subscriber + the watchdog poller and returns the hub.
pub fn spawn_sync(
    settings: ScoreboardSettings,
    client: reqwest::Client,
    control: Arc<ControlHub>,
) -> Arc<ScoreboardHub> {
    let ws_url = settings.ws_url.clone();
    let hub = Arc::new(ScoreboardHub::new(settings.into_config()));

    let push_hub = Arc::clone(&hub);
    let push_client = client.clone();
    let push_control = Arc::clone(&control);
    tokio::spawn(async move {
        push_loop(push_client, push_hub, push_control, ws_url).await;
    });

    let poll_hub = Arc::clone(&hub);
    let poll_control = Arc::clone(&control);
    tokio::spawn(async move {
        poll_loop(client, poll_hub, poll_control).await;
    });

    hub
}

/// Fetches the Reverb app key/path from the manager's public config
/// endpoint (cached by the caller between reconnects).
async fn resolve_realtime_config(
    client: &reqwest::Client,
    base_url: &str,
) -> Result<RealtimeConfig, String> {
    let url = format!("{base_url}/api/v1/cricket/public/realtime-config");
    let resp = client
        .get(&url)
        .send()
        .await
        .map_err(|e| e.to_string())?
        .error_for_status()
        .map_err(|e| e.to_string())?;
    let raw: serde_json::Value = resp.json().await.map_err(|e| e.to_string())?;

    if raw.get("driver").and_then(|v| v.as_str()) != Some("reverb") {
        return Err(format!("realtime-config driver is not reverb: {raw:?}"));
    }
    let key = raw
        .get("key")
        .and_then(|v| v.as_str())
        .ok_or_else(|| "realtime-config missing app key".to_string())?
        .to_string();
    let path = raw
        .get("path")
        .and_then(|v| v.as_str())
        .unwrap_or("/app")
        .to_string();
    if key.is_empty() {
        return Err("realtime-config app key is empty".to_string());
    }
    Ok(RealtimeConfig { key, path })
}

/// Builds the full Pusher-protocol connection URL from the manager base
/// URL (or the explicit WS override) and the runtime-resolved app key.
fn build_reverb_url(
    base_url: &str,
    ws_url: Option<&str>,
    rt: &RealtimeConfig,
) -> Result<String, String> {
    let query = "protocol=7&client=traceodd-engine&version=1.0.0&flash=false";
    let path = if rt.path.is_empty() {
        "/app"
    } else {
        rt.path.as_str()
    };

    match ws_url {
        Some(ws) => {
            let trimmed = ws.trim_end_matches('/');
            if trimmed.ends_with("/app") {
                Ok(format!("{trimmed}/{}?{query}", rt.key))
            } else {
                Ok(format!("{trimmed}{path}/{}?{query}", rt.key))
            }
        }
        None => {
            let base = base_url.trim_end_matches('/');
            let scheme = if base.starts_with("https://") {
                "wss://"
            } else {
                "ws://"
            };
            let host = base
                .trim_start_matches("https://")
                .trim_start_matches("http://");
            Ok(format!("{scheme}{host}{path}/{}?{query}", rt.key))
        }
    }
}

/// Push subscriber driver: connect → subscribe → react to events.
/// Reconnects with exponential backoff; re-reads the config every round
/// so runtime match-list changes take effect without a restart.
async fn push_loop(
    client: reqwest::Client,
    hub: Arc<ScoreboardHub>,
    control: Arc<ControlHub>,
    ws_url: Option<String>,
) {
    let mut backoff_secs: u64 = 1;
    const MAX_BACKOFF_SECS: u64 = 30;

    loop {
        let config = hub.current_config().await;
        if config.base_url.is_empty() {
            hub.set_push_connected(false);
            tokio::time::sleep(Duration::from_secs(5)).await;
            continue;
        }

        match resolve_realtime_config(&client, &config.base_url).await {
            Ok(rt) => match build_reverb_url(&config.base_url, ws_url.as_deref(), &rt) {
                Ok(url) => match ReverbClient::connect(&url, Duration::from_secs(30)).await {
                    Ok(mut socket) => {
                        backoff_secs = 1;
                        hub.set_push_connected(true);
                        tracing::info!(url = %url, "cricket reverb push connected");
                        match run_push_session(&mut socket, &client, &hub, &control).await {
                            Ok(()) => tracing::info!("cricket reverb push session ended"),
                            Err(e) => {
                                tracing::warn!(error = %e, "cricket reverb push session failed")
                            }
                        }
                    }
                    Err(e) => {
                        hub.set_push_connected(false);
                        tracing::warn!(error = %e, "cricket reverb connect failed");
                    }
                },
                Err(e) => {
                    hub.set_push_connected(false);
                    tracing::warn!(error = %e, "cricket reverb url invalid");
                }
            },
            Err(e) => {
                hub.set_push_connected(false);
                tracing::warn!(error = %e, "cricket realtime-config fetch failed");
            }
        }

        tokio::time::sleep(Duration::from_secs(backoff_secs)).await;
        backoff_secs = (backoff_secs * 2).min(MAX_BACKOFF_SECS);
    }
}

/// One connected push session: keeps the subscription set in sync with
/// the runtime config and reacts to incoming events until the socket
/// drops.
async fn run_push_session(
    socket: &mut ReverbClient,
    client: &reqwest::Client,
    hub: &Arc<ScoreboardHub>,
    control: &Arc<ControlHub>,
) -> Result<(), String> {
    let mut subscribed: std::collections::HashSet<String> = std::collections::HashSet::new();

    loop {
        // (Re)subscribe to the current match set: every configured match
        // plus the active-match context channel.
        let config = hub.current_config().await;
        let mut wanted: std::collections::HashSet<String> = config
            .match_configs
            .iter()
            .map(|m| format!("cricket.match.{}", m.match_id))
            .collect();
        if let Some(active) = hub.active_match_id().await {
            wanted.insert(format!("cricket.match.{active}"));
        }
        subscribed.retain(|channel| wanted.contains(channel));
        for channel in &wanted {
            if !subscribed.contains(channel) {
                socket.subscribe(channel).await?;
                subscribed.insert(channel.clone());
            }
        }

        let Some(event) = socket.next_event().await? else {
            return Ok(());
        };
        let Some(match_id) = event
            .channel
            .strip_prefix("cricket.match.")
            .map(str::to_string)
        else {
            continue;
        };
        handle_push_event(client, hub, control, &match_id, event).await;
    }
}

/// Routes one Reverb event to the right refresh action.
async fn handle_push_event(
    client: &reqwest::Client,
    hub: &Arc<ScoreboardHub>,
    control: &Arc<ControlHub>,
    match_id: &str,
    event: ReverbEvent,
) {
    match event.event.as_str() {
        "match.context.selected" => {
            // Manager flipped the active match: adopt it, register it if
            // unknown, and push the new context to every director panel.
            hub.set_active_match(match_id).await;
            hub.auto_add_match(match_id).await;
            publish_config(hub, control).await;
            // The context flip usually races the first score push —
            // refresh once so the lower-third never waits for the
            // next scoring event.
            refresh_match(client, hub, control, match_id).await;
        }
        "score.updated" | "match.updated" | "stream.updated" => {
            refresh_match(client, hub, control, match_id).await;
        }
        _ => {}
    }
}

/// Event-triggered canonical refresh: pull the authoritative state once
/// and fan it out to director panels.
async fn refresh_match(
    client: &reqwest::Client,
    hub: &Arc<ScoreboardHub>,
    control: &Arc<ControlHub>,
    match_id: &str,
) {
    let config = hub.current_config().await;
    let base_url = config.base_url.clone();
    let token = config.api_token.clone();
    drop(config);

    match fetch_match(client, &base_url, match_id, token.as_deref()).await {
        Ok(state) => {
            hub.record_sync(match_id, Ok(()), SyncTransport::Push);
            hub.touch_push(match_id);
            hub.upsert(state.clone());
            control.publish(ControlEvent::ScoreUpdated {
                match_id: match_id.to_string(),
                score: state,
            });
        }
        Err(message) => {
            hub.record_sync(match_id, Err(message), SyncTransport::Push);
        }
    }
}

/// Watchdog poller. Skips any match whose push feed is fresh; only polls
/// matches the push path has not updated within the watchdog window.
async fn poll_loop(client: reqwest::Client, hub: Arc<ScoreboardHub>, control: Arc<ControlHub>) {
    loop {
        // Read the config every round so runtime updates (match list,
        // poll interval, token) take effect without a restart.
        let config = hub.current_config().await;
        let started = Instant::now();
        let window = watchdog_window_ms(config.poll_ms);

        for match_config in &config.match_configs {
            let push_age = hub.last_push_age_ms(&match_config.match_id);
            if let Some(age) = push_age {
                if age < window {
                    // Push path healthy — REST polling is the watchdog only.
                    continue;
                }
            }

            match fetch_match(
                &client,
                &config.base_url,
                &match_config.match_id,
                config.api_token.as_deref(),
            )
            .await
            {
                Ok(state) => {
                    hub.record_sync(&match_config.match_id, Ok(()), SyncTransport::Poll);
                    hub.upsert(state.clone());
                    control.publish(ControlEvent::ScoreUpdated {
                        match_id: match_config.match_id.clone(),
                        score: state,
                    });
                }
                Err(message) => {
                    hub.record_sync(
                        &match_config.match_id,
                        Err(message.clone()),
                        SyncTransport::Poll,
                    );
                    tracing::warn!(
                        match_id = %match_config.match_id,
                        error = %message,
                        "cricket score poll failed; keeping last known score"
                    );
                }
            }
        }

        let interval = Duration::from_millis(config.poll_ms.max(MIN_POLL_MS));
        let wait = interval.saturating_sub(started.elapsed());
        tokio::time::sleep(wait).await;
    }
}

/// Publishes the current config view on the control plane (used after
/// active-match or auto-registration changes).
async fn publish_config(hub: &Arc<ScoreboardHub>, control: &Arc<ControlHub>) {
    let view = hub.config_view().await;
    control.publish(ControlEvent::CricketConfigChanged { config: view });
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
        // token is sent as a bearer credential. The endpoint is public,
        // so this is only used when a deployment keeps it private.
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
            None,
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
                None,
            )
            .into_config(),
        );

        let view = hub.config_view().await;
        assert_eq!(view.match_configs.len(), 1);
        assert!(!view.api_token_set);
        assert_eq!(view.sync[0].state, MatchSyncState::Pending);
        assert_eq!(view.sync[0].transport, SyncTransport::Pending);
        assert_eq!(view.active_match_id, None);

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
                None,
            )
            .into_config(),
        );

        hub.record_sync("m-1", Ok(()), SyncTransport::Push);
        let view = hub.config_view().await;
        assert_eq!(view.sync[0].state, MatchSyncState::Synced);
        assert_eq!(view.sync[0].transport, SyncTransport::Push);
        assert!(view.sync[0].last_ok_at_ms.is_some());

        hub.record_sync("m-1", Err("boom".to_string()), SyncTransport::Push);
        let view = hub.config_view().await;
        assert_eq!(view.sync[0].state, MatchSyncState::Error);
        assert_eq!(view.sync[0].last_error.as_deref(), Some("boom"));
        // Last successful fetch time is preserved across failures.
        assert!(view.sync[0].last_ok_at_ms.is_some());
    }

    #[tokio::test]
    async fn active_match_context_auto_registers_and_views() {
        let hub = ScoreboardHub::new(
            ScoreboardSettings::new(
                "https://manager.example".to_string(),
                vec!["m-1".to_string()],
                3000,
                None,
            )
            .into_config(),
        );

        hub.set_active_match("m-9").await;
        assert_eq!(hub.active_match_id().await.as_deref(), Some("m-9"));

        assert!(hub.auto_add_match("m-9").await);
        assert!(!hub.auto_add_match("m-9").await); // idempotent

        let view = hub.config_view().await;
        assert_eq!(view.active_match_id.as_deref(), Some("m-9"));
        assert_eq!(view.match_configs.len(), 2);
        assert_eq!(view.match_configs[1].match_id, "m-9");
    }

    #[test]
    fn watchdog_window_never_drops_below_two_seconds() {
        assert_eq!(watchdog_window_ms(500), 2_000);
        assert_eq!(watchdog_window_ms(3_000), 6_000);
    }

    #[test]
    fn reverb_url_derives_from_base_url() {
        let rt = RealtimeConfig {
            key: "abc".to_string(),
            path: "/app".to_string(),
        };
        let url = build_reverb_url("https://cricket-manager.traceodd.com", None, &rt).unwrap();
        assert_eq!(
            url,
            "wss://cricket-manager.traceodd.com/app/abc?protocol=7&client=traceodd-engine&version=1.0.0&flash=false"
        );

        let override_url = build_reverb_url(
            "https://manager.example",
            Some("wss://reverb.internal"),
            &rt,
        )
        .unwrap();
        assert_eq!(
            override_url,
            "wss://reverb.internal/app/abc?protocol=7&client=traceodd-engine&version=1.0.0&flash=false"
        );
    }
}
