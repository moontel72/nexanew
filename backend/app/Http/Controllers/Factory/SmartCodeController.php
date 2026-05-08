<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\District;
use App\Models\SmartCode;
use App\Models\Zone;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SmartCodeController extends Controller
{
    // ─── District & Zone Management ───────────────────────────────

    public function indexDistricts(Request $request)
    {
        // TODO: List all districts
        return response()->json(['success' => true, 'data' => []]);
    }

    public function storeDistrict(Request $request)
    {
        // TODO: Create a new district with name and prefix
        return response()->json(['success' => true, 'data' => []]);
    }

    public function indexZones(Request $request, string $districtId)
    {
        // TODO: List zones for a district
        return response()->json(['success' => true, 'data' => []]);
    }

    public function storeZone(Request $request, string $districtId)
    {
        // TODO: Create a new zone with a random 3-digit zone_code
        return response()->json(['success' => true, 'data' => []]);
    }

    // ─── Smart Code Generation ────────────────────────────────────

    /**
     * Generate a smart code for a zone (called when a delivery is created).
     *
     * Uses SmartCode::nextSerialForZone() to auto-increment the parcel serial.
     */
    public function store(Request $request)
    {
        // TODO: Accept zone_id, generate next parcel_serial,
        //       build full_code via SmartCode::buildFullCode(),
        //       save and return
        return response()->json(['success' => true, 'data' => []]);
    }

    /**
     * List smart codes with optional zone/district filter.
     */
    public function index(Request $request)
    {
        // TODO: Paginated list with zone/district filtering
        return response()->json(['success' => true, 'data' => []]);
    }

    /**
     * Show a specific smart code.
     */
    public function show(Request $request, string $id)
    {
        // TODO: Return smart code details with district/zone info
        return response()->json(['success' => true, 'data' => []]);
    }

    /**
     * Scan/lookup a smart code by its full_code string.
     * Used by the OCR pipeline: camera reads KB-067-0002 → this endpoint.
     */
    public function scan(Request $request)
    {
        // TODO: Accept full_code, validate format with regex,
        //       lookup in smart_codes, return delivery/zone details
        return response()->json(['success' => true, 'data' => []]);
    }
}
