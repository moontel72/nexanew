<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Fix Sanctum personal_access_tokens to support UUID tokenable_id.
     *
     * Laravel Sanctum's default migration uses morphs() which creates
     * tokenable_id as BIGINT UNSIGNED. Our models (TenantAccount,
     * GlobalIdentity) use UUIDs (CHAR(36)). This migration converts
     * the column to a UUID-compatible type.
     */
    public function up(): void
    {
        if (!Schema::hasTable('personal_access_tokens')) {
            // Table doesn't exist yet — create it with UUID support
            Schema::create('personal_access_tokens', function (Blueprint $table) {
                $table->id();
                $table->uuidMorphs('tokenable');
                $table->text('name');
                $table->string('token', 64)->unique();
                $table->text('abilities')->nullable();
                $table->timestamp('last_used_at')->nullable();
                $table->timestamp('expires_at')->nullable()->index();
                $table->timestamps();
            });
            return;
        }

        // Table exists with BIGINT — alter to UUID-compatible
        // 1. Drop the old morph index
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            try { $table->dropIndex('personal_access_tokens_tokenable_type_tokenable_id_index'); } catch (\Exception $e) {}
        });

        // 2. Change tokenable_id from BIGINT to CHAR(36)
        DB::statement('ALTER TABLE personal_access_tokens ALTER COLUMN tokenable_id TYPE CHAR(36) USING tokenable_id::TEXT');

        // 3. Recreate the morph index
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->index(['tokenable_type', 'tokenable_id']);
        });

        // 4. Also ensure token is unique (might be lost during alters)
        try {
            Schema::table('personal_access_tokens', function (Blueprint $table) {
                $table->unique('token');
            });
        } catch (\Exception $e) {}
    }

    public function down(): void
    {
        // Cannot revert UUID to BIGINT without data loss — no-op
    }
};
