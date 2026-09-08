import 'package:flutter/material.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.neonLime,
        secondary: AppColors.surface,
        surface: AppColors.surfaceLight,
        onPrimary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),

      dividerColor: AppColors.divider,

      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.displayXL,
        headlineMedium: AppTextStyles.displayLarge,

        titleLarge: AppTextStyles.headingLarge,
        titleMedium: AppTextStyles.headingMedium,

        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,

        labelLarge: AppTextStyles.technical,
        labelMedium: AppTextStyles.label,
      ),
    );
  }
}
