<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Live Dispatch & Duty Assignment Engine
     * =======================================
     *
     * Centralized table linking vehicles, routes, drivers, and conductors
     * on a daily/shift basis. Resources are fluid — a vehicle can run
     * Route A today and Route B tomorrow.
     *
     * Conflict Prevention:
     *   One vehicle/driver/conductor cannot hold two active assignments
     *   on the same date + shift simultaneously.
     *   (enforced at application layer in FleetDispatchController)
     *
     * Table: fleet_dispatch_assignments
     */
    public function up(): void
    {
        if (Schema::hasTable('fleet_dispatch_assignments')) {
            return;
        }

        Schema::create('fleet_dispatch_assignments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('bus_company_id')->nullable()->index();
            $table->uuid('vehicle_id');          // FK → absolute_bus_layouts.id
            $table->uuid('route_id');            // FK → transport_bus_routes.id
            $table->uuid('driver_id');           // FK → fleet_assignments.id (role=driver)
            $table->uuid('conductor_id')->nullable(); // FK → fleet_assignments.id (role=conductor)
            $table->date('assignment_date');
            $table->string('shift_type', 20)->default('morning'); // morning|evening|night|special
            $table->string('status', 20)->default('active');     // active|completed|cancelled
            $table->jsonb('meta')->nullable();
            $table->timestamps();

            $table->foreign('vehicle_id')
                ->references('id')->on('absolute_bus_layouts')
                ->onDelete('restrict');

            $table->foreign('route_id')
                ->references('id')->on('transport_bus_routes')
                ->onDelete('restrict');
        });

        DB::statement("ALTER TABLE fleet_dispatch_assignments ALTER COLUMN id SET DEFAULT gen_random_uuid()");
    }

    public function down(): void
    {
        Schema::dropIfExists('fleet_dispatch_assignments');
    }
};
