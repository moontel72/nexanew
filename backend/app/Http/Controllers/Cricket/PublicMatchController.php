<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\LiveScore;
use App\Models\Cricket\MatchModel;
use App\Models\Cricket\Sponsor;
use App\Models\Cricket\Tournament;
use App\Services\Cricket\LiveScoreService;
use Illuminate\Http\Request;

/**
 * PublicMatchController — No-auth endpoints for public viewers.
 *
 * These endpoints are consumed by the Flutter public app and web PWA.
 * They read from Redis cache or PostgreSQL directly — zero auth required.
 */
class PublicMatchController extends Controller
{
    public function __construct(private readonly LiveScoreService $scoreService)
    {
    }

    /**
     * Phase 4 — full scorecard for public fans (both innings with
     * batting/bowling scorecards, extras, fall of wickets).
     */
    public function scorecard(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        return response()->json($this->scoreService->fullScorecard($matchId));
    }

    /**
     * Realtime (WebSocket) connection details for live score streaming.
     *
     * The client connects same-origin through Nginx (which proxies
     * /app and /apps to the Reverb server), so only the app key and
     * path are needed. Everything is read from config — nothing hardcoded.
     */
    public function realtimeConfig(): \Illuminate\Http\JsonResponse
    {
        $apps = config('reverb.apps.apps', []);
        $app = $apps[0] ?? [];

        return response()->json([
            'driver' => config('broadcasting.default', 'log'),
            'key' => $app['key'] ?? null,
            'path' => '/app',
        ]);
    }

    /**
     * Get the currently active tournament.
     */
    public function activeTournament(): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::where('status', 'active')
            ->where('is_active', true)
            ->first();

        if (!$tournament) {
            return response()->json([
                'tournament' => null,
                'message' => 'No active tournament.',
            ], 200);
        }

        return response()->json([
            'tournament' => [
                'id' => $tournament->id,
                'name' => $tournament->name,
                'location' => $tournament->location,
                'start_date' => $tournament->start_date,
                'end_date' => $tournament->end_date,
                'logo_url' => $tournament->logo_url,
                'status' => $tournament->status,
            ],
        ]);
    }

    /**
     * Get all live/in-progress matches for public display.
     */
    public function liveMatches(Request $request): \Illuminate\Http\JsonResponse
    {
        $tournamentId = $request->tournament_id;

        $matches = MatchModel::with(['teamA:id,name,short_code,logo_url', 'teamB:id,name,short_code,logo_url'])
            ->when($tournamentId, fn($q) => $q->where('tournament_id', $tournamentId))
            ->whereIn('status', ['in_progress', 'innings_break', 'toss_done'])
            ->orderBy('scheduled_at')
            ->get()
            ->map(function ($match) {
                // Try cached score first
                $cached = LiveScoreService::getCachedScore($match->id);

                return [
                    'id' => $match->id,
                    'status' => $match->status,
                    'team_a' => $match->teamA?->name,
                    'team_b' => $match->teamB?->name,
                    'team_a_short' => $match->teamA?->short_code,
                    'team_b_short' => $match->teamB?->short_code,
                    'venue' => $match->venue,
                    'match_type' => $match->match_type,
                    'live_score' => $cached ?? $match->liveScore?->full_snapshot,
                ];
            });

        return response()->json(['matches' => $matches]);
    }

    /**
     * Get all matches for a tournament (schedule view).
     * Explicitly maps team relations so the public Flutter app receives
     * team names + short codes instead of raw FK ids.
     */
    public function allMatches(Request $request): \Illuminate\Http\JsonResponse
    {
        $tournamentId = $request->tournament_id;

        if (!$tournamentId) {
            $active = Tournament::where('is_active', true)->first();
            $tournamentId = $active?->id;
        }

        $matches = MatchModel::with(['teamA:id,name,short_code,logo_url', 'teamB:id,name,short_code,logo_url', 'ground:id,name,location'])
            ->where('tournament_id', $tournamentId)
            ->orderBy('scheduled_at')
            ->get()
            ->map(function ($match) {
                $cached = LiveScoreService::getCachedScore($match->id);

                return [
                    'id' => $match->id,
                    'status' => $match->status,
                    'team_a' => $match->teamA?->name,
                    'team_b' => $match->teamB?->name,
                    'team_a_short' => $match->teamA?->short_code,
                    'team_b_short' => $match->teamB?->short_code,
                    'team_a_id' => $match->team_a_id,
                    'team_b_id' => $match->team_b_id,
                    'venue' => $match->venue,
                    'match_type' => $match->match_type,
                    'overs_per_side' => $match->overs_per_side,
                    'scheduled_at' => $match->scheduled_at?->toIso8601String(),
                    'stage' => $match->stage,
                    'ground_id' => $match->ground_id,
                    'ground' => $match->ground ? [
                        'name' => $match->ground->name,
                        'location' => $match->ground->location,
                    ] : null,
                    'live_score' => $cached ?? $match->liveScore?->full_snapshot,
                ];
            });

        return response()->json(['matches' => $matches]);
    }

    /**
     * Get public score for a match.
     */
    public function score(string $matchId): \Illuminate\Http\JsonResponse
    {
        $cached = LiveScoreService::getCachedScore($matchId);
        if ($cached) {
            return response()->json($cached);
        }

        $liveScore = LiveScore::where('match_id', $matchId)->first();
        if (!$liveScore) {
            return response()->json(['message' => 'No live score yet.'], 404);
        }

        return response()->json($liveScore->full_snapshot);
    }

    /**
     * Live video URL for a match, sourced from the Todd Broadcaster.
     *
     * The playlist URL is *derived* from the match id rather than read from
     * a camera registry. That is deliberate: playback must not depend on a
     * database row, because a missing row is indistinguishable from "no
     * stream" and silently breaks the player.
     *
     * A sample of the SS stream-name scheme:
     *   cricket_match_{matchId}_cam1
     *
     * `available` reflects whether the engine is actually writing HLS
     * segments right now. It is advisory — the player can still try the
     * playlist, and a broadcaster that starts later will begin serving it.
     */
    public function streamUrl(string $matchId): \Illuminate\Http\JsonResponse
    {
        $sync = app(\App\Services\Cricket\CricketStreamSyncService::class);

        $health = $sync->healthForMatch($matchId);

        return response()->json([
            'streams' => [[
                'id' => $sync->streamNameFor($matchId),
                'camera_label' => 'Live',
                'camera_number' => 1,
                'hls_playlist_url' => $health['hls_url'],
                'is_primary' => true,
            ]],
            'available' => $health['forwarder_state'] === 'running',
            'source' => 'broadcaster',
        ]);
    }

    /**
     * Get teams for the active tournament.
     */
    public function teams(Request $request): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::where('is_active', true)->first();
        if (!$tournament) {
            return response()->json(['teams' => []]);
        }

        $teams = $tournament->teams()
            ->withCount('players')
            ->orderBy('name')
            ->get();

        return response()->json(['teams' => $teams]);
    }

    /**
     * Get active sponsors for a match (for banner display).
     */
    public function matchSponsors(string $matchId): \Illuminate\Http\JsonResponse
    {
        $sponsors = \App\Models\Cricket\MatchSponsor::with('sponsor')
            ->where('match_id', $matchId)
            ->where('is_active', true)
            ->orderBy('display_order')
            ->get()
            ->map(fn($ms) => [
                'placement' => $ms->placement,
                'name' => $ms->sponsor->name,
                'logo_url' => $ms->sponsor->logo_url,
                'banner_image_url' => $ms->sponsor->banner_image_url,
                'website_url' => $ms->sponsor->website_url,
                'tier' => $ms->sponsor->tier,
            ]);

        return response()->json(['sponsors' => $sponsors]);
    }
}
