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
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  final String id;
  final String email;
  final String role;
}

