<?php

namespace App\Http\Controllers;

use App\Models\Driver;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/**
 * NEXATRACE — FLEET MANAGEMENT CONTROLLER
 * =========================================
 *
 * CRUD for Bus Owners, Bus Drivers, and Bus Conductors.
 * All staff belong to a parent bus-fleet Company.
 *
 * Routes: /api/v1/bus-fleet/owners/*
 *         /api/v1/bus-fleet/drivers/manage/*
 *         /api/v1/bus-fleet/conductors/*
 */

class FleetManagementController extends Controller
{
    // ═══════════════════════════════════════════════════
    // BUS OWNERS
    // ═══════════════════════════════════════════════════

    public function listOwners(Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = $this->resolveCompanyId($user);

        $owners = Driver::where('driver_type', 'bus')
            ->where('staff_type', 'owner')
            ->when($companyId, fn($q) => $q->where('company_id', $companyId))
            ->when($request->search, fn($q, $s) => $q->where(fn($q2) =>
                $q2->where('name', 'ilike', "%{$s}%")
                  ->orWhere('phone', 'ilike', "%{$s}%")
                  ->orWhere('email', 'ilike', "%{$s}%")
            ))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $owners]);
    }

    public function storeOwner(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'     => ['required', 'string', 'max:255'],
            'email'    => ['required', 'email', 'unique:drivers,email'],
            'phone'    => ['required', 'string', 'max:50'],
            'password' => ['required', 'string', 'min:8'],
            'cnic'     => ['nullable', 'string', 'max:30'],
            'address'  => ['nullable', 'string'],
            'license_number'  => ['nullable', 'string', 'max:100'],
            'vehicle_plate_number' => ['nullable', 'string', 'max:50'],
            'salary'   => ['nullable', 'numeric'],
            'hire_date' => ['nullable', 'date'],
        ]);

        $user = $request->user();
        $companyId = $this->resolveCompanyId($user);

        $owner = Driver::create([
            'id'           => (string) Str::uuid(),
            'company_id'   => $companyId,
            'driver_type'  => 'bus',
            'staff_type'   => 'owner',
            'name'         => $data['name'],
            'email'        => $data['email'],
            'phone'        => $data['phone'],
            'password'     => $data['password'],
            'cnic'         => $data['cnic'] ?? null,
            'address'      => $data['address'] ?? null,
            'license_number'       => $data['license_number'] ?? null,
            'vehicle_plate_number'  => $data['vehicle_plate_number'] ?? null,
            'salary'       => $data['salary'] ?? null,
            'hire_date'    => $data['hire_date'] ?? null,
            'status'       => 'active',
            'is_active'    => true,
        ]);

        return response()->json(['success' => true, 'data' => $owner], 201);
    }

    public function showOwner(string $id, Request $request): JsonResponse
    {
        $owner = Driver::where('staff_type', 'owner')->findOrFail($id);
        return response()->json(['success' => true, 'data' => $owner]);
    }

    public function updateOwner(string $id, Request $request): JsonResponse
    {
        $owner = Driver::where('staff_type', 'owner')->findOrFail($id);

        $data = $request->validate([
            'name'     => ['sometimes', 'string', 'max:255'],
            'email'    => ['sometimes', 'email', Rule::unique('drivers', 'email')->ignore($owner->id)],
            'phone'    => ['sometimes', 'string', 'max:50'],
            'password' => ['sometimes', 'string', 'min:8'],
            'cnic'     => ['nullable', 'string', 'max:30'],
            'address'  => ['nullable', 'string'],
            'license_number'  => ['nullable', 'string', 'max:100'],
            'vehicle_plate_number' => ['nullable', 'string', 'max:50'],
            'salary'   => ['nullable', 'numeric'],
            'hire_date' => ['nullable', 'date'],
            'status'   => ['sometimes', 'string', Rule::in(['active', 'inactive', 'suspended'])],
        ]);

        if (isset($data['password'])) {
            $owner->password = $data['password'];
        }
        $owner->fill($data);
        $owner->save();

        return response()->json(['success' => true, 'data' => $owner]);
    }

    public function destroyOwner(string $id): JsonResponse
    {
        $owner = Driver::where('staff_type', 'owner')->findOrFail($id);
        $owner->delete();
        return response()->json(['success' => true]);
    }

    // ═══════════════════════════════════════════════════
    // BUS DRIVERS
    // ═══════════════════════════════════════════════════

    public function listDrivers(Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = $this->resolveCompanyId($user);

        $drivers = Driver::where('driver_type', 'bus')
            ->where('staff_type', 'driver')
            ->when($companyId, fn($q) => $q->where('company_id', $companyId))
            ->when($request->search, fn($q, $s) => $q->where(fn($q2) =>
                $q2->where('name', 'ilike', "%{$s}%")
                  ->orWhere('phone', 'ilike', "%{$s}%")
            ))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $drivers]);
    }

    public function storeDriver(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'     => ['required', 'string', 'max:255'],
            'phone'    => ['required', 'string', 'max:50'],
            'email'    => ['nullable', 'email', 'unique:drivers,email'],
            'password' => ['required', 'string', 'min:8'],
            'cnic'     => ['nullable', 'string', 'max:30'],
            'address'  => ['nullable', 'string'],
            'license_number'      => ['required', 'string', 'max:100'],
            'license_expiry'      => ['nullable', 'date'],
            'vehicle_plate_number' => ['nullable', 'string', 'max:50'],
            'salary'   => ['nullable', 'numeric'],
            'hire_date' => ['nullable', 'date'],
        ]);

        $user = $request->user();
        $companyId = $this->resolveCompanyId($user);

        $driver = Driver::create([
            'id'           => (string) Str::uuid(),
            'company_id'   => $companyId,
            'driver_type'  => 'bus',
            'staff_type'   => 'driver',
            'name'         => $data['name'],
            'email'        => $data['email'] ?? null,
            'phone'        => $data['phone'],
            'password'     => $data['password'],
            'cnic'         => $data['cnic'] ?? null,
            'address'      => $data['address'] ?? null,
            'license_number'       => $data['license_number'],
            'license_expiry'       => $data['license_expiry'] ?? null,
            'vehicle_plate_number'  => $data['vehicle_plate_number'] ?? null,
            'salary'       => $data['salary'] ?? null,
            'hire_date'    => $data['hire_date'] ?? null,
            'status'       => 'active',
            'is_active'    => true,
        ]);

        return response()->json(['success' => true, 'data' => $driver], 201);
    }

    public function showDriver(string $id): JsonResponse
    {
        $driver = Driver::where('staff_type', 'driver')->findOrFail($id);
        return response()->json(['success' => true, 'data' => $driver]);
    }

    public function updateDriver(string $id, Request $request): JsonResponse
    {
        $driver = Driver::where('staff_type', 'driver')->findOrFail($id);

        $data = $request->validate([
            'name'    => ['sometimes', 'string', 'max:255'],
            'phone'   => ['sometimes', 'string', 'max:50'],
            'email'   => ['nullable', 'email', Rule::unique('drivers', 'email')->ignore($driver->id)],
            'password' => ['sometimes', 'string', 'min:8'],
            'cnic'    => ['nullable', 'string', 'max:30'],
            'address' => ['nullable', 'string'],
            'license_number'      => ['sometimes', 'string', 'max:100'],
            'license_expiry'      => ['nullable', 'date'],
            'vehicle_plate_number' => ['nullable', 'string', 'max:50'],
            'salary'   => ['nullable', 'numeric'],
            'hire_date' => ['nullable', 'date'],
            'status'   => ['sometimes', 'string', Rule::in(['active', 'inactive', 'suspended'])],
        ]);

        if (isset($data['password'])) {
            $driver->password = $data['password'];
        }
        $driver->fill($data);
        $driver->save();

        return response()->json(['success' => true, 'data' => $driver]);
    }

    public function destroyDriver(string $id): JsonResponse
    {
        $driver = Driver::where('staff_type', 'driver')->findOrFail($id);
        $driver->delete();
        return response()->json(['success' => true]);
    }

    // ═══════════════════════════════════════════════════
    // BUS CONDUCTORS
    // ═══════════════════════════════════════════════════

    public function listConductors(Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = $this->resolveCompanyId($user);

        $conductors = Driver::where('driver_type', 'bus')
            ->where('staff_type', 'conductor')
            ->when($companyId, fn($q) => $q->where('company_id', $companyId))
            ->when($request->search, fn($q, $s) => $q->where(fn($q2) =>
                $q2->where('name', 'ilike', "%{$s}%")
                  ->orWhere('phone', 'ilike', "%{$s}%")
            ))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $conductors]);
    }

    public function storeConductor(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'     => ['required', 'string', 'max:255'],
            'phone'    => ['required', 'string', 'max:50'],
            'cnic'     => ['nullable', 'string', 'max:30'],
            'address'  => ['nullable', 'string'],
            'salary'   => ['nullable', 'numeric'],
            'hire_date' => ['nullable', 'date'],
        ]);

        $user = $request->user();
        $companyId = $this->resolveCompanyId($user);

        $conductor = Driver::create([
            'id'           => (string) Str::uuid(),
            'company_id'   => $companyId,
            'driver_type'  => 'bus',
            'staff_type'   => 'conductor',
            'name'         => $data['name'],
            'phone'        => $data['phone'],
            'cnic'         => $data['cnic'] ?? null,
            'address'      => $data['address'] ?? null,
            'salary'       => $data['salary'] ?? null,
            'hire_date'    => $data['hire_date'] ?? null,
            'status'       => 'active',
            'is_active'    => true,
        ]);

        return response()->json(['success' => true, 'data' => $conductor], 201);
    }

    public function showConductor(string $id): JsonResponse
    {
        $conductor = Driver::where('staff_type', 'conductor')->findOrFail($id);
        return response()->json(['success' => true, 'data' => $conductor]);
    }

    public function updateConductor(string $id, Request $request): JsonResponse
    {
        $conductor = Driver::where('staff_type', 'conductor')->findOrFail($id);

        $data = $request->validate([
            'name'    => ['sometimes', 'string', 'max:255'],
            'phone'   => ['sometimes', 'string', 'max:50'],
            'cnic'    => ['nullable', 'string', 'max:30'],
            'address' => ['nullable', 'string'],
            'salary'  => ['nullable', 'numeric'],
            'hire_date' => ['nullable', 'date'],
            'status'  => ['sometimes', 'string', Rule::in(['active', 'inactive', 'suspended'])],
        ]);

        $conductor->fill($data);
        $conductor->save();

        return response()->json(['success' => true, 'data' => $conductor]);
    }

    public function destroyConductor(string $id): JsonResponse
    {
        $conductor = Driver::where('staff_type', 'conductor')->findOrFail($id);
        $conductor->delete();
        return response()->json(['success' => true]);
    }

    // ═══════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════

    private function resolveCompanyId($user): ?string
    {
        $meta = $user->metadata;
        if (is_string($meta)) {
            $meta = json_decode($meta, true);
        }
        return $meta['company_id'] ?? null;
    }
}
