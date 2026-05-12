import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/core/services/api_service.dart';

class StoreKeeper {
  final String id;
  final String name;
  final String? employeeId;
  final String? phone;
  final String email;
  final String status;
  final String? dutyShift;
  final String? lastLoginAt;
  final String createdAt;

  const StoreKeeper({
    required this.id,
    required this.name,
    this.employeeId,
    this.phone,
    required this.email,
    this.status = 'active',
    this.dutyShift,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory StoreKeeper.fromJson(Map<String, dynamic> json) {
    return StoreKeeper(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      employeeId:
          json['employeeId']?.toString() ?? json['employee_id']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      dutyShift:
          json['dutyShift']?.toString() ?? json['duty_shift']?.toString(),
      lastLoginAt:
          json['lastLoginAt']?.toString() ?? json['last_login_at']?.toString(),
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
    );
  }
}

class AuditEntry {
  final String code;
  final String action;
  final String? timestamp;
  final String type;

  const AuditEntry({
    required this.code,
    required this.action,
    this.timestamp,
    required this.type,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      code: json['code']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      timestamp: json['timestamp']?.toString(),
      type: json['type']?.toString() ?? '',
    );
  }
}

abstract class StoreKeepersEvent extends Equatable {
  const StoreKeepersEvent();
  @override
  List<Object?> get props => [];
}

class LoadStoreKeepers extends StoreKeepersEvent {
  final String? search;
  final String? statusFilter;
  final int page;
  final int limit;
  const LoadStoreKeepers({
    this.search,
    this.statusFilter,
    this.page = 1,
    this.limit = 20,
  });
  @override
  List<Object?> get props => [search, statusFilter, page, limit];
}

class CreateStoreKeeper extends StoreKeepersEvent {
  final String name;
  final String? employeeId;
  final String? phone;
  final String email;
  final String password;
  final String? dutyShift;
  const CreateStoreKeeper({
    required this.name,
    this.employeeId,
    this.phone,
    required this.email,
    required this.password,
    this.dutyShift,
  });
  @override
  List<Object?> get props => [
    name,
    employeeId,
    phone,
    email,
    password,
    dutyShift,
  ];
}

class UpdateStoreKeeper extends StoreKeepersEvent {
  final String id;
  final String name;
  final String? employeeId;
  final String? phone;
  final String email;
  final String? dutyShift;
  final String? status;
  const UpdateStoreKeeper({
    required this.id,
    required this.name,
    this.employeeId,
    this.phone,
    required this.email,
    this.dutyShift,
    this.status,
  });
  @override
  List<Object?> get props => [
    id,
    name,
    employeeId,
    phone,
    email,
    dutyShift,
    status,
  ];
}

class DeleteStoreKeeper extends StoreKeepersEvent {
  final String id;
  const DeleteStoreKeeper({required this.id});
  @override
  List<Object?> get props => [id];
}

class LoadStoreKeeperAuditTrail extends StoreKeepersEvent {
  final String id;
  const LoadStoreKeeperAuditTrail({required this.id});
  @override
  List<Object?> get props => [id];
}

enum StoreKeepersStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  deleting,
  deleted,
  auditLoading,
  auditLoaded,
  error,
}

class StoreKeepersState extends Equatable {
  final StoreKeepersStatus status;
  final List<StoreKeeper> storeKeepers;
  final List<AuditEntry> auditEntries;
  final int total;
  final int page;
  final String? errorMessage;

  const StoreKeepersState({
    this.status = StoreKeepersStatus.initial,
    this.storeKeepers = const [],
    this.auditEntries = const [],
    this.total = 0,
    this.page = 1,
    this.errorMessage,
  });

  StoreKeepersState copyWith({
    StoreKeepersStatus? status,
    List<StoreKeeper>? storeKeepers,
    List<AuditEntry>? auditEntries,
    int? total,
    int? page,
    String? errorMessage,
  }) {
    return StoreKeepersState(
      status: status ?? this.status,
      storeKeepers: storeKeepers ?? this.storeKeepers,
      auditEntries: auditEntries ?? this.auditEntries,
      total: total ?? this.total,
      page: page ?? this.page,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    storeKeepers,
    auditEntries,
    total,
    page,
    errorMessage,
  ];
}

class StoreKeepersBloc extends Bloc<StoreKeepersEvent, StoreKeepersState> {
  final ApiService _api = ApiService();

  StoreKeepersBloc() : super(const StoreKeepersState()) {
    on<LoadStoreKeepers>(_onLoad);
    on<CreateStoreKeeper>(_onCreate);
    on<UpdateStoreKeeper>(_onUpdate);
    on<DeleteStoreKeeper>(_onDelete);
    on<LoadStoreKeeperAuditTrail>(_onAuditTrail);
  }

  Future<void> _onLoad(
    LoadStoreKeepers event,
    Emitter<StoreKeepersState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: StoreKeepersStatus.loading, errorMessage: null),
      );
      final qp = <String, dynamic>{
        'page': event.page.toString(),
        'limit': event.limit.toString(),
      };
      if (event.search != null && event.search!.isNotEmpty)
        qp['search'] = event.search;
      if (event.statusFilter != null && event.statusFilter!.isNotEmpty)
        qp['status'] = event.statusFilter;

      final response = await _api.get(
        '/api/factory/store-keepers/list',
        queryParams: qp,
      );
      final data = response is Map ? (response['data'] ?? response) : {};
      final list =
          (data['storeKeepers'] as List?)
              ?.map((j) => StoreKeeper.fromJson(j))
              .toList() ??
          [];
      final total = (data['total'] as int?) ?? list.length;

      emit(
        state.copyWith(
          status: StoreKeepersStatus.loaded,
          storeKeepers: list,
          total: total,
          page: event.page,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StoreKeepersStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreate(
    CreateStoreKeeper event,
    Emitter<StoreKeepersState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: StoreKeepersStatus.creating, errorMessage: null),
      );
      final body = <String, dynamic>{
        'name': event.name,
        'email': event.email,
        'password': event.password,
      };
      if (event.employeeId?.isNotEmpty == true)
        body['employee_id'] = event.employeeId;
      if (event.phone?.isNotEmpty == true) body['phone'] = event.phone;
      if (event.dutyShift?.isNotEmpty == true)
        body['duty_shift'] = event.dutyShift;

      final response = await _api.post(
        '/api/factory/store-keepers/create',
        body: body,
      );
      final created = StoreKeeper.fromJson(
        response is Map ? (response['data'] ?? response) : {},
      );
      emit(
        state.copyWith(
          status: StoreKeepersStatus.created,
          storeKeepers: [created, ...state.storeKeepers],
          total: state.total + 1,
        ),
      );
      emit(state.copyWith(status: StoreKeepersStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: StoreKeepersStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdate(
    UpdateStoreKeeper event,
    Emitter<StoreKeepersState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: StoreKeepersStatus.updating, errorMessage: null),
      );
      final body = <String, dynamic>{'name': event.name, 'email': event.email};
      if (event.employeeId?.isNotEmpty == true)
        body['employee_id'] = event.employeeId;
      if (event.phone?.isNotEmpty == true) body['phone'] = event.phone;
      if (event.dutyShift?.isNotEmpty == true)
        body['duty_shift'] = event.dutyShift;
      if (event.status?.isNotEmpty == true) body['status'] = event.status;

      final response = await _api.put(
        '/api/factory/store-keepers/${event.id}',
        body: body,
      );
      final updated = StoreKeeper.fromJson(
        response is Map ? (response['data'] ?? response) : {},
      );
      emit(
        state.copyWith(
          status: StoreKeepersStatus.updated,
          storeKeepers: state.storeKeepers
              .map((k) => k.id == event.id ? updated : k)
              .toList(),
        ),
      );
      emit(state.copyWith(status: StoreKeepersStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: StoreKeepersStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDelete(
    DeleteStoreKeeper event,
    Emitter<StoreKeepersState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: StoreKeepersStatus.deleting, errorMessage: null),
      );
      await _api.delete('/api/factory/store-keepers/${event.id}');
      emit(
        state.copyWith(
          status: StoreKeepersStatus.deleted,
          storeKeepers: state.storeKeepers
              .where((k) => k.id != event.id)
              .toList(),
          total: state.total - 1,
        ),
      );
      emit(state.copyWith(status: StoreKeepersStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: StoreKeepersStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAuditTrail(
    LoadStoreKeeperAuditTrail event,
    Emitter<StoreKeepersState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: StoreKeepersStatus.auditLoading,
          errorMessage: null,
        ),
      );
      final response = await _api.get(
        '/api/factory/store-keepers/${event.id}/audit-trail',
      );
      final data = response is Map ? (response['data'] ?? response) : {};
      final entries =
          (data['details'] as List?)
              ?.map((j) => AuditEntry.fromJson(j))
              .toList() ??
          [];
      emit(
        state.copyWith(
          status: StoreKeepersStatus.auditLoaded,
          auditEntries: entries,
        ),
      );
      emit(state.copyWith(status: StoreKeepersStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: StoreKeepersStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
