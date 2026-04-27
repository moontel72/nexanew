// App Providers for NexaTrace System
// This file provides dependency injection using Flutter BLoC's RepositoryProvider

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart' as api;
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/factory/admin/data/repositories/factory_auth_repository.dart';
import 'package:nexatrace_system/features/factory/admin/data/repositories/factory_products_repository.dart';
import 'package:nexatrace_system/features/factory/admin/data/datasources/codes_remote_datasource.dart';
import 'package:nexatrace_system/features/factory/admin/data/repositories/codes_repository_impl.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/codes_repository.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/auth/factory_auth_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_codes_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/carton_codes/carton_codes_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/packet_codes/packet_codes_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/unit_codes/unit_codes_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/company_management_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/admin_auth_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/dashboard_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/plan_management_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/companies/company_management_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/dashboard/admin_dashboard_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/layout/super_admin_layout_cubit.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/plans/plan_management_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/invoices/invoice_bloc.dart';
import 'package:nexatrace_system/core/interfaces/secure_storage_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Billing imports
import 'package:nexatrace_system/features/factory/admin/data/repositories/billing_repository_impl.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/billing_repository.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/billing/billing_bloc.dart';

import 'package:nexatrace_system/features/nexa_admin/data/datasources/billing_datasource.dart'
    as admin_billing_ds;
import 'package:nexatrace_system/features/nexa_admin/data/repositories/billing_repository.dart'
    as admin_billing_repo;
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/billing/billing_bloc.dart'
    as admin_billing_bloc;
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/generate_invoice_usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/process_payment_usecase.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/usecases/reconcile_payments_usecase.dart';

class AppProviders {
  /// Get all repository providers for the root of the app
  static List<RepositoryProvider> getRepositoryProviders({
    required SharedPreferences sharedPreferences,
    required SecureStorageInterface secureStorage,
  }) {
    return [
      // Core Services
      RepositoryProvider<SharedPreferences>.value(value: sharedPreferences),
      RepositoryProvider<SecureStorageInterface>.value(value: secureStorage),
      RepositoryProvider<ApiClient>(create: (context) => ApiClient()),
      RepositoryProvider<ApiService>(create: (context) => ApiService()),

      // Dio instance for services that need it
      RepositoryProvider<Dio>(
        create: (context) => Dio(
          BaseOptions(
            baseUrl: api.ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ),
      ),

      // Nexa Admin Repositories
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

      // Factory Admin Repositories
      RepositoryProvider<FactoryAuthRepository>(
        create: (context) => FactoryAuthRepository(
          apiClient: context.read<ApiClient>(),
          sharedPreferences: context.read<SharedPreferences>(),
        ),
      ),
      RepositoryProvider<FactoryProductsRepository>(
        create: (context) =>
            FactoryProductsRepository(apiService: context.read<ApiService>()),
      ),
      RepositoryProvider<CodesRemoteDatasource>(
        create: (context) =>
            CodesRemoteDatasource(apiService: context.read<ApiService>()),
      ),
      RepositoryProvider<CodesRepository>(
        create: (context) => CodesRepositoryImpl(
          remoteDatasource: context.read<CodesRemoteDatasource>(),
        ),
      ),
      // Billing Repository
      RepositoryProvider<BillingRepository>(
        create: (context) =>
            BillingRepositoryImpl(apiClient: context.read<ApiClient>()),
      ),
    ];
  }

  /// Get BLoC providers for Store Keeper module
  static List<BlocProvider> getStoreKeeperBlocProviders() {
    return [
      // Add Store Keeper BLoCs here
    ];
  }

  /// Get BLoC providers for Driver module
  static List<BlocProvider> getDriverBlocProviders() {
    return [
      // Add Driver BLoCs here
    ];
  }

  /// Get BLoC providers for Nexa Admin module
  static List<BlocProvider> getNexaAdminBlocProviders() {
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
          billingRepository: context.read<admin_billing_repo.BillingRepository>(),
        ),
      ),
    ];
  }

  /// Get BLoC providers for Factory Admin module
  static List<BlocProvider> getFactoryAdminBlocProviders() {
    return [
      BlocProvider<FactoryAuthBloc>(
        create: (context) => FactoryAuthBloc(
          authRepository: context.read<FactoryAuthRepository>(),
        ),
      ),
      BlocProvider<ProductsBloc>(
        create: (context) =>
            ProductsBloc(repository: context.read<FactoryProductsRepository>()),
      ),
      BlocProvider<UnitCodesBloc>(
        create: (context) =>
            UnitCodesBloc(codesRepository: context.read<CodesRepository>()),
      ),
      BlocProvider<PacketCodesBloc>(
        create: (context) =>
            PacketCodesBloc(codesRepository: context.read<CodesRepository>()),
      ),
      BlocProvider<CartonCodesBloc>(
        create: (context) =>
            CartonCodesBloc(codesRepository: context.read<CodesRepository>()),
      ),
      BlocProvider<BundleCodesBloc>(
        create: (context) =>
            BundleCodesBloc(codesRepository: context.read<CodesRepository>()),
      ),
      // Billing Bloc
      BlocProvider<BillingBloc>(
        create: (context) =>
            BillingBloc(billingRepository: context.read<BillingRepository>()),
      ),
    ];
  }

  /// Get global BLoC providers (available to all modules)
  static List<BlocProvider> getGlobalBlocProviders() {
    return [
      // Add global BLoCs here (e.g., theme, language, notifications)
    ];
  }
}
