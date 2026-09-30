<?php

namespace Tests\Feature;

use App\Services\Analytics\AnalyticsService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

/**
 * MASTER-TASK-LIST.md item 11 — the analytics dashboard answered 500.
 *
 * `AnalyticsService::computeHealthScore()` used
 * `DB::getPdo()->getAttribute(\PDO::ATTR_CONNECTION_STATUS)`. pdo_pgsql does not
 * implement that attribute, so it threw — and because the health score runs on
 * every realtime-dashboard request, `GET /api/v1/admin/analytics/dashboard`
 * returned 500 for everyone. Nothing covered this path, which is why it shipped.
 *
 * `collectGroup('system')` is the public method that reaches that line, so these
 * tests call it directly (the same approach the other feature tests use). The
 * production migrations are Postgres-specific, so the tables this path touches
 * are created here in a sqlite-compatible shape.
 */
class AnalyticsHealthScoreTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();

        $this->createTables();
    }

    public function test_the_system_metric_group_computes_without_throwing(): void
    {
        $metrics = app(AnalyticsService::class)->collectGroup('system');

        $this->assertSame(
            ['active_users_today', 'active_factories', 'codes_generated_today', 'health_score'],
            array_keys($metrics)
        );
    }

    public function test_the_health_score_is_sane_and_rewards_a_working_database(): void
    {
        // An active factory and a code generated just now: three of the five
        // components must fire (active companies, recent codes, a reachable
        // database). The database component is the one that used to throw.
        $this->makeCompany();
        $this->makeCode(now());

        $score = (float) $this->systemMetrics()['health_score'];

        $this->assertGreaterThanOrEqual(60.0, $score);
        $this->assertLessThanOrEqual(100.0, $score);
    }

    public function test_the_health_score_does_not_reward_an_empty_database(): void
    {
        $score = (float) $this->systemMetrics()['health_score'];

        // No companies and no codes: only the reachable-database component can
        // score, so the total must be well below the populated case.
        $this->assertLessThanOrEqual(60.0, $score);
    }

    /**
     * @return array<string, mixed>
     */
    private function systemMetrics(): array
    {
        return app(AnalyticsService::class)->collectGroup('system');
    }

    private function makeCompany(): void
    {
        DB::table('companies')->insert([
            'id' => '11111111-1111-1111-1111-111111111111',
            'name' => 'Moon Medi',
            'status' => 'active',
        ]);
    }

    private function makeCode(\DateTimeInterface $generatedAt): void
    {
        DB::table('base_codes')->insert([
            'id' => '22222222-2222-2222-2222-222222222222',
            'generated_at' => $generatedAt,
        ]);
    }

    /**
     * The tables this read path touches, in a sqlite-compatible shape.
     */
    private function createTables(): void
    {
        if (! Schema::hasTable('companies')) {
            Schema::create('companies', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name');
                $table->string('status')->default('active');
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('base_codes')) {
            Schema::create('base_codes', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->timestamp('generated_at')->nullable();
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('users')) {
            Schema::create('users', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->timestamp('last_login_at')->nullable();
                $table->timestamps();
            });
        }
    }
}
