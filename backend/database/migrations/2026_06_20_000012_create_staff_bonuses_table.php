<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('staff_bonuses')) return;

        Schema::create('staff_bonuses', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('bus_company_id');
            $table->string('bonus_name');
            $table->enum('staff_type', ['driver', 'conductor', 'office_staff']);
            $table->enum('bonus_category', ['mountain_terrain', 'festive', 'overtime', 'target', 'special_trip']);
            $table->enum('amount_type', ['percentage', 'fixed']);
            $table->decimal('amount_value', 10, 2);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->index('bus_company_id');
            $table->index('staff_type');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('staff_bonuses');
    }
};
