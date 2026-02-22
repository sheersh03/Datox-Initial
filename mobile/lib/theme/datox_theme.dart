import 'package:flutter/material.dart';
import 'tokens.dart';

class DatoxTheme {
  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: DatoxColors.bg,
      colorScheme: ColorScheme.light(
        primary: DatoxColors.primary,
        secondary: DatoxColors.accent,
        error: DatoxColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: DatoxColors.textPrimary,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 16),
      ),
      useMaterial3: true,
    );
  }
}
