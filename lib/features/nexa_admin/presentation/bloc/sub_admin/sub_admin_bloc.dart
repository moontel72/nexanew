// Sub-Admin Bloc — auth + dashboard + management
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
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
    on<CreateFactoryCompany>(_onCreateFactoryCo);
    on<FetchFactoryCompanies>(_onFetchFactoryCos);
    on<UpdateFactoryCompanyStatus>(_onUpdateFactoryCoStatus);
    on<EditFactoryCompany>(_onEditFactoryCo);
    on<ResetFactoryCompanyPassword>(_onResetFactoryCoPwd);
    on<DeleteFactoryCompany>(_onDelFactoryCo);
    on<RestoreFactoryCompany>(_onRestoreFactoryCo);
    on<CreateResellerAccount>(_onCreateResellerAccount);
    on<FetchResellerAccounts>(_onFetchResellerAccounts);
    on<UpdateResellerAccountStatus>(_onUpdateResellerAccountStatus);
    on<EditResellerAccount>(_onEditResellerAccount);
    on<DeleteResellerAccount>(_onDeleteResellerAccount);
    on<RestoreResellerAccount>(_onRestoreResellerAccount);
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
        // Keep the in-memory flag in step with the token, so the router's /sub-admin/* guard
        // lets this session through immediately (MASTER-TASK-LIST.md §17 step 5).
        setSubAdminAuthenticatedCache(true);
        await _api.setAuthToken(token);
        await prefs.setString(
          'sub_admin_name',
          (data['display_name'] ?? 'Sub-Admin').toString(),
        );
        // Only the resolved vertical code is meaningful here. Falling back to
        // `identity_type` (always 'sub_admin' for this endpoint) stored a value
        // that matched no vertical, so the dashboard silently fell through to
        // the bus default — see resolveSubAdminVertical() in the backend.
        await prefs.setString(
          'sub_admin_vertical',
          (data['sub_admin_vertical'] ?? '').toString(),
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
    // Load only the list this vertical's dashboard actually renders. The bus
    // list used to be fetched for EVERY vertical — a needless API call for
    // factory / marketplace, whose dashboards never show it.
    final vertical = p.getString('sub_admin_vertical') ?? '';
    if (vertical == 'factory') {
      // Factory panel (C2, MASTER-TASK-LIST.md §2b/§4).
      add(const FetchFactoryCompanies());
    } else if (vertical == 'commercial_marketplace') {
      // Marketplace panel (C2b, MASTER-TASK-LIST.md §2b).
      add(const FetchResellerAccounts());
    } else if (vertical == 'cricket_ops') {
      // The cricket dashboard loads its own managers on demand.
    } else {
      // bus_transit / goods_logistics / financial_auditor share the bus
      // dashboard, which lists bus companies.
      add(const FetchBusCompanies());
    }
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

  // ═══════════════ Factory Company Management ═══════════════

  Future<void> _onCreateFactoryCo(
    CreateFactoryCompany e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(
      state.copyWith(
        factoryFormLoading: true,
        factoryFormError: null,
        factoryFormSuccess: null,
      ),
    );
    try {
      await _api.post(
        '${ApiConfig.apiBaseUrl}/admin/factory-companies/create',
        data: {
          'name': e.name,
          'business_registration_number': e.regNumber,
          // One login per distinct email: the contact person IS the factory
          // admin, so `email` mirrors `contact_person_email`.
          'email': e.contactEmail,
          'password': e.password,
          'country': e.country,
          'city': e.city,
          'contact_person_name': e.contactName,
          'contact_person_email': e.contactEmail,
          'contact_person_phone': e.contactPhone,
          if (e.industryType.isNotEmpty) 'industry_type': e.industryType,
        },
      );
      emit(
        state.copyWith(
          factoryFormLoading: false,
          factoryFormSuccess: 'Company created',
        ),
      );
      add(const FetchFactoryCompanies());
    } catch (ex) {
      emit(
        state.copyWith(
          factoryFormLoading: false,
          factoryFormError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchFactoryCos(
    FetchFactoryCompanies e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(factoryListLoading: true));
    try {
      final r = await _api.get(
        '${ApiConfig.apiBaseUrl}/admin/factory-companies',
      );
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : (d is Map
                ? (d['companies'] as List?)?.cast<Map<String, dynamic>>() ??
                      (d['data'] as List?)?.cast<Map<String, dynamic>>() ??
                      []
                : []);
      emit(state.copyWith(factoryCompanies: list, factoryListLoading: false));
    } catch (ex) {
      emit(
        state.copyWith(
          factoryListLoading: false,
          factoryListError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateFactoryCoStatus(
    UpdateFactoryCompanyStatus e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.patch(
        '${ApiConfig.apiBaseUrl}/admin/factory-companies/${e.companyId}/status',
        data: {'status': e.newStatus},
      );
      emit(
        state.copyWith(
          actionLoading: false,
          actionSuccess: 'Status set to ${e.newStatus}',
        ),
      );
      add(const FetchFactoryCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onEditFactoryCo(
    EditFactoryCompany e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      // Map frontend field names to backend field names.
      final body = <String, dynamic>{};
      if (e.data['name'] != null) body['name'] = e.data['name'];
      if (e.data['business_registration_number'] != null)
        body['business_registration_number'] =
            e.data['business_registration_number'];
      if (e.data['industry_type'] != null)
        body['industry_type'] = e.data['industry_type'];
      if (e.data['contact_person_name'] != null)
        body['contact_person_name'] = e.data['contact_person_name'];
      if (e.data['contact_person_email'] != null) {
        body['contact_person_email'] = e.data['contact_person_email'];
        body['email'] = e.data['contact_person_email'];
      }
      if (e.data['contact_person_phone'] != null)
        body['contact_person_phone'] = e.data['contact_person_phone'];
      if (e.data['country'] != null) body['country'] = e.data['country'];
      if (e.data['city'] != null) body['city'] = e.data['city'];
      // Only include password if non-empty (otherwise backend keeps existing).
      if (e.data['password'] != null &&
          (e.data['password'] as String).isNotEmpty) {
        body['password'] = e.data['password'];
      }

      await _api.put(
        '${ApiConfig.apiBaseUrl}/admin/factory-companies/${e.companyId}',
        data: body,
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Company updated'),
      );
      add(const FetchFactoryCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onResetFactoryCoPwd(
    ResetFactoryCompanyPassword e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.put(
        '${ApiConfig.apiBaseUrl}/admin/factory-companies/${e.companyId}',
        data: {'password': e.newPassword},
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Password reset'),
      );
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onDelFactoryCo(
    DeleteFactoryCompany e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.delete(
        '${ApiConfig.apiBaseUrl}/admin/factory-companies/${e.companyId}',
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Company deleted'),
      );
      add(const FetchFactoryCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onRestoreFactoryCo(
    RestoreFactoryCompany e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.patch(
        '${ApiConfig.apiBaseUrl}/admin/factory-companies/${e.companyId}/restore',
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Company restored'),
      );
      add(const FetchFactoryCompanies());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  // ═══════════════ Reseller Account Management (C2b) ═══════════════

  Future<void> _onCreateResellerAccount(
    CreateResellerAccount e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(
      state.copyWith(
        resellerFormLoading: true,
        resellerFormError: null,
        resellerFormSuccess: null,
      ),
    );
    try {
      await _api.post(
        '${ApiConfig.apiBaseUrl}/admin/reseller-accounts/create',
        data: {
          'name': e.name,
          'business_name': e.businessName,
          'registration_no': e.registrationNo,
          'email': e.email,
          'phone': e.phone,
          'password': e.password,
          'city': e.city,
          if (e.address.isNotEmpty) 'address': e.address,
        },
      );
      emit(
        state.copyWith(
          resellerFormLoading: false,
          resellerFormSuccess: 'Account created',
        ),
      );
      add(const FetchResellerAccounts());
    } catch (ex) {
      emit(
        state.copyWith(
          resellerFormLoading: false,
          resellerFormError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchResellerAccounts(
    FetchResellerAccounts e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(resellerListLoading: true));
    try {
      final r = await _api.get(
        '${ApiConfig.apiBaseUrl}/admin/reseller-accounts',
      );
      final d = r?['data'];
      final List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : (d is Map
                ? (d['resellers'] as List?)?.cast<Map<String, dynamic>>() ??
                      (d['accounts'] as List?)?.cast<Map<String, dynamic>>() ??
                      (d['data'] as List?)?.cast<Map<String, dynamic>>() ??
                      []
                : []);
      emit(state.copyWith(resellerAccounts: list, resellerListLoading: false));
    } catch (ex) {
      emit(
        state.copyWith(
          resellerListLoading: false,
          resellerListError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateResellerAccountStatus(
    UpdateResellerAccountStatus e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.patch(
        '${ApiConfig.apiBaseUrl}/admin/reseller-accounts/${e.accountId}/status',
        data: {'status': e.newStatus},
      );
      emit(
        state.copyWith(
          actionLoading: false,
          actionSuccess: 'Status set to ${e.newStatus}',
        ),
      );
      add(const FetchResellerAccounts());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onEditResellerAccount(
    EditResellerAccount e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      // Map frontend field names to backend field names.
      final body = <String, dynamic>{};
      if (e.data['name'] != null) body['name'] = e.data['name'];
      if (e.data['business_name'] != null)
        body['business_name'] = e.data['business_name'];
      if (e.data['registration_no'] != null)
        body['registration_no'] = e.data['registration_no'];
      if (e.data['email'] != null) body['email'] = e.data['email'];
      if (e.data['phone'] != null) body['phone'] = e.data['phone'];
      if (e.data['city'] != null) body['city'] = e.data['city'];
      if (e.data['address'] != null) body['address'] = e.data['address'];
      // Only include password if non-empty (otherwise backend keeps existing).
      if (e.data['password'] != null &&
          (e.data['password'] as String).isNotEmpty) {
        body['password'] = e.data['password'];
      }

      await _api.put(
        '${ApiConfig.apiBaseUrl}/admin/reseller-accounts/${e.accountId}',
        data: body,
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Account updated'),
      );
      add(const FetchResellerAccounts());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onDeleteResellerAccount(
    DeleteResellerAccount e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.delete(
        '${ApiConfig.apiBaseUrl}/admin/reseller-accounts/${e.accountId}',
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Account deleted'),
      );
      add(const FetchResellerAccounts());
    } catch (ex) {
      emit(state.copyWith(actionLoading: false, actionError: ex.toString()));
    }
  }

  Future<void> _onRestoreResellerAccount(
    RestoreResellerAccount e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      await _api.patch(
        '${ApiConfig.apiBaseUrl}/admin/reseller-accounts/${e.accountId}/restore',
      );
      emit(
        state.copyWith(actionLoading: false, actionSuccess: 'Account restored'),
      );
      add(const FetchResellerAccounts());
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

  void _onToggleStudio(ToggleStudioAccess e, Emitter<SubAdminState> emit) {
    emit(state.copyWith(canAccessStudio: e.value));
  }

  Future<void> _onToggleAdmin(
    ToggleSubAdminStatus e,
    Emitter<SubAdminState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true));
    try {
      // Backend route is PATCH /admin/sub-admins/{id}/status (SubAdminController@toggleStatus).
      // This used to POST to /toggle-status, which does not exist — the action 404'd silently.
      await _api.patch(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}/status',
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
      // The backend changes a vertical through the SAME update endpoint
      // (SubAdminController@update reads a `vertical` key), so there is no
      // /change-vertical route — the old call 404'd.
      await _api.put(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}',
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
      // Password reset is the same update endpoint with a `password` key
      // (SubAdminController@update hashes via the model mutator) — the old
      // /reset-password POST did not exist.
      await _api.put(
        '${ApiConfig.apiBaseUrl}/admin/sub-admins/${e.adminId}',
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
      // Backend route is PATCH /admin/sub-admins/{id}/restore
      // (SubAdminController@restore); the old POST 405'd.
      await _api.patch(
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
    // Clear the in-memory flag too, or the router's guard would keep letting this session through
    // after logout (MASTER-TASK-LIST.md §17 step 5).
    setSubAdminAuthenticatedCache(false);
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
