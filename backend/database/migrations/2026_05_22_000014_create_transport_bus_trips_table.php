<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transport_bus_trips', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('route_id')->nullable();
            $table->uuid('bus_id');
            $table->uuid('driver_id')->nullable();
            $table->string('origin', 150);
            $table->string('destination', 150);
            $table->json('waypoints')->nullable();
            // waypoints: [{"station":"Rawalpindi","lat":33.6,"lng":73.0,"order":1,"eta":null}, ...]
            $table->string('status', 20)->default('scheduled');
            // scheduled → active → completed | cancelled
            $table->decimal('current_lat', 10, 7)->nullable();
            $table->decimal('current_lng', 10, 7)->nullable();
            $table->decimal('current_speed', 6, 2)->nullable(); // km/h
            $table->json('estimated_arrival_json')->nullable();
            // [{"station":"Gujar Khan","eta_seconds":420,"distance_km":15.2}, ...]
            $table->unsignedInteger('current_waypoint_index')->default(0);
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['status', 'bus_id']);
            $table->foreign('bus_id')->references('bus_id')->on('transport_bus_layouts')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transport_bus_trips');
    }
};
