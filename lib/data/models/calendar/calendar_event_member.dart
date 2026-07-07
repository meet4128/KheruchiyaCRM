import 'package:json_annotation/json_annotation.dart';

part 'calendar_event_member.g.dart';

/// `MemberRef` from the spec — the populated `agent` / `inLoopUsers` entries on
/// a Reminder. `agent` may also come back as a bare id string; see
/// `CalendarEventDto.agentFromJson`.
@JsonSerializable()
class CalendarEventMember {
  const CalendarEventMember({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.personalEmail,
  });

  factory CalendarEventMember.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventMemberFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventMemberToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? personalEmail;
}
