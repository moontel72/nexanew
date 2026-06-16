<?php

namespace App\Http\Controllers\Telemetry;

use App\Http\Controllers\Controller;
use App\Models\TenantAccount;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TrackingRouterController extends Controller
{
    /** POST /api/v1/tracking/generate-family-token */
    public function generateFamilyShareToken(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'bus_number_plate' => ['required', 'string', 'max:32'],
            'trip_id' => ['nullable', 'string', 'uuid'],
            'expires_in_minutes' => ['nullable', 'integer', 'min:10', 'max:1440'],
        ]);

        $token = Str::random(64);
        $expiresAt = now()->addMinutes($validated['expires_in_minutes'] ?? 120);

        DB::table('passenger_safety_tokens')->insert([
            'id' => (string) Str::uuid(),
            'bus_number_plate' => $validated['bus_number_plate'],
            'share_token' => $token,
            'trip_id' => $validated['trip_id'] ?? null,
            'passenger_id' => $request->user()?->id,
            'expires_at' => $expiresAt,
            'created_at' => now(), 'updated_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'data' => [
                'share_token' => $token,
                'share_url' => config('app.url') . "/track/{$token}",
                'expires_at' => $expiresAt->toIso8601String(),
                'bus_number_plate' => $validated['bus_number_plate'],
            ],
        ]);
    }

    /** GET /api/v1/tracking/family-stream/{token} — PUBLIC, no auth */
    public function getPublicFamilyStream(string $token): JsonResponse
    {
        $record = DB::table('passenger_safety_tokens')->where('share_token', $token)->first();
        if (!$record) return response()->json(['status' => 'error', 'message' => 'Invalid token.'], 404);
        if (now()->greaterThan($record->expires_at)) return response()->json(['status' => 'error', 'message' => 'Token expired.'], 410);

        $position = DB::table('transport_bus_trips')
            ->where('bus_id', $record->bus_number_plate)->where('status', 'active')
            ->select('current_lat', 'current_lng', 'speed_kmph', 'next_stop', 'eta_minutes')->first();

        return response()->json(['status' => 'success', 'data' => [
            'lat' => $position->current_lat ?? null, 'lng' => $position->current_lng ?? null,
            'speed_kmph' => $position->speed_kmph ?? null, 'next_stop' => $position->next_stop ?? null,
            'eta_minutes' => $position->eta_minutes ?? null, 'expires_at' => $record->expires_at,
        ]]);
    }

    /** GET /api/v1/super-admin/billing-invoice */
    public function getSuperAdminBillingInvoice(): JsonResponse
    {
        $tenants = TenantAccount::where('status', 'active')->get();
        $invoice = $tenants->map(function ($t) {
            $count = $t->active_bus_count ?: DB::table('absolute_bus_layouts')->where('tenant_account_id', $t->id)->count();
            $rate = $t->subscription_rate_pkr ?: 5000;
            return ['tenant_id' => $t->id, 'account_name' => $t->account_name, 'active_buses' => $count, 'rate_pkr' => $rate, 'monthly_pkr' => $count * $rate];
        });
        return response()->json(['status' => 'success', 'data' => ['tenants' => $invoice, 'grand_total_pkr' => $invoice->sum('monthly_pkr'), 'month' => now()->format('F Y')]]);
    }
}
