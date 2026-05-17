import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/amendment/session_messages_data.dart';

part 'session_messages_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SessionMessagesResponse {
  const SessionMessagesResponse({
    required this.status,
    required this.data,
  });

  factory SessionMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionMessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SessionMessagesResponseToJson(this);

  final String status;
  final SessionMessagesData data;
}
