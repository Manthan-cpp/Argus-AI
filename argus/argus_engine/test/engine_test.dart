import 'package:test/test.dart';
import 'package:argus_engine/argus_engine.dart';

void main() {
  group('Geometry tests', () {
    test('Point in polygon test', () {
      final poly = [
        const Point2D(0.2, 0.2),
        const Point2D(0.8, 0.2),
        const Point2D(0.8, 0.8),
        const Point2D(0.2, 0.8),
      ];

      expect(isPointInPolygon(const Point2D(0.5, 0.5), poly), isTrue);
      expect(isPointInPolygon(const Point2D(0.1, 0.5), poly), isFalse);
      expect(isPointInPolygon(const Point2D(0.9, 0.9), poly), isFalse);
    });

    test('BoundingBox IoU calculation', () {
      const boxA = BoundingBox(x: 0.1, y: 0.1, w: 0.4, h: 0.4);
      const boxB = BoundingBox(x: 0.1, y: 0.1, w: 0.4, h: 0.4);
      expect(boxA.intersectionOverUnion(boxB), closeTo(1.0, 0.001));

      const boxC = BoundingBox(x: 0.6, y: 0.6, w: 0.2, h: 0.2);
      expect(boxA.intersectionOverUnion(boxC), equals(0.0));
    });
  });

  group('Grammar Parser tests', () {
    const parser = GrammarParser();
    final zones = [
      Zone(
        id: 101,
        cameraId: 1,
        name: 'Chemical Lab',
        kind: ZoneKind.restricted,
        color: '#F43F5E',
        polygon: const [PointN(x: 0.1, y: 0.1), PointN(x: 0.5, y: 0.1), PointN(x: 0.5, y: 0.5)],
        createdAt: DateTime.now(),
      ),
    ];

    test('S1: After-hours lab entry', () {
      final res = parser.parse('If anyone enters Chemical Lab after 8 pm, alert supervisor', knownZones: zones);
      expect(res.spec, isNotNull);
      expect(res.spec!.trigger.signal, equals(TriggerSignal.person_in_zone));
      expect(res.spec!.trigger.zoneId, equals(101));
      expect(res.spec!.conditions.timeWindows.first.start, equals('20:00'));
      expect(res.spec!.actions.any((a) => a.kind == 'create_incident'), isTrue);
    });

    test('S2: Fall near stairs and stays down', () {
      final res = parser.parse('If someone falls and stays down for 20 seconds, alert security and escalate after 2 minutes');
      expect(res.spec, isNotNull);
      expect(res.spec!.trigger.signal, equals(TriggerSignal.fall_suspected));
      expect(res.spec!.trigger.minDurationSec, equals(20));
      expect(res.spec!.severity, equals(Severity.high));
      expect(res.spec!.escalation.first.afterSec, equals(120));
    });

    test('S3: Restricted zone dwell', () {
      final res = parser.parse('If a person stays in Chemical Lab for more than 5 seconds, create a high-severity incident', knownZones: zones);
      expect(res.spec, isNotNull);
      expect(res.spec!.trigger.signal, equals(TriggerSignal.person_in_zone));
      expect(res.spec!.trigger.zoneId, equals(101));
      expect(res.spec!.trigger.minDurationSec, equals(5));
      expect(res.spec!.severity, equals(Severity.high));
    });

    test('S4: Helmet check in work zone', () {
      final res = parser.parse("If a person in Chemical Lab isn't wearing a helmet, save evidence and alert site manager", knownZones: zones);
      expect(res.spec, isNotNull);
      expect(res.spec!.trigger.signal, equals(TriggerSignal.ppe_check));
      expect(res.spec!.verify.enabled, isTrue);
    });
  });

  group('Rule Evaluator tests', () {
    const evaluator = RuleEvaluator();
    final rule = RuleSpec(
      id: 1,
      workspaceId: 1,
      name: 'Intrusion Alert',
      cameraIds: const [1],
      trigger: const RuleTrigger(
        signal: TriggerSignal.person_in_zone,
        zoneId: 5,
        minDurationSec: 2,
      ),
      severity: Severity.high,
      sourceText: 'test',
      parsedBy: 'grammar',
      createdAt: DateTime.now(),
    );

    test('Arming and firing lifecycle', () {
      var state = const RuleState(ruleId: 1, cameraId: 1);
      final t0 = DateTime(2026, 10, 8, 12, 0, 0);

      // 1. Initial idle with person outside zone
      final batchOutside = SignalBatch(
        cameraId: 1,
        sentAtMs: 1000,
        seq: 1,
        signals: const [
          SignalEvent(
            tsMs: 1000,
            kind: SignalKind.change,
            personCount: 1,
            persons: [
              PersonSignal(
                trackId: 1,
                bboxN: BBoxN(x: 0, y: 0, w: 0.2, h: 0.5),
                footN: PointN(x: 0.1, y: 0.5),
                zoneIds: [2], // Not zone 5
                aspect: 0.4,
                motionScore: 0.1,
                fallScore: 0.0,
                motionlessMs: 0,
                confidence: 0.9,
              )
            ],
          )
        ],
      );

      var res = evaluator.evaluate(rule: rule, currentState: state, batch: batchOutside, now: t0);
      expect(res.newState.state, equals(RuleEngineStateKind.idle));
      expect(res.effects, isEmpty);

      // 2. Person enters zone 5 -> transitions to armed
      final batchInside1 = SignalBatch(
        cameraId: 1,
        sentAtMs: 2000,
        seq: 2,
        signals: const [
          SignalEvent(
            tsMs: 2000,
            kind: SignalKind.change,
            personCount: 1,
            persons: [
              PersonSignal(
                trackId: 1,
                bboxN: BBoxN(x: 0, y: 0, w: 0.2, h: 0.5),
                footN: PointN(x: 0.1, y: 0.5),
                zoneIds: [5], // In zone 5!
                aspect: 0.4,
                motionScore: 0.1,
                fallScore: 0.0,
                motionlessMs: 0,
                confidence: 0.9,
              )
            ],
          )
        ],
      );

      res = evaluator.evaluate(rule: rule, currentState: state, batch: batchInside1, now: t0);
      expect(res.newState.state, equals(RuleEngineStateKind.armed));
      expect(res.newState.armedSinceMs, equals(2000));
      expect(res.effects, isEmpty);
      state = res.newState;

      // 3. Person remains in zone 5 for >= 2 seconds (sentAtMs: 4050ms) -> fires incident!
      final batchInside2 = SignalBatch(
        cameraId: 1,
        sentAtMs: 4050,
        seq: 3,
        signals: const [
          SignalEvent(
            tsMs: 4050,
            kind: SignalKind.change,
            personCount: 1,
            persons: [
              PersonSignal(
                trackId: 1,
                bboxN: BBoxN(x: 0, y: 0, w: 0.2, h: 0.5),
                footN: PointN(x: 0.1, y: 0.5),
                zoneIds: [5],
                aspect: 0.4,
                motionScore: 0.1,
                fallScore: 0.0,
                motionlessMs: 0,
                confidence: 0.9,
              )
            ],
          )
        ],
      );

      res = evaluator.evaluate(rule: rule, currentState: state, batch: batchInside2, now: t0);
      expect(res.newState.state, equals(RuleEngineStateKind.cooldown));
      expect(res.effects.length, equals(1));
      expect(res.effects.first, isA<OpenIncidentEffect>());
    });
  });

  group('Escalation Planner tests', () {
    const planner = EscalationPlanner();
    final rule = RuleSpec(
      id: 1,
      workspaceId: 1,
      name: 'Fall Alert',
      cameraIds: const [1],
      trigger: const RuleTrigger(signal: TriggerSignal.fall_suspected),
      severity: Severity.high,
      escalation: const [
        RuleEscalation(afterSec: 60, notify: 'Supervisor', message: 'First escalation'),
        RuleEscalation(afterSec: 180, notify: 'Security Lead', message: 'Second escalation'),
      ],
      sourceText: 'test',
      parsedBy: 'grammar',
      createdAt: DateTime.now(),
    );

    test('Plans correct escalation steps', () {
      final openedAt = DateTime(2026, 10, 8, 14, 0, 0);
      final incident = Incident(
        id: 42,
        workspaceId: 1,
        cameraId: 1,
        ruleId: 1,
        ruleSnapshotJson: '{}',
        severity: Severity.high,
        status: IncidentStatus.open,
        openedAt: openedAt,
        summary: 'Fall detected',
      );

      final steps = planner.plan(incident: incident, rule: rule);
      expect(steps.length, equals(2));
      expect(steps[0].executeAt, equals(openedAt.add(const Duration(seconds: 60))));
      expect(steps[0].notifyTarget, equals('Supervisor'));
      expect(steps[1].executeAt, equals(openedAt.add(const Duration(seconds: 180))));
      expect(steps[1].notifyTarget, equals('Security Lead'));
    });
  });
}
