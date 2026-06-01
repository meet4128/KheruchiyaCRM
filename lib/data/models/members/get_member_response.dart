import 'package:json_annotation/json_annotation.dart';

import 'list_members_item.dart';

part 'get_member_response.g.dart';

/// `GET /api/v1/members/{id}` response envelope.
@JsonSerializable(explicitToJson: true)
class GetMemberResponse {
  const GetMemberResponse({
    required this.status,
    required this.data,
  });

  factory GetMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMemberResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetMemberResponseToJson(this);

  final String status;
  final GetMemberData data;
}

@JsonSerializable(explicitToJson: true)
class GetMemberData {
  const GetMemberData({
    required this.member,
  });

  factory GetMemberData.fromJson(Map<String, dynamic> json) =>
      _$GetMemberDataFromJson(json);

  Map<String, dynamic> toJson() => _$GetMemberDataToJson(this);

  final ListMembersItem member;
}
