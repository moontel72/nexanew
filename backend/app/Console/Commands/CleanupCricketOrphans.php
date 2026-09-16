<?php

namespace App\Console\Commands;

use App\Models\Cricket\MatchModel;
use App\Services\Cricket\CricketDataCleanupService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Removes cricket records that are already orphaned.
 *
 * The live deletion paths ({@see CricketDataCleanupService}) hard-delete the
 * whole child tree, so this command should normally find nothing. It exists
 * for data that was deleted *before* that service was introduced, and as a
 * safety net the operator can run after a manual DB intervention.
 *
 * "Orphaned" here means one of:
 *   - a child row pointing at a match that no longer exists,
 *   - a match whose row is gone-but-not-force-deleted (soft-deleted),
 *   - a score tied to a soft-deleted match, which is what keeps a deleted
 *     fixture's scoreboard reachable by stale URL.
 *
 * Teams and players are deliberately NOT hard-deleted: they use the Trash
 * flow and must stay restorable. Their *fixtures* are detached instead, via
 * `cleanup:teams`.
 *
 * Live video is not checked here. It is sourced from the Todd Broadcaster and
 * carries no database rows to orphan; `purgeMatch` tears its forwarder down.
 */
class CleanupCricketOrphans extends Command
{
    protected $signature = 'cricket:cleanup-orphans
        {--dry-run : Report what would be removed without deleting anything}
        {--force   : Skip the confirmation prompt}';

    protected $description = 'Remove orphaned cricket child records (soft-deleted matches, dangling innings/scores)';

    /** Child tables holding a `match_id` that must always have a live parent. */
    private const MATCH_CHILD_TABLES = [
        'cricket_commentary',
        'cricket_match_sponsors',
        'cricket_match_managers',
        'cricket_voice_score_logs',
        'cricket_match_squads',
        'cricket_best_xi',
        'cricket_replay_clips',
        'cricket_replay_events',
        'cricket_replay_chunks',
        'cricket_innings',
        'cricket_live_scores',
    ];

    public function handle(CricketDataCleanupService $cleanup): int
    {
        $dryRun = (bool) $this->option('dry-run');

        $this->info($dryRun
            ? 'Scanning for orphaned cricket records (dry run — nothing will be deleted)…'
            : 'Scanning for orphaned cricket records…');

        // Match ids that must not own any child data. Three cases:
        //   1. hard-deleted matches whose children outlived them,
        //   2. soft-deleted matches (no Trash UI, so never restorable),
        //   3. live matches whose *tournament* is deleted — the tournament
        //      delete is what removes the fixture from every screen, so a
        //      surviving match row is unreachable except by stale URL.
        $deadMatchIds = MatchModel::withTrashed()
            ->where(function ($query) {
                $query->whereNotNull('deleted_at')
                    ->orWhereIn('tournament_id', function ($sub) {
                        $sub->select('id')
                            ->from('cricket_tournaments')
                            ->whereNotNull('deleted_at');
                    });
            })
            ->pluck('id')
            ->all();

        // Children orphaned by a parent row that is gone entirely have no id
        // in the list above; collect them by scanning for dangling refs.
        $deadMatchIds = array_values(array_unique(array_merge(
            $deadMatchIds,
            $this->matchIdsWithDanglingChildren(),
        )));

        $totals = [];
        $touchedMatches = [];

        foreach ($deadMatchIds as $matchId) {
            $counts = $this->orphanCountsFor((string) $matchId);
            $sum = array_sum($counts);

            if ($sum === 0 && !$this->matchRowIsGone((string) $matchId)) {
                continue;
            }

            $touchedMatches[] = (string) $matchId;

            if (!$dryRun) {
                // Reuse the live path so cache flushes and the realtime
                // "overlay clear" broadcast happen exactly as they would for
                // an interactive delete.
                $cleanup->purgeMatch((string) $matchId);

                // A fixture whose tournament is gone is still a *live* row
                // (`deleted_at = NULL`), so `purgeMatch` leaves it behind.
                // Force-delete it or every screen keeps resolving it.
                MatchModel::withTrashed()->find($matchId)?->forceDelete();
            }

            foreach ($counts as $table => $count) {
                $totals[$table] = ($totals[$table] ?? 0) + $count;
            }
        }

        $this->report($totals, $touchedMatches, $dryRun);

        return self::SUCCESS;
    }

    /**
     * Match ids referenced by child rows but absent from `cricket_matches`.
     *
     * These are invisible to an Eloquent scan (there is no parent row to
     * load), so they have to be found from the child side.
     *
     * @return list<string>
     */
    private function matchIdsWithDanglingChildren(): array
    {
        $liveMatchIds = DB::table('cricket_matches')
            ->whereNull('deleted_at')
            ->pluck('id')
            ->all();

        $found = [];

        foreach (self::MATCH_CHILD_TABLES as $table) {
            $ids = DB::table($table)
                ->whereNotNull('match_id')
                ->distinct()
                ->pluck('match_id')
                ->all();

            foreach ($ids as $id) {
                if (!in_array($id, $liveMatchIds, true)) {
                    $found[(string) $id] = true;
                }
            }
        }

        return array_keys($found);
    }

    /**
     * @return array<string,int> child table => row count
     */
    private function orphanCountsFor(string $matchId): array
    {
        $counts = [];

        foreach (self::MATCH_CHILD_TABLES as $table) {
            $counts[$table] = DB::table($table)->where('match_id', $matchId)->count();
        }

        return array_filter($counts);
    }

    private function matchRowIsGone(string $matchId): bool
    {
        return !DB::table('cricket_matches')->where('id', $matchId)->exists();
    }

    /**
     * @param  array<string,int>  $totals
     * @param  list<string>       $touchedMatches
     */
    private function report(array $totals, array $touchedMatches, bool $dryRun): void
    {
        if (empty($totals)) {
            $this->info('No orphaned records found. Nothing to clean up.');

            return;
        }

        $rows = [];
        foreach ($totals as $table => $count) {
            $rows[] = [$table, $count];
        }

        $this->newLine();
        $this->table(['Table', 'Rows'], $rows);
        $this->line(sprintf(
            '%d orphaned match(es) affected, %d child row(s) total.',
            count($touchedMatches),
            array_sum($totals)
        ));

        if ($dryRun) {
            $this->warn('Dry run — nothing was deleted. Re-run without --dry-run to apply.');
        } else {
            $this->info('Cleanup complete. Caches and active-match pointers were flushed per match.');
        }
    }
}
