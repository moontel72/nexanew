<?php

namespace App\Http\Controllers;

use App\Services\Transport\TransitDisputeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — TRANSIT DISPUTE CONTROLLER
 * ========================================
 *
 * Passenger NFC check-in (15F) and photo-proof dispute (8X) endpoints.
 * Wired in routes/panels/factory.php (customer terminal access layer).
 *
 * SAFETY: Entirely new controller. Zero modification to existing code.
 */

class TransitDisputeController extends Controller
{
    public function __construct(
        private TransitDisputeService $dispute
    ) {}

    /**
     * POST /api/v1/factory/dispute/nfc-checkin
     */
    public function nfcCheckIn(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $data = $request->validate([
            'device_uuid' => ['required', 'string', 'max:100'],
            'trip_id' => ['required', 'string', 'max:100'],
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ]);

        try {
            $result = $this->dispute->verifyNfcCheckIn(
                userId: $userId,
                deviceUuid: $data['device_uuid'],
                tripId: $data['trip_id'],
                clientLat: (float) $data['lat'],
                clientLng: (float) $data['lng'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    /**
     * POST /api/v1/factory/dispute/photo-evidence
     */
    public function photoEvidence(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $data = $request->validate([
            'trip_id' => ['required', 'string', 'max:100'],
            'photos' => ['required', 'array', 'min:1', 'max:3'],
            'photos.*.path' => ['required', 'string'],
            'photos.*.lat' => ['nullable', 'numeric'],
            'photos.*.lng' => ['nullable', 'numeric'],
            'photos.*.captured_at' => ['nullable', 'string'],
            'lat' => ['required', 'numeric'],
            'lng' => ['required', 'numeric'],
        ]);

        try {
            $result = $this->dispute->submitPhotoEvidence(
                userId: $userId,
                tripId: $data['trip_id'],
                photos: $data['photos'],
                clientLat: (float) $data['lat'],
                clientLng: (float) $data['lng'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }
}
