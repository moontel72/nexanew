<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Http\Middleware\Cricket\CricketManagerAuth;
use App\Models\Cricket\MatchModel;
use App\Services\Cricket\ActiveMatchContextService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

/**
 * MatchContextController — the manager-side REST surface of the unified
 * "Active Match Context" (Phase 1 realtime sync engine).
 *
 * Selection flows:
 *   Flutter Manager dropdown → PUT /api/v1/cricket/manager/active-match
 *     → Redis write + `match.context.selected` broadcast on Reverb
 *     → Rust media engine subscribes, flips its scoreboard context
 *     → Todd Studio scoreboard switches automatically (sub-100ms).
 */
class MatchContextController extends Controller
{
    public function __construct(private readonly ActiveMatchContextService $context)
    {
    }

    public function show(Request $request): JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        return response()->json([
            'manager_id' => $manager->id,
            'active_match_id' => $this->context->get((string) $manager->id),
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        $validator = Validator::make($request->all(), [
            'match_id' => 'required|string|max:64',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $matchId = (string) $validator->validated()['match_id'];

        // The context must reference a real match. Managers operate inside
        // one tournament scope; a broader ownership check belongs to the
        // tournament boundary, not this context key.
        if (!MatchModel::where('id', $matchId)->exists()) {
            return response()->json(['message' => 'Match not found.'], 404);
        }

        $this->context->set((string) $manager->id, $matchId);

        return response()->json([
            'manager_id' => $manager->id,
            'active_match_id' => $matchId,
        ]);
    }

    public function destroy(Request $request): JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        $this->context->clear((string) $manager->id);

        return response()->json([
            'manager_id' => $manager->id,
            'active_match_id' => null,
        ]);
    }
}
