<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Fix team registration failures caused by NOT NULL columns
     * that the frontend and validation treat as optional.
     */
    public function up(): void
    {
        Schema::table('cricket_teams', function (Blueprint $table) {
            // tournament_id: frontend does not send this during team creation;
            // teams can be assigned to a tournament later.
            $table->uuid('tournament_id')->nullable()->change();

            // short_code: auto-generated or user-provided, but not required at creation.
            $table->string('short_code', 10)->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('cricket_teams', function (Blueprint $table) {
            $table->uuid('tournament_id')->nullable(false)->change();
            $table->string('short_code', 10)->nullable(false)->change();
        });
    }
};
