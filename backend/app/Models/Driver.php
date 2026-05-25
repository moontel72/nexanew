<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\HasApiTokens;

class Driver extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'drivers';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'factory_id',
        'name',
        'phone',
        'email',
        'password',
        'driver_type',
        'staff_type',
        'cnic',
        'address',
        'hire_date',
        'salary',
        'license_number',
        'license_expiry',
        'vehicle_plate_number',
        'vehicle_type',
        'insurance_number',
        'insurance_expiry',
        'registration_expiry',
        'status',
        'tier',
        'rating',
        'total_trips',
        'completed_trips',
        'driving_hours_today',
        'driving_hours_week',
        'is_fatigued',
        'is_active',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'license_expiry' => 'datetime',
        'insurance_expiry' => 'datetime',
        'registration_expiry' => 'datetime',
        'status' => 'string',
        'tier' => 'string',
        'rating' => 'float',
        'is_fatigued' => 'boolean',
        'last_login_at' => 'datetime',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function factory()
    {
        return $this->belongsTo(Company::class, 'factory_id');
    }

    public function setPasswordAttribute(string $value): void
    {
        $this->attributes['password'] = Hash::make($value);
    }

    public function verifyPassword(string $plain): bool
    {
        if (!$this->password) {
            return false;
        }
        return Hash::check($plain, $this->password);
    }

    public function scopeForFactory($query, $factoryId)
    {
        return $query->where('factory_id', $factoryId);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeByTier($query, $tier)
    {
        return $query->where('tier', $tier);
    }
}
