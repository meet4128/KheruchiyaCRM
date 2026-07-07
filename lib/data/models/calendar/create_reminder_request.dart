import 'package:json_annotation/json_annotation.dart';

part 'create_reminder_request.g.dart';

/// Body for `POST /inquiries/{inquiryId}/amendments/{amendmentId}/reminders`.
/// `remindAt`, `agent` and `priority` are required by the spec;
/// `includeIfNull: false` omits the optional fields.
@JsonSerializable(includeIfNull: false)
class CreateReminderRequest {
  const CreateReminderRequest({
    required this.remindAt,
    required this.agent,
    required this.priority,
    this.note,
    this.recurrenceRule,
    this.inLoopUsers,
    this.sessionId,
  });

  factory CreateReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReminderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReminderRequestToJson(this);

  /// ISO 8601 UTC.
  final String remindAt;

  /// Member id of the assigned agent.
  final String agent;

  /// `HIGH` | `MEDIUM` | `LOW`.
  final String priority;

  final String? note;
  final String? recurrenceRule;

  /// Member ids kept in the loop.
  final List<String>? inLoopUsers;
  final String? sessionId;
}
