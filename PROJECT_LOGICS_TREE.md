# NexaTrace System - Project Logics Tree

> Auto-generated documentation of the project architecture and implementation status.

---

## 1. App Bootstrap Sequence

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           APPLICATION STARTUP                                │
└─────────────────────────────────────────────────────────────────────────────┘

main.dart
    │
    ├── WidgetsFlutterBinding.ensureInitialized()
    ├── ScreenUtil.ensureScreenSize()
    ├── usePathUrlStrategy() (Web only - clean URLs)
    │
    └── NexaTraceApp
            │
            └── AppInitializer
                    │
                    ├── [1] Initialize Dependencies (Async)
                    │       ├── SharedPreferences.getInstance()
                    │       └── SecureStorageInterface (Mock for Web / FlutterSecureStorage for Mobile)
                    │
                    ├── [2] MultiRepositoryProvider
                    │       └── AppProviders.getRepositoryProviders()
                    │               ├── SharedPreferences
                    │               ├── SecureStorageInterface
                    │               ├── ApiClient
                    │               ├── ApiService
                    │               ├── Dio
                    │               ├── AdminAuthRepository
                    │               ├── PlanManagementRepository
                    │               ├── CompanyManagementRepository
                    │               ├── DashboardRepository
                    │               ├── CodesRemoteDatasource
                    │               └── CodesRepository
                    │
                    ├── [3] Auth Warmup Check
                    │       └── AdminAuthRepository.isAuthenticated()
                    │
                    ├── [4] RepositoryProvider<AppRouter>
                    │       └── AppRouter(authRepo: AdminAuthRepository)
                    │
                    ├── [5] MultiBlocProvider
                    │       ├── getGlobalBlocProviders()
                    │       ├── getNexaAdminBlocProviders()
                    │       │       ├── AdminAuthBloc
                    │       │       ├── PlanManagementBloc
                    │       │       ├── CompanyManagementBloc
                    │       │       ├── AdminDashboardBloc
                    │       │       └── SuperAdminLayoutCubit
                    │       └── getFactoryAdminBlocProviders()
                    │               ├── UnitCodesBloc
                    │               ├── PacketCodesBloc
                    │               ├── CartonCodesBloc
                    │               └── BundleCodesBloc
                    │
                    └── [6] MaterialApp.router
                            └── routerConfig: AppRouter.config
```

---

## 2. Directory Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core infrastructure
│   ├── config/
│   │   └── api_config.dart            # API endpoints configuration
│   ├── constants/
│   │   ├── api_endpoints.dart         # API endpoint constants
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── plan_limits.dart           # Subscription plan limits
│   │   └── user_roles.dart            # User role definitions
│   ├── errors/                        # Error handling (4 items)
│   ├── interfaces/
│   │   └── secure_storage_interface.dart
│   ├── models/                        # Core models (empty)
│   ├── providers/
│   │   └── app_providers.dart         # Dependency injection setup
│   ├── repositories/                  # Base repositories
│   ├── services/                      # Core services
│   │   ├── analytics_service.dart
│   │   ├── api_client.dart            # HTTP client wrapper
│   │   ├── api_service.dart           # API service layer
│   │   ├── cache_service.dart
│   │   ├── code_generator_service.dart
│   │   ├── fraud_detection_service.dart
│   │   ├── mock_secure_storage.dart   # Web mock storage
│   │   ├── multi_tenant_service.dart
│   │   ├── payment_service.dart
│   │   ├── secure_storage_service.dart
│   │   ├── subscription_service.dart
│   │   └── subscription_validator.dart
│   ├── usecase/                       # Base use cases
│   ├── utils/
│   │   ├── auth_state.dart            # Global auth state cache
│   │   ├── date_utils.dart
│   │   ├── extensions/
│   │   ├── helpers/
│   │   ├── mixins/
│   │   └── string_utils.dart
│   └── widgets/
│       └── app_initializer.dart       # Async dependency loader
│
├── features/                          # Feature modules
│   ├── nexa_admin/                    # Super Admin & Sub Admin
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   │       ├── admin_auth_repository.dart
│   │   │       ├── company_management_repository.dart
│   │   │       ├── dashboard_repository.dart
│   │   │       ├── plan_management_repository.dart
│   │   │       └── transport_admin_repository.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth/
│   │       │   ├── companies/
│   │       │   ├── dashboard/
│   │       │   ├── layout/
│   │       │   ├── plans/
│   │       │   └── transport_admin/
│   │       ├── screens/
│   │       │   ├── sub_admin/         # (empty)
│   │       │   └── super_admin/
│   │       │       ├── billing/
│   │       │       ├── companies/
│   │       │       ├── plans/
│   │       │       ├── reports/       # (empty)
│   │       │       ├── settings/      # (empty)
│   │       │       ├── subscriptions/ # (empty)
│   │       │       ├── transport/
│   │       │       ├── dashboard_screen.dart
│   │       │       ├── login_screen.dart
│   │       │       └── super_admin_shell.dart
│   │       └── widgets/
│   │
│   ├── factory/                       # Factory module
│   │   ├── admin/                     # Factory Admin Panel
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── providers/         # (empty)
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── codes/
│   │   │       │   ├── dashboard/     # (empty)
│   │   │       │   ├── employees/     # (empty)
│   │   │       │   └── products/      # (empty)
│   │   │       ├── screens/
│   │   │       └── widgets/           # (empty)
│   │   ├── driver/                    # Factory Driver App
│   │   └── store_keeper/              # Store Keeper App
│   │
│   ├── transport/                     # Transport module
│   │   ├── driver/                    # (empty)
│   │   ├── goods_company/
│   │   ├── presentation/
│   │   ├── truck_owner/               # (empty)
│   │   └── wallet/
│   │
│   ├── delivery/                      # Delivery module
│   │   └── presentation/
│   │
│   ├── driver_delivery/               # Driver Delivery module
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── transport_marketplace/         # Transport Marketplace
│   │
│   ├── courier_integration/           # Courier Integration
│   │
│   └── universal/                     # Universal Apps
│       ├── customer/                  # Customer App
│       ├── reseller/                  # Reseller App
│       └── shop/                      # Shop Keeper App
│
├── routes/
│   └── app_router.dart                # GoRouter configuration
│
├── rust_module/                       # Rust FFI module
│   ├── bridge/                        # (empty)
│   ├── src/
│   ├── ffi_config.dart
│   └── rust_module.dart
│
└── shared/                            # Shared resources
    ├── bloc/                          # Shared BLoCs
    ├── models/
    │   ├── base/
    │   ├── code/                      # Code models (18 files)
    │   ├── company/
    │   ├── dashboard/
    │   ├── delivery/
    │   ├── order/
    │   ├── product/
    │   ├── subscription/
    │   ├── transport/
    │   ├── user/
    │   └── wallet/
    ├── theme/
    │   ├── app_decorations.dart
    │   ├── app_theme.dart
    │   ├── colors.dart
    │   └── text_styles.dart
    ├── utils/
    └── widgets/
        ├── app_bars/
        ├── buttons/
        ├── cards/
        ├── dialogs/
        ├── empty_states/
        ├── error_state/
        ├── filters/
        ├── inputs/
        ├── loading/
        ├── navigation/
        ├── scanners/
        └── search/
```

---

## 3. Routing Tree

```
GoRouter Configuration
│
├── /                          # Root → redirects based on auth state
│   └── Redirect: authenticated → /dashboard | !authenticated → /login
│
├── /login                     # Super Admin Login Screen
│   └── SuperAdminLoginScreen
│
└── ShellRoute (SuperAdminShell wrapper)
    │
    ├── /dashboard             # Main dashboard
    │   └── SuperAdminDashboardScreen
    │
    ├── /companies             # Company management
    │   └── CompaniesListScreen
    │       ├── /companies/register
    │       │   └── RegisterCompanyScreen
    │       └── /companies/:id
    │           └── CompanyDetailScreen
    │
    ├── /plans                 # Subscription plans
    │   └── PlansListScreen
    │       └── /plans/create
    │           └── CreatePlanScreen
    │
    ├── /billing/invoices      # Platform invoices
    │   └── PlatformInvoicesScreen
    │
    └── Transport Routes
        ├── /transport/wallet
        │   └── TransportWalletAdminScreen
        ├── /transport/marketplace
        │   └── TransportMarketplaceAdminScreen
        ├── /transport/drivers
        │   └── TransportDriversAdminScreen
        └── /transport/fraud
            └── FraudPreventionAdminScreen
```

### Route Protection

| Route | Auth Required | Redirect |
|-------|---------------|----------|
| `/` | No | Based on auth state |
| `/login` | No | → `/dashboard` if authenticated |
| `/dashboard` | Yes | → `/login` if not authenticated |
| `/companies/*` | Yes | → `/login` if not authenticated |
| `/plans/*` | Yes | → `/login` if not authenticated |
| `/billing/*` | Yes | → `/login` if not authenticated |
| `/transport/*` | Yes | → `/login` if not authenticated |

---

## 4. Provider Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        REPOSITORY PROVIDERS                                  │
└─────────────────────────────────────────────────────────────────────────────┘

SharedPreferences ─────────────────────────────────────────────────────────────┐
SecureStorageInterface ────────────────────────────────────────────────────────┤
                                                                               │
ApiClient ─────────────────────────────────────────────────────────────────────┤
  │                                                                            │
  ├──→ AdminAuthRepository ────────────────────────────────────────────────────┤
  │         │                                                                   │
  │         ├── apiClient: ApiClient                                           │
  │         ├── secureStorage: SecureStorageInterface                          │
  │         └── sharedPreferences: SharedPreferences                           │
  │                                                                            │
  ├──→ PlanManagementRepository ───────────────────────────────────────────────┤
  │         └── apiClient: ApiClient                                           │
  │                                                                            │
  ├──→ CompanyManagementRepository ◄── ApiService ─────────────────────────────┤
  │         └── apiService: ApiService                                         │
  │                                                                            │
  └──→ DashboardRepository ────────────────────────────────────────────────────┤
            └── apiClient: ApiClient                                           │
                                                                               │
ApiService ────────────────────────────────────────────────────────────────────┤
  │                                                                            │
  └──→ CodesRemoteDatasource ──────────────────────────────────────────────────┤
            └── apiService: ApiService                                         │
                  │                                                            │
                  └──→ CodesRepositoryImpl ─────────────────────────────────────┘
                        └── remoteDatasource: CodesRemoteDatasource


┌─────────────────────────────────────────────────────────────────────────────┐
│                           BLoC PROVIDERS                                     │
└─────────────────────────────────────────────────────────────────────────────┘

NexaAdmin BLoCs:
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  AdminAuthRepository ───→ AdminAuthBloc                                      │
│                                                                              │
│  PlanManagementRepository ───→ PlanManagementBloc                            │
│                                                                              │
│  CompanyManagementRepository ───→ CompanyManagementBloc                      │
│                                                                              │
│  DashboardRepository ───→ AdminDashboardBloc                                 │
│                                                                              │
│  (standalone) ───→ SuperAdminLayoutCubit                                     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

FactoryAdmin BLoCs:
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  CodesRepository ───→ UnitCodesBloc                                          │
│                    ───→ PacketCodesBloc                                      │
│                    ───→ CartonCodesBloc                                      │
│                    ───→ BundleCodesBloc                                      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Feature Module Maps

### 5.1 Nexa Admin (Super Admin Panel)

```
nexa_admin/
│
├── data/
│   ├── datasources/
│   ├── models/                    # DTOs
│   └── repositories/
│       ├── admin_auth_repository.dart    ─── Auth API calls
│       ├── company_management_repository.dart ─── Company CRUD
│       ├── dashboard_repository.dart     ─── Dashboard stats
│       ├── plan_management_repository.dart ─── Plan CRUD
│       └── transport_admin_repository.dart
│
├── domain/
│   ├── entities/                  # Domain entities
│   └── usecases/                  # Business logic
│
└── presentation/
    ├── bloc/
    │   ├── auth/                  ─── AdminAuthBloc
    │   ├── companies/             ─── CompanyManagementBloc
    │   ├── dashboard/             ─── AdminDashboardBloc
    │   ├── layout/                ─── SuperAdminLayoutCubit
    │   ├── plans/                 ─── PlanManagementBloc
    │   └── transport_admin/
    │
    ├── screens/
    │   ├── super_admin/
    │   │   ├── dashboard_screen.dart     ─── 1A: Overview & quick actions
    │   │   ├── login_screen.dart         ─── Authentication
    │   │   ├── super_admin_shell.dart    ─── Layout wrapper
    │   │   ├── billing/
    │   │   │   └── platform_invoices_screen.dart ─── 1D: Earnings
    │   │   ├── companies/
    │   │   │   ├── companies_list_screen.dart
    │   │   │   ├── register_company_screen.dart
    │   │   │   └── company_detail_screen.dart ─── 1C: Company management
    │   │   ├── plans/
    │   │   │   ├── plans_list_screen.dart    ─── 1B: Subscription Plans
    │   │   │   └── create_plan_screen.dart
    │   │   ├── audit/                        ─── 1E: Audit Logs ⚠️
    │   │   ├── notifications/                ─── 1F: Notification Engine ⚠️
    │   │   ├── integrations/                 ─── 1G: Integration Hub ⚠️
    │   │   ├── disputes/                     ─── 1H: Dispute Resolution ⚠️
    │   │   ├── limits/                       ─── 1I: Subscription Limit Enforcement ⚠️
    │   │   ├── financial/                    ─── 1J: Financial Reconciliation ⚠️
    │   │   ├── permissions/                  ─── 1K: Sub-Admin Permission Matrix ⚠️
    │   │   ├── backup/                       ─── 1L: Backup & Data Retention ⚠️
    │   │   ├── fraud_dashboard/              ─── 1M: Fraud Detection Dashboard ⚠️
    │   │   ├── rate_limiting/                ─── 1N: Tiered Rate Limiting ⚠️
    │   │   ├── announcements/                ─── 1O: Announcements & Maintenance ⚠️
    │   │   ├── workflows/                    ─── 1P: Custom Workflow Builder ⚠️
    │   │   └── transport/
    │   │       ├── transport_wallet_screen.dart
    │   │       ├── transport_marketplace_admin_screen.dart
    │   │       ├── fraud_prevention_screen.dart
    │   │       └── drivers_admin_screen.dart
    │   │
    │   └── sub_admin/                        ─── Sub-Admin Panel ⚠️
    │       ├── dashboard_screen.dart         ─── 2C: Scoped Dashboard
    │       ├── reports_screen.dart           ─── 2D: Delegated Reports
    │       ├── escalation_screen.dart        ─── 2E: Escalation Workflow
    │       └── roles_screen.dart             ─── 2B: Role Definition
    │
    └── widgets/                   # Feature-specific widgets
```

### 5.2 Factory Admin

```
factory/admin/
│
├── data/
│   ├── datasources/
│   │   └── codes_remote_datasource.dart  ─── API calls for codes
│   └── repositories/
│       ├── codes_repository_impl.dart
│       └── codes_repository.dart (interface)
│
├── domain/
│   └── repositories/
│
└── presentation/
    ├── bloc/
    │   └── codes/
    │       ├── bundle_codes/      ─── 3B-3E: BundleCodesBloc ✅
    │       ├── carton_codes/      ─── 3F: CartonCodesBloc ✅
    │       ├── packet_codes/      ─── 3F: PacketCodesBloc ✅
    │       └── unit_codes/        ─── 3G-3I: UnitCodesBloc ✅
    │
    ├── screens/
    │   ├── codes/                 ─── Code Management
    │   │   ├── bundle_codes_screen.dart
    │   │   ├── carton_codes_screen.dart
    │   │   ├── packet_codes_screen.dart
    │   │   └── unit_codes_screen.dart
    │   │
    │   ├── products/              ─── 3L-3N: Product Management ⚠️
    │   │   ├── products_list_screen.dart
    │   │   ├── create_product_screen.dart
    │   │   └── product_version_history_screen.dart ─── 3W: Versioning
    │   │
    │   ├── drivers/               ─── 3O: Factory Drivers ⚠️
    │   │   ├── drivers_list_screen.dart
    │   │   ├── driver_performance_screen.dart ─── 3AC: Performance Analytics
    │   │   └── driver_detail_screen.dart
    │   │
    │   ├── partners/              ─── 3P-3S: Partners ⚠️
    │   │   ├── resellers_screen.dart
    │   │   ├── shopkeepers_screen.dart
    │   │   ├── commission_agents_screen.dart
    │   │   └── commission_rules_screen.dart ─── 3Y: Commission Engine
    │   │
    │   ├── analytics/             ─── 3T: Anti-Counterfeit Analytics
    │   │   └── counterfeit_alerts_screen.dart
    │   │
    │   ├── imports/               ─── 3U: Batch Import ⚠️
    │   │   └── code_import_screen.dart
    │   │
    │   ├── scheduling/            ─── 3V: Code Gen Scheduling ⚠️
    │   │   └── scheduled_generation_screen.dart
    │   │
    │   ├── audit/                 ─── 3X: Re-Linking Audit ⚠️
    │   │   └── linking_audit_screen.dart
    │   │
    │   ├── inventory/             ─── 3Z: Inventory Sync ⚠️
    │   │   └── depletion_warnings_screen.dart
    │   │
    │   ├── localization/          ─── 3AA: Multi-Language/Currency ⚠️
    │   │   └── product_localization_screen.dart
    │   │
    │   ├── recall/                ─── 3AB: Product Recall ⚠️
    │   │   └── recall_management_screen.dart
    │   │
    │   ├── storekeepers/          ─── 3AD: Shift Management ⚠️
    │   │   ├── shifts_screen.dart
    │   │   └── attendance_report_screen.dart
    │   │
    │   └── billing/               ─── 3AE-3AH: Factory Billing ⚠️
    │       ├── billing_dashboard_screen.dart   ─── 3AE: Owed Balance & Invoices
    │       ├── payment_history_screen.dart     ─── 3AH: Payment Ledger
    │       └── invoice_detail_screen.dart
    │
    └── widgets/
```

**Factory Billing Flow (3AE-3AH):**
```
┌─────────────────────────────────────────────────────────────────────────┐
│                     FACTORY BILLING WORKFLOW                             │
└─────────────────────────────────────────────────────────────────────────┘

Publish Code List ─── Cost Calculation (Tier-based) ─── Invoice Generated
        │                                                         │
        │                                                         ▼
        │                                              ┌──────────────────┐
        │                                              │ Payment Status?  │
        │                                              └──────────────────┘
        │                                                    │
        │                                    ┌───────────────┴───────────────┐
        │                                    │                               │
        │                                    ▼                               ▼
        │                           ┌────────────────┐              ┌────────────────┐
        │                           │     PAID       │              │    UNPAID      │
        │                           └────────────────┘              └────────────────┘
        │                                    │                               │
        │                                    ▼                               ▼
        │                           ┌────────────────┐              ┌────────────────┐
        │                           │ Download PDF   │              │ 🔒 LOCKED      │
        │                           │     ✅         │              │ Show Amount    │
        │                           └────────────────┘              └────────────────┘
        │                                                                    │
        │                                           Wallet/Credit Payment ───┘
        │                                                                    │
        └────────────────────────────────────────────────────────────────────┘
```

**Implemented Backend Endpoints (Billing + Download Lock):**
- `POST /factory/products/{product}/publish-codes` (Unit publish + invoice creation)
- `POST /codes/{bundle|carton|packet}/publish` (Publish + invoice creation)
- `POST /codes/{unit|bundle|carton|packet}/download` (CSV/PDF export; locked if publish invoice unpaid)
- `GET /factory/billing/invoices/{invoiceId}/download` (Generates invoice PDF; paid only)

### 5.3 Factory Store Keeper

```
factory/store_keeper/
├── data/
├── domain/
└── presentation/
    ├── screens/
    │   ├── scanner_screen.dart           ─── 5C-5K: Code Scanning
    │   ├── bundle_link_screen.dart       ─── 5D-5H: Bundle-Carton-Packet linking
    │   ├── inventory_screen.dart         ─── 5L-5M: Section/Rack placement
    │   ├── buyer_push_screen.dart        ─── 5N: Buyer linking & push
    │   ├── alerts_screen.dart            ─── 5O: Work time alerts
    │   ├── communication_screen.dart     ─── 5P: Admin chat/call
    │   ├── low_stock_screen.dart         ─── 5Q: Low Stock Alerts
    │   ├── batch_scan_screen.dart        ─── 5R: Batch Scanning Mode
    │   ├── sync_conflict_screen.dart     ─── 5S: Sync Conflict Resolution ⚠️
    │   ├── physical_count_screen.dart    ─── 5T: Inventory Variance ⚠️
    │   ├── packet_open_audit_screen.dart ─── 5U: Bundle/Packet Opening Audit ⚠️
    │   ├── shift_handover_screen.dart    ─── 5V: Shift Completion & Handover ⚠️
    │   ├── quarantine_screen.dart        ─── 5W: Product Recall Response ⚠️
    │   ├── scanner_calibration_screen.dart ─── 5X: Scanner Calibration ⚠️
    │   ├── notification_confirm_screen.dart ─── 5Y: Notification Delivery ⚠️
    │   ├── inventory_transfer_screen.dart  ─── 5Z: Section Transfer ⚠️
    │   ├── activity_report_screen.dart     ─── 5AA: Audit Trail Report ⚠️
    │   └── hierarchy_map_screen.dart       ─── 5AB: Visual Hierarchy Map ⚠️
    │
    └── widgets/
```

**Visual Hierarchy Map (5AB):**
```
┌─────────────────────────────────────────────────────────────────────────┐
│                     CODE HIERARCHY VISUALIZATION                         │
└─────────────────────────────────────────────────────────────────────────┘

                         ┌─────────────────┐
                         │   BUNDLE CODE   │
                         │   (e.g., B123)  │
                         └────────┬────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
              ▼                   ▼                   ▼
     ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
     │  CARTON CODE 1  │ │  CARTON CODE 2  │ │  CARTON CODE 3  │
     │   (C456)        │ │   (C457)        │ │   (C458)        │
     └────────┬────────┘ └────────┬────────┘ └────────┬────────┘
              │                   │                   │
         ┌────┴────┐         ┌────┴────┐         ┌────┴────┐
         │         │         │         │         │         │
         ▼         ▼         ▼         ▼         ▼         ▼
     ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
     │PACKET │ │PACKET │ │PACKET │ │PACKET │ │PACKET │ │PACKET │
     │ P789  │ │ P790  │ │ P791  │ │ P792  │ │ P793  │ │ P794  │
     └───┬───┘ └───┬───┘ └───┬───┘ └───┬───┘ └───┬───┘ └───┬───┘
         │         │         │         │         │         │
        ...       ...       ...       ...       ...       ...
         │         │         │         │         │         │
     ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
     │ UNIT  │ │ UNIT  │ │ UNIT  │ │ UNIT  │ │ UNIT  │ │ UNIT  │
     │ U001  │ │ U002  │ │ U003  │ │ U004  │ │ U005  │ │ U006  │
     └───────┘ └───────┘ └───────┘ └───────┘ └───────┘ └───────┘
```

### 5.4 Factory Driver

```
factory/driver/
├── data/
├── domain/
└── presentation/
    ├── screens/
    │   ├── scan_receive_screen.dart       ─── 4A: Receive product by scanning
    │   ├── delivery_scan_screen.dart      ─── 4B-4C: Delivery location scan (100m)
    │   ├── location_confirm_screen.dart   ─── 4D: Location confirmation fallback
    │   ├── proof_delivery_screen.dart     ─── 4E: PIN/Photo proof of delivery
    │   ├── map_tracking_screen.dart       ─── 4F: Address tracking via Google Maps
    │   ├── earnings_screen.dart           ─── 4G: Salary/Commission/Bonus/Trip Fee
    │   ├── payment_history_screen.dart    ─── 4H: Payment history & invoices
    │   ├── vehicle_info_screen.dart       ─── 4I: Vehicle plate number
    │   ├── meter_reading_screen.dart      ─── 4J: Vehicle meter reading
    │   ├── fuel_receipt_screen.dart       ─── 4K: Fuel receipt upload
    │   ├── food_receipt_screen.dart       ─── 4L: Food receipt upload
    │   ├── mechanic_receipt_screen.dart   ─── 4M: Mechanic/spare parts receipt
    │   ├── discretion_box_screen.dart     ─── 4O: Discretion/category selection
    │   ├── communication_screen.dart      ─── 4P: Chat/call with admin/client
    │   ├── vehicle_maintenance_screen.dart ─── 4Q: Vehicle maintenance log
    │   ├── digital_signature_screen.dart  ─── 4R: Digital signature in POD
    │   ├── fake_gps_detection_screen.dart ─── 4S: Fake GPS protection
    │   ├── trip_lifecycle_screen.dart     ─── 4T: Trip Status Tracking ⚠️
    │   ├── delivery_window_screen.dart    ─── 4U: Delivery Window Optimization ⚠️
    │   ├── geofencing_screen.dart         ─── 4V: Real-Time Geofencing ⚠️
    │   ├── trip_debrief_screen.dart       ─── 4W: Trip Debrief & Photo Upload ⚠️
    │   ├── chat_archive_screen.dart       ─── 4X: Communication History ⚠️
    │   ├── documents_screen.dart          ─── 4Y: Driver Documents & Compliance ⚠️
    │   ├── offline_mode_screen.dart       ─── 4Z: Offline Mode & Trip Sync ⚠️
    │   ├── performance_incentive_screen.dart ─── 4AA: Performance Incentive Program ⚠️
    │   ├── dispute_notification_screen.dart ─── 4AB: Dispute Notification & Escalation ⚠️
    │   └── fatigue_detection_screen.dart  ─── 4AC: Fatigue Detection & Rest ⚠️
    │
    └── widgets/
```

**Trip Lifecycle States (4T):**
```
┌─────────────────────────────────────────────────────────────────────────┐
│                        TRIP LIFECYCLE FLOW                               │
└─────────────────────────────────────────────────────────────────────────┘

  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
  │ ASSIGNED │ ──▶│ PICKED-UP│ ──▶│IN-TRANSIT│ ──▶│ ARRIVED  │
  └──────────┘    └──────────┘    └──────────┘    └──────────┘
                                                      │
                                                      ▼
  ┌──────────┐    ┌──────────┐                  ┌──────────┐
  │COMPLETED │ ◀──│ DELIVERED│ ◀─────────────────│          │
  └──────────┘    └──────────┘                  └──────────┘

  Note: Backward transitions are PREVENTED
```

### 5.5 Transport Module

```
transport/
├── driver/                        # Truck Driver App (11A-11R) ⚠️
│   ├── data/
│   ├── domain/
│   └── presentation/
│       └── screens/
│           ├── home_screen.dart            ─── 11A-11C: Account & Linking
│           ├── bidding_screen.dart         ─── 11D: Place/Receive Bits
│           ├── ratings_screen.dart         ─── 11E: Driver Ratings
│           ├── earnings_screen.dart        ─── 11F: Earning History
│           ├── tracking_screen.dart        ─── 11G: Location Tracking
│           ├── wallet_screen.dart          ─── 11H: Wallet for fraud prevention
│           ├── night_drive_alert_screen.dart ─── 11I: Night Drive Alert
│           ├── trip_acceptance_screen.dart ─── 11J: Trip Acceptance & Load Details ⚠️
│           ├── pre_trip_checklist_screen.dart ─── 11K: Pre-Trip Checklist ⚠️
│           ├── real_time_earnings_screen.dart ─── 11L: Real-Time Earnings Breakdown ⚠️
│           ├── safe_routes_screen.dart     ─── 11M: Safe Routes & Danger Zones ⚠️
│           ├── emergency_sos_screen.dart   ─── 11N: Emergency SOS ⚠️
│           ├── rest_compliance_screen.dart ─── 11O: Rest & Fatigue Compliance ⚠️
│           ├── tax_estimation_screen.dart  ─── 11P: Income Tax & GST ⚠️
│           ├── certifications_screen.dart  ─── 11Q: Skills & Certification ⚠️
│           └── leaderboard_screen.dart     ─── 11R: Performance Leaderboard ⚠️
│
├── goods_company/                 # Goods Company Panel (9A-9U) ⚠️
│   ├── data/
│   ├── domain/
│   └── presentation/
│       └── screens/
│           ├── dashboard_screen.dart       ─── 9A-9C: Linking & Truck List
│           ├── bidding_screen.dart         ─── 9D-9E: Place/Receive Bits
│           ├── earnings_screen.dart        ─── 9F-9G: Earnings & Commission
│           ├── tracking_screen.dart        ─── 9H-9I: Track Driver/Delivery
│           ├── wallet_screen.dart          ─── 9L: Wallet for fraud prevention
│           ├── route_optimization_screen.dart ─── 9M: Dynamic Route Optimization
│           ├── load_occupancy_screen.dart  ─── 9N: Load Occupancy Tracker
│           ├── dispatch_screen.dart        ─── 9O: Real-Time Dispatch ⚠️
│           ├── dynamic_pricing_screen.dart ─── 9P: Dynamic Pricing ⚠️
│           ├── quality_score_screen.dart   ─── 9Q: Delivery Quality Score ⚠️
│           ├── load_history_screen.dart    ─── 9R: Load History ⚠️
│           ├── profitability_screen.dart   ─── 9S: Profitability Analytics ⚠️
│           ├── external_logistics_screen.dart ─── 9T: External Logistics Integration ⚠️
│           └── compliance_screen.dart      ─── 9U: Compliance & Hazmat ⚠️
│
├── presentation/
├── truck_owner/                   # Truck Owner App (10A-10S) ⚠️
│   ├── data/
│   ├── domain/
│   └── presentation/
│       └── screens/
│           ├── home_screen.dart            ─── 10A-10C: Account & NexaTrace ID
│           ├── linking_screen.dart         ─── 10C: Link with panels/apps
│           ├── bidding_screen.dart         ─── 10D, 10I: Place/Receive Bits
│           ├── ratings_screen.dart         ─── 10E: Owner Ratings
│           ├── earnings_screen.dart        ─── 10F: Earning History
│           ├── fleet_screen.dart           ─── 10G-10H: Fleet & Driver Management
│           ├── tracking_screen.dart        ─── 10J: Truck Tracking
│           ├── wallet_screen.dart          ─── 10K: Wallet for fraud prevention
│           ├── document_alerts_screen.dart ─── 10L: Document Expiry Alerts
│           ├── fleet_health_screen.dart    ─── 10M: Fleet Health Monitoring ⚠️
│           ├── insurance_tracking_screen.dart ─── 10N: Insurance & Compliance ⚠️
│           ├── fuel_efficiency_screen.dart ─── 10O: Fuel Efficiency Analytics ⚠️
│           ├── driver_assignment_screen.dart ─── 10P: Driver-Truck Assignment ⚠️
│           ├── gps_dashboard_screen.dart   ─── 10Q: GPS Tracking Dashboard ⚠️
│           ├── competitive_bidding_screen.dart ─── 10R: Competitive Bidding ⚠️
│           └── vehicle_documents_screen.dart ─── 10S: Vehicle Document Upload ⚠️
│
└── wallet/
    ├── data/
    ├── domain/
    └── presentation/
```

### 5.6 Universal Apps

```
universal/
├── customer/                      # Customer App (8A-8U) ⚠️
│   ├── data/
│   ├── domain/
│   └── presentation/
│       └── screens/
│           ├── authenticity_screen.dart    ─── 8A: Check authenticity
│           ├── linking_screen.dart         ─── 8B: Link with panels/apps
│           ├── tracking_screen.dart        ─── 8C: Track parcels/deliveries
│           ├── history_screen.dart         ─── 8D: Previous records
│           ├── wallet_screen.dart          ─── 8E: Main wallet
│           ├── rewards_screen.dart         ─── 8F: Discounts, vouchers, points
│           ├── company_wallets_screen.dart ─── 8G-8H: Company subsidiary wallets
│           ├── warranty_screen.dart        ─── 8I: Warranty activation on scan
│           ├── contact_screen.dart         ─── 8J: Contact shopkeeper/company
│           ├── warranty_claim_screen.dart  ─── 8K: Claim Warranty button
│           ├── product_registration_screen.dart ─── 8L: Product Registration
│           ├── price_comparison_screen.dart ─── 8M: Price Comparison
│           ├── counterfeit_report_screen.dart ─── 8N: Counterfeit Report & Escalation ⚠️
│           ├── warranty_evidence_screen.dart ─── 8O: Warranty Claim Evidence ⚠️
│           ├── product_review_screen.dart  ─── 8P: Product Review & Rating ⚠️
│           ├── expiry_alert_screen.dart    ─── 8Q: Expiry Date Alert & Reminder ⚠️
│           ├── supply_chain_screen.dart    ─── 8R: Supply Chain Transparency ⚠️
│           ├── nearby_stores_screen.dart   ─── 8S: Retailer Comparison & Locator ⚠️
│           ├── rebate_screen.dart          ─── 8T: Subscription-Based Rebate ⚠️
│           └── watchlist_screen.dart       ─── 8U: Saved Products & Watchlist ⚠️
│
├── reseller/                      # Reseller/Wholesaler App (6A-6S) ⚠️
│   ├── data/
│   ├── domain/
│   └── presentation/
│       └── screens/
│           ├── dashboard_screen.dart       ─── 6A: Multiple shops control
│           ├── linking_screen.dart         ─── 6B: Link with panels/apps
│           ├── marketplace_screen.dart     ─── 6C: Buy from factory/sell products
│           ├── bidding_screen.dart         ─── 6D-6E: Place/Receive Bits
│           ├── delivery_tracking_screen.dart ─── 6E: Track deliveries
│           ├── driver_management_screen.dart ─── 6G-6H: Create/List drivers
│           ├── receive_products_screen.dart ─── 6I: Receive products by scanning
│           ├── income_screen.dart          ─── 6J: Income from goods
│           ├── wallet_screen.dart          ─── 6M: Wallet for fraud prevention
│           ├── bulk_order_screen.dart      ─── 6N: Bulk Order Requests
│           ├── shop_performance_screen.dart ─── 6O: Shop Performance Dashboard ⚠️
│           ├── tiered_pricing_screen.dart  ─── 6P: Tiered Pricing by Buyer ⚠️
│           ├── inventory_aggregation_screen.dart ─── 6Q: Inventory Aggregation ⚠️
│           ├── returns_screen.dart         ─── 6R: Returns & Refund Workflow ⚠️
│           └── employee_roles_screen.dart  ─── 6S: Employee Role Management ⚠️
│
└── shop/                          # Shop Keeper App (7A-7R) ⚠️
    ├── data/
    ├── domain/
    └── presentation/
        └── screens/
            ├── dashboard_screen.dart       ─── 7A-7B: Link & marketplace
            ├── bidding_screen.dart         ─── 7C-7D: Place/Receive Bits
            ├── delivery_tracking_screen.dart ─── 7D: Track deliveries
            ├── driver_management_screen.dart ─── 7F-7G: Create/List drivers
            ├── receive_products_screen.dart ─── 7H: Receive products by scanning
            ├── open_packets_screen.dart    ─── 7I: Open Packets declaration
            ├── wallet_screen.dart          ─── 7L: Wallet for fraud prevention
            ├── inventory_update_screen.dart ─── 7M: Inventory Auto-Update
            ├── loyalty_program_screen.dart ─── 7N: Customer Loyalty Program ⚠️
            ├── promotions_screen.dart      ─── 7O: Promotion & Discount Campaign ⚠️
            ├── recommendations_screen.dart ─── 7P: Product Recommendations ⚠️
            ├── supplier_orders_screen.dart ─── 7Q: Supplier Order Management ⚠️
            └── qr_promo_screen.dart        ─── 7R: QR Code Labeling for Promos ⚠️
```

---

## 6. Shared Resources

### 6.1 Shared Models

| Category | Purpose |
|----------|---------|
| `base/` | Base model classes |
| `code/` | Bundle, Carton, Packet, Unit code models (18 files) |
| `company/` | Company-related models |
| `dashboard/` | Dashboard data models |
| `delivery/` | Delivery models |
| `order/` | Order models |
| `product/` | Product models |
| `subscription/` | Plan & subscription models |
| `transport/` | Transport-related models |
| `user/` | User models |
| `wallet/` | Wallet & transaction models |

### 6.2 Shared Widgets

| Category | Widgets |
|----------|---------|
| `app_bars/` | Custom app bars |
| `buttons/` | Reusable buttons |
| `cards/` | Card components |
| `dialogs/` | Dialog widgets |
| `empty_states/` | Empty state placeholders |
| `error_state/` | Error display widgets |
| `filters/` | Filter components |
| `inputs/` | Input fields |
| `loading/` | Loading indicators |
| `navigation/` | Navigation widgets |
| `scanners/` | QR/Barcode scanners |
| `search/` | Search components |

### 6.3 Theme System

| File | Purpose |
|------|---------|
| `app_theme.dart` | Light/Dark theme definitions |
| `colors.dart` | Color palette |
| `text_styles.dart` | Typography styles |
| `app_decorations.dart` | Decorations & borders |

### 6.4 Core Services

| Service | Purpose |
|---------|---------|
| `api_client.dart` | Dio-based HTTP client with interceptors |
| `api_service.dart` | High-level API service |
| `secure_storage_service.dart` | Secure token storage |
| `mock_secure_storage.dart` | Web-compatible in-memory storage |
| `code_generator_service.dart` | Unique code generation |
| `fraud_detection_service.dart` | Anti-counterfeit detection |
| `subscription_validator.dart` | Plan limit enforcement |
| `payment_service.dart` | Payment processing |
| `multi_tenant_service.dart` | Multi-company support |
| `analytics_service.dart` | Analytics tracking |
| `cache_service.dart` | Local caching |

---

## 7. Implementation Status

### README Module Implementation Matrix

| Module | Section | Status | Notes |
|--------|---------|--------|-------|
| **1. Super Admin Panel** | | | |
| Dashboard | 1A | ✅ Implemented | `dashboard_screen.dart` |
| Subscription Plans | 1B | ✅ Implemented | `plans_list_screen.dart`, `create_plan_screen.dart` |
| Companies | 1C | ✅ Implemented | CRUD with list, register, detail |
| Earnings | 1D | ⚠️ Partial | Framework exists |
| Audit Logs | 1E | ⚠️ Planned | Directory structure ready |
| Notification Engine | 1F | ⚠️ Planned | |
| Integration Hub | 1G | ⚠️ Planned | |
| Dispute Resolution | 1H | ⚠️ Planned | |
| Subscription Limit Enforcement | 1I | ⚠️ Planned | Overage management |
| Financial Reconciliation | 1J | ⚠️ Planned | Revenue reporting |
| Sub-Admin Permission Matrix | 1K | ⚠️ Planned | Delegation system |
| Backup & Data Retention | 1L | ⚠️ Planned | GDPR export |
| Fraud Detection Dashboard | 1M | ⚠️ Planned | Real-time monitoring |
| Tiered Rate Limiting | 1N | ⚠️ Planned | API quota management |
| Announcements & Maintenance | 1O | ⚠️ Planned | Platform announcements |
| Custom Workflow Builder | 1P | ⚠️ Planned | Conditional workflows |
| **2. Sub Admin Panel** | | ⚠️ Planned | |
| Role Definition | 2B | ⚠️ Planned | Role types: Factory/Finance/Transport/Support |
| Scoped Dashboard | 2C | ⚠️ Planned | Permission-based metrics |
| Report Generator | 2D | ⚠️ Planned | Delegated reports |
| Escalation Workflow | 2E | ⚠️ Planned | Handoff to Super Admin |
| **3. Factory Panel** | | | |
| Bundle Codes | 3B-3E | ✅ Implemented | Bloc exists |
| Carton Codes | 3F | ✅ Implemented | Bloc exists |
| Packet Codes | 3F | ✅ Implemented | Bloc exists |
| Unit Codes | 3G-3I | ✅ Implemented | Bloc exists |
| Product Management | 3L-3N | ⚠️ Planned | Products + Food/Medical/Electronics |
| Factory Drivers | 3O | ⚠️ Planned | |
| Shopkeeper/Reseller Link | 3P-3S | ⚠️ Planned | |
| Anti-Counterfeit Analytics | 3T | ⚠️ Partial | Service exists |
| Batch Code Import | 3U | ⚠️ Planned | CSV import |
| Code Gen Scheduling | 3V | ⚠️ Planned | Off-peak scheduling |
| Product Versioning | 3W | ⚠️ Planned | Change history |
| Re-Linking Audit Trail | 3X | ⚠️ Planned | Storekeeper/Reseller tracking |
| Commission Rule Engine | 3Y | ⚠️ Planned | Tiered commissions |
| Inventory Sync | 3Z | ⚠️ Planned | Depletion warnings |
| Multi-Language/Currency | 3AA | ⚠️ Planned | Product localization |
| Product Recall | 3AB | ⚠️ Planned | Batch recall management |
| Driver Performance | 3AC | ⚠️ Planned | Analytics per driver |
| Storekeeper Shift Mgmt | 3AD | ⚠️ Planned | Attendance tracking |
| Factory Billing Dashboard | 3AE | ✅ Implemented | Owed balance + invoices + usage summary |
| Pay-per-Publish Billing | 3AF | ✅ Implemented | Invoice auto-created on publish (Unit/Packet/Carton/Bundle) |
| Download Lock | 3AG | ✅ Implemented | Codes CSV/PDF download blocked until publish invoice is paid |
| Payment History Ledger | 3AH | ✅ Implemented | Payment history + invoice PDF download |
| **4. Driver App** | | ⚠️ Planned | Structure exists |
| Trip Lifecycle Tracking | 4T | ⚠️ Planned | State machine |
| Delivery Window Optimization | 4U | ⚠️ Planned | Time windows |
| Real-Time Geofencing | 4V | ⚠️ Planned | GPS + cell tower + WiFi |
| Trip Debrief | 4W | ⚠️ Planned | Photo upload |
| Communication History | 4X | ⚠️ Planned | Chat archival |
| Documents Compliance | 4Y | ⚠️ Planned | License/insurance tracking |
| Offline Mode | 4Z | ⚠️ Planned | Local sync |
| Performance Incentive | 4AA | ⚠️ Planned | Bronze/Silver/Gold tiers |
| Dispute Notification | 4AB | ⚠️ Planned | Escalation workflow |
| Fatigue Detection | 4AC | ⚠️ Planned | Rest periods |
| **5. Store Keeper App** | | ⚠️ Planned | Structure exists |
| Sync Conflict Resolution | 5S | ⚠️ Planned | Conflict detection |
| Inventory Variance | 5T | ⚠️ Planned | Physical count |
| Bundle/Packet Opening Audit | 5U | ⚠️ Planned | Opened state tracking |
| Shift Handover | 5V | ⚠️ Planned | End-of-shift summary |
| Product Recall Response | 5W | ⚠️ Planned | Quarantine |
| Scanner Calibration | 5X | ⚠️ Planned | Quality check |
| Notification Delivery | 5Y | ⚠️ Planned | Confirmation |
| Inventory Transfer | 5Z | ⚠️ Planned | Section moves |
| Audit Trail Report | 5AA | ⚠️ Planned | Daily report |
| Visual Hierarchy Map | 5AB | ⚠️ Planned | Tree view |
| **6. Reseller App** | | ⚠️ Planned | Structure exists |
| Shop Performance Dashboard | 6O | ⚠️ Planned | Per-shop metrics |
| Tiered Pricing | 6P | ⚠️ Planned | By buyer type |
| Inventory Aggregation | 6Q | ⚠️ Planned | Cross-shop inventory |
| Returns & Refund | 6R | ⚠️ Planned | Return workflow |
| Employee Role Management | 6S | ⚠️ Planned | Per-shop roles |
| **7. Shop Keeper App** | | ⚠️ Planned | Structure exists |
| Customer Loyalty Program | 7N | ⚠️ Planned | Points system |
| Promotion Campaign | 7O | ⚠️ Planned | Time-limited promos |
| Product Recommendations | 7P | ⚠️ Planned | Analytics-driven |
| Supplier Order Management | 7Q | ⚠️ Planned | Reorder system |
| QR Code Labeling | 7R | ⚠️ Planned | In-store promos |
| **8. Customer App** | | ⚠️ Planned | Structure exists |
| Counterfeit Report | 8N | ⚠️ Planned | Photo + location |
| Warranty Claim Evidence | 8O | ⚠️ Planned | Photo workflow |
| Product Review & Rating | 8P | ⚠️ Planned | 1-5 stars |
| Expiry Date Alert | 8Q | ⚠️ Planned | Reminders |
| Supply Chain Transparency | 8R | ⚠️ Planned | Full traceability |
| Nearby Store Locator | 8S | ⚠️ Planned | Price comparison |
| Subscription Rebate | 8T | ⚠️ Planned | Auto-rebate codes |
| Saved Products Watchlist | 8U | ⚠️ Planned | Favorites |
| **9. Goods Company Panel** | | ⚠️ Partial | Structure exists |
| Real-Time Dispatch | 9O | ⚠️ Planned | Drag-drop assignment |
| Dynamic Pricing | 9P | ⚠️ Planned | Surge pricing |
| Delivery Quality Score | 9Q | ⚠️ Planned | Penalty system |
| Load History | 9R | ⚠️ Planned | Repeat customer pricing |
| Profitability Analytics | 9S | ⚠️ Planned | Per-truck profit |
| External Logistics Integration | 9T | ⚠️ Planned | Partner API |
| Compliance & Hazmat | 9U | ⚠️ Planned | Certification checks |
| **10. Truck Owner App** | | ⚠️ Planned | |
| Fleet Health Monitoring | 10M | ⚠️ Planned | Maintenance scheduling |
| Insurance & Compliance | 10N | ⚠️ Planned | Document tracking |
| Fuel Efficiency | 10O | ⚠️ Planned | Mileage analytics |
| Driver-Truck Assignment | 10P | ⚠️ Planned | Calendar view |
| GPS Tracking Dashboard | 10Q | ⚠️ Planned | Real-time fleet map |
| Competitive Bidding | 10R | ⚠️ Planned | Multi-platform loads |
| Vehicle Documents | 10S | ⚠️ Planned | Document upload |
| **11. Truck Driver App** | | ⚠️ Planned | |
| Trip Acceptance | 11J | ⚠️ Planned | Load details |
| Pre-Trip Checklist | 11K | ⚠️ Planned | Vehicle inspection |
| Real-Time Earnings | 11L | ⚠️ Planned | Per-trip breakdown |
| Safe Routes | 11M | ⚠️ Planned | Danger zone alerts |
| Emergency SOS | 11N | ⚠️ Planned | Breakdown assistance |
| Rest & Fatigue Compliance | 11O | ⚠️ Planned | Break enforcement |
| Income Tax & GST | 11P | ⚠️ Planned | Tax estimation |
| Skills & Certification | 11Q | ⚠️ Planned | CDL/hazmat tracking |
| Performance Leaderboard | 11R | ⚠️ Planned | Public rankings |
| **12. Cross-Cutting Concerns** | | | |
| Payment & Wallet | 12A | ⚠️ Planned | Critical priority |
| Authentication & Multi-Tenancy | 12B | ⚠️ Planned | Critical priority |
| Escrow & Dispute Resolution | 12C | ⚠️ Planned | Critical priority |
| Audit & Compliance Logging | 12D | ⚠️ Planned | Critical priority |
| Data Validation | 12E | ⚠️ Planned | High priority |
| Offline Sync | 12F | ⚠️ Planned | High priority |
| Scalability | 12G | ⚠️ Planned | High priority |
| Security & Encryption | 12H | ⚠️ Planned | High priority |
| Data Retention & GDPR | 12I | ⚠️ Planned | High priority |
| Fraud & Anti-Counterfeiting | 12J | ⚠️ Planned | High priority |
| Notification Architecture | 12K | ⚠️ Planned | High priority |
| Analytics & Reporting | 12L | ⚠️ Planned | High priority |
| Batch Operations | 12M | ⚠️ Planned | High priority |
| Mobile Network Resilience | 12N | ⚠️ Planned | High priority |
| Regulatory Compliance | 12O | ⚠️ Planned | Medium priority |

### Legend
- ✅ **Implemented** - Core functionality working
- ⚠️ **Planned/Partial** - Structure/framework exists or planned
- ❌ **Not Started** - Directory empty or not created

---

## 8. API Endpoints

### Base Configuration
```
Base URL: http://135.181.46.27
API Base: http://135.181.46.27/api/v1
Timeouts: 30s (connect, receive, send)
Max Retries: 3
```

### Endpoint Groups

#### Authentication (`AuthEndpoints`)
| Endpoint | Path |
|----------|------|
| Login | `/api/v1/auth/login` |
| Register | `/api/v1/auth/register` |
| Logout | `/api/v1/auth/logout` |
| Refresh Token | `/api/v1/auth/refresh` |
| Forgot Password | `/api/v1/auth/forgot-password` |
| Reset Password | `/api/v1/auth/reset-password` |
| Verify Email | `/api/v1/auth/verify-email` |
| Profile | `/api/v1/auth/profile` |
| Change Password | `/api/v1/auth/change-password` |

#### Companies (`CompanyEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/companies` |
| List | `/api/v1/companies/list` |
| Create | `/api/v1/companies/create` |
| Update | `/api/v1/companies/update` |
| Delete | `/api/v1/companies/delete` |
| Details | `/api/v1/companies/details` |
| Statistics | `/api/v1/companies/statistics` |
| Subscription | `/api/v1/companies/subscription` |
| Users | `/api/v1/companies/users` |

#### Codes (`CodeEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/codes` |
| Bundles | `/api/v1/codes/bundles` |
| Generate | `/api/v1/codes/generate` |
| Validate | `/api/v1/codes/validate` |
| Track | `/api/v1/codes/track` |
| Statistics | `/api/v1/codes/statistics` |
| Export | `/api/v1/codes/export` |
| Import | `/api/v1/codes/import` |
| Bundle Codes | `/api/v1/codes/bundles` |
| Carton Codes | `/api/v1/codes/cartons` |
| Packet Codes | `/api/v1/codes/packets` |
| Unit Codes | `/api/v1/codes/units` |

#### Plans (`PlanEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/plans` |
| List | `/api/v1/plans/list` |
| Create | `/api/v1/plans/create` |
| Update | `/api/v1/plans/update` |
| Delete | `/api/v1/plans/delete` |
| Details | `/api/v1/plans/details` |
| Features | `/api/v1/plans/features` |
| Pricing | `/api/v1/plans/pricing` |

#### Subscriptions (`SubscriptionEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/subscriptions` |
| List, Create, Update, Cancel, Renew, History, Invoices |

#### Users (`UserEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/users` |
| List, Create, Update, Delete, Profile, Roles, Permissions |

#### Factories (`FactoryEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/factories` |
| Context | `/api/v1/factories/context` |
| Switch Context | `/api/v1/factories/switch-context` |
| Accessible | `/api/v1/factories/accessible` |
| Employees | `/api/v1/factories/employees` |
| Products | `/api/v1/factories/products` |
| Store Keepers | `/api/v1/factories/store-keepers` |
| Drivers | `/api/v1/factories/drivers` |

#### Deliveries (`DeliveryEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/deliveries` |
| List, Create, Update, Track, Scan, Verify, Reports |

#### Admin (`AdminEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/admin` |
| Dashboard, Companies, Plans, Subscriptions, Users, Reports, Settings, Audit Logs |

#### Notifications (`NotificationEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/notifications` |
| List, Mark Read, Mark All Read, Delete, Settings |

#### Reports (`ReportEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/reports` |
| Usage, Revenue, Codes, Deliveries, Factories, Export |

#### Analytics (`AnalyticsEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/analytics` |
| Overview, Realtime, Trends, Predictions |

#### Files (`FileEndpoints`)
| Endpoint | Path |
|----------|------|
| Base | `/api/v1/files` |
| Upload, Download, Delete, List |

---

## 9. Cross-Cutting Architectural Concerns

### 9.1 Critical Priority

| ID | Concern | Description | Status |
|----|---------|-------------|--------|
| 12A | Payment & Wallet Architecture | Wallet state machine (Pending → Settled → Cleared), double-entry bookkeeping, PCI-DSS compliance, multi-gateway support, 2FA for amounts > ₹10K | ⚠️ Planned |
| 12B | Authentication & Multi-Tenancy | Row-Level Security, AES-256 encryption, JWT rotation (8 hrs), device fingerprinting, rate limiting on login | ⚠️ Planned |
| 12C | Escrow & Dispute Resolution | Escrow lifecycle: On-Hold → Buyer-Confirms → Release/Dispute, 3-way verification, mediation for > ₹50K | ⚠️ Planned |
| 12D | Audit & Compliance Logging | Immutable append-only log, 7-year retention, monthly signed exports, SIEM integration | ⚠️ Planned |

### 9.2 High Priority

| ID | Concern | Description | Status |
|----|---------|-------------|--------|
| 12E | Data Validation & Consistency | Frontend/backend validation, DB constraints, integration tests, checksums on critical data | ⚠️ Planned |
| 12F | Offline Sync & Conflict Resolution | Last-write-wins, server timestamp truth, CRDTs for non-losable ops, soft-delete | ⚠️ Planned |
| 12G | Scalability & Performance | Cursor pagination, Redis caching, DB indexes, async job queue, CDN, rate limiting | ⚠️ Planned |
| 12H | Security & Encryption | TLS 1.3+, SSL pinning in Flutter, API key rotation (90 days), Vault secrets, bcrypt (12 rounds) | ⚠️ Planned |
| 12I | Data Retention & GDPR | Retention policy per type, GDPR export (ZIP/JSON), right to delete, cookie consent | ⚠️ Planned |
| 12J | Fraud & Anti-Counterfeiting | ML fraud detection (score 0-100), behavioral biometrics, whistleblower rewards | ⚠️ Planned |
| 12K | Notification Architecture | Multi-channel (in-app, email, SMS, push, WhatsApp), opt-out preferences, retry backoff | ⚠️ Planned |
| 12L | Analytics & Reporting | BI tool integration (Metabase/Superset), scheduled reports, predictive analytics | ⚠️ Planned |
| 12M | Batch Operations & Async Processing | Chunked processing (1000-item), progress tracking, idempotency, webhooks | ⚠️ Planned |
| 12N | Mobile Network Resilience | Binary protocol (protobuf), Service Worker offline, exponential backoff, selective sync | ⚠️ Planned |

### 9.3 Medium Priority

| ID | Concern | Description | Status |
|----|---------|-------------|--------|
| 12O | Regulatory Compliance by Region | India: GST/FSSAI, EU: GDPR/ePrivacy, Medical: HIPAA/FDA, region-based feature toggles | ⚠️ Planned |

---

## 10. Key Workflow Diagrams

### 10.1 Factory Billing Flow (3AE-3AH)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     FACTORY BILLING WORKFLOW                             │
└─────────────────────────────────────────────────────────────────────────┘

   ┌────────────────┐     ┌────────────────┐     ┌────────────────┐
   │  PUBLISH CODE  │────▶│  COST CALC     │────▶│ INVOICE GEN    │
   │     LIST       │     │ (Tier-based)   │     │                │
   └────────────────┘     └────────────────┘     └───────┬────────┘
                                                          │
                                           ┌──────────────┴──────────────┐
                                           │                             │
                                           ▼                             ▼
                                  ┌────────────────┐            ┌────────────────┐
                                  │    PAID        │            │   UNPAID       │
                                  │  (via Wallet   │            │                │
                                  │   or Credit)   │            └───────┬────────┘
                                  └───────┬────────┘                    │
                                          │                             │
                                          ▼                             ▼
                                  ┌────────────────┐            ┌────────────────┐
                                  │  DOWNLOAD PDF  │            │ 🔒 LOCKED      │
                                  │      ✅        │            │ Show Amount    │
                                  └────────────────┘            └────────────────┘
                                                                        │
                                                           ┌────────────┘
                                                           │
                                                           ▼
                                                  ┌────────────────┐
                                                  │ Payment Method │
                                                  │ Selection      │
                                                  │ (Wallet/Credit)│
                                                  └────────┬───────┘
                                                           │
                                                           ▼
                                                  ┌────────────────┐
                                                  │ Payment Clear  │
                                                  │ → Unlock PDF   │
                                                  └────────────────┘
```

### 10.2 Product Recall Flow (3AB)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     PRODUCT RECALL WORKFLOW                              │
└─────────────────────────────────────────────────────────────────────────┘

   ┌────────────────┐     ┌────────────────┐     ┌────────────────┐
   │ FACTORY MARKS  │────▶│  SYSTEM AUTO   │────▶│  ALL LINKED    │
   │ BATCH RECALLED │     │  NOTIFIES      │     │  PARTIES       │
   └────────────────┘     └────────────────┘     └───────┬────────┘
                                  │                       │
                                  │                       ▼
                                  │              ┌────────┴────────┐
                                  │              │                 │
                                  │              ▼                 ▼
                                  │     ┌────────────────┐ ┌────────────────┐
                                  │     │  Storekeepers  │ │   Customers    │
                                  │     │  (Quarantine)  │ │   (Alert)      │
                                  │     └────────────────┘ └────────────────┘
                                  │              │
                                  │              ▼
                                  │     ┌────────────────┐
                                  │     │  Drivers       │
                                  │     │  (Stop Deliv.) │
                                  │     └────────────────┘
                                  │
                                  ▼
                         ┌────────────────┐
                         │ PREVENT FURTHER│
                         │ SCANNING OF    │
                         │ RECALLED BATCH │
                         └────────────────┘
```

### 10.3 Escrow Flow (12C)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        ESCROW WORKFLOW                                   │
└─────────────────────────────────────────────────────────────────────────┘

   ┌────────────────┐     ┌────────────────┐     ┌────────────────┐
   │  BIT PLACED    │────▶│  ESCROW ON     │────▶│  DRIVER        │
   │  (Transaction) │     │  HOLD          │     │  DELIVERS      │
   └────────────────┘     └────────────────┘     └───────┬────────┘
                                                          │
                                           ┌──────────────┴──────────────┐
                                           │                             │
                                           ▼                             ▼
                                  ┌────────────────┐            ┌────────────────┐
                                  │ BUYER SCANS    │            │ BUYER DOES NOT │
                                  │ (Receipt Conf) │            │ SCAN (24 hrs)  │
                                  └───────┬────────┘            └───────┬────────┘
                                          │                             │
                                          ▼                             ▼
                                  ┌────────────────┐            ┌────────────────┐
                                  │ SELLER FUNDS   │            │ AUTO-RELEASE   │
                                  │ RELEASED ✅    │            │ (7-day grace)  │
                                  └────────────────┘            └───────┬────────┘
                                                                        │
                                           ┌────────────────────────────┘
                                           │
                                           ▼
                                  ┌────────────────┐
                                  │ DISPUTE FILED  │
                                  │ (within 7 days)│
                                  └───────┬────────┘
                                          │
                           ┌──────────────┴──────────────┐
                           │                             │
                           ▼                             ▼
                  ┌────────────────┐            ┌────────────────┐
                  │ VALUE < ₹50K   │            │ VALUE > ₹50K   │
                  │ Auto-Resolve   │            │ Mediation      │
                  └────────────────┘            └────────────────┘
```

---

## Quick Reference

### Key Files
| Purpose | File |
|---------|------|
| App Entry | `lib/main.dart` |
| Dependency Setup | `lib/core/providers/app_providers.dart` |
| Routing | `lib/routes/app_router.dart` |
| API Config | `lib/core/config/api_config.dart` |
| Theme | `lib/shared/theme/app_theme.dart` |
| Auth State | `lib/core/utils/auth_state.dart` |

### Tech Stack
- **Frontend**: Flutter (Web, Android, iOS)
- **State Management**: Flutter BLoC
- **Routing**: GoRouter
- **HTTP Client**: Dio
- **Storage**: SharedPreferences + FlutterSecureStorage
- **Backend**: Laravel API
- **Database**: PostgreSQL

---

*Last Updated: April 2026*
