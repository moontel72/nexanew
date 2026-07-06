// Driver Dashboard Events
import 'package:equatable/equatable.dart';

abstract class DriverDashboardEvent extends Equatable {
  const DriverDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDriverProfile extends DriverDashboardEvent {
  final String storagePrefix;
  const LoadDriverProfile({required this.storagePrefix});
  @override
  List<Object?> get props => [storagePrefix];
}

class RefreshDriverProfile extends DriverDashboardEvent {
  const RefreshDriverProfile();
}

class DriverLogout extends DriverDashboardEvent {
  final String storagePrefix;
  const DriverLogout({required this.storagePrefix});
  @override
  List<Object?> get props => [storagePrefix];
}
