<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

/**
 * NEXATRACE — PANEL ROUTE SERVICE PROVIDER
 * =========================================
 *
 * Registers distributed panel route files from routes/panels/.
 * Each panel file maps to its own prefix under api/v1/ with
 * auth:sanctum middleware.
 *
 * PANEL ROUTE MAP:
 *   super_admin.php  →  /api/v1/super-admin    (Modules 1, 2)
 *   factory.php      →  /api/v1/factory        (Modules 3, 4, 5, 8)
 *   marketplace.php  →  /api/v1/marketplace    (Modules 6, 7, 12)
 *   truck_fleet.php  →  /api/v1/truck-fleet    (Modules 9, 10, 11)
 *   bus_fleet.php    →  /api/v1/bus-fleet      (Modules 13, 14, 15)
 *   goods_fleet.php  →  /api/v1/goods-fleet    (Goods Logistics)
 *
 * SAFETY:
 *   - 100 % ADDITIVE. Does NOT modify routes/api.php.
 *   - All panel route files start as stubs with commented-out
 *     route declarations for future migration.
 *   - Existing routes in api.php continue to function normally.
 *   - When a route is migrated from api.php to its panel file,
 *     comment out (don't delete) the old entry in api.php.
 *
 * REGISTRATION:
 *   This provider is registered in bootstrap/app.php.
 *   No changes to config/app.php required.
 */

class PanelRouteServiceProvider extends ServiceProvider
{
    /**
     * Panel route file map.
     *
     * @var array<string, string>
     */
    private array $panels = [
        'super_admin' => 'super_admin',
        'factory'     => 'factory',
        'marketplace' => 'marketplace',
        'truck_fleet' => 'truck_fleet',
        'bus_fleet'   => 'bus_fleet',
        'bus_owner'   => 'bus_owner',
        'goods_fleet' => 'goods_fleet',
    ];

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $this->registerPanelRoutes();
    }

    /**
     * Load all panel route files from routes/panels/.
     */
    private function registerPanelRoutes(): void
    {
        $basePath = base_path('routes/panels');

        foreach ($this->panels as $file) {
            $path = "{$basePath}/{$file}.php";

            if (file_exists($path)) {
                require $path;
            }
        }
    }
}
