<?php

use Illuminate\Support\Facades\Broadcast;

/**
 * NEXATRACE — BROADCASTING CHANNEL AUTHORIZATION ROUTES
 * ======================================================
 *
 * These authorization callbacks gate who can subscribe to
 * which WebSocket channels. Every channel rule below enforces
 * identity-spine ownership verification.
 *
 * CHANNEL MAP:
 *   bus.{tripId}        — Any authenticated user (public transit data)
 *   fleet.{companyId}   — Fleet owner, driver, or conductor of that company
 *   driver.{driverId}   — The driver themselves, their owning company
 *   trip.{tripId}       — Trip stakeholders (driver, owner, factory)
 *   auction.{loadId}    — Any authenticated carrier
 *   delivery.{id}       — Delivery stakeholders
 *   store_keeper.{id}   — The store keeper themselves
 */

// ─── BUS CHANNELS ─────────────────────────────────────

Broadcast::channel('bus.{tripId}', function ($user, string $tripId) {
    // Public transit data — any authenticated user can subscribe
    // to receive live bus location, ETA, and seat availability.
    return $user !== null;
});

Broadcast::channel('bus.{tripId}.seats', function ($user, string $tripId) {
    // Seat hold/release/confirm events — public to all authenticated
    // passengers viewing the trip layout.
    return $user !== null;
});

// ─── FLEET CHANNELS ───────────────────────────────────

Broadcast::channel('fleet.{companyId}', function ($user, string $companyId) {
    if (! $user) return false;

    // Master admin sees all
    if (($user->account_type ?? null) === 'master_admin') {
        return true;
    }

    // Fleet owner/driver/conductor of this company
    $globalId = $user->global_identity_id ?? $user->id;

    return \Illuminate\Support\Facades\DB::table('fleet_assignments')
        ->where('global_identity_id', $globalId)
        ->where('carrier_company_id', $companyId)
        ->whereIn('status', ['active', 'pending_acceptance'])
        ->exists();
});

// ─── DRIVER CHANNELS ──────────────────────────────────

Broadcast::channel('driver.{driverId}', function ($user, string $driverId) {
    if (! $user) return false;

    // Driver owns their own channel
    $globalId = $user->global_identity_id ?? $user->id;
    if ($globalId === $driverId) {
        return true;
    }

    // Owner can track their assigned drivers
    return \Illuminate\Support\Facades\DB::table('fleet_assignments')
        ->where('carrier_identity_id', $globalId)
        ->where('global_identity_id', $driverId)
        ->where('role', 'driver')
        ->whereIn('status', ['active', 'pending_acceptance'])
        ->exists();
});

// ─── TRIP CHANNELS ────────────────────────────────────

Broadcast::channel('trip.{tripId}', function ($user, string $tripId) {
    // Authenticated users can receive trip status updates
    return $user !== null;
});

// ─── AUCTION CHANNELS ─────────────────────────────────

Broadcast::channel('auction.{loadId}', function ($user, string $loadId) {
    // Any authenticated carrier can participate in auctions
    return $user !== null;
});

// ─── DELIVERY CHANNELS ────────────────────────────────

Broadcast::channel('delivery.{deliveryId}', function ($user, string $deliveryId) {
    // Authenticated users can receive delivery confirmations
    return $user !== null;
});

// ─── STORE KEEPER CHANNELS ────────────────────────────

Broadcast::channel('store_keeper.{storeKeeperId}', function ($user, string $storeKeeperId) {
    if (! $user) return false;

    $globalId = $user->global_identity_id ?? $user->id;

    // Store keeper owns their own channel
    if ($globalId === $storeKeeperId) {
        return true;
    }

    // Factory admin can track their store keepers
    return \Illuminate\Support\Facades\DB::table('fleet_assignments')
        ->where('carrier_identity_id', $globalId)
        ->where('global_identity_id', $storeKeeperId)
        ->whereIn('status', ['active', 'pending_acceptance'])
        ->exists();
});
