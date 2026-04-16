import 'package:flutter_bloc/flutter_bloc.dart';

import 'team_members_event.dart';
import 'team_members_state.dart';

class TeamMembersBloc extends Bloc<TeamMembersEvent, TeamMembersState> {
  TeamMembersBloc() : super(const TeamMembersState()) {
    on<TeamMembersFetched>(_onFetched);
    on<TeamMembersSearchChanged>(_onSearchChanged);
    on<TeamMembersFilterChanged>(_onFilterChanged);
    on<TeamMembersSortFilterTapped>(_onSortFilterTapped);
    on<TeamMemberEditTapped>(_onEditTapped);
    on<TeamMemberDeleteTapped>(_onDeleteTapped);
  }

  void _onFetched(TeamMembersFetched event, Emitter<TeamMembersState> emit) {
    final seed = _seedMembers;
    emit(
      state.copyWith(
        allMembers: seed,
        visibleMembers: _applyFilterAndSearch(
          members: seed,
          query: state.searchQuery,
          filter: state.selectedFilter,
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
        visibleMembers: _applyFilterAndSearch(
          members: state.allMembers,
          query: query,
          filter: state.selectedFilter,
        ),
      ),
    );
  }

  void _onFilterChanged(TeamMembersFilterChanged event, Emitter<TeamMembersState> emit) {
    emit(
      state.copyWith(
        selectedFilter: event.filter,
        visibleMembers: _applyFilterAndSearch(
          members: state.allMembers,
          query: state.searchQuery,
          filter: event.filter,
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

  void _onEditTapped(TeamMemberEditTapped event, Emitter<TeamMembersState> emit) {
    // Reserved for edit-member flow integration.
  }

  void _onDeleteTapped(TeamMemberDeleteTapped event, Emitter<TeamMembersState> emit) {
    // Reserved for delete-member confirmation + API integration.
  }

  List<TeamMemberUiModel> _applyFilterAndSearch({
    required List<TeamMemberUiModel> members,
    required String query,
    required MemberStatusFilter filter,
  }) {
    final normalizedQuery = query.toLowerCase();
    return members.where((member) {
      final matchesFilter = switch (filter) {
        MemberStatusFilter.all => true,
        MemberStatusFilter.online => member.status == TeamMemberStatus.online,
        MemberStatusFilter.idle => member.status == TeamMemberStatus.idle,
        MemberStatusFilter.offline => member.status == TeamMemberStatus.offline,
      };
      final matchesQuery = normalizedQuery.isEmpty ||
          member.name.toLowerCase().contains(normalizedQuery) ||
          member.email.toLowerCase().contains(normalizedQuery);
      return matchesFilter && matchesQuery;
    }).toList();
  }
}

const List<TeamMemberUiModel> _seedMembers = [
  TeamMemberUiModel(
    id: '1',
    name: 'Harik Kheruchiya',
    doj: '17/12/2025',
    email: 'harik.kheruchiya@kheruchiya.com',
    status: TeamMemberStatus.online,
  ),
  TeamMemberUiModel(
    id: '2',
    name: 'Katha Raval',
    doj: '17/12/2025',
    email: 'harik.kheruchiya@kheruchiya.com',
    status: TeamMemberStatus.offline,
  ),
  TeamMemberUiModel(
    id: '3',
    name: 'Meet Raval',
    doj: '17/12/2025',
    email: 'harik.kheruchiya@kheruchiya.com',
    status: TeamMemberStatus.idle,
  ),
];
