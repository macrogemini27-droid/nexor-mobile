import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'dimensions.dart';

/// Nexor app theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppTypography.fontFamily,

        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.primary,
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          background: AppColors.background,
          onBackground: AppColors.textPrimary,
        ),

        // Scaffold
        scaffoldBackgroundColor: AppColors.background,

        // App Bar
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: AppTypography.headlineLarge,
        ),

        // Card
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space16,
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            textStyle: AppTypography.button,
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            textStyle: AppTypography.button,
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            textStyle: AppTypography.button,
          ),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),

        // Icon
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconLarge,
        ),

        // Text Theme
        textTheme: const TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          displaySmall: AppTypography.displaySmall,
          headlineLarge: AppTypography.headlineLarge,
          headlineMedium: AppTypography.headlineMedium,
          headlineSmall: AppTypography.headlineSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),
      );
}
