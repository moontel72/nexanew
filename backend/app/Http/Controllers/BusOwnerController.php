<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — BUS OWNER CONTROLLER
 * ==================================
 *
 * Dedicated controller for the Bus Owner App (Module 14).
 * Driver/Conductor CRUD is handled directly (scoped to owner identity).
 * All layout operations moved to AbsoluteLayoutController.
 */

class BusOwnerController extends Controller
{
    // ═══════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════

    /** Resolve the owner's tenant account ID (used as carrier for staff). */
    private function ownerTenantId(Request $request): ?string
    {
        $user = $request->user();
        if (!$user) return null;

        $identityId = $user->global_identity_id ?? null;
        if (!$identityId) return null;

        return DB::table('tenant_accounts')
            ->where('global_identity_id', $identityId)
            ->value('id') ?? $identityId;
    }

    /** Resolve the owner's global_identity_id. */
    private function ownerIdentityId(Request $request): ?string
    {
        return $request->user()?->global_identity_id;
    }

    /** Build a safe display payload from a joined query row. */
    private function formatRow($row): array
    {
        $meta = json_decode($row->assignment_meta ?? '{}', true) ?: [];

        return [
            'id'                  => $row->assignment_id ?? $row->id ?? null,
            'global_identity_id'  => $row->global_identity_id ?? null,
            'identity_token'      => $row->identity_token ?? null,
            'name'                => $row->display_name ?? $row->account_name ?? '—',
            'email'               => $row->email ?? null,
            'phone'               => $row->phone ?? null,
            'cnic'                => $meta['cnic'] ?? null,
            'address'             => $meta['address'] ?? null,
            'role'                => $row->role ?? null,
            'fleet_type'          => $row->fleet_type ?? null,
            'status'              => $row->status ?? 'active',
            'license_number'      => $meta['license_number'] ?? null,
            'vehicle_plate'       => $meta['vehicle_plate'] ?? null,
            'salary'              => $meta['salary'] ?? null,
            'kyc_status'          => $row->kyc_status ?? 'unverified',
            'kyc_tier'            => $row->kyc_tier ?? 0,
            'created_at'          => $row->created_at ?? null,
            'updated_at'          => $row->updated_at ?? null,
        ];
    }

    /** Build base query for staff (drivers/conductors) scoped to owner. */
    private function staffBaseQuery(Request $request, string $role)
    {
        $tenantId = $this->ownerTenantId($request);

        $query = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->leftJoin('tenant_accounts AS ta', 'gi.id', '=', 'ta.global_identity_id')
            ->where('fa.role', $role)
            ->where('fa.fleet_type', 'bus')
            ->whereIn('fa.status', ['active', 'pending_acceptance', 'suspended']);

        if ($tenantId) {
            $query->where('fa.carrier_company_id', $tenantId);
        }

        return $query->select(
            'fa.id AS assignment_id',
            'gi.id AS global_identity_id',
            'gi.identity_token',
            'gi.display_name',
            'gi.kyc_status',
            'gi.kyc_tier',
            'fa.role',
            'fa.fleet_type',
            'fa.status',
            'fa.assignment_meta',
            'fa.created_at',
            'fa.updated_at',
            'ta.email',
            'ta.phone_number AS phone',
            'ta.account_name',
        );
    }

    // ═══════════════════════════════════════════════════════
    // DRIVERS — LIST
    // ═══════════════════════════════════════════════════════

    public function listDrivers(Request $request): JsonResponse
    {
        return $this->listStaff($request, 'driver');
    }

    public function listConductors(Request $request): JsonResponse
    {
        return $this->listStaff($request, 'conductor');
    }

    private function listStaff(Request $request, string $role): JsonResponse
    {
        try {
            $perPage = (int) $request->input('per_page', 20);
            $perPage = max(1, min(100, $perPage));

            $query = $this->staffBaseQuery($request, $role);

            if ($request->filled('search')) {
                $s = $request->search;
                $query->where(function ($q) use ($s) {
                    $q->where('gi.display_name', 'ilike', "%{$s}%")
                      ->orWhere('ta.phone_number', 'ilike', "%{$s}%")
                      ->orWhere('ta.email', 'ilike', "%{$s}%");
                });
            }

            $result = $query->orderBy('fa.created_at', 'desc')->paginate($perPage);

            $data = $result->getCollection()->map(fn($row) => $this->formatRow($row))->toArray();

            return response()->json([
                'success' => true,
                'data'    => [
                    'data'         => $data,
                    'total'        => $result->total(),
                    'current_page' => $result->currentPage(),
                    'per_page'     => $result->perPage(),
                    'last_page'    => $result->lastPage(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('BusOwner - listStaff Error: ' . $e->getMessage(), [
                'role'    => $role,
                'user_id' => $request->user()?->id,
            ]);
            return response()->json([
                'success' => true,
                'data'    => ['data' => [], 'total' => 0, 'current_page' => 1, 'per_page' => $perPage, 'last_page' => 1],
            ]);
        }
    }

    // ═══════════════════════════════════════════════════════
    // DRIVERS / CONDUCTORS — STORE
    // ═══════════════════════════════════════════════════════

    public function storeDriver(Request $request): JsonResponse
    {
        return $this->storeStaff($request, 'driver');
    }

    public function storeConductor(Request $request): JsonResponse
    {
        return $this->storeStaff($request, 'conductor');
    }

    private function storeStaff(Request $request, string $role): JsonResponse
    {
        try {
            $isDriver = ($role === 'driver');

            $rules = [
                'name'     => ['required', 'string', 'max:255'],
                'email'    => ['required', 'email'],
                'phone'    => ['required', 'string', 'max:50'],
                'password' => ['required', 'string', 'min:8'],
                'cnic'     => ['nullable', 'string', 'max:30'],
                'address'  => ['nullable', 'string', 'max:500'],
            ];
            if ($isDriver) {
                $rules['license_number'] = ['required', 'string', 'max:100'];
            }
            $rules['vehicle_plate'] = ['nullable', 'string', 'max:50'];
            $rules['salary']        = ['nullable', 'numeric', 'min:0'];

            $data = $request->validate($rules);
            $tenantId = $this->ownerTenantId($request);

            DB::beginTransaction();
            try {
                // 1. GlobalIdentity
                $identityId = (string) Str::orderedUuid();
                $token = \App\Models\GlobalIdentity::generateToken($role);

                DB::table('global_identities')->insert([
                    'id'             => $identityId,
                    'identity_token' => $token,
                    'display_name'   => $data['name'],
                    'password_hash'  => Hash::make($data['password']),
                    'kyc_status'     => 'unverified',
                    'kyc_tier'       => 0,
                    'status'         => 'active',
                    'identity_type'  => $role,
                    'risk_score'     => 0.00,
                    'created_at'     => now(),
                    'updated_at'     => now(),
                ]);

                // 2. IdentityClaim — email
                $rawHash = hash('sha256', strtolower($data['email']), true);
                DB::table('identity_claims')->insert([
                    'id'                 => (string) Str::orderedUuid(),
                    'global_identity_id' => $identityId,
                    'claim_type'         => 'email',
                    'claim_value'        => strtolower(trim($data['email'])),
                    'claim_value_hash'   => DB::raw("decode('" . bin2hex($rawHash) . "', 'hex')"),
                    'is_primary'         => true,
                    'is_revoked'         => false,
                    'verified_via'       => 'manual_kyc',
                    'verified_at'        => now(),
                    'created_at'         => now(),
                    'updated_at'         => now(),
                ]);

                // 3. IdentityClaim — phone
                if (!empty($data['phone'])) {
                    $phoneHash = hash('sha256', $data['phone'], true);
                    DB::table('identity_claims')->insert([
                        'id'                 => (string) Str::orderedUuid(),
                        'global_identity_id' => $identityId,
                        'claim_type'         => 'phone',
                        'claim_value'        => preg_replace('/[^0-9+]/', '', $data['phone']),
                        'claim_value_hash'   => DB::raw("decode('" . bin2hex($phoneHash) . "', 'hex')"),
                        'is_primary'         => true,
                        'is_revoked'         => false,
                        'verified_via'       => 'manual_kyc',
                        'verified_at'        => now(),
                        'created_at'         => now(),
                        'updated_at'         => now(),
                    ]);
                }

                // 4. TenantAccount
                $staffTenantId = (string) Str::orderedUuid();
                DB::table('tenant_accounts')->insert([
                    'id'                  => $staffTenantId,
                    'global_identity_id'  => $identityId,
                    'account_name'        => $data['name'],
                    'email'               => $data['email'],
                    'password'            => Hash::make($data['password']),
                    'phone_number'        => $data['phone'],
                    'is_independent'      => false,
                    'account_type'        => $isDriver ? 'bus_driver' : 'bus_conductor',
                    'status'              => 'active',
                    'created_at'          => now(),
                    'updated_at'          => now(),
                ]);

                // 5. FleetAssignment (linked to owner's tenant)
                $assignmentId = (string) Str::orderedUuid();
                $meta = [];
                if ($isDriver) {
                    $meta['license_number'] = $data['license_number'] ?? null;
                }
                $meta['vehicle_plate'] = $data['vehicle_plate'] ?? null;
                $meta['salary']        = $data['salary'] ?? null;
                if (!empty($data['cnic']))    $meta['cnic']    = $data['cnic'];
                if (!empty($data['address'])) $meta['address'] = $data['address'];

                DB::table('fleet_assignments')->insert([
                    'id'                  => $assignmentId,
                    'global_identity_id'  => $identityId,
                    'carrier_company_id'  => $tenantId,
                    'role'                => $role,
                    'fleet_type'          => 'bus',
                    'status'              => 'active',
                    'assignment_meta'     => json_encode($meta),
                    'accepted_at'         => now(),
                    'created_at'          => now(),
                    'updated_at'          => now(),
                ]);

                DB::commit();

                Log::info('BusOwner: staff created', [
                    'identity_id'   => $identityId,
                    'assignment_id' => $assignmentId,
                    'role'          => $role,
                    'owner_id'      => $tenantId,
                ]);

                return response()->json([
                    'success' => true,
                    'data'    => [
                        'id'                 => $assignmentId,
                        'global_identity_id' => $identityId,
                        'identity_token'     => $token,
                        'name'               => $data['name'],
                        'email'              => $data['email'],
                        'phone'              => $data['phone'],
                        'role'               => $role,
                        'fleet_type'         => 'bus',
                        'status'             => 'active',
                    ],
                ], 201);

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }
        } catch (\Exception $e) {
            Log::error('BusOwner - storeStaff Error: ' . $e->getMessage(), [
                'role'    => $role,
                'user_id' => $request->user()?->id,
                'trace'   => $e->getTraceAsString(),
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // DRIVERS / CONDUCTORS — SHOW
    // ═══════════════════════════════════════════════════════

    public function showDriver(string $id): JsonResponse
    {
        return $this->showStaff($id, 'driver');
    }

    public function showConductor(string $id): JsonResponse
    {
        return $this->showStaff($id, 'conductor');
    }

    private function showStaff(string $assignmentId, string $role): JsonResponse
    {
        try {
            $row = DB::table('fleet_assignments AS fa')
                ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
                ->leftJoin('tenant_accounts AS ta', 'gi.id', '=', 'ta.global_identity_id')
                ->where('fa.id', $assignmentId)
                ->where('fa.role', $role)
                ->select(
                    'fa.id AS assignment_id', 'gi.id AS global_identity_id',
                    'gi.identity_token', 'gi.display_name', 'gi.kyc_status', 'gi.kyc_tier',
                    'fa.role', 'fa.fleet_type', 'fa.status', 'fa.assignment_meta',
                    'fa.accepted_at', 'fa.unassigned_at', 'fa.unassign_reason',
                    'fa.created_at', 'fa.updated_at',
                    'ta.email', 'ta.phone_number AS phone', 'ta.account_name',
                )
                ->first();

            if (!$row) {
                return response()->json(['message' => 'Not found'], 404);
            }

            return response()->json(['success' => true, 'data' => $this->formatRow($row)]);
        } catch (\Exception $e) {
            Log::error('BusOwner - showStaff Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // DRIVERS / CONDUCTORS — UPDATE
    // ═══════════════════════════════════════════════════════

    public function updateDriver(string $id, Request $request): JsonResponse
    {
        return $this->updateStaff($id, $request, 'driver');
    }

    public function updateConductor(string $id, Request $request): JsonResponse
    {
        return $this->updateStaff($id, $request, 'conductor');
    }

    private function updateStaff(string $assignmentId, Request $request, string $role): JsonResponse
    {
        try {
            $assignment = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->where('role', $role)
                ->first();

            if (!$assignment) {
                return response()->json(['message' => 'Not found'], 404);
            }

            $isDriver = ($role === 'driver');
            $rules = [
                'name'     => ['sometimes', 'string', 'max:255'],
                'email'    => ['sometimes', 'email'],
                'phone'    => ['sometimes', 'string', 'max:50'],
                'password' => ['sometimes', 'string', 'min:8'],
                'cnic'     => ['nullable', 'string', 'max:30'],
                'address'  => ['nullable', 'string', 'max:500'],
                'status'   => ['sometimes', 'string', 'in:active,suspended,pending_acceptance'],
            ];
            if ($isDriver) {
                $rules['license_number'] = ['sometimes', 'string', 'max:100'];
            }
            $rules['vehicle_plate'] = ['nullable', 'string', 'max:50'];
            $rules['salary']        = ['nullable', 'numeric', 'min:0'];

            $data = $request->validate($rules);

            DB::beginTransaction();
            try {
                $identityId = $assignment->global_identity_id;

                if (isset($data['name'])) {
                    DB::table('global_identities')
                        ->where('id', $identityId)
                        ->update(['display_name' => $data['name'], 'updated_at' => now()]);
                }
                if (isset($data['password'])) {
                    DB::table('global_identities')
                        ->where('id', $identityId)
                        ->update(['password_hash' => Hash::make($data['password']), 'updated_at' => now()]);
                }

                $taUpdates = ['updated_at' => now()];
                if (isset($data['name']))     $taUpdates['account_name'] = $data['name'];
                if (isset($data['email']))    $taUpdates['email']        = $data['email'];
                if (isset($data['phone']))    $taUpdates['phone_number'] = $data['phone'];
                if (isset($data['password'])) $taUpdates['password']     = Hash::make($data['password']);
                if (isset($data['status']))   $taUpdates['status']       = $data['status'];

                DB::table('tenant_accounts')
                    ->where('global_identity_id', $identityId)
                    ->update($taUpdates);

                $meta = json_decode($assignment->assignment_meta ?? '{}', true) ?: [];
                if ($isDriver && isset($data['license_number'])) $meta['license_number'] = $data['license_number'];
                if (isset($data['vehicle_plate'])) $meta['vehicle_plate'] = $data['vehicle_plate'];
                if (isset($data['salary']))        $meta['salary']        = $data['salary'];
                if (isset($data['cnic']))           $meta['cnic']          = $data['cnic'];
                if (isset($data['address']))        $meta['address']       = $data['address'];

                $faUpdates = [
                    'assignment_meta' => json_encode($meta),
                    'updated_at'      => now(),
                ];
                if (isset($data['status'])) {
                    $faUpdates['status'] = $data['status'];
                }

                DB::table('fleet_assignments')
                    ->where('id', $assignmentId)
                    ->update($faUpdates);

                DB::commit();

                Log::info('BusOwner: staff updated', [
                    'assignment_id' => $assignmentId,
                    'identity_id'   => $identityId,
                    'role'          => $role,
                ]);

                return response()->json([
                    'success' => true,
                    'data'    => ['id' => $assignmentId, 'message' => 'Updated'],
                ]);
            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }
        } catch (\Exception $e) {
            Log::error('BusOwner - updateStaff Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // DRIVERS / CONDUCTORS — DESTROY (soft-revoke)
    // ═══════════════════════════════════════════════════════

    public function destroyDriver(string $id): JsonResponse
    {
        return $this->destroyStaff($id, 'driver');
    }

    public function destroyConductor(string $id): JsonResponse
    {
        return $this->destroyStaff($id, 'conductor');
    }

    private function destroyStaff(string $assignmentId, string $role): JsonResponse
    {
        try {
            $assignment = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->where('role', $role)
                ->first();

            if (!$assignment) {
                return response()->json(['message' => 'Not found'], 404);
            }

            DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->update([
                    'status'          => 'revoked',
                    'unassigned_at'   => now(),
                    'unassign_reason' => 'Revoked by bus owner',
                    'updated_at'      => now(),
                ]);

            Log::info('BusOwner: staff assignment revoked', [
                'assignment_id' => $assignmentId,
                'identity_id'   => $assignment->global_identity_id,
                'role'          => $role,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Staff assignment revoked. Identity preserved.',
            ]);
        } catch (\Exception $e) {
            Log::error('BusOwner - destroyStaff Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // IDENTITY PORTABILITY — LINK REQUEST (§10.11.2)
    // ═══════════════════════════════════════════════════════

    /**
     * GET /api/v1/bus-owner/available-companies
     *
     * Returns active bus companies that an owner can link with.
     * No admin auth required — this is a bus-owner-scoped endpoint.
     * Only returns id, name, email — no sub-admin data leaked.
     */
    public function availableCompanies(Request $request): JsonResponse
    {
        $search = $request->query('search', '');

        $query = DB::table('tenant_accounts')
            ->where('account_type', 'bus_company')
            ->where('status', 'active')
            ->select('id', 'account_name', 'email', 'phone_number', 'status');

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('account_name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        $companies = $query->orderBy('account_name')->limit(30)->get();

        return response()->json([
            'success' => true,
            'data'    => $companies,
        ]);
    }

    /**
     * POST /api/v1/bus-owner/link-request
     *
     * An independent Bus Owner requests to link with a Bus Company
     * (carrier). Creates a fleet_assignments row with
     * status='pending_acceptance' under the target carrier.
     *
     * The one_active_assignment_per_role partial unique index
     * guarantees no double-linking or simultaneous active links.
     */
    public function linkRequest(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'carrier_company_id' => ['required', 'uuid'],
                'message'            => ['nullable', 'string', 'max:500'],
            ]);

            $user = $request->user();
            $identityId = $user->global_identity_id ?? null;
            if (!$identityId) {
                return response()->json([
                    'success' => false,
                    'message' => 'No identity found for this account.',
                ], 400);
            }

            // Defensive: verify the authenticated user is NOT a sub-admin/admin
            $accountType = $user->account_type ?? '';
            if (in_array($accountType, ['master_admin', 'sub_admin', 'admin'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Admin accounts cannot send link requests. Please log in as a bus owner.',
                ], 403);
            }

            // Resolve identity info for response verification
            $identity = DB::table('global_identities')
                ->where('id', $identityId)
                ->first();

            // Verify target is a valid, active bus company
            $targetCompany = DB::table('tenant_accounts')
                ->where('id', $data['carrier_company_id'])
                ->where('account_type', 'bus_company')
                ->where('status', 'active')
                ->first();

            if (!$targetCompany) {
                return response()->json([
                    'success' => false,
                    'message' => 'Target bus company not found or not active.',
                ], 404);
            }

            // Don't link to yourself
            $ownerTenantId = $this->ownerTenantId($request);
            if ($ownerTenantId === $data['carrier_company_id']) {
                return response()->json([
                    'success' => false,
                    'message' => 'You cannot link to your own account.',
                ], 422);
            }

            // Guard: check for existing active/pending owner assignment
            $existing = DB::table('fleet_assignments')
                ->where('global_identity_id', $identityId)
                ->where('role', 'owner')
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->first();

            if ($existing) {
                $company = DB::table('tenant_accounts')
                    ->where('id', $existing->carrier_company_id)
                    ->value('account_name') ?? 'Unknown';

                return response()->json([
                    'success' => false,
                    'message' => "You already have an {$existing->status} link with '{$company}'. Cancel it before requesting a new one.",
                    'data'    => [
                        'existing_assignment_id' => $existing->id,
                        'existing_status'        => $existing->status,
                        'existing_carrier_name'  => $company,
                        'existing_carrier_id'    => $existing->carrier_company_id,
                    ],
                ], 409);
            }

            // Create pending_acceptance assignment
            $assignmentId = (string) Str::orderedUuid();
            $meta = [
                'link_message'  => $data['message'] ?? null,
                'requested_at'  => now()->toIso8601String(),
                'source'        => 'bus_owner_app',
            ];

            DB::table('fleet_assignments')->insert([
                'id'                  => $assignmentId,
                'global_identity_id'  => $identityId,
                'carrier_company_id'  => $data['carrier_company_id'],
                'role'                => 'owner',
                'fleet_type'          => 'bus',
                'status'              => 'pending_acceptance',
                'assignment_meta'     => json_encode($meta),
                'created_at'          => now(),
                'updated_at'          => now(),
            ]);

            Log::info('BusOwner: link request submitted', [
                'identity_id'        => $identityId,
                'assignment_id'      => $assignmentId,
                'carrier_company_id' => $data['carrier_company_id'],
                'carrier_name'       => $targetCompany->account_name,
            ]);

            return response()->json([
                'success' => true,
                'data'    => [
                    'assignment_id'      => $assignmentId,
                    'status'             => 'pending_acceptance',
                    'carrier_company_id' => $data['carrier_company_id'],
                    'carrier_name'       => $targetCompany->account_name,
                    'sender_identity_token' => $identity->identity_token ?? null,
                    'sender_name'           => $identity->display_name ?? null,
                    'message'            => 'Link request submitted. Awaiting approval from the bus company.',
                ],
            ], 201);

        } catch (\Exception $e) {
            Log::error('BusOwner - linkRequest Error: ' . $e->getMessage(), [
                'user_id' => $request->user()?->id,
                'trace'   => $e->getTraceAsString(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Server error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * POST /api/v1/bus-owner/link-request/{id}/cancel
     *
     * Cancel a pending link request before it is accepted/rejected.
     */
    public function cancelLinkRequest(string $assignmentId, Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $identityId = $user->global_identity_id ?? null;
            if (!$identityId) {
                return response()->json(['success' => false, 'message' => 'No identity found.'], 400);
            }

            $assignment = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->where('global_identity_id', $identityId)
                ->where('role', 'owner')
                ->first();

            if (!$assignment) {
                return response()->json(['message' => 'Link request not found'], 404);
            }

            if (!in_array($assignment->status, ['pending_acceptance', 'on_hold'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Only pending or on-hold requests can be cancelled.',
                ], 422);
            }

            DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->update([
                    'status'          => 'revoked',
                    'unassigned_at'   => now(),
                    'unassign_reason' => 'Cancelled by owner',
                    'updated_at'      => now(),
                ]);

            Log::info('BusOwner: link request cancelled', [
                'assignment_id' => $assignmentId,
                'identity_id'   => $identityId,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Link request cancelled.',
            ]);

        } catch (\Exception $e) {
            Log::error('BusOwner - cancelLinkRequest Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * POST /api/v1/bus-owner/link-request/{id}/leave
     *
     * An already-linked owner voluntarily leaves their current carrier.
     * Sets the active assignment to 'unassigned' and deactivates any
     * tenant_allowance_grants the carrier held on this owner's resources.
     */
    public function leaveCarrier(string $assignmentId, Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $identityId = $user->global_identity_id ?? null;
            if (!$identityId) {
                return response()->json(['success' => false, 'message' => 'No identity found.'], 400);
            }

            $assignment = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->where('global_identity_id', $identityId)
                ->where('role', 'owner')
                ->first();

            if (!$assignment) {
                return response()->json(['message' => 'Assignment not found'], 404);
            }

            if ($assignment->status !== 'active') {
                return response()->json([
                    'success' => false,
                    'message' => 'Only active links can be terminated.',
                ], 422);
            }

            $oldCarrierId = $assignment->carrier_company_id;

            DB::beginTransaction();
            try {
                // Step 1: Unassign the fleet assignment
                DB::table('fleet_assignments')
                    ->where('id', $assignmentId)
                    ->update([
                        'status'          => 'unassigned',
                        'unassigned_at'   => now(),
                        'unassign_reason' => 'Voluntarily left by owner',
                        'updated_at'      => now(),
                    ]);

                // Step 2: Deactivate old carrier's allowance grants
                DB::table('tenant_allowance_grants')
                    ->where('owner_identity_id', $identityId)
                    ->where('carrier_company_id', $oldCarrierId)
                    ->update([
                        'is_active'  => false,
                        'updated_at' => now(),
                    ]);

                DB::table('tenant_allowance_matrix')
                    ->where('owner_identity_id', $identityId)
                    ->where('carrier_company_id', $oldCarrierId)
                    ->update([
                        'status'     => 'inactive',
                        'updated_at' => now(),
                    ]);

                DB::commit();

                Log::info('BusOwner: left carrier', [
                    'assignment_id'      => $assignmentId,
                    'identity_id'        => $identityId,
                    'old_carrier_id'     => $oldCarrierId,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'You have left the carrier. You can now link with another company.',
                ]);

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('BusOwner - leaveCarrier Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * GET /api/v1/bus-owner/link-status
     *
     * Returns the current linking status for the authenticated owner.
     */
    public function linkStatus(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $identityId = $user->global_identity_id ?? null;
            if (!$identityId) {
                return response()->json(['success' => false, 'message' => 'No identity found.'], 400);
            }

            $assignment = DB::table('fleet_assignments')
                ->where('global_identity_id', $identityId)
                ->where('role', 'owner')
                ->whereIn('status', ['active', 'pending_acceptance', 'on_hold'])
                ->first();

            if (!$assignment) {
                return response()->json([
                    'success' => true,
                    'data'    => [
                        'linked'    => false,
                        'status'    => 'independent',
                    ],
                ]);
            }

            $carrier = DB::table('tenant_accounts')
                ->where('id', $assignment->carrier_company_id)
                ->first();

            return response()->json([
                'success' => true,
                'data'    => [
                    'linked'             => true,
                    'status'             => $assignment->status,
                    'assignment_id'      => $assignment->id,
                    'carrier_company_id' => $assignment->carrier_company_id,
                    'carrier_name'       => $carrier->account_name ?? 'Unknown',
                    'linked_at'          => $assignment->accepted_at ?? $assignment->created_at,
                ],
            ]);

        } catch (\Exception $e) {
            Log::error('BusOwner - linkStatus Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // LINK MESSAGES — Persistent B2B Chat
    // ═══════════════════════════════════════════════════════

    public function listAllMessages(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $identityId = $user->global_identity_id ?? null;
            if (!$identityId) {
                return response()->json(['data' => []]);
            }

            $messages = DB::table('fleet_assignment_messages AS fam')
                ->leftJoin('fleet_assignments AS fa', 'fam.fleet_assignment_id', '=', 'fa.id')
                ->leftJoin('tenant_accounts AS ta', 'fa.carrier_company_id', '=', 'ta.id')
                ->where('fam.owner_identity_id', $identityId)
                ->select(
                    'fam.id',
                    'fam.fleet_assignment_id',
                    'fam.sender_id',
                    'fam.message_body',
                    'fam.context_type',
                    'fam.created_at',
                    'ta.account_name AS carrier_name',
                    'fa.carrier_company_id',
                    'fa.status AS assignment_status'
                )
                ->orderBy('fam.created_at', 'desc')
                ->limit(200)
                ->get()
                ->map(fn($m) => [
                    'id'                  => $m->id,
                    'fleet_assignment_id' => $m->fleet_assignment_id,
                    'sender_id'           => $m->sender_id,
                    'message_body'        => $m->message_body,
                    'context_type'        => $m->context_type,
                    'created_at'          => $m->created_at,
                    'carrier_name'        => $m->carrier_name ?? 'Unknown Carrier',
                    'carrier_company_id'  => $m->carrier_company_id,
                    'status'              => $m->assignment_status ?? 'unknown',
                ]);

            return response()->json(['success' => true, 'data' => $messages]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function listMessages(string $assignmentId): JsonResponse
    {
        try {
            $messages = DB::table('fleet_assignment_messages')
                ->where('fleet_assignment_id', $assignmentId)
                ->orderBy('created_at', 'asc')
                ->get()
                ->map(fn($m) => [
                    'id'           => $m->id,
                    'sender_id'    => $m->sender_id,
                    'message_body' => $m->message_body,
                    'context_type' => $m->context_type,
                    'created_at'   => $m->created_at,
                ]);

            return response()->json(['success' => true, 'data' => $messages]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function sendMessage(string $assignmentId, Request $request): JsonResponse
    {
        try {
            $data = $request->validate(['message_body' => ['required', 'string', 'max:2000']]);
            $user = $request->user();
            $senderId = $user->global_identity_id ?? $user->id;

            // Resolve owner_identity_id from the assignment for retention
            $ownerId = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->value('global_identity_id');

            $msgId = (string) Str::orderedUuid();
            DB::table('fleet_assignment_messages')->insert([
                'id'                  => $msgId,
                'fleet_assignment_id' => $assignmentId,
                'owner_identity_id'   => $ownerId,
                'sender_id'           => $senderId,
                'message_body'        => $data['message_body'],
                'context_type'        => 'general',
                'created_at'          => now(),
                'updated_at'          => now(),
            ]);

            return response()->json(['success' => true, 'data' => ['id' => $msgId]]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // PHASE 2 — TRIP SEAT STATUS (Owner-Scoped)
    // ═══════════════════════════════════════════════════════

    public function tripSeatStatus(string $tripId, Request $request): JsonResponse
    {
        $ownerId = $this->ownerIdentityId($request);
        if (!$ownerId) {
            return response()->json(['success' => false, 'message' => 'Owner identity required.'], 403);
        }

        $trip = DB::table('transport_bus_trips')->where('id', $tripId)->first();
        if (!$trip) {
            return response()->json(['success' => false, 'message' => 'Trip not found.'], 404);
        }

        $layout = DB::table('absolute_bus_layouts')->where('id', $trip->bus_id)->first();
        if (!$layout) {
            return response()->json(['success' => false, 'message' => 'Bus layout not found.'], 404);
        }

        $isMasterAdmin = ($request->user()->account_type ?? null) === 'master_admin';
        $layoutOwnerId = $layout->owner_identity_id ?? null;
        if (!$isMasterAdmin && (string) $layoutOwnerId !== (string) $ownerId) {
            return response()->json(['success' => false, 'message' => 'This trip belongs to a different bus owner.'], 403);
        }

        $heldSeats = DB::table('transport_seat_holds')
            ->where('trip_id', $tripId)
            ->where('hold_expires_at', '>', now())
            ->select('seat_number', 'hold_expires_at')
            ->get()
            ->map(fn($row) => [
                'seat_number'       => (int) $row->seat_number,
                'remaining_seconds' => max(0, (int) now()->diffInSeconds($row->hold_expires_at, false)),
            ])->toArray();

        $bookedSeats = DB::table('transport_seat_bookings')
            ->where('trip_id', $tripId)
            ->whereIn('status', ['booked', 'confirmed', 'boarded'])
            ->pluck('seat_number')->map(fn($v) => (int) $v)->toArray();

        // Count total seats from snapshot metadata (bound-aware, excludes structural).
        $totalSeats = $layout->totalSeats();

        $available = $totalSeats - count($heldSeats) - count($bookedSeats);

        $holdsAllowed = false;
        try {
            $holdsAllowed = app(\App\Services\Transport\SeatHoldService::class)->holdsAllowed($tripId);
        } catch (\RuntimeException) {}

        return response()->json(['success' => true, 'data' => [
            'trip_id'          => $tripId,
            'bus_id'           => $trip->bus_id,
            'status'           => $trip->status,
            'origin'           => $trip->origin,
            'destination'      => $trip->destination,
            'layout_name'      => $layout->display_name ?? 'Untitled',
            'total_seats'      => $totalSeats,
            'held_seats'       => $heldSeats,
            'held_count'       => count($heldSeats),
            'booked_seats'     => $bookedSeats,
            'booked_count'     => count($bookedSeats),
            'available_seats'  => max(0, $available),
            'holds_allowed'    => $holdsAllowed,
            'scheduled_departure_at' => $trip->scheduled_departure_at ?? null,
        ]]);
    }
}
