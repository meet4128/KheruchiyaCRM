import 'package:json_annotation/json_annotation.dart';

import 'calendar_events_data.dart';

part 'calendar_events_response.g.dart';

/// Envelope for `GET /calendar/events` — `{ status, data }`.
@JsonSerializable(explicitToJson: true)
class CalendarEventsResponse {
  const CalendarEventsResponse({
    required this.status,
    required this.data,
  });

  factory CalendarEventsResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventsResponseToJson(this);

  final String status;
  final CalendarEventsData data;
}
