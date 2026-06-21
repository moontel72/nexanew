<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — SCHEMA BOOTSTRAP SERVICE
 * =====================================
 *
 * Ensures all required tables and columns exist on every
 * request. Uses raw SQL CREATE TABLE IF NOT EXISTS so it
 * works regardless of whether Laravel migrations have run.
 *
 * This is a failsafe for production servers where
 * php artisan migrate may have silently failed.
 */
class SchemaBootstrapService
{
    private static bool $booted = false;

    /**
     * Call once at app boot. Idempotent — safe to call
     * on every request or only on the first.
     */
    public static function boot(): void
    {
        if (self::$booted) return;
        self::$booted = true;

        try {
            self::ensureAllTablesAndColumns();
        } catch (\Throwable $e) {
            Log::warning('SchemaBootstrapService: ' . $e->getMessage());
        }
    }

    /**
     * Public entry point — always runs, ignores $booted flag.
     * Call this directly from controllers before DB writes.
     *
     * @throws \RuntimeException if pivot tables cannot be created
     */
    public static function ensureColumns(): void
    {
        try {
            self::ensureTransportBusRoutesColumns();
            self::ensureRouteSegmentPricesColumns();
        } catch (\Throwable $e) {
            Log::warning('SchemaBootstrapService::ensureColumns (non-critical): ' . $e->getMessage());
        }

        // Pivot tables are CRITICAL — verify they exist, throw if not
        try {
            self::ensureRoutePivotTables();
        } catch (\Throwable $e) {
            Log::error('SchemaBootstrapService: failed to create pivot tables — ' . $e->getMessage());
            throw new \RuntimeException(
                'Database schema is incomplete. Pivot tables for route vouchers/bonuses could not be created. ' .
                'Please run: php artisan migrate --force or check PostgreSQL permissions.'
            );
        }

        // Verify tables actually exist after creation
        if (!Schema::hasTable('route_assigned_vouchers') || !Schema::hasTable('route_assigned_bonuses')) {
            throw new \RuntimeException(
                'Pivot tables route_assigned_vouchers / route_assigned_bonuses do not exist and could not be created.'
            );
        }
    }

    private static function ensureAllTablesAndColumns(): void
    {
        self::ensureBusVouchersTable();
        self::ensurePassengerLoyaltyLedgerTable();
        self::ensureVoucherRedemptionsTable();
        self::ensureTransportBusRoutesColumns();
        self::ensureRouteSegmentPricesColumns();
        self::ensureRoutePivotTables();
    }

    private static function ensureBusVouchersTable(): void
    {
        if (Schema::hasTable('bus_vouchers')) return;

        DB::statement('
            CREATE TABLE IF NOT EXISTS bus_vouchers (
                id UUID PRIMARY KEY,
                bus_company_id VARCHAR(255) NOT NULL,
                code VARCHAR(30) NOT NULL UNIQUE,
                title VARCHAR(255) NOT NULL,
                type VARCHAR(20) NOT NULL CHECK (type IN (\'percentage\', \'fixed\', \'multiplier\')),
                value NUMERIC(10, 2) NOT NULL,
                min_order NUMERIC(10, 2) DEFAULT 0,
                max_discount NUMERIC(10, 2),
                usage_limit INTEGER,
                used_count INTEGER DEFAULT 0,
                starts_at TIMESTAMP,
                expires_at TIMESTAMP,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP,
                updated_at TIMESTAMP
            )
        ');

        DB::statement('CREATE INDEX IF NOT EXISTS bus_vouchers_bus_company_id_idx ON bus_vouchers (bus_company_id)');
        DB::statement('CREATE INDEX IF NOT EXISTS bus_vouchers_code_idx ON bus_vouchers (code)');
        DB::statement('CREATE INDEX IF NOT EXISTS bus_vouchers_is_active_idx ON bus_vouchers (is_active)');

        Log::info('SchemaBootstrapService: created bus_vouchers table');
    }

    private static function ensurePassengerLoyaltyLedgerTable(): void
    {
        if (Schema::hasTable('passenger_loyalty_ledger')) return;

        DB::statement('
            CREATE TABLE IF NOT EXISTS passenger_loyalty_ledger (
                id UUID PRIMARY KEY,
                passenger_id UUID NOT NULL,
                bus_company_id VARCHAR(255) NOT NULL,
                total_trips INTEGER DEFAULT 0,
                total_spent NUMERIC(12, 2) DEFAULT 0,
                loyalty_points INTEGER DEFAULT 0,
                tier VARCHAR(20) DEFAULT \'bronze\',
                last_trip_at TIMESTAMP,
                created_at TIMESTAMP,
                updated_at TIMESTAMP,
                UNIQUE (passenger_id, bus_company_id)
            )
        ');

        DB::statement('CREATE INDEX IF NOT EXISTS pll_passenger_idx ON passenger_loyalty_ledger (passenger_id)');
        DB::statement('CREATE INDEX IF NOT EXISTS pll_company_idx ON passenger_loyalty_ledger (bus_company_id)');

        Log::info('SchemaBootstrapService: created passenger_loyalty_ledger table');
    }

    private static function ensureVoucherRedemptionsTable(): void
    {
        if (Schema::hasTable('voucher_redemptions')) return;

        DB::statement('
            CREATE TABLE IF NOT EXISTS voucher_redemptions (
                id UUID PRIMARY KEY,
                voucher_id UUID NOT NULL,
                passenger_id UUID NOT NULL,
                booking_id UUID,
                discount_amount NUMERIC(10, 2) NOT NULL,
                original_price NUMERIC(10, 2) NOT NULL,
                final_price NUMERIC(10, 2) NOT NULL,
                created_at TIMESTAMP,
                updated_at TIMESTAMP
            )
        ');

        DB::statement('CREATE INDEX IF NOT EXISTS vr_voucher_idx ON voucher_redemptions (voucher_id)');
        DB::statement('CREATE INDEX IF NOT EXISTS vr_passenger_idx ON voucher_redemptions (passenger_id)');

        Log::info('SchemaBootstrapService: created voucher_redemptions table');
    }

    private static function ensureTransportBusRoutesColumns(): void
    {
        if (!Schema::hasColumn('transport_bus_routes', 'owner_identity_id')) {
            DB::statement('ALTER TABLE transport_bus_routes ADD COLUMN IF NOT EXISTS owner_identity_id VARCHAR(255)');
            DB::statement('CREATE INDEX IF NOT EXISTS tbr_owner_idx ON transport_bus_routes (owner_identity_id)');
            Log::info('SchemaBootstrapService: added owner_identity_id to transport_bus_routes');
        }

        if (!Schema::hasColumn('transport_bus_routes', 'voucher_id')) {
            DB::statement('ALTER TABLE transport_bus_routes ADD COLUMN IF NOT EXISTS voucher_id UUID');
            Log::info('SchemaBootstrapService: added voucher_id to transport_bus_routes');
        }

        if (!Schema::hasColumn('transport_bus_routes', 'driver_bonus_id')) {
            DB::statement('ALTER TABLE transport_bus_routes ADD COLUMN IF NOT EXISTS driver_bonus_id UUID');
            Log::info('SchemaBootstrapService: added driver_bonus_id to transport_bus_routes');
        }

        if (!Schema::hasColumn('transport_bus_routes', 'conductor_bonus_id')) {
            DB::statement('ALTER TABLE transport_bus_routes ADD COLUMN IF NOT EXISTS conductor_bonus_id UUID');
            Log::info('SchemaBootstrapService: added conductor_bonus_id to transport_bus_routes');
        }
    }

    private static function ensureRoutePivotTables(): void
    {
        if (!Schema::hasTable('route_assigned_vouchers')) {
            DB::statement('
                CREATE TABLE IF NOT EXISTS route_assigned_vouchers (
                    route_id UUID NOT NULL,
                    voucher_id UUID NOT NULL,
                    created_at TIMESTAMP,
                    PRIMARY KEY (route_id, voucher_id)
                )
            ');
            DB::statement('CREATE INDEX IF NOT EXISTS rav_route_idx ON route_assigned_vouchers (route_id)');
            DB::statement('CREATE INDEX IF NOT EXISTS rav_voucher_idx ON route_assigned_vouchers (voucher_id)');
            Log::info('SchemaBootstrapService: created route_assigned_vouchers table');
        }

        if (!Schema::hasTable('route_assigned_bonuses')) {
            DB::statement('
                CREATE TABLE IF NOT EXISTS route_assigned_bonuses (
                    route_id UUID NOT NULL,
                    bonus_id UUID NOT NULL,
                    created_at TIMESTAMP,
                    PRIMARY KEY (route_id, bonus_id)
                )
            ');
            DB::statement('CREATE INDEX IF NOT EXISTS rab_route_idx ON route_assigned_bonuses (route_id)');
            DB::statement('CREATE INDEX IF NOT EXISTS rab_bonus_idx ON route_assigned_bonuses (bonus_id)');
            Log::info('SchemaBootstrapService: created route_assigned_bonuses table');
        }
    }

    private static function ensureRouteSegmentPricesColumns(): void
    {
        if (Schema::hasColumn('route_segment_prices', 'price_business')) return;

        DB::statement('ALTER TABLE route_segment_prices ADD COLUMN IF NOT EXISTS price_sleeper_upper NUMERIC(10, 2)');
        DB::statement('ALTER TABLE route_segment_prices ADD COLUMN IF NOT EXISTS price_sleeper_lower NUMERIC(10, 2)');
        DB::statement('ALTER TABLE route_segment_prices ADD COLUMN IF NOT EXISTS price_business NUMERIC(10, 2)');
        DB::statement('ALTER TABLE route_segment_prices ADD COLUMN IF NOT EXISTS price_folding NUMERIC(10, 2)');

        Log::info('SchemaBootstrapService: added seat category price columns to route_segment_prices');
    }
}
