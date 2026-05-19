import 'package:json_annotation/json_annotation.dart';

part 'send_purchase_chat_message_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SendPurchaseChatMessageRequest {
  const SendPurchaseChatMessageRequest({
    this.text,
    this.type,
    this.mediaUrl,
    this.fileName,
    this.mimeType,
  });

  factory SendPurchaseChatMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendPurchaseChatMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendPurchaseChatMessageRequestToJson(this);

  final String? text;
  final String? type;
  final String? mediaUrl;
  final String? fileName;
  final String? mimeType;
}
