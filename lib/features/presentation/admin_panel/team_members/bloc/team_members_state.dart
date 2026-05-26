import 'package:equatable/equatable.dart';

enum MemberStatusFilter { all, online, idle, offline }

enum TeamMemberStatus { online, idle, offline }
enum EmploymentStatusFilter { active, inactive, all }

enum TeamSection { admin, sales, purchase, accounts }

/// Server-side invitation status returned in `GET /members`.
///
/// - [active]   → member has completed `set-password`. Normal row, no pill.
/// - [pending]  → backend has issued an invite token but it hasn't been
///   consumed. Show the "Invite pending" pill + "Resend invite" affordance.
/// - [disabled] → admin has disabled the account. Show a "Disabled" pill;
///   no resend affordance.
/// - [unknown]  → backend didn't include the field (legacy row created before
///   the migration). Treated visually like [active] so we don't accidentally
///   flag every old row as "pending".
enum TeamMemberInvitationStatus { active, pending, disabled, unknown }

extension TeamMemberInvitationStatusX on TeamMemberInvitationStatus {
  /// Parser tolerant of unknown / null values.
  static TeamMemberInvitationStatus fromString(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'active':
        return TeamMemberInvitationStatus.active;
      case 'pending':
        return TeamMemberInvitationStatus.pending;
      case 'disabled':
        return TeamMemberInvitationStatus.disabled;
      default:
        return TeamMemberInvitationStatus.unknown;
    }
  }
}

/// One-shot result of a resend-invite call; the screen consumes this via
/// [BlocListener] to show a SnackBar then clears it from state.
class TeamMembersResendInviteResult extends Equatable {
  const TeamMembersResendInviteResult({
    required this.memberId,
    required this.success,
    this.message,
    this.sentTo,
  });

  final String memberId;
  final bool success;
  final String? message;
  final String? sentTo;

  @override
  List<Object?> get props => [memberId, success, message, sentTo];
}

enum TeamCategoryTab {
  all,
  flight,
  hotel,
  holiday,
  visa,
  passport,
  travelInsurance,
  forex,
  transfer,
}

extension TeamSectionX on TeamSection {
  String get title {
    switch (this) {
      case TeamSection.admin:
        return 'Admin Data';
      case TeamSection.sales:
        return 'Sales Team Data';
      case TeamSection.purchase:
        return 'Purchase Team Data';
      case TeamSection.accounts:
        return 'Accounts Team Data';
    }
  }

  String get roleLabel {
    switch (this) {
      case TeamSection.admin:
        return 'Admin';
      case TeamSection.sales:
        return 'Sales Team';
      case TeamSection.purchase:
        return 'Purchase Team';
      case TeamSection.accounts:
        return 'Accounts Team';
    }
  }
}

extension TeamCategoryTabX on TeamCategoryTab {
  String get label {
    switch (this) {
      case TeamCategoryTab.all:
        return 'All';
      case TeamCategoryTab.flight:
        return 'Flight';
      case TeamCategoryTab.hotel:
        return 'Hotel';
      case TeamCategoryTab.holiday:
        return 'Holiday';
      case TeamCategoryTab.visa:
        return 'Visa';
      case TeamCategoryTab.passport:
        return 'Passport';
      case TeamCategoryTab.travelInsurance:
        return 'Travel Insurance';
      case TeamCategoryTab.forex:
        return 'Forex';
      case TeamCategoryTab.transfer:
        return 'Transfer';
    }
  }
}

class TeamMemberUiModel extends Equatable {
  const TeamMemberUiModel({
    required this.id,
    required this.name,
    required this.doj,
    required this.email,
    required this.status,
    this.department = '',
    this.invitationStatus = TeamMemberInvitationStatus.unknown,
    this.lastInviteSentAt,
  });

  final String id;
  final String name;
  final String doj;
  final String email;
  final TeamMemberStatus status;
  final String department;
  final TeamMemberInvitationStatus invitationStatus;
  final DateTime? lastInviteSentAt;

  bool get isInvitePending =>
      invitationStatus == TeamMemberInvitationStatus.pending;

  TeamMemberUiModel copyWith({
    String? id,
    String? name,
    String? doj,
    String? email,
    TeamMemberStatus? status,
    String? department,
    TeamMemberInvitationStatus? invitationStatus,
    DateTime? lastInviteSentAt,
    bool clearLastInviteSentAt = false,
  }) {
    return TeamMemberUiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      doj: doj ?? this.doj,
      email: email ?? this.email,
      status: status ?? this.status,
      department: department ?? this.department,
      invitationStatus: invitationStatus ?? this.invitationStatus,
      lastInviteSentAt: clearLastInviteSentAt
          ? null
          : (lastInviteSentAt ?? this.lastInviteSentAt),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        doj,
        email,
        status,
        department,
        invitationStatus,
        lastInviteSentAt,
      ];
}

class TopPerformerUiModel extends Equatable {
  const TopPerformerUiModel({
    required this.name,
    required this.team,
  });

  final String name;
  final String team;

  @override
  List<Object?> get props => [name, team];
}

class TeamMembersState extends Equatable {
  const TeamMembersState({
    this.membersBySection = const {},
    this.visibleMembersBySection = const {},
    this.topPerformersBySection = const {},
    this.searchQuery = '',
    this.selectedFilter = MemberStatusFilter.all,
    this.selectedCategoryTabBySection = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.employmentStatusFilter = EmploymentStatusFilter.active,
    this.errorMessage,
    this.resendingMemberIds = const <String>{},
    this.resendInviteResult,
  });

  final Map<TeamSection, List<TeamMemberUiModel>> membersBySection;
  final Map<TeamSection, List<TeamMemberUiModel>> visibleMembersBySection;
  final Map<TeamSection, List<TopPerformerUiModel>> topPerformersBySection;
  final String searchQuery;
  final MemberStatusFilter selectedFilter;
  final Map<TeamSection, TeamCategoryTab> selectedCategoryTabBySection;
  final bool isLoading;
  final bool isLoadingMore;
  final int currentPage;
  final int totalPages;
  final EmploymentStatusFilter employmentStatusFilter;
  final String? errorMessage;

  /// IDs of members currently mid-resend. Drives per-row spinner.
  final Set<String> resendingMemberIds;

  /// One-shot result for a resend (success or specific failure). The screen
  /// listens for non-null values, renders a SnackBar, then dispatches
  /// `TeamMembersResendInviteConsumed` to clear it.
  final TeamMembersResendInviteResult? resendInviteResult;

  bool get hasMorePages => currentPage < totalPages;

  TeamMembersState copyWith({
    Map<TeamSection, List<TeamMemberUiModel>>? membersBySection,
    Map<TeamSection, List<TeamMemberUiModel>>? visibleMembersBySection,
    Map<TeamSection, List<TopPerformerUiModel>>? topPerformersBySection,
    String? searchQuery,
    MemberStatusFilter? selectedFilter,
    Map<TeamSection, TeamCategoryTab>? selectedCategoryTabBySection,
    bool? isLoading,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPages,
    EmploymentStatusFilter? employmentStatusFilter,
    String? errorMessage,
    bool clearError = false,
    Set<String>? resendingMemberIds,
    TeamMembersResendInviteResult? resendInviteResult,
    bool clearResendInviteResult = false,
  }) {
    return TeamMembersState(
      membersBySection: membersBySection ?? this.membersBySection,
      visibleMembersBySection: visibleMembersBySection ?? this.visibleMembersBySection,
      topPerformersBySection: topPerformersBySection ?? this.topPerformersBySection,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedCategoryTabBySection:
          selectedCategoryTabBySection ?? this.selectedCategoryTabBySection,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      employmentStatusFilter: employmentStatusFilter ?? this.employmentStatusFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      resendingMemberIds: resendingMemberIds ?? this.resendingMemberIds,
      resendInviteResult: clearResendInviteResult
          ? null
          : (resendInviteResult ?? this.resendInviteResult),
    );
  }

  @override
  List<Object?> get props => [
        membersBySection,
        visibleMembersBySection,
        topPerformersBySection,
        searchQuery,
        selectedFilter,
        selectedCategoryTabBySection,
        isLoading,
        isLoadingMore,
        currentPage,
        totalPages,
        employmentStatusFilter,
        errorMessage,
        resendingMemberIds,
        resendInviteResult,
      ];
}
