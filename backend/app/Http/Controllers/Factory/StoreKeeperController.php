<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\StoreKeeper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class StoreKeeperController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $query = StoreKeeper::where('company_id', $companyId);

            if ($search = $request->query('search')) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'ILIKE', "%{$search}%")
                        ->orWhere('email', 'ILIKE', "%{$search}%")
                        ->orWhere('employee_id', 'ILIKE', "%{$search}%");
                });
            }

            if ($status = $request->query('status')) {
                $query->where('status', $status);
            }

            $page = (int) $request->query('page', 1);
            $limit = min(100, max(1, (int) $request->query('limit', 50)));

            $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

            $items = $paginator->map(function (StoreKeeper $sk) {
                return [
                    'id' => $sk->id,
                    'companyId' => $sk->company_id,
                    'factoryId' => $sk->factory_id,
                    'name' => $sk->name,
                    'employeeId' => $sk->employee_id,
                    'phone' => $sk->phone,
                    'email' => $sk->email,
                    'status' => $sk->status,
                    'dutyShift' => $sk->duty_shift,
                    'lastLoginAt' => $sk->last_login_at?->toISOString(),
                    'createdAt' => $sk->created_at->toISOString(),
                    'updatedAt' => $sk->updated_at->toISOString(),
                ];
            })->values();

            return response()->json([
                'success' => true,
                'data' => [
                    'storeKeepers' => $items,
                    'total' => $paginator->total(),
                    'page' => $paginator->currentPage(),
                    'limit' => $paginator->perPage(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeper index failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
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
                'employee_id' => ['nullable', 'string', 'max:100', 'unique:store_keepers,employee_id'],
                'phone' => ['nullable', 'string', 'max:50'],
                'email' => ['required', 'email', 'max:255', 'unique:store_keepers,email'],
                'password' => ['required', 'string', 'min:6'],
                'duty_shift' => ['nullable', 'string', 'max:100'],
            ]);

            $storeKeeper = StoreKeeper::create([
                'id' => (string) Str::uuid(),
                'company_id' => $companyId,
                'factory_id' => $companyId,
                'name' => $data['name'],
                'employee_id' => $data['employee_id'] ?? null,
                'phone' => $data['phone'] ?? null,
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'status' => 'active',
                'duty_shift' => $data['duty_shift'] ?? null,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $storeKeeper->id,
                    'companyId' => $storeKeeper->company_id,
                    'factoryId' => $storeKeeper->factory_id,
                    'name' => $storeKeeper->name,
                    'employeeId' => $storeKeeper->employee_id,
                    'phone' => $storeKeeper->phone,
                    'email' => $storeKeeper->email,
                    'status' => $storeKeeper->status,
                    'dutyShift' => $storeKeeper->duty_shift,
                    'createdAt' => $storeKeeper->created_at->toISOString(),
                ],
            ], 201);
        } catch (\Exception $e) {
            Log::error('StoreKeeper store failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function show(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $storeKeeper = StoreKeeper::where('id', $id)->where('company_id', $companyId)->first();

            if (!$storeKeeper) {
                return response()->json(['success' => false, 'message' => 'Store keeper not found'], 404);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $storeKeeper->id,
                    'companyId' => $storeKeeper->company_id,
                    'factoryId' => $storeKeeper->factory_id,
                    'name' => $storeKeeper->name,
                    'employeeId' => $storeKeeper->employee_id,
                    'phone' => $storeKeeper->phone,
                    'email' => $storeKeeper->email,
                    'status' => $storeKeeper->status,
                    'dutyShift' => $storeKeeper->duty_shift,
                    'lastLoginAt' => $storeKeeper->last_login_at?->toISOString(),
                    'createdAt' => $storeKeeper->created_at->toISOString(),
                    'updatedAt' => $storeKeeper->updated_at->toISOString(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeper show failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function update(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $storeKeeper = StoreKeeper::where('id', $id)->where('company_id', $companyId)->first();

            if (!$storeKeeper) {
                return response()->json(['success' => false, 'message' => 'Store keeper not found'], 404);
            }

            $data = $request->validate([
                'name' => ['nullable', 'string', 'max:255'],
                'employee_id' => ['nullable', 'string', 'max:100', 'unique:store_keepers,employee_id,' . $id],
                'phone' => ['nullable', 'string', 'max:50'],
                'email' => ['nullable', 'email', 'max:255', 'unique:store_keepers,email,' . $id],
                'duty_shift' => ['nullable', 'string', 'max:100'],
                'status' => ['nullable', 'string', 'in:active,inactive'],
                'password' => ['nullable', 'string', 'min:6'],
            ]);

            $updates = [];
            foreach (['name', 'employee_id', 'phone', 'email', 'duty_shift', 'status'] as $field) {
                if (array_key_exists($field, $data) && $data[$field] !== null) {
                    $updates[$field] = $data[$field];
                }
            }

            if (!empty($data['password'])) {
                $updates['password'] = Hash::make($data['password']);
            }

            if (!empty($updates)) {
                $storeKeeper->update($updates);
            }

            $storeKeeper->refresh();

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $storeKeeper->id,
                    'companyId' => $storeKeeper->company_id,
                    'factoryId' => $storeKeeper->factory_id,
                    'name' => $storeKeeper->name,
                    'employeeId' => $storeKeeper->employee_id,
                    'phone' => $storeKeeper->phone,
                    'email' => $storeKeeper->email,
                    'status' => $storeKeeper->status,
                    'dutyShift' => $storeKeeper->duty_shift,
                    'lastLoginAt' => $storeKeeper->last_login_at?->toISOString(),
                    'createdAt' => $storeKeeper->created_at->toISOString(),
                    'updatedAt' => $storeKeeper->updated_at->toISOString(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeper update failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function destroy(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $storeKeeper = StoreKeeper::where('id', $id)->where('company_id', $companyId)->first();

            if (!$storeKeeper) {
                return response()->json(['success' => false, 'message' => 'Store keeper not found'], 404);
            }

            $storeKeeper->delete();

            return response()->json(['success' => true, 'data' => ['deleted' => true]]);
        } catch (\Exception $e) {
            Log::error('StoreKeeper destroy failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function auditTrail(Request $request, string $id)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $storeKeeper = StoreKeeper::where('id', $id)->where('company_id', $companyId)->first();

            if (!$storeKeeper) {
                return response()->json(['success' => false, 'message' => 'Store keeper not found'], 404);
            }

            $baseCodes = DB::table('base_codes')
                ->where(function ($q) use ($storeKeeper) {
                    $q->where('store_keeper_code', $storeKeeper->employee_id)
                        ->orWhere('store_keeper_code', $storeKeeper->id)
                        ->orWhere('store_keeper_prefix', $storeKeeper->employee_id);
                })
                ->orderByDesc('created_at')
                ->get();

            $bundleActivities = DB::table('bundles')
                ->where('packed_by', $id)
                ->orderByDesc('created_at')
                ->get();

            $details = [];
            $dates = [];

            foreach ($baseCodes as $code) {
                $timestamp = $code->linked_at ?? $code->generated_at ?? $code->created_at;
                $dateStr = $timestamp ? date('Y-m-d', strtotime($timestamp)) : null;
                if ($dateStr && !in_array($dateStr, $dates, true)) {
                    $dates[] = $dateStr;
                }

                $details[] = [
                    'code' => $code->code ?? $code->id,
                    'action' => $code->linked_at ? 'linked' : ($code->generated_at ? 'generated' : 'created'),
                    'timestamp' => $timestamp,
                    'type' => $code->code_type ?? 'base_code',
                ];
            }

            foreach ($bundleActivities as $bundle) {
                $timestamp = $bundle->packed_at ?? $bundle->created_at;
                $dateStr = $timestamp ? date('Y-m-d', strtotime($timestamp)) : null;
                if ($dateStr && !in_array($dateStr, $dates, true)) {
                    $dates[] = $dateStr;
                }

                $details[] = [
                    'code' => $bundle->bundle_code,
                    'action' => 'packed',
                    'timestamp' => $timestamp,
                    'type' => 'bundle',
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
            Log::error('StoreKeeper auditTrail failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }
}
