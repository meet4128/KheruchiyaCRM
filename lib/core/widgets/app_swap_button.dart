import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable swap button widget
/// Used for swapping From/To locations or similar paired fields
class AppSwapButton extends StatelessWidget {
  const AppSwapButton({
    super.key,
    required this.onSwap,
    this.size = 40,
    this.iconSize = 20,
    this.enabled = true,
  });

  /// Callback when swap button is pressed
  final VoidCallback onSwap;

  /// Size of the button (width and height)
  final double size;

  /// Size of the swap icon
  final double iconSize;

  /// Whether the button is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onSwap : null,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: enabled
                ? colors.inputBackground.withOpacity(0.5)
                : colors.inputBackground.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled
                  ? colors.borderSecondary.withOpacity(0.5)
                  : colors.borderSecondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.swap_horiz,
            size: iconSize,
            color: enabled ? colors.textPrimary : colors.textTertiary,
          ),
        ),
      ),
    );
  }
}






