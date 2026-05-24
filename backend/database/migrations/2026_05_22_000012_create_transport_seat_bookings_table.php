<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transport_seat_bookings', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('bus_layout_id');
            $table->uuid('trip_id');
            $table->uuid('user_id');
            $table->unsignedInteger('seat_number');
            $table->string('payment_method', 20); // wallet, card, voucher
            $table->decimal('ticket_price', 10, 2);
            $table->string('status', 20)->default('booked'); // booked, cancelled, completed
            $table->timestamp('booked_at')->nullable();
            $table->timestamps();

            $table->unique(['trip_id', 'seat_number']);
            $table->index(['bus_layout_id', 'trip_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transport_seat_bookings');
    }
};
