// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goods_company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoodsCompanyModel _$GoodsCompanyModelFromJson(Map<String, dynamic> json) =>
    _GoodsCompanyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      companyName: json['companyName'] as String,
      ownerName: json['ownerName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      cnic: json['cnic'] as String,
      address: json['address'] as String,
      planType: $enumDecode(_$GoodsCompanyPlanTypeEnumMap, json['planType']),
      status:
          $enumDecodeNullable(_$GoodsCompanyStatusEnumMap, json['status']) ??
          GoodsCompanyStatus.pending,
      verificationStatus:
          $enumDecodeNullable(
            _$VerificationStatusEnumMap,
            json['verificationStatus'],
          ) ??
          VerificationStatus.pending,
      commissionMin: (json['commissionMin'] as num?)?.toDouble() ?? 0.0,
      commissionMax: (json['commissionMax'] as num?)?.toDouble() ?? 15.0,
      autoCommissionEnabled: json['autoCommissionEnabled'] as bool? ?? false,
      liveTrackingEnabled: json['liveTrackingEnabled'] as bool? ?? true,
      biddingEnabled: json['biddingEnabled'] as bool? ?? true,
      autoBiddingEnabled: json['autoBiddingEnabled'] as bool? ?? false,
      escrowEnabled: json['escrowEnabled'] as bool? ?? false,
      whatsappIntegration: json['whatsappIntegration'] as bool? ?? false,
      whiteLabelEnabled: json['whiteLabelEnabled'] as bool? ?? false,
      apiCallsToday: (json['apiCallsToday'] as num?)?.toInt() ?? 0,
      apiCallsLimit: (json['apiCallsLimit'] as num?)?.toInt() ?? 1000,
      totalTrucks: (json['totalTrucks'] as num?)?.toInt() ?? 0,
      totalFactories: (json['totalFactories'] as num?)?.toInt() ?? 0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      logoUrl: json['logoUrl'] as String?,
      website: json['website'] as String?,
      taxNumber: json['taxNumber'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankName: json['bankName'] as String?,
      verificationNotes: json['verificationNotes'] as String?,
      subscriptionStartDate: json['subscriptionStartDate'] == null
          ? null
          : DateTime.parse(json['subscriptionStartDate'] as String),
      subscriptionEndDate: json['subscriptionEndDate'] == null
          ? null
          : DateTime.parse(json['subscriptionEndDate'] as String),
      lastPaymentDate: json['lastPaymentDate'] == null
          ? null
          : DateTime.parse(json['lastPaymentDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GoodsCompanyModelToJson(
  _GoodsCompanyModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'companyName': instance.companyName,
  'ownerName': instance.ownerName,
  'phone': instance.phone,
  'email': instance.email,
  'cnic': instance.cnic,
  'address': instance.address,
  'planType': _$GoodsCompanyPlanTypeEnumMap[instance.planType]!,
  'status': _$GoodsCompanyStatusEnumMap[instance.status]!,
  'verificationStatus':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'commissionMin': instance.commissionMin,
  'commissionMax': instance.commissionMax,
  'autoCommissionEnabled': instance.autoCommissionEnabled,
  'liveTrackingEnabled': instance.liveTrackingEnabled,
  'biddingEnabled': instance.biddingEnabled,
  'autoBiddingEnabled': instance.autoBiddingEnabled,
  'escrowEnabled': instance.escrowEnabled,
  'whatsappIntegration': instance.whatsappIntegration,
  'whiteLabelEnabled': instance.whiteLabelEnabled,
  'apiCallsToday': instance.apiCallsToday,
  'apiCallsLimit': instance.apiCallsLimit,
  'totalTrucks': instance.totalTrucks,
  'totalFactories': instance.totalFactories,
  'totalTrips': instance.totalTrips,
  'totalRevenue': instance.totalRevenue,
  'rating': instance.rating,
  'ratingCount': instance.ratingCount,
  'logoUrl': instance.logoUrl,
  'website': instance.website,
  'taxNumber': instance.taxNumber,
  'bankAccountNumber': instance.bankAccountNumber,
  'bankName': instance.bankName,
  'verificationNotes': instance.verificationNotes,
  'subscriptionStartDate': instance.subscriptionStartDate?.toIso8601String(),
  'subscriptionEndDate': instance.subscriptionEndDate?.toIso8601String(),
  'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$GoodsCompanyPlanTypeEnumMap = {
  GoodsCompanyPlanType.basic: 'basic',
  GoodsCompanyPlanType.professional: 'professional',
  GoodsCompanyPlanType.enterprise: 'enterprise',
};

const _$GoodsCompanyStatusEnumMap = {
  GoodsCompanyStatus.pending: 'pending',
  GoodsCompanyStatus.active: 'active',
  GoodsCompanyStatus.suspended: 'suspended',
  GoodsCompanyStatus.terminated: 'terminated',
  GoodsCompanyStatus.underReview: 'underReview',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.verified: 'verified',
  VerificationStatus.rejected: 'rejected',
  VerificationStatus.underReview: 'underReview',
};

_GoodsCompanySubscription _$GoodsCompanySubscriptionFromJson(
  Map<String, dynamic> json,
) => _GoodsCompanySubscription(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  planType: $enumDecode(_$GoodsCompanyPlanTypeEnumMap, json['planType']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  amount: (json['amount'] as num).toDouble(),
  paymentMethod: json['paymentMethod'] as String,
  paymentReference: json['paymentReference'] as String,
  isAutoRenew: json['isAutoRenew'] as bool? ?? false,
  isPaid: json['isPaid'] as bool? ?? false,
  invoiceUrl: json['invoiceUrl'] as String?,
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  cancellationReason: json['cancellationReason'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GoodsCompanySubscriptionToJson(
  _GoodsCompanySubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'planType': _$GoodsCompanyPlanTypeEnumMap[instance.planType]!,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'amount': instance.amount,
  'paymentMethod': instance.paymentMethod,
  'paymentReference': instance.paymentReference,
  'isAutoRenew': instance.isAutoRenew,
  'isPaid': instance.isPaid,
  'invoiceUrl': instance.invoiceUrl,
  'paidAt': instance.paidAt?.toIso8601String(),
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
  'cancellationReason': instance.cancellationReason,
  'createdAt': instance.createdAt.toIso8601String(),
};

_CommissionStructureModel _$CommissionStructureModelFromJson(
  Map<String, dynamic> json,
) => _CommissionStructureModel(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  minPercentage: (json['minPercentage'] as num).toDouble(),
  maxPercentage: (json['maxPercentage'] as num).toDouble(),
  isDynamic: json['isDynamic'] as bool? ?? true,
  dynamicRates: (json['dynamicRates'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  includeTax: json['includeTax'] as bool? ?? false,
  includeInsurance: json['includeInsurance'] as bool? ?? false,
  notes: json['notes'] as String?,
  effectiveFrom: DateTime.parse(json['effectiveFrom'] as String),
  effectiveTo: json['effectiveTo'] == null
      ? null
      : DateTime.parse(json['effectiveTo'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CommissionStructureModelToJson(
  _CommissionStructureModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'minPercentage': instance.minPercentage,
  'maxPercentage': instance.maxPercentage,
  'isDynamic': instance.isDynamic,
  'dynamicRates': instance.dynamicRates,
  'includeTax': instance.includeTax,
  'includeInsurance': instance.includeInsurance,
  'notes': instance.notes,
  'effectiveFrom': instance.effectiveFrom.toIso8601String(),
  'effectiveTo': instance.effectiveTo?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

_GoodsCompanySettings _$GoodsCompanySettingsFromJson(
  Map<String, dynamic> json,
) => _GoodsCompanySettings(
  companyId: json['companyId'] as String,
  emailNotifications: json['emailNotifications'] as bool? ?? true,
  smsNotifications: json['smsNotifications'] as bool? ?? true,
  pushNotifications: json['pushNotifications'] as bool? ?? true,
  bidNotifications: json['bidNotifications'] as bool? ?? true,
  tripNotifications: json['tripNotifications'] as bool? ?? true,
  paymentNotifications: json['paymentNotifications'] as bool? ?? true,
  autoAcceptBids: json['autoAcceptBids'] as bool? ?? false,
  autoAcceptMaxAmount:
      (json['autoAcceptMaxAmount'] as num?)?.toDouble() ?? 50000.0,
  requireDriverVerification:
      json['requireDriverVerification'] as bool? ?? false,
  requireTruckVerification: json['requireTruckVerification'] as bool? ?? false,
  showLiveTracking: json['showLiveTracking'] as bool? ?? true,
  shareLocationWithFactories:
      json['shareLocationWithFactories'] as bool? ?? false,
  language: json['language'] as String? ?? 'en',
  country: json['country'] as String? ?? 'PK',
  timezone: json['timezone'] as String? ?? 'UTC',
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GoodsCompanySettingsToJson(
  _GoodsCompanySettings instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'emailNotifications': instance.emailNotifications,
  'smsNotifications': instance.smsNotifications,
  'pushNotifications': instance.pushNotifications,
  'bidNotifications': instance.bidNotifications,
  'tripNotifications': instance.tripNotifications,
  'paymentNotifications': instance.paymentNotifications,
  'autoAcceptBids': instance.autoAcceptBids,
  'autoAcceptMaxAmount': instance.autoAcceptMaxAmount,
  'requireDriverVerification': instance.requireDriverVerification,
  'requireTruckVerification': instance.requireTruckVerification,
  'showLiveTracking': instance.showLiveTracking,
  'shareLocationWithFactories': instance.shareLocationWithFactories,
  'language': instance.language,
  'country': instance.country,
  'timezone': instance.timezone,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
