import 'package:flutter/material.dart';

/// Nexor shadow system
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x330A84FF),
      blurRadius: 20,
      offset: Offset(0, 0),
    ),
  ];
}
