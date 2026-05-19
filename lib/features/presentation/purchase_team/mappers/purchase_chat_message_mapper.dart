import 'package:travel_crm/core/utils/inquiry_media_url.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_message_item.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

List<QnaChatMessage> qnaMessagesFromPurchaseChatItems(
  List<PurchaseChatMessageItem> items,
) {
  return items.map(qnaMessageFromPurchaseChatItem).toList();
}

QnaChatMessage qnaMessageFromPurchaseChatItem(PurchaseChatMessageItem item) {
  final role = item.senderRole?.toLowerCase();
  final kind = role == 'sales'
      ? QnaChatMessageKind.answer
      : QnaChatMessageKind.question;

  DateTime createdAt = DateTime.now();
  final raw = item.createdAt;
  if (raw != null && raw.isNotEmpty) {
    try {
      createdAt = DateTime.parse(raw).toLocal();
    } catch (_) {}
  }

  final type = item.type?.toLowerCase();
  final isDocument = type == 'document' || type == 'image';
  final hasMedia = item.mediaUrl?.trim().isNotEmpty == true;

  if (isDocument || (hasMedia && type != 'text')) {
    final caption = item.text?.trim() ?? '';
    final fileName = item.fileName?.trim().isNotEmpty == true
        ? item.fileName!.trim()
        : 'Document';
    final mediaPath = item.mediaUrl?.trim() ?? '';

    return QnaChatMessage(
      id: item.id ?? '${item.purchaseTeamMemberId}-${createdAt.microsecondsSinceEpoch}',
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
    id: item.id ?? '${item.purchaseTeamMemberId}-${createdAt.microsecondsSinceEpoch}',
    kind: kind,
    messageType: QnaChatMessageType.text,
    contentType: QnaChatMessageContentType.text,
    body: body,
    createdAt: createdAt,
  );
}
