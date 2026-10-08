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
import 'package:argus_server/src/generated/protocol.dart' as _iggnejrg;
import 'package:serverpod/serverpod.dart' as _is;
import 'rule_action.dart' as _ie2yorw3;
import 'rule_conditions.dart' as _ibwozmvt;
import 'rule_escalation.dart' as _ig7l9g0k;
import 'rule_trigger.dart' as _iszxsrqr;
import 'rule_verify.dart' as _i0rdyykc;

abstract class RuleSpec
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      enabled: _is.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      cameraIds: _iggnejrg.Protocol().deserialize<List<int>>(
        jsonSerialization['cameraIds'],
      ),
      trigger: _iggnejrg.Protocol().deserialize<_iszxsrqr.RuleTrigger>(
        jsonSerialization['trigger'],
      ),
      conditions: _iggnejrg.Protocol().deserialize<_ibwozmvt.RuleConditions>(
        jsonSerialization['conditions'],
      ),
      severity: jsonSerialization['severity'] as String,
      verify: _iggnejrg.Protocol().deserialize<_i0rdyykc.RuleVerify>(
        jsonSerialization['verify'],
      ),
      actions: _iggnejrg.Protocol().deserialize<List<_ie2yorw3.RuleAction>>(
        jsonSerialization['actions'],
      ),
      cooldownSec: jsonSerialization['cooldownSec'] as int,
      escalation: _iggnejrg.Protocol()
          .deserialize<List<_ig7l9g0k.RuleEscalation>>(
            jsonSerialization['escalation'],
          ),
      sourceText: jsonSerialization['sourceText'] as String,
      parsedBy: jsonSerialization['parsedBy'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      version: jsonSerialization['version'] as int,
    );
  }

  static final t = RuleSpecTable();

  static const db = RuleSpecRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RuleSpec]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static RuleSpecInclude include() {
    return RuleSpecInclude._();
  }

  static RuleSpecIncludeList includeList({
    _is.WhereExpressionBuilder<RuleSpecTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RuleSpecTable>? orderBy,
    _is.OrderByListBuilder<RuleSpecTable>? orderByList,
    RuleSpecInclude? include,
  }) {
    return RuleSpecIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RuleSpec.t),
      orderByList: orderByList?.call(RuleSpec.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class RuleSpecUpdateTable extends _is.UpdateTable<RuleSpecTable> {
  RuleSpecUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<bool, bool> enabled(bool value) => _is.ColumnValue(
    table.enabled,
    value,
  );

  _is.ColumnValue<List<int>, List<int>> cameraIds(List<int> value) =>
      _is.ColumnValue(
        table.cameraIds,
        value,
      );

  _is.ColumnValue<_iszxsrqr.RuleTrigger, _iszxsrqr.RuleTrigger> trigger(
    _iszxsrqr.RuleTrigger value,
  ) => _is.ColumnValue(
    table.trigger,
    value,
  );

  _is.ColumnValue<_ibwozmvt.RuleConditions, _ibwozmvt.RuleConditions>
  conditions(_ibwozmvt.RuleConditions value) => _is.ColumnValue(
    table.conditions,
    value,
  );

  _is.ColumnValue<String, String> severity(String value) => _is.ColumnValue(
    table.severity,
    value,
  );

  _is.ColumnValue<_i0rdyykc.RuleVerify, _i0rdyykc.RuleVerify> verify(
    _i0rdyykc.RuleVerify value,
  ) => _is.ColumnValue(
    table.verify,
    value,
  );

  _is.ColumnValue<List<_ie2yorw3.RuleAction>, List<_ie2yorw3.RuleAction>>
  actions(List<_ie2yorw3.RuleAction> value) => _is.ColumnValue(
    table.actions,
    value,
  );

  _is.ColumnValue<int, int> cooldownSec(int value) => _is.ColumnValue(
    table.cooldownSec,
    value,
  );

  _is.ColumnValue<
    List<_ig7l9g0k.RuleEscalation>,
    List<_ig7l9g0k.RuleEscalation>
  >
  escalation(List<_ig7l9g0k.RuleEscalation> value) => _is.ColumnValue(
    table.escalation,
    value,
  );

  _is.ColumnValue<String, String> sourceText(String value) => _is.ColumnValue(
    table.sourceText,
    value,
  );

  _is.ColumnValue<String, String> parsedBy(String value) => _is.ColumnValue(
    table.parsedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class RuleSpecTable extends _is.Table<int?> {
  RuleSpecTable({super.tableRelation}) : super(tableName: 'argus_rule_spec') {
    updateTable = RuleSpecUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    enabled = _is.ColumnBool(
      'enabled',
      this,
    );
    cameraIds = _is.ColumnSerializable<List<int>>(
      'cameraIds',
      this,
    );
    trigger = _is.ColumnSerializable<_iszxsrqr.RuleTrigger>(
      'trigger',
      this,
    );
    conditions = _is.ColumnSerializable<_ibwozmvt.RuleConditions>(
      'conditions',
      this,
    );
    severity = _is.ColumnString(
      'severity',
      this,
    );
    verify = _is.ColumnSerializable<_i0rdyykc.RuleVerify>(
      'verify',
      this,
    );
    actions = _is.ColumnSerializable<List<_ie2yorw3.RuleAction>>(
      'actions',
      this,
    );
    cooldownSec = _is.ColumnInt(
      'cooldownSec',
      this,
    );
    escalation = _is.ColumnSerializable<List<_ig7l9g0k.RuleEscalation>>(
      'escalation',
      this,
    );
    sourceText = _is.ColumnString(
      'sourceText',
      this,
    );
    parsedBy = _is.ColumnString(
      'parsedBy',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
  }

  late final RuleSpecUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnString name;

  late final _is.ColumnBool enabled;

  late final _is.ColumnSerializable<List<int>> cameraIds;

  late final _is.ColumnSerializable<_iszxsrqr.RuleTrigger> trigger;

  late final _is.ColumnSerializable<_ibwozmvt.RuleConditions> conditions;

  late final _is.ColumnString severity;

  late final _is.ColumnSerializable<_i0rdyykc.RuleVerify> verify;

  late final _is.ColumnSerializable<List<_ie2yorw3.RuleAction>> actions;

  late final _is.ColumnInt cooldownSec;

  late final _is.ColumnSerializable<List<_ig7l9g0k.RuleEscalation>> escalation;

  late final _is.ColumnString sourceText;

  late final _is.ColumnString parsedBy;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnInt version;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    name,
    enabled,
    cameraIds,
    trigger,
    conditions,
    severity,
    verify,
    actions,
    cooldownSec,
    escalation,
    sourceText,
    parsedBy,
    createdAt,
    version,
  ];
}

class RuleSpecInclude extends _is.IncludeObject {
  RuleSpecInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RuleSpec.t;
}

class RuleSpecIncludeList extends _is.IncludeList {
  RuleSpecIncludeList._({
    _is.WhereExpressionBuilder<RuleSpecTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RuleSpec.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RuleSpec.t;
}

class RuleSpecRepository {
  const RuleSpecRepository._();

  /// Returns a list of [RuleSpec]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<RuleSpec>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RuleSpecTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RuleSpecTable>? orderBy,
    _is.OrderByListBuilder<RuleSpecTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RuleSpec>(
      where: where?.call(RuleSpec.t),
      orderBy: orderBy?.call(RuleSpec.t),
      orderByList: orderByList?.call(RuleSpec.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RuleSpec] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<RuleSpec?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RuleSpecTable>? where,
    int? offset,
    _is.OrderByBuilder<RuleSpecTable>? orderBy,
    _is.OrderByListBuilder<RuleSpecTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RuleSpec>(
      where: where?.call(RuleSpec.t),
      orderBy: orderBy?.call(RuleSpec.t),
      orderByList: orderByList?.call(RuleSpec.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RuleSpec] by its [id] or null if no such row exists.
  Future<RuleSpec?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RuleSpec>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RuleSpec]s in the list and returns the inserted rows.
  ///
  /// The returned [RuleSpec]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RuleSpec>> insert(
    _is.DatabaseSession session,
    List<RuleSpec> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RuleSpec>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RuleSpec] and returns the inserted row.
  ///
  /// The returned [RuleSpec] will have its `id` field set.
  Future<RuleSpec> insertRow(
    _is.DatabaseSession session,
    RuleSpec row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RuleSpec>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RuleSpec]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [RuleSpec]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RuleSpec>> upsert(
    _is.DatabaseSession session,
    List<RuleSpec> rows, {
    required _is.ColumnSelections<RuleSpecTable> conflictColumns,
    _is.ColumnSelections<RuleSpecTable>? updateColumns,
    _is.WhereExpressionBuilder<RuleSpecTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RuleSpec>(
      rows,
      conflictColumns: conflictColumns(RuleSpec.t),
      updateColumns: updateColumns?.call(RuleSpec.t),
      updateWhere: updateWhere?.call(RuleSpec.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RuleSpec] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [RuleSpec] will have its `id` field set.
  Future<RuleSpec?> upsertRow(
    _is.DatabaseSession session,
    RuleSpec row, {
    required _is.ColumnSelections<RuleSpecTable> conflictColumns,
    _is.ColumnSelections<RuleSpecTable>? updateColumns,
    _is.WhereExpressionBuilder<RuleSpecTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RuleSpec>(
      row,
      conflictColumns: conflictColumns(RuleSpec.t),
      updateColumns: updateColumns?.call(RuleSpec.t),
      updateWhere: updateWhere?.call(RuleSpec.t),
      transaction: transaction,
    );
  }

  /// Updates all [RuleSpec]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RuleSpec>> update(
    _is.DatabaseSession session,
    List<RuleSpec> rows, {
    _is.ColumnSelections<RuleSpecTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RuleSpec>(
      rows,
      columns: columns?.call(RuleSpec.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RuleSpec]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RuleSpec> updateRow(
    _is.DatabaseSession session,
    RuleSpec row, {
    _is.ColumnSelections<RuleSpecTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RuleSpec>(
      row,
      columns: columns?.call(RuleSpec.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RuleSpec] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RuleSpec?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RuleSpecUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RuleSpec>(
      id,
      columnValues: columnValues(RuleSpec.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RuleSpec]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RuleSpec>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RuleSpecUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RuleSpecTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RuleSpecTable>? orderBy,
    _is.OrderByListBuilder<RuleSpecTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RuleSpec>(
      columnValues: columnValues(RuleSpec.t.updateTable),
      where: where(RuleSpec.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RuleSpec.t),
      orderByList: orderByList?.call(RuleSpec.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RuleSpec]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RuleSpec>> delete(
    _is.DatabaseSession session,
    List<RuleSpec> rows, {
    _is.OrderByBuilder<RuleSpecTable>? orderBy,
    _is.OrderByListBuilder<RuleSpecTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RuleSpec>(
      rows,
      orderBy: orderBy?.call(RuleSpec.t),
      orderByList: orderByList?.call(RuleSpec.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RuleSpec].
  Future<RuleSpec> deleteRow(
    _is.DatabaseSession session,
    RuleSpec row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RuleSpec>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RuleSpec>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RuleSpecTable> where,
    _is.OrderByBuilder<RuleSpecTable>? orderBy,
    _is.OrderByListBuilder<RuleSpecTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RuleSpec>(
      where: where(RuleSpec.t),
      orderBy: orderBy?.call(RuleSpec.t),
      orderByList: orderByList?.call(RuleSpec.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RuleSpecTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RuleSpec>(
      where: where?.call(RuleSpec.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RuleSpec] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RuleSpecTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RuleSpec>(
      where: where(RuleSpec.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
