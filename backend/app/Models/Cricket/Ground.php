<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Ground extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_grounds';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name',
        'location',
        'capacity',
    ];

    protected $casts = [
        'capacity' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Ground $ground): void {
            if (empty($ground->id)) {
                $ground->id = (string) Str::orderedUuid();
            }
        });
    }

    public function matches()
    {
        return $this->hasMany(MatchModel::class, 'ground_id');
    }
}
