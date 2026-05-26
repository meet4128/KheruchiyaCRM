import 'package:json_annotation/json_annotation.dart';

part 'reset_password_request.g.dart';

/// Body for `POST /api/v1/auth/reset-password` (public).
///
/// Consumed when a user opens the forgot-password email link. The token here
/// is a `purpose=reset` token. Kept as a sibling DTO of [SetPasswordRequest]
/// so the call sites stay legible and we can diverge fields cheaply if the
/// backend ever differentiates them.
@JsonSerializable(includeIfNull: false)
class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.token,
    required this.password,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);

  final String token;
  final String password;
}
