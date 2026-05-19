import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_messages_data.dart';

part 'purchase_chat_messages_response.g.dart';

@JsonSerializable(explicitToJson: true)
class PurchaseChatMessagesResponse {
  const PurchaseChatMessagesResponse({
    required this.status,
    required this.data,
  });

  factory PurchaseChatMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseChatMessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseChatMessagesResponseToJson(this);

  final String status;
  final PurchaseChatMessagesData data;
}
