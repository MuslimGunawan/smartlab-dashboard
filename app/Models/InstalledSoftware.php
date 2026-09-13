<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InstalledSoftware extends Model
{
    use HasFactory;

    protected $table = 'installed_software';

    protected $fillable = [
        'computer_id',
        'nama',
        'versi',
        'tanggal_install',
        'ukuran_kb',
        'uninstall_string',
        'terdeteksi_pertama_at',
        'terakhir_dicek_at',
    ];

    protected function casts(): array
    {
        return [
            'terdeteksi_pertama_at' => 'datetime',
            'terakhir_dicek_at' => 'datetime',
            'ukuran_kb' => 'integer',
        ];
    }

    public function computer(): BelongsTo
    {
        return $this->belongsTo(Computer::class);
    }
}
