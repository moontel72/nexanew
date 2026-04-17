import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/shared/models/wallet/wallet_model.dart';
import 'package:nexatrace_system/core/repositories/wallet_repository.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/load.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/bid.dart';
import 'package:nexatrace_system/core/services/fraud_detection_service.dart';
import 'package:nexatrace_system/core/services/subscription_service.dart';

// Events
abstract class TransportIntegrationEvent extends Equatable {
  const TransportIntegrationEvent();

  @override
  List<Object> get props => [];
}

class InitiateContactWithUser extends TransportIntegrationEvent {
  final String fromUserId;
  final String toUserId;
  final UserType fromUserType;
  final UserType toUserType;
  final String? relatedEntityId;
  final String? relatedEntityType;

  const InitiateContactWithUser({
    required this.fromUserId,
    required this.toUserId,
    required this.fromUserType,
    required this.toUserType,
    this.relatedEntityId,
    this.relatedEntityType,
  });

  @override
  List<Object> get props => [
        fromUserId,
        toUserId,
        fromUserType,
        toUserType,
        relatedEntityId ?? '',
        relatedEntityType ?? '',
      ];
}

class CheckWalletForLoadPosting extends TransportIntegrationEvent {
  final String userId;
  final UserType userType;
  final Load load;

  const CheckWalletForLoadPosting({
    required this.userId,
    required this.userType,
    required this.load,
  });

  @override
  List<Object> get props => [userId, userType, load];
}

class CheckWalletForBidPlacement extends TransportIntegrationEvent {
  final String userId;
  final UserType userType;
  final Bid bid;
  final String loadId;

  const CheckWalletForBidPlacement({
    required this.userId,
    required this.userType,
    required this.bid,
    required this.loadId,
  });

  @override
  List<Object> get props => [userId, userType, bid, loadId];
}

class ProcessTripPayment extends TransportIntegrationEvent {
  final String tripId;
  final String shipperId;
  final String transporterId;
  final double amount;
  final double commissionPercentage;

  const ProcessTripPayment({
    required this.tripId,
    required this.shipperId,
    required this.transporterId,
    required this.amount,
    required this.commissionPercentage,
  });

  @override
  List<Object> get props => [
        tripId,
        shipperId,
        transporterId,
        amount,
        commissionPercentage,
      ];
}

class ValidateChatMessage extends TransportIntegrationEvent {
  final String senderId;
  final String receiverId;
  final String message;
  final int warningCount;

  const ValidateChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.warningCount,
  });

  @override
  List<Object> get props => [senderId, receiverId, message, warningCount];
}

class CheckSubscriptionLimits extends TransportIntegrationEvent {
  final String userId;
  final UserType userType;
  final String feature;

  const CheckSubscriptionLimits({
    required this.userId,
    required this.userType,
    required this.feature,
  });

  @override
  List<Object> get props => [userId, userType, feature];
}

class ClearIntegrationError extends TransportIntegrationEvent {}

// States
abstract class TransportIntegrationState extends Equatable {
  const TransportIntegrationState();

  @override
  List<Object> get props => [];
}

class TransportIntegrationInitial extends TransportIntegrationState {}

class TransportIntegrationLoading extends TransportIntegrationState {}

class ContactInitiated extends TransportIntegrationState {
  final String chatId;
  final String transactionId;
  final double remainingBalance;

  const ContactInitiated({
    required this.chatId,
    required this.transactionId,
    required this.remainingBalance,
  });

  @override
  List<Object> get props => [chatId, transactionId, remainingBalance];
}

class WalletValidatedForLoad extends TransportIntegrationState {
  final bool canPostLoad;
  final double currentBalance;
  final double requiredBalance;
  final String message;

  const WalletValidatedForLoad({
    required this.canPostLoad,
    required this.currentBalance,
    required this.requiredBalance,
    required this.message,
  });

  @override
  List<Object> get props => [
        canPostLoad,
        currentBalance,
        requiredBalance,
        message,
      ];
}

class WalletValidatedForBid extends TransportIntegrationState {
  final bool canPlaceBid;
  final double currentBalance;
  final double requiredBalance;
  final String message;

  const WalletValidatedForBid({
    required this.canPlaceBid,
    required this.currentBalance,
    required this.requiredBalance,
    required this.message,
  });

  @override
  List<Object> get props => [
        canPlaceBid,
        currentBalance,
        requiredBalance,
        message,
      ];
}

class TripPaymentProcessed extends TransportIntegrationState {
  final String tripId;
  final String paymentTransactionId;
  final String commissionTransactionId;
  final double shipperBalance;
  final double transporterBalance;

  const TripPaymentProcessed({
    required this.tripId,
    required this.paymentTransactionId,
    required this.commissionTransactionId,
    required this.shipperBalance,
    required this.transporterBalance,
  });

  @override
  List<Object> get props => [
        tripId,
        paymentTransactionId,
        commissionTransactionId,
        shipperBalance,
        transporterBalance,
      ];
}

class ChatMessageValidated extends TransportIntegrationState {
  final bool isValid;
  final String? warningMessage;
  final bool penaltyApplied;
  final double penaltyAmount;

  const ChatMessageValidated({
    required this.isValid,
    this.warningMessage,
    this.penaltyApplied = false,
    this.penaltyAmount = 0.0,
  });

  @override
  List<Object> get props => [
        isValid,
        warningMessage ?? '',
        penaltyApplied,
        penaltyAmount,
      ];
}

class SubscriptionLimitsChecked extends TransportIntegrationState {
  final bool allowed;
  final String message;
  final Map<String, dynamic> limits;
  final Map<String, dynamic> usage;

  const SubscriptionLimitsChecked({
    required this.allowed,
    required this.message,
    required this.limits,
    required this.usage,
  });

  @override
  List<Object> get props => [allowed, message, limits, usage];
}

class TransportIntegrationError extends TransportIntegrationState {
  final String message;
  final String? errorCode;
  final bool isWalletError;
  final bool isFraudError;
  final bool isSubscriptionError;

  const TransportIntegrationError({
    required this.message,
    this.errorCode,
    this.isWalletError = false,
    this.isFraudError = false,
    this.isSubscriptionError = false,
  });

  @override
  List<Object> get props => [
        message,
        errorCode ?? '',
        isWalletError,
        isFraudError,
        isSubscriptionError,
      ];
}

class InsufficientBalanceError extends TransportIntegrationState {
  final String message;
  final double currentBalance;
  final double requiredBalance;
  final double deficit;

  const InsufficientBalanceError({
    required this.message,
    required this.currentBalance,
    required this.requiredBalance,
    required this.deficit,
  });

  @override
  List<Object> get props => [message, currentBalance, requiredBalance, deficit];
}

class FraudDetectedError extends TransportIntegrationState {
  final String message;
  final double penaltyAmount;
  final String reason;
  final List<String> evidence;

  const FraudDetectedError({
    required this.message,
    required this.penaltyAmount,
    required this.reason,
    required this.evidence,
  });

  @override
  List<Object> get props => [message, penaltyAmount, reason, evidence];
}

class SubscriptionLimitExceeded extends TransportIntegrationState {
  final String message;
  final String feature;
  final int currentUsage;
  final int limit;
  final String requiredPlan;

  const SubscriptionLimitExceeded({
    required this.message,
    required this.feature,
    required this.currentUsage,
    required this.limit,
    required this.requiredPlan,
  });

  @override
  List<Object> get props =>
      [message, feature, currentUsage, limit, requiredPlan];
}

class TransportIntegrationBloc
    extends Bloc<TransportIntegrationEvent, TransportIntegrationState> {
  final WalletRepository walletRepository;
  final FraudDetectionService fraudDetectionService;
  final SubscriptionService subscriptionService;

  TransportIntegrationBloc({
    required this.walletRepository,
    required this.fraudDetectionService,
    required this.subscriptionService,
  }) : super(TransportIntegrationInitial()) {
    on<InitiateContactWithUser>(_onInitiateContactWithUser);
    on<CheckWalletForLoadPosting>(_onCheckWalletForLoadPosting);
    on<CheckWalletForBidPlacement>(_onCheckWalletForBidPlacement);
    on<ProcessTripPayment>(_onProcessTripPayment);
    on<ValidateChatMessage>(_onValidateChatMessage);
    on<CheckSubscriptionLimits>(_onCheckSubscriptionLimits);
    on<ClearIntegrationError>(_onClearIntegrationError);
  }

  Future<void> _onInitiateContactWithUser(
    InitiateContactWithUser event,
    Emitter<TransportIntegrationState> emit,
  ) async {
    emit(TransportIntegrationLoading());

    try {
      final subscriptionResult = await subscriptionService.canUseFeature(
        userId: event.fromUserId,
        userType: event.fromUserType,
        feature: 'contact_user',
      );

      if (!subscriptionResult.allowed) {
        emit(SubscriptionLimitExceeded(
          message: subscriptionResult.message,
          feature: 'contact_user',
          currentUsage: subscriptionResult.currentUsage,
          limit: subscriptionResult.limit,
          requiredPlan: subscriptionResult.requiredPlan,
        ));
        return;
      }

      final walletResult = await walletRepository.getWallet(event.fromUserId);
      walletResult.fold(
        (error) => emit(TransportIntegrationError(
          message: error,
          isWalletError: true,
        )),
        (wallet) async {
          if (!wallet.canContact()) {
            emit(InsufficientBalanceError(
              message:
                  'Insufficient balance for contact. Minimum ₹10 required.',
              currentBalance: wallet.balance,
              requiredBalance: 10.0,
              deficit: 10.0 - wallet.balance,
            ));
            return;
          }

          final fraudResult = await fraudDetectionService.checkPattern(
            event.fromUserId,
            event.toUserId,
          );

          fraudResult.fold(
            (error) => emit(TransportIntegrationError(
              message: error,
              isFraudError: true,
            )),
            (isSuspicious) async {
              if (isSuspicious) {}

              final transactionResult =
                  await walletRepository.deductConnectionFee(
                fromUserId: event.fromUserId,
                toUserId: event.toUserId,
                amount: 10.0,
                description:
                    'Connection fee: Contact with ${event.toUserType.toString()}',
              );

              transactionResult.fold(
                (error) => emit(TransportIntegrationError(
                  message: error,
                  isWalletError: true,
                )),
                (transaction) {
                  walletRepository.getWallet(event.fromUserId).then(
                    (walletResult) {
                      walletResult.fold(
                        (error) => emit(TransportIntegrationError(
                          message: error,
                          isWalletError: true,
                        )),
                        (updatedWallet) {
                          emit(ContactInitiated(
                            chatId:
                                'chat_${event.fromUserId}_${event.toUserId}',
                            transactionId: transaction.id,
                            remainingBalance: updatedWallet.balance,
                          ));
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(TransportIntegrationError(
        message: 'Failed to initiate contact: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCheckWalletForLoadPosting(
    CheckWalletForLoadPosting event,
    Emitter<TransportIntegrationState> emit,
  ) async {
    emit(TransportIntegrationLoading());

    try {
      final subscriptionResult = await subscriptionService.canUseFeature(
        userId: event.userId,
        userType: event.userType,
        feature: 'post_load',
      );

      if (!subscriptionResult.allowed) {
        emit(SubscriptionLimitExceeded(
          message: subscriptionResult.message,
          feature: 'post_load',
          currentUsage: subscriptionResult.currentUsage,
          limit: subscriptionResult.limit,
          requiredPlan: subscriptionResult.requiredPlan,
        ));
        return;
      }

      final walletResult = await walletRepository.getWallet(event.userId);
      walletResult.fold(
        (error) => emit(TransportIntegrationError(
          message: error,
          isWalletError: true,
        )),
        (wallet) {
          final canPost = wallet.canContact();
          emit(WalletValidatedForLoad(
            canPostLoad: canPost,
            currentBalance: wallet.balance,
            requiredBalance: 10.0,
            message: canPost
                ? 'Wallet validated for load posting'
                : 'Insufficient balance. Minimum ₹10 required for contact.',
          ));
        },
      );
    } catch (e) {
      emit(TransportIntegrationError(
        message: 'Failed to validate wallet for load posting: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCheckWalletForBidPlacement(
    CheckWalletForBidPlacement event,
    Emitter<TransportIntegrationState> emit,
  ) async {
    emit(TransportIntegrationLoading());

    try {
      final subscriptionResult = await subscriptionService.canUseFeature(
        userId: event.userId,
        userType: event.userType,
        feature: 'place_bid',
      );

      if (!subscriptionResult.allowed) {
        emit(SubscriptionLimitExceeded(
          message: subscriptionResult.message,
          feature: 'place_bid',
          currentUsage: subscriptionResult.currentUsage,
          limit: subscriptionResult.limit,
          requiredPlan: subscriptionResult.requiredPlan,
        ));
        return;
      }

      final walletResult = await walletRepository.getWallet(event.userId);
      walletResult.fold(
        (error) => emit(TransportIntegrationError(
          message: error,
          isWalletError: true,
        )),
        (wallet) {
          final canBid = wallet.canContact();
          emit(WalletValidatedForBid(
            canPlaceBid: canBid,
            currentBalance: wallet.balance,
            requiredBalance: 10.0,
            message: canBid
                ? 'Wallet validated for bid placement'
                : 'Insufficient balance. Minimum ₹10 required for contact.',
          ));
        },
      );
    } catch (e) {
      emit(TransportIntegrationError(
        message: 'Failed to validate wallet for bid placement: ${e.toString()}',
      ));
    }
  }

  Future<void> _onProcessTripPayment(
    ProcessTripPayment event,
    Emitter<TransportIntegrationState> emit,
  ) async {
    emit(TransportIntegrationLoading());

    try {
      final commissionAmount =
          event.amount * (event.commissionPercentage / 100);
      final netAmount = event.amount - commissionAmount;

      final shipperWalletResult =
          await walletRepository.getWallet(event.shipperId);
      final transporterWalletResult =
          await walletRepository.getWallet(event.transporterId);

      if (shipperWalletResult.isLeft() || transporterWalletResult.isLeft()) {
        emit(TransportIntegrationError(
          message: 'Failed to get wallet information',
          isWalletError: true,
        ));
        return;
      }

      final WalletModel? shipperWallet =
          shipperWalletResult.fold((_) => null, (w) => w);
      final WalletModel? transporterWallet =
          transporterWalletResult.fold((_) => null, (w) => w);

      if (shipperWallet == null || transporterWallet == null) {
        emit(TransportIntegrationError(
          message: 'Failed to get wallet information',
          isWalletError: true,
        ));
        return;
      }

      if (!shipperWallet.canDeduct(event.amount)) {
        emit(InsufficientBalanceError(
          message: 'Shipper has insufficient balance for trip payment',
          currentBalance: shipperWallet.balance,
          requiredBalance: event.amount,
          deficit: event.amount - shipperWallet.balance,
        ));
        return;
      }

      final paymentResult = await walletRepository.createTransaction(
        WalletTransactionModel(
          id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
          walletId: event.shipperId,
          fromUserId: event.shipperId,
          toUserId: event.transporterId,
          amount: -event.amount,
          type: TransactionType.tripPayment,
          status: TransactionStatus.completed,
          description: 'Trip payment for trip ${event.tripId}',
          metadata: {
            'trip_id': event.tripId,
            'commission_percentage': event.commissionPercentage
          },
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        ),
      );

      final commissionResult = await walletRepository.createTransaction(
        WalletTransactionModel(
          id: 'commission_${DateTime.now().millisecondsSinceEpoch}',
          walletId: event.transporterId,
          fromUserId: event.transporterId,
          toUserId: 'nexatrace',
          amount: -commissionAmount,
          type: TransactionType.commission,
          status: TransactionStatus.completed,
          description: 'Commission for trip ${event.tripId}',
          metadata: {'trip_id': event.tripId, 'original_amount': event.amount},
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        ),
      );

      await walletRepository.updateWalletBalance(
        event.transporterId,
        netAmount,
      );

      await walletRepository.updateWalletBalance(
        event.shipperId,
        -event.amount,
      );

      final updatedShipperResult =
          await walletRepository.getWallet(event.shipperId);
      final updatedTransporterResult =
          await walletRepository.getWallet(event.transporterId);

      if (updatedShipperResult.isLeft() || updatedTransporterResult.isLeft()) {
        emit(TransportIntegrationError(
          message: 'Failed to get updated wallet balances',
          isWalletError: true,
        ));
        return;
      }

      final WalletModel? updatedShipper =
          updatedShipperResult.fold((_) => null, (w) => w);
      final WalletModel? updatedTransporter =
          updatedTransporterResult.fold((_) => null, (w) => w);

      if (updatedShipper == null || updatedTransporter == null) {
        emit(TransportIntegrationError(
          message: 'Failed to get updated wallet balances',
          isWalletError: true,
        ));
        return;
      }

      paymentResult.fold(
        (error) => emit(TransportIntegrationError(
          message: 'Failed to process payment: $error',
          isWalletError: true,
        )),
        (paymentTransaction) {
          commissionResult.fold(
            (error) => emit(TransportIntegrationError(
              message: 'Failed to process commission: $error',
              isWalletError: true,
            )),
            (commissionTransaction) {
              emit(TripPaymentProcessed(
                tripId: event.tripId,
                paymentTransactionId: paymentTransaction.id,
                commissionTransactionId: commissionTransaction.id,
                shipperBalance: updatedShipper.balance,
                transporterBalance: updatedTransporter.balance,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(TransportIntegrationError(
        message: 'Failed to process trip payment: ${e.toString()}',
      ));
    }
  }

  Future<void> _onValidateChatMessage(
    ValidateChatMessage event,
    Emitter<TransportIntegrationState> emit,
  ) async {
    emit(TransportIntegrationLoading());

    try {
      final validationResult = await fraudDetectionService.validateChatMessage(
        senderId: event.senderId,
        receiverId: event.receiverId,
        message: event.message,
        warningCount: event.warningCount,
      );

      validationResult.fold(
        (error) => emit(TransportIntegrationError(
          message: error,
          isFraudError: true,
        )),
        (result) {
          if (!result.isValid) {
            if (result.penaltyApplied) {
              emit(FraudDetectedError(
                message: result.warningMessage,
                penaltyAmount: result.penaltyAmount,
                reason: 'Phone number sharing in chat',
                evidence: [event.message],
              ));
            } else {
              emit(ChatMessageValidated(
                isValid: false,
                warningMessage: result.warningMessage,
                penaltyApplied: result.penaltyApplied,
                penaltyAmount: result.penaltyAmount,
              ));
            }
          } else {
            emit(ChatMessageValidated(
              isValid: true,
              warningMessage: null,
            ));
          }
        },
      );
    } catch (e) {
      emit(TransportIntegrationError(
        message: 'Failed to validate chat message: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCheckSubscriptionLimits(
    CheckSubscriptionLimits event,
    Emitter<TransportIntegrationState> emit,
  ) async {
    emit(TransportIntegrationLoading());

    try {
      final result = await subscriptionService.canUseFeature(
        userId: event.userId,
        userType: event.userType,
        feature: event.feature,
      );

      emit(SubscriptionLimitsChecked(
        allowed: result.allowed,
        message: result.message,
        limits: result.limits,
        usage: result.usage,
      ));
    } catch (e) {
      emit(TransportIntegrationError(
        message: 'Failed to check subscription limits: ${e.toString()}',
        isSubscriptionError: true,
      ));
    }
  }

  Future<void> _onClearIntegrationError(
    ClearIntegrationError event,
    Emitter<TransportIntegrationState> emit,
  ) async {
    if (state is TransportIntegrationError ||
        state is InsufficientBalanceError ||
        state is FraudDetectedError ||
        state is SubscriptionLimitExceeded) {
      emit(TransportIntegrationInitial());
    }
  }
}
