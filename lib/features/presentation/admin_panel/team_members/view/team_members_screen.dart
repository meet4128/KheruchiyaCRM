import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/role_summary_panel.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_members_filters_bar.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_members_header.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_members_table.dart';

class TeamMembersScreen extends StatelessWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeamMembersBloc()..add(const TeamMembersFetched()),
      child: Container(
        color: AppColors.dark().backgroundDark,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TeamMembersHeader(),
            const SizedBox(height: 18),
            const TeamMembersFiltersBar(),
            const SizedBox(height: 18),
            Expanded(
              child: BlocBuilder<TeamMembersBloc, TeamMembersState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: RoleSummaryPanel(memberCount: state.visibleMembers.length),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: TeamMembersTable()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
