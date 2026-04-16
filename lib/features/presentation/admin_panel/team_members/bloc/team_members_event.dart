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
