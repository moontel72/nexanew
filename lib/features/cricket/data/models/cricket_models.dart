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

  factory TournamentModel.fromJson(Map<String, dynamic> json) =>
      TournamentModel(
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

  factory LiveScoreSnapshot.fromJson(Map<String, dynamic> json) =>
      LiveScoreSnapshot(
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
        recentBalls:
            (json['recent_balls'] as List<dynamic>?)
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

  factory CricketManagerModel.fromJson(Map<String, dynamic> json) =>
      CricketManagerModel(
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

  factory CommentaryModel.fromJson(Map<String, dynamic> json) =>
      CommentaryModel(
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
