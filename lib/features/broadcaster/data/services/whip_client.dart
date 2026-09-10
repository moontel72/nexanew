/// Parsed components of a WHIP ingest URL.
class WhipUrlParts {
  final String baseUrl;
  final String roomId;
  final String cameraId;
  final String token;

  const WhipUrlParts({
    required this.baseUrl,
    required this.roomId,
    required this.cameraId,
    required this.token,
  });
}

/// Utility for parsing WHIP ingest URLs used by the broadcaster.
class WhipClient {
  WhipClient._();

  static final _whipIngestPattern =
      RegExp(r'/api/v1/whip/ingest/([^/?#]+)(?:/([^/?#]*))?');

  /// Parses a WHIP ingest URL into its component parts.
  ///
  /// Handles:
  /// - Standard URLs: `https://studio.traceodd.com/api/v1/whip/ingest/room/cam?token=t`
  /// - URLs without token or camera id
  /// - Wrapped URLs in `<>`, `()`, `""`, `''`
  /// - Trailing slashes and punctuation
  /// - Missing scheme (defaults to `https://`)
  /// - Share links that embed the ingest URL as a query parameter
  ///
  /// Returns `null` if the URL does not contain a valid WHIP ingest path.
  static WhipUrlParts? parseWhipUrl(String raw) {
    var url = raw.trim();
    if (url.isEmpty) return null;

    // Unwrap angle brackets, parentheses, and quotes.
    if ((url.startsWith('<') && url.endsWith('>')) ||
        (url.startsWith('(') && url.endsWith(')'))) {
      url = url.substring(1, url.length - 1);
    }
    if ((url.startsWith('"') && url.endsWith('"')) ||
        (url.startsWith("'") && url.endsWith("'"))) {
      url = url.substring(1, url.length - 1);
    }
    url = url.trim();

    // Strip trailing sentence punctuation (period, comma, semicolon).
    while (url.endsWith('.') || url.endsWith(',') || url.endsWith(';')) {
      url = url.substring(0, url.length - 1);
    }

    // Check if this is a share/proxy link that embeds the real URL as a parameter.
    final uri0 = Uri.tryParse(url);
    if (uri0 != null && uri0.hasQuery) {
      for (final key in ['url', 'whip', 'ingest']) {
        final embedded = uri0.queryParameters[key];
        if (embedded != null && embedded.contains('/api/v1/whip/ingest/')) {
          return parseWhipUrl(embedded);
        }
      }
    }

    // Restore a missing scheme.
    if (!url.contains('://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;

    // Must contain the WHIP ingest path segment.
    final match = _whipIngestPattern.firstMatch(uri.path);
    if (match == null) return null;

    final roomId = match.group(1) ?? '';
    var cameraId = match.group(2) ?? '';

    // Strip trailing slash from camera id if present.
    if (cameraId.endsWith('/')) {
      cameraId = cameraId.substring(0, cameraId.length - 1);
    }

    final token = uri.queryParameters['token'] ?? '';
    final baseUrl = '${uri.scheme}://${uri.host}'
        '${uri.hasPort ? ':${uri.port}' : ''}';

    return WhipUrlParts(
      baseUrl: baseUrl,
      roomId: roomId,
      cameraId: cameraId,
      token: token,
    );
  }
}
