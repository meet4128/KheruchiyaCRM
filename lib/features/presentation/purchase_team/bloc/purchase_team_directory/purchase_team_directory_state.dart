import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/purchase_team_member_ui.dart';

enum PurchaseTeamDirectoryStatus { idle, loading, success, failure }

class PurchaseTeamDirectoryState extends Equatable {
  const PurchaseTeamDirectoryState({
    this.inquiryId,
    this.status = PurchaseTeamDirectoryStatus.idle,
    this.members = const [],
    this.selectedMemberId,
    this.searchQuery = '',
    this.errorMessage,
  });

  final String? inquiryId;
  final PurchaseTeamDirectoryStatus status;
  final List<PurchaseTeamMemberUi> members;
  final String? selectedMemberId;
  final String searchQuery;
  final String? errorMessage;

  PurchaseTeamMemberUi? get selectedMember {
    if (selectedMemberId == null) return null;
    for (final m in members) {
      if (m.purchaseTeamMemberId == selectedMemberId) return m;
    }
    return null;
  }

  PurchaseTeamDirectoryState copyWith({
    String? inquiryId,
    PurchaseTeamDirectoryStatus? status,
    List<PurchaseTeamMemberUi>? members,
    String? selectedMemberId,
    bool clearSelectedMemberId = false,
    String? searchQuery,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PurchaseTeamDirectoryState(
      inquiryId: inquiryId ?? this.inquiryId,
      status: status ?? this.status,
      members: members ?? this.members,
      selectedMemberId:
          clearSelectedMemberId ? null : (selectedMemberId ?? this.selectedMemberId),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        inquiryId,
        status,
        members,
        selectedMemberId,
        searchQuery,
        errorMessage,
      ];
}
