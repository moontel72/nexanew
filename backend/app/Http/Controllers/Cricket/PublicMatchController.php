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
    /**
     * Get the currently active tournament.
     */
    public function activeTournament(): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::where('status', 'active')
            ->where('is_active', true)
            ->first();

        if (!$tournament) {
            return response()->json(['message' => 'No active tournament.'], 404);
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
     */
    public function allMatches(Request $request): \Illuminate\Http\JsonResponse
    {
        $tournamentId = $request->tournament_id;

        if (!$tournamentId) {
            $active = Tournament::where('is_active', true)->first();
            $tournamentId = $active?->id;
        }

        $matches = MatchModel::with(['teamA:id,name,short_code,logo_url', 'teamB:id,name,short_code,logo_url'])
            ->where('tournament_id', $tournamentId)
            ->orderBy('scheduled_at')
            ->get();

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
     * Get streaming URLs for a match.
     */
    public function streamUrl(string $matchId): \Illuminate\Http\JsonResponse
    {
        $streams = \App\Models\Cricket\StreamEndpoint::where('match_id', $matchId)
            ->where('stream_status', 'live')
            ->orderBy('is_primary', 'desc')
            ->orderBy('camera_number')
            ->get(['id', 'camera_label', 'camera_number', 'hls_playlist_url', 'is_primary']);

        if ($streams->isEmpty()) {
            return response()->json(['message' => 'No active streams for this match.'], 404);
        }

        return response()->json(['streams' => $streams]);
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
