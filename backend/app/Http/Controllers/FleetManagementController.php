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
        // BusFleetGate middleware attaches this
        return $request->get('_carrier_company_id');
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
        return [
            'id'                  => $row->assignment_id ?? $row->id ?? null,
            'global_identity_id'  => $row->global_identity_id ?? null,
            'identity_token'      => $row->identity_token ?? null,
            'name'                => $row->display_name ?? $row->account_name ?? '—',
            'email'               => $row->email ?? null,
            'phone'               => $row->phone ?? null,
            'cnic'                => $row->cnic ?? null,
            'address'             => $row->address ?? null,
            'role'                => $row->role ?? null,
            'fleet_type'          => $row->fleet_type ?? null,
            'status'              => $row->status ?? 'active',
            'license_number'      => $row->license_number ?? null,
            'vehicle_plate'       => $row->vehicle_plate ?? null,
            'salary'              => $row->salary ?? null,
            'hire_date'           => $row->hire_date ?? null,
            'kyc_status'          => $row->kyc_status ?? 'unverified',
            'kyc_tier'            => $row->kyc_tier ?? 0,
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
            ->where('fa.role', $role)
            ->where('fa.fleet_type', $fleetType)
            ->whereIn('fa.status', ['active', 'pending_acceptance', 'suspended']);

        if ($cid) {
            $query->where('fa.carrier_company_id', $cid);
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
                'trace'   => $e->getTraceAsString(),
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
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

            $rules = [
                'name'     => ['required', 'string', 'max:255'],
                'email'    => ['required', 'email'],
                'phone'    => ['required', 'string', 'max:50'],
                'password' => ['required', 'string', 'min:8'],
                'cnic'     => ['nullable', 'string', 'max:30'],
                'address'  => ['nullable', 'string', 'max:500'],
            ];
            if ($isDriver) {
                $rules['license_number'] = ['required', 'string', 'max:100];
                $rules['vehicle_plate']  = ['nullable', 'string', 'max:50];
                $rules['salary']         = ['nullable', 'numeric', 'min:0'];
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
                if ($isDriver) {
                    $meta['license_number'] = $data['license_number'] ?? null;
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
                'password'=> ['sometimes', 'string', 'min:8],
                'cnic'    => ['nullable', 'string', 'max:30'],
                'address' => ['nullable', 'string', 'max:500'],
                'status'  => ['sometimes', 'string', 'in:active,suspended,pending_acceptance'],
            ];
            if ($isDriver) {
                $rules['license_number'] = ['sometimes', 'string', 'max:100];
                $rules['vehicle_plate']  = ['nullable', 'string', 'max:50];
                $rules['salary']         = ['nullable', 'numeric', 'min:0'];
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
                if ($isDriver) {
                    if (isset($data['license_number'])) $meta['license_number'] = $data['license_number'];
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
    // DESTROY — Soft-revoke (NOT hard-delete)
    // ═══════════════════════════════════════════════════════

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
