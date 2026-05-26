import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens_response.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthTokensResponse {
  const AuthTokensResponse({
    required this.status,
    required this.data,
  });

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensResponseToJson(this);

  final String status;
  final AuthTokensData data;
}

@JsonSerializable(explicitToJson: true)
class AuthTokensData {
  const AuthTokensData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthTokensData.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensDataToJson(this);

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final AuthUser user;
}

@JsonSerializable()
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    this.tokenVersion = 0,
    this.fullName,
    this.invitationStatus,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  final String id;
  final String email;

  /// Backend-derived role. Guaranteed to be one of:
  /// `admin | sales | purchase | account | user`. Treat any other value as
  /// unknown via [UserRoleX.fromString] (see `lib/data/models/auth/user_role.dart`).
  final String role;

  /// Server-issued counter incremented on password reset / forced logout.
  /// Used to invalidate stale sessions when the same user reset on another
  /// device. Defaults to `0` for backward compat with older responses.
  @JsonKey(defaultValue: 0)
  final int tokenVersion;

  /// Full name of the logged-in user (nullable for forward-compat).
  final String? fullName;

  /// `active | pending | disabled` — usually `active` once login succeeds, but
  /// kept here so future flows (e.g. force-set-password on first login) can
  /// branch on it without another round-trip.
  final String? invitationStatus;
}

