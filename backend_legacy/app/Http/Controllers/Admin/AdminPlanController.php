<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use App\Models\PlanFeature;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class AdminPlanController extends Controller
{
    /**
     * Get all subscription plans
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        try {
            $perPage = $request->input('per_page', 20);
            $page = $request->input('page', 1);
            $search = $request->input('search', '');
            $type = $request->input('type', '');
            $status = $request->input('status', '');

            $query = SubscriptionPlan::with(['features']);

            // Apply search filter
            if (!empty($search)) {
                $query->where(function($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('description', 'like', "%{$search}%");
                });
            }

            // Apply type filter
            if (!empty($type)) {
                $query->where('type', $type);
            }

            // Apply status filter
            if (!empty($status)) {
                $query->where('status', $status);
            }

            // Apply sorting
            $sortBy = $request->input('sort_by', 'created_at');
            $sortOrder = $request->input('sort_order', 'desc');
            $query->orderBy($sortBy, $sortOrder);

            $plans = $query->paginate($perPage, ['*'], 'page', $page);

            return response()->json([
                'success' => true,
                'data' => [
                    'plans' => $plans->items(),
                    'pagination' => [
                        'total' => $plans->total(),
                        'per_page' => $plans->perPage(),
                        'current_page' => $plans->currentPage(),
                        'last_page' => $plans->lastPage(),
                        'from' => $plans->firstItem(),
                        'to' => $plans->lastItem(),
                    ],
                    'filters' => [
                        'search' => $search,
                        'type' => $type,
                        'status' => $status,
                        'sort_by' => $sortBy,
                        'sort_order' => $sortOrder,
                    ]
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch subscription plans',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get a specific subscription plan
     *
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(string $id)
    {
        try {
            $plan = SubscriptionPlan::with(['features'])->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => [
                    'plan' => $plan,
                    'feature_categories' => $this->getFeatureCategories(),
                    'available_features' => $this->getAvailableFeatures(),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Subscription plan not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Create a new subscription plan
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100|unique:subscription_plans,name',
            'type' => 'required|string|in:free,basic,standard,premium,custom',
            'description' => 'nullable|string|max:500',
            'price' => 'required|numeric|min:0',
            'billing_cycle' => 'required|string|in:monthly,quarterly,yearly,one_time',
            'currency' => 'required|string|size:3',
            'status' => 'required|string|in:active,inactive,draft',
            'is_featured' => 'boolean',
            'is_popular' => 'boolean',
            'sort_order' => 'integer|min:0',

            // Plan limits
            'limits.max_units_monthly' => 'required|integer|min:0',
            'limits.max_bundles_monthly' => 'required|integer|min:0',
            'limits.max_cartons_monthly' => 'required|integer|min:0',
            'limits.max_packets_monthly' => 'required|integer|min:0',
            'limits.max_products' => 'required|integer|min:0',
            'limits.max_stores' => 'required|integer|min:0',
            'limits.max_drivers' => 'required|integer|min:0',
            'limits.max_admin_users' => 'required|integer|min:0',
            'limits.max_store_keepers' => 'required|integer|min:0',

            // Features
            'features' => 'array',
            'features.*.id' => 'required|string|exists:plan_features,id',
            'features.*.is_enabled' => 'boolean',
            'features.*.limit' => 'nullable|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            // Create the plan
            $plan = SubscriptionPlan::create([
                'name' => $request->name,
                'type' => $request->type,
                'description' => $request->description,
                'price' => $request->price,
                'billing_cycle' => $request->billing_cycle,
                'currency' => $request->currency,
                'status' => $request->status,
                'is_featured' => $request->boolean('is_featured'),
                'is_popular' => $request->boolean('is_popular'),
                'sort_order' => $request->input('sort_order', 0),
                'limits' => $request->limits,
                'metadata' => $request->input('metadata', []),
            ]);

            // Attach features
            if ($request->has('features')) {
                foreach ($request->features as $feature) {
                    $plan->features()->attach($feature['id'], [
                        'is_enabled' => $feature['is_enabled'] ?? true,
                        'limit' => $feature['limit'] ?? null,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Subscription plan created successfully',
                'data' => [
                    'plan' => $plan->load('features')
                ]
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create subscription plan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update a subscription plan
     *
     * @param Request $request
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, string $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:100|unique:subscription_plans,name,' . $id,
            'type' => 'sometimes|required|string|in:free,basic,standard,premium,custom',
            'description' => 'nullable|string|max:500',
            'price' => 'sometimes|required|numeric|min:0',
            'billing_cycle' => 'sometimes|required|string|in:monthly,quarterly,yearly,one_time',
            'currency' => 'sometimes|required|string|size:3',
            'status' => 'sometimes|required|string|in:active,inactive,draft',
            'is_featured' => 'boolean',
            'is_popular' => 'boolean',
            'sort_order' => 'integer|min:0',

            // Plan limits
            'limits.max_units_monthly' => 'sometimes|required|integer|min:0',
            'limits.max_bundles_monthly' => 'sometimes|required|integer|min:0',
            'limits.max_cartons_monthly' => 'sometimes|required|integer|min:0',
            'limits.max_packets_monthly' => 'sometimes|required|integer|min:0',
            'limits.max_products' => 'sometimes|required|integer|min:0',
            'limits.max_stores' => 'sometimes|required|integer|min:0',
            'limits.max_drivers' => 'sometimes|required|integer|min:0',
            'limits.max_admin_users' => 'sometimes|required|integer|min:0',
            'limits.max_store_keepers' => 'sometimes|required|integer|min:0',

            // Features
            'features' => 'array',
            'features.*.id' => 'required|string|exists:plan_features,id',
            'features.*.is_enabled' => 'boolean',
            'features.*.limit' => 'nullable|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            $plan = SubscriptionPlan::findOrFail($id);

            // Update plan attributes
            $updateData = [];
            $fillable = [
                'name', 'type', 'description', 'price', 'billing_cycle',
                'currency', 'status', 'is_featured', 'is_popular',
                'sort_order', 'limits', 'metadata'
            ];

            foreach ($fillable as $field) {
                if ($request->has($field)) {
                    if ($field === 'is_featured' || $field === 'is_popular') {
                        $updateData[$field] = $request->boolean($field);
                    } elseif ($field === 'limits' || $field === 'metadata') {
                        $updateData[$field] = $request->input($field, []);
                    } else {
                        $updateData[$field] = $request->input($field);
                    }
                }
            }

            $plan->update($updateData);

            // Update features if provided
            if ($request->has('features')) {
                // Detach all existing features
                $plan->features()->detach();

                // Attach new features
                foreach ($request->features as $feature) {
                    $plan->features()->attach($feature['id'], [
                        'is_enabled' => $feature['is_enabled'] ?? true,
                        'limit' => $feature['limit'] ?? null,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Subscription plan updated successfully',
                'data' => [
                    'plan' => $plan->load('features')
                ]
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to update subscription plan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete a subscription plan
     *
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(string $id)
    {
        DB::beginTransaction();

        try {
            $plan = SubscriptionPlan::findOrFail($id);

            // Check if plan is being used by any company
            $usageCount = $plan->companies()->count();
            if ($usageCount > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot delete plan. It is currently being used by ' . $usageCount . ' companies.',
                    'data' => [
                        'usage_count' => $usageCount,
                        'companies' => $plan->companies()->limit(5)->pluck('name')
                    ]
                ], 400);
            }

            // Detach all features first
            $plan->features()->detach();

            // Delete the plan
            $plan->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Subscription plan deleted successfully'
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete subscription plan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Duplicate a subscription plan
     *
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function duplicate(string $id)
    {
        DB::beginTransaction();

        try {
            $originalPlan = SubscriptionPlan::with('features')->findOrFail($id);

            // Create duplicate plan
            $duplicatePlan = $originalPlan->replicate();
            $duplicatePlan->name = $originalPlan->name . ' (Copy)';
            $duplicatePlan->status = 'draft';
            $duplicatePlan->created_at = now();
            $duplicatePlan->updated_at = now();
            $duplicatePlan->save();

            // Duplicate features
            foreach ($originalPlan->features as $feature) {
                $duplicatePlan->features()->attach($feature->id, [
                    'is_enabled' => $feature->pivot->is_enabled,
                    'limit' => $feature->pivot->limit,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Subscription plan duplicated successfully',
                'data' => [
                    'plan' => $duplicatePlan->load('features')
                ]
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to duplicate subscription plan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get plan statistics
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function statistics()
    {
        try {
            $totalPlans = SubscriptionPlan::count();
            $activePlans = SubscriptionPlan::where('status', 'active')->count();
            $draftPlans = SubscriptionPlan::where('status', 'draft')->count();
            $inactivePlans = SubscriptionPlan::where('status', 'inactive')->count();

            // Plan distribution by type
            $planTypes = SubscriptionPlan::select('type', DB::raw('count(*) as count'))
                ->groupBy('type')
                ->get()
                ->pluck('count', 'type')
                ->toArray();

            // Featured plans
            $featuredPlans = SubscriptionPlan::where('is_featured', true)
                ->where('status', 'active')
                ->count();

            // Popular plans
            $popularPlans = SubscriptionPlan::where('is_popular', true)
                ->where('status', 'active')
                ->count();

            // Plans with most companies
            $topPlans = SubscriptionPlan::withCount('companies')
                ->orderBy('companies_count', 'desc')
                ->limit(5)
                ->get()
                ->map(function($plan) {
                    return [
                        'id' => $plan->id,
                        'name' => $plan->name,
                        'type' => $plan->type,
                        'company_count' => $plan->companies_count,
                        'price' => $plan->price,
                    ];
                })
                ->toArray();

            return response()->json([
                'success' => true,
                'data' => [
                    'total_plans' => $totalPlans,
                    'active_plans' => $activePlans,
                    'draft_plans' => $draftPlans,
                    'inactive_plans' => $inactivePlans,
                    'plan_types' => $planTypes,
                    'featured_plans' => $featuredPlans,
                    'popular_plans' => $popularPlans,
                    'top_plans' => $topPlans,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch plan statistics',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get available plan features
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function features()
    {
        try {
            $features = PlanFeature::all()->groupBy('category');

            return response()->json([
                'success' => true,
                'data' => [
                    'features' => $features,
                    'categories' => $this->getFeatureCategories(),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch plan features',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get feature categories
     *
     * @return array
     */
    private function getFeatureCategories(): array
    {
        return [
            'core' => 'Core Features',
            'advanced' => 'Advanced Features',
            'enterprise' => 'Enterprise Features',
            'custom' => 'Custom Features',
            'integration' => 'Integrations',
            'support' => 'Support',
        ];
    }

    /**
     * Get available features
     *
     * @return array
     */
    private function get
