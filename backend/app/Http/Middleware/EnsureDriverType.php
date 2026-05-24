<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * NEXATRACE — ENSURE DRIVER TYPE MIDDLEWARE
 * ==========================================
 *
 * Multi-tenant driver route interceptor that prevents
 * cross-contamination between different driver types.
 *
 * USAGE (in routes):
 *   Route::middleware('driver.type:factory')->group(...)
 *   Route::middleware('driver.type:truck')->group(...)
 *   Route::middleware('driver.type:bus')->group(...)
 *
 * If a Factory Driver tries to access Truck/Bus endpoints,
 * they receive HTTP 403 Forbidden.
 *
 * SAFETY: Entirely NEW middleware. Zero modification to existing code.
 * TARGET MODULES: 4AD, 11, 15
 */

class EnsureDriverType
{
    public function handle(Request $request, Closure $next, string ...$allowedTypes): mixed
    {
        $user = $request->user();

        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $driverType = $user->driver_type ?? 'factory';

        if (! in_array($driverType, $allowedTypes, true)) {
            return response()->json([
                'success' => false,
                'message' => "Access denied. Driver type '{$driverType}' is not authorized for this endpoint. Allowed: " . implode(', ', $allowedTypes),
            ], 403);
        }

        return $next($request);
    }
}
