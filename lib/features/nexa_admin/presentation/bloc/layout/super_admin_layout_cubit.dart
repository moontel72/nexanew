import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuperAdminLayoutState extends Equatable {
  final bool isSidebarCollapsed;

  const SuperAdminLayoutState({required this.isSidebarCollapsed});

  SuperAdminLayoutState copyWith({bool? isSidebarCollapsed}) {
    return SuperAdminLayoutState(
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
    );
  }

  @override
  List<Object?> get props => [isSidebarCollapsed];
}

class SuperAdminLayoutCubit extends Cubit<SuperAdminLayoutState> {
  SuperAdminLayoutCubit()
      : super(const SuperAdminLayoutState(isSidebarCollapsed: false));

  void toggleSidebar() {
    emit(state.copyWith(isSidebarCollapsed: !state.isSidebarCollapsed));
  }

  void setSidebarCollapsed(bool collapsed) {
    if (collapsed == state.isSidebarCollapsed) return;
    emit(state.copyWith(isSidebarCollapsed: collapsed));
  }
}

