import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/core/services/websocket_hub.dart';

import '../models/cricket_models.dart';
import '../models/replay_models.dart';

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

  /// Auth headers for multipart uploads.
  ///
  /// CRITICAL: must NOT set Content-Type — the http package generates the
  /// `multipart/form-data; boundary=...` header itself. Setting
  /// `application/json` here would make the server ignore the file body.
  Future<Map<String, String>> _authHeadersMultipart() async {
    await _loadToken();
    return _bearerToken != null
        ? {'Authorization': 'Bearer $_bearerToken'}
        : const <String, String>{};
  }

  // ────────────────────────────────────────────────────────────
  // Auth
  // ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = _parseBody(res);
    if (res.statusCode != 200) {
      throw Exception(
        body?['message'] ?? 'Login failed (HTTP ${res.statusCode})',
      );
    }
    final token = body?['token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('No token in login response');
    }
    await _persistToken(token);
    return body ?? {'token': token};
  }

  Future<CricketManagerModel> getManager() async {
    final res = await _http.get(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/me'),
      headers: await _authHeaders(),
    );
    final body = _parseBody(res);
    if (res.statusCode != 200) {
      throw Exception(
        body?['message'] ?? 'Failed to load profile (HTTP ${res.statusCode})',
      );
    }
    if (body?['manager'] == null) {
      throw Exception('Profile data missing');
    }
    return CricketManagerModel.fromJson(body!['manager']);
  }

  /// Safely parse response body as JSON. Returns null if body is HTML/plaintext.
  Map<String, dynamic>? _parseBody(http.Response res) {
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      // Server returned non-JSON (HTML error page)
      if (res.statusCode >= 500) {
        throw Exception(
          'Server error (HTTP ${res.statusCode}). Check Laravel logs.',
        );
      }
      return null;
    }
  }

  /// Extract the first validation error message from a 422 response.
  String? _extractValidationErrors(Map<String, dynamic>? body) {
    if (body == null) return null;
    final errors = body['errors'];
    if (errors is Map) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    return null;
  }

  // ────────────────────────────────────────────────────────────
  // Public Endpoints (no auth)
  // ────────────────────────────────────────────────────────────

  Future<TournamentModel?> getActiveTournament() async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/public/tournament/active'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final tournament = data['tournament'];
        if (tournament != null && tournament is Map) {
          return TournamentModel.fromJson(tournament as Map<String, dynamic>);
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

  Future<bool> deleteSponsor(String matchId, String sponsorId) async {
    try {
      final res = await _http.delete(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/sponsors/$sponsorId',
        ),
        headers: await _authHeaders(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
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

  // ────────────────────────────────────────────────────────────
  // V2 — Tournament Hub & Analytics
  // ────────────────────────────────────────────────────────────

  Future<List<PointsTableEntry>> getStandings(String tournamentId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/tournaments/$tournamentId/standings',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['standings'] as List)
            .map((s) => PointsTableEntry.fromJson(s))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, List<TopPerformer>>> getTopPerformers(
    String tournamentId,
  ) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/tournaments/$tournamentId/top-performers',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          'most_runs': (data['most_runs'] as List)
              .map((p) => TopPerformer.fromJson(p))
              .toList(),
          'most_wickets': (data['most_wickets'] as List)
              .map((p) => TopPerformer.fromJson(p))
              .toList(),
        };
      }
      return {'most_runs': [], 'most_wickets': []};
    } catch (_) {
      return {'most_runs': [], 'most_wickets': []};
    }
  }

  Future<PlayerCareerModel?> getPlayerCareer(String playerId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/players/$playerId/career',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['career'] != null) {
          return PlayerCareerModel.fromJson(data['career']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<WagonWheelShot>> getWagonWheel(
    String matchId, {
    String? batsmanId,
  }) async {
    try {
      var url =
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/wagon-wheel';
      if (batsmanId != null) url += '?batsman_id=$batsmanId';
      final res = await _http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['shots'] as List)
            .map((s) => WagonWheelShot.fromJson(s))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<RunDistribution?> getRunDistribution(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/run-distribution',
        ),
      );
      if (res.statusCode == 200) {
        return RunDistribution.fromJson(jsonDecode(res.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ConcededRunsBreakdown?> getConcededRuns(
    String matchId, {
    String? bowlerId,
  }) async {
    try {
      var url =
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/conceded-runs';
      if (bowlerId != null) url += '?bowler_id=$bowlerId';
      final res = await _http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return ConcededRunsBreakdown.fromJson(jsonDecode(res.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ClubModel?> getClub(String identifier) async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/public/clubs/$identifier'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return ClubModel.fromJson(data['club']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<ClubModel>> getClubs() async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/public/clubs'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['clubs'] as List)
            .map((c) => ClubModel.fromJson(c))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<BestXiModel?> getBestXi(String id) async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/public/best-xi/$id'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return BestXiModel.fromJson(data['best_xi']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<BestXiModel>> getBestXiList({
    String? tournamentId,
    String? matchId,
  }) async {
    try {
      var url = '${ApiConfig.apiBaseUrl}/cricket/public/best-xi';
      final params = <String>[];
      if (tournamentId != null) params.add('tournament_id=$tournamentId');
      if (matchId != null) params.add('match_id=$matchId');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      final res = await _http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['best_xi'] as List)
            .map((x) => BestXiModel.fromJson(x))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  void dispose() {
    _scoreController.close();
    _http.close();
  }

  // ────────────────────────────────────────────────────────────
  // V3 — Instant Replay / VAR
  // ────────────────────────────────────────────────────────────

  Future<bool> markReplayEvent(
    String matchId,
    String eventType,
    int frameTimestamp, {
    String? annotation,
  }) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/replay/event',
        ),
        headers: await _authHeaders(),
        body: jsonEncode({
          'event_type': eventType,
          'frame_timestamp': frameTimestamp,
          if (annotation != null) 'annotation': annotation,
        }),
      );
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> annotateEvent(String eventId, String annotation) async {
    try {
      final res = await _http.put(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/replay/events/$eventId/annotate',
        ),
        headers: await _authHeaders(),
        body: jsonEncode({'annotation': annotation}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<ReplayEventModel>> getReplayEvents(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/replay/events',
        ),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['events'] as List)
            .map((e) => ReplayEventModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<ReplayClipModel?> createClip(
    String matchId,
    String eventId, {
    int bufferBeforeMs = 5000,
    int bufferAfterMs = 5000,
    double speed = 1.0,
  }) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/replay/clip',
        ),
        headers: await _authHeaders(),
        body: jsonEncode({
          'event_id': eventId,
          'buffer_before_ms': bufferBeforeMs,
          'buffer_after_ms': bufferAfterMs,
          'playback_speed': speed,
        }),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return ReplayClipModel.fromJson(data['clip']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> publishClip(String clipId) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/replay/clips/$clipId/publish',
        ),
        headers: await _authHeaders(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteClip(String clipId) async {
    try {
      final res = await _http.delete(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/replay/clips/$clipId',
        ),
        headers: await _authHeaders(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<ReplayClipModel>> getPublicReplays(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/replays',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['replays'] as List)
            .map((r) => ReplayClipModel.fromJson(r))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────
  // V4 — Team & Player Management
  // ────────────────────────────────────────────────────────────

  Future<List<TeamModel>> getAllTeams() async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/teams/all'),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['data'] as List)
            .map((t) => TeamModel.fromJson(t))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<TeamModel> createTeam({
    required String name,
    String? shortCode,
    String? homeCity,
    String? primaryColor,
    String? details,
  }) async {
    final res = await _http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/teams'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        if (shortCode != null) 'short_code': shortCode,
        if (homeCity != null) 'home_city': homeCity,
        if (primaryColor != null) 'primary_color': primaryColor,
        if (details != null) 'details': details,
      }),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return TeamModel.fromJson(data['team']);
    }
    final err = _parseBody(res);
    final msg =
        err?['message'] ??
        _extractValidationErrors(err) ??
        'Failed to create team (HTTP ${res.statusCode})';
    throw Exception(msg);
  }

  Future<List<PlayerModel>> getAllPlayers() async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/players/all'),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['data'] as List)
            .map((p) => PlayerModel.fromJson(p))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<PlayerModel> createPlayer({
    required String teamId,
    required String name,
    String? role,
    String? jerseyNumber,
    String? battingStyle,
    String? bowlingStyle,
    String? position,
    String? email,
    String? phone,
    String? idCardNumber,
    String? dateOfBirth,
  }) async {
    final res = await _http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/players'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'team_id': teamId,
        'name': name,
        if (role != null) 'role': role,
        if (position != null) 'position': position,
        if (jerseyNumber != null) 'jersey_number': jerseyNumber,
        if (battingStyle != null) 'batting_style': battingStyle,
        if (bowlingStyle != null) 'bowling_style': bowlingStyle,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (idCardNumber != null) 'id_card_number': idCardNumber,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      }),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return PlayerModel.fromJson(data['player']);
    }
    final err = _parseBody(res);
    final msg =
        err?['message'] ??
        _extractValidationErrors(err) ??
        'Failed to create player (HTTP ${res.statusCode})';
    throw Exception(msg);
  }

  Future<void> deleteTeam(String teamId) async {
    final res = await _http.delete(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/teams/$teamId'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      final err = _parseBody(res);
      throw Exception(err?['message'] ?? 'Failed to delete team');
    }
  }

  Future<TeamModel> updateTeamStatus(String teamId, String status) async {
    final res = await _http.patch(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/teams/$teamId/status'),
      headers: await _authHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return TeamModel.fromJson(data['team']);
    }
    final err = _parseBody(res);
    throw Exception(err?['message'] ?? 'Failed to update team status');
  }

  Future<TeamModel> updateTeam({
    required String teamId,
    String? name,
    String? homeCity,
    String? details,
    String? primaryColor,
    String? shortCode,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (homeCity != null) body['home_city'] = homeCity;
    if (details != null) body['details'] = details;
    if (primaryColor != null) body['primary_color'] = primaryColor;
    if (shortCode != null) body['short_code'] = shortCode;

    final res = await _http.put(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/teams/$teamId'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return TeamModel.fromJson(data['team'] ?? data);
    }
    final err = _parseBody(res);
    throw Exception(err?['message'] ?? 'Failed to update team');
  }

  Future<void> deletePlayer(String playerId) async {
    final res = await _http.delete(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/players/$playerId'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      final err = _parseBody(res);
      throw Exception(err?['message'] ?? 'Failed to delete player');
    }
  }

  Future<PlayerModel> updatePlayerStatus(String playerId, String status) async {
    final res = await _http.patch(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/players/$playerId/status',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return PlayerModel.fromJson(data['player']);
    }
    final err = _parseBody(res);
    throw Exception(err?['message'] ?? 'Failed to update player status');
  }

  Future<PlayerModel> updatePlayer({
    required String playerId,
    String? name,
    String? position,
    String? status,
    String? teamId,
    String? jerseyNumber,
    String? role,
    String? battingStyle,
    String? bowlingStyle,
    String? email,
    String? phone,
    String? idCardNumber,
    String? dateOfBirth,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (position != null) body['position'] = position;
    if (status != null) body['status'] = status;
    if (teamId != null) body['team_id'] = teamId;
    if (jerseyNumber != null) body['jersey_number'] = jerseyNumber;
    if (role != null) body['role'] = role;
    if (battingStyle != null) body['batting_style'] = battingStyle;
    if (bowlingStyle != null) body['bowling_style'] = bowlingStyle;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (idCardNumber != null) body['id_card_number'] = idCardNumber;
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;

    final res = await _http.put(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/players/$playerId'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return PlayerModel.fromJson(data['player'] ?? data);
    }
    final err = _parseBody(res);
    throw Exception(err?['message'] ?? 'Failed to update player');
  }

  /// Upload player photo — returns the photo URL.
  Future<String?> uploadPlayerPhoto(
    String playerId,
    Uint8List bytes,
    String fileName,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.apiBaseUrl}/cricket/manager/players/$playerId',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _authHeadersMultipart())
      ..files.add(
        http.MultipartFile.fromBytes('photo', bytes, filename: fileName),
      );
    // Use _method spoofing for PUT since some servers don't handle multipart PUT well
    request.fields['_method'] = 'PUT';

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['player']?['photo_url'] ?? data['photo_url'];
    }
    final err = _parseBody(res);
    throw Exception(err?['message'] ?? 'Failed to upload photo');
  }

  /// Upload team logo — returns the logo URL.
  Future<String?> uploadTeamLogo(
    String teamId,
    Uint8List bytes,
    String fileName,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.apiBaseUrl}/cricket/manager/teams/$teamId',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _authHeadersMultipart())
      ..files.add(
        http.MultipartFile.fromBytes('logo', bytes, filename: fileName),
      );
    request.fields['_method'] = 'PUT';

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['team']?['logo_url'] ?? data['logo_url'];
    }
    final err = _parseBody(res);
    throw Exception(err?['message'] ?? 'Failed to upload logo');
  }

  Future<List<TeamModel>> getTrashedTeams() async {
    final res = await _http.get(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/teams/trashed'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['data'] as List).map((t) => TeamModel.fromJson(t)).toList();
    }
    return [];
  }

  Future<void> restoreTeam(String teamId) async {
    final res = await _http.post(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/teams/$teamId/restore',
      ),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      final err = _parseBody(res);
      throw Exception(err?['message'] ?? 'Failed to restore team');
    }
  }

  Future<List<PlayerModel>> getTrashedPlayers() async {
    final res = await _http.get(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/players/trashed'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['data'] as List)
          .map((p) => PlayerModel.fromJson(p))
          .toList();
    }
    return [];
  }

  Future<void> restorePlayer(String playerId) async {
    final res = await _http.post(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/players/$playerId/restore',
      ),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      final err = _parseBody(res);
      throw Exception(err?['message'] ?? 'Failed to restore player');
    }
  }
}
