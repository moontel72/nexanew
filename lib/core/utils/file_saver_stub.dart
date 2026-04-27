import 'dart:typed_data';

Future<String?> saveBytesToDownloadImpl(
  Uint8List bytes, {
  required String filename,
  required String mimeType,
}) {
  throw UnsupportedError('File saving is not supported on this platform');
}

