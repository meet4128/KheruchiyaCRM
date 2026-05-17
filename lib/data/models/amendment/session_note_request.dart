import 'package:json_annotation/json_annotation.dart';

part 'session_note_request.g.dart';

@JsonSerializable()
class SessionNoteRequest {
  const SessionNoteRequest({required this.text});

  factory SessionNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$SessionNoteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SessionNoteRequestToJson(this);

  final String text;
}
