/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:argus_client/src/protocol/protocol.dart' as _i5naexi9;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'rule_action.dart' as _ie2yorw3;
import 'rule_conditions.dart' as _ibwozmvt;
import 'rule_escalation.dart' as _ig7l9g0k;
import 'rule_trigger.dart' as _iszxsrqr;
import 'rule_verify.dart' as _i0rdyykc;

abstract class RuleSpec
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RuleSpec._({
    this.id,
    required this.workspaceId,
    required this.name,
    required this.enabled,
    required this.cameraIds,
    required this.trigger,
    required this.conditions,
    required this.severity,
    required this.verify,
    required this.actions,
    required this.cooldownSec,
    required this.escalation,
    required this.sourceText,
    required this.parsedBy,
    required this.createdAt,
    required this.version,
  });

  factory RuleSpec({
    int? id,
    required int workspaceId,
    required String name,
    required bool enabled,
    required List<int> cameraIds,
    required _iszxsrqr.RuleTrigger trigger,
    required _ibwozmvt.RuleConditions conditions,
    required String severity,
    required _i0rdyykc.RuleVerify verify,
    required List<_ie2yorw3.RuleAction> actions,
    required int cooldownSec,
    required List<_ig7l9g0k.RuleEscalation> escalation,
    required String sourceText,
    required String parsedBy,
    required DateTime createdAt,
    required int version,
  }) = _RuleSpecImpl;

  factory RuleSpec.fromJson(Map<String, dynamic> jsonSerialization) {
    return RuleSpec(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      name: jsonSerialization['name'] as String,
      enabled: _isc.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      cameraIds: _i5naexi9.Protocol().deserialize<List<int>>(
        jsonSerialization['cameraIds'],
      ),
      trigger: _i5naexi9.Protocol().deserialize<_iszxsrqr.RuleTrigger>(
        jsonSerialization['trigger'],
      ),
      conditions: _i5naexi9.Protocol().deserialize<_ibwozmvt.RuleConditions>(
        jsonSerialization['conditions'],
      ),
      severity: jsonSerialization['severity'] as String,
      verify: _i5naexi9.Protocol().deserialize<_i0rdyykc.RuleVerify>(
        jsonSerialization['verify'],
      ),
      actions: _i5naexi9.Protocol().deserialize<List<_ie2yorw3.RuleAction>>(
        jsonSerialization['actions'],
      ),
      cooldownSec: jsonSerialization['cooldownSec'] as int,
      escalation: _i5naexi9.Protocol()
          .deserialize<List<_ig7l9g0k.RuleEscalation>>(
            jsonSerialization['escalation'],
          ),
      sourceText: jsonSerialization['sourceText'] as String,
      parsedBy: jsonSerialization['parsedBy'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      version: jsonSerialization['version'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int workspaceId;

  String name;

  bool enabled;

  List<int> cameraIds;

  _iszxsrqr.RuleTrigger trigger;

  _ibwozmvt.RuleConditions conditions;

  String severity;

  _i0rdyykc.RuleVerify verify;

  List<_ie2yorw3.RuleAction> actions;

  int cooldownSec;

  List<_ig7l9g0k.RuleEscalation> escalation;

  String sourceText;

  String parsedBy;

  DateTime createdAt;

  int version;

  /// Returns a shallow copy of this [RuleSpec]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RuleSpec copyWith({
    int? id,
    int? workspaceId,
    String? name,
    bool? enabled,
    List<int>? cameraIds,
    _iszxsrqr.RuleTrigger? trigger,
    _ibwozmvt.RuleConditions? conditions,
    String? severity,
    _i0rdyykc.RuleVerify? verify,
    List<_ie2yorw3.RuleAction>? actions,
    int? cooldownSec,
    List<_ig7l9g0k.RuleEscalation>? escalation,
    String? sourceText,
    String? parsedBy,
    DateTime? createdAt,
    int? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RuleSpec',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'enabled': enabled,
      'cameraIds': cameraIds.toJson(),
      'trigger': trigger.toJson(),
      'conditions': conditions.toJson(),
      'severity': severity,
      'verify': verify.toJson(),
      'actions': actions.toJson(valueToJson: (v) => v.toJson()),
      'cooldownSec': cooldownSec,
      'escalation': escalation.toJson(valueToJson: (v) => v.toJson()),
      'sourceText': sourceText,
      'parsedBy': parsedBy,
      'createdAt': createdAt.toJson(),
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RuleSpec',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'enabled': enabled,
      'cameraIds': cameraIds.toJson(),
      'trigger': trigger.toJsonForProtocol(),
      'conditions': conditions.toJsonForProtocol(),
      'severity': severity,
      'verify': verify.toJsonForProtocol(),
      'actions': actions.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'cooldownSec': cooldownSec,
      'escalation': escalation.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'sourceText': sourceText,
      'parsedBy': parsedBy,
      'createdAt': createdAt.toJson(),
      'version': version,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RuleSpecImpl extends RuleSpec {
  _RuleSpecImpl({
    int? id,
    required int workspaceId,
    required String name,
    required bool enabled,
    required List<int> cameraIds,
    required _iszxsrqr.RuleTrigger trigger,
    required _ibwozmvt.RuleConditions conditions,
    required String severity,
    required _i0rdyykc.RuleVerify verify,
    required List<_ie2yorw3.RuleAction> actions,
    required int cooldownSec,
    required List<_ig7l9g0k.RuleEscalation> escalation,
    required String sourceText,
    required String parsedBy,
    required DateTime createdAt,
    required int version,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         name: name,
         enabled: enabled,
         cameraIds: cameraIds,
         trigger: trigger,
         conditions: conditions,
         severity: severity,
         verify: verify,
         actions: actions,
         cooldownSec: cooldownSec,
         escalation: escalation,
         sourceText: sourceText,
         parsedBy: parsedBy,
         createdAt: createdAt,
         version: version,
       );

  /// Returns a shallow copy of this [RuleSpec]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RuleSpec copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? name,
    bool? enabled,
    List<int>? cameraIds,
    _iszxsrqr.RuleTrigger? trigger,
    _ibwozmvt.RuleConditions? conditions,
    String? severity,
    _i0rdyykc.RuleVerify? verify,
    List<_ie2yorw3.RuleAction>? actions,
    int? cooldownSec,
    List<_ig7l9g0k.RuleEscalation>? escalation,
    String? sourceText,
    String? parsedBy,
    DateTime? createdAt,
    int? version,
  }) {
    return RuleSpec(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      cameraIds: cameraIds ?? this.cameraIds.map((e0) => e0).toList(),
      trigger: trigger ?? this.trigger.copyWith(),
      conditions: conditions ?? this.conditions.copyWith(),
      severity: severity ?? this.severity,
      verify: verify ?? this.verify.copyWith(),
      actions: actions ?? this.actions.map((e0) => e0.copyWith()).toList(),
      cooldownSec: cooldownSec ?? this.cooldownSec,
      escalation:
          escalation ?? this.escalation.map((e0) => e0.copyWith()).toList(),
      sourceText: sourceText ?? this.sourceText,
      parsedBy: parsedBy ?? this.parsedBy,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
    );
  }
}
