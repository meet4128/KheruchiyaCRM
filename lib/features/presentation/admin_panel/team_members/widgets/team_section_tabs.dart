import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';

class TeamSectionTabs extends StatelessWidget {
  const TeamSectionTabs({super.key, required this.section});

  final TeamSection section;

  static const _tabs = [
    TeamCategoryTab.all,
    TeamCategoryTab.flight,
    TeamCategoryTab.hotel,
    TeamCategoryTab.holiday,
    TeamCategoryTab.visa,
    TeamCategoryTab.passport,
    TeamCategoryTab.travelInsurance,
    TeamCategoryTab.forex,
    TeamCategoryTab.transfer,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamMembersBloc, TeamMembersState>(
      buildWhen: (previous, current) =>
          previous.selectedCategoryTabBySection != current.selectedCategoryTabBySection,
      builder: (context, state) {
        final selectedTab =
            state.selectedCategoryTabBySection[section] ?? TeamCategoryTab.all;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tabs.map((tab) {
            final selected = tab == selectedTab;
            return InkWell(
              onTap: () {
                context.read<TeamMembersBloc>().add(
                      TeamCategoryTabChanged(section: section, tab: tab),
                    );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.dark().secondary.withValues(alpha: 0.22)
                      : AppColors.dark().backgroundMedium,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? AppColors.dark().secondary
                        : AppColors.dark().borderPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  tab.label,
                  style: TextStyle(
                    color: selected ? AppColors.dark().textPrimary : AppColors.dark().textSecondary,
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
