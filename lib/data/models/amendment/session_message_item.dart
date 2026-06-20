import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/core/constants/whatsapp_constants.dart';

part 'session_message_item.g.dart';

@JsonSerializable()
class SessionMessageItem {
  const SessionMessageItem({
    this.id,
    this.inquiryId,
    this.sessionId,
    this.amendmentId,
    this.direction,
    this.senderType,
    this.type,
    this.text,
    this.peerPhone,
    this.fileName,
    this.mimeType,
    this.mediaUrl,
    this.waTimestamp,
    this.createdAt,
    this.templateName,
    this.templateBodyParams,
  });

  factory SessionMessageItem.fromJson(Map<String, dynamic> json) =>
      _$SessionMessageItemFromJson(_normalizeSessionMessageJson(json));

  Map<String, dynamic> toJson() => _$SessionMessageItemToJson(this);

  @JsonKey(name: '_id')
  final String? id;

  final String? inquiryId;
  final String? sessionId;
  final String? amendmentId;
  final String? direction;
  final String? senderType;
  final String? type;
  final String? text;
  final String? peerPhone;
  final String? fileName;
  final String? mimeType;
  final String? mediaUrl;
  final String? waTimestamp;
  final String? createdAt;
  final String? templateName;

  @JsonKey(defaultValue: [])
  final List<String>? templateBodyParams;
}

Map<String, dynamic> _normalizeSessionMessageJson(Map<String, dynamic> json) {
  final map = Map<String, dynamic>.from(json);

  map['_id'] ??= json['wamid'];
  map['text'] ??= json['body'] ?? json['message'] ?? json['content'];
  map['fileName'] ??= json['file_name'];
  map['mediaUrl'] ??= json['media_url'];
  map['mimeType'] ??= json['mime_type'];
  map['senderType'] ??= json['sender_type'];
  map['peerPhone'] ??= json['peer_phone'];
  map['waTimestamp'] ??= json['wa_timestamp'];
  map['createdAt'] ??= json['created_at'];
  map['inquiryId'] ??= json['inquiry_id'];
  map['sessionId'] ??= json['session_id'];
  map['amendmentId'] ??= json['amendment_id'];
  map['direction'] ??= _directionFromLegacyFlags(json);

  final media = json['media'];
  if (media is Map<String, dynamic>) {
    map['fileName'] ??= media['fileName'] ?? media['file_name'];
    map['mediaUrl'] ??=
        media['url'] ?? media['mediaUrl'] ?? media['media_url'];
    map['mimeType'] ??= media['mimeType'] ?? media['mime_type'];
    map['type'] ??= media['type'];
  }

  final document = json['document'];
  if (document is Map<String, dynamic>) {
    map['type'] ??= 'document';
    map['fileName'] ??=
        document['fileName'] ?? document['file_name'] ?? document['filename'];
    map['mediaUrl'] ??= document['url'] ??
        document['mediaUrl'] ??
        document['media_url'] ??
        document['link'];
    map['mimeType'] ??= document['mimeType'] ?? document['mime_type'];
    map['text'] ??= document['caption'] ?? document['text'];
  }

  final template = json['template'];
  if (template is Map<String, dynamic>) {
    map['type'] ??= 'template';
    map['templateName'] ??= template['name'];
    final params = template['bodyParams'] ?? template['body_params'];
    if (params is List) {
      map['templateBodyParams'] = params.map((e) => e.toString()).toList();
    }
    final existingText = map['text']?.toString().trim();
    if (existingText == null || existingText.isEmpty) {
      final bodyParams = map['templateBodyParams'];
      if (bodyParams is List && bodyParams.isNotEmpty) {
        map['text'] = WhatsappConstants.templatePreview(bodyParams.first.toString());
      } else if (map['templateName'] == WhatsappConstants.templateName) {
        map['text'] = WhatsappConstants.templatePreview('');
      }
    }
  }

  return map;
}

String? _directionFromLegacyFlags(Map<String, dynamic> json) {
  final fromMe = json['fromMe'] ?? json['from_me'] ?? json['isFromMe'];
  if (fromMe is bool) return fromMe ? 'outbound' : 'inbound';

  final isInbound = json['isInbound'] ?? json['is_inbound'];
  if (isInbound is bool) return isInbound ? 'inbound' : 'outbound';

  return null;
}
