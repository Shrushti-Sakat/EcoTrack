import 'package:flutter/material.dart';

/// App Color Constants - Blue theme inspired by the architecture diagram
class AppColors {
  AppColors._();
  
  // Primary Blue Colors (from the image)
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color primaryBlueLight = Color(0xFF42A5F5);
  static const Color primaryBlueAccent = Color(0xFF2196F3);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F9FF);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF1565C0);
  static const Color gradientEnd = Color(0xFF42A5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF718096);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF4299E1);
  
  // Input Colors
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputFocusBorder = Color(0xFF1565C0);
  static const Color inputBackground = Color(0xFFF7FAFC);
  
  // Shadow Color
  static const Color shadowColor = Color(0x1A1565C0);
  
  // Divider
  static const Color divider = Color(0xFFE2E8F0);
  
  // Category Colors (for usage data)
  static const Color electricityColor = Color(0xFFFFB74D);
  static const Color fuelColor = Color(0xFFFF7043);
  static const Color travelColor = Color(0xFF4FC3F7);
  static const Color applianceColor = Color(0xFF81C784);
  static const Color wasteColor = Color(0xFFBA68C8);
}

/// App Text Styles
class AppTextStyles {
  AppTextStyles._();
  
  static const String fontFamily = 'Roboto';
  
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.4,
  );
  
  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.3,
  );
  
  // Label Text
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );
}

/// App Dimensions
class AppDimensions {
  AppDimensions._();
  
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  
  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Button Heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
  
  // Input Height
  static const double inputHeight = 56.0;
  
  // Card Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
}

/// App Gradients
class AppGradients {
  AppGradients._();
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientEnd,
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF5F9FF),
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.backgroundLight,
      AppColors.backgroundWhite,
    ],
  );
}

/// App Box Shadows
class AppShadows {
  AppShadows._();
  
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: AppColors.primaryBlue.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
}
