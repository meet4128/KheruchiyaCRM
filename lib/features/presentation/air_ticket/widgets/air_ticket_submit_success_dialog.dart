import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

/// Shows a themed success dialog after air ticket submission.
/// Styling matches other air-ticket dialogs (e.g. checklist users picker).
/// Side effects (reset + navigation) stay in [BlocListener] via [onAcknowledge].
Future<void> showAirTicketSubmitSuccessDialog(
  BuildContext context, {
  required String message,
  required VoidCallback onAcknowledge,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (dialogContext) => _AirTicketSubmitSuccessDialog(
      message: message,
      onAcknowledge: () {
        Navigator.of(dialogContext).pop();
        onAcknowledge();
      },
    ),
  );
}

class _AirTicketSubmitSuccessDialog extends StatelessWidget {
  const _AirTicketSubmitSuccessDialog({
    required this.message,
    required this.onAcknowledge,
  });

  final String message;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final borderColor = colors.secondary.withValues(alpha: 0.5);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: colors.success,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      StringConstant.airTicketSubmissionSuccessTitle,
                      style: textStyles.heading5.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: colors.secondary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAcknowledge,
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            colors.secondary,
                            colors.secondary.withValues(alpha: 0.85),
                            const Color(0xFFEC4899),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colors.secondary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        StringConstant.done,
                        style: textStyles.labelLarge.copyWith(
                          color: colors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
