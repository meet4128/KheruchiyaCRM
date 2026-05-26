import 'package:json_annotation/json_annotation.dart';

part 'set_password_request.g.dart';

/// Body for `POST /api/v1/auth/set-password` (public).
///
/// Consumed when a newly-invited member opens the email link and submits
/// their initial password. The token here is a `purpose=invite` token.
@JsonSerializable(includeIfNull: false)
class SetPasswordRequest {
  const SetPasswordRequest({
    required this.token,
    required this.password,
  });

  factory SetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$SetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetPasswordRequestToJson(this);

  final String token;
  final String password;
}
