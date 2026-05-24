<?php

namespace App\Models\Transport;

use Illuminate\Database\Eloquent\Model;

class BusLayout extends Model
{
    protected $table = 'transport_bus_layouts';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'bus_id', 'owner_id',
        'total_rows', 'left_columns', 'right_columns', 'driver_seats',
        'raw_grid_json', 'is_active',
    ];

    protected $casts = [
        'total_rows' => 'integer', 'left_columns' => 'integer',
        'right_columns' => 'integer', 'driver_seats' => 'integer',
        'raw_grid_json' => 'array', 'is_active' => 'boolean',
    ];

    public function totalSeats(): int
    {
        return ($this->total_rows * ($this->left_columns + $this->right_columns)) + $this->driver_seats;
    }
}
