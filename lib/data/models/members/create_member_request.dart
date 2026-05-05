import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/core/models/inquiry/phone_number_model.dart';

import 'department_role_dto.dart';

part 'create_member_request.g.dart';

/// POST `/api/v1/members` body — field names and nesting match the API contract
/// (`fullName`, `phoneNumber.countryCode` / `number`, `departmentRoles[]`, etc.).
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CreateMemberRequest {
  const CreateMemberRequest({
    required this.fullName,
    required this.personalEmail,
    required this.phoneNumber,
    required this.homePhoneNumber,
    this.dateOfBirth,
    this.gender,
    required this.maritalStatus,
    this.dateOfAnniversary,
    required this.addressLine1,
    required this.addressLine2,
    required this.zipCode,
    required this.city,
    required this.firstName,
    required this.lastName,
    required this.employeeId,
    required this.designation,
    required this.employmentStatus,
    this.dateOfJoining,
    required this.departmentRoles,
    required this.officePhoneNumber,
    this.aadharDocumentUrl,
    this.panDocumentUrl,
    this.cancelChequeDocumentUrl,
  });

  factory CreateMemberRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMemberRequestToJson(this);

  final String fullName;
  final String personalEmail;
  final PhoneNumberModel phoneNumber;
  final PhoneNumberModel homePhoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String maritalStatus;
  final String? dateOfAnniversary;
  final String addressLine1;
  final String addressLine2;
  final String zipCode;
  final String city;
  final String firstName;
  final String lastName;
  final String employeeId;
  final String designation;
  final String employmentStatus;
  final String? dateOfJoining;
  final List<DepartmentRoleDto> departmentRoles;
  final PhoneNumberModel officePhoneNumber;
  final String? aadharDocumentUrl;
  final String? panDocumentUrl;
  final String? cancelChequeDocumentUrl;
}
