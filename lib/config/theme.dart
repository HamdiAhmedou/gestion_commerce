import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors ────────────────────────────────────────────────
  static const primary      = Color(0xFF6C63FF);
  static const primaryDark  = Color(0xFF4B44CC);
  static const secondary    = Color(0xFF03DAC6);
  static const accent       = Color(0xFFFF6584);

  static const success      = Color(0xFF4CAF50);
  static const warning      = Color(0xFFFFC107);
  static const error        = Color(0xFFEF5350);
  static const info         = Color(0xFF2196F3);

  // Status colors
  static const enAttente    = Color(0xFFFFC107);
  static const confirmee    = Color(0xFF2196F3);
  static const livree       = Color(0xFF4CAF50);
  static const annulee      = Color(0xFFEF5350);

  // ── Light Theme ─────────────────────────────────────────────────
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        error: error,
        surface: const Color(0xFFF8F9FE),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      fontFamily: 'Poppins',

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A2E),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEEEEF5), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEEEF5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFF9E9EAF),
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFBDBDCC),
          fontSize: 14,
        ),
        prefixIconColor: const Color(0xFF9E9EAF),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        
      ),

      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black12,
        indicatorColor: primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Color(0xFF9E9EAF),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF9E9EAF), size: 24);
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F5FA),
        selectedColor: primary.withOpacity(0.15),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEF5),
        thickness: 1,
        space: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),

      // List Tile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 32),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 28),
        displaySmall:  TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 24),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 22),
        headlineMedium:TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge:    TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium:   TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14),
        titleSmall:    TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13),
        bodyLarge:     TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 16),
        bodyMedium:    TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall:     TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge:    TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium:   TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall:    TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 11),
      ),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────────────
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        error: error,
        surface: const Color(0xFF1A1A2E),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      fontFamily: 'Poppins',

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A40), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252538),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A40), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6E6E8F), fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFF4A4A6A), fontSize: 14),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 8,
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Color(0xFF6E6E8F),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF6E6E8F), size: 24);
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A40),
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Responsive Helpers ─────────────────────────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return w * 0.15;
    if (w >= 600)  return 32;
    return 16;
  }

  // ── Status Color Helpers ───────────────────────────────────────
  static Color statutColor(String statut) {
    switch (statut) {
      case 'confirmee': return confirmee;
      case 'livree':    return livree;
      case 'annulee':   return annulee;
      default:          return enAttente;
    }
  }

  static Color statutBgColor(String statut) =>
      statutColor(statut).withOpacity(0.12);
}