import 'dart:io';

void deleteRecordingFileImpl(String? path) {
  if (path == null || path.isEmpty) return;
  try {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  } catch (_) {}
}
