import 'package:bloc/bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/reseller_management_repository.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class ResellerManagementEvent {}

final class LoadResellers extends ResellerManagementEvent {
  final String search;
  final String? status;
  final String? city;
  final String? planType;
  final String sortBy;
  final String sortOrder;
  final int page;
  final int perPage;

  LoadResellers({
    this.search = '',
    this.status,
    this.city,
    this.planType,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.page = 1,
    this.perPage = 20,
  });
}

final class LoadResellerDetail extends ResellerManagementEvent {
  final String id;
  LoadResellerDetail(this.id);
}

final class CreateReseller extends ResellerManagementEvent {
  final String name;
  final String businessName;
  final String registrationNo;
  final String email;
  final String phone;
  final String city;
  final String? address;
  final String? planId;

  CreateReseller({
    required this.name,
    required this.businessName,
    required this.registrationNo,
    required this.email,
    required this.phone,
    required this.city,
    this.address,
    this.planId,
  });
}

final class UpdateReseller extends ResellerManagementEvent {
  final String id;
  final String? name;
  final String? businessName;
  final String? registrationNo;
  final String? email;
  final String? phone;
  final String? city;
  final String? address;
  final String? planId;

  UpdateReseller({
    required this.id,
    this.name,
    this.businessName,
    this.registrationNo,
    this.email,
    this.phone,
    this.city,
    this.address,
    this.planId,
  });
}

final class DeleteReseller extends ResellerManagementEvent {
  final String id;
  DeleteReseller(this.id);
}

final class UpdateResellerStatus extends ResellerManagementEvent {
  final String id;
  final String status; // active | inactive
  final String? reason;
  UpdateResellerStatus({required this.id, required this.status, this.reason});
}

final class ToggleSuspendReseller extends ResellerManagementEvent {
  final String id;
  final bool suspend;
  final String? reason;
  ToggleSuspendReseller({required this.id, required this.suspend, this.reason});
}

final class ClearResellerMessage extends ResellerManagementEvent {}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum ResellerLoadStatus { initial, loading, loaded, error, actionSuccess }

final class ResellerManagementState {
  final ResellerLoadStatus status;

  // List
  final List<Map<String, dynamic>> resellers;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  // Filters
  final String search;
  final String? statusFilter;
  final String? cityFilter;
  final String? planTypeFilter;
  final String sortBy;
  final String sortOrder;

  // Detail
  final Map<String, dynamic>? selectedReseller;

  // Feedback
  final String? message;
  final String? errorMessage;

  const ResellerManagementState({
    this.status = ResellerLoadStatus.initial,
    this.resellers = const [],
    this.total = 0,
    this.page = 1,
    this.perPage = 20,
    this.totalPages = 1,
    this.search = '',
    this.statusFilter,
    this.cityFilter,
    this.planTypeFilter,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.selectedReseller,
    this.message,
    this.errorMessage,
  });

  ResellerManagementState copyWith({
    ResellerLoadStatus? status,
    List<Map<String, dynamic>>? resellers,
    int? total,
    int? page,
    int? perPage,
    int? totalPages,
    String? search,
    String? statusFilter,
    String? cityFilter,
    String? planTypeFilter,
    String? sortBy,
    String? sortOrder,
    Map<String, dynamic>? selectedReseller,
    String? message,
    String? errorMessage,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return ResellerManagementState(
      status: status ?? this.status,
      resellers: resellers ?? this.resellers,
      total: total ?? this.total,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      cityFilter: cityFilter ?? this.cityFilter,
      planTypeFilter: planTypeFilter ?? this.planTypeFilter,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedReseller: selectedReseller ?? this.selectedReseller,
      message: clearMessage ? null : (message ?? this.message),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class ResellerManagementBloc
    extends Bloc<ResellerManagementEvent, ResellerManagementState> {
  final ResellerManagementRepository _repo;

  ResellerManagementBloc({required ResellerManagementRepository repo})
    : _repo = repo,
      super(const ResellerManagementState()) {
    on<LoadResellers>(_onLoadResellers);
    on<LoadResellerDetail>(_onLoadDetail);
    on<CreateReseller>(_onCreate);
    on<UpdateReseller>(_onUpdate);
    on<DeleteReseller>(_onDelete);
    on<UpdateResellerStatus>(_onUpdateStatus);
    on<ToggleSuspendReseller>(_onToggleSuspend);
    on<ClearResellerMessage>(_onClearMessage);
  }

  // ── Load List ────────────────────────────────────────────────────
  Future<void> _onLoadResellers(
    LoadResellers event,
    Emitter<ResellerManagementState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ResellerLoadStatus.loading,
        clearError: true,
        search: event.search,
        statusFilter: event.status,
        cityFilter: event.city,
        planTypeFilter: event.planType,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      ),
    );

    try {
      final res = await _repo.listResellers(
        search: event.search,
        status: event.status,
        city: event.city,
        planType: event.planType,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        page: event.page,
        perPage: event.perPage,
      );

      final list =
          (res['data'] as List?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          [];

      emit(
        state.copyWith(
          status: ResellerLoadStatus.loaded,
          resellers: event.page == 1 ? list : [...state.resellers, ...list],
          total: (res['total'] as num?)?.toInt() ?? 0,
          page: (res['page'] as num?)?.toInt() ?? event.page,
          perPage: (res['per_page'] as num?)?.toInt() ?? event.perPage,
          totalPages: (res['total_pages'] as num?)?.toInt() ?? 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ── Load Detail ──────────────────────────────────────────────────
  Future<void> _onLoadDetail(
    LoadResellerDetail event,
    Emitter<ResellerManagementState> emit,
  ) async {
    emit(state.copyWith(status: ResellerLoadStatus.loading, clearError: true));

    try {
      final detail = await _repo.getResellerDetail(event.id);
      emit(
        state.copyWith(
          status: ResellerLoadStatus.loaded,
          selectedReseller: detail,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ── Create ───────────────────────────────────────────────────────
  Future<void> _onCreate(
    CreateReseller event,
    Emitter<ResellerManagementState> emit,
  ) async {
    emit(state.copyWith(status: ResellerLoadStatus.loading, clearError: true));

    try {
      final created = await _repo.createReseller(
        name: event.name,
        businessName: event.businessName,
        registrationNo: event.registrationNo,
        email: event.email,
        phone: event.phone,
        city: event.city,
        address: event.address,
        planId: event.planId,
      );

      emit(
        state.copyWith(
          status: ResellerLoadStatus.actionSuccess,
          selectedReseller: created,
          message: 'Reseller "${event.name}" created successfully.',
        ),
      );

      // Refresh list
      add(
        LoadResellers(
          search: state.search,
          status: state.statusFilter,
          city: state.cityFilter,
          sortBy: state.sortBy,
          sortOrder: state.sortOrder,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ── Update ───────────────────────────────────────────────────────
  Future<void> _onUpdate(
    UpdateReseller event,
    Emitter<ResellerManagementState> emit,
  ) async {
    emit(state.copyWith(status: ResellerLoadStatus.loading, clearError: true));

    try {
      final updated = await _repo.updateReseller(
        id: event.id,
        name: event.name,
        businessName: event.businessName,
        registrationNo: event.registrationNo,
        email: event.email,
        phone: event.phone,
        city: event.city,
        address: event.address,
        planId: event.planId,
      );

      emit(
        state.copyWith(
          status: ResellerLoadStatus.actionSuccess,
          selectedReseller: updated,
          message: 'Reseller updated successfully.',
        ),
      );

      add(
        LoadResellers(
          search: state.search,
          status: state.statusFilter,
          city: state.cityFilter,
          sortBy: state.sortBy,
          sortOrder: state.sortOrder,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ── Delete (soft) ────────────────────────────────────────────────
  Future<void> _onDelete(
    DeleteReseller event,
    Emitter<ResellerManagementState> emit,
  ) async {
    emit(state.copyWith(status: ResellerLoadStatus.loading, clearError: true));

    try {
      await _repo.deleteReseller(event.id);
      emit(
        state.copyWith(
          status: ResellerLoadStatus.actionSuccess,
          message: 'Reseller deleted successfully.',
        ),
      );

      add(
        LoadResellers(
          search: state.search,
          status: state.statusFilter,
          city: state.cityFilter,
          sortBy: state.sortBy,
          sortOrder: state.sortOrder,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ── Status (Active / Inactive) ───────────────────────────────────
  Future<void> _onUpdateStatus(
    UpdateResellerStatus event,
    Emitter<ResellerManagementState> emit,
  ) async {
    emit(state.copyWith(status: ResellerLoadStatus.loading, clearError: true));

    try {
      await _repo.updateResellerStatus(
        id: event.id,
        status: event.status,
        reason: event.reason,
      );

      emit(
        state.copyWith(
          status: ResellerLoadStatus.actionSuccess,
          message: 'Reseller status changed to "${event.status}".',
        ),
      );

      add(
        LoadResellers(
          search: state.search,
          status: state.statusFilter,
          city: state.cityFilter,
          sortBy: state.sortBy,
          sortOrder: state.sortOrder,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ── Suspend / Unsuspend ──────────────────────────────────────────
  Future<void> _onToggleSuspend(
    ToggleSuspendReseller event,
    Emitter<ResellerManagementState> emit,
  ) async {
    emit(state.copyWith(status: ResellerLoadStatus.loading, clearError: true));

    try {
      await _repo.toggleSuspend(
        id: event.id,
        suspend: event.suspend,
        reason: event.reason,
      );

      final label = event.suspend ? 'suspended' : 'reinstated';
      emit(
        state.copyWith(
          status: ResellerLoadStatus.actionSuccess,
          message: 'Reseller $label successfully.',
        ),
      );

      add(
        LoadResellers(
          search: state.search,
          status: state.statusFilter,
          city: state.cityFilter,
          sortBy: state.sortBy,
          sortOrder: state.sortOrder,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ResellerLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ── Clear message ────────────────────────────────────────────────
  void _onClearMessage(
    ClearResellerMessage event,
    Emitter<ResellerManagementState> emit,
  ) {
    emit(state.copyWith(clearMessage: true));
  }
}
