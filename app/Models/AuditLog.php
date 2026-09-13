<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AuditLog extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'aksi',
        'target',
        'detail',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'detail' => 'array',
            'created_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public static function log(?int $userId, string $aksi, ?string $target = null, ?array $detail = null): self
    {
        return self::create([
            'user_id' => $userId,
            'aksi' => $aksi,
            'target' => $target,
            'detail' => $detail,
            'created_at' => now(),
        ]);
    }
}
