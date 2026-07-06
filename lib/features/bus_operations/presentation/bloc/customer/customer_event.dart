// Customer Super App Events
import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class LoadPublishedLayouts extends CustomerEvent {
  const LoadPublishedLayouts();
}

class SwitchTab extends CustomerEvent {
  final int index;
  const SwitchTab(this.index);
  @override
  List<Object?> get props => [index];
}
