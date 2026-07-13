<?php

namespace App\Http\Controllers;

use App\Services\Transport\AbsoluteLayoutService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — ABSOLUTE LAYOUT CONTROLLER
 * =======================================
 *
 * Handles CRUD for the Absolute (Freeform) Bus Layout Engine.
 * All routes are under /api/v1/bus-owner/absolute-layouts/*
 * and scoped to the authenticated owner's global_identity_id.
 *
 * 100% isolated from the legacy BusOwnerController layout methods.
 */
class AbsoluteLayoutController extends Controller
{
    public function __construct(
        private ?AbsoluteLayoutService $service = null,
    ) {
        $this->service ??= app(AbsoluteLayoutService::class);
    }

    /** Resolve the authenticated owner's global_identity_id. */
    private function ownerIdentityId(Request $request): ?string
    {
        return $request->user()?->global_identity_id;
    }

    // ═══════════════════════════════════════════════════════════
    // LIST — GET /absolute-layouts
    // ═══════════════════════════════════════════════════════════

    public function index(Request $request): JsonResponse
    {
        $identityId = $this->ownerIdentityId($request);
        if (!$identityId) {
            return response()->json([
                'success' => false,
                'message' => 'No identity associated with this account.',
            ], 403);
        }

        // Fleet admin panel: scope by carrier_company_id instead of owner_identity_id
        $carrierCompanyId = $request->get('_carrier_company_id');

        $perPage = (int) ($request->query('per_page', 20));
        $result = $this->service->listLayouts($identityId, $perPage, $carrierCompanyId);

        return response()->json([
            'success' => true,
            'data' => $result['data'],
            'pagination' => $result['pagination'],
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // SHOW — GET /absolute-layouts/{id}
    // ═══════════════════════════════════════════════════════════

    public function show(Request $request, string $id): JsonResponse
    {
        $identityId = $this->ownerIdentityId($request);
        if (!$identityId) {
            return response()->json([
                'success' => false,
                'message' => 'No identity associated with this account.',
            ], 403);
        }

        $carrierCompanyId = $request->get('_carrier_company_id');
        $layout = $this->service->showLayout($id, $identityId, $carrierCompanyId);

        if (!$layout) {
            return response()->json([
                'success' => false,
                'message' => 'Layout not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $layout,
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // CREATE — POST /absolute-layouts
    // ═══════════════════════════════════════════════════════════

    public function store(Request $request): JsonResponse
    {
        $identityId = $this->ownerIdentityId($request);
        if (!$identityId) {
            return response()->json([
                'success' => false,
                'message' => 'No identity associated with this account.',
            ], 403);
        }

        $validated = $request->validate([
            'display_name' => 'sometimes|string|max:255',
            'deck_level' => 'sometimes|string|in:lower,upper',
            'canvas_width' => 'sometimes|integer|min:100|max:2000',
            'canvas_height' => 'sometimes|integer|min:100|max:5000',
            'current_snapshot' => 'sometimes|array',
            'canvas' => 'sometimes|array',
            'components' => 'sometimes|array',
            'metadata' => 'sometimes|array',
            'layout_status' => 'sometimes|string|in:draft,published',
        ]);

        // ── Accept flat frontend format: {canvas, components, metadata} ──
        // The Dart toSnapshot() sends data at top level; we must
        // construct current_snapshot from those fields so the
        // JSON column stores the full component graph.
        if (empty($validated['current_snapshot'])) {
            $canvas = $validated['canvas'] ?? [];
            $snapshot = [];
            if (!empty($canvas)) $snapshot['canvas'] = $canvas;
            if (!empty($validated['components'])) $snapshot['components'] = $validated['components'];
            if (!empty($validated['metadata'])) $snapshot['metadata'] = $validated['metadata'];
            if (!empty($snapshot)) $validated['current_snapshot'] = $snapshot;
        }

        // Extract canvas dimensions from canvas sub-object if provided
        $canvas = $validated['canvas'] ?? [];
        if (!empty($canvas)) {
            $validated['deck_level'] ??= $canvas['deck_level'] ?? 'lower';
            $validated['canvas_width'] ??= $canvas['canvas_width'] ?? 280;
            $validated['canvas_height'] ??= $canvas['canvas_height'] ?? 896;
        }

        // Fleet admin panel: attach carrier_company_id from middleware context
        $carrierCompanyId = $request->get('_carrier_company_id');
        if ($carrierCompanyId && \Illuminate\Support\Facades\Schema::hasColumn('absolute_bus_layouts', 'carrier_company_id')) {
            $validated['carrier_company_id'] = $carrierCompanyId;
        }

        $layout = $this->service->createLayout($identityId, $validated);

        return response()->json([
            'success' => true,
            'data' => $layout->toArray(),
            'message' => 'Absolute layout created successfully.',
        ], 201);
    }

    // ═══════════════════════════════════════════════════════════
    // UPDATE — PUT /absolute-layouts/{id}
    // ═══════════════════════════════════════════════════════════

    public function update(Request $request, string $id): JsonResponse
    {
        $identityId = $this->ownerIdentityId($request);
        if (!$identityId) {
            return response()->json([
                'success' => false,
                'message' => 'No identity associated with this account.',
            ], 403);
        }

        $validated = $request->validate([
            'display_name' => 'sometimes|string|max:255',
            'deck_level' => 'sometimes|string|in:lower,upper',
            'canvas_width' => 'sometimes|integer|min:100|max:2000',
            'canvas_height' => 'sometimes|integer|min:100|max:5000',
            'current_snapshot' => 'sometimes|array',
            'canvas' => 'sometimes|array',
            'components' => 'sometimes|array',
            'metadata' => 'sometimes|array',
            'layout_status' => 'sometimes|string|in:draft,published',
        ]);

        // ── Accept flat frontend format: {canvas, components, metadata} ──
        if (empty($validated['current_snapshot'])) {
            $canvas = $validated['canvas'] ?? [];
            $snapshot = [];
            if (!empty($canvas)) $snapshot['canvas'] = $canvas;
            if (!empty($validated['components'])) $snapshot['components'] = $validated['components'];
            if (!empty($validated['metadata'])) $snapshot['metadata'] = $validated['metadata'];
            if (!empty($snapshot)) $validated['current_snapshot'] = $snapshot;
        }

        $canvas = $validated['canvas'] ?? [];
        if (!empty($canvas)) {
            $validated['deck_level'] ??= $canvas['deck_level'] ?? 'lower';
            $validated['canvas_width'] ??= $canvas['canvas_width'] ?? 280;
            $validated['canvas_height'] ??= $canvas['canvas_height'] ?? 896;
        }

        $carrierCompanyId = $request->get('_carrier_company_id');
        $layout = $this->service->updateLayout($id, $identityId, $validated, $carrierCompanyId);

        if (!$layout) {
            return response()->json([
                'success' => false,
                'message' => 'Layout not found or access denied.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $layout->toArray(),
            'message' => 'Absolute layout updated successfully.',
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // DELETE — DELETE /absolute-layouts/{id}
    // ═══════════════════════════════════════════════════════════

    public function destroy(Request $request, string $id): JsonResponse
    {
        $identityId = $this->ownerIdentityId($request);
        if (!$identityId) {
            return response()->json([
                'success' => false,
                'message' => 'No identity associated with this account.',
            ], 403);
        }

        $carrierCompanyId = $request->get('_carrier_company_id');
        $deleted = $this->service->deleteLayout($id, $identityId, $carrierCompanyId);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Layout not found or access denied.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Absolute layout archived successfully.',
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // PUBLISH — POST /absolute-layouts/{id}/publish
    // ═══════════════════════════════════════════════════════════

    public function publish(Request $request, string $id): JsonResponse
    {
        $identityId = $this->ownerIdentityId($request);
        if (!$identityId) {
            return response()->json([
                'success' => false,
                'message' => 'No identity associated with this account.',
            ], 403);
        }

        $publisherId = $request->user()?->global_identity_id;
        $changeDescription = $request->input('change_description');
        $carrierCompanyId = $request->get('_carrier_company_id');

        $layout = $this->service->publishLayout(
            $id,
            $identityId,
            $publisherId,
            $changeDescription,
            $carrierCompanyId,
        );

        if (!$layout) {
            return response()->json([
                'success' => false,
                'message' => 'Layout not found or access denied.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $layout->toArray(),
            'message' => 'Absolute layout published (revision ' . $layout->version_number . ').',
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // LIST PUBLIC — GET /absolute-layouts/public
    // ═══════════════════════════════════════════════════════════

    /** List all published layouts (no auth). */
    public function listPublic(Request $request): JsonResponse
    {
        $perPage = (int) ($request->query('per_page', 20));
        $result = $this->service->listPublicLayouts($perPage);
        return response()->json([
            'success' => true,
            'data' => $result['data'],
            'pagination' => $result['pagination'],
        ]);
    }

    /** List published preset templates from sub-admins (no auth). */
    public function listPresets(): JsonResponse
    {
        // Only return templates created by sub-admins — NOT real vehicle data.
        $presets = \App\Models\Transport\AbsoluteBusLayout::where('absolute_bus_layouts.layout_status', 'published')
            ->where('absolute_bus_layouts.is_active', true)
            ->join('global_identities', 'absolute_bus_layouts.owner_identity_id', '=', 'global_identities.id')
            ->where('global_identities.identity_type', 'sub_admin')
            ->orderBy('absolute_bus_layouts.created_at', 'desc')
            ->limit(50)
            ->get(['absolute_bus_layouts.*'])
            ->map(fn($l) => [
                'id' => $l->id,
                'display_name' => $l->display_name,
                'deck_level' => $l->deck_level,
                'canvas_width' => $l->canvas_width,
                'canvas_height' => $l->canvas_height,
                'total_seats' => $l->totalSeats(),
                'total_components' => $l->totalComponents(),
            ]);
        return response()->json(['success' => true, 'data' => $presets]);
    }

    // ═══════════════════════════════════════════════════════════
    // SHOW PUBLIC — GET /absolute-layouts/{id}/public
    // ═══════════════════════════════════════════════════════════

    /**
     * Fetch a published layout without authentication.
     * Used by the Customer App (Module 8V) for guest-mode
     * seat-map browsing. Only returns layouts where
     * layout_status = 'published'. Booking still requires auth.
     */
    public function showPublic(Request $request, string $id): JsonResponse
    {
        $includeBookings = $request->query('include_bookings', 'false') === 'true';

        $layout = $this->service->showPublicLayout($id, $includeBookings);

        if (!$layout) {
            return response()->json([
                'success' => false,
                'message' => 'Layout not found or not published.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $layout,
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // PURGE ALL — DELETE /absolute-layouts/purge/all
    // ═══════════════════════════════════════════════════════════

    public function purgeAll(Request $request): JsonResponse
    {
        $identityId = $this->ownerIdentityId($request);
        if (!$identityId) {
            return response()->json([
                'success' => false,
                'message' => 'No identity associated with this account.',
            ], 403);
        }

        $carrierCompanyId = $request->get('_carrier_company_id');
        $count = $this->service->purgeAll($identityId, $carrierCompanyId);

        return response()->json([
            'success' => true,
            'message' => "Purged $count absolute layout(s).",
            'data' => ['deleted_count' => $count],
        ]);
    }
}
