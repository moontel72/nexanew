// Factory panel providers — admin, store keeper and driver.
//
// Moved verbatim out of `lib/core/providers/app_providers.dart` (PANEL-SEPARATION-PLAN.md §15b)
// so that `lib/core/` no longer imports `lib/features/`. Behaviour is unchanged: the same providers,
// in the same order.
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
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/factory/admin/data/datasources/codes_remote_datasource.dart';
import 'package:trace_odd/features/factory/admin/data/repositories/billing_repository_impl.dart';
import 'package:trace_odd/features/factory/admin/data/repositories/codes_repository_impl.dart';
import 'package:trace_odd/features/factory/admin/data/repositories/factory_auth_repository.dart';
import 'package:trace_odd/features/factory/admin/data/repositories/factory_products_repository.dart';
import 'package:trace_odd/features/factory/admin/domain/repositories/billing_repository.dart';
import 'package:trace_odd/features/factory/admin/domain/repositories/codes_repository.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/auth/factory_auth_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/billing/billing_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_codes_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_packing_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/carton_codes/carton_codes_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/packet_codes/packet_codes_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/unit_codes/unit_codes_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/drivers/drivers_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/store_keepers/store_keepers_bloc.dart';
import 'package:trace_odd/features/factory/driver/data/datasources/driver_remote_datasource.dart';
import 'package:trace_odd/features/factory/driver/data/repositories/driver_repository_impl.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/factory_driver_geofence_bloc.dart';
import 'package:trace_odd/features/factory/store_keeper/data/repositories/store_keeper_repository.dart';
import 'package:trace_odd/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';

class FactoryProviders {
  FactoryProviders._();

  /// Repository providers for the Factory Admin panel.
  static List<RepositoryProvider> repositoryProviders() {
    return [
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
      // Billing Repository (factory flavour — distinct from the nexa_admin one)
      RepositoryProvider<BillingRepository>(
        create: (context) =>
            BillingRepositoryImpl(apiClient: context.read<ApiClient>()),
      ),
    ];
  }

  /// BLoC providers for the Factory Store Keeper module.
  static List<BlocProvider> storeKeeperBlocProviders() {
    return [
      // Add Store Keeper BLoCs here
    ];
  }

  /// BLoC providers for the Factory Driver module.
  static List<BlocProvider> driverBlocProviders() {
    return [
      BlocProvider<FactoryDriverGeofenceBloc>(
        create: (context) => FactoryDriverGeofenceBloc(),
      ),
      BlocProvider<DriverBloc>(
        create: (context) => DriverBloc(
          repository: DriverRepositoryImpl(
            remoteDatasource: DriverRemoteDatasource(),
          ),
        ),
      ),
    ];
  }

  /// BLoC providers for the Factory Admin module.
  static List<BlocProvider> adminBlocProviders() {
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
      BlocProvider<BundleBloc>(create: (context) => BundleBloc()),
      BlocProvider<BundlePackingBloc>(create: (context) => BundlePackingBloc()),
      BlocProvider<StoreKeepersBloc>(create: (context) => StoreKeepersBloc()),
      BlocProvider<DriversBloc>(create: (context) => DriversBloc()),
      BlocProvider<StoreKeeperBloc>(
        create: (context) =>
            StoreKeeperBloc(repository: StoreKeeperRepository()),
      ),
      // Billing Bloc (factory flavour)
      BlocProvider<BillingBloc>(
        create: (context) =>
            BillingBloc(billingRepository: context.read<BillingRepository>()),
      ),
    ];
  }
}
