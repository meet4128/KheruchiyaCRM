import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/role_summary_panel.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_members_table.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_section_tabs.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/top_performer_card.dart';

class TeamSectionBlock extends StatelessWidget {
  const TeamSectionBlock({
    super.key,
    required this.section,
    required this.description,
    required this.showStatusColumn,
    required this.showTopPerformers,
    required this.showTabs,
    this.onMemberEdit,
  });

  final TeamSection section;
  final String description;
  final bool showStatusColumn;
  final bool showTopPerformers;
  final bool showTabs;

  /// Opens add/edit member UI for an existing member id (PATCH flow).
  final void Function(String memberId)? onMemberEdit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamMembersBloc, TeamMembersState>(
      builder: (context, state) {
        final members = state.visibleMembersBySection[section] ?? const [];
        final performers = state.topPerformersBySection[section] ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: TextStyle(
                color: AppColors.dark().textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      RoleSummaryPanel(
                        title: section.roleLabel,
                        memberCount: members.length,
                        description: description,
                      ),
                      if (showTopPerformers) ...[
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '5 Top Performer',
                            style: TextStyle(
                              color: AppColors.dark().textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TopPerformerCard(performers: performers.take(5).toList()),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showTabs) ...[
                        TeamSectionTabs(section: section),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '${section.roleLabel} Members',
                              style: TextStyle(
                                color: AppColors.dark().textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${members.length} Members',
                              style: TextStyle(
                                color: AppColors.dark().textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      TeamMembersTable(
                        members: members,
                        showStatus: showStatusColumn,
                        showDepartment: !showStatusColumn,
                        onEdit: (memberId) {
                          context.read<TeamMembersBloc>().add(TeamMemberEditTapped(memberId));
                          onMemberEdit?.call(memberId);
                        },
                        onDelete: (memberId) {
                          context.read<TeamMembersBloc>().add(TeamMemberDeleteTapped(memberId));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
