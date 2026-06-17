import 'package:travel_crm/data/models/members/member_directory_item.dart';

String memberDirectoryDisplayName(MemberDirectoryItem item) {
  final full = item.fullName?.trim();
  if (full != null && full.isNotEmpty) return full;

  final parts = <String>[
    if (item.firstName?.trim().isNotEmpty ?? false) item.firstName!.trim(),
    if (item.lastName?.trim().isNotEmpty ?? false) item.lastName!.trim(),
  ];
  if (parts.isNotEmpty) return parts.join(' ');

  final id = item.id?.trim();
  if (id != null && id.isNotEmpty) return id;
  return 'Unknown';
}

MemberDirectoryItem? memberDirectoryItemById(
  List<MemberDirectoryItem> agents,
  MemberDirectoryItem? selected,
) {
  if (selected == null) return null;
  final selectedId = selected.id?.trim();
  if (selectedId == null || selectedId.isEmpty) return selected;
  for (final agent in agents) {
    if (agent.id?.trim() == selectedId) return agent;
  }
  return selected;
}
