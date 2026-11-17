import 'package:flutter/material.dart';

class MoonsTheme {
  // Light color palette
  static const Color primaryLight = Color(0xFF4F46E5); // Rich Indigo
  static const Color secondaryLight = Color(0xFF0284C7); // Sky Blue
  static const Color tertiaryLight = Color(0xFFD97706); // Warm Amber
  static const Color surfaceLight = Color(0xFFF8FAFC); // Clean Canvas
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500

  // Dark color palette (Lunar Night)
  static const Color primaryDark = Color(0xFF818CF8); // Neon Violet/Indigo
  static const Color secondaryDark = Color(0xFF38BDF8); // Electric Sky
  static const Color tertiaryDark = Color(0xFFFBBF24); // Moonbeam Gold
  static const Color surfaceDark = Color(0xFF0B0F19); // Obsidian Celestial
  static const Color cardDark = Color(0xFF151C2C); // Deep Surface
  static const Color cardElevatedDark = Color(0xFF1E273D);
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Light Slate
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Muted Slate

  // Semantic Financial Colors
  static const Color incomeGreen = Color(0xFF10B981); // Emerald
  static const Color expenseRed = Color(0xFFF43F5E); // Radiant Rose
  static const Color warningOrange = Color(0xFFF59E0B); // Amber Warning

  static ThemeData get lightTheme {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
      primary: primaryLight,
      secondary: secondaryLight,
      tertiary: tertiaryLight,
      surface: surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: surfaceLight,
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimaryLight),
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        backgroundColor: Colors.white,
        indicatorColor: primaryLight.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryLight,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryLight,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.dark,
      primary: primaryDark,
      secondary: secondaryDark,
      tertiary: tertiaryDark,
      surface: surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: surfaceDark,
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF242E45)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimaryDark),
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: cardDark,
        indicatorColor: primaryDark.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryDark,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryDark,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: const Color(0xFF0B0F19),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),
    );
  }
}
