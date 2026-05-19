import 'package:travel_crm/data/models/purchase_chat/purchase_chat_inbox_item.dart';

class PurchaseChatInboxData {
  const PurchaseChatInboxData({
    this.inquiryId,
    this.items = const [],
  });

  factory PurchaseChatInboxData.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final items = <PurchaseChatInboxItem>[];
    if (itemsRaw is List) {
      for (final e in itemsRaw) {
        if (e is Map<String, dynamic>) {
          items.add(PurchaseChatInboxItem.fromJson(e));
        }
      }
    }
    return PurchaseChatInboxData(
      inquiryId: json['inquiryId'] as String?,
      items: items,
    );
  }

  final String? inquiryId;
  final List<PurchaseChatInboxItem> items;
}

class PurchaseChatInboxResponse {
  const PurchaseChatInboxResponse({
    required this.status,
    required this.data,
  });

  factory PurchaseChatInboxResponse.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    return PurchaseChatInboxResponse(
      status: json['status'] as String? ?? 'success',
      data: dataRaw is Map<String, dynamic>
          ? PurchaseChatInboxData.fromJson(dataRaw)
          : const PurchaseChatInboxData(),
    );
  }

  final String status;
  final PurchaseChatInboxData data;
}
