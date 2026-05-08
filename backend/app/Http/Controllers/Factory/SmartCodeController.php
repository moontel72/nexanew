<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\District;
use App\Models\SmartCode;
use App\Models\Zone;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SmartCodeController extends Controller
{
    private const CODE_REGEX = '/^[A-Z]{2,3}-\d{3}-\d{4}$/';

    // ─── District Management ──────────────────────────────────────

    public function indexDistricts(Request $request)
    {
        $districts = District::orderBy('name')->get()->map(fn(District $d) => [
            'id' => $d->id,
            'name' => $d->name,
            'prefix' => $d->prefix,
            'zonesCount' => $d->zones()->count(),
        ]);

        return response()->json(['success' => true, 'data' => ['districts' => $districts]]);
    }

    public function storeDistrict(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'prefix' => ['required', 'string', 'max:5', 'unique:districts,prefix'],
        ]);

        $district = District::create([
            'id' => (string) Str::uuid(),
            'name' => $data['name'],
            'prefix' => strtoupper($data['prefix']),
        ]);

        return response()->json([
            'success' => true,
            'data' => ['id' => $district->id, 'name' => $district->name, 'prefix' => $district->prefix],
        ], 201);
    }

    // ─── Zone Management ─────────────────────────────────────────

    public function indexZones(Request $request, string $districtId)
    {
        $district = District::findOrFail($districtId);
        $zones = $district->zones()->orderBy('zone_code')->get()->map(fn(Zone $z) => [
            'id' => $z->id,
            'name' => $z->name,
            'zoneCode' => $z->zone_code,
            'smartCodesCount' => $z->smartCodes()->count(),
            'lastSerial' => $z->smartCodes()->max('parcel_serial'),
        ]);

        return response()->json([
            'success' => true,
            'data' => ['district' => ['id' => $district->id, 'name' => $district->name, 'prefix' => $district->prefix], 'zones' => $zones],
        ]);
    }

    public function storeZone(Request $request, string $districtId)
    {
        $district = District::findOrFail($districtId);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:200'],
        ]);

        // Generate a unique 3-digit zone code within this district
        $existing = $district->zones()->pluck('zone_code')->toArray();
        do {
            $code = str_pad((string) random_int(0, 999), 3, '0', STR_PAD_LEFT);
        } while (in_array($code, $existing, true));

        $zone = Zone::create([
            'id' => (string) Str::uuid(),
            'district_id' => $districtId,
            'name' => $data['name'],
            'zone_code' => $code,
        ]);

        return response()->json([
            'success' => true,
            'data' => ['id' => $zone->id, 'name' => $zone->name, 'zoneCode' => $zone->zone_code, 'districtPrefix' => $district->prefix],
        ], 201);
    }

    // ─── Smart Code Generation ────────────────────────────────────

    public function store(Request $request)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'uuid', 'exists:zones,id'],
            'delivery_id' => ['nullable', 'string', 'max:100'],
        ]);

        $zone = Zone::with('district')->findOrFail($data['zone_id']);
        $prefix = $zone->district->prefix;

        $code = SmartCode::create([
            'id' => (string) Str::uuid(),
            'district_prefix' => $prefix,
            'zone_code' => $zone->zone_code,
            'parcel_serial' => SmartCode::nextSerialForZone($zone->id),
            'zone_id' => $zone->id,
            'delivery_id' => $data['delivery_id'] ?? null,
            'status' => 'active',
        ]);

        return response()->json([
            'success' => true,
            'data' => $this->formatCode($code),
        ], 201);
    }

    public function index(Request $request)
    {
        $query = SmartCode::with('zone.district');

        if ($zoneId = $request->query('zone_id')) {
            $query->where('zone_id', $zoneId);
        }
        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        $page = (int) $request->query('page', 1);
        $limit = min(100, max(1, (int) $request->query('limit', 50)));

        $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

        $items = $paginator->map(fn(SmartCode $c) => $this->formatCode($c))->values();

        return response()->json([
            'success' => true,
            'data' => [
                'smartCodes' => $items,
                'total' => $paginator->total(),
                'page' => $paginator->currentPage(),
                'limit' => $paginator->perPage(),
                'totalPages' => $paginator->lastPage(),
            ],
        ]);
    }

    public function show(Request $request, string $id)
    {
        $code = SmartCode::with('zone.district')->findOrFail($id);
        return response()->json(['success' => true, 'data' => $this->formatCode($code)]);
    }

    /**
     * Scan/lookup by full_code. Used by the OCR pipeline.
     */
    public function scan(Request $request)
    {
        $data = $request->validate([
            'full_code' => ['required', 'string', 'max:15'],
        ]);

        $input = strtoupper(trim($data['full_code']));

        if (!preg_match(self::CODE_REGEX, $input)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid smart code format. Expected: XX-000-0000',
            ], 422);
        }

        $code = SmartCode::where('full_code', $input)->with('zone.district')->first();

        if (!$code) {
            return response()->json([
                'success' => false,
                'message' => 'Smart code not found: ' . $input,
            ], 404);
        }

        // Mark as scanned if not already
        if (!$code->isScanned()) {
            $code->markScanned($request->user()?->name ?? 'system');
        }

        return response()->json([
            'success' => true,
            'data' => $this->formatCode($code, true),
        ]);
    }

    // ─── Helpers ──────────────────────────────────────────────────

    private function formatCode(SmartCode $code, bool $withScanInfo = false): array
    {
        $result = [
            'id' => $code->id,
            'fullCode' => $code->full_code,
            'districtPrefix' => $code->district_prefix,
            'zoneCode' => $code->zone_code,
            'parcelSerial' => $code->parcel_serial,
            'deliveryId' => $code->delivery_id,
            'status' => $code->status,
            'createdAt' => $code->created_at->toISOString(),
        ];

        if ($code->relationLoaded('zone') && $code->zone) {
            $result['zoneName'] = $code->zone->name;
            $result['districtName'] = $code->zone->district?->name;
        }

        if ($withScanInfo) {
            $result['scannedAt'] = $code->scanned_at?->toISOString();
            $result['scannedBy'] = $code->scanned_by;
        }

        return $result;
    }
}
