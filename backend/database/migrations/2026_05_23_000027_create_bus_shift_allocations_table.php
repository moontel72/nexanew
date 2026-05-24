<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ── 1. Add staff_type to drivers table for driver/conductor split ──
        Schema::table('drivers', function (Blueprint $table) {
            if (! Schema::hasColumn('drivers', 'staff_type')) {
                $table->string('staff_type', 20)->default('driver')->after('driver_type');
                // 'driver' | 'conductor'
            }
            if (! Schema::hasColumn('drivers', 'salary')) {
                $table->decimal('salary', 12, 2)->default(0)->after('staff_type');
            }
            if (! Schema::hasColumn('drivers', 'commission_rate')) {
                $table->decimal('commission_rate', 5, 2)->default(0)->after('salary');
            }
        });

        // ── 2. Create bus_shift_allocations table ──────────────────────────
        if (! Schema::hasTable('bus_shift_allocations')) {
            Schema::create('bus_shift_allocations', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('bus_number_plate', 32);
                $table->string('shift_type', 16); // morning | evening | night
                $table->jsonb('driver_ids')->default('[]');
                $table->jsonb('conductor_ids')->default('[]');
                $table->uuid('company_id')->nullable();
                $table->timestamps();

                $table->unique(['bus_number_plate', 'shift_type']);
                $table->index('company_id');
            });
        }
    }

    public function down(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            $table->dropColumn(['staff_type', 'salary', 'commission_rate']);
        });
        Schema::dropIfExists('bus_shift_allocations');
    }
};
