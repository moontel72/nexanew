<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminPlanController;
use App\Http\Controllers\Admin\AdminCompanyController;

/*
|--------------------------------------------------------------------------
| API Routes for NexaTrace Super Admin Panel
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for the super admin panel.
| These routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes (no authentication required)
Route::prefix('admin')->group(function () {
    // Authentication routes
    Route::prefix('auth')->group(function () {
        Route::post('login', [AdminAuthController::class, 'login']);
        Route::post('register', [AdminAuthController::class, 'register']);
        Route::post('forgot-password', [AdminAuthController::class, 'forgotPassword']);
        Route::post('reset-password', [AdminAuthController::class, 'resetPassword']);
    });
});

// Protected routes (require authentication)
Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {
    // Authentication routes
    Route::prefix('auth')->group(function () {
        Route::post('logout', [AdminAuthController::class, 'logout']);
        Route::get('profile', [AdminAuthController::class, 'profile']);
        Route::post('refresh', [AdminAuthController::class, 'refresh']);
        Route::post('change-password', [AdminAuthController::class, 'changePassword']);
        Route::get('check-password-expiry', [AdminAuthController::class, 'checkPasswordExpiry']);
    });

    // Dashboard routes
    Route::prefix('dashboard')->group(function () {
        Route::get('stats', [AdminDashboardController::class, 'getDashboardStats']);
        Route::get('filters', [AdminDashboardController::class, 'getDashboardFilters']);
    });

    // Subscription Plan Management routes
    Route::prefix('plans')->group(function () {
        Route::get('/', [AdminPlanController::class, 'index']);
        Route::post('/', [AdminPlanController::class, 'store']);
        Route::get('statistics', [AdminPlanController::class, 'statistics']);
        Route::get('features', [AdminPlanController::class, 'features']);
        Route::post('export', [AdminPlanController::class, 'export']);

        // Plan-specific routes
        Route::prefix('{plan}')->group(function () {
            Route::get('/', [AdminPlanController::class, 'show']);
            Route::put('/', [AdminPlanController::class, 'update']);
            Route::delete('/', [AdminPlanController::class, 'destroy']);
            Route::post('duplicate', [AdminPlanController::class, 'duplicate']);
        });
    });

    // Company Management routes
    Route::prefix('companies')->group(function () {
        Route::get('/', [AdminCompanyController::class, 'index']);
        Route::post('/', [AdminCompanyController::class, 'store']);
        Route::post('export', [AdminCompanyController::class, 'export']);
        Route::get('statistics', [AdminCompanyController::class, 'statistics']);

        // Company-specific routes
        Route::prefix('{company}')->group(function () {
            Route::get('/', [AdminCompanyController::class, 'show']);
            Route::put('/', [AdminCompanyController::class, 'update']);
            Route::delete('/', [AdminCompanyController::class, 'destroy']);

            // Company status routes
            Route::put('status', [AdminCompanyController::class, 'updateStatus']);
            Route::put('verification-status', [AdminCompanyController::class, 'updateVerificationStatus']);

            // Company subscription routes
            Route::post('assign-plan', [AdminCompanyController::class, 'assignPlan']);

            // Company document routes
            Route::post('documents', [AdminCompanyController::class, 'uploadDocument']);
            Route::delete('documents/{document}', [AdminCompanyController::class, 'deleteDocument']);

            // Company communication routes
            Route::post('send-welcome-email', [AdminCompanyController::class, 'sendWelcomeEmail']);
            Route::post('reset-password', [AdminCompanyController::class, 'resetCompanyPassword']);
        });
    });

    // Billing Management routes (to be implemented)
    Route::prefix('billing')->group(function () {
        Route::get('invoices', function () {
            return response()->json(['message' => 'Billing endpoints coming soon']);
        });
        Route::get('subscriptions', function () {
            return response()->json(['message' => 'Billing endpoints coming soon']);
        });
        Route::get('transactions', function () {
            return response()->json(['message' => 'Billing endpoints coming soon']);
        });
    });

    // User Management routes (to be implemented)
    Route::prefix('users')->group(function () {
        Route::get('/', function () {
            return response()->json(['message' => 'User management endpoints coming soon']);
        });
    });

    // Reports routes (to be implemented)
    Route::prefix('reports')->group(function () {
        Route::get('usage', function () {
            return response()->json(['message' => 'Reports endpoints coming soon']);
        });
        Route::get('revenue', function () {
            return response()->json(['message' => 'Reports endpoints coming soon']);
        });
        Route::get('audit-logs', function () {
            return response()->json(['message' => 'Reports endpoints coming soon']);
        });
    });

    // Settings routes (to be implemented)
    Route::prefix('settings')->group(function () {
        Route::get('system', function () {
            return response()->json(['message' => 'Settings endpoints coming soon']);
        });
        Route::get('email-templates', function () {
            return response()->json(['message' => 'Settings endpoints coming soon']);
        });
        Route::get('api-keys', function () {
            return response()->json(['message' => 'Settings endpoints coming soon']);
        });
    });
});

// Health check route
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
        'service' => 'NexaTrace Super Admin API',
        'version' => '1.0.0',
    ]);
});

// Catch-all route for undefined endpoints
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'Endpoint not found',
        'documentation' => 'https://docs.nexatrace.com/admin-api',
    ], 404);
});
