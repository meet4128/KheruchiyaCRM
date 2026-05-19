import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/phone_number_dto.dart';
import 'package:travel_crm/data/models/members/department_role_dto.dart';

part 'member_directory_item.g.dart';

@JsonSerializable(explicitToJson: true)
class MemberDirectoryItem {
  const MemberDirectoryItem({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.employeeId,
    this.designation,
    this.employmentStatus,
    this.departmentRoles = const [],
    this.officePhoneNumber,
    this.phoneNumber,
    this.personalEmail,
    this.city,
  });

  factory MemberDirectoryItem.fromJson(Map<String, dynamic> json) =>
      _$MemberDirectoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$MemberDirectoryItemToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? employeeId;
  final String? designation;
  final String? employmentStatus;

  @JsonKey(defaultValue: [])
  final List<DepartmentRoleDto> departmentRoles;

  final PhoneNumberDto? officePhoneNumber;
  final PhoneNumberDto? phoneNumber;
  final String? personalEmail;
  final String? city;
}
