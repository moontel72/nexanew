<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Club extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_clubs';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'name', 'slug', 'logo_url', 'banner_url',
        'location', 'established_year', 'description',
        'contact_email', 'website_url',
        'follower_count', 'club_views',
        'total_matches_hosted', 'total_tournaments_hosted',
        'created_by_manager_id',
    ];

    protected $casts = [
        'established_year' => 'integer',
        'follower_count' => 'integer',
        'club_views' => 'integer',
        'total_matches_hosted' => 'integer',
        'total_tournaments_hosted' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Club $club): void {
            if (empty($club->id)) {
                $club->id = (string) Str::orderedUuid();
            }
        });
    }

    public function creator()
    {
        return $this->belongsTo(CricketManager::class, 'created_by_manager_id');
    }

    public function players()
    {
        return $this->hasMany(PlayerCareerStats::class, 'club_id');
    }
}
