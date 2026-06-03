<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AuditService;
use App\Services\ConfigurationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/**
 * Wave 3 — Step 3.1: Sub-Admin Feature Toggle Controller
 *
 * Enables the Master Admin to dynamically grant or revoke feature
 * permissions across the 4 Sub-Admin verticals at runtime.
 *
 * Section 10.3.3 Write Path:
 *   In one Postgres transaction:
 *     - INSERT/UPDATE/DELETE on sub_admin_feature_grants
 *     - UPDATE feature_grants_version_counter SET version = version + 1
 *   AFTER COMMIT:
 *     - Redis: SET feat:current_version <new_version>
 *     - Redis Pub/Sub: PUBLISH feat:version:bumped <new_version>
 *
 * This guarantees global cache invalidation across all connected
 * devices and Sub-Admin panels within milliseconds.
 */
class SubAdminFeatureToggleController extends Controller
{
    public function __construct(
        private readonly ConfigurationService $config,
        private readonly AuditService $audit
    ) {}

    /**
     * POST /api/v1/admin/sub-admins/toggle-feature
     *
     * Grants or revokes a feature_code from a Sub-Admin assignment.
     * Increments the global grants version counter atomically.
     *
     * Request:
     *   sub_admin_assignment_id : UUID  — target assignment
     *   feature_code            : string — dotted feature path
     *   action                  : string — 'grant' | 'revoke'
     *   scope_filter            : object — optional row-level scoping
     */
    public function toggleFeature(Request $request): JsonResponse
    {
        $user = $request->user();

        // Verify caller is Master Admin
        $isMaster = DB::table('master_admin_assignments')
            ->where('global_identity_id', $user->global_identity_id ?? null)
            ->whereNull('revoked_at')
            ->exists();

        if (!$isMaster) {
            return response()->json(['status' => 'error', 'message' => 'Only Master Admin can toggle features.'], 403);
        }

        $validated = $request->validate([
            'sub_admin_assignment_id' => ['required', 'uuid', 'exists:sub_admin_assignments,id'],
            'feature_code'            => ['required', 'string', 'exists:feature_registry,code'],
            'action'                  => ['required', 'string', Rule::in(['grant', 'revoke'])],
            'scope_filter'            => ['nullable', 'json'],
        ]);

        $assignmentId = $validated['sub_admin_assignment_id'];
        $featureCode  = $validated['feature_code'];
        $action       = $validated['action'];
        $scopeFilter  = $validated['scope_filter'] ?? null;

        // Resolve Master Admin assignment ID
        $masterAssignment = DB::table('master_admin_assignments')
            ->where('global_identity_id', $user->global_identity_id)
            ->whereNull('revoked_at')
            ->first();

        if (!$masterAssignment) {
            return response()->json(['status' => 'error', 'message' => 'Master Admin assignment not found.'], 500);
        }

        $newVersion = DB::transaction(function () use (
            $assignmentId, $featureCode, $action, $scopeFilter, $masterAssignment
        ): int {
            if ($action === 'grant') {
                // Upsert: re-activate if previously revoked, else insert new
                $existing = DB::table('sub_admin_feature_grants')
                    ->where('sub_admin_assignment_id', $assignmentId)
                    ->where('feature_code', $featureCode)
                    ->first();

                if ($existing) {
                    if ($existing->revoked_at !== null) {
                        // Re-grant a previously revoked grant
                        DB::table('sub_admin_feature_grants')
                            ->where('id', $existing->id)
                            ->update([
                                'revoked_at'                => null,
                                'scope_filter'              => $scopeFilter ? json_decode($scopeFilter, true) : $existing->scope_filter,
                                'granted_by_master_admin_id' => $masterAssignment->id,
                                'granted_at'                => now(),
                                'updated_at'                => now(),
                            ]);
                    } else {
                        // Update scope only
                        DB::table('sub_admin_feature_grants')
                            ->where('id', $existing->id)
                            ->update([
                                'scope_filter' => $scopeFilter ? json_decode($scopeFilter, true) : null,
                                'updated_at'   => now(),
                            ]);
                    }
                } else {
                    // Fresh grant
                    DB::table('sub_admin_feature_grants')->insert([
                        'id'                        => (string) Str::orderedUuid(),
                        'sub_admin_assignment_id'   => $assignmentId,
                        'feature_code'              => $featureCode,
                        'granted_by_master_admin_id' => $masterAssignment->id,
                        'granted_at'                => now(),
                        'scope_filter'              => $scopeFilter ? json_decode($scopeFilter, true) : null,
                        'created_at'                => now(),
                        'updated_at'                => now(),
                    ]);
                }
            } else {
                // Revoke: soft-revoke (set revoked_at)
                DB::table('sub_admin_feature_grants')
                    ->where('sub_admin_assignment_id', $assignmentId)
                    ->where('feature_code', $featureCode)
                    ->whereNull('revoked_at')
                    ->update([
                        'revoked_at' => now(),
                        'updated_at' => now(),
                    ]);
            }

            // Increment global version counter inside same transaction
            return $this->config->incrementVersion();
        });

        // F-1 Fix: wrap publishVersionBump in afterCommit to ensure
        // external observers never see a version that doesn't exist yet.
        DB::afterCommit(fn () => $this->config->publishVersionBump($newVersion));

        // Audit
        $this->audit->emit('security', [
            'event_type'               => "feature_toggle.{$action}",
            'actor_global_identity_id' => $user->global_identity_id,
            'payload'                  => [
                'assignment_id' => $assignmentId,
                'feature_code'  => $featureCode,
                'action'        => $action,
                'new_version'   => $newVersion,
            ],
            'event_time' => now()->toIso8601String(),
        ]);

        return response()->json([
            'status'             => 'success',
            'message'            => "Feature '{$featureCode}' {$action}ed successfully.",
            'action'             => $action,
            'feature_code'       => $featureCode,
            'new_grants_version' => $newVersion,
        ]);
    }

    /**
     * GET /api/v1/admin/sub-admins/grants/{assignmentId}
     *
     * List all active feature grants for a Sub-Admin assignment.
     */
    public function listGrants(string $assignmentId): JsonResponse
    {
        $grants = DB::table('sub_admin_feature_grants')
            ->join('feature_registry', 'sub_admin_feature_grants.feature_code', '=', 'feature_registry.code')
            ->where('sub_admin_feature_grants.sub_admin_assignment_id', $assignmentId)
            ->whereNull('sub_admin_feature_grants.revoked_at')
            ->select(
                'sub_admin_feature_grants.id',
                'sub_admin_feature_grants.feature_code',
                'feature_registry.module_name',
                'feature_registry.severity',
                'sub_admin_feature_grants.scope_filter',
                'sub_admin_feature_grants.granted_at'
            )
            ->get();

        return response()->json(['status' => 'success', 'data' => $grants]);
    }
}
