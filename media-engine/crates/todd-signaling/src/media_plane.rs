//! Media plane abstraction — the seam that lets Phase 2 move the
//! Broadcaster to a dedicated server by flipping `MEDIA_PLANE=remote`
//! (plus `BROADCASTER_URL`) with zero code changes.

use std::sync::Arc;

use async_trait::async_trait;
use axum::http::header::{CONTENT_TYPE, LOCATION};
use todd_common::media::{AudioMixView, AudioMixerConfig};
use todd_common::types::{
    ForwardingStatus, OverlayCommand, OverlayState, ProgramState, ProgramTransitionRequest,
};
use todd_common::{error::AppError, types::ForwardTarget};
use todd_replay::export::{ClipExportRequest, ExportStatus};
use todd_replay::session::{ReplayInfo, ReplayTrigger};
use todd_sfu::engine::Engine;

#[async_trait]
pub trait MediaPlane: Send + Sync {
    async fn ping(&self) -> Result<(), AppError>;

    /// Accepts a WHIP offer; returns `(session_id, answer_sdp)`.
    async fn create_whip_session(
        &self,
        room_id: &str,
        camera_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError>;

    async fn close_session(&self, session_id: &str) -> Result<(), AppError>;

    /// WHEP egress: creates a viewer PeerConnection fed from the camera's
    /// live RTP stream of one simulcast layer (`rid` empty = lowest);
    /// returns `(session_id, answer_sdp)`.
    async fn create_viewer_session(
        &self,
        room_id: &str,
        camera_id: &str,
        rid: Option<String>,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError>;

    async fn close_viewer_session(&self, session_id: &str) -> Result<(), AppError>;

    async fn add_forwarder(
        &self,
        room_id: &str,
        camera_id: &str,
        target: &ForwardTarget,
    ) -> Result<(), AppError>;

    // ---- instant replay ----

    /// Triggers an instant replay from the ring buffer.
    async fn trigger_replay(&self, req: &ReplayTrigger) -> Result<ReplayInfo, AppError>;

    /// Lists live replay sessions.
    async fn list_replays(&self) -> Result<Vec<ReplayInfo>, AppError>;

    /// Closes a replay session.
    async fn close_replay(&self, replay_id: &str) -> Result<(), AppError>;

    /// WHEP egress fed from a replay session's paced slow-motion stream.
    async fn create_replay_viewer(
        &self,
        replay_id: &str,
        camera_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError>;

    /// Starts an async clip export job.
    async fn export_replay(&self, req: &ClipExportRequest) -> Result<ExportStatus, AppError>;

    // ---- vision switcher / program egress ----

    /// Records the program (PGM) source for a room.
    async fn set_program(&self, req: &ProgramTransitionRequest) -> Result<ProgramState, AppError>;

    /// Current program source for a room (`None` = not yet set).
    async fn get_program(&self, room_id: &str) -> Result<Option<ProgramState>, AppError>;

    /// WHEP egress fed from the room's current program source.
    async fn create_program_viewer(
        &self,
        room_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError>;

    // ---- audio mixer ----

    /// Current audio mix of a room: config + latest metering.
    async fn get_audio_mix(&self, room_id: &str) -> Result<AudioMixView, AppError>;

    /// Applies a new audio mix (faders, mute/solo, gain, delay).
    async fn set_audio_mix(
        &self,
        room_id: &str,
        config: AudioMixerConfig,
    ) -> Result<AudioMixView, AppError>;

    // ---- program overlays ----

    /// Current program overlay state of a room.
    async fn get_overlays(&self, room_id: &str) -> Result<OverlayState, AppError>;

    /// Applies one overlay command to a room's program bus.
    async fn apply_overlay(
        &self,
        room_id: &str,
        command: OverlayCommand,
    ) -> Result<OverlayState, AppError>;

    /// Clears every program overlay of a room.
    async fn clear_overlays(&self, room_id: &str) -> Result<OverlayState, AppError>;

    // ---- broadcast output distribution ----

    /// Starts a forwarder fed from the room's mixed program output.
    async fn add_program_forwarder(
        &self,
        room_id: &str,
        target: &ForwardTarget,
    ) -> Result<ForwardingStatus, AppError>;

    /// Stops an output forwarder by key.
    async fn stop_forwarder(&self, key: &str) -> Result<ForwardingStatus, AppError>;

    /// Runtime statuses of every output forwarder.
    async fn list_forwarders(&self) -> Result<Vec<ForwardingStatus>, AppError>;
}

/// Phase 1 default: the Broadcaster engine runs in-process.
pub struct EmbeddedMediaPlane {
    pub engine: Arc<Engine>,
}

#[async_trait]
impl MediaPlane for EmbeddedMediaPlane {
    async fn ping(&self) -> Result<(), AppError> {
        Ok(())
    }

    async fn create_whip_session(
        &self,
        room_id: &str,
        camera_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        self.engine
            .start_session(room_id, camera_id, offer_sdp)
            .await
    }

    async fn close_session(&self, session_id: &str) -> Result<(), AppError> {
        self.engine.stop_session(session_id).await
    }

    async fn create_viewer_session(
        &self,
        room_id: &str,
        camera_id: &str,
        rid: Option<String>,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        self.engine
            .start_viewer_session(room_id, camera_id, rid, offer_sdp)
            .await
    }

    async fn close_viewer_session(&self, session_id: &str) -> Result<(), AppError> {
        self.engine.stop_viewer_session(session_id).await
    }

    async fn add_forwarder(
        &self,
        room_id: &str,
        camera_id: &str,
        target: &ForwardTarget,
    ) -> Result<(), AppError> {
        self.engine.add_forwarder(room_id, camera_id, target).await
    }

    async fn trigger_replay(&self, req: &ReplayTrigger) -> Result<ReplayInfo, AppError> {
        self.engine.trigger_replay(req).await
    }

    async fn list_replays(&self) -> Result<Vec<ReplayInfo>, AppError> {
        Ok(self.engine.list_replays())
    }

    async fn close_replay(&self, replay_id: &str) -> Result<(), AppError> {
        self.engine.close_replay(replay_id).await
    }

    async fn create_replay_viewer(
        &self,
        replay_id: &str,
        camera_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        self.engine
            .start_replay_viewer(replay_id, camera_id, offer_sdp)
            .await
    }

    async fn export_replay(&self, req: &ClipExportRequest) -> Result<ExportStatus, AppError> {
        self.engine.export_replay(req).await
    }

    async fn set_program(&self, req: &ProgramTransitionRequest) -> Result<ProgramState, AppError> {
        Ok(self.engine.set_program(req))
    }

    async fn get_program(&self, room_id: &str) -> Result<Option<ProgramState>, AppError> {
        Ok(self.engine.get_program(room_id))
    }

    async fn create_program_viewer(
        &self,
        room_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        self.engine.start_program_viewer(room_id, offer_sdp).await
    }

    async fn get_audio_mix(&self, room_id: &str) -> Result<AudioMixView, AppError> {
        Ok(self.engine.get_audio_mix(room_id))
    }

    async fn set_audio_mix(
        &self,
        room_id: &str,
        config: AudioMixerConfig,
    ) -> Result<AudioMixView, AppError> {
        Ok(self.engine.set_audio_mix(room_id, config))
    }

    async fn get_overlays(&self, room_id: &str) -> Result<OverlayState, AppError> {
        Ok(self.engine.get_overlays(room_id))
    }

    async fn apply_overlay(
        &self,
        room_id: &str,
        command: OverlayCommand,
    ) -> Result<OverlayState, AppError> {
        Ok(self.engine.apply_overlay(room_id, command))
    }

    async fn clear_overlays(&self, room_id: &str) -> Result<OverlayState, AppError> {
        Ok(self.engine.clear_overlays(room_id))
    }

    async fn add_program_forwarder(
        &self,
        room_id: &str,
        target: &ForwardTarget,
    ) -> Result<ForwardingStatus, AppError> {
        self.engine.add_program_forwarder(room_id, target).await
    }

    async fn stop_forwarder(&self, key: &str) -> Result<ForwardingStatus, AppError> {
        self.engine.stop_forwarder(key).await
    }

    async fn list_forwarders(&self) -> Result<Vec<ForwardingStatus>, AppError> {
        Ok(self.engine.list_forwarders())
    }
}

/// Phase 2: proxies WHIP/forwarding to a standalone Broadcaster service.
pub struct RemoteMediaPlane {
    pub base: String,
    pub internal_token: String,
    pub client: reqwest::Client,
}

#[async_trait]
impl MediaPlane for RemoteMediaPlane {
    async fn ping(&self) -> Result<(), AppError> {
        let resp = self
            .client
            .get(format!("{}/healthz", self.base))
            .send()
            .await?;
        if resp.status().is_success() {
            Ok(())
        } else {
            Err(AppError::Internal(format!(
                "broadcaster unhealthy: {}",
                resp.status()
            )))
        }
    }

    async fn create_whip_session(
        &self,
        room_id: &str,
        camera_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let url = format!("{}/api/v1/whip/ingest/{room_id}/{camera_id}", self.base);
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .header(CONTENT_TYPE, "application/sdp")
            .body(offer_sdp.to_owned())
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected ingest: {e}")))?;

        // Read the Location header before consuming the body (reqwest's
        // `text()` takes ownership of the response).
        let session_id = resp
            .headers()
            .get(LOCATION)
            .and_then(|v| v.to_str().ok())
            .and_then(|loc| loc.rsplit('/').next())
            .ok_or_else(|| {
                AppError::Internal("broadcaster response missing Location header".to_string())
            })?
            .to_string();
        let answer = resp.text().await?;
        Ok((session_id, answer))
    }

    async fn close_session(&self, session_id: &str) -> Result<(), AppError> {
        let url = format!("{}/api/v1/whip/session/{session_id}", self.base);
        self.client
            .delete(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected close: {e}")))?;
        Ok(())
    }

    async fn create_viewer_session(
        &self,
        room_id: &str,
        camera_id: &str,
        rid: Option<String>,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let mut url = format!("{}/api/v1/whep/watch/{room_id}/{camera_id}", self.base);
        if let Some(rid) = &rid {
            if !rid.is_empty() {
                url.push_str(&format!("?rid={rid}"));
            }
        }
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .header(CONTENT_TYPE, "application/sdp")
            .body(offer_sdp.to_owned())
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected watch: {e}")))?;

        // Read the Location header before consuming the body (reqwest's
        // `text()` takes ownership of the response).
        let session_id = resp
            .headers()
            .get(LOCATION)
            .and_then(|v| v.to_str().ok())
            .and_then(|loc| loc.rsplit('/').next())
            .ok_or_else(|| {
                AppError::Internal("broadcaster response missing Location header".to_string())
            })?
            .to_string();
        let answer = resp.text().await?;
        Ok((session_id, answer))
    }

    async fn close_viewer_session(&self, session_id: &str) -> Result<(), AppError> {
        let url = format!("{}/api/v1/whep/session/{session_id}", self.base);
        self.client
            .delete(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected close: {e}")))?;
        Ok(())
    }

    async fn add_forwarder(
        &self,
        room_id: &str,
        camera_id: &str,
        target: &ForwardTarget,
    ) -> Result<(), AppError> {
        let url = format!("{}/api/v1/forward/{room_id}/{camera_id}", self.base);
        self.client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .json(target)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected forwarder: {e}")))?;
        Ok(())
    }

    async fn trigger_replay(&self, req: &ReplayTrigger) -> Result<ReplayInfo, AppError> {
        let url = format!("{}/api/v1/replay/trigger", self.base);
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .json(req)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected replay trigger: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid replay trigger response: {e}")))
    }

    async fn list_replays(&self) -> Result<Vec<ReplayInfo>, AppError> {
        let url = format!("{}/api/v1/replay/list", self.base);
        let resp = self
            .client
            .get(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected replay list: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid replay list response: {e}")))
    }

    async fn close_replay(&self, replay_id: &str) -> Result<(), AppError> {
        let url = format!("{}/api/v1/replay/{replay_id}", self.base);
        self.client
            .delete(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected replay close: {e}")))?;
        Ok(())
    }

    async fn create_replay_viewer(
        &self,
        replay_id: &str,
        camera_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let url = format!("{}/api/v1/replay/watch/{replay_id}/{camera_id}", self.base);
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .header(CONTENT_TYPE, "application/sdp")
            .body(offer_sdp.to_owned())
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected replay watch: {e}")))?;

        let session_id = resp
            .headers()
            .get(LOCATION)
            .and_then(|v| v.to_str().ok())
            .and_then(|loc| loc.rsplit('/').next())
            .ok_or_else(|| {
                AppError::Internal("broadcaster response missing Location header".to_string())
            })?
            .to_string();
        let answer = resp.text().await?;
        Ok((session_id, answer))
    }

    async fn export_replay(&self, req: &ClipExportRequest) -> Result<ExportStatus, AppError> {
        let url = format!("{}/api/v1/replay/{}/export", self.base, req.replay_id);
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .json(req)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected replay export: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid replay export response: {e}")))
    }

    async fn set_program(&self, req: &ProgramTransitionRequest) -> Result<ProgramState, AppError> {
        let url = format!("{}/api/v1/program/transition", self.base);
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .json(req)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| {
                AppError::Internal(format!("broadcaster rejected program transition: {e}"))
            })?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid program transition response: {e}")))
    }

    async fn get_program(&self, room_id: &str) -> Result<Option<ProgramState>, AppError> {
        let url = format!("{}/api/v1/program/{room_id}", self.base);
        let resp = self
            .client
            .get(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?;
        if resp.status() == axum::http::StatusCode::NOT_FOUND {
            return Ok(None);
        }
        let program = resp
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected program get: {e}")))?
            .json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid program response: {e}")))?;
        Ok(Some(program))
    }

    async fn create_program_viewer(
        &self,
        room_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let url = format!("{}/api/v1/whep/program/{room_id}", self.base);
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .header(CONTENT_TYPE, "application/sdp")
            .body(offer_sdp.to_owned())
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected program watch: {e}")))?;

        let session_id = resp
            .headers()
            .get(LOCATION)
            .and_then(|v| v.to_str().ok())
            .and_then(|loc| loc.rsplit('/').next())
            .ok_or_else(|| {
                AppError::Internal("broadcaster response missing Location header".to_string())
            })?
            .to_string();
        let answer = resp.text().await?;
        Ok((session_id, answer))
    }

    async fn get_audio_mix(&self, room_id: &str) -> Result<AudioMixView, AppError> {
        let url = format!("{}/api/v1/audio/mix/{room_id}", self.base);
        let resp = self
            .client
            .get(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected audio mix get: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid audio mix response: {e}")))
    }

    async fn set_audio_mix(
        &self,
        room_id: &str,
        config: AudioMixerConfig,
    ) -> Result<AudioMixView, AppError> {
        let url = format!("{}/api/v1/audio/mix/{room_id}", self.base);
        let resp = self
            .client
            .put(&url)
            .bearer_auth(&self.internal_token)
            .json(&config)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected audio mix set: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid audio mix response: {e}")))
    }

    async fn get_overlays(&self, room_id: &str) -> Result<OverlayState, AppError> {
        let url = format!("{}/api/v1/program/overlay/{room_id}", self.base);
        let resp = self
            .client
            .get(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected overlay get: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid overlay response: {e}")))
    }

    async fn apply_overlay(
        &self,
        room_id: &str,
        command: OverlayCommand,
    ) -> Result<OverlayState, AppError> {
        let url = format!("{}/api/v1/program/overlay", self.base);
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .json(&todd_common::types::OverlayRequest {
                room_id: room_id.to_string(),
                command,
            })
            .send()
            .await?
            .error_for_status()
            .map_err(|e| {
                AppError::Internal(format!("broadcaster rejected overlay command: {e}"))
            })?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid overlay response: {e}")))
    }

    async fn clear_overlays(&self, room_id: &str) -> Result<OverlayState, AppError> {
        let url = format!("{}/api/v1/program/overlay/{room_id}", self.base);
        let resp = self
            .client
            .delete(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected overlay clear: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid overlay response: {e}")))
    }

    async fn add_program_forwarder(
        &self,
        room_id: &str,
        target: &ForwardTarget,
    ) -> Result<ForwardingStatus, AppError> {
        let url = format!("{}/api/v1/forward/program/{room_id}", self.base);
        let resp = self
            .client
            .post(&url)
            .bearer_auth(&self.internal_token)
            .json(target)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| {
                AppError::Internal(format!("broadcaster rejected program forwarder: {e}"))
            })?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid forwarder status response: {e}")))
    }

    async fn stop_forwarder(&self, key: &str) -> Result<ForwardingStatus, AppError> {
        let url = format!("{}/api/v1/forward/{}", self.base, key);
        let resp = self
            .client
            .delete(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected forwarder stop: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid forwarder status response: {e}")))
    }

    async fn list_forwarders(&self) -> Result<Vec<ForwardingStatus>, AppError> {
        let url = format!("{}/api/v1/forward/list", self.base);
        let resp = self
            .client
            .get(&url)
            .bearer_auth(&self.internal_token)
            .send()
            .await?
            .error_for_status()
            .map_err(|e| AppError::Internal(format!("broadcaster rejected forwarder list: {e}")))?;
        resp.json()
            .await
            .map_err(|e| AppError::Internal(format!("invalid forwarder list response: {e}")))
    }
}
