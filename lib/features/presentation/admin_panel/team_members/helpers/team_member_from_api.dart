import 'package:intl/intl.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';

final DateFormat _apiDojOutputFormat = DateFormat('dd/MM/yyyy');

TeamMemberUiModel teamMemberUiModelFromApi(ListMembersItem item, {required String department}) {
  final displayName = (item.fullName ?? '').trim().isNotEmpty
      ? item.fullName!.trim()
      : '${item.firstName ?? ''} ${item.lastName ?? ''}'.trim();
  return TeamMemberUiModel(
    id: (item.id ?? '').trim(),
    name: displayName.isEmpty ? 'Unknown Member' : displayName,
    doj: _formatDate(item.dateOfJoining ?? item.createdAt),
    email: (item.personalEmail ?? '').trim(),
    status: _statusFromEmploymentStatus(item.employmentStatus),
    department: department,
  );
}

Set<TeamSection> teamSectionsFromDepartmentRoles(List<MapEntry<String, String>> departmentRoles) {
  final out = <TeamSection>{};
  for (final role in departmentRoles) {
    final section = _sectionFromDepartment(role.key);
    if (section != null) {
      out.add(section);
    }
  }
  return out;
}

List<MapEntry<String, String>> extractDepartmentRoles(ListMembersItem item) {
  return item.departmentRoles
      .map((e) => MapEntry(e.department.trim(), e.role.trim()))
      .where((e) => e.key.isNotEmpty)
      .toList();
}

String formatDepartmentRoleDisplay(List<MapEntry<String, String>> departmentRoles) {
  if (departmentRoles.isEmpty) {
    return '';
  }
  final labels = <String>[];
  final seen = <String>{};
  for (final entry in departmentRoles) {
    final department = entry.key.trim();
    final role = entry.value.trim();
    final label = role.isEmpty ? department : '$department ($role)';
    if (label.isNotEmpty && !seen.contains(label)) {
      seen.add(label);
      labels.add(label);
    }
  }
  return labels.join(', ');
}

String _formatDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return _apiDojOutputFormat.format(DateTime.now());
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return _apiDojOutputFormat.format(DateTime.now());
  }
  return _apiDojOutputFormat.format(parsed);
}

TeamMemberStatus _statusFromEmploymentStatus(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  switch (normalized) {
    case 'active':
      return TeamMemberStatus.online;
    case 'inactive':
      return TeamMemberStatus.offline;
    default:
      return TeamMemberStatus.idle;
  }
}

TeamSection? _sectionFromDepartment(String department) {
  switch (department.trim().toLowerCase()) {
    case 'admin':
      return TeamSection.admin;
    case 'sales':
      return TeamSection.sales;
    case 'purchase':
      return TeamSection.purchase;
    case 'accounts':
      return TeamSection.accounts;
    default:
      return null;
  }
}
