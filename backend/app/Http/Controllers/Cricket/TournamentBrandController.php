<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Tournament;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * Tournament branding — the Cricket Manager's OWN logo + name.
 *
 * Each subscription manager brands their tournament from the Cricket
 * Manager panel (upload logo, set name). The brand is served to:
 *   - the Cricket Manager login page (shows the ACTIVE tournament brand
 *     instead of hardcoded Trace Odd branding),
 *   - the public cricket app / web TV (left-side tournament identity),
 *   - the media engine (burn-in on the program stream).
 *
 * Todd Studio itself keeps the Trace Odd brand — this is cricket-only.
 */
class TournamentBrandController extends Controller
{
    /**
     * GET /api/v1/cricket/public/brand
     * Branding of the currently ACTIVE tournament (public — used by the
     * manager login page and the public app before/without auth).
     */
    public function active(): JsonResponse
    {
        $tournament = Tournament::where('status', 'active')
            ->where('is_active', true)
            ->first();

        if (!$tournament) {
            return response()->json([
                'brand' => null,
                'message' => 'No active tournament.',
            ]);
        }

        return response()->json([
            'brand' => [
                'tournament_id' => $tournament->id,
                'name' => $tournament->name,
                'logo_url' => $tournament->logo_url,
                'location' => $tournament->location,
            ],
        ]);
    }

    /**
     * POST /api/v1/cricket/manager/brand/logo
     * Upload the tournament brand logo (manager auth). Returns a relative
     * /storage/… URL that resolves same-origin on every cricket host.
     * The manager then saves it on the tournament via
     * PUT /api/v1/cricket/manager/tournaments/{id} (logo_url field).
     */
    public function uploadLogo(Request $request): JsonResponse
    {
        $request->validate([
            'logo' => 'required|file|max:5120|mimes:jpg,jpeg,png,webp',
        ]);

        try {
            $file = $request->file('logo');
            $ext = strtolower((string) $file->getClientOriginalExtension());
            $filename = sprintf(
                'cricket_brand_%s_%s.%s',
                Str::random(10),
                time(),
                $ext,
            );
            $path = $file->storeAs('cricket-branding', $filename, 'public');

            return response()->json([
                'success' => true,
                'data' => [
                    'url' => '/storage/' . $path,
                    'absolute_url' => Storage::disk('public')->url($path),
                    'path' => $path,
                ],
            ], 201);
        } catch (\Throwable $e) {
            Log::error('TournamentBrandController: logo upload failed.', [
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Upload failed. Please try again.',
            ], 500);
        }
    }
}
