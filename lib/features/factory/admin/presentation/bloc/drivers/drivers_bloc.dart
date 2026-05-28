import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/services/api_service.dart';

class Driver {
  final String id;
  final String name;
  final String? phone;
  final String email;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? vehiclePlateNumber;
  final String? vehicleType;
  final String status; // active, inactive, suspended
  final String? tier; // bronze, silver, gold
  final double? rating;
  final int totalTrips;
  final int completedTrips;
  final String? lastLoginAt;
  final String createdAt;

  const Driver({
    required this.id,
    required this.name,
    this.phone,
    required this.email,
    this.licenseNumber,
    this.licenseExpiry,
    this.vehiclePlateNumber,
    this.vehicleType,
    this.status = 'active',
    this.tier,
    this.rating,
    this.totalTrips = 0,
    this.completedTrips = 0,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString() ?? '',
      licenseNumber:
          json['licenseNumber']?.toString() ??
          json['license_number']?.toString(),
      licenseExpiry: json['licenseExpiry'] != null
          ? DateTime.tryParse(json['licenseExpiry'].toString())
          : (json['license_expiry'] != null
                ? DateTime.tryParse(json['license_expiry'].toString())
                : null),
      vehiclePlateNumber:
          json['vehiclePlateNumber']?.toString() ??
          json['vehicle_plate_number']?.toString(),
      vehicleType:
          json['vehicleType']?.toString() ?? json['vehicle_type']?.toString(),
      status: json['status']?.toString() ?? 'active',
      tier: json['tier']?.toString(),
      rating: (json['rating'] as num?)?.toDouble(),
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
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

abstract class DriversEvent extends Equatable {
  const DriversEvent();
  @override
  List<Object?> get props => [];
}

class LoadDrivers extends DriversEvent {
  final String? search;
  final String? statusFilter;
  final int page;
  final int limit;
  const LoadDrivers({
    this.search,
    this.statusFilter,
    this.page = 1,
    this.limit = 20,
  });
  @override
  List<Object?> get props => [search, statusFilter, page, limit];
}

class CreateDriver extends DriversEvent {
  final String name;
  final String? phone;
  final String email;
  final String password;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? vehiclePlateNumber;
  final String? vehicleType;
  const CreateDriver({
    required this.name,
    this.phone,
    required this.email,
    required this.password,
    this.licenseNumber,
    this.licenseExpiry,
    this.vehiclePlateNumber,
    this.vehicleType,
  });
  @override
  List<Object?> get props => [
    name,
    phone,
    email,
    password,
    licenseNumber,
    licenseExpiry,
    vehiclePlateNumber,
    vehicleType,
  ];
}

class UpdateDriver extends DriversEvent {
  final String id;
  final String name;
  final String? phone;
  final String email;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? vehiclePlateNumber;
  final String? vehicleType;
  final String? status;
  const UpdateDriver({
    required this.id,
    required this.name,
    this.phone,
    required this.email,
    this.licenseNumber,
    this.licenseExpiry,
    this.vehiclePlateNumber,
    this.vehicleType,
    this.status,
  });
  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    licenseNumber,
    licenseExpiry,
    vehiclePlateNumber,
    vehicleType,
    status,
  ];
}

class DeleteDriver extends DriversEvent {
  final String id;
  const DeleteDriver({required this.id});
  @override
  List<Object?> get props => [id];
}

class ToggleDriverStatus extends DriversEvent {
  final String id;
  final String newStatus; // active, inactive, suspended
  const ToggleDriverStatus({required this.id, required this.newStatus});
  @override
  List<Object?> get props => [id, newStatus];
}

class LoadDriverAuditTrail extends DriversEvent {
  final String id;
  const LoadDriverAuditTrail({required this.id});
  @override
  List<Object?> get props => [id];
}

enum DriversStatus {
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

class DriversState extends Equatable {
  final DriversStatus status;
  final List<Driver> drivers;
  final List<AuditEntry> auditEntries;
  final int total;
  final int page;
  final String? errorMessage;

  const DriversState({
    this.status = DriversStatus.initial,
    this.drivers = const [],
    this.auditEntries = const [],
    this.total = 0,
    this.page = 1,
    this.errorMessage,
  });

  DriversState copyWith({
    DriversStatus? status,
    List<Driver>? drivers,
    List<AuditEntry>? auditEntries,
    int? total,
    int? page,
    String? errorMessage,
  }) {
    return DriversState(
      status: status ?? this.status,
      drivers: drivers ?? this.drivers,
      auditEntries: auditEntries ?? this.auditEntries,
      total: total ?? this.total,
      page: page ?? this.page,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    drivers,
    auditEntries,
    total,
    page,
    errorMessage,
  ];
}

class DriversBloc extends Bloc<DriversEvent, DriversState> {
  final ApiService _api = ApiService();

  DriversBloc() : super(const DriversState()) {
    on<LoadDrivers>(_onLoad);
    on<CreateDriver>(_onCreate);
    on<UpdateDriver>(_onUpdate);
    on<DeleteDriver>(_onDelete);
    on<ToggleDriverStatus>(_onToggleStatus);
    on<LoadDriverAuditTrail>(_onAuditTrail);
  }

  Future<void> _onLoad(LoadDrivers event, Emitter<DriversState> emit) async {
    try {
      emit(state.copyWith(status: DriversStatus.loading, errorMessage: null));
      final qp = <String, dynamic>{
        'page': event.page.toString(),
        'limit': event.limit.toString(),
      };
      if (event.search != null && event.search!.isNotEmpty)
        qp['search'] = event.search;
      if (event.statusFilter != null && event.statusFilter!.isNotEmpty)
        qp['status'] = event.statusFilter;

      final response = await _api.get('/factory/drivers/list', queryParams: qp);
      final data = response is Map ? (response['data'] ?? response) : {};
      final list =
          (data['drivers'] as List?)?.map((j) => Driver.fromJson(j)).toList() ??
          [];
      final total = (data['total'] as int?) ?? list.length;

      emit(
        state.copyWith(
          status: DriversStatus.loaded,
          drivers: list,
          total: total,
          page: event.page,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: DriversStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCreate(CreateDriver event, Emitter<DriversState> emit) async {
    try {
      emit(state.copyWith(status: DriversStatus.creating, errorMessage: null));
      final body = <String, dynamic>{
        'name': event.name,
        'email': event.email,
        'password': event.password,
      };
      if (event.phone?.isNotEmpty == true) body['phone'] = event.phone;
      if (event.licenseNumber?.isNotEmpty == true)
        body['license_number'] = event.licenseNumber;
      if (event.licenseExpiry?.isNotEmpty == true)
        body['license_expiry'] = event.licenseExpiry;
      if (event.vehiclePlateNumber?.isNotEmpty == true)
        body['vehicle_plate_number'] = event.vehiclePlateNumber;
      if (event.vehicleType?.isNotEmpty == true)
        body['vehicle_type'] = event.vehicleType;

      final response = await _api.post('/factory/drivers/create', body: body);
      final created = Driver.fromJson(
        response is Map ? (response['data'] ?? response) : {},
      );
      emit(
        state.copyWith(
          status: DriversStatus.created,
          drivers: [created, ...state.drivers],
          total: state.total + 1,
        ),
      );
      emit(state.copyWith(status: DriversStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: DriversStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdate(UpdateDriver event, Emitter<DriversState> emit) async {
    try {
      emit(state.copyWith(status: DriversStatus.updating, errorMessage: null));
      final body = <String, dynamic>{'name': event.name, 'email': event.email};
      if (event.phone?.isNotEmpty == true) body['phone'] = event.phone;
      if (event.licenseNumber?.isNotEmpty == true)
        body['license_number'] = event.licenseNumber;
      if (event.licenseExpiry?.isNotEmpty == true)
        body['license_expiry'] = event.licenseExpiry;
      if (event.vehiclePlateNumber?.isNotEmpty == true)
        body['vehicle_plate_number'] = event.vehiclePlateNumber;
      if (event.vehicleType?.isNotEmpty == true)
        body['vehicle_type'] = event.vehicleType;
      if (event.status?.isNotEmpty == true) body['status'] = event.status;

      final response = await _api.put(
        '/factory/drivers/${event.id}',
        body: body,
      );
      final updated = Driver.fromJson(
        response is Map ? (response['data'] ?? response) : {},
      );
      emit(
        state.copyWith(
          status: DriversStatus.updated,
          drivers: state.drivers
              .map((d) => d.id == event.id ? updated : d)
              .toList(),
        ),
      );
      emit(state.copyWith(status: DriversStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: DriversStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDelete(DeleteDriver event, Emitter<DriversState> emit) async {
    try {
      emit(state.copyWith(status: DriversStatus.deleting, errorMessage: null));
      await _api.delete('/factory/drivers/${event.id}');
      emit(
        state.copyWith(
          status: DriversStatus.deleted,
          drivers: state.drivers.where((d) => d.id != event.id).toList(),
          total: state.total - 1,
        ),
      );
      emit(state.copyWith(status: DriversStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: DriversStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onToggleStatus(
    ToggleDriverStatus event,
    Emitter<DriversState> emit,
  ) async {
    try {
      emit(state.copyWith(status: DriversStatus.updating, errorMessage: null));
      final response = await _api.patch(
        '/factory/drivers/${event.id}/status',
        body: {'status': event.newStatus},
      );
      final updated = Driver.fromJson(
        response is Map ? (response['data'] ?? response) : {},
      );
      emit(
        state.copyWith(
          status: DriversStatus.updated,
          drivers: state.drivers
              .map((d) => d.id == event.id ? updated : d)
              .toList(),
        ),
      );
      emit(state.copyWith(status: DriversStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: DriversStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAuditTrail(
    LoadDriverAuditTrail event,
    Emitter<DriversState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: DriversStatus.auditLoading, errorMessage: null),
      );
      final response = await _api.get(
        '/factory/drivers/${event.id}/audit-trail',
      );
      final data = response is Map ? (response['data'] ?? response) : {};
      final entries =
          (data['details'] as List?)
              ?.map((j) => AuditEntry.fromJson(j))
              .toList() ??
          [];
      emit(
        state.copyWith(
          status: DriversStatus.auditLoaded,
          auditEntries: entries,
        ),
      );
      emit(state.copyWith(status: DriversStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: DriversStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
