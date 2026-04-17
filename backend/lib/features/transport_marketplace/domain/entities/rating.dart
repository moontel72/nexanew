import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final int stars;
  final String? comment;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.stars,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, fromUserId, toUserId, stars, comment, createdAt];
}

