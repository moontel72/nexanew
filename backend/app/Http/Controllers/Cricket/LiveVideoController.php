<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\MatchModel;
use App\Services\Cricket\CricketStreamSyncService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Live video for a cricket match, sourced from the Todd Broadcaster.
 *
 * There is no camera CRUD here on purpose. Cameras belong to the broadcaster:
 * it publishes them into the Studio room over WHIP, and that room is the only
 * registry. An earlier version of this module let the Cricket Manager create
 * its own camera rows, which produced a second, video-less camera entry in the
 * same room and split the Studio player into two panes.
 *
 * What is left is the one thing the manager must own: making sure the
 * engine→SRS bridge is running so the public page has an HLS playlist.
 */
class LiveVideoController extends Controller
{
    public function __construct(
        private readonly CricketStreamSyncService $sync,
    ) {
    }

    /**
     * Live video state for a match.
     *
     * Reports whether viewers can actually watch right now. The public HLS
     * playlist only exists while the engine→SRS forwarder is running, so a
     * 404 on the playlist is almost always a dead forwarder rather than a
     * playback problem — this endpoint is how an operator tells the two apart.
     */
    public function health(Request $request, string $matchId): JsonResponse
    {
        MatchModel::findOrFail($matchId);

        $health = $this->sync->healthForMatch($matchId);

        return response()->json([
            'match_id' => $matchId,
            'stream_name' => $this->sync->streamNameFor($matchId),
            'rtmp_url' => $this->sync->rtmpUrlFor($matchId),
            'hls_url' => $health['hls_url'],
            'forwarder_state' => $health['forwarder_state'],
            'forwarder_error' => $health['forwarder_error'],
            // Viewers can watch only when the forwarder is writing segments.
            'healthy' => $health['forwarder_state'] === 'running',
        ]);
    }

    /**
     * Re-asserts the engine→SRS bridge for this match.
     *
     * Idempotent and safe to call at any time: a forwarder that is already
     * running is left alone. Returns whether a forwarder is running
     * afterwards, so the console can tell "reconnected" apart from
     * "no broadcaster camera is live yet".
     */
    public function resync(Request $request, string $matchId): JsonResponse
    {
        MatchModel::findOrFail($matchId);

        $running = $this->sync->resyncMatch($matchId);

        return response()->json([
            'match_id' => $matchId,
            'message' => $running
                ? 'Live video reconnected.'
                : 'No live broadcaster camera yet — start the broadcast in Todd Studio first.',
            'forwarder_running' => $running,
            'hls_url' => $this->sync->hlsUrlFor($matchId),
        ]);
    }

    /** Stops the forwarder for this match (used when a match ends). */
    public function stop(Request $request, string $matchId): JsonResponse
    {
        MatchModel::findOrFail($matchId);
        $this->sync->stopForwarderForMatch($matchId);

        return response()->json(['message' => 'Live video stopped.']);
    }
}
