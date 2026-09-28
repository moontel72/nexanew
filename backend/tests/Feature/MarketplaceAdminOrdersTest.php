<?php

namespace Tests\Feature;

use App\Http\Controllers\Admin\MarketplaceAdminController;
use App\Models\Company;
use App\Models\Reseller;
use App\Models\ResellerOrder;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

/**
 * Item #11 — the read-only marketplace oversight the panels read.
 *
 * The Super Admin and each group's Sub-Admin own no factory and no product, so
 * this endpoint only reads. The production migrations are Postgres-specific, so
 * the three tables it touches are created here in a sqlite-compatible shape
 * (same approach as StudioAuthControllerTest).
 */
class MarketplaceAdminOrdersTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();

        $this->createTables();
    }

    public function test_the_orders_endpoint_is_route_protected(): void
    {
        // No token: platform-wide order data must never be public.
        $this->getJson('/api/v1/admin/marketplace/orders')->assertStatus(401);
    }

    public function test_orders_returns_every_order_with_its_reseller_and_factory(): void
    {
        $factory = $this->makeCompany('Moon Medi');
        $reseller = $this->makeReseller('Zahid Traders');

        $this->makeOrder($factory, $reseller, 'pending', 1000);
        $this->makeOrder($factory, $reseller, 'delivered', 500);

        $payload = $this->orders()->getData(true);

        $this->assertTrue($payload['success']);
        $this->assertCount(2, $payload['data']);
        $this->assertSame(2, $payload['meta']['total']);

        $this->assertSame('Zahid Traders', $payload['data'][0]['reseller']['name']);
        $this->assertSame('Moon Medi', $payload['data'][0]['factory']['name']);
    }

    public function test_orders_can_be_filtered_by_status_and_by_factory(): void
    {
        $moon = $this->makeCompany('Moon Medi');
        $maxi = $this->makeCompany('Maxi Electronic');
        $reseller = $this->makeReseller('Zahid Traders');

        $this->makeOrder($moon, $reseller, 'pending', 1000);
        $this->makeOrder($maxi, $reseller, 'delivered', 500);

        $pending = $this->orders(['status' => 'pending'])->getData(true);
        $this->assertCount(1, $pending['data']);
        $this->assertSame('pending', $pending['data'][0]['order_status']);

        $maxiOnly = $this->orders(['factory_id' => $maxi->id])->getData(true);
        $this->assertCount(1, $maxiOnly['data']);
        $this->assertSame($maxi->id, $maxiOnly['data'][0]['factory_id']);
    }

    public function test_orders_search_matches_the_reseller_name(): void
    {
        $factory = $this->makeCompany('Moon Medi');
        $zahid = $this->makeReseller('Zahid Traders');
        $ali = $this->makeReseller('Ali Distributors');

        $this->makeOrder($factory, $zahid, 'pending', 100);
        $this->makeOrder($factory, $ali, 'pending', 200);

        $payload = $this->orders(['search' => 'Zahid'])->getData(true);

        $this->assertCount(1, $payload['data']);
        $this->assertSame('Zahid Traders', $payload['data'][0]['reseller']['name']);
    }

    public function test_summary_groups_orders_by_status_with_values(): void
    {
        $factory = $this->makeCompany('Moon Medi');
        $reseller = $this->makeReseller('Zahid Traders');

        $this->makeOrder($factory, $reseller, 'pending', 1000);
        $this->makeOrder($factory, $reseller, 'pending', 250);
        $this->makeOrder($factory, $reseller, 'delivered', 500);

        $payload = app(MarketplaceAdminController::class)->summary()->getData(true);

        $this->assertTrue($payload['success']);
        $this->assertSame(3, $payload['data']['total_orders']);
        // JSON numbers decode as int when they have no fraction, so compare numerically.
        $this->assertSame(1750.0, (float) $payload['data']['total_value']);

        $byStatus = collect($payload['data']['by_status'])->keyBy('status');
        $this->assertSame(2, $byStatus['pending']['count']);
        $this->assertSame(1250.0, (float) $byStatus['pending']['value']);
        $this->assertSame(1, $byStatus['delivered']['count']);
        $this->assertSame(500.0, (float) $byStatus['delivered']['value']);
    }

    /**
     * @param  array<string, mixed>  $query
     */
    private function orders(array $query = [])
    {
        $request = Request::create('/api/v1/admin/marketplace/orders', 'GET', $query);

        return app(MarketplaceAdminController::class)->orders($request);
    }

    private function makeCompany(string $name): Company
    {
        return Company::create([
            'id' => (string) Str::uuid(),
            'name' => $name,
            'city' => 'Lahore',
            'company_type' => 'manufacturing',
            'status' => 'active',
            'is_deleted' => false,
        ]);
    }

    private function makeReseller(string $name): Reseller
    {
        return Reseller::create([
            'name' => $name,
            'business_name' => $name.' Pvt Ltd',
            'email' => Str::lower(Str::random(10)).'@example.com',
            'phone' => '+92'.random_int(3000000000, 3999999999),
            'city' => 'Lahore',
            'status' => 'active',
            'purchase_approved' => true,
        ]);
    }

    private function makeOrder(Company $factory, Reseller $reseller, string $status, float $grandTotal): ResellerOrder
    {
        return ResellerOrder::create([
            'reseller_id' => $reseller->id,
            'factory_id' => $factory->id,
            'tenant_id' => 'default',
            'order_status' => $status,
            'items' => [],
            'subtotal' => $grandTotal,
            'grand_total' => $grandTotal,
            'currency' => 'PKR',
        ]);
    }

    /**
     * The tables this read path touches, in a sqlite-compatible shape.
     */
    private function createTables(): void
    {
        if (! Schema::hasTable('companies')) {
            Schema::create('companies', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name');
                $table->string('city')->nullable();
                $table->string('company_type')->nullable();
                $table->string('status')->default('active');
                $table->boolean('is_deleted')->default(false);
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('resellers')) {
            Schema::create('resellers', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name');
                $table->string('business_name');
                $table->string('email');
                $table->string('phone');
                $table->string('password')->nullable();
                $table->string('city')->nullable();
                $table->string('status')->default('active');
                $table->boolean('purchase_approved')->default(false);
                $table->timestamps();
                // `Reseller` uses SoftDeletes, so every relation query adds this predicate.
                $table->softDeletes();
            });
        }

        if (! Schema::hasTable('reseller_orders')) {
            Schema::create('reseller_orders', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('reseller_id');
                $table->uuid('factory_id');
                $table->string('tenant_id')->default('default');
                $table->string('order_status')->default('pending');
                $table->json('items')->nullable();
                $table->decimal('subtotal', 12, 2)->default(0);
                $table->decimal('discount_total', 12, 2)->default(0);
                $table->decimal('tax_total', 12, 2)->default(0);
                $table->decimal('grand_total', 12, 2)->default(0);
                $table->string('currency', 10)->default('PKR');
                $table->string('pricing_profile_id')->nullable();
                $table->json('metadata')->nullable();
                $table->timestamps();
            });
        }
    }
}
