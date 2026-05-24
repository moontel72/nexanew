// WebSocket BLoC Mixin — Lifecycle-aware stream-to-event binding
//
// A single reactive mixin that auto-subscribes to WebSocketHub streams on
// BLoC initialization and guarantees absolute teardown on close(), eliminating
// manual subscription management and memory leaks across all 6 panels.
//
// Type parameters:
//   E — the bloc's event type
//   S — the bloc's state type
//
// Usage:
//   class LiveTrackingBloc extends Bloc<TrackingEvent, TrackingState>
//       with WebSocketBlocMixin<TrackingEvent, TrackingState> {
//     LiveTrackingBloc() : super(TrackingInitial()) {
//       connectStream(WebSocketHub.instance.busFleetGps,
//         (e) => BusLocationReceived(e.payload));
//     }
//   }
//
// Under 100 lines — delegates stream lifecycle to a single internal collection.

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

mixin WebSocketBlocMixin<E, S> on Bloc<E, S> {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Subscribe to [stream], mapping each emitted value [T] into a bloc event
  /// via [mapper] and dispatching it with `add(event)`.
  ///
  /// The subscription is automatically tracked and cancelled in [close].
  void connectStream<T>(Stream<T> stream, E Function(T data) mapper) {
    final sub = stream.listen(
      (data) {
        try {
          add(mapper(data));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('WS_BLOC_MIXIN: Event map error — $e');
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('WS_BLOC_MIXIN: Stream error — $error');
        }
      },
      cancelOnError: false,
    );
    _subscriptions.add(sub);
  }

  /// Convenience: subscribe directly to a `WebSocketHub` typed getter with
  /// the standard `WsEvent → E` mapping.
  void connectWsStream(
    Stream<dynamic> wsStream,
    E Function(Map<String, dynamic> payload) mapper,
  ) {
    connectStream(wsStream, (event) {
      // WsEvent and other payload-bearing types expose .payload.
      final payload = (event as dynamic).payload as Map<String, dynamic>;
      return mapper(payload);
    });
  }

  /// Cancel all tracked subscriptions and clear the collection.
  /// Called automatically by [close].
  void cancelAllSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> close() {
    cancelAllSubscriptions();
    return super.close();
  }
}
