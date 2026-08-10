import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import '../../data/models/cricket_models.dart';

/// Horizontal scrolling sponsor banner strip for live match overlay.
class SponsorBanner extends StatelessWidget {
  final List<SponsorModel> sponsors;

  const SponsorBanner({super.key, this.sponsors = const []});

  @override
  Widget build(BuildContext context) {
    if (sponsors.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      color: CricketColors.inputFill,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: sponsors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final s = sponsors[index];
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s.logoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    s.logoUrl!,
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _tierIcon(s.tier),
                  ),
                )
              else
                _tierIcon(s.tier),
              const SizedBox(width: 8),
              Text(
                s.name,
                style: const TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tierIcon(String tier) {
    final color = switch (tier) {
      'title' => CricketColors.tierTitle,
      'gold' => CricketColors.tierGold,
      'silver' => CricketColors.tierSilver,
      'bronze' => CricketColors.tierBronze,
      _ => CricketColors.tierSilver,
    };
    return Icon(Icons.star, color: color, size: 28);
  }
}
