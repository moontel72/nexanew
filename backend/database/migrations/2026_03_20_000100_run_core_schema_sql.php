<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
public function up(): void
{
    // database_path('sql/...') direct database folder ke andar jata hai
    $path = database_path('sql/001_initial_schema.sql');
    
    if (!file_exists($path)) {
        throw new RuntimeException("SQL file not found at: " . $path);
    }

    $sql = file_get_contents($path);
    DB::unprepared($sql);
}

    public function down(): void
    {
    }
};

