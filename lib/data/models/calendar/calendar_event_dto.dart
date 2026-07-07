import 'package:json_annotation/json_annotation.dart';

import 'calendar_event_member.dart';

part 'calendar_event_dto.g.dart';

/// A Reminder as returned by `GET /calendar/events` (with the extra
/// `reminderId` / `occurrenceAt` from the `CalendarEvent` allOf) and by
/// `POST .../reminders` (those two fields null). Matches the live spec's
/// `Reminder` + `CalendarEvent` schemas — see docs/openapi.json.
@JsonSerializable(explicitToJson: true)
class CalendarEventDto {
  const CalendarEventDto({
    this.id,
    this.reminderId,
    this.inquiryId,
    this.amendmentId,
    this.sessionId,
    this.note,
    this.remindAt,
    this.occurrenceAt,
    this.recurrenceRule,
    this.agent,
    this.inLoopUsers = const [],
    this.priority,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory CalendarEventDto.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventDtoToJson(this);

  @JsonKey(name: '_id')
  final String? id;

  /// Present on calendar-event rows (the underlying reminder's id).
  final String? reminderId;

  final String? inquiryId;
  final String? amendmentId;
  final String? sessionId;
  final String? note;

  /// Base reminder time (ISO 8601).
  final String? remindAt;

  /// Specific occurrence time for recurring reminders (ISO 8601).
  final String? occurrenceAt;
  final String? recurrenceRule;

  /// `agent` is `string | MemberRef` in the spec — normalised to a member.
  @JsonKey(fromJson: agentFromJson, toJson: agentToJson)
  final CalendarEventMember? agent;

  @JsonKey(defaultValue: [])
  final List<CalendarEventMember> inLoopUsers;

  /// `HIGH` | `MEDIUM` | `LOW`.
  final String? priority;

  /// `pending` | `completed` | `dismissed` | `snoozed`.
  final String? status;

  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;

  /// The best timestamp to place this event on the grid.
  String? get effectiveAt => occurrenceAt ?? remindAt;

  /// Accepts either a bare id string or a populated `MemberRef` object.
  static CalendarEventMember? agentFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return CalendarEventMember(id: json);
    if (json is Map<String, dynamic>) return CalendarEventMember.fromJson(json);
    return null;
  }

  static dynamic agentToJson(CalendarEventMember? agent) => agent?.id;
}
