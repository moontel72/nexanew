<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Http\Middleware\Cricket\CricketManagerAuth;
use App\Models\Cricket\ManagerSessionLog;
use App\Models\Cricket\MatchModel;
use App\Models\Cricket\MatchSquad;
use App\Models\Cricket\Player;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

/**
 * SquadController — Playing XI / batting order management per match.
 *
 * Phase 0 foundation for:
 *   - Opening batter selection & batting-order sequence
 *   - Bench selection before the match
 *   - The live scorer's "next batter" suggestions after a wicket
 */
class SquadController extends Controller
{
    /**
     * List both teams' squads (XI + bench) for a match.
     */
    public function index(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $match = MatchModel::with(['teamA', 'teamB'])->findOrFail($matchId);

        $rows = MatchSquad::with(['player'])
            ->where('match_id', $matchId)
            ->orderBy('team_id')
            ->orderBy('batting_order')
            ->get();

        $squads = collect([$match->teamA, $match->teamB])
            ->filter()
            ->map(function ($team) use ($rows) {
                $players = $rows
                    ->where('team_id', $team->id)
                    ->map(function (MatchSquad $row) {
                        $player = $row->player;

                        return [
                            'player_id' => $row->player_id,
                            'name' => $player?->name ?? '',
                            'jersey_number' => $player?->jersey_number,
                            'role' => $player?->role,
                            'batting_style' => $player?->batting_style,
                            'bowling_style' => $player?->bowling_style,
                            'is_captain' => (bool) ($player?->is_captain ?? false),
                            'is_wicket_keeper' => (bool) ($player?->is_wicket_keeper ?? false),
                            'batting_order' => $row->batting_order,
                            'status' => $row->status,
                        ];
                    })
                    ->values()
                    ->all();

                return [
                    'team_id' => $team->id,
                    'team_name' => $team->name,
                    'team_short' => $team->short_code,
                    'players' => $players,
                ];
            })
            ->values()
            ->all();

        return response()->json(['squads' => $squads]);
    }

    /**
     * Replace a team's squad for a match with a new batting order.
     *
     * Body: { "players": [ { "player_id": "...", "batting_order": 1 }, ... ] }
     */
    public function upsert(Request $request, string $matchId, string $teamId): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        $validator = Validator::make($request->all(), [
            'players' => 'required|array|min:1|max:15',
            'players.*.player_id' => 'required|uuid|exists:cricket_players,id',
            'players.*.batting_order' => 'required|integer|min:1|max:15',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $match = MatchModel::findOrFail($matchId);
        if (!in_array($teamId, [$match->team_a_id, $match->team_b_id], true)) {
            return response()->json(['message' => 'Team is not part of this match.'], 422);
        }

        $entries = $request->players;

        // Uniqueness guards.
        $playerIds = array_column($entries, 'player_id');
        if (count($playerIds) !== count(array_unique($playerIds))) {
            return response()->json(['message' => 'A player cannot appear twice in a squad.'], 422);
        }
        $orders = array_column($entries, 'batting_order');
        if (count($orders) !== count(array_unique($orders))) {
            return response()->json(['message' => 'Batting order positions must be unique.'], 422);
        }

        // Every selected player must belong to this team.
        $players = Player::whereIn('id', $playerIds)->get()->keyBy('id');
        foreach ($entries as $entry) {
            $player = $players->get($entry['player_id']);
            if (!$player || $player->team_id !== $teamId) {
                return response()->json([
                    'message' => 'One or more players do not belong to this team.',
                ], 422);
            }
        }

        DB::transaction(function () use ($matchId, $teamId, $entries) {
            // Replace the previous squad (soft-deleted; partial unique
            // indexes ignore deleted rows).
            MatchSquad::where('match_id', $matchId)
                ->where('team_id', $teamId)
                ->delete();

            foreach ($entries as $entry) {
                MatchSquad::create([
                    'match_id' => $matchId,
                    'team_id' => $teamId,
                    'player_id' => $entry['player_id'],
                    'batting_order' => $entry['batting_order'],
                    'status' => 'in_xi',
                ]);
            }
        });

        ManagerSessionLog::create([
            'cricket_manager_id' => $manager->id,
            'match_id' => $matchId,
            'action' => 'update_squad',
            'metadata' => [
                'team_id' => $teamId,
                'players_count' => count($entries),
                'batting_order' => array_column($entries, 'batting_order'),
            ],
            'ip_address' => $request->ip(),
        ]);

        return response()->json([
            'message' => 'Squad saved.',
            'team_id' => $teamId,
            'players_count' => count($entries),
        ]);
    }
}
