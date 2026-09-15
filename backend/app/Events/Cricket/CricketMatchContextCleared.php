<?php

namespace App\Events\Cricket;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * CricketMatchContextCleared — realtime broadcast when the active match
 * stops being valid: the manager cleared the selection, or the match /
 * its tournament was deleted.
 *
 * Counterpart to CricketMatchContextSelected. Without it the Rust media
 * engine keeps pointing at a match that no longer exists and would keep
 * burning the deleted match's score on the Studio lower-third, because
 * `match.context.selected` was the only event that ever moved the
 * active-match pointer.
 *
 * Fired on the same two channels as the selection event:
 *   - `cricket.context`          — global discovery channel (engine).
 *   - `cricket.match.{matchId}`  — per-match consumers.
 *
 * ShouldBroadcastNow = dispatched inline, no queue hop.
 */
class CricketMatchContextCleared implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public string $matchId,
        /** Null when the clear was caused by a deletion, not a manager. */
        public ?string $managerId = null,
    ) {
    }

    public function broadcastOn(): array
    {
        return [
            new Channel('cricket.context'),
            new Channel('cricket.match.' . $this->matchId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'match.context.cleared';
    }

    public function broadcastWith(): array
    {
        return [
            'match_id' => $this->matchId,
            'manager_id' => $this->managerId,
            'cleared_at' => now()->toIso8601String(),
        ];
    }
}
