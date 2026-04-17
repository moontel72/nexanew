part of 'admin_dashboard_bloc.dart';

/// Admin Dashboard States
/// States that represent the current state of the Admin Dashboard
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state - Dashboard is loading for the first time
class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

/// Dashboard data is loading
class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

/// Dashboard data loaded successfully
class AdminDashboardLoaded extends AdminDashboardState {
  final DashboardData dashboardData;
  final String? activeFilter;
  final String? activeViewMode;
  final String? activeTab;

  const AdminDashboardLoaded({
    required this.dashboardData,
    this.activeFilter,
    this.activeViewMode = 'overview',
    this.activeTab = 'overview',
  });

  @override
  List<Object?> get props => [
    dashboardData,
    activeFilter,
    activeViewMode,
    activeTab,
  ];

  /// Copy with method for updating state
  AdminDashboardLoaded copyWith({
    DashboardData? dashboardData,
    String? activeFilter,
    String? activeViewMode,
    String? activeTab,
  }) {
    return AdminDashboardLoaded(
      dashboardData: dashboardData ?? this.dashboardData,
      activeFilter: activeFilter ?? this.activeFilter,
      activeViewMode: activeViewMode ?? this.activeViewMode,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

/// Dashboard data refresh in progress
class AdminDashboardRefreshing extends AdminDashboardState {
  final DashboardData previousData;

  const AdminDashboardRefreshing({required this.previousData});

  @override
  List<Object?> get props => [previousData];
}

/// Dashboard data export in progress
class AdminDashboardExporting extends AdminDashboardState {
  final DashboardData dashboardData;
  final String exportFormat;

  const AdminDashboardExporting({
    required this.dashboardData,
    required this.exportFormat,
  });

  @override
  List<Object?> get props => [dashboardData, exportFormat];
}

/// Dashboard data export completed
class AdminDashboardExportComplete extends AdminDashboardState {
  final String filePath;
  final DashboardData dashboardData;

  const AdminDashboardExportComplete({
    required this.filePath,
    required this.dashboardData,
  });

  @override
  List<Object?> get props => [filePath, dashboardData];
}

/// Dashboard error state
class AdminDashboardError extends AdminDashboardState {
  final String message;
  final DashboardData? previousData;

  const AdminDashboardError({required this.message, this.previousData});

  @override
  List<Object?> get props => [message, previousData];
}

// Dashboard models live in lib/shared/models/dashboard/dashboard_models.dart
