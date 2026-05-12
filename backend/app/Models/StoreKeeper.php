<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;

class StoreKeeper extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'store_keepers';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'factory_id',
        'name',
        'employee_id',
        'phone',
        'email',
        'password',
        'status',
        'duty_shift',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'status' => 'string',
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

    public function setPassword(string $plain): void
    {
        $salt = Str::random(16);
        $this->password = Hash::make($plain . $salt);
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
}
