import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/phone_number_dto.dart';

import 'department_role_dto.dart';

part 'list_members_item.g.dart';

@JsonSerializable(explicitToJson: true)
class ListMembersItem {
  const ListMembersItem({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.personalEmail,
    this.employeeId,
    this.employmentStatus,
    this.dateOfJoining,
    this.createdAt,
    this.departmentRoles = const [],
    this.invitationStatus,
    this.lastInviteSentAt,
    this.phoneNumber,
    this.homePhoneNumber,
    this.officePhoneNumber,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.dateOfAnniversary,
    this.addressLine1,
    this.addressLine2,
    this.zipCode,
    this.city,
    this.designation,
    this.aadharDocumentUrl,
    this.panDocumentUrl,
    this.cancelChequeDocumentUrl,
  });

  factory ListMembersItem.fromJson(Map<String, dynamic> json) {
    // Some endpoints return Mongo `_id`, others expose a plain `id` alias.
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['_id'] == null && normalized['id'] != null) {
      normalized['_id'] = normalized['id'];
    }
    return _$ListMembersItemFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$ListMembersItemToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? personalEmail;
  final String? employeeId;
  final String? employmentStatus;
  final String? dateOfJoining;
  final String? createdAt;

  @JsonKey(defaultValue: [])
  final List<DepartmentRoleDto> departmentRoles;

  /// `pending | active | disabled`. Nullable so older API rows / unmodified
  /// records don't break decoding — treat `null` as "active" for legacy.
  final String? invitationStatus;

  /// ISO-8601 timestamp of the last invite email sent to this member.
  /// Used by the team-members list to surface "Sent X ago" tooltips.
  final String? lastInviteSentAt;

  /// Populated on `GET /members/:id` (and may appear on PATCH `data.member`).
  final PhoneNumberDto? phoneNumber;
  final PhoneNumberDto? homePhoneNumber;
  final PhoneNumberDto? officePhoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? dateOfAnniversary;
  final String? addressLine1;
  final String? addressLine2;
  final String? zipCode;
  final String? city;
  final String? designation;
  final String? aadharDocumentUrl;
  final String? panDocumentUrl;
  final String? cancelChequeDocumentUrl;
}
