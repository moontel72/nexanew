import 'package:trace_odd/shared/models/company/company_model.dart';

class CompanyDocumentInput {
  final DocumentType type;
  final String name;
  final String fileUrl;
  final String? description;
  final DateTime? expiryDate;

  const CompanyDocumentInput({
    required this.type,
    required this.name,
    required this.fileUrl,
    this.description,
    this.expiryDate,
  });

  factory CompanyDocumentInput.fromJson(Map<String, dynamic> json) {
    return CompanyDocumentInput(
      type: DocumentType.values.firstWhere(
        (e) => e.name == (json['type']?.toString() ?? ''),
        orElse: () => DocumentType.other,
      ),
      name: json['name']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      description: json['description']?.toString(),
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'file_url': fileUrl,
      if (description != null) 'description': description,
      if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
    };
  }
}

