import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/shared/models/wallet/wallet_model.dart';

abstract class WalletRepository {
  // Wallet operations
  Future<Either<String, WalletModel>> getWallet(String userId);
  Future<Either<String, WalletModel>> createWallet({
    required String userId,
    required UserType userType,
    required double initialBalance,
  });
  Future<Either<String, WalletModel>> updateWalletBalance(
    String userId,
    double amount,
  );
  Future<Either<String, bool>> deleteWallet(String userId);

  // Transaction operations
  Future<Either<String, WalletTransactionModel>> createTransaction(
    WalletTransactionModel transaction,
  );
  Future<Either<String, List<WalletTransactionModel>>> getTransactions({
    required String walletId,
    int? limit,
    int? offset,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<String, WalletTransactionModel>> getTransaction(
      String transactionId);
  Future<Either<String, bool>> updateTransactionStatus(
    String transactionId,
    TransactionStatus status,
  );

  // Specialized transaction methods
  Future<Either<String, WalletTransactionModel>> deductConnectionFee({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String description,
  });

  Future<Either<String, WalletTransactionModel>> deductCommission({
    required String userId,
    required double amount,
    required String tripId,
    required String description,
  });

  Future<Either<String, WalletTransactionModel>> applyPenalty({
    required String userId,
    required double amount,
    required String reason,
  });

  Future<Either<String, WalletTransactionModel>> addReward({
    required String userId,
    required double amount,
    required String reason,
  });

  // Top-up operations
  Future<Either<String, WalletTopUpModel>> initiateTopUp({
    required String walletId,
    required double amount,
    required String paymentMethod,
  });

  Future<Either<String, WalletTopUpModel>> completeTopUp({
    required String topUpId,
    required String paymentReference,
  });

  Future<Either<String, bool>> cancelTopUp(String topUpId);

  // Withdrawal operations
  Future<Either<String, WalletTransactionModel>> initiateWithdrawal({
    required String walletId,
    required double amount,
    required String bankAccountId,
  });

  Future<Either<String, bool>> approveWithdrawal(String transactionId);
  Future<Either<String, bool>> rejectWithdrawal(
      String transactionId, String reason);

  // Balance operations
  Future<Either<String, double>> getWalletBalance(String userId);
  Future<Either<String, WalletBalanceModel>> getWalletBalanceDetails(
      String userId);

  // Validation methods
  Future<Either<String, bool>> canDeductAmount({
    required String userId,
    required double amount,
  });

  Future<Either<String, bool>> canMakeContact(String userId);

  // Batch operations
  Future<Either<String, Map<String, double>>> getBalancesForUsers(
      List<String> userIds);
  Future<Either<String, bool>> batchUpdateBalances(
      Map<String, double> balanceUpdates);

  // Audit operations
  Future<Either<String, List<WalletTransactionModel>>> getAuditTrail({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Fraud detection support
  Future<Either<String, List<WalletTransactionModel>>>
      getSuspiciousTransactions({
    required String userId,
    int daysBack,
  });

  // Utility methods
  Future<Either<String, double>> calculateMinimumBalance(UserType userType);
  Future<Either<String, bool>> validateWalletForUserType({
    required String userId,
    required UserType userType,
  });
}
