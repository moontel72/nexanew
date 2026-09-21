<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

/**
 * Super-Admin authorisation — OBSERVATION MODE BY DEFAULT.
 *
 * WHY THIS EXISTS
 * ===============
 * `routes/panels/super_admin.php` is guarded by `auth:sanctum` alone, so every
 * one of its routes is reachable by *any* authenticated account — a customer, a
 * driver, a shopkeeper. `AdminMiddleware` exists and would close that, but it
 * could not simply be applied: for a super admin, tiers 1 and 2 cannot pass.
 *
 *   Tier 1  TenantAccount::isAdmin()  -> account_type === 'master_admin'
 *           GlobalAuthController::resolveTenantAccount() sets account_type to
 *           "{fleet_type}_{role}" when the identity has a fleet assignment, and
 *           to 'global_identity' otherwise. A super admin has no fleet
 *           assignment, so it is 'global_identity' — tier 1 fails.
 *
 *   Tier 2  $user->getAttribute('identity_type') === 'admin'
 *           $request->user() is a TenantAccount. `identity_type` is a
 *           GlobalIdentity column and is not in TenantAccount's fillable list,
 *           so this reads null — tier 2 fails.
 *
 *   Tier 3  a row in master_admin_assignments (or sub_admin_assignments) for the
 *           identity. This is the only tier that can pass, and whether the
 *           owner's account has that row is a database fact that could not be
 *           verified when this was written.
 *
 * Applying AdminMiddleware blind therefore risked returning 403 on every
 * super-admin call — taking down the most critical panel in the system. That is
 * not an acceptable way to fix an authorisation gap.
 *
 * WHAT THIS DOES
 * ==============
 * Runs the *same* decision, and:
 *   - logs what it decided, so the real grant state becomes observable;
 *   - lets the request through, so behaviour is unchanged — UNLESS
 *     SUPER_ADMIN_GATE_ENFORCE is set to a truthy value.
 *
 * So enforcement is a CONFIG change, not a code change, and the rollback is the
 * same single variable. The two SQL queries that settle it in advance are in
 * docs/handoff/PANEL-SEPARATION-PLAN.md §7b.4.
 *
 * HOW TO TURN IT ON
 * =================
 *   1. Read the log lines tagged `super_admin_gate.shadow`.
 *   2. Confirm the intended admin accounts appear as `authorised: true`
 *      (tier 1/2/3 named). If they show `authorised: false`, add the missing
 *      master_admin_assignments row first — do NOT enable enforcement yet.
 *   3. Set SUPER_ADMIN_GATE_ENFORCE=true.
 *   4. Once traffic is confirmed healthy, this middleware can be replaced by
 *      AdminMiddleware directly and kept as the enforcement point.
 */
class SuperAdminShadowGate
{
    /**
     * Truthy values accepted for SUPER_ADMIN_GATE_ENFORCE.
     *
     * Parsed explicitly rather than cast, because `(bool) "false"` is `true`
     * and a misread environment variable must never silently start denying
     * platform admins.
     */
    private const TRUTHY = ['1', 'true', 'on', 'yes'];

    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            // `auth:sanctum` already rejects this, so reaching here means the
            // guard is misconfigured. Never deny on our own account.
            $this->log(null, 'unauthenticated', false, $request);
            return $next($request);
        }

        [$authorised, $tier] = $this->decide($user);

        $this->log($user, $tier, $authorised, $request);

        if (!$authorised && $this->enforcing()) {
            return response()->json([
                'message' => 'Forbidden — not a system administrator',
            ], 403);
        }

        return $next($request);
    }

    /**
     * The same three-tier decision AdminMiddleware makes, returned as
     * `[$authorised, $tierLabel]` so the log can name which tier allowed it.
     *
     * @return array{0: bool, 1: string}
     */
    private function decide(object $user): array
    {
        // Tier 1 — TenantAccount.isAdmin() (account_type === 'master_admin').
        if (method_exists($user, 'isAdmin') && $user->isAdmin()) {
            return [true, 'tier1_account_type_master_admin'];
        }

        // Tier 2 — GlobalIdentity.identity_type === 'admin' and active.
        if (method_exists($user, 'getAttribute')
            && $user->getAttribute('identity_type') === 'admin'
            && $user->getAttribute('status') === 'active'
        ) {
            return [true, 'tier2_identity_type_admin'];
        }

        // Tier 3 — an active assignment row.
        $globalIdentityId = $user->global_identity_id ?? $user->id ?? null;

        if (!$globalIdentityId) {
            return [false, 'no_resolvable_global_identity_id'];
        }

        try {
            if (DB::table('master_admin_assignments')
                ->where('global_identity_id', $globalIdentityId)
                ->whereNull('revoked_at')
                ->exists()
            ) {
                return [true, 'tier3_master_admin_assignment'];
            }

            if (DB::table('sub_admin_assignments')
                ->where('global_identity_id', $globalIdentityId)
                ->whereNull('revoked_at')
                ->exists()
            ) {
                return [true, 'tier3_sub_admin_assignment'];
            }
        } catch (\Throwable $e) {
            // A database problem must not become an authorisation denial.
            return [false, 'tier3_query_failed:' . $e->getMessage()];
        }

        return [false, 'tier3_no_assignment'];
    }

    private function enforcing(): bool
    {
        $raw = env('SUPER_ADMIN_GATE_ENFORCE', 'false');

        return in_array(
            is_string($raw) ? strtolower(trim($raw)) : $raw,
            self::TRUTHY,
            true
        );
    }

    private function log(?object $user, string $tier, bool $authorised, Request $request): void
    {
        $context = [
            'decision' => $authorised ? 'authorised' : 'would_deny',
            'tier' => $tier,
            'enforcing' => $this->enforcing(),
            'method' => $request->method(),
            'path' => $request->path(),
            'user_class' => $user ? get_class($user) : null,
            'user_id' => $user->id ?? null,
            'global_identity_id' => $user->global_identity_id ?? null,
        ];

        if ($authorised) {
            Log::info('super_admin_gate.shadow', $context);
            return;
        }

        // A denial that would have been enforced is the line worth finding.
        if ($context['enforcing']) {
            Log::warning('super_admin_gate.shadow', $context);
        } else {
            Log::info('super_admin_gate.shadow', $context);
        }
    }
}
