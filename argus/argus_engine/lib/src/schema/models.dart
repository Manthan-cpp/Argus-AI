/// Canonical domain models and DTOs for Argus.
/// Shared across the pure-Dart engine, mock repositories, and Serverpod clients.

enum Severity { low, medium, high, critical }
enum IncidentStatus { open, acknowledged, resolved, false_positive }
enum VerificationStatus { not_requested, pending, confirmed, rejected, unverified }
enum CameraStatus { offline, online, replay }
enum CameraSourceKind { webcam, file, demo, replay }
enum ZoneKind { restricted, work, stairs, custom }
enum SignalKind { heartbeat, change }
enum TriggerSignal { person_in_zone, fall_suspected, motionless, person_count, ppe_check }

class PointN {
  final double x;
  final double y;

  const PointN({required this.x, required this.y});

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
  factory PointN.fromJson(Map<String, dynamic> json) => PointN(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}

class BBoxN {
  final double x;
  final double y;
  final double w;
  final double h;

  const BBoxN({required this.x, required this.y, required this.w, required this.h});

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'w': w, 'h': h};
  factory BBoxN.fromJson(Map<String, dynamic> json) => BBoxN(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        w: (json['w'] as num).toDouble(),
        h: (json['h'] as num).toDouble(),
      );
}

class WorkspaceSettings {
  final bool cloudVerification;
  final bool blurEvidence;
  final int retentionDays;
  final bool browserNotifications;
  final bool telegramLinked;
  final String timezone;

  const WorkspaceSettings({
    this.cloudVerification = false,
    this.blurEvidence = true,
    this.retentionDays = 7,
    this.browserNotifications = true,
    this.telegramLinked = false,
    this.timezone = 'UTC',
  });

  Map<String, dynamic> toJson() => {
        'cloudVerification': cloudVerification,
        'blurEvidence': blurEvidence,
        'retentionDays': retentionDays,
        'browserNotifications': browserNotifications,
        'telegramLinked': telegramLinked,
        'timezone': timezone,
      };

  factory WorkspaceSettings.fromJson(Map<String, dynamic> json) =>
      WorkspaceSettings(
        cloudVerification: json['cloudVerification'] as bool? ?? false,
        blurEvidence: json['blurEvidence'] as bool? ?? true,
        retentionDays: json['retentionDays'] as int? ?? 7,
        browserNotifications: json['browserNotifications'] as bool? ?? true,
        telegramLinked: json['telegramLinked'] as bool? ?? false,
        timezone: json['timezone'] as String? ?? 'UTC',
      );

  WorkspaceSettings copyWith({
    bool? cloudVerification,
    bool? blurEvidence,
    int? retentionDays,
    bool? browserNotifications,
    bool? telegramLinked,
    String? timezone,
  }) {
    return WorkspaceSettings(
      cloudVerification: cloudVerification ?? this.cloudVerification,
      blurEvidence: blurEvidence ?? this.blurEvidence,
      retentionDays: retentionDays ?? this.retentionDays,
      browserNotifications: browserNotifications ?? this.browserNotifications,
      telegramLinked: telegramLinked ?? this.telegramLinked,
      timezone: timezone ?? this.timezone,
    );
  }
}

class Workspace {
  final int id;
  final String ownerUserId;
  final String name;
  final DateTime createdAt;
  final WorkspaceSettings settings;

  const Workspace({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.createdAt,
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'settings': settings.toJson(),
      };

  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
        id: json['id'] as int,
        ownerUserId: json['ownerUserId'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        settings: WorkspaceSettings.fromJson(json['settings'] as Map<String, dynamic>),
      );
}

class Contact {
  final int id;
  final int workspaceId;
  final String name;
  final String role;
  final String? telegramChatId;
  final bool notifyInApp;

  const Contact({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.role,
    this.telegramChatId,
    this.notifyInApp = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'role': role,
        'telegramChatId': telegramChatId,
        'notifyInApp': notifyInApp,
      };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'] as int,
        workspaceId: json['workspaceId'] as int,
        name: json['name'] as String,
        role: json['role'] as String,
        telegramChatId: json['telegramChatId'] as String?,
        notifyInApp: json['notifyInApp'] as bool? ?? true,
      );
}

class Camera {
  final int id;
  final int workspaceId;
  final String name;
  final CameraSourceKind sourceKind;
  final String sourceRef;
  final bool enabled;
  final DateTime createdAt;
  final DateTime? lastSignalAt;
  final CameraStatus status;

  const Camera({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.sourceKind,
    required this.sourceRef,
    this.enabled = true,
    required this.createdAt,
    this.lastSignalAt,
    this.status = CameraStatus.offline,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'sourceKind': sourceKind.name,
        'sourceRef': sourceRef,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
        'lastSignalAt': lastSignalAt?.toIso8601String(),
        'status': status.name,
      };

  factory Camera.fromJson(Map<String, dynamic> json) => Camera(
        id: json['id'] as int,
        workspaceId: json['workspaceId'] as int,
        name: json['name'] as String,
        sourceKind: CameraSourceKind.values.byName(json['sourceKind'] as String),
        sourceRef: json['sourceRef'] as String,
        enabled: json['enabled'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastSignalAt: json['lastSignalAt'] != null
            ? DateTime.parse(json['lastSignalAt'] as String)
            : null,
        status: CameraStatus.values.byName(json['status'] as String? ?? 'offline'),
      );
}

class Zone {
  final int id;
  final int cameraId;
  final String name;
  final ZoneKind kind;
  final String color;
  final List<PointN> polygon;
  final DateTime createdAt;

  const Zone({
    required this.id,
    required this.cameraId,
    required this.name,
    required this.kind,
    required this.color,
    required this.polygon,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cameraId': cameraId,
        'name': name,
        'kind': kind.name,
        'color': color,
        'polygon': polygon.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        id: json['id'] as int,
        cameraId: json['cameraId'] as int,
        name: json['name'] as String,
        kind: ZoneKind.values.byName(json['kind'] as String),
        color: json['color'] as String,
        polygon: (json['polygon'] as List)
            .map((p) => PointN.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class TimeWindow {
  final String start; // "HH:mm"
  final String end;   // "HH:mm"

  const TimeWindow({required this.start, required this.end});

  Map<String, dynamic> toJson() => {'start': start, 'end': end};
  factory TimeWindow.fromJson(Map<String, dynamic> json) =>
      TimeWindow(start: json['start'] as String, end: json['end'] as String);
}

class RuleTrigger {
  final TriggerSignal signal;
  final int? zoneId;
  final int minDurationSec;
  final double minConfidence;
  final int? minCount;
  final String? ppe;

  const RuleTrigger({
    required this.signal,
    this.zoneId,
    this.minDurationSec = 0,
    this.minConfidence = 0.5,
    this.minCount,
    this.ppe,
  });

  Map<String, dynamic> toJson() => {
        'signal': signal.name,
        'zoneId': zoneId,
        'minDurationSec': minDurationSec,
        'minConfidence': minConfidence,
        'minCount': minCount,
        'ppe': ppe,
      };

  factory RuleTrigger.fromJson(Map<String, dynamic> json) => RuleTrigger(
        signal: TriggerSignal.values.byName(json['signal'] as String),
        zoneId: json['zoneId'] as int?,
        minDurationSec: json['minDurationSec'] as int? ?? 0,
        minConfidence: (json['minConfidence'] as num?)?.toDouble() ?? 0.5,
        minCount: json['minCount'] as int?,
        ppe: json['ppe'] as String?,
      );
}

class RuleConditions {
  final List<TimeWindow> timeWindows;
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  final String timezone;

  const RuleConditions({
    this.timeWindows = const [],
    this.daysOfWeek = const [],
    this.timezone = 'UTC',
  });

  Map<String, dynamic> toJson() => {
        'timeWindows': timeWindows.map((tw) => tw.toJson()).toList(),
        'daysOfWeek': daysOfWeek,
        'timezone': timezone,
      };

  factory RuleConditions.fromJson(Map<String, dynamic> json) => RuleConditions(
        timeWindows: (json['timeWindows'] as List? ?? [])
            .map((tw) => TimeWindow.fromJson(tw as Map<String, dynamic>))
            .toList(),
        daysOfWeek: (json['daysOfWeek'] as List? ?? []).map((e) => e as int).toList(),
        timezone: json['timezone'] as String? ?? 'UTC',
      );
}

class RuleVerify {
  final bool enabled;
  final String kind; // "helmet" | "person_down" | "generic"

  const RuleVerify({required this.enabled, this.kind = 'generic'});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'kind': kind};
  factory RuleVerify.fromJson(Map<String, dynamic> json) => RuleVerify(
        enabled: json['enabled'] as bool? ?? false,
        kind: json['kind'] as String? ?? 'generic',
      );
}

class RuleAction {
  final String kind; // in_app, browser, telegram, snapshot, create_incident
  final Map<String, dynamic> params;

  const RuleAction({required this.kind, this.params = const {}});

  Map<String, dynamic> toJson() => {'kind': kind, 'params': params};
  factory RuleAction.fromJson(Map<String, dynamic> json) => RuleAction(
        kind: json['kind'] as String,
        params: json['params'] as Map<String, dynamic>? ?? const {},
      );
}

class RuleEscalation {
  final int afterSec;
  final String notify; // contact id or role name
  final String message;

  const RuleEscalation({
    required this.afterSec,
    required this.notify,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'afterSec': afterSec,
        'notify': notify,
        'message': message,
      };

  factory RuleEscalation.fromJson(Map<String, dynamic> json) => RuleEscalation(
        afterSec: json['afterSec'] as int,
        notify: json['notify'] as String,
        message: json['message'] as String,
      );
}

class RuleSpec {
  final int id;
  final int workspaceId;
  final String name;
  final bool enabled;
  final List<int> cameraIds;
  final RuleTrigger trigger;
  final RuleConditions conditions;
  final Severity severity;
  final RuleVerify verify;
  final List<RuleAction> actions;
  final int cooldownSec;
  final List<RuleEscalation> escalation;
  final String sourceText;
  final String parsedBy; // "gemini" | "grammar" | "manual"
  final DateTime createdAt;
  final int version;

  const RuleSpec({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.enabled = true,
    required this.cameraIds,
    required this.trigger,
    this.conditions = const RuleConditions(),
    required this.severity,
    this.verify = const RuleVerify(enabled: false),
    this.actions = const [],
    this.cooldownSec = 60,
    this.escalation = const [],
    required this.sourceText,
    required this.parsedBy,
    required this.createdAt,
    this.version = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'enabled': enabled,
        'cameraIds': cameraIds,
        'trigger': trigger.toJson(),
        'conditions': conditions.toJson(),
        'severity': severity.name,
        'verify': verify.toJson(),
        'actions': actions.map((a) => a.toJson()).toList(),
        'cooldownSec': cooldownSec,
        'escalation': escalation.map((e) => e.toJson()).toList(),
        'sourceText': sourceText,
        'parsedBy': parsedBy,
        'createdAt': createdAt.toIso8601String(),
        'version': version,
      };

  factory RuleSpec.fromJson(Map<String, dynamic> json) => RuleSpec(
        id: json['id'] as int,
        workspaceId: json['workspaceId'] as int,
        name: json['name'] as String,
        enabled: json['enabled'] as bool? ?? true,
        cameraIds: (json['cameraIds'] as List).map((e) => e as int).toList(),
        trigger: RuleTrigger.fromJson(json['trigger'] as Map<String, dynamic>),
        conditions: json['conditions'] != null
            ? RuleConditions.fromJson(json['conditions'] as Map<String, dynamic>)
            : const RuleConditions(),
        severity: Severity.values.byName(json['severity'] as String),
        verify: json['verify'] != null
            ? RuleVerify.fromJson(json['verify'] as Map<String, dynamic>)
            : const RuleVerify(enabled: false),
        actions: (json['actions'] as List? ?? [])
            .map((a) => RuleAction.fromJson(a as Map<String, dynamic>))
            .toList(),
        cooldownSec: json['cooldownSec'] as int? ?? 60,
        escalation: (json['escalation'] as List? ?? [])
            .map((e) => RuleEscalation.fromJson(e as Map<String, dynamic>))
            .toList(),
        sourceText: json['sourceText'] as String,
        parsedBy: json['parsedBy'] as String? ?? 'manual',
        createdAt: DateTime.parse(json['createdAt'] as String),
        version: json['version'] as int? ?? 1,
      );
}

class ParseResult {
  final RuleSpec? spec;
  final String parsedBy; // "gemini" | "grammar" | "manual"
  final double confidence;
  final List<String> warnings;
  final String? unsupportedReason;
  final List<String> alternatives;

  const ParseResult({
    this.spec,
    required this.parsedBy,
    required this.confidence,
    this.warnings = const [],
    this.unsupportedReason,
    this.alternatives = const [],
  });

  Map<String, dynamic> toJson() => {
        'spec': spec?.toJson(),
        'parsedBy': parsedBy,
        'confidence': confidence,
        'warnings': warnings,
        'unsupportedReason': unsupportedReason,
        'alternatives': alternatives,
      };

  factory ParseResult.fromJson(Map<String, dynamic> json) => ParseResult(
        spec: json['spec'] != null ? RuleSpec.fromJson(json['spec'] as Map<String, dynamic>) : null,
        parsedBy: json['parsedBy'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        warnings: (json['warnings'] as List? ?? []).map((e) => e as String).toList(),
        unsupportedReason: json['unsupportedReason'] as String?,
        alternatives: (json['alternatives'] as List? ?? []).map((e) => e as String).toList(),
      );
}

class PersonSignal {
  final int trackId;
  final BBoxN bboxN;
  final PointN footN;
  final List<int> zoneIds;
  final double? torsoAngleDeg;
  final double? hipDropRatio;
  final double aspect;
  final double motionScore;
  final double fallScore;
  final int motionlessMs;
  final double confidence;

  const PersonSignal({
    required this.trackId,
    required this.bboxN,
    required this.footN,
    required this.zoneIds,
    this.torsoAngleDeg,
    this.hipDropRatio,
    required this.aspect,
    required this.motionScore,
    required this.fallScore,
    required this.motionlessMs,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
        'trackId': trackId,
        'bboxN': bboxN.toJson(),
        'footN': footN.toJson(),
        'zoneIds': zoneIds,
        'torsoAngleDeg': torsoAngleDeg,
        'hipDropRatio': hipDropRatio,
        'aspect': aspect,
        'motionScore': motionScore,
        'fallScore': fallScore,
        'motionlessMs': motionlessMs,
        'confidence': confidence,
      };

  factory PersonSignal.fromJson(Map<String, dynamic> json) => PersonSignal(
        trackId: json['trackId'] as int,
        bboxN: BBoxN.fromJson(json['bboxN'] as Map<String, dynamic>),
        footN: PointN.fromJson(json['footN'] as Map<String, dynamic>),
        zoneIds: (json['zoneIds'] as List? ?? []).map((e) => e as int).toList(),
        torsoAngleDeg: (json['torsoAngleDeg'] as num?)?.toDouble(),
        hipDropRatio: (json['hipDropRatio'] as num?)?.toDouble(),
        aspect: (json['aspect'] as num).toDouble(),
        motionScore: (json['motionScore'] as num).toDouble(),
        fallScore: (json['fallScore'] as num).toDouble(),
        motionlessMs: json['motionlessMs'] as int,
        confidence: (json['confidence'] as num).toDouble(),
      );
}

class SignalEvent {
  final int tsMs;
  final SignalKind kind;
  final int personCount;
  final List<PersonSignal> persons;

  const SignalEvent({
    required this.tsMs,
    required this.kind,
    required this.personCount,
    required this.persons,
  });

  Map<String, dynamic> toJson() => {
        'tsMs': tsMs,
        'kind': kind.name,
        'personCount': personCount,
        'persons': persons.map((p) => p.toJson()).toList(),
      };

  factory SignalEvent.fromJson(Map<String, dynamic> json) => SignalEvent(
        tsMs: json['tsMs'] as int,
        kind: SignalKind.values.byName(json['kind'] as String),
        personCount: json['personCount'] as int,
        persons: (json['persons'] as List)
            .map((p) => PersonSignal.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}

class SignalBatch {
  final int cameraId;
  final int sentAtMs;
  final int seq;
  final List<SignalEvent> signals;

  const SignalBatch({
    required this.cameraId,
    required this.sentAtMs,
    required this.seq,
    required this.signals,
  });

  Map<String, dynamic> toJson() => {
        'cameraId': cameraId,
        'sentAtMs': sentAtMs,
        'seq': seq,
        'signals': signals.map((s) => s.toJson()).toList(),
      };

  factory SignalBatch.fromJson(Map<String, dynamic> json) => SignalBatch(
        cameraId: json['cameraId'] as int,
        sentAtMs: json['sentAtMs'] as int,
        seq: json['seq'] as int,
        signals: (json['signals'] as List)
            .map((s) => SignalEvent.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class SignalAck {
  final bool accepted;
  final List<int> needEvidenceFor;
  final int serverTimeMs;

  const SignalAck({
    required this.accepted,
    this.needEvidenceFor = const [],
    required this.serverTimeMs,
  });

  Map<String, dynamic> toJson() => {
        'accepted': accepted,
        'needEvidenceFor': needEvidenceFor,
        'serverTimeMs': serverTimeMs,
      };

  factory SignalAck.fromJson(Map<String, dynamic> json) => SignalAck(
        accepted: json['accepted'] as bool,
        needEvidenceFor: (json['needEvidenceFor'] as List? ?? []).map((e) => e as int).toList(),
        serverTimeMs: json['serverTimeMs'] as int,
      );
}

class VerificationInfo {
  final VerificationStatus status;
  final String? reason;
  final String? model;

  const VerificationInfo({
    required this.status,
    this.reason,
    this.model,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'reason': reason,
        'model': model,
      };

  factory VerificationInfo.fromJson(Map<String, dynamic> json) => VerificationInfo(
        status: VerificationStatus.values.byName(json['status'] as String),
        reason: json['reason'] as String?,
        model: json['model'] as String?,
      );
}

class Incident {
  final int id;
  final int workspaceId;
  final int cameraId;
  final int ruleId;
  final String ruleSnapshotJson;
  final Severity severity;
  final IncidentStatus status;
  final DateTime openedAt;
  final DateTime? ackedAt;
  final DateTime? resolvedAt;
  final String? evidenceFileKey;
  final VerificationInfo verification;
  final String summary;
  final String signalContextJson;
  final String? assignedTo;

  const Incident({
    required this.id,
    required this.workspaceId,
    required this.cameraId,
    required this.ruleId,
    required this.ruleSnapshotJson,
    required this.severity,
    required this.status,
    required this.openedAt,
    this.ackedAt,
    this.resolvedAt,
    this.evidenceFileKey,
    this.verification = const VerificationInfo(status: VerificationStatus.not_requested),
    required this.summary,
    this.signalContextJson = '{}',
    this.assignedTo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'cameraId': cameraId,
        'ruleId': ruleId,
        'ruleSnapshotJson': ruleSnapshotJson,
        'severity': severity.name,
        'status': status.name,
        'openedAt': openedAt.toIso8601String(),
        'ackedAt': ackedAt?.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
        'evidenceFileKey': evidenceFileKey,
        'verification': verification.toJson(),
        'summary': summary,
        'signalContextJson': signalContextJson,
        'assignedTo': assignedTo,
      };

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: json['id'] as int,
        workspaceId: json['workspaceId'] as int,
        cameraId: json['cameraId'] as int,
        ruleId: json['ruleId'] as int,
        ruleSnapshotJson: json['ruleSnapshotJson'] as String,
        severity: Severity.values.byName(json['severity'] as String),
        status: IncidentStatus.values.byName(json['status'] as String),
        openedAt: DateTime.parse(json['openedAt'] as String),
        ackedAt: json['ackedAt'] != null ? DateTime.parse(json['ackedAt'] as String) : null,
        resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
        evidenceFileKey: json['evidenceFileKey'] as String?,
        verification: json['verification'] != null
            ? VerificationInfo.fromJson(json['verification'] as Map<String, dynamic>)
            : const VerificationInfo(status: VerificationStatus.not_requested),
        summary: json['summary'] as String,
        signalContextJson: json['signalContextJson'] as String? ?? '{}',
        assignedTo: json['assignedTo'] as String?,
      );

  Incident copyWith({
    IncidentStatus? status,
    DateTime? ackedAt,
    DateTime? resolvedAt,
    VerificationInfo? verification,
  }) {
    return Incident(
      id: id,
      workspaceId: workspaceId,
      cameraId: cameraId,
      ruleId: ruleId,
      ruleSnapshotJson: ruleSnapshotJson,
      severity: severity,
      status: status ?? this.status,
      openedAt: openedAt,
      ackedAt: ackedAt ?? this.ackedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      evidenceFileKey: evidenceFileKey,
      verification: verification ?? this.verification,
      summary: summary,
      signalContextJson: signalContextJson,
      assignedTo: assignedTo,
    );
  }
}

class IncidentEvent {
  final int id;
  final int incidentId;
  final DateTime at;
  final String kind; // opened, evidence_added, verified, notified, escalated, acknowledged, resolved, false_positive, note
  final String detail;

  const IncidentEvent({
    required this.id,
    required this.incidentId,
    required this.at,
    required this.kind,
    required this.detail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'incidentId': incidentId,
        'at': at.toIso8601String(),
        'kind': kind,
        'detail': detail,
      };

  factory IncidentEvent.fromJson(Map<String, dynamic> json) => IncidentEvent(
        id: json['id'] as int,
        incidentId: json['incidentId'] as int,
        at: DateTime.parse(json['at'] as String),
        kind: json['kind'] as String,
        detail: json['detail'] as String,
      );
}

class IncidentUpdate {
  final Incident incident;
  final IncidentEvent? event;

  const IncidentUpdate({required this.incident, this.event});

  Map<String, dynamic> toJson() => {
        'incident': incident.toJson(),
        'event': event?.toJson(),
      };

  factory IncidentUpdate.fromJson(Map<String, dynamic> json) => IncidentUpdate(
        incident: Incident.fromJson(json['incident'] as Map<String, dynamic>),
        event: json['event'] != null
            ? IncidentEvent.fromJson(json['event'] as Map<String, dynamic>)
            : null,
      );
}

class AuditEntry {
  final int id;
  final int workspaceId;
  final DateTime at;
  final String actor;
  final String action;
  final String targetKind;
  final int targetId;
  final String detail;

  const AuditEntry({
    required this.id,
    required this.workspaceId,
    required this.at,
    required this.actor,
    required this.action,
    required this.targetKind,
    required this.targetId,
    required this.detail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'at': at.toIso8601String(),
        'actor': actor,
        'action': action,
        'targetKind': targetKind,
        'targetId': targetId,
        'detail': detail,
      };

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        id: json['id'] as int,
        workspaceId: json['workspaceId'] as int,
        at: DateTime.parse(json['at'] as String),
        actor: json['actor'] as String,
        action: json['action'] as String,
        targetKind: json['targetKind'] as String,
        targetId: json['targetId'] as int,
        detail: json['detail'] as String,
      );
}

class EvidenceUpload {
  final int incidentId;
  final String snapshotJpegBase64;
  final String? verificationCropJpeg;

  const EvidenceUpload({
    required this.incidentId,
    required this.snapshotJpegBase64,
    this.verificationCropJpeg,
  });

  Map<String, dynamic> toJson() => {
        'incidentId': incidentId,
        'snapshotJpegBase64': snapshotJpegBase64,
        'verificationCropJpeg': verificationCropJpeg,
      };

  factory EvidenceUpload.fromJson(Map<String, dynamic> json) => EvidenceUpload(
        incidentId: json['incidentId'] as int,
        snapshotJpegBase64: json['snapshotJpegBase64'] as String,
        verificationCropJpeg: json['verificationCropJpeg'] as String?,
      );
}

class LabClipResult {
  final String clipId;
  final String scenario;
  final int expectedEvents;
  final int detectedEvents;
  final int tp;
  final int fp;
  final int fn;
  final int latencyMsP50;

  const LabClipResult({
    required this.clipId,
    required this.scenario,
    required this.expectedEvents,
    required this.detectedEvents,
    required this.tp,
    required this.fp,
    required this.fn,
    required this.latencyMsP50,
  });

  Map<String, dynamic> toJson() => {
        'clipId': clipId,
        'scenario': scenario,
        'expectedEvents': expectedEvents,
        'detectedEvents': detectedEvents,
        'tp': tp,
        'fp': fp,
        'fn': fn,
        'latencyMsP50': latencyMsP50,
      };

  factory LabClipResult.fromJson(Map<String, dynamic> json) => LabClipResult(
        clipId: json['clipId'] as String,
        scenario: json['scenario'] as String,
        expectedEvents: json['expectedEvents'] as int,
        detectedEvents: json['detectedEvents'] as int,
        tp: json['tp'] as int,
        fp: json['fp'] as int,
        fn: json['fn'] as int,
        latencyMsP50: json['latencyMsP50'] as int,
      );
}

class DetectorLabReport {
  final List<LabClipResult> clips;
  final double precision;
  final double recall;
  final DateTime generatedAt;
  final String notes;

  const DetectorLabReport({
    required this.clips,
    required this.precision,
    required this.recall,
    required this.generatedAt,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'clips': clips.map((c) => c.toJson()).toList(),
        'precision': precision,
        'recall': recall,
        'generatedAt': generatedAt.toIso8601String(),
        'notes': notes,
      };

  factory DetectorLabReport.fromJson(Map<String, dynamic> json) =>
      DetectorLabReport(
        clips: (json['clips'] as List)
            .map((c) => LabClipResult.fromJson(c as Map<String, dynamic>))
            .toList(),
        precision: (json['precision'] as num).toDouble(),
        recall: (json['recall'] as num).toDouble(),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        notes: json['notes'] as String,
      );
}

class DemoSeedResult {
  final int workspaceId;
  final List<int> cameraIds;
  final List<int> ruleIds;

  const DemoSeedResult({
    required this.workspaceId,
    required this.cameraIds,
    required this.ruleIds,
  });

  Map<String, dynamic> toJson() => {
        'workspaceId': workspaceId,
        'cameraIds': cameraIds,
        'ruleIds': ruleIds,
      };

  factory DemoSeedResult.fromJson(Map<String, dynamic> json) => DemoSeedResult(
        workspaceId: json['workspaceId'] as int,
        cameraIds: (json['cameraIds'] as List).map((e) => e as int).toList(),
        ruleIds: (json['ruleIds'] as List).map((e) => e as int).toList(),
      );
}

class HealthInfo {
  final String version;
  final String engineVersion;
  final String geminiState; // "available" | "limited" | "off"
  final String quotaNote;
  final int queueDepth;

  const HealthInfo({
    required this.version,
    required this.engineVersion,
    required this.geminiState,
    required this.quotaNote,
    required this.queueDepth,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'engineVersion': engineVersion,
        'geminiState': geminiState,
        'quotaNote': quotaNote,
        'queueDepth': queueDepth,
      };

  factory HealthInfo.fromJson(Map<String, dynamic> json) => HealthInfo(
        version: json['version'] as String,
        engineVersion: json['engineVersion'] as String,
        geminiState: json['geminiState'] as String,
        quotaNote: json['quotaNote'] as String,
        queueDepth: json['queueDepth'] as int,
      );
}

class ClientConfig {
  final Map<String, dynamic> limits;
  final Map<String, bool> features;

  const ClientConfig({
    required this.limits,
    required this.features,
  });

  Map<String, dynamic> toJson() => {
        'limits': limits,
        'features': features,
      };

  factory ClientConfig.fromJson(Map<String, dynamic> json) => ClientConfig(
        limits: json['limits'] as Map<String, dynamic>,
        features: (json['features'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v as bool)),
      );
}

class DryRunResult {
  final bool triggered;
  final int? triggeredAtMs;
  final String explanation;
  final List<int> firedPointsMs;

  const DryRunResult({
    required this.triggered,
    this.triggeredAtMs,
    required this.explanation,
    this.firedPointsMs = const [],
  });

  Map<String, dynamic> toJson() => {
        'triggered': triggered,
        'triggeredAtMs': triggeredAtMs,
        'explanation': explanation,
        'firedPointsMs': firedPointsMs,
      };

  factory DryRunResult.fromJson(Map<String, dynamic> json) => DryRunResult(
        triggered: json['triggered'] as bool,
        triggeredAtMs: json['triggeredAtMs'] as int?,
        explanation: json['explanation'] as String,
        firedPointsMs: (json['firedPointsMs'] as List? ?? []).map((e) => e as int).toList(),
      );
}

class IncidentDetail {
  final Incident incident;
  final List<IncidentEvent> events;
  final String? evidenceUrl;

  const IncidentDetail({
    required this.incident,
    required this.events,
    this.evidenceUrl,
  });

  Map<String, dynamic> toJson() => {
        'incident': incident.toJson(),
        'events': events.map((e) => e.toJson()).toList(),
        'evidenceUrl': evidenceUrl,
      };

  factory IncidentDetail.fromJson(Map<String, dynamic> json) => IncidentDetail(
        incident: Incident.fromJson(json['incident'] as Map<String, dynamic>),
        events: (json['events'] as List)
            .map((e) => IncidentEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        evidenceUrl: json['evidenceUrl'] as String?,
      );
}

class IncidentFilter {
  final IncidentStatus? status;
  final Severity? severity;
  final int? cameraId;
  final int? ruleId;

  const IncidentFilter({
    this.status,
    this.severity,
    this.cameraId,
    this.ruleId,
  });
}
