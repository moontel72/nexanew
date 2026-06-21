<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — VOUCHER REDEMPTIONS
 * ================================
 *
 * Tracks every voucher redemption event.
 * Links a passenger + booking + voucher together.
 *
 * TABLE: voucher_redemptions
 */

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('voucher_redemptions')) {
            return;
        }

        Schema::create('voucher_redemptions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('voucher_id');              // FK → bus_vouchers.id
            $table->uuid('passenger_id');             // FK → users.id
            $table->uuid('booking_id')->nullable();   // FK → transport_seat_bookings.id
            $table->decimal('discount_amount', 10, 2);
            $table->decimal('original_price', 10, 2);
            $table->decimal('final_price', 10, 2);
            $table->timestamps();

            $table->index('voucher_id');
            $table->index('passenger_id');
            $table->index('booking_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('voucher_redemptions');
    }
};
