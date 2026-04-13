<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Hash;

class AdminUser extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'admin_users';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'status',
        'avatar_url',
        'phone',
        'timezone',
        'language',
        'email_verified_at',
        'last_login_at',
        'last_login_ip',
        'last_login_user_agent',
        'login_attempts',
        'force_password_change',
        'password_changed_at',
        'reset_token',
        'reset_token_expires_at',
        'metadata',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'reset_token',
        'reset_token_expires_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_login_at' => 'datetime',
        'password_changed_at' => 'datetime',
        'reset_token_expires_at' => 'datetime',
        'login_attempts' => 'integer',
        'force_password_change' => 'boolean',
        'metadata' => 'array',
        'deleted_at' => 'datetime',
    ];

    /**
     * The attributes that should be appended to the model's array form.
     *
     * @var array
     */
    protected $appends = [
        'avatar_url_full',
        'role_display',
        'status_display',
    ];

    /**
     * Get the full avatar URL.
     *
     * @return string|null
     */
    public function getAvatarUrlFullAttribute()
    {
        if (!$this->avatar_url) {
            return null;
        }

        if (filter_var($this->avatar_url, FILTER_VALIDATE_URL)) {
            return $this->avatar_url;
        }

        return asset('storage/' . $this->avatar_url);
    }

    /**
     * Get the display name for the role.
     *
     * @return string
     */
    public function getRoleDisplayAttribute()
    {
        return match($this->role) {
            'super_admin' => 'Super Admin',
            'admin' => 'Admin',
            'moderator' => 'Moderator',
            'support' => 'Support',
            default => ucfirst(str_replace('_', ' ', $this->role)),
        };
    }

    /**
     * Get the display name for the status.
     *
     * @return string
     */
    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'active' => 'Active',
            'inactive' => 'Inactive',
            'suspended' => 'Suspended',
            'locked' => 'Locked',
            'pending' => 'Pending',
            default => ucfirst($this->status),
        };
    }

    /**
     * Check if the user is a super admin.
     *
     * @return bool
     */
    public function isSuperAdmin(): bool
    {
        return $this->role === 'super_admin';
    }

    /**
     * Check if the user is an admin.
     *
     * @return bool
     */
    public function isAdmin(): bool
    {
        return in_array($this->role, ['super_admin', 'admin']);
    }

    /**
     * Check if the user is a moderator.
     *
     * @return bool
     */
    public function isModerator(): bool
    {
        return in_array($this->role, ['super_admin', 'admin', 'moderator']);
    }

    /**
     * Check if the user is active.
     *
     * @return bool
     */
    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    /**
     * Check if the user needs to change their password.
     *
     * @return bool
     */
    public function needsPasswordChange(): bool
    {
        if ($this->force_password_change) {
            return true;
        }

        if (!$this->password_changed_at) {
            return true;
        }

        $passwordExpiryDays = config('auth.password_expire_days', 90);
        return $this->password_changed_at->diffInDays(now()) >= $passwordExpiryDays;
    }

    /**
     * Increment login attempts.
     *
     * @return void
     */
    public function incrementLoginAttempts(): void
    {
        $this->increment('login_attempts');

        if ($this->login_attempts >= 5) {
            $this->update(['status' => 'locked']);
        }
    }

    /**
     * Reset login attempts.
     *
     * @return void
     */
    public function resetLoginAttempts(): void
    {
        $this->update(['login_attempts' => 0]);
    }

    /**
     * Set the password attribute with hashing.
     *
     * @param string $value
     * @return void
     */
    public function setPasswordAttribute($value): void
    {
        $this->attributes['password'] = Hash::make($value);
    }

    /**
     * Get the permissions for the admin user.
     *
     * @return \Illuminate\Database\Eloquent\Relations\BelongsToMany
     */
    public function permissions()
    {
        return $this->belongsToMany(AdminPermission::class, 'admin_user_permissions', 'admin_user_id', 'permission_id')
            ->withTimestamps();
    }

    /**
     * Check if the user has a specific permission.
     *
     * @param string $permission
     * @return bool
     */
    public function hasPermission(string $permission): bool
    {
        // Super admins have all permissions
        if ($this->isSuperAdmin()) {
            return true;
        }

        return $this->permissions()->where('name', $permission)->exists();
    }

    /**
     * Check if the user has any of the given permissions.
     *
     * @param array $permissions
     * @return bool
     */
    public function hasAnyPermission(array $permissions): bool
    {
        // Super admins have all permissions
        if ($this->isSuperAdmin()) {
            return true;
        }

        return $this->permissions()->whereIn('name', $permissions)->exists();
    }

    /**
     * Check if the user has all of the given permissions.
     *
     * @param array $permissions
     * @return bool
     */
    public function hasAllPermissions(array $permissions): bool
    {
        // Super admins have all permissions
        if ($this->isSuperAdmin()) {
            return true;
        }

        $userPermissionCount = $this->permissions()->whereIn('name', $permissions)->count();
        return $userPermissionCount === count($permissions);
    }

    /**
     * Get the companies managed by this admin.
     *
     * @return \Illuminate\Database\Eloquent\Relations\BelongsToMany
     */
    public function managedCompanies()
    {
        return $this->belongsToMany(Company::class, 'admin_company_assignments', 'admin_user_id', 'company_id')
            ->withPivot(['assigned_at', 'assigned_by', 'role'])
            ->withTimestamps();
    }

    /**
     * Get the audit logs for this admin.
     *
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function auditLogs()
    {
        return $this->hasMany(AdminAuditLog::class, 'admin_user_id');
    }

    /**
     * Get the login history for this admin.
     *
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function loginHistory()
    {
        return $this->hasMany(AdminLoginHistory::class, 'admin_user_id');
    }

    /**
     * Scope a query to only include active users.
     *
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    /**
     * Scope a query to only include super admins.
     *
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeSuperAdmins($query)
    {
        return $query->where('role', 'super_admin');
    }

    /**
     * Scope a query to only include admins.
     *
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeAdmins($query)
    {
        return $query->whereIn('role', ['super_admin', 'admin']);
    }

    /**
     * Scope a query to only include users with a specific role.
     *
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @param string $role
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeRole($query, string $role)
    {
        return $query->where('role', $role);
    }

    /**
     * Scope a query to only include users who need to change their password.
     *
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeNeedsPasswordChange($query)
    {
        $passwordExpiryDays = config('auth.password_expire_days', 90);
        $expiryDate = now()->subDays($passwordExpiryDays);

        return $query->where(function ($q) use ($expiryDate) {
            $q->where('force_password_change', true)
              ->orWhereNull('password_changed_at')
              ->orWhere('password_changed_at', '<=', $expiryDate);
        });
    }

    /**
     * Get the dashboard statistics for this admin.
     *
     * @return array
     */
    public function getDashboardStats(): array
    {
        $stats = [
            'total_companies' => $this->managedCompanies()->count(),
            'active_companies' => $this->managedCompanies()->where('status', 'active')->count(),
            'pending_companies' => $this->managedCompanies()->where('status', 'pending')->count(),
            'suspended_companies' => $this->managedCompanies()->where('status', 'suspended')->count(),
            'recent_activity' => $this->auditLogs()->latest()->limit(10)->get(),
            'last_login' => $this->last_login_at ? $this->last_login_at->diffForHumans() : 'Never',
        ];

        return $stats;
    }
}
