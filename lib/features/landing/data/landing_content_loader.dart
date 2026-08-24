// Landing Content Loader
//
// Tries the LIVE content endpoint first — the Super Admin can edit the
// landing copy at runtime without any rebuild. Falls back to the bundled
// `assets/landing/landing_content.json` when the API is unreachable or no
// "landing" block exists yet. Content is cached in-memory after first load.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'models/landing_content.dart';

class LandingContentLoader {
  static const String assetPath = 'assets/landing/landing_content.json';

  /// Same-origin public endpoint (proxied to Laravel by nginx on
  /// traceodd.com). Relative so it works in every environment.
  static const String remotePath = 'api/v1/public/content/landing';

  LandingContent? _cached;

  /// Load (and cache) the landing content document.
  Future<LandingContent> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    var content = await _loadRemote();
    content ??= await _loadBundled();

    _cached = content;
    return content;
  }

  /// Reads the Super Admin-edited landing document from the API.
  Future<LandingContent?> _loadRemote() async {
    try {
      final uri = Uri.base.resolve(remotePath);
      final response = await Dio().getUri(
        uri,
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final data = response.data;
      if (data is Map<String, dynamic> &&
          data['success'] == true &&
          data['data'] is Map<String, dynamic> &&
          data['data']['payload'] is Map<String, dynamic>) {
        return LandingContent.fromJson(
          data['data']['payload'] as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // API unreachable or malformed — fall back to the bundled copy.
    }
    return null;
  }

  /// Loads the bundled JSON (build-time fallback document).
  Future<LandingContent> _loadBundled() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    return LandingContent.fromJson(
      decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
    );
  }
}
