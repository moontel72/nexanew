<?php

namespace App\Console\Commands;

use App\Models\Cricket\StreamEndpoint;
use App\Services\Cricket\CricketStreamSyncService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

/**
 * Keeps the engine→SRS forwarder alive for every stream marked `live`.
 *
 * The public HLS playlist only exists while a forwarder is actually writing
 * to SRS. Activation wires that forwarder once, at the moment a director
 * switches a camera on air — a single shot that cannot survive the normal
 * events of a match day:
 *
 *   - the broadcaster's phone drops Wi-Fi and reconnects (new WHIP session,
 *     new RTP tracks, old forwarder permanently dead),
 *   - the engine restarts (all in-memory forwarder state is lost while the
 *     database still says `live`),
 *   - the camera was activated before its publisher connected (the forwarder
 *     waited for video that never arrived, then gave up).
 *
 * In every one of those cases the stream row says `live`, the public page
 * shows its player, and `/hls/live/{key}.m3u8` returns 404 with nothing in
 * the logs to explain why. This command is the watchdog that notices and
 * re-arms the forwarder.
 *
 * Idempotent: a healthy forwarder is detected and left untouched.
 */
class CricketStreamWatchdog extends Command
{
    protected $signature = 'cricket:stream-watchdog
                            {--match= : Only check one match id}
                            {--dry-run : Report what would be re-armed without changing anything}';

    protected $description = 'Re-arms the engine→SRS forwarder for streams marked live (recovers HLS 404s)';

    public function handle(CricketStreamSyncService $sync): int
    {
        $query = StreamEndpoint::query()->where('stream_status', 'live');

        if ($match = $this->option('match')) {
            $query->where('match_id', $match);
        }

        $streams = $query->get();

        if ($streams->isEmpty()) {
            $this->info('No live streams to check.');

            return self::SUCCESS;
        }

        $dryRun = (bool) $this->option('dry-run');
        $repaired = 0;

        foreach ($streams as $stream) {
            $health = $sync->healthFor($stream);

            if ($health['forwarder_state'] === 'running') {
                $this->line(sprintf(
                    '  ok      cam%s %s — forwarder running',
                    $stream->camera_number,
                    $stream->rtmp_stream_key
                ));

                continue;
            }

            $this->warn(sprintf(
                '  BROKEN  cam%s %s — forwarder %s%s',
                $stream->camera_number,
                $stream->rtmp_stream_key,
                $health['forwarder_state'],
                $health['forwarder_error'] ? ' (' . $health['forwarder_error'] . ')' : ''
            ));

            if ($dryRun) {
                $this->line('          would re-arm (dry run)');

                continue;
            }

            if ($sync->resyncStream($stream)) {
                $repaired++;
                $this->line('          re-armed');
            } else {
                $this->line('          re-arm skipped (no usable broadcaster camera yet)');
            }
        }

        if ($repaired > 0) {
            Log::info('Cricket: stream watchdog re-armed forwarders', [
                'count' => $repaired,
            ]);
            $this->info("Re-armed {$repaired} forwarder(s).");
        } else {
            $this->info('Nothing to re-arm.');
        }

        return self::SUCCESS;
    }
}
