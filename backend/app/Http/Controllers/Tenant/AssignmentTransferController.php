<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * NEXATRACE — ASSIGNMENT TRANSFER CONTROLLER
 * ===========================================
 *
 * Implements identity portability (§10.11.2) — allows an
 * owner/driver/conductor to be transferred from one carrier
 * company to another without losing their global identity,
 * credentials, or history.
 *
 * Transfer is a two-step state machine:
 *   1. POST /transfer  → soft-unlink + create pending_acceptance
 *   2. POST /accept    → promote to active
 *
 * The partial unique index one_active_assignment_per_role
 * ensures no identity holds two active assignments for the
 * same role simultaneously.
 */
class AssignmentTransferController extends Controller
{
    /**
     * POST /api/v1/admin/assignments/{id}/transfer
     *
     * Body: { "to_carrier_company_id": "<uuid>", "reason": "..." }
     */
    public function transfer(string $assignmentId, Request $request): JsonResponse
    {
        $data = $request->validate([
            'to_carrier_company_id' => ['required', 'uuid'],
            'reason'                => ['nullable', 'string', 'max:500'],
        ]);

        return DB::transaction(function () use ($assignmentId, $data) {
            $current = DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->lockForUpdate()
                ->first();

            if (!$current) {
                return response()->json(['message' => 'Assignment not found'], 404);
            }
            if ($current->status !== 'active') {
                return response()->json([
                    'message' => 'Only active assignments can be transferred.',
                ], 422);
            }

            // Step 1: soft-unlink current assignment
            DB::table('fleet_assignments')
                ->where('id', $assignmentId)
                ->update([
                    'status'          => 'unassigned',
                    'unassigned_at'   => now(),
                    'unassign_reason' => $data['reason'] ?? 'Transferred to new carrier',
                    'updated_at'      => now(),
                ]);

            // Step 2: create pending_acceptance assignment under new carrier
            $newId = (string) Str::orderedUuid();
            DB::table('fleet_assignments')->insert([
                'id'                  => $newId,
                'global_identity_id'  => $current->global_identity_id,
                'carrier_company_id'  => $data['to_carrier_company_id'],
                'role'                => $current->role,
                'fleet_type'          => $current->fleet_type,
                'status'              => 'pending_acceptance',
                'assignment_meta'     => $current->assignment_meta,
                'created_at'          => now(),
                'updated_at'          => now(),
            ]);

            return response()->json([
                'success' => true,
                'data'    => [
                    'old_assignment_id'  => $assignmentId,
                    'new_assignment_id'  => $newId,
                    'identity_preserved' => true,
                    'message'            => 'Transfer initiated. Awaiting acceptance by new carrier.',
                ],
            ], 201);
        });
    }

    /**
     * POST /api/v1/admin/assignments/{id}/accept
     *
     * Called by the new carrier's admin or the identity owner.
     */
    public function accept(string $assignmentId, Request $request): JsonResponse
    {
        $row = DB::table('fleet_assignments')
            ->where('id', $assignmentId)
            ->first();

        if (!$row) {
            return response()->json(['message' => 'Not found'], 404);
        }
        if ($row->status !== 'pending_acceptance') {
            return response()->json(['message' => 'Already finalized'], 422);
        }

        DB::table('fleet_assignments')
            ->where('id', $assignmentId)
            ->update([
                'status'      => 'active',
                'accepted_at' => now(),
                'updated_at'  => now(),
            ]);

        return response()->json([
            'success' => true,
            'data'    => [
                'id'     => $assignmentId,
                'status' => 'active',
            ],
        ]);
    }

    /**
     * GET /api/v1/admin/assignments/{globalIdentityId}/history
     *
     * Returns full assignment history for an identity — all carriers
     * they've been linked to, in chronological order.
     */
    public function history(string $globalIdentityId): JsonResponse
    {
        $history = DB::table('fleet_assignments AS fa')
            ->join('tenant_accounts AS ta', 'fa.carrier_company_id', '=', 'ta.id')
            ->where('fa.global_identity_id', $globalIdentityId)
            ->orderBy('fa.created_at', 'desc')
            ->select(
                'fa.id',
                'fa.role',
                'fa.fleet_type',
                'fa.status',
                'fa.accepted_at',
                'fa.unassigned_at',
                'fa.unassign_reason',
                'fa.created_at',
                'ta.account_name AS carrier_name',
                'ta.id AS carrier_id',
            )
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $history,
        ]);
    }
}
