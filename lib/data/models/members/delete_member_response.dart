import 'package:json_annotation/json_annotation.dart';

import 'list_members_item.dart';

part 'delete_member_response.g.dart';

/// `DELETE /api/v1/members/{id}` response envelope.
@JsonSerializable(explicitToJson: true)
class DeleteMemberResponse {
  const DeleteMemberResponse({
    required this.status,
    required this.data,
  });

  factory DeleteMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteMemberResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteMemberResponseToJson(this);

  final String status;
  final DeleteMemberData data;
}

@JsonSerializable(explicitToJson: true)
class DeleteMemberData {
  const DeleteMemberData({
    required this.member,
  });

  factory DeleteMemberData.fromJson(Map<String, dynamic> json) =>
      _$DeleteMemberDataFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteMemberDataToJson(this);

  final ListMembersItem member;
}
