import 'package:equatable/equatable.dart';

enum BidStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}

class Bid extends Equatable {
  final String id;
  final String loadId;
  final String bidderId;
  final double amount;
  final BidStatus status;
  final String? notes;
  final DateTime createdAt;

  const Bid({
    required this.id,
    required this.loadId,
    required this.bidderId,
    required this.amount,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, loadId, bidderId, amount, status, notes, createdAt];
}

