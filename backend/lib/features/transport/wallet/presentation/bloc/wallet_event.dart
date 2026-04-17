part of 'wallet_bloc.dart';

/// Events for Wallet BLoC
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

// Get wallet events
class GetWalletBalance extends WalletEvent {
  final String userId;

  const GetWalletBalance(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetWalletDetails extends WalletEvent {
  final String userId;

  const GetWalletDetails(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetTransactionHistory extends WalletEvent {
  final String walletId;
  final int? limit;
  final int? offset;
  final String? transactionType;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetTransactionHistory({
    required this.walletId,
    this.limit,
    this.offset,
    this.transactionType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object> get props => [
        walletId,
        limit ?? 0,
        offset ?? 0,
        transactionType ?? '',
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now(),
      ];
}

// Top-up events
class TopUpWallet extends WalletEvent {
  final String walletId;
  final double amount;
  final String paymentMethod;

  const TopUpWallet({
    required this.walletId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object> get props => [walletId, amount, paymentMethod];
}

class CompleteTopUp extends WalletEvent {
  final String topUpId;
  final String paymentReference;

  const CompleteTopUp({
    required this.topUpId,
    required this.paymentReference,
  });

  @override
  List<Object> get props => [topUpId, paymentReference];
}

class CancelTopUp extends WalletEvent {
  final String topUpId;

  const CancelTopUp(this.topUpId);

  @override
  List<Object> get props => [topUpId];
}

// Withdrawal events
class InitiateWithdrawal extends WalletEvent {
  final String walletId;
  final double amount;
  final String bankAccountId;

  const InitiateWithdrawal({
    required this.walletId,
    required this.amount,
    required this.bankAccountId,
  });

  @override
  List<Object> get props => [walletId, amount, bankAccountId];
}

class ApproveWithdrawal extends WalletEvent {
  final String transactionId;

  const ApproveWithdrawal(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class RejectWithdrawal extends WalletEvent {
  final String transactionId;
  final String reason;

  const RejectWithdrawal({
    required this.transactionId,
    required this.reason,
  });

  @override
  List<Object> get props => [transactionId, reason];
}

// Transaction events
class DeductConnectionFee extends WalletEvent {
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String description;

  const DeductConnectionFee({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.description,
  });

  @override
  List<Object> get props => [fromUserId, toUserId, amount, description];
}

class DeductCommission extends WalletEvent {
  final String userId;
  final double amount;
  final String tripId;
  final String description;

  const DeductCommission({
    required this.userId,
    required this.amount,
    required this.tripId,
    required this.description,
  });

  @override
  List<Object> get props => [userId, amount, tripId, description];
}

class ApplyPenalty extends WalletEvent {
  final String userId;
  final double amount;
  final String reason;

  const ApplyPenalty({
    required this.userId,
    required this.amount,
    required this.reason,
  });

  @override
  List<Object> get props => [userId, amount, reason];
}

class AddReward extends WalletEvent {
  final String userId;
  final double amount;
  final String reason;

  const AddReward({
    required this.userId,
    required this.amount,
    required this.reason,
  });

  @override
  List<Object> get props => [userId, amount, reason];
}

// Validation events
class CheckCanDeductAmount extends WalletEvent {
  final String userId;
  final double amount;

  const CheckCanDeductAmount({
    required this.userId,
    required this.amount,
  });

  @override
  List<Object> get props => [userId, amount];
}

class CheckCanMakeContact extends WalletEvent {
  final String userId;

  const CheckCanMakeContact(this.userId);

  @override
  List<Object> get props => [userId];
}

// Batch operations
class GetBalancesForUsers extends WalletEvent {
  final List<String> userIds;

  const GetBalancesForUsers(this.userIds);

  @override
  List<Object> get props => [userIds];
}

// Audit events
class GetAuditTrail extends WalletEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetAuditTrail({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object> get props => [
        userId,
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now(),
      ];
}

// Fraud detection events
class GetSuspiciousTransactions extends WalletEvent {
  final String userId;
  final int daysBack;

  const GetSuspiciousTransactions({
    required this.userId,
    required this.daysBack,
  });

  @override
  List<Object> get props => [userId, daysBack];
}

// Utility events
class CalculateMinimumBalance extends WalletEvent {
  final String userType;

  const CalculateMinimumBalance(this.userType);

  @override
  List<Object> get props => [userType];
}

class ValidateWalletForUserType extends WalletEvent {
  final String userId;
  final String userType;

  const ValidateWalletForUserType({
    required this.userId,
    required this.userType,
  });

  @override
  List<Object> get props => [userId, userType];
}

// Refresh events
class RefreshWalletData extends WalletEvent {
  final String userId;

  const RefreshWalletData(this.userId);

  @override
  List<Object> get props => [userId];
}

// Clear events
class ClearWalletError extends WalletEvent {}

class ClearWalletData extends WalletEvent {}
