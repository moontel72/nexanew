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

    /**
     * Index of manager ids that currently hold a context pointer.
     *
     * The per-manager keys have no discoverable naming scheme (the cache
     * store may be file/array/redis), so deletion cleanup needs a way to
     * find the pointers referencing a match without scanning the whole
     * keyspace. Bounded and self-healing: entries are added on set and
     * removed as soon as a pointer is found to be gone.
     */
    private const INDEX_KEY = 'cricket.active_match._index';

    public function get(string $managerId): ?string
    {
        $value = Cache::get(self::key($managerId));

        return is_string($value) && $value !== '' ? $value : null;
    }

    public function set(string $managerId, string $matchId): string
    {
        Cache::put(self::key($managerId), $matchId, self::TTL_SECONDS);
        $this->rememberInIndex($managerId);

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
        $this->forgetFromIndex($managerId);
    }

    /**
     * Clears every manager pointer that targets `$matchId`.
     *
     * Called when a match (or its tournament) is deleted. Without this the
     * pointer survives its own match for up to 12h and the media engine
     * keeps targeting a match that no longer exists.
     *
     * @return list<string> Manager ids whose pointer was cleared.
     */
    public function clearForMatch(string $matchId): array
    {
        $cleared = [];
        $stale = [];

        foreach ($this->indexedManagers() as $managerId) {
            if ($this->get($managerId) === $matchId) {
                $cleared[] = $managerId;
            }
            // Any pointer that vanished (expired TTL, manual clear) is
            // dropped from the index while we are iterating it anyway.
            if ($this->get($managerId) === null) {
                $stale[] = $managerId;
            }
        }

        foreach ($cleared as $managerId) {
            $this->clear($managerId);
            Log::info('Cricket: cleared active-match pointer for deleted match', [
                'match_id' => $matchId,
                'manager_id' => $managerId,
            ]);
        }

        foreach (array_diff($stale, $cleared) as $managerId) {
            $this->forgetFromIndex($managerId);
        }

        return $cleared;
    }

    /** @return list<string> */
    private function indexedManagers(): array
    {
        $index = Cache::get(self::INDEX_KEY, []);

        if (!is_array($index)) {
            return [];
        }

        return array_values(array_filter($index, 'is_string'));
    }

    private function rememberInIndex(string $managerId): void
    {
        $index = $this->indexedManagers();
        if (in_array($managerId, $index, true)) {
            return;
        }
        $index[] = $managerId;
        // No TTL: entries are pruned by clear()/clearForMatch().
        Cache::forever(self::INDEX_KEY, $index);
    }

    private function forgetFromIndex(string $managerId): void
    {
        $index = $this->indexedManagers();
        $filtered = array_values(array_filter(
            $index,
            fn (string $entry) => $entry !== $managerId
        ));

        if ($filtered === $index) {
            return;
        }

        if (empty($filtered)) {
            Cache::forget(self::INDEX_KEY);

            return;
        }

        Cache::forever(self::INDEX_KEY, $filtered);
    }

    private static function key(string $managerId): string
    {
        return self::KEY_PREFIX . $managerId;
    }
}
