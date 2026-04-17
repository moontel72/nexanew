part of 'wallet_bloc.dart';

/// States for Wallet BLoC
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

// Initial state
class WalletInitial extends WalletState {}

// Loading states
class WalletLoading extends WalletState {}

class WalletTopUpLoading extends WalletState {}

class WalletWithdrawalLoading extends WalletState {}

class WalletTransactionLoading extends WalletState {}

// Loaded states
class WalletBalanceLoaded extends WalletState {
  final double balance;
  final double minimumBalance;
  final bool canMakeContact;

  const WalletBalanceLoaded({
    required this.balance,
    required this.minimumBalance,
    required this.canMakeContact,
  });

  @override
  List<Object> get props => [balance, minimumBalance, canMakeContact];
}

class WalletDetailsLoaded extends WalletState {
  final WalletModel wallet;
  final WalletBalanceModel balanceDetails;

  const WalletDetailsLoaded({
    required this.wallet,
    required this.balanceDetails,
  });

  @override
  List<Object> get props => [wallet, balanceDetails];
}

class TransactionHistoryLoaded extends WalletState {
  final List<WalletTransactionModel> transactions;
  final bool hasMore;
  final int totalCount;

  const TransactionHistoryLoaded({
    required this.transactions,
    required this.hasMore,
    required this.totalCount,
  });

  @override
  List<Object> get props => [transactions, hasMore, totalCount];
}

// Top-up states
class TopUpInitiated extends WalletState {
  final WalletTopUpModel topUp;
  final String paymentUrl;

  const TopUpInitiated({
    required this.topUp,
    required this.paymentUrl,
  });

  @override
  List<Object> get props => [topUp, paymentUrl];
}

class TopUpCompleted extends WalletState {
  final WalletTopUpModel topUp;
  final WalletModel updatedWallet;

  const TopUpCompleted({
    required this.topUp,
    required this.updatedWallet,
  });

  @override
  List<Object> get props => [topUp, updatedWallet];
}

class TopUpCancelled extends WalletState {
  final String topUpId;

  const TopUpCancelled(this.topUpId);

  @override
  List<Object> get props => [topUpId];
}

// Withdrawal states
class WithdrawalInitiated extends WalletState {
  final WalletTransactionModel transaction;

  const WithdrawalInitiated(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class WithdrawalApproved extends WalletState {
  final WalletTransactionModel transaction;
  final WalletModel updatedWallet;

  const WithdrawalApproved({
    required this.transaction,
    required this.updatedWallet,
  });

  @override
  List<Object> get props => [transaction, updatedWallet];
}

class WithdrawalRejected extends WalletState {
  final String transactionId;
  final String reason;

  const WithdrawalRejected({
    required this.transactionId,
    required this.reason,
  });

  @override
  List<Object> get props => [transactionId, reason];
}

// Transaction states
class ConnectionFeeDeducted extends WalletState {
  final WalletTransactionModel transaction;
  final WalletModel updatedWallet;

  const ConnectionFeeDeducted({
    required this.transaction,
    required this.updatedWallet,
  });

  @override
  List<Object> get props => [transaction, updatedWallet];
}

class CommissionDeducted extends WalletState {
  final WalletTransactionModel transaction;
  final WalletModel updatedWallet;

  const CommissionDeducted({
    required this.transaction,
    required this.updatedWallet,
  });

  @override
  List<Object> get props => [transaction, updatedWallet];
}

class PenaltyApplied extends WalletState {
  final WalletTransactionModel transaction;
  final WalletModel updatedWallet;

  const PenaltyApplied({
    required this.transaction,
    required this.updatedWallet,
  });

  @override
  List<Object> get props => [transaction, updatedWallet];
}

class RewardAdded extends WalletState {
  final WalletTransactionModel transaction;
  final WalletModel updatedWallet;

  const RewardAdded({
    required this.transaction,
    required this.updatedWallet,
  });

  @override
  List<Object> get props => [transaction, updatedWallet];
}

// Validation states
class CanDeductAmountChecked extends WalletState {
  final bool canDeduct;
  final double currentBalance;
  final double requiredAmount;

  const CanDeductAmountChecked({
    required this.canDeduct,
    required this.currentBalance,
    required this.requiredAmount,
  });

  @override
  List<Object> get props => [canDeduct, currentBalance, requiredAmount];
}

class CanMakeContactChecked extends WalletState {
  final bool canMakeContact;
  final double currentBalance;
  final double requiredBalance;

  const CanMakeContactChecked({
    required this.canMakeContact,
    required this.currentBalance,
    required this.requiredBalance,
  });

  @override
  List<Object> get props => [canMakeContact, currentBalance, requiredBalance];
}

// Batch operation states
class BalancesForUsersLoaded extends WalletState {
  final Map<String, double> userBalances;

  const BalancesForUsersLoaded(this.userBalances);

  @override
  List<Object> get props => [userBalances];
}

// Audit states
class AuditTrailLoaded extends WalletState {
  final List<WalletTransactionModel> auditTrail;

  const AuditTrailLoaded(this.auditTrail);

  @override
  List<Object> get props => [auditTrail];
}

// Fraud detection states
class SuspiciousTransactionsLoaded extends WalletState {
  final List<WalletTransactionModel> suspiciousTransactions;
  final int totalCount;

  const SuspiciousTransactionsLoaded({
    required this.suspiciousTransactions,
    required this.totalCount,
  });

  @override
  List<Object> get props => [suspiciousTransactions, totalCount];
}

// Utility states
class MinimumBalanceCalculated extends WalletState {
  final double minimumBalance;
  final String userType;

  const MinimumBalanceCalculated({
    required this.minimumBalance,
    required this.userType,
  });

  @override
  List<Object> get props => [minimumBalance, userType];
}

class WalletValidated extends WalletState {
  final bool isValid;
  final String userId;
  final String userType;
  final String? validationMessage;

  const WalletValidated({
    required this.isValid,
    required this.userId,
    required this.userType,
    this.validationMessage,
  });

  @override
  List<Object> get props =>
      [isValid, userId, userType, validationMessage ?? ''];
}

// Error states
class WalletError extends WalletState {
  final String message;
  final String? errorCode;
  final bool isNetworkError;
  final bool isServerError;
  final bool isUnauthorized;
  final bool isValidationError;

  const WalletError({
    required this.message,
    this.errorCode,
    this.isNetworkError = false,
    this.isServerError = false,
    this.isUnauthorized = false,
    this.isValidationError = false,
  });

  @override
  List<Object> get props => [
        message,
        errorCode ?? '',
        isNetworkError,
        isServerError,
        isUnauthorized,
        isValidationError,
      ];
}

// Insufficient balance states
class InsufficientBalance extends WalletState {
  final String message;
  final double currentBalance;
  final double requiredAmount;
  final double deficitAmount;

  const InsufficientBalance({
    required this.message,
    required this.currentBalance,
    required this.requiredAmount,
    required this.deficitAmount,
  });

  @override
  List<Object> get props =>
      [message, currentBalance, requiredAmount, deficitAmount];
}

// Wallet required states
class WalletRequired extends WalletState {
  final String message;
  final double minimumBalance;
  final String userType;

  const WalletRequired({
    required this.message,
    required this.minimumBalance,
    required this.userType,
  });

  @override
  List<Object> get props => [message, minimumBalance, userType];
}

// Fraud detected states
class FraudDetected extends WalletState {
  final String message;
  final double penaltyAmount;
  final String reason;
  final List<String> evidence;

  const FraudDetected({
    required this.message,
    required this.penaltyAmount,
    required this.reason,
    required this.evidence,
  });

  @override
  List<Object> get props => [message, penaltyAmount, reason, evidence];
}

// No data states
class NoWalletFound extends WalletState {
  final String userId;

  const NoWalletFound(this.userId);

  @override
  List<Object> get props => [userId];
}

class NoTransactionsFound extends WalletState {
  final String message;

  const NoTransactionsFound(this.message);

  @override
  List<Object> get props => [message];
}

// Refresh states
class WalletRefreshing extends WalletState {
  final WalletState currentState;

  const WalletRefreshing(this.currentState);

  @override
  List<Object> get props => [currentState];
}

// Empty states
class WalletEmpty extends WalletState {
  final String message;

  const WalletEmpty(this.message);

  @override
  List<Object> get props => [message];
}
