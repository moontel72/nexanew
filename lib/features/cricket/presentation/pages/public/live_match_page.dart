import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/live_score/live_score_bloc.dart';
import '../../blocs/stream_player/stream_player_bloc.dart';
import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../widgets/scoreboard_header.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/ball_by_ball_ticker.dart';
import '../../widgets/sponsor_banner.dart';

/// Full match experience: live stream + scoreboard + ball-by-ball.
class LiveMatchPage extends StatefulWidget {
  final MatchModel match;

  const LiveMatchPage({super.key, required this.match});

  @override
  State<LiveMatchPage> createState() => _LiveMatchPageState();
}

class _LiveMatchPageState extends State<LiveMatchPage> {
  @override
  void initState() {
    super.initState();
    final scoreBloc = context.read<LiveScoreBloc>();
    final streamBloc = context.read<StreamPlayerBloc>();
    final sponsorBloc = context.read<SponsorBloc>();

    scoreBloc.add(ConnectToMatch(widget.match.id));
    streamBloc.add(LoadStreams(widget.match.id));
    sponsorBloc.add(LoadSponsors(widget.match.id));
  }

  @override
  void dispose() {
    context.read<LiveScoreBloc>().add(DisconnectFromMatch());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${widget.match.teamAShort ?? 'T1'} vs ${widget.match.teamBShort ?? 'T2'}',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1A1E31),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Video player (HLS)
          SizedBox(
            height: 220,
            child: BlocBuilder<StreamPlayerBloc, StreamPlayerState>(
              builder: (context, state) => switch (state) {
                StreamPlayerReady(:final activeStreamUrl) => CricketVideoPlayer(
                  hlsUrl: activeStreamUrl ?? '',
                ),
                StreamPlayerOffline(:final message) => Center(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                _ => const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              },
            ),
          ),

          // Sponsor banner strip
          BlocBuilder<SponsorBloc, SponsorState>(
            builder: (ctx, state) => switch (state) {
              SponsorLoaded(:final sponsors) => SponsorBanner(
                sponsors: sponsors,
              ),
              _ => const SizedBox.shrink(),
            },
          ),

          // Scoreboard
          BlocBuilder<LiveScoreBloc, LiveScoreState>(
            builder: (context, state) => switch (state) {
              LiveScoreConnected(:final score) => CricketScoreboard(
                score: score,
              ),
              LiveScoreLoading() => const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Colors.green),
              ),
              LiveScoreError(:final message) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(message, style: const TextStyle(color: Colors.red)),
              ),
              _ => const SizedBox.shrink(),
            },
          ),

          // Ball-by-ball ticker
          Expanded(
            child: BlocBuilder<LiveScoreBloc, LiveScoreState>(
              builder: (context, state) => switch (state) {
                LiveScoreConnected(:final score) => BallByBallTicker(
                  score: score,
                ),
                _ => const Center(
                  child: Text(
                    'Waiting for match data...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
