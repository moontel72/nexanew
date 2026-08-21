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
 * Fired on the PUBLIC `cricket.match.{matchId}` channel so the Rust media
 * engine (Todd Studio scoreboard sync) and any other consumer can switch
 * their match context in sub-100ms without REST polling.
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
