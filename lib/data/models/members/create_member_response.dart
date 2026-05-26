import 'package:json_annotation/json_annotation.dart';

import 'invite_result_dto.dart';
import 'list_members_item.dart';

part 'create_member_response.g.dart';

/// `POST /api/v1/members` response envelope.
///
/// The backend now returns the freshly-created [member] plus an [invite]
/// block describing the email send outcome (see [InviteResultDto]).
@JsonSerializable(explicitToJson: true)
class CreateMemberResponse {
  const CreateMemberResponse({
    required this.status,
    required this.data,
  });

  factory CreateMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateMemberResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMemberResponseToJson(this);

  final String status;
  final CreateMemberData data;
}

@JsonSerializable(explicitToJson: true)
class CreateMemberData {
  const CreateMemberData({
    required this.member,
    required this.invite,
  });

  factory CreateMemberData.fromJson(Map<String, dynamic> json) =>
      _$CreateMemberDataFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMemberDataToJson(this);

  final ListMembersItem member;
  final InviteResultDto invite;
}
