<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('resellers', 'plan_id')) {
            Schema::table('resellers', function (Blueprint $table) {
                $table->dropColumn('plan_id');
            });
        }
    }

    public function down(): void
    {
        Schema::table('resellers', function (Blueprint $table) {
            $table->string('plan_id')->nullable();
        });
    }
};
