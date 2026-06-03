<?php

namespace App\Exceptions;

use RuntimeException;

/**
 * Wave 5 — Financial Mismatch Exception
 *
 * Thrown when double-entry validation fails or source/recipient
 * amounts do not balance within epsilon tolerance.
 *
 * This triggers an immediate transaction rollback, preventing
 * unbalanced financial states from persisting.
 */
class FinancialMismatchException extends RuntimeException
{
    /**
     * @param string      $message        Human-readable error description
     * @param string|null $ledgerId       Affected ledger UUID (null if cross-ledger)
     * @param float       $expectedAmount Sum that should have balanced
     * @param float       $actualAmount   Sum that was computed
     */
    public function __construct(
        string $message,
        public readonly ?string $ledgerId = null,
        public readonly float $expectedAmount = 0.0,
        public readonly float $actualAmount = 0.0,
    ) {
        parent::__construct($message, 422);
    }

    /**
     * Get structured context for error reporting.
     */
    public function context(): array
    {
        return [
            'ledger_id'       => $this->ledgerId,
            'expected_amount' => $this->expectedAmount,
            'actual_amount'   => $this->actualAmount,
            'delta'           => abs($this->expectedAmount - $this->actualAmount),
        ];
    }
}
