<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Dynamic site content blocks (CMS-lite).
 *
 * Super Admins edit text and screenshots for the landing site
 * (traceodd.com) and the documentation site (docs.traceodd.com) here.
 * Both public sites read these blocks at runtime, so content changes
 * require no rebuild and no code push.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('site_content_blocks', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 191)->unique();
            $table->string('title')->nullable();
            $table->json('payload')->nullable();
            $table->unsignedBigInteger('updated_by')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('site_content_blocks');
    }
};
