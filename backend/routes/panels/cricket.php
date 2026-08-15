<?php

use App\Http\Controllers\Cricket\BestXiController;
use App\Http\Controllers\Cricket\ClubController;
use App\Http\Controllers\Cricket\CricketManagerAuthController;
use App\Http\Controllers\Cricket\CricketManagerController;
use App\Http\Controllers\Cricket\GroundController;
use App\Http\Controllers\Cricket\LiveScoreController;
use App\Http\Controllers\Cricket\MatchAnalyticsController;
use App\Http\Controllers\Cricket\MatchController;
use App\Http\Controllers\Cricket\PlayerCareerController;
use App\Http\Controllers\Cricket\PlayerController;
use App\Http\Controllers\Cricket\PointsTableController;
use App\Http\Controllers\Cricket\PublicMatchController;
use App\Http\Controllers\Cricket\ReplayController;
use App\Http\Controllers\Cricket\SponsorController;
use App\Http\Controllers\Cricket\SquadController;
use App\Http\Controllers\Cricket\StreamController;
use App\Http\Controllers\Cricket\TeamController;
use App\Http\Controllers\Cricket\TournamentSetupController;
use App\Http\Controllers\Cricket\VoiceScoreController;
use Illuminate\Support\Facades\Route;

/*
|═══════════════════════════════════════════════════════════════
| NEXATRACE — CRICKET MODULE ROUTES
|═══════════════════════════════════════════════════════════════
|
| ROLE HIERARCHY:
|   Admin panel → Cricket Operations Manager(s) → Field Crew
|
| Three route groups:
|   1. PUBLIC  — No auth, consumed by Flutter public app / web PWA
|   2. MANAGER — Cricket Manager auth (Bearer token) — owns all
|               operational cricket features (tournaments, fixtures,
|               teams, players, scoring, streams, replays)
|   3. ADMIN   — Admin panel (Sanctum) — ONLY provisions and
|               manages Cricket Operations Manager accounts
|
| ISOLATION: All routes prefixed `api/v1/cricket/`.
| Zero modification to existing route files.
*/

// ═══════════════════════════════════════════════════════════════
// GROUP 1: PUBLIC ENDPOINTS (No Auth)
// ═══════════════════════════════════════════════════════════════
Route::prefix('api/v1/cricket/public')->group(function (): void {
    Route::get('tournament/active', [PublicMatchController::class, 'activeTournament']);
    Route::get('matches/live', [PublicMatchController::class, 'liveMatches']);
    Route::get('matches', [PublicMatchController::class, 'allMatches']);
    Route::get('matches/{matchId}/score', [PublicMatchController::class, 'score']);
    Route::get('matches/{matchId}/stream', [PublicMatchController::class, 'streamUrl']);
    Route::get('matches/{matchId}/sponsors', [PublicMatchController::class, 'matchSponsors']);
    Route::get('teams', [PublicMatchController::class, 'teams']);

    // Tournament Hub
    Route::get('tournaments/{tournamentId}/standings', [PointsTableController::class, 'standings']);
    Route::get('tournaments/{tournamentId}/top-performers', [PointsTableController::class, 'topPerformers']);

    // Player Career
    Route::get('players/{playerId}/career', [PlayerCareerController::class, 'show']);
    Route::get('players/leaderboard', [PlayerCareerController::class, 'leaderboard']);

    // Match Analytics
    Route::get('matches/{matchId}/wagon-wheel', [MatchAnalyticsController::class, 'wagonWheel']);
    Route::get('matches/{matchId}/run-distribution', [MatchAnalyticsController::class, 'runDistribution']);
    Route::get('matches/{matchId}/side-split', [MatchAnalyticsController::class, 'sideSplit']);
    Route::get('matches/{matchId}/conceded-runs', [MatchAnalyticsController::class, 'concededRuns']);
    Route::get('matches/{matchId}/partnerships', [MatchAnalyticsController::class, 'partnerships']);

    // Clubs
    Route::get('clubs', [ClubController::class, 'index']);
    Route::get('clubs/{identifier}', [ClubController::class, 'show']);

    // Best XI
    Route::get('best-xi', [BestXiController::class, 'index']);
    Route::get('best-xi/{id}', [BestXiController::class, 'show']);

    // AI Health Check
    Route::get('voice-score/health', [VoiceScoreController::class, 'health']);

    // Realtime (WebSocket) connection config for live score streaming
    Route::get('realtime-config', [PublicMatchController::class, 'realtimeConfig']);

    // Public replays
    Route::get('matches/{matchId}/replays', [ReplayController::class, 'publicReplays']);
    Route::get('replays/{clipId}/stream', [ReplayController::class, 'publicStream']);
});

// ═══════════════════════════════════════════════════════════════
// GROUP 2: CRICKET MANAGER ENDPOINTS (Bearer Token Auth)
//
// Authenticated via CricketManagerAuth middleware.
// These endpoints are for the Cricket Manager panel.
// ═══════════════════════════════════════════════════════════════
Route::prefix('api/v1/cricket/manager')
    ->middleware(['cricket.manager'])
    ->group(function (): void {

        // Auth
        Route::post('login', [CricketManagerAuthController::class, 'login'])
            ->withoutMiddleware('cricket.manager');
        Route::post('logout', [CricketManagerAuthController::class, 'logout']);
        Route::get('me', [CricketManagerAuthController::class, 'me']);

        // Match Management — Takeover / Failover
        Route::post('matches/{matchId}/take-over', [MatchController::class, 'takeOver']);

        // Live Scoring
        Route::post('matches/{matchId}/score', [LiveScoreController::class, 'update']);
        Route::post('matches/{matchId}/score/undo', [LiveScoreController::class, 'undoLastBall']);
        Route::get('matches/{matchId}/scorecard', [LiveScoreController::class, 'fullScorecard']);

        // Phase 2 — Ball-by-ball correction interface (unique ball_ids)
        Route::get('matches/{matchId}/deliveries', [LiveScoreController::class, 'deliveries']);
        Route::put('matches/{matchId}/deliveries/{ballId}', [LiveScoreController::class, 'editDelivery']);
        Route::delete('matches/{matchId}/deliveries/{ballId}', [LiveScoreController::class, 'deleteDelivery']);

        // Match lifecycle — toss & start (unlocks the scoring flow end-to-end)
        Route::post('matches/{id}/toss', [MatchController::class, 'updateToss']);
        Route::post('matches/{id}/start', [MatchController::class, 'startMatch']);

        // Squad / Lineup management — playing XI & batting order (Phase 0)
        Route::get('matches/{matchId}/squads', [SquadController::class, 'index']);
        Route::put('matches/{matchId}/squads/{teamId}', [SquadController::class, 'upsert']);

        // Stream Management
        Route::get('matches/{matchId}/streams', [StreamController::class, 'index']);
        Route::post('matches/{matchId}/streams', [StreamController::class, 'store']);
        Route::put('matches/{matchId}/streams/{streamId}', [StreamController::class, 'update']);
        Route::post('matches/{matchId}/streams/{streamId}/activate', [StreamController::class, 'activate']);
        Route::post('matches/{matchId}/streams/{streamId}/deactivate', [StreamController::class, 'deactivate']);
        Route::delete('matches/{matchId}/streams/{streamId}', [StreamController::class, 'destroy']);

        // Voice-to-Score AI
        Route::get('voice-score/health', [VoiceScoreController::class, 'health']);
        Route::post('voice-score/process', [VoiceScoreController::class, 'process']);
        Route::post('voice-score/{logId}/apply', [VoiceScoreController::class, 'apply']);
        Route::post('voice-score/{logId}/reject', [VoiceScoreController::class, 'reject']);
        Route::get('matches/{matchId}/voice-logs', [VoiceScoreController::class, 'history']);

        // Team Management
        Route::get('teams/all', [TeamController::class, 'listAll']);
        Route::get('teams/trashed', [TeamController::class, 'trashed']);
        Route::post('teams', [TeamController::class, 'store']);
        Route::get('teams/{id}', [TeamController::class, 'show']);
        Route::put('teams/{id}', [TeamController::class, 'update']);
        Route::delete('teams/{id}', [TeamController::class, 'destroy']);
        Route::patch('teams/{id}/status', [TeamController::class, 'updateStatus']);
        Route::post('teams/{id}/restore', [TeamController::class, 'restore']);
        Route::delete('teams/{id}/force', [TeamController::class, 'forceDelete']);

        // Player Management
        Route::get('players/all', [PlayerController::class, 'listAll']);
        Route::get('players/trashed', [PlayerController::class, 'trashed']);
        Route::post('players', [PlayerController::class, 'store']);
        Route::get('players/{id}', [PlayerController::class, 'show']);
        Route::put('players/{id}', [PlayerController::class, 'update']);
        Route::delete('players/{id}', [PlayerController::class, 'destroy']);
        Route::patch('players/{id}/status', [PlayerController::class, 'updateStatus']);
        Route::post('players/{id}/restore', [PlayerController::class, 'restore']);
        Route::delete('players/{id}/force', [PlayerController::class, 'forceDelete']);

        // Fixture Scheduling — Match CRUD (manager-scoped)
        Route::get('matches', [MatchController::class, 'index']);
        Route::post('matches', [MatchController::class, 'store']);
        Route::get('matches/{id}', [MatchController::class, 'show']);
        Route::put('matches/{id}', [MatchController::class, 'update']);
        Route::delete('matches/{id}', [MatchController::class, 'destroy']);
        Route::patch('matches/{id}/status', [MatchController::class, 'updateStatus']);

        // Tournament Setup (manager-scoped)
        Route::get('tournaments', [TournamentSetupController::class, 'index']);
        Route::post('tournaments', [TournamentSetupController::class, 'store']);
        Route::get('tournaments/{id}', [TournamentSetupController::class, 'show']);
        Route::put('tournaments/{id}', [TournamentSetupController::class, 'update']);
        Route::post('tournaments/{id}/activate', [TournamentSetupController::class, 'activate']);

        // Fixture Scheduling — Round-Robin auto-generation
        Route::post('tournaments/{tournamentId}/fixtures/generate', [MatchController::class, 'generateFixtures']);

        // Sponsor Management — manager-owned sponsor lifecycle & assignment
        Route::get('sponsors', [SponsorController::class, 'index']);
        Route::post('sponsors', [SponsorController::class, 'store']);
        Route::put('sponsors/{id}', [SponsorController::class, 'update']);
        Route::delete('sponsors/{id}', [SponsorController::class, 'destroy']);
        Route::get('matches/{matchId}/sponsors', [SponsorController::class, 'matchSponsors']);
        Route::post('matches/{matchId}/sponsors', [SponsorController::class, 'assignToMatch']);
        Route::delete('matches/{matchId}/sponsors/{sponsorId}', [SponsorController::class, 'removeFromMatch']);

        // Grounds / Venues registry (manager-scoped)
        Route::get('grounds', [GroundController::class, 'index']);
        Route::post('grounds', [GroundController::class, 'store']);
        Route::put('grounds/{id}', [GroundController::class, 'update']);
        Route::delete('grounds/{id}', [GroundController::class, 'destroy']);

        // Instant Replay / VAR
        Route::post('matches/{matchId}/replay/event', [ReplayController::class, 'markEvent']);
        Route::put('replay/events/{eventId}/annotate', [ReplayController::class, 'annotate']);
        Route::get('matches/{matchId}/replay/events', [ReplayController::class, 'listEvents']);
        Route::post('matches/{matchId}/replay/clip', [ReplayController::class, 'createClip']);
        Route::post('replay/clips/{clipId}/publish', [ReplayController::class, 'publishClip']);
        Route::delete('replay/clips/{clipId}', [ReplayController::class, 'deleteClip']);
    });

// ═══════════════════════════════════════════════════════════════
// GROUP 3: ADMIN PROVISIONING ENDPOINTS (Sanctum Auth)
//
// The admin panel ONLY provisions and manages Cricket Operations
// Manager accounts. All operational cricket features live in the
// Manager panel (GROUP 2).
// ═══════════════════════════════════════════════════════════════
Route::prefix('api/v1/cricket/admin')
    ->middleware(['auth:sanctum', 'sub.admin'])
    ->group(function (): void {

        // Cricket Manager Accounts (provisioned by Sub-Admin)
        Route::get('managers', [CricketManagerController::class, 'index']);
        Route::post('managers', [CricketManagerController::class, 'store']);
        Route::get('managers/{id}', [CricketManagerController::class, 'show']);
        Route::put('managers/{id}', [CricketManagerController::class, 'update']);
        Route::post('managers/{id}/suspend', [CricketManagerController::class, 'suspend']);
        Route::post('managers/{id}/activate', [CricketManagerController::class, 'activate']);
        Route::delete('managers/{id}', [CricketManagerController::class, 'destroy']);
    });

// ═══════════════════════════════════════════════════════════════
// INTERNAL: Sidecar-to-Laravel endpoints (Rust video chunker)
// ═══════════════════════════════════════════════════════════════
Route::prefix('api/v1/cricket/internal')
    ->group(function (): void {
        Route::post('replay/chunk', [ReplayController::class, 'recordChunk']);
    });
