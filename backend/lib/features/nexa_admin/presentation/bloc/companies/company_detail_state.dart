part of 'company_detail_bloc.dart';

// Company Detail State for NexaTrace System
// States for CompanyDetailBloc

abstract class CompanyDetailState extends Equatable {
  const CompanyDetailState();

  @override
  List<Object> get props => [];
}

/// Initial state
class CompanyDetailInitial extends CompanyDetailState {}

/// Loading company details
class CompanyDetailLoading extends CompanyDetailState {}

/// Company details loaded successfully
class CompanyDetailLoaded extends CompanyDetailState {
  final Map<String, dynamic> company;
  final CompanyDetailData? additionalData;

  const CompanyDetailLoaded({required this.company, this.additionalData});

  @override
  List<Object> get props => [company, ?additionalData];
}

/// Error loading company details
class CompanyDetailError extends CompanyDetailState {
  final String message;
  final String? errorCode;

  const CompanyDetailError({required this.message, this.errorCode});

  @override
  List<Object> get props => [message, ?errorCode];
}

/// Company updated successfully
class CompanyDetailUpdated extends CompanyDetailState {
  final Map<String, dynamic> company;
  final String message;

  const CompanyDetailUpdated({required this.company, required this.message});

  @override
  List<Object> get props => [company, message];
}

/// Company status updated successfully
class CompanyStatusUpdated extends CompanyDetailState {
  final String companyId;
  final String newStatus;
  final String message;

  const CompanyStatusUpdated({
    required this.companyId,
    required this.newStatus,
    required this.message,
  });

  @override
  List<Object> get props => [companyId, newStatus, message];
}

/// Company verification status updated successfully
class CompanyVerificationUpdated extends CompanyDetailState {
  final String companyId;
  final String newVerificationStatus;
  final String message;

  const CompanyVerificationUpdated({
    required this.companyId,
    required this.newVerificationStatus,
    required this.message,
  });

  @override
  List<Object> get props => [companyId, newVerificationStatus, message];
}

/// Company deleted successfully
class CompanyDeleted extends CompanyDetailState {
  final String companyId;
  final String message;

  const CompanyDeleted({required this.companyId, required this.message});

  @override
  List<Object> get props => [companyId, message];
}

/// Additional data for company detail
class CompanyDetailData {
  final Map<String, dynamic>? statistics;
  final List<Map<String, dynamic>>? recentActivities;
  final List<Map<String, dynamic>>? subscriptionHistory;
  final List<Map<String, dynamic>>? users;

  const CompanyDetailData({
    this.statistics,
    this.recentActivities,
    this.subscriptionHistory,
    this.users,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyDetailData &&
          runtimeType == other.runtimeType &&
          statistics == other.statistics &&
          recentActivities == other.recentActivities &&
          subscriptionHistory == other.subscriptionHistory &&
          users == other.users;

  @override
  int get hashCode =>
      statistics.hashCode ^
      recentActivities.hashCode ^
      subscriptionHistory.hashCode ^
      users.hashCode;
}
