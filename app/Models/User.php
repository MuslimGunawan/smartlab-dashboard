<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function labs(): BelongsToMany
    {
        return $this->belongsToMany(Lab::class, 'user_lab');
    }

    public function commands(): HasMany
    {
        return $this->hasMany(Command::class, 'created_by');
    }

    public function auditLogs(): HasMany
    {
        return $this->hasMany(AuditLog::class, 'user_id');
    }

    public function isSuperAdmin(): bool
    {
        return $this->role === 'super_admin';
    }

    public function isSenior(): bool
    {
        return in_array($this->role, ['super_admin', 'aslab_senior', 'aslab']);
    }

    public function isJunior(): bool
    {
        return $this->role === 'aslab_junior';
    }

    public function isAslab(): bool
    {
        return in_array($this->role, ['super_admin', 'aslab_senior', 'aslab_junior', 'aslab']);
    }

    public function canManageUsers(): bool
    {
        return $this->isSuperAdmin();
    }

    public function canDeleteResources(): bool
    {
        return $this->isSenior();
    }

    public function canManageBlocklist(): bool
    {
        return $this->isSenior();
    }

    public function canManageKiosk(): bool
    {
        return $this->isSenior();
    }

    public function getRoleBadgeAttribute(): string
    {
        return match ($this->role) {
            'super_admin' => 'Super Admin (Kalab)',
            'aslab_senior' => 'ASLAB Senior',
            'aslab_junior' => 'ASLAB Junior',
            default => 'ASLAB',
        };
    }
}
