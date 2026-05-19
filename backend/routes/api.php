<?php

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;

Route::get("/health", fn() => response()->json(["ok" => true]));

$registerRoutes = function (): void {
    Route::prefix("auth")->group(function (): void {
        Route::post("login", [
            \App\Http\Controllers\Auth\AdminAuthController::class,
            "login",
        ]);
        // Temporary GET route for debugging 405 errors
        Route::get("login", function (\Illuminate\Http\Request $request) {
            Log::warning("GET request to login endpoint", [
                "method" => $request->method(),
                "path" => $request->path(),
                "full_url" => $request->fullUrl(),
                "user_agent" => $request->userAgent(),
                "headers" => $request->headers->all(),
                "ip" => $request->ip(),
                "query_params" => $request->query(),
            ]);

            return response()->json(
                [
                    "error" => "GET method not supported for login",
                    "message" => "Please use POST method for login requests",
                    "debug" => [
                        "request_method" => $request->method(),
                        "expected_method" => "POST",
                        "timestamp" => now()->toISOString(),
                    ],
                ],
                405,
            );
        });
        Route::post("logout", [
            \App\Http\Controllers\Auth\AdminAuthController::class,
            "logout",
        ])->middleware("auth:admin");
        Route::post("refresh", [
            \App\Http\Controllers\Auth\AdminAuthController::class,
            "refresh",
        ])->middleware("auth:admin");
        Route::post("change-password", [
            \App\Http\Controllers\Auth\AdminAuthController::class,
            "changePassword",
        ])->middleware("auth:admin");
        Route::get("validate", [
            \App\Http\Controllers\Auth\AdminAuthController::class,
            "validateToken",
        ])->middleware("auth:admin");
        Route::get("profile", [
            \App\Http\Controllers\Auth\AdminAuthController::class,
            "profile",
        ])->middleware("auth:admin");
    });

    Route::prefix("admin")
        ->middleware(["auth:admin", "admin"])
        ->group(function (): void {
            Route::prefix("dashboard")->group(function (): void {
                Route::get("", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "index",
                ]);
                Route::get("stats", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "stats",
                ]);
                Route::get("statistics", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "statistics",
                ]);
                Route::get("filters", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "filters",
                ]);
                Route::get("revenue", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "revenue",
                ]);
                Route::get("usage", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "usage",
                ]);
                Route::get("activities", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "activities",
                ]);
                Route::get("top-companies", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "topCompanies",
                ]);
                Route::get("system-health", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "systemHealth",
                ]);
                Route::get("audit-logs", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "auditLogs",
                ]);
                Route::get("subscription-analytics", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "subscriptionAnalytics",
                ]);
                Route::get("code-analytics", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "codeAnalytics",
                ]);
                Route::get("user-growth", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "userGrowth",
                ]);
                Route::get("export", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "export",
                ]);
                Route::get("realtime-metrics", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "realtimeMetrics",
                ]);
                Route::get("alerts", [
                    \App\Http\Controllers\Admin\AdminDashboardController::class,
                    "alerts",
                ]);
            });

            Route::prefix("transport")->group(function (): void {
                Route::get("wallet/stats", [
                    \App\Http\Controllers\Admin\AdminTransportController::class,
                    "walletStats",
                ]);
                Route::get("marketplace/stats", [
                    \App\Http\Controllers\Admin\AdminTransportController::class,
                    "marketplaceStats",
                ]);
                Route::get("drivers/stats", [
                    \App\Http\Controllers\Admin\AdminTransportController::class,
                    "driversStats",
                ]);
            });

            // Super Admin Billing Routes
            Route::prefix("billing")->group(function (): void {
                // Platform invoices
                Route::get("invoices", [
                    \App\Http\Controllers\Admin\AdminBillingControllerNew::class,
                    "getPlatformInvoices",
                ]);
                Route::get("invoices/{id}", [
                    \App\Http\Controllers\Admin\AdminBillingControllerNew::class,
                    "getInvoiceById",
                ]);
                Route::get("invoices/{id}/usage-breakdown", [
                    \App\Http\Controllers\Admin\AdminBillingControllerNew::class,
                    "getInvoiceUsageBreakdown",
                ]);
                Route::post("invoices/generate", [
                    \App\Http\Controllers\Admin\AdminBillingControllerNew::class,
                    "generateInvoice",
                ]);
                Route::put("invoices/{id}/status", [
                    \App\Http\Controllers\Admin\AdminBillingControllerNew::class,
                    "updateInvoiceStatus",
                ]);
                Route::post("invoices/{id}/send", [
                    \App\Http\Controllers\Admin\AdminInvoiceController::class,
                    "sendInvoiceNotification",
                ]);
                Route::post("invoices/{id}/mark-paid", [
                    \App\Http\Controllers\Admin\AdminBillingControllerNew::class,
                    "markInvoiceAsPaid",
                ]);
                Route::post("invoices/{id}/extra-charges", [
                    \App\Http\Controllers\Admin\AdminBillingControllerNew::class,
                    "addExtraCharge",
                ]);
                Route::get("invoices/{id}/pdf", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "downloadInvoicePdf",
                ]);
                Route::post("invoices/export/csv", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "exportInvoicesToCsv",
                ]);
                Route::post("invoices/export/excel", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "exportInvoicesToExcel",
                ]);

                // Company invoices
                Route::get("companies/{companyId}/invoices", [
                    \App\Http\Controllers\Admin\AdminInvoiceController::class,
                    "getCompanyInvoices",
                ]);

                // Payments
                Route::get("invoices/{id}/payments", [
                    \App\Http\Controllers\Admin\AdminInvoiceController::class,
                    "getInvoicePayments",
                ]);
                Route::post("invoices/{id}/payments", [
                    \App\Http\Controllers\Admin\AdminInvoiceController::class,
                    "recordPayment",
                ]);
                Route::post("payments/export/csv", [
                    \App\Http\Controllers\Admin\AdminPaymentController::class,
                    "exportPaymentsToCsv",
                ]);
                Route::post("payments/export/excel", [
                    \App\Http\Controllers\Admin\AdminPaymentController::class,
                    "exportPaymentsToExcel",
                ]);
                Route::get("companies/overdue", [
                    \App\Http\Controllers\Admin\AdminInvoiceController::class,
                    "getCompaniesWithOverdueInvoices",
                ]);

                // Revenue reporting
                Route::get("revenue/summary", [
                    \App\Http\Controllers\Admin\AdminRevenueController::class,
                    "getPlatformRevenueSummary",
                ]);
                Route::get("revenue/by-company", [
                    \App\Http\Controllers\Admin\AdminRevenueController::class,
                    "getRevenueByCompany",
                ]);
                Route::get("revenue/recurring", [
                    \App\Http\Controllers\Admin\AdminRevenueController::class,
                    "getRecurringRevenueMetrics",
                ]);
                Route::get("revenue/forecast", [
                    \App\Http\Controllers\Admin\AdminRevenueController::class,
                    "getRevenueForecast",
                ]);
                Route::post("revenue/reports", [
                    \App\Http\Controllers\Admin\AdminRevenueController::class,
                    "generateFinancialReport",
                ]);
                Route::get("revenue/tax-summary", [
                    \App\Http\Controllers\Admin\AdminRevenueController::class,
                    "getTaxSummary",
                ]);
                Route::post("revenue/export", [
                    \App\Http\Controllers\Admin\AdminRevenueController::class,
                    "exportRevenueData",
                ]);

                // Credit notes
                Route::get("credit-notes", [
                    \App\Http\Controllers\Admin\AdminCreditNoteController::class,
                    "getCreditNotes",
                ]);
                Route::post("credit-notes", [
                    \App\Http\Controllers\Admin\AdminCreditNoteController::class,
                    "createCreditNote",
                ]);
                Route::post("credit-notes/{id}/approve", [
                    \App\Http\Controllers\Admin\AdminCreditNoteController::class,
                    "approveCreditNote",
                ]);
                Route::post("credit-notes/{id}/apply", [
                    \App\Http\Controllers\Admin\AdminCreditNoteController::class,
                    "applyCreditNoteToInvoice",
                ]);
                Route::put("credit-notes/{id}/cancel", [
                    \App\Http\Controllers\Admin\AdminCreditNoteController::class,
                    "cancelCreditNote",
                ]);
                Route::post("credit-notes/export/csv", [
                    \App\Http\Controllers\Admin\AdminCreditNoteController::class,
                    "exportCreditNotesToCsv",
                ]);

                // Payment reconciliation
                Route::get("reconciliation", [
                    \App\Http\Controllers\Admin\AdminPaymentController::class,
                    "getPaymentReconciliation",
                ]);
                Route::post("reconcile", [
                    \App\Http\Controllers\Admin\AdminPaymentController::class,
                    "reconcilePayments",
                ]);
                Route::post("reconciliation/analyze", [
                    \App\Http\Controllers\Admin\AdminPaymentController::class,
                    "analyzeReconciliation",
                ]);
                Route::post("reconciliation/{id}/resolve", [
                    \App\Http\Controllers\Admin\AdminPaymentController::class,
                    "resolveDiscrepancy",
                ]);

                // Refund management
                Route::get("refunds", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "getRefunds",
                ]);
                Route::post("refunds", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "createRefund",
                ]);
                Route::post("refunds/{id}/approve", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "approveRefund",
                ]);
                Route::post("refunds/{id}/reject", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "rejectRefund",
                ]);
                Route::post("refunds/{id}/partial", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "processPartialRefund",
                ]);

                // Credit limit management
                Route::get("companies/{id}/credit-limit", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "getCreditLimit",
                ]);
                Route::put("companies/{id}/credit-limit", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "updateCreditLimit",
                ]);
                Route::get("credit-limits/report", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "getCreditLimitReport",
                ]);
                Route::post("credit-limits/alerts", [
                    \App\Http\Controllers\Admin\AdminBillingController::class,
                    "sendCreditLimitAlerts",
                ]);
            });

            Route::get("plans/statistics", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "getStatistics",
            ]);
            Route::get("plans/features", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "getFeatures",
            ]);
            Route::put("plans/{plan}/features", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "updateFeatures",
            ]);
            Route::post("plans/{plan}/duplicate", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "duplicate",
            ]);
            Route::put("plans/{plan}/status", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "updateStatus",
            ]);
            Route::get("plans/export", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "export",
            ]);
            Route::post("plans/import", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "import",
            ]);
            Route::post("plans/validate", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "validatePlan",
            ]);
            Route::get("plans/{plan}/pricing", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "getPricing",
            ]);
            Route::put("plans/{plan}/pricing", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "updatePricing",
            ]);
            Route::get("plans/{plan}/usage", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "usage",
            ]);
            Route::get("plans/{plan}/companies", [
                \App\Http\Controllers\Admin\AdminPlanController::class,
                "companies",
            ]);
            Route::apiResource(
                "plans",
                \App\Http\Controllers\Admin\AdminPlanController::class,
            );

            Route::get("companies/statistics", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "statistics",
            ]);
            Route::patch("companies/{company}/status", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "updateStatus",
            ]);
            Route::patch("companies/{company}/verification", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "updateVerification",
            ]);
            Route::patch("companies/{company}/verification-status", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "updateVerification",
            ]);
            Route::post("companies/{company}/assign-plan", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "assignPlan",
            ]);
            Route::post("companies/{company}/documents", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "uploadDocument",
            ]);
            Route::delete("companies/{company}/documents/{document}", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "deleteDocument",
            ]);
            Route::get("companies/export", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "export",
            ]);
            Route::post("companies/{company}/send-welcome-email", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "sendWelcomeEmail",
            ]);
            Route::post("companies/{company}/reset-password", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "resetPassword",
            ]);
            Route::get("companies/{company}/usage-stats", [
                \App\Http\Controllers\Admin\AdminCompanyController::class,
                "usageStats",
            ]);
            Route::apiResource(
                "companies",
                \App\Http\Controllers\Admin\AdminCompanyController::class,
            );

            // Reseller Management
            Route::get("resellers", [\App\Http\Controllers\Admin\AdminResellerController::class, "index"]);
            Route::post("resellers", [\App\Http\Controllers\Admin\AdminResellerController::class, "store"]);
            Route::get("resellers/{id}", [\App\Http\Controllers\Admin\AdminResellerController::class, "show"]);
            Route::put("resellers/{id}", [\App\Http\Controllers\Admin\AdminResellerController::class, "update"]);
            Route::delete("resellers/{id}", [\App\Http\Controllers\Admin\AdminResellerController::class, "destroy"]);
            Route::patch("resellers/{id}/status", [\App\Http\Controllers\Admin\AdminResellerController::class, "updateStatus"]);
            Route::patch("resellers/{id}/suspend", [\App\Http\Controllers\Admin\AdminResellerController::class, "toggleSuspend"]);
            Route::patch("resellers/{id}/approve-purchase", [\App\Http\Controllers\Admin\AdminResellerController::class, "approvePurchase"]);
            Route::patch("resellers/{id}/reject-purchase", [\App\Http\Controllers\Admin\AdminResellerController::class, "rejectPurchase"]);
            Route::get("resellers/{id}/proof", [\App\Http\Controllers\Admin\AdminResellerController::class, "viewProof"]);
        });

    // ──────────────────────────────────────────────────────────────
    // FILE UPLOAD (generic)
    // ──────────────────────────────────────────────────────────────
    Route::prefix("files")->group(function (): void {
        Route::post("upload", [\App\Http\Controllers\FileController::class, "upload"]);
        Route::delete("delete", [\App\Http\Controllers\FileController::class, "delete"]);
    });

    // ──────────────────────────────────────────────────────────────
    // RESELLER MARKETPLACE (public B2B endpoints)
    // ──────────────────────────────────────────────────────────────
    Route::prefix("reseller")->group(function (): void {
        // Public login
        Route::post("login", [\App\Http\Controllers\Reseller\ResellerAuthController::class, "login"]);
        Route::get("factories", [\App\Http\Controllers\Reseller\ResellerMarketplaceController::class, "factories"]);
        Route::get("products", [\App\Http\Controllers\Reseller\ResellerMarketplaceController::class, "products"]);

        // Authenticated reseller routes (header-based X-Reseller-Id fallback)
        Route::prefix("proof")->group(function (): void {
            Route::post("upload", [\App\Http\Controllers\Reseller\ResellerProofController::class, "uploadProof"]);
            Route::get("status", [\App\Http\Controllers\Reseller\ResellerProofController::class, "checkStatus"]);
        });
        Route::apiResource("orders", \App\Http\Controllers\Reseller\ResellerOrderController::class)->only(['index', 'store', 'show']);
    });

    Route::prefix("factory")->group(function (): void {
        Route::prefix("auth")->group(function (): void {
            Route::post("login", [
                \App\Http\Controllers\Factory\FactoryAuthController::class,
                "login",
            ]);
            // Dedicated store-keeper login (uses StoreKeeper model + Sanctum)
            Route::post("store-keeper-login", [
                \App\Http\Controllers\Factory\StoreKeeperController::class,
                "login",
            ]);
            // Dedicated driver login (uses Driver model + Sanctum)
            Route::post("drivers/login", [
                \App\Http\Controllers\Factory\DriverController::class,
                "login",
            ]);
            Route::post("logout", [
                \App\Http\Controllers\Factory\FactoryAuthController::class,
                "logout",
            ])->middleware("auth:factory");
            Route::post("refresh", [
                \App\Http\Controllers\Factory\FactoryAuthController::class,
                "refresh",
            ])->middleware("auth:factory");
            Route::get("profile", [
                \App\Http\Controllers\Factory\FactoryAuthController::class,
                "profile",
            ])->middleware("auth:factory");
        });

        Route::middleware("auth:factory")->group(function (): void {
            // Billing routes
            Route::prefix("billing")->group(function (): void {
                Route::get("summary", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "getBillingSummary",
                ]);
                Route::get("invoices", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "getInvoices",
                ]);
                Route::get("invoices/{invoiceId}", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "getInvoice",
                ]);
                Route::get("invoices/{invoiceId}/payments", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "getInvoicePayments",
                ]);
                Route::get("invoices/{invoiceId}/download", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "downloadInvoice",
                ]);
                Route::get("invoices/{invoiceId}/pdf", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "downloadInvoicePdf",
                ]);
                Route::get("invoices/{invoiceId}/downloadable", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "checkInvoiceDownloadable",
                ]);
                Route::post("invoices/{invoiceId}/send-email", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "sendInvoiceEmail",
                ]);
                Route::get("payments", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "getPaymentHistory",
                ]);
                Route::post("payments", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "makePayment",
                ]);
                Route::get("statistics", [
                    \App\Http\Controllers\Factory\FactoryBillingController::class,
                    "getInvoiceStatistics",
                ]);
            });

            Route::prefix("customer-invoices")->group(function (): void {
                Route::get("", [
                    \App\Http\Controllers\Factory\FactoryCustomerInvoicesController::class,
                    "list",
                ]);
                Route::post("generate", [
                    \App\Http\Controllers\Factory\FactoryCustomerInvoicesController::class,
                    "generate",
                ]);
                Route::post("{invoiceId}/send-email", [
                    \App\Http\Controllers\Factory\FactoryCustomerInvoicesController::class,
                    "sendEmail",
                ]);
            });

            Route::get("products/types", [
                \App\Http\Controllers\Factory\ProductController::class,
                "types",
            ]);
            Route::get("products/categories", [
                \App\Http\Controllers\Factory\ProductController::class,
                "categories",
            ]);
            Route::apiResource(
                "products",
                \App\Http\Controllers\Factory\ProductController::class,
            );
            Route::post("products/{product}/link-codes", [
                \App\Http\Controllers\Factory\ProductController::class,
                "linkCodes",
            ]);
            Route::get("products/{product}/codes", [
                \App\Http\Controllers\Factory\ProductController::class,
                "codes",
            ]);
            Route::post("products/{product}/publish-codes", [
                \App\Http\Controllers\Factory\ProductController::class,
                "publishCodes",
            ]);

            // Marketplace toggle
            Route::post("products/{product}/marketplace-toggle", [
                \App\Http\Controllers\Factory\ProductController::class,
                "toggleMarketplace",
            ]);

            // Store Keeper Management
            Route::prefix("store-keepers")->group(function (): void {
                Route::get("list", [\App\Http\Controllers\Factory\StoreKeeperController::class, "index"]);
                Route::post("create", [\App\Http\Controllers\Factory\StoreKeeperController::class, "store"]);
                Route::get("{id}", [\App\Http\Controllers\Factory\StoreKeeperController::class, "show"]);
                Route::put("{id}", [\App\Http\Controllers\Factory\StoreKeeperController::class, "update"]);
                Route::delete("{id}", [\App\Http\Controllers\Factory\StoreKeeperController::class, "destroy"]);
                Route::get("{id}/audit-trail", [\App\Http\Controllers\Factory\StoreKeeperController::class, "auditTrail"]);
            });

            // Driver Management
            Route::prefix("drivers")->group(function (): void {
                Route::get("list", [\App\Http\Controllers\Factory\DriverController::class, "index"]);
                Route::post("create", [\App\Http\Controllers\Factory\DriverController::class, "store"]);
                Route::get("{id}", [\App\Http\Controllers\Factory\DriverController::class, "show"]);
                Route::put("{id}", [\App\Http\Controllers\Factory\DriverController::class, "update"]);
                Route::delete("{id}", [\App\Http\Controllers\Factory\DriverController::class, "destroy"]);
                Route::patch("{id}/status", [\App\Http\Controllers\Factory\DriverController::class, "toggleStatus"]);
                Route::get("{id}/audit-trail", [\App\Http\Controllers\Factory\DriverController::class, "auditTrail"]);
            });

        });

        // Store Keeper Bundle Linking — accessible by BOTH factory admin and store keeper.
        // Uses multi-guard: tries auth:factory first, falls back to auth:store_keeper.
        Route::middleware("auth:factory,store_keeper")->group(function (): void {
            Route::prefix("store-keeper-bundles")->group(function (): void {
                Route::get("test-codes", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "testCodes"]);
                Route::get("pending", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "pendingOrders"]);
                Route::get("history", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "history"]);
                Route::post("create-dummy", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "createDummyOrder"]);
                Route::post("{bundleId}/generate-qr", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "generateBundleQR"]);
                Route::post("{bundleId}/link-carton", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "linkCartonToBundle"]);
                Route::post("{bundleId}/link-packet", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "linkPacketToBundle"]);
                Route::post("{bundleId}/link-unit", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "linkUnitToBundle"]);
                Route::delete("{bundleId}/unlink-carton/{cartonId}", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "unlinkCartonFromBundle"]);
                Route::delete("{bundleId}/unlink-packet/{packetId}", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "unlinkPacketFromBundle"]);
                Route::get("{bundleId}/summary", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "bundleSummary"]);
                Route::put("{bundleId}/linking-status", [\App\Http\Controllers\Factory\StoreKeeperBundleController::class, "updateLinkingStatus"]);
            });
        });
    });

    Route::prefix("codes")
        ->group(function (): void {
            Route::get('exports/{companyId}/{file}', [
                \App\Http\Controllers\Factory\Codes\CodeExportsController::class,
                'download',
            ])->middleware('signed')->name('codes.exports.download');

            Route::middleware("auth:factory")->group(function (): void {
            Route::prefix("unit")->group(function (): void {
                            Route::get("batches", [\App\Http\Controllers\Factory\Codes\UnitCodesController::class, "listBatches"]);
                            Route::post("batch/delete", [\App\Http\Controllers\Factory\Codes\UnitCodesController::class, "deleteBatch"]);
                            Route::post("generate", [\App\Http\Controllers\Factory\Codes\UnitCodesController::class, "generate"]);
                            Route::get("list", [\App\Http\Controllers\Factory\Codes\UnitCodesController::class, "list"]);
                            Route::post("{format}/generate", [\App\Http\Controllers\Factory\Codes\UnitCodesController::class, "generateForFormat"])->where(['format' => 'itf14|gs1_128|code128_industrial|qr|datamatrix|code128_label|auth_code']);
                            Route::get("{format}/list", [\App\Http\Controllers\Factory\Codes\UnitCodesController::class, "listForFormat"])->where(['format' => 'itf14|gs1_128|code128_industrial|qr|datamatrix|code128_label|auth_code']);
                            Route::post("publish", [\App\Http\Controllers\Factory\Codes\UnitCodesController::class, "publish"]);
                            Route::post("download", [\App\Http\Controllers\Factory\Codes\UnitCodesController::class, "download"]);
                                                    });

                                        // ─── Aggregation (Packet ↔ Unit linking) ────────────
                                        Route::prefix("aggregation")->group(function (): void {
                                            Route::post("link-units", [\App\Http\Controllers\Factory\Codes\AggregationController::class, "linkUnitsToPacket"]);
                                            Route::post("unlink-units", [\App\Http\Controllers\Factory\Codes\AggregationController::class, "unlinkUnitsFromPacket"]);
                                            Route::get("available-units", [\App\Http\Controllers\Factory\Codes\AggregationController::class, "availableUnits"]);
                                            Route::get("available-products", [\App\Http\Controllers\Factory\Codes\AggregationController::class, "availableProducts"]);
                Route::get("available-batches", [\App\Http\Controllers\Factory\Codes\AggregationController::class, "availableBatches"]);
                                        });

                                        Route::prefix("packet")->group(function (): void {
                Route::get("batches", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "listBatches",
                ]);
                Route::post("batch/delete", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "deleteBatch",
                ]);
                Route::post("generate", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "generate",
                ]);
                Route::get("list", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "list",
                ]);
                Route::post("{format}/generate", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "generateForFormat",
                ])->where(['format' => 'itf14|gs1_128|code128_industrial|qr|datamatrix|code128_label']);
                Route::get("{format}/list", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "listForFormat",
                ])->where(['format' => 'itf14|gs1_128|code128_industrial|qr|datamatrix|code128_label']);
                Route::put("{id}", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "update",
                ]);
                Route::delete("{id}", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "delete",
                ]);
                Route::post("link", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "link",
                ]);
                Route::post("publish", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "publish",
                ]);
                Route::post("download", [
                    \App\Http\Controllers\Factory\Codes\PacketCodesController::class,
                    "download",
                ]);
            });

            Route::prefix("carton")->group(function (): void {
                Route::get("batches", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "listBatches",
                ]);
                Route::post("batch/delete", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "deleteBatch",
                ]);
                Route::post("generate", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "generate",
                ]);
                Route::get("list", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "list",
                ]);
                Route::post("{format}/generate", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "generateForFormat",
                ])->where(['format' => 'itf14|gs1_128|code128_industrial|qr|datamatrix|code128_label']);
                Route::get("{format}/list", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "listForFormat",
                ])->where(['format' => 'itf14|gs1_128|code128_industrial|qr|datamatrix|code128_label']);
                Route::put("{id}", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "update",
                ]);
                Route::delete("{id}", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "delete",
                ]);
                Route::post("link", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "link",
                ]);
                Route::post("publish", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "publish",
                ]);
                Route::post("download", [
                    \App\Http\Controllers\Factory\Codes\CartonCodesController::class,
                    "download",
                ]);
            });

            Route::prefix("bundle")->group(function (): void {
                Route::post("generate", [
                    \App\Http\Controllers\Factory\Codes\BundleCodesController::class,
                    "generate",
                ]);
                Route::get("list", [
                    \App\Http\Controllers\Factory\Codes\BundleCodesController::class,
                    "list",
                ]);
                Route::put("{id}", [
                    \App\Http\Controllers\Factory\Codes\BundleCodesController::class,
                    "update",
                ]);
                Route::delete("{id}", [
                    \App\Http\Controllers\Factory\Codes\BundleCodesController::class,
                    "delete",
                ]);
                Route::post("link", [
                    \App\Http\Controllers\Factory\Codes\BundleCodesController::class,
                    "link",
                ]);
                Route::post("publish", [
                    \App\Http\Controllers\Factory\Codes\BundleCodesController::class,
                    "publish",
                ]);
                Route::post("download", [
                    \App\Http\Controllers\Factory\Codes\BundleCodesController::class,
                    "download",
                ]);
            });

            // ─── New Bundle System (Order-Level) ──────────────────
            Route::prefix("bundles")->group(function (): void {
                Route::get("list", [\App\Http\Controllers\Factory\BundleController::class, "index"]);
                Route::post("generate", [\App\Http\Controllers\Factory\BundleController::class, "store"]);
                Route::get("{id}", [\App\Http\Controllers\Factory\BundleController::class, "show"]);
                Route::put("{id}", [\App\Http\Controllers\Factory\BundleController::class, "update"]);
                Route::delete("{id}", [\App\Http\Controllers\Factory\BundleController::class, "destroy"]);
                Route::get("{id}/scan", [\App\Http\Controllers\Factory\BundleController::class, "scan"]);
                Route::get("{id}/insights", [\App\Http\Controllers\Factory\Codes\BundleInsightsController::class, "show"]);
            });

            // ─── Smart Codes (OCR-Friendly, Delivery-Level) ───────
            Route::prefix("smart-codes")->group(function (): void {
                Route::get("districts", [\App\Http\Controllers\Factory\SmartCodeController::class, "indexDistricts"]);
                Route::post("districts", [\App\Http\Controllers\Factory\SmartCodeController::class, "storeDistrict"]);
                Route::get("districts/{districtId}/zones", [\App\Http\Controllers\Factory\SmartCodeController::class, "indexZones"]);
                Route::post("districts/{districtId}/zones", [\App\Http\Controllers\Factory\SmartCodeController::class, "storeZone"]);
                Route::get("list", [\App\Http\Controllers\Factory\SmartCodeController::class, "index"]);
                Route::post("generate", [\App\Http\Controllers\Factory\SmartCodeController::class, "store"]);
                Route::get("{id}", [\App\Http\Controllers\Factory\SmartCodeController::class, "show"]);
                Route::post("scan", [\App\Http\Controllers\Factory\SmartCodeController::class, "scan"]);
            });

            });
        });

    Route::prefix("transport")
        ->middleware(["auth:admin", "admin"])
        ->group(function (): void {
            Route::prefix("fraud")->group(function (): void {
                Route::get("stats", [
                    \App\Http\Controllers\Transport\FraudController::class,
                    "stats",
                ]);
            });
        });
};

Route::prefix("v1")->group($registerRoutes);
