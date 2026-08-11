<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Team;
use App\Models\Cricket\Tournament;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
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

        // Ensure consistent typing in the response
        $teams->getCollection()->transform(function ($team) {
            return [
                'id' => (string) $team->id,
                'name' => (string) $team->name,
                'short_code' => (string) ($team->short_code ?? ''),
                'logo_url' => $team->logo_url ? (string) $team->logo_url : null,
                'primary_color' => $team->primary_color ? (string) $team->primary_color : null,
                'details' => $team->details ? (string) $team->details : null,
                'team_code' => $team->team_code ? (string) $team->team_code : null,
                'home_city' => $team->home_city ? (string) $team->home_city : null,
                'status' => (string) ($team->status ?? 'active'),
                'player_count' => (int) ($team->players_count ?? 0),
            ];
        });

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
            'details' => 'nullable|string|max:5000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        // Handle logo upload
        if ($request->hasFile('logo')) {
            $path = $request->file('logo')->store('teams', 'public');
            $data['logo_url'] = Storage::url($path);
        }
        unset($data['logo']);

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
            'team' => [
                'id' => (string) $team->id,
                'name' => (string) $team->name,
                'short_code' => (string) ($team->short_code ?? ''),
                'logo_url' => $team->logo_url ? (string) $team->logo_url : null,
                'primary_color' => $team->primary_color ? (string) $team->primary_color : null,
                'details' => $team->details ? (string) $team->details : null,
                'team_code' => $team->team_code ? (string) $team->team_code : null,
                'home_city' => $team->home_city ? (string) $team->home_city : null,
                'status' => (string) ($team->status ?? 'active'),
                'player_count' => 0,
            ],
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

        $data = $validator->validated();

        // Handle logo upload
        if ($request->hasFile('logo')) {
            $path = $request->file('logo')->store('teams', 'public');
            $data['logo_url'] = Storage::url($path);
        }
        unset($data['logo']);

        $team->update($data);
        return response()->json($team);
    }

    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        Team::findOrFail($id)->delete();
        return response()->json(['message' => 'Team deleted.']);
    }

    /**
     * List soft-deleted teams (trash).
     */
    public function trashed(): \Illuminate\Http\JsonResponse
    {
        $teams = Team::onlyTrashed()
            ->orderBy('deleted_at', 'desc')
            ->paginate(50);

        $teams->getCollection()->transform(function ($team) {
            return [
                'id' => (string) $team->id,
                'name' => (string) $team->name,
                'short_code' => (string) ($team->short_code ?? ''),
                'logo_url' => $team->logo_url ? (string) $team->logo_url : null,
                'primary_color' => $team->primary_color ? (string) $team->primary_color : null,
                'team_code' => $team->team_code ? (string) $team->team_code : null,
                'home_city' => $team->home_city ? (string) $team->home_city : null,
                'player_count' => 0,
                'details' => $team->details ? (string) $team->details : null,
                'status' => (string) ($team->status ?? 'active'),
                'deleted_at' => $team->deleted_at ? $team->deleted_at->toIso8601String() : null,
            ];
        });

        return response()->json($teams);
    }

    /**
     * Restore a soft-deleted team.
     */
    public function restore(string $id): \Illuminate\Http\JsonResponse
    {
        $team = Team::onlyTrashed()->findOrFail($id);
        $team->restore();

        return response()->json([
            'message' => 'Team restored successfully.',
            'team' => [
                'id' => (string) $team->id,
                'name' => (string) $team->name,
                'status' => (string) ($team->status ?? 'active'),
            ],
        ]);
    }

    public function updateStatus(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:active,inactive,suspended',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $team = Team::findOrFail($id);
        $team->status = $request->status;
        $team->save();

        return response()->json([
            'message' => "Team status updated to {$team->status}.",
            'team' => [
                'id' => (string) $team->id,
                'name' => (string) $team->name,
                'status' => (string) $team->status,
            ],
        ]);
    }
}
