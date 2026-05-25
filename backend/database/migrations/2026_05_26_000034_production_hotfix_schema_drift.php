<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

/**
 * Standalone drivers schema fix.
 * Adds columns that may have been skipped due to previous migration failures.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('drivers')) return;

        Schema::table('drivers', function (Blueprint $table) {
            // Make email nullable first (NOT NULL breaks inserts)
            if (Schema::hasColumn('drivers', 'email')) {
                DB::statement('ALTER TABLE drivers ALTER COLUMN email DROP NOT NULL');
            }

            if (!Schema::hasColumn('drivers', 'driver_type')) {
                $table->string('driver_type', 20)->default('factory');
            }

            if (!Schema::hasColumn('drivers', 'staff_type')) {
                $table->string('staff_type', 30)->default('driver');
            }

            if (!Schema::hasColumn('drivers', 'is_active')) {
                $table->boolean('is_active')->default(true);
            }

            if (!Schema::hasColumn('drivers', 'cnic')) {
                $table->string('cnic', 30)->nullable();
            }

            if (!Schema::hasColumn('drivers', 'address')) {
                $table->text('address')->nullable();
            }

            if (!Schema::hasColumn('drivers', 'hire_date')) {
                $table->date('hire_date')->nullable();
            }

            if (!Schema::hasColumn('drivers', 'salary')) {
                $table->decimal('salary', 12, 2)->nullable();
            }
        });
    }

    public function down(): void {}
};
