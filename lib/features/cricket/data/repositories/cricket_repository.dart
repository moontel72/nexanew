import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/core/services/websocket_hub.dart';

import '../models/cricket_models.dart';

/// Cricket data repository.
///
/// Manages its own Bearer token under `cricket_manager_token` in
/// SharedPreferences so it never conflicts with the main app's
/// sanctum token stored by ApiClient under `auth_token`.
class CricketRepository {
  static const _tokenKey = 'cricket_manager_token';
  final http.Client _http = http.Client();

  String? _bearerToken;
  final _scoreController = StreamController<LiveScoreSnapshot>.broadcast();
  Stream<LiveScoreSnapshot> get scoreStream => _scoreController.stream;

  // ────────────────────────────────────────────────────────────
  // Token management
  // ────────────────────────────────────────────────────────────

  Future<void> _persistToken(String token) async {
    _bearerToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _loadToken() async {
    if (_bearerToken != null) return;
    final prefs = await SharedPreferences.getInstance();
    _bearerToken = prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    _bearerToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> _authHeaders() async {
    await _loadToken();
    return _bearerToken != null
        ? {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_bearerToken',
          }
        : {'Content-Type': 'application/json'};
  }

  // ────────────────────────────────────────────────────────────
  // Auth
  // ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await _http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await _persistToken(token);
        }
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<CricketManagerModel?> getManager() async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/me'),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['manager'] != null) {
          return CricketManagerModel.fromJson(data['manager']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────
  // Public Endpoints (no auth)
  // ────────────────────────────────────────────────────────────

  Future<TournamentModel?> getActiveTournament() async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/tournament/active',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['tournament'] != null) {
          return TournamentModel.fromJson(data['tournament']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<MatchModel>> getLiveMatches({String? tournamentId}) async {
    try {
      var url = '${ApiConfig.apiBaseUrl}/cricket/public/matches/live';
      if (tournamentId != null) url += '?tournament_id=$tournamentId';
      final res = await _http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['matches'] as List)
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
      var url = '${ApiConfig.apiBaseUrl}/cricket/public/matches';
      if (tournamentId != null) url += '?tournament_id=$tournamentId';
      final res = await _http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['matches'] as List)
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
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/score',
        ),
      );
      if (res.statusCode == 200) {
        return LiveScoreSnapshot.fromJson(jsonDecode(res.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<StreamModel>> getStreams(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/stream',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['streams'] as List)
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
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/sponsors',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['sponsors'] as List)
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
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/public/teams'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['teams'] as List)
            .map((t) => TeamModel.fromJson(t))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────
  // Live Score — WebSocket via shared WebSocketHub
  // ────────────────────────────────────────────────────────────

  void subscribeToScore(String matchId) {
    try {
      WebSocketHub.instance.subscribe('cricket.match.$matchId', (event) {
        try {
          _scoreController.add(LiveScoreSnapshot.fromJson(event));
        } catch (_) {}
      });
    } catch (_) {}
  }

  void unsubscribeFromScore(String matchId) {
    try {
      WebSocketHub.instance.unsubscribe('cricket.match.$matchId');
    } catch (_) {}
  }

  // ────────────────────────────────────────────────────────────
  // Manager Auth endpoints
  // ────────────────────────────────────────────────────────────

  Future<List<StreamModel>> getManagerStreams(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/streams',
        ),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list.map((s) => StreamModel.fromJson(s)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> activateStream(String matchId, String streamId) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/streams/$streamId/activate',
        ),
        headers: await _authHeaders(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deactivateStream(String matchId, String streamId) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/streams/$streamId/deactivate',
        ),
        headers: await _authHeaders(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateScore(String matchId, Map<String, dynamic> ball) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/score',
        ),
        headers: await _authHeaders(),
        body: jsonEncode(ball),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> undoLastBall(String matchId) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/score/undo',
        ),
        headers: await _authHeaders(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> processVoiceScore(
    String matchId,
    String transcript,
  ) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/voice-score/process',
        ),
        headers: await _authHeaders(),
        body: jsonEncode({'match_id': matchId, 'transcript': transcript}),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> applyVoiceScore(String logId) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/voice-score/$logId/apply',
        ),
        headers: await _authHeaders(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _scoreController.close();
    _http.close();
  }
}
