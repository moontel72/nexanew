<?php

namespace App\Console\Commands;

use App\Models\Cricket\MatchModel;
use App\Services\Cricket\CricketStreamSyncService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

/**
 * Keeps live video flowing to the public page for every match in progress.
 *
 * The public HLS playlist only exists while the engine→SRS forwarder is
 * running, and that forwarder is tied to one broadcaster publishing session.
 * It therefore cannot survive the normal events of a match day:
 *
 *   - the broadcaster's phone drops Wi-Fi and reconnects (new WHIP session,
 *     new RTP tracks, old forwarder permanently dead),
 *   - the engine restarts (all in-memory forwarder state is lost),
 *   - the match was started before the broadcaster went on air (nothing to
 *     forward yet).
 *
 * In each case the public page shows its player and
 * `/hls/live/cricket_match_{matchId}_cam1.m3u8` returns 404 with nothing in
 * the logs to explain why. This command notices and re-arms the forwarder.
 *
 * Idempotent: a healthy forwarder is detected and left untouched, and a match
 * with no live broadcaster camera is skipped without noise.
 */
class CricketStreamWatchdog extends Command
{
    /**
     * How long to wait before checking whether a re-armed feed really publishes.
     *
     * Long enough for the pipeline to build, connect to SRS and write a first
     * segment; short enough that a per-minute watchdog stays cheap.
     */
    private const VERIFY_SECONDS = 5;

    protected $signature = 'cricket:stream-watchdog
                            {--match= : Only check one match id}
                            {--dry-run : Report what would be re-armed without changing anything}';

    protected $description = 'Re-arms the engine→SRS forwarder for matches in progress (recovers HLS 404s)';

    public function handle(CricketStreamSyncService $sync): int
    {
        // Video only matters while a match is being played. Including every
        // other status would probe the engine for feeds nobody is watching.
        $query = MatchModel::query()
            ->whereIn('status', ['in_progress', 'innings_break']);

        if ($match = $this->option('match')) {
            $query->where('id', $match);
        }

        $matches = $query->get();

        if ($matches->isEmpty()) {
            $this->info('No matches in progress.');

            return self::SUCCESS;
        }

        $dryRun = (bool) $this->option('dry-run');
        $repaired = 0;

        foreach ($matches as $match) {
            $health = $sync->healthForMatch((string) $match->id);

            if ($health['forwarder_state'] === 'running') {
                $this->line(sprintf('  ok      %s — forwarder running', $match->id));

                continue;
            }

            if ($dryRun) {
                $this->warn(sprintf(
                    '  BROKEN  %s — forwarder %s (would re-arm)',
                    $match->id,
                    $health['forwarder_state']
                ));

                continue;
            }

            // Silence here is the common case: the broadcaster has not gone
            // on air yet, so there is nothing to forward. Only report a
            // re-arm that actually changed something.
            if ($sync->resyncMatch((string) $match->id)) {
                $repaired++;

                // `resyncMatch()` returning true only means the engine accepted
                // the forwarder (or already claimed to be running), and the
                // engine reports `running` from the moment a pipeline object
                // exists — not from bytes reaching SRS. So say what was actually
                // achieved instead of promising a restored feed: an optimistic
                // "live video restored" is how a dark public page stayed
                // unexplained for days.
                sleep(self::VERIFY_SECONDS);
                $after = $sync->healthForMatch((string) $match->id);

                $this->info($after['forwarder_state'] === 'running'
                    ? sprintf('  RE-ARMED %s — live video restored', $match->id)
                    : sprintf(
                        '  RE-ARMED %s — forwarder re-created, but nothing is publishing yet (%s). Is the broadcaster on air?',
                        $match->id,
                        $after['forwarder_error'] ?? $after['forwarder_state']
                    ));
            }
        }

        if ($repaired > 0) {
            Log::info('Cricket: stream watchdog re-armed forwarders', [
                'count' => $repaired,
            ]);
            $this->info("Re-armed {$repaired} forwarder(s).");
        } else {
            $this->info('No forwarders needed re-arming.');
        }

        return self::SUCCESS;
    }
}
