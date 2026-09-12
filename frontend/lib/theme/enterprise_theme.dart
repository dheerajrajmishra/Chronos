import 'package:flutter/material.dart';

class EnterpriseTheme {
  // Brand Dark Colors (Ultra-sleek High-Tech Cyberpunk HUD)
  static const Color darkBackground = Color(0xFF0A0E17);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCardBg = Color(0xFF161F30);
  static const Color darkCardBgElevated = Color(0xFF1E293B);
  static const Color darkCardBorder = Color(0xFF2D3748);
  static const Color darkCardBorderHighlight = Color(0xFF3B82F6);
  static const Color darkInputBg = Color(0xFF0F172A);
  static const Color darkSubtleBg = Color(0xFF1E293B);

  // Brand Light Colors (Clean, Modern Enterprise Slate & Crisp White)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightCardBgElevated = Color(0xFFF1F5F9);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightCardBorderHighlight = Color(0xFF0284C7);
  static const Color lightInputBg = Color(0xFFF8FAFC);
  static const Color lightSubtleBg = Color(0xFFF1F5F9);

  // Fallback / Default Dark Constants (for backwards compatibility)
  static const Color background = darkBackground;
  static const Color surfaceDark = darkSurface;
  static const Color cardBg = darkCardBg;
  static const Color cardBgElevated = darkCardBgElevated;
  static const Color cardBorder = darkCardBorder;
  static const Color cardBorderHighlight = darkCardBorderHighlight;

  // Accents (High-contrast for both dark and light modes)
  static const Color cyan = Color(0xFF00F2FE);
  static const Color cyanDark = Color(0xFF0284C7);
  static const Color cyanGlow = Color(0xFF4FACFE);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldGlow = Color(0xFF34D399);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFFD97706);
  static const Color rose = Color(0xFFEF4444);
  static const Color roseDark = Color(0xFFDC2626);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF7C3AED);
  static const Color indigo = Color(0xFF6366F1);

  // Text Colors Dark
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Text Colors Light
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Fallback Text Colors
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;
  static const Color textAccent = Color(0xFF38BDF8);

  // Dynamic Theme Getters
  static Color getBackground(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getCardBg(bool isDark) => isDark ? darkCardBg : lightCardBg;
  static Color getCardBgElevated(bool isDark) => isDark ? darkCardBgElevated : lightCardBgElevated;
  static Color getCardBorder(bool isDark) => isDark ? darkCardBorder : lightCardBorder;
  static Color getInputBg(bool isDark) => isDark ? darkInputBg : lightInputBg;
  static Color getSubtleBg(bool isDark) => isDark ? darkSubtleBg : lightSubtleBg;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getTextMuted(bool isDark) => isDark ? darkTextMuted : lightTextMuted;
  static Color getPrimaryAccent(bool isDark) => isDark ? cyan : cyanDark;
  static Color getEmeraldAccent(bool isDark) => isDark ? emerald : emeraldDark;

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

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dynamic Box Decorations
  static BoxDecoration cardDecoration({
    bool isDark = true,
    Color? borderColor,
    bool glow = false,
    double radius = 12,
  }) {
    final border = borderColor ?? getCardBorder(isDark);
    final accent = getPrimaryAccent(isDark);

    return BoxDecoration(
      color: getCardBg(isDark),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: border,
        width: glow ? 1.5 : 1.0,
      ),
      boxShadow: isDark
          ? (glow
              ? [
                  BoxShadow(
                    color: (borderColor ?? accent).withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ])
          : (glow
              ? [
                  BoxShadow(
                    color: (borderColor ?? accent).withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF64748B).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]),
    );
  }

  static BoxDecoration panelDecoration({
    bool isDark = true,
    Color? borderColor,
    double radius = 10,
  }) {
    return BoxDecoration(
      color: getInputBg(isDark),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? getCardBorder(isDark)),
    );
  }

  static BoxDecoration badgeDecoration({
    bool isDark = true,
    required Color color,
    double radius = 4,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.15 : 0.12),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.35)),
    );
  }

  static BoxDecoration terminalDecoration({bool isDark = true}) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF06090F) : const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFF334155)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: cyan,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: emerald,
        surface: darkSurface,
        error: rose,
      ),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkTextPrimary, fontSize: 26, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: darkTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 13),
        bodySmall: TextStyle(color: darkTextMuted, fontSize: 11),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cyan, width: 1.5),
        ),
        hintStyle: const TextStyle(color: darkTextMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // Light Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: cyanDark,
      colorScheme: const ColorScheme.light(
        primary: cyanDark,
        secondary: emeraldDark,
        surface: lightSurface,
        error: roseDark,
      ),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: lightTextPrimary, fontSize: 26, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: lightTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: lightTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 13),
        bodySmall: TextStyle(color: lightTextMuted, fontSize: 11),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cyanDark, width: 1.5),
        ),
        hintStyle: const TextStyle(color: lightTextMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
