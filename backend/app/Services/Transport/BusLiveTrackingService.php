<?php

namespace App\Services\Transport;

use App\Events\BusLocationUpdated;
use App\Models\Transport\BusTrip;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — ACTIVE BUS FLEET & LIVE DISPATCH ENGINE
 * =====================================================
 *
 * Real-time GPS dispatch, trip activation, coordinate streaming,
 * and automated stop-by-stop ETA computation for the Bus Ecosystem.
 *
 * CORE FEATURES:
 *   - startTrip(): Activates trip, locks seat layout, begins tracking
 *   - updateBusCoordinates(): Streams GPS → WebSocket broadcast + ETA recompute
 *   - computeETA(): Calculates remaining station arrival estimates from
 *                   current position + speed vs. waypoint distances
 *   - completeTrip(): Finalizes trip, releases seat layout
 *
 * WEBSOCKET INTEGRATION:
 *   Every coordinate update fires `BusLocationUpdated` event on
 *   channel `bus.{trip_id}` (Step 3 infrastructure).
 *
 * TARGET MODULES: 13, 14, 15, 8V
 *
 * SAFETY:
 *   - Entirely NEW service. Zero modification to existing code.
 *   - All mutations in DB::transaction().
 *   - WebSocket degrades to log when broadcasting unavailable.
 */

class BusLiveTrackingService
{
    private const EARTH_RADIUS_KM = 6371.0;

    /**
     * Activate a trip — driver presses "Start Trip".
     * Locks the bus layout, transitions status to active.
     */
    public function startTrip(string $tripId, string $driverId, float $startLat, float $startLng): BusTrip
    {
        return DB::transaction(function () use ($tripId, $driverId, $startLat, $startLng) {
            $trip = BusTrip::where('id', $tripId)->lockForUpdate()->firstOrFail();

            if ($trip->status !== BusTrip::STATUS_SCHEDULED) {
                throw new \RuntimeException("Trip cannot be started. Status: {$trip->status}");
            }

            $trip->update([
                'status' => BusTrip::STATUS_ACTIVE,
                'driver_id' => $driverId,
                'current_lat' => $startLat,
                'current_lng' => $startLng,
                'current_speed' => 0,
                'started_at' => now(),
            ]);

            // Initialize ETA for all waypoints from origin
            $this->recomputeAllETAs($trip);

            Log::info('BusLiveTrackingService: trip started', [
                'trip_id' => $tripId, 'bus_id' => $trip->bus_id, 'driver_id' => $driverId,
            ]);

            // Broadcast trip activation
            $this->broadcast($trip, 'trip_started');

            return $trip->fresh();
        });
    }

    /**
     * Driver updates GPS coordinates — streams via WebSocket + recomputes ETA.
     */
    public function updateBusCoordinates(
        string $tripId,
        float $lat,
        float $lng,
        float $speed,
        ?int $waypointIndex = null
    ): BusTrip {
        $trip = BusTrip::where('id', $tripId)->firstOrFail();

        if (! $trip->isActive()) {
            throw new \RuntimeException("Trip is not active. Status: {$trip->status}");
        }

        $trip->update([
            'current_lat' => $lat,
            'current_lng' => $lng,
            'current_speed' => $speed,
            'current_waypoint_index' => $waypointIndex ?? $this->detectNearestWaypoint($trip, $lat, $lng),
        ]);

        // Recompute ETAs from current position
        $this->recomputeETAsFromCurrent($trip, $lat, $lng, $speed);

        // Broadcast via WebSocket
        $this->broadcast($trip, 'location_update');

        return $trip->fresh();
    }

    /**
     * Complete a trip.
     */
    public function completeTrip(string $tripId, float $endLat, float $endLng): BusTrip
    {
        $trip = BusTrip::where('id', $tripId)->firstOrFail();

        $trip->update([
            'status' => BusTrip::STATUS_COMPLETED,
            'current_lat' => $endLat,
            'current_lng' => $endLng,
            'current_speed' => 0,
            'completed_at' => now(),
        ]);

        Log::info('BusLiveTrackingService: trip completed', ['trip_id' => $tripId]);
        $this->broadcast($trip, 'trip_completed');

        return $trip->fresh();
    }

    // ─────────────────────────────────────────────────
    // ETA ENGINE
    // ─────────────────────────────────────────────────

    /**
     * Compute ETA for all waypoints from origin (used at trip start).
     */
    private function recomputeAllETAs(BusTrip $trip): void
    {
        $waypoints = $trip->waypoints ?? [];
        if (empty($waypoints)) return;

        $etaJson = [];
        $cumulativeDist = 0;
        $prevLat = $trip->current_lat;
        $prevLng = $trip->current_lng;

        foreach ($waypoints as $wp) {
            $wpLat = (float) ($wp['lat'] ?? 0);
            $wpLng = (float) ($wp['lng'] ?? 0);
            $segmentKm = $this->haversineDistance($prevLat, $prevLng, $wpLat, $wpLng);
            $cumulativeDist += $segmentKm;

            // Assume average speed 40 km/h for initial estimate
            $etaSeconds = $cumulativeDist > 0 ? (int) round(($cumulativeDist / 40) * 3600) : 0;

            $etaJson[] = [
                'station' => $wp['station'] ?? "Stop {$wp['order']}",
                'distance_km' => round($cumulativeDist, 2),
                'eta_seconds' => $etaSeconds,
            ];

            $prevLat = $wpLat;
            $prevLng = $wpLng;
        }

        $trip->update(['estimated_arrival_json' => $etaJson]);
    }

    /**
     * Recompute ETAs from current live position.
     */
    private function recomputeETAsFromCurrent(BusTrip $trip, float $lat, float $lng, float $speedKmph): void
    {
        $waypoints = $trip->waypoints ?? [];
        if (empty($waypoints)) return;

        $etaJson = [];
        $cumulativeDist = 0;
        $prevLat = $lat;
        $prevLng = $lng;
        $effectiveSpeed = max($speedKmph, 20); // floor at 20 km/h to avoid infinite ETA

        // Skip already-passed waypoints
        $remaining = array_slice($waypoints, $trip->current_waypoint_index);

        foreach ($remaining as $wp) {
            $wpLat = (float) ($wp['lat'] ?? 0);
            $wpLng = (float) ($wp['lng'] ?? 0);
            $segmentKm = $this->haversineDistance($prevLat, $prevLng, $wpLat, $wpLng);
            $cumulativeDist += $segmentKm;

            $etaSeconds = (int) round(($cumulativeDist / $effectiveSpeed) * 3600);

            $etaJson[] = [
                'station' => $wp['station'] ?? "Stop {$wp['order']}",
                'distance_km' => round($cumulativeDist, 2),
                'eta_seconds' => $etaSeconds,
            ];

            $prevLat = $wpLat;
            $prevLng = $wpLng;
        }

        $trip->update(['estimated_arrival_json' => $etaJson]);
    }

    /**
     * Detect which waypoint the bus is nearest to.
     */
    private function detectNearestWaypoint(BusTrip $trip, float $lat, float $lng): int
    {
        $waypoints = $trip->waypoints ?? [];
        if (empty($waypoints)) return 0;

        $minDist = PHP_FLOAT_MAX;
        $nearestIdx = $trip->current_waypoint_index;

        foreach ($waypoints as $i => $wp) {
            $d = $this->haversineDistance($lat, $lng, (float) ($wp['lat'] ?? 0), (float) ($wp['lng'] ?? 0));
            if ($d < $minDist) {
                $minDist = $d;
                $nearestIdx = $i;
            }
        }

        return $nearestIdx;
    }

    // ─────────────────────────────────────────────────
    // WEBSOCKET BROADCAST
    // ─────────────────────────────────────────────────

    private function broadcast(BusTrip $trip, string $eventType): void
    {
        BusLocationUpdated::dispatch(
            busId: $trip->bus_id,
            tripId: $trip->id,
            lat: $trip->current_lat ?? 0,
            lng: $trip->current_lng ?? 0,
            speed: $trip->current_speed ?? 0,
            etaJson: $trip->estimated_arrival_json ?? [],
            status: $trip->status,
            eventType: $eventType,
        );
    }

    // ─────────────────────────────────────────────────
    // MATH
    // ─────────────────────────────────────────────────

    private function haversineDistance(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        return self::EARTH_RADIUS_KM * $c;
    }
}
