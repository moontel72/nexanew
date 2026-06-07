<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Make legacy owner_id nullable — superseded by owner_identity_id
     * (Wave 4 identity spine). Also drop the old FK to users table.
     */
    public function up(): void
    {
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            // Drop the old foreign key — find its actual name first
            $fkName = $this->findForeignKeyName('transport_bus_layouts', 'owner_id');
            if ($fkName) {
                Schema::table('transport_bus_layouts', function (Blueprint $table) use ($fkName) {
                    $table->dropForeign($fkName);
                });
            }

            // Make owner_id nullable (now superseded by owner_identity_id)
            $table->unsignedBigInteger('owner_id')->nullable()->change();
        });
    }

    private function findForeignKeyName(string $table, string $column): ?string
    {
        $result = \Illuminate\Support\Facades\DB::select(
            "SELECT conname FROM pg_constraint
             WHERE conrelid = ?::regclass
             AND contype = 'f'
             AND conkey @> ARRAY[(SELECT attnum FROM pg_attribute
               WHERE attrelid = ?::regclass AND attname = ?)]",
            [$table, $table, $column]
        );
        return $result[0]->conname ?? null;
    }

    public function down(): void
    {
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            $table->unsignedBigInteger('owner_id')->nullable(false)->change();
        });
    }
};
