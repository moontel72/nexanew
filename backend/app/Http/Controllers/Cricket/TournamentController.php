<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Tournament;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TournamentController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $tournaments = Tournament::withCount(['teams', 'matches'])
            ->when($request->status, fn($q) => $q->where('status', $request->status))
            ->when($request->has('is_active'), fn($q) => $q->where('is_active', $request->boolean('is_active')))
            ->orderBy('start_date', 'desc')
            ->paginate($request->per_page ?? 20);

        return response()->json($tournaments);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:200',
            'location' => 'nullable|string|max:200',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'description' => 'nullable|string',
            'logo_url' => 'nullable|url|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $tournament = Tournament::create($validator->validated());

        return response()->json($tournament, 201);
    }

    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::with(['teams', 'sponsors'])->findOrFail($id);
        return response()->json($tournament);
    }

    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:200',
            'location' => 'nullable|string|max:200',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after_or_equal:start_date',
            'description' => 'nullable|string',
            'logo_url' => 'nullable|url|max:500',
            'status' => 'sometimes|in:upcoming,active,completed,cancelled',
            'is_active' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $tournament->update($validator->validated());

        return response()->json($tournament);
    }

    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        Tournament::findOrFail($id)->delete();
        return response()->json(['message' => 'Tournament deleted.']);
    }
}
