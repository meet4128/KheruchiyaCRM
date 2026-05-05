import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/core/models/inquiry/phone_number_model.dart';

import 'department_role_dto.dart';

part 'update_member_request.g.dart';

/// PATCH body: only non-null fields are serialized ([includeIfNull]: false).
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UpdateMemberRequest {
  const UpdateMemberRequest({
    this.fullName,
    this.personalEmail,
    this.phoneNumber,
    this.homePhoneNumber,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.dateOfAnniversary,
    this.addressLine1,
    this.addressLine2,
    this.zipCode,
    this.city,
    this.firstName,
    this.lastName,
    this.employeeId,
    this.designation,
    this.employmentStatus,
    this.dateOfJoining,
    this.departmentRoles,
    this.officePhoneNumber,
    this.aadharDocumentUrl,
    this.panDocumentUrl,
    this.cancelChequeDocumentUrl,
  });

  factory UpdateMemberRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMemberRequestToJson(this);

  final String? fullName;
  final String? personalEmail;
  final PhoneNumberModel? phoneNumber;
  final PhoneNumberModel? homePhoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? dateOfAnniversary;
  final String? addressLine1;
  final String? addressLine2;
  final String? zipCode;
  final String? city;
  final String? firstName;
  final String? lastName;
  final String? employeeId;
  final String? designation;
  final String? employmentStatus;
  final String? dateOfJoining;
  final List<DepartmentRoleDto>? departmentRoles;
  final PhoneNumberModel? officePhoneNumber;
  final String? aadharDocumentUrl;
  final String? panDocumentUrl;
  final String? cancelChequeDocumentUrl;
}
