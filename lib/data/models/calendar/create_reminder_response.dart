import 'package:json_annotation/json_annotation.dart';

import 'calendar_event_dto.dart';

part 'create_reminder_response.g.dart';

/// Envelope for `POST .../reminders` — `{ status, data: { reminder } }`.
@JsonSerializable(explicitToJson: true)
class CreateReminderResponse {
  const CreateReminderResponse({
    required this.status,
    required this.data,
  });

  factory CreateReminderResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateReminderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReminderResponseToJson(this);

  final String status;
  final CreateReminderData data;
}

@JsonSerializable(explicitToJson: true)
class CreateReminderData {
  const CreateReminderData({this.reminder});

  factory CreateReminderData.fromJson(Map<String, dynamic> json) =>
      _$CreateReminderDataFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReminderDataToJson(this);

  final CalendarEventDto? reminder;
}
