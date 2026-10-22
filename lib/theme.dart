import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFFBFCFB);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF1F7A3A);
  static const primaryDark = Color(0xFF166534);
  static const mint = Color(0xFFD8F3DC);
  static const mintDeep = Color(0xFFBFE6C8);
  static const sprout = Color(0xFF2F8A46);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const hint = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const disabled = Color(0xFFE8EBE8);
  static const disabledText = Color(0xFF9AA09C);
  static const error = Color(0xFFDC3B3B);
  static const infoFill = Color(0xFFEEF5FB);
  static const infoStroke = Color(0xFFD5E6F4);
  static const infoText = Color(0xFF3B6280);
}

class AppTheme {
  static ThemeData light() {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme();
    final display = GoogleFonts.fraunces;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme.copyWith(
        displaySmall: display(
          fontSize: 40,
          height: 1.12,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        headlineMedium: display(
          fontSize: 34,
          height: 1.15,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        headlineSmall: display(
          fontSize: 28,
          height: 1.15,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        titleLarge: display(
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
    );
  }
}

class AppRoutes {
  static const welcome = '/';
  static const signIn = '/sign-in';
  static const createAccount = '/create-account';
  static const forgotPassword = '/forgot-password';
  static const resetSuccess = '/reset-success';
}
