/// Domain model for a reconciliation record.
class CateringReconciliation {
  final String id;
  final String companyId;
  final String issuanceId;
  final String storekeeperId;
  final int totalIssuedValuePaisa;
  final int totalReturnedValuePaisa;
  final int totalSoldValuePaisa;
  final int variancePaisa;
  final String status; // draft | confirmed | disputed
  final String? notes;
  final DateTime? reconciledAt;
  final DateTime createdAt;

  const CateringReconciliation({
    required this.id,
    required this.companyId,
    required this.issuanceId,
    required this.storekeeperId,
    this.totalIssuedValuePaisa = 0,
    this.totalReturnedValuePaisa = 0,
    this.totalSoldValuePaisa = 0,
    this.variancePaisa = 0,
    this.status = 'draft',
    this.notes,
    this.reconciledAt,
    required this.createdAt,
  });

  bool get isDraft => status == 'draft';
  bool get isConfirmed => status == 'confirmed';

  factory CateringReconciliation.fromJson(Map<String, dynamic> json) {
    return CateringReconciliation(
      id: json['id'] ?? '',
      companyId: json['company_id'] ?? '',
      issuanceId: json['issuance_id'] ?? '',
      storekeeperId: json['storekeeper_id'] ?? '',
      totalIssuedValuePaisa: _parseInt(json['total_issued_value_paisa']),
      totalReturnedValuePaisa: _parseInt(json['total_returned_value_paisa']),
      totalSoldValuePaisa: _parseInt(json['total_sold_value_paisa']),
      variancePaisa: _parseInt(json['variance_paisa']),
      status: json['status'] ?? 'draft',
      notes: json['notes'],
      reconciledAt: json['reconciled_at'] != null ? DateTime.tryParse(json['reconciled_at']) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }
}
