import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Main theme configuration for the Travel CRM app
/// Provides dark theme with purple gradient
class AppTheme {
  // Color instance
  static final AppColors _colors = AppColors.dark();
  
  // Text styles instance
  static final AppTextStyles _textStyles = AppTextStyles.dark(_colors);

  /// Main gradient background for the app (radial gradient - dark purple to black)
  static const RadialGradient gradientBackground = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.5,
    colors: [
      Color(0xFF1A0B2E), // Dark purple
      Color(0xFF0A0515), // Very dark purple
      Color(0xFF000000), // Black
    ],
    stops: [0.0, 0.6, 1.0],
  );

  /// Linear gradient background (for backward compatibility)
  static const LinearGradient gradientBackgroundLinear = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A0B2E), // primaryDark
      Color(0xFF2D1B4E), // primaryMedium
      Color(0xFF4A2C6B), // primaryLight
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Secondary gradient for accents
  static const LinearGradient gradientSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B46C1), // secondary
      Color(0xFF8B5CF6), // secondaryLight
    ],
  );

  /// Accent gradient
  static const LinearGradient gradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9333EA), // accent
      Color(0xFFB855F0), // accentLight
    ],
  );

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: _colors.primaryLight,
        secondary: _colors.secondary,
        surface: _colors.surface,
        error: _colors.error,
        onPrimary: _colors.textOnPrimary,
        onSecondary: _colors.textOnPrimary,
        onSurface: _colors.textPrimary,
        onError: _colors.textOnPrimary,
        background: _colors.backgroundDark,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: _colors.backgroundDark,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _colors.backgroundMedium,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _colors.textPrimary),
        titleTextStyle: _textStyles.heading6,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: _colors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input Decoration Theme (for form fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _colors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _colors.inputBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _colors.inputBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _colors.inputBorderFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _colors.inputErrorBorder,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _colors.inputErrorBorder,
            width: 2,
          ),
        ),
        labelStyle: _textStyles.formLabel,
        hintStyle: _textStyles.formHint,
        errorStyle: _textStyles.formError,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _colors.secondary,
          foregroundColor: _colors.textOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: _textStyles.buttonMedium,
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _colors.secondary,
          side: BorderSide(
            color: _colors.secondary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: _textStyles.buttonMedium,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _colors.secondary,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: _textStyles.buttonMedium,
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: _colors.borderSecondary,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: _colors.textPrimary,
        size: 24,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: _textStyles.heading1,
        displayMedium: _textStyles.heading2,
        displaySmall: _textStyles.heading3,
        headlineMedium: _textStyles.heading4,
        headlineSmall: _textStyles.heading5,
        titleLarge: _textStyles.heading6,
        titleMedium: _textStyles.bodyLarge,
        titleSmall: _textStyles.bodyMedium,
        bodyLarge: _textStyles.bodyLarge,
        bodyMedium: _textStyles.bodyMedium,
        bodySmall: _textStyles.bodySmall,
        labelLarge: _textStyles.labelLarge,
        labelMedium: _textStyles.labelMedium,
        labelSmall: _textStyles.labelSmall,
      ),
      
      // Extensions for custom colors and text styles
      extensions: <ThemeExtension<dynamic>>[
        _colors,
        _textStyles,
      ],
    );
  }

  /// Get colors from theme context
  static AppColors colors(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? _colors;
  }

  /// Get text styles from theme context
  static AppTextStyles textStyles(BuildContext context) {
    return Theme.of(context).extension<AppTextStyles>() ?? _textStyles;
  }
}

