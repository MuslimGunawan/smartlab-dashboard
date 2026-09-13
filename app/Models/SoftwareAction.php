<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SoftwareAction extends Model
{
    use HasFactory;

    protected $fillable = [
        'computer_id',
        'software_name',
        'aksi',
        'status',
        'dikirim_oleh',
        'keterangan_gagal',
    ];

    public function computer(): BelongsTo
    {
        return $this->belongsTo(Computer::class);
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'dikirim_oleh');
    }
}
