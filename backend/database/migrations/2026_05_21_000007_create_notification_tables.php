<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notification_templates', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('template_key', 100)->unique();
            $table->string('name', 200);
            $table->string('channel', 30); // email, push, sms, websocket
            $table->string('subject', 300)->nullable();
            $table->text('body_template');
            $table->json('placeholders')->nullable(); // ['user_name', 'invoice_amount', ...]
            $table->json('metadata')->nullable();
            $table->timestamps();
        });

        Schema::create('notification_logs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('company_id')->nullable();
            $table->uuid('user_id')->nullable();
            $table->string('channel', 30); // email, push, sms, websocket
            $table->string('type', 100); // invoice_ready, delivery_confirmed, bid_won, etc.
            $table->string('status', 20)->default('queued');
            // queued → sending → delivered | failed | bounced | opted_out
            $table->text('content')->nullable();
            $table->json('metadata')->nullable();
            $table->unsignedTinyInteger('attempts')->default(0);
            $table->timestamp('delivered_at')->nullable();
            $table->timestamp('failed_at')->nullable();
            $table->text('failure_reason')->nullable();
            $table->timestamps();

            $table->index(['company_id', 'type']);
            $table->index(['status', 'created_at']);
        });

        Schema::create('user_notification_preferences', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->string('notification_type', 100); // invoice_ready, delivery_update, auction_alert, marketing, system
            $table->json('channel_preferences'); // {"email": true, "push": true, "sms": false, "websocket": true}
            $table->boolean('is_enabled')->default(true);
            $table->timestamps();

            $table->unique(['user_id', 'notification_type']);
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_notification_preferences');
        Schema::dropIfExists('notification_logs');
        Schema::dropIfExists('notification_templates');
    }
};
