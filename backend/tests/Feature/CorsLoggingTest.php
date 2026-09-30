<?php

namespace Tests\Feature;

use App\Http\Middleware\CorsMiddleware;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;
use Tests\TestCase;

/**
 * MASTER-TASK-LIST.md item 13 — the CORS log flood.
 *
 * The middleware used to write three INFO lines for every request (plus two more per
 * preflight), so healthy traffic buried the real errors in laravel.log and grew the
 * disk. Nothing tested that, which is how it survived. These tests pin the rule: a
 * normal exchange is silent, and only a rejected origin talks — once.
 */
class CorsLoggingTest extends TestCase
{
    public function test_a_normal_cors_exchange_writes_no_log_lines(): void
    {
        Log::spy();

        $this->runMiddleware('https://admin.traceodd.com');

        Log::shouldNotHaveReceived('info');
        Log::shouldNotHaveReceived('warning');
    }

    public function test_a_request_without_an_origin_header_writes_no_log_lines(): void
    {
        Log::spy();

        $this->runMiddleware(null);

        Log::shouldNotHaveReceived('info');
        Log::shouldNotHaveReceived('warning');
    }

    public function test_a_rejected_origin_warns_exactly_once(): void
    {
        Log::spy();

        $this->runMiddleware('https://not-ours.example.com');

        Log::shouldNotHaveReceived('info');
        Log::shouldHaveReceived('warning')->once();
    }

    public function test_the_allowed_origin_is_still_echoed_back(): void
    {
        $response = $this->runMiddleware('https://admin.traceodd.com');

        $this->assertSame(
            'https://admin.traceodd.com',
            $response->headers->get('Access-Control-Allow-Origin'),
        );
    }

    /**
     * Drive the middleware directly, like the other feature tests drive controllers.
     */
    private function runMiddleware(?string $origin): Response
    {
        $request = Request::create('/api/v1/health', 'GET');

        if ($origin !== null) {
            $request->headers->set('Origin', $origin);
        }

        return app(CorsMiddleware::class)->handle(
            $request,
            static fn (): Response => new Response('ok'),
        );
    }
}
