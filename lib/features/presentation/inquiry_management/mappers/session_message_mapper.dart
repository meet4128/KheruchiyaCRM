import 'package:travel_crm/core/utils/inquiry_media_url.dart';
import 'package:travel_crm/data/models/amendment/session_message_item.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

List<QnaChatMessage> qnaMessagesFromSessionItems(List<SessionMessageItem> items) {
  return items
      .map(qnaMessageFromSessionItem)
      .where((message) => message.isDocument || message.body != '—')
      .toList();
}

/// Keeps optimistic document bubbles when the server returns placeholder text rows.
List<QnaChatMessage> mergeQnaChatMessages(
  List<QnaChatMessage> previous,
  List<QnaChatMessage> fromServer,
) {
  if (previous.isEmpty) return fromServer;

  final upgraded = fromServer.map((serverMsg) {
    if (serverMsg.isDocument || serverMsg.body != '—') return serverMsg;

    for (final prev in previous.reversed) {
      if (!prev.id.startsWith('local-doc-') || !prev.isDocument) continue;
      if (prev.kind != serverMsg.kind) continue;
      if (serverMsg.createdAt.difference(prev.createdAt).inSeconds.abs() > 180) {
        continue;
      }
      return QnaChatMessage(
        id: serverMsg.id,
        kind: serverMsg.kind,
        messageType: QnaChatMessageType.document,
        contentType: QnaChatMessageContentType.structured,
        body: prev.body,
        createdAt: serverMsg.createdAt,
        fileName: prev.fileName,
        mimeType: prev.mimeType,
        mediaUrl: prev.mediaUrl,
        caption: prev.caption,
      );
    }
    return serverMsg;
  }).toList();

  final extras = <QnaChatMessage>[];
  for (final prev in previous) {
    if (!prev.id.startsWith('local-doc-') || !prev.isDocument) continue;
    final duplicate = upgraded.any(
      (serverMsg) =>
          serverMsg.isDocument &&
          serverMsg.fileName == prev.fileName &&
          serverMsg.createdAt.difference(prev.createdAt).inSeconds.abs() < 180,
    );
    if (!duplicate) extras.add(prev);
  }

  final merged = [...upgraded, ...extras]
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return merged
      .where((message) => message.isDocument || message.body != '—')
      .toList();
}

QnaChatMessage qnaMessageFromSessionItem(SessionMessageItem item) {
  final direction = _normalizedDirection(item);
  final kind = direction == 'inbound'
      ? QnaChatMessageKind.question
      : QnaChatMessageKind.answer;

  DateTime createdAt = DateTime.now();
  final raw = item.createdAt ?? item.waTimestamp;
  if (raw != null && raw.isNotEmpty) {
    try {
      createdAt = DateTime.parse(raw).toLocal();
    } catch (_) {}
  }

  if (_isSessionDocument(item)) {
    final caption = item.text?.trim() ?? '';
    final fileName = _resolveFileName(item);
    final mediaPath = item.mediaUrl?.trim() ?? '';

    return QnaChatMessage(
      id: item.id ?? '${item.sessionId}-${createdAt.microsecondsSinceEpoch}',
      kind: kind,
      messageType: QnaChatMessageType.document,
      contentType: QnaChatMessageContentType.structured,
      body: caption.isNotEmpty ? caption : fileName,
      createdAt: createdAt,
      fileName: fileName,
      mimeType: item.mimeType,
      mediaUrl: mediaPath.isNotEmpty ? buildInquiryMediaUrl(mediaPath) : null,
      caption: caption.isEmpty ? null : caption,
    );
  }

  var body = item.text?.trim() ?? '';
  if (body.isEmpty) body = '—';

  return QnaChatMessage(
    id: item.id ?? '${item.sessionId}-${createdAt.microsecondsSinceEpoch}',
    kind: kind,
    messageType: QnaChatMessageType.text,
    contentType: QnaChatMessageContentType.text,
    body: body,
    createdAt: createdAt,
  );
}

String? _normalizedDirection(SessionMessageItem item) {
  final direction = item.direction?.toLowerCase().trim();
  if (direction == 'inbound' || direction == 'incoming') return 'inbound';
  if (direction == 'outbound' || direction == 'outgoing') return 'outbound';

  final sender = item.senderType?.toLowerCase().trim();
  if (sender == 'customer' || sender == 'user' || sender == 'peer') {
    return 'inbound';
  }
  if (sender == 'agent' ||
      sender == 'employee' ||
      sender == 'staff' ||
      sender == 'system' ||
      sender == 'business') {
    return 'outbound';
  }
  return direction;
}

bool _isSessionDocument(SessionMessageItem item) {
  final type = item.type?.toLowerCase().trim();
  if (type == 'document' || type == 'file' || type == 'attachment') {
    return true;
  }
  if (item.mediaUrl?.trim().isNotEmpty == true) return true;
  if (_resolveFileName(item) != 'Document') return true;

  final mime = item.mimeType?.toLowerCase().trim() ?? '';
  if (mime.isNotEmpty && mime != 'text/plain') return true;

  final text = item.text?.trim() ?? '';
  if (text.isNotEmpty && _looksLikeFileName(text)) return true;

  return false;
}

String _resolveFileName(SessionMessageItem item) {
  final explicit = item.fileName?.trim();
  if (explicit != null && explicit.isNotEmpty) return explicit;

  final text = item.text?.trim();
  if (text != null && text.isNotEmpty && _looksLikeFileName(text)) return text;

  final fromUrl = _fileNameFromPath(item.mediaUrl);
  if (fromUrl != null) return fromUrl;

  return 'Document';
}

String? _fileNameFromPath(String? path) {
  final trimmed = path?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  final uri = Uri.tryParse(
    trimmed.contains('://') ? trimmed : 'https://local$trimmed',
  );
  final segment = uri?.pathSegments.where((s) => s.isNotEmpty).lastOrNull;
  if (segment == null || segment.isEmpty) return null;
  return Uri.decodeComponent(segment);
}

bool _looksLikeFileName(String value) {
  return RegExp(
    r'\.(pdf|doc|docx|png|jpe?g|gif|webp|xls|xlsx|csv|txt|zip)$',
    caseSensitive: false,
  ).hasMatch(value.trim());
}
