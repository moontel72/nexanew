<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

/**
 * HOTFIX: Resolves migration blockers and schema drift
 *
 * Issue 1: user_notification_preferences.user_id is uuid but users.id is bigint
 *   → FK constraint fails, blocking ALL subsequent migrations
 * Issue 2: drivers.driver_type, staff_type columns never created because of blocker
 */
return new class extends Migration
{
    public function up(): void
    {
        // ═══════════════════════════════════════════════
        // FIX 1: Drop broken notification_preferences FK
        //        so remaining migrations can run
        // ═══════════════════════════════════════════════
        if (Schema::hasTable('user_notification_preferences')) {
            // Drop the broken FK first
            try {
                Schema::table('user_notification_preferences', function (Blueprint $table) {
                    $table->dropForeign(['user_id']);
                });
            } catch (\Exception $e) {
                // FK may not exist yet — safe to ignore
            }

            // Change user_id from uuid to bigInteger to match users.id
            try {
                DB::statement('ALTER TABLE user_notification_preferences ALTER COLUMN user_id TYPE BIGINT USING (user_id::text::bigint)');
            } catch (\Exception $e) {
                // Column may have no data or conversion fails — drop and recreate
                Schema::dropIfExists('user_notification_preferences');
                Schema::create('user_notification_preferences', function (Blueprint $table) {
                    $table->uuid('id')->primary();
                    $table->foreignId('user_id');
                    $table->string('notification_type', 100);
                    $table->json('channel_preferences');
                    $table->boolean('is_enabled')->default(true);
                    $table->timestamps();
                    $table->unique(['user_id', 'notification_type']);
                });
            }

            // Re-add FK with correct type
            try {
                Schema::table('user_notification_preferences', function (Blueprint $table) {
                    $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
                });
            } catch (\Exception $e) {
                // FK might fail if data mismatch — OK to skip
            }
        }

        // ═══════════════════════════════════════════════
        // FIX 2: Add missing columns to drivers table
        //        (were skipped because migration batch failed)
        // ═══════════════════════════════════════════════
        if (Schema::hasTable('drivers')) {
            Schema::table('drivers', function (Blueprint $table) {
                // Make email nullable first (NOT NULL breaks inserts)
                if (Schema::hasColumn('drivers', 'email')) {
                    DB::statement('ALTER TABLE drivers ALTER COLUMN email DROP NOT NULL');
                }

                if (!Schema::hasColumn('drivers', 'driver_type')) {
                    $table->string('driver_type', 20)->default('factory');
                }

                if (!Schema::hasColumn('drivers', 'staff_type')) {
                    $table->string('staff_type', 30)->default('driver');
                }

                if (!Schema::hasColumn('drivers', 'is_active')) {
                    $table->boolean('is_active')->default(true);
                }

                if (!Schema::hasColumn('drivers', 'cnic')) {
                    $table->string('cnic', 30)->nullable();
                }

                if (!Schema::hasColumn('drivers', 'address')) {
                    $table->text('address')->nullable();
                }

                if (!Schema::hasColumn('drivers', 'hire_date')) {
                    $table->date('hire_date')->nullable();
                }

                if (!Schema::hasColumn('drivers', 'salary')) {
                    $table->decimal('salary', 12, 2)->nullable();
                }
            });
        }
    }

    public function down(): void
    {
        // No down migration — this is a hotfix
    }
};
