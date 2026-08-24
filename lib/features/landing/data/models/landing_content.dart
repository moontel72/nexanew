// Landing Page Content Models
//
// Single source of truth for ALL landing page copy is the JSON asset at
// `assets/landing/landing_content.json`. These models mirror that document
// 1:1 so the UI renders 100% dynamically — no hardcoded strings, features,
// pricing tiers, or metadata anywhere in the landing widgets.
//
// Adding a vertical, a pricing tier, or a roadmap phase is a JSON-only
// change; no Dart edits required.

import 'package:flutter/material.dart' show Color;

/// Root document of the landing content JSON.
class LandingContent {
  final LandingMeta meta;
  final List<LandingNavLink> nav;
  final LandingHero hero;
  final List<LandingStat> stats;
  final List<LandingVertical> verticals;
  final LandingPricing pricing;
  final LandingRoadmap roadmap;
  final LandingSignup signup;
  final LandingFooter footer;

  const LandingContent({
    required this.meta,
    required this.nav,
    required this.hero,
    required this.stats,
    required this.verticals,
    required this.pricing,
    required this.roadmap,
    required this.signup,
    required this.footer,
  });

  factory LandingContent.fromJson(Map<String, dynamic> json) => LandingContent(
    meta: LandingMeta.fromJson(_map(json['meta'])),
    nav: _list(
      json['nav'],
    ).map((e) => LandingNavLink.fromJson(_map(e))).toList(),
    hero: LandingHero.fromJson(_map(json['hero'])),
    stats: _list(
      json['stats'],
    ).map((e) => LandingStat.fromJson(_map(e))).toList(),
    verticals:
        _list(
            json['verticals'],
          ).map((e) => LandingVertical.fromJson(_map(e))).toList()
          ..sort((a, b) => a.order.compareTo(b.order)),
    pricing: LandingPricing.fromJson(_map(json['pricing'])),
    roadmap: LandingRoadmap.fromJson(_map(json['roadmap'])),
    signup: LandingSignup.fromJson(_map(json['signup'])),
    footer: LandingFooter.fromJson(_map(json['footer'])),
  );

  /// Top-level metadata: brand identity + launch countdown target.
  static Map<String, dynamic> _map(Object? v) =>
      v is Map<String, dynamic> ? v : <String, dynamic>{};
  static List<dynamic> _list(Object? v) => v is List ? v : <dynamic>[];
}

class LandingMeta {
  final String brand;
  final String brandFull;
  final String logoText;
  final String logoAsset;
  final String announcementBadge;
  final DateTime? launchTarget;
  final String defaultInterest;

  const LandingMeta({
    required this.brand,
    required this.brandFull,
    required this.logoText,
    required this.logoAsset,
    required this.announcementBadge,
    required this.launchTarget,
    required this.defaultInterest,
  });

  factory LandingMeta.fromJson(Map<String, dynamic> json) => LandingMeta(
    brand: _s(json, 'brand'),
    brandFull: _s(json, 'brandFull'),
    logoText: _s(json, 'logoText'),
    logoAsset: _s(json, 'logoAsset'),
    announcementBadge: _s(json, 'announcementBadge'),
    launchTarget: DateTime.tryParse(_s(json, 'launchTarget')),
    defaultInterest: _s(json, 'defaultInterest'),
  );
}

class LandingNavLink {
  final String label;
  final String anchor;

  const LandingNavLink({required this.label, required this.anchor});

  factory LandingNavLink.fromJson(Map<String, dynamic> json) =>
      LandingNavLink(label: _s(json, 'label'), anchor: _s(json, 'anchor'));
}

class LandingHero {
  final String eyebrow;
  final String headline;
  final String subheadline;
  final String primaryCta;
  final String secondaryCta;
  final String countdownLabel;
  final String downloadCta;
  final String downloadUrl;

  const LandingHero({
    required this.eyebrow,
    required this.headline,
    required this.subheadline,
    required this.primaryCta,
    required this.secondaryCta,
    required this.countdownLabel,
    this.downloadCta = '',
    this.downloadUrl = '',
  });

  factory LandingHero.fromJson(Map<String, dynamic> json) => LandingHero(
    eyebrow: _s(json, 'eyebrow'),
    headline: _s(json, 'headline'),
    subheadline: _s(json, 'subheadline'),
    primaryCta: _s(json, 'primaryCta'),
    secondaryCta: _s(json, 'secondaryCta'),
    countdownLabel: _s(json, 'countdownLabel'),
    downloadCta: _s(json, 'downloadCta'),
    downloadUrl: _s(json, 'downloadUrl'),
  );
}

class LandingStat {
  final String value;
  final String label;

  const LandingStat({required this.value, required this.label});

  factory LandingStat.fromJson(Map<String, dynamic> json) =>
      LandingStat(value: _s(json, 'value'), label: _s(json, 'label'));
}

class LandingVertical {
  final String id;
  final int order;
  final String tag;
  final String title;
  final String headline;
  final String copy;
  final List<String> features;
  final String icon;
  final Color accent;

  const LandingVertical({
    required this.id,
    required this.order,
    required this.tag,
    required this.title,
    required this.headline,
    required this.copy,
    required this.features,
    required this.icon,
    required this.accent,
  });

  factory LandingVertical.fromJson(Map<String, dynamic> json) {
    final features = (json['features'] is List)
        ? (json['features'] as List).map((e) => e.toString()).toList()
        : <String>[];
    return LandingVertical(
      id: _s(json, 'id'),
      order: json['order'] is num ? (json['order'] as num).toInt() : 0,
      tag: _s(json, 'tag'),
      title: _s(json, 'title'),
      headline: _s(json, 'headline'),
      copy: _s(json, 'copy'),
      features: features,
      icon: _s(json, 'icon'),
      accent: _hexColor(json['accent']),
    );
  }
}

class LandingPricing {
  final String title;
  final String subtitle;
  final String note;
  final List<LandingPricingTier> tiers;

  const LandingPricing({
    required this.title,
    required this.subtitle,
    required this.note,
    required this.tiers,
  });

  factory LandingPricing.fromJson(Map<String, dynamic> json) {
    final tiers = (json['tiers'] is List)
        ? (json['tiers'] as List)
              .map(
                (e) => LandingPricingTier.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{},
                ),
              )
              .toList()
        : <LandingPricingTier>[];
    return LandingPricing(
      title: _s(json, 'title'),
      subtitle: _s(json, 'subtitle'),
      note: _s(json, 'note'),
      tiers: tiers,
    );
  }
}

class LandingPricingTier {
  final String name;
  final String device;
  final String price;
  final String period;
  final List<String> features;
  final bool highlight;

  const LandingPricingTier({
    required this.name,
    required this.device,
    required this.price,
    required this.period,
    required this.features,
    required this.highlight,
  });

  factory LandingPricingTier.fromJson(Map<String, dynamic> json) {
    final features = (json['features'] is List)
        ? (json['features'] as List).map((e) => e.toString()).toList()
        : <String>[];
    return LandingPricingTier(
      name: _s(json, 'name'),
      device: _s(json, 'device'),
      price: _s(json, 'price'),
      period: _s(json, 'period'),
      features: features,
      highlight: json['highlight'] == true,
    );
  }
}

class LandingRoadmap {
  final String title;
  final String subtitle;
  final List<LandingRoadmapPhase> phases;

  const LandingRoadmap({
    required this.title,
    required this.subtitle,
    required this.phases,
  });

  factory LandingRoadmap.fromJson(Map<String, dynamic> json) {
    final phases = (json['phases'] is List)
        ? (json['phases'] as List)
              .map(
                (e) => LandingRoadmapPhase.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{},
                ),
              )
              .toList()
        : <LandingRoadmapPhase>[];
    return LandingRoadmap(
      title: _s(json, 'title'),
      subtitle: _s(json, 'subtitle'),
      phases: phases,
    );
  }
}

class LandingRoadmapPhase {
  final String phase;
  final String title;
  final String detail;

  const LandingRoadmapPhase({
    required this.phase,
    required this.title,
    required this.detail,
  });

  factory LandingRoadmapPhase.fromJson(Map<String, dynamic> json) =>
      LandingRoadmapPhase(
        phase: _s(json, 'phase'),
        title: _s(json, 'title'),
        detail: _s(json, 'detail'),
      );
}

class LandingSignup {
  final String headline;
  final String copy;
  final String button;
  final String interestLabel;
  final List<String> interestOptions;
  final String successTitle;
  final String successBody;
  final String endpoint;

  const LandingSignup({
    required this.headline,
    required this.copy,
    required this.button,
    required this.interestLabel,
    required this.interestOptions,
    required this.successTitle,
    required this.successBody,
    required this.endpoint,
  });

  factory LandingSignup.fromJson(Map<String, dynamic> json) {
    final options = (json['interestOptions'] is List)
        ? (json['interestOptions'] as List).map((e) => e.toString()).toList()
        : <String>[];
    return LandingSignup(
      headline: _s(json, 'headline'),
      copy: _s(json, 'copy'),
      button: _s(json, 'button'),
      interestLabel: _s(json, 'interestLabel'),
      interestOptions: options,
      successTitle: _s(json, 'successTitle'),
      successBody: _s(json, 'successBody'),
      endpoint: _s(json, 'endpoint'),
    );
  }
}

class LandingFooter {
  final String tagline;
  final String contactEmail;
  final String contactLabel;
  final String copyright;
  final List<LandingFooterLink> links;

  const LandingFooter({
    required this.tagline,
    required this.contactEmail,
    required this.contactLabel,
    required this.copyright,
    required this.links,
  });

  factory LandingFooter.fromJson(Map<String, dynamic> json) {
    final links = (json['links'] is List)
        ? (json['links'] as List)
              .map(
                (e) => LandingFooterLink.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{},
                ),
              )
              .toList()
        : <LandingFooterLink>[];
    return LandingFooter(
      tagline: _s(json, 'tagline'),
      contactEmail: _s(json, 'contactEmail'),
      contactLabel: _s(json, 'contactLabel'),
      copyright: _s(json, 'copyright'),
      links: links,
    );
  }
}

class LandingFooterLink {
  final String label;
  final String url;

  const LandingFooterLink({required this.label, required this.url});

  factory LandingFooterLink.fromJson(Map<String, dynamic> json) =>
      LandingFooterLink(label: _s(json, 'label'), url: _s(json, 'url'));
}

// ── Helpers ────────────────────────────────────────────────

String _s(Map<String, dynamic> json, String key) => json[key]?.toString() ?? '';

/// Parse `#RRGGBB` hex strings from JSON; falls back to transparent.
Color _hexColor(Object? value) {
  if (value is! String || value.isEmpty) return const Color(0x00000000);
  var hex = value.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? const Color(0x00000000) : Color(parsed);
}
