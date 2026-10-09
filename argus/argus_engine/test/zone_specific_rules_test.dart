import 'package:test/test.dart';
import 'package:argus_engine/argus_engine.dart';

void main() {
  group('Zone-specific rule discrimination tests', () {
    const evaluator = RuleEvaluator();
    final now = DateTime(2026, 10, 8, 12, 0, 0);

    final ruleRestrictedIntrusion = RuleSpec(
      id: 101,
      workspaceId: 1,
      name: 'Restricted Area Intrusion',
      enabled: true,
      cameraIds: const [1],
      trigger: const RuleTrigger(
        signal: TriggerSignal.person_in_zone,
        zoneId: 1, // Strictly Restricted Area (Zone 1)
        minDurationSec: 0,
        minConfidence: 0.5,
      ),
      conditions: const RuleConditions(),
      severity: Severity.critical,
      verify: const RuleVerify(enabled: false),
      actions: const [RuleAction(kind: 'alarm')],
      cooldownSec: 60,
      escalation: const [],
      sourceText: 'If a person enters Restricted Area, trigger critical alert',
      parsedBy: 'grammar',
      createdAt: DateTime(2026, 1, 1),
    );

    final ruleStaircaseCrowd = RuleSpec(
      id: 102,
      workspaceId: 1,
      name: 'Staircase Crowd Density',
      enabled: true,
      cameraIds: const [1],
      trigger: const RuleTrigger(
        signal: TriggerSignal.person_count,
        zoneId: 2, // Strictly Staircase (Zone 2)
        minCount: 3,
        minDurationSec: 0,
        minConfidence: 0.5,
      ),
      conditions: const RuleConditions(),
      severity: Severity.medium,
      verify: const RuleVerify(enabled: false),
      actions: const [RuleAction(kind: 'notify')],
      cooldownSec: 60,
      escalation: const [],
      sourceText: 'If more than 3 people gather in Staircase, raise crowd alert',
      parsedBy: 'grammar',
      createdAt: DateTime(2026, 1, 1),
    );

    PersonSignal makePerson({required int id, required List<int> zones, double conf = 0.9}) {
      return PersonSignal(
        trackId: id,
        bboxN: const BBoxN(x: 0.1, y: 0.1, w: 0.2, h: 0.5),
        footN: const PointN(x: 0.1, y: 0.5),
        zoneIds: zones,
        aspect: 0.4,
        motionScore: 0.1,
        fallScore: 0.0,
        motionlessMs: 0,
        confidence: conf,
      );
    }

    test('1 person in Staircase does NOT trigger Restricted Area rule or Staircase Crowd rule', () {
      final batch = SignalBatch(
        cameraId: 1,
        sentAtMs: 1000,
        seq: 1,
        signals: [
          SignalEvent(
            tsMs: 1000,
            kind: SignalKind.change,
            personCount: 1,
            persons: [
              makePerson(id: 1, zones: [2]), // In Staircase (Zone 2) only
            ],
          ),
        ],
      );

      final stateA = const RuleState(ruleId: 101, cameraId: 1);
      final resA = evaluator.evaluate(rule: ruleRestrictedIntrusion, currentState: stateA, batch: batch, now: now);
      expect(resA.newState.state, equals(RuleEngineStateKind.idle));
      expect(resA.effects.whereType<OpenIncidentEffect>(), isEmpty);

      final stateB = const RuleState(ruleId: 102, cameraId: 1);
      final resB = evaluator.evaluate(rule: ruleStaircaseCrowd, currentState: stateB, batch: batch, now: now);
      expect(resB.newState.state, equals(RuleEngineStateKind.idle));
      expect(resB.effects.whereType<OpenIncidentEffect>(), isEmpty);
    });

    test('3 people in Staircase triggers Staircase Crowd rule but NOT Restricted Area rule', () {
      final batch = SignalBatch(
        cameraId: 1,
        sentAtMs: 2000,
        seq: 2,
        signals: [
          SignalEvent(
            tsMs: 2000,
            kind: SignalKind.change,
            personCount: 3,
            persons: [
              makePerson(id: 1, zones: [2]),
              makePerson(id: 2, zones: [2]),
              makePerson(id: 3, zones: [2]),
            ],
          ),
        ],
      );

      final stateA = const RuleState(ruleId: 101, cameraId: 1);
      final resA = evaluator.evaluate(rule: ruleRestrictedIntrusion, currentState: stateA, batch: batch, now: now);
      expect(resA.newState.state, equals(RuleEngineStateKind.idle));
      expect(resA.effects.whereType<OpenIncidentEffect>(), isEmpty);

      final stateB = const RuleState(ruleId: 102, cameraId: 1);
      final resB = evaluator.evaluate(rule: ruleStaircaseCrowd, currentState: stateB, batch: batch, now: now);
      expect(resB.newState.state, equals(RuleEngineStateKind.cooldown));
      expect(resB.effects.whereType<OpenIncidentEffect>(), isNotEmpty);
    });

    test('1 person in Restricted Area triggers Restricted Area rule without triggering Staircase rule', () {
      final batch = SignalBatch(
        cameraId: 1,
        sentAtMs: 3000,
        seq: 3,
        signals: [
          SignalEvent(
            tsMs: 3000,
            kind: SignalKind.change,
            personCount: 1,
            persons: [
              makePerson(id: 99, zones: [1]), // In Restricted Area (Zone 1)
            ],
          ),
        ],
      );

      final stateA = const RuleState(ruleId: 101, cameraId: 1);
      final resA = evaluator.evaluate(rule: ruleRestrictedIntrusion, currentState: stateA, batch: batch, now: now);
      expect(resA.newState.state, equals(RuleEngineStateKind.cooldown));
      expect(resA.effects.whereType<OpenIncidentEffect>(), isNotEmpty);

      final stateB = const RuleState(ruleId: 102, cameraId: 1);
      final resB = evaluator.evaluate(rule: ruleStaircaseCrowd, currentState: stateB, batch: batch, now: now);
      expect(resB.newState.state, equals(RuleEngineStateKind.idle));
      expect(resB.effects.whereType<OpenIncidentEffect>(), isEmpty);
    });
  });
}
