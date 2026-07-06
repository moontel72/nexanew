// Conductor Dashboard State
import 'package:equatable/equatable.dart';
import 'conductor_models.dart';

enum ConductorDashboardStatus { initial, loading, loaded, error }

class ConductorDashboardState extends Equatable {
  final ConductorDashboardStatus status;
  final ConductorProfile? profile;
  final TicketManifest? manifest;
  final String? error;
  final bool isRefreshing;

  const ConductorDashboardState({
    this.status = ConductorDashboardStatus.initial,
    this.profile,
    this.manifest,
    this.error,
    this.isRefreshing = false,
  });

  ConductorDashboardState copyWith({
    ConductorDashboardStatus? status,
    ConductorProfile? profile,
    TicketManifest? manifest,
    String? error,
    bool? isRefreshing,
  }) => ConductorDashboardState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    manifest: manifest ?? this.manifest,
    error: error,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );

  @override
  List<Object?> get props => [status, profile, manifest, error, isRefreshing];
}
