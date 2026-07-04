import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

/// Themed success dialog shown after the vendor company details form submits.
/// Side effects (reset + navigation) stay in the [BlocListener] via [onAcknowledge].
Future<void> showVendorSubmitSuccessDialog(
  BuildContext context, {
  required String message,
  required VoidCallback onAcknowledge,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (dialogContext) => _VendorSubmitSuccessDialog(
      message: message,
      onAcknowledge: () {
        Navigator.of(dialogContext).pop();
        onAcknowledge();
      },
    ),
  );
}

class _VendorSubmitSuccessDialog extends StatelessWidget {
  const _VendorSubmitSuccessDialog({
    required this.message,
    required this.onAcknowledge,
  });

  final String message;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colors.secondary.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primaryDark.withValues(alpha: 0.45),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 86,
                height: 86,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.info,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.info.withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.textOnPrimary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                StringConstant.vendorSubmitSuccessTitle,
                textAlign: TextAlign.center,
                style: textStyles.heading5.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAcknowledge,
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            colors.secondary,
                            colors.secondary.withValues(alpha: 0.88),
                            const Color(0xFFEC4899),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Text(
                          StringConstant.continueAction,
                          style: textStyles.labelLarge.copyWith(
                            color: colors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
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
