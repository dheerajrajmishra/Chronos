import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnterpriseTheme {
  // ─── Dark Mode Surfaces ───────────────────────────────────────────
  static const Color darkBackground = Color(0xFF09090B);
  static const Color darkSurface = Color(0xFF0F1117);
  static const Color darkCardBg = Color(0xFF141519);
  static const Color darkCardBgElevated = Color(0xFF1A1B23);
  static const Color darkCardBorder = Color(0xFF27272A);
  static const Color darkCardBorderHighlight = Color(0xFF3B82F6);
  static const Color darkInputBg = Color(0xFF0C0D12);
  static const Color darkSubtleBg = Color(0xFF18181B);

  // ─── Light Mode Surfaces ──────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightCardBgElevated = Color(0xFFF4F4F5);
  static const Color lightCardBorder = Color(0xFFE4E4E7);
  static const Color lightCardBorderHighlight = Color(0xFF2563EB);
  static const Color lightInputBg = Color(0xFFFAFAFA);
  static const Color lightSubtleBg = Color(0xFFF4F4F5);

  // ─── Backwards-compatible aliases (dark default) ──────────────────
  static const Color background = darkBackground;
  static const Color surfaceDark = darkSurface;
  static const Color cardBg = darkCardBg;
  static const Color cardBgElevated = darkCardBgElevated;
  static const Color cardBorder = darkCardBorder;
  static const Color cardBorderHighlight = darkCardBorderHighlight;

  // ─── Accent Palette ───────────────────────────────────────────────
  static const Color cyan = Color(0xFF38BDF8);
  static const Color cyanDark = Color(0xFF0EA5E9);
  static const Color cyanGlow = Color(0xFF7DD3FC);
  static const Color emerald = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldGlow = Color(0xFF6EE7B7);
  static const Color amber = Color(0xFFFBBF24);
  static const Color amberDark = Color(0xFFD97706);
  static const Color rose = Color(0xFFFB7185);
  static const Color roseDark = Color(0xFFE11D48);
  static const Color purple = Color(0xFFA78BFA);
  static const Color purpleDark = Color(0xFF7C3AED);
  static const Color indigo = Color(0xFF818CF8);

  // ─── Brand Colors ─────────────────────────────────────────────────
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color brandBlueDark = Color(0xFF2563EB);

  // ─── Text Colors ──────────────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextMuted = Color(0xFF71717A);

  static const Color lightTextPrimary = Color(0xFF09090B);
  static const Color lightTextSecondary = Color(0xFF52525B);
  static const Color lightTextMuted = Color(0xFFA1A1AA);

  // Fallback aliases
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;
  static const Color textAccent = Color(0xFF38BDF8);

  // ─── Dynamic Theme Getters ────────────────────────────────────────
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
  static Color getPrimaryAccent(bool isDark) => isDark ? brandBlue : brandBlueDark;
  static Color getEmeraldAccent(bool isDark) => isDark ? emerald : emeraldDark;

  // ─── Gradients ────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF141519), Color(0xFF0F1117)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Dynamic Box Decorations ──────────────────────────────────────
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
                    color: (borderColor ?? accent).withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 0,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ])
          : (glow
              ? [
                  BoxShadow(
                    color: (borderColor ?? accent).withValues(alpha: 0.12),
                    blurRadius: 16,
                    spreadRadius: 0,
                  )
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF71717A).withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
    double radius = 6,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.12 : 0.08),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.25)),
    );
  }

  static BoxDecoration terminalDecoration({bool isDark = true}) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF09090B) : const Color(0xFF18181B),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: isDark ? const Color(0xFF27272A) : const Color(0xFF3F3F46)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  // ─── Typography Helper ────────────────────────────────────────────
  static TextStyle _inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ─── Dark Theme Data ──────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: brandBlue,
      colorScheme: const ColorScheme.dark(
        primary: brandBlue,
        secondary: emerald,
        surface: darkSurface,
        error: roseDark,
      ),
      textTheme: TextTheme(
        headlineLarge: _inter(color: darkTextPrimary, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: _inter(color: darkTextPrimary, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        headlineSmall: _inter(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: _inter(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: _inter(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: _inter(color: darkTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: _inter(color: darkTextPrimary, fontSize: 14),
        bodyMedium: _inter(color: darkTextSecondary, fontSize: 13),
        bodySmall: _inter(color: darkTextMuted, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _inter(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
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
          borderSide: const BorderSide(color: brandBlue, width: 1.5),
        ),
        hintStyle: _inter(color: darkTextMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // ─── Light Theme Data ─────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: brandBlueDark,
      colorScheme: const ColorScheme.light(
        primary: brandBlueDark,
        secondary: emeraldDark,
        surface: lightSurface,
        error: roseDark,
      ),
      textTheme: TextTheme(
        headlineLarge: _inter(color: lightTextPrimary, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: _inter(color: lightTextPrimary, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        headlineSmall: _inter(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: _inter(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: _inter(color: lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: _inter(color: lightTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: _inter(color: lightTextPrimary, fontSize: 14),
        bodyMedium: _inter(color: lightTextSecondary, fontSize: 13),
        bodySmall: _inter(color: lightTextMuted, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: lightTextPrimary),
        titleTextStyle: _inter(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
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
          borderSide: const BorderSide(color: brandBlueDark, width: 1.5),
        ),
        hintStyle: _inter(color: lightTextMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
