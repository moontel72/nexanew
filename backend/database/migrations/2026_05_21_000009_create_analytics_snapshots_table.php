<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('analytics_snapshots', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('snapshot_type', 30); // hourly, daily, weekly, monthly, realtime
            $table->string('metric_group', 50); // marketplace, freight, financial, system, factory
            $table->string('metric_key', 100); // total_gmv, active_pools, completed_trips, platform_revenue, system_health
            $table->decimal('metric_value', 20, 4);
            $table->string('unit', 20)->nullable(); // usd, count, percentage, score
            $table->json('dimensions')->nullable(); // {"factory_id": "...", "plan_tier": "premium"}
            $table->timestamp('snapshot_at'); // The time window this snapshot represents
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['snapshot_type', 'metric_group', 'snapshot_at']);
            $table->index(['metric_key', 'snapshot_at']);
            $table->unique(['snapshot_type', 'metric_group', 'metric_key', 'snapshot_at'], 'idx_snapshot_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('analytics_snapshots');
    }
};
