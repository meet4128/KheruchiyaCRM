import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';

/// Action icons rendered in the rightmost column of each team-members table
/// row. Includes Delete, Edit, and optionally Resend-invite (only when the
/// caller passes a non-null [onResendInvite]).
class TeamMemberRowActions extends StatelessWidget {
  const TeamMemberRowActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.onResendInvite,
    this.isResending = false,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Tap handler for the "Resend invite" icon. Pass `null` to hide the icon
  /// entirely (e.g. for members already in `active` status).
  final VoidCallback? onResendInvite;

  /// When true, the resend icon is replaced with a small spinner so the
  /// admin gets per-row feedback during the API round-trip.
  final bool isResending;

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
        if (onResendInvite != null) ...[
          const SizedBox(width: 6),
          _ResendInviteAction(
            isResending: isResending,
            onTap: onResendInvite!,
          ),
        ],
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

class _ResendInviteAction extends StatelessWidget {
  const _ResendInviteAction({
    required this.isResending,
    required this.onTap,
  });

  final bool isResending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Tooltip(
      message: StringConstant.teamMembersResendInviteTooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isResending ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: isResending
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: colors.textSecondary,
                  ),
                )
              : Icon(
                  Icons.forward_to_inbox_outlined,
                  size: 18,
                  color: colors.textSecondary,
                ),
        ),
      ),
    );
  }
}
