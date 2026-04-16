import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_members_filters_bar.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_members_header.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_section_block.dart';

class TeamMembersScreen extends StatelessWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeamMembersBloc()..add(const TeamMembersFetched()),
      child: Container(
        color: AppColors.dark().backgroundDark,
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: const [
            TeamMembersHeader(),
            SizedBox(height: 18),
            TeamMembersFiltersBar(),
            SizedBox(height: 18),
            TeamSectionBlock(
              section: TeamSection.admin,
              description:
                  'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
              showStatusColumn: true,
              showTopPerformers: false,
              showTabs: false,
            ),
            SizedBox(height: 18),
            _SectionDivider(),
            SizedBox(height: 18),
            TeamSectionBlock(
              section: TeamSection.sales,
              description:
                  'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
              showStatusColumn: false,
              showTopPerformers: true,
              showTabs: true,
            ),
            SizedBox(height: 18),
            _SectionDivider(),
            SizedBox(height: 18),
            TeamSectionBlock(
              section: TeamSection.purchase,
              description:
                  'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
              showStatusColumn: false,
              showTopPerformers: true,
              showTabs: true,
            ),
            SizedBox(height: 18),
            _SectionDivider(),
            SizedBox(height: 18),
            TeamSectionBlock(
              section: TeamSection.accounts,
              description:
                  'Manage user accounts, permissions, and access levels within the app to ensure smooth operation and security.',
              showStatusColumn: false,
              showTopPerformers: true,
              showTabs: true,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
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
