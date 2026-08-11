<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Player;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class PlayerController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $players = Player::where('team_id', $request->team_id)
            ->when($request->role, fn($q) => $q->where('role', $request->role))
            ->orderBy('name')
            ->get();

        return response()->json($players);
    }

    public function listAll(): \Illuminate\Http\JsonResponse
    {
        $players = Player::with('team:id,name,short_code,team_code')
            ->orderByRaw("CASE 
                WHEN position = 'manager' THEN 1
                WHEN position = 'coach' THEN 2
                WHEN position = 'captain' THEN 3
                WHEN position = 'vice_captain' THEN 4
                WHEN position = 'player' THEN 5
                WHEN position = 'extra' THEN 6
                ELSE 7 END")
            ->orderByRaw("CASE WHEN status = 'active' THEN 1 ELSE 2 END")
            ->orderBy('name')
            ->paginate(100);

        // Ensure consistent typing in the response
        $players->getCollection()->transform(function ($player) {
            return [
                'id' => (string) $player->id,
                'team_id' => (string) $player->team_id,
                'name' => (string) $player->name,
                'player_code' => $player->player_code ? (string) $player->player_code : null,
                'jersey_number' => $player->jersey_number ? (string) $player->jersey_number : null,
                'role' => (string) $player->role,
                'batting_style' => $player->batting_style ? (string) $player->batting_style : null,
                'bowling_style' => $player->bowling_style ? (string) $player->bowling_style : null,
                'photo_url' => $player->photo_url ? (string) $player->photo_url : null,
                'is_captain' => (bool) $player->is_captain,
                'is_wicket_keeper' => (bool) $player->is_wicket_keeper,
                'position' => $player->position ? (string) $player->position : 'player',
                'status' => (string) ($player->status ?? 'active'),
                'team' => $player->team,
            ];
        });

        return response()->json($players);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'team_id' => 'required|uuid|exists:cricket_teams,id',
            'name' => 'required|string|max:200',
            'jersey_number' => 'nullable|string|max:5',
            'role' => 'required|in:batsman,bowler,all_rounder,wicket_keeper',
            'batting_style' => 'nullable|string|max:50',
            'bowling_style' => 'nullable|string|max:100',
            'photo' => 'nullable|image|max:5120',
            'is_captain' => 'boolean',
            'is_wicket_keeper' => 'boolean',
            'position' => 'nullable|in:player,captain,vice_captain,coach,manager,extra',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        // Handle photo upload
        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('players', 'public');
            $data['photo_url'] = Storage::url($path);
        }

        unset($data['photo']);

        $player = Player::create($data);

        return response()->json([
            'message' => 'Player created.',
            'player' => [
                'id' => (string) $player->id,
                'team_id' => (string) $player->team_id,
                'name' => (string) $player->name,
                'player_code' => $player->player_code ? (string) $player->player_code : null,
                'jersey_number' => $player->jersey_number ? (string) $player->jersey_number : null,
                'role' => (string) $player->role,
                'batting_style' => $player->batting_style ? (string) $player->batting_style : null,
                'bowling_style' => $player->bowling_style ? (string) $player->bowling_style : null,
                'photo_url' => $player->photo_url ? (string) $player->photo_url : null,
                'is_captain' => (bool) $player->is_captain,
                'is_wicket_keeper' => (bool) $player->is_wicket_keeper,
                'position' => $player->position ? (string) $player->position : 'player',
                'status' => (string) ($player->status ?? 'active'),
                'team' => $player->team,
            ],
        ], 201);
    }

    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $player = Player::with('team')->findOrFail($id);
        return response()->json($player);
    }

    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $player = Player::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:200',
            'jersey_number' => 'nullable|string|max:5',
            'role' => 'sometimes|in:batsman,bowler,all_rounder,wicket_keeper',
            'batting_style' => 'nullable|string|max:50',
            'bowling_style' => 'nullable|string|max:100',
            'photo' => 'nullable|image|max:5120',
            'is_captain' => 'boolean',
            'is_wicket_keeper' => 'boolean',
            'position' => 'nullable|in:player,captain,vice_captain,coach,manager,extra',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('players', 'public');
            $data['photo_url'] = Storage::url($path);
        }

        unset($data['photo']);
        $player->update($data);

        return response()->json($player->load('team:id,name,short_code,team_code'));
    }

    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        Player::findOrFail($id)->delete();
        return response()->json(['message' => 'Player deleted.']);
    }

    /**
     * List soft-deleted players (trash).
     */
    public function trashed(): \Illuminate\Http\JsonResponse
    {
        $players = Player::onlyTrashed()
            ->with('team:id,name,short_code,team_code')
            ->orderBy('deleted_at', 'desc')
            ->paginate(50);

        $players->getCollection()->transform(function ($player) {
            return [
                'id' => (string) $player->id,
                'team_id' => (string) $player->team_id,
                'name' => (string) $player->name,
                'player_code' => $player->player_code ? (string) $player->player_code : null,
                'jersey_number' => $player->jersey_number ? (string) $player->jersey_number : null,
                'role' => (string) $player->role,
                'batting_style' => $player->batting_style ? (string) $player->batting_style : null,
                'bowling_style' => $player->bowling_style ? (string) $player->bowling_style : null,
                'photo_url' => $player->photo_url ? (string) $player->photo_url : null,
                'is_captain' => (bool) $player->is_captain,
                'is_wicket_keeper' => (bool) $player->is_wicket_keeper,
                'status' => (string) ($player->status ?? 'active'),
                'deleted_at' => $player->deleted_at ? $player->deleted_at->toIso8601String() : null,
                'team' => $player->team,
            ];
        });

        return response()->json($players);
    }

    /**
     * Restore a soft-deleted player.
     */
    public function restore(string $id): \Illuminate\Http\JsonResponse
    {
        $player = Player::onlyTrashed()->findOrFail($id);
        $player->restore();

        return response()->json([
            'message' => 'Player restored successfully.',
            'player' => [
                'id' => (string) $player->id,
                'name' => (string) $player->name,
                'status' => (string) ($player->status ?? 'active'),
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

        $player = Player::findOrFail($id);
        $player->status = $request->status;
        $player->save();

        return response()->json([
            'message' => "Player status updated to {$player->status}.",
            'player' => [
                'id' => (string) $player->id,
                'name' => (string) $player->name,
                'status' => (string) $player->status,
            ],
        ]);
    }
}
