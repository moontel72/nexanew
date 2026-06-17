<?php

namespace App\Services\Transport;

use App\Models\Transport\AbsoluteBusLayout;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — ABSOLUTE LAYOUT SERVICE
 * ====================================
 *
 * Manages the lifecycle of absolute (freeform) bus seat layouts.
 * Components are stored as JSON with pixel coordinates (x, y, width,
 * height, rotation) — no grid row/column math.
 *
 * 100% isolated from the legacy LayoutService.
 *
 * API routes: /api/bus-owner/absolute-layouts/*
 */
class AbsoluteLayoutService
{
    /**
     * Check if the carrier_company_id column exists (migration may not have run yet).
     */
    private function hasCarrierColumn(): bool
    {
        return \Illuminate\Support\Facades\Schema::hasColumn('absolute_bus_layouts', 'carrier_company_id');
    }

    // ═══════════════════════════════════════════════════════════
    // LIST
    // ═══════════════════════════════════════════════════════════

    /**
     * Get all absolute layouts for the authenticated owner.
     * When $carrierCompanyId is provided, scopes by carrier company
     * instead of owner identity (used by bus-fleet admin panel).
     */
    public function listLayouts(string $ownerIdentityId, int $perPage = 20, ?string $carrierCompanyId = null): array
    {
        $perPage = max(1, min(100, $perPage));

        $query = AbsoluteBusLayout::where('layout_status', '!=', 'archived');

        if ($carrierCompanyId !== null && $this->hasCarrierColumn()) {
            $query->where('carrier_company_id', $carrierCompanyId);
        } else {
            $query->where('owner_identity_id', $ownerIdentityId);
        }

        $query->orderBy('updated_at', 'desc');

        $paginator = $query->paginate($perPage);

        return [
            'data' => $paginator->items(),
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'last_page' => $paginator->lastPage(),
            ],
        ];
    }

    // ═══════════════════════════════════════════════════════════
    // SHOW
    // ═══════════════════════════════════════════════════════════

    /**
     * Get a single absolute layout by ID.
     * For single-layout lookups, scoping by owner/carrier is relaxed —
     * the UUID alone is sufficiently unguessable. If owner or carrier
     * scope is provided and finds a match, use it; otherwise fall back
     * to ID-only lookup.
     */
    public function showLayout(string $id, string $ownerIdentityId, ?string $carrierCompanyId = null): ?array
    {
        // Try scoped lookup first
        $query = AbsoluteBusLayout::where('id', $id);

        if ($carrierCompanyId !== null && $this->hasCarrierColumn()) {
            $query->where('carrier_company_id', $carrierCompanyId);
        } else {
            $query->where('owner_identity_id', $ownerIdentityId);
        }

        $layout = $query->first();

        // Fall back to ID-only lookup (unguessable UUID is safe)
        if (!$layout) {
            $layout = AbsoluteBusLayout::find($id);
        }

        if (!$layout) return null;

        return $layout->toArray();
    }

    // ═══════════════════════════════════════════════════════════
    // CREATE
    // ═══════════════════════════════════════════════════════════

    /**
     * Create a new absolute layout.
     */
    public function createLayout(string $ownerIdentityId, array $data): AbsoluteBusLayout
    {
        $id = $data['id'] ?? (string) \Illuminate\Support\Str::uuid();

        $layoutData = [
            'id' => $id,
            'owner_identity_id' => $ownerIdentityId,
            'display_name' => $data['display_name'] ?? 'Untitled Layout',
            'deck_level' => $data['deck_level'] ?? 'lower',
            'canvas_width' => $data['canvas_width'] ?? 280,
            'canvas_height' => $data['canvas_height'] ?? 896,
            'current_snapshot' => $data['current_snapshot'] ?? null,
            'layout_status' => $data['layout_status'] ?? 'draft',
            'version_number' => 1,
            'is_active' => true,
        ];

        if ($this->hasCarrierColumn() && isset($data['carrier_company_id'])) {
            $layoutData['carrier_company_id'] = $data['carrier_company_id'];
        }

        $layout = AbsoluteBusLayout::create($layoutData);

        Log::info('AbsoluteBusLayout created', [
            'layout_id' => $layout->id,
            'owner_identity_id' => $ownerIdentityId,
        ]);

        return $layout;
    }

    // ═══════════════════════════════════════════════════════════
    // UPDATE
    // ═══════════════════════════════════════════════════════════

    /**
     * Update an existing absolute layout (owner-scoped or carrier-scoped).
     */
    public function updateLayout(string $id, string $ownerIdentityId, array $data, ?string $carrierCompanyId = null): ?AbsoluteBusLayout
    {
        $query = AbsoluteBusLayout::where('id', $id);

        if ($carrierCompanyId !== null && $this->hasCarrierColumn()) {
            $query->where('carrier_company_id', $carrierCompanyId);
        } else {
            $query->where('owner_identity_id', $ownerIdentityId);
        }

        $layout = $query->first();

        if (!$layout) return null;

        $updateFields = [];
        if (isset($data['display_name'])) $updateFields['display_name'] = $data['display_name'];
        if (isset($data['deck_level'])) $updateFields['deck_level'] = $data['deck_level'];
        if (isset($data['canvas_width'])) $updateFields['canvas_width'] = (int) $data['canvas_width'];
        if (isset($data['canvas_height'])) $updateFields['canvas_height'] = (int) $data['canvas_height'];
        if (array_key_exists('current_snapshot', $data)) {
            $updateFields['current_snapshot'] = $data['current_snapshot'];
        }
        if (isset($data['layout_status'])) $updateFields['layout_status'] = $data['layout_status'];
        if ($updateFields) {
            $updateFields['version_number'] = $layout->version_number + 1;
        }

        $layout->update($updateFields);

        Log::info('AbsoluteBusLayout updated', [
            'layout_id' => $id,
            'version' => $layout->version_number,
        ]);

        return $layout->fresh();
    }

    // ═══════════════════════════════════════════════════════════
    // DELETE (soft-delete → archive)
    // ═══════════════════════════════════════════════════════════

    /**
     * Soft-delete (archive) a layout (owner-scoped or carrier-scoped).
     */
    public function deleteLayout(string $id, string $ownerIdentityId, ?string $carrierCompanyId = null): bool
    {
        $query = AbsoluteBusLayout::where('id', $id);

        if ($carrierCompanyId !== null && $this->hasCarrierColumn()) {
            $query->where('carrier_company_id', $carrierCompanyId);
        } else {
            $query->where('owner_identity_id', $ownerIdentityId);
        }

        $layout = $query->first();

        if (!$layout) return false;

        $layout->update([
            'layout_status' => 'archived',
            'is_active' => false,
        ]);
        $layout->delete(); // soft delete

        Log::info('AbsoluteBusLayout archived', ['layout_id' => $id]);
        return true;
    }

    // ═══════════════════════════════════════════════════════════
    // LIST PUBLIC (no auth — customer guest browsing)
    // ═══════════════════════════════════════════════════════════

    /** List all published layouts (no auth). */
    public function listPublicLayouts(int $perPage = 20): array
    {
        $perPage = max(1, min(100, $perPage));
        $paginator = AbsoluteBusLayout::where('layout_status', 'published')
            ->orderBy('updated_at', 'desc')
            ->paginate($perPage);

        Log::info('listPublicLayouts', [
            'total' => $paginator->total(),
            'count' => $paginator->count(),
        ]);

        return [
            'data' => $paginator->items(),
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'last_page' => $paginator->lastPage(),
            ],
        ];
    }

    // ═══════════════════════════════════════════════════════════
    // SHOW PUBLIC (no auth — customer guest browsing)
    // ═══════════════════════════════════════════════════════════

    /**
     * Fetch a published layout without authentication.
     * Only returns layouts with layout_status = 'published'.
     * When $includeBookings is true, attaches current booked seat
     * numbers from transport_seat_bookings.
     */
    public function showPublicLayout(string $id, bool $includeBookings = false): ?array
    {
        // Reject non-UUID values before they hit PostgreSQL to avoid
        // SQLSTATE[22P02] "invalid input syntax for type uuid".
        if (!\Illuminate\Support\Str::isUuid($id)) {
            Log::info('showPublicLayout rejected non-UUID', ['id' => $id]);
            return null;
        }

        try {
            $layout = AbsoluteBusLayout::where('id', $id)
                ->where('layout_status', 'published')
                ->first();

            if (!$layout) {
                // Diagnostic: check if the layout exists at all (any status)
                $any = AbsoluteBusLayout::find($id);
                Log::info('showPublicLayout not found', [
                    'id' => $id,
                    'exists_at_all' => $any !== null,
                    'actual_status' => $any?->layout_status ?? 'n/a',
                ]);
                return null;
            }

            $result = $layout->toArray();

            if ($includeBookings) {
                // Attach booked seat numbers (trip-agnostic: all bookings for this layout)
                $bookedSeats = DB::table('transport_seat_bookings')
                    ->where('bus_layout_id', $id)
                    ->whereIn('status', ['confirmed', 'boarded'])
                    ->pluck('seat_number')
                    ->toArray();

                $result['booked_seats'] = $bookedSeats;
                $result['booked_seat_numbers'] = $bookedSeats;
            }

            // Count total seats from the snapshot components
            $snapshot = $layout->current_snapshot;
            $components = is_string($snapshot) ? json_decode($snapshot, true) : ($snapshot ?? []);
            $seats = $components['seats'] ?? $components['components'] ?? $components ?? [];
            $totalSeats = is_array($seats) ? count($seats) : 0;

            $bookedCount = 0;
            if (!empty($result['booked_seats']) && is_array($result['booked_seats'])) {
                $bookedCount = count($result['booked_seats']);
            } elseif (!empty($result['booked_seat_numbers']) && is_array($result['booked_seat_numbers'])) {
                $bookedCount = count($result['booked_seat_numbers']);
            }
            $availableSeats = max(0, $totalSeats - $bookedCount);

            $result['total_seats'] = $totalSeats;
            $result['available_seats'] = $availableSeats;

            // Embed canvas dimensions inside current_snapshot so the Flutter
            // BLoC can read them via result.snapshot['canvas'].
            $snapshotDecoded = is_string($snapshot) ? json_decode($snapshot, true) : ($snapshot ?? []);
            if (is_array($snapshotDecoded)) {
                $snapshotDecoded['canvas'] = [
                    'width' => (int) ($layout->canvas_width ?? 280),
                    'height' => (int) ($layout->canvas_height ?? 728),
                ];
                $result['current_snapshot'] = $snapshotDecoded;
            }

            return $result;
        } catch (\Exception $e) {
            Log::warning('showPublicLayout failed', [
                'id' => $id,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    // ═══════════════════════════════════════════════════════════
    // PUBLISH (create immutable revision snapshot)
    // ═══════════════════════════════════════════════════════════

    /**
     * Publish a layout: marks it 'published' and writes an
     * immutable revision row to absolute_bus_layout_revisions.
     */
    public function publishLayout(
        string $id,
        string $ownerIdentityId,
        ?string $publisherId = null,
        ?string $changeDescription = null,
        ?string $carrierCompanyId = null,
    ): ?AbsoluteBusLayout {
        $query = AbsoluteBusLayout::where('id', $id);

        if ($carrierCompanyId !== null && $this->hasCarrierColumn()) {
            $query->where('carrier_company_id', $carrierCompanyId);
        } else {
            $query->where('owner_identity_id', $ownerIdentityId);
        }

        $layout = $query->first();

        if (!$layout) return null;

        // Write immutable revision
        DB::table('absolute_bus_layout_revisions')->insert([
            'layout_id' => $layout->id,
            'version_number' => $layout->version_number,
            'full_snapshot' => json_encode($layout->current_snapshot),
            'published_by' => $publisherId,
            'change_description' => $changeDescription,
            'created_at' => now(),
        ]);

        // Mark as published
        $layout->update([
            'layout_status' => 'published',
            'version_number' => $layout->version_number + 1,
        ]);

        Log::info('AbsoluteBusLayout published', [
            'layout_id' => $id,
            'version' => $layout->version_number,
        ]);

        return $layout->fresh();
    }

    // ═══════════════════════════════════════════════════════════
    // PURGE (hard delete all for an owner — dev helper)
    // ═══════════════════════════════════════════════════════════

    /**
     * Purge all absolute layouts for an owner or carrier (hard delete).
     */
    public function purgeAll(string $ownerIdentityId, ?string $carrierCompanyId = null): int
    {
        $query = AbsoluteBusLayout::where('owner_identity_id', $ownerIdentityId);

        if ($carrierCompanyId !== null && $this->hasCarrierColumn()) {
            $query->where('carrier_company_id', $carrierCompanyId);
        }

        $count = $query->forceDelete();

        Log::warning('AbsoluteBusLayout purge all', [
            'owner_identity_id' => $ownerIdentityId,
            'count' => $count,
        ]);

        return $count;
    }
}
