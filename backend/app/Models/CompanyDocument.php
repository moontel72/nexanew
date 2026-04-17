<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CompanyDocument extends Model
{
    use HasFactory;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'document_type',
        'document_name',
        'document_url',
        'file_size',
        'mime_type',
        'verification_status',
        'verification_notes',
        'verified_at',
        'verified_by',
        'is_deleted',
    ];

    protected $casts = [
        'verified_at' => 'datetime',
        'is_deleted' => 'boolean',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }
}

