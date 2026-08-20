// Sub-Admin Bloc — auth + dashboard + management
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_state.dart';

class SubAdminBloc extends Bloc<SubAdminEvent, SubAdminState> {
  final ApiClient _api = ApiClient();

  SubAdminBloc() : super(const SubAdminState()) {
    on<SubAdminLoginRequested>(_onLogin);
    on<TogglePasswordVisibility>(_onTogglePwd);
    on<BootstrapDashboard>(_onBoot);
    on<LoadDashboardMetrics>(_onMetrics);
    on<CreateBusCompany>(_onCreateBusCo);
    on<FetchBusCompanies>(_onFetchBusCos);
    on<ToggleBusCompanyStatus>(_onToggleBusCo);
    on<UpdateBusCompanyStatus>(_onUpdateBusCoStatus);
    on<EditBusCompany>(_onEditBusCo);
    on<ResetBusCompanyPassword>(_onResetBusCoPwd);
    on<DeleteBusCompany>(_onDelBusCo);
    on<RestoreBusCompany>(_onRestoreBusCo);
    on<FetchSubAdmins>(_onFetchAdmins);
    on<CreateSubAdmin>(_onCreateAdmin);
    on<ToggleStudioAccess>(_onToggleStudio);
    on<ToggleSubAdminStatus>(_onToggleAdmin);
    on<EditSubAdmin>(_onEditAdmin);
    on<ChangeSubAdminVertical>(_onChangeVert);
    on<ResetSubAdminPassword>(_onResetAdminPwd);
    on<DeleteSubAdmin>(_onDelAdmin);
    on<RestoreSubAdmin>(_onRestoreAdmin);
    on<SubAdminLogout>(_onLogout);
    on<ClearSubAdminError>(_onClear);
  }

  // ═══════════════════ Auth ═══════════════════

  Future<void> _onLogin(
    SubAdminLoginRequested e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(
      state.copyWith(
        authStatus: SubAdminAuthStatus.loading,
        authError: null,
        authSuccess: null,
      ),
    );
    try {
      final res = await _api.post(
        '/api/v1/auth/login',
        body: {'identifier': e.identifier, 'password': e.password},
        requiresAuth: false,
      );
      final token = (res['token'] ?? '').toString();
      if (token.isNotEmpty) {
        final data = (res['data'] is Map<String, dynamic>)
            ? res['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sub_admin_token', token);
        await _api.setAuthToken(token);
        await prefs.setString(
          'sub_admin_name',
          (data['display_name'] ?? 'Sub-Admin').toString(),
        );
        await prefs.setString(
          'sub_admin_vertical',
          (data['sub_admin_vertical'] ?? data['identity_type'] ?? '').toString(),
        );
        await prefs.setString(
          'sub_admin_email',
          (data['claim_value'] ?? e.identifier).toString(),
        );
        emit(
          state.copyWith(
            authStatus: SubAdminAuthStatus.success,
            authSuccess: 'Login successful!',
            subAdminName: (data['display_name'] ?? 'Sub-Admin').toString(),
          ),
        );
      } else {
        emit(
          state.copyWith(
            authStatus: SubAdminAuthStatus.error,
            authError: 'Invalid response from server',
          ),
        );
      }
    } catch (ex) {
      var msg = ex.toString().replaceAll('Exception: ', '');
      if (msg.contains('401') || msg.contains('Unauthorized')) {
        msg =
            'Invalid credentials. Please check your email/phone and password.';
      }
      emit(
        state.copyWith(authStatus: SubAdminAuthStatus.error, authError: msg),
      );
    }
  }

  void _onTogglePwd(TogglePasswordVisibility e, Emitter<SubAdminState> emit) =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  // ═══════════════════ Dashboard ═══════════════════

  Future<void> _onBoot(
    BootstrapDashboard e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(dashStatus: SubAdminViewStatus.loading));
    final p = await SharedPreferences.getInstance();
    final name = p.getString('sub_admin_name') ?? 'Sub-Admin';
    emit(state.copyWith(subAdminName: name));
    add(const LoadDashboardMetrics());
    add(const FetchBusCompanies());
  }

  Future<void> _onMetrics(
    LoadDashboardMetrics e,
    Emitter<SubAdminState> emit,
  ) async {
    try {
      final r = await _api.get(
        '${ApiConfig.apiBaseUrl}/admin/analytics/dashboard',
      );
      final d = r?['data'];
      int tenants = 0;
      List<String> features = [];
      double revenue = 0;
      if (d is Map<String, dynamic>) {
        tenants = (d['tenant_count'] ?? 0).toInt();
        features =
            (d['features'] as List?)?.map((f) => f.toString()).toList() ?? [];
        revenue = (d['monthly_revenue'] ?? 0).toDouble();
      }
      emit(
        state.copyWith(
          dashStatus: SubAdminViewStatus.loaded,
          tenantCount: tenants,
          activeFeatures: features,
          monthlyRevenue: revenue,
        ),
      );
    } catch (_) {
      emit(state.copyWith(dashStatus: SubAdminViewStatus.loaded));
    }
  }

  // ═══════════════════ Bus Company Management ═══════════════════

  Future<void> _onCreateBusCo(
    CreateBusCompany e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(
      state.copyWith(
        busFormLoading: true,
        busFormError: null,
        busFormSuccess: null,
      ),
    );
    try {
      await _api.post(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/create',
        data: {
          'company_name': e.name,
          'email': e.email,
          'password': e.password,
          'phone': e.phone,
          'registration_code': e.regCode,
          'fleet_size': e.fleetSize,
          'transit_license': e.license,
        },
      );
      emit(
        state.copyWith(
          busFormLoading: false,
          busFormSuccess: 'Company created',
        ),
      );
      add(const FetchBusCompanies());
    } catch (ex) {
      emit(state.copyWith(busFormLoading: false, busFormError: ex.toString()));
    }
  }

  Future<void> _onFetchBusCos(
    FetchBusCompanies e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(busListLoading: true));
    try {
      final r = await _api.get('${ApiConfig.apiBaseUrl}/admin/bus-companies');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : (d is Map
                ? (d['companies'] as List?)?.cast<Map<String, dynamic>>() ??
                      (d['data'] as List?)?.cast<Map<String, dynamic>>() ??
                      []
                : []);
      emit(state.copyWith(busCompanies: list, busListLoading: false));
    } catch (ex) {
      emit(state.copyWith(busListLoading: false, busListError: ex.toString()));
    }
  }

  Future<void> _onToggleBusCo(
    ToggleBusCompanyStatus e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      // Use explicit status update: toggle between active and suspended
      final company = state.busCompanies.firstWhere(
        (c) => c['id']?.toString() == e.companyId,
        orElse: () => <String, dynamic>{},
      );
      final currentStatus = company['status']?.toString() ?? 'active';
      final newStatus = currentStatus == 'active' ? 'suspended' : 'active';

      await _api.patch(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/${e.companyId}/status',
        data: {'status': newStatus},
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Status updated'),
      );
      add(const FetchBusCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onUpdateBusCoStatus(
    UpdateBusCompanyStatus e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.patch(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/${e.companyId}/status',
        data: {'status': e.newStatus},
      );
      emit(
        state.copyWith(
          actionLoading: false,
          actionSuccess: 'Status set to ${e.newStatus}',
        ),
      );
      add(const FetchBusCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onEditBusCo(
    EditBusCompany e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      // Map frontend field names to backend field names
      final body = <String, dynamic>{};
      if (e.data['name'] != null) body['company_name'] = e.data['name'];
      if (e.data['email'] != null) body['email'] = e.data['email'];
      if (e.data['phone'] != null) body['phone'] = e.data['phone'];
      if (e.data['registration_code'] != null)
        body['registration_code'] = e.data['registration_code'];
      if (e.data['fleet_size'] != null)
        body['fleet_size'] = e.data['fleet_size'];
      if (e.data['license'] != null)
        body['transit_license'] = e.data['license'];
      // Only include password if non-empty (otherwise backend keeps existing)
      if (e.data['password'] != null &&
          (e.data['password'] as String).isNotEmpty) {
        body['password'] = e.data['password'];
      }

      await _api.put(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/${e.companyId}',
        data: body,
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Company updated'),
      );
      add(const FetchBusCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onResetBusCoPwd(
    ResetBusCompanyPassword e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.put(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/${e.companyId}',
        data: {'password': e.newPassword},
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Password reset'),
      );
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onDelBusCo(
    DeleteBusCompany e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.delete(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/${e.companyId}',
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Company deleted'),
      );
      add(const FetchBusCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onRestoreBusCo(
    RestoreBusCompany e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.patch(
        '${ApiConfig.apiBaseUrl}/admin/bus-companies/${e.companyId}/restore',
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Company restored'),
      );
      add(const FetchBusCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  // ═══════════════════ Sub-Admin Management ═══════════════════

  Future<void> _onFetchAdmins(
    FetchSubAdmins e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(subAdminListLoading: true));
    try {
      final r = await _api.get('${ApiConfig.apiBaseUrl}/admin/sub-admins');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : (d is Map && d['data'] is List
                ? (d['data'] as List).cast<Map<String, dynamic>>()
                : []);
      emit(state.copyWith(subAdmins: list, subAdminListLoading: false));
    } catch (ex) {
      emit(
        state.copyWith(
          subAdminListLoading: false,
          subAdminListError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateAdmin(
    CreateSubAdmin e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true, actionError: null));
    try {
      await _api.post(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/create',
        data: {
          'name': e.name,
          'email': e.email,
          'phone': e.phone,
          'cnic': e.cnic,
          'vertical': e.vertical,
          'password': e.password,
          'can_access_studio': e.canAccessStudio,
        },
      );
      emit(
        state.copyWith(
          actionLoading: false,
          actionSuccess: 'Sub-Admin created',
        ),
      );
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  void _onToggleStudio(
    ToggleStudioAccess e,
    Emitter<SubAdminState> emit,
  ) {
    emit(state.copyWith(canAccessStudio: e.value));
  }

  Future<void> _onToggleAdmin(
    ToggleSubAdminStatus e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.post(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}/toggle-status',
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Status updated'),
      );
      add(const FetchSubAdmins());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onEditAdmin(EditSubAdmin e, Emitter<SubAdminState> emit) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.put(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}',
        data: e.data,
      );
      emit(
        state.copyWith(
          actionLoading: false,
          actionSuccess: 'Sub-Admin updated',
        ),
      );
      add(const FetchSubAdmins());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onChangeVert(
    ChangeSubAdminVertical e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.post(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}/change-vertical',
        data: {'vertical': e.newVertical},
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Vertical changed'),
      );
      add(const FetchSubAdmins());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onResetAdminPwd(
    ResetSubAdminPassword e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.post(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}/reset-password',
        data: {'password': e.newPassword},
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Password reset'),
      );
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onDelAdmin(
    DeleteSubAdmin e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.delete(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}',
      );
      emit(
        state.copyWith(
          actionLoading: false,
          actionSuccess: 'Sub-Admin deleted',
        ),
      );
      add(const FetchSubAdmins());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onRestoreAdmin(
    RestoreSubAdmin e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.post(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}/restore',
      );
      emit(
        state.copyWith(
          actionLoading: false,
          actionSuccess: 'Sub-Admin restored',
        ),
      );
      add(const FetchSubAdmins());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  // ═══════════════════ Logout / Clear ═══════════════════

  Future<void> _onLogout(SubAdminLogout e, Emitter<SubAdminState> emit) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('sub_admin_token');
    await p.remove('sub_admin_name');
    await p.remove('sub_admin_vertical');
    await p.remove('sub_admin_email');
  }

  void _onClear(ClearSubAdminError e, Emitter<SubAdminState> emit) => emit(
    state.copyWith(
      actionError: null,
      actionSuccess: null,
      authError: null,
      busFormError: null,
    ),
  );
}
