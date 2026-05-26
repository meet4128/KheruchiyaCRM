import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_response.g.dart';

/// `POST /api/v1/auth/forgot-password` — always returns 200 with this body,
/// regardless of whether the email exists (anti-enumeration). The Flutter
/// side never branches on the message; it simply shows the universal
/// "If an account exists…" copy. This DTO exists for completeness only.
@JsonSerializable(explicitToJson: true)
class ForgotPasswordResponse {
  const ForgotPasswordResponse({
    required this.status,
    this.data,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseToJson(this);

  final String status;
  final ForgotPasswordResponseData? data;
}

@JsonSerializable()
class ForgotPasswordResponseData {
  const ForgotPasswordResponseData({this.message});

  factory ForgotPasswordResponseData.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseDataToJson(this);

  final String? message;
}
