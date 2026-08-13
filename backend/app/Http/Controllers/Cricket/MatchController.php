<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\MatchManager;
use App\Models\Cricket\MatchModel;
use App\Models\Cricket\MatchOfficial;
use App\Models\Cricket\Tournament;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class MatchController extends Controller
{
    /** Supported match formats (shared with the DB enum). */
    private const MATCH_TYPES = 't20,odi,test,t10,other';

    /** Bracket stages supported by the fixture scheduler. */
    private const STAGES = 'group_stage,quarter_final,semi_final,final,friendly_test';

    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $matches = MatchModel::with(['teamA', 'teamB', 'ground'])
            ->where('tournament_id', $request->tournament_id)
            ->when($request->status, fn($q) => $q->where('status', $request->status))
            ->when($request->stage, fn($q) => $q->where('stage', $request->stage))
            ->when($request->date, fn($q) => $q->whereDate('scheduled_at', $request->date))
            ->orderBy('scheduled_at')
            ->paginate($request->per_page ?? 20);

        return response()->json($matches);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'tournament_id' => 'required|uuid|exists:cricket_tournaments,id',
            'team_a_id' => [
                'required',
                'uuid',
                Rule::exists('cricket_teams', 'id')->where(
                    fn ($q) => $q->where('tournament_id', $request->tournament_id)
                ),
                'different:team_b_id',
            ],
            'team_b_id' => [
                'required',
                'uuid',
                Rule::exists('cricket_teams', 'id')->where(
                    fn ($q) => $q->where('tournament_id', $request->tournament_id)
                ),
            ],
            'venue' => 'nullable|string|max:300',
            'ground_id' => 'nullable|uuid|exists:cricket_grounds,id',
            'scheduled_at' => 'required|date',
            'match_type' => 'required|in:'.self::MATCH_TYPES,
            'overs_per_side' => 'nullable|integer|min:1|max:90',
            'stage' => 'nullable|in:'.self::STAGES,
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $data['stage'] = $data['stage'] ?? 'group_stage';

        // Derive overs from the format when not explicitly provided.
        if (empty($data['overs_per_side'])) {
            $data['overs_per_side'] = $this->deriveOversForType($data['match_type']);
        }

        // Prevent the same pairing being scheduled twice in one stage.
        $duplicate = MatchModel::where('tournament_id', $data['tournament_id'])
            ->where('team_a_id', $data['team_a_id'])
            ->where('team_b_id', $data['team_b_id'])
            ->where('stage', $data['stage'])
            ->exists();
        if ($duplicate) {
            return response()->json([
                'message' => 'This fixture already exists for the tournament stage.',
            ], 422);
        }

        $match = MatchModel::create($data);

        return response()->json(
            $match->load(['teamA', 'teamB', 'ground']),
            201
        );
    }

    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $match = MatchModel::with([
            'teamA', 'teamB', 'ground',
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
            'team_a_id' => [
                'sometimes', 'uuid',
                Rule::exists('cricket_teams', 'id')->where(
                    fn ($q) => $q->where('tournament_id', $match->tournament_id)
                ),
                'different:team_b_id',
            ],
            'team_b_id' => [
                'sometimes', 'uuid',
                Rule::exists('cricket_teams', 'id')->where(
                    fn ($q) => $q->where('tournament_id', $match->tournament_id)
                ),
            ],
            'venue' => 'nullable|string|max:300',
            'ground_id' => 'nullable|uuid|exists:cricket_grounds,id',
            'scheduled_at' => 'sometimes|date',
            'match_type' => 'sometimes|in:'.self::MATCH_TYPES,
            'overs_per_side' => 'nullable|integer|min:1|max:90',
            'stage' => 'sometimes|in:'.self::STAGES,
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        // Teams may only be changed while the fixture is still scheduled.
        if (
            ($request->has('team_a_id') || $request->has('team_b_id'))
            && $match->status !== 'scheduled'
        ) {
            return response()->json([
                'message' => 'Teams can only be changed while the fixture is scheduled.',
            ], 422);
        }

        // Prevent duplicate pairing when teams or stage change.
        if ($request->has('team_a_id') || $request->has('team_b_id') || $request->has('stage')) {
            $teamA = $data['team_a_id'] ?? $match->team_a_id;
            $teamB = $data['team_b_id'] ?? $match->team_b_id;
            $stage = $data['stage'] ?? $match->stage;

            if ($teamA === $teamB) {
                return response()->json([
                    'message' => 'Team A and Team B must be different.',
                ], 422);
            }

            $duplicate = MatchModel::where('tournament_id', $match->tournament_id)
                ->where('team_a_id', $teamA)
                ->where('team_b_id', $teamB)
                ->where('stage', $stage)
                ->where('id', '!=', $match->id)
                ->exists();
            if ($duplicate) {
                return response()->json([
                    'message' => 'This fixture already exists for the tournament stage.',
                ], 422);
            }
        }

        $match->update($data);

        return response()->json($match->fresh()->load(['teamA', 'teamB', 'ground']));
    }

    /**
     * Cancel a scheduled fixture or re-open a cancelled one.
     *
     * Live-state transitions are owned by the scoring flow
     * (LiveScoreController) and are intentionally not allowed here.
     */
    public function updateStatus(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:cancelled,scheduled',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $match = MatchModel::findOrFail($id);

        $allowedTransitions = [
            'scheduled' => ['cancelled'],
            'cancelled' => ['scheduled'],
        ];

        if (!in_array($request->status, $allowedTransitions[$match->status] ?? [], true)) {
            return response()->json([
                'message' => "Fixture status cannot change from {$match->status} to {$request->status}.",
            ], 422);
        }

        $match->status = $request->status;
        $match->save();

        return response()->json($match->fresh()->load(['teamA', 'teamB', 'ground']));
    }

    /**
     * Auto-generate single or double round-robin fixtures for a tournament.
     *
     * Options:
     *   format                  single_round_robin | double_round_robin
     *   team_ids[]              optional subset (defaults to all active teams)
     *   start_date              first round date (required)
     *   match_interval_days     days between rounds (default 1; 0 = same day)
     *   kickoff_time            first kickoff of the day, HH:MM (default 09:00)
     *   match_gap_hours         hours between consecutive kickoffs (default 3)
     *   default_match_type      t20 | odi | test | t10 | other (default t20)
     *   default_overs_per_side  optional, derived from match type when omitted
     *   default_venue           free-text venue for all generated fixtures
     *   default_ground_id       ground reference for all generated fixtures
     *   stage                   bracket tag (default group_stage)
     *   force                   allow generation when fixtures already exist
     */
    public function generateFixtures(Request $request, string $tournamentId): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::findOrFail($tournamentId);

        $validator = Validator::make($request->all(), [
            'format' => 'required|in:single_round_robin,double_round_robin',
            'team_ids' => 'nullable|array|min:2',
            'team_ids.*' => 'uuid|exists:cricket_teams,id',
            'start_date' => 'required|date',
            'match_interval_days' => 'nullable|integer|min:0|max:30',
            'kickoff_time' => 'nullable|date_format:H:i',
            'match_gap_hours' => 'nullable|integer|min:1|max:12',
            'default_match_type' => 'nullable|in:'.self::MATCH_TYPES,
            'default_overs_per_side' => 'nullable|integer|min:1|max:90',
            'default_venue' => 'nullable|string|max:300',
            'default_ground_id' => 'nullable|uuid|exists:cricket_grounds,id',
            'stage' => 'nullable|in:'.self::STAGES,
            'force' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Never generate over live data.
        $liveCount = MatchModel::where('tournament_id', $tournamentId)
            ->whereIn('status', ['toss_pending', 'toss_done', 'in_progress', 'innings_break'])
            ->count();
        if ($liveCount > 0) {
            return response()->json([
                'message' => 'Cannot generate fixtures while matches are live or in progress.',
            ], 422);
        }

        // Guard against accidental duplicate generation.
        $existingCount = MatchModel::where('tournament_id', $tournamentId)
            ->where('status', '!=', 'cancelled')
            ->count();
        if ($existingCount > 0 && !$request->boolean('force')) {
            return response()->json([
                'message' => 'Fixtures already exist for this tournament. Pass force=true to generate anyway.',
            ], 422);
        }

        $teamIds = $request->input('team_ids');
        if (empty($teamIds)) {
            $teamIds = $tournament->teams()
                ->where('status', 'active')
                ->orderBy('name')
                ->pluck('id')
                ->all();
        }

        if (count($teamIds) < 2) {
            return response()->json([
                'message' => 'At least 2 teams are required to generate fixtures.',
            ], 422);
        }

        $rounds = $this->buildRoundRobinRounds($teamIds);
        if ($request->input('format') === 'double_round_robin') {
            // Second leg: same pairings with home/away swapped.
            $rounds = array_merge(
                $rounds,
                array_map(
                    fn (array $round) => array_map(
                        fn (array $pair) => [$pair[1], $pair[0]],
                        $round
                    ),
                    $rounds
                )
            );
        }

        $intervalDays = (int) $request->input('match_interval_days', 1);
        $start = \Carbon\Carbon::parse($request->input('start_date'))->startOfDay();
        $kickoff = \Carbon\Carbon::parse($request->input('kickoff_time', '09:00'));
        $gapHours = (int) $request->input('match_gap_hours', 3);
        $stage = $request->input('stage', 'group_stage');
        $matchType = $request->input('default_match_type', 't20');

        $overs = $request->input('default_overs_per_side');
        if (empty($overs)) {
            $overs = $this->deriveOversForType($matchType);
        }

        $venue = $request->input('default_venue');
        $groundId = $request->input('default_ground_id');

        $created = DB::transaction(function () use (
            $rounds, $intervalDays, $start, $kickoff, $gapHours, $stage, $matchType,
            $overs, $venue, $groundId, $tournamentId
        ) {
            $matches = [];
            $matchCounter = 0;
            foreach ($rounds as $roundIndex => $round) {
                $roundDate = $start->copy()->addDays($roundIndex * $intervalDays);
                foreach ($round as $pair) {
                    // Stagger kickoffs globally from the configured start time
                    // and gap so times never collide, even when every round
                    // shares a single day (match_interval_days = 0).
                    $scheduledAt = $roundDate->copy()
                        ->setTimeFrom($kickoff)
                        ->addHours($matchCounter * $gapHours);
                    $matchCounter++;
                    $matches[] = MatchModel::create([
                        'tournament_id' => $tournamentId,
                        'team_a_id' => $pair[0],
                        'team_b_id' => $pair[1],
                        'venue' => $venue,
                        'ground_id' => $groundId,
                        'scheduled_at' => $scheduledAt,
                        'match_type' => $matchType,
                        'overs_per_side' => $overs,
                        'stage' => $stage,
                        'status' => 'scheduled',
                    ]);
                }
            }
            return $matches;
        });

        return response()->json([
            'message' => 'Fixtures generated.',
            'count' => count($created),
            'matches' => MatchModel::with(['teamA', 'teamB', 'ground'])
                ->whereIn('id', collect($created)->pluck('id'))
                ->orderBy('scheduled_at')
                ->get(),
        ], 201);
    }

    /**
     * Default overs per side for a match format.
     *
     * Tests are unlimited-overs; they are stored at the maximum supported
     * value (90) as a placeholder.
     */
    private function deriveOversForType(string $matchType): int
    {
        return match ($matchType) {
            't20' => 20,
            'odi' => 50,
            't10' => 10,
            'test' => 90,
            'other' => 20,
        };
    }

    /**
     * Circle-method round-robin: returns rounds of [homeId, awayId] pairs.
     *
     * With an odd number of teams a bye entry is inserted so every team
     * rests once per round; bye pairings are skipped.
     */
    private function buildRoundRobinRounds(array $teamIds): array
    {
        $teams = array_values($teamIds);
        if (count($teams) % 2 !== 0) {
            $teams[] = null; // bye
        }

        $n = count($teams);
        $half = intdiv($n, 2);
        $rounds = [];

        for ($round = 0; $round < $n - 1; $round++) {
            $pairs = [];
            for ($i = 0; $i < $half; $i++) {
                $a = $teams[$i];
                $b = $teams[$n - 1 - $i];
                if ($a !== null && $b !== null) {
                    $pairs[] = [$a, $b];
                }
            }
            $rounds[] = $pairs;

            // Rotate clockwise: keep first team fixed.
            $last = array_pop($teams);
            array_splice($teams, 1, 0, [$last]);
        }

        return $rounds;
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
