// Fleet Dashboard Bloc — bus-fleet panel dashboard state machine
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_state.dart';

class FleetDashboardBloc
    extends Bloc<FleetDashboardEvent, FleetDashboardState> {
  final ApiService _api = ApiService();

  FleetDashboardBloc() : super(const FleetDashboardState()) {
    on<BootstrapDashboard>(_onBootstrap);
    on<FetchDashboardMetrics>(_onFetchMetrics);
    on<LoadDrivers>(_onLoadDrivers);
    on<LoadConductors>(_onLoadConductors);
    on<LoadLayouts>(_onLoadLayouts);
    on<NavigateToPage>(_onNavigate);
    on<LogoutRequested>(_onLogout);
    on<RegisterStaff>(_onRegisterStaff);
    on<RemoveStaff>(_onRemoveStaff);
    on<ClearStaffError>(_onClearS);
    on<PublishLayout>(_onPublish);
    on<ArchiveLayout>(_onArchive);
    on<DeleteLayout>(_onDelete);
    on<PurgeAllLayouts>(_onPurge);
    on<ClearLayoutError>(_onClearL);
    on<LoadCarrierLink>(_onLoadLink);
    on<AcceptCarrierRequest>(_onAcceptLink);
    on<RejectCarrierRequest>(_onRejectLink);
    on<UnlinkCarrier>(_onUnlink);
    on<LoadInboxMessages>(_onLoadInbox);
    on<LoadConversation>(_onLoadConv);
    on<SendChatMessage>(_onSendMsg);
    on<ClearChatError>(_onClearChat);
  }

  // ── Bootstrap ──────────────────────────────────────────
  Future<void> _onBootstrap(
    BootstrapDashboard e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(status: FleetDashboardStatus.loading));
    final p = await SharedPreferences.getInstance();
    final t = p.getString('${e.storagePrefix}_auth_token') ?? '';
    if (t.isEmpty) {
      emit(
        state.copyWith(
          status: FleetDashboardStatus.initial,
          errorMessage: 'Not authenticated',
        ),
      );
      return;
    }
    // Resolve owner name from multiple storage keys for robustness.
    // Prefer the registered company name (corporate identity) over
    // the account/display name for dashboard branding.
    String ownerName =
        p.getString('${e.storagePrefix}_company_name') ??
        p.getString('${e.storagePrefix}_owner_name') ??
        p.getString('${e.storagePrefix}_driver_name') ??
        p.getString('sub_admin_name') ??
        p.getString('display_name') ??
        'Fleet';
    emit(
      state.copyWith(status: FleetDashboardStatus.loaded, ownerName: ownerName),
    );

    // ── Fetch real company name from backend profile ──
    // The login response carries user identity, not company identity.
    // We must fetch the corporate profile to get the registered name.
    _fetchCompanyProfile(e.panelPrefix, e.storagePrefix, emit);

    add(FetchDashboardMetrics(panelPrefix: e.panelPrefix));
  }

  Future<void> _fetchCompanyProfile(
    String panelPrefix,
    String storagePrefix,
    Emitter<FleetDashboardState> emit,
  ) async {
    try {
      // Correct endpoint: /bus-fleet/profile (not /bus-fleet/owner/profile)
      final r = await _api.get('$panelPrefix/profile');
      final d = r?['data'];
      if (d is Map) {
        // Bus-fleet profile wraps company in a nested object:
        //   { data: { company: { name: "Radhnal Express" }, owner_name: "..." } }
        // Bus-owner profile returns flat:
        //   { data: { account_name: "Radhnal Express" } }
        final cn =
            (d['company'] is Map
                ? (d['company'] as Map)['name']?.toString()
                : null) ??
            d['account_name']?.toString() ??
            d['company_name']?.toString() ??
            d['owner_name']?.toString() ??
            '';
        if (cn.isNotEmpty) {
          final p = await SharedPreferences.getInstance();
          await p.setString('${storagePrefix}_company_name', cn);
          await p.setString('${storagePrefix}_owner_name', cn);
          emit(state.copyWith(ownerName: cn));
          return;
        }
      }
    } catch (_) {
      // Profile endpoint may not exist for this panel; fall through.
    }

    // Fallback: try staff profile (for driver/conductor panels).
    try {
      final r = await _api.get('$panelPrefix/staff/profile');
      final d = r?['data'];
      if (d is Map) {
        final cn =
            (d['company_name'] ??
                    d['account_name'] ??
                    d['owner_name'] ??
                    d['display_name'])
                ?.toString() ??
            '';
        if (cn.isNotEmpty) {
          final p = await SharedPreferences.getInstance();
          await p.setString('${storagePrefix}_company_name', cn);
          await p.setString('${storagePrefix}_owner_name', cn);
          emit(state.copyWith(ownerName: cn));
        }
      }
    } catch (_) {
      // No profile available — keep the SharedPreferences fallback.
    }
  }

  Future<void> _onFetchMetrics(
    FetchDashboardMetrics e,
    Emitter<FleetDashboardState> emit,
  ) async {
    add(LoadDrivers(panelPrefix: e.panelPrefix));
    add(LoadConductors(panelPrefix: e.panelPrefix));
    add(LoadLayouts(panelPrefix: e.panelPrefix));
  }

  // ── Staff ──────────────────────────────────────────────
  Future<void> _onLoadDrivers(
    LoadDrivers e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(driversLoading: true));
    try {
      final r = await _api.get('${e.panelPrefix}/staff/drivers');
      final d = r?['data'];
      emit(
        state.copyWith(
          drivers: d is List ? d.cast<Map<String, dynamic>>() : [],
          driverCount: d is List ? d.length : 0,
          driversLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(driversLoading: false));
    }
  }

  Future<void> _onLoadConductors(
    LoadConductors e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(conductorsLoading: true));
    try {
      final r = await _api.get('${e.panelPrefix}/staff/conductors');
      final d = r?['data'];
      emit(
        state.copyWith(
          conductors: d is List ? d.cast<Map<String, dynamic>>() : [],
          conductorCount: d is List ? d.length : 0,
          conductorsLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(conductorsLoading: false));
    }
  }

  Future<void> _onRegisterStaff(
    RegisterStaff e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isStaffSubmitting: true, staffActionError: null));
    try {
      await _api.post('${e.panelPrefix}/${e.role}s', data: e.data);
      e.role == 'driver'
          ? add(LoadDrivers(panelPrefix: e.panelPrefix))
          : add(LoadConductors(panelPrefix: e.panelPrefix));
      emit(state.copyWith(isStaffSubmitting: false));
    } catch (ex) {
      emit(
        state.copyWith(
          isStaffSubmitting: false,
          staffActionError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onRemoveStaff(
    RemoveStaff e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isStaffSubmitting: true, staffActionError: null));
    try {
      await _api.delete('${e.panelPrefix}/${e.role}s/${e.staffId}');
      e.role == 'driver'
          ? add(LoadDrivers(panelPrefix: e.panelPrefix))
          : add(LoadConductors(panelPrefix: e.panelPrefix));
      emit(state.copyWith(isStaffSubmitting: false));
    } catch (ex) {
      emit(
        state.copyWith(
          isStaffSubmitting: false,
          staffActionError: ex.toString(),
        ),
      );
    }
  }

  void _onClearS(ClearStaffError e, Emitter<FleetDashboardState> emit) =>
      emit(state.copyWith(staffActionError: null));

  // ── Layouts ────────────────────────────────────────────
  Future<void> _onLoadLayouts(
    LoadLayouts e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(layoutsLoading: true));
    try {
      final r = await _api.get('${e.panelPrefix}/absolute-layouts');
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

  Future<void> _onPublish(
    PublishLayout e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isLayoutMutating: true));
    try {
      await _api.post(
        '${e.panelPrefix}/absolute-layouts/${e.layoutId}/publish',
      );
      add(LoadLayouts(panelPrefix: e.panelPrefix));
    } catch (_) {
    } finally {
      emit(state.copyWith(isLayoutMutating: false));
    }
  }

  Future<void> _onArchive(
    ArchiveLayout e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isLayoutMutating: true));
    try {
      await _api.delete('${e.panelPrefix}/absolute-layouts/${e.layoutId}');
      add(LoadLayouts(panelPrefix: e.panelPrefix));
    } catch (_) {
    } finally {
      emit(state.copyWith(isLayoutMutating: false));
    }
  }

  Future<void> _onDelete(
    DeleteLayout e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isLayoutMutating: true));
    try {
      await _api.delete(
        '${e.panelPrefix}/absolute-layouts/${e.layoutId}?permanent=true',
      );
      add(LoadLayouts(panelPrefix: e.panelPrefix));
    } catch (_) {
    } finally {
      emit(state.copyWith(isLayoutMutating: false));
    }
  }

  Future<void> _onPurge(
    PurgeAllLayouts e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isLayoutMutating: true));
    try {
      await _api.delete('${e.panelPrefix}/absolute-layouts/purge/all');
      add(LoadLayouts(panelPrefix: e.panelPrefix));
    } catch (_) {
    } finally {
      emit(state.copyWith(isLayoutMutating: false));
    }
  }

  void _onClearL(ClearLayoutError e, Emitter<FleetDashboardState> emit) =>
      emit(state.copyWith(layoutActionError: null));

  // ── Carrier Link ───────────────────────────────────────
  Future<void> _onLoadLink(
    LoadCarrierLink e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(linkLoading: true, linkActionError: null));
    try {
      final inc = await _api.get('${e.panelPrefix}/link/incoming');
      final act = await _api.get('${e.panelPrefix}/link/active');
      List<Map<String, dynamic>> incList = (inc?['data'] is List)
          ? (inc!['data'] as List).cast<Map<String, dynamic>>()
          : [];
      List<Map<String, dynamic>> actList = (act?['data'] is List)
          ? (act!['data'] as List).cast<Map<String, dynamic>>()
          : [];
      emit(
        state.copyWith(
          incomingRequests: incList,
          linkedCarriers: actList,
          linkLoading: false,
        ),
      );
    } catch (ex) {
      emit(state.copyWith(linkLoading: false, linkActionError: ex.toString()));
    }
  }

  Future<void> _onAcceptLink(
    AcceptCarrierRequest e,
    Emitter<FleetDashboardState> emit,
  ) async {
    try {
      await _api.post('${e.panelPrefix}/link/${e.assignmentId}/accept');
      add(LoadCarrierLink(panelPrefix: e.panelPrefix));
    } catch (ex) {
      emit(state.copyWith(linkActionError: ex.toString()));
    }
  }

  Future<void> _onRejectLink(
    RejectCarrierRequest e,
    Emitter<FleetDashboardState> emit,
  ) async {
    try {
      await _api.post('${e.panelPrefix}/link/${e.assignmentId}/reject');
      add(LoadCarrierLink(panelPrefix: e.panelPrefix));
    } catch (ex) {
      emit(state.copyWith(linkActionError: ex.toString()));
    }
  }

  Future<void> _onUnlink(
    UnlinkCarrier e,
    Emitter<FleetDashboardState> emit,
  ) async {
    try {
      await _api.post('${e.panelPrefix}/link/${e.assignmentId}/unlink');
      add(LoadCarrierLink(panelPrefix: e.panelPrefix));
    } catch (ex) {
      emit(state.copyWith(linkActionError: ex.toString()));
    }
  }

  // ── Chat Inbox ─────────────────────────────────────────
  Future<void> _onLoadInbox(
    LoadInboxMessages e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(inboxLoading: true, chatError: null));
    try {
      final r = await _api.get('${e.panelPrefix}/link-messages');
      final list = (r?['data'] as List?) ?? [];
      final raw = list
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
      // Group by assignment_id into conversations
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
            'owner_name': m['sender_name'] ?? m['owner_name'] ?? 'Owner',
            'messages': <Map<String, dynamic>>[],
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

  Future<void> _onLoadConv(
    LoadConversation e,
    Emitter<FleetDashboardState> emit,
  ) async {
    try {
      final r = await _api.get(
        '${e.panelPrefix}/link-messages/${e.assignmentId}',
      );
      final list = (r?['data'] as List?) ?? [];
      final msgs = list
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
      emit(
        state.copyWith(
          activeChatMessages: msgs,
          expandedConversationId: e.assignmentId,
        ),
      );
    } catch (ex) {
      emit(state.copyWith(chatError: ex.toString()));
    }
  }

  Future<void> _onSendMsg(
    SendChatMessage e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(chatSending: true));
    try {
      await _api.post(
        '${e.panelPrefix}/link-messages/${e.assignmentId}',
        data: {'message_body': e.message},
      );
      add(
        LoadConversation(
          panelPrefix: e.panelPrefix,
          assignmentId: e.assignmentId,
        ),
      );
      add(LoadInboxMessages(panelPrefix: e.panelPrefix));
      emit(state.copyWith(chatSending: false));
    } catch (ex) {
      emit(state.copyWith(chatSending: false, chatError: ex.toString()));
    }
  }

  void _onClearChat(ClearChatError e, Emitter<FleetDashboardState> emit) =>
      emit(state.copyWith(chatError: null));

  void _onNavigate(NavigateToPage e, Emitter<FleetDashboardState> emit) =>
      emit(state.copyWith(currentPage: e.page));
  Future<void> _onLogout(
    LogoutRequested e,
    Emitter<FleetDashboardState> emit,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('${e.storagePrefix}_auth_token');
    await p.remove('auth_token');
  }
}
