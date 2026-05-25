<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

/**
 * Consolidated fix for drivers table:
 * - Make email nullable (NOT NULL was breaking driver/conductor inserts)
 * - Add staff_type, cnic, address, hire_date, salary columns
 * - Add is_active column if missing
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            // 1. Make email nullable (was NOT NULL UNIQUE, breaks driver/conductor)
            if (Schema::hasColumn('drivers', 'email')) {
                DB::statement("ALTER TABLE drivers ALTER COLUMN email DROP NOT NULL");
            }

            // 2. Add staff_type column (driver, conductor, owner)
            if (!Schema::hasColumn('drivers', 'staff_type')) {
                $table->string('staff_type', 30)->default('driver')->after('driver_type');
            }

            // 3. Add cnic column
            if (!Schema::hasColumn('drivers', 'cnic')) {
                $table->string('cnic', 30)->nullable()->after('phone');
            }

            // 4. Add address column
            if (!Schema::hasColumn('drivers', 'address')) {
                $table->text('address')->nullable()->after('cnic');
            }

            // 5. Add hire_date column
            if (!Schema::hasColumn('drivers', 'hire_date')) {
                $table->date('hire_date')->nullable()->after('address');
            }

            // 6. Add salary column
            if (!Schema::hasColumn('drivers', 'salary')) {
                $table->decimal('salary', 12, 2)->nullable()->after('hire_date');
            }

            // 7. Ensure is_active exists
            if (!Schema::hasColumn('drivers', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('status');
            }

            // 8. Ensure driver_type exists
            if (!Schema::hasColumn('drivers', 'driver_type')) {
                $table->string('driver_type', 20)->default('factory')->after('status');
            }
        });
    }

    public function down(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            // Don't drop critical columns in rollback — just the ones we added
            $columns = ['staff_type', 'cnic', 'address', 'hire_date', 'salary'];
            foreach ($columns as $col) {
                if (Schema::hasColumn('drivers', $col)) {
                    $table->dropColumn($col);
                }
            }
        });
    }
};
