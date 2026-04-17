class CompanyStatistics {
  final int totalCompanies;
  final int activeCompanies;
  final int pendingCompanies;
  final int suspendedCompanies;
  final int verifiedCompanies;
  final int pendingVerification;
  final Map<String, int> companiesByCountry;
  final Map<String, int> companiesByPlan;
  final Map<String, int> companiesByIndustry;
  final List<CompanyGrowth> monthlyGrowth;

  const CompanyStatistics({
    required this.totalCompanies,
    required this.activeCompanies,
    required this.pendingCompanies,
    required this.suspendedCompanies,
    required this.verifiedCompanies,
    required this.pendingVerification,
    required this.companiesByCountry,
    required this.companiesByPlan,
    required this.companiesByIndustry,
    required this.monthlyGrowth,
  });

  factory CompanyStatistics.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data')) {
      final data = Map<String, dynamic>.from(json['data'] as Map);
      final companyStats = Map<String, dynamic>.from(data['company_stats'] as Map);

      final growthData = (data['monthly_growth'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final months = (growthData['months'] as List?) ?? const [];
      final companyGrowth = (growthData['company_growth'] as List?) ?? const [];

      final monthlyGrowth = <CompanyGrowth>[];
      for (var i = 0; i < months.length; i++) {
        monthlyGrowth.add(
          CompanyGrowth(
            month: months[i].toString(),
            companyCount: i < companyGrowth.length
                ? (companyGrowth[i] as num?)?.toInt() ?? 0
                : 0,
          ),
        );
      }

      return CompanyStatistics(
        totalCompanies: (companyStats['total'] as num?)?.toInt() ?? 0,
        activeCompanies: (companyStats['active'] as num?)?.toInt() ?? 0,
        pendingCompanies: (companyStats['pending'] as num?)?.toInt() ?? 0,
        suspendedCompanies: (companyStats['suspended'] as num?)?.toInt() ?? 0,
        verifiedCompanies: (companyStats['verified'] as num?)?.toInt() ?? 0,
        pendingVerification:
            (companyStats['pending_verification'] as num?)?.toInt() ?? 0,
        companiesByCountry: const {},
        companiesByPlan: const {},
        companiesByIndustry: const {},
        monthlyGrowth: monthlyGrowth,
      );
    }

    return CompanyStatistics(
      totalCompanies: (json['total'] as num?)?.toInt() ??
          (json['total_companies'] as num?)?.toInt() ??
          0,
      activeCompanies: (json['active'] as num?)?.toInt() ??
          (json['active_companies'] as num?)?.toInt() ??
          0,
      pendingCompanies: (json['pending'] as num?)?.toInt() ??
          (json['pending_companies'] as num?)?.toInt() ??
          0,
      suspendedCompanies: (json['suspended'] as num?)?.toInt() ??
          (json['suspended_companies'] as num?)?.toInt() ??
          0,
      verifiedCompanies: (json['verified'] as num?)?.toInt() ??
          (json['verified_companies'] as num?)?.toInt() ??
          0,
      pendingVerification: (json['pending_verification'] as num?)?.toInt() ??
          (json['pendingVerification'] as num?)?.toInt() ??
          0,
      companiesByCountry: const {},
      companiesByPlan: const {},
      companiesByIndustry: const {},
      monthlyGrowth: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_companies': totalCompanies,
      'active_companies': activeCompanies,
      'pending_companies': pendingCompanies,
      'suspended_companies': suspendedCompanies,
      'verified_companies': verifiedCompanies,
      'pending_verification': pendingVerification,
      'companies_by_country': companiesByCountry,
      'companies_by_plan': companiesByPlan,
      'companies_by_industry': companiesByIndustry,
      'monthly_growth': monthlyGrowth.map((g) => g.toJson()).toList(),
    };
  }
}

class CompanyGrowth {
  final String month;
  final int companyCount;

  const CompanyGrowth({required this.month, required this.companyCount});

  factory CompanyGrowth.fromJson(Map<String, dynamic> json) {
    return CompanyGrowth(
      month: json['month']?.toString() ?? '',
      companyCount: (json['company_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'company_count': companyCount};
  }
}
