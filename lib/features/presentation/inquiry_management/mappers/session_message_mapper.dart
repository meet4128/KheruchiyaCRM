import 'package:travel_crm/data/models/amendment/session_message_item.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

List<QnaChatMessage> qnaMessagesFromSessionItems(List<SessionMessageItem> items) {
  return items.map(qnaMessageFromSessionItem).toList();
}

QnaChatMessage qnaMessageFromSessionItem(SessionMessageItem item) {
  final direction = item.direction?.toLowerCase();
  final kind = direction == 'inbound'
      ? QnaChatMessageKind.question
      : QnaChatMessageKind.answer;

  final type = item.type?.toLowerCase();
  final contentType = type == 'text'
      ? QnaChatMessageContentType.text
      : QnaChatMessageContentType.structured;

  var body = item.text?.trim() ?? '';
  if (type == 'document') {
    final parts = <String>[];
    if (item.fileName != null && item.fileName!.isNotEmpty) {
      parts.add(item.fileName!);
    }
    if (body.isNotEmpty) parts.add(body);
    if (item.mediaUrl != null && item.mediaUrl!.isNotEmpty) {
      parts.add(item.mediaUrl!);
    }
    body = parts.join('\n');
  }

  if (body.isEmpty) body = '—';

  DateTime createdAt = DateTime.now();
  final raw = item.createdAt ?? item.waTimestamp;
  if (raw != null && raw.isNotEmpty) {
    try {
      createdAt = DateTime.parse(raw).toLocal();
    } catch (_) {}
  }

  return QnaChatMessage(
    id: item.id ?? '${item.sessionId}-${createdAt.microsecondsSinceEpoch}',
    kind: kind,
    contentType: contentType,
    body: body,
    createdAt: createdAt,
  );
}
