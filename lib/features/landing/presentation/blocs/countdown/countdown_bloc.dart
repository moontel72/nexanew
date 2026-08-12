// Launch Countdown BLoC
//
// Pure unidirectional countdown state machine. The target timestamp comes
// from the landing JSON meta (launchTarget) — never hardcoded in Dart.
// The LandingPage forwards the parsed target via CountdownStarted once
// content is loaded.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class CountdownState {
  final Duration remaining;
  final bool isLive;

  const CountdownState({required this.remaining, required this.isLive});

  int get days => remaining.inDays;
  int get hours => remaining.inHours % 24;
  int get minutes => remaining.inMinutes % 60;
  int get seconds => remaining.inSeconds % 60;

  static const CountdownState initial = CountdownState(
    remaining: Duration.zero,
    isLive: true,
  );
}

sealed class CountdownEvent {
  const CountdownEvent();
}

final class CountdownStarted extends CountdownEvent {
  final DateTime target;
  const CountdownStarted(this.target);
}

final class CountdownStopped extends CountdownEvent {
  const CountdownStopped();
}

class CountdownBloc extends Bloc<CountdownEvent, CountdownState> {
  Timer? _ticker;
  DateTime? _target;

  CountdownBloc() : super(CountdownState.initial) {
    on<CountdownStarted>(_onStarted);
    on<CountdownStopped>(_onStopped);
  }

  void _onStarted(CountdownStarted event, Emitter<CountdownState> emit) {
    _ticker?.cancel();
    _target = event.target;
    _tick(emit);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick(emit));
  }

  void _tick(Emitter<CountdownState> emit) {
    final target = _target;
    if (target == null) return;
    final remaining = target.difference(DateTime.now().toUtc());
    emit(CountdownState(remaining: remaining, isLive: remaining.isNegative));
  }

  void _onStopped(CountdownStopped event, Emitter<CountdownState> emit) {
    _ticker?.cancel();
    _ticker = null;
    _target = null;
    emit(CountdownState.initial);
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
