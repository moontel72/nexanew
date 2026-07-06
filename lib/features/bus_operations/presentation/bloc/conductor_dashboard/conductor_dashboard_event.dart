// Conductor Dashboard Events
import 'package:equatable/equatable.dart';

abstract class ConductorDashboardEvent extends Equatable {
  const ConductorDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadConductorProfile extends ConductorDashboardEvent {
  final String storagePrefix;
  const LoadConductorProfile({required this.storagePrefix});
  @override
  List<Object?> get props => [storagePrefix];
}

class RefreshConductorData extends ConductorDashboardEvent {
  const RefreshConductorData();
}

class ConductorLogout extends ConductorDashboardEvent {
  final String storagePrefix;
  const ConductorLogout({required this.storagePrefix});
  @override
  List<Object?> get props => [storagePrefix];
}
