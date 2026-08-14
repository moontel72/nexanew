<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\MatchSponsor;
use App\Models\Cricket\Sponsor;
use App\Models\Cricket\Tournament;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

/**
 * Sponsor management — Cricket Manager scope.
 *
 * Sponsor revenue belongs to the Cricket Operations Manager (the manager
 * runs the tournament on a subscription + streaming basis), so the full
 * sponsor lifecycle — create, edit, delete, and match assignment — lives
 * in the manager panel.
 */
class SponsorController extends Controller
{
    /**
     * List sponsors (manager-owned library).
     */
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $sponsors = Sponsor::query()
            ->when(
                $request->tournament_id,
                fn ($q) => $q->where('tournament_id', $request->tournament_id)
            )
            ->orderBy('display_order')
            ->orderBy('name')
            ->paginate($request->per_page ?? 50);

        return response()->json($sponsors);
    }

    /**
     * Create a sponsor, bound to the active tournament.
     */
    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $activeTournament = Tournament::where('status', 'active')
            ->where('is_active', true)
            ->first();
        if (!$activeTournament) {
            return response()->json([
                'message' => 'No active tournament. Activate a tournament before adding sponsors.',
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:200',
            'tier' => 'required|in:title,gold,silver,bronze,partner',
            'logo_url' => 'nullable|string|max:500',
            'banner_image_url' => 'nullable|string|max:500',
            'website_url' => 'nullable|string|max:500',
            'display_order' => 'nullable|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $data['tournament_id'] = $activeTournament->id;

        $sponsor = Sponsor::create($data);

        return response()->json(['sponsor' => $sponsor], 201);
    }

    /**
     * Update a sponsor.
     */
    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $sponsor = Sponsor::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:200',
            'tier' => 'sometimes|in:title,gold,silver,bronze,partner',
            'logo_url' => 'nullable|string|max:500',
            'banner_image_url' => 'nullable|string|max:500',
            'website_url' => 'nullable|string|max:500',
            'display_order' => 'sometimes|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $sponsor->update($validator->validated());

        return response()->json(['sponsor' => $sponsor->fresh()]);
    }

    /**
     * Delete a sponsor (and its match assignments).
     */
    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        $sponsor = Sponsor::findOrFail($id);
        $sponsor->matchSponsors()->delete();
        $sponsor->delete();

        return response()->json(['message' => 'Sponsor deleted.']);
    }

    /**
     * Sponsors assigned to a match (with placement info).
     */
    public function matchSponsors(string $matchId): \Illuminate\Http\JsonResponse
    {
        $assignments = MatchSponsor::with('sponsor')
            ->where('match_id', $matchId)
            ->where('is_active', true)
            ->orderBy('display_order')
            ->get()
            ->map(fn ($ms) => [
                'id' => $ms->sponsor?->id,
                'sponsor_id' => $ms->sponsor?->id,
                'name' => $ms->sponsor?->name,
                'logo_url' => $ms->sponsor?->logo_url,
                'banner_image_url' => $ms->sponsor?->banner_image_url,
                'website_url' => $ms->sponsor?->website_url,
                'tier' => $ms->sponsor?->tier,
                'placement' => $ms->placement,
                'display_order' => $ms->display_order,
            ])
            ->filter(fn ($s) => $s['sponsor_id'] !== null)
            ->values();

        return response()->json(['sponsors' => $assignments]);
    }

    /**
     * Assign a sponsor to a match.
     */
    public function assignToMatch(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'sponsor_id' => 'required|uuid|exists:cricket_sponsors,id',
            'placement' => 'required|in:scoreboard_top,scoreboard_bottom,stream_overlay,mid_over_bumper,fall_of_wicket',
            'display_order' => 'nullable|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $exists = MatchSponsor::where('match_id', $matchId)
            ->where('sponsor_id', $request->sponsor_id)
            ->where('placement', $request->placement)
            ->exists();
        if ($exists) {
            return response()->json([
                'message' => 'This sponsor is already assigned at that placement for this match.',
            ], 422);
        }

        $assignment = MatchSponsor::create([
            'match_id' => $matchId,
            'sponsor_id' => $request->sponsor_id,
            'placement' => $request->placement,
            'display_order' => $request->display_order ?? 0,
        ]);

        return response()->json(['assignment' => $assignment->load('sponsor')], 201);
    }

    /**
     * Remove a sponsor from a match.
     */
    public function removeFromMatch(string $matchId, string $sponsorId): \Illuminate\Http\JsonResponse
    {
        MatchSponsor::where('match_id', $matchId)
            ->where('sponsor_id', $sponsorId)
            ->delete();

        return response()->json(['message' => 'Sponsor removed from match.']);
    }
}
