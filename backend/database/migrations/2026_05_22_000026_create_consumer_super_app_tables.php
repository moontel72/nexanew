<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transit_bookings', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->uuid('bus_id');
            $table->unsignedInteger('seat_number');
            $table->string('booking_status', 20)->default('pending'); // pending, confirmed, canceled
            $table->decimal('ticket_price', 10, 2)->nullable();
            $table->uuid('trip_id')->nullable();
            $table->timestamps();

            $table->unique(['trip_id', 'seat_number']);
            $table->index(['user_id', 'booking_status']);
        });

        Schema::create('fleet_auctions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('requester_id');
            $table->string('vehicle_type', 20); // truck, special_bus
            $table->string('origin', 150)->nullable();
            $table->string('destination', 150)->nullable();
            $table->decimal('bid_amount', 15, 2)->nullable();
            $table->unsignedInteger('failed_count_this_month')->default(0);
            $table->string('status', 20)->default('open'); // open, matched, canceled, expired
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['requester_id', 'status']);
        });

        Schema::create('secure_chat_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('sender_id');
            $table->uuid('receiver_id');
            $table->text('message_body');
            $table->boolean('is_blocked')->default(false);
            $table->string('blocked_reason', 100)->nullable();
            $table->text('masked_payload')->nullable();
            $table->timestamps();

            $table->index(['sender_id', 'receiver_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('secure_chat_logs');
        Schema::dropIfExists('fleet_auctions');
        Schema::dropIfExists('transit_bookings');
    }
};
