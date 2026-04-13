<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;

class FactoryUser extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'factory_users';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'email',
        'phone',
        'full_name',
        'position',
        'password_hash',
        'password_salt',
        'email_verified',
        'phone_verified',
        'permissions',
        'is_active',
        'last_login_at',
        'metadata',
    ];

    protected $hidden = [
        'password_hash',
        'password_salt',
        'remember_token',
    ];

    protected $casts = [
        'email_verified' => 'boolean',
        'phone_verified' => 'boolean',
        'permissions' => 'array',
        'is_active' => 'boolean',
        'last_login_at' => 'datetime',
        'metadata' => 'array',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function setPassword(string $plain): void
    {
        $salt = Str::random(16);
        $this->password_salt = $salt;
        $this->password_hash = Hash::make($plain . $salt);
    }

    public function verifyPassword(string $plain): bool
    {
        if (!$this->password_hash || !$this->password_salt) {
            return false;
        }

        return Hash::check($plain . $this->password_salt, $this->password_hash);
    }
}

