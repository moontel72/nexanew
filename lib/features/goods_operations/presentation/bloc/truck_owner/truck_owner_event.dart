// Truck Owner Dashboard Events
import 'package:equatable/equatable.dart';

abstract class TruckOwnerEvent extends Equatable {
  const TruckOwnerEvent();
  @override
  List<Object?> get props => [];
}

class BootstrapTruckOwner extends TruckOwnerEvent {
  final String storagePrefix, panelPrefix, loginRoute;
  const BootstrapTruckOwner({
    required this.storagePrefix,
    required this.panelPrefix,
    required this.loginRoute,
  });
  @override
  List<Object?> get props => [storagePrefix, panelPrefix, loginRoute];
}

class FetchTruckOwnerMetrics extends TruckOwnerEvent {
  const FetchTruckOwnerMetrics();
}

class LoadTruckDrivers extends TruckOwnerEvent {
  const LoadTruckDrivers();
}

class LoadTruckConductors extends TruckOwnerEvent {
  const LoadTruckConductors();
}

class LoadTruckVehicles extends TruckOwnerEvent {
  const LoadTruckVehicles();
}

class LoadTruckFreightLoads extends TruckOwnerEvent {
  const LoadTruckFreightLoads();
}

class NavigateTruckOwnerPage extends TruckOwnerEvent {
  final String page;
  const NavigateTruckOwnerPage(this.page);
  @override
  List<Object?> get props => [page];
}

class TruckOwnerLogout extends TruckOwnerEvent {
  final String storagePrefix;
  const TruckOwnerLogout(this.storagePrefix);
  @override
  List<Object?> get props => [storagePrefix];
}

// Staff CRUD
class RegisterTruckStaff extends TruckOwnerEvent {
  final String role;
  final Map<String, dynamic> data;
  const RegisterTruckStaff({required this.role, required this.data});
  @override
  List<Object?> get props => [role, data];
}

class RemoveTruckStaff extends TruckOwnerEvent {
  final String staffId, role;
  const RemoveTruckStaff({required this.staffId, required this.role});
  @override
  List<Object?> get props => [staffId, role];
}

// Vehicle actions
class AddTruckVehicle extends TruckOwnerEvent {
  final Map<String, dynamic> data;
  const AddTruckVehicle(this.data);
  @override
  List<Object?> get props => [data];
}

class RemoveTruckVehicle extends TruckOwnerEvent {
  final String vehicleId;
  const RemoveTruckVehicle(this.vehicleId);
  @override
  List<Object?> get props => [vehicleId];
}

// Carrier link
class LoadTruckLinkStatus extends TruckOwnerEvent {
  const LoadTruckLinkStatus();
}

class SearchTruckCompanies extends TruckOwnerEvent {
  final String query;
  const SearchTruckCompanies(this.query);
  @override
  List<Object?> get props => [query];
}

class SendTruckLinkRequest extends TruckOwnerEvent {
  final String companyId;
  final String? message;
  const SendTruckLinkRequest({required this.companyId, this.message});
  @override
  List<Object?> get props => [companyId, message];
}

class CancelTruckLinkRequest extends TruckOwnerEvent {
  final String assignmentId;
  const CancelTruckLinkRequest(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}

class LeaveTruckCarrier extends TruckOwnerEvent {
  final String assignmentId;
  const LeaveTruckCarrier(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}

class ClearTruckOwnerError extends TruckOwnerEvent {
  const ClearTruckOwnerError();
}

// Chat inbox
class LoadTruckInbox extends TruckOwnerEvent {
  const LoadTruckInbox();
}

class LoadTruckConversation extends TruckOwnerEvent {
  final String assignmentId;
  const LoadTruckConversation(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}

class SendTruckMessage extends TruckOwnerEvent {
  final String assignmentId, message;
  const SendTruckMessage({required this.assignmentId, required this.message});
  @override
  List<Object?> get props => [assignmentId, message];
}
