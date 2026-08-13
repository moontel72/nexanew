<?php

namespace App\Services\Cricket;

use App\Models\Cricket\MatchModel;
use App\Models\Cricket\ReplayChunk;
use App\Models\Cricket\ReplayClip;
use App\Models\Cricket\ReplayEvent;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * ReplayService — Core replay & video chunking service.
 *
 * Handles:
 *   - Recording chunk completions from the Rust sidecar
 *   - Marking replay events with frame-precise timestamps
 *   - Creating trimmed clips with configurable buffer offsets
 *   - Publishing clips for public viewing
 */
class ReplayService
{
    /**
     * Record a completed 5-minute chunk from the Rust sidecar.
     */
    public function recordChunk(array $data): ReplayChunk
    {
        return DB::transaction(function () use ($data) {
            $chunk = ReplayChunk::create([
                'match_id' => $data['match_id'],
                'chunk_counter' => $data['chunk_counter'],
                'file_path' => $data['file_path'],
                'start_timestamp' => $data['start_timestamp'],
                'end_timestamp' => $data['end_timestamp'],
                'duration_seconds' => $data['duration_seconds'] ?? 300,
                'file_size_bytes' => $data['file_size_bytes'] ?? null,
                'is_complete' => true,
            ]);

            Log::info('Cricket: Replay chunk recorded', [
                'match_id' => $data['match_id'],
                'chunk_counter' => $data['chunk_counter'],
                'file' => $data['file_path'],
            ]);

            return $chunk;
        });
    }

    /**
     * Mark a replay event (wicket, boundary, appeal, review, etc.).
     * Captures frame-precise timestamp from the manager's UI.
     */
    public function markEvent(string $matchId, array $data, string $managerId): ReplayEvent
    {
        // Find the chunk that contains this timestamp
        $chunk = $this->findChunkForTimestamp($matchId, $data['frame_timestamp']);

        $event = ReplayEvent::create([
            'match_id' => $matchId,
            'chunk_id' => $chunk?->id,
            'event_type' => $data['event_type'] ?? 'custom',
            'frame_timestamp' => $data['frame_timestamp'],
            'annotation' => $data['annotation'] ?? null,
            'tagged_by_cricket_manager_id' => $managerId,
        ]);

        Log::info('Cricket: Replay event marked', [
            'match_id' => $matchId,
            'event_type' => $data['event_type'] ?? 'custom',
            'frame_ts' => $data['frame_timestamp'],
            'manager' => $managerId,
        ]);

        return $event;
    }

    /**
     * Annotate an existing replay event.
     */
    public function annotateEvent(string $eventId, string $annotation): ReplayEvent
    {
        $event = ReplayEvent::findOrFail($eventId);
        $event->update(['annotation' => $annotation]);
        return $event;
    }

    /**
     * List all marked events for a match.
     */
    public function listEvents(string $matchId): array
    {
        return ReplayEvent::with('chunk')
            ->where('match_id', $matchId)
            ->orderBy('frame_timestamp', 'asc')
            ->get()
            ->toArray();
    }

    /**
     * Create a trimmed clip with configurable buffer offsets.
     * This notifies the Rust sidecar to perform the actual FFmpeg trim.
     */
    public function createClip(string $matchId, array $data): ReplayClip
    {
        $event = ReplayEvent::findOrFail($data['event_id']);

        $clip = ReplayClip::create([
            'match_id' => $matchId,
            'event_id' => $data['event_id'],
            'clip_file_path' => '', // Populated by Rust sidecar after trimming
            'buffer_before_ms' => $data['buffer_before_ms'] ?? 5000,
            'buffer_after_ms' => $data['buffer_after_ms'] ?? 5000,
            'playback_speed' => $data['playback_speed'] ?? 1.0,
        ]);

        // TODO: Send clip request to Rust sidecar via HTTP POST :9090
        $this->requestClipTrim($clip);

        return $clip;
    }

    /**
     * Publish a clip for public viewing.
     */
    public function publishClip(string $clipId): ReplayClip
    {
        $clip = ReplayClip::findOrFail($clipId);
        $clip->update([
            'is_published' => true,
            'published_at' => now(),
        ]);

        Log::info('Cricket: Replay clip published', [
            'clip_id' => $clipId,
            'match_id' => $clip->match_id,
        ]);

        return $clip;
    }

    /**
     * Delete a clip.
     */
    public function deleteClip(string $clipId): void
    {
        $clip = ReplayClip::findOrFail($clipId);

        // Delete file if exists
        if ($clip->clip_file_path && file_exists($clip->clip_file_path)) {
            unlink($clip->clip_file_path);
        }

        $clip->delete();
    }

    /**
     * Get public replays for a match.
     */
    public function getPublicReplays(string $matchId): array
    {
        return ReplayClip::with('event')
            ->where('match_id', $matchId)
            ->where('is_published', true)
            ->orderBy('published_at', 'desc')
            ->get()
            ->toArray();
    }

    /**
     * Generate a public HLS URL for a replay clip.
     * In production, this would point to a CDN-served HLS playlist.
     */
    public function getClipStreamUrl(string $clipId): ?string
    {
        $clip = ReplayClip::find($clipId);
        if (!$clip || !$clip->is_published) {
            return null;
        }

        // Convert mp4 to HLS path
        $path = $clip->clip_file_path;
        if (empty($path)) return null;

        $hlsPath = str_replace('.mp4', '.m3u8', $path);
        $relativePath = str_replace('/var/replays/', '', $hlsPath);

        return config('app.url') . '/replays/' . $relativePath;
    }

    // ── Private helpers ──────────────────────────────────────

    private function findChunkForTimestamp(string $matchId, int $frameTimestampMs): ?ReplayChunk
    {
        // Convert ms to approximate server time
        $match = MatchModel::find($matchId);
        if (!$match || !$match->started_at) return null;

        $eventTime = $match->started_at->copy()->addMilliseconds($frameTimestampMs);

        return ReplayChunk::where('match_id', $matchId)
            ->where('start_timestamp', '<=', $eventTime)
            ->where('end_timestamp', '>=', $eventTime)
            ->first();
    }

    /**
     * Ask the Rust video-chunker sidecar to trim the clip from its
     * source chunk. The sidecar runs FFmpeg with the buffer offsets and
     * speed filter, then returns the output path.
     *
     * Never throws: clip creation must succeed even when the sidecar is
     * down — the clip stays with an empty file path until trimmed.
     */
    private function requestClipTrim(ReplayClip $clip): void
    {
        $chunk = $clip->event?->chunk;
        if (!$chunk || empty($chunk->file_path) || !file_exists($chunk->file_path)) {
            Log::warning('Cricket: Replay clip trim skipped — source chunk not available', [
                'clip_id' => $clip->id,
                'chunk_id' => $chunk?->id,
            ]);
            return;
        }

        $outputPath = '/var/replays/' . $clip->match_id . '/clips/' . $clip->id . '.mp4';
        $baseUrl = rtrim(env('RUST_CHUNKER_URL', 'http://127.0.0.1:9090'), '/');

        try {
            $response = Http::timeout(300)->post($baseUrl . '/clip/trim', [
                'clip_id' => $clip->id,
                'chunk_id' => $chunk->id,
                'source_path' => $chunk->file_path,
                'buffer_before_ms' => (int) $clip->buffer_before_ms,
                'buffer_after_ms' => (int) $clip->buffer_after_ms,
                'speed' => (float) ($clip->playback_speed ?? 1.0),
                'output_path' => $outputPath,
            ]);

            if ($response->successful() && $response->json('success')) {
                $resolvedPath = $response->json('output_path') ?? $outputPath;
                $clip->update(['clip_file_path' => $resolvedPath]);
                Log::info('Cricket: Replay clip trimmed by Rust sidecar', [
                    'clip_id' => $clip->id,
                    'output' => $resolvedPath,
                ]);
            } else {
                Log::warning('Cricket: Replay clip trim failed', [
                    'clip_id' => $clip->id,
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
            }
        } catch (\Throwable $e) {
            Log::warning('Cricket: Rust sidecar unreachable for clip trim', [
                'clip_id' => $clip->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
