// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => _WalletModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  minimumBalance: (json['minimumBalance'] as num).toDouble(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  isActive: json['isActive'] as bool? ?? true,
  currency: json['currency'] as String? ?? 'PKR',
  dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 100000.0,
  monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 1000000.0,
  transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
  totalTransacted: (json['totalTransacted'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastActivityAt: json['lastActivityAt'] == null
      ? null
      : DateTime.parse(json['lastActivityAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$WalletModelToJson(_WalletModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userType': _$UserTypeEnumMap[instance.userType]!,
      'balance': instance.balance,
      'minimumBalance': instance.minimumBalance,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'isActive': instance.isActive,
      'currency': instance.currency,
      'dailyLimit': instance.dailyLimit,
      'monthlyLimit': instance.monthlyLimit,
      'transactionCount': instance.transactionCount,
      'totalTransacted': instance.totalTransacted,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
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
  walletId: json['walletId'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  status:
      $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
      TransactionStatus.pending,
  description: json['description'] as String,
  referenceId: json['referenceId'] as String?,
  fromUserId: json['fromUserId'] as String?,
  toUserId: json['toUserId'] as String?,
  commissionPercentage: (json['commissionPercentage'] as num?)?.toDouble(),
  commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
  connectionDetails: json['connectionDetails'] as String?,
  penaltyReason: json['penaltyReason'] as String?,
  tripDetails: json['tripDetails'] as String?,
  subscriptionDetails: json['subscriptionDetails'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  failureReason: json['failureReason'] as String?,
  receiptUrl: json['receiptUrl'] as String?,
  referenceNumber: json['referenceNumber'] as String?,
);

Map<String, dynamic> _$WalletTransactionModelToJson(
  _WalletTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'walletId': instance.walletId,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'description': instance.description,
  'referenceId': instance.referenceId,
  'fromUserId': instance.fromUserId,
  'toUserId': instance.toUserId,
  'commissionPercentage': instance.commissionPercentage,
  'commissionAmount': instance.commissionAmount,
  'connectionDetails': instance.connectionDetails,
  'penaltyReason': instance.penaltyReason,
  'tripDetails': instance.tripDetails,
  'subscriptionDetails': instance.subscriptionDetails,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'failureReason': instance.failureReason,
  'receiptUrl': instance.receiptUrl,
  'referenceNumber': instance.referenceNumber,
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
      minimumBalance: (json['minimumBalance'] as num).toDouble(),
      canMakeContact: json['canMakeContact'] as bool,
      userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
      currency: json['currency'] as String,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$WalletBalanceModelToJson(_WalletBalanceModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'minimumBalance': instance.minimumBalance,
      'canMakeContact': instance.canMakeContact,
      'userType': _$UserTypeEnumMap[instance.userType]!,
      'currency': instance.currency,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_WalletTopUpModel _$WalletTopUpModelFromJson(Map<String, dynamic> json) =>
    _WalletTopUpModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      gatewayReference: json['gatewayReference'] as String?,
      status:
          $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
          TransactionStatus.pending,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      failureReason: json['failureReason'] as String?,
    );

Map<String, dynamic> _$WalletTopUpModelToJson(_WalletTopUpModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'amount': instance.amount,
      'paymentMethod': instance.paymentMethod,
      'gatewayReference': instance.gatewayReference,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'failureReason': instance.failureReason,
    };

_WalletWithdrawalModel _$WalletWithdrawalModelFromJson(
  Map<String, dynamic> json,
) => _WalletWithdrawalModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  amount: (json['amount'] as num).toDouble(),
  bankDetails: json['bankDetails'] as Map<String, dynamic>,
  status:
      $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
      TransactionStatus.pending,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  failureReason: json['failureReason'] as String?,
  transactionId: json['transactionId'] as String?,
);

Map<String, dynamic> _$WalletWithdrawalModelToJson(
  _WalletWithdrawalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'amount': instance.amount,
  'bankDetails': instance.bankDetails,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'failureReason': instance.failureReason,
  'transactionId': instance.transactionId,
};
