import '../schema/models.dart';

/// Grammar-based deterministic rule parser for Argus.
/// Serves as the zero-latency, offline, and quota-independent parser fallback.
class GrammarParser {
  const GrammarParser();

  /// Parse a natural language safety sentence against optional known zones and cameras.
  ParseResult parse(
    String sentence, {
    List<Zone> knownZones = const [],
    List<Camera> knownCameras = const [],
  }) {
    final raw = sentence.trim();
    final lower = raw.toLowerCase();
    final warnings = <String>[];

    if (raw.isEmpty) {
      return const ParseResult(
        parsedBy: 'grammar',
        confidence: 0.0,
        unsupportedReason: 'Sentence is empty',
      );
    }

    // 1. Detect Trigger Signal & Zone
    TriggerSignal? signal;
    int minDurationSec = 0;
    int? minCount;
    String? ppe;
    int? matchedZoneId;
    String? matchedZoneName;

    // Search for zone in sentence (full name or distinctive keywords)
    for (final zone in knownZones) {
      final zNameLower = zone.name.toLowerCase();
      if (lower.contains(zNameLower)) {
        matchedZoneId = zone.id;
        matchedZoneName = zone.name;
        break;
      }
      final tokens = zNameLower.split(RegExp(r'\s+')).where((t) => t.length >= 4 && t != 'zone' && t != 'area');
      for (final tok in tokens) {
        if (lower.contains(tok)) {
          matchedZoneId = zone.id;
          matchedZoneName = zone.name;
          break;
        }
      }
      if (matchedZoneId != null) break;
    }

    // Signal pattern 1: PPE / Helmet check
    if (lower.contains('helmet') || lower.contains('ppe') || lower.contains('hard hat')) {
      signal = TriggerSignal.ppe_check;
      ppe = 'helmet';
    }
    // Signal pattern 2: Fall suspected
    else if (lower.contains('fall') || lower.contains('falls') || lower.contains('fallen') || lower.contains('stays down') || lower.contains('collapsed') || lower.contains('trips') || lower.contains('tumble') || lower.contains('lies down')) {
      signal = TriggerSignal.fall_suspected;
      const numPattern = r'(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|fifteen|twenty|thirty|forty|fifty|sixty)';
      final staysDownMatch = RegExp(
        r"(?:stays down|does not get up|doesn't get up|doesn't gets up|fails to get up|fails to stand|doesn't stand|unable to get up|remains down|unresponsive|within|for)\s*(?:for\s*)?(?:more than\s*|over\s*|within\s*)?" + numPattern + r"\s*(?:s|sec|seconds?)",
      ).firstMatch(lower);
      if (staysDownMatch != null) {
        minDurationSec = _parseNumber(staysDownMatch.group(1)) ?? 0;
      } else {
        // Check for general "within/for X seconds" anywhere
        final generalSecMatch = RegExp(r'(?:within|for|after)\s+' + numPattern + r'\s*(?:s|sec|seconds?)').firstMatch(lower);
        if (generalSecMatch != null) {
          minDurationSec = _parseNumber(generalSecMatch.group(1)) ?? 0;
        }
      }
      // Safe default: if user explicitly expressed non-recovery ("doesn't gets up", "stays down") without number, default to 3s
      if (minDurationSec == 0 && (lower.contains('get up') || lower.contains('gets up') || lower.contains('stays down') || lower.contains('remains down'))) {
        minDurationSec = 3;
      }
    }
    // Signal pattern 3: Motionless / No one moves
    else if (lower.contains('no one moves') || lower.contains('motionless') || lower.contains('unmoving') || lower.contains('stationary')) {
      signal = TriggerSignal.motionless;
      const numPattern = r'(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|fifteen|twenty|thirty|forty|fifty|sixty)';
      final motionMatch = RegExp(r'(?:for|over)\s+(?:more than\s*)?' + numPattern + r'\s*(?:s|sec|seconds?)').firstMatch(lower);
      if (motionMatch != null) {
        minDurationSec = _parseNumber(motionMatch.group(1)) ?? 10;
      } else {
        minDurationSec = 10;
      }
    }
    // Signal pattern 4: Person count / Crowd
    else if (RegExp(r'(?:more than|over|exceeds|at least)\s+(?:\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten)\s+(?:people|persons)').hasMatch(lower) || lower.contains('crowd')) {
      signal = TriggerSignal.person_count;
      const numPattern = r'(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten)';
      final countMatch = RegExp(r'(?:more than|over|exceeds|at least)\s+' + numPattern).firstMatch(lower);
      if (countMatch != null) {
        minCount = _parseNumber(countMatch.group(1)) ?? 3;
      } else {
        minCount = 3;
      }
    }
    // Signal pattern 5: Zone dwell (stays in zone for N seconds)
    else if (lower.contains('stays in') || lower.contains('dwells in') || lower.contains('remains in') || lower.contains('loiter')) {
      signal = TriggerSignal.person_in_zone;
      const numPattern = r'(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|fifteen|twenty|thirty|forty|fifty|sixty)';
      final dwellMatch = RegExp(r'(?:for|over|after)\s+(?:more than\s*)?' + numPattern + r'\s*(?:s|sec|seconds?)').firstMatch(lower);
      if (dwellMatch != null) {
        minDurationSec = _parseNumber(dwellMatch.group(1)) ?? 0;
      }
    }
    // Signal pattern 6: Zone entry / intrusion
    else if (lower.contains('enters') || lower.contains('enter') || lower.contains('in the') || lower.contains('trespass') || lower.contains('steps into')) {
      signal = TriggerSignal.person_in_zone;
    }

    if (signal == null) {
      return ParseResult(
        parsedBy: 'grammar',
        confidence: 0.1,
        unsupportedReason: 'Could not determine trigger signal (e.g. entry, fall, dwell, motionless, or PPE check)',
        alternatives: const [
          'If someone enters the restricted zone, alert supervisor',
          'If someone falls and stays down for 10 seconds, create critical incident',
          'If a person stays in red zone for more than 5 seconds, sound alarm',
        ],
      );
    }

    // Zone inference fallback if not strictly named
    if (matchedZoneId == null && knownZones.isNotEmpty) {
      if (lower.contains('zone') || lower.contains('area') || lower.contains('lab') || lower.contains('room')) {
        matchedZoneId = knownZones.first.id;
        matchedZoneName = knownZones.first.name;
        warnings.add('Assumed zone "${matchedZoneName}" (ID $matchedZoneId)');
      }
    }

    // 2. Detect Severity
    Severity severity = Severity.medium;
    if (lower.contains('critical') || lower.contains('urgent') || lower.contains('siren') || lower.contains('emergency')) {
      severity = Severity.critical;
    } else if (lower.contains('high') || lower.contains('danger') || lower.contains('immediate')) {
      severity = Severity.high;
    } else if (lower.contains('low') || lower.contains('info') || lower.contains('log only')) {
      severity = Severity.low;
    } else if (signal == TriggerSignal.fall_suspected) {
      severity = Severity.high;
    }

    // 3. Detect Conditions (Time Windows & Days)
    final timeWindows = <TimeWindow>[];
    final daysOfWeek = <int>[];

    // After hours / night / working hours
    if (lower.contains('after 8 pm') || lower.contains('after 20:00')) {
      timeWindows.add(const TimeWindow(start: '20:00', end: '06:00'));
    } else if (lower.contains('at night') || lower.contains('overnight')) {
      timeWindows.add(const TimeWindow(start: '22:00', end: '06:00'));
    } else if (lower.contains('outside working hours') || lower.contains('after hours')) {
      timeWindows.add(const TimeWindow(start: '18:00', end: '09:00'));
    } else if (lower.contains('before 6 am')) {
      timeWindows.add(const TimeWindow(start: '00:00', end: '06:00'));
    }

    // Parse generic "between X and Y"
    final betweenMatch = RegExp(r'between\s+(\d{1,2}(?::\d{2})?\s*(?:am|pm)?)\s+and\s+(\d{1,2}(?::\d{2})?\s*(?:am|pm)?)').firstMatch(lower);
    if (betweenMatch != null) {
      final startFormatted = _normalizeTime(betweenMatch.group(1)!);
      final endFormatted = _normalizeTime(betweenMatch.group(2)!);
      timeWindows.add(TimeWindow(start: startFormatted, end: endFormatted));
    }

    if (lower.contains('weekdays')) {
      daysOfWeek.addAll([1, 2, 3, 4, 5]);
    } else if (lower.contains('weekends')) {
      daysOfWeek.addAll([6, 7]);
    }

    // 4. Detect Actions
    final actions = <RuleAction>[];
    actions.add(const RuleAction(kind: 'create_incident'));
    actions.add(const RuleAction(kind: 'in_app'));

    if (lower.contains('snapshot') || lower.contains('photo') || lower.contains('evidence')) {
      actions.add(const RuleAction(kind: 'snapshot'));
    }
    if (lower.contains('telegram') || lower.contains('telegram message')) {
      actions.add(const RuleAction(kind: 'telegram'));
    }
    if (lower.contains('browser') || lower.contains('push notification')) {
      actions.add(const RuleAction(kind: 'browser'));
    }

    // 5. Detect Escalation
    final escalation = <RuleEscalation>[];
    final escMatch = RegExp(r'escalate (?:after|in) (\d+)\s*(seconds?|s|minutes?|m|mins?)').firstMatch(lower);
    if (escMatch != null) {
      int amount = int.parse(escMatch.group(1)!);
      final unit = escMatch.group(2)!;
      int sec = unit.startsWith('m') ? amount * 60 : amount;
      escalation.add(RuleEscalation(
        afterSec: sec,
        notify: 'Security Lead',
        message: 'Unacknowledged incident: $raw',
      ));
    } else if (severity == Severity.critical || signal == TriggerSignal.fall_suspected) {
      escalation.add(const RuleEscalation(
        afterSec: 120,
        notify: 'Supervisor',
        message: 'Incident unacknowledged after 2 minutes',
      ));
    }

    // 6. Build RuleSpec
    final ruleName = _deriveRuleName(signal, matchedZoneName, severity);
    final spec = RuleSpec(
      id: 0,
      workspaceId: 0,
      name: ruleName,
      enabled: true,
      cameraIds: knownCameras.isNotEmpty ? [knownCameras.first.id] : [1],
      trigger: RuleTrigger(
        signal: signal,
        zoneId: matchedZoneId,
        minDurationSec: minDurationSec,
        minConfidence: 0.60,
        minCount: minCount,
        ppe: ppe,
      ),
      conditions: RuleConditions(
        timeWindows: timeWindows,
        daysOfWeek: daysOfWeek,
        timezone: 'UTC',
      ),
      severity: severity,
      verify: RuleVerify(
        enabled: signal == TriggerSignal.ppe_check,
        kind: ppe ?? (signal == TriggerSignal.fall_suspected ? 'person_down' : 'generic'),
      ),
      actions: actions,
      cooldownSec: 60,
      escalation: escalation,
      sourceText: raw,
      parsedBy: 'grammar',
      createdAt: DateTime.now(),
      version: 1,
    );

    double confidence = 0.85;
    if (matchedZoneId == null && (signal == TriggerSignal.person_in_zone || signal == TriggerSignal.ppe_check)) {
      confidence = 0.65;
      warnings.add('No target zone specified. Rule will evaluate across entire camera frame.');
    }

    return ParseResult(
      spec: spec,
      parsedBy: 'grammar',
      confidence: confidence,
      warnings: warnings,
    );
  }

  String _normalizeTime(String raw) {
    var t = raw.trim().toLowerCase();
    bool isPm = t.contains('pm');
    bool isAm = t.contains('am');
    t = t.replaceAll('am', '').replaceAll('pm', '').trim();

    int hour = 0;
    int minute = 0;
    if (t.contains(':')) {
      final parts = t.split(':');
      hour = int.tryParse(parts[0]) ?? 0;
      minute = int.tryParse(parts[1]) ?? 0;
    } else {
      hour = int.tryParse(t) ?? 0;
    }

    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;

    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _deriveRuleName(TriggerSignal signal, String? zoneName, Severity severity) {
    final prefix = severity == Severity.critical
        ? 'Critical'
        : severity == Severity.high
            ? 'High'
            : 'Standard';

    switch (signal) {
      case TriggerSignal.fall_suspected:
        return '$prefix: Fall Detected${zoneName != null ? ' in $zoneName' : ''}';
      case TriggerSignal.person_in_zone:
        return '$prefix: Zone Entry${zoneName != null ? ' ($zoneName)' : ''}';
      case TriggerSignal.motionless:
        return '$prefix: Inactivity Monitor${zoneName != null ? ' in $zoneName' : ''}';
      case TriggerSignal.person_count:
        return '$prefix: Crowd Threshold Exceeded';
      case TriggerSignal.ppe_check:
        return '$prefix: PPE Non-compliance Check';
    }
  }

  static int? _parseNumber(String? str) {
    if (str == null) return null;
    final s = str.trim().toLowerCase();
    final asInt = int.tryParse(s);
    if (asInt != null) return asInt;
    const wordMap = {
      'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
      'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9,
      'ten': 10, 'eleven': 11, 'twelve': 12, 'thirteen': 13,
      'fourteen': 14, 'fifteen': 15, 'sixteen': 16, 'seventeen': 17,
      'eighteen': 18, 'nineteen': 19, 'twenty': 20, 'thirty': 30,
      'forty': 40, 'fifty': 50, 'sixty': 60,
    };
    return wordMap[s];
  }
}

