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
 * All CRUD operations are scoped to the authenticated owner's
 * global_identity_id so owner data stays modular and ready for
 * future multi-company linking.
 *
 * Drivers and conductors are stored as fleet_assignments rows
 * with carrier_company_id = owner's tenant_account.id.
 * Seat layouts are stored in transport_bus_layouts with
 * owner_identity_id = owner's global_identity_id.
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

                // Update global_identities
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

                // Update tenant_accounts
                $taUpdates = ['updated_at' => now()];
                if (isset($data['name']))     $taUpdates['account_name'] = $data['name'];
                if (isset($data['email']))    $taUpdates['email']        = $data['email'];
                if (isset($data['phone']))    $taUpdates['phone_number'] = $data['phone'];
                if (isset($data['password'])) $taUpdates['password']     = Hash::make($data['password']);
                if (isset($data['status']))   $taUpdates['status']       = $data['status'];

                DB::table('tenant_accounts')
                    ->where('global_identity_id', $identityId)
                    ->update($taUpdates);

                // Update fleet_assignments meta
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
    // SEAT LAYOUTS — LIST
    // ═══════════════════════════════════════════════════════

    public function listLayouts(Request $request): JsonResponse
    {
        try {
            $identityId = $this->ownerIdentityId($request);

            $layouts = DB::table('transport_bus_layouts')
                ->where('owner_identity_id', $identityId)
                ->where('layout_status', '!=', 'archived')
                ->orderBy('updated_at', 'desc')
                ->get()
                ->map(function ($l) {
                    $snap = json_decode($l->current_snapshot ?? '{}', true) ?: [];
                    return [
                        'id'                => $l->id,
                        'display_name'      => $l->display_name ?? 'Untitled',
                        'vehicle_class'     => $l->vehicle_class ?? 'unknown',
                        'layout_status'     => $l->layout_status ?? 'draft',
                        'version_number'    => $l->version_number ?? 1,
                        'deck_level'        => $l->deck_level ?? 0,
                        'is_locked_sovereign' => $l->is_locked_sovereign ?? true,
                        'total_seats'       => $snap['total_seats'] ?? 0,
                        'created_at'        => $l->created_at,
                        'updated_at'        => $l->updated_at,
                    ];
                });

            return response()->json([
                'success' => true,
                'data'    => $layouts,
            ]);
        } catch (\Exception $e) {
            Log::error('BusOwner - listLayouts Error: ' . $e->getMessage());
            return response()->json(['success' => true, 'data' => []]);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SEAT LAYOUTS — STORE
    // ═══════════════════════════════════════════════════════

    public function storeLayout(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'vehicle_class'   => ['required', 'string', 'in:coach_54,standard_45,coaster_34,hiace_13,sleeper_custom'],
                'display_name'    => ['required', 'string', 'max:160'],
                'deck_level'      => ['nullable', 'integer', 'in:0,1'],
            ]);

            $identityId = $this->ownerIdentityId($request);
            $tenantId   = $this->ownerTenantId($request);

            $preset = $this->getPreset($data['vehicle_class']);
            $totalSeats = $preset['total_seats'] ?? 0;

            $snapshot = [
                'vehicle_class'  => $data['vehicle_class'],
                'total_seats'    => $totalSeats,
                'total_rows'     => $preset['rows'] ?? 0,
                'left_columns'   => $preset['left_cols'] ?? 0,
                'right_columns'  => $preset['right_cols'] ?? 0,
                'grid'           => [],
                'created_from'   => 'preset',
                'deck_level'     => $data['deck_level'] ?? 0,
            ];

            $layoutId = (string) Str::orderedUuid();

            DB::table('transport_bus_layouts')->insert([
                'id'                  => $layoutId,
                'owner_identity_id'   => $identityId,
                'carrier_company_id'  => $tenantId,
                'vehicle_class'       => $data['vehicle_class'],
                'display_name'        => $data['display_name'],
                'is_locked_sovereign' => true,
                'version_number'      => 1,
                'layout_status'       => 'draft',
                'current_snapshot'    => json_encode($snapshot),
                'deck_level'          => $data['deck_level'] ?? 0,
                'created_at'          => now(),
                'updated_at'          => now(),
            ]);

            Log::info('BusOwner: layout created', [
                'layout_id'  => $layoutId,
                'owner_id'   => $identityId,
                'class'      => $data['vehicle_class'],
            ]);

            return response()->json([
                'success' => true,
                'data'    => [
                    'id'                => $layoutId,
                    'display_name'      => $data['display_name'],
                    'vehicle_class'     => $data['vehicle_class'],
                    'layout_status'     => 'draft',
                    'version_number'    => 1,
                    'total_seats'       => $totalSeats,
                ],
            ], 201);

        } catch (\Exception $e) {
            Log::error('BusOwner - storeLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SEAT LAYOUTS — SHOW
    // ═══════════════════════════════════════════════════════

    public function showLayout(string $id): JsonResponse
    {
        try {
            $layout = DB::table('transport_bus_layouts')->where('id', $id)->first();

            if (!$layout) {
                return response()->json(['message' => 'Layout not found'], 404);
            }

            $snap = json_decode($layout->current_snapshot ?? '{}', true) ?: [];

            return response()->json([
                'success' => true,
                'data'    => [
                    'id'                  => $layout->id,
                    'display_name'        => $layout->display_name,
                    'vehicle_class'       => $layout->vehicle_class,
                    'layout_status'       => $layout->layout_status ?? 'draft',
                    'version_number'      => $layout->version_number ?? 1,
                    'deck_level'          => $layout->deck_level ?? 0,
                    'is_locked_sovereign' => $layout->is_locked_sovereign ?? true,
                    'total_seats'         => $snap['total_seats'] ?? 0,
                    'total_rows'          => $snap['total_rows'] ?? 0,
                    'left_columns'        => $snap['left_columns'] ?? 0,
                    'right_columns'       => $snap['right_columns'] ?? 0,
                    'grid'                => $snap['grid'] ?? [],
                    'created_at'          => $layout->created_at,
                    'updated_at'          => $layout->updated_at,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('BusOwner - showLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // SEAT LAYOUTS — UPDATE
    // ═══════════════════════════════════════════════════════

    public function updateLayout(string $id, Request $request): JsonResponse
    {
        try {
            $layout = DB::table('transport_bus_layouts')->where('id', $id)->first();
            if (!$layout) {
                return response()->json(['message' => 'Layout not found'], 404);
            }

            $data = $request->validate([
                'display_name'  => ['sometimes', 'string', 'max:160'],
                'vehicle_class' => ['sometimes', 'string', 'in:coach_54,standard_45,coaster_34,hiace_13,sleeper_custom'],
                'layout_status' => ['sometimes', 'string', 'in:draft,published,archived'],
            ]);

            $updates = ['updated_at' => now()];
            if (isset($data['display_name']))  $updates['display_name']  = $data['display_name'];
            if (isset($data['vehicle_class'])) $updates['vehicle_class'] = $data['vehicle_class'];
            if (isset($data['layout_status'])) $updates['layout_status'] = $data['layout_status'];

            // If vehicle_class changed, regenerate snapshot
            if (isset($data['vehicle_class']) && $data['vehicle_class'] !== $layout->vehicle_class) {
                $preset = $this->getPreset($data['vehicle_class']);
                $snap = json_decode($layout->current_snapshot ?? '{}', true) ?: [];
                $snap['vehicle_class'] = $data['vehicle_class'];
                $snap['total_seats']   = $preset['total_seats'] ?? 0;
                $snap['total_rows']    = $preset['rows'] ?? 0;
                $snap['left_columns']  = $preset['left_cols'] ?? 0;
                $snap['right_columns'] = $preset['right_cols'] ?? 0;
                $updates['current_snapshot'] = json_encode($snap);
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
    // SEAT LAYOUTS — DESTROY (archive)
    // ═══════════════════════════════════════════════════════

    public function destroyLayout(string $id): JsonResponse
    {
        try {
            $layout = DB::table('transport_bus_layouts')->where('id', $id)->first();
            if (!$layout) {
                return response()->json(['message' => 'Layout not found'], 404);
            }

            DB::table('transport_bus_layouts')
                ->where('id', $id)
                ->update([
                    'layout_status' => 'archived',
                    'updated_at'    => now(),
                ]);

            Log::info('BusOwner: layout archived', ['layout_id' => $id]);

            return response()->json([
                'success' => true,
                'message' => 'Layout archived.',
            ]);
        } catch (\Exception $e) {
            Log::error('BusOwner - destroyLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ═══════════════════════════════════════════════════════
    // LAYOUT PRESETS
    // ═══════════════════════════════════════════════════════

    public function layoutPresets(): JsonResponse
    {
        $presets = [
            ['key' => 'coach_54',     'label' => 'Coach 54-Seater',    'rows' => 14, 'left_cols' => 2, 'right_cols' => 2, 'total_seats' => 54],
            ['key' => 'standard_45',  'label' => 'Standard 45-Seater', 'rows' => 12, 'left_cols' => 2, 'right_cols' => 2, 'total_seats' => 45],
            ['key' => 'coaster_34',   'label' => 'Coaster 34-Seater',  'rows' => 9,  'left_cols' => 2, 'right_cols' => 2, 'total_seats' => 34],
            ['key' => 'hiace_13',     'label' => 'Hiace 13-Seater',    'rows' => 4,  'left_cols' => 2, 'right_cols' => 2, 'total_seats' => 13],
            ['key' => 'sleeper_custom','label' => 'Sleeper Custom',    'rows' => 10, 'left_cols' => 1, 'right_cols' => 1, 'total_seats' => 20],
        ];

        return response()->json(['success' => true, 'data' => $presets]);
    }

    /** Get a single preset by key. */
    private function getPreset(string $key): array
    {
        $map = [
            'coach_54'      => ['rows' => 14, 'left_cols' => 2, 'right_cols' => 2, 'total_seats' => 54],
            'standard_45'   => ['rows' => 12, 'left_cols' => 2, 'right_cols' => 2, 'total_seats' => 45],
            'coaster_34'    => ['rows' => 9,  'left_cols' => 2, 'right_cols' => 2, 'total_seats' => 34],
            'hiace_13'      => ['rows' => 4,  'left_cols' => 2, 'right_cols' => 2, 'total_seats' => 13],
            'sleeper_custom'=> ['rows' => 10, 'left_cols' => 1, 'right_cols' => 1, 'total_seats' => 20],
        ];

        return $map[$key] ?? ['rows' => 0, 'left_cols' => 0, 'right_cols' => 0, 'total_seats' => 0];
    }
}
