// Driver Dashboard State
import 'package:equatable/equatable.dart';
import 'driver_profile.dart';

enum DriverDashboardStatus { initial, loading, loaded, error }

class DriverDashboardState extends Equatable {
  final DriverDashboardStatus status;
  final DriverProfile? profile;
  final String? error;
  final bool isRefreshing;

  const DriverDashboardState({
    this.status = DriverDashboardStatus.initial,
    this.profile,
    this.error,
    this.isRefreshing = false,
  });

  DriverDashboardState copyWith({
    DriverDashboardStatus? status,
    DriverProfile? profile,
    String? error,
    bool? isRefreshing,
  }) => DriverDashboardState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    error: error,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );

  @override
  List<Object?> get props => [status, profile, error, isRefreshing];
}
