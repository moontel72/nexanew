<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class MatchOfficial extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_match_officials';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'tournament_id',
        'name',
        'role',
        'photo_url',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (MatchOfficial $official): void {
            if (empty($official->id)) {
                $official->id = (string) Str::orderedUuid();
            }
        });
    }

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }
}
