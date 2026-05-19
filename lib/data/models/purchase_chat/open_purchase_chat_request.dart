import 'package:json_annotation/json_annotation.dart';

part 'open_purchase_chat_request.g.dart';

@JsonSerializable()
class OpenPurchaseChatRequest {
  const OpenPurchaseChatRequest({required this.purchaseTeamMemberId});

  factory OpenPurchaseChatRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenPurchaseChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPurchaseChatRequestToJson(this);

  final String purchaseTeamMemberId;
}
