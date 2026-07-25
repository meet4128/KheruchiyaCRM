import 'package:travel_crm/core/constants/whatsapp_constants.dart';
import 'package:travel_crm/core/utils/inquiry_media_url.dart';
import 'package:travel_crm/data/models/amendment/session_message_item.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

List<QnaChatMessage> qnaMessagesFromSessionItems(List<SessionMessageItem> items) {
  return items.map(qnaMessageFromSessionItem).where(_shouldDisplayQnaChatMessage).toList();
}

bool _shouldDisplayQnaChatMessage(QnaChatMessage message) {
  if (message.isDocument) return true;
  if (message.body != '—') return true;
  return message.kind == QnaChatMessageKind.question;
}

/// Combines message lists and removes duplicates (same send, different API ids/body formats).
List<QnaChatMessage> deduplicateQnaChatMessages(List<QnaChatMessage> messages) {
  final deduped = <QnaChatMessage>[];
  for (final message in messages) {
    final index = deduped.indexWhere((existing) => areDuplicateQnaChatMessages(existing, message));
    if (index >= 0) {
      deduped[index] = preferRicherQnaChatMessage(deduped[index], message);
    } else {
      deduped.add(message);
    }
  }
  return deduped..sort((a, b) => a.createdAt.compareTo(b.createdAt));
}

/// Combines WhatsApp conversation + amendment session feeds without duplicates.
List<QnaChatMessage> mergeServerMessageLists(List<List<QnaChatMessage>> sources) {
  final all = <QnaChatMessage>[];
  for (final list in sources) {
    all.addAll(list);
  }
  return deduplicateQnaChatMessages(all);
}

bool areDuplicateQnaChatMessages(QnaChatMessage a, QnaChatMessage b) {
  if (a.id == b.id) return true;
  if (a.kind != b.kind) return false;
  if (a.createdAt.difference(b.createdAt).inSeconds.abs() > 90) return false;

  final bodyA = normalizeQnaChatMessageBody(a.body);
  final bodyB = normalizeQnaChatMessageBody(b.body);
  if (bodyA == bodyB) return true;

  return false;
}

QnaChatMessage preferRicherQnaChatMessage(QnaChatMessage a, QnaChatMessage b) {
  final scoreA = qnaChatMessageBodyQualityScore(a);
  final scoreB = qnaChatMessageBodyQualityScore(b);
  final preferred = scoreA >= scoreB ? a : b;
  final other = scoreA >= scoreB ? b : a;
  final body = normalizeQnaChatMessageBody(preferred.body).isNotEmpty
      ? normalizeQnaChatMessageBody(preferred.body)
      : normalizeQnaChatMessageBody(other.body);

  return QnaChatMessage(
    id: _stableQnaChatMessageId(preferred, other),
    kind: preferred.kind,
    messageType: preferred.messageType,
    contentType: preferred.contentType,
    body: body,
    createdAt: preferred.createdAt,
    fileName: preferred.fileName ?? other.fileName,
    mimeType: preferred.mimeType ?? other.mimeType,
    mediaUrl: preferred.mediaUrl ?? other.mediaUrl,
    caption: preferred.caption ?? other.caption,
  );
}

String _stableQnaChatMessageId(QnaChatMessage preferred, QnaChatMessage other) {
  for (final id in [preferred.id, other.id]) {
    if (!id.startsWith('local-')) return id;
  }
  return preferred.id;
}

int qnaChatMessageBodyQualityScore(QnaChatMessage message) {
  final body = normalizeQnaChatMessageBody(message.body);
  if (body.isEmpty) return 0;
  if (body.startsWith('[template:')) return 1;
  if (body.startsWith('Hello ') && body.contains('thank you for contacting Kheruchiya')) {
    return 3;
  }
  return 2;
}

/// Maps raw API template text to the approved preview when possible.
String normalizeQnaChatMessageBody(String body) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) return trimmed;

  final rawTemplate = RegExp(
    r'^\[template:([^\]]+)\]:\s*(.+)$',
    caseSensitive: false,
  );
  final match = rawTemplate.firstMatch(trimmed);
  if (match != null) {
    final name = match.group(1)?.trim();
    final param = match.group(2)?.trim() ?? '';
    if (name == WhatsappConstants.templateName) {
      return WhatsappConstants.templatePreview(param);
    }
  }

  return trimmed;
}

/// Keeps optimistic document/template bubbles when the server returns placeholder rows.
List<QnaChatMessage> mergeQnaChatMessages(
  List<QnaChatMessage> previous,
  List<QnaChatMessage> fromServer,
) {
  if (previous.isEmpty) return fromServer;

  final upgraded = fromServer.map((serverMsg) {
    if (serverMsg.isDocument || serverMsg.body != '—') return serverMsg;

    for (final prev in previous.reversed) {
      if (prev.id.startsWith('local-doc-') && prev.isDocument) {
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

      if (prev.id.startsWith('local-template-')) {
        if (prev.kind != serverMsg.kind) continue;
        if (!areDuplicateQnaChatMessages(prev, serverMsg) &&
            serverMsg.createdAt.difference(prev.createdAt).inSeconds.abs() > 180) {
          continue;
        }
        final body = normalizeQnaChatMessageBody(
          normalizeQnaChatMessageBody(serverMsg.body).isNotEmpty &&
                  !serverMsg.body.trim().startsWith('[template:')
              ? serverMsg.body
              : prev.body,
        );
        return QnaChatMessage(
          id: _stableQnaChatMessageId(serverMsg, prev),
          kind: serverMsg.kind,
          messageType: QnaChatMessageType.text,
          contentType: QnaChatMessageContentType.text,
          body: body,
          createdAt: serverMsg.createdAt,
        );
      }
    }
    return serverMsg;
  }).toList();

  final extras = <QnaChatMessage>[];
  for (final prev in previous) {
    if (prev.id.startsWith('local-doc-') && prev.isDocument) {
      final duplicate = upgraded.any(
        (serverMsg) =>
            serverMsg.isDocument &&
            serverMsg.fileName == prev.fileName &&
            serverMsg.createdAt.difference(prev.createdAt).inSeconds.abs() < 180,
      );
      if (!duplicate) extras.add(prev);
      continue;
    }

    if (prev.id.startsWith('local-template-')) {
      final duplicate = upgraded.any(
        (serverMsg) =>
            serverMsg.kind == prev.kind &&
            areDuplicateQnaChatMessages(serverMsg, prev),
      );
      if (!duplicate) extras.add(prev);
    }
  }

  final merged = deduplicateQnaChatMessages([...upgraded, ...extras]);
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
  if (body.isEmpty && _isTemplateMessage(item)) {
    body = _templateDisplayBody(item);
  }
  body = normalizeQnaChatMessageBody(body);
  if (body.isEmpty) {
    if (kind == QnaChatMessageKind.question) {
      final type = item.type?.trim();
      body = type != null && type.isNotEmpty ? '[$type message]' : '[Customer message]';
    } else {
      body = '—';
    }
  }

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
  if (direction == 'inbound' ||
      direction == 'incoming' ||
      direction == 'received' ||
      direction == 'receive') {
    return 'inbound';
  }
  if (direction == 'outbound' ||
      direction == 'outgoing' ||
      direction == 'sent' ||
      direction == 'send') {
    return 'outbound';
  }

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

bool _isTemplateMessage(SessionMessageItem item) {
  return item.type?.toLowerCase().trim() == 'template' ||
      WhatsappConstants.isKnownTemplate(item.templateName);
}

String _templateDisplayBody(SessionMessageItem item) {
  final params = item.templateBodyParams ?? const <String>[];
  final preview = WhatsappConstants.previewFromParams(item.templateName, params);
  if (preview != null) return preview;
  // Fallback for unknown/legacy templates: treat the first param as the name.
  return WhatsappConstants.templatePreview(
    params.isNotEmpty ? params.first : '',
  );
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
