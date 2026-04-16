import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/widgets/team_member_row_actions.dart';

class TeamMembersTable extends StatelessWidget {
  const TeamMembersTable({
    super.key,
    required this.members,
    required this.showStatus,
    required this.showDepartment,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TeamMemberUiModel> members;
  final bool showStatus;
  final bool showDepartment;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;

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
          _TableHeader(
            showStatus: showStatus,
            showDepartment: showDepartment,
          ),
          const SizedBox(height: 8),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No team members found.',
                style: TextStyle(color: AppColors.dark().textSecondary),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (_, __) => Divider(
                color: AppColors.dark().borderPrimary.withValues(alpha: 0.3),
                height: 14,
              ),
              itemBuilder: (context, index) {
                final member = members[index];
                return _MemberRow(
                  member: member,
                  showStatus: showStatus,
                  showDepartment: showDepartment,
                  onEdit: onEdit,
                  onDelete: onDelete,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.showStatus,
    required this.showDepartment,
  });

  final bool showStatus;
  final bool showDepartment;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: AppColors.dark().textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    final dynamicColumnLabel = showStatus ? 'Status' : (showDepartment ? 'Department' : '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 36, child: Checkbox(value: false, onChanged: (_) {})),
          Expanded(flex: 3, child: Text('Name', style: textStyle)),
          Expanded(flex: 2, child: Text('D.O.J', style: textStyle)),
          Expanded(flex: 4, child: Text('Email', style: textStyle)),
          Expanded(flex: 2, child: Text(dynamicColumnLabel, style: textStyle)),
          Expanded(flex: 2, child: Text('Action', style: textStyle)),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.showStatus,
    required this.showDepartment,
    required this.onEdit,
    required this.onDelete,
  });

  final TeamMemberUiModel member;
  final bool showStatus;
  final bool showDepartment;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;

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
            child: showStatus
                ? _StatusTag(status: member.status)
                : Text(
                    showDepartment ? member.department : '',
                    style: textStyle.copyWith(color: AppColors.dark().textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          Expanded(
            flex: 2,
            child: TeamMemberRowActions(
              onEdit: () => onEdit(member.id),
              onDelete: () => onDelete(member.id),
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
