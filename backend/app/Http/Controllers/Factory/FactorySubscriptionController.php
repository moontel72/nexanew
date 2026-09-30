<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\CompanySubscription;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * The calling factory's REAL subscription limits.
 *
 * WHY THIS EXISTS (MASTER-TASK-LIST.md item 9, owner-approved)
 * ------------------------------------------------------------
 * The factory dashboard's Transport tab was driven by a hardcoded
 * `const limits = PlanLimitModel(maxLoadsPerMonth: 5, ...)` in Flutter, so every
 * factory saw the same transport features no matter what it actually pays for.
 * The only limits endpoint that existed was `/api/v1/admin/plans/limits`
 * (Super-Admin side), which a factory cannot call.
 *
 * This endpoint answers one question for the logged-in factory: "what does MY
 * plan entitle me to?" — read from the factory's active CompanySubscription →
 * SubscriptionPlan. No plan (or no active subscription) returns the free/empty
 * set, which gates the Transport tab off.
 *
 * WHERE THE NUMBERS COME FROM — the plan metadata is written in TWO shapes and
 * both must be honoured, because two different writers own it:
 *   * the seeder (NexaBootstrapSeeder) writes NESTED `metadata.transport`
 *     (level, connections_per_month, loads_posting_per_month, ...);
 *   * the Super Admin plan editor (plans_list / plan_detail / create_plan)
 *     writes FLAT `metadata.transport_connections_per_month` and
 *     `metadata.max_loads_per_month`.
 * The nested value wins when both exist, otherwise the flat one is used.
 */
class FactorySubscriptionController extends Controller
{
    /**
     * GET /api/v1/factory/subscription/limits
     */
    public function limits(Request $request): JsonResponse
    {
        $companyId = $this->resolveCompanyId();

        $subscription = $companyId
            ? CompanySubscription::query()
                ->with('plan')
                ->where('company_id', $companyId)
                ->where('status', 'active')
                ->orderByDesc('start_date')
                ->first()
            : null;

        $plan = $subscription?->plan;
        $metadata = is_array($plan?->metadata) ? $plan->metadata : [];
        $transport = is_array($metadata['transport'] ?? null) ? $metadata['transport'] : [];

        $enabled = (bool) ($transport['enabled'] ?? false);
        $level = (string) ($transport['level'] ?? ($enabled ? 'full' : 'none'));

        // 'limited' is the entry transport tier: it grants direct driver contact but
        // not the owner/goods-company marketplaces. Everything above it grants all
        // three. An explicit flag on the plan always wins over this fallback.
        $isBroad = in_array($level, ['full', 'premium', 'enterprise'], true);

        $canContactDrivers = (bool) ($transport['can_contact_drivers_directly'] ?? $enabled);
        $canContactOwners = (bool) ($transport['can_contact_owners_directly'] ?? ($enabled && $isBroad));
        $canUseGoodsCompanies = (bool) ($transport['can_use_goods_companies'] ?? ($enabled && $isBroad));

        $maxLoadsPerMonth = (int) (
            $transport['loads_posting_per_month']
            ?? $metadata['max_loads_per_month']
            ?? 0
        );
        $connectionsPerMonth = (int) (
            $transport['connections_per_month']
            ?? $metadata['transport_connections_per_month']
            ?? 0
        );

        return response()->json([
            'success' => true,
            'data' => [
                'plan_id' => $plan?->id,
                'plan_name' => $plan?->name,
                'plan_type' => $plan?->type,
                'subscription_status' => $subscription?->status,
                'transport_enabled' => $enabled,
                'transport_level' => $level,
                'can_contact_drivers_directly' => $canContactDrivers,
                'can_contact_owners_directly' => $canContactOwners,
                'can_use_goods_companies' => $canUseGoodsCompanies,
                'max_loads_per_month' => $maxLoadsPerMonth,
                'transport_connections_per_month' => $connectionsPerMonth,
            ],
        ]);
    }

    /**
     * The authenticated factory's company id. Same resolution the billing
     * controller uses, so the two always agree on which factory is calling.
     */
    private function resolveCompanyId(): ?string
    {
        $user = Auth::user();

        if ($user instanceof \App\Models\FactoryUser) {
            return $user->company_id;
        }

        // Admin impersonating a factory (testing/debugging only) — same escape
        // hatch FactoryBillingController allows.
        if ($user instanceof \App\Models\AdminUser && request()->filled('factory_id')) {
            return (string) request()->input('factory_id');
        }

        return null;
    }
}
