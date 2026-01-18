import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Button style variants
enum AppButtonStyle {
  primary,
  secondary,
}

/// Reusable button widget with consistent styling and loading state
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.left,
  });

  /// Button text
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button style variant
  final AppButtonStyle style;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button should take full width
  final bool isFullWidth;

  /// Optional icon
  final IconData? icon;

  /// Icon position relative to text
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    final isEnabled = onPressed != null && !isLoading;

    Widget button;

    switch (style) {
      case AppButtonStyle.primary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.secondary,
            foregroundColor: colors.textOnPrimary,
            disabledBackgroundColor: colors.secondary.withOpacity(0.5),
            disabledForegroundColor: colors.textOnPrimary.withOpacity(0.5),
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _buildButtonContent(colors, textStyles),
        );
        break;

      case AppButtonStyle.secondary:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.secondary,
            side: BorderSide(
              color: isEnabled ? colors.secondary : colors.secondary.withOpacity(0.5),
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _buildButtonContent(colors, textStyles),
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  /// Build button content (text, icon, or loading indicator)
  Widget _buildButtonContent(AppColors colors, AppTextStyles textStyles) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            style == AppButtonStyle.primary
                ? colors.textOnPrimary
                : colors.secondary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconPosition == IconPosition.left) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: textStyles.buttonMedium.copyWith(
              color: style == AppButtonStyle.primary
                  ? colors.textOnPrimary
                  : colors.secondary,
            ),
          ),
          if (iconPosition == IconPosition.right) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ],
      );
    }

    return Text(
      text,
      style: textStyles.buttonMedium.copyWith(
        color: style == AppButtonStyle.primary
            ? colors.textOnPrimary
            : colors.secondary,
      ),
    );
  }
}

/// Icon position enum
enum IconPosition {
  left,
  right,
}










