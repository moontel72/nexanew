//! Room/session state storage.
//!
//! Two backends behind one trait:
//! - `memory` (default): in-process DashMaps — Phase 1, single Studio.
//! - `redis`: shared keys — multiple Studio replicas behind one nginx
//!   upstream, or Studio and Broadcaster split across hosts (Phase 2.5).
//!
//! Selected with `ROOM_STORE=memory|redis` (+ `REDIS_URL`).

use std::sync::Arc;

use async_trait::async_trait;
use chrono::Utc;
use dashmap::DashMap;
use redis::AsyncCommands;
use todd_common::{
    config::Settings,
    error::AppError,
    types::{CameraInfo, Room},
};

#[async_trait]
pub trait RoomStore: Send + Sync {
    async fn upsert_room(&self, room: &Room, ttl_secs: u64) -> Result<(), AppError>;
    async fn get_room(&self, room_id: &str) -> Result<Option<Room>, AppError>;
    async fn list_rooms(&self) -> Result<Vec<Room>, AppError>;
    async fn delete_room(&self, room_id: &str) -> Result<(), AppError>;

    /// Inserts a camera into a room, or replaces its metadata when a
    /// camera with the same id already exists. Errors with `NotFound`
    /// when the room does not exist.
    async fn upsert_camera(
        &self,
        room_id: &str,
        camera: &CameraInfo,
        ttl_secs: u64,
    ) -> Result<(), AppError>;

    /// Removes a camera from a room together with its session registry
    /// entries. Errors with `NotFound` when the room does not exist; a
    /// missing camera inside an existing room is a no-op.
    async fn remove_camera(&self, room_id: &str, camera_id: &str) -> Result<(), AppError>;

    async fn add_session(
        &self,
        room_id: &str,
        session_id: &str,
        camera_id: &str,
        ttl_secs: u64,
    ) -> Result<(), AppError>;
    async fn remove_session(&self, room_id: &str, session_id: &str) -> Result<(), AppError>;
    /// (session_id, camera_id) pairs for one room.
    async fn list_sessions(&self, room_id: &str) -> Result<Vec<(String, String)>, AppError>;
    /// Reverse lookup: (room_id, camera_id) for a live session.
    async fn find_session(&self, session_id: &str) -> Result<Option<(String, String)>, AppError>;
}

/// Builds the backend selected by the environment.
pub async fn build(settings: &Settings) -> Result<Arc<dyn RoomStore>, AppError> {
    match settings.room_store {
        todd_common::config::RoomStoreMode::Memory => Ok(Arc::new(InMemoryRoomStore::new())),
        todd_common::config::RoomStoreMode::Redis => {
            Ok(Arc::new(RedisRoomStore::new(&settings.redis_url).await?))
        }
    }
}

// ---------------------------------------------------------------------------
// In-memory backend
// ---------------------------------------------------------------------------

pub struct RoomRecord {
    pub room: Room,
    /// session_id -> camera_id
    pub sessions: DashMap<String, String>,
}

pub struct InMemoryRoomStore {
    rooms: DashMap<String, RoomRecord>,
}

impl InMemoryRoomStore {
    pub fn new() -> Self {
        Self {
            rooms: DashMap::new(),
        }
    }

    fn prune_expired(&self) {
        let now = Utc::now();
        self.rooms.retain(|_, record| record.room.expires_at > now);
    }
}

#[async_trait]
impl RoomStore for InMemoryRoomStore {
    async fn upsert_room(&self, room: &Room, _ttl_secs: u64) -> Result<(), AppError> {
        self.rooms.insert(
            room.id.clone(),
            RoomRecord {
                room: room.clone(),
                sessions: DashMap::new(),
            },
        );
        Ok(())
    }

    async fn get_room(&self, room_id: &str) -> Result<Option<Room>, AppError> {
        self.prune_expired();
        Ok(self.rooms.get(room_id).map(|r| r.value().room.clone()))
    }

    async fn list_rooms(&self) -> Result<Vec<Room>, AppError> {
        self.prune_expired();
        Ok(self
            .rooms
            .iter()
            .map(|entry| entry.value().room.clone())
            .collect())
    }

    async fn delete_room(&self, room_id: &str) -> Result<(), AppError> {
        self.rooms.remove(room_id);
        Ok(())
    }

    async fn upsert_camera(
        &self,
        room_id: &str,
        camera: &CameraInfo,
        _ttl_secs: u64,
    ) -> Result<(), AppError> {
        let Some(mut record) = self.rooms.get_mut(room_id) else {
            return Err(AppError::NotFound(format!("room {room_id}")));
        };
        let cameras = &mut record.room.cameras;
        match cameras.iter_mut().find(|existing| existing.id == camera.id) {
            Some(existing) => *existing = camera.clone(),
            None => cameras.push(camera.clone()),
        }
        Ok(())
    }

    async fn remove_camera(&self, room_id: &str, camera_id: &str) -> Result<(), AppError> {
        let Some(mut record) = self.rooms.get_mut(room_id) else {
            return Err(AppError::NotFound(format!("room {room_id}")));
        };
        record.room.cameras.retain(|camera| camera.id != camera_id);
        record
            .value_mut()
            .sessions
            .retain(|_, session_camera| session_camera != camera_id);
        Ok(())
    }

    async fn add_session(
        &self,
        room_id: &str,
        session_id: &str,
        camera_id: &str,
        _ttl_secs: u64,
    ) -> Result<(), AppError> {
        let Some(record) = self.rooms.get(room_id) else {
            return Err(AppError::NotFound(format!("room {room_id}")));
        };
        record
            .value()
            .sessions
            .insert(session_id.to_string(), camera_id.to_string());
        Ok(())
    }

    async fn remove_session(&self, room_id: &str, session_id: &str) -> Result<(), AppError> {
        if let Some(record) = self.rooms.get(room_id) {
            record.value().sessions.remove(session_id);
        }
        Ok(())
    }

    async fn list_sessions(&self, room_id: &str) -> Result<Vec<(String, String)>, AppError> {
        let Some(record) = self.rooms.get(room_id) else {
            return Ok(Vec::new());
        };
        Ok(record
            .value()
            .sessions
            .iter()
            .map(|entry| (entry.key().clone(), entry.value().clone()))
            .collect())
    }

    async fn find_session(&self, session_id: &str) -> Result<Option<(String, String)>, AppError> {
        for entry in self.rooms.iter() {
            if let Some(camera_id) = entry.value().sessions.get(session_id) {
                return Ok(Some((entry.key().clone(), camera_id.value().clone())));
            }
        }
        Ok(None)
    }
}

// ---------------------------------------------------------------------------
// Redis backend
// ---------------------------------------------------------------------------

/// Key layout (prefix `todd`):
/// ```text
/// todd:rooms               SET of room ids (lazy-cleaned on reads)
/// todd:room:{id}           JSON room, EXPIRE = room TTL
/// todd:room:{id}:sessions  HASH session_id -> camera_id, EXPIRE refreshed
///                          on every write
/// todd:session:{id}        "{room_id}|{camera_id}", EXPIRE = session TTL
/// ```
pub struct RedisRoomStore {
    /// `AsyncCommands` requires `&mut self`, while the `RoomStore` trait
    /// methods receive `&self` (it must stay object-safe behind
    /// `Arc<dyn RoomStore>`). A tokio Mutex bridges the gap: each method
    /// locks, executes its commands, and releases.
    ///
    /// `ConnectionManager` (not a raw `Connection`) is used inside the
    /// mutex because it reconnects automatically and multiplexes commands
    /// — a dropped Redis is not a dead service.
    conn: tokio::sync::Mutex<redis::aio::ConnectionManager>,
    prefix: String,
}

impl RedisRoomStore {
    pub async fn new(url: &str) -> Result<Self, AppError> {
        let client = redis::Client::open(url)
            .map_err(|e| AppError::Internal(format!("invalid REDIS_URL: {e}")))?;
        let conn = redis::aio::ConnectionManager::new(client)
            .await
            .map_err(|e| AppError::Internal(format!("redis connection failed: {e}")))?;
        Ok(Self {
            conn: tokio::sync::Mutex::new(conn),
            prefix: "todd".to_string(),
        })
    }

    fn room_key(&self, id: &str) -> String {
        format!("{}:room:{id}", self.prefix)
    }
    fn sessions_key(&self, id: &str) -> String {
        format!("{}:room:{id}:sessions", self.prefix)
    }
    fn session_key(&self, id: &str) -> String {
        format!("{}:session:{id}", self.prefix)
    }
    fn index_key(&self) -> String {
        format!("{}:rooms", self.prefix)
    }
}

fn redis_err(e: redis::RedisError) -> AppError {
    AppError::Internal(format!("redis error: {e}"))
}

#[async_trait]
impl RoomStore for RedisRoomStore {
    async fn upsert_room(&self, room: &Room, ttl_secs: u64) -> Result<(), AppError> {
        let json = serde_json::to_string(room)
            .map_err(|e| AppError::Internal(format!("room serialization failed: {e}")))?;

        // Lock the connection for the duration of the write.
        let mut conn = self.conn.lock().await;
        conn.set_ex::<_, _, ()>(self.room_key(&room.id), json, ttl_secs)
            .await
            .map_err(redis_err)?;
        conn.sadd::<_, _, ()>(self.index_key(), &room.id)
            .await
            .map_err(redis_err)?;
        Ok(())
    }

    async fn get_room(&self, room_id: &str) -> Result<Option<Room>, AppError> {
        let raw: Option<String> = {
            let mut conn = self.conn.lock().await;
            conn.get(self.room_key(room_id)).await.map_err(redis_err)?
        };

        let room: Option<Room> = match raw {
            Some(json) => {
                let room: Room = serde_json::from_str(&json)
                    .map_err(|e| AppError::Internal(format!("room deserialization failed: {e}")))?;
                Some(room)
            }
            None => None,
        };

        if room.is_none() {
            // Key expired — drop the stale index entry.
            let mut conn = self.conn.lock().await;
            let _: Result<(), redis::RedisError> = conn.srem(self.index_key(), room_id).await;
        }
        Ok(room)
    }

    async fn list_rooms(&self) -> Result<Vec<Room>, AppError> {
        let ids: Vec<String> = {
            let mut conn = self.conn.lock().await;
            conn.smembers(self.index_key()).await.map_err(redis_err)?
        };

        let mut rooms: Vec<Room> = Vec::with_capacity(ids.len());
        for id in ids {
            let room: Option<Room> = self.get_room(&id).await?;
            if let Some(room) = room {
                rooms.push(room);
            }
        }
        Ok(rooms)
    }

    async fn delete_room(&self, room_id: &str) -> Result<(), AppError> {
        let mut conn = self.conn.lock().await;

        let session_ids: Vec<String> = conn
            .hkeys(self.sessions_key(room_id))
            .await
            .map_err(redis_err)?;
        for session_id in session_ids {
            let _: Result<(), redis::RedisError> = conn.del(self.session_key(&session_id)).await;
        }
        conn.del::<_, ()>(self.room_key(room_id))
            .await
            .map_err(redis_err)?;
        conn.del::<_, ()>(self.sessions_key(room_id))
            .await
            .map_err(redis_err)?;
        conn.srem::<_, _, ()>(self.index_key(), room_id)
            .await
            .map_err(redis_err)?;
        Ok(())
    }

    async fn upsert_camera(
        &self,
        room_id: &str,
        camera: &CameraInfo,
        ttl_secs: u64,
    ) -> Result<(), AppError> {
        let mut conn = self.conn.lock().await;
        let room_key = self.room_key(room_id);
        let raw: Option<String> = conn.get(&room_key).await.map_err(redis_err)?;
        let Some(raw) = raw else {
            return Err(AppError::NotFound(format!("room {room_id}")));
        };

        let mut room: Room = serde_json::from_str(&raw)
            .map_err(|e| AppError::Internal(format!("room deserialization failed: {e}")))?;
        match room
            .cameras
            .iter_mut()
            .find(|existing| existing.id == camera.id)
        {
            Some(existing) => *existing = camera.clone(),
            None => room.cameras.push(camera.clone()),
        }

        let json = serde_json::to_string(&room)
            .map_err(|e| AppError::Internal(format!("room serialization failed: {e}")))?;
        // `ttl_secs` is the room's remaining lifetime (computed by the
        // caller) so camera edits never extend or drop the room expiry.
        conn.set_ex::<_, _, ()>(&room_key, json, ttl_secs.max(1))
            .await
            .map_err(redis_err)?;
        Ok(())
    }

    async fn remove_camera(&self, room_id: &str, camera_id: &str) -> Result<(), AppError> {
        let mut conn = self.conn.lock().await;
        let room_key = self.room_key(room_id);
        let raw: Option<String> = conn.get(&room_key).await.map_err(redis_err)?;
        let Some(raw) = raw else {
            return Err(AppError::NotFound(format!("room {room_id}")));
        };

        let mut room: Room = serde_json::from_str(&raw)
            .map_err(|e| AppError::Internal(format!("room deserialization failed: {e}")))?;
        room.cameras.retain(|camera| camera.id != camera_id);

        // Drop the session registry entries of the removed camera so no
        // stale (session -> camera) mapping survives.
        let sessions: Vec<(String, String)> = conn
            .hgetall(self.sessions_key(room_id))
            .await
            .map_err(redis_err)?;
        for (session_id, session_camera) in &sessions {
            if session_camera == camera_id {
                let _: Result<(), redis::RedisError> =
                    conn.hdel(self.sessions_key(room_id), session_id).await;
                let _: Result<(), redis::RedisError> = conn.del(self.session_key(session_id)).await;
            }
        }

        let json = serde_json::to_string(&room)
            .map_err(|e| AppError::Internal(format!("room serialization failed: {e}")))?;
        // Preserve the room's existing expiry: camera edits must not
        // extend (or, worse, drop) the room lifetime. Redis has no
        // KEEPTTL option in this crate version, so read and re-apply the
        // remaining TTL explicitly (`-1` = key has no expiry).
        let remaining: i64 = conn.ttl(&room_key).await.map_err(redis_err)?;
        if remaining < 0 {
            conn.set::<_, _, ()>(&room_key, json)
                .await
                .map_err(redis_err)?;
        } else {
            conn.set_ex::<_, _, ()>(&room_key, json, remaining.max(1) as u64)
                .await
                .map_err(redis_err)?;
        }
        Ok(())
    }

    async fn add_session(
        &self,
        room_id: &str,
        session_id: &str,
        camera_id: &str,
        ttl_secs: u64,
    ) -> Result<(), AppError> {
        let mut conn = self.conn.lock().await;

        // Explicit `()` type annotations: these commands have a generic
        // return type `RV: FromRedisValue` that is discarded here. Without
        // the turbofish, type inference falls back to `!` (never), which
        // `rust_2024_compatibility` denies (dependency_on_unit_never_type_
        // fallback) and Rust 2024 turns into a hard error.
        conn.hset::<_, _, _, ()>(self.sessions_key(room_id), session_id, camera_id)
            .await
            .map_err(redis_err)?;
        conn.expire::<_, ()>(self.sessions_key(room_id), ttl_secs as i64)
            .await
            .map_err(redis_err)?;
        conn.set_ex::<_, _, ()>(
            self.session_key(session_id),
            format!("{room_id}|{camera_id}"),
            ttl_secs,
        )
        .await
        .map_err(redis_err)?;
        Ok(())
    }

    async fn remove_session(&self, room_id: &str, session_id: &str) -> Result<(), AppError> {
        let mut conn = self.conn.lock().await;

        conn.hdel::<_, _, ()>(self.sessions_key(room_id), session_id)
            .await
            .map_err(redis_err)?;
        conn.del::<_, ()>(self.session_key(session_id))
            .await
            .map_err(redis_err)?;
        Ok(())
    }

    async fn list_sessions(&self, room_id: &str) -> Result<Vec<(String, String)>, AppError> {
        let mut conn = self.conn.lock().await;
        conn.hgetall(self.sessions_key(room_id))
            .await
            .map_err(redis_err)
    }

    async fn find_session(&self, session_id: &str) -> Result<Option<(String, String)>, AppError> {
        let mut conn = self.conn.lock().await;
        let raw: Option<String> = conn
            .get(self.session_key(session_id))
            .await
            .map_err(redis_err)?;

        let found: Option<(String, String)> = raw.and_then(|value| {
            value
                .split_once('|')
                .map(|(room, camera)| (room.to_string(), camera.to_string()))
        });
        Ok(found)
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Duration as ChronoDuration;
    use todd_common::types::CameraInfo;

    fn sample_room(id: &str) -> Room {
        let now = Utc::now();
        Room {
            id: id.to_string(),
            name: format!("room-{id}"),
            created_at: now,
            expires_at: now + ChronoDuration::seconds(3600),
            cameras: vec![CameraInfo {
                id: "cam-1".to_string(),
                label: None,
                kind: todd_common::types::CameraSourceKind::Whip,
                group: None,
                active: false,
            }],
        }
    }

    fn sample_camera(id: &str, kind: todd_common::types::CameraSourceKind) -> CameraInfo {
        CameraInfo {
            id: id.to_string(),
            label: Some(format!("Camera {id}")),
            kind,
            group: Some("ground".to_string()),
            active: false,
        }
    }

    #[tokio::test]
    async fn memory_store_roundtrip() {
        let store = InMemoryRoomStore::new();
        let room = sample_room("mem-1");

        store.upsert_room(&room, 3600).await.unwrap();
        assert!(store.get_room("mem-1").await.unwrap().is_some());

        store
            .add_session("mem-1", "s1", "cam-1", 600)
            .await
            .unwrap();
        assert_eq!(
            store.find_session("s1").await.unwrap(),
            Some(("mem-1".to_string(), "cam-1".to_string()))
        );
        assert_eq!(store.list_sessions("mem-1").await.unwrap().len(), 1);

        store.remove_session("mem-1", "s1").await.unwrap();
        assert!(store.find_session("s1").await.unwrap().is_none());

        store.delete_room("mem-1").await.unwrap();
        assert!(store.get_room("mem-1").await.unwrap().is_none());
    }

    #[tokio::test]
    async fn memory_store_camera_crud() {
        use todd_common::types::CameraSourceKind;

        let store = InMemoryRoomStore::new();
        store
            .upsert_room(&sample_room("mem-cam"), 3600)
            .await
            .unwrap();

        // Add: new camera appears with its metadata intact.
        let cam2 = sample_camera("cam-2", CameraSourceKind::Rtsp);
        store.upsert_camera("mem-cam", &cam2, 3600).await.unwrap();
        let room = store.get_room("mem-cam").await.unwrap().unwrap();
        assert_eq!(room.cameras.len(), 2);
        let stored = room.cameras.iter().find(|c| c.id == "cam-2").unwrap();
        assert_eq!(stored.kind, CameraSourceKind::Rtsp);
        assert_eq!(stored.label.as_deref(), Some("Camera cam-2"));
        assert_eq!(stored.group.as_deref(), Some("ground"));

        // Update: same id replaces metadata instead of duplicating.
        let updated = sample_camera("cam-2", CameraSourceKind::Whip);
        store
            .upsert_camera("mem-cam", &updated, 3600)
            .await
            .unwrap();
        let room = store.get_room("mem-cam").await.unwrap().unwrap();
        assert_eq!(room.cameras.len(), 2);
        let stored = room.cameras.iter().find(|c| c.id == "cam-2").unwrap();
        assert_eq!(stored.kind, CameraSourceKind::Whip);

        // Remove: camera and its session registry entries are gone.
        store
            .add_session("mem-cam", "s-cam2", "cam-2", 600)
            .await
            .unwrap();
        store.remove_camera("mem-cam", "cam-2").await.unwrap();
        let room = store.get_room("mem-cam").await.unwrap().unwrap();
        assert!(!room.cameras.iter().any(|c| c.id == "cam-2"));
        assert!(store.list_sessions("mem-cam").await.unwrap().is_empty());

        // Unknown room errors; missing camera inside an existing room is a no-op.
        assert!(store
            .upsert_camera(
                "missing-room",
                &sample_camera("x", CameraSourceKind::Whip),
                60
            )
            .await
            .is_err());
        store.remove_camera("mem-cam", "ghost").await.unwrap();
    }

    #[tokio::test]
    #[ignore = "requires a running Redis (CI runs it via a service container)"]
    async fn redis_store_roundtrip() {
        let url =
            std::env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1:6379/0".to_string());
        let store = RedisRoomStore::new(&url).await.unwrap();
        let room = sample_room("red-1");

        store.upsert_room(&room, 3600).await.unwrap();
        assert!(store.get_room("red-1").await.unwrap().is_some());

        store
            .add_session("red-1", "s1", "cam-1", 600)
            .await
            .unwrap();
        assert_eq!(
            store.find_session("s1").await.unwrap(),
            Some(("red-1".to_string(), "cam-1".to_string()))
        );
        assert_eq!(store.list_sessions("red-1").await.unwrap().len(), 1);

        store.remove_session("red-1", "s1").await.unwrap();
        assert!(store.find_session("s1").await.unwrap().is_none());

        let extra = sample_camera("cam-2", todd_common::types::CameraSourceKind::Rtsp);
        store.upsert_camera("red-1", &extra, 3600).await.unwrap();
        let room = store.get_room("red-1").await.unwrap().unwrap();
        assert!(room.cameras.iter().any(|c| c.id == "cam-2"));
        store.remove_camera("red-1", "cam-2").await.unwrap();
        let room = store.get_room("red-1").await.unwrap().unwrap();
        assert!(!room.cameras.iter().any(|c| c.id == "cam-2"));

        store.delete_room("red-1").await.unwrap();
        assert!(store.get_room("red-1").await.unwrap().is_none());
    }
}
