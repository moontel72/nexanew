<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// ═══════════════════════════════════════════════════════════════
// Wave 3 — Scheduled Jobs
// ═══════════════════════════════════════════════════════════════

// Daily purge of expired vendor allowance grants (Section 10.4.4)
Schedule::job(\App\Jobs\PurgeExpiredAllowancesJob::class)
    ->dailyAt('03:00')
    ->withoutOverlapping(300)
    ->onOneServer();

// Every 30 seconds — release expired seat holds (Phase 2)
Schedule::command('bus:release-expired-holds')
    ->everyThirtySeconds()
    ->withoutOverlapping(60)
    ->runInBackground();

// ─── Cricket live-stream watchdog ──────────────────────────
//
// The public HLS playlist only exists while the engine→SRS forwarder is
// running. Activation wires it once, which cannot survive a broadcaster
// reconnect, an engine restart, or a camera activated before its publisher
// connected — in each case the stream row still says `live` while
// /hls/live/{key}.m3u8 returns 404. This re-arms it.
//
// One minute is deliberate: a forwarder takes a few seconds to rebuild and
// the command is idempotent, so a faster tick would only add engine probes
// without making the stream come back any sooner.
Schedule::command('cricket:stream-watchdog')
    ->everyMinute()
    ->withoutOverlapping(120)
    ->runInBackground();
