<?php

namespace App\Jobs;

use App\Services\Financial\CommissionService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — COMMISSION PAYOUT JOB
 * ===================================
 *
 * Async background job that executes commission calculations
 * and wallet payouts on completed orders / freight trips.
 *
 * DISPATCH TRIGGERS:
 *   - Freight load marked as 'delivered' (Module 9G)
 *   - B2B marketplace group buy pool completed (Module 12D)
 *   - Code generation invoice paid (Module 3AF)
 *
 * FLOW:
 *   1. Reads payer/payee/module/amount from job payload
 *   2. Calls CommissionService::processPayout()
 *   3. lockForUpdate() prevents race conditions
 *   4. Double-entry produces 3 immutable transactions
 *   5. Net payout credited to vendor/driver wallet
 *
 * QUEUE: finance (Redis)
 * TIMEOUT: 120 seconds
 * RETRIES: 2
 *
 * TARGET MODULES: 9G, 10F, 11H, 12A
 *
 * SAFETY:
 *   - Entirely NEW job. Uses only CommissionService + financial models.
 *   - Zero interaction with existing code.
 */

class CommissionPayoutJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $timeout = 120;
    public int $tries = 2;
    public int $maxExceptions = 2;

    private string $module;
    private string $payerType;
    private string $payerId;
    private string $payeeId;
    private string $payeeType;
    private float $amount;
    private string $referenceId;
    private string $referenceType;
    private string $currency;

    /**
     * @param string $module        freight_auction | code_generation | marketplace
     * @param string $payerType     truck_owner | truck_driver | factory | reseller | goods_company
     * @param string $payerId       Payer wallet owner ID
     * @param string $payeeId       Payee wallet owner ID
     * @param string $payeeType     Payee owner type
     * @param float  $amount        Gross transaction amount
     * @param string $referenceId   Order/trip/bid ID
     * @param string $referenceType trip | order | freight_load | group_buy_pool
     * @param string $currency      Default USD
     */
    public function __construct(
        string $module,
        string $payerType,
        string $payerId,
        string $payeeId,
        string $payeeType,
        float $amount,
        string $referenceId,
        string $referenceType = 'trip',
        string $currency = 'USD'
    ) {
        $this->module = $module;
        $this->payerType = $payerType;
        $this->payerId = $payerId;
        $this->payeeId = $payeeId;
        $this->payeeType = $payeeType;
        $this->amount = $amount;
        $this->referenceId = $referenceId;
        $this->referenceType = $referenceType;
        $this->currency = $currency;

        $this->queue = 'finance';
        $this->connection = 'redis';
    }

    public function handle(CommissionService $service): void
    {
        Log::info('CommissionPayoutJob: processing', [
            'module' => $this->module,
            'payer' => "{$this->payerId}({$this->payerType})",
            'payee' => "{$this->payeeId}({$this->payeeType})",
            'amount' => $this->amount,
            'reference' => $this->referenceId,
        ]);

        try {
            $result = $service->processPayout(
                module: $this->module,
                payerType: $this->payerType,
                payerId: $this->payerId,
                payeeId: $this->payeeId,
                payeeType: $this->payeeType,
                amount: $this->amount,
                referenceId: $this->referenceId,
                referenceType: $this->referenceType,
                currency: $this->currency,
            );

            Log::info('CommissionPayoutJob: completed', [
                'commission' => $result['commission'],
                'net_payout' => $result['net_payout'],
                'txn_count' => count($result['transactions']),
            ]);
        } catch (\RuntimeException $e) {
            Log::warning('CommissionPayoutJob: payout failed', [
                'error' => $e->getMessage(),
                'reference' => $this->referenceId,
            ]);

            // Re-throw to trigger retry (insufficient funds errors are transient)
            if (str_contains($e->getMessage(), 'Insufficient funds')) {
                throw $e;
            }

            // Non-retryable failures log and exit
            $this->fail($e);
        }
    }

    public function failed(\Throwable $exception): void
    {
        Log::error('CommissionPayoutJob: FAILED', [
            'module' => $this->module,
            'payer' => $this->payerId,
            'payee' => $this->payeeId,
            'amount' => $this->amount,
            'reference' => $this->referenceId,
            'error' => $exception->getMessage(),
        ]);
    }
}
