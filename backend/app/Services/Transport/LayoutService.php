<?php

namespace App\Services\Transport;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — SEAT LAYOUT SERVICE (Wave 4)
 * ========================================
 *
 * Manages the lifecycle of bus seat layouts including creation
 * from vehicle-class presets, edit-lock leasing with 5-minute
 * expiry, optimistic concurrency publishing to an immutable
 * revision vault, and soft-delete (archival).
 *
 * Uses DB facade directly — consistent with the
 * FleetManagementController pattern.
 *
 * Section 10.6: Decentralized Seat Layout Sovereignty.
 * Section 14E:   Seat Layout Designer.
 */
class LayoutService
{
    private const EDIT_LOCK_TTL_MINUTES = 5;

    // ═══════════════════════════════════════════════════════════
    // LIST
    // ═══════════════════════════════════════════════════════════

    /**
     * Get all layouts for a company, optionally filtered by vehicle class.
     */
    public function listLayouts(
        string $companyId,
        ?string $vehicleClass = null,
        int $perPage = 20,
    ): array {
        $perPage = max(1, min(100, $perPage));

        $query = DB::table('transport_bus_layouts')
            ->where('carrier_company_id', $companyId)
            ->where('layout_status', '!=', 'archived');

        if ($vehicleClass !== null && $vehicleClass !== '') {
            $query->where('vehicle_class', $vehicleClass);
        }

        $paginator = $query->orderBy('updated_at', 'desc')->paginate($perPage);

        return [
            'data'       => $this->decodeSnapshots($paginator->items()),
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'per_page'     => $paginator->perPage(),
                'total'        => $paginator->total(),
                'last_page'    => $paginator->lastPage(),
            ],
        ];
    }

    // ═══════════════════════════════════════════════════════════
    // GET SINGLE
    // ═══════════════════════════════════════════════════════════

    /**
     * Get a single layout with its current snapshot and revision count.
     */
    public function getLayout(string $layoutId): array
    {
        $layout = DB::table('transport_bus_layouts')
            ->where('id', $layoutId)
            ->first();

        if (! $layout) {
            throw new \RuntimeException('Layout not found.');
        }

        $revisionCount = DB::table('transport_bus_layout_revisions')
            ->where('layout_id', $layoutId)
            ->count();

        // Check if edit lock is still valid
        $editLock = null;
        if ($layout->edit_lock_held_by) {
            $expires = $layout->edit_lock_expires_at
                ? Carbon::parse($layout->edit_lock_expires_at)
                : null;
            if ($expires && $expires->isFuture()) {
                $editLock = [
                    'held_by'    => $layout->edit_lock_held_by,
                    'expires_at' => $expires->toIso8601String(),
                ];
            }
        }

        return [
            'data' => [
                'id'                  => $layout->id,
                'bus_id'              => $layout->bus_id ?? null,
                'owner_id'            => $layout->owner_id ?? null,
                'owner_identity_id'   => $layout->owner_identity_id ?? null,
                'carrier_company_id'  => $layout->carrier_company_id ?? null,
                'vehicle_class'       => $layout->vehicle_class ?? null,
                'display_name'        => $layout->display_name ?? null,
                'is_locked_sovereign' => (bool) ($layout->is_locked_sovereign ?? true),
                'version_number'      => (int) ($layout->version_number ?? 1),
                'layout_status'       => $layout->layout_status ?? 'draft',
                'current_snapshot'    => $this->jsonDecode($layout->current_snapshot ?? null),
                'edit_lock'           => $editLock,
                'deck_level'          => (int) ($layout->deck_level ?? 0),
                'parent_layout_id'    => $layout->parent_layout_id ?? null,
                'total_rows'          => $layout->total_rows ?? null,
                'left_columns'        => $layout->left_columns ?? null,
                'right_columns'       => $layout->right_columns ?? null,
                'driver_seats'        => $layout->driver_seats ?? null,
                'is_active'           => (bool) ($layout->is_active ?? true),
                'revision_count'      => $revisionCount,
                'created_at'          => $layout->created_at ?? null,
                'updated_at'          => $layout->updated_at ?? null,
            ],
        ];
    }

    // ═══════════════════════════════════════════════════════════
    // CREATE
    // ═══════════════════════════════════════════════════════════

    /**
     * Create (initialize) a new layout from a vehicle-class preset.
     */
    public function createLayout(
        string $ownerIdentityId,
        string $companyId,
        string $vehicleClass,
        string $displayName,
        int $deckLevel = 0,
    ): array {
        $presets = $this->getPresets();
        $preset = collect($presets)->firstWhere('key', $vehicleClass);

        if (! $preset) {
            throw new \RuntimeException("Unknown vehicle class: {$vehicleClass}. Valid: " . implode(', ', array_column($presets, 'key')));
        }

        $id = DB::selectOne("SELECT gen_random_uuid() AS id")->id;
        $now = now();
        $snapshot = $this->buildInitialSnapshot($preset);

        DB::table('transport_bus_layouts')->insert([
            'id'                  => $id,
            'bus_id'              => $id,  // self-reference for backward compat
            'owner_identity_id'   => $ownerIdentityId,
            'carrier_company_id'  => $companyId,
            'vehicle_class'       => $vehicleClass,
            'display_name'        => $displayName,
            'is_locked_sovereign' => true,
            'version_number'      => 1,
            'layout_status'       => 'draft',
            'current_snapshot'    => json_encode($snapshot),
            'edit_lock_held_by'   => null,
            'edit_lock_expires_at'=> null,
            'deck_level'          => $deckLevel,
            'parent_layout_id'    => null,
            'total_rows'          => $preset['rows'],
            'left_columns'        => $preset['left_cols'],
            'right_columns'       => $preset['right_cols'],
            'driver_seats'        => $preset['driver_seats'],
            'raw_grid_json'       => json_encode($snapshot['grid'] ?? []),
            'is_active'           => true,
            'created_at'          => $now,
            'updated_at'          => $now,
        ]);

        Log::info('LayoutService: layout created', [
            'layout_id'     => $id,
            'vehicle_class' => $vehicleClass,
            'identity_id'   => $ownerIdentityId,
            'company_id'    => $companyId,
        ]);

        return $this->getLayout($id)['data'];
    }

    // ═══════════════════════════════════════════════════════════
    // EDIT LOCK
    // ═══════════════════════════════════════════════════════════

    /**
     * Acquire an edit lock (5-minute lease) for a layout.
     *
     * Returns true if the lock was acquired. Returns false if
     * another identity holds a valid lock.
     */
    public function acquireEditLock(string $layoutId, string $identityId): bool
    {
        return DB::transaction(function () use ($layoutId, $identityId) {
            $layout = DB::table('transport_bus_layouts')
                ->where('id', $layoutId)
                ->lockForUpdate()
                ->first();

            if (! $layout) {
                throw new \RuntimeException('Layout not found.');
            }

            // Check if someone else holds a valid lock
            if ($layout->edit_lock_held_by && $layout->edit_lock_held_by !== $identityId) {
                $expires = $layout->edit_lock_expires_at
                    ? Carbon::parse($layout->edit_lock_expires_at)
                    : null;
                if ($expires && $expires->isFuture()) {
                    return false; // Lock held by another user
                }
                // Lock expired — fall through to acquire
            }

            $expiresAt = Carbon::now()->addMinutes(self::EDIT_LOCK_TTL_MINUTES);

            DB::table('transport_bus_layouts')
                ->where('id', $layoutId)
                ->update([
                    'edit_lock_held_by'    => $identityId,
                    'edit_lock_expires_at' => $expiresAt,
                    'updated_at'           => now(),
                ]);

            Log::info('LayoutService: edit lock acquired', [
                'layout_id'   => $layoutId,
                'identity_id' => $identityId,
                'expires_at'  => $expiresAt->toIso8601String(),
            ]);

            return true;
        });
    }

    /**
     * Release the edit lock on a layout.
     */
    public function releaseEditLock(string $layoutId): void
    {
        DB::table('transport_bus_layouts')
            ->where('id', $layoutId)
            ->update([
                'edit_lock_held_by'    => null,
                'edit_lock_expires_at' => null,
                'updated_at'           => now(),
            ]);

        Log::info('LayoutService: edit lock released', [
            'layout_id' => $layoutId,
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // PUBLISH (optimistic concurrency)
    // ═══════════════════════════════════════════════════════════

    /**
     * Publish a layout revision with optimistic concurrency.
     *
     * Atomic version bump: UPDATE … WHERE version_number = expectedVersion.
     * If 0 rows affected → version conflict error.
     */
    public function publishLayout(
        string $layoutId,
        string $identityId,
        array $gridSnapshot,
        int $expectedVersion,
        ?string $changeDescription = null,
    ): array {
        return DB::transaction(function () use (
            $layoutId, $identityId, $gridSnapshot, $expectedVersion, $changeDescription
        ) {
            // ── Lock the row for this transaction ──────────
            $layout = DB::table('transport_bus_layouts')
                ->where('id', $layoutId)
                ->lockForUpdate()
                ->first();

            if (! $layout) {
                throw new \RuntimeException('Layout not found.');
            }

            // ── Validate edit lock ─────────────────────────
            if ($layout->edit_lock_held_by && $layout->edit_lock_held_by !== $identityId) {
                $expires = $layout->edit_lock_expires_at
                    ? Carbon::parse($layout->edit_lock_expires_at)
                    : null;
                if ($expires && $expires->isFuture()) {
                    throw new \RuntimeException('Edit lock is held by another user.');
                }
            }

            // ── Sovereign lock check ───────────────────────
            if ($layout->is_locked_sovereign && $layout->owner_identity_id !== $identityId) {
                throw new \RuntimeException('Sovereign lock: only the layout owner can publish.');
            }

            // ── Version conflict check ─────────────────────
            $currentVersion = (int) $layout->version_number;
            if ($currentVersion !== $expectedVersion) {
                throw new \RuntimeException(
                    "Version conflict: expected version {$expectedVersion}, but current version is {$currentVersion}."
                );
            }

            // ── Collision validation ────────────────────────
            $this->validateSnapshot($gridSnapshot);

            // ── Re-number seats server-side (canonical) ───────
            $components = $gridSnapshot['components'] ?? $gridSnapshot['grid'] ?? [];
            if (!empty($components)) {
                $renumbered = $this->recomputeSeatNumbers($components);
                if (isset($gridSnapshot['components'])) {
                    $gridSnapshot['components'] = $renumbered;
                } else {
                    $gridSnapshot['grid'] = $renumbered;
                }
            }

            $newVersion = $currentVersion + 1;
            $now = now();

            // ── Atomic version bump ────────────────────────
            $updated = DB::table('transport_bus_layouts')
                ->where('id', $layoutId)
                ->where('version_number', $expectedVersion)
                ->update([
                    'version_number'       => $newVersion,
                    'current_snapshot'     => json_encode($gridSnapshot),
                    'layout_status'        => 'published',
                    'edit_lock_held_by'    => null,
                    'edit_lock_expires_at' => null,
                    'updated_at'           => $now,
                ]);

            if ($updated === 0) {
                throw new \RuntimeException(
                    "Version conflict: the layout was modified by another process. Expected version {$expectedVersion}."
                );
            }

            // ── Insert immutable revision ──────────────────
            DB::table('transport_bus_layout_revisions')->insert([
                'layout_id'          => $layoutId,
                'version_number'     => $newVersion,
                'full_snapshot'      => json_encode($gridSnapshot),
                'published_by'       => $identityId,
                'change_description' => $changeDescription,
                'deck_level'         => $layout->deck_level ?? 0,
                'created_at'         => $now,
            ]);

            Log::info('LayoutService: layout published', [
                'layout_id'    => $layoutId,
                'version'      => $newVersion,
                'identity_id'  => $identityId,
            ]);

            return [
                'layout_id'      => $layoutId,
                'version_number' => $newVersion,
                'layout_status'  => 'published',
                'published_at'   => $now->toIso8601String(),
            ];
        });
    }

    // ═══════════════════════════════════════════════════════════
    // COMPONENT UPDATE (Granular edit)
    // ═══════════════════════════════════════════════════════════

    /**
     * Partial component update — add, move, resize, or delete a single
     * component and atomically merge into the current snapshot.
     */
    public function updateComponent(
        string $layoutId,
        string $identityId,
        string $componentId,
        string $action,  // 'add' | 'move' | 'resize' | 'delete' | 'update'
        array $componentData,
    ): array {
        return DB::transaction(function () use ($layoutId, $identityId, $componentId, $action, $componentData) {
            $layout = DB::table('transport_bus_layouts')
                ->where('id', $layoutId)
                ->lockForUpdate()
                ->first();

            if (! $layout) throw new \RuntimeException('Layout not found.');

            $snapshot = $this->jsonDecode($layout->current_snapshot ?? null) ?? [];
            $components = $snapshot['components'] ?? $snapshot['grid'] ?? [];

            switch ($action) {
                case 'add':
                    $componentData['id'] = $componentId;
                    $components[] = $componentData;
                    break;
                case 'move':
                case 'resize':
                case 'update':
                    foreach ($components as &$comp) {
                        if (($comp['id'] ?? null) === $componentId) {
                            $comp = array_merge($comp, $componentData);
                            break;
                        }
                    }
                    unset($comp);
                    break;
                case 'delete':
                    $components = array_values(array_filter($components,
                        fn($c) => ($c['id'] ?? null) !== $componentId));
                    break;
            }

            // Re-number seats server-side
            $components = $this->recomputeSeatNumbers($components);

            // Validate no collisions
            $this->validateSnapshot(['components' => $components]);

            // Update the snapshot structure
            if (isset($snapshot['components'])) {
                $snapshot['components'] = $components;
            } else {
                $snapshot['grid'] = $components;
            }

            // Persist draft update
            DB::table('transport_bus_layouts')
                ->where('id', $layoutId)
                ->update([
                    'current_snapshot' => json_encode($snapshot),
                    'updated_at'       => now(),
                ]);

            Log::info('LayoutService: component updated', [
                'layout_id'    => $layoutId,
                'component_id' => $componentId,
                'action'       => $action,
            ]);

            return [
                'layout_id'    => $layoutId,
                'components'   => $components,
                'snapshot'     => $snapshot,
            ];
        });
    }

    // ═══════════════════════════════════════════════════════════
    // REVISIONS
    // ═══════════════════════════════════════════════════════════

    /**
     * List all revisions for a layout, newest first.
     */
    public function listRevisions(string $layoutId): array
    {
        $revisions = DB::table('transport_bus_layout_revisions')
            ->where('layout_id', $layoutId)
            ->orderBy('version_number', 'desc')
            ->get()
            ->map(function ($rev) {
                return [
                    'id'                 => $rev->id,
                    'layout_id'          => $rev->layout_id,
                    'version_number'     => (int) $rev->version_number,
                    'full_snapshot'      => $this->jsonDecode($rev->full_snapshot ?? null),
                    'published_by'       => $rev->published_by ?? null,
                    'change_description' => $rev->change_description ?? null,
                    'deck_level'         => (int) ($rev->deck_level ?? 0),
                    'created_at'         => $rev->created_at ?? null,
                ];
            })
            ->toArray();

        return ['data' => $revisions];
    }

    /**
     * Get a specific revision by version number.
     */
    public function getRevision(string $layoutId, int $versionNumber): array
    {
        $rev = DB::table('transport_bus_layout_revisions')
            ->where('layout_id', $layoutId)
            ->where('version_number', $versionNumber)
            ->first();

        if (! $rev) {
            throw new \RuntimeException("Revision {$versionNumber} not found for layout {$layoutId}.");
        }

        return [
            'data' => [
                'id'                 => $rev->id,
                'layout_id'          => $rev->layout_id,
                'version_number'     => (int) $rev->version_number,
                'full_snapshot'      => $this->jsonDecode($rev->full_snapshot ?? null),
                'published_by'       => $rev->published_by ?? null,
                'change_description' => $rev->change_description ?? null,
                'deck_level'         => (int) ($rev->deck_level ?? 0),
                'created_at'         => $rev->created_at ?? null,
            ],
        ];
    }

    // ═══════════════════════════════════════════════════════════
    // ARCHIVE
    // ═══════════════════════════════════════════════════════════

    /**
     * Soft-delete a layout by setting layout_status = 'archived'.
     */
    public function archiveLayout(string $layoutId): void
    {
        $updated = DB::table('transport_bus_layouts')
            ->where('id', $layoutId)
            ->update([
                'layout_status' => 'archived',
                'updated_at'    => now(),
            ]);

        if ($updated === 0) {
            throw new \RuntimeException('Layout not found.');
        }

        Log::info('LayoutService: layout archived', [
            'layout_id' => $layoutId,
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // PRESETS (public, static data)
    // ═══════════════════════════════════════════════════════════

    /**
     * Return the static preset definitions for vehicle classes.
     */
    public function getPresets(): array
    {
        return [
            [
                'key'            => 'coach_54',
                'label'          => '54-Seat Coach (Large)',
                'rows'           => 14,
                'cols'           => 4,
                'left_cols'      => 2,
                'right_cols'     => 2,
                'driver_seats'   => 1,
                'has_upper_deck' => false,
                'deck_type'      => 'single',
            ],
            [
                'key'            => 'standard_45',
                'label'          => '45-Seat Standard Coach',
                'rows'           => 11,
                'cols'           => 4,
                'left_cols'      => 2,
                'right_cols'     => 2,
                'driver_seats'   => 1,
                'has_upper_deck' => false,
                'deck_type'      => 'single',
            ],
            [
                'key'            => 'coaster_34',
                'label'          => '34-Seat Coaster',
                'rows'           => 9,
                'cols'           => 4,
                'left_cols'      => 2,
                'right_cols'     => 2,
                'driver_seats'   => 1,
                'has_upper_deck' => false,
                'deck_type'      => 'single',
            ],
            [
                'key'            => 'hiace_13',
                'label'          => '13-Seat HiAce',
                'rows'           => 4,
                'cols'           => 3,
                'left_cols'      => 2,
                'right_cols'     => 1,
                'driver_seats'   => 1,
                'has_upper_deck' => false,
                'deck_type'      => 'single',
            ],
            [
                'key'            => 'sleeper_custom',
                'label'          => 'Custom Sleeper Coach',
                'rows'           => 10,
                'cols'           => 4,
                'left_cols'      => 2,
                'right_cols'     => 2,
                'driver_seats'   => 1,
                'has_upper_deck' => true,
                'deck_type'      => 'dual',
            ],
        ];
    }

    // ═══════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════

    private function buildInitialSnapshot(array $preset): array
    {
        $grid = [];
        $seatNumber = 1;

        // Calculate authoritative dimensions
        $leftCols = (int) $preset['left_cols'];
        $rightCols = (int) $preset['right_cols'];
        $totalVisualCols = $leftCols + 1 + $rightCols; // left + aisle + right
        $ticketableCols = $leftCols + $rightCols;

        for ($row = 1; $row <= $preset['rows']; $row++) {
            // Left seats (columns 1..leftCols)
            for ($l = 1; $l <= $leftCols; $l++) {
                $label = $this->seatLabelByIndex($row, $seatNumber, $leftCols, $rightCols);
                $grid[] = [
                    'row'               => $row,
                    'col'               => $l,
                    'type'              => 'seat',
                    'seat_id'           => $label,
                    'bookable'          => true,
                    'gender_restriction' => null,
                    'seat_number'       => $seatNumber,
                ];
                $seatNumber++;
            }

            // Aisle column (structural marker — not ticketable)
            $aisleCol = $leftCols + 1;
            $grid[] = [
                'row'               => $row,
                'col'               => $aisleCol,
                'type'              => 'aisle',
                'seat_id'           => null,
                'bookable'          => false,
                'gender_restriction' => null,
                'seat_number'       => null,
            ];

            // Right seats (columns leftCols+2 .. totalVisualCols)
            for ($r = 1; $r <= $rightCols; $r++) {
                $col = $leftCols + 1 + $r;
                $label = $this->seatLabelByIndex($row, $seatNumber, $leftCols, $rightCols);
                $grid[] = [
                    'row'               => $row,
                    'col'               => $col,
                    'type'              => 'seat',
                    'seat_id'           => $label,
                    'bookable'          => true,
                    'gender_restriction' => null,
                    'seat_number'       => $seatNumber,
                ];
                $seatNumber++;
            }
        }

        // Driver seats (row 0, structural — not ticketable)
        for ($d = 1; $d <= $preset['driver_seats']; $d++) {
            $grid[] = [
                'row'               => 0,
                'col'               => $d,
                'type'              => 'driver',
                'seat_id'           => 'DRV' . $d,
                'bookable'          => false,
                'gender_restriction' => null,
                'seat_number'       => null,
            ];
        }

        $totalSeats = $preset['rows'] * $ticketableCols;

        return [
            'rows'              => $preset['rows'],
            'cols'              => $totalVisualCols,  // authoritative: total visual columns INCLUDING aisle
            'total_visual_cols' => $totalVisualCols,
            'seat_cols'         => $ticketableCols,   // ticketable columns only (excludes aisle/driver)
            'grid'              => $grid,
            'metadata' => [
                'total_seats'    => $totalSeats,
                'bookable_seats' => $totalSeats,
                'reserved_seats' => 0,
                'layout_version' => 1,
                'preset_key'     => $preset['key'],
                'left_cols'      => $leftCols,
                'right_cols'     => $rightCols,
                'driver_seats'   => $preset['driver_seats'],
            ],
        ];
    }

    /**
     * Generate a human-readable seat label like A1, A2, B1, B2…
     *
     * Uses letter for row and sequential seat position within the row.
     * Aisles and structural cells are SKIPPED — the seat index maps
     * only to ticketable positions.
     *
     * Example: 4-col bus (2L + aisle + 2R):
     *   Row 1 → A1, A2, [aisle], A3, A4
     *   Row 2 → B1, B2, [aisle], B3, B4
     */
    private function seatLabelByIndex(int $row, int $seatIndex, int $leftCols, int $rightCols): string
    {
        $ticketablePerRow = $leftCols + $rightCols;
        $positionInRow = (($seatIndex - 1) % $ticketablePerRow) + 1;
        $rowLetter = chr(64 + $row); // A-Z (supports up to row 26)
        return $rowLetter . $positionInRow;
    }

    /**
     * Legacy seat label (kept for backward-compat with old snapshots).
     * @deprecated Use seatLabelByIndex() for new snapshots.
     */
    private function seatLabel(int $row, int $col): string
    {
        $rowLetter = chr(64 + $row);
        return $rowLetter . $col;
    }

    /**
     * Server-side seat renumbering — walks the component grid top-left
     * to bottom-right, skipping structural cells (aisle, driver, exit door,
     * emergency, lavatory), and assigns monotonic seat numbers to ticketable
     * cells only.
     *
     * Prevents frontend-only numbering drift. Call this before publishing.
     */
    public function recomputeSeatNumbers(array $components): array
    {
        // Sort by (row, col) for top-left to bottom-right walk
        usort($components, function ($a, $b) {
            $rowCmp = ($a['origin_row'] ?? $a['row'] ?? 0) <=> ($b['origin_row'] ?? $b['row'] ?? 0);
            if ($rowCmp !== 0) return $rowCmp;
            return ($a['origin_col'] ?? $a['col'] ?? 0) <=> ($b['origin_col'] ?? $b['col'] ?? 0);
        });

        $seatCounter = 0;
        $structuralTypes = ['aisle', 'driver', 'exit_door', 'emergency', 'lavatory', 'driverCabin'];

        foreach ($components as &$comp) {
            $type = $comp['type'] ?? 'empty';
            if (in_array($type, $structuralTypes, true)) {
                $comp['seat_number'] = null;
                $comp['seat_id'] = null;
                continue;
            }

            $seatCounter++;
            $comp['seat_number'] = $seatCounter;

            // Generate label if not already set or if it needs regeneration
            $rowNum = $comp['origin_row'] ?? $comp['row'] ?? 0;
            $rowLetter = chr(64 + max(1, $rowNum)); // A-Z
            $comp['seat_id'] = $comp['seat_id'] ?? ($rowLetter . $seatCounter);
        }
        unset($comp);

        return $components;
    }

    /**
     * Validate snapshot for collision detection.
     *
     * Checks that no two components occupy overlapping grid cells.
     * Returns true if valid, throws on collision.
     */
    public function validateSnapshot(array $snapshot): bool
    {
        $components = $snapshot['components'] ?? $snapshot['grid'] ?? [];
        $occupied = [];

        foreach ($components as $comp) {
            $originRow = $comp['origin_row'] ?? $comp['row'] ?? 0;
            $originCol = $comp['origin_col'] ?? $comp['col'] ?? 0;
            $spanRows = $comp['span_rows'] ?? 1;
            $spanCols = $comp['span_cols'] ?? 1;

            for ($r = $originRow; $r < $originRow + $spanRows; $r++) {
                for ($c = $originCol; $c < $originCol + $spanCols; $c++) {
                    $key = "{$r},{$c}";
                    if (isset($occupied[$key])) {
                        throw new \RuntimeException(
                            "Collision detected at row {$r}, col {$c}: " .
                            "component '{$comp['id']}' overlaps with '{$occupied[$key]}'"
                        );
                    }
                    $occupied[$key] = $comp['id'] ?? 'unknown';
                }
            }
        }

        return true;
    }

    private function jsonDecode($value): mixed
    {
        if ($value === null || $value === '') {
            return null;
        }
        if (is_array($value) || is_object($value)) {
            return $value;
        }
        $decoded = json_decode($value, true);
        return $decoded ?? $value;
    }

    /**
     * Decode JSON snapshot columns on a collection of rows.
     */
    private function decodeSnapshots(array $rows): array
    {
        return array_map(function ($row) {
            $row = (array) $row;
            if (isset($row['current_snapshot'])) {
                $row['current_snapshot'] = $this->jsonDecode($row['current_snapshot']);
            }
            if (isset($row['raw_grid_json'])) {
                $row['raw_grid_json'] = $this->jsonDecode($row['raw_grid_json']);
            }
            return $row;
        }, $rows);
    }
}
