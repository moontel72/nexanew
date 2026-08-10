<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Team;
use App\Models\Cricket\Tournament;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TeamController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $teams = Team::withCount('players')
            ->where('tournament_id', $request->tournament_id)
            ->orderBy('name')
            ->paginate($request->per_page ?? 20);

        return response()->json($teams);
    }

    public function listAll(): \Illuminate\Http\JsonResponse
    {
        $teams = Team::withCount('players')
            ->orderBy('name')
            ->paginate(50);

        return response()->json($teams);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'tournament_id' => 'nullable|uuid|exists:cricket_tournaments,id',
            'name' => 'required|string|max:200',
            'short_code' => 'nullable|string|max:10',
            'logo_url' => 'nullable|url|max:500',
            'captain_name' => 'nullable|string|max:200',
            'home_city' => 'nullable|string|max:200',
            'primary_color' => 'nullable|string|max:7',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        // Auto-assign active tournament if none provided
        if (empty($data['tournament_id'])) {
            $activeTournament = Tournament::where('status', 'active')->first();
            if ($activeTournament) {
                $data['tournament_id'] = $activeTournament->id;
            }
        }

        $team = Team::create($data);

        return response()->json([
            'message' => 'Team created.',
            'team' => $team,
        ], 201);
    }

    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $team = Team::with('players')->findOrFail($id);
        return response()->json($team);
    }

    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $team = Team::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:200',
            'short_code' => 'sometimes|string|max:10',
            'logo_url' => 'nullable|url|max:500',
            'captain_name' => 'nullable|string|max:200',
            'home_city' => 'nullable|string|max:200',
            'primary_color' => 'nullable|string|max:7',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $team->update($validator->validated());
        return response()->json($team);
    }

    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        Team::findOrFail($id)->delete();
        return response()->json(['message' => 'Team deleted.']);
    }
}
