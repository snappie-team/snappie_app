import 'package:flutter/material.dart';
import 'themes/primary_colors.dart';
import 'themes/accent_colors.dart';
import 'themes/warning_colors.dart';
import 'themes/danger_colors.dart';
import 'themes/success_colors.dart';
import 'themes/meta_colors.dart';
import 'themes/light_sea_green_colors.dart';

/// App Color Theme System
/// 
/// This class provides a centralized color management system for the Snappie app.
/// Colors are organized by semantic meaning rather than specific color values,
/// making it easy to maintain consistency and implement theme switching.

class AppColors {
  const AppColors._();
  
  // ============================================================================
  // PRIMARY COLORS
  // ============================================================================
  
  /// Primary brand color - used for main actions, active states
  static Color primary = PrimaryColors.primary500; // Teal
  static Color primaryLight = PrimaryColors.primary300; // Light Teal
  static Color primaryDark = PrimaryColors.primary700; // Dark Teal
  static Color primarySurface = PrimaryColors.primary50; // Very Light Teal
  static Color primaryContainer = PrimaryColors.primary100; // Light Teal Container

  // SECONDARY COLORS - Light Sea Green (Turquoise)
  static Color secondary = LightSeaGreenColors.lightSeaGreen500;
  static Color secondaryLight = LightSeaGreenColors.lightSeaGreen300; // Light Turquoise
  static Color secondaryDark = LightSeaGreenColors.lightSeaGreen700; // Dark Turquoise
  static Color secondaryContainer = LightSeaGreenColors.lightSeaGreen50; // Very Light Turquoise
  static Color secondarySurface = LightSeaGreenColors.lightSeaGreen100; // Light Turquoise Surface


  // ============================================================================
  // SURFACE COLORS
  // ============================================================================
  
  /// Background colors for different surfaces
  static Color background = MetaColors.meta50; // Light Grey
  static Color backgroundContainer = Colors.white; // White
  
  static Color surface = MetaColors.meta100; // White
  static Color surfaceVariant = MetaColors.meta100; // Very Light Grey
  static Color surfaceContainer = MetaColors.meta200; // Light Grey Container
  
  // ============================================================================
  // TEXT COLORS
  // ============================================================================
  
  /// Text colors with different emphasis levels
  static Color textPrimary = MetaColors.meta900; // Dark Grey/Black
  static Color textSecondary = MetaColors.meta600; // Medium Grey
  static Color textTertiary = MetaColors.meta500; // Grey
  static Color textDisabled = MetaColors.meta400; // Light Grey
  static Color textOnPrimary = MetaColors.meta50; // White/Very Light
  static Color textOnSurface = MetaColors.meta900; // Dark Grey/Black
  
  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  
  /// Success colors - for positive actions, confirmations
  static Color success = SuccessColors.success500; // Green
  static Color successLight = SuccessColors.success300; // Light Green
  static Color successDark = SuccessColors.success700; // Dark Green
  static Color successSurface = SuccessColors.success50; // Very Light Green
  static Color successContainer = SuccessColors.success100; // Light Green Container
  
  /// Error colors - for errors, warnings, destructive actions
  static Color error = DangerColors.danger500; // Red
  static Color errorLight = DangerColors.danger300; // Light Red
  static Color errorDark = DangerColors.danger700; // Dark Red
  static Color errorSurface = DangerColors.danger50; // Very Light Red
  static Color errorContainer = DangerColors.danger100; // Light Red Container
  
  /// Warning colors - for caution, pending states
  static Color warning = WarningColors.warning500; // Yellow/Orange
  static Color warningLight = WarningColors.warning300; // Light Yellow
  static Color warningDark = WarningColors.warning700; // Dark Yellow
  static Color warningSurface = WarningColors.warning50; // Very Light Yellow
  static Color warningContainer = WarningColors.warning100; // Light Yellow Container
  
  /// Accent colors - for highlights and special elements
  static Color accent = AccentColors.accent500; // Orange
  static Color accentLight = AccentColors.accent100; // Light Orange
  static Color accentDark = AccentColors.accent700; // Dark Orange
  static Color accentSurface = AccentColors.accent50; // Very Light Orange
  static Color accentContainer = AccentColors.accent100; // Light Orange Container
  
  // ============================================================================
  // BORDER & DIVIDER COLORS
  // ============================================================================
  
  /// Border and divider colors
  static Color border = MetaColors.meta300; // Grey
  static Color borderLight = MetaColors.meta200; // Light Grey
  static Color borderDark = MetaColors.meta400; // Dark Grey
  static Color divider = MetaColors.meta200; // Light Grey
  
  // ============================================================================
  // OVERLAY COLORS
  // ============================================================================
  
  /// Overlay colors for modals, shadows, etc.
  static Color overlay = MetaColors.meta950.withAlpha(50);
  static Color overlayLight = MetaColors.meta950.withAlpha(30);
  static Color overlayDark = MetaColors.meta950.withAlpha(70);
  static Color scrim = MetaColors.meta950.withAlpha(60);

  // ============================================================================
  // GRADIENT COLORS
  // ============================================================================
  
  /// Common gradients used in the app
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get successGradient => LinearGradient(
    colors: [successLight, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================================================
  // SHADOW COLORS
  // ============================================================================
  
  /// Shadow colors for elevation
  static Color shadowLight = MetaColors.meta500.withAlpha(10);
  static Color shadowMedium = MetaColors.meta500.withAlpha(20);
  static Color shadowDark = MetaColors.meta500.withAlpha(50);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).toInt());
  }
  
  /// Get rating color based on rating value
  static Color getRatingColor(double rating) {
    if (rating >= 4.0) return success;
    if (rating >= 3.0) return warning;
    if (rating >= 2.0) return accent;
    return error;
  }
  
  /// Get status color based on status type
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'open':
      case 'available':
      case 'online':
        return success;
      case 'pending':
      case 'processing':
        return warning;
      case 'inactive':
      case 'closed':
      case 'unavailable':
      case 'offline':
        return textTertiary;
      case 'error':
      case 'failed':
      case 'rejected':
        return error;
      default:
        return textSecondary;
    }
  }
}

/// Extension for easy access to colors with semantic naming
// extension AppColorsExtension on BuildContext {
//   /// Get colors instance for easy access
//   static AppColors get instance => const AppColors._();
// }
