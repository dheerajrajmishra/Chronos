import 'package:flutter/material.dart';

class EnterpriseTheme {
  // Brand & Background Colors
  static const Color background = Color(0xFF0A0E17);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardBg = Color(0xFF161F30);
  static const Color cardBgElevated = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF2D3748);
  static const Color cardBorderHighlight = Color(0xFF3B82F6);

  // Accents
  static const Color cyan = Color(0xFF00F2FE);
  static const Color cyanGlow = Color(0xFF4FACFE);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldGlow = Color(0xFF34D399);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFEF4444);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color indigo = Color(0xFF6366F1);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textAccent = Color(0xFF38BDF8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF151D2E), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Box Decorations
  static BoxDecoration cardDecoration({
    Color? borderColor,
    bool glow = false,
    double radius = 12,
  }) {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? cardBorder,
        width: glow ? 1.5 : 1.0,
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: (borderColor ?? cyan).withOpacity(0.15),
                blurRadius: 16,
                spreadRadius: 2,
              )
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
    );
  }

  static BoxDecoration terminalDecoration() {
    return BoxDecoration(
      color: const Color(0xFF06090F),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF1E293B)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 12,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: cyan,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: emerald,
        surface: surfaceDark,
        error: rose,
      ),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontSize: 26, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: textMuted, fontSize: 11),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cyan, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
