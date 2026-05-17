import 'package:json_annotation/json_annotation.dart';

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
  });

  factory SessionMessageItem.fromJson(Map<String, dynamic> json) =>
      _$SessionMessageItemFromJson(json);

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
}
