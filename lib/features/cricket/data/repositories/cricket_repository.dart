import 'dart:async';
import 'dart:convert';

import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/core/services/websocket_hub.dart';

import '../models/cricket_models.dart';

/// Cricket data repository — uses shared ApiClient (singleton) and WebSocketHub.
///
/// Zero custom HTTP or WebSocket clients. All networking goes through
/// the existing shared infrastructure so auth tokens, retries, and error
/// handling are consistent across the entire ecosystem.
class CricketRepository {
  final ApiClient _api = ApiClient();

  /// Stream controller for live score updates from Reverb.
  final _scoreController = StreamController<LiveScoreSnapshot>.broadcast();

  Stream<LiveScoreSnapshot> get scoreStream => _scoreController.stream;

  // ═══════════════════════════════════════════════════════════
  // Auth (Cricket Manager Bearer token — stored as shared token)
  // ═══════════════════════════════════════════════════════════

  Future<void> setAuthToken(String token) => _api.setAuthToken(token);
  Future<void> clearToken() => _api.clearAuthToken();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await _api.post(
        '/api/v1/cricket/manager/login',
        body: {'email': email, 'password': password},
        requiresAuth: false,
      );
      if (res is Map<String, dynamic>) {
        final token = res['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await _api.setAuthToken(token);
        }
        return res;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<CricketManagerModel?> getManager() async {
    try {
      final res = await _api.get('/api/v1/cricket/manager/me');
      if (res is Map<String, dynamic> && res['manager'] != null) {
        return CricketManagerModel.fromJson(res['manager']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Public Endpoints (no auth)
  // ═══════════════════════════════════════════════════════════

  Future<TournamentModel?> getActiveTournament() async {
    try {
      final res = await _api.get(
        '/api/v1/cricket/public/tournament/active',
        requiresAuth: false,
      );
      if (res is Map<String, dynamic> && res['tournament'] != null) {
        return TournamentModel.fromJson(res['tournament']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<MatchModel>> getLiveMatches({String? tournamentId}) async {
    try {
      final params = <String, dynamic>{};
      if (tournamentId != null) params['tournament_id'] = tournamentId;
      final res = await _api.get(
        '/api/v1/cricket/public/matches/live',
        queryParams: params,
        requiresAuth: false,
      );
      if (res is Map<String, dynamic> && res['matches'] is List) {
        return (res['matches'] as List)
            .map((m) => MatchModel.fromJson(m))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<MatchModel>> getAllMatches({String? tournamentId}) async {
    try {
      final params = <String, dynamic>{};
      if (tournamentId != null) params['tournament_id'] = tournamentId;
      final res = await _api.get(
        '/api/v1/cricket/public/matches',
        queryParams: params,
        requiresAuth: false,
      );
      if (res is Map<String, dynamic> && res['matches'] is List) {
        return (res['matches'] as List)
            .map((m) => MatchModel.fromJson(m))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<LiveScoreSnapshot?> fetchScore(String matchId) async {
    try {
      final res = await _api.get(
        '/api/v1/cricket/public/matches/$matchId/score',
        requiresAuth: false,
      );
      if (res is Map<String, dynamic>) {
        return LiveScoreSnapshot.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<StreamModel>> getStreams(String matchId) async {
    try {
      final res = await _api.get(
        '/api/v1/cricket/public/matches/$matchId/stream',
        requiresAuth: false,
      );
      if (res is Map<String, dynamic> && res['streams'] is List) {
        return (res['streams'] as List)
            .map((s) => StreamModel.fromJson(s))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<SponsorModel>> getMatchSponsors(String matchId) async {
    try {
      final res = await _api.get(
        '/api/v1/cricket/public/matches/$matchId/sponsors',
        requiresAuth: false,
      );
      if (res is Map<String, dynamic> && res['sponsors'] is List) {
        return (res['sponsors'] as List)
            .map((s) => SponsorModel.fromJson(s))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<TeamModel>> getTeams() async {
    try {
      final res = await _api.get(
        '/api/v1/cricket/public/teams',
        requiresAuth: false,
      );
      if (res is Map<String, dynamic> && res['teams'] is List) {
        return (res['teams'] as List)
            .map((t) => TeamModel.fromJson(t))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Live Score — WebSocket via shared WebSocketHub
  // ═══════════════════════════════════════════════════════════

  void subscribeToScore(String matchId) {
    final channel = 'cricket.match.$matchId';
    try {
      WebSocketHub.instance.subscribe(channel, (event) {
        try {
          final score = LiveScoreSnapshot.fromJson(event);
          _scoreController.add(score);
        } catch (_) {}
      });
    } catch (_) {
      // WebSocketHub not initialized — gracefully degrade to REST polling
    }
  }

  void unsubscribeFromScore(String matchId) {
    try {
      WebSocketHub.instance.unsubscribe('cricket.match.$matchId');
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════
  // Stream Management (Manager Auth)
  // ═══════════════════════════════════════════════════════════

  Future<List<StreamModel>> getManagerStreams(String matchId) async {
    try {
      final res = await _api.get(
        '/api/v1/cricket/manager/matches/$matchId/streams',
      );
      if (res is List) {
        return res.map((s) => StreamModel.fromJson(s)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> activateStream(String matchId, String streamId) async {
    try {
      await _api.post(
        '/api/v1/cricket/manager/matches/$matchId/streams/$streamId/activate',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deactivateStream(String matchId, String streamId) async {
    try {
      await _api.post(
        '/api/v1/cricket/manager/matches/$matchId/streams/$streamId/deactivate',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Score Update (Manager Auth)
  // ═══════════════════════════════════════════════════════════

  Future<bool> updateScore(String matchId, Map<String, dynamic> ball) async {
    try {
      await _api.post(
        '/api/v1/cricket/manager/matches/$matchId/score',
        body: ball,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> undoLastBall(String matchId) async {
    try {
      await _api.post('/api/v1/cricket/manager/matches/$matchId/score/undo');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Voice Score (Manager Auth)
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> processVoiceScore(
    String matchId,
    String transcript,
  ) async {
    try {
      final res = await _api.post(
        '/api/v1/cricket/manager/voice-score/process',
        body: {'match_id': matchId, 'transcript': transcript},
      );
      if (res is Map<String, dynamic>) return res;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> applyVoiceScore(String logId) async {
    try {
      await _api.post('/api/v1/cricket/manager/voice-score/$logId/apply');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Cleanup
  // ═══════════════════════════════════════════════════════════

  void dispose() {
    _scoreController.close();
  }
}
