import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';

class TeamMembersFiltersBar extends StatelessWidget {
  const TeamMembersFiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              onChanged: (query) {
                context.read<TeamMembersBloc>().add(TeamMembersSearchChanged(query));
              },
              style: TextStyle(color: AppColors.dark().textPrimary),
              decoration: InputDecoration(
                hintText: 'Search members...',
                hintStyle: TextStyle(color: AppColors.dark().textTertiary),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.dark().textTertiary),
                filled: true,
                fillColor: AppColors.dark().backgroundMedium,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.dark().borderPrimary.withValues(alpha: 0.35),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.dark().borderPrimary.withValues(alpha: 0.35),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.dark().secondary),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            context.read<TeamMembersBloc>().add(const TeamMembersSortFilterTapped());
          },
          icon: const Icon(Icons.sort_rounded, size: 16),
          label: const Text('Sort & Filter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.dark().textSecondary,
            side: BorderSide(color: AppColors.dark().borderPrimary.withValues(alpha: 0.45)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          ),
        ),
        const SizedBox(width: 8),
        const _EmploymentStatusDropdown(),
        const SizedBox(width: 8),
        _FilterChipButton(
          filter: MemberStatusFilter.all,
          label: 'All',
        ),
        const SizedBox(width: 8),
        _FilterChipButton(
          filter: MemberStatusFilter.online,
          label: 'Online',
        ),
        const SizedBox(width: 8),
        _FilterChipButton(
          filter: MemberStatusFilter.idle,
          label: 'Idle',
        ),
        const SizedBox(width: 8),
        _FilterChipButton(
          filter: MemberStatusFilter.offline,
          label: 'Offline',
        ),
      ],
    );
  }
}

class _EmploymentStatusDropdown extends StatelessWidget {
  const _EmploymentStatusDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamMembersBloc, TeamMembersState>(
      buildWhen: (previous, current) =>
          previous.employmentStatusFilter != current.employmentStatusFilter ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.dark().backgroundMedium,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.dark().borderPrimary.withValues(alpha: 0.40)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<EmploymentStatusFilter>(
              value: state.employmentStatusFilter,
              dropdownColor: AppColors.dark().backgroundMedium,
              iconEnabledColor: AppColors.dark().textSecondary,
              style: TextStyle(color: AppColors.dark().textSecondary, fontSize: 12),
              onChanged: state.isLoading
                  ? null
                  : (value) {
                      if (value == null) return;
                      context.read<TeamMembersBloc>().add(
                            TeamMembersEmploymentStatusChanged(value),
                          );
                    },
              items: const [
                DropdownMenuItem(
                  value: EmploymentStatusFilter.active,
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: EmploymentStatusFilter.inactive,
                  child: Text('Inactive'),
                ),
                DropdownMenuItem(
                  value: EmploymentStatusFilter.all,
                  child: Text('All Employment'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.filter,
    required this.label,
  });

  final MemberStatusFilter filter;
  final String label;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamMembersBloc, TeamMembersState>(
      buildWhen: (previous, current) => previous.selectedFilter != current.selectedFilter,
      builder: (context, state) {
        final selected = state.selectedFilter == filter;
        return InkWell(
          onTap: () {
            context.read<TeamMembersBloc>().add(TeamMembersFilterChanged(filter));
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.dark().secondary.withValues(alpha: 0.20)
                  : AppColors.dark().backgroundMedium,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? AppColors.dark().secondary
                    : AppColors.dark().borderPrimary.withValues(alpha: 0.40),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.dark().textPrimary : AppColors.dark().textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
