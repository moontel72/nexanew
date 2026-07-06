// Storekeeper Events
import 'package:equatable/equatable.dart';

abstract class StorekeeperEvent extends Equatable {
  const StorekeeperEvent();
  @override
  List<Object?> get props => [];
}

class LoadStorekeeperDashboard extends StorekeeperEvent {
  final String panel;
  const LoadStorekeeperDashboard({required this.panel});
  @override
  List<Object?> get props => [panel];
}

class RefreshStorekeeperData extends StorekeeperEvent {
  final String panel;
  const RefreshStorekeeperData({required this.panel});
  @override
  List<Object?> get props => [panel];
}

// Catering
class LoadCategories extends StorekeeperEvent {
  final String panel;
  const LoadCategories({required this.panel});
  @override
  List<Object?> get props => [panel];
}

class LoadItems extends StorekeeperEvent {
  final String panel;
  final String? categoryId;
  final int page;
  final String search;
  const LoadItems({
    required this.panel,
    this.categoryId,
    this.page = 1,
    this.search = '',
  });
  @override
  List<Object?> get props => [panel, categoryId, page, search];
}

class CreateCategory extends StorekeeperEvent {
  final String panel;
  final Map<String, dynamic> data;
  const CreateCategory({required this.panel, required this.data});
  @override
  List<Object?> get props => [panel, data];
}

class CreateItem extends StorekeeperEvent {
  final String panel;
  final Map<String, dynamic> data;
  const CreateItem({required this.panel, required this.data});
  @override
  List<Object?> get props => [panel, data];
}

class DeleteCategory extends StorekeeperEvent {
  final String panel;
  final String id;
  const DeleteCategory({required this.panel, required this.id});
  @override
  List<Object?> get props => [panel, id];
}

class DeleteItem extends StorekeeperEvent {
  final String panel;
  final String id;
  const DeleteItem({required this.panel, required this.id});
  @override
  List<Object?> get props => [panel, id];
}

// Issuance
class CreateIssuance extends StorekeeperEvent {
  final String panel;
  final Map<String, dynamic> data;
  const CreateIssuance({required this.panel, required this.data});
  @override
  List<Object?> get props => [panel, data];
}

class IssueItems extends StorekeeperEvent {
  final String panel;
  final String issuanceId;
  const IssueItems({required this.panel, required this.issuanceId});
  @override
  List<Object?> get props => [panel, issuanceId];
}

// Reconciliation
class ReconcileIssuance extends StorekeeperEvent {
  final String panel;
  final String issuanceId;
  final Map<String, dynamic> data;
  const ReconcileIssuance({
    required this.panel,
    required this.issuanceId,
    required this.data,
  });
  @override
  List<Object?> get props => [panel, issuanceId, data];
}

// Bundle
class CreateBundle extends StorekeeperEvent {
  final String panel;
  final Map<String, dynamic> data;
  const CreateBundle({required this.panel, required this.data});
  @override
  List<Object?> get props => [panel, data];
}

class ClearStorekeeperError extends StorekeeperEvent {
  const ClearStorekeeperError();
}
