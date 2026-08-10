use clap::Parser;
use std::path::PathBuf;
use std::process::Command;
use std::sync::Arc;
use chrono::Utc;
use reqwest::Client;
use serde_json::json;
use tokio::sync::Mutex;
use tracing::{error, info, warn};

// ── CLI Arguments ──────────────────────────────────────────────

#[derive(Parser, Debug)]
#[command(name = "video-chunker", version = "0.1.0")]
struct Args {
    #[arg(long, default_value = "/var/www/traceodd/public/hls")]
    hls_dir: PathBuf,
    #[arg(long, default_value = "/var/replays")]
    replay_dir: PathBuf,
    #[arg(long, default_value = "http://127.0.0.1/api/v1/cricket/internal")]
    laravel_url: String,
    #[arg(long, default_value_t = 9090)]
    http_port: u16,
    #[arg(long, default_value_t = 300)]
    chunk_duration_secs: u64,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();
    let args = Args::parse();

    info!("NexaTrace Video Chunker v0.1.0 starting");
    info!("HLS dir: {:?}", args.hls_dir);
    info!("Replay dir: {:?}", args.replay_dir);
    info!("Laravel URL: {}", args.laravel_url);

    let engine = Arc::new(ChunkingEngine::new(
        args.hls_dir.clone(),
        args.replay_dir.clone(),
        args.laravel_url.clone(),
        args.chunk_duration_secs,
    ));

    // Spawn watcher
    let e1 = engine.clone();
    let watcher = tokio::spawn(async move {
        if let Err(e) = e1.watch_loop().await {
            error!("Watcher error: {}", e);
        }
    });

    // Start HTTP server for clip trimming
    let e2 = engine.clone();
    let server = tokio::spawn(async move {
        start_http_server(args.http_port, e2).await;
    });

    tokio::select! {
        _ = watcher => info!("Watcher stopped"),
        _ = server => info!("Server stopped"),
    }
}

// ── Chunking Engine ────────────────────────────────────────────

struct ChunkingEngine {
    hls_dir: PathBuf,
    replay_dir: PathBuf,
    laravel_url: String,
    chunk_duration_secs: u64,
    http_client: Client,
    state: Mutex<EngineState>,
}

struct EngineState {
    current_match_id: Option<String>,
    current_counter: u32,
    chunk_start: Option<chrono::DateTime<Utc>>,
    segment_buffer: Vec<PathBuf>,
}

impl ChunkingEngine {
    fn new(
        hls_dir: PathBuf,
        replay_dir: PathBuf,
        laravel_url: String,
        chunk_duration_secs: u64,
    ) -> Self {
        Self {
            hls_dir,
            replay_dir,
            laravel_url,
            chunk_duration_secs,
            http_client: Client::new(),
            state: Mutex::new(EngineState {
                current_match_id: None,
                current_counter: 0,
                chunk_start: None,
                segment_buffer: Vec::new(),
            }),
        }
    }

    /// Simple polling-based watch loop (in production, use inotify via `notify` crate).
    async fn watch_loop(&self) -> anyhow::Result<()> {
        info!("Watch loop started — polling HLS directory every 10s");

        loop {
            tokio::time::sleep(tokio::time::Duration::from_secs(10)).await;
            // In production: use notify::Watcher for real-time events.
            // For now, this is a stub demonstrating the architecture.
            info!("Poll tick — checking for new segments...");
        }
    }

    /// Assemble buffered .ts segments into a 5-minute .mp4 chunk using FFmpeg.
    async fn assemble_chunk(
        &self,
        match_id: &str,
        segments: &[PathBuf],
        counter: u32,
        start_time: chrono::DateTime<Utc>,
    ) -> anyhow::Result<()> {
        let timestamp = Utc::now().format("%Y%m%d_%H%M%S");
        let match_dir = self.replay_dir.join(match_id).join("chunks");
        tokio::fs::create_dir_all(&match_dir).await?;

        let output_file = match_dir.join(format!(
            "MATCH_{}_{:06}.mp4",
            timestamp, counter
        ));

        info!(
            "Assembling chunk {:06}: {} → {:?}",
            counter,
            segments.len(),
            output_file
        );

        // Write concat file listing all segments
        let concat_path = match_dir.join(format!("concat_{:06}.txt", counter));
        let concat_content: String = segments
            .iter()
            .map(|p| format!("file '{}'", p.display()))
            .collect::<Vec<_>>()
            .join("\n");
        tokio::fs::write(&concat_path, concat_content).await?;

        // Run FFmpeg concat
        let output = Command::new("ffmpeg")
            .args([
                "-y",
                "-f", "concat",
                "-safe", "0",
                "-i", &concat_path.to_string_lossy(),
                "-c", "copy",
                &output_file.to_string_lossy(),
            ])
            .output()?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            error!("FFmpeg concat failed: {}", stderr);
            return Err(anyhow::anyhow!("FFmpeg concat failed"));
        }

        // Clean up concat file
        let _ = tokio::fs::remove_file(&concat_path).await;

        let end_time = Utc::now();
        let duration = (end_time - start_time).num_seconds() as u64;
        let file_size = tokio::fs::metadata(&output_file).await?.len();

        // Notify Laravel
        self.notify_laravel(
            match_id,
            counter,
            &output_file.to_string_lossy(),
            start_time,
            end_time,
            duration,
            file_size,
        )
        .await?;

        info!("Chunk {:06} completed successfully", counter);
        Ok(())
    }

    /// Notify Laravel backend that a chunk is complete.
    async fn notify_laravel(
        &self,
        match_id: &str,
        counter: u32,
        file_path: &str,
        start: chrono::DateTime<Utc>,
        end: chrono::DateTime<Utc>,
        duration: u64,
        file_size: u64,
    ) -> anyhow::Result<()> {
        let url = format!("{}/replay/chunk", self.laravel_url);
        let payload = json!({
            "match_id": match_id,
            "chunk_counter": counter,
            "file_path": file_path,
            "start_timestamp": start.to_rfc3339(),
            "end_timestamp": end.to_rfc3339(),
            "duration_seconds": duration,
            "file_size_bytes": file_size,
        });

        let resp = self
            .http_client
            .post(&url)
            .json(&payload)
            .send()
            .await?;

        if !resp.status().is_success() {
            warn!(
                "Laravel notification returned {}: {}",
                resp.status(),
                resp.text().await.unwrap_or_default()
            );
        }

        Ok(())
    }

    /// Trim a clip from a chunk file with buffer offsets and speed.
    pub async fn trim_clip(
        &self,
        source_path: &str,
        buffer_before_ms: i64,
        buffer_after_ms: i64,
        speed: f64,
        output_path: &str,
    ) -> anyhow::Result<()> {
        let duration_ms = buffer_after_ms - buffer_before_ms;

        info!(
            "Trimming clip: {} → {} (buffer: {}ms to {}ms, {}x speed)",
            source_path, output_path, buffer_before_ms, buffer_after_ms, speed
        );

        let temp_output = format!("{}_temp.mp4", output_path);

        // Step 1: Trim with buffer offsets
        let trim = Command::new("ffmpeg")
            .args([
                "-y",
                "-ss", &format!("{}ms", buffer_before_ms),
                "-t", &format!("{}ms", duration_ms),
                "-i", source_path,
                "-c", "copy",
                &temp_output,
            ])
            .output()?;

        if !trim.status.success() {
            anyhow::bail!("FFmpeg trim failed");
        }

        // Step 2: Apply speed filter
        let speed_filter = format!("setpts={}*PTS", 1.0 / speed);
        let audio_filter = format!("atempo={}", speed);

        let output = Command::new("ffmpeg")
            .args([
                "-y",
                "-i", &temp_output,
                "-filter:v", &speed_filter,
                "-filter:a", &audio_filter,
                output_path,
            ])
            .output()?;

        // Clean temp
        let _ = std::fs::remove_file(&temp_output);

        if !output.status.success() {
            anyhow::bail!("FFmpeg speed filter failed");
        }

        info!("Clip trimmed successfully: {}", output_path);
        Ok(())
    }
}

// ── HTTP Server (stub) ─────────────────────────────────────────

async fn start_http_server(_port: u16, _engine: Arc<ChunkingEngine>) {
    info!("HTTP server placeholder — implement with axum or actix-web in production");
    // In production, use axum:
    //
    // use axum::{Router, routing::get, Json};
    //
    // let app = Router::new()
    //     .route("/health", get(|| async { "ok" }))
    //     .route("/clip/trim", post(trim_clip_handler));
    //
    // let listener = tokio::net::TcpListener::bind(("0.0.0.0", port)).await?;
    // axum::serve(listener, app).await?;
}
