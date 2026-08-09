<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\MatchSponsor;
use App\Models\Cricket\Sponsor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SponsorController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $sponsors = Sponsor::where('tournament_id', $request->tournament_id)
            ->when($request->tier, fn($q) => $q->where('tier', $request->tier))
            ->when($request->has('is_active'), fn($q) => $q->where('is_active', $request->boolean('is_active')))
            ->orderBy('display_order')
            ->paginate($request->per_page ?? 20);

        return response()->json($sponsors);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'tournament_id' => 'required|uuid|exists:cricket_tournaments,id',
            'name' => 'required|string|max:200',
            'logo_url' => 'nullable|url|max:500',
            'banner_image_url' => 'nullable|url|max:500',
            'website_url' => 'nullable|url|max:500',
            'tier' => 'required|in:title,gold,silver,bronze,partner',
            'display_order' => 'integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $sponsor = Sponsor::create($validator->validated());

        return response()->json($sponsor, 201);
    }

    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $sponsor = Sponsor::with('matchSponsors')->findOrFail($id);
        return response()->json($sponsor);
    }

    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $sponsor = Sponsor::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:200',
            'logo_url' => 'nullable|url|max:500',
            'banner_image_url' => 'nullable|url|max:500',
            'website_url' => 'nullable|url|max:500',
            'tier' => 'sometimes|in:title,gold,silver,bronze,partner',
            'is_active' => 'boolean',
            'display_order' => 'integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $sponsor->update($validator->validated());
        return response()->json($sponsor);
    }

    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        Sponsor::findOrFail($id)->delete();
        return response()->json(['message' => 'Sponsor deleted.']);
    }

    // ─── Match Sponsor Assignments ──────────────────────────

    public function matchSponsors(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $sponsors = MatchSponsor::with('sponsor')
            ->where('match_id', $matchId)
            ->where('is_active', true)
            ->orderBy('display_order')
            ->get();

        return response()->json($sponsors);
    }

    public function assignToMatch(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $count = MatchSponsor::where('match_id', $matchId)->count();
        if ($count >= 10) {
            return response()->json(['message' => 'Maximum 10 active sponsors per match.'], 422);
        }

        $validator = Validator::make($request->all(), [
            'sponsor_id' => 'required|uuid|exists:cricket_sponsors,id',
            'placement' => 'required|in:scoreboard_top,scoreboard_bottom,stream_overlay,mid_over_bumper,fall_of_wicket',
            'display_order' => 'integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $assignment = MatchSponsor::create(array_merge(
            $validator->validated(),
            ['match_id' => $matchId, 'is_active' => true]
        ));

        return response()->json($assignment->load('sponsor'), 201);
    }

    public function removeFromMatch(string $matchId, string $assignmentId): \Illuminate\Http\JsonResponse
    {
        MatchSponsor::where('match_id', $matchId)
            ->where('id', $assignmentId)
            ->delete();

        return response()->json(['message' => 'Sponsor removed from match.']);
    }
}
