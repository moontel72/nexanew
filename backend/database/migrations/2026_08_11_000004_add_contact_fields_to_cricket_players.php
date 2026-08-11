<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cricket_players', function (Blueprint $table) {
            if (!Schema::hasColumn('cricket_players', 'email')) {
                $table->string('email', 200)->nullable()->after('name');
            }
            if (!Schema::hasColumn('cricket_players', 'phone')) {
                $table->string('phone', 30)->nullable()->after('email');
            }
            if (!Schema::hasColumn('cricket_players', 'id_card_number')) {
                $table->string('id_card_number', 50)->nullable()->after('phone');
            }
            if (!Schema::hasColumn('cricket_players', 'date_of_birth')) {
                $table->date('date_of_birth')->nullable()->after('id_card_number');
            }
        });
    }

    public function down(): void
    {
        Schema::table('cricket_players', function (Blueprint $table) {
            $table->dropColumn(['email', 'phone', 'id_card_number', 'date_of_birth']);
        });
    }
};
