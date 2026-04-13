<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AdminUserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'name' => (string) ($this->name ?? ''),
            'email' => (string) ($this->email ?? ''),
            'role' => (string) ($this->role ?? ''),
            'status' => (string) ($this->status ?? ''),
            'phone' => $this->phone,
            'timezone' => $this->timezone,
            'language' => $this->language,
            'created_at' => optional($this->created_at)->toISOString(),
            'updated_at' => optional($this->updated_at)->toISOString(),
        ];
    }
}

