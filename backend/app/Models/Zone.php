<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Zone extends Model
{
    protected $table = 'zones';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ['id', 'district_id', 'name', 'zone_code'];

    public function district(): BelongsTo
    {
        return $this->belongsTo(District::class);
    }

    public function smartCodes(): HasMany
    {
        return $this->hasMany(SmartCode::class);
    }
}
