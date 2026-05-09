part of 'unit_codes_bloc.dart';

/// Unit Codes Events
abstract class UnitCodesEvent extends Equatable {
  const UnitCodesEvent();

  @override
  List<Object?> get props => [];
}

/// Load unit codes event
class LoadUnitCodes extends UnitCodesEvent {
  const LoadUnitCodes();
}

/// Generate unit codes event
class GenerateUnitCodes extends UnitCodesEvent {
  final UnitCodeGenerationRequest request;
  final String? productId;
  final String? manufacturingDate;
  final String? expiryDate;
  final int? warrantyMonths;

  const GenerateUnitCodes(
    this.request, {
    this.productId,
    this.manufacturingDate,
    this.expiryDate,
    this.warrantyMonths,
  });

  @override
  List<Object?> get props => [
    request,
    productId,
    manufacturingDate,
    expiryDate,
    warrantyMonths,
  ];
}

/// Delete single unit code event
class DeleteUnitCode extends UnitCodesEvent {
  final String unitCodeId;

  const DeleteUnitCode(this.unitCodeId);

  @override
  List<Object?> get props => [unitCodeId];
}

/// Delete batch of unit codes event
class DeleteUnitCodeBatch extends UnitCodesEvent {
  final List<String> unitCodeIds;

  const DeleteUnitCodeBatch(this.unitCodeIds);

  @override
  List<Object?> get props => [unitCodeIds];
}

/// Link unit code to product event
class LinkUnitCodeToProduct extends UnitCodesEvent {
  final String unitCodeId;
  final String productId;
  final String productBatchNumber;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final int? warrantyMonths;

  const LinkUnitCodeToProduct({
    required this.unitCodeId,
    required this.productId,
    required this.productBatchNumber,
    this.manufacturingDate,
    this.expiryDate,
    this.warrantyMonths,
  });

  @override
  List<Object?> get props => [
    unitCodeId,
    productId,
    productBatchNumber,
    manufacturingDate,
    expiryDate,
    warrantyMonths,
  ];
}

/// Publish unit code event
class PublishUnitCode extends UnitCodesEvent {
  final String unitCodeId;

  const PublishUnitCode(this.unitCodeId);

  @override
  List<Object?> get props => [unitCodeId];
}

class PublishSelectedUnitCodes extends UnitCodesEvent {
  final String productId;
  final List<String> unitCodeIds;
  final String? productBatchNumber;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final int? warrantyMonths;

  const PublishSelectedUnitCodes({
    required this.productId,
    required this.unitCodeIds,
    this.productBatchNumber,
    this.manufacturingDate,
    this.expiryDate,
    this.warrantyMonths,
  });

  @override
  List<Object?> get props => [
    productId,
    unitCodeIds,
    productBatchNumber,
    manufacturingDate,
    expiryDate,
    warrantyMonths,
  ];
}

/// Deactivate unit code event
class DeactivateUnitCode extends UnitCodesEvent {
  final String unitCodeId;
  final String reason;

  const DeactivateUnitCode(this.unitCodeId, this.reason);

  @override
  List<Object?> get props => [unitCodeId, reason];
}

/// Search unit codes event
class SearchUnitCodes extends UnitCodesEvent {
  final String query;

  const SearchUnitCodes(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter unit codes event
class FilterUnitCodes extends UnitCodesEvent {
  final CodeStatus? status;
  final String? packetCode;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isMasterCode;
  final bool? isReportedFake;
  final bool? isBlocked;

  const FilterUnitCodes({
    this.status,
    this.packetCode,
    this.startDate,
    this.endDate,
    this.isMasterCode,
    this.isReportedFake,
    this.isBlocked,
  });

  @override
  List<Object?> get props => [
    status,
    packetCode,
    startDate,
    endDate,
    isMasterCode,
    isReportedFake,
    isBlocked,
  ];
}

/// Export unit codes event
class ExportUnitCodes extends UnitCodesEvent {
  final List<String> unitCodeIds;
  final String format; // 'csv', 'excel', 'pdf'

  const ExportUnitCodes(this.unitCodeIds, this.format);

  @override
  List<Object?> get props => [unitCodeIds, format];
}

/// Select unit code event
class SelectUnitCode extends UnitCodesEvent {
  final String unitCodeId;
  final bool isSelected;

  const SelectUnitCode(this.unitCodeId, this.isSelected);

  @override
  List<Object?> get props => [unitCodeId, isSelected];
}

/// Clear selection event
class ClearSelection extends UnitCodesEvent {
  const ClearSelection();
}

/// Refresh unit codes event
class RefreshUnitCodes extends UnitCodesEvent {
  const RefreshUnitCodes();
}

/// Verify unit code event
class VerifyUnitCode extends UnitCodesEvent {
  final String unitCodeId;
  final String verifiedBy;
  final String? verificationLocation;

  const VerifyUnitCode(
    this.unitCodeId,
    this.verifiedBy, {
    this.verificationLocation,
  });

  @override
  List<Object?> get props => [unitCodeId, verifiedBy, verificationLocation];
}

/// Report unit code as fake event
class ReportUnitCodeAsFake extends UnitCodesEvent {
  final String unitCodeId;
  final String reportedBy;
  final String reason;

  const ReportUnitCodeAsFake(this.unitCodeId, this.reportedBy, this.reason);

  @override
  List<Object?> get props => [unitCodeId, reportedBy, reason];
}

/// Block unit code event
class BlockUnitCode extends UnitCodesEvent {
  final String unitCodeId;
  final String blockedBy;
  final String reason;

  const BlockUnitCode(this.unitCodeId, this.blockedBy, this.reason);

  @override
  List<Object?> get props => [unitCodeId, blockedBy, reason];
}

/// Unblock unit code event
class UnblockUnitCode extends UnitCodesEvent {
  final String unitCodeId;
  final String unblockedBy;
  final String reason;

  const UnblockUnitCode(this.unitCodeId, this.unblockedBy, this.reason);

  @override
  List<Object?> get props => [unitCodeId, unblockedBy, reason];
}

/// Update unit code properties event
class UpdateUnitCodeProperties extends UnitCodesEvent {
  final String unitCodeId;
  final String? model;
  final String? serialNumber;
  final String? metadata;

  const UpdateUnitCodeProperties({
    required this.unitCodeId,
    this.model,
    this.serialNumber,
    this.metadata,
  });

  @override
  List<Object?> get props => [unitCodeId, model, serialNumber, metadata];
}

/// Generate master authentication code event
class GenerateMasterAuthenticationCode extends UnitCodesEvent {
  final String unitCodeId;
  final int length;

  const GenerateMasterAuthenticationCode(this.unitCodeId, this.length);

  @override
  List<Object?> get props => [unitCodeId, length];
}

/// Reset verification count event
class ResetVerificationCount extends UnitCodesEvent {
  final String unitCodeId;

  const ResetVerificationCount(this.unitCodeId);

  @override
  List<Object?> get props => [unitCodeId];
}

/// Get unit code verification history event
class GetVerificationHistory extends UnitCodesEvent {
  final String unitCodeId;

  const GetVerificationHistory(this.unitCodeId);

  @override
  List<Object?> get props => [unitCodeId];
}
