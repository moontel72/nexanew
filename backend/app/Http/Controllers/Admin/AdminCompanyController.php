<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\CompanyResource;
use App\Models\Company;
use App\Models\CompanyDocument;
use App\Models\CompanySubscription;
use App\Models\FactoryUser;
use App\Models\AdminUser;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AdminCompanyController extends Controller
{
    public function index(Request $request)
    {
        $query = Company::query();

        $search = (string) $request->query('search', '');
        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                    ->orWhere('business_registration_number', 'ilike', "%{$search}%")
                    ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        if ($verificationStatus = $request->query('verification_status')) {
            $query->where('verification_status', $verificationStatus);
        }

        if ($country = $request->query('country')) {
            $query->where('country', $country);
        }

        $sortBy = (string) $request->query('sort_by', 'created_at');
        $sortOrder = strtolower((string) $request->query('sort_order', 'desc')) === 'asc' ? 'asc' : 'desc';
        if (!in_array($sortBy, ['created_at', 'updated_at', 'name', 'status', 'verification_status', 'country'], true)) {
            $sortBy = 'created_at';
        }

        $query->orderBy($sortBy, $sortOrder);

        $page = (int) $request->query('page', 1);
        $perPage = (int) ($request->query('per_page', $request->query('limit', 20)));
        $perPage = max(1, min(100, $perPage));

        $paginator = $query
            ->with(['documents', 'activeSubscription.plan'])
            ->paginate($perPage, ['*'], 'page', $page);

        $items = collect($paginator->items())
            ->map(fn ($c) => (new CompanyResource($c))->toArray($request))
            ->all();

        return response()->json([
            'success' => true,
            'data' => [
                'companies' => $items,
                'total' => $paginator->total(),
                'page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total_pages' => $paginator->lastPage(),
            ],
        ]);
    }

    public function show(Request $request, Company $company)
    {
        $company->load(['documents', 'activeSubscription.plan']);
        return response()->json(['success' => true, 'data' => (new CompanyResource($company))->toArray($request)]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'business_registration_number' => ['required', 'string', 'max:100', 'unique:companies,business_registration_number'],
            'tax_id' => ['nullable', 'string', 'max:100'],
            'company_type' => ['required', 'string', 'max:50'],
            'industry_type' => ['required', 'string', 'max:50'],
            'email' => ['required', 'email', 'max:255', 'unique:companies,email'],
            'phone' => ['nullable', 'string', 'max:50'],
            'website' => ['nullable', 'string', 'max:255'],
            'country' => ['required', 'string', 'max:100'],
            'city' => ['required', 'string', 'max:100'],
            'address' => ['nullable', 'string'],
            'postal_code' => ['nullable', 'string', 'max:50'],
            'contact_person_name' => ['required', 'string', 'max:255'],
            'contact_person_email' => ['required', 'email', 'max:255'],
            'contact_person_phone' => ['required', 'string', 'max:50'],
            'contact_person_position' => ['nullable', 'string', 'max:100'],
            'password' => ['required', 'string', 'min:8'],
            'timezone' => ['nullable', 'string', 'max:50'],
            'language' => ['nullable', 'string', 'max:10'],
            'currency' => ['nullable', 'string', 'size:3'],
            'plan_id' => ['nullable', 'uuid'],
            'billing_cycle' => ['nullable', Rule::in(['monthly', 'yearly'])],
            'documents' => ['nullable', 'array'],
            'documents.*.document_type' => ['required_with:documents', 'string'],
            'documents.*.document_name' => ['required_with:documents', 'string'],
            'documents.*.document_url' => ['required_with:documents', 'string'],
            'admin_notes' => ['nullable', 'string'],
        ]);

        return DB::transaction(function () use ($data, $request) {
            $adminNotes = $data['admin_notes'] ?? null;
            $companyPayload = $data;
            unset($companyPayload['password']);
            unset($companyPayload['admin_notes']);

            $company = Company::query()->create(array_merge(
                ['id' => (string) Str::uuid()],
                $companyPayload,
                ['metadata' => array_merge(($companyPayload['metadata'] ?? []), ['notes' => $adminNotes])]
            ));

            if (!empty($data['documents'])) {
                foreach ($data['documents'] as $doc) {
                    CompanyDocument::query()->create([
                        'id' => (string) Str::uuid(),
                        'company_id' => $company->id,
                        'document_type' => $doc['document_type'],
                        'document_name' => $doc['document_name'],
                        'document_url' => $doc['document_url'],
                        'verification_status' => 'pending',
                    ]);
                }
            }

            if (!empty($data['plan_id'])) {
                $this->createSubscription($company, $data['plan_id'], $data['billing_cycle'] ?? 'monthly');
            }

            $loginEmails = array_values(array_unique([
                $data['contact_person_email'],
                $data['email'],
            ]));

            foreach ($loginEmails as $loginEmail) {
                $existing = FactoryUser::query()
                    ->where('company_id', $company->id)
                    ->where('email', $loginEmail)
                    ->first();

                if ($existing) {
                    continue;
                }

                $factoryUser = new FactoryUser([
                    'company_id' => $company->id,
                    'email' => $loginEmail,
                    'phone' => $data['contact_person_phone'],
                    'full_name' => $data['contact_person_name'],
                    'position' => $data['contact_person_position'] ?? 'admin',
                    'email_verified' => true,
                    'phone_verified' => true,
                    'permissions' => [],
                    'is_active' => true,
                    'metadata' => [],
                ]);
                $factoryUser->setPassword($data['password']);
                $factoryUser->save();
            }

            // Also create AdminUser for universal auth login (/bus-fleet/login)
            foreach ($loginEmails as $loginEmail) {
                $existingAdmin = AdminUser::query()
                    ->where('email', $loginEmail)
                    ->first();

                if ($existingAdmin) {
                    continue;
                }

                AdminUser::query()->create([
                    'id'       => (string) Str::uuid(),
                    'name'     => $data['contact_person_name'],
                    'email'    => $loginEmail,
                    'password' => bcrypt($data['password']),
                    'role'     => 'company_admin',
                    'status'   => 'active',
                    'metadata' => json_encode([
                        'company_id'   => $company->id,
                        'company_type' => 'bus_fleet',
                    ]),
                ]);
            }

            $company->load(['documents', 'activeSubscription.plan']);

            return response()->json(['success' => true, 'data' => (new CompanyResource($company))->toArray($request)], 201);
        });
    }

    public function update(Request $request, Company $company)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'business_registration_number' => ['sometimes', 'string', 'max:100', Rule::unique('companies', 'business_registration_number')->ignore($company->id, 'id')],
            'tax_id' => ['sometimes', 'nullable', 'string', 'max:100'],
            'company_type' => ['sometimes', 'string', 'max:50'],
            'industry_type' => ['sometimes', 'string', 'max:50'],
            'email' => ['sometimes', 'email', 'max:255', Rule::unique('companies', 'email')->ignore($company->id, 'id')],
            'phone' => ['sometimes', 'nullable', 'string', 'max:50'],
            'website' => ['sometimes', 'nullable', 'string', 'max:255'],
            'country' => ['sometimes', 'string', 'max:100'],
            'city' => ['sometimes', 'string', 'max:100'],
            'address' => ['sometimes', 'nullable', 'string'],
            'postal_code' => ['sometimes', 'nullable', 'string', 'max:50'],
            'contact_person_name' => ['sometimes', 'string', 'max:255'],
            'contact_person_email' => ['sometimes', 'email', 'max:255'],
            'contact_person_phone' => ['sometimes', 'string', 'max:50'],
            'contact_person_position' => ['sometimes', 'nullable', 'string', 'max:100'],
            'status' => ['sometimes', 'string'],
            'verification_status' => ['sometimes', 'string'],
            'verification_notes' => ['sometimes', 'nullable', 'string'],
            'timezone' => ['sometimes', 'nullable', 'string', 'max:50'],
            'language' => ['sometimes', 'nullable', 'string', 'max:10'],
            'currency' => ['sometimes', 'nullable', 'string', 'size:3'],
            'admin_notes' => ['sometimes', 'nullable', 'string'],
        ]);

        if (array_key_exists('admin_notes', $data)) {
            $company->metadata = array_merge(($company->metadata ?? []), ['notes' => $data['admin_notes']]);
            unset($data['admin_notes']);
        }

        $company->fill($data)->save();
        $company->load(['documents', 'activeSubscription.plan']);

        return response()->json(['success' => true, 'data' => (new CompanyResource($company))->toArray($request)]);
    }

    public function destroy(Company $company)
    {
        $company->delete();
        return response()->json(['success' => true]);
    }

    public function updateStatus(Request $request, Company $company)
    {
        $data = $request->validate([
            'status' => ['required', 'string'],
            'verification_status' => ['sometimes', 'string'],
            'reason' => ['nullable', 'string'],
        ]);

        $company->status = $data['status'];
        if (isset($data['verification_status'])) {
            $company->verification_status = $data['verification_status'];
            if ($data['verification_status'] === 'verified') {
                $company->verified_at = now();
            }
        }
        if (!empty($data['reason'])) {
            $company->metadata = array_merge(($company->metadata ?? []), ['status_reason' => $data['reason']]);
        }
        $company->save();
        $company->load(['documents', 'activeSubscription.plan']);

        return response()->json(['success' => true, 'data' => (new \App\Http\Resources\CompanyResource($company))->toArray($request)]);
    }

    public function updateVerification(Request $request, Company $company)
    {
        $data = $request->validate([
            'verification_status' => ['required', 'string'],
            'verification_notes' => ['nullable', 'string'],
        ]);

        $company->verification_status = $data['verification_status'];
        $company->verification_notes = $data['verification_notes'] ?? null;
        if ($data['verification_status'] === 'verified') {
            $company->verified_at = now();
        }
        $company->save();

        return response()->json(['success' => true]);
    }

    public function assignPlan(Request $request, Company $company)
    {
        $data = $request->validate([
            'plan_id' => ['required', 'uuid'],
            'billing_cycle' => ['nullable', Rule::in(['monthly', 'yearly'])],
            'auto_renew' => ['nullable', 'boolean'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date'],
        ]);

        $subscription = $this->createSubscription(
            $company,
            $data['plan_id'],
            $data['billing_cycle'] ?? 'monthly',
            $data['starts_at'] ?? null,
            $data['ends_at'] ?? null,
            $data['auto_renew'] ?? true,
        );

        return response()->json(['success' => true, 'data' => ['subscription_id' => (string) $subscription->id]]);
    }

    public function uploadDocument(Request $request, Company $company)
    {
        $data = $request->validate([
            'document_type' => ['required', 'string'],
            'document_name' => ['required', 'string'],
            'file' => ['required', 'file', 'max:10240'],
        ]);

        $path = $request->file('file')->store("company_documents/{$company->id}", 'public');

        $doc = CompanyDocument::query()->create([
            'id' => (string) Str::uuid(),
            'company_id' => $company->id,
            'document_type' => $data['document_type'],
            'document_name' => $data['document_name'],
            'document_url' => Storage::disk('public')->url($path),
            'file_size' => $request->file('file')->getSize(),
            'mime_type' => $request->file('file')->getMimeType(),
            'verification_status' => 'pending',
        ]);

        return response()->json(['success' => true, 'data' => [
            'id' => (string) $doc->id,
            'document_type' => (string) $doc->document_type,
            'document_name' => (string) $doc->document_name,
            'document_url' => (string) $doc->document_url,
            'verification_status' => (string) $doc->verification_status,
        ]], 201);
    }

    public function deleteDocument(Company $company, string $document)
    {
        $doc = CompanyDocument::query()->where('company_id', $company->id)->where('id', $document)->firstOrFail();
        $doc->delete();
        return response()->json(['success' => true]);
    }

    public function statistics()
    {
        $total = Company::query()->count();
        $byStatus = Company::query()
            ->selectRaw('status, count(*) as c')
            ->groupBy('status')
            ->get()
            ->mapWithKeys(fn ($r) => [(string) $r->status => (int) $r->c])
            ->all();

        return response()->json(['success' => true, 'data' => [
            'total_companies' => $total,
            'by_status' => $byStatus,
        ]]);
    }

    public function export()
    {
        return response()->json(['success' => true, 'data' => ['file_path' => null]]);
    }

    public function sendWelcomeEmail(Company $company)
    {
        return response()->json(['success' => true]);
    }

    public function resetPassword(Company $company)
    {
        return response()->json(['success' => true]);
    }

    public function usageStats(Company $company)
    {
        $sub = $company->activeSubscription()->first();
        return response()->json(['success' => true, 'data' => [
            'company_id' => (string) $company->id,
            'total_codes_generated' => (int) ($company->total_codes_generated ?? 0),
            'current_unit_codes_used' => (int) ($sub?->current_unit_codes_used ?? 0),
            'current_packet_codes_used' => (int) ($sub?->current_packet_codes_used ?? 0),
            'current_carton_codes_used' => (int) ($sub?->current_carton_codes_used ?? 0),
            'current_bundle_codes_used' => (int) ($sub?->current_bundle_codes_used ?? 0),
        ]]);
    }

    private function createSubscription(
        Company $company,
        string $planId,
        string $billingCycle,
        ?string $startsAt = null,
        ?string $endsAt = null,
        bool $autoRenew = true,
    ): CompanySubscription {
        $plan = SubscriptionPlan::query()->findOrFail($planId);

        CompanySubscription::query()
            ->where('company_id', $company->id)
            ->where('status', 'active')
            ->update(['status' => 'inactive']);

        $start = $startsAt ? now()->parse($startsAt)->toDateString() : now()->toDateString();
        $end = $endsAt ? now()->parse($endsAt)->toDateString() : null;

        return CompanySubscription::query()->create([
            'id' => (string) Str::uuid(),
            'company_id' => $company->id,
            'plan_id' => $plan->id,
            'billing_cycle' => $billingCycle,
            'start_date' => $start,
            'end_date' => $end,
            'auto_renew' => $autoRenew,
            'payment_status' => 'pending',
            'status' => 'active',
            'metadata' => [],
        ]);
    }
}
