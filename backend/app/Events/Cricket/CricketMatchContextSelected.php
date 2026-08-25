<?php

namespace App\Events\Cricket;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * CricketMatchContextSelected — realtime broadcast when a manager picks
 * the "active match" in the Cricket Manager panel.
 *
 * Fired on TWO public channels:
 *   - `cricket.context`          — global discovery channel. The Rust
 *                                  media engine subscribes to it once at
 *                                  startup, so ANY manager's selection is
 *                                  auto-discovered with ZERO match ids
 *                                  configured (no daily env updates).
 *   - `cricket.match.{matchId}`  — per-match consumers (existing feeds).
 *
 * ShouldBroadcastNow = dispatched inline, no queue hop.
 */
class CricketMatchContextSelected implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public string $matchId,
        public string $managerId,
    ) {
    }

    public function broadcastOn(): array
    {
        return [
            // Global discovery channel — lets consumers (the media engine)
            // learn the active match without knowing any match id upfront.
            new Channel('cricket.context'),
            // Per-match channel — existing score/live consumers.
            new Channel('cricket.match.' . $this->matchId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'match.context.selected';
    }

    public function broadcastWith(): array
    {
        return [
            'match_id' => $this->matchId,
            'manager_id' => $this->managerId,
            'selected_at' => now()->toIso8601String(),
        ];
    }
}
