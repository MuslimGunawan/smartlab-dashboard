<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Violation extends Model
{
    use HasFactory;

    protected $fillable = [
        'computer_id',
        'process_name',
        'screenshot_path',
        'webcam_path',
        'detected_at',
        'resolved',
    ];

    protected function casts(): array
    {
        return [
            'detected_at' => 'datetime',
            'resolved' => 'boolean',
        ];
    }

    public function computer(): BelongsTo
    {
        return $this->belongsTo(Computer::class);
    }
}
