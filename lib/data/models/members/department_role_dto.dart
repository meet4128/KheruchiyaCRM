import 'package:json_annotation/json_annotation.dart';

part 'department_role_dto.g.dart';

@JsonSerializable()
class DepartmentRoleDto {
  const DepartmentRoleDto({
    required this.department,
    required this.role,
  });

  factory DepartmentRoleDto.fromJson(Map<String, dynamic> json) =>
      _$DepartmentRoleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentRoleDtoToJson(this);

  final String department;
  final String role;
}
