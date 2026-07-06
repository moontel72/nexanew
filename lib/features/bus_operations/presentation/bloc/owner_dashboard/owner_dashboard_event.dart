// Owner Dashboard Events — events for bus-owner panel
import 'package:equatable/equatable.dart';

abstract class OwnerDashboardEvent extends Equatable {
  const OwnerDashboardEvent();
  @override
  List<Object?> get props => [];
}

class BootstrapOwner extends OwnerDashboardEvent {
  final String storagePrefix, panelPrefix, loginRoute;
  const BootstrapOwner({
    required this.storagePrefix,
    required this.panelPrefix,
    required this.loginRoute,
  });
  @override
  List<Object?> get props => [storagePrefix, panelPrefix, loginRoute];
}

class FetchOwnerMetrics extends OwnerDashboardEvent {
  const FetchOwnerMetrics();
}

class LoadOwnerDrivers extends OwnerDashboardEvent {
  const LoadOwnerDrivers();
}

class LoadOwnerConductors extends OwnerDashboardEvent {
  const LoadOwnerConductors();
}

class LoadOwnerLayouts extends OwnerDashboardEvent {
  const LoadOwnerLayouts();
}

class NavigateOwnerPage extends OwnerDashboardEvent {
  final String page;
  const NavigateOwnerPage(this.page);
  @override
  List<Object?> get props => [page];
}

class OwnerLogout extends OwnerDashboardEvent {
  final String storagePrefix;
  const OwnerLogout(this.storagePrefix);
  @override
  List<Object?> get props => [storagePrefix];
}

// Staff CRUD
class RegisterOwnerStaff extends OwnerDashboardEvent {
  final String role;
  final Map<String, dynamic> data;
  const RegisterOwnerStaff({required this.role, required this.data});
  @override
  List<Object?> get props => [role, data];
}

class RemoveOwnerStaff extends OwnerDashboardEvent {
  final String staffId, role;
  const RemoveOwnerStaff({required this.staffId, required this.role});
  @override
  List<Object?> get props => [staffId, role];
}

// Layout actions
class PublishOwnerLayout extends OwnerDashboardEvent {
  final String layoutId, name;
  const PublishOwnerLayout({required this.layoutId, required this.name});
  @override
  List<Object?> get props => [layoutId, name];
}

class ArchiveOwnerLayout extends OwnerDashboardEvent {
  final String layoutId, name;
  const ArchiveOwnerLayout({required this.layoutId, required this.name});
  @override
  List<Object?> get props => [layoutId, name];
}

class DeleteOwnerLayout extends OwnerDashboardEvent {
  final String layoutId, name;
  const DeleteOwnerLayout({required this.layoutId, required this.name});
  @override
  List<Object?> get props => [layoutId, name];
}

// Carrier link (owner-side)
class LoadOwnerLinkStatus extends OwnerDashboardEvent {
  const LoadOwnerLinkStatus();
}

class SearchCompanies extends OwnerDashboardEvent {
  final String query;
  const SearchCompanies(this.query);
  @override
  List<Object?> get props => [query];
}

class SendLinkRequest extends OwnerDashboardEvent {
  final String companyId;
  final String? message;
  const SendLinkRequest({required this.companyId, this.message});
  @override
  List<Object?> get props => [companyId, message];
}

class CancelLinkRequest extends OwnerDashboardEvent {
  final String assignmentId;
  const CancelLinkRequest(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}

class LeaveCarrier extends OwnerDashboardEvent {
  final String assignmentId;
  const LeaveCarrier(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}

class ClearOwnerError extends OwnerDashboardEvent {
  const ClearOwnerError();
}

// Chat inbox
class LoadOwnerInbox extends OwnerDashboardEvent {
  const LoadOwnerInbox();
}

class LoadOwnerConversation extends OwnerDashboardEvent {
  final String assignmentId;
  const LoadOwnerConversation(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}

class SendOwnerMessage extends OwnerDashboardEvent {
  final String assignmentId, message;
  const SendOwnerMessage({required this.assignmentId, required this.message});
  @override
  List<Object?> get props => [assignmentId, message];
}
