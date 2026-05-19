import 'package:travel_crm/data/models/members/member_directory_item.dart';

/// Inbox thread row from `GET .../purchase-chats`.
class PurchaseChatInboxItem {
  const PurchaseChatInboxItem({
    this.id,
    this.inquiryId,
    this.purchaseTeamMemberId,
    this.purchaseTeamMember,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseChatInboxItem.fromJson(Map<String, dynamic> json) {
    final memberRaw = json['purchaseTeamMemberId'];
    MemberDirectoryItem? member;
    String? memberId;

    if (memberRaw is Map<String, dynamic>) {
      member = MemberDirectoryItem.fromJson(memberRaw);
      memberId = member.id;
    } else if (memberRaw is String) {
      memberId = memberRaw;
    }

    return PurchaseChatInboxItem(
      id: json['_id'] as String?,
      inquiryId: json['inquiryId'] as String?,
      purchaseTeamMemberId: memberId,
      purchaseTeamMember: member,
      lastMessageAt: json['lastMessageAt'] as String?,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String? id;
  final String? inquiryId;
  final String? purchaseTeamMemberId;
  final MemberDirectoryItem? purchaseTeamMember;
  final String? lastMessageAt;
  final String? lastMessagePreview;
  final String? createdAt;
  final String? updatedAt;
}
