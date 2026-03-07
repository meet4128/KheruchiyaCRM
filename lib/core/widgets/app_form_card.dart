import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable form card widget with gradient background
/// Used for containing form fields with consistent styling
class AppFormCard extends StatelessWidget {
  const AppFormCard({
    super.key,
    required this.child,
    this.padding,
    this.title,
    this.subtitle,
    this.borderGlow = false,
    this.centerTitle = false,
  });

  /// Child widget (typically form fields)
  final Widget child;

  /// Custom padding (defaults to EdgeInsets.all(32))
  final EdgeInsets? padding;

  /// Optional title text
  final String? title;

  /// Optional subtitle text
  final String? subtitle;

  /// When true, adds a thin glowing purple outline (box shadow)
  final bool borderGlow;

  /// When true, title and subtitle are centered in the form
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F1A2E),
              Color(0xFF2A2338),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.secondary.withOpacity(borderGlow ? 0.5 : 0.2),
            width: 1,
          ),
          boxShadow: [
            if (borderGlow)
              BoxShadow(
                color: colors.secondary.withOpacity(0.25),
                blurRadius: 12,
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title and subtitle if provided
          if (title != null || subtitle != null) ...[
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment:
                    centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      textAlign: centerTitle ? TextAlign.center : null,
                      style: textStyles.heading3.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (subtitle != null) ...[
                    if (title != null) const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      textAlign: centerTitle ? TextAlign.center : null,
                      style: textStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
          // Child content
          child,
        ],
      ),
    );
  }
}



