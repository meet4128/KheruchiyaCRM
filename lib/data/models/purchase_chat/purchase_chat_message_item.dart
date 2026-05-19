import 'package:json_annotation/json_annotation.dart';

part 'purchase_chat_message_item.g.dart';

@JsonSerializable()
class PurchaseChatMessageItem {
  const PurchaseChatMessageItem({
    this.id,
    this.inquiryId,
    this.purchaseTeamMemberId,
    this.senderUserId,
    this.senderRole,
    this.type,
    this.text,
    this.fileName,
    this.mimeType,
    this.mediaUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseChatMessageItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseChatMessageItemFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseChatMessageItemToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? inquiryId;
  final String? purchaseTeamMemberId;
  final String? senderUserId;
  final String? senderRole;
  final String? type;
  final String? text;
  final String? fileName;
  final String? mimeType;
  final String? mediaUrl;
  final String? createdAt;
  final String? updatedAt;
}
