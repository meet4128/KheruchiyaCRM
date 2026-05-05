import 'package:equatable/equatable.dart';

import 'team_members_state.dart';

abstract class TeamMembersEvent extends Equatable {
  const TeamMembersEvent();

  @override
  List<Object?> get props => [];
}

class TeamMembersFetched extends TeamMembersEvent {
  const TeamMembersFetched();
}

class TeamMembersSearchChanged extends TeamMembersEvent {
  const TeamMembersSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class TeamMembersFilterChanged extends TeamMembersEvent {
  const TeamMembersFilterChanged(this.filter);

  final MemberStatusFilter filter;

  @override
  List<Object?> get props => [filter];
}

class TeamMembersSortFilterTapped extends TeamMembersEvent {
  const TeamMembersSortFilterTapped();
}

class TeamMembersEmploymentStatusChanged extends TeamMembersEvent {
  const TeamMembersEmploymentStatusChanged(this.filter);

  final EmploymentStatusFilter filter;

  @override
  List<Object?> get props => [filter];
}

class TeamMembersLoadMoreRequested extends TeamMembersEvent {
  const TeamMembersLoadMoreRequested();
}

class TeamCategoryTabChanged extends TeamMembersEvent {
  const TeamCategoryTabChanged({
    required this.section,
    required this.tab,
  });

  final TeamSection section;
  final TeamCategoryTab tab;

  @override
  List<Object?> get props => [section, tab];
}

class TeamMemberEditTapped extends TeamMembersEvent {
  const TeamMemberEditTapped(this.memberId);

  final String memberId;

  @override
  List<Object?> get props => [memberId];
}

class TeamMemberDeleteTapped extends TeamMembersEvent {
  const TeamMemberDeleteTapped(this.memberId);

  final String memberId;

  @override
  List<Object?> get props => [memberId];
}

/// New member saved from the add-member wizard (session-only until API list exists).
class TeamMemberAdded extends TeamMembersEvent {
  const TeamMemberAdded({required this.member, required this.sections});

  final TeamMemberUiModel member;
  final Set<TeamSection> sections;

  @override
  List<Object?> get props => [member, sections];
}

/// Existing member updated from the wizard; [sections] is where they should appear after save.
class TeamMemberUpdated extends TeamMembersEvent {
  const TeamMemberUpdated({
    required this.memberId,
    required this.updated,
    required this.sections,
  });

  final String memberId;
  final TeamMemberUiModel updated;
  final Set<TeamSection> sections;

  @override
  List<Object?> get props => [memberId, updated, sections];
}
