import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable section title widget
/// Displays title and optional subtitle with consistent styling
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.spacing = 24,
  });

  /// Main title text
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Spacing between title and subtitle (default: 24)
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          style: textStyles.heading1.copyWith(
            color: colors.textPrimary,
          ),
        ),
        // Subtitle
        if (subtitle != null) ...[
          SizedBox(height: spacing),
          Text(
            subtitle!,
            style: textStyles.bodyLarge.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}










