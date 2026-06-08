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
    // SEAT LAYOUTS — UPDATE (metadata only)
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
