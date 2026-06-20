import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

/// True when the customer sent an inbound message within the last 24 hours.
bool computeHasActiveWhatsappSession(List<QnaChatMessage> messages) {
  DateTime? lastInbound;
  for (final message in messages) {
    if (message.kind != QnaChatMessageKind.question) continue;
    if (lastInbound == null || message.createdAt.isAfter(lastInbound)) {
      lastInbound = message.createdAt;
    }
  }
  if (lastInbound == null) return false;
  return DateTime.now().difference(lastInbound).inHours < 24;
}

/// True when we have already sent at least one outbound message (e.g. greeting template).
bool computeHasOutboundMessage(List<QnaChatMessage> messages) {
  return messages.any((message) => message.kind == QnaChatMessageKind.answer);
}
