import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_thread_dto.dart';

part 'open_purchase_chat_response.g.dart';

@JsonSerializable(explicitToJson: true)
class OpenPurchaseChatData {
  const OpenPurchaseChatData({required this.thread});

  factory OpenPurchaseChatData.fromJson(Map<String, dynamic> json) =>
      _$OpenPurchaseChatDataFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPurchaseChatDataToJson(this);

  final PurchaseChatThreadDto thread;
}

@JsonSerializable(explicitToJson: true)
class OpenPurchaseChatResponse {
  const OpenPurchaseChatResponse({
    required this.status,
    required this.data,
  });

  factory OpenPurchaseChatResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenPurchaseChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPurchaseChatResponseToJson(this);

  final String status;
  final OpenPurchaseChatData data;
}
