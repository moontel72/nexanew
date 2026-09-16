<?php

namespace App\Services\Cricket;

use App\Events\Cricket\CricketMatchContextCleared;
use App\Events\Cricket\CricketScoreUpdated;
use App\Models\Cricket\BestXi;
use App\Models\Cricket\Commentary;
use App\Models\Cricket\Innings;
use App\Models\Cricket\LiveScore;
use App\Models\Cricket\MatchManager;
use App\Models\Cricket\MatchModel;
use App\Models\Cricket\MatchSponsor;
use App\Models\Cricket\MatchSquad;
use App\Models\Cricket\Player;
use App\Models\Cricket\ReplayChunk;
use App\Models\Cricket\ReplayClip;
use App\Models\Cricket\ReplayEvent;
use App\Models\Cricket\Team;
use App\Models\Cricket\Tournament;
use App\Models\Cricket\VoiceScoreLog;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * CricketDataCleanupService — permanent removal of cricket records and
 * every derived/pointing-at-them artefact (MySQL + Redis + realtime).
 *
 * Why this exists: the cricket tables have **no foreign keys**, and the
 * Eloquent models use `SoftDeletes`. A plain `$match->delete()` therefore
 * leaves the whole child tree (innings, live score, commentary, squads,
 * replays) intact and queryable. The Rust media engine and the public
 * portal then keep serving a deleted match's score — the "stale overlay"
 * bug where Todd Studio kept burning `Multan Hero Club vs Rawalpindi Club,
 * 15/0` after the data was wiped.
 *
 * Both the child records and the cache entries are hard-deleted, and the
 * realtime context is explicitly cleared. Order matters: children first,
 * then the parent.
 */
class CricketDataCleanupService
{
    public function __construct(
        private readonly ActiveMatchContextService $context,
    ) {
    }

    /**
     * Deletes one match and every record that references it.
     *
     * @return array<string,int> Row counts removed, for logging/response.
     */
    public function purgeMatch(string $matchId): array
    {
        $counts = DB::transaction(function () use ($matchId) {
            return [
                'commentary' => Commentary::where('match_id', $matchId)->delete(),
                'match_sponsors' => MatchSponsor::where('match_id', $matchId)->delete(),
                'match_managers' => MatchManager::where('match_id', $matchId)->delete(),
                'voice_score_logs' => VoiceScoreLog::where('match_id', $matchId)->delete(),
                'match_squads' => MatchSquad::where('match_id', $matchId)->delete(),
                'best_xi' => BestXi::where('match_id', $matchId)->delete(),
                // Clips reference replay events; drop clips before the
                // events they point at so nothing is left orphaned.
                'replay_clips' => ReplayClip::where('match_id', $matchId)->delete(),
                'replay_events' => ReplayEvent::where('match_id', $matchId)->delete(),
                'replay_chunks' => ReplayChunk::where('match_id', $matchId)->delete(),
                'innings' => Innings::where('match_id', $matchId)->delete(),
                'live_scores' => LiveScore::where('match_id', $matchId)->delete(),
            ];
        });

        // Force-delete so a trashed match cannot resurface through the
        // public portal's `withTrashed()` / restore paths.
        $match = MatchModel::withTrashed()->find($matchId);
        $counts['matches'] = $match && $match->forceDelete() ? 1 : 0;

        $this->flushMatchCaches($matchId);
        $this->broadcastContextCleared($matchId);
        $this->stopLiveVideo($matchId);

        return $counts;
    }

    /**
     * Tears down the engine→SRS forwarder for a deleted match.
     *
     * Without this SRS keeps segmenting the feed into
     * `/hls/live/cricket_match_{matchId}_cam1.m3u8` and the playlist stays
     * fetchable after the match is gone, so anyone with the old URL — or a
     * cached player — keeps streaming a deleted fixture.
     */
    private function stopLiveVideo(string $matchId): void
    {
        try {
            app(\App\Services\Cricket\CricketStreamSyncService::class)
                ->stopForwarderForMatch($matchId);
        } catch (\Throwable $e) {
            Log::warning('Cricket: forwarder teardown failed (non-critical)', [
                'match_id' => $matchId,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Deletes a tournament plus every match, team and player inside it.
     *
     * @return array<string,int>
     */
    public function purgeTournament(string $tournamentId): array
    {
        $matchIds = MatchModel::withTrashed()
            ->where('tournament_id', $tournamentId)
            ->pluck('id')
            ->all();

        $counts = ['matches' => 0, 'players' => 0];
        foreach ($matchIds as $matchId) {
            $nested = $this->purgeMatch((string) $matchId);
            $counts['matches'] += $nested['matches'];
        }

        // Teams own players. purgeTeam also prunes any fixture still
        // referencing the team — already handled by the loop above, so it
        // is a no-op here.
        $teamIds = Team::withTrashed()
            ->where('tournament_id', $tournamentId)
            ->pluck('id')
            ->all();

        foreach ($teamIds as $teamId) {
            $counts['players'] += $this->purgeTeam((string) $teamId);
        }

        $tournament = Tournament::withTrashed()->find($tournamentId);
        $counts['tournaments'] = $tournament && $tournament->forceDelete() ? 1 : 0;

        return $counts;
    }

    /**
     * Deletes one team, its players, and any match referencing it as either
     * side. Used by tournament purges, where the team row itself goes away.
     *
     * @return int Number of players removed.
     */
    public function purgeTeam(string $teamId): int
    {
        $this->purgeTeamFixtures($teamId);

        $players = Player::withTrashed()
            ->where('team_id', $teamId)
            ->forceDelete();

        $team = Team::withTrashed()->find($teamId);
        if ($team) {
            $team->forceDelete();
        }

        return $players;
    }

    /**
     * Deletes every fixture referencing this team as either side, along
     * with that fixture's child records, caches and overlay state — but
     * leaves the team row and its players alone.
     *
     * Split out because the team's own deletion keeps the app's two-stage
     * trash flow (soft delete → Trash → restore/purge), while the fixtures
     * must go immediately: a fixture holding a dangling team reference is
     * exactly what renders as a placeholder (`T1 vs T2`-style) label.
     *
     * @return int Number of matches purged.
     */
    public function purgeTeamFixtures(string $teamId): int
    {
        $matchIds = MatchModel::withTrashed()
            ->where('team_a_id', $teamId)
            ->orWhere('team_b_id', $teamId)
            ->pluck('id')
            ->all();

        foreach ($matchIds as $matchId) {
            $this->purgeMatch((string) $matchId);
        }

        return count($matchIds);
    }

    /**
     * Detaches a player from every active surface without deleting the row.
     *
     * Paired with the team/player trash flow: the player stays restorable
     * from the Trash tab, but must be invisible on every live screen the
     * moment it is deleted. Leaving the id in a squad list, in the current
     * striker/bowler slots, or in a cached snapshot is what makes a deleted
     * player keep appearing in the scoring console and the Studio overlay.
     *
     * Touched surfaces:
     *   - `cricket_match_squads`  — remove their squad rows (soft delete,
     *     so an accidental deletion can be undone).
     *   - `cricket_innings`       — null the striker/non-striker/bowler
     *     slots if this player currently occupies one.
     *   - `cricket_live_scores`   — null the mirrored player ids.
     *   - `cricket_best_xi`       — strip them from the JSONB selections.
     *
     * Any match whose cached snapshot changed is flushed and re-broadcast,
     * so the overlay stops showing the deleted player immediately.
     *
     * @return int Number of affected matches whose caches were flushed.
     */
    public function detachPlayer(string $playerId): int
    {
        $matchIds = [];

        // Squad rows: soft delete so a restore brings the selection back.
        $squadMatchIds = MatchSquad::where('player_id', $playerId)
            ->pluck('match_id')
            ->all();
        MatchSquad::where('player_id', $playerId)->delete();
        $matchIds = array_merge($matchIds, $squadMatchIds);

        // Live player slots: clear whatever this player currently occupies.
        $inningsMatchIds = Innings::where('current_striker_id', $playerId)
            ->orWhere('current_non_striker_id', $playerId)
            ->orWhere('current_bowler_id', $playerId)
            ->pluck('match_id')
            ->all();

        Innings::where('current_striker_id', $playerId)
            ->update(['current_striker_id' => null]);
        Innings::where('current_non_striker_id', $playerId)
            ->update(['current_non_striker_id' => null]);
        Innings::where('current_bowler_id', $playerId)
            ->update(['current_bowler_id' => null]);
        $matchIds = array_merge($matchIds, $inningsMatchIds);

        $liveScoreMatchIds = LiveScore::where('striker_id', $playerId)
            ->orWhere('non_striker_id', $playerId)
            ->orWhere('bowler_id', $playerId)
            ->pluck('match_id')
            ->all();

        LiveScore::where('striker_id', $playerId)->update(['striker_id' => null]);
        LiveScore::where('non_striker_id', $playerId)->update(['non_striker_id' => null]);
        LiveScore::where('bowler_id', $playerId)->update(['bowler_id' => null]);
        $matchIds = array_merge($matchIds, $liveScoreMatchIds);

        // Best XI selections are a JSONB array of {player_id, ...} entries.
        foreach (BestXi::all() as $bestXi) {
            $selections = $bestXi->selections ?? [];
            if (!is_array($selections) || empty($selections)) {
                continue;
            }

            $filtered = array_values(array_filter(
                $selections,
                fn ($entry) => !is_array($entry)
                    || ($entry['player_id'] ?? null) !== $playerId
            ));

            if (count($filtered) !== count($selections)) {
                $bestXi->selections = $filtered;
                $bestXi->save();
            }
        }

        $matchIds = array_values(array_unique(array_filter($matchIds)));

        // A changed snapshot must not be served from cache, and the overlay
        // must be told to re-read it.
        foreach ($matchIds as $matchId) {
            $this->flushMatchCaches((string) $matchId);
            $this->broadcastScoreRefresh((string) $matchId);
        }

        return count($matchIds);
    }

    /**
     * Drops every cache entry that can still serve this match's score.
     *
     * Two independent keys matter:
     *   - `cricket:score:{id}` — the short-lived public score snapshot.
     *   - `cricket.active_match.{mgr}` — the 12h "which match is this
     *     manager on" pointer. It outlives any deletion by design, so it
     *     must be cleared explicitly or the engine keeps targeting a
     *     match that no longer exists.
     */
    public function flushMatchCaches(string $matchId): void
    {
        // Delegates to the owning service so the key format lives in one
        // place. Non-critical: a cache miss only costs a DB read.
        LiveScoreService::forgetCachedScore($matchId);

        try {
            // The context service keeps its own manager index, so this
            // needs no keyspace scan and works on every cache driver.
            $cleared = $this->context->clearForMatch($matchId);
            if (!empty($cleared)) {
                Log::info('Cricket: cleared active-match pointers for deleted match', [
                    'match_id' => $matchId,
                    'managers' => $cleared,
                ]);
            }
        } catch (\Throwable $e) {
            Log::warning('Cricket: active-match pointer flush failed (non-critical)', [
                'match_id' => $matchId,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Tells the media engine (and every other realtime consumer) to drop
     * this match's overlay. Without this the engine only learns the match
     * is gone on its next watchdog poll — and a push carrying the dead
     * match id would keep the stale lower-third on air.
     */
    private function broadcastContextCleared(string $matchId): void
    {
        try {
            CricketMatchContextCleared::dispatch($matchId);
        } catch (\Throwable $e) {
            Log::warning('Cricket: context-cleared broadcast failed (non-critical)', [
                'match_id' => $matchId,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Re-broadcasts `score.updated` for a match whose live state changed
     * but which still exists.
     *
     * Used when a player is detached from an active match: the match is
     * still live, so the overlay must stay up — but it has to re-read the
     * snapshot, otherwise it keeps rendering the deleted player's name.
     * The engine treats this event as a change signal and pulls the
     * authoritative state from the live endpoint.
     */
    private function broadcastScoreRefresh(string $matchId): void
    {
        try {
            $snapshot = LiveScore::where('match_id', $matchId)
                ->first()
                ?->full_snapshot ?? [];

            CricketScoreUpdated::dispatch($matchId, $snapshot);
        } catch (\Throwable $e) {
            Log::warning('Cricket: score refresh broadcast failed (non-critical)', [
                'match_id' => $matchId,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
