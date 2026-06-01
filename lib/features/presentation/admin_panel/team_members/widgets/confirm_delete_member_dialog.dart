import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';

/// Themed confirmation before `DELETE /api/v1/members/:id`.
///
/// Returns `true` when the admin confirmed deletion, `false` on cancel.
class ConfirmDeleteMemberDialog extends StatelessWidget {
  const ConfirmDeleteMemberDialog({
    super.key,
    required this.memberName,
    required this.memberEmail,
    this.isDeleting = false,
  });

  final String memberName;
  final String memberEmail;
  final bool isDeleting;

  static Future<bool> show(
    BuildContext context, {
    required String memberName,
    required String memberEmail,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return ConfirmDeleteMemberDialog(
          memberName: memberName,
          memberEmail: memberEmail,
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    final displayName = memberName.trim().isEmpty ? 'this member' : memberName.trim();
    final displayEmail = memberEmail.trim();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        decoration: BoxDecoration(
          color: colors.backgroundMedium.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.borderPrimary.withValues(alpha: 0.55)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colors.error.withValues(alpha: 0.9),
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringConstant.teamMembersDeleteConfirmTitle,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        StringConstant.teamMembersDeleteConfirmMessage(
                          displayName,
                          displayEmail,
                        ),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isDeleting ? null : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      side: BorderSide(color: colors.borderPrimary.withValues(alpha: 0.65)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(StringConstant.teamMembersDeleteCancelButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isDeleting ? null : () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.textOnPrimary,
                      disabledBackgroundColor: colors.error.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isDeleting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.textOnPrimary,
                            ),
                          )
                        : Text(StringConstant.teamMembersDeleteConfirmButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
