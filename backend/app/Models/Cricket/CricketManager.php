<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class CricketManager extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_managers';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name',
        'email',
        'password',
        'phone',
        'auth_token',
        'token_expires_at',
        'status',
        'permissions',
        'provisioned_by_global_identity_id',
        'last_login_at',
        'last_login_ip',
    ];

    protected $hidden = [
        'password',
        'auth_token',
    ];

    protected $casts = [
        'permissions' => 'array',
        'token_expires_at' => 'datetime',
        'last_login_at' => 'datetime',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (CricketManager $manager): void {
            if (empty($manager->id)) {
                $manager->id = (string) Str::orderedUuid();
            }
        });
    }

    public function setPasswordAttribute($value): void
    {
        if ($value !== null && $value !== '') {
            $this->attributes['password'] = Hash::make($value);
        }
    }

    /**
     * Verify the plain-text password against the stored hash.
     */
    public function verifyPassword(string $password): bool
    {
        return Hash::check($password, $this->password);
    }

    /**
     * Generate a new auth token and store its hash.
     * Returns the plain-text token (only time it's visible).
     */
    public function generateAuthToken(): string
    {
        $plainToken = Str::random(64);
        $this->auth_token = hash('sha256', $plainToken);
        $this->token_expires_at = now()->addHours(12);
        $this->save();

        return $plainToken;
    }

    /**
     * Revoke the current auth token.
     */
    public function revokeAuthToken(): void
    {
        $this->auth_token = null;
        $this->token_expires_at = null;
        $this->save();
    }

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function matchAssignments()
    {
        return $this->hasMany(MatchManager::class, 'cricket_manager_id');
    }

    public function sessionLogs()
    {
        return $this->hasMany(ManagerSessionLog::class, 'cricket_manager_id');
    }
}
