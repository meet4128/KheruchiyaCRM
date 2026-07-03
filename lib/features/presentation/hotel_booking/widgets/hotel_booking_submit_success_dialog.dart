import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

/// Shows a themed success dialog after hotel booking submission.
/// Layout: close control, hero illustration, centered title + message, full-width pill CTA.
/// Side effects (reset + navigation) stay in [BlocListener] via [onAcknowledge].
Future<void> showHotelBookingSubmitSuccessDialog(
  BuildContext context, {
  required String message,
  required VoidCallback onAcknowledge,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (dialogContext) => _HotelBookingSubmitSuccessDialog(
      message: message,
      onAcknowledge: () {
        Navigator.of(dialogContext).pop();
        onAcknowledge();
      },
    ),
  );
}

class _HotelBookingSubmitSuccessDialog extends StatelessWidget {
  const _HotelBookingSubmitSuccessDialog({
    required this.message,
    required this.onAcknowledge,
  });

  final String message;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final borderColor = colors.secondary.withValues(alpha: 0.45);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: colors.primaryDark.withValues(alpha: 0.45),
              blurRadius: 32,
              offset: const Offset(0, 18),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: onAcknowledge,
                ),
              ),
              const SizedBox(height: 4),
              _SuccessHeroIllustration(colors: colors),
              const SizedBox(height: 22),
              Text(
                StringConstant.airTicketSubmissionSuccessTitle,
                textAlign: TextAlign.center,
                style: textStyles.heading5.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
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
                        boxShadow: [
                          BoxShadow(
                            color: colors.secondary.withValues(alpha: 0.38),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          StringConstant.continueAction,
                          style: textStyles.labelLarge.copyWith(
                            color: colors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
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

/// Decorative success mark: soft blob, confetti hints, circular check.
class _SuccessHeroIllustration extends StatelessWidget {
  const _SuccessHeroIllustration({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final blobColor = colors.secondary.withValues(alpha: 0.14);
    final accentDot = colors.secondaryLight.withValues(alpha: 0.9);

    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 18,
            child: Container(
              width: 160,
              height: 110,
              decoration: BoxDecoration(
                color: blobColor,
                borderRadius: BorderRadius.circular(56),
              ),
            ),
          ),
          Positioned(top: 28, left: 48, child: _confettiDot(6, accentDot)),
          Positioned(top: 40, right: 52, child: _confettiDot(5, colors.success)),
          Positioned(bottom: 36, left: 58, child: _confettiDash(colors.info)),
          Positioned(top: 52, right: 44, child: _confettiDot(4, colors.textTertiary)),
          Container(
            width: 86,
            height: 86,
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
        ],
      ),
    );
  }

  Widget _confettiDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _confettiDash(Color color) {
    return Container(
      width: 14,
      height: 4,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
