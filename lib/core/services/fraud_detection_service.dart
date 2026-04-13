import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:nexatrace_system/shared/models/wallet/wallet_model.dart';
import 'package:nexatrace_system/core/services/analytics_service.dart';
import 'package:nexatrace_system/core/services/cache_service.dart';
import '../repositories/wallet_repository.dart';

class FraudDetectionService {
  final CacheService cache;
  final AnalyticsService analytics;
  final WalletRepository walletRepository;

  FraudDetectionService({
    required this.cache,
    required this.analytics,
    required this.walletRepository,
  });

  // Pattern: User contacted, then cancelled, then no trip
  Future<Either<String, bool>> checkPattern(
      String userId1, String userId2) async {
    try {
      final recentInteractions = await _getRecentInteractions(userId1, userId2);

      int cancelCount = 0;
      int contactCount = 0;

      for (var interaction in recentInteractions) {
        if (interaction.type == 'contact') {
          contactCount++;
          if (interaction.followUpAction == 'cancel' && !interaction.hasTrip) {
            cancelCount++;
          }
        }
      }

      // If more than 3 cancellations without trips in last 24h
      if (cancelCount >= 3) {
        await _flagForReview(userId1, userId2);
        return Right(true);
      }

      // If more than 10 contacts in 24h without any trip
      if (contactCount >= 10 && cancelCount == contactCount) {
        await _flagForReview(userId1, userId2);
        return Right(true);
      }

      return Right(false);
    } catch (e) {
      return Left('Failed to check pattern: ${e.toString()}');
    }
  }

  // Detect phone number sharing in chat
  bool containsPhoneNumber(String message) {
    // Pakistani phone number patterns
    final patterns = [
      r'03[0-9]{9}', // 03001234567
      r'\+92[0-9]{10}', // +923001234567
      r'0[0-9]{10}', // 03001234567 (alternative)
      r'0092[0-9]{10}', // 00923001234567
      r'92[0-9]{10}', // 923001234567
    ];

    for (var pattern in patterns) {
      if (RegExp(pattern).hasMatch(message)) {
        return true;
      }
    }
    return false;
  }

  // Detect WhatsApp links
  bool containsWhatsAppLink(String message) {
    final patterns = [
      r'wa\.me\/',
      r'whatsapp\.com',
      r'chat\.whatsapp\.com',
      r'whatsapp:\/\/',
      r'whatsapp group',
      r'whatsapp chat',
    ];

    for (var pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(message)) {
        return true;
      }
    }
    return false;
  }

  // Detect external payment requests
  bool containsPaymentRequest(String message) {
    final patterns = [
      r'easypaisa',
      r'jazzcash',
      r'send money',
      r'pay outside',
      r'cash payment',
      r'direct payment',
      r'bank transfer',
      r'account number',
      r'IBAN',
      r'account no',
    ];

    for (var pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(message)) {
        return true;
      }
    }
    return false;
  }

  // Apply penalty for confirmed fraud
  Future<Either<String, bool>> applyFraudPenalty({
    required String userId1,
    required String userId2,
    required String reason,
    List<String> evidence = const [],
    double? customPenalty,
  }) async {
    try {
      const defaultPenalty = 500.0; // ₹500 penalty
      final penalty = customPenalty ?? defaultPenalty;

      // Check if users have sufficient balance
      final balance1 = await walletRepository.getWalletBalance(userId1);
      final balance2 = await walletRepository.getWalletBalance(userId2);

      if (balance1.isLeft() || balance2.isLeft()) {
        return Left('Failed to get wallet balances');
      }

      final balance1Value = balance1.getOrElse(() => 0.0);
      final balance2Value = balance2.getOrElse(() => 0.0);

      if (balance1Value < penalty || balance2Value < penalty) {
        return Left('Insufficient balance for penalty');
      }

      // Deduct from both users
      final deduct1 =
          await walletRepository.updateWalletBalance(userId1, -penalty);
      final deduct2 =
          await walletRepository.updateWalletBalance(userId2, -penalty);

      if (deduct1.isLeft() || deduct2.isLeft()) {
        return Left('Failed to deduct penalty');
      }

      // Add to NexaTrace revenue
      await walletRepository.updateWalletBalance('nexatrace', penalty * 2);

      // Create penalty transactions
      await walletRepository.createTransaction(
        WalletTransactionModel(
          id: 'penalty_${DateTime.now().millisecondsSinceEpoch}_1',
          walletId: userId1,
          fromUserId: userId1,
          toUserId: 'nexatrace',
          amount: -penalty,
          type: TransactionType.penalty,
          status: TransactionStatus.completed,
          description: 'Fraud penalty: $reason',
          metadata: {'evidence': evidence, 'related_user': userId2},
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        ),
      );

      await walletRepository.createTransaction(
        WalletTransactionModel(
          id: 'penalty_${DateTime.now().millisecondsSinceEpoch}_2',
          walletId: userId2,
          fromUserId: userId2,
          toUserId: 'nexatrace',
          amount: -penalty,
          type: TransactionType.penalty,
          status: TransactionStatus.completed,
          description: 'Fraud penalty: $reason',
          metadata: {'evidence': evidence, 'related_user': userId1},
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        ),
      );

      // Log fraud
      await analytics.logFraud(
        userId1: userId1,
        userId2: userId2,
        penalty: penalty,
        reason: reason,
        evidence: evidence,
      );

      // Suspend accounts if repeated offense
      await _checkAndSuspendAccounts(userId1, userId2);

      return Right(true);
    } catch (e) {
      return Left('Failed to apply fraud penalty: ${e.toString()}');
    }
  }

  // Check for repeated offenses and suspend accounts
  Future<void> _checkAndSuspendAccounts(String userId1, String userId2) async {
    final offenses1 = await _getFraudOffenses(userId1);
    final offenses2 = await _getFraudOffenses(userId2);

    if (offenses1 >= 3) {
      await _suspendAccount(userId1, 'Repeated fraud offenses');
    }

    if (offenses2 >= 3) {
      await _suspendAccount(userId2, 'Repeated fraud offenses');
    }
  }

  // Validate chat message for fraud indicators
  Future<Either<String, ChatValidationResult>> validateChatMessage({
    required String senderId,
    required String receiverId,
    required String message,
    required int warningCount,
  }) async {
    try {
      final validationResult = ChatValidationResult();

      // Check for phone numbers
      if (containsPhoneNumber(message)) {
        validationResult.hasPhoneNumber = true;
        validationResult.isValid = false;
        validationResult.penaltyAmount = 500.0;
        validationResult.warningMessage =
            'Phone number sharing detected. ₹500 penalty will be applied.';

        // Apply penalty immediately for repeated offense
        if (warningCount >= 2) {
          await applyFraudPenalty(
            userId1: senderId,
            userId2: receiverId,
            reason: 'Phone number sharing in chat',
            evidence: [message],
          );
          validationResult.penaltyApplied = true;
        }
      }

      // Check for WhatsApp links
      if (containsWhatsAppLink(message)) {
        validationResult.hasWhatsAppLink = true;
        validationResult.isValid = false;
        validationResult.warningMessage =
            'WhatsApp links are not allowed. Please stay in the app.';
      }

      // Check for payment requests
      if (containsPaymentRequest(message)) {
        validationResult.hasPaymentRequest = true;
        validationResult.isValid = false;
        validationResult.warningMessage =
            'External payment requests are not allowed. Use in-app wallet only.';
      }

      // Check for suspicious pattern
      final patternResult = await checkPattern(senderId, receiverId);
      patternResult.fold(
        (error) => null,
        (isSuspicious) {
          if (isSuspicious) {
            validationResult.hasSuspiciousPattern = true;
            validationResult.isValid = false;
            validationResult.warningMessage =
                'Suspicious behavior detected. Account under review.';
          }
        },
      );

      return Right(validationResult);
    } catch (e) {
      return Left('Failed to validate chat message: ${e.toString()}');
    }
  }

  // Monitor transaction patterns
  Future<Either<String, List<SuspiciousTransaction>>> monitorTransactions({
    required String userId,
    int daysBack = 7,
  }) async {
    try {
      final transactions = await walletRepository.getTransactions(
        walletId: userId,
        startDate: DateTime.now().subtract(Duration(days: daysBack)),
        endDate: DateTime.now(),
      );

      return transactions.fold(
        (error) => Left(error),
        (txList) async {
          final suspicious = <SuspiciousTransaction>[];

          // Check for rapid connection fee deductions
          final connectionFees = txList
              .where((tx) =>
                  tx.type == TransactionType.connectionFee && tx.isDebit)
              .toList();

          if (connectionFees.length >= 5) {
            suspicious.add(SuspiciousTransaction(
              type: 'RapidConnectionFees',
              count: connectionFees.length,
              amount:
                  connectionFees.fold(0.0, (sum, tx) => sum + tx.amount.abs()),
              description: 'Multiple connection fees in short period',
            ));
          }

          // Check for small top-ups followed by immediate deductions
          final smallTopUps = txList
              .where((tx) =>
                  tx.type == TransactionType.topUp &&
                  tx.amount > 0 &&
                  tx.amount <= 20.0)
              .toList();

          for (var topUp in smallTopUps) {
            final subsequentDeductions = txList
                .where((tx) =>
                    tx.createdAt.isAfter(topUp.createdAt) &&
                    tx.createdAt
                        .isBefore(topUp.createdAt.add(Duration(hours: 1))) &&
                    tx.isDebit)
                .toList();

            if (subsequentDeductions.length >= 3) {
              suspicious.add(SuspiciousTransaction(
                type: 'SmallTopUpPattern',
                count: subsequentDeductions.length,
                amount: subsequentDeductions.fold(
                    0.0, (sum, tx) => sum + tx.amount.abs()),
                description: 'Small top-up followed by multiple deductions',
              ));
            }
          }

          // Check for circular transactions
          final circularPattern =
              await _detectCircularTransactions(userId, txList);
          if (circularPattern.isNotEmpty) {
            suspicious.add(SuspiciousTransaction(
              type: 'CircularTransactions',
              count: circularPattern.length,
              amount:
                  circularPattern.fold(0.0, (sum, tx) => sum + tx.amount.abs()),
              description: 'Circular transaction pattern detected',
            ));
          }

          return Right(suspicious);
        },
      );
    } catch (e) {
      return Left('Failed to monitor transactions: ${e.toString()}');
    }
  }

  // Generate fraud report
  Future<Either<String, FraudReport>> generateFraudReport({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    List<String> evidence = const [],
    String? tripId,
  }) async {
    try {
      final report = FraudReport(
        id: 'fraud_${DateTime.now().millisecondsSinceEpoch}',
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reason: reason,
        evidence: evidence,
        tripId: tripId,
        status: FraudReportStatus.pending,
        createdAt: DateTime.now(),
      );

      // Save report to database
      await _saveFraudReport(report);

      // Check if immediate action is needed
      if (_requiresImmediateAction(reason)) {
        await applyFraudPenalty(
          userId1: reporterId,
          userId2: reportedUserId,
          reason: reason,
          evidence: evidence,
        );
        report.status = FraudReportStatus.actionTaken;
      }

      // Notify admin team
      await _notifyAdmins(report);

      return Right(report);
    } catch (e) {
      return Left('Failed to generate fraud report: ${e.toString()}');
    }
  }

  // Private helper methods
  Future<List<Interaction>> _getRecentInteractions(
      String userId1, String userId2) async {
    // Implementation would fetch from database
    return [];
  }

  Future<void> _flagForReview(String userId1, String userId2) async {
    // Implementation would flag users for admin review
  }

  Future<int> _getFraudOffenses(String userId) async {
    // Implementation would fetch from database
    return 0;
  }

  Future<void> _suspendAccount(String userId, String reason) async {
    // Implementation would suspend account
  }

  Future<List<WalletTransactionModel>> _detectCircularTransactions(
    String userId,
    List<WalletTransactionModel> transactions,
  ) async {
    // Implementation would detect circular transaction patterns
    return [];
  }

  Future<void> _saveFraudReport(FraudReport report) async {
    // Implementation would save to database
  }

  Future<void> _notifyAdmins(FraudReport report) async {
    // Implementation would notify admin team
  }

  bool _requiresImmediateAction(String reason) {
    const immediateReasons = [
      'phone_number_sharing',
      'payment_outside_app',
      'whatsapp_contact',
      'fake_load',
      'fake_truck',
    ];
    return immediateReasons.contains(reason);
  }
}

// Supporting classes
class ChatValidationResult {
  bool isValid = true;
  bool hasPhoneNumber = false;
  bool hasWhatsAppLink = false;
  bool hasPaymentRequest = false;
  bool hasSuspiciousPattern = false;
  bool penaltyApplied = false;
  double penaltyAmount = 0.0;
  String warningMessage = '';
}

class SuspiciousTransaction {
  final String type;
  final int count;
  final double amount;
  final String description;

  SuspiciousTransaction({
    required this.type,
    required this.count,
    required this.amount,
    required this.description,
  });
}

class FraudReport {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final List<String> evidence;
  final String? tripId;
  FraudReportStatus status;
  final DateTime createdAt;
  DateTime? resolvedAt;
  String? resolutionNotes;
  double? penaltyApplied;

  FraudReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.evidence,
    this.tripId,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolutionNotes,
    this.penaltyApplied,
  });
}

enum FraudReportStatus {
  pending,
  investigating,
  confirmed,
  rejected,
  actionTaken,
}

class Interaction {
  final String type;
  final String followUpAction;
  final bool hasTrip;

  Interaction({
    required this.type,
    required this.followUpAction,
    required this.hasTrip,
  });
}
