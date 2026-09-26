<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\FactoryUser;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/**
 * Sub-Admin Factory Company Management Controller — Group-Incharge C2.
 *
 * Lets the Factory Sub-Admin (the `factory` vertical) onboard and manage the factory
 * companies — and their factory admin login — for its own group.
 *
 * Mirrors the shape of SubAdminBusCompanyController (index / store / show / update /
 * updateStatus / destroy / restore), but the domain objects are the FACTORY ones:
 *   * `companies`   — Company, not TenantAccount
 *   * `factory_users` — the factory admin's login (position `admin`), not a bus owner
 *
 * Differences from the Super Admin path (AdminCompanyController@store), each deliberate:
 *   1. Every company records `metadata.created_by_sub_admin_id` (+ name) — that is the scoping key,
 *      because `companies` has no parent column the way `tenant_accounts` does.
 *   2. NO subscription/plan is assigned. Plans belong to the financial_auditor (C0 section 2b.3).
 *   3. NO legacy `admin_users` `company_admin` row is created. That row existed for the old
 *      `/bus-fleet/login` / `/goods-fleet/login` paths and is the pattern the owner is removing.
 *   4. Every read/write is scoped to the caller's own companies, and a foreign id is a 404 —
 *      a sub-admin must not touch another sub-admin's group.
 *
 * NOT here (Phase 6, by design — C0 section 2b.3): vertical enforcement. These routes sit behind the
 * `admin` middleware (any active sub-admin passes, as with bus-companies today); the route-to-feature
 * map that confines a vertical to its own endpoints is Phase 6.
 */
class SubAdminFactoryCompanyController extends Controller
{
    /**
     * List the factory companies this sub-admin created.
     */
    public function index(Request $request): JsonResponse
    {
        $subAdminId = $request->user()->global_identity_id;

        $companies = $this->ownedQuery($subAdminId)
            ->orderBy('created_at', 'desc')
            ->get([
                'id', 'name', 'email', 'phone', 'country', 'city',
                'company_type', 'industry_type', 'status', 'verification_status',
                'contact_person_name', 'contact_person_email', 'contact_person_phone',
                'business_registration_number', 'metadata', 'created_at',
            ]);

        return response()->json([
            'success' => true,
            'data'    => $companies,
        ]);
    }

    /**
     * Create a factory company plus its factory admin login.
     */
    public function store(Request $request): JsonResponse
    {
        $subAdmin = $request->user();

        $validated = $request->validate([
            // Company
            'name'                         => ['required', 'string', 'max:255'],
            'business_registration_number' => ['required', 'string', 'max:100', 'unique:companies,business_registration_number'],
            'tax_id'                       => ['nullable', 'string', 'max:100'],
            'company_type'                 => ['nullable', 'string', 'max:50'],
            'industry_type'                => ['nullable', 'string', 'max:50'],
            'email'                        => ['required', 'email', 'max:255', 'unique:companies,email'],
            'phone'                        => ['nullable', 'string', 'max:50'],
            'website'                      => ['nullable', 'string', 'max:255'],
            'country'                      => ['required', 'string', 'max:100'],
            'city'                         => ['required', 'string', 'max:100'],
            'address'                      => ['nullable', 'string'],
            'postal_code'                  => ['nullable', 'string', 'max:50'],
            // Contact person — this IS the factory admin
            'contact_person_name'          => ['required', 'string', 'max:255'],
            'contact_person_email'         => ['required', 'email', 'max:255'],
            'contact_person_phone'         => ['required', 'string', 'max:50'],
            'contact_person_position'      => ['nullable', 'string', 'max:100'],
            // Factory admin login
            'password'                     => ['required', 'string', 'min:8'],
            'admin_notes'                  => ['nullable', 'string'],
        ]);

        $subAdminId   = $subAdmin->global_identity_id;
        $subAdminName = $subAdmin->account_name ?? $subAdmin->display_name ?? null;

        $company = DB::transaction(function () use ($validated, $subAdminId, $subAdminName) {
            $notes = $validated['admin_notes'] ?? null;

            $company = Company::query()->create([
                'id'                           => (string) Str::uuid(),
                'name'                         => $validated['name'],
                'business_registration_number' => $validated['business_registration_number'],
                'tax_id'                       => $validated['tax_id'] ?? null,
                'company_type'                 => $validated['company_type'] ?? 'manufacturing',
                'industry_type'                => $validated['industry_type'] ?? 'other',
                'email'                        => $validated['email'],
                'phone'                        => $validated['phone'] ?? null,
                'website'                      => $validated['website'] ?? null,
                'country'                      => $validated['country'],
                'city'                         => $validated['city'],
                'address'                      => $validated['address'] ?? null,
                'postal_code'                  => $validated['postal_code'] ?? null,
                'contact_person_name'          => $validated['contact_person_name'],
                'contact_person_email'         => $validated['contact_person_email'],
                'contact_person_phone'         => $validated['contact_person_phone'],
                'contact_person_position'      => $validated['contact_person_position'] ?? null,
                'status'                       => 'pending',
                'verification_status'          => 'notSubmitted',
                'timezone'                     => 'Asia/Karachi',
                'language'                     => 'en',
                'currency'                     => 'PKR',
                'metadata'                     => [
                    'created_by_sub_admin_id'   => $subAdminId,
                    'created_by_sub_admin_name' => $subAdminName,
                    'created_via'               => 'sub_admin',
                    'notes'                     => $notes,
                ],
            ]);

            // One factory-admin login per distinct email — the same rule the Super Admin path uses,
            // so moving creation here loses nothing.
            $loginEmails = array_values(array_unique([
                $validated['contact_person_email'],
                $validated['email'],
            ]));

            foreach ($loginEmails as $loginEmail) {
                $factoryUser = new FactoryUser([
                    'company_id'      => $company->id,
                    'email'           => $loginEmail,
                    'phone'           => $validated['contact_person_phone'],
                    'full_name'       => $validated['contact_person_name'],
                    'position'        => $validated['contact_person_position'] ?? 'admin',
                    'email_verified'  => true,
                    'phone_verified'  => true,
                    'permissions'     => [],
                    'is_active'       => true,
                    'metadata'        => ['created_by_sub_admin_id' => $subAdminId],
                ]);
                $factoryUser->setPassword($validated['password']);
                $factoryUser->save();
            }

            return $company;
        });

        return response()->json([
            'success' => true,
            'message' => 'Factory company created successfully',
            'data'    => [
                'id'              => $company->id,
                'company_name'    => $company->name,
                'email'           => $company->email,
                'status'          => $company->status,
                'admin_email'     => $validated['contact_person_email'],
            ],
        ], 201);
    }

    /**
     * Show one factory company owned by this sub-admin.
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $company = $this->findOwned($request, $id);

        if (!$company) {
            return response()->json(['message' => 'Factory company not found'], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => $company,
        ]);
    }

    /**
     * Update a factory company's details (and, if given, its admin login password).
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $company = $this->findOwned($request, $id);

        if (!$company) {
            return response()->json(['message' => 'Factory company not found'], 404);
        }

        $validated = $request->validate([
            'name'                    => ['sometimes', 'string', 'max:255'],
            'email'                   => ['sometimes', 'email', 'max:255', Rule::unique('companies', 'email')->ignore($company->id, 'id')],
            'password'                => ['sometimes', 'string', 'min:8'],
            'phone'                   => ['nullable', 'string', 'max:50'],
            'website'                 => ['nullable', 'string', 'max:255'],
            'country'                 => ['sometimes', 'string', 'max:100'],
            'city'                    => ['sometimes', 'string', 'max:100'],
            'address'                 => ['nullable', 'string'],
            'postal_code'             => ['nullable', 'string', 'max:50'],
            'company_type'            => ['sometimes', 'string', 'max:50'],
            'industry_type'           => ['sometimes', 'string', 'max:50'],
            'tax_id'                  => ['nullable', 'string', 'max:100'],
            'contact_person_name'     => ['sometimes', 'string', 'max:255'],
            'contact_person_email'    => ['sometimes', 'email', 'max:255'],
            'contact_person_phone'    => ['sometimes', 'string', 'max:50'],
            'contact_person_position' => ['nullable', 'string', 'max:100'],
            'admin_notes'             => ['nullable', 'string'],
        ]);

        if (array_key_exists('admin_notes', $validated)) {
            $company->metadata = array_merge(
                ($company->metadata ?? []),
                ['notes' => $validated['admin_notes']]
            );
            unset($validated['admin_notes']);
        }

        // Only the keys that were actually sent. Genuinely nullable columns may be sent as null to clear
        // them; the NOT NULL ones (name, email, country, city, company_type, industry_type) reject null by
        // their validation rule above, so a partial form can never blank a column by accident.
        $updates = $validated;
        unset($updates['password'], $updates['admin_notes']);

        // business_registration_number is required at creation and not editable here on purpose —
        // changing it would break the audit trail back to the registration document.
        $company->fill($updates);
        $company->save();

        // Password, if provided, goes to every factory-admin login of this company.
        if (!empty($validated['password'])) {
            foreach (FactoryUser::query()->where('company_id', $company->id)->get() as $factoryUser) {
                $factoryUser->setPassword($validated['password']);
                $factoryUser->is_active = true;
                $factoryUser->save();
            }
        }

        return response()->json(['success' => true, 'message' => 'Factory company updated']);
    }

    /**
     * Set a factory company's status.
     * Accepts: pending, verified, active, inactive, suspended, deleted.
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'string', 'in:pending,verified,active,inactive,suspended,deleted'],
        ]);

        $company = $this->findOwned($request, $id);

        if (!$company) {
            return response()->json(['message' => 'Factory company not found'], 404);
        }

        $newStatus = $validated['status'];
        $isDeleted = $newStatus === 'deleted';

        $company->fill([
            'status'      => $newStatus,
            'is_deleted'  => $isDeleted,
            'deleted_at'  => $isDeleted ? now() : null,
        ]);

        // 'verified' also clears the verification gate, so the factory admin can log in to a live panel.
        if ($newStatus === 'verified') {
            $company->verification_status = 'verified';
            $company->verified_at         = now();
        }
        $company->save();

        // The login follows the company: a deleted/suspended company must not keep a working admin login.
        $newUserState = match ($newStatus) {
            'verified', 'active' => true,
            default              => false,
        };
        FactoryUser::query()
            ->where('company_id', $company->id)
            ->update(['is_active' => $newUserState, 'updated_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => "Factory company status updated to {$newStatus}",
            'data'    => ['status' => $newStatus],
        ]);
    }

    /**
     * Soft-delete a factory company (restorable).
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        $company = $this->findOwned($request, $id);

        if (!$company) {
            return response()->json(['message' => 'Factory company not found'], 404);
        }

        $company->fill([
            'status'     => 'deleted',
            'is_deleted' => true,
            'deleted_at' => now(),
        ])->save();

        FactoryUser::query()
            ->where('company_id', $company->id)
            ->update(['is_active' => false, 'updated_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Factory company deleted (restorable for 30 days)',
        ]);
    }

    /**
     * Restore a soft-deleted factory company.
     */
    public function restore(Request $request, string $id): JsonResponse
    {
        $subAdminId = $request->user()->global_identity_id;

        $company = $this->ownedQuery($subAdminId)
            ->where('id', $id)
            ->where('status', 'deleted')
            ->first();

        if (!$company) {
            return response()->json(['message' => 'Factory company not found or not deleted'], 404);
        }

        $company->fill([
            'status'     => 'active',
            'is_deleted' => false,
            'deleted_at' => null,
        ])->save();

        FactoryUser::query()
            ->where('company_id', $company->id)
            ->update(['is_active' => true, 'updated_at' => now()]);

        return response()->json(['success' => true, 'message' => 'Factory company restored']);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Scoping — the isolation rule. `companies` has no parent column, so the creator is recorded in
    // `metadata.created_by_sub_admin_id` at creation and matched here with the Postgres `->>` operator.
    // ─────────────────────────────────────────────────────────────────────────

    private function ownedQuery(?string $subAdminId)
    {
        return Company::query()->where('metadata->>created_by_sub_admin_id', $subAdminId);
    }

    private function findOwned(Request $request, string $id): ?Company
    {
        return $this->ownedQuery($request->user()->global_identity_id)
            ->where('id', $id)
            ->first();
    }
}
