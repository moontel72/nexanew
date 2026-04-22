import 'package:nexatrace_system/core/constants/app_constants.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/subscription_plan.dart';
import 'package:flutter/foundation.dart';
import 'package:nexatrace_system/shared/models/company/company_document_input.dart';
import 'package:nexatrace_system/shared/models/company/company_model.dart';
import 'package:nexatrace_system/shared/models/company/company_statistics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyManagementRepository {
  final ApiService _apiService;

  CompanyManagementRepository({required ApiService apiService})
    : _apiService = apiService;

  Future<CompaniesResponse> getCompanies({
    String search = '',
    String? status,
    String? verificationStatus,
    String? country,
    String? planType,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = {
        'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (verificationStatus != null && verificationStatus.isNotEmpty)
          'verification_status': verificationStatus,
        if (country != null && country.isNotEmpty) 'country': country,
        if (planType != null && planType.isNotEmpty) 'plan_type': planType,
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final response = await _apiService.get(
        ApiEndpoints.adminCompanies,
        queryParameters: queryParams,
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};

      final companiesData = (data['companies'] as List?) ?? const [];
      final companies = <Company>[];
      for (final item in companiesData) {
        if (item is! Map) continue;
        try {
          companies.add(Company.fromJson(item.cast<String, dynamic>()));
        } catch (_) {
          // Skip invalid company data instead of failing the whole list
        }
      }

      return CompaniesResponse(
        companies: companies,
        total: (data['total'] as num?)?.toInt() ?? 0,
        page: (data['page'] as num?)?.toInt() ?? page,
        perPage: (data['per_page'] as num?)?.toInt() ?? perPage,
        totalPages: (data['total_pages'] as num?)?.toInt() ?? 1,
      );
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<Company> getCompany(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.adminCompanies}/$id',
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      return Company.fromJson(data);
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<Company> createCompany({
    required String name,
    required String businessRegistrationNumber,
    String? taxId,
    required String companyType,
    required String industryType,
    required String email,
    String? phone,
    String? website,
    required String country,
    required String city,
    String? address,
    String? postalCode,
    required String contactPersonName,
    required String contactPersonEmail,
    required String contactPersonPhone,
    String? contactPersonPosition,
    String? timezone,
    String? language,
    String? currency,
    String? planId,
    String? billingCycle,
    List<CompanyDocumentInput>? documents,
    String? adminNotes,
    String? password,
  }) async {
    try {
      final body = {
        'name': name,
        'business_registration_number': businessRegistrationNumber,
        if (taxId != null && taxId.isNotEmpty) 'tax_id': taxId,
        'company_type': companyType,
        'industry_type': industryType,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (website != null && website.isNotEmpty) 'website': website,
        'country': country,
        'city': city,
        if (address != null && address.isNotEmpty) 'address': address,
        if (postalCode != null && postalCode.isNotEmpty)
          'postal_code': postalCode,
        'contact_person_name': contactPersonName,
        'contact_person_email': contactPersonEmail,
        'contact_person_phone': contactPersonPhone,
        if (contactPersonPosition != null && contactPersonPosition.isNotEmpty)
          'contact_person_position': contactPersonPosition,
        if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
        if (language != null && language.isNotEmpty) 'language': language,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
        if (planId != null && planId.isNotEmpty) 'plan_id': planId,
        if (billingCycle != null && billingCycle.isNotEmpty)
          'billing_cycle': billingCycle,
        if (documents != null)
          'documents': documents.map((doc) => doc.toJson()).toList(),
        if (adminNotes != null && adminNotes.isNotEmpty)
          'admin_notes': adminNotes,
        if (password != null && password.isNotEmpty) 'password': password,
      };

      final response = await _apiService.post(
        ApiEndpoints.adminCompanies,
        data: body,
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      return Company.fromJson(data);
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<Company> createCompanyFromMap(Map<String, dynamic> companyData) {
    return createCompany(
      name: companyData['name']?.toString() ?? '',
      businessRegistrationNumber:
          companyData['business_registration_number']?.toString() ??
          companyData['registration_number']?.toString() ??
          '',
      taxId: companyData['tax_id']?.toString(),
      companyType:
          companyData['company_type']?.toString() ??
          companyData['type']?.toString() ??
          '',
      industryType:
          companyData['industry_type']?.toString() ??
          companyData['industry']?.toString() ??
          '',
      email: companyData['email']?.toString() ?? '',
      phone: companyData['phone']?.toString(),
      website: companyData['website']?.toString(),
      country: companyData['country']?.toString() ?? '',
      city: companyData['city']?.toString() ?? '',
      address: companyData['address']?.toString(),
      postalCode: companyData['postal_code']?.toString(),
      contactPersonName:
          companyData['contact_person_name']?.toString() ??
          (companyData['contact_person'] is Map
              ? (companyData['contact_person'] as Map)['name']?.toString()
              : null) ??
          '',
      contactPersonEmail:
          companyData['contact_person_email']?.toString() ??
          (companyData['contact_person'] is Map
              ? (companyData['contact_person'] as Map)['email']?.toString()
              : null) ??
          '',
      contactPersonPhone:
          companyData['contact_person_phone']?.toString() ??
          (companyData['contact_person'] is Map
              ? (companyData['contact_person'] as Map)['phone']?.toString()
              : null) ??
          '',
      contactPersonPosition: companyData['contact_person_position']?.toString(),
      timezone: companyData['timezone']?.toString(),
      language: companyData['language']?.toString(),
      currency: companyData['currency']?.toString(),
      planId: companyData['plan_id']?.toString(),
      billingCycle: companyData['billing_cycle']?.toString(),
      adminNotes: companyData['admin_notes']?.toString(),
      password: companyData['password']?.toString(),
    );
  }

  Future<Company> updateCompany({
    required String id,
    String? name,
    String? businessRegistrationNumber,
    String? taxId,
    String? companyType,
    String? industryType,
    String? email,
    String? phone,
    String? website,
    String? country,
    String? city,
    String? address,
    String? postalCode,
    String? contactPersonName,
    String? contactPersonEmail,
    String? contactPersonPhone,
    String? contactPersonPosition,
    String? status,
    String? verificationStatus,
    String? verificationNotes,
    String? timezone,
    String? language,
    String? currency,
    String? planId,
    String? billingCycle,
    String? adminNotes,
  }) async {
    try {
      final body = {
        if (name != null && name.isNotEmpty) 'name': name,
        if (businessRegistrationNumber != null &&
            businessRegistrationNumber.isNotEmpty)
          'business_registration_number': businessRegistrationNumber,
        if (taxId != null && taxId.isNotEmpty) 'tax_id': taxId,
        if (companyType != null && companyType.isNotEmpty)
          'company_type': companyType,
        if (industryType != null && industryType.isNotEmpty)
          'industry_type': industryType,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (website != null && website.isNotEmpty) 'website': website,
        if (country != null && country.isNotEmpty) 'country': country,
        if (city != null && city.isNotEmpty) 'city': city,
        if (address != null && address.isNotEmpty) 'address': address,
        if (postalCode != null && postalCode.isNotEmpty)
          'postal_code': postalCode,
        if (contactPersonName != null && contactPersonName.isNotEmpty)
          'contact_person_name': contactPersonName,
        if (contactPersonEmail != null && contactPersonEmail.isNotEmpty)
          'contact_person_email': contactPersonEmail,
        if (contactPersonPhone != null && contactPersonPhone.isNotEmpty)
          'contact_person_phone': contactPersonPhone,
        if (contactPersonPosition != null && contactPersonPosition.isNotEmpty)
          'contact_person_position': contactPersonPosition,
        if (status != null && status.isNotEmpty) 'status': status,
        if (verificationStatus != null && verificationStatus.isNotEmpty)
          'verification_status': verificationStatus,
        if (verificationNotes != null && verificationNotes.isNotEmpty)
          'verification_notes': verificationNotes,
        if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
        if (language != null && language.isNotEmpty) 'language': language,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
        if (planId != null && planId.isNotEmpty) 'plan_id': planId,
        if (billingCycle != null && billingCycle.isNotEmpty)
          'billing_cycle': billingCycle,
        if (adminNotes != null && adminNotes.isNotEmpty)
          'admin_notes': adminNotes,
      };

      final response = await _apiService.put(
        '${ApiEndpoints.adminCompanies}/$id',
        data: body,
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      return Company.fromJson(data);
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<Company> updateCompanyRaw(
    String id,
    Map<String, dynamic> companyData,
  ) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.adminCompanies}/$id',
        data: companyData,
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      return Company.fromJson(data);
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<void> deleteCompany(String id) async {
    try {
      await _apiService.delete('${ApiEndpoints.adminCompanies}/$id');
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<void> updateCompanyStatus({
    required String id,
    required String status,
    String? reason,
  }) async {
    try {
      final body = {
        'status': status,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };

      await _apiService.patch(
        '${ApiEndpoints.adminCompanies}/$id/status',
        data: body,
      );
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<void> updateVerificationStatus({
    required String id,
    required String verificationStatus,
    String? verificationNotes,
  }) async {
    try {
      final body = {
        'verification_status': verificationStatus,
        if (verificationNotes != null && verificationNotes.isNotEmpty)
          'verification_notes': verificationNotes,
      };

      await _apiService.patch(
        ApiEndpoints.adminUpdateVerificationStatus.replaceFirst('{id}', id),
        data: body,
      );
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<void> assignPlan({
    required String companyId,
    required String planId,
    String? billingCycle,
    bool? autoRenew,
    DateTime? startsAt,
    DateTime? endsAt,
  }) async {
    try {
      final body = {
        'plan_id': planId,
        if (billingCycle != null && billingCycle.isNotEmpty)
          'billing_cycle': billingCycle,
        'auto_renew': ?autoRenew,
        if (startsAt != null) 'starts_at': startsAt.toIso8601String(),
        if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
      };

      await _apiService.post(
        '${ApiEndpoints.adminCompanies}/$companyId/assign-plan',
        data: body,
      );
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<CompanyDocument> uploadDocument({
    required String companyId,
    required String documentType,
    required String documentName,
    required String filePath,
  }) async {
    try {
      final response = await _apiService.uploadFile(
        '${ApiEndpoints.adminCompanies}/$companyId/documents',
        filePath,
        'file',
        fields: {'document_type': documentType, 'document_name': documentName},
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      return CompanyDocument.fromJson(data);
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<void> deleteDocument({
    required String companyId,
    required String documentId,
  }) async {
    try {
      await _apiService.delete(
        '${ApiEndpoints.adminCompanies}/$companyId/documents/$documentId',
      );
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<CompanyStatistics> getCompanyStatistics() async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.adminCompanies}/statistics',
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      return CompanyStatistics.fromJson(data);
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<String> exportCompanies({
    String? search,
    String? status,
    String? verificationStatus,
    String? country,
    String? planType,
  }) async {
    try {
      final queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (verificationStatus != null && verificationStatus.isNotEmpty)
          'verification_status': verificationStatus,
        if (country != null && country.isNotEmpty) 'country': country,
        if (planType != null && planType.isNotEmpty) 'plan_type': planType,
      };

      final response = await _apiService.get(
        '${ApiEndpoints.adminCompanies}/export',
        queryParameters: queryParams,
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      return data['file_path']?.toString() ?? '';
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<void> sendWelcomeEmail(String companyId) async {
    try {
      await _apiService.post(
        '${ApiEndpoints.adminCompanies}/$companyId/send-welcome-email',
      );
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<void> resetCompanyPassword(String companyId) async {
    try {
      await _apiService.post(
        '${ApiEndpoints.adminCompanies}/$companyId/reset-password',
      );
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<CompanyUsageStats> getCompanyUsageStats(String companyId) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.adminCompanies}/$companyId/usage-stats',
      );

      final data =
          (response['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      return CompanyUsageStats.fromJson(data);
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }

  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      if (kDebugMode) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = (prefs.getString(AppConstants.authTokenKey) ?? '').trim();
          print('DEBUG: Super Admin token present: ${token.isNotEmpty}');
        } catch (e) {
          print('DEBUG: Failed to read auth token: $e');
        }
        print('DEBUG: Plans endpoint: ${ApiEndpoints.adminPlans}');
      }

      final response = await _apiService.get(
        ApiEndpoints.adminPlans,
        queryParameters: {'status': 'active'},
      );

      if (kDebugMode) {
        print('DEBUG: Plans Response: $response');
      }

      try {
        List<dynamic> plansData = const [];

        if (response is Map) {
          final data = response['data'];
          if (data is List) {
            plansData = data;
          } else if (data is Map) {
            final nested = data['plans'];
            if (nested is List) plansData = nested;
            final nestedData = data['data'];
            if (plansData.isEmpty && nestedData is List) plansData = nestedData;
          }
        } else if (response is List) {
          plansData = response;
        }

        final plans = <SubscriptionPlan>[];
        for (final item in plansData) {
          if (item is Map) {
            try {
              final map = Map<String, dynamic>.from(item);
              final id = map['id']?.toString().trim() ?? '';
              if (id.isEmpty) continue;
              plans.add(SubscriptionPlan.fromJson(map));
            } catch (e) {
              if (kDebugMode) {
                debugPrint('DEBUG: Failed to parse plan item: $item');
                debugPrint('DEBUG: Parse error: $e');
              }
            }
          }
        }
        return plans;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('DEBUG: Failed to map plans response: $e');
        }
        return const <SubscriptionPlan>[];
      }
    } catch (error, stackTrace) {
      throw mapExceptionToFailure(error, stackTrace);
    }
  }
}

class CompaniesResponse {
  final List<Company> companies;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  CompaniesResponse({
    required this.companies,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });
}
