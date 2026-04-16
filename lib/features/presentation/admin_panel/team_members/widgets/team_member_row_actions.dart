import 'package:flutter/material.dart';
import 'package:travel_crm/core/theme/app_colors.dart';

class TeamMemberRowActions extends StatelessWidget {
  const TeamMemberRowActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIconButton(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Delete',
          onTap: onDelete,
        ),
        const SizedBox(width: 6),
        _ActionIconButton(
          icon: Icons.edit_outlined,
          tooltip: 'Edit',
          onTap: onEdit,
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.dark().textSecondary,
          ),
        ),
      ),
    );
  }
}
