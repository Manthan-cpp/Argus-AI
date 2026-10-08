import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

class ArgusTheme {
  static ThemeData darkTheme() {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.sora(fontSize: 48, fontWeight: FontWeight.w700, color: ArgusTokens.textPrimary),
      displayMedium: GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
      headlineMedium: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
      titleLarge: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: ArgusTokens.textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: ArgusTokens.textSecondary),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: ArgusTokens.textTertiary),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
      labelSmall: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w500, color: ArgusTokens.textTertiary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ArgusTokens.bgBase,
      canvasColor: ArgusTokens.bgRaised,
      cardColor: ArgusTokens.bgRaised,
      dividerColor: ArgusTokens.borderSubtle,
      colorScheme: const ColorScheme.dark(
        primary: ArgusTokens.accent,
        onPrimary: ArgusTokens.accentInk,
        surface: ArgusTokens.bgRaised,
        onSurface: ArgusTokens.textPrimary,
        outline: ArgusTokens.borderSubtle,
        outlineVariant: ArgusTokens.borderStrong,
        error: ArgusTokens.severityCritical,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: ArgusTokens.bgRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
          side: const BorderSide(color: ArgusTokens.borderSubtle, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ArgusTokens.bgOverlay,
        hintStyle: GoogleFonts.inter(color: ArgusTokens.textTertiary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
          borderSide: const BorderSide(color: ArgusTokens.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
          borderSide: const BorderSide(color: ArgusTokens.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
          borderSide: const BorderSide(color: ArgusTokens.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ArgusTokens.accent,
          foregroundColor: ArgusTokens.accentInk,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ArgusTokens.radiusSm)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ArgusTokens.textPrimary,
          side: const BorderSide(color: ArgusTokens.borderStrong),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ArgusTokens.radiusSm)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ArgusTokens.bgOverlay,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
        side: const BorderSide(color: ArgusTokens.borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ArgusTokens.radiusSm)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ArgusTokens.bgOverlay,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ArgusTokens.borderStrong),
        ),
        textStyle: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textPrimary),
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ArgusTokens.lightBgBase,
      canvasColor: ArgusTokens.lightBgRaised,
      cardColor: ArgusTokens.lightBgRaised,
      dividerColor: ArgusTokens.lightBorderSubtle,
      colorScheme: const ColorScheme.light(
        primary: ArgusTokens.accent,
        surface: ArgusTokens.lightBgRaised,
        onSurface: ArgusTokens.lightTextPrimary,
        outline: ArgusTokens.lightBorderSubtle,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }
}
