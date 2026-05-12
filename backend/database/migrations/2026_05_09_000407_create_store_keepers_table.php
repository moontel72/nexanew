<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('store_keepers')) {
            return;
        }

        Schema::create('store_keepers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('company_id')->nullable();
            $table->uuid('factory_id')->nullable();
            $table->string('name', 255);
            $table->string('employee_id', 100)->nullable()->unique();
            $table->string('phone', 50)->nullable();
            $table->string('email', 255)->unique();
            $table->string('password', 255);
            $table->string('status', 50)->default('active');
            $table->string('duty_shift', 100)->nullable();
            $table->string('remember_token', 100)->nullable();
            $table->timestamp('last_login_at')->nullable();
            $table->timestamps();

            $table->index('company_id');
            $table->index('factory_id');
        });

        DB::statement('ALTER TABLE store_keepers ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
    }

    public function down(): void
    {
        Schema::dropIfExists('store_keepers');
    }
};
