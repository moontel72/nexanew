import 'dart:typed_data';

import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';

Future<String?> saveBytesToDownload(
  Uint8List bytes, {
  required String filename,
  String mimeType = 'application/pdf',
}) {
  return saveBytesToDownloadImpl(bytes, filename: filename, mimeType: mimeType);
}
