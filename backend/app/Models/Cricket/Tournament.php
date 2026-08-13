<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Tournament extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_tournaments';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name',
        'slug',
        'location',
        'start_date',
        'end_date',
        'description',
        'logo_url',
        'status',
        'is_active',
        'created_by_global_identity_id',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'is_active' => 'boolean',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Tournament $tournament): void {
            if (empty($tournament->id)) {
                $tournament->id = (string) Str::orderedUuid();
            }
            if (empty($tournament->slug)) {
                $tournament->slug = Str::slug($tournament->name . '-' . Str::random(6));
            }
        });
    }

    public function teams()
    {
        return $this->hasMany(Team::class);
    }

    public function matches()
    {
        return $this->hasMany(MatchModel::class);
    }

    public function sponsors()
    {
        return $this->hasMany(Sponsor::class);
    }
}
