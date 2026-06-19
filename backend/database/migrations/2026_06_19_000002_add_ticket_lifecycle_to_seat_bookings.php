<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ADD TICKET LIFECYCLE COLUMNS
 * ==========================================
 *
 * Extends transport_seat_bookings with ticket issuance,
 * QR verification, and boarding status fields.
 *
 * NEW COLUMNS:
 *   ticket_hash       — SHA-256(booking_id + APP_KEY) tamper-proof seal
 *   qr_payload        — JSON verification bundle for gate scanning
 *   ticket_status     — issued → boarded → completed | cancelled
 *   ticket_issued_at  — when the ticket PDF was generated
 *   ticket_boarded_at — when the conductor scanned at the gate
 *
 * NEW INDEXES:
 *   ticket_hash (unique) — fast verification lookup
 *   ticket_status        — dashboard filtering
 *
 * TARGET MODULES: 8V, 15C, 15E
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transport_seat_bookings', function (Blueprint $table) {
            if (! Schema::hasColumn('transport_seat_bookings', 'ticket_hash')) {
                $table->string('ticket_hash', 64)->nullable()->unique()->after('status');
            }
            if (! Schema::hasColumn('transport_seat_bookings', 'qr_payload')) {
                $table->json('qr_payload')->nullable()->after('ticket_hash');
            }
            if (! Schema::hasColumn('transport_seat_bookings', 'ticket_status')) {
                $table->string('ticket_status', 20)->default('issued')->after('qr_payload');
                // issued → boarded → completed | cancelled
            }
            if (! Schema::hasColumn('transport_seat_bookings', 'ticket_issued_at')) {
                $table->timestampTz('ticket_issued_at')->nullable()->after('ticket_status');
            }
            if (! Schema::hasColumn('transport_seat_bookings', 'ticket_boarded_at')) {
                $table->timestampTz('ticket_boarded_at')->nullable()->after('ticket_issued_at');
            }
        });

        // Add index for ticket status queries
        Schema::table('transport_seat_bookings', function (Blueprint $table) {
            $table->index('ticket_status');
        });
    }

    public function down(): void
    {
        Schema::table('transport_seat_bookings', function (Blueprint $table) {
            $table->dropIndex(['ticket_status']);
            $table->dropColumn([
                'ticket_hash',
                'qr_payload',
                'ticket_status',
                'ticket_issued_at',
                'ticket_boarded_at',
            ]);
        });
    }
};
