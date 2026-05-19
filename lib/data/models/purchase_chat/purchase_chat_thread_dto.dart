import 'package:json_annotation/json_annotation.dart';

part 'purchase_chat_thread_dto.g.dart';

@JsonSerializable()
class PurchaseChatThreadDto {
  const PurchaseChatThreadDto({
    this.id,
    this.inquiryId,
    this.purchaseTeamMemberId,
    this.createdBy,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseChatThreadDto.fromJson(Map<String, dynamic> json) =>
      _$PurchaseChatThreadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseChatThreadDtoToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? inquiryId;
  final String? purchaseTeamMemberId;
  final String? createdBy;
  final String? lastMessageAt;
  final String? lastMessagePreview;
  final String? createdAt;
  final String? updatedAt;
}
