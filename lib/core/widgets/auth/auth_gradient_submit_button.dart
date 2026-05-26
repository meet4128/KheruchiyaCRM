import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/widgets/auth/auth_constants.dart';

/// Full-width gradient CTA used at the bottom of every auth form.
///
/// When [isLoading] is true the label is swapped for a centered spinner; when
/// [onPressed] is null *and* not loading we render a dimmed (un-tappable) state
/// so the button still reads as the primary action.
class AuthGradientSubmitButton extends StatelessWidget {
  const AuthGradientSubmitButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.gradientColors = kAuthGradientColors,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final List<Color> gradientColors;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorConstant.whiteColor,
              ),
            )
          : Text(
              label,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
    );

    if (onPressed == null && !isLoading) {
      return Opacity(opacity: 0.95, child: child);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: child,
      ),
    );
  }
}
