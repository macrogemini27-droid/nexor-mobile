import 'package:flutter/material.dart';

/// Nexor color system - Dark theme with iOS Blue accent
class AppColors {
  AppColors._();

  // Background Colors
  static const Color background = Color(0xFF000000); // Pure Black
  static const Color backgroundElevated = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceElevated = Color(0xFF2C2C2E);

  // Primary Color
  static const Color primary = Color(0xFF0A84FF); // iOS Blue
  static const Color primaryDark = Color(0xFF0066CC);
  static const Color primaryLight = Color(0xFF409CFF);

  // Semantic Colors
  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF453A);
  static const Color info = Color(0xFF64D2FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textTertiary = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF3A3A3C);

  // Border Colors
  static const Color border = Color(0xFF38383A);
  static const Color borderLight = Color(0xFF48484A);

  // Status Colors
  static const Color online = Color(0xFF30D158);
  static const Color offline = Color(0xFF666666);
  static const Color connecting = Color(0xFFFF9F0A);

  // Overlay Colors
  static const Color overlay = Color(0x1AFFFFFF);
  static const Color overlayStrong = Color(0x33FFFFFF);

  // Glassmorphism
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
