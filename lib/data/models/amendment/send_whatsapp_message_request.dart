import 'package:json_annotation/json_annotation.dart';

part 'send_whatsapp_message_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SendWhatsappMessageRequest {
  const SendWhatsappMessageRequest({
    required this.to,
    required this.sessionId,
    required this.inquiryId,
    required this.type,
    this.text,
    this.mediaUrl,
    this.fileName,
  });

  factory SendWhatsappMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendWhatsappMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendWhatsappMessageRequestToJson(this);

  final String to;
  final String sessionId;
  final String inquiryId;
  final String type;
  final String? text;
  final String? mediaUrl;
  final String? fileName;
}
