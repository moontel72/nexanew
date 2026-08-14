// Cricket Manager Panel Entrypoint — cricket-manager.traceodd.com
//
// Standalone Flutter web build hosting ONLY the cricket operations routes:
// manager login + manager dashboard (scoring, cameras, voice, sponsors,
// teams, players, media) plus the shared match analytics / player profile
// deep links used from inside the dashboard.
//
// Public viewer routes are NOT compiled in — compile-time isolation.
//
// Build:
//   flutter build web --release --target=lib/main_cricket_manager.dart \
//     --dart-define=API_BASE_URL=https://cricket-manager.traceodd.com

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/camera_switcher/camera_switcher_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/cricket_auth/cricket_auth_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/live_score/live_score_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/match_analytics/match_analytics_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/match_list/match_list_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/player_career/player_career_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/sponsor/sponsor_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/tournament_hub/tournament_hub_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/voice_score/voice_score_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/pages/manager/manager_dashboard_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/manager/manager_login_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/match_analytics_page.dart';
import 'package:trace_odd/features/cricket/presentation/pages/public/player_profile_page.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

/// Cached at boot: whether a cricket manager Bearer token exists locally.
bool _managerAuthed = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();
  _managerAuthed = (prefs.getString('cricket_manager_token') ?? '').isNotEmpty;
  runApp(const CricketManagerApp());
}

class CricketManagerApp extends StatelessWidget {
  const CricketManagerApp({super.key});

  /// Routes the root path to the manager dashboard when a token exists,
  /// otherwise to the login page. Login/dashboard routes themselves are
  /// never gated — the login flow navigates via MaterialPageRoute and the
  /// dashboard manages its own auth state (mirrors the shared app).
  GoRouter get _router => GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/' || path.isEmpty) {
        return _managerAuthed
            ? '/cricket-manager/dashboard'
            : '/cricket-manager/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/cricket-manager/login',
        name: 'cricket_manager_login',
        builder: (context, state) => RepositoryProvider(
          create: (_) => CricketRepository(),
          child: BlocProvider(
            create: (ctx) => CricketAuthBloc(
              repo: RepositoryProvider.of<CricketRepository>(ctx),
            ),
            child: const ManagerLoginPage(),
          ),
        ),
      ),
      GoRoute(
        path: '/cricket-manager/dashboard',
        name: 'cricket_manager_dashboard',
        builder: (context, state) {
          final repo = CricketRepository();
          return RepositoryProvider.value(
            value: repo,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => CricketAuthBloc(repo: repo)),
                BlocProvider(create: (_) => MatchListBloc(repo: repo)),
                BlocProvider(create: (_) => TournamentHubBloc(repo: repo)),
                BlocProvider(create: (_) => LiveScoreBloc(repo: repo)),
                BlocProvider(create: (_) => CameraSwitcherBloc(repo: repo)),
                BlocProvider(create: (_) => VoiceScoreBloc(repo: repo)),
                BlocProvider(create: (_) => SponsorBloc(repo: repo)),
              ],
              child: const ManagerDashboardPage(),
            ),
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
    ],
    errorBuilder: (context, state) => const Scaffold(
      backgroundColor: CricketColors.background,
      body: Center(
        child: Text(
          'Page not found',
          style: TextStyle(color: CricketColors.textSecondary),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trace Odd Cricket Manager',
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
