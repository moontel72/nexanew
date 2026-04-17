<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $path = base_path('database/sql/admin_schema.sql');
        $sql = file_get_contents($path);

        if ($sql === false) {
            throw new RuntimeException('Failed to read admin schema SQL');
        }

        DB::unprepared($sql);
    }

    public function down(): void
    {
    }
};

