<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('tenant_accounts')) return;

        Schema::create('tenant_accounts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('parent_account_id')->nullable();
            $table->foreign('parent_account_id')->references('id')->on('tenant_accounts')->nullOnDelete();
            $table->string('account_name', 255);
            $table->string('email', 255)->unique();
            $table->string('password', 255);
            $table->string('phone_number', 50)->nullable();
            $table->boolean('is_independent')->default(true);
            $table->string('account_type', 30)->default('bus_owner'); // bus_company | bus_owner
            $table->string('status', 20)->default('active');
            $table->jsonb('metadata')->default('{}');
            $table->timestamps();

            $table->index('parent_account_id');
            $table->index('account_type');
        });

        // Link bus_shift_allocations to tenant_accounts
        Schema::table('bus_shift_allocations', function (Blueprint $table) {
            if (!Schema::hasColumn('bus_shift_allocations', 'tenant_account_id')) {
                $table->uuid('tenant_account_id')->nullable()->after('company_id');
                $table->foreign('tenant_account_id')->references('id')->on('tenant_accounts')->nullOnDelete();
            }
        });

        // Link bus_layouts to tenant_accounts
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            if (!Schema::hasColumn('transport_bus_layouts', 'tenant_account_id')) {
                $table->uuid('tenant_account_id')->nullable()->after('owner_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('bus_shift_allocations', function (Blueprint $table) {
            $table->dropForeign(['tenant_account_id']);
            $table->dropColumn('tenant_account_id');
        });
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            $table->dropColumn('tenant_account_id');
        });
        Schema::dropIfExists('tenant_accounts');
    }
};
