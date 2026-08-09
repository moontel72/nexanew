<?php

namespace App\Events\Cricket;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * CricketScoreUpdated — Realtime WebSocket event.
 *
 * Fired after every score update. Broadcasts on cricket.match.{id}
 * channel so all connected Flutter clients receive the update instantly.
 *
 * Uses ShouldBroadcastNow for immediate dispatch (no queue delay).
 */
class CricketScoreUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $matchId;
    public array $scoreData;

    public function __construct(string $matchId, array $scoreData)
    {
        $this->matchId = $matchId;
        $this->scoreData = $scoreData;
    }

    public function broadcastOn(): array
    {
        return [
            new Channel('cricket.match.' . $this->matchId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'score.updated';
    }

    public function broadcastWith(): array
    {
        return [
            'match_id' => $this->matchId,
            'score' => $this->scoreData,
            'timestamp' => now()->toIso8601String(),
        ];
    }
}
