import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/data/repositories/members_repository.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/view/add_member_dialog.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/helpers/team_member_from_add_member_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_members_filters_bar.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_members_header.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_section_block.dart';

class TeamMembersScreen extends StatelessWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeamMembersBloc(sl<MembersRepository>())..add(const TeamMembersFetched()),
      child: Builder(
        builder: (context) {
          return Container(
            color: AppColors.dark().backgroundDark,
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                TeamMembersHeader(onAddMembersTap: () => _openAddMemberDialog(context, null)),
                SizedBox(height: 18),
                const TeamMembersFiltersBar(),
                BlocBuilder<TeamMembersBloc, TeamMembersState>(
                  buildWhen: (previous, current) =>
                      previous.isLoading != current.isLoading ||
                      previous.errorMessage != current.errorMessage,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      );
                    }
                    if (state.errorMessage == null || state.errorMessage!.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: AppColors.dark().error,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                TeamSectionBlock(
                  section: TeamSection.admin,
                  description:
                      'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
                  showStatusColumn: true,
                  showTopPerformers: false,
                  showTabs: false,
                  onMemberEdit: (id) => _openAddMemberDialog(context, id),
                ),
                const SizedBox(height: 18),
                const _SectionDivider(),
                const SizedBox(height: 18),
                TeamSectionBlock(
                  section: TeamSection.sales,
                  description:
                      'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
                  showStatusColumn: false,
                  showTopPerformers: true,
                  showTabs: true,
                  onMemberEdit: (id) => _openAddMemberDialog(context, id),
                ),
                const SizedBox(height: 18),
                const _SectionDivider(),
                const SizedBox(height: 18),
                TeamSectionBlock(
                  section: TeamSection.purchase,
                  description:
                      'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
                  showStatusColumn: false,
                  showTopPerformers: true,
                  showTabs: true,
                  onMemberEdit: (id) => _openAddMemberDialog(context, id),
                ),
                const SizedBox(height: 18),
                const _SectionDivider(),
                const SizedBox(height: 18),
                TeamSectionBlock(
                  section: TeamSection.accounts,
                  description:
                      'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
                  showStatusColumn: false,
                  showTopPerformers: true,
                  showTabs: true,
                  onMemberEdit: (id) => _openAddMemberDialog(context, id),
                ),
                const SizedBox(height: 10),
                BlocBuilder<TeamMembersBloc, TeamMembersState>(
                  buildWhen: (previous, current) =>
                      previous.isLoadingMore != current.isLoadingMore ||
                      previous.currentPage != current.currentPage ||
                      previous.totalPages != current.totalPages,
                  builder: (context, state) {
                    if (!state.hasMorePages) {
                      return const SizedBox.shrink();
                    }
                    return Align(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        onPressed: state.isLoadingMore
                            ? null
                            : () {
                                context.read<TeamMembersBloc>().add(
                                      const TeamMembersLoadMoreRequested(),
                                    );
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.dark().textSecondary,
                          side: BorderSide(
                            color: AppColors.dark().borderPrimary.withValues(alpha: 0.45),
                          ),
                        ),
                        child: state.isLoadingMore
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('Load More (${state.currentPage}/${state.totalPages})'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddMemberDialog(BuildContext context, String? editingMemberId) async {
    final teamMembersBloc = context.read<TeamMembersBloc>();
    String? prefillName;
    String? prefillEmail;
    if (editingMemberId != null) {
      for (final list in teamMembersBloc.state.membersBySection.values) {
        for (final m in list) {
          if (m.id == editingMemberId) {
            prefillName = m.name;
            prefillEmail = m.email;
            break;
          }
        }
      }
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider(
          create: (_) => AddMemberBloc(sl<MembersRepository>())
            ..add(
              editingMemberId == null
                  ? const AddMemberDialogOpened()
                  : AddMemberDialogOpened(
                      editingMemberId: editingMemberId,
                      prefillFullName: prefillName,
                      prefillPersonalEmail: prefillEmail,
                    ),
            ),
          child: AddMemberDialog(
            onMemberSaved: (addState) {
              final sections = teamSectionsFromRoleRows(addState.roleRows);
              if (addState.editingMemberId != null) {
                teamMembersBloc.add(
                  TeamMemberUpdated(
                    memberId: addState.editingMemberId!,
                    updated: teamMemberUiModelForUpdatedMember(
                      addState,
                      addState.editingMemberId!,
                    ),
                    sections: sections,
                  ),
                );
              } else {
                teamMembersBloc.add(
                  TeamMemberAdded(
                    member: teamMemberUiModelForNewMember(addState),
                    sections: sections,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.dark().borderPrimary.withValues(alpha: 0.35),
      height: 1,
    );
  }
}
