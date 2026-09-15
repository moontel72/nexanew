<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Player;
use App\Models\Cricket\Team;
use App\Models\Cricket\Tournament;
use App\Services\Cricket\CricketDataCleanupService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TeamController extends Controller
{
    public function __construct(
        private readonly CricketDataCleanupService $cleanup,
    ) {
    }
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

        // Handle logo upload.
        // Store a root-relative path (/storage/teams/<file>) so any client
        // (domain, IP, HTTP or HTTPS) resolves it against its own origin.
        if ($request->hasFile('logo')) {
            $path = $request->file('logo')->store('teams', 'public');
            $data['logo_url'] = '/storage/'.$path;
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

        // Handle logo upload (root-relative path — see store()).
        if ($request->hasFile('logo')) {
            $path = $request->file('logo')->store('teams', 'public');
            $data['logo_url'] = '/storage/'.$path;
        }
        unset($data['logo']);

        $team->update($data);
        return response()->json($team);
    }

    /**
     * Delete a team.
     *
     * Keeps the app's two-stage delete UX: the team row is soft-deleted so
     * it can be restored from the Trash tab, but it is disconnected from
     * every active surface immediately — its fixtures and their child
     * records are purged (a fixture referencing a deleted team renders as a
     * placeholder label, and a fixture cannot outlive one of the teams
     * playing it), and its players are detached from any other live match.
     */
    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        $team = Team::findOrFail($id);

        // Prune fixtures referencing this team (both sides) + their child
        // records, caches and overlay state.
        $this->cleanup->purgeTeamFixtures((string) $team->id);

        // Players stay restorable (they belong to the team's trash flow)
        // but must vanish from any squad or live slot they currently hold.
        $playerIds = Player::where('team_id', $team->id)->pluck('id')->all();
        foreach ($playerIds as $playerId) {
            $this->cleanup->detachPlayer((string) $playerId);
        }

        $team->delete();

        return response()->json([
            'message' => 'Team deleted.',
            'detached_players' => count($playerIds),
        ]);
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

    /**
     * Permanently delete a soft-deleted team (cannot be undone).
     *
     * This is the real removal, so the team's players are purged here too
     * rather than left orphaned against a team that no longer exists.
     */
    public function forceDelete(string $id): \Illuminate\Http\JsonResponse
    {
        $team = Team::onlyTrashed()->findOrFail($id);
        $name = (string) $team->name;

        // Detach and remove every player the team owns (including ones
        // already in the trash — nothing can restore them once the team
        // itself is gone).
        $playerIds = Player::withTrashed()->where('team_id', $team->id)->pluck('id')->all();
        foreach ($playerIds as $playerId) {
            $this->cleanup->detachPlayer((string) $playerId);
        }
        Player::withTrashed()->where('team_id', $team->id)->forceDelete();

        // Fixtures were pruned at soft-delete time; this covers any created
        // while the team sat in the trash.
        $this->cleanup->purgeTeamFixtures((string) $team->id);
        $team->forceDelete();

        return response()->json([
            'message' => "Team '{$name}' permanently deleted.",
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
