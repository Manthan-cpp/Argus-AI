import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class DemoEndpoint extends Endpoint {
  Future<DemoSeedResult> seed(Session session) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final wsId = ws.id!;

    // Clean existing records for this workspace
    await Camera.db.deleteWhere(session, where: (t) => t.workspaceId.equals(wsId));
    await RuleSpec.db.deleteWhere(session, where: (t) => t.workspaceId.equals(wsId));
    await Contact.db.deleteWhere(session, where: (t) => t.workspaceId.equals(wsId));

    // 1. Seed Cameras
    final cam1 = await Camera.db.insertRow(
      session,
      Camera(
        workspaceId: wsId,
        name: 'Cam 01 — North Perimeter & Gate',
        sourceKind: 'webcam',
        sourceRef: 'local_webcam_0',
        enabled: true,
        createdAt: DateTime.now(),
        status: 'online',
      ),
    );

    final cam2 = await Camera.db.insertRow(
      session,
      Camera(
        workspaceId: wsId,
        name: 'Cam 02 — Central Transit Stairwell',
        sourceKind: 'replay',
        sourceRef: 's2_fall_stairs',
        enabled: true,
        createdAt: DateTime.now(),
        status: 'replay',
      ),
    );

    final cam3 = await Camera.db.insertRow(
      session,
      Camera(
        workspaceId: wsId,
        name: 'Cam 03 — High Voltage Machinery Bay',
        sourceKind: 'replay',
        sourceRef: 's3_zone_intrusion',
        enabled: true,
        createdAt: DateTime.now(),
        status: 'replay',
      ),
    );

    final cam4 = await Camera.db.insertRow(
      session,
      Camera(
        workspaceId: wsId,
        name: 'Cam 04 — Public Concourse & Emergency Exit',
        sourceKind: 'replay',
        sourceRef: 's1_after_hours',
        enabled: true,
        createdAt: DateTime.now(),
        status: 'replay',
      ),
    );

    // 2. Seed Geofence Zones
    await Zone.db.insertRow(
      session,
      Zone(
        cameraId: cam1.id!,
        name: 'Sterile Perimeter Fence',
        kind: 'restricted',
        color: '#F43F5E',
        polygon: [
          PointN(x: 0.10, y: 0.15),
          PointN(x: 0.85, y: 0.15),
          PointN(x: 0.85, y: 0.75),
          PointN(x: 0.10, y: 0.75),
        ],
        createdAt: DateTime.now(),
      ),
    );

    await Zone.db.insertRow(
      session,
      Zone(
        cameraId: cam2.id!,
        name: 'Stairwell Landing & Drop Zone',
        kind: 'stairs',
        color: '#A78BFA',
        polygon: [
          PointN(x: 0.20, y: 0.30),
          PointN(x: 0.80, y: 0.30),
          PointN(x: 0.80, y: 0.85),
          PointN(x: 0.20, y: 0.85),
        ],
        createdAt: DateTime.now(),
      ),
    );

    await Zone.db.insertRow(
      session,
      Zone(
        cameraId: cam3.id!,
        name: 'Red Danger Enclosure',
        kind: 'restricted',
        color: '#F43F5E',
        polygon: [
          PointN(x: 0.25, y: 0.20),
          PointN(x: 0.75, y: 0.20),
          PointN(x: 0.75, y: 0.80),
          PointN(x: 0.25, y: 0.80),
        ],
        createdAt: DateTime.now(),
      ),
    );

    // 3. Seed Declarative Multi-Scenario Safety Rules
    final rule1 = await RuleSpec.db.insertRow(
      session,
      RuleSpec(
        workspaceId: wsId,
        name: 'Perimeter Breach & Sterile Zone Intrusion',
        enabled: true,
        cameraIds: [cam1.id!],
        trigger: RuleTrigger(
          signal: 'person_in_zone',
          zoneId: 1,
          minDurationSec: 2,
          minConfidence: 0.75,
        ),
        conditions: RuleConditions(
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          timezone: 'UTC',
          timeWindows: [],
        ),
        severity: 'high',
        verify: RuleVerify(enabled: false, kind: 'generic'),
        actions: [
          RuleAction(kind: 'create_incident', paramsJson: '{"alarm":"perimeter"}'),
          RuleAction(kind: 'snapshot', paramsJson: '{"blurHead":true}'),
        ],
        cooldownSec: 45,
        escalation: [
          RuleEscalation(afterSec: 30, notify: 'Duty Security Officer', message: 'Unauthorized presence at North Perimeter'),
          RuleEscalation(afterSec: 120, notify: 'Shift Commander', message: 'Escalation: Unacknowledged North Perimeter breach'),
        ],
        sourceText: 'If anyone enters the sterile perimeter fence for more than 2 seconds, create a high-severity incident and alert security.',
        parsedBy: 'grammar',
        createdAt: DateTime.now(),
        version: 1,
      ),
    );

    final rule2 = await RuleSpec.db.insertRow(
      session,
      RuleSpec(
        workspaceId: wsId,
        name: 'Incapacitation & Fall Near Stairs',
        enabled: true,
        cameraIds: [cam2.id!],
        trigger: RuleTrigger(
          signal: 'fall_suspected',
          zoneId: 2,
          minDurationSec: 5,
          minConfidence: 0.80,
        ),
        conditions: RuleConditions(
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          timezone: 'UTC',
          timeWindows: [],
        ),
        severity: 'critical',
        verify: RuleVerify(enabled: false, kind: 'person_down'),
        actions: [
          RuleAction(kind: 'create_incident', paramsJson: '{"alarm":"medical"}'),
          RuleAction(kind: 'snapshot', paramsJson: '{"blurHead":true}'),
        ],
        cooldownSec: 60,
        escalation: [
          RuleEscalation(afterSec: 15, notify: 'First Aid Dispatch', message: 'Subject fallen and motionless near stairs'),
          RuleEscalation(afterSec: 60, notify: 'Operations Director', message: 'Critical: Emergency response team unconfirmed'),
        ],
        sourceText: 'If someone falls near the stairs and stays down, create a critical incident and dispatch medical assistance immediately.',
        parsedBy: 'grammar',
        createdAt: DateTime.now(),
        version: 1,
      ),
    );

    final rule3 = await RuleSpec.db.insertRow(
      session,
      RuleSpec(
        workspaceId: wsId,
        name: 'Unauthorized Loitering & Extended Dwell Time',
        enabled: true,
        cameraIds: [cam3.id!],
        trigger: RuleTrigger(
          signal: 'person_in_zone',
          zoneId: 3,
          minDurationSec: 5,
          minConfidence: 0.70,
        ),
        conditions: RuleConditions(
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          timezone: 'UTC',
          timeWindows: [],
        ),
        severity: 'high',
        verify: RuleVerify(enabled: false, kind: 'generic'),
        actions: [
          RuleAction(kind: 'create_incident', paramsJson: '{"alarm":"dwell"}'),
        ],
        cooldownSec: 60,
        escalation: [
          RuleEscalation(afterSec: 45, notify: 'Safety Inspector', message: 'Worker lingering in dangerous machinery sector'),
        ],
        sourceText: 'If a person remains inside the machinery enclosure for over 5 seconds, raise an alert.',
        parsedBy: 'grammar',
        createdAt: DateTime.now(),
        version: 1,
      ),
    );

    final rule4 = await RuleSpec.db.insertRow(
      session,
      RuleSpec(
        workspaceId: wsId,
        name: 'Crowd Density Surge & Evacuation Blockage',
        enabled: true,
        cameraIds: [cam4.id!],
        trigger: RuleTrigger(
          signal: 'person_count',
          minCount: 5,
          minDurationSec: 3,
          minConfidence: 0.70,
        ),
        conditions: RuleConditions(
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          timezone: 'UTC',
          timeWindows: [],
        ),
        severity: 'medium',
        verify: RuleVerify(enabled: false, kind: 'generic'),
        actions: [
          RuleAction(kind: 'create_incident', paramsJson: '{"alarm":"crowd"}'),
        ],
        cooldownSec: 90,
        escalation: [
          RuleEscalation(afterSec: 60, notify: 'Hall Stewards', message: 'Crowd bottleneck near main exit turnstiles'),
        ],
        sourceText: 'If more than 5 people congregate near the exit turnstiles, alert hall stewards to clear the passageway.',
        parsedBy: 'grammar',
        createdAt: DateTime.now(),
        version: 1,
      ),
    );

    // 4. Seed Contacts
    await Contact.db.insertRow(
      session,
      Contact(
        workspaceId: wsId,
        name: 'Inspector Vikram Sharma',
        role: 'Central Control Supervisor',
        notifyInApp: true,
        isLinked: true,
        createdAt: DateTime.now(),
      ),
    );

    await Contact.db.insertRow(
      session,
      Contact(
        workspaceId: wsId,
        name: 'Rapid Response Unit 04',
        role: 'Site Security Patrol',
        notifyInApp: true,
        isLinked: false,
        createdAt: DateTime.now(),
      ),
    );

    return DemoSeedResult(
      workspaceId: wsId,
      cameraIds: [cam1.id!, cam2.id!, cam3.id!, cam4.id!],
      ruleIds: [rule1.id!, rule2.id!, rule3.id!, rule4.id!],
    );
  }
}
