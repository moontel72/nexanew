<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Wave 3 — TenantContextResolver (Section 10.10, Step 7)
 *
 * Defect F-8 Fix: Extracts tenant and owner context from request
 * headers, route parameters, or body before the authorization engine
 * evaluates the request.
 *
 * This prevents cross-tenant data leaks by ensuring every multi-tenant
 * route has an explicitly resolved target_owner_identity_id and
 * resource_type before reaching VendorAllowanceShield.
 *
 * Resolution priority:
 *   1. X-Target-Owner-Id / X-Carrier-Company-Id headers
 *   2. Route model bindings (e.g., /buses/{bus_id} → bus.owner_identity_id)
 *   3. Request body fields (target_owner_id, carrier_company_id)
 *   4. If unresolvable on a multi-tenant route → 400 Bad Request
 *
 * Bound into $request->attributes:
 *   - target_owner_identity_id  : UUID of the resource owner
 *   - carrier_company_id         : UUID of the requesting carrier
 *   - resource_type              : dotted resource path
 */
class TenantContextResolver
{
    /**
     * Known route prefixes that are multi-tenant (require context).
     */
    private const MULTI_TENANT_PREFIXES = [
        'api/v1/bus-fleet',
        'api/v1/goods-fleet',
        'api/v1/transport',
        'api/v1/fleet',
        'api/v1/seat',
        'api/v1/drivers',
    ];

    /**
     * Route-to-resource-type mapping.
     */
    private const RESOURCE_TYPE_MAP = [
        'bus'           => 'bus.fleet.vehicle',
        'buses'         => 'bus.fleet.vehicle',
        'bus-fleet'     => 'bus.fleet',
        'seat'          => 'bus.layouts.seat',
        'seat_layout'   => 'bus.layouts.seat',
        'driver'        => 'fleet.driver',
        'drivers'       => 'fleet.driver',
        'goods-fleet'   => 'truck.fleet',
        'truck'         => 'truck.fleet.vehicle',
        'layout'        => 'bus.layouts.grid',
        'layouts'       => 'bus.layouts.grid',
    ];

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $path = $request->path();

        // Skip for non-multi-tenant routes
        if (!$this->isMultiTenantRoute($path)) {
            return $next($request);
        }

        $targetOwnerId  = $this->resolveTargetOwnerId($request);
        $carrierCompanyId = $this->resolveCarrierCompanyId($request);
        $resourceType   = $this->resolveResourceType($path);

        // If context cannot be determined, abort immediately
        if (!$targetOwnerId || !$resourceType) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Tenant context unresolved. Provide X-Target-Owner-Id header or valid route binding.',
                'required' => [
                    'target_owner_identity_id' => 'UUID of the resource owner',
                    'resource_type'            => 'dotted path of the resource being accessed',
                ],
            ], 400);
        }

        // Bind context into request attributes for downstream middleware
        $request->attributes->set('target_owner_identity_id', $targetOwnerId);
        $request->attributes->set('carrier_company_id', $carrierCompanyId);
        $request->attributes->set('resource_type', $resourceType);

        return $next($request);
    }

    /**
     * Resolve target owner identity ID from multiple sources.
     *
     * Priority:
     *   1. X-Target-Owner-Id header (explicit)
     *   2. Route model binding (bus_id, driver_id, owner_id)
     *   3. Request body field
     */
    private function resolveTargetOwnerId(Request $request): ?string
    {
        // 1. Header
        $header = $request->header('X-Target-Owner-Id');
        if ($header && $this->isValidUuid($header)) {
            return $header;
        }

        // 2. Route model bindings
        $routeParams = ['bus_id', 'owner_id', 'driver_id', 'layout_id', 'vehicle_id'];
        foreach ($routeParams as $param) {
            $value = $request->route($param);
            if ($value) {
                // If it's a model instance, extract owner
                if (is_object($value)) {
                    $ownerId = $value->owner_identity_id
                        ?? $value->owner_id
                        ?? $value->global_identity_id
                        ?? null;
                    if ($ownerId) return (string) $ownerId;
                }
                if (is_string($value) && $this->isValidUuid($value)) {
                    // Try to resolve owner from the UUID in relevant tables
                    $ownerId = $this->resolveOwnerFromEntity($param, $value);
                    if ($ownerId) return $ownerId;
                }
            }
        }

        // 3. Request body
        $body = $request->input('target_owner_id')
            ?? $request->input('owner_id')
            ?? $request->input('owner_identity_id');
        if ($body && $this->isValidUuid($body)) {
            return $body;
        }

        return null;
    }

    /**
     * Resolve carrier company ID.
     */
    private function resolveCarrierCompanyId(Request $request): ?string
    {
        // 1. Header
        $header = $request->header('X-Carrier-Company-Id');
        if ($header && $this->isValidUuid($header)) {
            return $header;
        }

        // 2. Request body
        $body = $request->input('carrier_company_id');
        if ($body && $this->isValidUuid($body)) {
            return $body;
        }

        // 3. Resolve from authenticated user's active fleet assignment
        $user = $request->user();
        if ($user && !empty($user->global_identity_id)) {
            $assignment = \App\Models\FleetAssignment::where('global_identity_id', $user->global_identity_id)
                ->whereIn('status', ['active'])
                ->select('carrier_company_id')
                ->first();
            if ($assignment && $assignment->carrier_company_id) {
                return $assignment->carrier_company_id;
            }
        }

        return null;
    }

    /**
     * Determine resource type from the URL path.
     */
    private function resolveResourceType(string $path): ?string
    {
        $segments = explode('/', trim($path, '/'));

        foreach ($segments as $segment) {
            $normalized = strtolower(preg_replace('/[^a-z_-]/', '', $segment));
            foreach (self::RESOURCE_TYPE_MAP as $key => $type) {
                if ($normalized === $key || str_contains($normalized, $key)) {
                    return $type;
                }
            }
        }

        // Fallback: use the module prefix from URL
        if (count($segments) >= 2) {
            $prefix = $segments[0] . '.' . $segments[1];
            return $prefix;
        }

        return null;
    }

    /**
     * Check if the current route requires multi-tenant context.
     */
    private function isMultiTenantRoute(string $path): bool
    {
        foreach (self::MULTI_TENANT_PREFIXES as $prefix) {
            if (str_starts_with($path, $prefix)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Resolve the owner identity from an entity UUID.
     */
    private function resolveOwnerFromEntity(string $param, string $id): ?string
    {
        return match (true) {
            str_contains($param, 'bus') => \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->where('id', $id)->value('owner_identity_id'),
            str_contains($param, 'layout') => \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->where('id', $id)->value('owner_identity_id'),
            str_contains($param, 'driver') => \Illuminate\Support\Facades\DB::table('fleet_assignments')
                ->where('id', $id)->value('global_identity_id'),
            str_contains($param, 'owner') => $id, // owner_id IS the identity
            default => null,
        };
    }

    private function isValidUuid(string $value): bool
    {
        return (bool) preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $value);
    }
}
