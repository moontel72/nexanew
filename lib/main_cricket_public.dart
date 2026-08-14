// Cricket Public Viewer Entrypoint — cricket.traceodd.com
//
// Standalone Flutter web build hosting ONLY the public cricket routes:
// tournament home, tournament hub, match analytics, player profiles,
// club pages, and Best XI. Manager/admin routes are NOT compiled in —
// compile-time isolation from the manager panel.
//
// Build:
//   flutter build web --release --target=lib/main_cricket_public.dart \
//     --dart-define=API_BASE_URL=https://cricket.traceodd.com

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/live_score/live_score_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/match_analytics/match_analytics_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/match_list/match_list_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/player_career/player_career_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/sponsor/sponsor_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/stream_player/stream_player_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/tournament_hub/tournament_hub_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/best_xi_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/club_home_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/live_match_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/match_analytics_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/player_profile_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/tournament_home_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/tournament_hub_page.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) usePathUrlStrategy();
  runApp(const CricketPublicApp());
}

class CricketPublicApp extends StatelessWidget {
  const CricketPublicApp({super.key});

  GoRouter get _router => GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => MatchListBloc(repo: CricketRepository()),
          child: const TournamentHomePage(),
        ),
      ),
      GoRoute(
        path: '/cricket/match/:matchId',
        name: 'cricket_live_match',
        builder: (context, state) {
          final mid = state.pathParameters['matchId']!;
          final extra = state.extra;
          final match = extra is MatchModel
              ? extra
              : MatchModel(id: mid, status: 'unknown');
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => LiveScoreBloc(repo: CricketRepository()),
              ),
              BlocProvider(
                create: (_) => StreamPlayerBloc(repo: CricketRepository()),
              ),
              BlocProvider(
                create: (_) => SponsorBloc(repo: CricketRepository()),
              ),
            ],
            child: LiveMatchPage(match: match),
          );
        },
      ),
      GoRoute(
        path: '/cricket/tournament/:tournamentId',
        name: 'cricket_tournament_hub',
        builder: (context, state) {
          final tid = state.pathParameters['tournamentId']!;
          final name = state.uri.queryParameters['name'] ?? 'Tournament';
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => TournamentHubBloc(repo: CricketRepository()),
              ),
              BlocProvider(
                create: (_) => MatchListBloc(repo: CricketRepository()),
              ),
            ],
            child: TournamentHubPage(tournamentId: tid, tournamentName: name),
          );
        },
      ),
      GoRoute(
        path: '/cricket/player/:playerId',
        name: 'cricket_player_profile',
        builder: (context, state) {
          final pid = state.pathParameters['playerId']!;
          final name = state.uri.queryParameters['name'] ?? 'Player';
          return BlocProvider(
            create: (_) => PlayerCareerBloc(repo: CricketRepository()),
            child: PlayerProfilePage(playerId: pid, playerName: name),
          );
        },
      ),
      GoRoute(
        path: '/cricket/match/:matchId/analytics',
        name: 'cricket_match_analytics',
        builder: (context, state) {
          final mid = state.pathParameters['matchId']!;
          final title = state.uri.queryParameters['title'] ?? 'Match';
          return BlocProvider(
            create: (_) => MatchAnalyticsBloc(repo: CricketRepository()),
            child: MatchAnalyticsPage(matchId: mid, matchTitle: title),
          );
        },
      ),
      GoRoute(
        path: '/cricket/club/:clubId',
        name: 'cricket_club_home',
        builder: (context, state) {
          final cid = state.pathParameters['clubId']!;
          return FutureBuilder<ClubModel?>(
            future: CricketRepository().getClub(cid),
            builder: (ctx, snap) {
              if (snap.hasData && snap.data != null) {
                return ClubHomePage(club: snap.data!);
              }
              return const Scaffold(
                backgroundColor: CricketColors.background,
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/cricket/best-xi/:xiId',
        name: 'cricket_best_xi',
        builder: (context, state) {
          final xid = state.pathParameters['xiId']!;
          return FutureBuilder<BestXiModel?>(
            future: CricketRepository().getBestXi(xid),
            builder: (ctx, snap) {
              if (snap.hasData && snap.data != null) {
                return BestXiPage(bestXi: snap.data!);
              }
              return const Scaffold(
                backgroundColor: CricketColors.background,
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      backgroundColor: CricketColors.background,
      body: Center(
        child: Text(
          'Match not found',
          style: TextStyle(color: CricketColors.textSecondary),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trace Odd Cricket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CricketColors.background,
        colorScheme: const ColorScheme.dark(
          primary: CricketColors.textAccent,
          secondary: CricketColors.textAccent,
        ),
      ),
      routerConfig: _router,
    );
  }
}
