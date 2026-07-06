// Storekeeper Dashboard Events
import 'package:equatable/equatable.dart';

abstract class StorekeeperEvent extends Equatable {
  const StorekeeperEvent();
  @override
  List<Object?> get props => [];
}

class LoadStorekeeperDashboard extends StorekeeperEvent {
  final String panel;
  const LoadStorekeeperDashboard({required this.panel});
  @override
  List<Object?> get props => [panel];
}

class RefreshStorekeeperData extends StorekeeperEvent {
  final String panel;
  const RefreshStorekeeperData({required this.panel});
  @override
  List<Object?> get props => [panel];
}
