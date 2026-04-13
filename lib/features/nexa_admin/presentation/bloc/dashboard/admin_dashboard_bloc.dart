import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/dashboard_repository.dart';
import 'package:nexatrace_system/shared/models/dashboard/dashboard_models.dart';

part 'admin_dashboard_event.dart';
part 'admin_dashboard_state.dart';

/// Admin Dashboard BLoC
/// Manages the state and business logic for the Admin Dashboard
class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final DashboardRepository _dashboardRepository;
  StreamSubscription? _realTimeUpdatesSubscription;

  AdminDashboardBloc({
    required DashboardRepository dashboardRepository,
  })  : _dashboardRepository = dashboardRepository,
        super(const AdminDashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<ExportDashboardData>(_onExportDashboardData);
  }

  @override
  Future<void> close() {
    _realTimeUpdatesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    try {
      final dashboardData = await _dashboardRepository.getDashboardData();

      emit(AdminDashboardLoaded(dashboardData: dashboardData));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(AdminDashboardError(message: failure.message));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is AdminDashboardLoaded) {
      final currentState = state as AdminDashboardLoaded;
      emit(AdminDashboardRefreshing(previousData: currentState.dashboardData));

      try {
        final dashboardData = await _dashboardRepository.getDashboardData();

        emit(AdminDashboardLoaded(dashboardData: dashboardData));
      } catch (error, stackTrace) {
        final failure = mapExceptionToFailure(error, stackTrace);
        emit(AdminDashboardError(
          message: failure.message,
          previousData: currentState.dashboardData,
        ));
      }
    } else {
      add(const LoadDashboardData());
    }
  }

  Future<void> _onExportDashboardData(
    ExportDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    final currentData =
        state is AdminDashboardLoaded ? (state as AdminDashboardLoaded).dashboardData : null;
    if (currentData != null) {
      emit(AdminDashboardExporting(
        dashboardData: currentData,
        exportFormat: event.format,
      ));
    }

    try {
      final filePath = await _dashboardRepository.exportDashboardData(
        format: event.format,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      if (currentData != null) {
        emit(AdminDashboardExportComplete(filePath: filePath, dashboardData: currentData));
      } else {
        emit(const AdminDashboardInitial());
      }
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(AdminDashboardError(message: failure.message, previousData: currentData));
    }
  }
}
