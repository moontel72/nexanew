<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('resellers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('business_name');
            $table->string('registration_no')->comment('Govt business registration number');
            $table->string('email')->unique();
            $table->string('phone')->unique();
            $table->string('city');
            $table->text('address')->nullable();
            $table->string('status')->default('active')->comment('active, inactive, suspended');
            $table->string('plan_id')->nullable();
            $table->string('plan_name')->nullable();
            $table->timestamp('suspended_at')->nullable();
            $table->string('suspended_reason')->nullable();
            $table->softDeletes();
            $table->timestamps();

            $table->index('status');
            $table->index('city');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('resellers');
    }
};
