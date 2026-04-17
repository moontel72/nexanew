<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CorsMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $origin = $request->headers->get("Origin");
        $allowedOrigin = $this->resolveAllowedOrigin($origin);

        // Log request for debugging
        \Log::info("CORS Request", [
            "method" => $request->getMethod(),
            "path" => $request->path(),
            "full_url" => $request->fullUrl(),
            "origin" => $origin,
            "allowed_origin" => $allowedOrigin,
            "user_agent" => $request->userAgent(),
            "headers" => $request->headers->all(),
        ]);

        // Handle preflight requests
        if ($request->getMethod() === "OPTIONS") {
            \Log::info("CORS Preflight Request Handled", [
                "path" => $request->path(),
                "origin" => $origin,
            ]);
            return $this->createPreflightResponse($request, $allowedOrigin);
        }

        // Handle actual request
        $response = $next($request);

        // Log response
        \Log::info("CORS Response", [
            "method" => $request->getMethod(),
            "path" => $request->path(),
            "status" => $response->getStatusCode(),
            "origin" => $origin,
        ]);

        return $this->addCorsHeaders($request, $response, $allowedOrigin);
    }

    /**
     * Resolve allowed origin based on request origin.
     */
    private function resolveAllowedOrigin(?string $origin): ?string
    {
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

        // Log rejected origins for debugging
        \Log::warning("CORS Origin Rejected", [
            "origin" => $origin,
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
        } else {
            // Fallback for debugging
            $response->headers->set("Access-Control-Allow-Origin", "*");
            \Log::warning("CORS Using wildcard origin for preflight", [
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
        $response->headers->set("Access-Control-Allow-Credentials", "true");
        $response->headers->set("Access-Control-Max-Age", "86400"); // 24 hours
        $response->headers->set(
            "Access-Control-Expose-Headers",
            "Authorization, Content-Type, X-Total-Count, X-RateLimit-Limit, X-RateLimit-Remaining",
        );

        // Log preflight response headers for debugging
        \Log::info("CORS Preflight Response Headers", [
            "headers" => $response->headers->all(),
            "path" => $request->path(),
        ]);

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
        } else {
            // For debugging, allow all origins temporarily
            $origin = $request->headers->get("Origin");
            if ($origin && preg_match("#^https?://#", $origin)) {
                $response->headers->set("Access-Control-Allow-Origin", $origin);
                $response->headers->set(
                    "Access-Control-Allow-Credentials",
                    "true",
                );
                \Log::warning("CORS Allowing origin for debugging", [
                    "origin" => $origin,
                    "path" => $request->path(),
                    "method" => $request->getMethod(),
                ]);
            }
        }

        $response->headers->set(
            "Access-Control-Expose-Headers",
            "Authorization, Content-Type, X-Total-Count, X-RateLimit-Limit, X-RateLimit-Remaining",
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

        // Log CORS headers for debugging
        \Log::info("CORS Headers Added", [
            "method" => $request->getMethod(),
            "path" => $request->path(),
            "status" => $response->getStatusCode(),
            "cors_headers" => [
                "Access-Control-Allow-Origin" => $response->headers->get(
                    "Access-Control-Allow-Origin",
                ),
                "Access-Control-Allow-Methods" => $response->headers->get(
                    "Access-Control-Allow-Methods",
                ),
                "Access-Control-Allow-Headers" => $response->headers->get(
                    "Access-Control-Allow-Headers",
                ),
            ],
        ]);

        return $response;
    }
}
