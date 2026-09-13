<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class IssueReport extends Model
{
    use HasFactory;

    protected $fillable = [
        'computer_id',
        'lab_id',
        'reporter_name',
        'reporter_nim',
        'reporter_contact',
        'category',
        'description',
        'status',
        'resolved_by',
        'resolution_notes',
        'resolved_at',
    ];

    protected function casts(): array
    {
        return [
            'resolved_at' => 'datetime',
        ];
    }

    public function computer(): BelongsTo
    {
        return $this->belongsTo(Computer::class);
    }

    public function lab(): BelongsTo
    {
        return $this->belongsTo(Lab::class);
    }

    public function resolver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'resolved_by');
    }

    public function getCategoryLabelAttribute(): string
    {
        return match ($this->category) {
            'mouse' => 'Mouse / Pointer',
            'keyboard' => 'Keyboard',
            'monitor' => 'Monitor / Layar',
            'pc_hang' => 'PC Hang / Lambat / BSOD',
            'network' => 'Koneksi Internet / LAN',
            'software' => 'Aplikasi / Software Eror',
            default => 'Lainnya / Fisik Meja',
        };
    }
}
