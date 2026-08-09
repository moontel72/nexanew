<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Player;
use Illuminate\Http\Request;
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

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'team_id' => 'required|uuid|exists:cricket_teams,id',
            'name' => 'required|string|max:200',
            'jersey_number' => 'nullable|string|max:5',
            'role' => 'required|in:batsman,bowler,all_rounder,wicket_keeper',
            'batting_style' => 'nullable|string|max:50',
            'bowling_style' => 'nullable|string|max:100',
            'photo_url' => 'nullable|url|max:500',
            'is_captain' => 'boolean',
            'is_wicket_keeper' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $player = Player::create($validator->validated());

        return response()->json($player, 201);
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
            'is_captain' => 'boolean',
            'is_wicket_keeper' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $player->update($validator->validated());
        return response()->json($player);
    }

    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        Player::findOrFail($id)->delete();
        return response()->json(['message' => 'Player deleted.']);
    }
}
