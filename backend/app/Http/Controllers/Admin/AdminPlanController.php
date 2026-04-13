<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\SubscriptionPlanResource;
use App\Models\CompanySubscription;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AdminPlanController extends Controller
{
    public function index(Request $request)
    {
        $query = SubscriptionPlan::query();

        $search = (string) $request->query('search', '');
        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                    ->orWhere('description', 'ilike', "%{$search}%");
            });
        }

        if ($type = $request->query('type')) {
            $query->where('type', $type);
        }

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        $sortBy = (string) $request->query('sort_by', 'created_at');
        $sortOrder = strtolower((string) $request->query('sort_order', 'desc')) === 'asc' ? 'asc' : 'desc';
        if (!in_array($sortBy, ['created_at', 'updated_at', 'name', 'type', 'monthly_price', 'yearly_price'], true)) {
            $sortBy = 'created_at';
        }

        $query->orderBy($sortBy, $sortOrder);

        $page = (int) $request->query('page', 1);
        $limit = (int) $request->query('limit', 10);
        $limit = max(1, min(100, $limit));

        $paginator = $query->paginate($limit, ['*'], 'page', $page);

        $items = collect($paginator->items())
            ->map(fn ($p) => (new SubscriptionPlanResource($p))->toArray($request))
            ->all();

        return response()->json([
            'data' => $items,
            'total' => $paginator->total(),
            'page' => $paginator->currentPage(),
            'limit' => $paginator->perPage(),
            'total_pages' => $paginator->lastPage(),
        ]);
    }

    public function show(SubscriptionPlan $plan)
    {
        return response()->json(['success' => true, 'data' => new SubscriptionPlanResource($plan)]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'string', 'max:20'],
            'description' => ['nullable', 'string'],
            'monthly_price' => ['required', 'numeric', 'min:0'],
            'yearly_price' => ['nullable', 'numeric', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'status' => ['nullable', 'string'],
            'is_recommended' => ['nullable', 'boolean'],
            'features' => ['nullable', 'array'],
            'monthly_unit_codes' => ['nullable', 'integer', 'min:0'],
            'monthly_packet_codes' => ['nullable', 'integer', 'min:0'],
            'monthly_carton_codes' => ['nullable', 'integer', 'min:0'],
            'monthly_bundle_codes' => ['nullable', 'integer', 'min:0'],
            'max_users' => ['nullable', 'integer', 'min:0'],
            'max_stores' => ['nullable', 'integer', 'min:0'],
            'max_drivers' => ['nullable', 'integer', 'min:0'],
            'metadata' => ['nullable', 'array'],
        ]);

        $plan = SubscriptionPlan::query()->create([
            'id' => (string) Str::uuid(),
            'name' => $data['name'],
            'type' => $data['type'],
            'description' => $data['description'] ?? '',
            'monthly_price' => $data['monthly_price'],
            'yearly_price' => $data['yearly_price'] ?? 0,
            'currency' => $data['currency'] ?? 'USD',
            'status' => $data['status'] ?? 'active',
            'is_recommended' => $data['is_recommended'] ?? false,
            'features' => $data['features'] ?? [],
            'monthly_unit_codes' => $data['monthly_unit_codes'] ?? 0,
            'monthly_packet_codes' => $data['monthly_packet_codes'] ?? 0,
            'monthly_carton_codes' => $data['monthly_carton_codes'] ?? 0,
            'monthly_bundle_codes' => $data['monthly_bundle_codes'] ?? 0,
            'max_users' => $data['max_users'] ?? 1,
            'max_stores' => $data['max_stores'] ?? 1,
            'max_drivers' => $data['max_drivers'] ?? 1,
            'metadata' => $data['metadata'] ?? [],
        ]);

        return response()->json(['success' => true, 'data' => new SubscriptionPlanResource($plan)], 201);
    }

    public function update(Request $request, SubscriptionPlan $plan)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:100'],
            'type' => ['sometimes', 'string', 'max:20'],
            'description' => ['sometimes', 'nullable', 'string'],
            'monthly_price' => ['sometimes', 'numeric', 'min:0'],
            'yearly_price' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'currency' => ['sometimes', 'nullable', 'string', 'size:3'],
            'status' => ['sometimes', 'string'],
            'is_recommended' => ['sometimes', 'boolean'],
            'features' => ['sometimes', 'array'],
            'monthly_unit_codes' => ['sometimes', 'integer', 'min:0'],
            'monthly_packet_codes' => ['sometimes', 'integer', 'min:0'],
            'monthly_carton_codes' => ['sometimes', 'integer', 'min:0'],
            'monthly_bundle_codes' => ['sometimes', 'integer', 'min:0'],
            'max_users' => ['sometimes', 'integer', 'min:0'],
            'max_stores' => ['sometimes', 'integer', 'min:0'],
            'max_drivers' => ['sometimes', 'integer', 'min:0'],
            'metadata' => ['sometimes', 'array'],
        ]);

        $plan->fill($data);
        $plan->save();

        return response()->json(['success' => true, 'data' => new SubscriptionPlanResource($plan)]);
    }

    public function destroy(SubscriptionPlan $plan)
    {
        $plan->delete();
        return response()->json(['success' => true]);
    }

    public function getStatistics()
    {
        $totalPlans = SubscriptionPlan::query()->count();
        $activePlans = SubscriptionPlan::query()->where('status', 'active')->count();
        $companiesByPlan = CompanySubscription::query()
            ->selectRaw('plan_id, count(*) as companies')
            ->where('status', 'active')
            ->groupBy('plan_id')
            ->get()
            ->mapWithKeys(fn ($row) => [(string) $row->plan_id => (int) $row->companies])
            ->all();

        return response()->json([
            'success' => true,
            'data' => [
                'total_plans' => $totalPlans,
                'active_plans' => $activePlans,
                'companies_by_plan' => $companiesByPlan,
            ],
        ]);
    }

    public function getFeatures()
    {
        return response()->json([
            'success' => true,
            'data' => [],
        ]);
    }

    public function updateFeatures(Request $request, SubscriptionPlan $plan)
    {
        $data = $request->validate([
            'features' => ['required', 'array'],
        ]);

        $plan->features = $data['features'];
        $plan->save();

        return response()->json(['success' => true]);
    }

    public function duplicate(SubscriptionPlan $plan)
    {
        $copy = $plan->replicate();
        $copy->id = (string) Str::uuid();
        $copy->name = $plan->name . ' (Copy)';
        $copy->status = 'inactive';
        $copy->save();

        return response()->json(['success' => true, 'data' => new SubscriptionPlanResource($copy)]);
    }

    public function updateStatus(Request $request, SubscriptionPlan $plan)
    {
        $data = $request->validate([
            'status' => ['required', 'string', Rule::in(['active', 'inactive', 'archived'])],
        ]);

        $plan->status = $data['status'];
        $plan->save();

        return response()->json(['success' => true]);
    }

    public function export()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'download_url' => null,
            ],
        ]);
    }

    public function import()
    {
        return response()->json(['message' => 'Not implemented'], 501);
    }

    public function validatePlan(Request $request)
    {
        $request->validate([
            'name' => ['required', 'string'],
            'type' => ['required', 'string'],
            'monthly_price' => ['required', 'numeric', 'min:0'],
        ]);

        return response()->json(['success' => true, 'data' => ['valid' => true]]);
    }

    public function getPricing(SubscriptionPlan $plan)
    {
        return response()->json([
            'success' => true,
            'data' => [
                'monthly_price' => (float) ($plan->monthly_price ?? 0),
                'yearly_price' => (float) ($plan->yearly_price ?? 0),
                'currency' => (string) ($plan->currency ?? 'USD'),
                'setup_fee' => (float) ($plan->setup_fee ?? 0),
            ],
        ]);
    }

    public function updatePricing(Request $request, SubscriptionPlan $plan)
    {
        $data = $request->validate([
            'monthly_price' => ['sometimes', 'numeric', 'min:0'],
            'yearly_price' => ['sometimes', 'numeric', 'min:0'],
            'setup_fee' => ['sometimes', 'numeric', 'min:0'],
            'currency' => ['sometimes', 'string', 'size:3'],
        ]);

        $plan->fill($data)->save();

        return response()->json(['success' => true]);
    }

    public function usage(SubscriptionPlan $plan)
    {
        $active = CompanySubscription::query()->where('plan_id', $plan->id)->where('status', 'active')->count();
        return response()->json(['success' => true, 'data' => ['active_subscriptions' => $active]]);
    }

    public function companies(Request $request, SubscriptionPlan $plan)
    {
        $page = (int) $request->query('page', 1);
        $limit = (int) $request->query('limit', 10);
        $limit = max(1, min(100, $limit));

        $paginator = CompanySubscription::query()
            ->with('company')
            ->where('plan_id', $plan->id)
            ->where('status', 'active')
            ->paginate($limit, ['*'], 'page', $page);

        $items = collect($paginator->items())->map(function ($sub) {
            return [
                'subscription_id' => (string) $sub->id,
                'company_id' => (string) $sub->company_id,
                'company_name' => (string) ($sub->company?->name ?? ''),
                'billing_cycle' => (string) ($sub->billing_cycle ?? 'monthly'),
                'start_date' => optional($sub->start_date)->toISOString(),
                'end_date' => optional($sub->end_date)->toISOString(),
                'status' => (string) ($sub->status ?? 'active'),
            ];
        })->all();

        return response()->json([
            'success' => true,
            'data' => [
                'companies' => $items,
                'total' => $paginator->total(),
                'page' => $paginator->currentPage(),
                'limit' => $paginator->perPage(),
                'total_pages' => $paginator->lastPage(),
            ],
        ]);
    }
}
