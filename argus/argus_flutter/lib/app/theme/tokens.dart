import 'package:flutter/material.dart';

/// Design tokens for Argus Control Room theme.
/// Normative specifications from plan.md § 9.3.
class ArgusTokens {
  // Dark Palette (Default)
  static const Color bgBase = Color(0xFF0B0E13);
  static const Color bgRaised = Color(0xFF11161E);
  static const Color bgOverlay = Color(0xFF171D27);
  static const Color borderSubtle = Color(0xFF212A37);
  static const Color borderStrong = Color(0xFF2E3A4B);

  static const Color textPrimary = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFFA1AEC2);
  static const Color textTertiary = Color(0xFF6A778B);

  // Accents
  static const Color accent = Color(0xFF38BDF8); // Electric Sky / Cyan
  static const Color accentInk = Color(0xFF031A26);
  static const Color accentGlow = Color(0x3338BDF8);
  static const Color focusRing = Color(0xFF38BDF8);

  // States
  static const Color success = Color(0xFF34D399); // Emerald
  static const Color info = Color(0xFF60A5FA);

  // Severity Scale
  static const Color severityLow = Color(0xFF60A5FA);
  static const Color severityMedium = Color(0xFFFBBF24); // Amber
  static const Color severityHigh = Color(0xFFFB923C);   // Orange
  static const Color severityCritical = Color(0xFFF43F5E); // Crimson Rose

  // Status Colors
  static const Color statusOpen = Color(0xFF38BDF8);
  static const Color statusAcknowledged = Color(0xFFFBBF24);
  static const Color statusResolved = Color(0xFF34D399);
  static const Color statusFalsePositive = Color(0xFF6A778B);

  // Zone Colors
  static const Color zoneRestricted = Color(0xFFF43F5E);
  static const Color zoneWork = Color(0xFFFBBF24);
  static const Color zoneStairs = Color(0xFFA78BFA);
  static const Color zoneCustom = Color(0xFF2DD4BF);

  // Spacing Grid
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;

  // Radii
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Light Palette Alternatives
  static const Color lightBgBase = Color(0xFFF5F7FA);
  static const Color lightBgRaised = Color(0xFFFFFFFF);
  static const Color lightBgOverlay = Color(0xFFF0F4F8);
  static const Color lightBorderSubtle = Color(0xFFE2E8F0);
  static const Color lightBorderStrong = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0E1520);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
}
