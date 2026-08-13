<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Ground;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class GroundController extends Controller
{
    /**
     * List grounds (optionally search by name or location).
     */
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $grounds = Ground::query()
            ->when($request->search, fn ($q) => $q->where(
                fn ($w) => $w
                    ->where('name', 'ilike', "%{$request->search}%")
                    ->orWhere('location', 'ilike', "%{$request->search}%")
            ))
            ->orderBy('name')
            ->paginate($request->per_page ?? 50);

        return response()->json($grounds);
    }

    /**
     * Create a ground / venue.
     */
    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:200',
            'location' => 'nullable|string|max:200',
            'capacity' => 'nullable|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $ground = Ground::create($validator->validated());

        return response()->json($ground, 201);
    }

    /**
     * Update a ground.
     */
    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $ground = Ground::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:200',
            'location' => 'nullable|string|max:200',
            'capacity' => 'nullable|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $ground->update($validator->validated());

        return response()->json($ground);
    }

    /**
     * Soft-delete a ground.
     */
    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        Ground::findOrFail($id)->delete();

        return response()->json(['message' => 'Ground deleted.']);
    }
}
