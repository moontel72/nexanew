<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Dynamic site content block (CMS-lite) — see SiteContentController.
 *
 * `payload` is an open JSON document whose shape depends on the slug:
 *   - "landing"      → the full landing_content.json document (traceodd.com)
 *   - "book2-*", …   → {title, image, text_en, text_ur} docs blocks
 */
class SiteContentBlock extends Model
{
    protected $table = 'site_content_blocks';

    protected $fillable = [
        'slug',
        'title',
        'payload',
        'updated_by',
    ];

    protected $casts = [
        'payload' => 'array',
    ];
}
