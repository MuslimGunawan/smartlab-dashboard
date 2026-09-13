<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PairingCode extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'lab_id',
        'computer_id',
        'is_used',
        'expired_at',
    ];

    protected function casts(): array
    {
        return [
            'is_used' => 'boolean',
            'expired_at' => 'datetime',
        ];
    }

    public function lab(): BelongsTo
    {
        return $this->belongsTo(Lab::class);
    }

    public function computer(): BelongsTo
    {
        return $this->belongsTo(Computer::class);
    }

    public function isValid(): bool
    {
        return !$this->is_used && $this->expired_at && $this->expired_at->isFuture();
    }
}
