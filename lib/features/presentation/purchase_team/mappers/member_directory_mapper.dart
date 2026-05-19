import 'package:travel_crm/data/models/members/member_directory_item.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_inbox_item.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/purchase_team_member_ui.dart';

List<PurchaseTeamMemberUi> purchaseTeamMembersFromDirectory(
  List<MemberDirectoryItem> items, {
  Map<String, PurchaseChatInboxItem>? inboxByMemberId,
}) {
  return items
      .map((item) => purchaseTeamMemberFromDirectory(item, inboxByMemberId))
      .toList();
}

PurchaseTeamMemberUi purchaseTeamMemberFromDirectory(
  MemberDirectoryItem item,
  Map<String, PurchaseChatInboxItem>? inboxByMemberId,
) {
  final id = item.id ?? '';
  final inbox = inboxByMemberId?[id];

  final displayName = _displayName(item);
  return PurchaseTeamMemberUi(
    purchaseTeamMemberId: id,
    displayName: displayName,
    designation: item.designation?.trim() ?? '',
    employeeId: item.employeeId?.trim() ?? '',
    city: item.city?.trim() ?? '',
    initials: _initials(displayName),
    lastMessagePreview: inbox?.lastMessagePreview,
    lastMessageAt: inbox?.lastMessageAt,
  );
}

String _displayName(MemberDirectoryItem item) {
  final full = item.fullName?.trim();
  if (full != null && full.isNotEmpty) return full;
  final first = item.firstName?.trim() ?? '';
  final last = item.lastName?.trim() ?? '';
  final combined = '$first $last'.trim();
  return combined.isEmpty ? 'Purchase team member' : combined;
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.length >= 2
        ? parts.first.substring(0, 2).toUpperCase()
        : parts.first.toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
