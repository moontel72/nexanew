<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\Bundle;
use App\Models\BundleItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class BundleController extends Controller
{
    /**
     * List all bundles for the authenticated factory.
     */
    public function index(Request $request)
    {
        // TODO: Implement paginated bundle list with filters
        return response()->json(['success' => true, 'data' => []]);
    }

    /**
     * Generate a new bundle for an order by linking carton/packet codes.
     *
     * Takes an order_reference and a list of carton_code_ids + packet_code_ids,
     * creates a bundle, assigns all items, and returns the bundle with its items.
     */
    public function store(Request $request)
    {
        // TODO: Validate order_reference, carton_code_ids, packet_code_ids
        //       Create bundle, insert bundle_items, recalculate totals
        return response()->json(['success' => true, 'data' => []]);
    }

    /**
     * Show a specific bundle with all its carton/packet items.
     */
    public function show(Request $request, string $id)
    {
        // TODO: Return bundle detail with expanded items + location info
        return response()->json(['success' => true, 'data' => []]);
    }

    /**
     * Update bundle metadata (location, status, notes).
     */
    public function update(Request $request, string $id)
    {
        // TODO: Validate and update location_store, location_shelf, status
        return response()->json(['success' => true, 'data' => []]);
    }

    /**
     * Delete a bundle. Carton/Packet codes survive (ON DELETE SET NULL).
     */
    public function destroy(Request $request, string $id)
    {
        // TODO: Soft-delete or hard-delete bundle; items cascade; codes survive
        return response()->json(['success' => true, 'data' => []]);
    }

    /**
     * Scan response: full hierarchy of a bundle for mobile/scanning.
     */
    public function scan(Request $request, string $id)
    {
        // TODO: Return bundle_code, total cartons, total packets,
        //       list of carton codes with their packet/unit details,
        //       location info
        return response()->json(['success' => true, 'data' => []]);
    }
}
