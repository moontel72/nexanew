<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Team;
use App\Models\Cricket\Tournament;
use App\Services\Cricket\CricketDataCleanupService;
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
    public function __construct(
        private readonly CricketDataCleanupService $cleanup,
    ) {
    }

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
     * Delete a tournament and everything inside it.
     *
     * Permanent cleanup (not a soft delete): matches, teams and players are
     * removed along with their innings/scores/commentary, the Redis score
     * snapshots and active-match pointers are flushed, and the media engine
     * is told to drop the overlays. A soft delete here is what left deleted
     * teams visible in Todd Studio's lower-third.
     */
    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::withTrashed()->findOrFail($id);
        $counts = $this->cleanup->purgeTournament((string) $tournament->id);

        return response()->json([
            'success' => true,
            'message' => 'Tournament deleted.',
            'purged' => $counts,
        ]);
    }

    /**
     * Activate this tournament and deactivate all others so the public
     * portal and Fixture Scheduler always resolve a single active one.
     *
     * Orphan teams (no `tournament_id`) are NOT adopted implicitly. Team
     * ownership is an operator decision — silently binding teams to
     * whichever tournament happens to be activated next is how a team ends
     * up in a tournament nobody chose. Unscheduled orphans are reported in
     * the response so the operator can assign them deliberately.
     */
    public function activate(string $id): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::findOrFail($id);

        DB::transaction(function () use ($tournament) {
            Tournament::where('id', '!=', $tournament->id)
                ->update(['is_active' => false]);
            $tournament->update([
                'status' => 'active',
                'is_active' => true,
            ]);
        });

        $orphanTeams = Team::whereNull('tournament_id')->count();

        return response()->json([
            'message' => 'Tournament activated.'
                . ($orphanTeams > 0
                    ? " {$orphanTeams} team(s) are not assigned to any tournament"
                        . ' and were left untouched — assign them explicitly.'
                    : ''),
            'unassigned_teams' => $orphanTeams,
            'tournament' => $tournament->fresh(),
        ]);
    }
}
