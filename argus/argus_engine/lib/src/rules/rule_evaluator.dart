import '../schema/models.dart';

enum RuleEngineStateKind { idle, armed, fired, cooldown }

class RuleState {
  final int ruleId;
  final int cameraId;
  final RuleEngineStateKind state;
  final int? armedSinceMs;
  final int? firedAtMs;
  final int? cooldownUntilMs;
  final int? activeIncidentId;
  final int? lastInactiveMs;

  const RuleState({
    required this.ruleId,
    required this.cameraId,
    this.state = RuleEngineStateKind.idle,
    this.armedSinceMs,
    this.firedAtMs,
    this.cooldownUntilMs,
    this.activeIncidentId,
    this.lastInactiveMs,
  });

  RuleState copyWith({
    RuleEngineStateKind? state,
    int? armedSinceMs,
    int? firedAtMs,
    int? cooldownUntilMs,
    int? activeIncidentId,
    int? lastInactiveMs,
    bool clearArmedSince = false,
  }) {
    return RuleState(
      ruleId: ruleId,
      cameraId: cameraId,
      state: state ?? this.state,
      armedSinceMs: clearArmedSince ? null : (armedSinceMs ?? this.armedSinceMs),
      firedAtMs: firedAtMs ?? this.firedAtMs,
      cooldownUntilMs: cooldownUntilMs ?? this.cooldownUntilMs,
      activeIncidentId: activeIncidentId ?? this.activeIncidentId,
      lastInactiveMs: lastInactiveMs ?? this.lastInactiveMs,
    );
  }
}

sealed class RuleEffect {
  const RuleEffect();
}

class OpenIncidentEffect extends RuleEffect {
  final RuleSpec rule;
  final int cameraId;
  final String summary;
  final Map<String, dynamic> signalContext;
  final bool requestEvidence;

  const OpenIncidentEffect({
    required this.rule,
    required this.cameraId,
    required this.summary,
    required this.signalContext,
    this.requestEvidence = true,
  });
}

class AppendEventEffect extends RuleEffect {
  final int incidentId;
  final String kind;
  final String detail;

  const AppendEventEffect({
    required this.incidentId,
    required this.kind,
    required this.detail,
  });
}

class NotifyEffect extends RuleEffect {
  final String channel;
  final String message;
  final Severity severity;

  const NotifyEffect({
    required this.channel,
    required this.message,
    required this.severity,
  });
}

class RuleEvaluationResult {
  final RuleState newState;
  final List<RuleEffect> effects;

  const RuleEvaluationResult({
    required this.newState,
    this.effects = const [],
  });
}

/// Deterministic Rule Evaluator for Argus
class RuleEvaluator {
  const RuleEvaluator();

  /// Evaluate a single rule against a camera signal batch
  RuleEvaluationResult evaluate({
    required RuleSpec rule,
    required RuleState currentState,
    required SignalBatch batch,
    required DateTime now,
  }) {
    final effects = <RuleEffect>[];
    final nowMs = batch.sentAtMs > 0 ? batch.sentAtMs : now.millisecondsSinceEpoch;

    // Check time condition (windows & days of week)
    if (!_isTimeConditionMet(rule.conditions, now)) {
      return RuleEvaluationResult(
        newState: currentState.state == RuleEngineStateKind.armed
            ? currentState.copyWith(state: RuleEngineStateKind.idle, clearArmedSince: true)
            : currentState,
      );
    }

    // Check if the signal trigger condition is currently satisfied by any person in the batch
    final triggerActive = _isTriggerConditionSatisfied(rule.trigger, batch);

    // State Machine Transitions
    switch (currentState.state) {
      case RuleEngineStateKind.idle:
        if (triggerActive) {
          final minDurationMs = rule.trigger.minDurationSec * 1000;
          if (minDurationMs <= 0) {
            // Immediate fire
            final openEffect = _createOpenIncidentEffect(rule, batch, nowMs);
            effects.add(openEffect);
            return RuleEvaluationResult(
              newState: currentState.copyWith(
                state: RuleEngineStateKind.cooldown,
                firedAtMs: nowMs,
                cooldownUntilMs: nowMs + (rule.cooldownSec * 1000),
                clearArmedSince: true,
              ),
              effects: effects,
            );
          } else {
            // Transition to Armed
            return RuleEvaluationResult(
              newState: currentState.copyWith(
                state: RuleEngineStateKind.armed,
                armedSinceMs: nowMs,
              ),
            );
          }
        }
        return RuleEvaluationResult(newState: currentState);

      case RuleEngineStateKind.armed:
        if (triggerActive) {
          final elapsedArmedMs = nowMs - (currentState.armedSinceMs ?? nowMs);
          final requiredMs = rule.trigger.minDurationSec * 1000;

          if (elapsedArmedMs >= requiredMs) {
            // Trigger threshold reached! Fire incident!
            final openEffect = _createOpenIncidentEffect(rule, batch, nowMs);
            effects.add(openEffect);
            return RuleEvaluationResult(
              newState: currentState.copyWith(
                state: RuleEngineStateKind.cooldown,
                firedAtMs: nowMs,
                cooldownUntilMs: nowMs + (rule.cooldownSec * 1000),
                clearArmedSince: true,
              ),
              effects: effects,
            );
          }
          // Continue arming
          return RuleEvaluationResult(newState: currentState);
        } else {
          // Condition dropped. Apply hysteresis: if inactive for > 1500ms, disarm.
          final lastInactive = currentState.lastInactiveMs ?? nowMs;
          if (nowMs - lastInactive > 1500) {
            return RuleEvaluationResult(
              newState: currentState.copyWith(
                state: RuleEngineStateKind.idle,
                clearArmedSince: true,
                lastInactiveMs: null,
              ),
            );
          } else {
            return RuleEvaluationResult(
              newState: currentState.copyWith(lastInactiveMs: lastInactive),
            );
          }
        }

      case RuleEngineStateKind.fired:
      case RuleEngineStateKind.cooldown:
        final cooldownUntil = currentState.cooldownUntilMs ?? 0;
        if (nowMs >= cooldownUntil) {
          // Cooldown finished
          return RuleEvaluationResult(
            newState: currentState.copyWith(
              state: RuleEngineStateKind.idle,
              clearArmedSince: true,
              lastInactiveMs: null,
            ),
          );
        }
        // Still in cooldown
        return RuleEvaluationResult(newState: currentState);
    }
  }

  bool _isTriggerConditionSatisfied(RuleTrigger trigger, SignalBatch batch) {
    for (final event in batch.signals) {
      if (trigger.signal == TriggerSignal.person_count) {
        if (trigger.zoneId != null && trigger.zoneId! > 0) {
          final countInZone = event.persons.where((p) =>
              p.confidence >= trigger.minConfidence && p.zoneIds.contains(trigger.zoneId)).length;
          if (countInZone >= (trigger.minCount ?? 1)) {
            return true;
          }
        } else {
          if (event.personCount >= (trigger.minCount ?? 1)) {
            return true;
          }
        }
      }

      for (final person in event.persons) {
        if (person.confidence < trigger.minConfidence) continue;

        // Check Zone Constraint
        if (trigger.zoneId != null && trigger.zoneId! > 0) {
          if (!person.zoneIds.contains(trigger.zoneId)) continue;
        } else if (trigger.signal == TriggerSignal.person_in_zone) {
          if (person.zoneIds.isEmpty) continue;
        }

        switch (trigger.signal) {
          case TriggerSignal.person_in_zone:
            return true;

          case TriggerSignal.fall_suspected:
            if (person.fallScore >= 0.60) {
              return true;
            }
            break;

          case TriggerSignal.motionless:
            if (person.motionlessMs >= (trigger.minDurationSec * 1000)) {
              return true;
            }
            break;

          case TriggerSignal.ppe_check:
            // Client vision flags unverified PPE or bounding detection
            return true;

          case TriggerSignal.person_count:
            break;
        }
      }
    }
    return false;
  }

  bool _isTimeConditionMet(RuleConditions conditions, DateTime now) {
    if (conditions.daysOfWeek.isNotEmpty) {
      if (!conditions.daysOfWeek.contains(now.weekday)) {
        return false;
      }
    }

    if (conditions.timeWindows.isEmpty) return true;

    final currentMinutes = now.hour * 60 + now.minute;

    for (final tw in conditions.timeWindows) {
      final startMin = _parseMinutes(tw.start);
      final endMin = _parseMinutes(tw.end);

      if (startMin <= endMin) {
        // Same-day window (e.g. 09:00 - 17:00)
        if (currentMinutes >= startMin && currentMinutes <= endMin) return true;
      } else {
        // Midnight crossing window (e.g. 20:00 - 06:00)
        if (currentMinutes >= startMin || currentMinutes <= endMin) return true;
      }
    }

    return false;
  }

  int _parseMinutes(String timeStr) {
    final parts = timeStr.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return h * 60 + m;
  }

  OpenIncidentEffect _createOpenIncidentEffect(
    RuleSpec rule,
    SignalBatch batch,
    int nowMs,
  ) {
    return OpenIncidentEffect(
      rule: rule,
      cameraId: batch.cameraId,
      summary: '${rule.name} triggered on camera #${batch.cameraId}',
      signalContext: {
        'batchSeq': batch.seq,
        'sentAtMs': batch.sentAtMs,
        'signalsCount': batch.signals.length,
      },
      requestEvidence: rule.actions.any((a) => a.kind == 'snapshot' || a.kind == 'create_incident'),
    );
  }
}
