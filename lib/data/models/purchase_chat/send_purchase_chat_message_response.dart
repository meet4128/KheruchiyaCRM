import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_message_item.dart';

part 'send_purchase_chat_message_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SendPurchaseChatMessageData {
  const SendPurchaseChatMessageData({required this.message});

  factory SendPurchaseChatMessageData.fromJson(Map<String, dynamic> json) =>
      _$SendPurchaseChatMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$SendPurchaseChatMessageDataToJson(this);

  final PurchaseChatMessageItem message;
}

@JsonSerializable(explicitToJson: true)
class SendPurchaseChatMessageResponse {
  const SendPurchaseChatMessageResponse({
    required this.status,
    required this.data,
  });

  factory SendPurchaseChatMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$SendPurchaseChatMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SendPurchaseChatMessageResponseToJson(this);

  final String status;
  final SendPurchaseChatMessageData data;
}
