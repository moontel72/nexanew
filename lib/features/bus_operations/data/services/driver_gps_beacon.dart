// NEXATRACE — DRIVER GPS BEACON
// ================================
// Background telemetry handler using Timer.periodic to
// POST location updates to the server every N seconds.
// Feeds the Reverb WebSocket pipeline for 8V live tracking.
//
// MODULE: 15B — High-Frequency Spatial Telemetry Beacon

import 'dart:async';
import 'package:trace_odd/core/services/api_service.dart';

class DriverGpsBeacon {
  final ApiService _api;
  final String _tripId;
  Timer? _timer;
  double _lat = 0, _lng = 0, _speed = 0;
  int _intervalSec;
  bool _running = false;

  DriverGpsBeacon({
    required String tripId,
    ApiService? api,
    int intervalSec = 4,
  }) : _tripId = tripId,
       _api = api ?? ApiService(),
       _intervalSec = intervalSec;

  bool get isRunning => _running;

  /// Start periodic location broadcasts.
  void start({double lat = 0, double lng = 0, double speed = 0}) {
    if (_running) return;
    _lat = lat;
    _lng = lng;
    _speed = speed;
    _running = true;
    _timer = Timer.periodic(Duration(seconds: _intervalSec), (_) => _emit());
  }

  /// Update current position (call from geolocator listener).
  void updatePosition(double lat, double lng, double speed) {
    _lat = lat;
    _lng = lng;
    _speed = speed;
  }

  Future<void> _emit() async {
    try {
      await _api.post(
        '/bus-fleet/driver/update-location/$_tripId',
        body: {'lat': _lat, 'lng': _lng, 'speed': _speed},
      );
    } catch (_) {
      /* silently skip — beacon is fire-and-forget */
    }
  }

  void stop() {
    _timer?.cancel();
    _running = false;
  }

  void dispose() {
    stop();
  }
}
