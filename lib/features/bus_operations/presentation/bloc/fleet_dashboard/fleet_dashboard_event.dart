// Fleet Dashboard Events — events for bus-fleet panel dashboard
import 'package:equatable/equatable.dart';

abstract class FleetDashboardEvent extends Equatable {
  const FleetDashboardEvent();
  @override
  List<Object?> get props => [];
}

class BootstrapDashboard extends FleetDashboardEvent {
  final String storagePrefix, panelPrefix, loginRoute;
  const BootstrapDashboard({
    required this.storagePrefix,
    required this.panelPrefix,
    required this.loginRoute,
  });
  @override
  List<Object?> get props => [storagePrefix, panelPrefix, loginRoute];
}

class FetchDashboardMetrics extends FleetDashboardEvent {
  final String panelPrefix;
  const FetchDashboardMetrics({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class LoadDrivers extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadDrivers({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class LoadConductors extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadConductors({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class LoadLayouts extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadLayouts({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class NavigateToPage extends FleetDashboardEvent {
  final String page;
  const NavigateToPage(this.page);
  @override
  List<Object?> get props => [page];
}

class LogoutRequested extends FleetDashboardEvent {
  final String storagePrefix;
  const LogoutRequested({required this.storagePrefix});
  @override
  List<Object?> get props => [storagePrefix];
}

class RegisterStaff extends FleetDashboardEvent {
  final String panelPrefix, role;
  final Map<String, dynamic> data;
  const RegisterStaff({
    required this.panelPrefix,
    required this.role,
    required this.data,
  });
  @override
  List<Object?> get props => [panelPrefix, role, data];
}

class RemoveStaff extends FleetDashboardEvent {
  final String panelPrefix, staffId, role;
  const RemoveStaff({
    required this.panelPrefix,
    required this.staffId,
    required this.role,
  });
  @override
  List<Object?> get props => [panelPrefix, staffId, role];
}

class ClearStaffError extends FleetDashboardEvent {
  const ClearStaffError();
}

class PublishLayout extends FleetDashboardEvent {
  final String panelPrefix, layoutId, name;
  const PublishLayout({
    required this.panelPrefix,
    required this.layoutId,
    required this.name,
  });
  @override
  List<Object?> get props => [panelPrefix, layoutId, name];
}

class ArchiveLayout extends FleetDashboardEvent {
  final String panelPrefix, layoutId, name;
  const ArchiveLayout({
    required this.panelPrefix,
    required this.layoutId,
    required this.name,
  });
  @override
  List<Object?> get props => [panelPrefix, layoutId, name];
}

class DeleteLayout extends FleetDashboardEvent {
  final String panelPrefix, layoutId, name;
  const DeleteLayout({
    required this.panelPrefix,
    required this.layoutId,
    required this.name,
  });
  @override
  List<Object?> get props => [panelPrefix, layoutId, name];
}

class PurgeAllLayouts extends FleetDashboardEvent {
  final String panelPrefix;
  const PurgeAllLayouts({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class ClearLayoutError extends FleetDashboardEvent {
  const ClearLayoutError();
}

// ── Carrier Link ──────────────────────────────────────

class LoadCarrierLink extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadCarrierLink({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class AcceptCarrierRequest extends FleetDashboardEvent {
  final String panelPrefix, assignmentId;
  const AcceptCarrierRequest({
    required this.panelPrefix,
    required this.assignmentId,
  });
  @override
  List<Object?> get props => [panelPrefix, assignmentId];
}

class RejectCarrierRequest extends FleetDashboardEvent {
  final String panelPrefix, assignmentId;
  const RejectCarrierRequest({
    required this.panelPrefix,
    required this.assignmentId,
  });
  @override
  List<Object?> get props => [panelPrefix, assignmentId];
}

class UnlinkCarrier extends FleetDashboardEvent {
  final String panelPrefix, assignmentId;
  const UnlinkCarrier({required this.panelPrefix, required this.assignmentId});
  @override
  List<Object?> get props => [panelPrefix, assignmentId];
}

// ── Chat Inbox ────────────────────────────────────────

class LoadInboxMessages extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadInboxMessages({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class LoadConversation extends FleetDashboardEvent {
  final String panelPrefix, assignmentId;
  const LoadConversation({
    required this.panelPrefix,
    required this.assignmentId,
  });
  @override
  List<Object?> get props => [panelPrefix, assignmentId];
}

class SendChatMessage extends FleetDashboardEvent {
  final String panelPrefix, assignmentId, message;
  const SendChatMessage({
    required this.panelPrefix,
    required this.assignmentId,
    required this.message,
  });
  @override
  List<Object?> get props => [panelPrefix, assignmentId, message];
}

class ClearChatError extends FleetDashboardEvent {
  const ClearChatError();
}
