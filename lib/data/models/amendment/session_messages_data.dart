import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/amendment/session_message_item.dart';

part 'session_messages_data.g.dart';

@JsonSerializable(explicitToJson: true)
class SessionMessagesData {
  const SessionMessagesData({
    this.sessionId,
    this.amendmentId,
    required this.items,
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  factory SessionMessagesData.fromJson(Map<String, dynamic> json) =>
      _$SessionMessagesDataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionMessagesDataToJson(this);

  final String? sessionId;
  final String? amendmentId;

  @JsonKey(defaultValue: [])
  final List<SessionMessageItem> items;

  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
}
