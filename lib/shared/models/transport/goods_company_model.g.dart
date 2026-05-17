// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goods_company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoodsCompanyModel _$GoodsCompanyModelFromJson(Map<String, dynamic> json) =>
    _GoodsCompanyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      companyName: json['company_name'] as String,
      ownerName: json['owner_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      cnic: json['cnic'] as String,
      address: json['address'] as String,
      planType: $enumDecode(_$GoodsCompanyPlanTypeEnumMap, json['plan_type']),
      status:
          $enumDecodeNullable(_$GoodsCompanyStatusEnumMap, json['status']) ??
          GoodsCompanyStatus.pending,
      verificationStatus:
          $enumDecodeNullable(
            _$VerificationStatusEnumMap,
            json['verification_status'],
          ) ??
          VerificationStatus.pending,
      commissionMin: (json['commission_min'] as num?)?.toDouble() ?? 0.0,
      commissionMax: (json['commission_max'] as num?)?.toDouble() ?? 15.0,
      autoCommissionEnabled: json['auto_commission_enabled'] as bool? ?? false,
      liveTrackingEnabled: json['live_tracking_enabled'] as bool? ?? true,
      biddingEnabled: json['bidding_enabled'] as bool? ?? true,
      autoBiddingEnabled: json['auto_bidding_enabled'] as bool? ?? false,
      escrowEnabled: json['escrow_enabled'] as bool? ?? false,
      whatsappIntegration: json['whatsapp_integration'] as bool? ?? false,
      whiteLabelEnabled: json['white_label_enabled'] as bool? ?? false,
      apiCallsToday: (json['api_calls_today'] as num?)?.toInt() ?? 0,
      apiCallsLimit: (json['api_calls_limit'] as num?)?.toInt() ?? 1000,
      totalTrucks: (json['total_trucks'] as num?)?.toInt() ?? 0,
      totalFactories: (json['total_factories'] as num?)?.toInt() ?? 0,
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      logoUrl: json['logo_url'] as String?,
      website: json['website'] as String?,
      taxNumber: json['tax_number'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankName: json['bank_name'] as String?,
      verificationNotes: json['verification_notes'] as String?,
      subscriptionStartDate: json['subscription_start_date'] == null
          ? null
          : DateTime.parse(json['subscription_start_date'] as String),
      subscriptionEndDate: json['subscription_end_date'] == null
          ? null
          : DateTime.parse(json['subscription_end_date'] as String),
      lastPaymentDate: json['last_payment_date'] == null
          ? null
          : DateTime.parse(json['last_payment_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$GoodsCompanyModelToJson(
  _GoodsCompanyModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'company_name': instance.companyName,
  'owner_name': instance.ownerName,
  'phone': instance.phone,
  'email': instance.email,
  'cnic': instance.cnic,
  'address': instance.address,
  'plan_type': _$GoodsCompanyPlanTypeEnumMap[instance.planType]!,
  'status': _$GoodsCompanyStatusEnumMap[instance.status]!,
  'verification_status':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'commission_min': instance.commissionMin,
  'commission_max': instance.commissionMax,
  'auto_commission_enabled': instance.autoCommissionEnabled,
  'live_tracking_enabled': instance.liveTrackingEnabled,
  'bidding_enabled': instance.biddingEnabled,
  'auto_bidding_enabled': instance.autoBiddingEnabled,
  'escrow_enabled': instance.escrowEnabled,
  'whatsapp_integration': instance.whatsappIntegration,
  'white_label_enabled': instance.whiteLabelEnabled,
  'api_calls_today': instance.apiCallsToday,
  'api_calls_limit': instance.apiCallsLimit,
  'total_trucks': instance.totalTrucks,
  'total_factories': instance.totalFactories,
  'total_trips': instance.totalTrips,
  'total_revenue': instance.totalRevenue,
  'rating': instance.rating,
  'rating_count': instance.ratingCount,
  'logo_url': instance.logoUrl,
  'website': instance.website,
  'tax_number': instance.taxNumber,
  'bank_account_number': instance.bankAccountNumber,
  'bank_name': instance.bankName,
  'verification_notes': instance.verificationNotes,
  'subscription_start_date': instance.subscriptionStartDate?.toIso8601String(),
  'subscription_end_date': instance.subscriptionEndDate?.toIso8601String(),
  'last_payment_date': instance.lastPaymentDate?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
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
  companyId: json['company_id'] as String,
  planType: $enumDecode(_$GoodsCompanyPlanTypeEnumMap, json['plan_type']),
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  amount: (json['amount'] as num).toDouble(),
  paymentMethod: json['payment_method'] as String,
  paymentReference: json['payment_reference'] as String,
  isAutoRenew: json['is_auto_renew'] as bool? ?? false,
  isPaid: json['is_paid'] as bool? ?? false,
  invoiceUrl: json['invoice_url'] as String?,
  paidAt: json['paid_at'] == null
      ? null
      : DateTime.parse(json['paid_at'] as String),
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  cancellationReason: json['cancellation_reason'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GoodsCompanySubscriptionToJson(
  _GoodsCompanySubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'company_id': instance.companyId,
  'plan_type': _$GoodsCompanyPlanTypeEnumMap[instance.planType]!,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
  'amount': instance.amount,
  'payment_method': instance.paymentMethod,
  'payment_reference': instance.paymentReference,
  'is_auto_renew': instance.isAutoRenew,
  'is_paid': instance.isPaid,
  'invoice_url': instance.invoiceUrl,
  'paid_at': instance.paidAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'cancellation_reason': instance.cancellationReason,
  'created_at': instance.createdAt.toIso8601String(),
};

_CommissionStructureModel _$CommissionStructureModelFromJson(
  Map<String, dynamic> json,
) => _CommissionStructureModel(
  id: json['id'] as String,
  companyId: json['company_id'] as String,
  minPercentage: (json['min_percentage'] as num).toDouble(),
  maxPercentage: (json['max_percentage'] as num).toDouble(),
  isDynamic: json['is_dynamic'] as bool? ?? true,
  dynamicRates: (json['dynamic_rates'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  includeTax: json['include_tax'] as bool? ?? false,
  includeInsurance: json['include_insurance'] as bool? ?? false,
  notes: json['notes'] as String?,
  effectiveFrom: DateTime.parse(json['effective_from'] as String),
  effectiveTo: json['effective_to'] == null
      ? null
      : DateTime.parse(json['effective_to'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CommissionStructureModelToJson(
  _CommissionStructureModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'company_id': instance.companyId,
  'min_percentage': instance.minPercentage,
  'max_percentage': instance.maxPercentage,
  'is_dynamic': instance.isDynamic,
  'dynamic_rates': instance.dynamicRates,
  'include_tax': instance.includeTax,
  'include_insurance': instance.includeInsurance,
  'notes': instance.notes,
  'effective_from': instance.effectiveFrom.toIso8601String(),
  'effective_to': instance.effectiveTo?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

_GoodsCompanySettings _$GoodsCompanySettingsFromJson(
  Map<String, dynamic> json,
) => _GoodsCompanySettings(
  companyId: json['company_id'] as String,
  emailNotifications: json['email_notifications'] as bool? ?? true,
  smsNotifications: json['sms_notifications'] as bool? ?? true,
  pushNotifications: json['push_notifications'] as bool? ?? true,
  bidNotifications: json['bid_notifications'] as bool? ?? true,
  tripNotifications: json['trip_notifications'] as bool? ?? true,
  paymentNotifications: json['payment_notifications'] as bool? ?? true,
  autoAcceptBids: json['auto_accept_bids'] as bool? ?? false,
  autoAcceptMaxAmount:
      (json['auto_accept_max_amount'] as num?)?.toDouble() ?? 50000.0,
  requireDriverVerification:
      json['require_driver_verification'] as bool? ?? false,
  requireTruckVerification:
      json['require_truck_verification'] as bool? ?? false,
  showLiveTracking: json['show_live_tracking'] as bool? ?? true,
  shareLocationWithFactories:
      json['share_location_with_factories'] as bool? ?? false,
  language: json['language'] as String? ?? 'en',
  country: json['country'] as String? ?? 'PK',
  timezone: json['timezone'] as String? ?? 'UTC',
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GoodsCompanySettingsToJson(
  _GoodsCompanySettings instance,
) => <String, dynamic>{
  'company_id': instance.companyId,
  'email_notifications': instance.emailNotifications,
  'sms_notifications': instance.smsNotifications,
  'push_notifications': instance.pushNotifications,
  'bid_notifications': instance.bidNotifications,
  'trip_notifications': instance.tripNotifications,
  'payment_notifications': instance.paymentNotifications,
  'auto_accept_bids': instance.autoAcceptBids,
  'auto_accept_max_amount': instance.autoAcceptMaxAmount,
  'require_driver_verification': instance.requireDriverVerification,
  'require_truck_verification': instance.requireTruckVerification,
  'show_live_tracking': instance.showLiveTracking,
  'share_location_with_factories': instance.shareLocationWithFactories,
  'language': instance.language,
  'country': instance.country,
  'timezone': instance.timezone,
  'updated_at': instance.updatedAt?.toIso8601String(),
};
