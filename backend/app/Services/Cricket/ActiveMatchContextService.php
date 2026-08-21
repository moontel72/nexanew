<?php

namespace App\Services\Cricket;

use App\Events\Cricket\CricketMatchContextSelected;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

/**
 * ActiveMatchContextService — single source of truth for "which match is
 * this manager currently operating".
 *
 * Phase 1 of the unified realtime sync engine:
 *  - Stored in the shared cache (Redis in production; the default cache
 *    driver otherwise) so the context survives page reloads, app restarts
 *    and is readable from any panel of the ecosystem.
 *  - Selecting a match also fires `CricketMatchContextSelected` on the
 *    public match channel, which the Rust media engine subscribes to and
 *    uses to switch the Todd Studio scoreboard instantly (push, no poll).
 *
 * The Laravel cache is the contract — this service deliberately has no
 * knowledge of how consumers read it; they read the realtime channel or
 * call GET /api/v1/cricket/manager/active-match.
 */
class ActiveMatchContextService
{
    private const KEY_PREFIX = 'cricket.active_match.';
    /** 12h — aligned with the cricket manager token sliding window. */
    private const TTL_SECONDS = 43_200;

    public function get(string $managerId): ?string
    {
        $value = Cache::get(self::key($managerId));

        return is_string($value) && $value !== '' ? $value : null;
    }

    public function set(string $managerId, string $matchId): string
    {
        Cache::put(self::key($managerId), $matchId, self::TTL_SECONDS);

        try {
            CricketMatchContextSelected::dispatch($matchId, $managerId);
        } catch (\Throwable $e) {
            // A failed broadcast must never block the selection itself —
            // consumers fall back to the REST read of the same key.
            Log::warning('Cricket: active-match broadcast failed (non-critical)', [
                'match_id' => $matchId,
                'error' => $e->getMessage(),
            ]);
        }

        return $matchId;
    }

    public function clear(string $managerId): void
    {
        Cache::forget(self::key($managerId));
    }

    private static function key(string $managerId): string
    {
        return self::KEY_PREFIX . $managerId;
    }
}
