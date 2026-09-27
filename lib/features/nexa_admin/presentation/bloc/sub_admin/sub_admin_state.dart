// Sub-Admin States — auth + dashboard + management
import 'package:equatable/equatable.dart';

enum SubAdminAuthStatus { initial, loading, success, error }

enum SubAdminViewStatus { initial, loading, loaded, error }

class SubAdminState extends Equatable {
  // ── Auth ──
  final SubAdminAuthStatus authStatus;
  final bool obscurePassword;
  final String? authError;
  final String? authSuccess;

  // ── Dashboard ──
  final SubAdminViewStatus dashStatus;
  final String subAdminName;
  final String? dashError;
  final int tenantCount;
  final List<String> activeFeatures;
  final double monthlyRevenue;

  // ── Bus Company Form ──
  final bool busFormLoading;
  final bool busFormObscurePassword;
  final String? busFormError;
  final String? busFormSuccess;

  // ── Bus Company List ──
  final List<Map<String, dynamic>> busCompanies;
  final bool busListLoading;
  final String? busListError;

  // ── Factory Company Form ──
  final bool factoryFormLoading;
  final String? factoryFormError;
  final String? factoryFormSuccess;

  // ── Factory Company List ──
  final List<Map<String, dynamic>> factoryCompanies;
  final bool factoryListLoading;
  final String? factoryListError;

  // ── Reseller Account Form ──
  final bool resellerFormLoading;
  final String? resellerFormError;
  final String? resellerFormSuccess;

  // ── Reseller Account List ──
  final List<Map<String, dynamic>> resellerAccounts;
  final bool resellerListLoading;
  final String? resellerListError;

  // ── Sub-Admin Management (list screen) ──
  final List<Map<String, dynamic>> subAdmins;
  final bool subAdminListLoading;
  final String? subAdminListError;

  // ── Sub-Admin Action (add/edit/delete) ──
  final bool actionLoading;
  final String? actionError;
  final String? actionSuccess;

  // ── Sub-Admin Creation Form ──
  final bool canAccessStudio;

  const SubAdminState({
    this.authStatus = SubAdminAuthStatus.initial,
    this.obscurePassword = true,
    this.authError,
    this.authSuccess,
    this.dashStatus = SubAdminViewStatus.initial,
    this.subAdminName = 'Sub-Admin',
    this.dashError,
    this.tenantCount = 0,
    this.activeFeatures = const [],
    this.monthlyRevenue = 0,
    this.busFormLoading = false,
    this.busFormObscurePassword = true,
    this.busFormError,
    this.busFormSuccess,
    this.busCompanies = const [],
    this.busListLoading = false,
    this.busListError,
    this.factoryFormLoading = false,
    this.factoryFormError,
    this.factoryFormSuccess,
    this.factoryCompanies = const [],
    this.factoryListLoading = false,
    this.factoryListError,
    this.resellerFormLoading = false,
    this.resellerFormError,
    this.resellerFormSuccess,
    this.resellerAccounts = const [],
    this.resellerListLoading = false,
    this.resellerListError,
    this.subAdmins = const [],
    this.subAdminListLoading = false,
    this.subAdminListError,
    this.actionLoading = false,
    this.actionError,
    this.actionSuccess,
    this.canAccessStudio = false,
  });

  SubAdminState copyWith({
    SubAdminAuthStatus? authStatus,
    bool? obscurePassword,
    String? authError,
    String? authSuccess,
    SubAdminViewStatus? dashStatus,
    String? subAdminName,
    String? dashError,
    int? tenantCount,
    List<String>? activeFeatures,
    double? monthlyRevenue,
    bool? busFormLoading,
    bool? busFormObscurePassword,
    String? busFormError,
    String? busFormSuccess,
    List<Map<String, dynamic>>? busCompanies,
    bool? busListLoading,
    String? busListError,
    bool? factoryFormLoading,
    String? factoryFormError,
    String? factoryFormSuccess,
    List<Map<String, dynamic>>? factoryCompanies,
    bool? factoryListLoading,
    String? factoryListError,
    bool? resellerFormLoading,
    String? resellerFormError,
    String? resellerFormSuccess,
    List<Map<String, dynamic>>? resellerAccounts,
    bool? resellerListLoading,
    String? resellerListError,
    List<Map<String, dynamic>>? subAdmins,
    bool? subAdminListLoading,
    String? subAdminListError,
    bool? actionLoading,
    String? actionError,
    String? actionSuccess,
    bool? canAccessStudio,
  }) => SubAdminState(
    authStatus: authStatus ?? this.authStatus,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    authError: authError,
    authSuccess: authSuccess,
    dashStatus: dashStatus ?? this.dashStatus,
    subAdminName: subAdminName ?? this.subAdminName,
    dashError: dashError,
    tenantCount: tenantCount ?? this.tenantCount,
    activeFeatures: activeFeatures ?? this.activeFeatures,
    monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
    busFormLoading: busFormLoading ?? this.busFormLoading,
    busFormObscurePassword:
        busFormObscurePassword ?? this.busFormObscurePassword,
    busFormError: busFormError,
    busFormSuccess: busFormSuccess,
    busCompanies: busCompanies ?? this.busCompanies,
    busListLoading: busListLoading ?? this.busListLoading,
    busListError: busListError,
    factoryFormLoading: factoryFormLoading ?? this.factoryFormLoading,
    factoryFormError: factoryFormError,
    factoryFormSuccess: factoryFormSuccess,
    factoryCompanies: factoryCompanies ?? this.factoryCompanies,
    factoryListLoading: factoryListLoading ?? this.factoryListLoading,
    factoryListError: factoryListError,
    resellerFormLoading: resellerFormLoading ?? this.resellerFormLoading,
    resellerFormError: resellerFormError,
    resellerFormSuccess: resellerFormSuccess,
    resellerAccounts: resellerAccounts ?? this.resellerAccounts,
    resellerListLoading: resellerListLoading ?? this.resellerListLoading,
    resellerListError: resellerListError,
    subAdmins: subAdmins ?? this.subAdmins,
    subAdminListLoading: subAdminListLoading ?? this.subAdminListLoading,
    subAdminListError: subAdminListError,
    actionLoading: actionLoading ?? this.actionLoading,
    actionError: actionError,
    actionSuccess: actionSuccess,
    canAccessStudio: canAccessStudio ?? this.canAccessStudio,
  );

  @override
  List<Object?> get props => [
    authStatus,
    obscurePassword,
    authError,
    authSuccess,
    dashStatus,
    subAdminName,
    dashError,
    tenantCount,
    activeFeatures,
    monthlyRevenue,
    busFormLoading,
    busFormObscurePassword,
    busFormError,
    busFormSuccess,
    busCompanies,
    busListLoading,
    busListError,
    factoryFormLoading,
    factoryFormError,
    factoryFormSuccess,
    factoryCompanies,
    factoryListLoading,
    factoryListError,
    resellerFormLoading,
    resellerFormError,
    resellerFormSuccess,
    resellerAccounts,
    resellerListLoading,
    resellerListError,
    subAdmins,
    subAdminListLoading,
    subAdminListError,
    actionLoading,
    actionError,
    actionSuccess,
    canAccessStudio,
  ];
}
