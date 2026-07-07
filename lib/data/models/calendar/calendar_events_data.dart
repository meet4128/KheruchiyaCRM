import 'package:json_annotation/json_annotation.dart';

import 'calendar_event_dto.dart';

part 'calendar_events_data.g.dart';

/// `data` payload of `GET /calendar/events` — `{ items, from, to, totalItems }`
/// per the live spec (no per-category counts / pagination).
@JsonSerializable(explicitToJson: true)
class CalendarEventsData {
  const CalendarEventsData({
    this.items = const [],
    this.from,
    this.to,
    this.totalItems = 0,
  });

  factory CalendarEventsData.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventsDataFromJson(_normalize(json));

  Map<String, dynamic> toJson() => _$CalendarEventsDataToJson(this);

  @JsonKey(defaultValue: [])
  final List<CalendarEventDto> items;
  final String? from;
  final String? to;
  @JsonKey(defaultValue: 0)
  final int totalItems;

  static Map<String, dynamic> _normalize(Map<String, dynamic> input) {
    final out = Map<String, dynamic>.from(input);
    out['items'] = out['items'] ?? out['docs'] ?? out['results'] ?? const [];
    out['totalItems'] = out['totalItems'] ?? out['totalDocs'] ?? out['count'] ?? 0;
    return out;
  }
}
