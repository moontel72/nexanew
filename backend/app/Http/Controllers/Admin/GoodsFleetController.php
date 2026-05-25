<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminUser;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

/**
 * NEXATRACE — GOODS FLEET CONTROLLER
 * ===================================
 *
 * Manages Goods Fleet Companies (truck-based logistics).
 * Super Admin manages goods companies; company owners login
 * via the public login endpoint.
 *
 * Uses DB facade directly where practical to avoid Eloquent
 * model fillable/column issues, following FleetManagementController.
 */

class GoodsFleetController extends Controller
{
    /**
     * List all companies tagged as goods_fleet.
     * Super Admin only (auth:admin middleware).
     */
    public function listCompanies(Request $request): JsonResponse
    {
        try {
            $perPage = (int) $request->input('per_page', 20);
            $perPage = max(1, min(100, $perPage));

            $query = DB::table('companies')
                ->whereRaw("metadata->'notes'->>'company_type_tag' = ?", ['goods_fleet']);

            // Search filter
            if ($request->filled('search')) {
                $search = $request->input('search');
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'ilike', "%{$search}%")
                      ->orWhere('email', 'ilike', "%{$search}%")
                      ->orWhere('business_registration_number', 'ilike', "%{$search}%");
                });
            }

            // Status filter
            if ($request->filled('status')) {
                $query->where('status', $request->input('status'));
            }

            $result = $query->orderBy('created_at', 'desc')->paginate($perPage);

            // Decode metadata.notes for each item to expose goods-specific fields
            $items = collect($result->items())->map(function ($company) {
                $metadata = $company->metadata;
                if (is_string($metadata)) {
                    $metadata = json_decode($metadata, true);
                }
                $notes = $metadata['notes'] ?? null;
                $goodsMeta = null;
                if ($notes && is_string($notes)) {
                    $decoded = json_decode($notes, true);
                    if (is_array($decoded) && ($decoded['company_type_tag'] ?? null) === 'goods_fleet') {
                        $goodsMeta = $decoded;
                    }
                }

                return array_merge((array) $company, [
                    'fleet_size'    => $goodsMeta['fleet_size'] ?? 0,
                    'truck_count'   => $goodsMeta['truck_count'] ?? 0,
                    'owner_name'    => $goodsMeta['owner_name'] ?? null,
                    'is_goods_fleet' => $goodsMeta !== null,
                ]);
            })->all();

            return response()->json([
                'success' => true,
                'data'    => [
                    'companies'  => $items,
                    'total'      => $result->total(),
                    'page'       => $result->currentPage(),
                    'per_page'   => $result->perPage(),
                    'total_pages' => $result->lastPage(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Server error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create a new goods fleet company with owner credentials.
     * Super Admin only (auth:admin middleware).
     */
    public function storeCompany(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'                    => ['required', 'string', 'max:255'],
            'business_registration_number' => ['required', 'string', 'max:100', 'unique:companies,business_registration_number'],
            'tax_id'                  => ['nullable', 'string', 'max:100'],
            'company_type'            => ['required', 'string', 'max:50'],
            'industry_type'           => ['required', 'string', 'max:50'],
            'email'                   => ['required', 'email', 'max:255', 'unique:companies,email'],
            'phone'                   => ['nullable', 'string', 'max:50'],
            'website'                 => ['nullable', 'string', 'max:255'],
            'country'                 => ['required', 'string', 'max:100'],
            'city'                    => ['required', 'string', 'max:100'],
            'address'                 => ['nullable', 'string'],
            'postal_code'             => ['nullable', 'string', 'max:50'],
            'contact_person_name'     => ['required', 'string', 'max:255'],
            'contact_person_email'    => ['required', 'email', 'max:255'],
            'contact_person_phone'    => ['required', 'string', 'max:50'],
            'contact_person_position' => ['nullable', 'string', 'max:100'],
            'password'                => ['required', 'string', 'min:8'],
            'timezone'                => ['nullable', 'string', 'max:50'],
            'language'                => ['nullable', 'string', 'max:10'],
            'currency'                => ['nullable', 'string', 'size:3'],
            'status'                  => ['nullable', 'string', Rule::in(['active', 'inactive', 'suspended'])],
            'fleet_size'              => ['nullable', 'integer', 'min:0'],
            'truck_count'             => ['nullable', 'integer', 'min:0'],
            'owner_name'              => ['nullable', 'string', 'max:255'],
        ]);

        try {
            DB::beginTransaction();

            $companyId = (string) Str::uuid();

            // Build goods-specific notes metadata
            $goodsNotes = json_encode([
                'company_type_tag' => 'goods_fleet',
                'fleet_size'       => (int) ($data['fleet_size'] ?? 0),
                'truck_count'      => (int) ($data['truck_count'] ?? 0),
                'owner_name'       => $data['owner_name'] ?? $data['contact_person_name'],
            ]);

            $metadata = json_encode([
                'notes' => $goodsNotes,
            ]);

            // Create the company record
            DB::table('companies')->insert([
                'id'                          => $companyId,
                'name'                        => $data['name'],
                'business_registration_number' => $data['business_registration_number'],
                'tax_id'                      => $data['tax_id'] ?? null,
                'company_type'                => $data['company_type'],
                'industry_type'               => $data['industry_type'],
                'email'                       => $data['email'],
                'phone'                       => $data['phone'] ?? null,
                'website'                     => $data['website'] ?? null,
                'country'                     => $data['country'],
                'city'                        => $data['city'],
                'address'                     => $data['address'] ?? null,
                'postal_code'                 => $data['postal_code'] ?? null,
                'contact_person_name'         => $data['contact_person_name'],
                'contact_person_email'        => $data['contact_person_email'],
                'contact_person_phone'        => $data['contact_person_phone'],
                'contact_person_position'     => $data['contact_person_position'] ?? null,
                'status'                      => $data['status'] ?? 'active',
                'metadata'                    => $metadata,
                'timezone'                    => $data['timezone'] ?? 'UTC',
                'language'                    => $data['language'] ?? 'en',
                'currency'                    => $data['currency'] ?? 'USD',
                'verification_status'         => 'pending',
                'created_at'                  => now(),
                'updated_at'                  => now(),
            ]);

            // Create admin user for the company owner login
            $loginEmails = array_values(array_unique([
                $data['contact_person_email'],
                $data['email'],
            ]));

            foreach ($loginEmails as $loginEmail) {
                $existingAdmin = DB::table('admin_users')
                    ->where('email', $loginEmail)
                    ->first();

                if ($existingAdmin) {
                    continue;
                }

                DB::table('admin_users')->insert([
                    'id'       => (string) Str::uuid(),
                    'name'     => $data['contact_person_name'],
                    'email'    => $loginEmail,
                    'password' => bcrypt($data['password']),
                    'role'     => 'company_admin',
                    'status'   => 'active',
                    'metadata' => json_encode([
                        'company_id'   => $companyId,
                        'company_type' => 'goods_fleet',
                    ]),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            DB::commit();

            $company = DB::table('companies')->find($companyId);

            // Decode metadata for the response
            $respMeta = $company->metadata;
            if (is_string($respMeta)) {
                $respMeta = json_decode($respMeta, true);
            }
            $respNotes = $respMeta['notes'] ?? null;
            $goodsMeta = null;
            if ($respNotes && is_string($respNotes)) {
                $decoded = json_decode($respNotes, true);
                if (is_array($decoded)) {
                    $goodsMeta = $decoded;
                }
            }

            return response()->json([
                'success' => true,
                'data'    => array_merge((array) $company, [
                    'fleet_size'     => $goodsMeta['fleet_size'] ?? 0,
                    'truck_count'    => $goodsMeta['truck_count'] ?? 0,
                    'owner_name'     => $goodsMeta['owner_name'] ?? null,
                    'is_goods_fleet' => $goodsMeta !== null,
                ]),
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Server error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Show a single goods fleet company.
     * Super Admin only (auth:admin middleware).
     */
    public function showCompany(string $id): JsonResponse
    {
        try {
            $company = DB::table('companies')
                ->where('id', $id)
                ->first();

            if (!$company) {
                return response()->json(['message' => 'Company not found'], 404);
            }

            // Decode metadata
            $metadata = $company->metadata;
            if (is_string($metadata)) {
                $metadata = json_decode($metadata, true);
            }
            $notes = $metadata['notes'] ?? null;
            $goodsMeta = null;
            if ($notes && is_string($notes)) {
                $decoded = json_decode($notes, true);
                if (is_array($decoded)) {
                    $goodsMeta = $decoded;
                }
            }

            return response()->json([
                'success' => true,
                'data'    => array_merge((array) $company, [
                    'fleet_size'     => $goodsMeta['fleet_size'] ?? 0,
                    'truck_count'    => $goodsMeta['truck_count'] ?? 0,
                    'owner_name'     => $goodsMeta['owner_name'] ?? null,
                    'is_goods_fleet' => $goodsMeta !== null && ($goodsMeta['company_type_tag'] ?? null) === 'goods_fleet',
                ]),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Server error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * PUBLIC endpoint — Goods company owner login.
     * No auth middleware required.
     */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email'    => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        // Look up the company by email first, then find its admin user
        $company = DB::table('companies')
            ->where('email', $data['email'])
            ->orWhere('contact_person_email', $data['email'])
            ->first();

        if (!$company) {
            throw ValidationException::withMessages([
                'email' => 'No goods fleet company found with this email.',
            ])->status(401);
        }

        // Verify this is a goods_fleet company
        $cMeta = $company->metadata;
        if (is_string($cMeta)) {
            $cMeta = json_decode($cMeta, true);
        }
        $cNotes = $cMeta['notes'] ?? null;
        if ($cNotes && is_string($cNotes)) {
            $cNotes = json_decode($cNotes, true);
        }
        if (($cNotes['company_type_tag'] ?? null) !== 'goods_fleet') {
            throw ValidationException::withMessages([
                'email' => 'This account is not a goods fleet company.',
            ])->status(401);
        }

        // Find the admin user created for this company
        $adminUser = AdminUser::query()
            ->whereJsonContains('metadata->company_id', $company->id)
            ->whereJsonContains('metadata->company_type', 'goods_fleet')
            ->first();

        if (!$adminUser) {
            // Fallback: try matching by email directly
            $adminUser = AdminUser::query()
                ->where('email', $data['email'])
                ->first();
        }

        if (!$adminUser || !Hash::check($data['password'], $adminUser->password)) {
            throw ValidationException::withMessages([
                'email' => 'Invalid credentials.',
            ])->status(401);
        }

        if (($adminUser->status ?? 'active') !== 'active') {
            return response()->json(['message' => 'Account is not active.'], 403);
        }

        // Update login metadata
        $adminUser->forceFill([
            'last_login_at'       => now(),
            'last_login_ip'       => $request->ip(),
            'last_login_user_agent' => substr((string) $request->userAgent(), 0, 1000),
            'login_attempts'      => 0,
        ])->save();

        $token = $adminUser->createToken('goods-fleet-login')->plainTextToken;

        return response()->json([
            'success' => true,
            'data'    => [
                'user'  => [
                    'id'         => $adminUser->id,
                    'name'       => $adminUser->name,
                    'email'      => $adminUser->email,
                    'role'       => $adminUser->role,
                    'company_id' => $company->id,
                ],
                'token'        => $token,
                'token_expiry' => now()->addDays(30)->toISOString(),
            ],
        ]);
    }

    /**
     * Get authenticated goods fleet company profile.
     * Auth required (auth:admin middleware).
     */
    public function profile(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            // Extract company_id from the admin user's metadata
            $meta = $user->metadata;
            if (is_string($meta)) {
                $meta = json_decode($meta, true);
            }
            $companyId = is_array($meta) ? ($meta['company_id'] ?? null) : null;

            if (!$companyId) {
                return response()->json(['message' => 'No company associated with this account'], 404);
            }

            $company = DB::table('companies')->find($companyId);

            if (!$company) {
                return response()->json(['message' => 'Company not found'], 404);
            }

            // Decode goods metadata
            $cMetadata = $company->metadata;
            if (is_string($cMetadata)) {
                $cMetadata = json_decode($cMetadata, true);
            }
            $notes = $cMetadata['notes'] ?? null;
            $goodsMeta = null;
            if ($notes && is_string($notes)) {
                $decoded = json_decode($notes, true);
                if (is_array($decoded)) {
                    $goodsMeta = $decoded;
                }
            }

            return response()->json([
                'success' => true,
                'data'    => [
                    'company'       => $company,
                    'fleet_size'    => $goodsMeta['fleet_size'] ?? 0,
                    'truck_count'   => $goodsMeta['truck_count'] ?? 0,
                    'owner_name'    => $goodsMeta['owner_name'] ?? null,
                    'is_goods_fleet' => $goodsMeta !== null && ($goodsMeta['company_type_tag'] ?? null) === 'goods_fleet',
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Server error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get dashboard stats for the authenticated goods fleet company.
     * Auth required (auth:admin middleware).
     */
    public function dashboard(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $meta = $user->metadata;
            if (is_string($meta)) {
                $meta = json_decode($meta, true);
            }
            $companyId = is_array($meta) ? ($meta['company_id'] ?? null) : null;

            if (!$companyId) {
                return response()->json(['message' => 'No company associated with this account'], 404);
            }

            $company = DB::table('companies')->find($companyId);

            if (!$company) {
                return response()->json(['message' => 'Company not found'], 404);
            }

            // Decode goods metadata
            $cMetadata = $company->metadata;
            if (is_string($cMetadata)) {
                $cMetadata = json_decode($cMetadata, true);
            }
            $notes = $cMetadata['notes'] ?? null;
            $goodsMeta = null;
            if ($notes && is_string($notes)) {
                $decoded = json_decode($notes, true);
                if (is_array($decoded)) {
                    $goodsMeta = $decoded;
                }
            }

            // Count active trips (future: query trips table)
            $activeTrips = DB::table('trips')
                ->where('company_id', $companyId)
                ->where('status', 'in_progress')
                ->count();

            $totalTrips = DB::table('trips')
                ->where('company_id', $companyId)
                ->count();

            return response()->json([
                'success' => true,
                'data'    => [
                    'company_id'    => $company->id,
                    'company_name'  => $company->name,
                    'status'        => $company->status,
                    'fleet_size'    => $goodsMeta['fleet_size'] ?? 0,
                    'truck_count'   => $goodsMeta['truck_count'] ?? 0,
                    'owner_name'    => $goodsMeta['owner_name'] ?? $company->contact_person_name,
                    'total_trips'   => $totalTrips,
                    'active_trips'  => $activeTrips,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Server error: ' . $e->getMessage(),
            ], 500);
        }
    }
}
