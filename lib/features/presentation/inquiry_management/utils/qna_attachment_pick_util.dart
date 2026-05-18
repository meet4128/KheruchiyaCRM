import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_pending_attachment.dart';

const _allowedExtensions = [
  'pdf',
  'png',
  'jpg',
  'jpeg',
  'doc',
  'docx',
  'webp',
  'heic',
];

/// Opens the system picker and normalizes bytes/path for mobile, desktop, and web.
Future<QnaChatPendingAttachment?> pickQnaChatAttachment() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: _allowedExtensions,
    allowMultiple: false,
    // Web: load bytes (path is unavailable). Native: use filesystem path.
    withData: kIsWeb,
    withReadStream: false,
  );

  if (result == null || result.files.isEmpty) return null;

  final file = result.files.single;
  final fileName = file.name.trim();
  if (fileName.isEmpty) return null;

  final bytes = await _loadPlatformFileBytes(file);
  final path = kIsWeb ? null : file.path;

  if ((bytes == null || bytes.isEmpty) && (path == null || path.trim().isEmpty)) {
    return null;
  }

  return QnaChatPendingAttachment(
    fileName: fileName,
    filePath: path?.trim().isEmpty == true ? null : path?.trim(),
    bytes: bytes,
  );
}

Future<List<int>?> _loadPlatformFileBytes(PlatformFile file) async {
  if (file.bytes != null && file.bytes!.isNotEmpty) {
    return file.bytes;
  }

  final stream = file.readStream;
  if (stream != null) {
    final chunks = await stream.toList();
    if (chunks.isEmpty) return null;
    return chunks.expand((chunk) => chunk).toList(growable: false);
  }

  return null;
}
