// Customer Super App State
import 'package:equatable/equatable.dart';

enum CustomerStatus { initial, loading, loaded, error }

class CustomerState extends Equatable {
  final CustomerStatus status;
  final int selectedTab; // 0=Transit, 1=Scan
  final List<Map<String, dynamic>> publishedLayouts;
  final String? error;

  const CustomerState({
    this.status = CustomerStatus.initial,
    this.selectedTab = 0,
    this.publishedLayouts = const [],
    this.error,
  });

  CustomerState copyWith({
    CustomerStatus? status,
    int? selectedTab,
    List<Map<String, dynamic>>? publishedLayouts,
    String? error,
  }) => CustomerState(
    status: status ?? this.status,
    selectedTab: selectedTab ?? this.selectedTab,
    publishedLayouts: publishedLayouts ?? this.publishedLayouts,
    error: error,
  );

  @override
  List<Object?> get props => [status, selectedTab, publishedLayouts, error];
}
