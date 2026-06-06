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
        // Wave 4 columns
        'owner_identity_id', 'carrier_company_id',
        'vehicle_class', 'display_name',
        'is_locked_sovereign', 'version_number', 'layout_status',
        'current_snapshot',
        'edit_lock_held_by', 'edit_lock_expires_at',
        'deck_level', 'parent_layout_id',
    ];

    protected $casts = [
        'total_rows' => 'integer', 'left_columns' => 'integer',
        'right_columns' => 'integer', 'driver_seats' => 'integer',
        'raw_grid_json' => 'array', 'is_active' => 'boolean',
        // Wave 4
        'is_locked_sovereign' => 'boolean',
        'version_number' => 'integer',
        'current_snapshot' => 'array',
        'deck_level' => 'integer',
        'edit_lock_expires_at' => 'datetime',
    ];

    public function totalSeats(): int
    {
        return ($this->total_rows * ($this->left_columns + $this->right_columns)) + $this->driver_seats;
    }
}
