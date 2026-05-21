import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Palette
  static const Color primaryLight = Color(0xFF059669); // Emerald-600
  static const Color secondaryLight = Color(0xFF0284C7); // Sky-600
  static const Color bgLight = Color(0xFFF8FAFC); // Slate-50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate-900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate-600
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate-400
  static const Color borderLight = Color(0xFFE2E8F0); // Slate-200

  // Dark Palette
  static const Color primaryDark = Color(0xFF10B981); // Emerald-500
  static const Color secondaryDark = Color(0xFF38BDF8); // Sky-400
  static const Color bgDark = Color(0xFF090D16); // Ultra deep slate-950
  static const Color surfaceDark = Color(0xFF111827); // Slate-900
  static const Color cardDark = Color(0xFF1E293B); // Slate-800
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate-50
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate-300
  static const Color textMutedDark = Color(0xFF64748B); // Slate-500
  static const Color borderDark = Color(0xFF334155); // Slate-700

  // Status Colors (Universal)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        background: AppColors.bgLight,
        surface: AppColors.surfaceLight,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.textPrimaryLight,
        onSurface: AppColors.textPrimaryLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          textStyle: baseTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        headlineMedium: GoogleFonts.outfit(
          textStyle: baseTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMutedLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        background: AppColors.bgDark,
        surface: AppColors.surfaceDark,
        error: AppColors.danger,
        onPrimary: AppColors.bgDark,
        onSecondary: Colors.white,
        onBackground: AppColors.textPrimaryDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          textStyle: baseTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        headlineMedium: GoogleFonts.outfit(
          textStyle: baseTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.bgDark,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
