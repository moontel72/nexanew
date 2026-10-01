<?php

namespace Tests\Feature;

use App\Services\Cricket\CricketStreamSyncService;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

/**
 * The Cricket Manager's live-video health must not be shadowed by a stale row.
 *
 * WHY THIS EXISTS
 * ---------------
 * The engine never drops a terminal forwarder status row: a forwarder that
 * failed (e.g. `bad request: no RTP received; camera is inactive`) or was
 * stopped keeps its row — with its old error text — under the same target URL.
 * `GET /api/v1/forward/list` returns every row sorted by key
 * (`{room}/{camera}/{url}`), so once the camera id changes the same URL carries
 * several rows. Health used to take the FIRST match. When that row was the dead
 * one, the manager panel showed a red error while a healthy bridge was actually
 * running — which is exactly the "video is live in Todd Studio but the panel
 * says no RTP received" report this test pins down.
 */
class CricketStreamHealthTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.media_engine.url' => 'http://engine.test',
            'services.media_engine.secret' => 'test-secret',
            // Far-end confirmation (SRS + the HLS dir) is opt-in via config; an
            // empty value disables that probe, so these tests exercise only the
            // forwarder-row selection and never touch the network.
            'cricket.streaming.srs_api_url' => '',
            'cricket.streaming.hls_dir' => '',
        ]);
    }

    /**
     * @param  array<int, array<string, mixed>>  $rows
     */
    private function fakeForwarderList(string $url, array $rows): void
    {
        Http::fake([
            '*forward/list*' => Http::response(array_map(
                static fn (array $row): array => ['url' => $url] + $row,
                $rows,
            )),
        ]);
    }

    public function test_a_running_row_wins_over_an_older_failed_row_for_the_same_url(): void
    {
        $service = app(CricketStreamSyncService::class);
        $url = $service->rtmpUrlFor('m1');

        // The failed row is deliberately first: that is the order the old
        // "take the first match" code picked, and it is the reported symptom.
        $this->fakeForwarderList($url, [
            [
                'state' => 'failed',
                'error' => 'bad request: no RTP received; camera is inactive',
                'started_at_ms' => 1000,
            ],
            [
                'state' => 'running',
                'error' => null,
                'started_at_ms' => 2000,
            ],
        ]);

        $health = $service->healthForMatch('m1');

        $this->assertSame('running', $health['forwarder_state']);
        $this->assertNull($health['forwarder_error']);
    }

    public function test_the_newest_failed_row_reports_its_error(): void
    {
        $service = app(CricketStreamSyncService::class);
        $url = $service->rtmpUrlFor('m1');

        $this->fakeForwarderList($url, [
            [
                'state' => 'failed',
                'error' => 'old failure',
                'started_at_ms' => 1000,
            ],
            [
                'state' => 'failed',
                'error' => 'newer failure',
                'started_at_ms' => 5000,
            ],
        ]);

        $health = $service->healthForMatch('m1');

        $this->assertSame('failed', $health['forwarder_state']);
        $this->assertSame('newer failure', $health['forwarder_error']);
    }

    public function test_a_lone_failed_row_is_still_reported(): void
    {
        $service = app(CricketStreamSyncService::class);
        $url = $service->rtmpUrlFor('m1');

        $this->fakeForwarderList($url, [
            [
                'state' => 'failed',
                'error' => 'bad request: no RTP received; camera is inactive',
                'started_at_ms' => 1000,
            ],
        ]);

        $health = $service->healthForMatch('m1');

        $this->assertSame('failed', $health['forwarder_state']);
        $this->assertSame(
            'bad request: no RTP received; camera is inactive',
            $health['forwarder_error'],
        );
    }

    public function test_rows_for_another_target_are_ignored(): void
    {
        $service = app(CricketStreamSyncService::class);
        $url = $service->rtmpUrlFor('m1');

        Http::fake([
            '*forward/list*' => Http::response([
                [
                    'url' => 'rtmp://elsewhere/live/some_other_stream',
                    'state' => 'running',
                    'error' => null,
                    'started_at_ms' => 9000,
                ],
            ]),
        ]);

        $health = $service->healthForMatch('m1');

        $this->assertSame('missing', $health['forwarder_state']);
        $this->assertNull($health['forwarder_error']);
        $this->assertStringContainsString('cricket_match_m1_cam1', $url);
    }
}
