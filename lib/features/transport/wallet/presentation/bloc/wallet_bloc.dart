import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/repositories/wallet_repository.dart';
import 'package:trace_odd/shared/models/wallet/wallet_model.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

/// Wallet BLoC for managing user's balance and transactions
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({
    required this.walletRepository,
  }) : super(WalletInitial()) {
    // Wallet operations
    on<GetWalletBalance>(_onGetWalletBalance);
    on<GetWalletDetails>(_onGetWalletDetails);
    on<GetTransactionHistory>(_onGetTransactionHistory);
    on<RefreshWalletData>(_onRefreshWalletData);

    // Top-up operations
    on<TopUpWallet>(_onTopUpWallet);
    on<CompleteTopUp>(_onCompleteTopUp);
    on<CancelTopUp>(_onCancelTopUp);

    // Withdrawal operations
    on<InitiateWithdrawal>(_onInitiateWithdrawal);
    on<ApproveWithdrawal>(_onApproveWithdrawal);
    on<RejectWithdrawal>(_onRejectWithdrawal);

    // Transaction operations
    on<DeductConnectionFee>(_onDeductConnectionFee);
    on<DeductCommission>(_onDeductCommission);
    on<ApplyPenalty>(_onApplyPenalty);
    on<AddReward>(_onAddReward);

    // Validation operations
    on<CheckCanDeductAmount>(_onCheckCanDeductAmount);
    on<CheckCanMakeContact>(_onCheckCanMakeContact);

    // Batch operations
    on<GetBalancesForUsers>(_onGetBalancesForUsers);

    // Audit operations
    on<GetAuditTrail>(_onGetAuditTrail);

    // Fraud detection
    on<GetSuspiciousTransactions>(_onGetSuspiciousTransactions);

    // Utility operations
    on<CalculateMinimumBalance>(_onCalculateMinimumBalance);
    on<ValidateWalletForUserType>(_onValidateWalletForUserType);

    // Clear operations
    on<ClearWalletError>(_onClearWalletError);
    on<ClearWalletData>(_onClearWalletData);
  }

  // Wallet operations handlers
  Future<void> _onGetWalletBalance(
    GetWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final result = await walletRepository.getWalletBalance(event.userId);
      result.fold(
        (error) => emit(WalletError(message: error)),
        (balance) {
          final minimumResult = walletRepository.calculateMinimumBalance(
            UserType.values.firstWhere(
              (type) =>
                  type.toString() ==
                  'UserType.${event.userId.split('_').first}',
              orElse: () => UserType.customer,
            ),
          );

          minimumResult.then((res) {
            res.fold(
              (error) => emit(WalletError(message: error)),
              (minimumBalance) {
                emit(WalletBalanceLoaded(
                  balance: balance,
                  minimumBalance: minimumBalance,
                  canMakeContact: balance >= 10.0,
                ));
              },
            );
          });
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to get wallet balance: ${e.toString()}'));
    }
  }

  Future<void> _onGetWalletDetails(
    GetWalletDetails event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final walletResult = await walletRepository.getWallet(event.userId);
      final balanceResult =
          await walletRepository.getWalletBalanceDetails(event.userId);

      walletResult.fold(
        (error) => emit(WalletError(message: error)),
        (wallet) {
          balanceResult.fold(
            (error) => emit(WalletError(message: error)),
            (balanceDetails) {
              emit(WalletDetailsLoaded(
                wallet: wallet,
                balanceDetails: balanceDetails,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to get wallet details: ${e.toString()}'));
    }
  }

  Future<void> _onGetTransactionHistory(
    GetTransactionHistory event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    try {
      final result = await walletRepository.getTransactions(
        walletId: event.walletId,
        limit: event.limit,
        offset: event.offset,
        type: event.transactionType != null
            ? TransactionType.values.firstWhere(
                (type) =>
                    type.toString() ==
                    'TransactionType.${event.transactionType}',
                orElse: () => TransactionType.topUp,
              )
            : null,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (transactions) {
          emit(TransactionHistoryLoaded(
            transactions: transactions,
            hasMore: transactions.length == (event.limit ?? 20),
            totalCount: transactions.length,
          ));
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to get transaction history: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshWalletData(
    RefreshWalletData event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletRefreshing(state));

    try {
      final result = await walletRepository.getWallet(event.userId);
      result.fold(
        (error) => emit(WalletError(message: error)),
        (wallet) {
          // Refresh successful, return to current state
          add(GetWalletDetails(event.userId));
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to refresh wallet data: ${e.toString()}'));
    }
  }

  // Top-up handlers
  Future<void> _onTopUpWallet(
    TopUpWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTopUpLoading());

    try {
      final result = await walletRepository.initiateTopUp(
        walletId: event.walletId,
        amount: event.amount,
        paymentMethod: event.paymentMethod,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (topUp) {
          // In a real implementation, this would return a payment URL
          // For now, we'll simulate it
          emit(TopUpInitiated(
            topUp: topUp,
            paymentUrl: 'https://payment.nexatrace.com/topup/${topUp.id}',
          ));
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to initiate top-up: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteTopUp(
    CompleteTopUp event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTopUpLoading());

    try {
      final result = await walletRepository.completeTopUp(
        topUpId: event.topUpId,
        paymentReference: event.paymentReference,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (topUp) async {
          // Get updated wallet
          final walletResult = await walletRepository.getWallet(topUp.userId);
          walletResult.fold(
            (error) => emit(WalletError(message: error)),
            (wallet) {
              emit(TopUpCompleted(
                topUp: topUp,
                updatedWallet: wallet,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to complete top-up: ${e.toString()}'));
    }
  }

  Future<void> _onCancelTopUp(
    CancelTopUp event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTopUpLoading());

    try {
      final result = await walletRepository.cancelTopUp(event.topUpId);
      result.fold(
        (error) => emit(WalletError(message: error)),
        (_) {
          emit(TopUpCancelled(event.topUpId));
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to cancel top-up: ${e.toString()}'));
    }
  }

  // Withdrawal handlers
  Future<void> _onInitiateWithdrawal(
    InitiateWithdrawal event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletWithdrawalLoading());

    try {
      // Check if user has sufficient balance
      final balanceResult =
          await walletRepository.getWalletBalance(event.walletId);
      balanceResult.fold(
        (error) => emit(WalletError(message: error)),
        (balance) async {
          if (balance < event.amount) {
            emit(InsufficientBalance(
              message: 'Insufficient balance for withdrawal',
              currentBalance: balance,
              requiredAmount: event.amount,
              deficitAmount: event.amount - balance,
            ));
            return;
          }

          final result = await walletRepository.initiateWithdrawal(
            walletId: event.walletId,
            amount: event.amount,
            bankAccountId: event.bankAccountId,
          );

          result.fold(
            (error) => emit(WalletError(message: error)),
            (transaction) {
              emit(WithdrawalInitiated(transaction));
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to initiate withdrawal: ${e.toString()}'));
    }
  }

  Future<void> _onApproveWithdrawal(
    ApproveWithdrawal event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletWithdrawalLoading());

    try {
      final result =
          await walletRepository.approveWithdrawal(event.transactionId);
      result.fold(
        (error) => emit(WalletError(message: error)),
        (_) async {
          // Get transaction details
          final transactionResult =
              await walletRepository.getTransaction(event.transactionId);
          transactionResult.fold(
            (error) => emit(WalletError(message: error)),
            (transaction) async {
              // Get updated wallet
              final walletResult =
                  await walletRepository.getWallet(transaction.walletId);
              walletResult.fold(
                (error) => emit(WalletError(message: error)),
                (wallet) {
                  emit(WithdrawalApproved(
                    transaction: transaction,
                    updatedWallet: wallet,
                  ));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to approve withdrawal: ${e.toString()}'));
    }
  }

  Future<void> _onRejectWithdrawal(
    RejectWithdrawal event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletWithdrawalLoading());

    try {
      final result = await walletRepository.rejectWithdrawal(
        event.transactionId,
        event.reason,
      );
      result.fold(
        (error) => emit(WalletError(message: error)),
        (_) {
          emit(WithdrawalRejected(
            transactionId: event.transactionId,
            reason: event.reason,
          ));
        },
      );
    } catch (e) {
      emit(
          WalletError(message: 'Failed to reject withdrawal: ${e.toString()}'));
    }
  }

  // Transaction handlers
  Future<void> _onDeductConnectionFee(
    DeductConnectionFee event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    try {
      // Check if user can make contact
      final canContactResult =
          await walletRepository.canMakeContact(event.fromUserId);
      canContactResult.fold(
        (error) => emit(WalletError(message: error)),
        (canContact) async {
          if (!canContact) {
            final balanceResult =
                await walletRepository.getWalletBalance(event.fromUserId);
            balanceResult.fold(
              (error) => emit(WalletError(message: error)),
              (balance) {
                emit(InsufficientBalance(
                  message: 'Insufficient balance for connection fee',
                  currentBalance: balance,
                  requiredAmount: 10.0,
                  deficitAmount: 10.0 - balance,
                ));
              },
            );
            return;
          }

          final result = await walletRepository.deductConnectionFee(
            fromUserId: event.fromUserId,
            toUserId: event.toUserId,
            amount: event.amount,
            description: event.description,
          );

          result.fold(
            (error) => emit(WalletError(message: error)),
            (transaction) async {
              // Get updated wallet
              final walletResult =
                  await walletRepository.getWallet(event.fromUserId);
              walletResult.fold(
                (error) => emit(WalletError(message: error)),
                (wallet) {
                  emit(ConnectionFeeDeducted(
                    transaction: transaction,
                    updatedWallet: wallet,
                  ));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to deduct connection fee: ${e.toString()}'));
    }
  }

  Future<void> _onDeductCommission(
    DeductCommission event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    try {
      final result = await walletRepository.deductCommission(
        userId: event.userId,
        amount: event.amount,
        tripId: event.tripId,
        description: event.description,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (transaction) async {
          // Get updated wallet
          final walletResult = await walletRepository.getWallet(event.userId);
          walletResult.fold(
            (error) => emit(WalletError(message: error)),
            (wallet) {
              emit(CommissionDeducted(
                transaction: transaction,
                updatedWallet: wallet,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(
          WalletError(message: 'Failed to deduct commission: ${e.toString()}'));
    }
  }

  Future<void> _onApplyPenalty(
    ApplyPenalty event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    try {
      final result = await walletRepository.applyPenalty(
        userId: event.userId,
        amount: event.amount,
        reason: event.reason,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (transaction) async {
          // Get updated wallet
          final walletResult = await walletRepository.getWallet(event.userId);
          walletResult.fold(
            (error) => emit(WalletError(message: error)),
            (wallet) {
              emit(PenaltyApplied(
                transaction: transaction,
                updatedWallet: wallet,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to apply penalty: ${e.toString()}'));
    }
  }

  Future<void> _onAddReward(
    AddReward event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    try {
      final result = await walletRepository.addReward(
        userId: event.userId,
        amount: event.amount,
        reason: event.reason,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (transaction) async {
          // Get updated wallet
          final walletResult = await walletRepository.getWallet(event.userId);
          walletResult.fold(
            (error) => emit(WalletError(message: error)),
            (wallet) {
              emit(RewardAdded(
                transaction: transaction,
                updatedWallet: wallet,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to add reward: ${e.toString()}'));
    }
  }

  // Validation handlers
  Future<void> _onCheckCanDeductAmount(
    CheckCanDeductAmount event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final result = await walletRepository.canDeductAmount(
        userId: event.userId,
        amount: event.amount,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (canDeduct) async {
          final balanceResult =
              await walletRepository.getWalletBalance(event.userId);
          balanceResult.fold(
            (error) => emit(WalletError(message: error)),
            (balance) {
              emit(CanDeductAmountChecked(
                canDeduct: canDeduct,
                currentBalance: balance,
                requiredAmount: event.amount,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to check deduction capability: ${e.toString()}'));
    }
  }

  Future<void> _onCheckCanMakeContact(
    CheckCanMakeContact event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final result = await walletRepository.canMakeContact(event.userId);
      result.fold(
        (error) => emit(WalletError(message: error)),
        (canMakeContact) async {
          final balanceResult =
              await walletRepository.getWalletBalance(event.userId);
          balanceResult.fold(
            (error) => emit(WalletError(message: error)),
            (balance) {
              emit(CanMakeContactChecked(
                canMakeContact: canMakeContact,
                currentBalance: balance,
                requiredBalance: 10.0,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to check contact capability: ${e.toString()}'));
    }
  }

  // Batch operation handlers
  Future<void> _onGetBalancesForUsers(
    GetBalancesForUsers event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final result = await walletRepository.getBalancesForUsers(event.userIds);
      result.fold(
        (error) => emit(WalletError(message: error)),
        (userBalances) {
          emit(BalancesForUsersLoaded(userBalances));
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to get balances for users: ${e.toString()}'));
    }
  }

  // Audit handlers
  Future<void> _onGetAuditTrail(
    GetAuditTrail event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    try {
      final result = await walletRepository.getAuditTrail(
        userId: event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (auditTrail) {
          emit(AuditTrailLoaded(auditTrail));
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to get audit trail: ${e.toString()}'));
    }
  }

  // Fraud detection handlers
  Future<void> _onGetSuspiciousTransactions(
    GetSuspiciousTransactions event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionLoading());

    try {
      final result = await walletRepository.getSuspiciousTransactions(
        userId: event.userId,
        daysBack: event.daysBack,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (suspiciousTransactions) {
          emit(SuspiciousTransactionsLoaded(
            suspiciousTransactions: suspiciousTransactions,
            totalCount: suspiciousTransactions.length,
          ));
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to get suspicious transactions: ${e.toString()}'));
    }
  }

  // Utility handlers
  Future<void> _onCalculateMinimumBalance(
    CalculateMinimumBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final userType = UserType.values.firstWhere(
        (type) => type.toString() == 'UserType.${event.userType}',
        orElse: () => UserType.customer,
      );

      final result = await walletRepository.calculateMinimumBalance(userType);
      result.fold(
        (error) => emit(WalletError(message: error)),
        (minimumBalance) {
          emit(MinimumBalanceCalculated(
            minimumBalance: minimumBalance,
            userType: event.userType,
          ));
        },
      );
    } catch (e) {
      emit(WalletError(
          message: 'Failed to calculate minimum balance: ${e.toString()}'));
    }
  }

  Future<void> _onValidateWalletForUserType(
    ValidateWalletForUserType event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final userType = UserType.values.firstWhere(
        (type) => type.toString() == 'UserType.${event.userType}',
        orElse: () => UserType.customer,
      );

      final result = await walletRepository.validateWalletForUserType(
        userId: event.userId,
        userType: userType,
      );

      result.fold(
        (error) => emit(WalletError(message: error)),
        (isValid) {
          emit(WalletValidated(
            isValid: isValid,
            userId: event.userId,
            userType: event.userType,
            validationMessage:
                isValid ? 'Wallet is valid' : 'Wallet validation failed',
          ));
        },
      );
    } catch (e) {
      emit(WalletError(message: 'Failed to validate wallet: ${e.toString()}'));
    }
  }

  // Clear handlers
  Future<void> _onClearWalletError(
    ClearWalletError event,
    Emitter<WalletState> emit,
  ) async {
    // If current state is an error, go back to initial state
    if (state is WalletError) {
      emit(WalletInitial());
    }
  }

  Future<void> _onClearWalletData(
    ClearWalletData event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletInitial());
  }
}
