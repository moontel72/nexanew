// Fleet Dispatch Events — events for multi-entity dispatch form
import 'package:equatable/equatable.dart';

abstract class DispatchEvent extends Equatable {
  const DispatchEvent();
  @override
  List<Object?> get props => [];
}

class InitDispatch extends DispatchEvent {
  final String apiPrefix;
  final String? busCompanyId;
  final String? routeId;
  const InitDispatch({
    required this.apiPrefix,
    this.busCompanyId,
    this.routeId,
  });
  @override
  List<Object?> get props => [apiPrefix, busCompanyId, routeId];
}

class SaveDispatch extends DispatchEvent {
  const SaveDispatch();
}

class SetDispatchField extends DispatchEvent {
  final String field;
  final dynamic value;
  const SetDispatchField(this.field, this.value);
  @override
  List<Object?> get props => [field, value];
}

class SetDispatchSet extends DispatchEvent {
  final String field;
  final Set<String> value;
  const SetDispatchSet(this.field, this.value);
  @override
  List<Object?> get props => [field, value];
}

class ResetDispatch extends DispatchEvent {
  const ResetDispatch();
}

class UpdateDispatch extends DispatchEvent {
  final String assignmentId;
  const UpdateDispatch(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}

class DeleteDispatch extends DispatchEvent {
  final String assignmentId;
  const DeleteDispatch(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}
