import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../blocs/live_score/live_score_bloc.dart';
import '../../blocs/stream_player/stream_player_bloc.dart';
import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../blocs/scorecard/scorecard_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';
import '../../widgets/boundary_celebration.dart';
import '../../widgets/match_three_column_layout.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/whep_video_player.dart';
import '../../widgets/sponsor_banner.dart';
import 'scorecard_page.dart';

/// Full match experience (Phase 3): live stream on top, then the
/// 3-partition fan layout — Bowlers | Batters | Match Summary —
/// collapsing to a stacked summary-first layout on narrow screens.
///
/// Fully BLoC-driven: LiveScoreBloc pushes every realtime snapshot and
/// the columns re-render automatically (no setState anywhere).
class LiveMatchPage extends StatefulWidget {
  final MatchModel match;

  const LiveMatchPage({super.key, required this.match});

  @override
  State<LiveMatchPage> createState() => _LiveMatchPageState();
}

class _LiveMatchPageState extends State<LiveMatchPage> {
  /// WHEP target for this match, when the engine has a live camera.
  ///
  /// Fetched independently of the HLS stream list on purpose: WHEP watches the
  /// engine's own SFU egress, so it delivers video even while the engine→SRS
  /// bridge (which the HLS playlist depends on) is down.
  Map<String, dynamic>? _whep;

  /// Retry handle for [_loadWhepTarget].
  ///
  /// The engine only reports a WHEP target once a broadcaster camera is
  /// actually live, and a fan can easily open this page *before* the operator
  /// goes live. Without a retry the viewer is pinned to the HLS fallback —
  /// seconds behind live — for the whole session, even after the camera comes
  /// up. (Observed 2026-10-01: a page left at 6.4s behind Todd Studio.)
  Timer? _whepRetry;

  /// Whether the half-screen score panel is open. The stream keeps playing in
  /// the top half while it is.
  bool _scorePanelOpen = false;

  /// Drives the score panel's scrollbar.
  final ScrollController _scoreScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final scoreBloc = context.read<LiveScoreBloc>();
    final streamBloc = context.read<StreamPlayerBloc>();
    final sponsorBloc = context.read<SponsorBloc>();

    scoreBloc.add(ConnectToMatch(widget.match.id));
    streamBloc.add(LoadStreams(widget.match.id));
    sponsorBloc.add(LoadSponsors(widget.match.id));

    _loadWhepTarget();
  }

  Future<void> _loadWhepTarget() async {
    try {
      final whep = await context.read<CricketRepository>().getWhepTarget(
        widget.match.id,
      );
      if (!mounted) return;
      final url = whep?['url']?.toString();
      if (url != null && url.isNotEmpty && url != _whep?['url']?.toString()) {
        setState(() => _whep = whep);
      }
    } catch (_) {
      // Transient (engine restarting, network): the next poll retries.
    }

    if (!mounted) return;

    // Poll for the whole session. The engine reports a WHEP target only while a
    // broadcaster camera is live, and the on-air camera can change (program
    // switch, phone reconnect) — so a one-shot fetch left two holes: a viewer
    // who arrived before "Go Live" stayed pinned to the HLS fallback (seconds
    // behind) for the whole session, and a camera switch never reached the
    // viewer at all.
    _whepRetry?.cancel();
    _whepRetry = Timer(const Duration(seconds: 10), _loadWhepTarget);
  }

  /// The player to show: WHEP first (sub-second, and independent of the HLS
  /// bridge), then the HLS playlist, then a waiting message.
  Widget _livePlayer(String? hlsUrl) {
    final whep = _whep;
    final whepUrl = whep?['url']?.toString();
    final whepToken = whep?['token']?.toString();

    if (whepUrl != null &&
        whepUrl.isNotEmpty &&
        whepToken != null &&
        whepToken.isNotEmpty) {
      final ice = whep?['ice_servers'];
      return WhepVideoPlayer(
        // Keyed by the target: a camera switch must re-register the platform
        // view and re-POST the offer, while an unchanged target must NOT — a
        // rebuild would tear the live session down.
        key: ValueKey(whepUrl),
        url: whepUrl,
        token: whepToken,
        iceServers: ice is List ? ice : const [],
        autoPlay: true,
      );
    }

    if (hlsUrl != null && hlsUrl.isNotEmpty) {
      return CricketVideoPlayer(hlsUrl: hlsUrl, autoPlay: true);
    }

    return const Center(
      child: Text(
        'Stream starting soon...',
        style: TextStyle(color: CricketColors.textSecondary),
      ),
    );
  }

  @override
  void dispose() {
    _whepRetry?.cancel();
    _scoreScroll.dispose();
    context.read<LiveScoreBloc>().add(DisconnectFromMatch());
    super.dispose();
  }

  void _openScorecard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (ctx) => ScorecardBloc(
            repo: RepositoryProvider.of<CricketRepository>(ctx),
          ),
          child: ScorecardPage(matchId: widget.match.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        title: Text(
          widget.match.displayTitle,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: CricketColors.inputFill,
        foregroundColor: CricketColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart, color: CricketColors.complete),
            tooltip: 'Full Scorecard',
            onPressed: () => _openScorecard(context),
          ),
        ],
      ),
      // The stream owns the whole screen. Everything that used to sit below the
      // player is revealed by ONE overlay button, in a scrollable half-screen
      // panel — while the video keeps playing in the top half.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Guard the panel height. On a wide/short window (a laptop with the
          // browser at 125-150% zoom, or a small window) the body can be
          // shorter than the panel's minimum, and `clamp(240, maxHeight)`
          // THROWS when the lower bound exceeds the upper one — and an
          // unbounded/non-finite maxHeight made the panel position itself off
          // the bottom of the screen, which is exactly how it "disappeared" on
          // a laptop while working on a phone. Use the real viewport as the
          // fallback and a plain fraction (never a throwing clamp).
          final viewportHeight = MediaQuery.sizeOf(context).height;
          final maxHeight = constraints.maxHeight.isFinite &&
                  constraints.maxHeight > 0
              ? constraints.maxHeight
              : viewportHeight;
          final panelHeight = maxHeight < 520 ? maxHeight * 0.75 : maxHeight * 0.5;
          final videoBottom = _scorePanelOpen ? panelHeight : 0.0;

          return Stack(
            children: [
              // 1) The stream. Always present and only ever RESIZED (never
              //    re-created), so toggling the panel cannot restart it.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                top: 0,
                left: 0,
                right: 0,
                bottom: videoBottom,
                child: ColoredBox(
                  color: Colors.black,
                  child: BlocBuilder<StreamPlayerBloc, StreamPlayerState>(
                    builder: (context, state) => switch (state) {
                      StreamPlayerReady(:final activeStreamUrl) =>
                        _livePlayer(activeStreamUrl),
                      StreamPlayerOffline(:final message) => Center(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: CricketColors.textSecondary,
                          ),
                        ),
                      ),
                      _ => const Center(
                        child: CircularProgressIndicator(
                          color: CricketColors.complete,
                        ),
                      ),
                    },
                  ),
                ),
              ),

              // 2) Boundary / wicket celebration, over the video only.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                top: 0,
                left: 0,
                right: 0,
                bottom: videoBottom,
                child: IgnorePointer(
                  child: BlocBuilder<LiveScoreBloc, LiveScoreState>(
                    builder: (context, state) => BoundaryCelebration(
                      score: state is LiveScoreConnected ? state.score : null,
                    ),
                  ),
                ),
              ),

              // 3) Multi-camera selector — over the video so it never costs
              //    screen space; shown only when there are 2+ cameras.
              _cameraChipsOverlay(),

              // 4) The overlay button.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                right: 16,
                bottom: videoBottom + 16,
                child: _scoreToggle(),
              ),

              // 5) The half-screen, scrollable score panel. Parked off-screen
              //    (below the viewport) while closed, so nothing overlaps the
              //    full-screen video.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,
                height: panelHeight,
                bottom: _scorePanelOpen ? 0 : -panelHeight - 4,
                child: _scorePanel(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Compact camera selector pinned to the top of the video.
  Widget _cameraChipsOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: BlocBuilder<StreamPlayerBloc, StreamPlayerState>(
        builder: (context, state) {
          if (state is! StreamPlayerReady || state.streams.length < 2) {
            return const SizedBox.shrink();
          }

          return Container(
            color: Colors.black.withValues(alpha: 0.35),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.streams.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final s = state.streams[index];
                  final selected = index == state.activeCameraIndex;
                  return ChoiceChip(
                    label: Text(s.cameraLabel),
                    selected: selected,
                    backgroundColor: CricketColors.inputFill,
                    selectedColor: CricketColors.complete,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : CricketColors.textSecondary,
                      fontSize: 11,
                    ),
                    onSelected: (_) => context
                        .read<StreamPlayerBloc>()
                        .add(SwitchCamera(index)),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// The one button that reveals everything below the player.
  Widget _scoreToggle() {
    return Material(
      color: CricketColors.complete,
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => setState(() => _scorePanelOpen = !_scorePanelOpen),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _scorePanelOpen ? Icons.keyboard_arrow_down : Icons.leaderboard,
                size: 18,
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                _scorePanelOpen ? 'Hide details' : 'Score & details',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom-half, scrollable panel: sponsors + summary + batters + bowlers.
  Widget _scorePanel() {
    return Material(
      color: CricketColors.background,
      elevation: 16,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 4, 6),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CricketColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Match Centre',
                    style: TextStyle(
                      color: CricketColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: CricketColors.textSecondary,
                  ),
                  tooltip: 'Close',
                  onPressed: () => setState(() => _scorePanelOpen = false),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: CricketColors.border),
          Expanded(
            child: BlocBuilder<LiveScoreBloc, LiveScoreState>(
              builder: (context, state) => switch (state) {
                LiveScoreConnected(:final score) => Scrollbar(
                  controller: _scoreScroll,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scoreScroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BlocBuilder<SponsorBloc, SponsorState>(
                          builder: (ctx, s) => switch (s) {
                            SponsorLoaded(:final sponsors) => SponsorBanner(
                              sponsors: sponsors,
                            ),
                            _ => const SizedBox.shrink(),
                          },
                        ),
                        const SizedBox(height: 8),
                        MatchSummaryColumn(score: score),
                        const SizedBox(height: 20),
                        BattersColumn(score: score),
                        const SizedBox(height: 20),
                        BowlersColumn(score: score),
                      ],
                    ),
                  ),
                ),
                LiveScoreLoading() => const Center(
                  child: CircularProgressIndicator(
                    color: CricketColors.complete,
                  ),
                ),
                LiveScoreError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      message,
                      style: const TextStyle(color: CricketColors.wicket),
                    ),
                  ),
                ),
                _ => const Center(
                  child: Text(
                    'Waiting for match data...',
                    style: TextStyle(color: CricketColors.textSecondary),
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
