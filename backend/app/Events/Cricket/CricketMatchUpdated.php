<?php

namespace App\Events\Cricket;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * CricketMatchUpdated — Match lifecycle change (GO LIVE, completed, breaks).
 *
 * Fired whenever the Cricket Manager changes a match status via the
 * status endpoint. Broadcast on both the match channel (public live
 * match page) and the tournament channel (public tournament home),
 * so viewers on cricket.traceodd.com see the change instantly.
 *
 * Uses ShouldBroadcastNow for immediate dispatch (no queue delay).
 */
class CricketMatchUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $matchId;

    public string $tournamentId;

    /** Minimal match payload for client-side refresh decisions. */
    public array $matchData;

    public function __construct(string $matchId, string $tournamentId, array $matchData)
    {
        $this->matchId = $matchId;
        $this->tournamentId = $tournamentId;
        $this->matchData = $matchData;
    }

    public function broadcastOn(): array
    {
        return [
            new Channel('cricket.match.' . $this->matchId),
            new Channel('cricket.tournament.' . $this->tournamentId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'match.updated';
    }

    public function broadcastWith(): array
    {
        return [
            'match_id' => $this->matchId,
            'tournament_id' => $this->tournamentId,
            'status' => $this->matchData['status'] ?? null,
            'match' => $this->matchData,
            'timestamp' => now()->toIso8601String(),
        ];
    }
}
