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
