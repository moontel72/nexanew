import 'package:equatable/equatable.dart';

class Route extends Equatable {
  final String id;
  final String origin;
  final String destination;
  final double? distanceKm;
  final Duration? estimatedDuration;

  const Route({
    required this.id,
    required this.origin,
    required this.destination,
    this.distanceKm,
    this.estimatedDuration,
  });

  @override
  List<Object?> get props => [id, origin, destination, distanceKm, estimatedDuration];
}

