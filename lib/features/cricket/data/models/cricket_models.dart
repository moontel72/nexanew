/// Unified cricket data models — mirror Laravel API responses.
///
/// All models use factory constructors from JSON for clean API deserialization.
/// Zero dependency on existing non-cricket models.
///
/// NOTE: short_code and tournament_id are nullable in DB since migration 000004.
/// TeamModel.fromJson handles null short_code with empty string fallback.

class TournamentModel {
  final String id;
  final String name;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  final String? logoUrl;
  final String status;
  final String? description;
  final bool isActive;
  final int teamsCount;
  final int matchesCount;

  const TournamentModel({
    required this.id,
    required this.name,
    this.location,
    required this.startDate,
    required this.endDate,
    this.logoUrl,
    required this.status,
    this.description,
    this.isActive = false,
    this.teamsCount = 0,
    this.matchesCount = 0,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    DateTime _safeDate(String? v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v) ?? DateTime.now();
    }

    return TournamentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString(),
      startDate: _safeDate(json['start_date']?.toString()),
      endDate: _safeDate(json['end_date']?.toString()),
      logoUrl: json['logo_url']?.toString(),
      status: json['status']?.toString() ?? 'unknown',
      description: json['description']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      teamsCount: json['teams_count'] is int
          ? json['teams_count'] as int
          : int.tryParse(json['teams_count']?.toString() ?? '') ?? 0,
      matchesCount: json['matches_count'] is int
          ? json['matches_count'] as int
          : int.tryParse(json['matches_count']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'logo_url': logoUrl,
    'status': status,
    'is_active': isActive,
  };
}

class TeamModel {
  final String id;
  final String name;
  final String shortCode;
  final String? logoUrl;
  final String? primaryColor;
  final String? teamCode;
  final String? homeCity;
  final int? playerCount;
  final String? details;
  final String status;
  final DateTime? deletedAt;

  const TeamModel({
    required this.id,
    required this.name,
    required this.shortCode,
    this.logoUrl,
    this.primaryColor,
    this.teamCode,
    this.homeCity,
    this.playerCount,
    this.details,
    this.status = 'active',
    this.deletedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) => TeamModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    shortCode: json['short_code']?.toString() ?? '',
    logoUrl: json['logo_url']?.toString(),
    primaryColor: json['primary_color']?.toString(),
    teamCode: json['team_code']?.toString(),
    homeCity: json['home_city']?.toString(),
    playerCount: json['player_count'] is int
        ? json['player_count'] as int
        : int.tryParse(json['player_count']?.toString() ?? ''),
    details: json['details']?.toString(),
    status: json['status']?.toString() ?? 'active',
    deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'] as String)
        : null,
  );
}

class MatchModel {
  final String id;
  final String status;
  final String? teamAName;
  final String? teamBName;
  final String? teamAShort;
  final String? teamBShort;
  final String? teamAId;
  final String? teamBId;
  final String? currentBattingTeamId;
  final String? currentBowlingTeamId;
  final String? venue;
  final String? matchType;
  final int oversPerSide;
  final DateTime? scheduledAt;
  final LiveScoreSnapshot? liveScore;
  final String? stage;
  final String? groundId;
  final String? groundName;
  final String? groundLocation;

  const MatchModel({
    required this.id,
    required this.status,
    this.teamAName,
    this.teamBName,
    this.teamAShort,
    this.teamBShort,
    this.teamAId,
    this.teamBId,
    this.currentBattingTeamId,
    this.currentBowlingTeamId,
    this.venue,
    this.matchType,
    this.oversPerSide = 20,
    this.scheduledAt,
    this.liveScore,
    this.stage,
    this.groundId,
    this.groundName,
    this.groundLocation,
  });

  /// Public endpoints return `team_a` as a name string; manager endpoints
  /// return it as a relation object — accept both shapes.
  static String? _teamNameOf(dynamic value) {
    if (value == null) return null;
    if (value is Map) return value['name']?.toString();
    return value.toString();
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
    id: json['id']?.toString() ?? '',
    status: json['status']?.toString() ?? 'unknown',
    teamAName: _teamNameOf(json['team_a']),
    teamBName: _teamNameOf(json['team_b']),
    teamAShort:
        json['team_a_short']?.toString() ??
        (json['team_a'] is Map
            ? (json['team_a'] as Map)['short_code']?.toString()
            : null),
    teamBShort:
        json['team_b_short']?.toString() ??
        (json['team_b'] is Map
            ? (json['team_b'] as Map)['short_code']?.toString()
            : null),
    teamAId: json['team_a_id']?.toString(),
    teamBId: json['team_b_id']?.toString(),
    currentBattingTeamId: json['current_batting_team_id']?.toString(),
    currentBowlingTeamId: json['current_bowling_team_id']?.toString(),
    venue: json['venue']?.toString(),
    matchType: json['match_type']?.toString(),
    oversPerSide: json['overs_per_side'] is int
        ? json['overs_per_side'] as int
        : int.tryParse(json['overs_per_side']?.toString() ?? '') ?? 20,
    scheduledAt: json['scheduled_at'] != null
        ? DateTime.parse(json['scheduled_at'] as String)
        : null,
    liveScore: json['live_score'] != null
        ? LiveScoreSnapshot.fromJson(json['live_score'] as Map<String, dynamic>)
        : null,
    stage: json['stage']?.toString() ?? 'group_stage',
    groundId: json['ground_id']?.toString(),
    groundName: json['ground'] is Map
        ? (json['ground'] as Map)['name']?.toString()
        : null,
    groundLocation: json['ground'] is Map
        ? (json['ground'] as Map)['location']?.toString()
        : null,
  );

  bool get isLive => status == 'in_progress' || status == 'innings_break';
}

class GroundModel {
  final String id;
  final String name;
  final String? location;
  final int? capacity;

  const GroundModel({
    required this.id,
    required this.name,
    this.location,
    this.capacity,
  });

  factory GroundModel.fromJson(Map<String, dynamic> json) => GroundModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    location: json['location']?.toString(),
    capacity: json['capacity'] is int
        ? json['capacity'] as int
        : int.tryParse(json['capacity']?.toString() ?? ''),
  );
}

class LiveScoreSnapshot {
  final String? matchId;
  final String? battingTeam;
  final String? bowlingTeam;
  final String? battingTeamId;
  final String? score;
  final double overs;
  final int? target;
  final double? crr;
  final double? rrr;
  final String? lastBallResult;
  final String? lastWicketInfo;
  final int partnershipRuns;
  final int partnershipBalls;
  final List<RecentBall> recentBalls;
  final Map<String, dynamic>? extras;
  final List<Map<String, dynamic>>? fallOfWickets;

  /// Phase 0 — batter/bowler attribution payloads.
  final List<PlayerStats> batters;
  final List<BowlerStats> bowlers;
  final CurrentPlayersModel? currentPlayers;
  final int? maxOversPerBowler;

  /// Phase 4 — realtime commentary feed (newest first).
  final List<CommentaryModel> commentary;

  const LiveScoreSnapshot({
    this.matchId,
    this.battingTeam,
    this.bowlingTeam,
    this.battingTeamId,
    this.score,
    this.overs = 0,
    this.target,
    this.crr,
    this.rrr,
    this.lastBallResult,
    this.lastWicketInfo,
    this.partnershipRuns = 0,
    this.partnershipBalls = 0,
    this.recentBalls = const [],
    this.extras,
    this.fallOfWickets,
    this.batters = const [],
    this.bowlers = const [],
    this.currentPlayers,
    this.maxOversPerBowler,
    this.commentary = const [],
  });

  factory LiveScoreSnapshot.fromJson(Map<String, dynamic> json) =>
      LiveScoreSnapshot(
        matchId: json['match_id'] as String?,
        battingTeam: json['batting_team_name'] as String?,
        bowlingTeam: json['bowling_team_name'] as String?,
        battingTeamId: json['batting_team'] as String?,
        score: json['score'] as String?,
        overs: (json['overs'] as num?)?.toDouble() ?? 0,
        target: json['target'] as int?,
        crr: (json['crr'] as num?)?.toDouble(),
        rrr: (json['rrr'] as num?)?.toDouble(),
        lastBallResult: json['last_ball_result'] as String?,
        lastWicketInfo: json['last_wicket_info'] as String?,
        partnershipRuns: json['partnership_runs'] as int? ?? 0,
        partnershipBalls: json['partnership_balls'] as int? ?? 0,
        recentBalls:
            (json['recent_balls'] as List<dynamic>?)
                ?.map((b) => RecentBall.fromJson(b as Map<String, dynamic>))
                .toList() ??
            [],
        extras: json['extras'] as Map<String, dynamic>?,
        fallOfWickets: (json['fall_of_wickets'] as List<dynamic>?)
            ?.map((f) => Map<String, dynamic>.from(f as Map))
            .toList(),
        batters:
            (json['batters'] as List<dynamic>?)
                ?.map((b) => PlayerStats.fromJson(b as Map<String, dynamic>))
                .toList() ??
            const [],
        bowlers:
            (json['bowlers'] as List<dynamic>?)
                ?.map((b) => BowlerStats.fromJson(b as Map<String, dynamic>))
                .toList() ??
            const [],
        currentPlayers: json['current'] is Map
            ? CurrentPlayersModel.fromJson(
                Map<String, dynamic>.from(json['current'] as Map),
              )
            : null,
        maxOversPerBowler: json['max_overs_per_bowler'] as int?,
        commentary:
            (json['commentary'] as List<dynamic>?)
                ?.map(
                  (c) => CommentaryModel.fromJson(
                    Map<String, dynamic>.from(c as Map),
                  ),
                )
                .toList() ??
            const [],
      );
}

/// The two batters at the crease and the active bowler (Phase 0 payload).
class CurrentPlayersModel {
  final PlayerStats? striker;
  final PlayerStats? nonStriker;
  final BowlerStats? bowler;

  const CurrentPlayersModel({this.striker, this.nonStriker, this.bowler});

  factory CurrentPlayersModel.fromJson(Map<String, dynamic> json) =>
      CurrentPlayersModel(
        striker: json['striker'] is Map
            ? PlayerStats.fromJson(
                Map<String, dynamic>.from(json['striker'] as Map),
              )
            : null,
        nonStriker: json['non_striker'] is Map
            ? PlayerStats.fromJson(
                Map<String, dynamic>.from(json['non_striker'] as Map),
              )
            : null,
        bowler: json['bowler'] is Map
            ? BowlerStats.fromJson(
                Map<String, dynamic>.from(json['bowler'] as Map),
              )
            : null,
      );
}

class RecentBall {
  final int runs;
  final bool isWicket;
  final String? wicketType;
  final String? extrasType;

  /// Phase 0/1 — delivery identity & attribution (correction UI groundwork).
  final String? ballId;
  final int? overNumber;
  final int? ballNumber;
  final String? batterId;
  final String? bowlerId;

  const RecentBall({
    this.runs = 0,
    this.isWicket = false,
    this.wicketType,
    this.extrasType,
    this.ballId,
    this.overNumber,
    this.ballNumber,
    this.batterId,
    this.bowlerId,
  });

  factory RecentBall.fromJson(Map<String, dynamic> json) => RecentBall(
    runs: json['runs'] as int? ?? 0,
    isWicket: json['is_wicket'] as bool? ?? false,
    wicketType: json['wicket_type'] as String?,
    extrasType: json['extras_type'] as String?,
    ballId: json['ball_id'] as String?,
    overNumber: json['over_number'] as int?,
    ballNumber: json['ball_number'] as int?,
    batterId: json['batter_id'] as String?,
    bowlerId: json['bowler_id'] as String?,
  );

  String get display {
    if (isWicket) return 'W';
    if (extrasType != null) {
      switch (extrasType) {
        case 'wide':
          return 'WD${runs > 0 ? '+$runs' : ''}';
        case 'no_ball':
          return 'NB${runs > 0 ? '+$runs' : ''}';
        case 'bye':
          return '${runs}B';
        case 'leg_bye':
          return '${runs}LB';
      }
    }
    return runs.toString();
  }
}

/// Phase 2 — one delivery in the correction history (unique ball_id).
class DeliveryModel {
  final String ballId;
  final int? overNumber;
  final int? ballNumber;
  final String? batterId;
  final String? nonStrikerId;
  final String? bowlerId;
  final int runs;
  final String? extrasType;
  final bool isWicket;
  final String? wicketType;
  final String? dismissedPlayerId;
  final String? fielderId;
  final String? nextBatterId;

  const DeliveryModel({
    required this.ballId,
    this.overNumber,
    this.ballNumber,
    this.batterId,
    this.nonStrikerId,
    this.bowlerId,
    this.runs = 0,
    this.extrasType,
    this.isWicket = false,
    this.wicketType,
    this.dismissedPlayerId,
    this.fielderId,
    this.nextBatterId,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
    ballId: json['ball_id'] as String? ?? '',
    overNumber: json['over_number'] as int?,
    ballNumber: json['ball_number'] as int?,
    batterId: json['batter_id'] as String?,
    nonStrikerId: json['non_striker_id'] as String?,
    bowlerId: json['bowler_id'] as String?,
    runs: json['runs'] as int? ?? 0,
    extrasType: json['extras_type'] as String?,
    isWicket: json['is_wicket'] as bool? ?? false,
    wicketType: json['wicket_type'] as String?,
    dismissedPlayerId: json['dismissed_player_id'] as String?,
    fielderId: json['fielder_id'] as String?,
    nextBatterId: json['next_batter_id'] as String?,
  );

  /// Compact over.ball label, e.g. `3.2`.
  String get label => '${overNumber ?? 0}.${ballNumber ?? 1}';

  /// Display context for the shared ball badge.
  RecentBall get recentBall => RecentBall(
    runs: runs,
    isWicket: isWicket,
    wicketType: wicketType,
    extrasType: extrasType,
    ballId: ballId,
    overNumber: overNumber,
    ballNumber: ballNumber,
    batterId: batterId,
    bowlerId: bowlerId,
  );
}

class StreamModel {
  final String id;
  final String cameraLabel;
  final int cameraNumber;
  final String? rtmpIngestUrl;
  final String? rtmpStreamKey;
  final String? hlsPlaylistUrl;
  final String streamStatus;
  final bool isPrimary;
  final int failoverPriority;

  const StreamModel({
    required this.id,
    required this.cameraLabel,
    required this.cameraNumber,
    this.rtmpIngestUrl,
    this.rtmpStreamKey,
    this.hlsPlaylistUrl,
    required this.streamStatus,
    this.isPrimary = false,
    this.failoverPriority = 0,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) => StreamModel(
    id: json['id']?.toString() ?? '',
    cameraLabel: json['camera_label']?.toString() ?? '',
    cameraNumber: (json['camera_number'] as num?)?.toInt() ?? 0,
    rtmpIngestUrl: json['rtmp_ingest_url']?.toString(),
    rtmpStreamKey: json['rtmp_stream_key']?.toString(),
    hlsPlaylistUrl: json['hls_playlist_url']?.toString(),
    streamStatus: json['stream_status']?.toString() ?? 'offline',
    isPrimary: json['is_primary'] as bool? ?? false,
    failoverPriority: (json['failover_priority'] as num?)?.toInt() ?? 0,
  );

  bool get isLive => streamStatus == 'live';
}

/// Realtime program-feed context pushed by the backend when the manager
/// switches cameras (`stream.updated` event). When [isLive] is false the
/// manager has ended the live feed.
class CricketStreamUpdate {
  final String? streamId;
  final int? cameraNumber;
  final String? cameraLabel;
  final String? hlsPlaylistUrl;
  final bool isLive;

  const CricketStreamUpdate({
    this.streamId,
    this.cameraNumber,
    this.cameraLabel,
    this.hlsPlaylistUrl,
    this.isLive = false,
  });

  factory CricketStreamUpdate.fromJson(Map<String, dynamic> json) {
    final active = json['active_stream'];
    if (active is Map) {
      final m = Map<String, dynamic>.from(active);
      return CricketStreamUpdate(
        streamId: m['id']?.toString(),
        cameraNumber: (m['camera_number'] as num?)?.toInt(),
        cameraLabel: m['camera_label']?.toString(),
        hlsPlaylistUrl: m['hls_playlist_url']?.toString(),
        isLive: true,
      );
    }
    // active_stream: null → nothing is live.
    return const CricketStreamUpdate();
  }
}

/// Match lifecycle change pushed by the backend (`match.updated` event)
/// when the manager toggles GO LIVE, breaks, or completion.
class MatchUpdate {
  final String? matchId;
  final String? tournamentId;
  final String? status;

  const MatchUpdate({this.matchId, this.tournamentId, this.status});

  factory MatchUpdate.fromJson(Map<String, dynamic> json) => MatchUpdate(
    matchId: json['match_id']?.toString(),
    tournamentId: json['tournament_id']?.toString(),
    status: json['status']?.toString(),
  );
}

class SponsorModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String? bannerImageUrl;
  final String? websiteUrl;
  final String tier;
  final String? placement;
  final int displayOrder;

  const SponsorModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.bannerImageUrl,
    this.websiteUrl,
    required this.tier,
    this.placement,
    this.displayOrder = 0,
  });

  factory SponsorModel.fromJson(Map<String, dynamic> json) => SponsorModel(
    id: json['id']?.toString() ?? json['sponsor_id']?.toString() ?? '',
    name: json['name']?.toString() ?? 'Sponsor',
    logoUrl: json['logo_url'] as String?,
    bannerImageUrl: json['banner_image_url'] as String?,
    websiteUrl: json['website_url'] as String?,
    tier: json['tier'] as String? ?? 'silver',
    placement: json['placement'] as String?,
    displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
  );
}

class CricketManagerModel {
  final String id;
  final String name;
  final String email;
  final Map<String, dynamic>? permissions;

  const CricketManagerModel({
    required this.id,
    required this.name,
    required this.email,
    this.permissions,
  });

  factory CricketManagerModel.fromJson(Map<String, dynamic> json) =>
      CricketManagerModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        permissions: json['permissions'] is Map<String, dynamic>
            ? json['permissions'] as Map<String, dynamic>
            : null,
      );

  bool canManageScores() => permissions?['can_manage_scores'] == true;
  bool canManageStreams() => permissions?['can_manage_streams'] == true;
  bool canManageSponsors() => permissions?['can_manage_sponsors'] == true;
  bool canAccessStudio() => permissions?['can_access_studio'] == true;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (permissions != null) 'permissions': permissions,
  };
}

class CommentaryModel {
  final double over;
  final int? ballNumber;
  final String text;
  final String event;

  const CommentaryModel({
    required this.over,
    this.ballNumber,
    required this.text,
    required this.event,
  });

  factory CommentaryModel.fromJson(Map<String, dynamic> json) =>
      CommentaryModel(
        over: (json['over'] as num?)?.toDouble() ?? 0,
        ballNumber: json['ball_number'] as int?,
        text: json['text'] as String? ?? '',
        event: json['event'] as String? ?? 'ball',
      );
}

class PlayerStats {
  final String? playerId;
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final double strikeRate;
  final bool dismissed;
  final String? dismissal;
  final bool retiredHurt;
  final int? battingOrder;

  const PlayerStats({
    this.playerId,
    required this.name,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.strikeRate = 0,
    this.dismissed = false,
    this.dismissal,
    this.retiredHurt = false,
    this.battingOrder,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    playerId: json['player_id'] as String?,
    name: json['name'] as String? ?? '',
    runs: json['runs'] as int? ?? 0,
    balls: json['balls'] as int? ?? 0,
    fours: json['fours'] as int? ?? 0,
    sixes: json['sixes'] as int? ?? 0,
    strikeRate: (json['strike_rate'] as num?)?.toDouble() ?? 0,
    dismissed: json['dismissed'] as bool? ?? false,
    dismissal: json['dismissal'] as String?,
    retiredHurt: json['retired_hurt'] as bool? ?? false,
    battingOrder: json['batting_order'] as int?,
  );
}

class BowlerStats {
  final String? playerId;
  final String name;
  final double overs;
  final int maidens;
  final int runs;
  final int wickets;
  final double economy;
  final int balls;

  const BowlerStats({
    this.playerId,
    required this.name,
    this.overs = 0,
    this.maidens = 0,
    this.runs = 0,
    this.wickets = 0,
    this.economy = 0,
    this.balls = 0,
  });

  factory BowlerStats.fromJson(Map<String, dynamic> json) => BowlerStats(
    playerId: json['player_id'] as String?,
    name: json['name'] as String? ?? '',
    overs: (json['overs'] as num?)?.toDouble() ?? 0,
    maidens: json['maidens'] as int? ?? 0,
    runs: json['runs'] as int? ?? 0,
    wickets: json['wickets'] as int? ?? 0,
    economy: (json['economy'] as num?)?.toDouble() ?? 0,
    balls: json['balls'] as int? ?? 0,
  );
}

// ═══════════════════════════════════════════════════════════
// Phase 0 — Squad / lineup models
// ═══════════════════════════════════════════════════════════

/// One player entry inside a match squad (batting order, status).
class SquadPlayerModel {
  final String playerId;
  final String name;
  final String? jerseyNumber;
  final String? role;
  final String? battingStyle;
  final String? bowlingStyle;
  final bool isCaptain;
  final bool isWicketKeeper;
  final int? battingOrder;
  final String? status;

  const SquadPlayerModel({
    required this.playerId,
    required this.name,
    this.jerseyNumber,
    this.role,
    this.battingStyle,
    this.bowlingStyle,
    this.isCaptain = false,
    this.isWicketKeeper = false,
    this.battingOrder,
    this.status,
  });

  factory SquadPlayerModel.fromJson(Map<String, dynamic> json) =>
      SquadPlayerModel(
        playerId: json['player_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        jerseyNumber: json['jersey_number'] as String?,
        role: json['role'] as String?,
        battingStyle: json['batting_style'] as String?,
        bowlingStyle: json['bowling_style'] as String?,
        isCaptain: json['is_captain'] as bool? ?? false,
        isWicketKeeper: json['is_wicket_keeper'] as bool? ?? false,
        battingOrder: json['batting_order'] as int?,
        status: json['status'] as String?,
      );
}

/// A team's squad (XI + bench) for one match.
class MatchSquadModel {
  final String teamId;
  final String? teamName;
  final String? teamShort;
  final List<SquadPlayerModel> players;

  const MatchSquadModel({
    required this.teamId,
    this.teamName,
    this.teamShort,
    this.players = const [],
  });

  factory MatchSquadModel.fromJson(Map<String, dynamic> json) =>
      MatchSquadModel(
        teamId: json['team_id'] as String? ?? '',
        teamName: json['team_name'] as String?,
        teamShort: json['team_short'] as String?,
        players:
            (json['players'] as List<dynamic>?)
                ?.map(
                  (p) => SquadPlayerModel.fromJson(
                    Map<String, dynamic>.from(p as Map),
                  ),
                )
                .toList() ??
            const [],
      );
}

// ═══════════════════════════════════════════════════════════════
// V2 Models — Tournament Hub, Analytics, Career, Best XI
// ═══════════════════════════════════════════════════════════════

class PointsTableEntry {
  final String teamId;
  final String teamName;
  final String? teamShortCode;
  final String? teamLogo;
  final int played;
  final int won;
  final int lost;
  final int tied;
  final int noResult;
  final int points;
  final double nrr;
  final int runsFor;
  final double oversFaced;
  final int runsAgainst;
  final double oversBowled;

  const PointsTableEntry({
    required this.teamId,
    required this.teamName,
    this.teamShortCode,
    this.teamLogo,
    this.played = 0,
    this.won = 0,
    this.lost = 0,
    this.tied = 0,
    this.noResult = 0,
    this.points = 0,
    this.nrr = 0,
    this.runsFor = 0,
    this.oversFaced = 0,
    this.runsAgainst = 0,
    this.oversBowled = 0,
  });

  factory PointsTableEntry.fromJson(Map<String, dynamic> json) =>
      PointsTableEntry(
        teamId: json['team_id'] as String? ?? '',
        teamName: json['team']?['name'] as String? ?? '',
        teamShortCode: json['team']?['short_code'] as String?,
        teamLogo: json['team']?['logo_url'] as String?,
        played: json['matches_played'] as int? ?? 0,
        won: json['won'] as int? ?? 0,
        lost: json['lost'] as int? ?? 0,
        tied: json['tied'] as int? ?? 0,
        noResult: json['no_result'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
        nrr: (json['net_run_rate'] as num?)?.toDouble() ?? 0,
        runsFor: json['runs_for'] as int? ?? 0,
        oversFaced: (json['overs_faced'] as num?)?.toDouble() ?? 0,
        runsAgainst: json['runs_against'] as int? ?? 0,
        oversBowled: (json['overs_bowled'] as num?)?.toDouble() ?? 0,
      );

  String get nrrDisplay =>
      nrr >= 0 ? '+${nrr.toStringAsFixed(3)}' : nrr.toStringAsFixed(3);
}

class TopPerformer {
  final String playerId;
  final String name;
  final String? teamShort;
  final int runs;
  final int wickets;

  const TopPerformer({
    required this.playerId,
    required this.name,
    this.teamShort,
    this.runs = 0,
    this.wickets = 0,
  });

  factory TopPerformer.fromJson(Map<String, dynamic> json) => TopPerformer(
    playerId: json['player_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    teamShort: json['team'] as String?,
    runs: json['runs'] as int? ?? 0,
    wickets: json['wickets'] as int? ?? 0,
  );
}

class PlayerCareerModel {
  final BattingCareer batting;
  final BowlingCareer bowling;
  final FieldingCareer fielding;
  final List<RecentFormEntry> recentForm;
  final ClubRef? club;

  const PlayerCareerModel({
    required this.batting,
    required this.bowling,
    required this.fielding,
    this.recentForm = const [],
    this.club,
  });

  factory PlayerCareerModel.fromJson(Map<String, dynamic> json) =>
      PlayerCareerModel(
        batting: BattingCareer.fromJson(
          json['batting'] as Map<String, dynamic>? ?? {},
        ),
        bowling: BowlingCareer.fromJson(
          json['bowling'] as Map<String, dynamic>? ?? {},
        ),
        fielding: FieldingCareer.fromJson(
          json['fielding'] as Map<String, dynamic>? ?? {},
        ),
        recentForm:
            (json['recent_form'] as List<dynamic>?)
                ?.map(
                  (e) => RecentFormEntry.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        club: json['club'] != null
            ? ClubRef.fromJson(json['club'] as Map<String, dynamic>)
            : null,
      );

  String get highestScoreDisplay {
    final b = batting;
    return '${b.highestScore}${b.highestScoreNotOut ? '*' : ''}';
  }
}

class BattingCareer {
  final int totalMatches;
  final int totalInnings;
  final int totalRuns;
  final int notOuts;
  final int highestScore;
  final bool highestScoreNotOut;
  final double? average;
  final int ballsFaced;
  final double strikeRate;
  final int centuries;
  final int halfCenturies;
  final int fours;
  final int sixes;

  const BattingCareer({
    this.totalMatches = 0,
    this.totalInnings = 0,
    this.totalRuns = 0,
    this.notOuts = 0,
    this.highestScore = 0,
    this.highestScoreNotOut = false,
    this.average,
    this.ballsFaced = 0,
    this.strikeRate = 0,
    this.centuries = 0,
    this.halfCenturies = 0,
    this.fours = 0,
    this.sixes = 0,
  });

  factory BattingCareer.fromJson(Map<String, dynamic> json) => BattingCareer(
    totalMatches: json['total_matches'] as int? ?? 0,
    totalInnings: json['total_innings'] as int? ?? 0,
    totalRuns: json['total_runs'] as int? ?? 0,
    notOuts: json['not_outs'] as int? ?? 0,
    highestScore: json['highest_score'] as int? ?? 0,
    highestScoreNotOut: json['highest_score_not_out'] as bool? ?? false,
    average: (json['average'] as num?)?.toDouble(),
    ballsFaced: json['balls_faced'] as int? ?? 0,
    strikeRate: (json['strike_rate'] as num?)?.toDouble() ?? 0,
    centuries: json['centuries'] as int? ?? 0,
    halfCenturies: json['half_centuries'] as int? ?? 0,
    fours: json['fours'] as int? ?? 0,
    sixes: json['sixes'] as int? ?? 0,
  );
}

class BowlingCareer {
  final int totalWickets;
  final double? average;
  final String? bestFigures;
  final double economyRate;
  final double oversBowled;
  final int maidens;
  final int fiveWicketHauls;

  const BowlingCareer({
    this.totalWickets = 0,
    this.average,
    this.bestFigures,
    this.economyRate = 0,
    this.oversBowled = 0,
    this.maidens = 0,
    this.fiveWicketHauls = 0,
  });

  factory BowlingCareer.fromJson(Map<String, dynamic> json) => BowlingCareer(
    totalWickets: json['total_wickets'] as int? ?? 0,
    average: (json['average'] as num?)?.toDouble(),
    bestFigures: json['best_figures'] as String?,
    economyRate: (json['economy_rate'] as num?)?.toDouble() ?? 0,
    oversBowled: (json['overs_bowled'] as num?)?.toDouble() ?? 0,
    maidens: json['maidens'] as int? ?? 0,
    fiveWicketHauls: json['five_wicket_hauls'] as int? ?? 0,
  );
}

class FieldingCareer {
  final int catches;
  final int runOuts;
  final int stumpings;

  const FieldingCareer({
    this.catches = 0,
    this.runOuts = 0,
    this.stumpings = 0,
  });

  factory FieldingCareer.fromJson(Map<String, dynamic> json) => FieldingCareer(
    catches: json['catches'] as int? ?? 0,
    runOuts: json['run_outs'] as int? ?? 0,
    stumpings: json['stumpings'] as int? ?? 0,
  );
}

class RecentFormEntry {
  final int runs;
  final int balls;
  final bool notOut;
  final String? matchId;
  final String? date;

  const RecentFormEntry({
    this.runs = 0,
    this.balls = 0,
    this.notOut = false,
    this.matchId,
    this.date,
  });

  factory RecentFormEntry.fromJson(Map<String, dynamic> json) =>
      RecentFormEntry(
        runs: json['runs'] as int? ?? 0,
        balls: json['balls'] as int? ?? 0,
        notOut: json['not_out'] as bool? ?? false,
        matchId: json['match_id'] as String?,
        date: json['date'] as String?,
      );

  String get display => notOut ? '${runs}*' : '$runs';
}

class ClubRef {
  final String id;
  final String name;
  final String? logoUrl;

  const ClubRef({required this.id, required this.name, this.logoUrl});

  factory ClubRef.fromJson(Map<String, dynamic> json) => ClubRef(
    id: json['id'] as String,
    name: json['name'] as String,
    logoUrl: json['logo_url'] as String?,
  );
}

class ClubModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String? bannerUrl;
  final String? location;
  final int? establishedYear;
  final String? description;
  final int followerCount;
  final int clubViews;
  final int totalMatchesHosted;
  final int totalTournamentsHosted;

  const ClubModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.bannerUrl,
    this.location,
    this.establishedYear,
    this.description,
    this.followerCount = 0,
    this.clubViews = 0,
    this.totalMatchesHosted = 0,
    this.totalTournamentsHosted = 0,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) => ClubModel(
    id: json['id'] as String,
    name: json['name'] as String,
    logoUrl: json['logo_url'] as String?,
    bannerUrl: json['banner_url'] as String?,
    location: json['location'] as String?,
    establishedYear: json['established_year'] as int?,
    description: json['description'] as String?,
    followerCount: json['follower_count'] as int? ?? 0,
    clubViews: json['club_views'] as int? ?? 0,
    totalMatchesHosted: json['total_matches_hosted'] as int? ?? 0,
    totalTournamentsHosted: json['total_tournaments_hosted'] as int? ?? 0,
  );
}

class WagonWheelShot {
  final int runs;
  final double? direction;
  final double? x;
  final double? y;
  final bool isBoundary;
  final bool isWicket;
  final String? extrasType;

  const WagonWheelShot({
    this.runs = 0,
    this.direction,
    this.x,
    this.y,
    this.isBoundary = false,
    this.isWicket = false,
    this.extrasType,
  });

  factory WagonWheelShot.fromJson(Map<String, dynamic> json) => WagonWheelShot(
    runs: json['runs'] as int? ?? 0,
    direction: (json['direction'] as num?)?.toDouble(),
    x: (json['x'] as num?)?.toDouble(),
    y: (json['y'] as num?)?.toDouble(),
    isBoundary: json['is_boundary'] as bool? ?? false,
    isWicket: json['is_wicket'] as bool? ?? false,
    extrasType: json['extras_type'] as String?,
  );
}

class RunDistribution {
  final int dotBalls;
  final int singles;
  final int twos;
  final int threes;
  final int fours;
  final int sixes;
  final int extrasWides;
  final int extrasNoBalls;
  final int extrasByes;
  final int extrasLegByes;
  final int totalRuns;
  final int totalBalls;

  const RunDistribution({
    this.dotBalls = 0,
    this.singles = 0,
    this.twos = 0,
    this.threes = 0,
    this.fours = 0,
    this.sixes = 0,
    this.extrasWides = 0,
    this.extrasNoBalls = 0,
    this.extrasByes = 0,
    this.extrasLegByes = 0,
    this.totalRuns = 0,
    this.totalBalls = 0,
  });

  factory RunDistribution.fromJson(Map<String, dynamic> json) {
    final d = json['distribution'] as Map<String, dynamic>? ?? {};
    return RunDistribution(
      dotBalls: d['dot_balls'] as int? ?? 0,
      singles: d['singles'] as int? ?? 0,
      twos: d['twos'] as int? ?? 0,
      threes: d['threes'] as int? ?? 0,
      fours: d['fours'] as int? ?? 0,
      sixes: d['sixes'] as int? ?? 0,
      extrasWides: d['extras_wides'] as int? ?? 0,
      extrasNoBalls: d['extras_no_balls'] as int? ?? 0,
      extrasByes: d['extras_byes'] as int? ?? 0,
      extrasLegByes: d['extras_leg_byes'] as int? ?? 0,
      totalRuns: d['total_runs'] as int? ?? 0,
      totalBalls: d['total_balls'] as int? ?? 0,
    );
  }
}

class ConcededRunsBreakdown {
  final double singlesPct;
  final double twosPct;
  final double threesPct;
  final double foursPct;
  final double sixesPct;
  final double extrasPct;
  final int totalConceded;

  const ConcededRunsBreakdown({
    this.singlesPct = 0,
    this.twosPct = 0,
    this.threesPct = 0,
    this.foursPct = 0,
    this.sixesPct = 0,
    this.extrasPct = 0,
    this.totalConceded = 0,
  });

  factory ConcededRunsBreakdown.fromJson(Map<String, dynamic> json) {
    final b = json['breakdown'] as Map<String, dynamic>? ?? {};
    double pct(String key) =>
        ((b[key] as Map<String, dynamic>?)?['percentage'] as num?)
            ?.toDouble() ??
        0;
    return ConcededRunsBreakdown(
      singlesPct: pct('singles'),
      twosPct: pct('twos'),
      threesPct: pct('threes'),
      foursPct: pct('fours'),
      sixesPct: pct('sixes'),
      extrasPct: pct('extras'),
      totalConceded: json['total_conceded'] as int? ?? 0,
    );
  }
}

class BestXiModel {
  final String id;
  final String teamLabel;
  final String? tournamentName;
  final List<BestXiPlayer> selections;

  const BestXiModel({
    required this.id,
    required this.teamLabel,
    this.tournamentName,
    this.selections = const [],
  });

  factory BestXiModel.fromJson(Map<String, dynamic> json) => BestXiModel(
    id: json['id'] as String,
    teamLabel: json['team_label'] as String? ?? '',
    tournamentName: json['tournament_name'] as String?,
    selections:
        (json['selections'] as List<dynamic>?)
            ?.map((s) => BestXiPlayer.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class BestXiPlayer {
  final String playerId;
  final String playerName;
  final String? playerPhoto;
  final String? playerRole;
  final String? teamName;
  final String? teamShort;
  final String positionName;
  final double x;
  final double y;
  final double? rating;

  const BestXiPlayer({
    required this.playerId,
    required this.playerName,
    this.playerPhoto,
    this.playerRole,
    this.teamName,
    this.teamShort,
    required this.positionName,
    this.x = 0.5,
    this.y = 0.5,
    this.rating,
  });

  factory BestXiPlayer.fromJson(Map<String, dynamic> json) => BestXiPlayer(
    playerId: json['player_id'] as String? ?? '',
    playerName: json['player_name'] as String? ?? '',
    playerPhoto: json['player_photo'] as String?,
    playerRole: json['player_role'] as String?,
    teamName: json['team_name'] as String?,
    teamShort: json['team_short'] as String?,
    positionName: json['position_name'] as String? ?? '',
    x: (json['x'] as num?)?.toDouble() ?? 0.5,
    y: (json['y'] as num?)?.toDouble() ?? 0.5,
    rating: (json['rating'] as num?)?.toDouble(),
  );
}

class PlayerModel {
  final String id;
  final String name;
  final String? playerCode;
  final String? teamId;
  final String? teamName;
  final String? teamShortCode;
  final String? jerseyNumber;
  final String role;
  final String position;
  final String? battingStyle;
  final String? bowlingStyle;
  final String? photoUrl;
  final bool isCaptain;
  final bool isWicketKeeper;
  final String status;
  final DateTime? deletedAt;
  final String? email;
  final String? phone;
  final String? idCardNumber;
  final String? dateOfBirth;

  const PlayerModel({
    required this.id,
    required this.name,
    this.playerCode,
    this.teamId,
    this.teamName,
    this.teamShortCode,
    this.jerseyNumber,
    required this.role,
    this.position = 'player',
    this.battingStyle,
    this.bowlingStyle,
    this.photoUrl,
    this.isCaptain = false,
    this.isWicketKeeper = false,
    this.status = 'active',
    this.deletedAt,
    this.email,
    this.phone,
    this.idCardNumber,
    this.dateOfBirth,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    playerCode: json['player_code']?.toString(),
    teamId: json['team_id']?.toString(),
    teamName: (json['team'] as Map<String, dynamic>?)?['name']?.toString(),
    teamShortCode: (json['team'] as Map<String, dynamic>?)?['short_code']
        ?.toString(),
    jerseyNumber: json['jersey_number']?.toString(),
    role: json['role']?.toString() ?? 'batsman',
    position: json['position']?.toString() ?? 'player',
    battingStyle: json['batting_style']?.toString(),
    bowlingStyle: json['bowling_style']?.toString(),
    photoUrl: json['photo_url']?.toString(),
    isCaptain: json['is_captain'] == true || json['is_captain'] == 1,
    isWicketKeeper:
        json['is_wicket_keeper'] == true || json['is_wicket_keeper'] == 1,
    status: json['status']?.toString() ?? 'active',
    deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'] as String)
        : null,
    email: json['email']?.toString(),
    phone: json['phone']?.toString(),
    idCardNumber: json['id_card_number']?.toString(),
    dateOfBirth: json['date_of_birth']?.toString(),
  );

  PlayerModel copyWith({
    String? id,
    String? name,
    String? playerCode,
    String? teamId,
    String? teamName,
    String? teamShortCode,
    String? jerseyNumber,
    String? role,
    String? position,
    String? battingStyle,
    String? bowlingStyle,
    String? photoUrl,
    bool? isCaptain,
    bool? isWicketKeeper,
    String? status,
    DateTime? deletedAt,
    String? email,
    String? phone,
    String? idCardNumber,
    String? dateOfBirth,
  }) => PlayerModel(
    id: id ?? this.id,
    name: name ?? this.name,
    playerCode: playerCode ?? this.playerCode,
    teamId: teamId ?? this.teamId,
    teamName: teamName ?? this.teamName,
    teamShortCode: teamShortCode ?? this.teamShortCode,
    jerseyNumber: jerseyNumber ?? this.jerseyNumber,
    role: role ?? this.role,
    position: position ?? this.position,
    battingStyle: battingStyle ?? this.battingStyle,
    bowlingStyle: bowlingStyle ?? this.bowlingStyle,
    photoUrl: photoUrl ?? this.photoUrl,
    isCaptain: isCaptain ?? this.isCaptain,
    isWicketKeeper: isWicketKeeper ?? this.isWicketKeeper,
    status: status ?? this.status,
    deletedAt: deletedAt ?? this.deletedAt,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    idCardNumber: idCardNumber ?? this.idCardNumber,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
  );

  String get roleDisplay => role.replaceAll('_', ' ').toUpperCase();
}

// ═══════════════════════════════════════════════════════════════
// Phase 4 — Full scorecard models
// ═══════════════════════════════════════════════════════════════

/// One point on the over-by-over run progression (worm chart).
class ProgressionPoint {
  final int over;
  final int runs;
  final int wickets;

  const ProgressionPoint({
    required this.over,
    required this.runs,
    required this.wickets,
  });

  factory ProgressionPoint.fromJson(Map<String, dynamic> json) =>
      ProgressionPoint(
        over: json['over'] as int? ?? 0,
        runs: json['runs'] as int? ?? 0,
        wickets: json['wickets'] as int? ?? 0,
      );
}

/// One innings of the full scorecard — reuses `PlayerStats` and
/// `BowlerStats` for the per-player rows (single model source).
class ScorecardInnings {
  final int inningsNumber;
  final String battingTeam;
  final String bowlingTeam;
  final int totalRuns;
  final int totalWickets;
  final double totalOvers;
  final String? status;
  final bool isSuperOver;
  final int? oversLimit;
  final Map<String, dynamic>? extras;
  final List<PlayerStats> batting;
  final List<BowlerStats> bowling;
  final List<Map<String, dynamic>> fallOfWickets;
  final List<ProgressionPoint> runProgression;

  const ScorecardInnings({
    required this.inningsNumber,
    required this.battingTeam,
    required this.bowlingTeam,
    this.totalRuns = 0,
    this.totalWickets = 0,
    this.totalOvers = 0,
    this.status,
    this.isSuperOver = false,
    this.oversLimit,
    this.extras,
    this.batting = const [],
    this.bowling = const [],
    this.fallOfWickets = const [],
    this.runProgression = const [],
  });

  factory ScorecardInnings.fromJson(Map<String, dynamic> json) =>
      ScorecardInnings(
        inningsNumber: json['innings_number'] as int? ?? 1,
        battingTeam: json['batting_team'] as String? ?? '',
        bowlingTeam: json['bowling_team'] as String? ?? '',
        totalRuns: json['total_runs'] as int? ?? 0,
        totalWickets: json['total_wickets'] as int? ?? 0,
        totalOvers: (json['total_overs'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String?,
        isSuperOver: json['is_super_over'] as bool? ?? false,
        oversLimit: json['overs_limit'] as int?,
        extras: json['extras'] is Map
            ? Map<String, dynamic>.from(json['extras'] as Map)
            : null,
        batting:
            (json['batting_scorecard'] as List<dynamic>?)
                ?.map(
                  (b) =>
                      PlayerStats.fromJson(Map<String, dynamic>.from(b as Map)),
                )
                .toList() ??
            const [],
        bowling:
            (json['bowling_scorecard'] as List<dynamic>?)
                ?.map(
                  (b) =>
                      BowlerStats.fromJson(Map<String, dynamic>.from(b as Map)),
                )
                .toList() ??
            const [],
        fallOfWickets:
            (json['fall_of_wickets'] as List<dynamic>?)
                ?.map((f) => Map<String, dynamic>.from(f as Map))
                .toList() ??
            const [],
        runProgression:
            (json['run_progression'] as List<dynamic>?)
                ?.map(
                  (p) => ProgressionPoint.fromJson(
                    Map<String, dynamic>.from(p as Map),
                  ),
                )
                .toList() ??
            const [],
      );
}

/// Full match scorecard payload (`/cricket/public/matches/{id}/scorecard`).
class ScorecardModel {
  final String teamA;
  final String teamB;
  final String teamAShort;
  final String teamBShort;
  final String? venue;
  final String? matchType;
  final int? oversPerSide;
  final String status;
  final List<ScorecardInnings> innings;
  final LiveScoreSnapshot? liveScore;

  const ScorecardModel({
    this.teamA = '',
    this.teamB = '',
    this.teamAShort = '',
    this.teamBShort = '',
    this.venue,
    this.matchType,
    this.oversPerSide,
    this.status = '',
    this.innings = const [],
    this.liveScore,
  });

  factory ScorecardModel.fromJson(Map<String, dynamic> json) {
    final match = json['match'] is Map
        ? Map<String, dynamic>.from(json['match'] as Map)
        : const <String, dynamic>{};

    return ScorecardModel(
      teamA: match['team_a'] as String? ?? '',
      teamB: match['team_b'] as String? ?? '',
      teamAShort: match['team_a_short'] as String? ?? '',
      teamBShort: match['team_b_short'] as String? ?? '',
      venue: match['venue'] as String?,
      matchType: match['match_type'] as String?,
      oversPerSide: match['overs_per_side'] as int?,
      status: match['status'] as String? ?? '',
      innings:
          (json['innings'] as List<dynamic>?)
              ?.map(
                (i) => ScorecardInnings.fromJson(
                  Map<String, dynamic>.from(i as Map),
                ),
              )
              .toList() ??
          const [],
      liveScore: json['live_score'] is Map
          ? LiveScoreSnapshot.fromJson(
              Map<String, dynamic>.from(json['live_score'] as Map),
            )
          : null,
    );
  }
}
