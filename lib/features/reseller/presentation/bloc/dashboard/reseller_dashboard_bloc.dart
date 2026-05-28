import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/features/reseller/data/datasources/reseller_local_datasource.dart';
import 'package:trace_odd/shared/models/reseller/reseller_employee_model.dart';
import 'package:trace_odd/shared/models/reseller/reseller_shop_model.dart';
import 'package:trace_odd/shared/models/wallet/wallet_model.dart';

sealed class ResellerDashboardEvent {}

final class ResellerDashboardLoadRequested extends ResellerDashboardEvent {}

final class ResellerCreateShopRequested extends ResellerDashboardEvent {
  final String name;
  ResellerCreateShopRequested(this.name);
}

final class ResellerDeleteShopRequested extends ResellerDashboardEvent {
  final String shopId;
  ResellerDeleteShopRequested(this.shopId);
}

final class ResellerCreateEmployeeRequested extends ResellerDashboardEvent {
  final String shopId;
  final String name;
  final ResellerEmployeeRole role;
  ResellerCreateEmployeeRequested({
    required this.shopId,
    required this.name,
    required this.role,
  });
}

final class ResellerDeleteEmployeeRequested extends ResellerDashboardEvent {
  final String employeeId;
  ResellerDeleteEmployeeRequested(this.employeeId);
}

final class ResellerCancelBitRequested extends ResellerDashboardEvent {
  final double fee;
  ResellerCancelBitRequested({required this.fee});
}

sealed class ResellerDashboardState {}

final class ResellerDashboardInitial extends ResellerDashboardState {}

final class ResellerDashboardLoading extends ResellerDashboardState {}

final class ResellerDashboardLoaded extends ResellerDashboardState {
  final String resellerId;
  final WalletModel wallet;
  final List<ResellerShopModel> shops;
  final List<ResellerEmployeeModel> employees;

  ResellerDashboardLoaded({
    required this.resellerId,
    required this.wallet,
    required this.shops,
    required this.employees,
  });
}

final class ResellerDashboardError extends ResellerDashboardState {
  final String message;
  ResellerDashboardError(this.message);
}

class ResellerDashboardBloc
    extends Bloc<ResellerDashboardEvent, ResellerDashboardState> {
  final ResellerLocalDatasource _local;

  ResellerDashboardBloc({required SharedPreferences prefs})
      : _local = ResellerLocalDatasource(prefs),
        super(ResellerDashboardInitial()) {
    on<ResellerDashboardLoadRequested>(_onLoad);
    on<ResellerCreateShopRequested>(_onCreateShop);
    on<ResellerDeleteShopRequested>(_onDeleteShop);
    on<ResellerCreateEmployeeRequested>(_onCreateEmployee);
    on<ResellerDeleteEmployeeRequested>(_onDeleteEmployee);
    on<ResellerCancelBitRequested>(_onCancelBit);
  }

  Future<void> _onLoad(
    ResellerDashboardLoadRequested event,
    Emitter<ResellerDashboardState> emit,
  ) async {
    emit(ResellerDashboardLoading());
    final resellerId = _local.getResellerId();
    if (resellerId == null || resellerId.isEmpty) {
      emit(ResellerDashboardError('Not logged in'));
      return;
    }
    final wallet = _local.getOrCreateWallet(resellerId);
    final shops = _local.listShops(resellerId);
    final employees = _local.listEmployees(resellerId: resellerId);
    emit(
      ResellerDashboardLoaded(
        resellerId: resellerId,
        wallet: wallet,
        shops: shops,
        employees: employees,
      ),
    );
  }

  Future<void> _onCreateShop(
    ResellerCreateShopRequested event,
    Emitter<ResellerDashboardState> emit,
  ) async {
    final current = state;
    if (current is! ResellerDashboardLoaded) return;
    if (event.name.trim().isEmpty) return;
    await _local.createShop(resellerId: current.resellerId, name: event.name);
    add(ResellerDashboardLoadRequested());
  }

  Future<void> _onDeleteShop(
    ResellerDeleteShopRequested event,
    Emitter<ResellerDashboardState> emit,
  ) async {
    final current = state;
    if (current is! ResellerDashboardLoaded) return;
    await _local.deleteShop(resellerId: current.resellerId, shopId: event.shopId);
    add(ResellerDashboardLoadRequested());
  }

  Future<void> _onCreateEmployee(
    ResellerCreateEmployeeRequested event,
    Emitter<ResellerDashboardState> emit,
  ) async {
    final current = state;
    if (current is! ResellerDashboardLoaded) return;
    if (event.name.trim().isEmpty) return;
    await _local.createEmployee(
      resellerId: current.resellerId,
      shopId: event.shopId,
      name: event.name,
      role: event.role,
    );
    add(ResellerDashboardLoadRequested());
  }

  Future<void> _onDeleteEmployee(
    ResellerDeleteEmployeeRequested event,
    Emitter<ResellerDashboardState> emit,
  ) async {
    final current = state;
    if (current is! ResellerDashboardLoaded) return;
    await _local.deleteEmployee(
      resellerId: current.resellerId,
      employeeId: event.employeeId,
    );
    add(ResellerDashboardLoadRequested());
  }

  Future<void> _onCancelBit(
    ResellerCancelBitRequested event,
    Emitter<ResellerDashboardState> emit,
  ) async {
    final current = state;
    if (current is! ResellerDashboardLoaded) return;
    final fee = event.fee;
    if (fee <= 0) return;

    final wallet = current.wallet;
    if (!wallet.canDeduct(fee)) {
      emit(ResellerDashboardError('Insufficient wallet balance for fee'));
      emit(current);
      return;
    }

    final updated = wallet.copyWith(
      balance: wallet.balance - fee,
      lastUpdated: DateTime.now(),
      transactionCount: wallet.transactionCount + 1,
      totalTransacted: wallet.totalTransacted + fee,
    );
    await _local.updateWallet(updated);
    add(ResellerDashboardLoadRequested());
  }
}

