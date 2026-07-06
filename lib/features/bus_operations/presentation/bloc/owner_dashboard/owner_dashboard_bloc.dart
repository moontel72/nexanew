// Owner Dashboard Bloc — bus-owner panel state machine
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/owner_dashboard/owner_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/owner_dashboard/owner_dashboard_state.dart';

class OwnerDashboardBloc
    extends Bloc<OwnerDashboardEvent, OwnerDashboardState> {
  final ApiService _api = ApiService();
  static const _prefix = '/bus-owner';

  OwnerDashboardBloc() : super(const OwnerDashboardState()) {
    on<BootstrapOwner>(_onBoot);
    on<FetchOwnerMetrics>(_onMetrics);
    on<LoadOwnerDrivers>(_onDrivers);
    on<LoadOwnerConductors>(_onConductors);
    on<LoadOwnerLayouts>(_onLayouts);
    on<NavigateOwnerPage>(_onNav);
    on<OwnerLogout>(_onLogout);
    on<RegisterOwnerStaff>(_onRegStaff);
    on<RemoveOwnerStaff>(_onRemStaff);
    on<PublishOwnerLayout>(_onPub);
    on<ArchiveOwnerLayout>(_onArch);
    on<DeleteOwnerLayout>(_onDel);
    on<LoadOwnerLinkStatus>(_onLinkStatus);
    on<SearchCompanies>(_onSearch);
    on<SendLinkRequest>(_onSendLink);
    on<CancelLinkRequest>(_onCancelLink);
    on<LeaveCarrier>(_onLeave);
    on<ClearOwnerError>(_onClear);
    on<LoadOwnerInbox>(_onInbox);
    on<LoadOwnerConversation>(_onConv);
    on<SendOwnerMessage>(_onSendMsg);
  }

  Future<void> _onBoot(
    BootstrapOwner e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(status: OwnerDashboardStatus.loading));
    final p = await SharedPreferences.getInstance();
    final t = p.getString('${e.storagePrefix}_auth_token') ?? '';
    if (t.isEmpty) {
      emit(
        state.copyWith(
          status: OwnerDashboardStatus.initial,
          error: 'Not authenticated',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: OwnerDashboardStatus.loaded,
        ownerName: p.getString('${e.storagePrefix}_owner_name') ?? 'Owner',
      ),
    );
    add(const FetchOwnerMetrics());
  }

  Future<void> _onMetrics(
    FetchOwnerMetrics e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    add(const LoadOwnerDrivers());
    add(const LoadOwnerConductors());
    add(const LoadOwnerLayouts());
  }

  Future<void> _onDrivers(
    LoadOwnerDrivers e,
    Emitter<OwnerDashboardState> emit,
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
    LoadOwnerConductors e,
    Emitter<OwnerDashboardState> emit,
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

  Future<void> _onLayouts(
    LoadOwnerLayouts e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(layoutsLoading: true));
    try {
      final r = await _api.get('$_prefix/absolute-layouts');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : (d is Map && d['data'] is List
                ? (d['data'] as List).cast<Map<String, dynamic>>()
                : []);
      emit(
        state.copyWith(
          layouts: list,
          layoutCount: list.length,
          layoutsLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(layoutsLoading: false));
    }
  }

  Future<void> _onRegStaff(
    RegisterOwnerStaff e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post('$_prefix/${e.role}s', data: e.data);
      add(const FetchOwnerMetrics());
    } catch (ex) {
      emit(state.copyWith(actionError: ex.toString()));
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onRemStaff(
    RemoveOwnerStaff e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.delete('$_prefix/${e.role}s/${e.staffId}');
      add(const FetchOwnerMetrics());
    } catch (ex) {
      emit(state.copyWith(actionError: ex.toString()));
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onPub(
    PublishOwnerLayout e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post('$_prefix/absolute-layouts/${e.layoutId}/publish');
      add(const LoadOwnerLayouts());
    } catch (_) {
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onArch(
    ArchiveOwnerLayout e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.delete('$_prefix/absolute-layouts/${e.layoutId}');
      add(const LoadOwnerLayouts());
    } catch (_) {
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onDel(
    DeleteOwnerLayout e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.delete(
        '$_prefix/absolute-layouts/${e.layoutId}?permanent=true',
      );
      add(const LoadOwnerLayouts());
    } catch (_) {
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  // ── Carrier Link (owner-side) ──
  Future<void> _onLinkStatus(
    LoadOwnerLinkStatus e,
    Emitter<OwnerDashboardState> emit,
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
    SearchCompanies e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(companiesLoading: true));
    try {
      final r = await _api.get(
        '$_prefix/available-companies',
        queryParams: {'search': e.query},
      );
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : [];
      emit(state.copyWith(availableCompanies: list, companiesLoading: false));
    } catch (_) {
      emit(state.copyWith(companiesLoading: false));
    }
  }

  Future<void> _onSendLink(
    SendLinkRequest e,
    Emitter<OwnerDashboardState> emit,
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
      add(const LoadOwnerLinkStatus());
      emit(state.copyWith(isMutating: false));
    } catch (ex) {
      emit(state.copyWith(isMutating: false, actionError: ex.toString()));
    }
  }

  Future<void> _onCancelLink(
    CancelLinkRequest e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post('$_prefix/link-request/${e.assignmentId}/cancel');
      add(const LoadOwnerLinkStatus());
    } catch (_) {
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  Future<void> _onLeave(
    LeaveCarrier e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(isMutating: true));
    try {
      await _api.post('$_prefix/link-request/${e.assignmentId}/leave');
      add(const LoadOwnerLinkStatus());
    } catch (_) {
    } finally {
      emit(state.copyWith(isMutating: false));
    }
  }

  // ── Chat Inbox ──
  Future<void> _onInbox(
    LoadOwnerInbox e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(inboxLoading: true, chatError: null));
    try {
      final r = await _api.get('$_prefix/link-messages');
      final list = (r?['data'] as List?) ?? [];
      final raw = list
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
      final Map<String, Map<String, dynamic>> convMap = {};
      for (final m in raw) {
        final aid =
            m['fleet_assignment_id']?.toString() ??
            m['assignment_id']?.toString() ??
            '';
        if (aid.isEmpty) continue;
        convMap.putIfAbsent(
          aid,
          () => {
            'id': aid,
            'owner_name': m['sender_name'] ?? 'Owner',
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
    LoadOwnerConversation e,
    Emitter<OwnerDashboardState> emit,
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
    SendOwnerMessage e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(state.copyWith(chatSending: true));
    try {
      await _api.post(
        '$_prefix/link-messages/${e.assignmentId}',
        data: {'message_body': e.message},
      );
      add(LoadOwnerConversation(e.assignmentId));
      add(const LoadOwnerInbox());
      emit(state.copyWith(chatSending: false));
    } catch (ex) {
      emit(state.copyWith(chatSending: false, chatError: ex.toString()));
    }
  }

  void _onNav(NavigateOwnerPage e, Emitter<OwnerDashboardState> emit) =>
      emit(state.copyWith(currentPage: e.page));
  void _onClear(ClearOwnerError e, Emitter<OwnerDashboardState> emit) =>
      emit(state.copyWith(actionError: null));
  Future<void> _onLogout(
    OwnerLogout e,
    Emitter<OwnerDashboardState> emit,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('${e.storagePrefix}_auth_token');
    await p.remove('auth_token');
  }
}
