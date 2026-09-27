<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — Restore the factory `drivers` table
 * ==============================================
 *
 * WHY THIS EXISTS
 * ---------------
 * `2026_06_03_000700_drop_legacy_drivers_table.php` dropped `drivers` as part of the Wave-1 "greenfield
 * cutover", on the assumption that the identity spine (global_identities + identity_claims +
 * fleet_assignments) replaces it. The bus/truck side did move to the spine - but `App\Http\Controllers\
 * Factory\DriverController` never did: it still reads and writes `drivers`.
 *
 * The consequence stayed invisible until the Factory panel's sidebar was repaired (commit deb1d661):
 * before that, the Drivers button was dead, so nobody ever reached the endpoint. Now it 500s with
 * `SQLSTATE[42P01] relation "drivers" does not exist` on both `GET /api/v1/factory/drivers/list` and
 * `POST /api/v1/factory/drivers/create`.
 *
 * WHY RESTORE RATHER THAN REWRITE
 * ------------------------------
 * The owner's standing rule for this phase is: bring back what was tested, do not build new things. The
 * factory-driver flow was tested against this table; re-pointing the controller at the spine would be a
 * rewrite, not a restoration. So this migration recreates the table with the **exact** column set the
 * controller and its related screens expect - the union of the table's original definition
 * (2026_05_18_000500), the later additions (driver_type/is_active 2026_05_22_000020; staff_type/salary/
 * commission_rate 2026_05_23_000027; owner_id 2026_05_25_000001) and the schema-drift hotfix
 * (cnic/address/hire_date 2026_05_26_000034).
 *
 * Notes kept from those migrations on purpose:
 *   * `email` is NULLABLE - the hotfix made it nullable because NOT NULL broke inserts.
 *   * The self-referencing `owner_id` foreign key is deliberately NOT recreated (it needed a separate
 *     pass and the controller does not depend on it); the column and its index are enough.
 *
 * TRACKED DEBT: the cutover's intent was for everything to live on the spine. The factory-driver flow is
 * therefore the last consumer of this table, and moving it to `fleet_assignments` is real work for a
 * later phase - recorded in the handoff docs rather than smuggled in here.
 *
 * Idempotent: does nothing if `drivers` already exists.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('drivers')) {
            return;
        }

        Schema::create('drivers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('company_id')->nullable();
            $table->uuid('factory_id')->nullable();
            $table->uuid('owner_id')->nullable();

            $table->string('name', 255);
            $table->string('phone', 50)->nullable();
            // Nullable on purpose - see the class docblock.
            $table->string('email', 255)->nullable();
            $table->string('password', 255)->nullable();

            $table->string('license_number', 100)->nullable();
            $table->timestamp('license_expiry')->nullable();
            $table->string('vehicle_plate_number', 50)->nullable();
            $table->string('vehicle_type', 50)->nullable();
            $table->string('insurance_number', 100)->nullable();
            $table->timestamp('insurance_expiry')->nullable();
            $table->timestamp('registration_expiry')->nullable();

            $table->string('status', 50)->default('active');
            $table->string('driver_type', 20)->default('factory'); // factory | truck | bus
            $table->string('staff_type', 30)->default('driver');   // driver | conductor
            $table->boolean('is_active')->default(true);
            $table->string('tier', 20)->default('bronze');
            $table->decimal('rating', 3, 2)->default(0.00);

            // Factory-driver profile fields the controller reads back.
            $table->integer('total_trips')->default(0);
            $table->integer('completed_trips')->default(0);
            $table->integer('on_time_deliveries')->default(0);
            $table->integer('late_deliveries')->default(0);
            $table->decimal('driving_hours_today', 4, 1)->default(0.0);
            $table->decimal('driving_hours_week', 5, 1)->default(0.0);
            $table->boolean('is_fatigued')->default(false);

            $table->string('cnic', 30)->nullable();
            $table->text('address')->nullable();
            $table->date('hire_date')->nullable();
            $table->decimal('salary', 12, 2)->default(0);
            $table->decimal('commission_rate', 5, 2)->default(0);

            $table->timestamp('last_login_at')->nullable();
            $table->string('remember_token', 100)->nullable();
            $table->timestamps();

            $table->index('company_id');
            $table->index('factory_id');
            $table->index('owner_id');
        });
    }

    public function down(): void
    {
        // Intentionally empty: dropping it again would re-break the Factory panel's driver flow.
    }
};
