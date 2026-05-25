<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * A–E Hierarchy Support:
     *   A = Owner (staff_type='owner')
     *   B = Company Driver (staff_type='driver', owner_id=null)
     *   C = Company Conductor (staff_type='conductor', owner_id=null)
     *   D = Owner's Driver (staff_type='driver', owner_id=<owner_uuid>)
     *   E = Owner's Conductor (staff_type='conductor', owner_id=<owner_uuid>)
     */
    public function up(): void
    {
        if (!Schema::hasColumn('drivers', 'owner_id')) {
            Schema::table('drivers', function (Blueprint $table) {
                $table->uuid('owner_id')->nullable()->after('company_id');
                $table->index('owner_id');
            });
        }

        // Self-referencing FK must be added in a separate Schema::table call
        // to avoid PostgreSQL single-pass transaction evaluation issues
        if (Schema::hasColumn('drivers', 'owner_id')) {
            $fkExists = \Illuminate\Support\Facades\DB::select(
                "SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = ? AND table_name = ?",
                ['drivers_owner_id_foreign', 'drivers']
            );
            if (empty($fkExists)) {
                Schema::table('drivers', function (Blueprint $table) {
                    $table->foreign('owner_id')
                          ->references('id')
                          ->on('drivers')
                          ->nullOnDelete();
                });
            }
        }
    }

    public function down(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            if (Schema::hasColumn('drivers', 'owner_id')) {
                $table->dropForeign(['owner_id']);
                $table->dropIndex(['owner_id']);
                $table->dropColumn('owner_id');
            }
        });
    }
};
