import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Custom text style definitions for the Travel CRM app
/// Provides consistent typography across the application
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  // Heading Styles
  final TextStyle heading1;
  final TextStyle heading2;
  final TextStyle heading3;
  final TextStyle heading4;
  final TextStyle heading5;
  final TextStyle heading6;
  
  // Body Text Styles
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  
  // Label Styles
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  
  // Button Text Styles
  final TextStyle buttonLarge;
  final TextStyle buttonMedium;
  final TextStyle buttonSmall;
  
  // Caption Styles
  final TextStyle caption;
  final TextStyle overline;
  
  // Form Field Styles
  final TextStyle formLabel;
  final TextStyle formHint;
  final TextStyle formError;
  final TextStyle formInput;

  const AppTextStyles({
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.heading4,
    required this.heading5,
    required this.heading6,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.buttonLarge,
    required this.buttonMedium,
    required this.buttonSmall,
    required this.caption,
    required this.overline,
    required this.formLabel,
    required this.formHint,
    required this.formError,
    required this.formInput,
  });

  /// Default dark theme text styles
  factory AppTextStyles.dark(AppColors colors) {
    return AppTextStyles(
      // Heading Styles
      heading1: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      heading2: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      heading3: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.3,
        letterSpacing: -0.3,
      ),
      heading4: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.4,
        letterSpacing: -0.2,
      ),
      heading5: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.4,
        letterSpacing: 0,
      ),
      heading6: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.5,
        letterSpacing: 0,
      ),
      
      // Body Text Styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: colors.textPrimary,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: colors.textPrimary,
        height: 1.5,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: colors.textSecondary,
        height: 1.4,
        letterSpacing: 0.4,
      ),
      
      // Label Styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.4,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
        height: 1.3,
        letterSpacing: 0.5,
      ),
      
      // Button Text Styles
      buttonLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textOnPrimary,
        height: 1.2,
        letterSpacing: 0.5,
      ),
      buttonMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textOnPrimary,
        height: 1.2,
        letterSpacing: 0.4,
      ),
      buttonSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colors.textOnPrimary,
        height: 1.2,
        letterSpacing: 0.4,
      ),
      
      // Caption Styles
      caption: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: colors.textSecondary,
        height: 1.3,
        letterSpacing: 0.4,
      ),
      overline: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
        height: 1.2,
        letterSpacing: 1.5,
      ),
      
      // Form Field Styles
      formLabel: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      formHint: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: colors.textTertiary,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      formError: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: colors.error,
        height: 1.3,
        letterSpacing: 0.4,
      ),
      formInput: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: colors.textPrimary,
        height: 1.5,
        letterSpacing: 0.25,
      ),
    );
  }

  @override
  ThemeExtension<AppTextStyles> copyWith({
    TextStyle? heading1,
    TextStyle? heading2,
    TextStyle? heading3,
    TextStyle? heading4,
    TextStyle? heading5,
    TextStyle? heading6,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? buttonLarge,
    TextStyle? buttonMedium,
    TextStyle? buttonSmall,
    TextStyle? caption,
    TextStyle? overline,
    TextStyle? formLabel,
    TextStyle? formHint,
    TextStyle? formError,
    TextStyle? formInput,
  }) {
    return AppTextStyles(
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      heading4: heading4 ?? this.heading4,
      heading5: heading5 ?? this.heading5,
      heading6: heading6 ?? this.heading6,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
      buttonLarge: buttonLarge ?? this.buttonLarge,
      buttonMedium: buttonMedium ?? this.buttonMedium,
      buttonSmall: buttonSmall ?? this.buttonSmall,
      caption: caption ?? this.caption,
      overline: overline ?? this.overline,
      formLabel: formLabel ?? this.formLabel,
      formHint: formHint ?? this.formHint,
      formError: formError ?? this.formError,
      formInput: formInput ?? this.formInput,
    );
  }

  @override
  ThemeExtension<AppTextStyles> lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }

    return AppTextStyles(
      heading1: TextStyle.lerp(heading1, other.heading1, t)!,
      heading2: TextStyle.lerp(heading2, other.heading2, t)!,
      heading3: TextStyle.lerp(heading3, other.heading3, t)!,
      heading4: TextStyle.lerp(heading4, other.heading4, t)!,
      heading5: TextStyle.lerp(heading5, other.heading5, t)!,
      heading6: TextStyle.lerp(heading6, other.heading6, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      buttonLarge: TextStyle.lerp(buttonLarge, other.buttonLarge, t)!,
      buttonMedium: TextStyle.lerp(buttonMedium, other.buttonMedium, t)!,
      buttonSmall: TextStyle.lerp(buttonSmall, other.buttonSmall, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
      formLabel: TextStyle.lerp(formLabel, other.formLabel, t)!,
      formHint: TextStyle.lerp(formHint, other.formHint, t)!,
      formError: TextStyle.lerp(formError, other.formError, t)!,
      formInput: TextStyle.lerp(formInput, other.formInput, t)!,
    );
  }
}










