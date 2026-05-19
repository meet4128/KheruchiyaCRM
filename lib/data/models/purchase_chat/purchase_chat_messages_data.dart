import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_message_item.dart';

part 'purchase_chat_messages_data.g.dart';

@JsonSerializable(explicitToJson: true)
class PurchaseChatMessagesData {
  const PurchaseChatMessagesData({
    this.inquiryId,
    this.purchaseTeamMemberId,
    this.items = const [],
    this.page = 1,
    this.limit = 50,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory PurchaseChatMessagesData.fromJson(Map<String, dynamic> json) =>
      _$PurchaseChatMessagesDataFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseChatMessagesDataToJson(this);

  final String? inquiryId;
  final String? purchaseTeamMemberId;

  @JsonKey(defaultValue: [])
  final List<PurchaseChatMessageItem> items;

  @JsonKey(defaultValue: 1)
  final int page;

  @JsonKey(defaultValue: 50)
  final int limit;

  @JsonKey(defaultValue: 0)
  final int totalItems;

  @JsonKey(defaultValue: 0)
  final int totalPages;
}
