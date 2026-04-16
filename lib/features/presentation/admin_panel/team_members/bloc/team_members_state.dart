import 'package:equatable/equatable.dart';

enum MemberStatusFilter { all, online, idle, offline }

enum TeamMemberStatus { online, idle, offline }

class TeamMemberUiModel extends Equatable {
  const TeamMemberUiModel({
    required this.id,
    required this.name,
    required this.doj,
    required this.email,
    required this.status,
  });

  final String id;
  final String name;
  final String doj;
  final String email;
  final TeamMemberStatus status;

  @override
  List<Object?> get props => [id, name, doj, email, status];
}

class TeamMembersState extends Equatable {
  const TeamMembersState({
    this.allMembers = const [],
    this.visibleMembers = const [],
    this.searchQuery = '',
    this.selectedFilter = MemberStatusFilter.all,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<TeamMemberUiModel> allMembers;
  final List<TeamMemberUiModel> visibleMembers;
  final String searchQuery;
  final MemberStatusFilter selectedFilter;
  final bool isLoading;
  final String? errorMessage;

  TeamMembersState copyWith({
    List<TeamMemberUiModel>? allMembers,
    List<TeamMemberUiModel>? visibleMembers,
    String? searchQuery,
    MemberStatusFilter? selectedFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeamMembersState(
      allMembers: allMembers ?? this.allMembers,
      visibleMembers: visibleMembers ?? this.visibleMembers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        allMembers,
        visibleMembers,
        searchQuery,
        selectedFilter,
        isLoading,
        errorMessage,
      ];
}
