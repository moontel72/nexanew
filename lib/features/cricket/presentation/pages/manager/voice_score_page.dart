import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/shared/theme/colors.dart';

import '../../blocs/voice_score/voice_score_bloc.dart';

/// Voice-to-score interface — microphone trigger → DeepSeek V4 → score.
class VoiceScorePage extends StatefulWidget {
  final String matchId;

  const VoiceScorePage({super.key, required this.matchId});

  @override
  State<VoiceScorePage> createState() => _VoiceScorePageState();
}

class _VoiceScorePageState extends State<VoiceScorePage> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        title: const Text('Voice-to-Score'),
        backgroundColor: CricketColors.surface,
        foregroundColor: CricketColors.textPrimary,
      ),
      body: BlocConsumer<VoiceScoreBloc, VoiceScoreState>(
        listener: (context, state) {
          if (state is VoiceScoreApplied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Instruction card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CricketColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.mic,
                        size: 48,
                        color: CricketColors.roleAllRounder,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Speak or Type Score Update',
                        style: TextStyle(
                          color: CricketColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Examples: "Four runs", "Wicket, bowled",\n"Wide ball", "Six over mid-wicket"',
                        style: TextStyle(
                          color: CricketColors.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Text input field
                TextField(
                  controller: _textCtrl,
                  style: const TextStyle(color: CricketColors.textPrimary),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Type score commentary...',
                    hintStyle: const TextStyle(
                      color: CricketColors.placeholder,
                    ),
                    filled: true,
                    fillColor: CricketColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.secondary),
                      onPressed: () {
                        final text = _textCtrl.text.trim();
                        if (text.isNotEmpty && widget.matchId.isNotEmpty) {
                          context.read<VoiceScoreBloc>().add(
                            ProcessTranscript(widget.matchId, text),
                          );
                          _textCtrl.clear();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Processing / results
                switch (state) {
                  VoiceScoreIdle() => const Text(
                    'Ready for voice input.',
                    style: TextStyle(color: CricketColors.textSecondary),
                  ),
                  VoiceScoreListening() => const Column(
                    children: [
                      Icon(
                        Icons.mic,
                        size: 48,
                        color: CricketColors.roleAllRounder,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Listening...',
                        style: TextStyle(color: CricketColors.roleAllRounder),
                      ),
                    ],
                  ),
                  VoiceScoreProcessing(:final transcript) => Column(
                    children: [
                      const CircularProgressIndicator(
                        color: CricketColors.roleAllRounder,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Processing: "$transcript"',
                        style: const TextStyle(
                          color: CricketColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  VoiceScoreParsed(:final parsedData, :final logId) =>
                    _ParsedScoreCard(data: parsedData, logId: logId),
                  VoiceScoreApplied(:final message) => Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  VoiceScoreError(:final message) => Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: CricketColors.wicket,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(color: CricketColors.wicket),
                      ),
                    ],
                  ),
                },
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Display parsed voice score data with apply/reject buttons.
class _ParsedScoreCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String logId;

  const _ParsedScoreCard({required this.data, required this.logId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'PARSED SCORE',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _DataRow(label: 'Runs', value: '${data['runs'] ?? 0}'),
          _DataRow(
            label: 'Wicket',
            value: data['is_wicket'] == true ? 'YES' : 'NO',
          ),
          if (data['wicket_type'] != null)
            _DataRow(label: 'Type', value: '${data['wicket_type']}'),
          if (data['extras_type'] != null)
            _DataRow(label: 'Extras', value: '${data['extras_type']}'),
          if (data['commentary_hint'] != null)
            _DataRow(label: 'Commentary', value: '${data['commentary_hint']}'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: CricketColors.wicket,
                ),
                onPressed: () =>
                    context.read<VoiceScoreBloc>().add(CancelVoiceScore()),
                child: const Text('REJECT'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: () =>
                    context.read<VoiceScoreBloc>().add(ApplyVoiceScore(logId)),
                child: const Text('APPLY SCORE'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CricketColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: CricketColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
