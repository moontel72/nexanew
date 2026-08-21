import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/config/api_config.dart';

import '../models/cricket_models.dart';
import '../models/replay_models.dart';
import '../realtime/cricket_realtime_client.dart';

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

  // Director-style program feed updates (manager camera switches).
  final _streamController = StreamController<CricketStreamUpdate>.broadcast();
  Stream<CricketStreamUpdate> get streamUpdates => _streamController.stream;

  // Match lifecycle updates (GO LIVE / breaks / completed).
  final _matchController = StreamController<MatchUpdate>.broadcast();
  Stream<MatchUpdate> get matchUpdates => _matchController.stream;

  // Realtime (Reverb) client — lazily created from the backend's
  // `realtime-config` endpoint so the app key is never hardcoded.
  CricketRealtimeClient? _realtime;
  StreamSubscription<CricketRealtimeEvent>? _realtimeSubscription;

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

  /// Build a user-friendly error message from a failed API response.
  String _apiError(http.Response res) {
    final body = _parseBody(res);
    final message = body?['message'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }
    final validation = _extractValidationErrors(body);
    if (validation != null) return validation;
    return 'Request failed (HTTP ${res.statusCode})';
  }

  /// Parse a paginated `data` list defensively — skips null/non-map rows
  /// so a single malformed record can never crash a page.
  List<Map<String, dynamic>> _pagedRows(http.Response res) {
    final decoded = jsonDecode(res.body);
    if (decoded is! Map) return const [];
    final rows = decoded['data'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
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

  /// Phase 4 — full scorecard for both innings (public endpoint).
  Future<ScorecardModel?> getScorecard(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/scorecard',
        ),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return ScorecardModel.fromJson(data);
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

  /// Sponsors assigned to a match. Uses the public endpoint so the
  /// public portal banner strip and the manager panel share one source.
  Future<List<SponsorModel>> getMatchSponsors(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/public/matches/$matchId/sponsors',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rows = data['sponsors'];
        if (rows is List) {
          return rows
              .whereType<Map>()
              .map((s) => SponsorModel.fromJson(Map<String, dynamic>.from(s)))
              .toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Unassign a sponsor from a match. Throws so the bloc can surface
  /// the server's error message to the manager.
  Future<void> deleteSponsor(String matchId, String sponsorId) async {
    final res = await _http.delete(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/sponsors/$sponsorId',
      ),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception(_apiError(res));
    }
  }

  // ────────────────────────────────────────────────────────────
  // Sponsor Management — manager-owned library & match assignment
  // ────────────────────────────────────────────────────────────

  /// List the manager's sponsor library (bound to the active tournament).
  Future<List<SponsorModel>> getSponsors({String? tournamentId}) async {
    try {
      final params = <String, String>{
        'per_page': '100',
        if (tournamentId != null) 'tournament_id': tournamentId,
      };
      final uri = Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/sponsors',
      ).replace(queryParameters: params);
      final res = await _http.get(uri, headers: await _authHeaders());
      if (res.statusCode == 200) {
        return _pagedRows(res).map((s) => SponsorModel.fromJson(s)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> createSponsor({
    required String name,
    required String tier,
    String? logoUrl,
    String? bannerImageUrl,
    String? websiteUrl,
    int? displayOrder,
  }) async {
    final res = await _http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/sponsors'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        'tier': tier,
        if (logoUrl != null && logoUrl.isNotEmpty) 'logo_url': logoUrl,
        if (bannerImageUrl != null && bannerImageUrl.isNotEmpty)
          'banner_image_url': bannerImageUrl,
        if (websiteUrl != null && websiteUrl.isNotEmpty)
          'website_url': websiteUrl,
        if (displayOrder != null) 'display_order': displayOrder,
      }),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(_apiError(res));
    }
  }

  Future<void> updateSponsor({
    required String id,
    required String name,
    required String tier,
    String? logoUrl,
    String? bannerImageUrl,
    String? websiteUrl,
    int? displayOrder,
  }) async {
    final res = await _http.put(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/sponsors/$id'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        'tier': tier,
        'logo_url': (logoUrl == null || logoUrl.isEmpty) ? null : logoUrl,
        'banner_image_url': (bannerImageUrl == null || bannerImageUrl.isEmpty)
            ? null
            : bannerImageUrl,
        'website_url': (websiteUrl == null || websiteUrl.isEmpty)
            ? null
            : websiteUrl,
        if (displayOrder != null) 'display_order': displayOrder,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception(_apiError(res));
    }
  }

  /// Delete a sponsor from the library (also removes match assignments).
  Future<void> destroySponsor(String id) async {
    final res = await _http.delete(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/sponsors/$id'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception(_apiError(res));
    }
  }

  /// Assign a sponsor to a match at a placement.
  Future<void> assignSponsorToMatch({
    required String matchId,
    required String sponsorId,
    required String placement,
    int? displayOrder,
  }) async {
    final res = await _http.post(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/sponsors',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({
        'sponsor_id': sponsorId,
        'placement': placement,
        'display_order': displayOrder ?? 0,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception(_apiError(res));
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
  // Live Score — realtime via Reverb (Pusher protocol)
  // ────────────────────────────────────────────────────────────

  /// Subscribe to live score pushes for a match. Falls back silently to
  /// REST polling (handled by the bloc) when Reverb is unavailable.
  Future<void> subscribeToScore(String matchId) async {
    try {
      _realtime ??= await _createRealtimeClient();
      _realtime?.subscribe('cricket.match.$matchId');
    } catch (_) {}
  }

  void unsubscribeFromScore(String matchId) {
    try {
      _realtime?.unsubscribe();
    } catch (_) {}
  }

  /// Subscribe to match lifecycle pushes for a whole tournament
  /// (`match.updated` events on cricket.tournament.{id}). The public
  /// tournament home uses this to refresh instantly when a match goes
  /// live or completes. Silent no-op when Reverb is unavailable.
  Future<void> subscribeToTournament(String tournamentId) async {
    try {
      _realtime ??= await _createRealtimeClient();
      _realtime?.subscribe('cricket.tournament.$tournamentId');
    } catch (_) {}
  }

  Future<CricketRealtimeClient?> _createRealtimeClient() async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/public/realtime-config'),
      );
      if (res.statusCode != 200) return null;
      final config = jsonDecode(res.body) as Map<String, dynamic>;
      if (config['driver'] != 'reverb' || config['key'] == null) return null;

      final client = CricketRealtimeClient(
        baseUrl: ApiConfig.baseUrl,
        appKey: config['key'] as String,
        wsPath: config['path'] as String? ?? '/app',
      );
      _realtimeSubscription?.cancel();
      _realtimeSubscription = client.events.listen((e) {
        try {
          switch (e.event) {
            case 'score.updated':
              // Reverb wraps the snapshot under `score` — unwrap before
              // parsing so live pushes render identically to REST fetches.
              final score = e.data['score'];
              if (score is Map) {
                _scoreController.add(
                  LiveScoreSnapshot.fromJson(Map<String, dynamic>.from(score)),
                );
              }
            case 'stream.updated':
              _streamController.add(CricketStreamUpdate.fromJson(e.data));
            case 'match.updated':
              _matchController.add(MatchUpdate.fromJson(e.data));
            default:
              break;
          }
        } catch (_) {}
      });
      return client;
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────
  // Unified State — Active Match Context + Studio SSO (Phase 1)
  // ────────────────────────────────────────────────────────────

  /// The manager's active match context (single source of truth stored
  /// server-side, shared with Todd Studio).
  Future<String?> getActiveMatch() async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/active-match'),
        headers: await _authHeaders(),
      );
      if (res.statusCode != 200) return null;
      final body = _parseBody(res);
      final id = body?['active_match_id']?.toString();
      return (id == null || id.isEmpty) ? null : id;
    } catch (_) {
      return null;
    }
  }

  /// Selects the active match. The backend persists the context and
  /// broadcasts `match.context.selected` on Reverb, which the Rust media
  /// engine consumes to switch Todd Studio in sub-100ms.
  ///
  /// Never throws: match selection in the manager UI must not be blocked
  /// by sync-side failures.
  Future<bool> selectActiveMatch(String matchId) async {
    try {
      final res = await _http.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/active-match'),
        headers: await _authHeaders(),
        body: jsonEncode({'match_id': matchId}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Mints a short-lived Todd Studio JWT from the current manager
  /// session (single sign-on — no credential re-entry). Returns null
  /// when the account lacks Studio access or the exchange fails.
  Future<String?> requestStudioTicket() async {
    try {
      await _loadToken();
      final res = await _http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/studio/exchange'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'manager_token': _bearerToken ?? ''}),
      );
      if (res.statusCode != 200) return null;
      final body = _parseBody(res);
      final token = body?['token']?.toString();
      return (token == null || token.isEmpty) ? null : token;
    } catch (_) {
      return null;
    }
  }

  /// Deep-link URL for Todd Studio: carries the SSO ticket and the
  /// active match so the director opens directly into the live context.
  Future<Uri> buildStudioOpenUrl() async {
    final base = Uri.tryParse(ApiConfig.studioUrl);
    if (base == null) {
      return Uri.parse(ApiConfig.studioUrl);
    }
    final params = <String, String>{};
    final ticket = await requestStudioTicket();
    if (ticket != null && ticket.isNotEmpty) params['sso'] = ticket;
    final active = await getActiveMatch();
    if (active != null && active.isNotEmpty) params['match'] = active;
    return params.isEmpty ? base : base.replace(queryParameters: params);
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

  /// Create a new camera stream row for a match. The backend generates the
  /// RTMP stream key when one is not supplied — the returned model carries
  /// the ingest URL + stream key for the mobile camera operator.
  /// Throws with the server message when creation fails.
  Future<StreamModel> createStream(
    String matchId, {
    required String cameraLabel,
    required int cameraNumber,
    String? rtmpIngestUrl,
    bool isPrimary = false,
  }) async {
    final res = await _http.post(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/streams',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({
        'camera_label': cameraLabel,
        'camera_number': cameraNumber,
        if (rtmpIngestUrl != null && rtmpIngestUrl.isNotEmpty)
          'rtmp_ingest_url': rtmpIngestUrl,
        'is_primary': isPrimary,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception(_apiError(res));
    }
    return StreamModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<bool> updateStream(
    String matchId,
    String streamId, {
    String? cameraLabel,
    String? rtmpIngestUrl,
    String? hlsPlaylistUrl,
    bool? isPrimary,
  }) async {
    try {
      final res = await _http.put(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/streams/$streamId',
        ),
        headers: await _authHeaders(),
        body: jsonEncode({
          if (cameraLabel != null) 'camera_label': cameraLabel,
          if (rtmpIngestUrl != null) 'rtmp_ingest_url': rtmpIngestUrl,
          if (hlsPlaylistUrl != null) 'hls_playlist_url': hlsPlaylistUrl,
          if (isPrimary != null) 'is_primary': isPrimary,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteStream(String matchId, String streamId) async {
    try {
      final res = await _http.delete(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/streams/$streamId',
        ),
        headers: await _authHeaders(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Submit a ball to the score. Returns the fresh score snapshot on
  /// success (backend returns `{message, score}`), null on failure.
  Future<LiveScoreSnapshot?> updateScore(
    String matchId,
    Map<String, dynamic> ball,
  ) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/score',
        ),
        headers: await _authHeaders(),
        body: jsonEncode(ball),
      );
      if (res.statusCode != 200) return null;
      return _snapshotFromBody(res.body);
    } catch (_) {
      return null;
    }
  }

  /// Undo the last ball. Returns the fresh score snapshot on success.
  Future<LiveScoreSnapshot?> undoLastBall(String matchId) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/score/undo',
        ),
        headers: await _authHeaders(),
      );
      if (res.statusCode != 200) return null;
      return _snapshotFromBody(res.body);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────
  // Phase 2 — Ball-by-ball correction interface
  // ────────────────────────────────────────────────────────────

  /// Recent deliveries of the current innings (newest first), each with
  /// its unique ball_id for the correction interface.
  Future<List<DeliveryModel>> listDeliveries(
    String matchId, {
    int limit = 50,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/deliveries',
      ).replace(queryParameters: {'limit': '$limit'});
      final res = await _http.get(uri, headers: await _authHeaders());
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rows = data['deliveries'];
      if (rows is! List) return const [];
      return rows
          .whereType<Map>()
          .map((d) => DeliveryModel.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Edit a past delivery by ball_id. The backend recomputes everything
  /// forward and returns the fresh snapshot (also pushed via WebSocket).
  Future<LiveScoreSnapshot?> editDelivery(
    String matchId,
    String ballId,
    Map<String, dynamic> changes,
  ) async {
    try {
      final res = await _http.put(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/deliveries/$ballId',
        ),
        headers: await _authHeaders(),
        body: jsonEncode(changes),
      );
      if (res.statusCode != 200) return null;
      return _snapshotFromBody(res.body);
    } catch (_) {
      return null;
    }
  }

  /// Delete a past delivery by ball_id and recompute everything forward.
  Future<LiveScoreSnapshot?> deleteDelivery(
    String matchId,
    String ballId,
  ) async {
    try {
      final res = await _http.delete(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/deliveries/$ballId',
        ),
        headers: await _authHeaders(),
      );
      if (res.statusCode != 200) return null;
      return _snapshotFromBody(res.body);
    } catch (_) {
      return null;
    }
  }

  /// Shared parse of the backend's `{message, score}` scoring responses.
  LiveScoreSnapshot? _snapshotFromBody(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final score = data['score'];
    return score is Map
        ? LiveScoreSnapshot.fromJson(Map<String, dynamic>.from(score))
        : null;
  }

  /// Fetch a single match via the manager endpoint (includes team ids).
  Future<MatchModel?> getMatch(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId'),
        headers: await _authHeaders(),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final match = data['match'] ?? data;
      return match is Map
          ? MatchModel.fromJson(Map<String, dynamic>.from(match))
          : null;
    } catch (_) {
      return null;
    }
  }

  /// Phase 5 — start a new innings (second innings / super over).
  /// Throws so the caller can surface the server's validation message.
  Future<void> startInnings(
    String matchId, {
    required String battingTeamId,
    required String bowlingTeamId,
    bool isSuperOver = false,
    int? oversLimit,
  }) async {
    final res = await _http.post(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/innings',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({
        'batting_team_id': battingTeamId,
        'bowling_team_id': bowlingTeamId,
        'is_super_over': isSuperOver,
        if (oversLimit != null) 'overs_limit': oversLimit,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception(_apiError(res));
    }
  }

  /// Record the toss result (moves the match to `toss_done`).
  Future<MatchModel?> recordToss(
    String matchId, {
    required String tossWinnerTeamId,
    required String tossDecision,
    required String battingTeamId,
    required String bowlingTeamId,
  }) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/toss',
        ),
        headers: await _authHeaders(),
        body: jsonEncode({
          'toss_winner_team_id': tossWinnerTeamId,
          'toss_decision': tossDecision,
          'current_batting_team_id': battingTeamId,
          'current_bowling_team_id': bowlingTeamId,
        }),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final match = data['match'] ?? data;
      return match is Map
          ? MatchModel.fromJson(Map<String, dynamic>.from(match))
          : null;
    } catch (_) {
      return null;
    }
  }

  /// Start the match (moves it to `in_progress` and opens innings 1).
  Future<MatchModel?> startMatch(String matchId) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/start',
        ),
        headers: await _authHeaders(),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final match = data['match'] ?? data;
      return match is Map
          ? MatchModel.fromJson(Map<String, dynamic>.from(match))
          : null;
    } catch (_) {
      return null;
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

  /// Reject a parsed voice score without applying it.
  Future<bool> rejectVoiceScore(String logId) async {
    try {
      final res = await _http.post(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/voice-score/$logId/reject',
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
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    _realtime?.dispose();
    _realtime = null;
    _scoreController.close();
    _streamController.close();
    _matchController.close();
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
        return _pagedRows(res).map((t) => TeamModel.fromJson(t)).toList();
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
        return _pagedRows(res).map((p) => PlayerModel.fromJson(p)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────
  // Squad & Lineup Management (Phase 0)
  // ────────────────────────────────────────────────────────────

  /// Fetch both teams' squads (playing XI + bench) for a match.
  Future<List<MatchSquadModel>> getMatchSquads(String matchId) async {
    try {
      final res = await _http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/squads',
        ),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rows = data['squads'];
        if (rows is List) {
          return rows
              .whereType<Map>()
              .map(
                (s) => MatchSquadModel.fromJson(Map<String, dynamic>.from(s)),
              )
              .toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Replace a team's squad with a new batting order for the match.
  /// [players] entries: `{ 'player_id': ..., 'batting_order': ... }`.
  /// Throws so the caller can surface the server's validation message.
  Future<void> saveMatchSquad(
    String matchId,
    String teamId,
    List<Map<String, dynamic>> players,
  ) async {
    final res = await _http.put(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/squads/$teamId',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({'players': players}),
    );
    if (res.statusCode != 200) {
      throw Exception(_apiError(res));
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

  // ────────────────────────────────────────────────────────────
  // Fixture Scheduling (manager endpoints)
  // ────────────────────────────────────────────────────────────

  /// List fixtures for a tournament (optionally filtered).
  Future<List<MatchModel>> getManagerMatches({
    String? tournamentId,
    String? status,
    String? stage,
    String? date,
  }) async {
    final params = <String, String>{
      'per_page': '100',
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (status != null) 'status': status,
      if (stage != null) 'stage': stage,
      if (date != null) 'date': date,
    };
    final uri = Uri.parse(
      '${ApiConfig.apiBaseUrl}/cricket/manager/matches',
    ).replace(queryParameters: params);
    final res = await _http.get(uri, headers: await _authHeaders());
    if (res.statusCode == 200) {
      return _pagedRows(res).map((m) => MatchModel.fromJson(m)).toList();
    }
    return [];
  }

  Future<MatchModel> createMatch({
    required String tournamentId,
    required String teamAId,
    required String teamBId,
    required DateTime scheduledAt,
    required String matchType,
    String? venue,
    String? groundId,
    int? oversPerSide,
    String? stage,
  }) async {
    final res = await _http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/matches'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'tournament_id': tournamentId,
        'team_a_id': teamAId,
        'team_b_id': teamBId,
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'match_type': matchType,
        if (venue != null && venue.isNotEmpty) 'venue': venue,
        if (groundId != null) 'ground_id': groundId,
        if (oversPerSide != null) 'overs_per_side': oversPerSide,
        if (stage != null) 'stage': stage,
      }),
    );
    if (res.statusCode == 201) {
      return MatchModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception(_apiError(res));
  }

  Future<MatchModel> updateMatch({
    required String matchId,
    String? teamAId,
    String? teamBId,
    String? venue,
    String? groundId,
    DateTime? scheduledAt,
    String? matchType,
    int? oversPerSide,
    String? stage,
  }) async {
    final res = await _http.put(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        if (teamAId != null) 'team_a_id': teamAId,
        if (teamBId != null) 'team_b_id': teamBId,
        if (venue != null) 'venue': venue,
        if (groundId != null) 'ground_id': groundId,
        if (scheduledAt != null)
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        if (matchType != null) 'match_type': matchType,
        if (oversPerSide != null) 'overs_per_side': oversPerSide,
        if (stage != null) 'stage': stage,
      }),
    );
    if (res.statusCode == 200) {
      return MatchModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception(_apiError(res));
  }

  Future<void> deleteMatch(String matchId) async {
    final res = await _http.delete(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(_apiError(res));
    }
  }

  Future<MatchModel> updateMatchStatus(String matchId, String status) async {
    final res = await _http.patch(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/matches/$matchId/status',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode == 200) {
      return MatchModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception(_apiError(res));
  }

  /// Auto-generate round-robin fixtures. Returns the number of fixtures
  /// created.
  Future<int> generateFixtures({
    required String tournamentId,
    required String format,
    required DateTime startDate,
    List<String> teamIds = const [],
    int matchIntervalDays = 1,
    String? kickoffTime,
    int? matchGapHours,
    String matchType = 't20',
    int? oversPerSide,
    String? venue,
    String? groundId,
    String stage = 'group_stage',
    bool force = false,
  }) async {
    final res = await _http.post(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/tournaments/$tournamentId/fixtures/generate',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({
        'format': format,
        'start_date': _dateOnly(startDate),
        if (teamIds.isNotEmpty) 'team_ids': teamIds,
        'match_interval_days': matchIntervalDays,
        if (kickoffTime != null) 'kickoff_time': kickoffTime,
        if (matchGapHours != null) 'match_gap_hours': matchGapHours,
        'default_match_type': matchType,
        if (oversPerSide != null) 'default_overs_per_side': oversPerSide,
        if (venue != null && venue.isNotEmpty) 'default_venue': venue,
        if (groundId != null) 'default_ground_id': groundId,
        'stage': stage,
        'force': force,
      }),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['count'] is int ? data['count'] as int : 0;
    }
    throw Exception(_apiError(res));
  }

  /// List registered grounds/venues.
  Future<List<GroundModel>> getGrounds() async {
    final uri = Uri.parse(
      '${ApiConfig.apiBaseUrl}/cricket/manager/grounds',
    ).replace(queryParameters: {'per_page': '100'});
    final res = await _http.get(uri, headers: await _authHeaders());
    if (res.statusCode == 200) {
      return _pagedRows(res).map((g) => GroundModel.fromJson(g)).toList();
    }
    return [];
  }

  Future<GroundModel> createGround({
    required String name,
    String? location,
  }) async {
    final res = await _http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/grounds'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        if (location != null && location.isNotEmpty) 'location': location,
      }),
    );
    if (res.statusCode == 201) {
      return GroundModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception(_apiError(res));
  }

  // ────────────────────────────────────────────────────────────
  // Tournament Setup (manager endpoints)
  // ────────────────────────────────────────────────────────────

  Future<List<TournamentModel>> getTournaments() async {
    final uri = Uri.parse(
      '${ApiConfig.apiBaseUrl}/cricket/manager/tournaments',
    ).replace(queryParameters: {'per_page': '100'});
    final res = await _http.get(uri, headers: await _authHeaders());
    if (res.statusCode == 200) {
      return _pagedRows(res).map((t) => TournamentModel.fromJson(t)).toList();
    }
    return [];
  }

  Future<TournamentModel> createTournament({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    String? description,
  }) async {
    final res = await _http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/tournaments'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        'start_date': _dateOnly(startDate),
        'end_date': _dateOnly(endDate),
        if (location != null && location.isNotEmpty) 'location': location,
        if (description != null && description.isNotEmpty)
          'description': description,
      }),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return TournamentModel.fromJson(
        data['tournament'] as Map<String, dynamic>,
      );
    }
    throw Exception(_apiError(res));
  }

  Future<TournamentModel> updateTournament({
    required String tournamentId,
    String? name,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? status,
    bool? isActive,
  }) async {
    final res = await _http.put(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/tournaments/$tournamentId',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (location != null) 'location': location,
        if (startDate != null) 'start_date': _dateOnly(startDate),
        if (endDate != null) 'end_date': _dateOnly(endDate),
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (isActive != null) 'is_active': isActive,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return TournamentModel.fromJson(
        data['tournament'] as Map<String, dynamic>,
      );
    }
    throw Exception(_apiError(res));
  }

  Future<TournamentModel> activateTournament(String tournamentId) async {
    final res = await _http.post(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/tournaments/$tournamentId/activate',
      ),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return TournamentModel.fromJson(
        data['tournament'] as Map<String, dynamic>,
      );
    }
    throw Exception(_apiError(res));
  }

  static String _dateOnly(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  Future<List<TeamModel>> getTrashedTeams() async {
    final res = await _http.get(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/teams/trashed'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) {
      return _pagedRows(res).map((t) => TeamModel.fromJson(t)).toList();
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

  /// Permanently delete a trashed team (cannot be undone).
  Future<void> permanentlyDeleteTeam(String teamId) async {
    final res = await _http.delete(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/teams/$teamId/force'),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      final err = _parseBody(res);
      throw Exception(err?['message'] ?? 'Failed to permanently delete team');
    }
  }

  Future<List<PlayerModel>> getTrashedPlayers() async {
    final res = await _http.get(
      Uri.parse('${ApiConfig.apiBaseUrl}/cricket/manager/players/trashed'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) {
      return _pagedRows(res).map((p) => PlayerModel.fromJson(p)).toList();
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

  /// Permanently delete a trashed player (cannot be undone).
  Future<void> permanentlyDeletePlayer(String playerId) async {
    final res = await _http.delete(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/cricket/manager/players/$playerId/force',
      ),
      headers: await _authHeaders(),
    );
    if (res.statusCode != 200) {
      final err = _parseBody(res);
      throw Exception(err?['message'] ?? 'Failed to permanently delete player');
    }
  }
}
