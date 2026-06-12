<?php

namespace App\Http\Controllers;

use App\Services\Transport\LayoutService;
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
 * Layout operations delegate to the shared LayoutService.
 */

class BusOwnerController extends Controller
{
    public function __construct(
        private ?LayoutService $layouts = null,
    ) {
        $this->layouts ??= app(LayoutService::class);
    }
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
    // SEAT LAYOUTS — LIST (delegated to LayoutService)
    // ═══════════════════════════════════════════════════════

    public function listLayouts(Request $request): JsonResponse
    {
        try {
            $identityId = $this->ownerIdentityId($request);
            $vehicleClass = $request->query('vehicle_class');
            $perPage = (int) $request->query('per_page', 20);

            $layouts = DB::table('transport_bus_layouts')
                ->where('owner_identity_id', $identityId)
                ->where('layout_status', '!=', 'archived')
                ->when($vehicleClass, fn($q) => $q->where('vehicle_class', $vehicleClass))
                ->orderBy('updated_at', 'desc')
                ->paginate(min($perPage, 100));

            $data = $layouts->getCollection()->map(function ($l) {
                $snap = json_decode($l->current_snapshot ?? '{}', true) ?: [];
                return [
                    'id'                => $l->id,
                    'display_name'      => $l->display_name ?? 'Untitled',
                    'vehicle_class'     => $l->vehicle_class ?? 'unknown',
                    'layout_status'     => $l->layout_status ?? 'draft',
                    'version_number'    => $l->version_number ?? 1,
                    'deck_level'        => $l->deck_level ?? 0,
                    'is_locked_sovereign' => $l->is_locked_sovereign ?? true,
                    'current_snapshot'  => $snap,
                    'created_at'        => $l->created_at,
                    'updated_at'        => $l->updated_at,
                ];
            })->toArray();

            return response()->json([
                'success' => true,
                'data'    => [
                    'data'         => $data,
                    'total'        => $layouts->total(),
                    'current_page' => $layouts->currentPage(),
                    'per_page'     => $layouts->perPage(),
                    'last_page'    => $layouts->lastPage(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('BusOwner - listLayouts Error: ' . $e->getMessage());
            return response()->json(['success' => true, 'data' => ['data' => [], 'total' => 0]]);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SEAT LAYOUTS — STORE (delegated to LayoutService)
    // ═══════════════════════════════════════════════════════

    public function storeLayout(Request $request): JsonResponse
    {
        try {
            // Detect format: preset-based or grid-based
            if ($request->has('vehicle_class')) {
                // Preset format — delegate to LayoutService
                $data = $request->validate([
                    'vehicle_class' => ['required', 'string', 'in:coach_54,standard_45,coaster_34,hiace_13,sleeper_custom'],
                    'display_name'  => ['required', 'string', 'max:160'],
                    'deck_level'    => ['nullable', 'integer', 'in:0,1'],
                ]);

                $result = $this->layouts->createLayout(
                    ownerIdentityId: $this->ownerIdentityId($request),
                    companyId: $this->ownerTenantId($request),
                    vehicleClass: $data['vehicle_class'],
                    displayName: $data['display_name'],
                    deckLevel: (int) ($data['deck_level'] ?? 0),
                );

                return response()->json(['success' => true, 'data' => $result], 201);
            }

            // Grid-based format (custom blank-slate builder)
            $data = $request->validate([
                'bus_plate'        => ['required', 'string', 'max:50'],
                'bus_brand'        => ['required', 'string', 'max:100'],
                'bus_category'     => ['required', 'string', 'max:50'],
                'total_rows'       => ['required', 'integer', 'min:3', 'max:20'],
                'total_cols'       => ['required', 'integer', 'min:2', 'max:8'],
                'aisle_after_col'  => ['required', 'integer', 'min:0'],
                'grid'             => ['required', 'array'],
            ]);

            $identityId = $this->ownerIdentityId($request);
            $tenantId   = $this->ownerTenantId($request);

            $seatCount = 0;
            $driverCount = 0;
            $cells = [];
            foreach ($data['grid'] as $row) {
                $rowCells = [];
                foreach ((array) $row as $cell) {
                    $type = $cell['type'] ?? 'empty';
                    if ($type === 'seat' || $type === 'folding') $seatCount++;
                    if ($type === 'driver') $driverCount++;
                    $rowCells[] = [
                        'type'   => $type,
                        'label'  => $cell['label'] ?? '',
                        'seat_id'=> $cell['seat_id'] ?? null,
                    ];
                }
                $cells[] = $rowCells;
            }

            $hasUpper = $request->has('has_upper_deck') || $request->has('upper_grid');

            if ($hasUpper) {
                // Use composite snapshot builder for multi-tier layouts
                $snapshot = $this->layouts->buildCompositeSnapshot([
                    'total_rows'   => (int) $data['total_rows'],
                    'total_cols'   => (int) $data['total_cols'],
                    'bus_category' => $data['bus_category'],
                    'grid'         => $cells,
                    'upper_grid'   => $request->input('upper_grid', []),
                ]);
            } else {
                $snapshot = [
                    'bus_plate'       => $data['bus_plate'],
                    'bus_brand'       => $data['bus_brand'],
                    'bus_category'    => $data['bus_category'],
                    'total_rows'      => (int) $data['total_rows'],
                    'total_cols'      => (int) $data['total_cols'],
                    'aisle_after_col' => (int) $data['aisle_after_col'],
                    'total_seats'     => $seatCount,
                    'driver_seats'    => $driverCount,
                    'grid'            => $cells,
                    'created_from'    => 'custom_builder',
                ];
            }

            $displayName = $data['bus_plate'] . ' — ' . $data['bus_brand'] . ' ' . $data['bus_category'];
            $layoutId = (string) Str::orderedUuid();

            DB::table('transport_bus_layouts')->insert([
                'id'                  => $layoutId,
                'bus_id'              => $layoutId,
                'owner_id'            => 1,
                'owner_identity_id'   => $identityId,
                'carrier_company_id'  => $tenantId,
                'vehicle_class'       => $data['bus_category'],
                'display_name'        => $displayName,
                'total_rows'          => (int) $data['total_rows'],
                'left_columns'        => (int) $data['aisle_after_col'],
                'right_columns'       => (int) $data['total_cols'] - (int) $data['aisle_after_col'] - 1,
                'driver_seats'        => $driverCount,
                'raw_grid_json'       => json_encode($cells),
                'is_active'           => true,
                'is_locked_sovereign' => true,
                'version_number'      => 1,
                'layout_status'       => 'draft',
                'current_snapshot'    => json_encode($snapshot),
                'deck_level'          => 0,
                'created_at'          => now(),
                'updated_at'          => now(),
            ]);

            Log::info('BusOwner: custom layout created', [
                'layout_id' => $layoutId,
                'plate'     => $data['bus_plate'],
                'seats'     => $seatCount,
            ]);

            return response()->json([
                'success' => true,
                'data'    => [
                    'id'              => $layoutId,
                    'display_name'    => $displayName,
                    'bus_plate'       => $data['bus_plate'],
                    'layout_status'   => 'draft',
                    'version_number'  => 1,
                    'total_seats'     => $seatCount,
                ],
            ], 201);

        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        } catch (\Exception $e) {
            Log::error('BusOwner - storeLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SEAT LAYOUTS — SHOW (delegated to LayoutService)
    // ═══════════════════════════════════════════════════════

    public function showLayout(string $id): JsonResponse
    {
        try {
            $result = $this->layouts->getLayout($id);
            return response()->json(['success' => true, ...$result]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => 'Layout not found'], 404);
        } catch (\Exception $e) {
            Log::error('BusOwner - showLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SEAT LAYOUTS — UPDATE (full grid + metadata)
    // ═══════════════════════════════════════════════════════

    public function updateLayout(string $id, Request $request): JsonResponse
    {
        try {
            $layout = DB::table('transport_bus_layouts')->where('id', $id)->first();
            if (!$layout) {
                return response()->json(['message' => 'Layout not found'], 404);
            }

            $updates = ['updated_at' => now()];

            // Metadata updates
            if ($request->has('display_name'))  $updates['display_name']  = $request->display_name;
            if ($request->has('vehicle_class')) $updates['vehicle_class'] = $request->vehicle_class;
            if ($request->has('layout_status')) $updates['layout_status'] = $request->layout_status;

            // Full grid update (from builder save)
            if ($request->has('grid')) {
                $grid = $request->grid;
                $totalRows = (int) ($request->total_rows ?? count($grid));
                $totalCols = (int) ($request->total_cols ?? (count($grid[0] ?? [])));

                $seatCount = 0; $driverCount = 0;
                $cells = [];
                foreach ($grid as $row) {
                    $rowCells = [];
                    foreach ((array) $row as $cell) {
                        $type = $cell['type'] ?? 'empty';
                        if ($type === 'seat' || $type === 'folding') $seatCount++;
                        if ($type === 'driver') $driverCount++;
                        $rowCells[] = [
                            'type'   => $type,
                            'label'  => $cell['label'] ?? '',
                            'seat_id'=> $cell['seat_id'] ?? null,
                        ];
                    }
                    $cells[] = $rowCells;
                }

                $snapshot = [
                    'bus_plate'       => $request->bus_plate ?? '',
                    'bus_brand'       => $request->bus_brand ?? '',
                    'bus_category'    => $request->bus_category ?? '',
                    'total_rows'      => $totalRows,
                    'total_cols'      => $totalCols,
                    'aisle_after_col' => (int) ($request->aisle_after_col ?? 0),
                    'total_seats'     => $seatCount,
                    'driver_seats'    => $driverCount,
                    'grid'            => $cells,
                    'created_from'    => 'custom_builder',
                ];

                // Include upper deck if present
                if ($request->has('upper_grid')) {
                    $upperCells = [];
                    foreach ($request->upper_grid as $row) {
                        $rowCells = [];
                        foreach ((array) $row as $cell) {
                            $rowCells[] = [
                                'type'   => $cell['type'] ?? 'empty',
                                'label'  => $cell['label'] ?? '',
                                'seat_id'=> $cell['seat_id'] ?? null,
                            ];
                        }
                        $upperCells[] = $rowCells;
                    }
                    $snapshot['upper_grid'] = $upperCells;
                }

                $updates['current_snapshot'] = json_encode($snapshot);
                $updates['raw_grid_json'] = json_encode($cells);
                $updates['total_rows'] = $totalRows;
                $updates['left_columns'] = (int) ($request->aisle_after_col ?? 0);
                $updates['right_columns'] = $totalCols - (int) ($request->aisle_after_col ?? 0) - 1;
                $updates['driver_seats'] = $driverCount;
            }

            DB::table('transport_bus_layouts')
                ->where('id', $id)
                ->update($updates);

            Log::info('BusOwner: layout updated', ['layout_id' => $id]);

            return response()->json([
                'success' => true,
                'data'    => ['id' => $id, 'message' => 'Layout updated'],
            ]);
        } catch (\Exception $e) {
            Log::error('BusOwner - updateLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SEAT LAYOUTS — PUBLISH (delegated to LayoutService)
    // ═══════════════════════════════════════════════════════

    public function publishLayout(string $id, Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $identityId = $user->global_identity_id ?? null;

            // If no snapshot sent, load existing from DB (standard publish flow)
            $gridSnapshot = $request->input('grid_snapshot');
            $expectedVersion = (int) $request->input('expected_version', 0);

            if ($gridSnapshot === null) {
                $layout = DB::table('transport_bus_layouts')->where('id', $id)->first();
                if (!$layout) {
                    return response()->json(['success' => false, 'message' => 'Layout not found'], 404);
                }
                $gridSnapshot = json_decode($layout->current_snapshot ?? '{}', true) ?: [];
                $expectedVersion = $expectedVersion ?: (int) ($layout->version_number ?? 1);
            }

            $this->layouts->publishLayout(
                layoutId: $id,
                identityId: $identityId,
                gridSnapshot: $gridSnapshot,
                expectedVersion: $expectedVersion,
                changeDescription: $request->input('change_description'),
            );

            return response()->json([
                'success' => true,
                'message' => 'Layout published successfully.',
            ]);
        } catch (\RuntimeException $e) {
            $code = ($e->getMessage() === 'Layout not found') ? 404 : 409;
            return response()->json(['success' => false, 'message' => $e->getMessage()], $code);
        } catch (\Exception $e) {
            Log::error('BusOwner - publishLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SEAT LAYOUTS — DESTROY (delegated to LayoutService)
    // ═══════════════════════════════════════════════════════

    public function destroyLayout(string $id, Request $request): JsonResponse
    {
        try {
            $permanent = $request->query('permanent') === 'true';
            if ($permanent) {
                DB::table('transport_bus_layouts')->where('id', $id)->delete();
                Log::info('BusOwner: layout permanently deleted', ['layout_id' => $id]);
                return response()->json(['success' => true, 'message' => 'Layout permanently deleted.']);
            }

            $this->layouts->archiveLayout($id);
            return response()->json(['success' => true, 'message' => 'Layout archived.']);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => 'Layout not found'], 404);
        } catch (\Exception $e) {
            Log::error('BusOwner - destroyLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * DELETE /bus-owner/layouts/purge/all
     *
     * Purge ALL non-archived layouts owned by this identity.
     */
    public function purgeLayouts(Request $request): JsonResponse
    {
        try {
            $identityId = $this->ownerIdentityId($request);
            // Scope to this owner's layouts via owner_identity_id
            $count = DB::table('transport_bus_layouts')
                ->where('owner_identity_id', $identityId)
                ->where('layout_status', '!=', 'archived')
                ->count();

            DB::table('transport_bus_layouts')
                ->where('owner_identity_id', $identityId)
                ->where('layout_status', '!=', 'archived')
                ->update([
                    'layout_status' => 'archived',
                    'edit_lock_held_by' => null,
                    'edit_lock_expires_at' => null,
                    'updated_at' => now(),
                ]);

            Log::warning('BusOwner: bulk layout purge', [
                'identity_id' => $identityId,
                'count'       => $count,
            ]);

            return response()->json([
                'success'      => true,
                'message'      => "Purged {$count} layout(s).",
                'purged_count' => $count,
            ]);
        } catch (\Exception $e) {
            Log::error('BusOwner - purgeLayouts Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // LAYOUT PRESETS (delegated to LayoutService)
    // ═══════════════════════════════════════════════════════

    public function layoutPresets(): JsonResponse
    {
        try {
            $presets = $this->layouts->getPresets();
            return response()->json(['success' => true, 'data' => $presets]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
