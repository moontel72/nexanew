<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ── 1. Passenger Safety Tokens ──────────────────────────
        if (!Schema::hasTable('passenger_safety_tokens')) {
            Schema::create('passenger_safety_tokens', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('bus_number_plate', 32);
                $table->string('share_token', 128)->unique();
                $table->uuid('trip_id')->nullable();
                $table->uuid('passenger_id')->nullable();
                $table->decimal('current_lat', 10, 7)->nullable();
                $table->decimal('current_lng', 10, 7)->nullable();
                $table->timestamp('expires_at');
                $table->jsonb('metadata')->default('{}');
                $table->timestamps();
                $table->index('share_token');
                $table->index('bus_number_plate');
            });
        }

        // ── 2. Billing snapshot: active_bus_count on tenant_accounts ──
        Schema::table('tenant_accounts', function (Blueprint $table) {
            if (!Schema::hasColumn('tenant_accounts', 'active_bus_count')) {
                $table->integer('active_bus_count')->default(0)->after('status');
            }
            if (!Schema::hasColumn('tenant_accounts', 'subscription_rate_pkr')) {
                $table->decimal('subscription_rate_pkr', 10, 2)->default(5000)->after('active_bus_count');
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('passenger_safety_tokens');
        Schema::table('tenant_accounts', function (Blueprint $table) {
            $table->dropColumn(['active_bus_count', 'subscription_rate_pkr']);
        });
    }
};
