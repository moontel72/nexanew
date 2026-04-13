<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CompanyResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $subscription = $this->whenLoaded('activeSubscription');
        $plan = $subscription && $subscription->relationLoaded('plan') ? $subscription->plan : null;

        return [
            'id' => (string) $this->id,
            'name' => (string) ($this->name ?? ''),
            'trading_name' => (string) (($this->metadata['trading_name'] ?? '') ?? ''),
            'registration_number' => (string) ($this->business_registration_number ?? ''),
            'tax_id' => $this->tax_id,
            'type' => (string) ($this->company_type ?? 'manufacturing'),
            'industry' => (string) ($this->industry_type ?? 'other'),
            'country' => (string) ($this->country ?? ''),
            'city' => (string) ($this->city ?? ''),
            'address' => (string) ($this->address ?? ''),
            'postal_code' => $this->postal_code,
            'phone' => (string) ($this->phone ?? ''),
            'email' => (string) ($this->email ?? ''),
            'website' => $this->website,
            'status' => (string) ($this->status ?? 'pending'),
            'verification_status' => (string) ($this->verification_status ?? 'notSubmitted'),
            'contact_person' => [
                'name' => (string) ($this->contact_person_name ?? ''),
                'email' => (string) ($this->contact_person_email ?? ''),
                'phone' => (string) ($this->contact_person_phone ?? ''),
                'position' => $this->contact_person_position,
            ],
            'subscription_plan' => $plan ? new SubscriptionPlanResource($plan) : null,
            'subscription_id' => $subscription ? (string) $subscription->id : null,
            'billing_cycle' => $subscription ? (string) ($subscription->billing_cycle ?? 'monthly') : 'monthly',
            'subscription_start_date' => $subscription ? optional($subscription->start_date)->toISOString() : null,
            'subscription_end_date' => $subscription ? optional($subscription->end_date)->toISOString() : null,
            'is_trial' => (bool) (($this->metadata['is_trial'] ?? false) ?? false),
            'trial_end_date' => (($this->metadata['trial_end_date'] ?? null) ?: null),
            'employee_count' => (int) ($this->active_users_count ?? 0),
            'annual_revenue' => (($this->metadata['annual_revenue'] ?? null) ?: null),
            'revenue_currency' => (string) (($this->metadata['revenue_currency'] ?? 'USD') ?? 'USD'),
            'notes' => (($this->metadata['notes'] ?? null) ?: null),
            'tags' => (array) (($this->metadata['tags'] ?? []) ?? []),
            'documents' => $this->whenLoaded('documents', function () {
                return $this->documents->map(function ($doc) {
                    return [
                        'id' => (string) $doc->id,
                        'document_type' => (string) ($doc->document_type ?? ''),
                        'document_name' => (string) ($doc->document_name ?? ''),
                        'document_url' => (string) ($doc->document_url ?? ''),
                        'verification_status' => (string) ($doc->verification_status ?? 'pending'),
                        'verification_notes' => $doc->verification_notes,
                        'created_at' => optional($doc->created_at)->toISOString(),
                    ];
                })->all();
            }),
            'settings' => (array) (($this->metadata['settings'] ?? []) ?? []),
            'usage_stats' => [
                'total_codes_generated' => (int) ($this->total_codes_generated ?? 0),
                'active_users_count' => (int) ($this->active_users_count ?? 0),
                'last_activity_at' => optional($this->last_activity_at)->toISOString(),
            ],
            'created_at' => optional($this->created_at)->toISOString(),
            'updated_at' => optional($this->updated_at)->toISOString(),
        ];
    }
}

