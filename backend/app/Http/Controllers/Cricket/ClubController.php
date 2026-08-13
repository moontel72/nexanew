<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Club;
use Illuminate\Http\JsonResponse;

class ClubController extends Controller
{
    /**
     * List all clubs (public).
     */
    public function index(): JsonResponse
    {
        $clubs = Club::orderBy('name')->get();
        return response()->json(['clubs' => $clubs]);
    }

    /**
     * Get club profile by ID or slug (public).
     */
    public function show(string $identifier): JsonResponse
    {
        $club = Club::where('id', $identifier)
            ->orWhere('slug', $identifier)
            ->with('players.player')
            ->first();

        if (!$club) {
            return response()->json(['message' => 'Club not found.'], 404);
        }

        // Increment view count
        $club->increment('club_views');

        return response()->json(['club' => $club]);
    }
}
