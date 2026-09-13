<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AgentVersion extends Model
{
    use HasFactory;

    protected $fillable = [
        'versi',
        'changelog',
        'github_release_url',
        'mandatory',
        'released_at',
    ];

    protected function casts(): array
    {
        return [
            'mandatory' => 'boolean',
            'released_at' => 'datetime',
        ];
    }
}
