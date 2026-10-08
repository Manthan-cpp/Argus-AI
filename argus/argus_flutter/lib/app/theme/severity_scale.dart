import 'package:flutter/material.dart';
import 'tokens.dart';

/// Semantic severity helper ensuring color + icon + label are never separated.
/// Normative guideline: Never rely on color alone.
enum SeverityLevel {
  low,
  medium,
  high,
  critical;

  static SeverityLevel fromString(String val) {
    switch (val.toLowerCase()) {
      case 'critical':
        return SeverityLevel.critical;
      case 'high':
        return SeverityLevel.high;
      case 'medium':
        return SeverityLevel.medium;
      case 'low':
      default:
        return SeverityLevel.low;
    }
  }

  Color get color {
    switch (this) {
      case SeverityLevel.low:
        return ArgusTokens.severityLow;
      case SeverityLevel.medium:
        return ArgusTokens.severityMedium;
      case SeverityLevel.high:
        return ArgusTokens.severityHigh;
      case SeverityLevel.critical:
        return ArgusTokens.severityCritical;
    }
  }

  IconData get icon {
    switch (this) {
      case SeverityLevel.low:
        return Icons.info_outline_rounded;
      case SeverityLevel.medium:
        return Icons.warning_amber_rounded;
      case SeverityLevel.high:
        return Icons.error_outline_rounded;
      case SeverityLevel.critical:
        return Icons.notification_important_rounded;
    }
  }

  String get label {
    switch (this) {
      case SeverityLevel.low:
        return 'LOW';
      case SeverityLevel.medium:
        return 'MEDIUM';
      case SeverityLevel.high:
        return 'HIGH';
      case SeverityLevel.critical:
        return 'CRITICAL';
    }
  }
}
