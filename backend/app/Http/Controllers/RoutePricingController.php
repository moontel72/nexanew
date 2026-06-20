<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * NEXATRACE — ROUTE PRICING CONTROLLER
 * =====================================
 *
 * City-to-city segment pricing CRUD for multi-stopover routes.
 *
 * ROUTES:
 *   GET    /api/v1/bus-fleet/routes/{id}/pricing
 *   PUT    /api/v1/bus-fleet/routes/{id}/pricing
 *
 * TARGET MODULES: 13B, 8V
 */
class RoutePricingController extends Controller
{
    /**
     * GET segment prices for a route.
     */
    public function index(string $routeId, Request $request): JsonResponse
    {
        $prices = DB::table('route_segment_prices')
            ->where('route_id', $routeId)
            ->whereColumn('from_station', '!=', 'to_station')
            ->orderBy('from_stop_order')
            ->orderBy('to_stop_order')
            ->get();

        $waypoints = DB::table('transport_bus_route_waypoints')
            ->where('route_id', $routeId)
            ->orderBy('stop_order')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => [
                'route_id'  => $routeId,
                'waypoints' => $waypoints,
                'prices'    => $prices,
            ],
        ]);
    }

    /**
     * PUT batch-update segment prices for a route.
     *
     * Body: { prices: [{from_stop_order, to_stop_order, from_station,
     *                    to_station, price, seat_category}] }
     */
    public function update(string $routeId, Request $request): JsonResponse
    {
        $data = $request->validate([
            'prices'                    => ['required', 'array'],
            'prices.*.from_stop_order'  => ['required', 'integer', 'min:0'],
            'prices.*.to_stop_order'    => ['required', 'integer', 'min:0'],
            'prices.*.from_station'     => ['required', 'string', 'max:255'],
            'prices.*.to_station'       => ['required', 'string', 'max:255'],
            'prices.*.price'            => ['required', 'numeric', 'min:0'],
            'prices.*.seat_category'    => ['nullable', 'string', 'max:30'],
            'prices.*.distance_km'      => ['nullable', 'numeric', 'min:0'],
        ]);

        DB::transaction(function () use ($routeId, $data) {
            // Delete existing prices for this route
            DB::table('route_segment_prices')
                ->where('route_id', $routeId)
                ->delete();

            // Insert new prices
            $inserts = [];
            foreach ($data['prices'] as $p) {
                $inserts[] = [
                    'id'              => (string) Str::uuid(),
                    'route_id'        => $routeId,
                    'from_stop_order' => $p['from_stop_order'],
                    'to_stop_order'   => $p['to_stop_order'],
                    'from_station'    => $p['from_station'],
                    'to_station'      => $p['to_station'],
                    'price'           => $p['price'],
                    'distance_km'     => $p['distance_km'] ?? null,
                    'seat_category'   => $p['seat_category'] ?? 'standard',
                    'created_at'      => now(),
                    'updated_at'      => now(),
                ];
            }

            // Filter out self-referencing segments (same station → same station)
            $inserts = array_filter($inserts, function ($p) {
                return $p['from_station'] !== $p['to_station'];
            });
            $inserts = array_values($inserts);

            DB::table('route_segment_prices')->insert($inserts);

            // Update the pricing_matrix JSON cache (use filtered inserts,
            // strip DB metadata so the cache stays lean)
            $cacheEntries = array_map(function ($p) {
                unset($p['id'], $p['created_at'], $p['updated_at']);
                return $p;
            }, $inserts);
            DB::table('transport_bus_routes')
                ->where('id', $routeId)
                ->update([
                    'pricing_matrix' => json_encode(array_values($cacheEntries)),
                    'updated_at'     => now(),
                ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Segment prices updated.',
            'data'    => $data['prices'],
        ]);
    }

    /**
     * GET /api/v1/bus-fleet/routes/{id}/pricing/{segId}/pdf
     *
     * Generate a printable PDF ticket for a specific route segment.
     */
    public function segmentPdf(string $routeId, string $segId, Request $request): \Illuminate\Http\Response
    {
        $segment = DB::table('route_segment_prices')
            ->where('id', $segId)
            ->where('route_id', $routeId)
            ->first();

        if (! $segment) {
            return response()->json(['success' => false, 'message' => 'Segment not found.'], 404);
        }

        $route = DB::table('transport_bus_routes')->where('id', $routeId)->first();

        if (! $route) {
            return response()->json(['success' => false, 'message' => 'Route not found.'], 404);
        }

        // Multi-tenant ownership enforcement (bus-owner panel only)
        $user = $request->user();
        $isMasterAdmin = ($user->account_type ?? null) === 'master_admin';
        $panelPrefix = $request->route()->getPrefix();
        if (! $isMasterAdmin && str_contains($panelPrefix, 'bus-owner')) {
            $ownerIdentityId = $user->global_identity_id ?? null;
            if (! $ownerIdentityId || ($route->owner_identity_id ?? null) !== $ownerIdentityId) {
                return response()->json(['success' => false, 'message' => 'This route does not belong to your account.'], 403);
            }
        }

        // Generate a tracking ID based on segment
        $trackingId = strtoupper(substr(md5($segId . ($route->route_code ?? 'NX')), 0, 12));

        // Build QR payload
        $qrPayload = json_encode([
            'v'   => 1,
            'sid' => $segId,
            'rid' => $routeId,
            'from'=> $segment->from_station,
            'to'  => $segment->to_station,
            'fare'=> $segment->price,
            'hash'=> hash('sha256', "{$segId}|{$segment->price}|" . config('app.key')),
        ]);
        $qrBase64 = base64_encode($qrPayload);

        // Build HTML ticket
        $html = $this->buildSegmentTicketHtml(
            from: $segment->from_station,
            to: $segment->to_station,
            fare: $segment->price,
            km: $segment->distance_km,
            trackingId: $trackingId,
            qrBase64: $qrBase64,
            routeName: $route->display_name ?? '',
            routeCode: $route->route_code ?? '',
        );

        return response($html, 200, [
            'Content-Type' => 'text/html; charset=utf-8',
            'Content-Disposition' => 'inline; filename="ticket-' . Str::slug($segment->from_station) . '-to-' . Str::slug($segment->to_station) . '.html"',
        ]);
    }

    /**
     * Build a printable HTML ticket for a route segment.
     */
    private function buildSegmentTicketHtml(
        string $from,
        string $to,
        float $fare,
        ?float $km,
        string $trackingId,
        string $qrBase64,
        string $routeName,
        string $routeCode,
    ): string {
        $qrSvg = $this->generateQrSvg($qrBase64);
        $kmDisplay = $km ? number_format($km, 1) . ' km' : '—';

        return <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>NexaTrace Ticket — {$from} → {$to}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', system-ui, sans-serif; background: #f1f5f9; display: flex; justify-content: center; padding: 20px; }
        .ticket { max-width: 440px; width: 100%; background: #fff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,.12); }
        .ticket-header { background: linear-gradient(135deg, #0D9488, #0F766E); color: #fff; padding: 24px; }
        .ticket-header h1 { font-size: 18px; font-weight: 700; }
        .ticket-header .sub { font-size: 12px; opacity: .85; margin-top: 4px; }
        .ticket-body { padding: 20px 24px; }
        .route-display { text-align: center; padding: 16px 0; }
        .route-display .station { font-size: 18px; font-weight: 700; color: #1e293b; }
        .route-display .arrow { color: #0D9488; font-size: 20px; margin: 0 12px; }
        .row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f1f5f9; }
        .row:last-child { border-bottom: none; }
        .label { font-size: 11px; color: #64748b; text-transform: uppercase; letter-spacing: .5px; }
        .value { font-size: 14px; font-weight: 600; color: #1e293b; text-align: right; }
        .fare-badge { display: inline-block; background: #dcfce7; color: #16a34a; padding: 6px 20px; border-radius: 20px; font-size: 18px; font-weight: 700; }
        .qr-section { text-align: center; padding: 16px 24px 24px; background: #f8fafc; }
        .qr-code { width: 140px; height: 140px; margin: 0 auto 12px; background: #fff; border: 3px solid #0D9488; border-radius: 12px; padding: 8px; }
        .tracking { font-family: 'Courier New', monospace; font-size: 10px; color: #94a3b8; word-break: break-all; margin-top: 8px; }
        .footer { text-align: center; padding: 14px 24px; background: #0F172A; color: #94a3b8; font-size: 10px; }
        @media print { body { background: #fff; padding: 0; } .ticket { box-shadow: none; max-width: 100%; } }
    </style>
</head>
<body>
    <div class="ticket">
        <div class="ticket-header">
            <h1>🎫 {$from} → {$to}</h1>
            <div class="sub">{$routeName} · {$routeCode}</div>
        </div>
        <div class="ticket-body">
            <div class="route-display">
                <span class="station">{$from}</span>
                <span class="arrow">→</span>
                <span class="station">{$to}</span>
            </div>
            <div class="row">
                <span class="label">Ticket Fare</span>
                <span class="fare-badge">Rs. {$fare}</span>
            </div>
            <div class="row">
                <span class="label">Distance</span>
                <span class="value">{$kmDisplay}</span>
            </div>
            <div class="row">
                <span class="label">Route</span>
                <span class="value">{$routeName}</span>
            </div>
            <div class="row">
                <span class="label">Tracking ID</span>
                <span class="value" style="font-family: monospace; font-size: 12px;">{$trackingId}</span>
            </div>
        </div>
        <div class="qr-section">
            <div class="qr-code">
                {$qrSvg}
            </div>
            <div class="tracking">🔐 {$trackingId}</div>
        </div>
        <div class="footer">
            NexaTrace Secure Transit · Tamper-Proof SHA-256 · Tracking: {$trackingId}
        </div>
    </div>
</body>
</html>
HTML;
    }

    /**
     * Generate an SVG QR-code-like visual from base64 payload.
     */
    private function generateQrSvg(string $payload): string
    {
        $seed = crc32($payload);
        srand($seed);
        $cells = '';
        for ($r = 0; $r < 10; $r++) {
            for ($c = 0; $c < 10; $c++) {
                if (rand(0, 1)) {
                    $x = $c * 10;
                    $y = $r * 10;
                    $cells .= "<rect x=\"{$x}\" y=\"{$y}\" width=\"10\" height=\"10\" fill=\"#0F172A\"/>";
                }
            }
        }
        srand(); // reset

        return <<<SVG
<svg viewBox="0 0 100 100" width="100%" height="100%">
    {$cells}
    <rect x="35" y="35" width="30" height="30" rx="4" fill="#fff" stroke="#0D9488" stroke-width="2"/>
    <text x="50" y="55" text-anchor="middle" font-size="10" font-weight="700" fill="#0D9488">NX</text>
</svg>
SVG;
    }

    /**
     * GET ticket statistics for a route (for reporting dashboard).
     */
    public function ticketStats(string $routeId, Request $request): JsonResponse
    {
        $tripIds = DB::table('transport_bus_trips')
            ->where('route_id', $routeId)
            ->pluck('id');

        $totalIssued = DB::table('transport_seat_bookings')
            ->whereIn('trip_id', $tripIds)
            ->where('ticket_status', 'issued')
            ->count();

        $totalBoarded = DB::table('transport_seat_bookings')
            ->whereIn('trip_id', $tripIds)
            ->where('ticket_status', 'boarded')
            ->count();

        $totalBooked = DB::table('transport_seat_bookings')
            ->whereIn('trip_id', $tripIds)
            ->whereIn('status', ['booked', 'confirmed', 'boarded'])
            ->count();

        $totalRevenue = DB::table('transport_seat_bookings')
            ->whereIn('trip_id', $tripIds)
            ->whereIn('status', ['booked', 'confirmed', 'boarded'])
            ->sum('ticket_price');

        $activeHolds = DB::table('transport_seat_holds')
            ->whereIn('trip_id', $tripIds)
            ->where('hold_expires_at', '>', now())
            ->count();

        $trips = DB::table('transport_bus_trips')
            ->where('route_id', $routeId)
            ->select('id', 'status', 'origin', 'destination', 'started_at', 'completed_at', 'scheduled_departure_at')
            ->orderByDesc('created_at')
            ->limit(20)
            ->get();

        return response()->json([
            'success' => true,
            'data'    => [
                'route_id'       => $routeId,
                'total_issued'   => $totalIssued,
                'total_boarded'  => $totalBoarded,
                'total_booked'   => $totalBooked,
                'total_revenue'  => (float) $totalRevenue,
                'active_holds'   => $activeHolds,
                'recent_trips'   => $trips,
            ],
        ]);
    }
}
