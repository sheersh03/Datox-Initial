import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

class DatoxTheme {
  static ThemeData get light {
    const baseTextTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, height: 1.15),
      displayMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.15),
      headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.18),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.18),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2),
      bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1.35),
      bodyMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.35),
      bodySmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.3),
      labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2),
      labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2),
      labelSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.15),
    );

    final themedText = GoogleFonts.quicksandTextTheme(
      baseTextTheme.apply(
        bodyColor: DatoxColors.textPrimary,
        displayColor: DatoxColors.textPrimary,
      ),
    );

    return ThemeData(
      scaffoldBackgroundColor: DatoxColors.bg,
      colorScheme: ColorScheme.light(
        primary: DatoxColors.primary,
        secondary: DatoxColors.accent,
        error: DatoxColors.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: DatoxColors.textPrimary,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: DatoxColors.textPrimary,
        ),
      ),
      textTheme: themedText,
      primaryTextTheme: themedText,
      chipTheme: ChipThemeData(
        labelStyle: GoogleFonts.quicksand(
          textStyle: baseTextTheme.labelLarge,
          color: DatoxColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: GoogleFonts.quicksand(textStyle: baseTextTheme.labelLarge),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.quicksand(textStyle: baseTextTheme.labelLarge),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.quicksand(textStyle: baseTextTheme.labelLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.quicksand(
          fontSize: 18,
          height: 1.25,
        ),
        labelStyle: GoogleFonts.quicksand(
          fontSize: 18,
          height: 1.25,
        ),
      ),
      iconTheme: const IconThemeData(color: DatoxColors.textPrimary),
      useMaterial3: true,
    );
  }
}
