<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 2 — Advanced Dispatch: Multi-Staff, Handover, Return Trip, Multi-Leg
     * =========================================================================
     *
     * Extends fleet_dispatch_assignments with:
     *   - relief_driver_id       (handover / relief driver)
     *   - conductor_ids          (JSONB array — multiple conductors)
     *   - handover_stop_id       (FK → waypoints — staff swap location)
     *   - leg_type               (outbound | inbound — return trip separation)
     *   - parent_assignment_id   (self-referencing — return trip pairing / cross-vehicle chaining)
     *   - departure_time         (for timeline ordering on staff apps)
     *   - route_leg_start_stop_id / route_leg_end_stop_id (multi-leg support)
     */
    public function up(): void
    {
        if (!Schema::hasTable('fleet_dispatch_assignments')) {
            return;
        }

        Schema::table('fleet_dispatch_assignments', function (Blueprint $table) {
            // Multi-staff support
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'relief_driver_id')) {
                $table->uuid('relief_driver_id')->nullable()->after('driver_id');
            }
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'conductor_ids')) {
                $table->jsonb('conductor_ids')->nullable()->after('conductor_id');
            }

            // Handover stop
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'handover_stop_id')) {
                $table->uuid('handover_stop_id')->nullable()->after('conductor_ids');
            }

            // Leg type for return trip separation
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'leg_type')) {
                $table->string('leg_type', 20)->default('outbound')->after('shift_type');
            }

            // Parent assignment for chaining
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'parent_assignment_id')) {
                $table->uuid('parent_assignment_id')->nullable()->after('leg_type');
            }

            // Timeline ordering
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'departure_time')) {
                $table->time('departure_time')->nullable()->after('assignment_date');
            }

            // Multi-leg start/end stops
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'route_leg_start_stop_id')) {
                $table->uuid('route_leg_start_stop_id')->nullable()->after('route_id');
            }
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'route_leg_end_stop_id')) {
                $table->uuid('route_leg_end_stop_id')->nullable()->after('route_leg_start_stop_id');
            }

            // Handover stop FK (optional — waypoints table may not exist yet)
            if (Schema::hasTable('transport_bus_route_waypoints') &&
                !$this->hasFK('fleet_dispatch_assignments', 'fleet_dispatch_assignments_handover_stop_id_foreign')) {
                $table->foreign('handover_stop_id')
                    ->references('id')->on('transport_bus_route_waypoints')
                    ->onDelete('set null');
            }
        });
    }

    public function down(): void
    {
        Schema::table('fleet_dispatch_assignments', function (Blueprint $table) {
            $columns = [
                'relief_driver_id', 'conductor_ids', 'handover_stop_id',
                'leg_type', 'parent_assignment_id', 'departure_time',
                'route_leg_start_stop_id', 'route_leg_end_stop_id',
            ];
            foreach ($columns as $col) {
                if (Schema::hasColumn('fleet_dispatch_assignments', $col)) {
                    $table->dropColumn($col);
                }
            }
        });
    }

    private function hasFK(string $table, string $fkName): bool
    {
        $rows = DB::select("SELECT 1 FROM information_schema.table_constraints
            WHERE table_name = ? AND constraint_name = ? AND constraint_type = 'FOREIGN KEY'", [$table, $fkName]);
        return !empty($rows);
    }
};
