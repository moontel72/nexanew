// Landing Content Loader
//
// Loads `assets/landing/landing_content.json` from the app bundle and
// decodes it into the typed LandingContent model. Content is cached
// in-memory after first load so the single-page site never re-reads it.

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models/landing_content.dart';

class LandingContentLoader {
  static const String assetPath = 'assets/landing/landing_content.json';

  LandingContent? _cached;

  /// Load (and cache) the landing content document.
  Future<LandingContent> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    final content = LandingContent.fromJson(
      decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
    );
    _cached = content;
    return content;
  }
}
