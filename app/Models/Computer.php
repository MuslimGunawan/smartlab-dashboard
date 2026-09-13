<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Computer extends Model
{
    use HasFactory;

    protected $fillable = [
        'lab_id',
        'nama_pc',
        'hostname',
        'device_token',
        'mac_address',
        'ip_terakhir',
        'status',
        'versi_agent',
        'active_user',
        'uptime_seconds',
        'last_seen_at',
    ];

    protected function casts(): array
    {
        return [
            'last_seen_at' => 'datetime',
            'uptime_seconds' => 'integer',
        ];
    }

    public function lab(): BelongsTo
    {
        return $this->belongsTo(Lab::class);
    }

    public function commands(): HasMany
    {
        return $this->hasMany(Command::class);
    }

    public function pendingCommands(): HasMany
    {
        return $this->hasMany(Command::class)->where('status', 'pending');
    }

    public function hardwareSpec(): HasOne
    {
        return $this->hasOne(HardwareSpec::class);
    }

    public function diskPartitions(): HasMany
    {
        return $this->hasMany(DiskPartition::class);
    }

    public function installedSoftware(): HasMany
    {
        return $this->hasMany(InstalledSoftware::class);
    }

    public function violations(): HasMany
    {
        return $this->hasMany(Violation::class);
    }

    public function softwareEvents(): HasMany
    {
        return $this->hasMany(SoftwareEvent::class);
    }

    public function issueReports(): HasMany
    {
        return $this->hasMany(IssueReport::class);
    }

    public function isOnline(): bool
    {
        if ($this->status !== 'online' || !$this->last_seen_at) {
            return false;
        }

        // Heartbeat expected every 15-30s. If last_seen is within 45 seconds, it is online.
        return $this->last_seen_at->diffInSeconds(now()) <= 45;
    }
}
