import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> saveBytesToDownloadImpl(
  Uint8List bytes, {
  required String filename,
  required String mimeType,
}) async {
  final baseDir = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(baseDir.path, 'downloads'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final file = File(p.join(dir.path, filename));
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

