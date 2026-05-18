<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('drivers')) {
            return;
        }

        Schema::create('drivers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('company_id')->nullable();
            $table->uuid('factory_id')->nullable();
            $table->string('name', 255);
            $table->string('phone', 50)->nullable();
            $table->string('email', 255)->unique();
            $table->string('password', 255);
            $table->string('license_number', 100)->nullable();
            $table->timestamp('license_expiry')->nullable();
            $table->string('vehicle_plate_number', 50)->nullable();
            $table->string('vehicle_type', 50)->nullable();
            $table->string('insurance_number', 100)->nullable();
            $table->timestamp('insurance_expiry')->nullable();
            $table->timestamp('registration_expiry')->nullable();
            $table->string('status', 50)->default('active');
            $table->string('tier', 20)->default('bronze');
            $table->decimal('rating', 3, 2)->default(0.00);
            $table->integer('total_trips')->default(0);
            $table->integer('completed_trips')->default(0);
            $table->integer('on_time_deliveries')->default(0);
            $table->integer('late_deliveries')->default(0);
            $table->decimal('driving_hours_today', 4, 1)->default(0.0);
            $table->decimal('driving_hours_week', 5, 1)->default(0.0);
            $table->boolean('is_fatigued')->default(false);
            $table->timestamp('last_login_at')->nullable();
            $table->string('remember_token', 100)->nullable();
            $table->timestamps();

            $table->index('company_id');
            $table->index('factory_id');
        });

        DB::statement('ALTER TABLE drivers ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
    }

    public function down(): void
    {
        Schema::dropIfExists('drivers');
    }
};
