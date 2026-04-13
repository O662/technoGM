import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnoColors {
  TechnoColors._();

  static const Color bgPrimary = Color(0xFF050510);
  static const Color bgSecondary = Color(0xFF0A0A1E);
  static const Color bgTertiary = Color(0xFF0F1030);
  static const Color cardBg = Color(0xFF0D0D25);
  static const Color cardBorder = Color(0xFF1A2050);

  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPurple = Color(0xFF7B2FFF);
  static const Color neonYellow = Color(0xFFFFE600);
  static const Color neonOrange = Color(0xFFFF6B00);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8890B5);
  static const Color textMuted = Color(0xFF444466);

  static const Color success = neonGreen;
  static const Color warning = neonYellow;
  static const Color error = neonPink;
  static const Color info = neonCyan;
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TechnoColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: TechnoColors.neonCyan,
        secondary: TechnoColors.neonPink,
        tertiary: TechnoColors.neonGreen,
        surface: TechnoColors.bgSecondary,
        error: TechnoColors.neonPink,
        onPrimary: TechnoColors.bgPrimary,
        onSecondary: TechnoColors.bgPrimary,
        onSurface: TechnoColors.textPrimary,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: TechnoColors.bgPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          color: TechnoColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: TechnoColors.neonCyan),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: TechnoColors.bgSecondary,
        indicatorColor: TechnoColors.neonCyan.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.rajdhani(
              color: TechnoColors.neonCyan,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            );
          }
          return GoogleFonts.rajdhani(
            color: TechnoColors.textMuted,
            fontSize: 11,
            letterSpacing: 1,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: TechnoColors.neonCyan, size: 24);
          }
          return const IconThemeData(color: TechnoColors.textMuted, size: 22);
        }),
      ),
      cardTheme: CardThemeData(
        color: TechnoColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TechnoColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TechnoColors.bgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TechnoColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TechnoColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TechnoColors.neonCyan, width: 1.5),
        ),
        labelStyle: GoogleFonts.rajdhani(color: TechnoColors.textSecondary),
        hintStyle: GoogleFonts.rajdhani(color: TechnoColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: TechnoColors.neonCyan,
        thumbColor: TechnoColors.neonCyan,
        overlayColor: Color(0x2200F5FF),
        inactiveTrackColor: TechnoColors.cardBorder,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? TechnoColors.neonCyan : TechnoColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected)
                  ? TechnoColors.neonCyan.withValues(alpha: 0.3)
                  : TechnoColors.cardBorder,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? TechnoColors.neonCyan : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(TechnoColors.bgPrimary),
        side: const BorderSide(color: TechnoColors.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dividerTheme: const DividerThemeData(
        color: TechnoColors.cardBorder,
        thickness: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TechnoColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TechnoColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: TechnoColors.cardBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TechnoColors.bgTertiary,
        contentTextStyle: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.orbitron(
        color: TechnoColors.textPrimary,
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
      ),
      displayMedium: GoogleFonts.orbitron(
        color: TechnoColors.textPrimary,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: 3,
      ),
      displaySmall: GoogleFonts.orbitron(
        color: TechnoColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
      headlineLarge: GoogleFonts.orbitron(
        color: TechnoColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
      headlineMedium: GoogleFonts.orbitron(
        color: TechnoColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
      headlineSmall: GoogleFonts.orbitron(
        color: TechnoColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
      titleLarge: GoogleFonts.rajdhani(
        color: TechnoColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      titleMedium: GoogleFonts.rajdhani(
        color: TechnoColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.rajdhani(
        color: TechnoColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      bodyLarge: GoogleFonts.rajdhani(
        color: TechnoColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.rajdhani(
        color: TechnoColors.textSecondary,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.rajdhani(
        color: TechnoColors.textMuted,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.rajdhani(
        color: TechnoColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
      labelMedium: GoogleFonts.rajdhani(
        color: TechnoColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
      labelSmall: GoogleFonts.rajdhani(
        color: TechnoColors.textMuted,
        fontSize: 10,
        letterSpacing: 1,
      ),
    );
  }
}
