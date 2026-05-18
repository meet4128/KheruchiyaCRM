import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> viewBytesInBrowser(Uint8List bytes, String mimeType) async {
  await saveAndOpenBytes(bytes, 'file', mimeType);
}

Future<void> downloadBytes(Uint8List bytes, String fileName, String mimeType) async {
  final file = await _writeTemp(bytes, fileName);
  final uri = Uri.file(file.path);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> saveAndOpenBytes(
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  final file = await _writeTemp(bytes, fileName);
  final uri = Uri.file(file.path);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<File> _writeTemp(Uint8List bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final safeName = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
  final file = File('${dir.path}/$safeName');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}
