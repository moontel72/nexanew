<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class District extends Model
{
    protected $table = 'districts';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ['id', 'name', 'prefix'];

    public function zones(): HasMany
    {
        return $this->hasMany(Zone::class);
    }
}
