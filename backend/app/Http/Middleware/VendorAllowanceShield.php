<?php

namespace App\Http\Middleware;

use App\Models\TenantAllowanceGrant;
use App\Services\AuditService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Wave 3 — Step 3.4: Vendor Allowance Shield Middleware
 *
 * Per Section 10.4.5 — Cross-tenant data exposure with deny-by-default.
 *
 * Five Mask Levels (Section 10.4.1):
 *   1. full      — Read & write, all columns
 *   2. view      — Read-only, all columns
 *   3. aggregate — Only counts/sums/averages, no row identifiers
 *   4. redacted  — PII columns masked (phone → ***, name → Customer #N)
 *   5. hidden    — Row not returned at all (deny-by-default)
 *
 * Algorithm:
 *   1. Resolve (viewer_identity_id, target_identity_id, resource_type)
 *   2. Single B-tree probe on tenant_allowance_grants
 *   3. If row missing or inactive → hidden (return 404 / empty set)
 *   4. Attach mask_level to request context
 *   5. Log probe to audit_log_security
 */
class VendorAllowanceShield
{
    public function __construct(
        private readonly AuditService $audit
    ) {}

    /**
     * Handle an incoming request.
     *
     * Reads target_owner_id and resource_type from request attributes
     * (set by upstream route binding or TenantContextResolver).
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if (!$user) {
            return $next($request);
        }

        // Resolve viewer identity from authenticated user
        $viewerIdentityId = $user->global_identity_id ?? null;
        if (!$viewerIdentityId) {
            return $next($request);
        }

        // Target owner and resource type must be set by route/controller
        $targetOwnerId  = $request->attributes->get('target_owner_identity_id');
        $resourceType   = $request->attributes->get('resource_type');

        if (!$targetOwnerId || !$resourceType) {
            // Not a cross-tenant request — pass through
            return $next($request);
        }

        // If viewer is the target owner, always full access
        if ($viewerIdentityId === $targetOwnerId) {
            $request->attributes->set('mask_level', 'full');
            return $next($request);
        }

        // Resolve carrier company from active fleet assignment
        $carrierCompanyId = $this->resolveCarrierCompany($viewerIdentityId);
        if (!$carrierCompanyId) {
            // No fleet assignment → deny
            $this->logProbe($request, $viewerIdentityId, $targetOwnerId, $resourceType, 'hidden', 'no_carrier');
            return response()->json(['status' => 'error', 'message' => 'Access denied.'], 404);
        }

        // B-tree probe on flat projection (Section 10.4.5 step 2)
        $maskLevel = TenantAllowanceGrant::resolveLevel(
            $targetOwnerId,
            $carrierCompanyId,
            $resourceType
        );

        // Log the probe
        $this->logProbe($request, $viewerIdentityId, $targetOwnerId, $resourceType, $maskLevel, 'probe');

        // Deny-by-default: hidden → 404
        if ($maskLevel === 'hidden') {
            return response()->json(['status' => 'error', 'message' => 'Access denied.'], 404);
        }

        // Attach mask level to request context for downstream use
        $request->attributes->set('mask_level', $maskLevel);

        return $next($request);
    }

    /**
     * Resolve the carrier company ID for a viewer identity.
     * Uses active fleet assignment.
     */
    private function resolveCarrierCompany(string $identityId): ?string
    {
        $assignment = \App\Models\FleetAssignment::where('global_identity_id', $identityId)
            ->whereIn('status', ['active'])
            ->select('carrier_company_id')
            ->first();

        return $assignment ? $assignment->carrier_company_id : null;
    }

    private function logProbe(
        Request $request,
        string $viewerId,
        string $targetId,
        string $resourceType,
        string $maskLevel,
        string $outcome
    ): void {
        try {
            $this->audit->emit('security', [
                'event_type'               => 'allowance.probe',
                'actor_global_identity_id' => $viewerId,
                'target_global_identity_id'=> $targetId,
                'ip_address'               => $request->ip(),
                'payload'                  => [
                    'resource_type'  => $resourceType,
                    'mask_level'     => $maskLevel,
                    'outcome'        => $outcome,
                    'route'          => $request->path(),
                ],
                'event_time' => now()->toIso8601String(),
            ]);
        } catch (\Exception $e) {
            report($e);
        }
    }
}
