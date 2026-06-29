<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ── Catering Categories (e.g. Beverages, Snacks, Meals, Toiletries) ──
        if (!Schema::hasTable('catering_categories')) {
            Schema::create('catering_categories', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('company_id');
                $table->string('name', 150);
                $table->string('icon', 100)->nullable();
                $table->unsignedSmallInteger('sort_order')->default(0);
                $table->timestamps();

                $table->index('company_id');
                $table->unique(['company_id', 'name']);
            });

            DB::statement('ALTER TABLE catering_categories ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
        }

        // ── Catering Items (stockable products issued to buses) ──
        if (!Schema::hasTable('catering_items')) {
            Schema::create('catering_items', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('company_id');
                $table->uuid('category_id')->nullable();
                $table->string('name', 200);
                $table->string('sku', 80)->nullable();
                $table->string('unit', 50)->default('piece'); // piece, box, bottle, kg, L
                $table->unsignedInteger('stock_on_hand')->default(0);
                $table->unsignedInteger('low_stock_threshold')->default(10);
                $table->unsignedInteger('unit_price_paisa')->default(0); // stored in paisa/cent
                $table->string('image_url')->nullable();
                $table->string('status', 30)->default('active'); // active | discontinued
                $table->timestamps();

                $table->index('company_id');
                $table->index('category_id');
                $table->unique(['company_id', 'sku']);
            });

            DB::statement('ALTER TABLE catering_items ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
        }

        // ── Catering Issuances (one issuance = one bus/trip) ──
        if (!Schema::hasTable('catering_issuances')) {
            Schema::create('catering_issuances', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('company_id');
                $table->uuid('storekeeper_id');
                $table->uuid('trip_id')->nullable();
                $table->uuid('route_id')->nullable();
                $table->string('bus_reg_number', 50)->nullable();
                $table->string('conductor_name', 200)->nullable();
                $table->string('status', 30)->default('pending'); // pending | issued | partially_returned | reconciled
                $table->text('notes')->nullable();
                $table->timestamp('issued_at')->nullable();
                $table->timestamp('reconciled_at')->nullable();
                $table->timestamps();

                $table->index('company_id');
                $table->index('storekeeper_id');
                $table->index('trip_id');
                $table->index('status');
            });

            DB::statement('ALTER TABLE catering_issuances ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
        }

        // ── Issuance Line Items ──
        if (!Schema::hasTable('catering_issuance_items')) {
            Schema::create('catering_issuance_items', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('issuance_id');
                $table->uuid('item_id');
                $table->unsignedInteger('quantity_issued')->default(0);
                $table->unsignedInteger('quantity_returned')->default(0);
                $table->unsignedInteger('quantity_sold')->default(0);
                $table->unsignedInteger('unit_price_paisa')->default(0);
                $table->timestamps();

                $table->index('issuance_id');
                $table->index('item_id');
            });

            DB::statement('ALTER TABLE catering_issuance_items ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
        }

        // ── Reconciliation Records (end-of-trip count) ──
        if (!Schema::hasTable('catering_reconciliations')) {
            Schema::create('catering_reconciliations', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('company_id');
                $table->uuid('issuance_id')->unique();
                $table->uuid('storekeeper_id');
                $table->unsignedInteger('total_issued_value_paisa')->default(0);
                $table->unsignedInteger('total_returned_value_paisa')->default(0);
                $table->unsignedInteger('total_sold_value_paisa')->default(0);
                $table->unsignedInteger('variance_paisa')->default(0); // sold + returned - issued
                $table->string('status', 30)->default('draft'); // draft | confirmed | disputed
                $table->text('notes')->nullable();
                $table->timestamp('reconciled_at')->nullable();
                $table->timestamps();

                $table->index('company_id');
                $table->index('storekeeper_id');
            });

            DB::statement('ALTER TABLE catering_reconciliations ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('catering_reconciliations');
        Schema::dropIfExists('catering_issuance_items');
        Schema::dropIfExists('catering_issuances');
        Schema::dropIfExists('catering_items');
        Schema::dropIfExists('catering_categories');
    }
};
