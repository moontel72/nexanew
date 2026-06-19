<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NexaTrace Bus Ticket — {{ $ticket['seat_label'] }}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', system-ui, -apple-system, sans-serif; background: #f1f5f9; display: flex; justify-content: center; padding: 20px; }
        .ticket { max-width: 420px; width: 100%; background: #fff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,.1); }
        .ticket-header { background: linear-gradient(135deg, #0D9488, #0F766E); color: #fff; padding: 20px 24px; }
        .ticket-header h1 { font-size: 18px; font-weight: 700; }
        .ticket-header .sub { font-size: 12px; opacity: .85; margin-top: 4px; }
        .ticket-body { padding: 20px 24px; }
        .row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f1f5f9; }
        .row:last-child { border-bottom: none; }
        .label { font-size: 11px; color: #64748b; text-transform: uppercase; letter-spacing: .5px; }
        .value { font-size: 14px; font-weight: 600; color: #1e293b; text-align: right; }
        .seat-badge { display: inline-block; background: #0D9488; color: #fff; padding: 6px 16px; border-radius: 20px; font-size: 16px; font-weight: 700; }
        .qr-section { text-align: center; padding: 16px 24px 24px; background: #f8fafc; }
        .qr-code { width: 140px; height: 140px; margin: 0 auto 12px; background: #fff; border: 3px solid #0D9488; border-radius: 12px; padding: 8px; }
        .hash { font-family: 'Fira Code', 'Courier New', monospace; font-size: 9px; color: #94a3b8; word-break: break-all; margin-top: 8px; }
        .footer { text-align: center; padding: 14px 24px; background: #0F172A; color: #94a3b8; font-size: 10px; }
        .status-badge { display: inline-block; padding: 3px 10px; border-radius: 10px; font-size: 11px; font-weight: 600; }
        .status-issued { background: #dcfce7; color: #16a34a; }
        .status-boarded { background: #dbeafe; color: #2563eb; }
        .driver-info { background: #fef3c7; border-radius: 10px; padding: 12px; margin-top: 12px; font-size: 12px; color: #92400e; }

        @media print {
            body { background: #fff; padding: 0; }
            .ticket { box-shadow: none; max-width: 100%; }
        }
    </style>
</head>
<body>
    <div class="ticket">
        <div class="ticket-header">
            <h1>🎫 {{ $ticket['bus_name'] }}</h1>
            <div class="sub">{{ $ticket['route_name'] }} @if($ticket['route_code']) · {{ $ticket['route_code'] }} @endif</div>
        </div>

        <div class="ticket-body">
            <div class="row">
                <span class="label">Passenger Seat</span>
                <span class="seat-badge">{{ $ticket['seat_label'] }}</span>
            </div>
            <div class="row">
                <span class="label">Seat Number</span>
                <span class="value">#{{ $ticket['seat_number'] }}</span>
            </div>
            <div class="row">
                <span class="label">From</span>
                <span class="value">{{ $ticket['origin'] }}</span>
            </div>
            <div class="row">
                <span class="label">To</span>
                <span class="value">{{ $ticket['destination'] }}</span>
            </div>
            <div class="row">
                <span class="label">Departure</span>
                <span class="value">{{ $ticket['scheduled_departure_at'] ? \Carbon\Carbon::parse($ticket['scheduled_departure_at'])->format('d M Y, h:i A') : '—' }}</span>
            </div>
            <div class="row">
                <span class="label">Ticket Price</span>
                <span class="value">Rs. {{ number_format($ticket['ticket_price'], 0) }}</span>
            </div>
            <div class="row">
                <span class="label">Payment</span>
                <span class="value">{{ ucfirst($ticket['payment_method']) }}</span>
            </div>
            <div class="row">
                <span class="label">Status</span>
                <span class="value">
                    <span class="status-badge status-{{ $ticket['ticket_status'] }}">{{ ucfirst($ticket['ticket_status']) }}</span>
                </span>
            </div>
            <div class="row">
                <span class="label">Booked At</span>
                <span class="value">{{ \Carbon\Carbon::parse($ticket['booked_at'])->format('d M Y, h:i A') }}</span>
            </div>

            @if($ticket['driver_name'] || $ticket['conductor_name'] || $ticket['bus_plate'])
            <div class="driver-info">
                @if($ticket['bus_plate'])<strong>Plate:</strong> {{ $ticket['bus_plate'] }} · @endif
                @if($ticket['driver_name'])<strong>Driver:</strong> {{ $ticket['driver_name'] }} · @endif
                @if($ticket['conductor_name'])<strong>Conductor:</strong> {{ $ticket['conductor_name'] }}@endif
            </div>
            @endif
        </div>

        <div class="qr-section">
            <div class="qr-code">
                <svg viewBox="0 0 100 100" width="100%" height="100%">
                    @php
                        $hash = $ticket['ticket_hash'] ?? 'nexatrace';
                        $seed = crc32($hash);
                        srand($seed);
                    @endphp
                    @for($r = 0; $r < 10; $r++)
                        @for($c = 0; $c < 10; $c++)
                            @if(rand(0, 1))
                                <rect x="{{ $c * 10 }}" y="{{ $r * 10 }}" width="10" height="10" fill="#0F172A"/>
                            @endif
                        @endfor
                    @endfor
                    <rect x="35" y="35" width="30" height="30" rx="4" fill="#fff" stroke="#0D9488" stroke-width="2"/>
                    <text x="50" y="55" text-anchor="middle" font-size="10" font-weight="700" fill="#0D9488">NX</text>
                </svg>
            </div>
            <div class="hash">🔐 {{ $ticket['ticket_hash'] }}</div>
        </div>

        <div class="footer">
            Booking ID: {{ $ticket['booking_id'] }} · NexaTrace Secure Transit · Tamper-Proof SHA-256
        </div>
    </div>
</body>
</html>
