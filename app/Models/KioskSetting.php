<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class KioskSetting extends Model
{
    use HasFactory;

    protected $fillable = [
        'lab_id',
        'computer_id',
        'disable_taskmgr',
        'disable_cmd',
        'disable_regedit',
        'disable_control_panel',
    ];

    protected function casts(): array
    {
        return [
            'disable_taskmgr' => 'boolean',
            'disable_cmd' => 'boolean',
            'disable_regedit' => 'boolean',
            'disable_control_panel' => 'boolean',
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
}
