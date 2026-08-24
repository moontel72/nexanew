<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Team;
use App\Models\Cricket\Tournament;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

/**
 * Tournament setup — Cricket Operations Manager scope.
 *
 * The manager creates, edits, and activates tournaments before scheduling
 * fixtures. The public portal and Fixture Scheduler resolve the active
 * tournament via status = 'active' AND is_active = true.
 */
class TournamentSetupController extends Controller
{
    /**
     * List all tournaments (most recent first).
     */
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $tournaments = Tournament::withCount(['teams', 'matches'])
            ->orderBy('start_date', 'desc')
            ->paginate($request->per_page ?? 20);

        return response()->json($tournaments);
    }

    /**
     * Create a tournament (inactive by default).
     */
    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:200',
            'location' => 'nullable|string|max:200',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'description' => 'nullable|string',
            'logo_url' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $data['slug'] = Str::slug($data['name'] . '-' . Str::random(6));
        $data['status'] = 'upcoming';
        $data['is_active'] = false;

        $tournament = Tournament::create($data);

        return response()->json(['tournament' => $tournament], 201);
    }

    /**
     * Get a single tournament.
     */
    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::withCount(['teams', 'matches'])->findOrFail($id);

        return response()->json(['tournament' => $tournament]);
    }

    /**
     * Update tournament details (including status / is_active).
     */
    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:200',
            'location' => 'nullable|string|max:200',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after_or_equal:start_date',
            'description' => 'nullable|string',
            'logo_url' => 'nullable|string|max:500',
            'status' => 'sometimes|in:upcoming,active,completed,cancelled',
            'is_active' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $tournament->update($validator->validated());

        return response()->json(['tournament' => $tournament->fresh()]);
    }

    /**
     * Delete a tournament (soft delete) — including completed ones.
     */
    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::findOrFail($id);
        $tournament->delete();

        return response()->json([
            'success' => true,
            'message' => 'Tournament deleted.',
        ]);
    }

    /**
     * Activate this tournament and deactivate all others so the public
     * portal and Fixture Scheduler always resolve a single active one.
     *
     * Teams registered before any tournament existed have no
     * tournament_id — they are attached to the activated tournament so
     * fixture scheduling works without manual fixes.
     */
    public function activate(string $id): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::findOrFail($id);

        $assignedTeams = DB::transaction(function () use ($tournament) {
            Tournament::where('id', '!=', $tournament->id)
                ->update(['is_active' => false]);
            $tournament->update([
                'status' => 'active',
                'is_active' => true,
            ]);

            return Team::whereNull('tournament_id')
                ->update(['tournament_id' => $tournament->id]);
        });

        return response()->json([
            'message' => 'Tournament activated.'
                . ($assignedTeams > 0
                    ? " {$assignedTeams} existing team(s) attached to it."
                    : ''),
            'assigned_teams' => $assignedTeams,
            'tournament' => $tournament->fresh(),
        ]);
    }
}
