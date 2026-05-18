<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\Driver;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class DriverController extends Controller
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);
        $driver = Driver::where('email', $data['email'])->first();
        if (!$driver || !Hash::check($data['password'], $driver->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }
        if ($driver->status !== 'active') {
            return response()->json(['message' => 'Account is not active'], 403);
        }
        $driver->forceFill(['last_login_at' => now()])->save();
        $token = $driver->createToken('driver')->plainTextToken;
        return response()->json([
            'success' => true,
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $driver->id,
                    'name' => $driver->name,
                    'email' => $driver->email,
                    'company_id' => $driver->company_id,
                ],
            ],
        ]);
    }

    public function index(Request $request)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $query = Driver::where('company_id', $companyId);

            if ($search = $request->query('search')) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'ILIKE', "%{$search}%")
                        ->orWhere('email', 'ILIKE', "%{$search}%")
                        ->orWhere('phone', 'ILIKE', "%{$search}%")
                        ->orWhere('license_number', 'ILIKE', "%{$search}%")
                        ->orWhere('vehicle_plate_number', 'ILIKE', "%{$search}%");
                });
            }

            if ($status = $request->query('status')) {
                $query->where('status', $status);
            }

            if ($tier = $request->query('tier')) {
                $query->where('tier', $tier);
            }

            $page = (int) $request->query('page', 1);
            $limit = min(100, max(1, (int) $request->query('limit', 50)));

            $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

            $items = $paginator->map(function (Driver $d) {
                return [
                    'id' => $d->id,
                    'companyId' => $d->company_id,
                    'factoryId' => $d->factory_id,
                    'name' => $d->name,
                    'phone' => $d->phone,
                    'email' => $d->email,
                    'licenseNumber' => $d->license_number,
                    'licenseExpiry' => $d->license_expiry?->toISOString(),
                    'vehiclePlateNumber' => $d->vehicle_plate_number,
                    'vehicleType' => $d->vehicle_type,
                    'insuranceNumber' => $d->insurance_number,
                    'insuranceExpiry' => $d->insurance_expiry?->toISOString(),
                    'registrationExpiry' => $d->registration_expiry?->toISOString(),
                    'status' => $d->status,
                    'tier' => $d->tier,
                    'rating' => $d->rating,
                    'totalTrips' => $d->total_trips,
                    'completedTrips' => $d->completed_trips,
                    'onTimeDeliveries' => $d->on_time_deliveries,
                    'lateDeliveries' => $d->late_deliveries,
                    'drivingHoursToday' => $d->driving_hours_today,
                    'drivingHoursWeek' => $d->driving_hours_week,
                    'isFatigued' => $d->is_fatigued,
                    'lastLoginAt' => $d->last_login_at?->toISOString(),
                    'createdAt' => $d->created_at->toISOString(),
                    'updatedAt' => $d->updated_at->toISOString(),
                ];
            })->values();

            return response()->json([
                'success' => true,
                'data' => [
                    'drivers' => $items,
                    'total' => $paginator->total(),
                    'page' => $paginator->currentPage(),
                    'limit' => $paginator->perPage(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Driver index failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $data = $request->validate([
                'name' => ['required', 'string', 'max:255'],
                'email' => ['required', 'email', 'max:255', 'unique:drivers,email'],
                'password' => ['required', 'string', 'min:6'],
                'phone' => ['nullable', 'string', 'max:50'],
                'license_number' => ['nullable', 'string', 'max:100'],
                'license_expiry' => ['nullable', 'date'],
                'vehicle_plate_number' => ['nullable', 'string', 'max:50'],
                'vehicle_type' => ['nullable', 'string', 'in:Motorcycle,Car,Van,Truck,Other'],
                'insurance_number' => ['nullable', 'string', 'max:100'],
                'insurance_expiry' => ['nullable', 'date'],
                'registration_expiry' => ['nullable', 'date'],
            ]);

            $driver = Driver::create([
                'id' => (string) Str::uuid(),
                'company_id' => $companyId,
                'factory_id' => $companyId,
                'name' => $data['name'],
                'phone' => $data['phone'] ?? null,
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'license_number' => $data['license_number'] ?? null,
                'license_expiry' => $data['license_expiry'] ?? null,
                'vehicle_plate_number' => $data['vehicle_plate_number'] ?? null,
                'vehicle_type' => $data['vehicle_type'] ?? null,
                'insurance_number' => $data['insurance_number'] ?? null,
                'insurance_expiry' => $data['insurance_expiry'] ?? null,
                'registration_expiry' => $data['registration_expiry'] ?? null,
                'status' => 'active',
                'tier' => 'bronze',
                'rating' => 0.00,
                'total_trips' => 0,
                'completed_trips' => 0,
                'on_time_deliveries' => 0,
                'late_deliveries' => 0,
                'driving_hours_today' => 0.0,
                'driving_hours_week' => 0.0,
                'is_fatigued' => false,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $driver->id,
                    'companyId' => $driver->company_id,
                    'factoryId' => $driver->factory_id,
                    'name' => $driver->name,
                    'phone' => $driver->phone,
                    'email' => $driver->email,
                    'licenseNumber' => $driver->license_number,
                    'licenseExpiry' => $driver->license_expiry?->toISOString(),
                    'vehiclePlateNumber' => $driver->vehicle_plate_number,
                    'vehicleType' => $driver->vehicle_type,
                    'insuranceNumber' => $driver->insurance_number,
                    'insuranceExpiry' => $driver->insurance_expiry?->toISOString(),
                    'registrationExpiry' => $driver->registration_expiry?->toISOString(),
                    'status' => $driver->status,
                    'tier' => $driver->tier,
                    'rating' => $driver->rating,
                    'totalTrips' => $driver->total_trips,
                    'completedTrips' => $driver->completed_trips,
                    'drivingHoursToday' => $driver->driving_hours_today,
                    'drivingHoursWeek' => $driver->driving_hours_week,
                    'isFatigued' => $driver->is_fatigued,
                    'createdAt' => $driver->created_at->toISOString(),
                ],
            ], 201);
        } catch (\Exception $e) {
            Log::error('Driver store failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function show(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $driver = Driver::where('id', $id)->where('company_id', $companyId)->first();

            if (!$driver) {
                return response()->json(['success' => false, 'message' => 'Driver not found'], 404);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $driver->id,
                    'companyId' => $driver->company_id,
                    'factoryId' => $driver->factory_id,
                    'name' => $driver->name,
                    'phone' => $driver->phone,
                    'email' => $driver->email,
                    'licenseNumber' => $driver->license_number,
                    'licenseExpiry' => $driver->license_expiry?->toISOString(),
                    'vehiclePlateNumber' => $driver->vehicle_plate_number,
                    'vehicleType' => $driver->vehicle_type,
                    'insuranceNumber' => $driver->insurance_number,
                    'insuranceExpiry' => $driver->insurance_expiry?->toISOString(),
                    'registrationExpiry' => $driver->registration_expiry?->toISOString(),
                    'status' => $driver->status,
                    'tier' => $driver->tier,
                    'rating' => $driver->rating,
                    'totalTrips' => $driver->total_trips,
                    'completedTrips' => $driver->completed_trips,
                    'onTimeDeliveries' => $driver->on_time_deliveries,
                    'lateDeliveries' => $driver->late_deliveries,
                    'drivingHoursToday' => $driver->driving_hours_today,
                    'drivingHoursWeek' => $driver->driving_hours_week,
                    'isFatigued' => $driver->is_fatigued,
                    'lastLoginAt' => $driver->last_login_at?->toISOString(),
                    'createdAt' => $driver->created_at->toISOString(),
                    'updatedAt' => $driver->updated_at->toISOString(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Driver show failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function update(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $driver = Driver::where('id', $id)->where('company_id', $companyId)->first();

            if (!$driver) {
                return response()->json(['success' => false, 'message' => 'Driver not found'], 404);
            }

            $data = $request->validate([
                'name' => ['nullable', 'string', 'max:255'],
                'phone' => ['nullable', 'string', 'max:50'],
                'email' => ['nullable', 'email', 'max:255', 'unique:drivers,email,' . $id],
                'license_number' => ['nullable', 'string', 'max:100'],
                'license_expiry' => ['nullable', 'date'],
                'vehicle_plate_number' => ['nullable', 'string', 'max:50'],
                'vehicle_type' => ['nullable', 'string', 'in:Motorcycle,Car,Van,Truck,Other'],
                'insurance_number' => ['nullable', 'string', 'max:100'],
                'insurance_expiry' => ['nullable', 'date'],
                'registration_expiry' => ['nullable', 'date'],
                'status' => ['nullable', 'string', 'in:active,inactive,suspended'],
                'tier' => ['nullable', 'string', 'in:bronze,silver,gold'],
                'password' => ['nullable', 'string', 'min:6'],
            ]);

            $updates = [];
            foreach (['name', 'phone', 'email', 'license_number', 'license_expiry', 'vehicle_plate_number', 'vehicle_type', 'insurance_number', 'insurance_expiry', 'registration_expiry', 'status', 'tier'] as $field) {
                if (array_key_exists($field, $data) && $data[$field] !== null) {
                    $updates[$field] = $data[$field];
                }
            }

            if (!empty($data['password'])) {
                $updates['password'] = Hash::make($data['password']);
            }

            if (!empty($updates)) {
                $driver->update($updates);
            }

            $driver->refresh();

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $driver->id,
                    'companyId' => $driver->company_id,
                    'factoryId' => $driver->factory_id,
                    'name' => $driver->name,
                    'phone' => $driver->phone,
                    'email' => $driver->email,
                    'licenseNumber' => $driver->license_number,
                    'licenseExpiry' => $driver->license_expiry?->toISOString(),
                    'vehiclePlateNumber' => $driver->vehicle_plate_number,
                    'vehicleType' => $driver->vehicle_type,
                    'insuranceNumber' => $driver->insurance_number,
                    'insuranceExpiry' => $driver->insurance_expiry?->toISOString(),
                    'registrationExpiry' => $driver->registration_expiry?->toISOString(),
                    'status' => $driver->status,
                    'tier' => $driver->tier,
                    'rating' => $driver->rating,
                    'totalTrips' => $driver->total_trips,
                    'completedTrips' => $driver->completed_trips,
                    'onTimeDeliveries' => $driver->on_time_deliveries,
                    'lateDeliveries' => $driver->late_deliveries,
                    'drivingHoursToday' => $driver->driving_hours_today,
                    'drivingHoursWeek' => $driver->driving_hours_week,
                    'isFatigued' => $driver->is_fatigued,
                    'lastLoginAt' => $driver->last_login_at?->toISOString(),
                    'createdAt' => $driver->created_at->toISOString(),
                    'updatedAt' => $driver->updated_at->toISOString(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Driver update failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function destroy(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $driver = Driver::where('id', $id)->where('company_id', $companyId)->first();

            if (!$driver) {
                return response()->json(['success' => false, 'message' => 'Driver not found'], 404);
            }

            $driver->delete();

            return response()->json(['success' => true, 'data' => ['deleted' => true]]);
        } catch (\Exception $e) {
            Log::error('Driver destroy failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function toggleStatus(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $driver = Driver::where('id', $id)->where('company_id', $companyId)->first();

            if (!$driver) {
                return response()->json(['success' => false, 'message' => 'Driver not found'], 404);
            }

            $data = $request->validate([
                'status' => ['required', 'string', 'in:active,inactive,suspended'],
            ]);

            $driver->update(['status' => $data['status']]);
            $driver->refresh();

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $driver->id,
                    'status' => $driver->status,
                    'updatedAt' => $driver->updated_at->toISOString(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Driver toggleStatus failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function auditTrail(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $driver = Driver::where('id', $id)->where('company_id', $companyId)->first();

            if (!$driver) {
                return response()->json(['success' => false, 'message' => 'Driver not found'], 404);
            }

            // Gather driver activity: trips from deliveries or transport records
            $trips = DB::table('deliveries')
                ->where('driver_id', $id)
                ->orderByDesc('created_at')
                ->get();

            $scans = DB::table('scan_logs')
                ->where('scanned_by', $id)
                ->orWhere('driver_id', $id)
                ->orderByDesc('created_at')
                ->get();

            $details = [];
            $dates = [];

            foreach ($trips as $trip) {
                $timestamp = $trip->completed_at ?? $trip->created_at;
                $dateStr = $timestamp ? date('Y-m-d', strtotime($timestamp)) : null;
                if ($dateStr && !in_array($dateStr, $dates, true)) {
                    $dates[] = $dateStr;
                }

                $details[] = [
                    'code' => $trip->id,
                    'action' => $trip->status ?? 'trip',
                    'timestamp' => $timestamp,
                    'type' => 'trip',
                ];
            }

            foreach ($scans as $scan) {
                $timestamp = $scan->created_at;
                $dateStr = $timestamp ? date('Y-m-d', strtotime($timestamp)) : null;
                if ($dateStr && !in_array($dateStr, $dates, true)) {
                    $dates[] = $dateStr;
                }

                $details[] = [
                    'code' => $scan->code ?? $scan->id,
                    'action' => $scan->action ?? 'scanned',
                    'timestamp' => $timestamp,
                    'type' => 'scan',
                ];
            }

            usort($details, function ($a, $b) {
                return strcmp($b['timestamp'] ?? '', $a['timestamp'] ?? '');
            });

            $totalScans = count($details);

            return response()->json([
                'success' => true,
                'data' => [
                    'dates' => $dates,
                    'totalScans' => $totalScans,
                    'details' => $details,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Driver auditTrail failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }
}
