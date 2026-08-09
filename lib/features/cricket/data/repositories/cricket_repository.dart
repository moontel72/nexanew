import '../datasources/cricket_remote_datasource.dart';
import '../datasources/cricket_websocket_repository.dart';
import '../models/cricket_models.dart';

/// Facade repository — coordinates between REST and WebSocket data sources.
class CricketRepository {
  final CricketRemoteDataSource _remote;
  final CricketWebSocketRepository _webSocket;

  CricketRepository({
    required CricketRemoteDataSource remote,
    required CricketWebSocketRepository webSocket,
  }) : _remote = remote,
       _webSocket = webSocket;

  // ─── Auth ──────────────────────────────────────────────

  void setBearerToken(String token) => _remote.setBearerToken(token);
  void clearToken() => _remote.clearToken();

  Future<Map<String, dynamic>?> login(String email, String password) =>
      _remote.login(email, password);

  Future<CricketManagerModel?> getManager() => _remote.getMe();

  // ─── Tournament & Matches ──────────────────────────────

  Future<TournamentModel?> getActiveTournament() =>
      _remote.getActiveTournament();

  Future<List<MatchModel>> getLiveMatches({String? tournamentId}) =>
      _remote.getLiveMatches(tournamentId: tournamentId);

  Future<List<MatchModel>> getAllMatches({String? tournamentId}) =>
      _remote.getAllMatches(tournamentId: tournamentId);

  Future<List<TeamModel>> getTeams() => _remote.getTeams();

  // ─── Live Score (WebSocket + REST fallback) ────────────

  Stream<LiveScoreSnapshot> subscribeToScore(String matchId) {
    _webSocket.subscribeToMatch(matchId);
    return _webSocket.scoreStream;
  }

  bool get isWebSocketConnected => _webSocket.isConnected;

  Future<LiveScoreSnapshot?> fetchScore(String matchId) =>
      _remote.getScore(matchId);

  Future<bool> updateScore(String matchId, Map<String, dynamic> ball) =>
      _remote.updateScore(matchId, ball);

  Future<bool> undoLastBall(String matchId) => _remote.undoScore(matchId);

  // ─── Streams ───────────────────────────────────────────

  Future<List<StreamModel>> getPublicStreams(String matchId) =>
      _remote.getStreams(matchId);

  Future<List<StreamModel>> getManagerStreams(String matchId) =>
      _remote.getManagerStreams(matchId);

  Future<bool> activateStream(String matchId, String streamId) =>
      _remote.activateStream(matchId, streamId);

  Future<bool> deactivateStream(String matchId, String streamId) =>
      _remote.deactivateStream(matchId, streamId);

  // ─── Sponsors ──────────────────────────────────────────

  Future<List<SponsorModel>> getMatchSponsors(String matchId) =>
      _remote.getMatchSponsors(matchId);

  // ─── Voice Score ───────────────────────────────────────

  Future<Map<String, dynamic>?> processVoiceScore(
    String matchId,
    String transcript,
  ) => _remote.processVoiceScore(matchId, transcript);

  Future<bool> applyVoiceScore(String logId) => _remote.applyVoiceScore(logId);

  void dispose() {
    _remote.dispose();
    _webSocket.dispose();
  }
}
