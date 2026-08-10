<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Club;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class ClubController extends Controller
{
    /**
     * List all clubs (public).
     */
    public function index(): \Illuminate\Http\JsonResponse
    {
        $clubs = Club::orderBy('name')->get();
        return response()->json(['clubs' => $clubs]);
    }

    /**
     * Get club profile by ID or slug.
     */
    public function show(string $identifier): \Illuminate\Http\JsonResponse
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

    /**
     * Create a new club (admin).
     */
    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:200',
            'slug' => 'nullable|string|max:200|unique:cricket_clubs,slug',
            'location' => 'nullable|string|max:200',
            'established_year' => 'nullable|integer|min:1800|max:2099',
            'description' => 'nullable|string',
            'contact_email' => 'nullable|email|max:200',
            'website_url' => 'nullable|url|max:500',
            'logo_url' => 'nullable|url|max:500',
            'banner_url' => 'nullable|url|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $data['slug'] = $data['slug'] ?? Str::slug($data['name']);

        $club = Club::create($data);

        return response()->json(['club' => $club], 201);
    }

    /**
     * Update a club (admin).
     */
    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $club = Club::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:200',
            'slug' => 'nullable|string|max:200|unique:cricket_clubs,slug,' . $id,
            'location' => 'nullable|string|max:200',
            'established_year' => 'nullable|integer|min:1800|max:2099',
            'description' => 'nullable|string',
            'contact_email' => 'nullable|email|max:200',
            'website_url' => 'nullable|url|max:500',
            'logo_url' => 'nullable|url|max:500',
            'banner_url' => 'nullable|url|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $club->update($validator->validated());

        return response()->json(['club' => $club->fresh()]);
    }

    /**
     * Delete a club (admin).
     */
    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        $club = Club::findOrFail($id);
        $club->delete();

        return response()->json(['message' => 'Club deleted.']);
    }
}
