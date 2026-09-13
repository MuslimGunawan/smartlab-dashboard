<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HardwareSpec extends Model
{
    use HasFactory;

    protected $fillable = [
        'computer_id',
        'serial_number',
        'processor',
        'ram_gb',
        'os_version',
    ];

    protected function casts(): array
    {
        return [
            'ram_gb' => 'decimal:2',
        ];
    }

    public function computer(): BelongsTo
    {
        return $this->belongsTo(Computer::class);
    }
}
