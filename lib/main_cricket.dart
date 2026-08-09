import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/cricket/data/datasources/cricket_remote_datasource.dart';
import 'features/cricket/data/datasources/cricket_websocket_repository.dart';
import 'features/cricket/data/repositories/cricket_repository.dart';
import 'features/cricket/presentation/blocs/match_list/match_list_bloc.dart';
import 'features/cricket/presentation/blocs/live_score/live_score_bloc.dart';
import 'features/cricket/presentation/blocs/stream_player/stream_player_bloc.dart';
import 'features/cricket/presentation/blocs/cricket_auth/cricket_auth_bloc.dart';
import 'features/cricket/presentation/blocs/camera_switcher/camera_switcher_bloc.dart';
import 'features/cricket/presentation/blocs/voice_score/voice_score_bloc.dart';
import 'features/cricket/presentation/blocs/sponsor/sponsor_bloc.dart';
import 'features/cricket/presentation/pages/public/tournament_home_page.dart';

/// ─── NEXATRACE CRICKET PORTAL — Dedicated Entry Point ──
///
/// Build target: cricket.traceodd.com
/// Flutter build: flutter build web --release -t lib/main_cricket.dart
///
/// This is a COMPLETELY SEPARATE Flutter app instance from the
/// main NexaTrace admin/fleet apps. It connects exclusively to
/// the cricket API endpoints (cricket.traceodd.com/api/v1/cricket/).
///
/// ROLE HIERARCHY:
///   Public viewers → Tournament Home → Live Match (score + stream)
///   Cricket Managers → Login → Dashboard → Scoring / Cameras / Voice
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Cricket module configuration
  const cricketBaseUrl = 'https://cricket.traceodd.com';
  const cricketWsUrl = 'wss://cricket.traceodd.com';

  // Initialize data sources
  final remoteDataSource = CricketRemoteDataSource(baseUrl: cricketBaseUrl);
  final webSocketRepo = CricketWebSocketRepository(wsUrl: cricketWsUrl);
  final repository = CricketRepository(
    remote: remoteDataSource,
    webSocket: webSocketRepo,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CricketRepository>.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<MatchListBloc>(
            create: (_) => MatchListBloc(repo: repository),
          ),
          BlocProvider<LiveScoreBloc>(
            create: (_) => LiveScoreBloc(repo: repository),
          ),
          BlocProvider<StreamPlayerBloc>(
            create: (_) => StreamPlayerBloc(repo: repository),
          ),
          BlocProvider<CricketAuthBloc>(
            create: (_) => CricketAuthBloc(repo: repository),
          ),
          BlocProvider<CameraSwitcherBloc>(
            create: (_) => CameraSwitcherBloc(repo: repository),
          ),
          BlocProvider<VoiceScoreBloc>(
            create: (_) => VoiceScoreBloc(repo: repository),
          ),
          BlocProvider<SponsorBloc>(
            create: (_) => SponsorBloc(repo: repository),
          ),
        ],
        child: const CricketApp(),
      ),
    ),
  );
}

class CricketApp extends StatelessWidget {
  const CricketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valley Soon Cricket 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: const ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.greenAccent,
          surface: Color(0xFF1A1E31),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1E31),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const TournamentHomePage(),
    );
  }
}
