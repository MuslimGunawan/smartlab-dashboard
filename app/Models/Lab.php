<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Lab extends Model
{
    use HasFactory;

    protected $fillable = [
        'nama_lab',
        'lokasi',
        'deskripsi',
    ];

    public function computers(): HasMany
    {
        return $this->hasMany(Computer::class);
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_lab');
    }

    public function pairingCodes(): HasMany
    {
        return $this->hasMany(PairingCode::class);
    }

    public function schedules(): HasMany
    {
        return $this->hasMany(Schedule::class);
    }

    public function commands(): HasMany
    {
        return $this->hasMany(Command::class);
    }

    public function issueReports(): HasMany
    {
        return $this->hasMany(IssueReport::class);
    }
}
