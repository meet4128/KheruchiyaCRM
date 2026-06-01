import 'package:json_annotation/json_annotation.dart';

import 'invite_result_dto.dart';
import 'list_members_item.dart';

part 'resend_invite_response.g.dart';

/// `POST /api/v1/members/{id}/invitations/resend` response envelope.
///
/// Identical shape to [CreateMemberResponse] — the backend always returns the
/// member alongside the [invite] block so the admin UI can refresh both the
/// list and the snackbar in one round-trip.
@JsonSerializable(explicitToJson: true)
class ResendInviteResponse {
  const ResendInviteResponse({
    required this.status,
    required this.data,
  });

  factory ResendInviteResponse.fromJson(Map<String, dynamic> json) =>
      _$ResendInviteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResendInviteResponseToJson(this);

  final String status;
  final ResendInviteData data;
}

@JsonSerializable(explicitToJson: true)
class ResendInviteData {
  const ResendInviteData({
    required this.member,
    required this.invite,
  });

  factory ResendInviteData.fromJson(Map<String, dynamic> json) =>
      _$ResendInviteDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResendInviteDataToJson(this);

  final ListMembersItem member;
  final InviteResultDto invite;
}
