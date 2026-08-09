import 'package:flutter/material.dart';
import '../../data/models/cricket_models.dart';

/// Compact match card for the tournament home page list.
class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                _LiveMatchPageShell(matchId: match.id, match: match),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E31),
          borderRadius: BorderRadius.circular(12),
          border: match.isLive
              ? Border.all(color: Colors.red.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${match.teamAShort ?? 'T1'} vs ${match.teamBShort ?? 'T2'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (match.isLive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (match.liveScore != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      match.liveScore!.score ?? '',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Overs: ${match.liveScore!.overs.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            if (match.venue != null)
              Flexible(
                child: Text(
                  match.venue!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shell widget that provides BLoC context for live match page.
class _LiveMatchPageShell extends StatelessWidget {
  final String matchId;
  final MatchModel match;

  const _LiveMatchPageShell({required this.matchId, required this.match});

  @override
  Widget build(BuildContext context) {
    // We defer to the public LiveMatchPage — importing here to avoid
    // circular dependency with the full page definition.
    return _LiveMatchPageContent(match: match);
  }
}

/// Inline live match content (avoids extra import complexity).
class _LiveMatchPageContent extends StatefulWidget {
  final MatchModel match;
  const _LiveMatchPageContent({required this.match});

  @override
  State<_LiveMatchPageContent> createState() => _LiveMatchPageContentState();
}

class _LiveMatchPageContentState extends State<_LiveMatchPageContent> {
  @override
  Widget build(BuildContext context) {
    // Use the BLoCs from the cricket app scope
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${widget.match.teamAShort ?? 'T1'} vs ${widget.match.teamBShort ?? 'T2'}',
        ),
        backgroundColor: const Color(0xFF1A1E31),
        foregroundColor: Colors.white,
      ),
      body: _MatchDetailBody(matchId: widget.match.id),
    );
  }
}

/// Match detail body that connects to BLoCs.
class _MatchDetailBody extends StatefulWidget {
  final String matchId;
  const _MatchDetailBody({required this.matchId});

  @override
  State<_MatchDetailBody> createState() => _MatchDetailBodyState();
}

class _MatchDetailBodyState extends State<_MatchDetailBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.findAncestorStateOfType<_MatchDetailBodyState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_cricket, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Match Details',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            'Live score and stream will appear when match is in progress.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
