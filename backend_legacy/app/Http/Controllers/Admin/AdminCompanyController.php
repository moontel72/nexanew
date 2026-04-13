<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\CompanyDocument;
use App\Models\SubscriptionPlan;
use App\Models\Subscription;
use App\Models\Invoice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Carbon\Carbon;

class AdminCompanyController extends Controller
{
    /**
     * Get all companies
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
            $status = $request->input('status', '');
            $verificationStatus = $request->input('verification_status', '');
            $country = $request->input('country', '');
            $planType = $request->input('plan_type', '');
            $sortBy = $request->input('sort_by', 'created_at');
            $sortOrder = $request->input('sort_order', 'desc');

            $query = Company::with(['currentPlan', 'documents', 'subscriptions'])
                ->withCount(['users', 'activeSubscriptions']);

            // Apply search filter
            if (!empty($search)) {
                $query->where(function($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%")
                      ->orWhere('business_registration_number', 'like', "%{$search}%")
                      ->orWhere('contact_person_name', 'like', "%{$search}%")
                      ->orWhere('contact_person_email', 'like', "%{$search}%");
                });
            }

            // Apply status filter
            if (!empty($status)) {
                $query->where('status', $status);
            }

            // Apply verification status filter
            if (!empty($verificationStatus)) {
                $query->where('verification_status', $verificationStatus);
            }

            // Apply country filter
            if (!empty($country)) {
                $query->where('country', $country);
            }

            // Apply plan type filter
            if (!empty($planType)) {
                $query->whereHas('currentPlan', function($q) use ($planType) {
                    $q->where('type', $planType);
                });
            }

            // Apply sorting
            $query->orderBy($sortBy, $sortOrder);

            $companies = $query->paginate($perPage, ['*'], 'page', $page);

            // Get filter options
            $filterOptions = [
                'status_options' => $this->getStatusOptions(),
                'verification_status_options' => $this->getVerificationStatusOptions(),
                'country_options' => $this->getCountryOptions(),
                'plan_type_options' => $this->getPlanTypeOptions(),
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'companies' => $companies->items(),
                    'pagination' => [
                        'total' => $companies->total(),
                        'per_page' => $companies->perPage(),
                        'current_page' => $companies->currentPage(),
                        'last_page' => $companies->lastPage(),
                        'from' => $companies->firstItem(),
                        'to' => $companies->lastItem(),
                    ],
                    'filters' => [
                        'search' => $search,
                        'status' => $status,
                        'verification_status' => $verificationStatus,
                        'country' => $country,
                        'plan_type' => $planType,
                        'sort_by' => $sortBy,
                        'sort_order' => $sortOrder,
                    ],
                    'filter_options' => $filterOptions,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch companies',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get a specific company
     *
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(string $id)
    {
        try {
            $company = Company::with([
                'currentPlan',
                'documents',
                'subscriptions' => function($query) {
                    $query->orderBy('created_at', 'desc');
                },
                'subscriptions.plan',
                'invoices' => function($query) {
                    $query->orderBy('created_at', 'desc')->limit(10);
                },
                'users' => function($query) {
                    $query->orderBy('created_at', 'desc')->limit(10);
                },
            ])
            ->withCount(['users', 'activeSubscriptions', 'invoices'])
            ->findOrFail($id);

            // Get usage statistics
            $usageStats = $this->getCompanyUsageStats($id);

            // Get available plans for assignment
            $availablePlans = SubscriptionPlan::where('status', 'active')->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'company' => $company,
                    'usage_stats' => $usageStats,
                    'available_plans' => $availablePlans,
                    'status_options' => $this->getStatusOptions(),
                    'verification_status_options' => $this->getVerificationStatusOptions(),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Company not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Create a new company
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'business_registration_number' => 'required|string|max:100|unique:companies',
            'tax_id' => 'nullable|string|max:100',
            'company_type' => 'required|string|in:manufacturing,distributor,retailer,wholesaler,importer,exporter,other',
            'industry_type' => 'required|string|in:food_beverage,pharmaceutical,electronics,textile,automotive,chemical,cosmetics,agriculture,other',

            // Contact Information
            'email' => 'required|string|email|max:255|unique:companies',
            'phone' => 'nullable|string|max:50',
            'website' => 'nullable|string|max:255|url',
            'country' => 'required|string|max:100',
            'city' => 'required|string|max:100',
            'address' => 'nullable|string',
            'postal_code' => 'nullable|string|max:50',

            // Contact Person
            'contact_person_name' => 'required|string|max:255',
            'contact_person_email' => 'required|string|email|max:255',
            'contact_person_phone' => 'required|string|max:50',
            'contact_person_position' => 'nullable|string|max:100',

            // Settings
            'timezone' => 'nullable|string|max:50',
            'language' => 'nullable|string|max:10',
            'currency' => 'nullable|string|size:3',
            'logo' => 'nullable|image|max:2048',

            // Initial Plan
            'plan_id' => 'nullable|exists:subscription_plans,id',
            'billing_cycle' => 'nullable|string|in:monthly,quarterly,yearly,one_time',

            // Documents
            'documents' => 'nullable|array',
            'documents.*.type' => 'required|string',
            'documents.*.name' => 'required|string|max:255',
            'documents.*.file' => 'required|file|max:5120', // 5MB
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            // Handle logo upload
            $logoUrl = null;
            if ($request->hasFile('logo')) {
                $logoPath = $request->file('logo')->store('company-logos', 'public');
                $logoUrl = Storage::url($logoPath);
            }

            // Create company
            $company = Company::create([
                'name' => $request->name,
                'business_registration_number' => $request->business_registration_number,
                'tax_id' => $request->tax_id,
                'company_type' => $request->company_type,
                'industry_type' => $request->industry_type,

                // Contact Information
                'email' => $request->email,
                'phone' => $request->phone,
                'website' => $request->website,
                'country' => $request->country,
                'city' => $request->city,
                'address' => $request->address,
                'postal_code' => $request->postal_code,

                // Contact Person
                'contact_person_name' => $request->contact_person_name,
                'contact_person_email' => $request->contact_person_email,
                'contact_person_phone' => $request->contact_person_phone,
                'contact_person_position' => $request->contact_person_position,

                // Status & Verification
                'status' => 'pending',
                'verification_status' => 'notSubmitted',

                // Settings
                'timezone' => $request->timezone ?? 'UTC',
                'language' => $request->language ?? 'en',
                'currency' => $request->currency ?? 'USD',
                'logo_url' => $logoUrl,

                // Metadata
                'metadata' => [
                    'created_by_admin' => true,
                    'admin_notes' => $request->input('admin_notes', ''),
                ],
            ]);

            // Assign initial plan if provided
            if ($request->has('plan_id')) {
                $plan = SubscriptionPlan::find($request->plan_id);

                $subscription = Subscription::create([
                    'company_id' => $company->id,
                    'plan_id' => $plan->id,
                    'billing_cycle' => $request->billing_cycle ?? $plan->billing_cycle,
                    'status' => 'active',
                    'starts_at' => now(),
                    'ends_at' => $this->calculateSubscriptionEndDate($plan->billing_cycle),
                    'auto_renew' => true,
                    'metadata' => [
                        'assigned_by_admin' => true,
                        'initial_subscription' => true,
                    ],
                ]);

                // Update company's current plan
                $company->update([
                    'current_plan_id' => $plan->id,
                ]);

                // Create initial invoice
                $this->createInitialInvoice($company, $subscription, $plan);
            }

            // Handle document uploads
            if ($request->has('documents')) {
                foreach ($request->documents as $documentData) {
                    if (isset($documentData['file'])) {
                        $file = $documentData['file'];
                        $filePath = $file->store('company-documents/' . $company->id, 'public');

                        CompanyDocument::create([
                            'company_id' => $company->id,
                            'document_type' => $documentData['type'],
                            'document_name' => $documentData['name'],
                            'document_url' => Storage::url($filePath),
                            'file_size' => $file->getSize(),
                            'mime_type' => $file->getMimeType(),
                            'verification_status' => 'pending',
                        ]);
                    }
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Company created successfully',
                'data' => [
                    'company' => $company->load(['currentPlan', 'documents', 'subscriptions'])
                ]
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create company',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update a company
     *
     * @param Request $request
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, string $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'business_registration_number' => 'sometimes|required|string|max:100|unique:companies,business_registration_number,' . $id,
            'tax_id' => 'nullable|string|max:100',
            'company_type' => 'sometimes|required|string|in:manufacturing,distributor,retailer,wholesaler,importer,exporter,other',
            'industry_type' => 'sometimes|required|string|in:food_beverage,pharmaceutical,electronics,textile,automotive,chemical,cosmetics,agriculture,other',

            // Contact Information
            'email' => 'sometimes|required|string|email|max:255|unique:companies,email,' . $id,
            'phone' => 'nullable|string|max:50',
            'website' => 'nullable|string|max:255|url',
            'country' => 'sometimes|required|string|max:100',
            'city' => 'sometimes|required|string|max:100',
            'address' => 'nullable|string',
            'postal_code' => 'nullable|string|max:50',

            // Contact Person
            'contact_person_name' => 'sometimes|required|string|max:255',
            'contact_person_email' => 'sometimes|required|string|email|max:255',
            'contact_person_phone' => 'sometimes|required|string|max:50',
            'contact_person_position' => 'nullable|string|max:100',

            // Status & Verification
            'status' => 'sometimes|required|string|in:active,pending,suspended,terminated',
            'verification_status' => 'sometimes|required|string|in:notSubmitted,pending,verified,rejected',
            'verification_notes' => 'nullable|string',

            // Settings
            'timezone' => 'nullable|string|max:50',
            'language' => 'nullable|string|max:10',
            'currency' => 'nullable|string|size:3',
            'logo' => 'nullable|image|max:2048',

            // Plan Assignment
            'plan_id' => 'nullable|exists:subscription_plans,id',
            'billing_cycle' => 'nullable|string|in:monthly,quarterly,yearly,one_time',

            // Admin Notes
            'admin_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            $company = Company::findOrFail($id);

            // Handle logo upload
            if ($request->hasFile('logo')) {
                // Delete old logo if exists
                if ($company->logo_url) {
                    $oldLogoPath = str_replace('/storage/', '', $company->logo_url);
                    Storage::disk('public')->delete($oldLogoPath);
                }

                $logoPath = $request->file('logo')->store('company-logos', 'public');
                $logoUrl = Storage::url($logoPath);
                $company->logo_url = $logoUrl;
            }

            // Update company attributes
            $updateData = [];
            $fillable = [
                'name', 'business_registration_number', 'tax_id', 'company_type', 'industry_type',
                'email', 'phone', 'website', 'country', 'city', 'address', 'postal_code',
                'contact_person_name', 'contact_person_email', 'contact_person_phone', 'contact_person_position',
                'status', 'verification_status', 'verification_notes',
                'timezone', 'language', 'currency',
            ];

            foreach ($fillable as $field) {
                if ($request->has($field)) {
                    $updateData[$field] = $request->input($field);
                }
            }

            // Handle verification status change
            if ($request->has('verification_status') && $request->verification_status === 'verified') {
                $updateData['verified_at'] = now();
                $updateData['verified_by'] = $request->user()->id;
            }

            // Update metadata
            $metadata = $company->metadata ?? [];
            if ($request->has('admin_notes')) {
                $metadata['admin_notes'] = $request->admin_notes;
            }
            $updateData['metadata'] = $metadata;

            $company->update($updateData);

            // Handle plan assignment
            if ($request->has('plan_id')) {
                $this->assignPlanToCompany($company, $request->plan_id, $request->billing_cycle, $request->user());
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Company updated successfully',
                'data' => [
                    'company' => $company->load(['currentPlan', 'documents', 'subscriptions'])
                ]
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to update company',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete a company
     *
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(string $id)
    {
        DB::
