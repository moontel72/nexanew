// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => _WalletModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  userType: $enumDecode(_$UserTypeEnumMap, json['user_type']),
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  minimumBalance: (json['minimum_balance'] as num).toDouble(),
  lastUpdated: DateTime.parse(json['last_updated'] as String),
  isActive: json['is_active'] as bool? ?? true,
  currency: json['currency'] as String? ?? 'PKR',
  dailyLimit: (json['daily_limit'] as num?)?.toDouble() ?? 100000.0,
  monthlyLimit: (json['monthly_limit'] as num?)?.toDouble() ?? 1000000.0,
  transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
  totalTransacted: (json['total_transacted'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['created_at'] as String),
  lastActivityAt: json['last_activity_at'] == null
      ? null
      : DateTime.parse(json['last_activity_at'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$WalletModelToJson(_WalletModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'user_type': _$UserTypeEnumMap[instance.userType]!,
      'balance': instance.balance,
      'minimum_balance': instance.minimumBalance,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'is_active': instance.isActive,
      'currency': instance.currency,
      'daily_limit': instance.dailyLimit,
      'monthly_limit': instance.monthlyLimit,
      'transaction_count': instance.transactionCount,
      'total_transacted': instance.totalTransacted,
      'created_at': instance.createdAt.toIso8601String(),
      'last_activity_at': instance.lastActivityAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$UserTypeEnumMap = {
  UserType.factory: 'factory',
  UserType.goodsCompany: 'goodsCompany',
  UserType.truckOwner: 'truckOwner',
  UserType.driver: 'driver',
  UserType.reseller: 'reseller',
  UserType.shop: 'shop',
  UserType.customer: 'customer',
  UserType.superAdmin: 'superAdmin',
  UserType.factoryAdmin: 'factoryAdmin',
  UserType.factoryUser: 'factoryUser',
  UserType.transportAdmin: 'transportAdmin',
};

_WalletTransactionModel _$WalletTransactionModelFromJson(
  Map<String, dynamic> json,
) => _WalletTransactionModel(
  id: json['id'] as String,
  walletId: json['wallet_id'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  status:
      $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
      TransactionStatus.pending,
  description: json['description'] as String,
  referenceId: json['reference_id'] as String?,
  fromUserId: json['from_user_id'] as String?,
  toUserId: json['to_user_id'] as String?,
  commissionPercentage: (json['commission_percentage'] as num?)?.toDouble(),
  commissionAmount: (json['commission_amount'] as num?)?.toDouble(),
  connectionDetails: json['connection_details'] as String?,
  penaltyReason: json['penalty_reason'] as String?,
  tripDetails: json['trip_details'] as String?,
  subscriptionDetails: json['subscription_details'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  failureReason: json['failure_reason'] as String?,
  receiptUrl: json['receipt_url'] as String?,
  referenceNumber: json['reference_number'] as String?,
);

Map<String, dynamic> _$WalletTransactionModelToJson(
  _WalletTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'wallet_id': instance.walletId,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'description': instance.description,
  'reference_id': instance.referenceId,
  'from_user_id': instance.fromUserId,
  'to_user_id': instance.toUserId,
  'commission_percentage': instance.commissionPercentage,
  'commission_amount': instance.commissionAmount,
  'connection_details': instance.connectionDetails,
  'penalty_reason': instance.penaltyReason,
  'trip_details': instance.tripDetails,
  'subscription_details': instance.subscriptionDetails,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'failure_reason': instance.failureReason,
  'receipt_url': instance.receiptUrl,
  'reference_number': instance.referenceNumber,
};

const _$TransactionTypeEnumMap = {
  TransactionType.topUp: 'topUp',
  TransactionType.connectionFee: 'connectionFee',
  TransactionType.commission: 'commission',
  TransactionType.penalty: 'penalty',
  TransactionType.reward: 'reward',
  TransactionType.tripPayment: 'tripPayment',
  TransactionType.withdrawal: 'withdrawal',
  TransactionType.refund: 'refund',
  TransactionType.subscriptionPayment: 'subscriptionPayment',
  TransactionType.planUpgrade: 'planUpgrade',
  TransactionType.planDowngrade: 'planDowngrade',
  TransactionType.systemCredit: 'systemCredit',
  TransactionType.systemDebit: 'systemDebit',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
  TransactionStatus.processing: 'processing',
  TransactionStatus.refunded: 'refunded',
};

_WalletBalanceModel _$WalletBalanceModelFromJson(Map<String, dynamic> json) =>
    _WalletBalanceModel(
      balance: (json['balance'] as num).toDouble(),
      minimumBalance: (json['minimum_balance'] as num).toDouble(),
      canMakeContact: json['can_make_contact'] as bool,
      userType: $enumDecode(_$UserTypeEnumMap, json['user_type']),
      currency: json['currency'] as String,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$WalletBalanceModelToJson(_WalletBalanceModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'minimum_balance': instance.minimumBalance,
      'can_make_contact': instance.canMakeContact,
      'user_type': _$UserTypeEnumMap[instance.userType]!,
      'currency': instance.currency,
      'last_updated': instance.lastUpdated?.toIso8601String(),
    };

_WalletTopUpModel _$WalletTopUpModelFromJson(Map<String, dynamic> json) =>
    _WalletTopUpModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      gatewayReference: json['gateway_reference'] as String?,
      status:
          $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
          TransactionStatus.pending,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      failureReason: json['failure_reason'] as String?,
    );

Map<String, dynamic> _$WalletTopUpModelToJson(_WalletTopUpModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'amount': instance.amount,
      'payment_method': instance.paymentMethod,
      'gateway_reference': instance.gatewayReference,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'failure_reason': instance.failureReason,
    };

_WalletWithdrawalModel _$WalletWithdrawalModelFromJson(
  Map<String, dynamic> json,
) => _WalletWithdrawalModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  bankDetails: json['bank_details'] as Map<String, dynamic>,
  status:
      $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
      TransactionStatus.pending,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  failureReason: json['failure_reason'] as String?,
  transactionId: json['transaction_id'] as String?,
);

Map<String, dynamic> _$WalletWithdrawalModelToJson(
  _WalletWithdrawalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'amount': instance.amount,
  'bank_details': instance.bankDetails,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'failure_reason': instance.failureReason,
  'transaction_id': instance.transactionId,
};
