import 'package:equatable/equatable.dart';

class PurchaseTeamMemberUi extends Equatable {
  const PurchaseTeamMemberUi({
    required this.purchaseTeamMemberId,
    required this.displayName,
    required this.designation,
    required this.initials,
    this.employeeId = '',
    this.city = '',
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  final String purchaseTeamMemberId;
  final String displayName;
  final String designation;
  final String employeeId;
  final String city;
  final String initials;
  final String? lastMessagePreview;
  final String? lastMessageAt;

  bool get hasThreadPreview =>
      lastMessagePreview != null && lastMessagePreview!.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        purchaseTeamMemberId,
        displayName,
        designation,
        employeeId,
        city,
        initials,
        lastMessagePreview,
        lastMessageAt,
      ];
}
