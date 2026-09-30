<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

class CorsMiddleware
{
    /**
     * Handle an incoming request.
     *
     * LOGGING RULE (MASTER-TASK-LIST.md item 13)
     * ------------------------------------------
     * This used to emit three INFO lines for EVERY request — "CORS Request" (with a
     * full header dump), "CORS Response" and "CORS Headers Added" — plus two more for
     * each preflight. Healthy traffic therefore buried the real errors in
     * laravel.log and grew the disk, while telling nobody anything: a normal CORS
     * exchange is not news. A successful exchange is now SILENT. Only a rejected
     * origin is logged (warning), because refusing a client is the one case that
     * needs a human.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $origin = $request->headers->get("Origin");
        $allowedOrigin = $this->resolveAllowedOrigin($request, $origin);

        // Handle preflight requests
        if ($request->getMethod() === "OPTIONS") {
            return $this->createPreflightResponse($request, $allowedOrigin);
        }

        // Handle actual request
        $response = $next($request);

        return $this->addCorsHeaders($request, $response, $allowedOrigin);
    }

    /**
     * Resolve allowed origin based on request origin.
     */
    private function resolveAllowedOrigin(
        Request $request,
        ?string $origin,
    ): ?string {
        if (!$origin) {
            return null;
        }

        // Allow localhost, local IPs, and the production server
        if (
            preg_match(
                '#^https?://(localhost|127\.0\.0\.1|135\.181\.46\.27)(:\d+)?$#',
                $origin,
            ) === 1
        ) {
            return $origin;
        }

        // Allow every traceodd.com subdomain (studio, cricket,
        // cricket-manager, www) over http/https with any port.
        if (
            preg_match(
                '#^https?://([a-z0-9-]+\.)*traceodd\.com(:\d+)?$#',
                $origin,
            ) === 1
        ) {
            return $origin;
        }

        // Allow the packaged desktop app (Todd Studio): Tauri's WebView2
        // origin on Windows (http(s)://tauri.localhost) and its custom
        // scheme on macOS/Linux (tauri://localhost).
        if (
            preg_match(
                '#^(tauri://localhost|https?://tauri\.localhost)$#',
                $origin,
            ) === 1
        ) {
            return $origin;
        }

        // A rejected origin is worth exactly one log line — the path is what makes
        // it actionable (which endpoint was refused for whom).
        Log::warning("CORS Origin Rejected", [
            "origin" => $origin,
            "path" => $request->path(),
            "pattern" =>
                '#^https?://(localhost|127\.0\.0\.1|135\.181\.46\.27)(:\d+)?$#',
        ]);

        return null;
    }

    /**
     * Create response for preflight (OPTIONS) requests.
     */
    private function createPreflightResponse(
        Request $request,
        ?string $allowedOrigin,
    ): Response {
        $response = new Response("", 204);

        if ($allowedOrigin) {
            $response->headers->set(
                "Access-Control-Allow-Origin",
                $allowedOrigin,
            );
            $response->headers->set("Access-Control-Allow-Credentials", "true");
        } else {
            Log::warning("CORS Origin not allowed for preflight", [
                "requested_origin" => $request->headers->get("Origin"),
                "path" => $request->path(),
            ]);
        }

        $response->headers->set(
            "Access-Control-Allow-Methods",
            "GET, POST, PUT, PATCH, DELETE, OPTIONS",
        );
        $response->headers->set(
            "Access-Control-Allow-Headers",
            "Content-Type, Authorization, X-Requested-With, Accept, Origin, X-CSRF-TOKEN, X-Requested-With",
        );
        $response->headers->set("Access-Control-Max-Age", "86400"); // 24 hours
        $response->headers->set(
            "Access-Control-Expose-Headers",
            "Authorization, Content-Type, X-Total-Count, X-RateLimit-Limit, X-RateLimit-Remaining, Content-Disposition"
        );

        // NOTE: no success log here on purpose — see the logging rule in handle().
        return $response;
    }

    /**
     * Add CORS headers to the response.
     */
    private function addCorsHeaders(
        Request $request,
        Response $response,
        ?string $allowedOrigin,
    ): Response {
        $response->headers->set("Vary", "Origin");

        if ($allowedOrigin) {
            $response->headers->set(
                "Access-Control-Allow-Origin",
                $allowedOrigin,
            );
            $response->headers->set("Access-Control-Allow-Credentials", "true");
        }

        $response->headers->set(
            "Access-Control-Expose-Headers",
            "Authorization, Content-Type, X-Total-Count, X-RateLimit-Limit, X-RateLimit-Remaining, Content-Disposition"
        );
        $response->headers->set(
            "Access-Control-Allow-Methods",
            "GET, POST, PUT, PATCH, DELETE, OPTIONS",
        );

        // Add requested headers if present in preflight
        $requestedHeaders = $request->headers->get(
            "Access-Control-Request-Headers",
        );
        if ($requestedHeaders) {
            $response->headers->set(
                "Access-Control-Allow-Headers",
                $requestedHeaders,
            );
        } else {
            $response->headers->set(
                "Access-Control-Allow-Headers",
                "Content-Type, Authorization, X-Requested-With, Accept, Origin, X-CSRF-TOKEN, X-Requested-With",
            );
        }

        // NOTE: no success log here on purpose — see the logging rule in handle().
        return $response;
    }
}
