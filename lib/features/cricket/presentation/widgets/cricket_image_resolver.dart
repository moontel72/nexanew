import 'package:trace_odd/core/config/api_config.dart';

/// Standardized image URL resolver for the Cricket module.
///
/// Resolves any stored logo/photo value dynamically against the current
/// origin — no host or scheme is ever hardcoded:
///
///   - `/storage/...` (root-relative, current backend format)
///     → `{current origin}/storage/...`
///   - `http(s)://host/storage/...` (legacy absolute URLs written by the
///     old Storage::url() backend) → rewritten to `{current origin}/storage/...`
///     so images load on every device regardless of which host uploaded them
///   - any other absolute URL (external sponsor/club assets) → kept as-is
///
/// Returns null for null/empty/unparseable input so callers can show
/// their fallback avatar.
String? resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  if (uri.hasScheme) {
    // Absolute URL: legacy uploads are pinned to the uploading host.
    // Re-point /storage/ paths at the current origin (domain, IP, HTTP
    // or HTTPS) so the image loads from wherever the app is running.
    if (uri.host.isNotEmpty && uri.path.startsWith('/storage/')) {
      final query = uri.hasQuery ? '?${uri.query}' : '';
      return '${ApiConfig.baseUrl}${uri.path}$query';
    }
    // External image (e.g. a sponsor's website) — load as-is.
    return url;
  }

  // Root-relative path — resolve against the current origin.
  if (url.startsWith('/')) {
    return '${ApiConfig.baseUrl}$url';
  }

  return url;
}
