import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1); // Modern Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Modern Violet
  static const Color backgroundColor = Color(0xFF0F172A); // Dark Slate
  static const Color cardColor = Color(0xFF1E293B); // Lighter Slate
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);

  // Light Theme Palette
  static const Color lightBgColor = Color(0xFFF3F4F6); // Soft Gray-Blue
  static const Color lightCardColor = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A); // Dark Indigo-Slate
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate Gray

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        color: textSecondary.withValues(alpha: 0.8),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBgColor,
    cardColor: lightCardColor,
    dividerColor: lightTextSecondary.withValues(alpha: 0.1),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightCardColor,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: lightTextSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        color: lightTextSecondary.withValues(alpha: 0.7),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: lightTextPrimary),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
    ),
  );
}

class ThemeManager {
  static const String _themeKey = 'theme_mode';
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true;
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static void toggleTheme(bool isDark) async {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  static bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;
}
