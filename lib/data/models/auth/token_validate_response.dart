import 'package:json_annotation/json_annotation.dart';

part 'token_validate_response.g.dart';

/// `GET /api/v1/auth/token/validate?token=…&purpose=invite|reset` (public).
///
/// Returns just enough metadata for the Set / Reset Password page to render
/// a personalised header without leaking the full email address.
@JsonSerializable(explicitToJson: true)
class TokenValidateResponse {
  const TokenValidateResponse({
    required this.status,
    required this.data,
  });

  factory TokenValidateResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenValidateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TokenValidateResponseToJson(this);

  final String status;
  final TokenValidateData data;
}

@JsonSerializable()
class TokenValidateData {
  const TokenValidateData({
    required this.valid,
    required this.purpose,
    required this.email,
    required this.expiresAt,
  });

  factory TokenValidateData.fromJson(Map<String, dynamic> json) =>
      _$TokenValidateDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenValidateDataToJson(this);

  final bool valid;

  /// `invite` or `reset` — Flutter checks this matches what it asked for.
  final String purpose;

  /// Server-masked email, e.g. `a****@example.com` — safe to render in the UI.
  final String email;

  /// ISO-8601 UTC expiry timestamp.
  final String expiresAt;
}
