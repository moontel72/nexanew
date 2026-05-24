<?php

namespace App\Models\Financial;

use Illuminate\Database\Eloquent\Model;

class CommissionConfig extends Model
{
    protected $table = 'financial_commission_configs';
    public $incrementing = false;
    protected $keyType = 'string';

    public const METHOD_PERCENTAGE = 'percentage';
    public const METHOD_FLAT = 'flat';
    public const METHOD_TIERED = 'tiered';

    protected $fillable = [
        'id', 'module', 'payer_type',
        'calculation_method', 'rate', 'tiers',
        'is_active', 'metadata',
    ];

    protected $casts = [
        'rate' => 'float', 'tiers' => 'array',
        'is_active' => 'boolean', 'metadata' => 'array',
    ];

    /**
     * Calculate the commission for a given transaction amount.
     */
    public function calculate(float $amount): float
    {
        return match ($this->calculation_method) {
            self::METHOD_FLAT => (float) $this->rate,
            self::METHOD_TIERED => $this->calculateTiered($amount),
            default => round($amount * (float) $this->rate, 2), // percentage
        };
    }

    private function calculateTiered(float $amount): float
    {
        $tiers = $this->tiers ?? [];
        foreach ($tiers as $tier) {
            $min = (float) ($tier['min_amount'] ?? 0);
            $max = (float) ($tier['max_amount'] ?? PHP_FLOAT_MAX);
            if ($amount >= $min && $amount <= $max) {
                return round($amount * (float) ($tier['rate'] ?? 0), 2);
            }
        }
        return round($amount * (float) $this->rate, 2);
    }
}
