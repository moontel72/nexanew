import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

/// User types for wallet system
enum UserType {
  factory,
  goodsCompany,
  truckOwner,
  driver,
  reseller,
  shop,
  customer,
  superAdmin,
  factoryAdmin,
  factoryUser,
  transportAdmin,
}

/// Transaction types for wallet system
enum TransactionType {
  topUp, // Adding money to wallet
  connectionFee, // ₹10 fee for any contact
  commission, // % fee on successful trip
  penalty, // Fraud penalty
  reward, // Honesty reward
  tripPayment, // Payment for trip
  withdrawal, // Withdraw to bank
  refund, // Refund (if applicable)
  subscriptionPayment, // Subscription payment
  planUpgrade, // Plan upgrade payment
  planDowngrade, // Plan downgrade refund
  systemCredit, // System credit (bonus, referral, etc.)
  systemDebit, // System debit (fines, adjustments, etc.)
}

/// Transaction statuses
enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  processing,
  refunded,
}

/// Wallet model for the transport ecosystem and general wallet system
@freezed
abstract class WalletModel with _$WalletModel {
  const factory WalletModel({
    /// Unique identifier
    required String id,

    /// User ID (foreign key to users table)
    required String userId,

    /// Type of user (determines minimum balance requirements)
    required UserType userType,

    /// Current wallet balance
    @Default(0.0) double balance,

    /// Minimum required balance (₹100 for drivers, ₹500 for others)
    required double minimumBalance,

    /// Last transaction timestamp
    required DateTime lastUpdated,

    /// Whether wallet is active
    @Default(true) bool isActive,

    /// Wallet currency (default: PKR)
    @Default('PKR') String currency,

    /// Daily transaction limit
    @Default(100000.0) double dailyLimit,

    /// Monthly transaction limit
    @Default(1000000.0) double monthlyLimit,

    /// Total transactions count
    @Default(0) int transactionCount,

    /// Total amount transacted
    @Default(0.0) double totalTransacted,

    /// Wallet creation timestamp
    required DateTime createdAt,

    /// Wallet last activity timestamp
    DateTime? lastActivityAt,

    /// Additional metadata
    Map<String, dynamic>? metadata,
  }) = _WalletModel;

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  const WalletModel._();

  /// Check if wallet can deduct specified amount
  bool canDeduct(double amount) => balance >= amount;

  /// Check if wallet has minimum balance for contact (₹10 connection fee)
  bool canContact() => balance >= 10.0;

  /// Calculate required top-up amount to reach minimum balance
  double get requiredTopUpAmount {
    if (balance >= minimumBalance) return 0.0;
    return minimumBalance - balance;
  }

  /// Check if wallet is below minimum balance
  bool get isBelowMinimumBalance => balance < minimumBalance;

  /// Check if transaction would exceed daily limit
  bool wouldExceedDailyLimit(double amount) {
    // Assuming we track daily usage elsewhere
    // This is a simplified check
    return amount > dailyLimit;
  }

  /// Check if transaction would exceed monthly limit
  bool wouldExceedMonthlyLimit(double amount) {
    // Assuming we track monthly usage elsewhere
    // This is a simplified check
    return amount > monthlyLimit;
  }

  /// Get formatted balance string with currency
  String get formattedBalance => '$balance $currency';

  /// Get minimum balance description based on user type
  String get minimumBalanceDescription {
    switch (userType) {
      case UserType.driver:
        return 'Minimum ₹100 required for drivers';
      default:
        return 'Minimum ₹500 required';
    }
  }
}

/// Wallet transaction model
@freezed
abstract class WalletTransactionModel with _$WalletTransactionModel {
  const factory WalletTransactionModel({
    /// Unique identifier
    required String id,

    /// Wallet ID (foreign key)
    required String walletId,

    /// Transaction type
    required TransactionType type,

    /// Transaction amount (positive for credit, negative for debit)
    required double amount,

    /// Transaction status
    @Default(TransactionStatus.pending) TransactionStatus status,

    /// Description of transaction
    required String description,

    /// Reference ID (trip ID, load ID, bid ID, subscription ID, etc.)
    String? referenceId,

    /// From user ID (if applicable)
    String? fromUserId,

    /// To user ID (if applicable)
    String? toUserId,

    /// Commission percentage (if type is commission)
    double? commissionPercentage,

    /// Commission amount (if type is commission)
    double? commissionAmount,

    /// Connection fee details (if type is connectionFee)
    String? connectionDetails,

    /// Fraud penalty reason (if type is penalty)
    String? penaltyReason,

    /// Trip details (if type is tripPayment)
    String? tripDetails,

    /// Subscription details (if type is subscriptionPayment)
    String? subscriptionDetails,

    /// Additional metadata
    Map<String, dynamic>? metadata,

    /// Transaction creation timestamp
    required DateTime createdAt,

    /// Transaction completion timestamp
    DateTime? completedAt,

    /// Transaction failure/cancellation reason
    String? failureReason,

    /// Receipt/Proof URL
    String? receiptUrl,

    /// Bank/Wallet reference number
    String? referenceNumber,
  }) = _WalletTransactionModel;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);

  const WalletTransactionModel._();

  /// Check if transaction is credit (adds to balance)
  bool get isCredit => amount > 0;

  /// Check if transaction is debit (subtracts from balance)
  bool get isDebit => amount < 0;

  /// Get formatted amount with sign
  String get formattedAmount {
    final sign = isCredit ? '+' : '';
    return '$sign$amount PKR';
  }

  /// Get transaction type description
  String get typeDescription {
    switch (type) {
      case TransactionType.topUp:
        return 'Top Up';
      case TransactionType.connectionFee:
        return 'Connection Fee';
      case TransactionType.commission:
        return 'Commission';
      case TransactionType.penalty:
        return 'Penalty';
      case TransactionType.reward:
        return 'Reward';
      case TransactionType.tripPayment:
        return 'Trip Payment';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.subscriptionPayment:
        return 'Subscription Payment';
      case TransactionType.planUpgrade:
        return 'Plan Upgrade';
      case TransactionType.planDowngrade:
        return 'Plan Downgrade';
      case TransactionType.systemCredit:
        return 'System Credit';
      case TransactionType.systemDebit:
        return 'System Debit';
    }
  }

  String get typeDisplay => typeDescription;

  /// Get status description
  String get statusDescription {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.refunded:
        return 'Refunded';
    }
  }

  /// Check if transaction is completed successfully
  bool get isCompleted => status == TransactionStatus.completed;

  /// Check if transaction is pending
  bool get isPending => status == TransactionStatus.pending;

  /// Check if transaction failed
  bool get isFailed => status == TransactionStatus.failed;
}

/// Wallet balance details model
@freezed
abstract class WalletBalanceModel with _$WalletBalanceModel {
  const factory WalletBalanceModel({
    required double balance,
    required double minimumBalance,
    required bool canMakeContact,
    required UserType userType,
    required String currency,
    DateTime? lastUpdated,
  }) = _WalletBalanceModel;

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceModelFromJson(json);
}

/// Wallet top-up request model
@freezed
abstract class WalletTopUpModel with _$WalletTopUpModel {
  const factory WalletTopUpModel({
    /// Unique identifier
    required String id,

    /// User ID
    required String userId,

    /// Amount to top up
    required double amount,

    /// Payment method
    required String paymentMethod,

    /// Payment gateway reference
    String? gatewayReference,

    /// Payment status
    @Default(TransactionStatus.pending) TransactionStatus status,

    /// Additional metadata
    Map<String, dynamic>? metadata,

    /// Request creation timestamp
    required DateTime createdAt,

    /// Request completion timestamp
    DateTime? completedAt,

    /// Failure reason (if any)
    String? failureReason,
  }) = _WalletTopUpModel;

  factory WalletTopUpModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTopUpModelFromJson(json);
}

/// Wallet withdrawal request model
@freezed
abstract class WalletWithdrawalModel with _$WalletWithdrawalModel {
  const factory WalletWithdrawalModel({
    /// Unique identifier
    required String id,

    /// User ID
    required String userId,

    /// Amount to withdraw
    required double amount,

    /// Bank account details
    required Map<String, dynamic> bankDetails,

    /// Withdrawal status
    @Default(TransactionStatus.pending) TransactionStatus status,

    /// Additional metadata
    Map<String, dynamic>? metadata,

    /// Request creation timestamp
    required DateTime createdAt,

    /// Request completion timestamp
    DateTime? completedAt,

    /// Failure reason (if any)
    String? failureReason,

    /// Transaction ID (if processed)
    String? transactionId,
  }) = _WalletWithdrawalModel;

  factory WalletWithdrawalModel.fromJson(Map<String, dynamic> json) =>
      _$WalletWithdrawalModelFromJson(json);
}
