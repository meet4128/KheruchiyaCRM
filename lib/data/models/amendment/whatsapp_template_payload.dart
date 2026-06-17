import 'package:json_annotation/json_annotation.dart';

part 'whatsapp_template_payload.g.dart';

@JsonSerializable(includeIfNull: false)
class WhatsappTemplatePayload {
  const WhatsappTemplatePayload({
    required this.name,
    required this.language,
    required this.bodyParams,
  });

  factory WhatsappTemplatePayload.fromJson(Map<String, dynamic> json) =>
      _$WhatsappTemplatePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$WhatsappTemplatePayloadToJson(this);

  final String name;
  final String language;
  final List<String> bodyParams;
}
