<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\MatchManager;
use App\Models\Cricket\MatchModel;
use App\Models\Cricket\MatchOfficial;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MatchController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $matches = MatchModel::with(['teamA', 'teamB'])
            ->where('tournament_id', $request->tournament_id)
            ->when($request->status, fn($q) => $q->where('status', $request->status))
            ->orderBy('scheduled_at')
            ->paginate($request->per_page ?? 20);

        return response()->json($matches);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'tournament_id' => 'required|uuid|exists:cricket_tournaments,id',
            'team_a_id' => 'required|uuid|exists:cricket_teams,id|different:team_b_id',
            'team_b_id' => 'required|uuid|exists:cricket_teams,id',
            'venue' => 'nullable|string|max:300',
            'scheduled_at' => 'required|date',
            'match_type' => 'required|in:t20,odi,test,t10,other',
            'overs_per_side' => 'integer|min:1|max:90',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $match = MatchModel::create($validator->validated());

        return response()->json($match, 201);
    }

    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $match = MatchModel::with([
            'teamA', 'teamB',
            'innings', 'liveScore',
            'matchManagers.cricketManager',
            'streams', 'matchSponsors.sponsor',
            'commentary' => fn($q) => $q->latest('ball_number')->limit(50),
        ])->findOrFail($id);

        return response()->json($match);
    }

    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $match = MatchModel::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'venue' => 'nullable|string|max:300',
            'scheduled_at' => 'sometimes|date',
            'match_type' => 'sometimes|in:t20,odi,test,t10,other',
            'overs_per_side' => 'integer|min:1|max:90',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $match->update($validator->validated());
        return response()->json($match);
    }

    /**
     * Assign Cricket Manager(s) to a match.
     */
    public function assignManager(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'cricket_manager_id' => 'required|uuid|exists:cricket_managers,id',
            'role' => 'required|in:primary,backup,observer',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $match = MatchModel::findOrFail($id);

        // Ensure max 5 managers per match
        $currentCount = $match->matchManagers()->count();
        if ($currentCount >= 5) {
            return response()->json(['message' => 'Maximum 5 managers per match.'], 422);
        }

        // Only one primary at a time
        if ($request->role === 'primary') {
            $match->matchManagers()->where('role', 'primary')->update(['role' => 'backup']);
        }

        $assignment = MatchManager::create([
            'match_id' => $id,
            'cricket_manager_id' => $request->cricket_manager_id,
            'role' => $request->role,
        ]);

        return response()->json($assignment, 201);
    }

    /**
     * Remove a Cricket Manager from a match.
     */
    public function removeManager(string $matchId, string $assignmentId): \Illuminate\Http\JsonResponse
    {
        MatchManager::where('match_id', $matchId)
            ->where('id', $assignmentId)
            ->delete();

        return response()->json(['message' => 'Manager removed from match.']);
    }

    /**
     * Take over active match management (failover).
     */
    public function takeOver(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $manager = $request->userResolver()();

        $assignment = MatchManager::where('match_id', $id)
            ->where('cricket_manager_id', $manager->id)
            ->first();

        if (!$assignment) {
            return response()->json(['message' => 'You are not assigned to this match.'], 403);
        }

        // Deactivate other managers' active sessions
        MatchManager::where('match_id', $id)
            ->update(['is_active_session' => false]);

        // Activate this manager's session
        $assignment->is_active_session = true;
        $assignment->role = 'primary';
        $assignment->last_heartbeat_at = now();
        $assignment->save();

        // Log takeover
        \App\Models\Cricket\ManagerSessionLog::create([
            'cricket_manager_id' => $manager->id,
            'match_id' => $id,
            'action' => 'take_over_match',
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return response()->json([
            'message' => 'Match management taken over successfully.',
            'assignment' => $assignment,
        ]);
    }

    /**
     * Update toss details.
     */
    public function updateToss(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'toss_winner_team_id' => 'required|uuid|exists:cricket_teams,id',
            'toss_decision' => 'required|in:bat,bowl',
            'current_batting_team_id' => 'required|uuid|exists:cricket_teams,id',
            'current_bowling_team_id' => 'required|uuid|exists:cricket_teams,id|different:current_batting_team_id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $match = MatchModel::findOrFail($id);
        $match->update([
            'toss_winner_team_id' => $request->toss_winner_team_id,
            'toss_decision' => $request->toss_decision,
            'current_batting_team_id' => $request->current_batting_team_id,
            'current_bowling_team_id' => $request->current_bowling_team_id,
            'status' => 'toss_done',
        ]);

        return response()->json($match);
    }

    /**
     * Start the match (begin first innings).
     */
    public function startMatch(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $match = MatchModel::findOrFail($id);

        if (!in_array($match->status, ['toss_done'], true)) {
            return response()->json(['message' => 'Toss must be completed before starting the match.'], 422);
        }

        $match->status = 'in_progress';
        $match->save();

        // Create first innings
        \App\Models\Cricket\Innings::create([
            'match_id' => $match->id,
            'innings_number' => 1,
            'batting_team_id' => $match->current_batting_team_id,
            'bowling_team_id' => $match->current_bowling_team_id,
            'status' => 'in_progress',
        ]);

        return response()->json([
            'message' => 'Match started. First innings in progress.',
            'match' => $match->fresh()->load('innings'),
        ]);
    }

    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        MatchModel::findOrFail($id)->delete();
        return response()->json(['message' => 'Match deleted.']);
    }
}
