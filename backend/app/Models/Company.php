<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    use HasFactory;

    public $incrementing = false;
    protected $keyType = "string";

    protected $fillable = [
        "id",
        "name",
        "business_registration_number",
        "tax_id",
        "company_type",
        "industry_type",
        "email",
        "phone",
        "website",
        "country",
        "city",
        "address",
        "postal_code",
        "contact_person_name",
        "contact_person_email",
        "contact_person_phone",
        "contact_person_position",
        "status",
        "verification_status",
        "verification_notes",
        "verified_at",
        "verified_by",
        "timezone",
        "language",
        "currency",
        "logo_url",
        "metadata",
        "is_deleted",
        "deleted_at",
        "last_activity_at",
        "total_codes_generated",
        "active_users_count",
        "credit_limit",
        "credit_used",
        "credit_status",
        "credit_limit_set_at",
        "credit_limit_set_by",
        "credit_review_date",
        "credit_limit_notes",
        "credit_metadata",
    ];

    protected $casts = [
        "verified_at" => "datetime",
        "deleted_at" => "datetime",
        "last_activity_at" => "datetime",
        "credit_limit_set_at" => "datetime",
        "credit_review_date" => "date",
        "metadata" => "array",
        "credit_metadata" => "array",
    ];

    public function documents()
    {
        return $this->hasMany(CompanyDocument::class);
    }

    public function subscriptions()
    {
        return $this->hasMany(CompanySubscription::class);
    }

    public function activeSubscription()
    {
        return $this->hasOne(CompanySubscription::class)->where(
            "status",
            "active",
        );
    }
}
