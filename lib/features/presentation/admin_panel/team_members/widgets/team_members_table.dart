import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_bloc.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_event.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_member_row_actions.dart';

class TeamMembersTable extends StatelessWidget {
  const TeamMembersTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dark().backgroundMedium,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dark().borderPrimary.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const _TableHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TeamMembersBloc, TeamMembersState>(
              buildWhen: (previous, current) => previous.visibleMembers != current.visibleMembers,
              builder: (context, state) {
                if (state.visibleMembers.isEmpty) {
                  return Center(
                    child: Text(
                      'No team members found.',
                      style: TextStyle(color: AppColors.dark().textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: state.visibleMembers.length,
                  separatorBuilder: (_, __) => Divider(
                    color: AppColors.dark().borderPrimary.withValues(alpha: 0.3),
                    height: 14,
                  ),
                  itemBuilder: (context, index) {
                    final member = state.visibleMembers[index];
                    return _MemberRow(member: member);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: AppColors.dark().textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 36, child: Checkbox(value: false, onChanged: (_) {})),
          Expanded(flex: 3, child: Text('Name', style: textStyle)),
          Expanded(flex: 2, child: Text('D.O.J', style: textStyle)),
          Expanded(flex: 4, child: Text('Email', style: textStyle)),
          Expanded(flex: 2, child: Text('Status', style: textStyle)),
          Expanded(flex: 2, child: Text('Action', style: textStyle)),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final TeamMemberUiModel member;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: AppColors.dark().textPrimary, fontSize: 13);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 36, child: Checkbox(value: false, onChanged: (_) {})),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.dark().secondary.withValues(alpha: 0.2),
                  child: Text(
                    member.name.isEmpty ? '-' : member.name.characters.first.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.dark().textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    member.name,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(member.doj, style: textStyle)),
          Expanded(
            flex: 4,
            child: Text(
              member.email,
              style: textStyle.copyWith(color: AppColors.dark().textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: _StatusTag(status: member.status),
          ),
          Expanded(
            flex: 2,
            child: TeamMemberRowActions(
              onEdit: () {
                context.read<TeamMembersBloc>().add(TeamMemberEditTapped(member.id));
              },
              onDelete: () {
                context.read<TeamMembersBloc>().add(TeamMemberDeleteTapped(member.id));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final TeamMemberStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TeamMemberStatus.online => ('Online', const Color(0xFF28C76F)),
      TeamMemberStatus.idle => ('Idle', const Color(0xFFF9A826)),
      TeamMemberStatus.offline => ('Offline', AppColors.dark().textTertiary),
    };
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.dark().textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
