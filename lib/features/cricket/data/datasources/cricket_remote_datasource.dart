import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cricket_models.dart';

/// REST API client for cricket public + manager endpoints.
class CricketRemoteDataSource {
  final String _baseUrl;
  final http.Client _client;
  String? _bearerToken;

  CricketRemoteDataSource({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl.replaceAll(RegExp(r'/$'), ''),
      _client = client ?? http.Client();

  void setBearerToken(String token) => _bearerToken = token;
  void clearToken() => _bearerToken = null;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_bearerToken != null) 'Authorization': 'Bearer $_bearerToken',
  };

  // ─── Public Endpoints ──────────────────────────────────

  Future<TournamentModel?> getActiveTournament() async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/api/v1/cricket/public/tournament/active'),
    );
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    if (data['tournament'] == null) return null;
    return TournamentModel.fromJson(data['tournament']);
  }

  Future<List<MatchModel>> getLiveMatches({String? tournamentId}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/cricket/public/matches/live')
        .replace(
          queryParameters: {
            if (tournamentId != null) 'tournament_id': tournamentId,
          },
        );
    final res = await _client.get(uri);
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    return (data['matches'] as List<dynamic>)
        .map((m) => MatchModel.fromJson(m))
        .toList();
  }

  Future<List<MatchModel>> getAllMatches({String? tournamentId}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/cricket/public/matches').replace(
      queryParameters: {
        if (tournamentId != null) 'tournament_id': tournamentId,
      },
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    return (data['matches'] as List<dynamic>)
        .map((m) => MatchModel.fromJson(m))
        .toList();
  }

  Future<LiveScoreSnapshot?> getScore(String matchId) async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/api/v1/cricket/public/matches/$matchId/score'),
    );
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    return LiveScoreSnapshot.fromJson(data);
  }

  Future<List<StreamModel>> getStreams(String matchId) async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/api/v1/cricket/public/matches/$matchId/stream'),
    );
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    return (data['streams'] as List<dynamic>)
        .map((s) => StreamModel.fromJson(s))
        .toList();
  }

  Future<List<SponsorModel>> getMatchSponsors(String matchId) async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/api/v1/cricket/public/matches/$matchId/sponsors'),
    );
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    return (data['sponsors'] as List<dynamic>)
        .map((s) => SponsorModel.fromJson(s))
        .toList();
  }

  Future<List<TeamModel>> getTeams() async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/api/v1/cricket/public/teams'),
    );
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    return (data['teams'] as List<dynamic>)
        .map((t) => TeamModel.fromJson(t))
        .toList();
  }

  // ─── Manager Auth ──────────────────────────────────────

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/api/v1/cricket/manager/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body);
  }

  Future<CricketManagerModel?> getMe() async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/api/v1/cricket/manager/me'),
      headers: _headers,
    );
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    return CricketManagerModel.fromJson(data['manager']);
  }

  // ─── Stream Management (Manager Auth) ──────────────────

  Future<List<StreamModel>> getManagerStreams(String matchId) async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/api/v1/cricket/manager/matches/$matchId/streams'),
      headers: _headers,
    );
    if (res.statusCode != 200) return [];
    return (jsonDecode(res.body) as List<dynamic>)
        .map((s) => StreamModel.fromJson(s))
        .toList();
  }

  Future<bool> activateStream(String matchId, String streamId) async {
    final res = await _client.post(
      Uri.parse(
        '$_baseUrl/api/v1/cricket/manager/matches/$matchId/streams/$streamId/activate',
      ),
      headers: _headers,
    );
    return res.statusCode == 200;
  }

  Future<bool> deactivateStream(String matchId, String streamId) async {
    final res = await _client.post(
      Uri.parse(
        '$_baseUrl/api/v1/cricket/manager/matches/$matchId/streams/$streamId/deactivate',
      ),
      headers: _headers,
    );
    return res.statusCode == 200;
  }

  // ─── Voice Score (Manager Auth) ────────────────────────

  Future<Map<String, dynamic>?> processVoiceScore(
    String matchId,
    String transcript,
  ) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/api/v1/cricket/manager/voice-score/process'),
      headers: _headers,
      body: jsonEncode({'match_id': matchId, 'transcript': transcript}),
    );
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body);
  }

  Future<bool> applyVoiceScore(String logId) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/api/v1/cricket/manager/voice-score/$logId/apply'),
      headers: _headers,
    );
    return res.statusCode == 200;
  }

  // ─── Score Update (Manager Auth) ───────────────────────

  Future<bool> updateScore(String matchId, Map<String, dynamic> ball) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/api/v1/cricket/manager/matches/$matchId/score'),
      headers: _headers,
      body: jsonEncode(ball),
    );
    return res.statusCode == 200;
  }

  Future<bool> undoScores(String matchId) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/api/v1/cricket/manager/matches/$matchId/score/undo'),
      headers: _headers,
    );
    return res.statusCode == 200;
  }

  void dispose() => _client.close();
}
