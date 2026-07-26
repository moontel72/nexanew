// Trip & Vault Events — events for driver trip lifecycle + ticket vault
import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();
  @override
  List<Object?> get props => [];
}

class LoadTrip extends TripEvent {
  const LoadTrip();
}

class StartTrip extends TripEvent {
  const StartTrip();
}

class CompleteTrip extends TripEvent {
  const CompleteTrip();
}

class LoadVault extends TripEvent {
  const LoadVault();
}
