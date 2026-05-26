import 'package:json_annotation/json_annotation.dart';

part 'invite_result_dto.g.dart';

/// Shared envelope describing the outcome of an invite email send, returned
/// by both `POST /members` (create) and `POST /members/:id/invitations/resend`.
///
/// - `sent: false` ⇒ the admin opted out via `sendInvite: false` on create.
/// - `devFallback: true` ⇒ backend has no Resend API key configured; link
///   was logged to the server console instead of emailed. Only surface
///   this in `kDebugMode` builds.
@JsonSerializable()
class InviteResultDto {
  const InviteResultDto({
    required this.sent,
    this.sentTo,
    this.expiresAt,
    this.devFallback = false,
  });

  factory InviteResultDto.fromJson(Map<String, dynamic> json) =>
      _$InviteResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InviteResultDtoToJson(this);

  final bool sent;
  final String? sentTo;

  /// ISO-8601 UTC timestamp at which the invite token expires.
  final String? expiresAt;

  @JsonKey(defaultValue: false)
  final bool devFallback;
}
