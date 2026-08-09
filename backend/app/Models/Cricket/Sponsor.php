<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Sponsor extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_sponsors';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'tournament_id',
        'name',
        'logo_url',
        'banner_image_url',
        'website_url',
        'tier',
        'is_active',
        'display_order',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'display_order' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Sponsor $sponsor): void {
            if (empty($sponsor->id)) {
                $sponsor->id = (string) Str::orderedUuid();
            }
        });
    }

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }

    public function matchSponsors()
    {
        return $this->hasMany(MatchSponsor::class, 'sponsor_id');
    }
}
