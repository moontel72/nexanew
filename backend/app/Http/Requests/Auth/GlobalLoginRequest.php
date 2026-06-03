<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class GlobalLoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'identifier' => ['required', 'string', 'max:255'],
            'claim_type' => ['nullable', 'string', 'in:phone,email,cnic_old,cnic_new,passport,driving_license,device_fingerprint'],
            'password'   => ['required', 'string'],
            'fleet_role' => ['nullable', 'string', 'in:owner,driver,conductor,customer'],
            'fleet_type' => ['nullable', 'string', 'in:bus,truck,factory'],
        ];
    }

    public function messages(): array
    {
        return [
            'identifier.required' => 'An email, phone number, CNIC, or passport is required to log in.',
            'password.required'   => 'Password is required.',
            'claim_type.in'       => 'Invalid identifier type specified.',
        ];
    }
}
