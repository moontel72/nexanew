<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\FleetAssignment;
use App\Models\GlobalIdentity;
use App\Models\IdentityClaim;
use App\Models\TenantAccount;
use App\Services\AuditService;
use App\Services\ConfigurationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Wave 2 — Unified Global Authentication API (Section 10.1.5)
 *
 * Replaces all legacy /bus-fleet/*, /goods-fleet/* login gates.
 * Accepts ANY valid, unrevoked identifier claim (phone, email, CNIC, etc.),
 * resolves it to the global_identities spine, and authenticates.
 *
 * Login Resolution Algorithm (Section 10.1.5):
 *   1. User enters any identifier (phone / email / CNIC / passport).
 *   2. Backend normalizes and computes claim_value_hash.
 *   3. Lookup identity_claims WHERE is_revoked = FALSE -> global_identity_id.
 *   4. Verify password / OTP / biometric challenge.
 *   5. Token payload includes: sub=global_identity_id, claim_id,
 *      feature_grants_version, tenant_context array.
 *
 * FIXED Defect #1: Token name now embeds v{grantsVersion}: prefix so
 * TokenVersionGuard can parse it. Defect #4: Uses dedicated
 * global_identity_id column. Defect #5: Raw arrays, no double json_encode.
 *
 * Endpoints:
 *   POST /api/v1/auth/login    — Unified login
 *   POST /api/v1/auth/refresh  — Token refresh (handles token_stale)
 *   POST /api/v1/auth/logout   — Token revocation
 *   GET  /api/v1/auth/me       — Current identity + assignments
 */
class GlobalAuthController extends Controller
{
    /**
     * Unified login — accepts any claim type.
     */
    public function login(Request $request, AuditService $audit, ConfigurationService $config): JsonResponse
    {
        $validated = $request->validate([
            'identifier' => ['required', 'string', 'max:255'],
            'claim_type' => ['nullable', 'string', 'in:phone,email,cnic_old,cnic_new,passport,driving_license,device_fingerprint'],
            'password'   => ['required', 'string'],
            'fleet_role' => ['nullable', 'string', 'in:owner,driver,conductor,customer,store_keeper'],
            'fleet_type' => ['nullable', 'string', 'in:bus,truck,factory'],
        ]);

        $identifier = trim($validated['identifier']);
        $password   = $validated['password'];
        $fleetRole  = $validated['fleet_role'] ?? null;
        $fleetType  = $validated['fleet_type'] ?? null;

        // 1. Auto-detect claim_type if not provided
        $claimType = $validated['claim_type'] ?? $this->detectClaimType($identifier);
        if (!$claimType) {
            return response()->json(['status' => 'error', 'message' => 'Unable to determine identifier type. Please specify claim_type.'], 422);
        }

        // 2. Normalize
        $normalized = IdentityClaim::normalize($claimType, $identifier);

        // 3. Lookup active claim
        $claim = IdentityClaim::where('claim_type', $claimType)
            ->where('claim_value', $normalized)
            ->where('is_revoked', false)
            ->first();

        if (!$claim) {
            $this->logFailure($audit, $request, $claimType, $normalized, null, 'claim_not_found');
            return response()->json(['status' => 'error', 'message' => 'Invalid credentials.'], 401);
        }

        // 4. Resolve to spine
        $identity = GlobalIdentity::find($claim->global_identity_id);
        if (!$identity) {
            $this->logFailure($audit, $request, $claimType, $normalized, null, 'spine_not_found');
            return response()->json(['status' => 'error', 'message' => 'Identity record not found.'], 500);
        }

        // 5. Status gate
        if (!$identity->isActive()) {
            $this->logFailure($audit, $request, $claimType, $normalized, $identity->id, "status_{$identity->status}");
            $msg = match ($identity->status) {
                'suspended' => 'Account suspended. Contact your administrator.',
                'frozen'    => 'Account frozen pending review. Contact support.',
                'deleted'   => 'Account has been deactivated.',
                default     => 'Account is not active.',
            };
            return response()->json(['status' => 'error', 'message' => $msg], 403);
        }

        // 6. Password verification
        if (!$identity->verifyPassword($password)) {
            $this->logFailure($audit, $request, $claimType, $normalized, $identity->id, 'password_mismatch');
            return response()->json(['status' => 'error', 'message' => 'Invalid credentials.'], 401);
        }

        // 7. Fleet assignment validation
        $assignment = null;
        if ($fleetRole) {
            $query = FleetAssignment::where('global_identity_id', $identity->id)
                ->where('role', $fleetRole)
                ->whereIn('status', ['active', 'pending_acceptance']);

            if ($fleetType) {
                $query->where('fleet_type', $fleetType);
            }

            $assignment = $query->first();

            if (!$assignment) {
                $this->logFailure($audit, $request, $claimType, $normalized, $identity->id, 'no_active_assignment');
                return response()->json(['status' => 'error', 'message' => "No active {$fleetRole} assignment found for your account."], 403);
            }

            if ($assignment->isPendingAcceptance()) {
                $assignment->accept();
                $assignment->refresh();
            }
        }

        // 8. Fetch grants version BEFORE token creation (Defect #1 fix)
        $grantsVersion = $config->currentVersion();

        // 9. Create or resolve TenantAccount bridge
        $tenantAccount = $this->resolveTenantAccount($identity, $claim, $assignment);

        // 10. Create Sanctum token with v{version}: prefix (Defect #1 fix)
        $tokenName = 'v' . $grantsVersion . ':' . ($fleetRole
            ? "fleet-{$fleetRole}-" . Str::random(8)
            : 'global-auth-' . Str::random(8));

        $token = $tenantAccount->createToken($tokenName)->plainTextToken;

        // 11. Audit success — raw array, no double json_encode (Defect #5 fix)
        $audit->emit('security', [
            'event_type'               => 'login.success',
            'actor_global_identity_id' => $identity->id,
            'target_global_identity_id'=> $identity->id,
            'claim_type'               => $claimType,
            'claim_id'                 => $claim->id,
            'ip_address'               => $request->ip(),
            'user_agent'               => substr((string) $request->userAgent(), 0, 500),
            'payload'                  => [
                'fleet_role'     => $fleetRole,
                'fleet_type'     => $fleetType,
                'assignment_id'  => $assignment?->id,
                'grants_version' => $grantsVersion,
            ],
            'event_time' => now()->toIso8601String(),
        ]);

        // 12. Response
        return response()->json([
            'status' => 'success',
            'token'  => $token,
            'data'   => [
                'global_identity_id' => $identity->id,
                'identity_token'     => $identity->identity_token,
                'display_name'       => $identity->display_name,
                'identity_type'      => $identity->identity_type,
                'sub_admin_vertical' => $this->resolveSubAdminVertical($identity->id),
                'kyc_tier'           => $identity->kyc_tier,
                'kyc_status'         => $identity->kyc_status,
                'claim_id'           => $claim->id,
                'claim_type'         => $claimType,
                'claim_value'        => $normalized,
                'grants_version'     => $grantsVersion,
                'assignment'         => $assignment ? [
                    'id'                 => $assignment->id,
                    'role'               => $assignment->role,
                    'fleet_type'         => $assignment->fleet_type,
                    'status'             => $assignment->status,
                    'carrier_company_id' => $assignment->carrier_company_id,
                ] : null,
                'tenant_account_id'   => $tenantAccount->id,
            ],
        ]);
    }

    /**
     * Refresh token with fresh grants_version.
     * Called by Flutter TokenVersionGuard interceptor on 401 token_stale.
     */
    public function refresh(Request $request, ConfigurationService $config): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
        }

        $request->user()->currentAccessToken()?->delete();

        // Defect #1 fix: embed version in token name
        $grantsVersion = $config->currentVersion();
        $newToken = $user->createToken("v{$grantsVersion}:auth-refresh")->plainTextToken;

        return response()->json([
            'status'         => 'success',
            'token'          => $newToken,
            'grants_version' => $grantsVersion,
        ]);
    }

    /**
     * Logout — revoke current token.
     */
    public function logout(Request $request, AuditService $audit): JsonResponse
    {
        $user = $request->user();
        // Defect #4 fix: use dedicated global_identity_id column
        $identityId = $user->global_identity_id ?? null;

        $request->user()->currentAccessToken()?->delete();

        if ($identityId) {
            $audit->emit('security', [
                'event_type'               => 'logout.success',
                'actor_global_identity_id' => $identityId,
                'ip_address'               => $request->ip(),
                'payload'                  => ['method' => 'user_initiated'], // Defect #5 fix: raw array
                'event_time'               => now()->toIso8601String(),
            ]);
        }

        return response()->json(['status' => 'success', 'message' => 'Logged out.']);
    }

    /**
     * Me — profile + active assignments.
     */
    public function me(Request $request): JsonResponse
    {
        $tenantAccount = $request->user();
        if (!$tenantAccount) {
            return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
        }

        // Defect #4 fix: use dedicated global_identity_id column
        $identity = GlobalIdentity::find($tenantAccount->global_identity_id);
        if (!$identity) {
            return response()->json(['status' => 'error', 'message' => 'Identity not resolved.'], 404);
        }

        $assignments = FleetAssignment::where('global_identity_id', $identity->id)
            ->whereIn('status', ['active', 'pending_acceptance'])
            ->get()
            ->map(fn (FleetAssignment $a) => [
                'id'                 => $a->id,
                'role'               => $a->role,
                'fleet_type'         => $a->fleet_type,
                'status'             => $a->status,
                'carrier_company_id' => $a->carrier_company_id,
                'accepted_at'        => $a->accepted_at?->toIso8601String(),
            ]);

        return response()->json([
            'status' => 'success',
            'data'   => [
                'global_identity_id' => $identity->id,
                'identity_token'     => $identity->identity_token,
                'display_name'       => $identity->display_name,
                'identity_type'      => $identity->identity_type,
                'kyc_status'         => $identity->kyc_status,
                'kyc_tier'           => $identity->kyc_tier,
                'status'             => $identity->status,
                'active_assignments' => $assignments,
            ],
        ]);
    }

    // ================================================================
    //  PRIVATE HELPERS
    // ================================================================

    private function detectClaimType(string $identifier): ?string
    {
        if (filter_var($identifier, FILTER_VALIDATE_EMAIL)) {
            return 'email';
        }
        $digits = preg_replace('/[^0-9+]/', '', $identifier);
        if (preg_match('/^\+?[0-9]{10,15}$/', $digits)) {
            return 'phone';
        }
        if (preg_match('/^[0-9]{13}$/', $digits)) {
            return 'cnic_old';
        }
        if (preg_match('/^[0-9]{5}-[0-9]{7}-[0-9]$/', $identifier)) {
            return 'cnic_new';
        }
        if (preg_match('/^[A-Za-z0-9]{6,9}$/', strtoupper($identifier))) {
            return 'passport';
        }
        return null;
    }

    /**
     * Resolve or create a TenantAccount bridge for Sanctum token issuance.
     *
     * Defect #4 fix: Uses dedicated global_identity_id column instead of
     * overloading parent_account_id. parent_account_id remains exclusively
     * for self-referential tenant hierarchy.
     */
    private function resolveTenantAccount(
        GlobalIdentity $identity,
        IdentityClaim $claim,
        ?FleetAssignment $assignment
    ): TenantAccount {
        $tenant = null;

        if ($claim->claim_type === 'email') {
            $tenant = TenantAccount::where('email', $claim->claim_value)->first();
        }
        if (!$tenant && $claim->claim_type === 'phone') {
            $tenant = TenantAccount::where('phone_number', $claim->claim_value)->first();
        }

        if ($tenant) {
            if ($tenant->global_identity_id !== $identity->id) {
                $tenant->update(['global_identity_id' => $identity->id]);
            }
            return $tenant;
        }

        $email = ($claim->claim_type === 'email')
            ? $claim->claim_value
            : ($claim->claim_value . '@identity.local');

        return TenantAccount::create([
            'account_name'        => $identity->display_name,
            'email'               => $email,
            'password'            => $identity->password_hash ?? Hash::make(Str::random(32)),
            'phone_number'        => $claim->claim_type === 'phone' ? $claim->claim_value : null,
            'global_identity_id'  => $identity->id,          // Defect #4 fix: dedicated column
            'is_independent'      => false,
            'account_type'        => $assignment
                ? ($assignment->fleet_type . '_' . $assignment->role)
                : 'global_identity',
            'status'              => 'active',
        ]);
    }

    /**
     * Dynamically resolve the sub-admin's active vertical code.
     * Queries sub_admin_assignments JOIN sub_admin_verticals.
     * Returns null if identity is not a sub-admin or has no active vertical.
     */
    private function resolveSubAdminVertical(string $globalIdentityId): ?string
    {
        return \Illuminate\Support\Facades\DB::table('sub_admin_assignments')
            ->join('sub_admin_verticals', 'sub_admin_assignments.vertical_id', '=', 'sub_admin_verticals.id')
            ->where('sub_admin_assignments.global_identity_id', $globalIdentityId)
            ->whereNull('sub_admin_assignments.revoked_at')
            ->value('sub_admin_verticals.code');
    }

    private function logFailure(
        AuditService $audit,
        Request $request,
        string $claimType,
        string $normalized,
        ?string $identityId,
        string $reason
    ): void {
        try {
            $audit->emit('security', [
                'event_type'                => 'login.failed',
                'actor_global_identity_id'  => $identityId ?? '00000000-0000-0000-0000-000000000000',
                'target_global_identity_id' => $identityId,
                'claim_type'                => $claimType,
                'ip_address'                => $request->ip(),
                'user_agent'                => substr((string) $request->userAgent(), 0, 500),
                'payload'                   => [                          // Defect #5 fix: raw array
                    'claim_value_masked'     => substr($normalized, 0, 3) . '***',
                    'fail_reason'            => $reason,
                ],
                'event_time' => now()->toIso8601String(),
            ]);
        } catch (\Exception $e) {
            report($e);
        }
    }
}
