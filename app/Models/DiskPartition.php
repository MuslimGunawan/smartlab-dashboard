<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DiskPartition extends Model
{
    use HasFactory;

    protected $fillable = [
        'computer_id',
        'drive_letter',
        'total_gb',
        'free_gb',
    ];

    protected function casts(): array
    {
        return [
            'total_gb' => 'decimal:2',
            'free_gb' => 'decimal:2',
        ];
    }

    public function computer(): BelongsTo
    {
        return $this->belongsTo(Computer::class);
    }
}
