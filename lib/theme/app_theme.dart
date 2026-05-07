import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary     = Color(0xFF2563EB);
  static const Color surface     = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textMuted   = Color(0xFF94A3B8);
  static const Color background  = Color(0xFFE8F0FE);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
}
