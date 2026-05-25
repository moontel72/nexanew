<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/**
 * NEXATRACE — FLEET MANAGEMENT CONTROLLER (v2)
 * Uses DB facade directly to avoid Eloquent model fillable/column issues.
 */

class FleetManagementController extends Controller
{
    private function companyId(Request $request): ?string
    {
        $user = $request->user();
        if (!$user) return null;
        $meta = $user->metadata;
        if (is_string($meta)) $meta = json_decode($meta, true);
        return is_array($meta) ? ($meta['company_id'] ?? null) : null;
    }

    // ═══════════════════ OWNERS ═══════════════════

    public function listOwners(Request $request): JsonResponse
    {
        try {
            $cid = $this->companyId($request);
            $perPage = (int) $request->input('per_page', 20);
            $perPage = max(1, min(100, $perPage));

            $query = DB::table('drivers')
                ->where('driver_type', 'bus')
                ->where('staff_type', 'owner');
            if ($cid) $query->where('company_id', $cid);
            if ($request->filled('search')) {
                $s = $request->search;
                $query->where(function($q) use ($s) {
                    $q->where('name', 'ilike', "%{$s}%")
                      ->orWhere('phone', 'ilike', "%{$s}%")
                      ->orWhere('email', 'ilike', "%{$s}%");
                });
            }
            $result = $query->orderBy('created_at', 'desc')->paginate($perPage);
            return response()->json(['success' => true, 'data' => $result]);
        } catch (\Exception $e) {
            Log::error('Fleet Management - listOwners Error: ' . $e->getMessage(), [
                'sql' => $e->getTraceAsString(),
                'user_id' => $request->user()?->id,
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function storeOwner(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:drivers,email',
            'phone' => 'required|string|max:50',
            'password' => 'required|string|min:8',
            'cnic' => 'nullable|string|max:30',
            'address' => 'nullable|string',
        ]);

        $id = (string) Str::uuid();
        DB::table('drivers')->insert([
            'id' => $id,
            'company_id' => $this->companyId($request),
            'driver_type' => 'bus',
            'staff_type' => 'owner',
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'],
            'password' => bcrypt($data['password']),
            'cnic' => $data['cnic'] ?? null,
            'address' => $data['address'] ?? null,
            'status' => 'active',
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $owner = DB::table('drivers')->find($id);
        return response()->json(['success' => true, 'data' => $owner], 201);
    }

    public function showOwner(string $id): JsonResponse
    {
        $owner = DB::table('drivers')->where('staff_type', 'owner')->find($id);
        if (!$owner) return response()->json(['message' => 'Not found'], 404);
        return response()->json(['success' => true, 'data' => $owner]);
    }

    public function updateOwner(string $id, Request $request): JsonResponse
    {
        $exists = DB::table('drivers')->where('staff_type', 'owner')->where('id', $id)->exists();
        if (!$exists) return response()->json(['message' => 'Not found'], 404);

        // Owners (Type A) — no salary, vehicle_plate, license, or hire_date
        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:drivers,email,'.$id,
            'phone' => 'sometimes|string|max:50',
            'password' => 'sometimes|string|min:8',
            'cnic' => 'nullable|string|max:30',
            'address' => 'nullable|string',
            'status' => 'sometimes|in:active,inactive,suspended',
        ]);

        $update = ['updated_at' => now()];
        foreach (['name','email','phone','cnic','address','status'] as $f) {
            if (array_key_exists($f, $data)) $update[$f] = $data[$f];
        }
        if (isset($data['password'])) $update['password'] = bcrypt($data['password']);

        DB::table('drivers')->where('id', $id)->update($update);
        return response()->json(['success' => true, 'data' => DB::table('drivers')->find($id)]);
    }

    public function destroyOwner(string $id): JsonResponse
    {
        DB::table('drivers')->where('staff_type', 'owner')->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }

    // ═══════════════════ DRIVERS ═══════════════════

    public function listDrivers(Request $request): JsonResponse
    {
        try {
            $cid = $this->companyId($request);
            $perPage = (int) $request->input('per_page', 20);
            $perPage = max(1, min(100, $perPage));

            $query = DB::table('drivers')
                ->where('driver_type', 'bus')
                ->where('staff_type', 'driver');
            if ($cid) $query->where('company_id', $cid);

            // owner_id filter: B (null) vs D (specific owner UUID)
            if ($request->has('owner_id')) {
                $oid = $request->input('owner_id');
                if ($oid === 'null' || $oid === '' || $oid === 'company') {
                    $query->whereNull('owner_id'); // Type B — Company Direct Drivers
                } else {
                    $query->where('owner_id', $oid); // Type D — Owner's Drivers
                }
            }

            if ($request->filled('search')) {
                $s = $request->search;
                $query->where(function($q) use ($s) {
                    $q->where('name', 'ilike', "%{$s}%")
                      ->orWhere('phone', 'ilike', "%{$s}%");
                });
            }
            $result = $query->orderBy('created_at', 'desc')->paginate($perPage);
            return response()->json(['success' => true, 'data' => $result]);
        } catch (\Exception $e) {
            Log::error('Fleet Management - listDrivers Error: ' . $e->getMessage(), [
                'sql' => $e->getTraceAsString(),
                'user_id' => $request->user()?->id,
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function storeDriver(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:50',
            'license_number' => 'required|string|max:100',
            'password' => 'required|string|min:8',
            'email' => 'nullable|email|unique:drivers,email',
            'cnic' => 'nullable|string|max:30',
            'address' => 'nullable|string',
            'vehicle_plate_number' => 'nullable|string|max:50',
            'salary' => 'nullable|numeric',
            'hire_date' => 'nullable|date',
            'owner_id' => 'nullable|uuid|exists:drivers,id', // D = Owner's Driver
        ]);

        $cid = $this->companyId($request);
        $ownerId = $data['owner_id'] ?? null;

        // If owner_id is provided (Type D), validate ownership scoping
        if ($ownerId) {
            $owner = DB::table('drivers')
                ->where('id', $ownerId)
                ->where('staff_type', 'owner')
                ->first();
            if (!$owner) {
                return response()->json(['message' => 'Invalid owner_id: not a bus owner'], 422);
            }
        }

        $id = (string) Str::uuid();
        DB::table('drivers')->insert([
            'id' => $id,
            'company_id' => $cid,
            'owner_id' => $ownerId,
            'driver_type' => 'bus',
            'staff_type' => 'driver',
            'name' => $data['name'],
            'phone' => $data['phone'],
            'email' => $data['email'] ?? null,
            'password' => bcrypt($data['password']),
            'license_number' => $data['license_number'],
            'cnic' => $data['cnic'] ?? null,
            'address' => $data['address'] ?? null,
            'vehicle_plate_number' => $data['vehicle_plate_number'] ?? null,
            'salary' => $data['salary'] ?? null,
            'hire_date' => $data['hire_date'] ?? null,
            'status' => 'active',
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'data' => DB::table('drivers')->find($id)], 201);
    }

    public function showDriver(string $id): JsonResponse
    {
        $d = DB::table('drivers')->where('staff_type', 'driver')->find($id);
        if (!$d) return response()->json(['message' => 'Not found'], 404);
        return response()->json(['success' => true, 'data' => $d]);
    }

    public function updateDriver(string $id, Request $request): JsonResponse
    {
        $driver = DB::table('drivers')->where('staff_type', 'driver')->where('id', $id)->first();
        if (!$driver) return response()->json(['message' => 'Not found'], 404);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:50',
            'license_number' => 'sometimes|string|max:100',
            'password' => 'sometimes|string|min:8',
            'email' => 'nullable|email|unique:drivers,email,'.$id,
            'cnic' => 'nullable|string|max:30',
            'address' => 'nullable|string',
            'vehicle_plate_number' => 'nullable|string|max:50',
            'salary' => 'nullable|numeric',
            'hire_date' => 'nullable|date',
            'owner_id' => 'nullable|uuid|exists:drivers,id',
            'status' => 'sometimes|in:active,inactive,suspended',
        ]);

        // If owner_id is provided, validate it references a valid owner
        if ($ownerId = ($data['owner_id'] ?? null)) {
            $owner = DB::table('drivers')
                ->where('id', $ownerId)
                ->where('staff_type', 'owner')
                ->first();
            if (!$owner) {
                return response()->json(['message' => 'Invalid owner_id: not a bus owner'], 422);
            }
        }

        $update = ['updated_at' => now()];
        foreach (['name','phone','email','license_number','cnic','address','vehicle_plate_number','salary','hire_date','owner_id','status'] as $f) {
            if (array_key_exists($f, $data)) $update[$f] = $data[$f];
        }
        if (isset($data['password'])) $update['password'] = bcrypt($data['password']);

        DB::table('drivers')->where('id', $id)->update($update);
        return response()->json(['success' => true, 'data' => DB::table('drivers')->find($id)]);
    }

    public function destroyDriver(string $id): JsonResponse
    {
        DB::table('drivers')->where('staff_type', 'driver')->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }

    // ═══════════════════ CONDUCTORS ═══════════════════

    public function listConductors(Request $request): JsonResponse
    {
        try {
            $cid = $this->companyId($request);
            $perPage = (int) $request->input('per_page', 20);
            $perPage = max(1, min(100, $perPage));

            $query = DB::table('drivers')
                ->where('driver_type', 'bus')
                ->where('staff_type', 'conductor');
            if ($cid) $query->where('company_id', $cid);

            // owner_id filter: C (null) vs E (specific owner UUID)
            if ($request->has('owner_id')) {
                $oid = $request->input('owner_id');
                if ($oid === 'null' || $oid === '' || $oid === 'company') {
                    $query->whereNull('owner_id'); // Type C — Company Direct Conductors
                } else {
                    $query->where('owner_id', $oid); // Type E — Owner's Conductors
                }
            }

            if ($request->filled('search')) {
                $s = $request->search;
                $query->where(function($q) use ($s) {
                    $q->where('name', 'ilike', "%{$s}%")
                      ->orWhere('phone', 'ilike', "%{$s}%");
                });
            }
            $result = $query->orderBy('created_at', 'desc')->paginate($perPage);
            return response()->json(['success' => true, 'data' => $result]);
        } catch (\Exception $e) {
            Log::error('Fleet Management - listConductors Error: ' . $e->getMessage(), [
                'sql' => $e->getTraceAsString(),
                'user_id' => $request->user()?->id,
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function storeConductor(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:50',
            'password' => 'required|string|min:8',
            'email' => 'nullable|email|unique:drivers,email',
            'cnic' => 'nullable|string|max:30',
            'address' => 'nullable|string',
            'salary' => 'nullable|numeric',
            'hire_date' => 'nullable|date',
            'owner_id' => 'nullable|uuid|exists:drivers,id', // E = Owner's Conductor
        ]);

        $cid = $this->companyId($request);
        $ownerId = $data['owner_id'] ?? null;

        // If owner_id is provided (Type E), validate ownership scoping
        if ($ownerId) {
            $owner = DB::table('drivers')
                ->where('id', $ownerId)
                ->where('staff_type', 'owner')
                ->first();
            if (!$owner) {
                return response()->json(['message' => 'Invalid owner_id: not a bus owner'], 422);
            }
        }

        $id = (string) Str::uuid();
        DB::table('drivers')->insert([
            'id' => $id,
            'company_id' => $cid,
            'owner_id' => $ownerId,
            'driver_type' => 'bus',
            'staff_type' => 'conductor',
            'name' => $data['name'],
            'phone' => $data['phone'],
            'email' => $data['email'] ?? null,
            'password' => bcrypt($data['password']),
            'cnic' => $data['cnic'] ?? null,
            'address' => $data['address'] ?? null,
            'salary' => $data['salary'] ?? null,
            'hire_date' => $data['hire_date'] ?? null,
            'status' => 'active',
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'data' => DB::table('drivers')->find($id)], 201);
    }

    public function showConductor(string $id): JsonResponse
    {
        $c = DB::table('drivers')->where('staff_type', 'conductor')->find($id);
        if (!$c) return response()->json(['message' => 'Not found'], 404);
        return response()->json(['success' => true, 'data' => $c]);
    }

    public function updateConductor(string $id, Request $request): JsonResponse
    {
        $conductor = DB::table('drivers')->where('staff_type', 'conductor')->where('id', $id)->first();
        if (!$conductor) return response()->json(['message' => 'Not found'], 404);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:50',
            'password' => 'sometimes|string|min:8',
            'email' => 'nullable|email|unique:drivers,email,'.$id,
            'cnic' => 'nullable|string|max:30',
            'address' => 'nullable|string',
            'salary' => 'nullable|numeric',
            'hire_date' => 'nullable|date',
            'owner_id' => 'nullable|uuid|exists:drivers,id',
            'status' => 'sometimes|in:active,inactive,suspended',
        ]);

        // If owner_id is provided, validate it references a valid owner
        if ($ownerId = ($data['owner_id'] ?? null)) {
            $owner = DB::table('drivers')
                ->where('id', $ownerId)
                ->where('staff_type', 'owner')
                ->first();
            if (!$owner) {
                return response()->json(['message' => 'Invalid owner_id: not a bus owner'], 422);
            }
        }

        $update = ['updated_at' => now()];
        foreach (['name','phone','email','cnic','address','salary','hire_date','owner_id','status'] as $f) {
            if (array_key_exists($f, $data)) $update[$f] = $data[$f];
        }
        if (isset($data['password'])) $update['password'] = bcrypt($data['password']);

        DB::table('drivers')->where('id', $id)->update($update);
        return response()->json(['success' => true, 'data' => DB::table('drivers')->find($id)]);
    }

    public function destroyConductor(string $id): JsonResponse
    {
        DB::table('drivers')->where('staff_type', 'conductor')->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }
}
