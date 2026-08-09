import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/cricket_models.dart';

/// WebSocket client for Laravel Reverb — cricket.match.{id} channel.
///
/// Subscribes to live score updates via Reverb's Pusher-compatible protocol.
/// Falls back gracefully if WebSocket connection fails.
class CricketWebSocketRepository {
  final String _wsUrl;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _scoreController = StreamController<LiveScoreSnapshot>.broadcast();
  bool _isConnected = false;

  CricketWebSocketRepository({required String wsUrl}) : _wsUrl = wsUrl;

  Stream<LiveScoreSnapshot> get scoreStream => _scoreController.stream;
  bool get isConnected => _isConnected;

  /// Subscribe to a match's score channel.
  void subscribeToMatch(String matchId) {
    _disconnect();

    try {
      final uri = Uri.parse('$_wsUrl/app/cricket.match.$matchId');
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        (data) {
          _isConnected = true;
          try {
            final decoded = jsonDecode(data as String);
            // Handle Pusher protocol wrapper
            if (decoded is Map<String, dynamic>) {
              if (decoded['event'] == 'score.updated') {
                final scoreData = jsonDecode(decoded['data'] as String);
                final score = scoreData['score'];
                if (score != null) {
                  _scoreController.add(LiveScoreSnapshot.fromJson(score));
                }
              }
            }
          } catch (_) {
            // Ignore malformed messages
          }
        },
        onError: (error) {
          _isConnected = false;
          // Auto-reconnect after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (!_isConnected) subscribeToMatch(matchId);
          });
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (_) {
      _isConnected = false;
    }
  }

  void _disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    _disconnect();
    _scoreController.close();
  }
}
