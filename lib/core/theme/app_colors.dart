import 'package:flutter/material.dart';

/// Custom color definitions for the Travel CRM app
/// Uses dark-purple gradient theme
class AppColors extends ThemeExtension<AppColors> {
  // Primary Colors - Dark Purple Gradient
  final Color primaryDark;
  final Color primaryMedium;
  final Color primaryLight;
  
  // Secondary Colors
  final Color secondary;
  final Color secondaryLight;
  
  // Background Colors
  final Color backgroundDark;
  final Color backgroundMedium;
  final Color backgroundLight;
  final Color surface;
  
  // Text Colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  
  // Accent Colors
  final Color accent;
  final Color accentLight;
  
  // Status Colors
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  
  // Border Colors
  final Color borderPrimary;
  final Color borderSecondary;
  final Color borderError;
  
  // Input Field Colors
  final Color inputBackground;
  final Color inputBorder;
  final Color inputBorderFocused;
  final Color inputErrorBorder;
  
  const AppColors({
    required this.primaryDark,
    required this.primaryMedium,
    required this.primaryLight,
    required this.secondary,
    required this.secondaryLight,
    required this.backgroundDark,
    required this.backgroundMedium,
    required this.backgroundLight,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.accent,
    required this.accentLight,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.borderPrimary,
    required this.borderSecondary,
    required this.borderError,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.inputErrorBorder,
  });

  /// Default dark theme colors with purple gradient
  factory AppColors.dark() {
    return const AppColors(
      // Primary Colors - Dark Purple Gradient
      primaryDark: Color(0xFF1A0B2E),      // Deep dark purple
      primaryMedium: Color(0xFF2D1B4E),    // Medium purple
      primaryLight: Color(0xFF4A2C6B),     // Light purple
      
      // Secondary Colors
      secondary: Color(0xFF6B46C1),        // Purple accent
      secondaryLight: Color(0xFF8B5CF6),   // Light purple accent
      
      // Background Colors
      backgroundDark: Color(0xFF0F0B1E),   // Very dark background
      backgroundMedium: Color(0xFF1A1625), // Medium dark background
      backgroundLight: Color(0xFF252031),  // Light dark background
      surface: Color(0xFF2D2839),          // Surface color
      
      // Text Colors
      textPrimary: Color(0xFFFFFFFF),       // White for primary text
      textSecondary: Color(0xFFB8B5C7),    // Light gray for secondary text
      textTertiary: Color(0xFF8B8799),     // Medium gray for tertiary text
      textOnPrimary: Color(0xFFFFFFFF),     // White text on primary color
      
      // Accent Colors
      accent: Color(0xFF9333EA),            // Purple accent
      accentLight: Color(0xFFB855F0),      // Light purple accent
      
      // Status Colors
      success: Color(0xFF10B981),          // Green
      error: Color(0xFFEF4444),            // Red
      warning: Color(0xFFF59E0B),          // Orange
      info: Color(0xFF3B82F6),             // Blue
      
      // Border Colors
      borderPrimary: Color(0xFF3D3551),     // Primary border
      borderSecondary: Color(0xFF2D2839),  // Secondary border
      borderError: Color(0xFFEF4444),       // Error border
      
      // Input Field Colors
      inputBackground: Color(0xFF0A0A0A),   // Near-black input background
      inputBorder: Color(0xFF1A1A1A),      // Subtle input border
      inputBorderFocused: Color(0xFF6B46C1), // Focused input border (purple)
      inputErrorBorder: Color(0xFFEF4444), // Error input border
    );
  }

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primaryDark,
    Color? primaryMedium,
    Color? primaryLight,
    Color? secondary,
    Color? secondaryLight,
    Color? backgroundDark,
    Color? backgroundMedium,
    Color? backgroundLight,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnPrimary,
    Color? accent,
    Color? accentLight,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? borderPrimary,
    Color? borderSecondary,
    Color? borderError,
    Color? inputBackground,
    Color? inputBorder,
    Color? inputBorderFocused,
    Color? inputErrorBorder,
  }) {
    return AppColors(
      primaryDark: primaryDark ?? this.primaryDark,
      primaryMedium: primaryMedium ?? this.primaryMedium,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      backgroundMedium: backgroundMedium ?? this.backgroundMedium,
      backgroundLight: backgroundLight ?? this.backgroundLight,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      borderError: borderError ?? this.borderError,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputBorderFocused: inputBorderFocused ?? this.inputBorderFocused,
      inputErrorBorder: inputErrorBorder ?? this.inputErrorBorder,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryMedium: Color.lerp(primaryMedium, other.primaryMedium, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      backgroundMedium: Color.lerp(backgroundMedium, other.backgroundMedium, t)!,
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      borderError: Color.lerp(borderError, other.borderError, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputBorderFocused: Color.lerp(inputBorderFocused, other.inputBorderFocused, t)!,
      inputErrorBorder: Color.lerp(inputErrorBorder, other.inputErrorBorder, t)!,
    );
  }
}

