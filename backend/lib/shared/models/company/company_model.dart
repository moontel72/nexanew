// File: lib/features/nexa_admin/data/models/company/company_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../subscription/plan_model.dart';
import '../subscription/plan_type.dart';

part 'company_model.freezed.dart';

// ============================================================================
// HELPER FUNCTIONS FOR DEFENSIVE JSON PARSING
// ============================================================================

/// Helper function to safely parse DateTime with fallback
dynamic _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  try {
    if (value is String) {
      return DateTime.tryParse(value);
    }
  } catch (_) {
    // Fall through to return null
  }
  return null;
}

/// Helper function to parse CompanyStatus with fallback
CompanyStatus _parseCompanyStatus(dynamic value) {
  if (value == null) return CompanyStatus.pending;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'pending':
      return CompanyStatus.pending;
    case 'active':
      return CompanyStatus.active;
    case 'suspended':
      return CompanyStatus.suspended;
    case 'rejected':
      return CompanyStatus.rejected;
    case 'trial':
      return CompanyStatus.trial;
    case 'archived':
      return CompanyStatus.archived;
    default:
      return CompanyStatus.pending;
  }
}

/// Helper function to parse CompanyType with fallback
CompanyType _parseCompanyType(dynamic value) {
  if (value == null) return CompanyType.other;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'manufacturing':
      return CompanyType.manufacturing;
    case 'distributor':
      return CompanyType.distributor;
    case 'retailer':
      return CompanyType.retailer;
    case 'pharmaceutical':
      return CompanyType.pharmaceutical;
    case 'foodbeverage':
    case 'food_beverage':
      return CompanyType.foodBeverage;
    case 'textile':
      return CompanyType.textile;
    case 'electronics':
      return CompanyType.electronics;
    case 'other':
      return CompanyType.other;
    default:
      return CompanyType.other;
  }
}

/// Helper function to parse IndustryType with fallback
IndustryType _parseIndustryType(dynamic value) {
  if (value == null) return IndustryType.other;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'pharmaceutical':
      return IndustryType.pharmaceutical;
    case 'foodbeverage':
    case 'food_beverage':
      return IndustryType.foodBeverage;
    case 'textile':
      return IndustryType.textile;
    case 'electronics':
      return IndustryType.electronics;
    case 'automotive':
      return IndustryType.automotive;
    case 'chemical':
      return IndustryType.chemical;
    case 'construction':
      return IndustryType.construction;
    case 'agriculture':
      return IndustryType.agriculture;
    case 'other':
      return IndustryType.other;
    default:
      return IndustryType.other;
  }
}

/// Helper function to parse VerificationStatus with fallback
VerificationStatus _parseVerificationStatus(dynamic value) {
  if (value == null) return VerificationStatus.notSubmitted;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'notsubmitted':
    case 'not_submitted':
      return VerificationStatus.notSubmitted;
    case 'submitted':
      return VerificationStatus.submitted;
    case 'underreview':
    case 'under_review':
      return VerificationStatus.underReview;
    case 'verified':
      return VerificationStatus.verified;
    case 'rejected':
      return VerificationStatus.rejected;
    case 'requiresadditional':
    case 'requires_additional':
      return VerificationStatus.requiresAdditional;
    default:
      return VerificationStatus.notSubmitted;
  }
}

/// Helper function to parse BillingCycle with fallback
BillingCycle _parseBillingCycle(dynamic value) {
  if (value == null) return BillingCycle.monthly;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'monthly':
      return BillingCycle.monthly;
    case 'quarterly':
      return BillingCycle.quarterly;
    case 'yearly':
      return BillingCycle.yearly;
    case 'onetime':
    case 'one_time':
      return BillingCycle.oneTime;
    default:
      return BillingCycle.monthly;
  }
}

/// Helper function to parse DocumentType with fallback
DocumentType _parseDocumentType(dynamic value) {
  if (value == null) return DocumentType.other;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'registrationcertificate':
    case 'registration_certificate':
      return DocumentType.registrationCertificate;
    case 'taxcertificate':
    case 'tax_certificate':
      return DocumentType.taxCertificate;
    case 'owneridproof':
    case 'owner_id_proof':
      return DocumentType.ownerIdProof;
    case 'addressproof':
    case 'address_proof':
      return DocumentType.addressProof;
    case 'bankdetails':
    case 'bank_details':
      return DocumentType.bankDetails;
    case 'businesslicense':
    case 'business_license':
      return DocumentType.businessLicense;
    case 'importexportlicense':
    case 'import_export_license':
      return DocumentType.importExportLicense;
    case 'other':
      return DocumentType.other;
    default:
      return DocumentType.other;
  }
}

/// Helper function to parse DocumentStatus with fallback
DocumentStatus _parseDocumentStatus(dynamic value) {
  if (value == null) return DocumentStatus.pending;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'pending':
      return DocumentStatus.pending;
    case 'uploaded':
      return DocumentStatus.uploaded;
    case 'underreview':
    case 'under_review':
      return DocumentStatus.underReview;
    case 'verified':
      return DocumentStatus.verified;
    case 'rejected':
      return DocumentStatus.rejected;
    case 'expired':
      return DocumentStatus.expired;
    default:
      return DocumentStatus.pending;
  }
}

/// Helper function to safely parse ContactPerson with defaults
ContactPerson _parseContactPerson(dynamic value) {
  if (value == null) {
    return ContactPerson(
      fullName: '',
      position: '',
      email: '',
      phone: '',
    );
  }

  try {
    if (value is Map<String, dynamic>) {
      return ContactPerson.fromJson(value);
    }
    if (value is Map) {
      return ContactPerson.fromJson(value.cast<String, dynamic>());
    }
  } catch (_) {
    // Fall through to return default
  }

  return ContactPerson(
    fullName: '',
    position: '',
    email: '',
    phone: '',
  );
}

/// Helper function to safely parse Plan with defaults
Plan? _parsePlan(dynamic value) {
  if (value == null) return null;

  try {
    if (value is Map<String, dynamic>) {
      return Plan.fromJson(value);
    }
    if (value is Map) {
      return Plan.fromJson(value.cast<String, dynamic>());
    }
  } catch (_) {
    // Fall through to return null
  }

  return null;
}

/// Helper function to safely parse CompanySettings with defaults
CompanySettings _parseCompanySettings(dynamic value) {
  if (value == null) return const CompanySettings();

  try {
    if (value is Map<String, dynamic>) {
      return CompanySettings.fromJson(value);
    }
    if (value is Map) {
      return CompanySettings.fromJson(value.cast<String, dynamic>());
    }
  } catch (_) {
    // Fall through to return default
  }

  return const CompanySettings();
}

/// Helper function to safely parse CompanyUsageStats with defaults
CompanyUsageStats _parseCompanyUsageStats(dynamic value) {
  if (value == null) return const CompanyUsageStats();

  try {
    if (value is Map<String, dynamic>) {
      return CompanyUsageStats.fromJson(value);
    }
    if (value is Map) {
      return CompanyUsageStats.fromJson(value.cast<String, dynamic>());
    }
  } catch (_) {
    // Fall through to return default
  }

  return const CompanyUsageStats();
}

/// Helper function to safely parse a list of CompanyDocuments
List<CompanyDocument> _parseDocuments(dynamic value) {
  if (value == null) return const [];
  if (value is! List) return const [];

  final List<CompanyDocument> documents = [];
  for (final item in value) {
    if (item == null) continue;
    try {
      if (item is Map<String, dynamic>) {
        documents.add(CompanyDocument.fromJson(item));
      } else if (item is Map) {
        documents.add(CompanyDocument.fromJson(item.cast<String, dynamic>()));
      }
    } catch (_) {
      // Skip invalid documents instead of failing
    }
  }

  return documents;
}

/// Helper function to safely parse a list of strings
List<String> _parseStringList(dynamic value) {
  if (value == null) return const [];
  if (value is! List) return const [];

  return value
      .map((e) => e?.toString() ?? '')
      .where((e) => e.isNotEmpty)
      .toList();
}

/// Helper function to safely parse a list of MonthlyUsage
List<MonthlyUsage> _parseMonthlyHistory(dynamic value) {
  if (value == null) return const [];
  if (value is! List) return const [];

  final List<MonthlyUsage> history = [];
  for (final item in value) {
    if (item == null) continue;
    try {
      if (item is Map<String, dynamic>) {
        history.add(MonthlyUsage.fromJson(item));
      } else if (item is Map) {
        history.add(MonthlyUsage.fromJson(item.cast<String, dynamic>()));
      }
    } catch (_) {
      // Skip invalid entries instead of failing
    }
  }

  return history;
}

/// Company Status Enumeration
/// Defines the status of a company in the system
enum CompanyStatus {
  /// Company is pending verification
  pending,

  /// Company is active and operational
  active,

  /// Company is suspended (temporarily disabled)
  suspended,

  /// Company is rejected during verification
  rejected,

  /// Company is in trial period
  trial,

  /// Company is archived (permanently disabled)
  archived,
}

/// Company Type Enumeration
/// Defines the type of company/business
enum CompanyType {
  /// Manufacturing company
  manufacturing,

  /// Distributor/Wholesaler
  distributor,

  /// Retailer
  retailer,

  /// Pharmaceutical company
  pharmaceutical,

  /// Food and beverage company
  foodBeverage,

  /// Textile company
  textile,

  /// Electronics company
  electronics,

  /// Other type of company
  other,
}

/// Industry Type Enumeration
/// Defines the industry of the company
enum IndustryType {
  /// Pharmaceutical industry
  pharmaceutical,

  /// Food and beverage industry
  foodBeverage,

  /// Textile industry
  textile,

  /// Electronics industry
  electronics,

  /// Automotive industry
  automotive,

  /// Chemical industry
  chemical,

  /// Construction industry
  construction,

  /// Agriculture industry
  agriculture,

  /// Other industry
  other,
}

/// Verification Status Enumeration
/// Defines the verification status of company documents
enum VerificationStatus {
  /// Not submitted
  notSubmitted,

  /// Submitted for review
  submitted,

  /// Under review
  underReview,

  /// Verified and approved
  verified,

  /// Rejected
  rejected,

  /// Requires additional documents
  requiresAdditional,
}

/// Company Model
/// Represents a factory/client company in the NexaTrace system
@Freezed(fromJson: false, toJson: false)
abstract class Company with _$Company {
  const Company._();

  const factory Company({
    /// Unique identifier for the company
    @JsonKey(name: 'id') required String id,

    /// Official company name
    @JsonKey(name: 'name') required String name,

    /// Trading name (if different from official name)
    @JsonKey(name: 'trading_name') String? tradingName,

    /// Company registration number
    @JsonKey(name: 'registration_number') required String registrationNumber,

    /// Tax ID/VAT number
    @JsonKey(name: 'tax_id') String? taxId,

    /// Type of company
    @JsonKey(name: 'type') required CompanyType type,

    /// Industry type
    @JsonKey(name: 'industry') required IndustryType industry,

    /// Country where company is registered
    @JsonKey(name: 'country') required String country,

    /// City where company is located
    @JsonKey(name: 'city') required String city,

    /// Full address of the company
    @JsonKey(name: 'address') required String address,

    /// Postal/ZIP code
    @JsonKey(name: 'postal_code') String? postalCode,

    /// Primary phone number
    @JsonKey(name: 'phone') required String phone,

    /// Primary email address
    @JsonKey(name: 'email') required String email,

    /// Company website
    @JsonKey(name: 'website') String? website,

    /// Status of the company
    @JsonKey(name: 'status')
    @Default(CompanyStatus.pending)
    CompanyStatus status,

    /// Verification status
    @JsonKey(name: 'verification_status')
    @Default(VerificationStatus.notSubmitted)
    VerificationStatus verificationStatus,

    /// Contact person information
    @JsonKey(name: 'contact_person') required ContactPerson contactPerson,

    /// Subscription plan assigned to the company
    @JsonKey(name: 'subscription_plan') Plan? subscriptionPlan,

    /// Subscription ID (if subscribed)
    @JsonKey(name: 'subscription_id') String? subscriptionId,

    /// Billing cycle (monthly/yearly)
    @JsonKey(name: 'billing_cycle')
    @Default(BillingCycle.monthly)
    BillingCycle billingCycle,

    /// Date when subscription started
    @JsonKey(name: 'subscription_start_date') DateTime? subscriptionStartDate,

    /// Date when subscription ends/renews
    @JsonKey(name: 'subscription_end_date') DateTime? subscriptionEndDate,

    /// Whether the company is on trial
    @JsonKey(name: 'is_trial') @Default(false) bool isTrial,

    /// Trial end date (if applicable)
    @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,

    /// Number of employees in the company
    @JsonKey(name: 'employee_count') @Default(0) int employeeCount,

    /// Annual revenue (optional)
    @JsonKey(name: 'annual_revenue') double? annualRevenue,

    /// Currency for revenue
    @JsonKey(name: 'revenue_currency') @Default('USD') String revenueCurrency,

    /// Notes about the company
    @JsonKey(name: 'notes') String? notes,

    /// Tags for categorization
    @JsonKey(name: 'tags') @Default([]) List<String> tags,

    /// Documents submitted for verification
    @JsonKey(name: 'documents') @Default([]) List<CompanyDocument> documents,

    /// Settings specific to this company
    @JsonKey(name: 'settings')
    @Default(CompanySettings())
    CompanySettings settings,

    /// Usage statistics
    @JsonKey(name: 'usage_stats')
    @Default(CompanyUsageStats())
    CompanyUsageStats usageStats,

    /// Date when the company was registered
    @JsonKey(name: 'registered_at') required DateTime registeredAt,

    /// Date when the company was last updated
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Date when the company was verified
    @JsonKey(name: 'verified_at') DateTime? verifiedAt,

    /// Date when the company was suspended
    @JsonKey(name: 'suspended_at') DateTime? suspendedAt,

    /// Reason for suspension
    @JsonKey(name: 'suspension_reason') String? suspensionReason,
  }) = _Company;

  /// Creates a Company from a JSON map
  factory Company.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for all required String fields
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final registrationNumber = json['registration_number']?.toString() ?? '';
    final country = json['country']?.toString() ?? '';
    final city = json['city']?.toString() ?? '';
    final address = json['address']?.toString() ?? '';
    final phone = json['phone']?.toString() ?? '';
    final email = json['email']?.toString() ?? '';

    // Defensive parsing for optional String fields
    final tradingName = json['trading_name']?.toString();
    final taxId = json['tax_id']?.toString();
    final postalCode = json['postal_code']?.toString();
    final website = json['website']?.toString();
    final subscriptionId = json['subscription_id']?.toString();
    final revenueCurrency = json['revenue_currency']?.toString() ?? 'USD';
    final notes = json['notes']?.toString();
    final suspensionReason = json['suspension_reason']?.toString();

    // Defensive parsing for enum fields
    final type = _parseCompanyType(json['type']);
    final industry = _parseIndustryType(json['industry']);
    final status = _parseCompanyStatus(json['status']);
    final verificationStatus =
        _parseVerificationStatus(json['verification_status']);
    final billingCycle = _parseBillingCycle(json['billing_cycle']);

    // Defensive parsing for int fields
    final employeeCount = (json['employee_count'] as num?)?.toInt() ?? 0;

    // Defensive parsing for double fields
    final annualRevenue = (json['annual_revenue'] as num?)?.toDouble();

    // Defensive parsing for bool fields
    final isTrial = json['is_trial'] == true;

    // Defensive parsing for DateTime fields
    final registeredAt =
        _parseDateTime(json['registered_at']) ?? DateTime.now();
    final updatedAt = _parseDateTime(json['updated_at']) ?? DateTime.now();
    final verifiedAt = _parseDateTime(json['verified_at']);
    final suspendedAt = _parseDateTime(json['suspended_at']);
    final subscriptionStartDate =
        _parseDateTime(json['subscription_start_date']);
    final subscriptionEndDate = _parseDateTime(json['subscription_end_date']);
    final trialEndDate = _parseDateTime(json['trial_end_date']);

    // Defensive parsing for nested objects
    final contactPerson = _parseContactPerson(json['contact_person']);
    final subscriptionPlan = _parsePlan(json['subscription_plan']);
    final settings = _parseCompanySettings(json['settings']);
    final usageStats = _parseCompanyUsageStats(json['usage_stats']);

    // Defensive parsing for list fields
    final tags = _parseStringList(json['tags']);
    final documents = _parseDocuments(json['documents']);

    return Company(
      id: id,
      name: name,
      tradingName: tradingName,
      registrationNumber: registrationNumber,
      taxId: taxId,
      type: type,
      industry: industry,
      country: country,
      city: city,
      address: address,
      postalCode: postalCode,
      phone: phone,
      email: email,
      website: website,
      status: status,
      verificationStatus: verificationStatus,
      contactPerson: contactPerson,
      subscriptionPlan: subscriptionPlan,
      subscriptionId: subscriptionId,
      billingCycle: billingCycle,
      subscriptionStartDate: subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate,
      isTrial: isTrial,
      trialEndDate: trialEndDate,
      employeeCount: employeeCount,
      annualRevenue: annualRevenue,
      revenueCurrency: revenueCurrency,
      notes: notes,
      tags: tags,
      documents: documents,
      settings: settings,
      usageStats: usageStats,
      registeredAt: registeredAt,
      updatedAt: updatedAt,
      verifiedAt: verifiedAt,
      suspendedAt: suspendedAt,
      suspensionReason: suspensionReason,
    );
  }

  /// Converts the Company to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trading_name': tradingName,
      'registration_number': registrationNumber,
      'tax_id': taxId,
      'type': type.name,
      'industry': industry.name,
      'country': country,
      'city': city,
      'address': address,
      'postal_code': postalCode,
      'phone': phone,
      'email': email,
      'website': website,
      'status': status.name,
      'verification_status': verificationStatus.name,
      'contact_person': contactPerson.toJson(),
      'subscription_plan': subscriptionPlan?.toJson(),
      'subscription_id': subscriptionId,
      'billing_cycle': billingCycle.name,
      'subscription_start_date': subscriptionStartDate?.toIso8601String(),
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'is_trial': isTrial,
      'trial_end_date': trialEndDate?.toIso8601String(),
      'employee_count': employeeCount,
      'annual_revenue': annualRevenue,
      'revenue_currency': revenueCurrency,
      'notes': notes,
      'tags': tags,
      'documents': documents.map((d) => d.toJson()).toList(),
      'settings': settings.toJson(),
      'usage_stats': usageStats.toJson(),
      'registered_at': registeredAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'suspended_at': suspendedAt?.toIso8601String(),
      'suspension_reason': suspensionReason,
    };
  }
}

/// Contact Person Model
/// Represents the primary contact person for a company
@Freezed(fromJson: false, toJson: false)
abstract class ContactPerson with _$ContactPerson {
  const ContactPerson._();

  const factory ContactPerson({
    /// Full name of the contact person
    @JsonKey(name: 'full_name') required String fullName,

    /// Position/title of the contact person
    @JsonKey(name: 'position') required String position,

    /// Email address of the contact person
    @JsonKey(name: 'email') required String email,

    /// Phone number of the contact person
    @JsonKey(name: 'phone') required String phone,

    /// Whether this is the primary contact
    @JsonKey(name: 'is_primary') @Default(true) bool isPrimary,

    /// Additional contact information
    @JsonKey(name: 'additional_info') String? additionalInfo,
  }) = _ContactPerson;

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for all required String fields
    final fullName = json['full_name']?.toString() ??
        json['fullName']?.toString() ??
        json['name']?.toString() ??
        '';
    final position =
        json['position']?.toString() ?? json['title']?.toString() ?? '';
    final email =
        json['email']?.toString() ?? json['email_address']?.toString() ?? '';
    final phone =
        json['phone']?.toString() ?? json['phone_number']?.toString() ?? '';

    // Defensive parsing for optional String fields
    final additionalInfo = json['additional_info']?.toString() ??
        json['additionalInfo']?.toString();

    // Defensive parsing for bool fields
    final isPrimary =
        json['is_primary'] as bool? ?? json['isPrimary'] as bool? ?? true;

    return ContactPerson(
      fullName: fullName,
      position: position,
      email: email,
      phone: phone,
      isPrimary: isPrimary,
      additionalInfo: additionalInfo,
    );
  }

  /// Converts the ContactPerson to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'position': position,
      'email': email,
      'phone': phone,
      'is_primary': isPrimary,
      'additional_info': additionalInfo,
    };
  }
}

/// Company Document Model
/// Represents a document submitted by the company for verification
@Freezed(fromJson: false, toJson: false)
abstract class CompanyDocument with _$CompanyDocument {
  const CompanyDocument._();

  const factory CompanyDocument({
    /// Unique identifier for the document
    @JsonKey(name: 'id') required String id,

    /// Type of document
    @JsonKey(name: 'type') required DocumentType type,

    /// Name of the document
    @JsonKey(name: 'name') required String name,

    /// Description of the document
    @JsonKey(name: 'description') String? description,

    /// File URL/path
    @JsonKey(name: 'file_url') required String fileUrl,

    /// File size in bytes
    @JsonKey(name: 'file_size') int? fileSize,

    /// File MIME type
    @JsonKey(name: 'mime_type') String? mimeType,

    /// Status of the document verification
    @JsonKey(name: 'status')
    @Default(DocumentStatus.pending)
    DocumentStatus status,

    /// Rejection reason (if rejected)
    @JsonKey(name: 'rejection_reason') String? rejectionReason,

    /// Verified by (admin user ID)
    @JsonKey(name: 'verified_by') String? verifiedBy,

    /// Date when document was uploaded
    @JsonKey(name: 'uploaded_at') required DateTime uploadedAt,

    /// Date when document was verified
    @JsonKey(name: 'verified_at') DateTime? verifiedAt,

    /// Expiry date of the document (if applicable)
    @JsonKey(name: 'expiry_date') DateTime? expiryDate,
  }) = _CompanyDocument;

  factory CompanyDocument.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for all required String fields
    final id = json['id']?.toString() ?? '';
    final name =
        json['name']?.toString() ?? json['document_name']?.toString() ?? '';
    final fileUrl = json['file_url']?.toString() ??
        json['fileUrl']?.toString() ??
        json['url']?.toString() ??
        '';

    // Defensive parsing for optional String fields
    final description = json['description']?.toString();
    final mimeType =
        json['mime_type']?.toString() ?? json['mimeType']?.toString();
    final rejectionReason = json['rejection_reason']?.toString() ??
        json['rejectionReason']?.toString();
    final verifiedBy =
        json['verified_by']?.toString() ?? json['verifiedBy']?.toString();

    // Defensive parsing for enum fields
    final type = _parseDocumentType(json['type'] ?? json['document_type']);
    final status = _parseDocumentStatus(json['status']);

    // Defensive parsing for int fields
    final fileSize = (json['file_size'] as num?)?.toInt() ??
        (json['fileSize'] as num?)?.toInt();

    // Defensive parsing for DateTime fields
    final uploadedAt =
        _parseDateTime(json['uploaded_at'] ?? json['uploadedAt']) ??
            DateTime.now();
    final verifiedAt =
        _parseDateTime(json['verified_at'] ?? json['verifiedAt']);
    final expiryDate =
        _parseDateTime(json['expiry_date'] ?? json['expiryDate']);

    return CompanyDocument(
      id: id,
      type: type,
      name: name,
      description: description,
      fileUrl: fileUrl,
      fileSize: fileSize,
      mimeType: mimeType,
      status: status,
      rejectionReason: rejectionReason,
      verifiedBy: verifiedBy,
      uploadedAt: uploadedAt,
      verifiedAt: verifiedAt,
      expiryDate: expiryDate,
    );
  }

  /// Converts the CompanyDocument to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'file_url': fileUrl,
      'file_size': fileSize,
      'mime_type': mimeType,
      'status': status.name,
      'rejection_reason': rejectionReason,
      'verified_by': verifiedBy,
      'uploaded_at': uploadedAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}

/// Document Type Enumeration
/// Defines the type of company document
enum DocumentType {
  /// Company registration certificate
  registrationCertificate,

  /// Tax registration/VAT certificate
  taxCertificate,

  /// Owner/CEO ID proof
  ownerIdProof,

  /// Address proof (utility bill)
  addressProof,

  /// Bank account details
  bankDetails,

  /// Business license
  businessLicense,

  /// Import/export license
  importExportLicense,

  /// Other document
  other,
}

/// Document Status Enumeration
/// Defines the status of a document
enum DocumentStatus {
  /// Document is pending upload
  pending,

  /// Document is uploaded
  uploaded,

  /// Document is under review
  underReview,

  /// Document is verified
  verified,

  /// Document is rejected
  rejected,

  /// Document is expired
  expired,
}

/// Company Settings Model
/// Represents company-specific settings and configurations
@Freezed(fromJson: false, toJson: false)
abstract class CompanySettings with _$CompanySettings {
  const CompanySettings._();

  const factory CompanySettings({
    /// Whether email notifications are enabled
    @JsonKey(name: 'email_notifications')
    @Default(true)
    bool emailNotifications,

    /// Whether SMS notifications are enabled
    @JsonKey(name: 'sms_notifications') @Default(false) bool smsNotifications,

    /// Whether auto-renewal is enabled
    @JsonKey(name: 'auto_renewal') @Default(true) bool autoRenewal,

    /// Invoice payment terms (in days)
    @JsonKey(name: 'payment_terms') @Default(15) int paymentTerms,

    /// Preferred language
    @JsonKey(name: 'preferred_language')
    @Default('en')
    String preferredLanguage,

    /// Timezone
    @JsonKey(name: 'timezone') @Default('UTC') String timezone,

    /// Currency for billing
    @JsonKey(name: 'billing_currency') @Default('USD') String billingCurrency,

    /// Tax rate percentage
    @JsonKey(name: 'tax_rate') @Default(0.0) double taxRate,

    /// Whether VAT is applicable
    @JsonKey(name: 'vat_applicable') @Default(false) bool vatApplicable,

    /// VAT number
    @JsonKey(name: 'vat_number') String? vatNumber,

    /// Custom settings
    @JsonKey(name: 'custom_settings')
    @Default({})
    Map<String, dynamic> customSettings,
  }) = _CompanySettings;

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for bool fields
    final emailNotifications = json['email_notifications'] as bool? ??
        json['emailNotifications'] as bool? ??
        true;
    final smsNotifications = json['sms_notifications'] as bool? ??
        json['smsNotifications'] as bool? ??
        false;
    final autoRenewal =
        json['auto_renewal'] as bool? ?? json['autoRenewal'] as bool? ?? true;
    final vatApplicable = json['vat_applicable'] as bool? ??
        json['vatApplicable'] as bool? ??
        false;

    // Defensive parsing for int fields
    final paymentTerms = (json['payment_terms'] as num?)?.toInt() ??
        (json['paymentTerms'] as num?)?.toInt() ??
        15;

    // Defensive parsing for double fields
    final taxRate = (json['tax_rate'] as num?)?.toDouble() ??
        (json['taxRate'] as num?)?.toDouble() ??
        0.0;

    // Defensive parsing for String fields
    final preferredLanguage = json['preferred_language']?.toString() ??
        json['preferredLanguage']?.toString() ??
        'en';
    final timezone = json['timezone']?.toString() ?? 'UTC';
    final billingCurrency = json['billing_currency']?.toString() ??
        json['billingCurrency']?.toString() ??
        'USD';
    final vatNumber =
        json['vat_number']?.toString() ?? json['vatNumber']?.toString();

    // Defensive parsing for Map fields
    Map<String, dynamic> customSettings = const {};
    try {
      final settingsValue = json['custom_settings'] ?? json['customSettings'];
      if (settingsValue is Map<String, dynamic>) {
        customSettings = settingsValue;
      } else if (settingsValue is Map) {
        customSettings = settingsValue.cast<String, dynamic>();
      }
    } catch (_) {
      customSettings = const {};
    }

    return CompanySettings(
      emailNotifications: emailNotifications,
      smsNotifications: smsNotifications,
      autoRenewal: autoRenewal,
      paymentTerms: paymentTerms,
      preferredLanguage: preferredLanguage,
      timezone: timezone,
      billingCurrency: billingCurrency,
      taxRate: taxRate,
      vatApplicable: vatApplicable,
      vatNumber: vatNumber,
      customSettings: customSettings,
    );
  }

  /// Converts the CompanySettings to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'auto_renewal': autoRenewal,
      'payment_terms': paymentTerms,
      'preferred_language': preferredLanguage,
      'timezone': timezone,
      'billing_currency': billingCurrency,
      'tax_rate': taxRate,
      'vat_applicable': vatApplicable,
      'vat_number': vatNumber,
      'custom_settings': customSettings,
    };
  }
}

/// Company Usage Statistics Model
/// Tracks usage statistics for a company
@Freezed(fromJson: false, toJson: false)
abstract class CompanyUsageStats with _$CompanyUsageStats {
  const CompanyUsageStats._();

  const factory CompanyUsageStats({
    /// Current month's unit code usage
    @JsonKey(name: 'current_month_unit_codes')
    @Default(0)
    int currentMonthUnitCodes,

    /// Current month's packet code usage
    @JsonKey(name: 'current_month_packet_codes')
    @Default(0)
    int currentMonthPacketCodes,

    /// Current month's carton code usage
    @JsonKey(name: 'current_month_carton_codes')
    @Default(0)
    int currentMonthCartonCodes,

    /// Current month's bundle code usage
    @JsonKey(name: 'current_month_bundle_codes')
    @Default(0)
    int currentMonthBundleCodes,

    /// Total unit codes generated
    @JsonKey(name: 'total_unit_codes') @Default(0) int totalUnitCodes,

    /// Total packet codes generated
    @JsonKey(name: 'total_packet_codes') @Default(0) int totalPacketCodes,

    /// Total carton codes generated
    @JsonKey(name: 'total_carton_codes') @Default(0) int totalCartonCodes,

    /// Total bundle codes generated
    @JsonKey(name: 'total_bundle_codes') @Default(0) int totalBundleCodes,

    /// Current store keepers count
    @JsonKey(name: 'current_store_keepers') @Default(0) int currentStoreKeepers,

    /// Current drivers count
    @JsonKey(name: 'current_drivers') @Default(0) int currentDrivers,

    /// Current admin users count
    @JsonKey(name: 'current_admin_users') @Default(0) int currentAdminUsers,

    /// Current active products count
    @JsonKey(name: 'current_active_products')
    @Default(0)
    int currentActiveProducts,

    /// Storage used in MB
    @JsonKey(name: 'storage_used_mb') @Default(0) int storageUsedMb,

    /// API calls made today
    @JsonKey(name: 'api_calls_today') @Default(0) int apiCallsToday,

    /// Last activity timestamp
    @JsonKey(name: 'last_activity_at') DateTime? lastActivityAt,

    /// Monthly usage history
    @JsonKey(name: 'monthly_history')
    @Default([])
    List<MonthlyUsage> monthlyHistory,
  }) = _CompanyUsageStats;

  factory CompanyUsageStats.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for all int fields
    final currentMonthUnitCodes =
        (json['current_month_unit_codes'] as num?)?.toInt() ?? 0;
    final currentMonthPacketCodes =
        (json['current_month_packet_codes'] as num?)?.toInt() ?? 0;
    final currentMonthCartonCodes =
        (json['current_month_carton_codes'] as num?)?.toInt() ?? 0;
    final currentMonthBundleCodes =
        (json['current_month_bundle_codes'] as num?)?.toInt() ?? 0;
    final totalUnitCodes = (json['total_unit_codes'] as num?)?.toInt() ?? 0;
    final totalPacketCodes = (json['total_packet_codes'] as num?)?.toInt() ?? 0;
    final totalCartonCodes = (json['total_carton_codes'] as num?)?.toInt() ?? 0;
    final totalBundleCodes = (json['total_bundle_codes'] as num?)?.toInt() ?? 0;
    final currentStoreKeepers =
        (json['current_store_keepers'] as num?)?.toInt() ?? 0;
    final currentDrivers = (json['current_drivers'] as num?)?.toInt() ?? 0;
    final currentAdminUsers =
        (json['current_admin_users'] as num?)?.toInt() ?? 0;
    final currentActiveProducts =
        (json['current_active_products'] as num?)?.toInt() ?? 0;
    final storageUsedMb = (json['storage_used_mb'] as num?)?.toInt() ?? 0;
    final apiCallsToday = (json['api_calls_today'] as num?)?.toInt() ?? 0;

    // Defensive parsing for DateTime fields
    final lastActivityAt = _parseDateTime(json['last_activity_at']);

    // Defensive parsing for list fields
    final monthlyHistory = _parseMonthlyHistory(json['monthly_history']);

    return CompanyUsageStats(
      currentMonthUnitCodes: currentMonthUnitCodes,
      currentMonthPacketCodes: currentMonthPacketCodes,
      currentMonthCartonCodes: currentMonthCartonCodes,
      currentMonthBundleCodes: currentMonthBundleCodes,
      totalUnitCodes: totalUnitCodes,
      totalPacketCodes: totalPacketCodes,
      totalCartonCodes: totalCartonCodes,
      totalBundleCodes: totalBundleCodes,
      currentStoreKeepers: currentStoreKeepers,
      currentDrivers: currentDrivers,
      currentAdminUsers: currentAdminUsers,
      currentActiveProducts: currentActiveProducts,
      storageUsedMb: storageUsedMb,
      apiCallsToday: apiCallsToday,
      lastActivityAt: lastActivityAt,
      monthlyHistory: monthlyHistory,
    );
  }

  /// Converts the CompanyUsageStats to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'current_month_unit_codes': currentMonthUnitCodes,
      'current_month_packet_codes': currentMonthPacketCodes,
      'current_month_carton_codes': currentMonthCartonCodes,
      'current_month_bundle_codes': currentMonthBundleCodes,
      'total_unit_codes': totalUnitCodes,
      'total_packet_codes': totalPacketCodes,
      'total_carton_codes': totalCartonCodes,
      'total_bundle_codes': totalBundleCodes,
      'current_store_keepers': currentStoreKeepers,
      'current_drivers': currentDrivers,
      'current_admin_users': currentAdminUsers,
      'current_active_products': currentActiveProducts,
      'storage_used_mb': storageUsedMb,
      'api_calls_today': apiCallsToday,
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'monthly_history': monthlyHistory.map((m) => m.toJson()).toList(),
    };
  }
}

/// Monthly Usage Model
/// Tracks monthly usage statistics
@Freezed(fromJson: false, toJson: false)
abstract class MonthlyUsage with _$MonthlyUsage {
  const MonthlyUsage._();

  const factory MonthlyUsage({
    /// Year and month (format: YYYY-MM)
    @JsonKey(name: 'month') required String month,

    /// Unit codes used in this month
    @JsonKey(name: 'unit_codes') @Default(0) int unitCodes,

    /// Packet codes used in this month
    @JsonKey(name: 'packet_codes') @Default(0) int packetCodes,

    /// Carton codes used in this month
    @JsonKey(name: 'carton_codes') @Default(0) int cartonCodes,

    /// Bundle codes used in this month
    @JsonKey(name: 'bundle_codes') @Default(0) int bundleCodes,

    /// Storage used in MB
    @JsonKey(name: 'storage_used_mb') @Default(0) int storageUsedMb,

    /// API calls made
    @JsonKey(name: 'api_calls') @Default(0) int apiCalls,
  }) = _MonthlyUsage;

  factory MonthlyUsage.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for all fields
    final month = json['month']?.toString() ?? '';
    final unitCodes = (json['unit_codes'] as num?)?.toInt() ?? 0;
    final packetCodes = (json['packet_codes'] as num?)?.toInt() ?? 0;
    final cartonCodes = (json['carton_codes'] as num?)?.toInt() ?? 0;
    final bundleCodes = (json['bundle_codes'] as num?)?.toInt() ?? 0;
    final storageUsedMb = (json['storage_used_mb'] as num?)?.toInt() ?? 0;
    final apiCalls = (json['api_calls'] as num?)?.toInt() ?? 0;

    return MonthlyUsage(
      month: month,
      unitCodes: unitCodes,
      packetCodes: packetCodes,
      cartonCodes: cartonCodes,
      bundleCodes: bundleCodes,
      storageUsedMb: storageUsedMb,
      apiCalls: apiCalls,
    );
  }

  /// Converts the MonthlyUsage to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'unit_codes': unitCodes,
      'packet_codes': packetCodes,
      'carton_codes': cartonCodes,
      'bundle_codes': bundleCodes,
      'storage_used_mb': storageUsedMb,
      'api_calls': apiCalls,
    };
  }
}

/// Extension methods for CompanyStatus enum
extension CompanyStatusExtension on CompanyStatus {
  /// Get the display name of the company status
  String get displayName {
    switch (this) {
      case CompanyStatus.pending:
        return 'Pending';
      case CompanyStatus.active:
        return 'Active';
      case CompanyStatus.suspended:
        return 'Suspended';
      case CompanyStatus.rejected:
        return 'Rejected';
      case CompanyStatus.trial:
        return 'Trial';
      case CompanyStatus.archived:
        return 'Archived';
    }
  }

  /// Get the color code for the company status
  String get colorCode {
    switch (this) {
      case CompanyStatus.pending:
        return '#FF9800'; // Orange
      case CompanyStatus.active:
        return '#4CAF50'; // Green
      case CompanyStatus.suspended:
        return '#F44336'; // Red
      case CompanyStatus.rejected:
        return '#9E9E9E'; // Grey
      case CompanyStatus.trial:
        return '#2196F3'; // Blue
      case CompanyStatus.archived:
        return '#607D8B'; // Blue Grey
    }
  }

  /// Get the icon for the company status
  String get icon {
    switch (this) {
      case CompanyStatus.pending:
        return 'hourglass_empty';
      case CompanyStatus.active:
        return 'check_circle';
      case CompanyStatus.suspended:
        return 'pause_circle';
      case CompanyStatus.rejected:
        return 'cancel';
      case CompanyStatus.trial:
        return 'timer';
      case CompanyStatus.archived:
        return 'archive';
    }
  }
}

/// Extension methods for CompanyType enum
extension CompanyTypeExtension on CompanyType {
  /// Get the display name of the company type
  String get displayName {
    switch (this) {
      case CompanyType.manufacturing:
        return 'Manufacturing';
      case CompanyType.distributor:
        return 'Distributor';
      case CompanyType.retailer:
        return 'Retailer';
      case CompanyType.pharmaceutical:
        return 'Pharmaceutical';
      case CompanyType.foodBeverage:
        return 'Food & Beverage';
      case CompanyType.textile:
        return 'Textile';
      case CompanyType.electronics:
        return 'Electronics';
      case CompanyType.other:
        return 'Other';
    }
  }
}

/// Extension methods for IndustryType enum
extension IndustryTypeExtension on IndustryType {
  /// Get the display name of the industry type
  String get displayName {
    switch (this) {
      case IndustryType.pharmaceutical:
        return 'Pharmaceutical';
      case IndustryType.foodBeverage:
        return 'Food & Beverage';
      case IndustryType.textile:
        return 'Textile';
      case IndustryType.electronics:
        return 'Electronics';
      case IndustryType.automotive:
        return 'Automotive';
      case IndustryType.chemical:
        return 'Chemical';
      case IndustryType.construction:
        return 'Construction';
      case IndustryType.agriculture:
        return 'Agriculture';
      case IndustryType.other:
        return 'Other';
    }
  }
}

/// Extension methods for VerificationStatus enum
extension VerificationStatusExtension on VerificationStatus {
  /// Get the display name of the verification status
  String get displayName {
    switch (this) {
      case VerificationStatus.notSubmitted:
        return 'Not Submitted';
      case VerificationStatus.submitted:
        return 'Submitted';
      case VerificationStatus.underReview:
        return 'Under Review';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.requiresAdditional:
        return 'Requires Additional';
    }
  }
}
