import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';
import 'package:travel_crm/data/repositories/members_repository.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/helpers/team_member_from_api.dart';

import 'team_members_event.dart';
import 'team_members_state.dart';

class TeamMembersBloc extends Bloc<TeamMembersEvent, TeamMembersState> {
  TeamMembersBloc(this._membersRepository) : super(const TeamMembersState()) {
    on<TeamMembersFetched>(_onFetched);
    on<TeamMembersSearchChanged>(_onSearchChanged);
    on<TeamMembersFilterChanged>(_onFilterChanged);
    on<TeamMembersSortFilterTapped>(_onSortFilterTapped);
    on<TeamMembersEmploymentStatusChanged>(_onEmploymentStatusChanged);
    on<TeamMembersLoadMoreRequested>(_onLoadMoreRequested);
    on<TeamCategoryTabChanged>(_onCategoryTabChanged);
    on<TeamMemberAdded>(_onMemberAdded);
    on<TeamMemberUpdated>(_onMemberUpdated);
    on<TeamMemberResendInviteRequested>(_onResendInviteRequested);
    on<TeamMembersResendInviteConsumed>(_onResendInviteConsumed);
    on<TeamMemberDeleteConfirmed>(_onDeleteConfirmed);
    on<TeamMembersDeleteResultConsumed>(_onDeleteResultConsumed);
  }

  final MembersRepository _membersRepository;

  /// Members created this session (merged on top of fetched data).
  final List<TeamMemberSessionAdd> _sessionAdds = [];
  Map<TeamSection, List<TeamMemberUiModel>> _fetchedMembersBySection = _emptyMembersBySection();

  Future<void> _onFetched(TeamMembersFetched event, Emitter<TeamMembersState> emit) async {
    await _fetchPage(
      emit: emit,
      page: 1,
      replace: true,
      selectedTabsFallback: const {
        TeamSection.sales: TeamCategoryTab.all,
        TeamSection.purchase: TeamCategoryTab.all,
        TeamSection.accounts: TeamCategoryTab.all,
      },
    );
  }

  Future<void> _fetchPage({
    required Emitter<TeamMembersState> emit,
    required int page,
    required bool replace,
    Map<TeamSection, TeamCategoryTab>? selectedTabsFallback,
  }) async {
    final selectedTabs = <TeamSection, TeamCategoryTab>{
      TeamSection.sales: state.selectedCategoryTabBySection[TeamSection.sales] ?? TeamCategoryTab.all,
      TeamSection.purchase:
          state.selectedCategoryTabBySection[TeamSection.purchase] ?? TeamCategoryTab.all,
      TeamSection.accounts:
          state.selectedCategoryTabBySection[TeamSection.accounts] ?? TeamCategoryTab.all,
      ...?selectedTabsFallback,
    };
    emit(
      state.copyWith(
        isLoading: replace,
        isLoadingMore: !replace,
        clearError: true,
      ),
    );

    try {
      final response = await _membersRepository.listMembers(
        page: page,
        employmentStatus: _employmentStatusQueryValue(state.employmentStatusFilter),
      );
      final fetchedPageMembers = _groupMembersBySection(response.data.items);
      if (replace) {
        _fetchedMembersBySection = fetchedPageMembers;
      } else {
        _fetchedMembersBySection = _mergeSections(_fetchedMembersBySection, fetchedPageMembers);
      }
      final membersBySection = _mergeFromFetchedAndAdds();
      final membersById = _buildMembersById(
        state.membersById,
        response.data.items,
        replace: replace,
      );
      emit(
        state.copyWith(
          membersBySection: membersBySection,
          topPerformersBySection: _topPerformersFromMembers(membersBySection),
          selectedCategoryTabBySection: selectedTabs,
          visibleMembersBySection: _applyAllFilters(
            membersBySection: membersBySection,
            query: state.searchQuery,
            filter: state.selectedFilter,
            selectedTabs: selectedTabs,
          ),
          currentPage: response.data.page,
          totalPages: response.data.totalPages,
          isLoading: false,
          isLoadingMore: false,
          clearError: true,
          membersById: membersById,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onMemberAdded(TeamMemberAdded event, Emitter<TeamMembersState> emit) {
    _sessionAdds.add(TeamMemberSessionAdd(sections: event.sections, member: event.member));
    final membersBySection = _mergeFromFetchedAndAdds();
    emit(
      state.copyWith(
        membersBySection: membersBySection,
        topPerformersBySection: _topPerformersFromMembers(membersBySection),
        visibleMembersBySection: _applyAllFilters(
          membersBySection: membersBySection,
          query: state.searchQuery,
          filter: state.selectedFilter,
          selectedTabs: state.selectedCategoryTabBySection,
        ),
      ),
    );
  }

  void _onMemberUpdated(TeamMemberUpdated event, Emitter<TeamMembersState> emit) {
    final id = event.memberId;
    final model = event.updated;
    final targets = event.sections;

    var membersById = Map<String, ListMembersItem>.from(state.membersById);
    final apiMember = event.apiMember;
    if (apiMember != null) {
      final apiId = (apiMember.id ?? '').trim();
      if (apiId.isNotEmpty) {
        membersById[apiId] = apiMember;
      }
    }

    final sessionIdx = _sessionAdds.indexWhere((a) => a.member.id == id);
    if (sessionIdx >= 0) {
      _sessionAdds[sessionIdx] = TeamMemberSessionAdd(sections: targets, member: model);
      final membersBySection = _mergeFromFetchedAndAdds();
      emit(
        state.copyWith(
          membersBySection: membersBySection,
          topPerformersBySection: _topPerformersFromMembers(membersBySection),
          visibleMembersBySection: _applyAllFilters(
            membersBySection: membersBySection,
            query: state.searchQuery,
            filter: state.selectedFilter,
            selectedTabs: state.selectedCategoryTabBySection,
          ),
          membersById: membersById,
        ),
      );
      return;
    }

    final next = <TeamSection, List<TeamMemberUiModel>>{};
    final nextFetched = <TeamSection, List<TeamMemberUiModel>>{};
    for (final section in TeamSection.values) {
      final list = List<TeamMemberUiModel>.from(state.membersBySection[section] ?? const []);
      list.removeWhere((m) => m.id == id);
      if (targets.contains(section)) {
        list.add(model);
      }
      next[section] = list;

      final fetchedList = List<TeamMemberUiModel>.from(_fetchedMembersBySection[section] ?? const []);
      fetchedList.removeWhere((m) => m.id == id);
      if (targets.contains(section)) {
        fetchedList.add(model);
      }
      nextFetched[section] = fetchedList;
    }
    _fetchedMembersBySection = nextFetched;
    emit(
      state.copyWith(
        membersBySection: next,
        topPerformersBySection: _topPerformersFromMembers(next),
        visibleMembersBySection: _applyAllFilters(
          membersBySection: next,
          query: state.searchQuery,
          filter: state.selectedFilter,
          selectedTabs: state.selectedCategoryTabBySection,
        ),
        membersById: membersById,
      ),
    );
  }

  Future<void> _onDeleteConfirmed(
    TeamMemberDeleteConfirmed event,
    Emitter<TeamMembersState> emit,
  ) async {
    final memberId = event.memberId.trim();
    if (memberId.isEmpty || memberId.startsWith('m_')) {
      emit(
        state.copyWith(
          deleteResult: TeamMembersDeleteResult(
            memberId: memberId,
            success: false,
            message: StringConstant.teamMembersDeleteFailedMessage,
          ),
        ),
      );
      return;
    }
    if (state.deletingMemberIds.contains(memberId)) return;

    emit(
      state.copyWith(
        deletingMemberIds: {...state.deletingMemberIds, memberId},
        clearDeleteResult: true,
      ),
    );

    try {
      await _membersRepository.deleteMember(memberId);
      if (isClosed) return;

      _sessionAdds.removeWhere((a) => a.member.id == memberId);
      _fetchedMembersBySection = _removeMemberFromSections(
        _fetchedMembersBySection,
        memberId,
      );

      final membersById = Map<String, ListMembersItem>.from(state.membersById)
        ..remove(memberId);

      final membersBySection = _mergeFromFetchedAndAdds();
      emit(
        state.copyWith(
          membersBySection: membersBySection,
          topPerformersBySection: _topPerformersFromMembers(membersBySection),
          visibleMembersBySection: _applyAllFilters(
            membersBySection: membersBySection,
            query: state.searchQuery,
            filter: state.selectedFilter,
            selectedTabs: state.selectedCategoryTabBySection,
          ),
          membersById: membersById,
          deletingMemberIds: _withoutId(state.deletingMemberIds, memberId),
          deleteResult: TeamMembersDeleteResult(
            memberId: memberId,
            success: true,
            message: StringConstant.teamMembersDeleteSuccessMessage,
          ),
        ),
      );
    } on MembersNotFoundException catch (_) {
      if (isClosed) return;
      emit(_deleteFailureState(memberId, StringConstant.teamMembersDeleteFailedMessage));
    } on MembersUnauthorizedException catch (e) {
      if (isClosed) return;
      emit(_deleteFailureState(memberId, e.toString()));
    } on MembersApiException catch (e) {
      if (isClosed) return;
      emit(_deleteFailureState(memberId, e.message));
    } catch (_) {
      if (isClosed) return;
      emit(_deleteFailureState(memberId, StringConstant.teamMembersDeleteFailedMessage));
    }
  }

  void _onDeleteResultConsumed(
    TeamMembersDeleteResultConsumed event,
    Emitter<TeamMembersState> emit,
  ) {
    if (state.deleteResult == null) return;
    emit(state.copyWith(clearDeleteResult: true));
  }

  TeamMembersState _deleteFailureState(String memberId, String? message) {
    return state.copyWith(
      deletingMemberIds: _withoutId(state.deletingMemberIds, memberId),
      deleteResult: TeamMembersDeleteResult(
        memberId: memberId,
        success: false,
        message: (message?.trim().isNotEmpty ?? false)
            ? message!.trim()
            : StringConstant.teamMembersDeleteFailedMessage,
      ),
    );
  }

  Map<TeamSection, List<TeamMemberUiModel>> _removeMemberFromSections(
    Map<TeamSection, List<TeamMemberUiModel>> source,
    String memberId,
  ) {
    final out = <TeamSection, List<TeamMemberUiModel>>{};
    for (final entry in source.entries) {
      out[entry.key] =
          entry.value.where((m) => m.id != memberId).toList(growable: false);
    }
    return out;
  }

  Map<String, ListMembersItem> _buildMembersById(
    Map<String, ListMembersItem> existing,
    List<ListMembersItem> items, {
    required bool replace,
  }) {
    final out = replace ? <String, ListMembersItem>{} : Map<String, ListMembersItem>.from(existing);
    for (final item in items) {
      final id = (item.id ?? '').trim();
      if (id.isNotEmpty) {
        out[id] = item;
      }
    }
    return out;
  }

  Map<TeamSection, List<TeamMemberUiModel>> _mergeFromFetchedAndAdds() {
    final out = <TeamSection, List<TeamMemberUiModel>>{
      for (final e in _fetchedMembersBySection.entries) e.key: List<TeamMemberUiModel>.from(e.value),
    };
    for (final add in _sessionAdds) {
      for (final s in add.sections) {
        (out[s] ??= []).add(add.member);
      }
    }
    return out;
  }

  Map<TeamSection, List<TeamMemberUiModel>> _groupMembersBySection(List<ListMembersItem> items) {
    final out = _emptyMembersBySection();
    for (final item in items) {
      final departmentRoles = extractDepartmentRoles(item);
      final sections = teamSectionsFromDepartmentRoles(departmentRoles);
      if (sections.isEmpty) {
        continue;
      }
      final departmentLabel = formatDepartmentRoleDisplay(departmentRoles);
      final ui = teamMemberUiModelFromApi(item, department: departmentLabel);
      for (final section in sections) {
        out[section]!.add(ui);
      }
    }
    return out;
  }

  Map<TeamSection, List<TopPerformerUiModel>> _topPerformersFromMembers(
    Map<TeamSection, List<TeamMemberUiModel>> membersBySection,
  ) {
    final output = <TeamSection, List<TopPerformerUiModel>>{};
    for (final section in [TeamSection.sales, TeamSection.purchase, TeamSection.accounts]) {
      output[section] = membersBySection[section]
              ?.take(5)
              .map(
                (member) => TopPerformerUiModel(
                  name: member.name,
                  team: member.department.isEmpty ? section.roleLabel : member.department,
                ),
              )
              .toList() ??
          const [];
    }
    return output;
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

  Future<void> _onEmploymentStatusChanged(
    TeamMembersEmploymentStatusChanged event,
    Emitter<TeamMembersState> emit,
  ) async {
    if (event.filter == state.employmentStatusFilter) {
      return;
    }
    emit(state.copyWith(employmentStatusFilter: event.filter));
    await _fetchPage(emit: emit, page: 1, replace: true);
  }

  Future<void> _onLoadMoreRequested(
    TeamMembersLoadMoreRequested event,
    Emitter<TeamMembersState> emit,
  ) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMorePages) {
      return;
    }
    await _fetchPage(
      emit: emit,
      page: state.currentPage + 1,
      replace: false,
    );
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

  Future<void> _onResendInviteRequested(
    TeamMemberResendInviteRequested event,
    Emitter<TeamMembersState> emit,
  ) async {
    final memberId = event.memberId.trim();
    if (memberId.isEmpty || memberId.startsWith('m_')) {
      emit(
        state.copyWith(
          resendInviteResult: TeamMembersResendInviteResult(
            memberId: memberId,
            success: false,
            message: StringConstant.teamMembersInviteResendFailed,
          ),
        ),
      );
      return;
    }
    if (state.resendingMemberIds.contains(memberId)) {
      // Already in flight — ignore double taps.
      return;
    }
    emit(
      state.copyWith(
        resendingMemberIds: {...state.resendingMemberIds, memberId},
        clearResendInviteResult: true,
      ),
    );

    try {
      final response = await _membersRepository.resendInvite(memberId);
      if (isClosed) return;
      // Stamp the row as pending again with the updated invite-sent timestamp
      // so the UI shows the fresh "pending" pill + the next 72h window.
      final refreshed = _withRefreshedInviteStamp(memberId, response.data.member);
      emit(
        state.copyWith(
          membersBySection: refreshed,
          visibleMembersBySection: _applyAllFilters(
            membersBySection: refreshed,
            query: state.searchQuery,
            filter: state.selectedFilter,
            selectedTabs: state.selectedCategoryTabBySection,
          ),
          resendingMemberIds: _withoutId(state.resendingMemberIds, memberId),
          resendInviteResult: TeamMembersResendInviteResult(
            memberId: memberId,
            success: true,
            sentTo: response.data.invite.sentTo,
            message: StringConstant.teamMembersInviteResentMessage,
          ),
        ),
      );
    } on MembersAlreadyActiveException catch (_) {
      if (isClosed) return;
      emit(_failureState(memberId, StringConstant.teamMembersInviteAlreadyActive));
    } on MembersRateLimitedException catch (_) {
      if (isClosed) return;
      emit(_failureState(memberId, StringConstant.teamMembersInviteResendRateLimit));
    } on MembersNotFoundException catch (_) {
      if (isClosed) return;
      emit(_failureState(
        memberId,
        StringConstant.teamMembersInviteResendFailed,
      ));
    } on MembersUnauthorizedException catch (e) {
      if (isClosed) return;
      emit(_failureState(memberId, e.toString()));
    } on MembersApiException catch (e) {
      if (isClosed) return;
      emit(_failureState(memberId, e.message));
    } catch (e) {
      if (isClosed) return;
      emit(_failureState(memberId, StringConstant.teamMembersInviteResendFailed));
    }
  }

  void _onResendInviteConsumed(
    TeamMembersResendInviteConsumed event,
    Emitter<TeamMembersState> emit,
  ) {
    if (state.resendInviteResult == null) return;
    emit(state.copyWith(clearResendInviteResult: true));
  }

  /// Apply a freshly-resent invite stamp to a member id across all sections,
  /// returning the new map. The backend always responds with the updated
  /// member doc — we use that as the source of truth for status / sent-at.
  Map<TeamSection, List<TeamMemberUiModel>> _withRefreshedInviteStamp(
    String memberId,
    ListMembersItem updatedMember,
  ) {
    final refreshedInviteStatus = TeamMemberInvitationStatusX.fromString(
      updatedMember.invitationStatus,
    );
    final refreshedSentAt = _tryParseDate(updatedMember.lastInviteSentAt);
    final out = <TeamSection, List<TeamMemberUiModel>>{};
    for (final entry in state.membersBySection.entries) {
      out[entry.key] = entry.value
          .map((m) => m.id == memberId
              ? m.copyWith(
                  invitationStatus: refreshedInviteStatus,
                  lastInviteSentAt: refreshedSentAt,
                )
              : m)
          .toList();
    }
    return out;
  }

  TeamMembersState _failureState(String memberId, String? message) {
    return state.copyWith(
      resendingMemberIds: _withoutId(state.resendingMemberIds, memberId),
      resendInviteResult: TeamMembersResendInviteResult(
        memberId: memberId,
        success: false,
        message: (message?.trim().isNotEmpty ?? false)
            ? message!.trim()
            : StringConstant.teamMembersInviteResendFailed,
      ),
    );
  }

  Set<String> _withoutId(Set<String> source, String memberId) {
    return source.where((id) => id != memberId).toSet();
  }

  DateTime? _tryParseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
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

/// One member added in-session with the team blocks they belong to.
class TeamMemberSessionAdd {
  TeamMemberSessionAdd({required this.sections, required this.member});

  final Set<TeamSection> sections;
  final TeamMemberUiModel member;
}

Map<TeamSection, List<TeamMemberUiModel>> _emptyMembersBySection() => {
      TeamSection.admin: <TeamMemberUiModel>[],
      TeamSection.sales: <TeamMemberUiModel>[],
      TeamSection.purchase: <TeamMemberUiModel>[],
      TeamSection.accounts: <TeamMemberUiModel>[],
    };

String? _employmentStatusQueryValue(EmploymentStatusFilter filter) {
  switch (filter) {
    case EmploymentStatusFilter.active:
      return 'active';
    case EmploymentStatusFilter.inactive:
      return 'inactive';
    case EmploymentStatusFilter.all:
      return null;
  }
}

Map<TeamSection, List<TeamMemberUiModel>> _mergeSections(
  Map<TeamSection, List<TeamMemberUiModel>> base,
  Map<TeamSection, List<TeamMemberUiModel>> incoming,
) {
  final out = _emptyMembersBySection();
  for (final section in TeamSection.values) {
    final list = <TeamMemberUiModel>[
      ...?base[section],
      ...?incoming[section],
    ];
    final deduped = <String, TeamMemberUiModel>{};
    for (final member in list) {
      deduped[member.id] = member;
    }
    out[section] = deduped.values.toList();
  }
  return out;
}
