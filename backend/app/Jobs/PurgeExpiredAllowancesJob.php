<?php

namespace App\Jobs;

use App\Services\AuditService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;

/**
 * Wave 3 — Step 3.5: Purge Expired Allowances Job
 *
 * Scheduled daily job that:
 *   1. Finds tenant_allowance_grants rows where expires_at < NOW()
 *   2. Sets them to is_active = FALSE
 *   3. Updates parent tenant_allowance_matrix permissions_blob keys to 'hidden'
 *   4. Logs each purge event to audit_log_security
 *
 * Idempotent — safe to run multiple times.
 */
class PurgeExpiredAllowancesJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(AuditService $audit): void
    {
        // 1. Find all expired but still active grant rows
        $expiredGrants = DB::table('tenant_allowance_grants')
            ->where('is_active', true)
            ->whereNotNull('expires_at')
            ->where('expires_at', '<', now())
            ->get();

        if ($expiredGrants->isEmpty()) {
            return;
        }

        DB::transaction(function () use ($expiredGrants, $audit) {
            // 2. Deactivate all expired grant rows
            DB::table('tenant_allowance_grants')
                ->whereIn('id', $expiredGrants->pluck('id'))
                ->update([
                    'is_active'  => false,
                    'updated_at' => now(),
                ]);

            // 3. Update parent matrix: set each expired key to 'hidden'
            foreach ($expiredGrants as $grant) {
                $matrix = DB::table('tenant_allowance_matrix')
                    ->where('id', $grant->matrix_id)
                    ->first();

                if ($matrix) {
                    $blob = json_decode($matrix->permissions_blob, true) ?? [];
                    if (isset($blob[$grant->permission_key])) {
                        $blob[$grant->permission_key] = 'hidden';
                        DB::table('tenant_allowance_matrix')
                            ->where('id', $grant->matrix_id)
                            ->update([
                                'permissions_blob' => json_encode($blob),
                                'updated_at'       => now(),
                            ]);
                    }
                }

                // 4. Audit each purge
                $audit->emit('security', [
                    'event_type'                => 'allowance.expired',
                    'actor_global_identity_id'  => '00000000-0000-0000-0000-000000000000',
                    'target_global_identity_id' => $grant->owner_identity_id,
                    'payload'                   => [
                        'matrix_id'      => $grant->matrix_id,
                        'permission_key' => $grant->permission_key,
                        'carrier_id'     => $grant->carrier_company_id,
                        'expired_at'     => $grant->expires_at,
                    ],
                    'event_time' => now()->toIso8601String(),
                ]);
            }
        });
    }
}
