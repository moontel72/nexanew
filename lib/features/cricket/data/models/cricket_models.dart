/// Unified cricket data models — mirror Laravel API responses.
///
/// All models use factory constructors from JSON for clean API deserialization.
/// Zero dependency on existing non-cricket models.

class TournamentModel {
  final String id;
  final String name;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  final String? logoUrl;
  final String status;

  const TournamentModel({
    required this.id,
    required this.name,
    this.location,
    required this.startDate,
    required this.endDate,
    this.logoUrl,
    required this.status,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) => TournamentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        location: json['location'] as String?,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        logoUrl: json['logo_url'] as String?,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'logo_url': logoUrl,
        'status': status,
      };
}

class TeamModel {
  final String id;
  final String name;
  final String shortCode;
  final String? logoUrl;
  final String? primaryColor;

  const TeamModel({
    required this.id,
    required this.name,
    required this.shortCode,
    this.logoUrl,
    this.primaryColor,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) => TeamModel(
        id: json['id'] as String,
        name: json['name'] as String,
        shortCode: json['short_code'] as String,
        logoUrl: json['logo_url'] as String?,
        primaryColor: json['primary_color'] as String?,
      );
}

class MatchModel {
  final String id;
  final String status;
  final String? teamAName;
  final String? teamBName;
  final String? teamAShort;
  final String? teamBShort;
  final String? venue;
  final String? matchType;
  final int oversPerSide;
  final DateTime? scheduledAt;
  final LiveScoreSnapshot? liveScore;

  const MatchModel({
    required this.id,
    required this.status,
    this.teamAName,
    this.teamBName,
    this.teamAShort,
    this.teamBShort,
    this.venue,
    this.matchType,
    this.oversPerSide = 20,
    this.scheduledAt,
    this.liveScore,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
        id: json['id'] as String,
        status: json['status'] as String,
        teamAName: json['team_a'] as String?,
        teamBName: json['team_b'] as String?,
        teamAShort: json['team_a_short'] as String?,
        teamBShort: json['team_b_short'] as String?,
        venue: json['venue'] as String?,
        matchType: json['match_type'] as String?,
        oversPerSide: json['overs_per_side'] as int? ?? 20,
        scheduledAt: json['scheduled_at'] != null
            ? DateTime.parse(json['scheduled_at'] as String)
            : null,
        liveScore: json['live_score'] != null
            ? LiveScoreSnapshot.fromJson(json['live_score'] as Map<String, dynamic>)
            : null,
      );

  bool get isLive => status == 'in_progress' || status == 'innings_break';
}

class LiveScoreSnapshot {
  final String? battingTeam;
  final String? bowlingTeam;
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

  const LiveScoreSnapshot({
    this.battingTeam,
    this.bowlingTeam,
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
  });

  factory LiveScoreSnapshot.fromJson(Map<String, dynamic> json) => LiveScoreSnapshot(
        battingTeam: json['batting_team_name'] as String?,
        bowlingTeam: json['bowling_team_name'] as String?,
        score: json['score'] as String?,
        overs: (json['overs'] as num?)?.toDouble() ?? 0,
        target: json['target'] as int?,
        crr: (json['crr'] as num?)?.toDouble(),
        rrr: (json['rrr'] as num?)?.toDouble(),
        lastBallResult: json['last_ball_result'] as String?,
        lastWicketInfo: json['last_wicket_info'] as String?,
        partnershipRuns: json['partnership_runs'] as int? ?? 0,
        partnershipBalls: json['partnership_balls'] as int? ?? 0,
        recentBalls: (json['recent_balls'] as List<dynamic>?)
                ?.map((b) => RecentBall.fromJson(b as Map<String, dynamic>))
                .toList() ??
            [],
        extras: json['extras'] as Map<String, dynamic>?,
        fallOfWickets: (json['fall_of_wickets'] as List<dynamic>?)
            ?.map((f) => Map<String, dynamic>.from(f as Map))
            .toList(),
      );
}

class RecentBall {
  final int runs;
  final bool isWicket;
  final String? wicketType;
  final String? extrasType;

  const RecentBall({
    this.runs = 0,
    this.isWicket = false,
    this.wicketType,
    this.extrasType,
  });

  factory RecentBall.fromJson(Map<String, dynamic> json) => RecentBall(
        runs: json['runs'] as int? ?? 0,
        isWicket: json['is_wicket'] as bool? ?? false,
        wicketType: json['wicket_type'] as String?,
        extrasType: json['extras_type'] as String?,
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

class StreamModel {
  final String id;
  final String cameraLabel;
  final int cameraNumber;
  final String? hlsPlaylistUrl;
  final String streamStatus;
  final bool isPrimary;
  final int failoverPriority;

  const StreamModel({
    required this.id,
    required this.cameraLabel,
    required this.cameraNumber,
    this.hlsPlaylistUrl,
    required this.streamStatus,
    this.isPrimary = false,
    this.failoverPriority = 0,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) => StreamModel(
        id: json['id'] as String,
        cameraLabel: json['camera_label'] as String,
        cameraNumber: json['camera_number'] as int,
        hlsPlaylistUrl: json['hls_playlist_url'] as String?,
        streamStatus: json['stream_status'] as String,
        isPrimary: json['is_primary'] as bool? ?? false,
        failoverPriority: json['failover_priority'] as int? ?? 0,
      );

  bool get isLive => streamStatus == 'live';
}

class SponsorModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String? bannerImageUrl;
  final String? websiteUrl;
  final String tier;
  final String? placement;

  const SponsorModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.bannerImageUrl,
    this.websiteUrl,
    required this.tier,
    this.placement,
  });

  factory SponsorModel.fromJson(Map<String, dynamic> json) => SponsorModel(
        id: json['id'] as String? ?? json['sponsor_id'] as String? ?? '',
        name: json['name'] as String,
        logoUrl: json['logo_url'] as String?,
        bannerImageUrl: json['banner_image_url'] as String?,
        websiteUrl: json['website_url'] as String?,
        tier: json['tier'] as String? ?? 'silver',
        placement: json['placement'] as String?,
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

  factory CricketManagerModel.fromJson(Map<String, dynamic> json) => CricketManagerModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        permissions: json['permissions'] as Map<String, dynamic>?,
      );

  bool canManageScores() => permissions?['can_manage_scores'] == true;
  bool canManageStreams() => permissions?['can_manage_streams'] == true;
  bool canManageSponsors() => permissions?['can_manage_sponsors'] == true;
}

class CommentaryModel {
  final double over;
  final String text;
  final String event;

  const CommentaryModel({
    required this.over,
    required this.text,
    required this.event,
  });

  factory CommentaryModel.fromJson(Map<String, dynamic> json) => CommentaryModel(
        over: (json['over'] as num?)?.toDouble() ?? 0,
        text: json['text'] as String,
        event: json['event'] as String,
      );
}

class PlayerStats {
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final double strikeRate;
  final String? dismissal;

  const PlayerStats({
    required this.name,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.strikeRate = 0,
    this.dismissal,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        name: json['name'] as String? ?? '',
        runs: json['runs'] as int? ?? 0,
        balls: json['balls'] as int? ?? 0,
        fours: json['fours'] as int? ?? 0,
        sixes: json['sixes'] as int? ?? 0,
        strikeRate: (json['strike_rate'] as num?)?.toDouble() ?? 0,
        dismissal: json['dismissal'] as String?,
      );
}

class BowlerStats {
  final String name;
  final double overs;
  final int maidens;
  final int runs;
  final int wickets;
  final double economy;

  const BowlerStats({
    required this.name,
    this.overs = 0,
    this.maidens = 0,
    this.runs = 0,
    this.wickets = 0,
    this.economy = 0,
  });

  factory BowlerStats.fromJson(Map<String, dynamic> json) => BowlerStats(
        name: json['name'] as String? ?? '',
        overs: (json['overs'] as num?)?.toDouble() ?? 0,
        maidens: json['maidens'] as int? ?? 0,
        runs: json['runs'] as int? ?? 0,
        wickets: json['wickets'] as int? ?? 0,
        economy: (json['economy'] as num?)?.toDouble() ?? 0,
      );
}
