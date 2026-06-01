import 'package:json_annotation/json_annotation.dart';

import 'list_members_item.dart';

part 'update_member_response.g.dart';

/// `PATCH /api/v1/members/{id}` response envelope.
@JsonSerializable(explicitToJson: true)
class UpdateMemberResponse {
  const UpdateMemberResponse({
    required this.status,
    required this.data,
  });

  factory UpdateMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateMemberResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMemberResponseToJson(this);

  final String status;
  final UpdateMemberData data;
}

@JsonSerializable(explicitToJson: true)
class UpdateMemberData {
  const UpdateMemberData({
    required this.member,
  });

  factory UpdateMemberData.fromJson(Map<String, dynamic> json) =>
      _$UpdateMemberDataFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMemberDataToJson(this);

  final ListMembersItem member;
}
