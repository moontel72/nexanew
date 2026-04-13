<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SubscriptionPlanResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $features = $this->features ?? [];
        if (!is_array($features)) {
            $features = [];
        }

        $limits = [
            'monthly_unit_codes' => (int) ($this->monthly_unit_codes ?? 0),
            'monthly_packet_codes' => (int) ($this->monthly_packet_codes ?? 0),
            'monthly_carton_codes' => (int) ($this->monthly_carton_codes ?? 0),
            'monthly_bundle_codes' => (int) ($this->monthly_bundle_codes ?? 0),
            'is_custom' => (bool) ($this->is_custom ?? false),
        ];

        $userLimits = [
            'store_keepers' => (int) ($this->max_stores ?? 0),
            'drivers' => (int) ($this->max_drivers ?? 0),
            'admin_users' => (int) ($this->max_users ?? 0),
            'active_products' => (int) (($this->metadata['active_products'] ?? 0) ?? 0),
            'is_custom' => (bool) ($this->is_custom ?? false),
        ];

        return [
            'id' => (string) $this->id,
            'name' => (string) ($this->name ?? ''),
            'type' => (string) ($this->type ?? 'basic'),
            'description' => (string) ($this->description ?? ''),
            'monthly_price' => (float) ($this->monthly_price ?? 0),
            'yearly_price' => (float) ($this->yearly_price ?? 0),
            'currency' => (string) ($this->currency ?? 'USD'),
            'billing_cycle' => 'monthly',
            'status' => (string) ($this->status ?? 'active'),
            'is_featured' => (bool) (($this->metadata['is_featured'] ?? false) ?? false),
            'is_popular' => (bool) (($this->metadata['is_popular'] ?? false) ?? false),
            'sort_order' => (int) (($this->metadata['sort_order'] ?? 0) ?? 0),
            'features' => $features,
            'limits' => $limits,
            'user_limits' => $userLimits,
            'storage_gb' => (int) (($this->metadata['storage_gb'] ?? 1) ?? 1),
            'daily_api_calls' => (int) (($this->metadata['daily_api_calls'] ?? 0) ?? 0),
            'is_recommended' => (bool) ($this->is_recommended ?? false),
            'company_count' => (int) ($this->company_count ?? 0),
            'metadata' => $this->metadata ?? [],
            'created_at' => optional($this->created_at)->toISOString(),
            'updated_at' => optional($this->updated_at)->toISOString(),
            'archived_at' => optional($this->archived_at)->toISOString(),
        ];
    }
}

