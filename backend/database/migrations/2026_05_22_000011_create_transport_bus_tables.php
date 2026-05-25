<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Bus seat floor-plan layouts
        Schema::create('transport_bus_layouts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('bus_id');
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedTinyInteger('total_rows')->default(10);
            $table->unsignedTinyInteger('left_columns')->default(2);  // 2 or 3 seats
            $table->unsignedTinyInteger('right_columns')->default(2); // 2 or 1 seats
            $table->unsignedTinyInteger('driver_seats')->default(1);  // 1 or 2
            $table->json('raw_grid_json'); // full serialized grid
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique('bus_id');
        });

        // 2. Bus door QR code registry
        Schema::create('transport_bus_qr_codes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('bus_id');
            $table->string('qr_payload_uuid', 100)->unique();
            $table->uuid('active_trip_id')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->foreign('bus_id')->references('id')->on('transport_bus_layouts')->cascadeOnDelete();
        });

        // 3. NexaTrace cash vouchers (physical, bought from local shops)
        Schema::create('transport_nexatrace_vouchers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('voucher_code_hash', 64)->unique(); // SHA-256 hash of plaintext code
            $table->decimal('amount', 15, 2);
            $table->string('currency', 10)->default('PKR');
            $table->string('status', 20)->default('unused'); // unused, redeemed, expired, revoked
            $table->uuid('created_by_shop_id')->nullable();
            $table->uuid('redeemed_by_user_id')->nullable();
            $table->timestamp('redeemed_at')->nullable();
            $table->uuid('redemption_transaction_id')->nullable(); // FK to financial_wallet_transactions
            $table->timestamp('expires_at')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['status', 'expires_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transport_nexatrace_vouchers');
        Schema::dropIfExists('transport_bus_qr_codes');
        Schema::dropIfExists('transport_bus_layouts');
    }
};
