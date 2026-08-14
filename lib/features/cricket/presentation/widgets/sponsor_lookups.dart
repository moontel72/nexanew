import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

/// Shared labels, colors, and option lists for sponsor management.
///
/// Single source of truth for sponsor tiers and placements so the
/// library page, sponsor form, and assignment sheet never duplicate
/// these mappings.

const List<String> sponsorTiers = [
  'title',
  'gold',
  'silver',
  'bronze',
  'partner',
];

const List<String> sponsorPlacements = [
  'scoreboard_top',
  'scoreboard_bottom',
  'stream_overlay',
  'mid_over_bumper',
  'fall_of_wicket',
];

String sponsorTierLabel(String tier) => switch (tier) {
  'title' => 'Title',
  'gold' => 'Gold',
  'silver' => 'Silver',
  'bronze' => 'Bronze',
  'partner' => 'Partner',
  _ => tier,
};

Color sponsorTierColor(String tier) => switch (tier) {
  'title' => CricketColors.tierTitle,
  'gold' => CricketColors.tierGold,
  'silver' => CricketColors.tierSilver,
  'bronze' => CricketColors.tierBronze,
  'partner' => CricketColors.teamA,
  _ => CricketColors.textSecondary,
};

String sponsorPlacementLabel(String placement) =>
    placement.replaceAll('_', ' ').toUpperCase();
