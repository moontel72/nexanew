<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('resellers', function (Blueprint $table) {
            $table->boolean('purchase_approved')->default(false)->after('suspended_reason');
            $table->string('business_proof_url', 500)->nullable()->after('purchase_approved');
            $table->string('business_proof_title', 255)->nullable()->after('business_proof_url');
            $table->timestamp('business_proof_uploaded_at')->nullable()->after('business_proof_title');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('resellers', function (Blueprint $table) {
            $table->dropColumn([
                'purchase_approved',
                'business_proof_url',
                'business_proof_title',
                'business_proof_uploaded_at',
            ]);
        });
    }
};
