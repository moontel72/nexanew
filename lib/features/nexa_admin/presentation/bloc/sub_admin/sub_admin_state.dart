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

  // ── Sub-Admin Management (list screen) ──
  final List<Map<String, dynamic>> subAdmins;
  final bool subAdminListLoading;
  final String? subAdminListError;

  // ── Sub-Admin Action (add/edit/delete) ──
  final bool actionLoading;
  final String? actionError;
  final String? actionSuccess;

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
    this.subAdmins = const [],
    this.subAdminListLoading = false,
    this.subAdminListError,
    this.actionLoading = false,
    this.actionError,
    this.actionSuccess,
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
    List<Map<String, dynamic>>? subAdmins,
    bool? subAdminListLoading,
    String? subAdminListError,
    bool? actionLoading,
    String? actionError,
    String? actionSuccess,
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
    busFormObscurePassword: busFormObscurePassword ?? this.busFormObscurePassword,
    busFormError: busFormError,
    busFormSuccess: busFormSuccess,
    busCompanies: busCompanies ?? this.busCompanies,
    busListLoading: busListLoading ?? this.busListLoading,
    busListError: busListError,
    subAdmins: subAdmins ?? this.subAdmins,
    subAdminListLoading: subAdminListLoading ?? this.subAdminListLoading,
    subAdminListError: subAdminListError,
    actionLoading: actionLoading ?? this.actionLoading,
    actionError: actionError,
    actionSuccess: actionSuccess,
  );

  @override
  List<Object?> get props => [
    authStatus, obscurePassword, authError, authSuccess,
    dashStatus, subAdminName, dashError, tenantCount, activeFeatures, monthlyRevenue,
    busFormLoading, busFormObscurePassword, busFormError, busFormSuccess,
    busCompanies, busListLoading, busListError,
    subAdmins, subAdminListLoading, subAdminListError,
    actionLoading, actionError, actionSuccess,
  ];
}
