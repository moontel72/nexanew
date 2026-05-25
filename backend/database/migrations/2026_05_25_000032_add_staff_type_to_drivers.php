<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            if (!Schema::hasColumn('drivers', 'staff_type')) {
                $table->string('staff_type', 30)->default('driver')->after('driver_type');
                // driver, conductor, owner
            }
            if (!Schema::hasColumn('drivers', 'company_id')) {
                $table->uuid('company_id')->nullable()->after('id');
            }
            if (!Schema::hasColumn('drivers', 'cnic')) {
                $table->string('cnic', 30)->nullable()->after('phone');
            }
            if (!Schema::hasColumn('drivers', 'address')) {
                $table->text('address')->nullable()->after('cnic');
            }
            if (!Schema::hasColumn('drivers', 'hire_date')) {
                $table->date('hire_date')->nullable()->after('address');
            }
            if (!Schema::hasColumn('drivers', 'salary')) {
                $table->decimal('salary', 12, 2)->nullable()->after('hire_date');
            }
        });
    }

    public function down(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            $table->dropColumn(['staff_type', 'cnic', 'address', 'hire_date', 'salary']);
        });
    }
};
