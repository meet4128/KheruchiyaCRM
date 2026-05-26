import 'package:flutter/material.dart';

/// Brand-pane + primary-button gradient shared by every public-auth screen
/// (login, forgot-password, set-password, reset-password). Owning this in one
/// place keeps the chrome visually identical even if marketing tweaks the
/// palette later.
const List<Color> kAuthGradientColors = [
  Color(0xFFC44EB9),
  Color(0xFF6B3FA8),
  Color(0xFF1E1C4A),
];

/// Width above which auth screens render the brand pane side-by-side with the
/// form pane. Below this we fall back to stacked / scrollable layout.
const double kAuthWideBreakpoint = 880;
