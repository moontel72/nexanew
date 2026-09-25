// Nexa Admin — panel providers.
//
// Moved verbatim out of `lib/core/providers/app_providers.dart` (PANEL-SEPARATION-PLAN.md §15b)
// so that `lib/core/` no longer imports `lib/features/`. Behaviour is unchanged: the same
// providers, in the same order.
//
// Callers live in the entry-point layer (`lib/app/app_initializer.dart`, `lib/main_*.dart`), which is
// allowed to import any layer. Compose the lists in this order:
//
//     [...core services, ...NexaAdminProviders.repositoryProviders(), ...FactoryProviders.repositoryProviders()]
//
// Dependencies are resolved with `context.read` while each provider is created, so **list order is
// behavioural, not cosmetic** — do not reorder.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/interfaces/secure_storage_interface.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/nexa_admin/data/datasources/billing_datasource.dart'
    as admin_billing_ds;
import 'package:trace_odd/features/nexa_admin/data/datasources/reseller_management_remote_datasource.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/admin_auth_repository.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/billing_repository.dart'
    as admin_billing_repo;
import 'package:trace_odd/features/nexa_admin/data/repositories/company_management_repository.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/dashboard_repository.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/plan_management_repository.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/reseller_management_repository.dart';
import 'package:trace_odd/features/nexa_admin/domain/usecases/generate_invoice_usecase.dart';
import 'package:trace_odd/features/nexa_admin/domain/usecases/process_payment_usecase.dart';
import 'package:trace_odd/features/nexa_admin/domain/usecases/reconcile_payments_usecase.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/billing/billing_bloc.dart'
    as admin_billing_bloc;
import 'package:trace_odd/features/nexa_admin/presentation/bloc/companies/company_management_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/dashboard/admin_dashboard_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/invoices/invoice_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/layout/super_admin_layout_cubit.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/plans/plan_management_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/reseller_management/reseller_management_bloc.dart';

class NexaAdminProviders {
  NexaAdminProviders._();

  /// Repository providers for the Super Admin / Sub-Admin panels.
  static List<RepositoryProvider> repositoryProviders() {
    return [
      RepositoryProvider<AdminAuthRepository>(
        create: (context) => AdminAuthRepository(
          apiClient: context.read<ApiClient>(),
          secureStorage: context.read<SecureStorageInterface>(),
          sharedPreferences: context.read<SharedPreferences>(),
        ),
      ),
      RepositoryProvider<PlanManagementRepository>(
        create: (context) =>
            PlanManagementRepository(apiClient: context.read<ApiClient>()),
      ),
      RepositoryProvider<CompanyManagementRepository>(
        create: (context) =>
            CompanyManagementRepository(apiService: context.read<ApiService>()),
      ),
      RepositoryProvider<DashboardRepository>(
        create: (context) =>
            DashboardRepository(apiClient: context.read<ApiClient>()),
      ),

      RepositoryProvider<admin_billing_ds.BillingDataSource>(
        create: (context) =>
            admin_billing_ds.BillingDataSourceImpl(context.read<ApiClient>()),
      ),
      RepositoryProvider<admin_billing_repo.BillingRepository>(
        create: (context) => admin_billing_repo.BillingRepositoryImpl(
          context.read<admin_billing_ds.BillingDataSource>(),
        ),
      ),

      RepositoryProvider<ResellerManagementRemoteDatasource>(
        create: (context) => ResellerManagementRemoteDatasource(
          apiService: context.read<ApiService>(),
        ),
      ),
      RepositoryProvider<ResellerManagementRepository>(
        create: (context) => ResellerManagementRepository(
          remote: context.read<ResellerManagementRemoteDatasource>(),
        ),
      ),
    ];
  }

  /// BLoC providers for the Super Admin / Sub-Admin panels.
  static List<BlocProvider> blocProviders() {
    return [
      BlocProvider<AdminAuthBloc>(
        create: (context) =>
            AdminAuthBloc(authRepository: context.read<AdminAuthRepository>()),
      ),
      BlocProvider<PlanManagementBloc>(
        create: (context) => PlanManagementBloc(
          planRepository: context.read<PlanManagementRepository>(),
        ),
      ),
      BlocProvider<CompanyManagementBloc>(
        create: (context) => CompanyManagementBloc(
          repository: context.read<CompanyManagementRepository>(),
        ),
      ),
      BlocProvider<AdminDashboardBloc>(
        create: (context) => AdminDashboardBloc(
          dashboardRepository: context.read<DashboardRepository>(),
        ),
      ),
      BlocProvider<SuperAdminLayoutCubit>(
        create: (context) => SuperAdminLayoutCubit(),
      ),
      BlocProvider<admin_billing_bloc.BillingBloc>(
        create: (context) {
          final repo = context.read<admin_billing_repo.BillingRepository>();
          return admin_billing_bloc.BillingBloc(
            generateInvoiceUseCase: GenerateInvoiceUseCase(repo),
            processPaymentUseCase: ProcessPaymentUseCase(repo),
            reconcilePaymentsUseCase: ReconcilePaymentsUseCase(repo),
            billingRepository: repo,
          );
        },
      ),
      BlocProvider<InvoiceBloc>(
        create: (context) => InvoiceBloc(
          billingRepository: context
              .read<admin_billing_repo.BillingRepository>(),
        ),
      ),
      BlocProvider<ResellerManagementBloc>(
        create: (context) => ResellerManagementBloc(
          repo: context.read<ResellerManagementRepository>(),
        ),
      ),
    ];
  }
}
