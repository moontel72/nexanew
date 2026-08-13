<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\BestXi;
use Illuminate\Http\Request;

class BestXiController extends Controller
{
    /**
     * Get all Best XI selections for a tournament or match (public).
     */
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $query = BestXi::query();

        if ($tournamentId = $request->query('tournament_id')) {
            $query->where('tournament_id', $tournamentId);
        }

        if ($matchId = $request->query('match_id')) {
            $query->where('match_id', $matchId);
        }

        $xis = $query->with('tournament:id,name')->get();

        return response()->json(['best_xi' => $xis]);
    }

    /**
     * Get a specific Best XI selection (public).
     */
    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $xi = BestXi::with('tournament:id,name', 'match:id,team_a_id,team_b_id,venue')
            ->findOrFail($id);

        // Resolve player names from selections JSON
        $selections = $xi->selections ?? [];
        $playerIds = collect($selections)->pluck('player_id')->toArray();

        $players = \App\Models\Cricket\Player::whereIn('id', $playerIds)
            ->with('team:id,name,short_code,logo_url')
            ->get()
            ->keyBy('id');

        $resolvedSelections = collect($selections)->map(function ($sel) use ($players) {
            $player = $players->get($sel['player_id'] ?? '');
            return array_merge($sel, [
                'player_name' => $player->name ?? 'Unknown',
                'player_photo' => $player->photo_url ?? null,
                'player_role' => $player->role ?? null,
                'team_name' => $player->team->name ?? '',
                'team_short' => $player->team->short_code ?? '',
            ]);
        })->toArray();

        return response()->json([
            'best_xi' => [
                'id' => $xi->id,
                'team_label' => $xi->team_label,
                'tournament_name' => $xi->tournament->name ?? null,
                'selections' => $resolvedSelections,
            ],
        ]);
    }
}
