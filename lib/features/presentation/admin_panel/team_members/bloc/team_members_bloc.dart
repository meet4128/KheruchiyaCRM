import 'package:flutter_bloc/flutter_bloc.dart';

import 'team_members_event.dart';
import 'team_members_state.dart';

class TeamMembersBloc extends Bloc<TeamMembersEvent, TeamMembersState> {
  TeamMembersBloc() : super(const TeamMembersState()) {
    on<TeamMembersFetched>(_onFetched);
    on<TeamMembersSearchChanged>(_onSearchChanged);
    on<TeamMembersFilterChanged>(_onFilterChanged);
    on<TeamMembersSortFilterTapped>(_onSortFilterTapped);
    on<TeamCategoryTabChanged>(_onCategoryTabChanged);
    on<TeamMemberEditTapped>(_onEditTapped);
    on<TeamMemberDeleteTapped>(_onDeleteTapped);
  }

  void _onFetched(TeamMembersFetched event, Emitter<TeamMembersState> emit) {
    final selectedTabs = <TeamSection, TeamCategoryTab>{
      TeamSection.sales: TeamCategoryTab.all,
      TeamSection.purchase: TeamCategoryTab.all,
      TeamSection.accounts: TeamCategoryTab.all,
    };
    final membersBySection = _seedMembersBySection;
    emit(
      state.copyWith(
        membersBySection: membersBySection,
        topPerformersBySection: _seedTopPerformersBySection,
        selectedCategoryTabBySection: selectedTabs,
        visibleMembersBySection: _applyAllFilters(
          membersBySection: membersBySection,
          query: state.searchQuery,
          filter: state.selectedFilter,
          selectedTabs: selectedTabs,
        ),
        isLoading: false,
        clearError: true,
      ),
    );
  }

  void _onSearchChanged(TeamMembersSearchChanged event, Emitter<TeamMembersState> emit) {
    final query = event.query.trim();
    emit(
      state.copyWith(
        searchQuery: query,
        visibleMembersBySection: _applyAllFilters(
          membersBySection: state.membersBySection,
          query: query,
          filter: state.selectedFilter,
          selectedTabs: state.selectedCategoryTabBySection,
        ),
      ),
    );
  }

  void _onFilterChanged(TeamMembersFilterChanged event, Emitter<TeamMembersState> emit) {
    emit(
      state.copyWith(
        selectedFilter: event.filter,
        visibleMembersBySection: _applyAllFilters(
          membersBySection: state.membersBySection,
          query: state.searchQuery,
          filter: event.filter,
          selectedTabs: state.selectedCategoryTabBySection,
        ),
      ),
    );
  }

  void _onSortFilterTapped(
    TeamMembersSortFilterTapped event,
    Emitter<TeamMembersState> emit,
  ) {
    // Reserved for sort/filter options panel integration.
  }

  void _onCategoryTabChanged(TeamCategoryTabChanged event, Emitter<TeamMembersState> emit) {
    if (event.section == TeamSection.admin) return;
    final selectedTabs = Map<TeamSection, TeamCategoryTab>.from(
      state.selectedCategoryTabBySection,
    )..[event.section] = event.tab;
    emit(
      state.copyWith(
        selectedCategoryTabBySection: selectedTabs,
        visibleMembersBySection: _applyAllFilters(
          membersBySection: state.membersBySection,
          query: state.searchQuery,
          filter: state.selectedFilter,
          selectedTabs: selectedTabs,
        ),
      ),
    );
  }

  void _onEditTapped(TeamMemberEditTapped event, Emitter<TeamMembersState> emit) {
    // Reserved for edit-member flow integration.
  }

  void _onDeleteTapped(TeamMemberDeleteTapped event, Emitter<TeamMembersState> emit) {
    // Reserved for delete-member confirmation + API integration.
  }

  Map<TeamSection, List<TeamMemberUiModel>> _applyAllFilters({
    required Map<TeamSection, List<TeamMemberUiModel>> membersBySection,
    required String query,
    required MemberStatusFilter filter,
    required Map<TeamSection, TeamCategoryTab> selectedTabs,
  }) {
    final output = <TeamSection, List<TeamMemberUiModel>>{};
    for (final section in TeamSection.values) {
      final sourceMembers = membersBySection[section] ?? const [];
      output[section] = _applyFilterAndSearchForSection(
        section: section,
        members: sourceMembers,
        query: query,
        filter: filter,
        categoryTab: selectedTabs[section] ?? TeamCategoryTab.all,
      );
    }
    return output;
  }

  List<TeamMemberUiModel> _applyFilterAndSearchForSection({
    required TeamSection section,
    required List<TeamMemberUiModel> members,
    required String query,
    required MemberStatusFilter filter,
    required TeamCategoryTab categoryTab,
  }) {
    final normalizedQuery = query.toLowerCase();
    return members.where((member) {
      final matchesFilter = section == TeamSection.admin
          ? switch (filter) {
              MemberStatusFilter.all => true,
              MemberStatusFilter.online => member.status == TeamMemberStatus.online,
              MemberStatusFilter.idle => member.status == TeamMemberStatus.idle,
              MemberStatusFilter.offline => member.status == TeamMemberStatus.offline,
            }
          : true;
      final normalizedDepartment = member.department.toLowerCase();
      final matchesCategory = section == TeamSection.admin || categoryTab == TeamCategoryTab.all
          ? true
          : normalizedDepartment.contains(categoryTab.label.toLowerCase());
      final matchesQuery = normalizedQuery.isEmpty ||
          member.name.toLowerCase().contains(normalizedQuery) ||
          member.email.toLowerCase().contains(normalizedQuery) ||
          normalizedDepartment.contains(normalizedQuery);
      return matchesFilter && matchesCategory && matchesQuery;
    }).toList();
  }
}

final Map<TeamSection, List<TeamMemberUiModel>> _seedMembersBySection = {
  TeamSection.admin: const [
    TeamMemberUiModel(
      id: 'a1',
      name: 'Harik Kheruchiya',
      doj: '17/12/2025',
      email: 'harik.kheruchiya@kheruchiya.com',
      status: TeamMemberStatus.online,
    ),
    TeamMemberUiModel(
      id: 'a2',
      name: 'Katha Raval',
      doj: '17/12/2025',
      email: 'katha.raval@kheruchiya.com',
      status: TeamMemberStatus.offline,
    ),
    TeamMemberUiModel(
      id: 'a3',
      name: 'Meet Raval',
      doj: '17/12/2025',
      email: 'meet.raval@kheruchiya.com',
      status: TeamMemberStatus.idle,
    ),
  ],
  TeamSection.sales: _sharedTeamMembers,
  TeamSection.purchase: _sharedTeamMembers,
  TeamSection.accounts: _sharedTeamMembers,
};

const List<TeamMemberUiModel> _sharedTeamMembers = [
  TeamMemberUiModel(
    id: 's1',
    name: 'Goldie Bumrah',
    doj: '17/12/2025',
    email: 'goldie.bumrah@kheruchiya.com',
    status: TeamMemberStatus.online,
    department: 'Visa',
  ),
  TeamMemberUiModel(
    id: 's2',
    name: 'Hootiya Singh',
    doj: '17/12/2025',
    email: 'hootiya.singh@kheruchiya.com',
    status: TeamMemberStatus.offline,
    department: 'Forex',
  ),
  TeamMemberUiModel(
    id: 's3',
    name: 'Tejpal Samosa',
    doj: '17/12/2025',
    email: 'tejpal.samosa@kheruchiya.com',
    status: TeamMemberStatus.online,
    department: 'Holiday',
  ),
  TeamMemberUiModel(
    id: 's4',
    name: 'Moong Dal',
    doj: '17/12/2025',
    email: 'moong.dal@kheruchiya.com',
    status: TeamMemberStatus.idle,
    department: 'Hotel',
  ),
  TeamMemberUiModel(
    id: 's5',
    name: 'Kheer Puri',
    doj: '17/12/2025',
    email: 'kheer.puri@kheruchiya.com',
    status: TeamMemberStatus.offline,
    department: 'Flight',
  ),
];

final Map<TeamSection, List<TopPerformerUiModel>> _seedTopPerformersBySection = {
  TeamSection.sales: const [
    TopPerformerUiModel(name: 'Goldie Bumrah', team: 'Visa'),
    TopPerformerUiModel(name: 'Hootiya Singh', team: 'Forex'),
    TopPerformerUiModel(name: 'Tejpal Samosa', team: 'Holiday'),
    TopPerformerUiModel(name: 'Moong Dal', team: 'Hotel'),
    TopPerformerUiModel(name: 'Kheer Puri', team: 'Flight'),
  ],
  TeamSection.purchase: const [
    TopPerformerUiModel(name: 'Goldie Bumrah', team: 'Visa'),
    TopPerformerUiModel(name: 'Hootiya Singh', team: 'Forex'),
    TopPerformerUiModel(name: 'Tejpal Samosa', team: 'Holiday'),
    TopPerformerUiModel(name: 'Moong Dal', team: 'Hotel'),
    TopPerformerUiModel(name: 'Kheer Puri', team: 'Flight'),
  ],
  TeamSection.accounts: const [
    TopPerformerUiModel(name: 'Goldie Bumrah', team: 'Visa'),
    TopPerformerUiModel(name: 'Hootiya Singh', team: 'Forex'),
    TopPerformerUiModel(name: 'Tejpal Samosa', team: 'Holiday'),
    TopPerformerUiModel(name: 'Moong Dal', team: 'Hotel'),
    TopPerformerUiModel(name: 'Kheer Puri', team: 'Flight'),
  ],
};
