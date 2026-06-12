<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — FLEET MANAGEMENT CONTROLLER (v3 — Identity Spine)
 *
 * All CRUD for Owners, Drivers, and Conductors now routes through
 * the Wave 2 identity spine: global_identities → identity_claims →
 * fleet_assignments → tenant_accounts.
 *
 * Legacy drivers table references COMPLETELY REMOVED.
 * Deletion is soft-revoke (fleet_assignments.status = 'revoked').
 * No hard-deletes on identity rows.
 *
 * Section 10.1: Global Identity & Claims Spine.
 * Section 10.11.2: FleetAssignment state machine.
 */

class FleetManagementController extends Controller
{
    // ═══════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════

    /** Resolve the carrier company ID from the authenticated user's assignment. */
    private function carrierCompanyId(Request $request): ?string
    {
        // 1. Middleware-provided value wins
        $cid = $request->get('_carrier_company_id');
        if ($cid) return $cid;

        $user = $request->user();
        if (!$user) return null;

        // 2. Master admin sees ALL — no filter
        if (($user->account_type ?? null) === 'master_admin') {
            return null;
        }

        // 3. The user IS the carrier company tenant
        if (in_array($user->account_type ?? null, ['bus_company', 'truck_company'], true)) {
            return $user->id;
        }

        // 4. The user is an OWNER assigned TO a carrier — show that carrier's staff
        if (($user->global_identity_id ?? null)) {
            $cid = DB::table('fleet_assignments')
                ->where('global_identity_id', $user->global_identity_id)
                ->where('role', 'owner')
                ->where('fleet_type', $this->fleetType($request))
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->value('carrier_company_id');
            if ($cid) return $cid;
        }

        // 5. No resolution → DENY (returns zero rows, not all rows)
        return '00000000-0000-0000-0000-000000000000';
    }

    /** Detect fleet_type from request path. */
    private function fleetType(Request $request): string
    {
        return str_contains($request->path(), 'goods-fleet') ? 'truck' : 'bus';
    }

    /** Map a staff-type string to the fleet_assignments role enum. */
    private function roleFor(string $staffType): string
    {
        return match ($staffType) {
            'owners'      => 'owner',
            'drivers'     => 'driver',
            'conductors'  => 'conductor',
            default       => $staffType,
        };
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
            'hire_date'           => $row->hire_date ?? null,
            'kyc_status'          => $row->kyc_status ?? 'unverified',
            'kyc_tier'            => $row->kyc_tier ?? 0,
            'owner_company_id'    => $row->carrier_company_id ?? null,
            'owner_company_name'  => $row->owner_company_name ?? null,
            'created_at'          => $row->created_at ?? null,
            'updated_at'          => $row->updated_at ?? null,
        ];
    }

    // ═══════════════════════════════════════════════════════
    // BASE QUERY — fleet_assignments JOIN global_identities
    // ═══════════════════════════════════════════════════════

    private function baseQuery(Request $request, string $staffType)
    {
        $role = $this->roleFor($staffType);
        $fleetType = $this->fleetType($request);
        $cid = $this->carrierCompanyId($request);

        $query = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->leftJoin('tenant_accounts AS ta', 'gi.id', '=', 'ta.global_identity_id')
            ->leftJoin('tenant_accounts AS owner_ta', 'fa.carrier_company_id', '=', 'owner_ta.id')
            ->where('fa.role', $role)
            ->where('fa.fleet_type', $fleetType)
            ->whereIn('fa.status', ['active', 'pending_acceptance', 'suspended']);

        if ($cid) {
            // R-5 Fix: Expand carrier filter to include delegated owners'
            // staff via active tenant_allowance_grants (Section 10.4).
            // Radhnal admin sees: own staff + staff of all linked owners
            // where an active 'fleet.staff' grant exists.
            // Use inner join to tenant_accounts to resolve owner_identity_id → tenant_id
            $delegatedTenantIds = DB::table('tenant_allowance_grants AS tag')
                ->join('tenant_accounts AS ta2', 'tag.owner_identity_id', '=', 'ta2.global_identity_id')
                ->where('tag.carrier_company_id', $cid)
                ->where('tag.permission_key', 'fleet.staff')
                ->where(function ($q) {
                    $q->whereNull('tag.expires_at')
                      ->orWhere('tag.expires_at', '>', now());
                })
                ->pluck('ta2.id')
                ->toArray();

            $allCarrierIds = array_values(array_unique(array_merge([$cid], $delegatedTenantIds)));
            $query->whereIn('fa.carrier_company_id', $allCarrierIds);
        }

        return $query->select(
            'fa.id AS assignment_id',
            'fa.carrier_company_id',
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
            'owner_ta.account_name AS owner_company_name',
        );
    }

    // ═══════════════════════════════════════════════════════
    // LIST
    // ═══════════════════════════════════════════════════════

    public function listOwners(Request $request): JsonResponse
    {
        return $this->listStaff($request, 'owners');
    }

    public function listDrivers(Request $request): JsonResponse
    {
        return $this->listStaff($request, 'drivers');
    }

    public function listConductors(Request $request): JsonResponse
    {
        return $this->listStaff($request, 'conductors');
    }

    private function listStaff(Request $request, string $type): JsonResponse
    {
        try {
            $perPage = (int) $request->input('per_page', 20);
            $perPage = max(1, min(100, $perPage));

            $query = $this->baseQuery($request, $type);

            if ($request->filled('search')) {
                $s = $request->search;
                $query->where(function ($q) use ($s) {
                    $q->where('gi.display_name', 'ilike', "%{$s}%")
                      ->orWhere('ta.phone_number', 'ilike', "%{$s}%")
                      ->orWhere('ta.email', 'ilike', "%{$s}%");
                });
            }

            $result = $query->orderBy('fa.created_at', 'desc')->paginate($perPage);

            $data = $result->getCollection()->map(fn ($row) => $this->formatRow($row))->toArray();

            return response()->json([
                'success' => true,
                'data'    => [
                    'data'  => $data,
                    'total' => $result->total(),
                    'current_page' => $result->currentPage(),
                    'per_page'     => $result->perPage(),
                    'last_page'    => $result->lastPage(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('FleetManagement - listStaff Error: ' . $e->getMessage(), [
                'type'    => $type,
                'user_id' => $request->user()?->id,
                'sql'     => $e->getMessage(),
            ]);
            // Fallback: return empty list instead of 500
            return response()->json([
                'success' => true,
                'data'    => ['data' => [], 'total' => 0, 'current_page' => 1, 'per_page' => $perPage, 'last_page' => 1],
            ]);
        }
    }

    // ═══════════════════════════════════════════════════════
    // STORE (Create) — identity spine onboarding
    // ═══════════════════════════════════════════════════════

    public function storeOwner(Request $request): JsonResponse
    {
        return $this->storeStaff($request, 'owner');
    }

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
            $isOwner  = ($role === 'owner');
            $isConductor = ($role === 'conductor');

            $rules = [
                'name'     => ['required', 'string', 'max:255'],
                'email'    => ['required', 'email'],
                'phone'    => ['required', 'string', 'max:50'],
                'password' => ['required', 'string', 'min:8'],
                'cnic'     => ['nullable', 'string', 'max:30'],
                'address'  => ['nullable', 'string', 'max:500'],
            ];
            if ($isDriver || $isConductor) {
                if ($isDriver) {
                    $rules['license_number'] = ['required', 'string', 'max:100'];
                }
                $rules['vehicle_plate'] = ['nullable', 'string', 'max:50'];
                $rules['salary']        = ['nullable', 'numeric', 'min:0'];
            }

            $data = $request->validate($rules);

            $cid   = $this->carrierCompanyId($request);
            $fleet = $this->fleetType($request);

            // Use DB transaction to guarantee atomic spine creation
            DB::beginTransaction();
            try {

                // 1. Create GlobalIdentity (Layer 1)
                $identityId = (string) Str::orderedUuid();
                $token = \App\Models\GlobalIdentity::generateToken(
                    match ($role) {
                        'owner'      => 'owner',
                        'driver'     => 'driver',
                        'conductor'  => 'conductor',
                        default      => null,
                    }
                );

                DB::table('global_identities')->insert([
                    'id'             => $identityId,
                    'identity_token' => $token,
                    'display_name'   => $data['name'],
                    'password_hash'  => Hash::make($data['password']),
                    'kyc_status'     => 'unverified',
                    'kyc_tier'       => 0,
                    'status'         => 'active',
                    'identity_type'  => match ($role) {
                        'owner'      => 'owner',
                        'driver'     => 'driver',
                        'conductor'  => 'conductor',
                        default      => 'mixed',
                    },
                    'risk_score'     => 0.00,
                    'created_at'     => now(),
                    'updated_at'     => now(),
                ]);

                // 2. Create IdentityClaim — email (Layer 2)
                $claimId = (string) Str::orderedUuid();
                $rawHash = hash('sha256', strtolower($data['email']), true);

                DB::table('identity_claims')->insert([
                    'id'                 => $claimId,
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

                // 3. Create IdentityClaim — phone
                if (!empty($data['phone'])) {
                    $phoneClaimId = (string) Str::orderedUuid();
                    $phoneHash = hash('sha256', $data['phone'], true);
                    DB::table('identity_claims')->insert([
                        'id'                 => $phoneClaimId,
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

                // 4. Create TenantAccount (organizational bridge)
                $tenantId = (string) Str::orderedUuid();
                DB::table('tenant_accounts')->insert([
                    'id'                  => $tenantId,
                    'global_identity_id'  => $identityId,
                    'account_name'        => $data['name'],
                    'email'               => $data['email'],
                    'password'            => Hash::make($data['password']),
                    'phone_number'        => $data['phone'],
                    'is_independent'      => $isOwner,
                    'account_type'        => $fleet === 'bus'
                        ? ($isOwner ? 'bus_owner' : ($isDriver ? 'bus_driver' : 'bus_conductor'))
                        : ($isOwner ? 'truck_owner' : ($isDriver ? 'truck_driver' : 'truck_conductor')),
                    'status'              => 'active',
                    'created_at'          => now(),
                    'updated_at'          => now(),
                ]);

                // 5. Create FleetAssignment (Layer 3 — the binding)
                $assignmentId = (string) Str::orderedUuid();
                $meta = [];
                if ($isDriver || $isConductor) {
                    if ($isDriver) {
                        $meta['license_number'] = $data['license_number'] ?? null;
                    }
                    $meta['vehicle_plate']  = $data['vehicle_plate'] ?? null;
                    $meta['salary']         = $data['salary'] ?? null;
                }
                if (!empty($data['cnic'])) {
                    $meta['cnic'] = $data['cnic'];
                }
                if (!empty($data['address'])) {
                    $meta['address'] = $data['address'];
                }

                DB::table('fleet_assignments')->insert([
                    'id'                  => $assignmentId,
                    'global_identity_id'  => $identityId,
                    'carrier_company_id'  => $cid,
                    'role'                => $role,
                    'fleet_type'          => $fleet,
                    'status'              => 'active',
                    'assignment_meta'     => json_encode($meta),
                    'accepted_at'         => now(),
                    'created_at'          => now(),
                    'updated_at'          => now(),
                ]);

                DB::commit();

                Log::info('FleetManagement: staff created via identity spine', [
                    'identity_id'  => $identityId,
                    'assignment_id'=> $assignmentId,
                    'role'         => $role,
                    'fleet'        => $fleet,
                    'company_id'   => $cid,
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
                        'fleet_type'         => $fleet,
                        'status'             => 'active',
                    ],
                ], 201);

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }
        } catch (\Exception $e) {
            Log::error('FleetManagement - storeStaff Error: ' . $e->getMessage(), [
                'role'    => $role,
                'user_id' => $request->user()?->id,
                'trace'   => $e->getTraceAsString(),
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SHOW (single)
    // ═══════════════════════════════════════════════════════

    public function showOwner(string $id): JsonResponse
    {
        return $this->showStaff($id, 'owner');
    }

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
                    'fa.accepted_at',
                    'fa.unassigned_at',
                    'fa.unassign_reason',
                    'fa.created_at',
                    'fa.updated_at',
                    'ta.email',
                    'ta.phone_number AS phone',
                    'ta.account_name',
                )
                ->first();

            if (!$row) {
                return response()->json(['message' => 'Not found'], 404);
            }

            return response()->json(['success' => true, 'data' => $this->formatRow($row)]);
        } catch (\Exception $e) {
            Log::error('FleetManagement - showStaff Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // UPDATE
    // ═══════════════════════════════════════════════════════

    public function updateOwner(string $id, Request $request): JsonResponse
    {
        return $this->updateStaff($id, $request, 'owner');
    }

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
                'name'    => ['sometimes', 'string', 'max:255'],
                'email'   => ['sometimes', 'email'],
                'phone'   => ['sometimes', 'string', 'max:50'],
                'password'=> ['sometimes', 'string', 'min:8'],
                'cnic'    => ['nullable', 'string', 'max:30'],
                'address' => ['nullable', 'string', 'max:500'],
                'status'  => ['sometimes', 'string', 'in:active,suspended,pending_acceptance'],
            ];
            if ($isDriver || $role === 'conductor') {
                if ($isDriver) {
                    $rules['license_number'] = ['sometimes', 'string', 'max:100'];
                }
                $rules['vehicle_plate'] = ['nullable', 'string', 'max:50'];
                $rules['salary']        = ['nullable', 'numeric', 'min:0'];
            }
            $data = $request->validate($rules);

            DB::beginTransaction();
            try {
                $identityId = $assignment->global_identity_id;

                // Update global_identities display_name
                if (isset($data['name'])) {
                    DB::table('global_identities')
                        ->where('id', $identityId)
                        ->update([
                            'display_name' => $data['name'],
                            'updated_at'   => now(),
                        ]);
                }

                // Update password on global_identities
                if (isset($data['password'])) {
                    DB::table('global_identities')
                        ->where('id', $identityId)
                        ->update([
                            'password_hash' => Hash::make($data['password']),
                            'updated_at'    => now(),
                        ]);
                }

                // Sync to tenant_accounts
                $taUpdates = ['updated_at' => now()];
                if (isset($data['name'])) $taUpdates['account_name'] = $data['name'];
                if (isset($data['email'])) $taUpdates['email'] = $data['email'];
                if (isset($data['phone'])) $taUpdates['phone_number'] = $data['phone'];
                if (isset($data['password'])) $taUpdates['password'] = Hash::make($data['password']);
                if (isset($data['status'])) $taUpdates['status'] = $data['status'];

                DB::table('tenant_accounts')
                    ->where('global_identity_id', $identityId)
                    ->update($taUpdates);

                // Update fleet_assignments assignment_meta
                $meta = json_decode($assignment->assignment_meta ?? '{}', true) ?: [];
                if ($isDriver || $role === 'conductor') {
                    if ($isDriver && isset($data['license_number'])) $meta['license_number'] = $data['license_number'];
                    if (isset($data['vehicle_plate']))  $meta['vehicle_plate']  = $data['vehicle_plate'];
                    if (isset($data['salary']))         $meta['salary']         = $data['salary'];
                }
                if (isset($data['cnic']))    $meta['cnic']    = $data['cnic'];
                if (isset($data['address'])) $meta['address'] = $data['address'];

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

                Log::info('FleetManagement: staff updated', [
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
            Log::error('FleetManagement - updateStaff Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // IDENTITY PORTABILITY — LINK REQUEST MANAGEMENT (§10.11.2)
    // ═══════════════════════════════════════════════════════

    /**
     * GET /api/v1/bus-fleet/link-requests
     *
     * List all pending owner link requests targeting this carrier.
     * Used by Bus Company admins to review and approve/reject
     * independent owners who want to join their fleet.
     */
    public function listLinkRequests(Request $request): JsonResponse
    {
        try {
            $cid = $this->carrierCompanyId($request);
            if (!$cid || $cid === '00000000-0000-0000-0000-000000000000') {
                return response()->json(['message' => 'No carrier context'], 403);
            }

            $perPage = (int) $request->input('per_page', 20);
            $perPage = max(1, min(100, $perPage));

            $query = DB::table('fleet_assignments AS fa')
                ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
                ->leftJoin('tenant_accounts AS ta', 'gi.id', '=', 'ta.global_identity_id')
                ->where('fa.carrier_company_id', $cid)
                ->where('fa.role', 'owner')
                ->where('fa.fleet_type', 'bus')
                ->whereIn('fa.status', ['pending_acceptance', 'on_hold'])
                ->select(
                    'fa.id AS assignment_id',
                    'gi.id AS global_identity_id',
                    'gi.identity_token',
                    'gi.display_name',
                    'gi.identity_type',
                    'gi.kyc_status',
                    'gi.kyc_tier',
                    'fa.assignment_meta',
                    'fa.created_at',
                    'ta.email',
                    'ta.phone_number AS phone',
                    'ta.account_name',
                );

            if ($request->filled('search')) {
                $s = $request->search;
                $query->where(function ($q) use ($s) {
                    $q->where('gi.display_name', 'ilike', "%{$s}%")
                      ->orWhere('ta.phone_number', 'ilike', "%{$s}%")
                      ->orWhere('ta.email', 'ilike', "%{$s}%");
                });
            }

            $result = $query->orderBy('fa.created_at', 'desc')->paginate($perPage);

            $data = $result->getCollection()->map(function ($row) {
                $meta = json_decode($row->assignment_meta ?? '{}', true) ?: [];
                return [
                    'assignment_id'      => $row->assignment_id,
                    'global_identity_id' => $row->global_identity_id,
                    'identity_token'     => $row->identity_token,
                    'identity_type'      => $row->identity_type ?? null,
                    'name'               => $row->display_name ?? '—',
                    'email'              => $row->email,
                    'phone'              => $row->phone,
                    'kyc_status'         => $row->kyc_status,
                    'kyc_tier'           => $row->kyc_tier,
                    'message'            => $meta['link_message'] ?? null,
                    'source'             => $meta['source'] ?? 'unknown',
                    'requested_at'       => $row->created_at,
                ];
            })->toArray();

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
            Log::error('FleetManagement - listLinkRequests Error: ' . $e->getMessage());
            return response()->json(['success' => true, 'data' => ['data' => [], 'total' => 0]]);
        }
    }

    /**
     * POST /api/v1/bus-fleet/link-requests/{id}/accept
     *
     * Bus Company admin accepts a pending owner link request.
     * Promotes assignment from pending_acceptance → active and
     * auto-creates tenant_allowance_grants so the carrier can
     * see the delegated owner's staff and seat layouts.
     */
    public function acceptLinkRequest(string $assignmentId, Request $request): JsonResponse
    {
        try {
            $cid = $this->carrierCompanyId($request);
            if (!$cid || $cid === '00000000-0000-0000-0000-000000000000') {
                return response()->json(['message' => 'No carrier context'], 403);
            }

            $assignment = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->where('role', 'owner')
                ->where('fleet_type', 'bus')
                ->first();

            if (!$assignment) {
                return response()->json(['message' => 'Link request not found'], 404);
            }

            if ($assignment->carrier_company_id !== $cid) {
                return response()->json(['message' => 'This link request is not for your company'], 403);
            }

            if (!in_array($assignment->status, ['pending_acceptance', 'on_hold'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'This link request is no longer pending (current status: ' . $assignment->status . ').',
                ], 422);
            }

            $ownerIdentityId = $assignment->global_identity_id;

            DB::beginTransaction();
            try {
                // Step 1: Promote assignment to active
                DB::table('fleet_assignments')
                    ->where('id', $assignmentId)
                    ->update([
                        'status'      => 'active',
                        'accepted_at' => now(),
                        'updated_at'  => now(),
                    ]);

                // Step 2: Auto-create allowance matrix so carrier can see owner's staff & layouts
                $existingMatrix = DB::table('tenant_allowance_matrix')
                    ->where('owner_identity_id', $ownerIdentityId)
                    ->where('carrier_company_id', $cid)
                    ->first();

                if (!$existingMatrix) {
                    $matrixId = (string) Str::orderedUuid();
                    DB::table('tenant_allowance_matrix')->insert([
                        'id'                  => $matrixId,
                        'owner_identity_id'   => $ownerIdentityId,
                        'carrier_company_id'  => $cid,
                        'permissions_blob'    => json_encode([
                            'fleet.staff' => 'view',
                            'seat_layout' => 'view',
                        ]),
                        'status'              => 'active',
                        'created_at'          => now(),
                        'updated_at'          => now(),
                    ]);

                    // Materialize grants via Eloquent model observer
                    $matrix = \App\Models\TenantAllowanceMatrix::find($matrixId);
                    if ($matrix) {
                        $matrix->syncProjection();
                    }
                }

                DB::commit();

                Log::info('FleetManagement: link request accepted', [
                    'assignment_id'      => $assignmentId,
                    'owner_identity_id'  => $ownerIdentityId,
                    'carrier_company_id' => $cid,
                ]);

                return response()->json([
                    'success' => true,
                    'data'    => [
                        'assignment_id' => $assignmentId,
                        'status'        => 'active',
                        'message'       => 'Link request accepted. Owner is now linked to your company with view access to their staff and layouts.',
                    ],
                ]);

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('FleetManagement - acceptLinkRequest Error: ' . $e->getMessage(), [
                'assignment_id' => $assignmentId,
                'trace'         => $e->getTraceAsString(),
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * POST /api/v1/bus-fleet/link-requests/{id}/hold
     *
     * Bus Company admin places a pending link request on hold.
     */
    public function holdLinkRequest(string $assignmentId, Request $request): JsonResponse
    {
        try {
            $cid = $this->carrierCompanyId($request);
            if (!$cid || $cid === '00000000-0000-0000-0000-000000000000') {
                return response()->json(['message' => 'No carrier context'], 403);
            }

            $assignment = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->where('role', 'owner')
                ->where('fleet_type', 'bus')
                ->first();

            if (!$assignment) {
                return response()->json(['message' => 'Link request not found'], 404);
            }

            if ($assignment->carrier_company_id !== $cid) {
                return response()->json(['message' => 'This link request is not for your company'], 403);
            }

            if ($assignment->status !== 'pending_acceptance') {
                return response()->json([
                    'success' => false,
                    'message' => 'This link request is no longer pending.',
                ], 422);
            }

            DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->update([
                    'status'     => 'on_hold',
                    'updated_at' => now(),
                ]);

            // Persist hold reason as permanent message for 60-day retention
            $reason = $request->input('message_body', 'Request placed on hold by carrier admin');
            $this->saveSystemMessage($assignmentId, $assignment->global_identity_id, $reason, 'hold_reason');

            Log::info('FleetManagement: link request put on hold', [
                'assignment_id' => $assignmentId,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Link request placed on hold.',
            ]);

        } catch (\Exception $e) {
            Log::error('FleetManagement - holdLinkRequest Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * POST /api/v1/bus-fleet/link-requests/{id}/reject
     *
     * Bus Company admin rejects a pending owner link request.
     */
    public function rejectLinkRequest(string $assignmentId, Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'reason' => ['nullable', 'string', 'max:500'],
            ]);

            $cid = $this->carrierCompanyId($request);
            if (!$cid || $cid === '00000000-0000-0000-0000-000000000000') {
                return response()->json(['message' => 'No carrier context'], 403);
            }

            $assignment = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->where('role', 'owner')
                ->where('fleet_type', 'bus')
                ->first();

            if (!$assignment) {
                return response()->json(['message' => 'Link request not found'], 404);
            }

            if ($assignment->carrier_company_id !== $cid) {
                return response()->json(['message' => 'This link request is not for your company'], 403);
            }

            if (!in_array($assignment->status, ['pending_acceptance', 'on_hold'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'This link request is no longer pending.',
                ], 422);
            }

            DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->update([
                    'status'          => 'revoked',
                    'unassigned_at'   => now(),
                    'unassign_reason' => $data['reason'] ?? 'Rejected by carrier admin',
                    'updated_at'      => now(),
                ]);

            // Persist rejection reason as permanent message for 60-day retention
            if (!empty($data['reason'])) {
                $this->saveSystemMessage($assignmentId, $assignment->global_identity_id, $data['reason'], 'rejection_reason');
            }

            Log::info('FleetManagement: link request rejected', [
                'assignment_id' => $assignmentId,
                'reason'        => $data['reason'] ?? 'No reason provided',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Link request rejected.',
            ]);

        } catch (\Exception $e) {
            Log::error('FleetManagement - rejectLinkRequest Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // LINK MESSAGES — Persistent B2B Chat
    // ═══════════════════════════════════════════════════════

    public function listMessages(string $assignmentId, Request $request): JsonResponse
    {
        try {
            $cid = $this->carrierCompanyId($request);
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

    public function listAllConversations(Request $request): JsonResponse
    {
        try {
            $cid = $this->carrierCompanyId($request);

            // Get all assignments (active + pending + on_hold) for this carrier
            // with the latest message from each
            $assignments = DB::table('fleet_assignments AS fa')
                ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
                ->leftJoin('tenant_accounts AS ta', 'gi.id', '=', 'ta.global_identity_id')
                ->where('fa.carrier_company_id', $cid)
                ->where('fa.role', 'owner')
                ->where('fa.fleet_type', 'bus')
                ->whereIn('fa.status', ['active', 'pending_acceptance', 'on_hold'])
                ->select(
                    'fa.id AS assignment_id',
                    'gi.id AS global_identity_id',
                    'gi.identity_token',
                    'gi.display_name',
                    'gi.kyc_status',
                    'fa.status',
                    'fa.created_at AS linked_at',
                    'ta.email',
                    'ta.phone_number AS phone',
                    'ta.account_name'
                )
                ->orderBy('fa.created_at', 'desc')
                ->limit(100)
                ->get()
                ->map(function ($row) {
                    // Get latest message for this assignment
                    $latest = DB::table('fleet_assignment_messages')
                        ->where('fleet_assignment_id', $row->assignment_id)
                        ->orderBy('created_at', 'desc')
                        ->first();

                    // Count total messages
                    $count = DB::table('fleet_assignment_messages')
                        ->where('fleet_assignment_id', $row->assignment_id)
                        ->count();

                    return [
                        'assignment_id'      => $row->assignment_id,
                        'global_identity_id' => $row->global_identity_id,
                        'identity_token'     => $row->identity_token,
                        'name'               => $row->display_name ?? '—',
                        'email'              => $row->email,
                        'phone'              => $row->phone,
                        'kyc_status'         => $row->kyc_status,
                        'status'             => $row->status,
                        'linked_at'          => $row->linked_at,
                        'account_name'       => $row->account_name,
                        'message_count'      => $count,
                        'latest_message'     => $latest ? [
                            'id'           => $latest->id,
                            'message_body' => $latest->message_body,
                            'context_type' => $latest->context_type,
                            'created_at'   => $latest->created_at,
                        ] : null,
                    ];
                });

            return response()->json(['success' => true, 'data' => $assignments]);
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
    // DESTROY — Soft-revoke (NOT hard-delete)
    // ═══════════════════════════════════════════════════════

    private function saveSystemMessage(string $assignmentId, ?string $ownerIdentityId, string $body, string $contextType): void
    {
        DB::table('fleet_assignment_messages')->insert([
            'id'                  => (string) Str::orderedUuid(),
            'fleet_assignment_id' => $assignmentId,
            'owner_identity_id'   => $ownerIdentityId,
            'sender_id'           => auth()->user()->global_identity_id ?? auth()->id(),
            'message_body'        => $body,
            'context_type'        => $contextType,
            'created_at'          => now(),
            'updated_at'          => now(),
        ]);
    }

    public function destroyOwner(string $id): JsonResponse
    {
        return $this->destroyStaff($id, 'owner');
    }

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

            // Soft-revoke: set status to 'revoked' — identity spine is NEVER hard-deleted
            DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->update([
                    'status'          => 'revoked',
                    'unassigned_at'   => now(),
                    'unassign_reason' => 'Revoked by fleet admin',
                    'updated_at'      => now(),
                ]);

            Log::info('FleetManagement: staff assignment revoked', [
                'assignment_id' => $assignmentId,
                'identity_id'   => $assignment->global_identity_id,
                'role'          => $role,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Staff assignment revoked. Identity preserved.',
            ]);
        } catch (\Exception $e) {
            Log::error('FleetManagement - destroyStaff Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }
}
