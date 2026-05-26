import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_request.g.dart';

/// Body for `POST /api/v1/auth/forgot-password` (public).
@JsonSerializable(includeIfNull: false)
class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);

  final String email;
}
