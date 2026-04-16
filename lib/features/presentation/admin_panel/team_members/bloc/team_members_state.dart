import 'package:equatable/equatable.dart';

enum MemberStatusFilter { all, online, idle, offline }

enum TeamMemberStatus { online, idle, offline }

enum TeamSection { admin, sales, purchase, accounts }

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
  });

  final String id;
  final String name;
  final String doj;
  final String email;
  final TeamMemberStatus status;
  final String department;

  @override
  List<Object?> get props => [id, name, doj, email, status, department];
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
    this.errorMessage,
  });

  final Map<TeamSection, List<TeamMemberUiModel>> membersBySection;
  final Map<TeamSection, List<TeamMemberUiModel>> visibleMembersBySection;
  final Map<TeamSection, List<TopPerformerUiModel>> topPerformersBySection;
  final String searchQuery;
  final MemberStatusFilter selectedFilter;
  final Map<TeamSection, TeamCategoryTab> selectedCategoryTabBySection;
  final bool isLoading;
  final String? errorMessage;

  TeamMembersState copyWith({
    Map<TeamSection, List<TeamMemberUiModel>>? membersBySection,
    Map<TeamSection, List<TeamMemberUiModel>>? visibleMembersBySection,
    Map<TeamSection, List<TopPerformerUiModel>>? topPerformersBySection,
    String? searchQuery,
    MemberStatusFilter? selectedFilter,
    Map<TeamSection, TeamCategoryTab>? selectedCategoryTabBySection,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
        errorMessage,
      ];
}
