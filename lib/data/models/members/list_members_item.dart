import 'package:json_annotation/json_annotation.dart';

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
  });

  factory ListMembersItem.fromJson(Map<String, dynamic> json) => _$ListMembersItemFromJson(json);

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
}
