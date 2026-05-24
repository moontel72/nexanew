<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — AI CHAT LEAK FILTER (Module 12N)
 * =============================================
 *
 * Real-time regex scanner that intercepts B2B/B2C chat messages
 * and blocks phone numbers, email strings, and local mobile prefixes
 * to prevent off-platform contact sharing and commission circumvention.
 *
 * DETECTED PATTERNS:
 *   - Phone numbers (03xx-xxxxxxx, +92, 7-12 digits)
 *   - Email addresses (user@domain.com)
 *   - Social handles (@username)
 *
 * On detection: freezes stream, masks payload, logs policy infraction.
 *
 * SAFETY: Entirely NEW middleware. Registered via 'chat.filter' alias.
 */

class AIChatLeakFilter
{
    private const BLOCKED_PATTERNS = [
        '/0[3-9]\d{2}[-\s]?\d{7}/',       // Pakistan mobile: 03xx-xxxxxxx
        '/\+92[-\s]?\d{2}[-\s]?\d{7}/',    // +92 international
        '/\b\d{7,12}\b/',                   // Raw 7-12 digit numbers
        '/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/', // Email
        '/@[a-zA-Z0-9_]{3,}/',              // @username
    ];

    public function handle(Request $request, Closure $next): mixed
    {
        $messageBody = $request->input('message', '');

        if (empty($messageBody)) {
            return $next($request);
        }

        foreach (self::BLOCKED_PATTERNS as $pattern) {
            if (preg_match($pattern, $messageBody, $matches)) {
                $senderId = (string) ($request->user()->id ?? 'unknown');
                $receiverId = $request->input('receiver_id', 'unknown');

                // Log blocked message
                DB::table('secure_chat_logs')->insert([
                    'id' => (string) Str::uuid(),
                    'sender_id' => $senderId,
                    'receiver_id' => $receiverId,
                    'message_body' => $messageBody,
                    'is_blocked' => true,
                    'blocked_reason' => 'Contact info detected: ' . $matches[0],
                    'masked_payload' => preg_replace($pattern, '[REDACTED]', $messageBody),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                Log::warning('AIChatLeakFilter: contact leak blocked', [
                    'sender' => $senderId,
                    'detected' => $matches[0],
                    'pattern' => $pattern,
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Message blocked. Sharing contact information violates NexaTrace policy. Continued attempts may result in account suspension.',
                    'blocked_reason' => 'Contact info detected',
                ], 422);
            }
        }

        return $next($request);
    }
}
