// Truck Owner Dashboard Bloc — truck-owner panel state machine
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/goods_operations/presentation/bloc/truck_owner/truck_owner_event.dart';
import 'package:trace_odd/features/goods_operations/presentation/bloc/truck_owner/truck_owner_state.dart';

class TruckOwnerDashboardBloc extends Bloc<TruckOwnerEvent, TruckOwnerState> {
  final ApiService _api = ApiService();
  static const _prefix = '/truck-owner';

  TruckOwnerDashboardBloc() : super(const TruckOwnerState()) {
    on<BootstrapTruckOwner>(_onBoot);
    on<FetchTruckOwnerMetrics>(_onMetrics);
    on<LoadTruckDrivers>(_onDrivers);
    on<LoadTruckConductors>(_onConductors);
    on<LoadTruckVehicles>(_onVehicles);
    on<LoadTruckFreightLoads>(_onFreight);
    on<NavigateTruckOwnerPage>(_onNav);
    on<TruckOwnerLogout>(_onLogout);
    on<RegisterTruckStaff>(_onRegStaff);
    on<RemoveTruckStaff>(_onRemStaff);
    on<AddTruckVehicle>(_onAddVehicle);
    on<RemoveTruckVehicle>(_onRemVehicle);
    on<LoadTruckLinkStatus>(_onLinkStatus);
    on<SearchTruckCompanies>(_onSearch);
    on<SendTruckLinkRequest>(_onSendLink);
    on<CancelTruckLinkRequest>(_onCancelLink);
    on<LeaveTruckCarrier>(_onLeave);
    on<ClearTruckOwnerError>(_onClear);
    on<LoadTruckInbox>(_onInbox);
    on<LoadTruckConversation>(_onConv);
    on<SendTruckMessage>(_onSendMsg);
  }

  Future<void> _onBoot(
    BootstrapTruckOwner e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(status: TruckOwnerStatus.loading));
    final p = await SharedPreferences.getInstance();
    final t = p.getString('${e.storagePrefix}_auth_token') ?? '';
    if (t.isEmpty) {
      emit(
        state.copyWith(
          status: TruckOwnerStatus.initial,
          error: 'Not authenticated',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: TruckOwnerStatus.loaded,
        ownerName:
            p.getString('${e.storagePrefix}_company_name') ??
            p.getString('${e.storagePrefix}_owner_name') ??
            'Truck Owner',
      ),
    );
    add(const FetchTruckOwnerMetrics());
  }

  Future<void> _onMetrics(
    FetchTruckOwnerMetrics e,
    Emitter<TruckOwnerState> emit,
  ) async {
    add(const LoadTruckDrivers());
    add(const LoadTruckConductors());
    add(const LoadTruckVehicles());
    add(const LoadTruckFreightLoads());
  }

  Future<void> _onDrivers(
    LoadTruckDrivers e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(driversLoading: true));
    try {
      final r = await _api.get('$_prefix/drivers');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is Map && d['data'] is List
          ? (d['data'] as List).cast<Map<String, dynamic>>()
          : (d is List ? d.cast<Map<String, dynamic>>() : []);
      emit(
        state.copyWith(
          drivers: list,
          driverCount: list.length,
          driversLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(driversLoading: false));
    }
  }

  Future<void> _onConductors(
    LoadTruckConductors e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(conductorsLoading: true));
    try {
      final r = await _api.get('$_prefix/conductors');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is Map && d['data'] is List
          ? (d['data'] as List).cast<Map<String, dynamic>>()
          : (d is List ? d.cast<Map<String, dynamic>>() : []);
      emit(
        state.copyWith(
          conductors: list,
          conductorCount: list.length,
          conductorsLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(conductorsLoading: false));
    }
  }

  Future<void> _onVehicles(
    LoadTruckVehicles e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(vehiclesLoading: true));
    try {
      final r = await _api.get('$_prefix/vehicles');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : (d is Map && d['data'] is List
                ? (d['data'] as List).cast<Map<String, dynamic>>()
                : []);
      emit(
        state.copyWith(
          vehicles: list,
          vehicleCount: list.length,
          vehiclesLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(vehiclesLoading: false));
    }
  }

  Future<void> _onFreight(
    LoadTruckFreightLoads e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(freightLoading: true));
    try {
      final r = await _api.get('$_prefix/freight-loads');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : (d is Map && d['data'] is List
                ? (d['data'] as List).cast<Map<String, dynamic>>()
                : []);
      emit(
        state.copyWith(
          freightLoads: list,
          freightLoadCount: list.length,
          freightLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(freightLoading: false));
    }
  }

  Future<void> _onRegStaff(
    RegisterTruckStaff e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post('$_prefix/${e.role}s', data: e.data);
      add(const FetchTruckOwnerMetrics());
    } catch (ex) {
      emit(state.copyWith(actionError: ex.toString()));
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onRemStaff(
    RemoveTruckStaff e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.delete('$_prefix/${e.role}s/${e.staffId}');
      add(const FetchTruckOwnerMetrics());
    } catch (ex) {
      emit(state.copyWith(actionError: ex.toString()));
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onAddVehicle(
    AddTruckVehicle e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post('$_prefix/vehicles', data: e.data);
      add(const LoadTruckVehicles());
    } catch (ex) {
      emit(state.copyWith(actionError: ex.toString()));
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onRemVehicle(
    RemoveTruckVehicle e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.delete('$_prefix/vehicles/${e.vehicleId}');
      add(const LoadTruckVehicles());
    } catch (ex) {
      emit(state.copyWith(actionError: ex.toString()));
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  // ── Carrier Link ──
  Future<void> _onLinkStatus(
    LoadTruckLinkStatus e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(linkLoading: true));
    try {
      final r = await _api.get('$_prefix/link-status');
      emit(
        state.copyWith(
          linkStatus: (r?['data'] as Map<String, dynamic>?) ?? {},
          linkLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(linkLoading: false));
    }
  }

  Future<void> _onSearch(
    SearchTruckCompanies e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(companiesLoading: true));
    try {
      final r = await _api.get(
        '$_prefix/available-companies',
        queryParams: {'search': e.query},
      );
      final d = r?['data'];
      emit(
        state.copyWith(
          availableCompanies: d is List ? d.cast<Map<String, dynamic>>() : [],
          companiesLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(companiesLoading: false));
    }
  }

  Future<void> _onSendLink(
    SendTruckLinkRequest e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post(
        '$_prefix/link-request',
        data: {
          'company_id': e.companyId,
          if (e.message != null) 'message': e.message,
        },
      );
      add(const LoadTruckLinkStatus());
      emit(state.copyWith(isMutating: false));
    } catch (ex) {
      emit(state.copyWith(isMutating: false, actionError: ex.toString()));
    }
  }

  Future<void> _onCancelLink(
    CancelTruckLinkRequest e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post('$_prefix/link-request/${e.assignmentId}/cancel');
      add(const LoadTruckLinkStatus());
    } catch (_) {
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onLeave(
    LeaveTruckCarrier e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post('$_prefix/link-request/${e.assignmentId}/leave');
      add(const LoadTruckLinkStatus());
    } catch (_) {
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  // ── Chat Inbox ──
  Future<void> _onInbox(LoadTruckInbox e, Emitter<TruckOwnerState> emit) async {
    emit(state.copyWith(inboxLoading: true, chatError: null));
    try {
      final r = await _api.get('$_prefix/link-messages');
      final list = (r?['data'] as List?) ?? [];
      final Map<String, Map<String, dynamic>> convMap = {};
      for (final m in list) {
        if (m is! Map) continue;
        final aid =
            m['fleet_assignment_id']?.toString() ??
            m['assignment_id']?.toString() ??
            '';
        if (aid.isEmpty) continue;
        convMap.putIfAbsent(
          aid,
          () => {
            'id': aid,
            'owner_name': 'Owner',
            'latest_body': '',
            'latest_at': '',
          },
        );
        convMap[aid]!['latest_body'] = m['message_body']?.toString() ?? '';
        convMap[aid]!['latest_at'] = m['created_at']?.toString() ?? '';
      }
      emit(
        state.copyWith(
          inboxConversations: convMap.values.toList(),
          inboxLoading: false,
        ),
      );
    } catch (ex) {
      emit(state.copyWith(inboxLoading: false, chatError: ex.toString()));
    }
  }

  Future<void> _onConv(
    LoadTruckConversation e,
    Emitter<TruckOwnerState> emit,
  ) async {
    try {
      final r = await _api.get('$_prefix/link-messages/${e.assignmentId}');
      final list = (r?['data'] as List?) ?? [];
      emit(
        state.copyWith(
          activeChatMessages: list
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList(),
          expandedConversationId: e.assignmentId,
        ),
      );
    } catch (ex) {
      emit(state.copyWith(chatError: ex.toString()));
    }
  }

  Future<void> _onSendMsg(
    SendTruckMessage e,
    Emitter<TruckOwnerState> emit,
  ) async {
    emit(state.copyWith(chatSending: true));
    try {
      await _api.post(
        '$_prefix/link-messages/${e.assignmentId}',
        data: {'message_body': e.message},
      );
      add(LoadTruckConversation(e.assignmentId));
      add(const LoadTruckInbox());
      emit(state.copyWith(chatSending: false));
    } catch (ex) {
      emit(state.copyWith(chatSending: false, chatError: ex.toString()));
    }
  }

  void _onNav(NavigateTruckOwnerPage e, Emitter<TruckOwnerState> emit) =>
      emit(state.copyWith(currentPage: e.page));
  void _onClear(ClearTruckOwnerError e, Emitter<TruckOwnerState> emit) =>
      emit(state.copyWith(actionError: null));
  Future<void> _onLogout(
    TruckOwnerLogout e,
    Emitter<TruckOwnerState> emit,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('${e.storagePrefix}_auth_token');
    await p.remove('auth_token');
  }
}
