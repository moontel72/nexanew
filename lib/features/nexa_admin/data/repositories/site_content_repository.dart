// Site Content Repository
//
// Talks to the CMS-lite endpoints (/api/v1/admin/content… + the public
// read endpoint) so the Super Admin can edit landing + docs content and
// upload screenshots at runtime — no rebuild, no code push.

import 'dart:typed_data';

import 'package:trace_odd/core/services/api_client.dart';

class SiteContentRepository {
  SiteContentRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String _publicBase = '/api/v1/public/content';
  static const String _adminBase = '/api/v1/admin/content';

  /// GET /api/v1/admin/content — all blocks (slug, title, updated_at).
  Future<List<Map<String, dynamic>>> listBlocks() async {
    final res = await _client.get(_adminBase);
    final map = Map<String, dynamic>.from(res as Map);
    final data = map['data'];
    if (data is! List) return const [];
    return data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  /// GET /api/v1/public/content/{slug} — full block (public read).
  Future<Map<String, dynamic>?> getBlock(String slug) async {
    try {
      final res = await _client.get('$_publicBase/$slug', requiresAuth: false);
      final map = Map<String, dynamic>.from(res as Map);
      if (map['success'] != true) return null;
      return Map<String, dynamic>.from(map['data'] as Map);
    } catch (_) {
      return null; // Block does not exist yet.
    }
  }

  /// PUT /api/v1/admin/content/{slug} — create/update a block.
  Future<void> saveBlock(
    String slug, {
    required String? title,
    required Map<String, dynamic>? payload,
  }) async {
    await _client.put(
      '$_adminBase/$slug',
      body: {'title': title, 'payload': payload},
    );
  }

  /// DELETE /api/v1/admin/content/{slug}.
  Future<void> deleteBlock(String slug) async {
    await _client.delete('$_adminBase/$slug');
  }

  /// POST /api/v1/admin/content/upload-image — screenshot upload.
  /// Returns the relative `/storage/…` URL on success.
  Future<String?> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String filePath = '',
  }) async {
    final res = await _client.uploadFile(
      '$_adminBase/upload-image',
      filePath,
      'image',
      fileBytes: bytes,
      fileName: fileName,
    );
    final map = Map<String, dynamic>.from(res as Map);
    if (map['success'] != true) return null;
    final data = Map<String, dynamic>.from(map['data'] as Map);
    return data['url']?.toString();
  }
}
