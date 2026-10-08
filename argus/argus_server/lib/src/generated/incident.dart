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
import 'verification_info.dart' as _iv8f4ltc;

abstract class Incident
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Incident._({
    this.id,
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
    required this.verification,
    required this.summary,
    required this.signalContextJson,
    this.assignedTo,
  });

  factory Incident({
    int? id,
    required int workspaceId,
    required int cameraId,
    required int ruleId,
    required String ruleSnapshotJson,
    required String severity,
    required String status,
    required DateTime openedAt,
    DateTime? ackedAt,
    DateTime? resolvedAt,
    String? evidenceFileKey,
    required _iv8f4ltc.VerificationInfo verification,
    required String summary,
    required String signalContextJson,
    String? assignedTo,
  }) = _IncidentImpl;

  factory Incident.fromJson(Map<String, dynamic> jsonSerialization) {
    return Incident(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      cameraId: jsonSerialization['cameraId'] as int,
      ruleId: jsonSerialization['ruleId'] as int,
      ruleSnapshotJson: jsonSerialization['ruleSnapshotJson'] as String,
      severity: jsonSerialization['severity'] as String,
      status: jsonSerialization['status'] as String,
      openedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['openedAt'],
      ),
      ackedAt: jsonSerialization['ackedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['ackedAt']),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
      evidenceFileKey: jsonSerialization['evidenceFileKey'] as String?,
      verification: _iggnejrg.Protocol()
          .deserialize<_iv8f4ltc.VerificationInfo>(
            jsonSerialization['verification'],
          ),
      summary: jsonSerialization['summary'] as String,
      signalContextJson: jsonSerialization['signalContextJson'] as String,
      assignedTo: jsonSerialization['assignedTo'] as String?,
    );
  }

  static final t = IncidentTable();

  static const db = IncidentRepository._();

  @override
  int? id;

  int workspaceId;

  int cameraId;

  int ruleId;

  String ruleSnapshotJson;

  String severity;

  String status;

  DateTime openedAt;

  DateTime? ackedAt;

  DateTime? resolvedAt;

  String? evidenceFileKey;

  _iv8f4ltc.VerificationInfo verification;

  String summary;

  String signalContextJson;

  String? assignedTo;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Incident]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Incident copyWith({
    int? id,
    int? workspaceId,
    int? cameraId,
    int? ruleId,
    String? ruleSnapshotJson,
    String? severity,
    String? status,
    DateTime? openedAt,
    DateTime? ackedAt,
    DateTime? resolvedAt,
    String? evidenceFileKey,
    _iv8f4ltc.VerificationInfo? verification,
    String? summary,
    String? signalContextJson,
    String? assignedTo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Incident',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'cameraId': cameraId,
      'ruleId': ruleId,
      'ruleSnapshotJson': ruleSnapshotJson,
      'severity': severity,
      'status': status,
      'openedAt': openedAt.toJson(),
      if (ackedAt != null) 'ackedAt': ackedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (evidenceFileKey != null) 'evidenceFileKey': evidenceFileKey,
      'verification': verification.toJson(),
      'summary': summary,
      'signalContextJson': signalContextJson,
      if (assignedTo != null) 'assignedTo': assignedTo,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Incident',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'cameraId': cameraId,
      'ruleId': ruleId,
      'ruleSnapshotJson': ruleSnapshotJson,
      'severity': severity,
      'status': status,
      'openedAt': openedAt.toJson(),
      if (ackedAt != null) 'ackedAt': ackedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (evidenceFileKey != null) 'evidenceFileKey': evidenceFileKey,
      'verification': verification.toJsonForProtocol(),
      'summary': summary,
      'signalContextJson': signalContextJson,
      if (assignedTo != null) 'assignedTo': assignedTo,
    };
  }

  static IncidentInclude include() {
    return IncidentInclude._();
  }

  static IncidentIncludeList includeList({
    _is.WhereExpressionBuilder<IncidentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    IncidentInclude? include,
  }) {
    return IncidentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentImpl extends Incident {
  _IncidentImpl({
    int? id,
    required int workspaceId,
    required int cameraId,
    required int ruleId,
    required String ruleSnapshotJson,
    required String severity,
    required String status,
    required DateTime openedAt,
    DateTime? ackedAt,
    DateTime? resolvedAt,
    String? evidenceFileKey,
    required _iv8f4ltc.VerificationInfo verification,
    required String summary,
    required String signalContextJson,
    String? assignedTo,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         cameraId: cameraId,
         ruleId: ruleId,
         ruleSnapshotJson: ruleSnapshotJson,
         severity: severity,
         status: status,
         openedAt: openedAt,
         ackedAt: ackedAt,
         resolvedAt: resolvedAt,
         evidenceFileKey: evidenceFileKey,
         verification: verification,
         summary: summary,
         signalContextJson: signalContextJson,
         assignedTo: assignedTo,
       );

  /// Returns a shallow copy of this [Incident]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Incident copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    int? cameraId,
    int? ruleId,
    String? ruleSnapshotJson,
    String? severity,
    String? status,
    DateTime? openedAt,
    Object? ackedAt = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? evidenceFileKey = _Undefined,
    _iv8f4ltc.VerificationInfo? verification,
    String? summary,
    String? signalContextJson,
    Object? assignedTo = _Undefined,
  }) {
    return Incident(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      cameraId: cameraId ?? this.cameraId,
      ruleId: ruleId ?? this.ruleId,
      ruleSnapshotJson: ruleSnapshotJson ?? this.ruleSnapshotJson,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      ackedAt: ackedAt is DateTime? ? ackedAt : this.ackedAt,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      evidenceFileKey: evidenceFileKey is String?
          ? evidenceFileKey
          : this.evidenceFileKey,
      verification: verification ?? this.verification.copyWith(),
      summary: summary ?? this.summary,
      signalContextJson: signalContextJson ?? this.signalContextJson,
      assignedTo: assignedTo is String? ? assignedTo : this.assignedTo,
    );
  }
}

class IncidentUpdateTable extends _is.UpdateTable<IncidentTable> {
  IncidentUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<int, int> cameraId(int value) => _is.ColumnValue(
    table.cameraId,
    value,
  );

  _is.ColumnValue<int, int> ruleId(int value) => _is.ColumnValue(
    table.ruleId,
    value,
  );

  _is.ColumnValue<String, String> ruleSnapshotJson(String value) =>
      _is.ColumnValue(
        table.ruleSnapshotJson,
        value,
      );

  _is.ColumnValue<String, String> severity(String value) => _is.ColumnValue(
    table.severity,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> openedAt(DateTime value) =>
      _is.ColumnValue(
        table.openedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> ackedAt(DateTime? value) =>
      _is.ColumnValue(
        table.ackedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _is.ColumnValue(
        table.resolvedAt,
        value,
      );

  _is.ColumnValue<String, String> evidenceFileKey(String? value) =>
      _is.ColumnValue(
        table.evidenceFileKey,
        value,
      );

  _is.ColumnValue<_iv8f4ltc.VerificationInfo, _iv8f4ltc.VerificationInfo>
  verification(_iv8f4ltc.VerificationInfo value) => _is.ColumnValue(
    table.verification,
    value,
  );

  _is.ColumnValue<String, String> summary(String value) => _is.ColumnValue(
    table.summary,
    value,
  );

  _is.ColumnValue<String, String> signalContextJson(String value) =>
      _is.ColumnValue(
        table.signalContextJson,
        value,
      );

  _is.ColumnValue<String, String> assignedTo(String? value) => _is.ColumnValue(
    table.assignedTo,
    value,
  );
}

class IncidentTable extends _is.Table<int?> {
  IncidentTable({super.tableRelation}) : super(tableName: 'argus_incident') {
    updateTable = IncidentUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    cameraId = _is.ColumnInt(
      'cameraId',
      this,
    );
    ruleId = _is.ColumnInt(
      'ruleId',
      this,
    );
    ruleSnapshotJson = _is.ColumnString(
      'ruleSnapshotJson',
      this,
    );
    severity = _is.ColumnString(
      'severity',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    openedAt = _is.ColumnDateTime(
      'openedAt',
      this,
    );
    ackedAt = _is.ColumnDateTime(
      'ackedAt',
      this,
    );
    resolvedAt = _is.ColumnDateTime(
      'resolvedAt',
      this,
    );
    evidenceFileKey = _is.ColumnString(
      'evidenceFileKey',
      this,
    );
    verification = _is.ColumnSerializable<_iv8f4ltc.VerificationInfo>(
      'verification',
      this,
    );
    summary = _is.ColumnString(
      'summary',
      this,
    );
    signalContextJson = _is.ColumnString(
      'signalContextJson',
      this,
    );
    assignedTo = _is.ColumnString(
      'assignedTo',
      this,
    );
  }

  late final IncidentUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnInt cameraId;

  late final _is.ColumnInt ruleId;

  late final _is.ColumnString ruleSnapshotJson;

  late final _is.ColumnString severity;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime openedAt;

  late final _is.ColumnDateTime ackedAt;

  late final _is.ColumnDateTime resolvedAt;

  late final _is.ColumnString evidenceFileKey;

  late final _is.ColumnSerializable<_iv8f4ltc.VerificationInfo> verification;

  late final _is.ColumnString summary;

  late final _is.ColumnString signalContextJson;

  late final _is.ColumnString assignedTo;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    cameraId,
    ruleId,
    ruleSnapshotJson,
    severity,
    status,
    openedAt,
    ackedAt,
    resolvedAt,
    evidenceFileKey,
    verification,
    summary,
    signalContextJson,
    assignedTo,
  ];
}

class IncidentInclude extends _is.IncludeObject {
  IncidentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Incident.t;
}

class IncidentIncludeList extends _is.IncludeList {
  IncidentIncludeList._({
    _is.WhereExpressionBuilder<IncidentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Incident.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Incident.t;
}

class IncidentRepository {
  const IncidentRepository._();

  /// Returns a list of [Incident]s matching the given query parameters.
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
  Future<List<Incident>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Incident>(
      where: where?.call(Incident.t),
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Incident] matching the given query parameters.
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
  Future<Incident?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentTable>? where,
    int? offset,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Incident>(
      where: where?.call(Incident.t),
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Incident] by its [id] or null if no such row exists.
  Future<Incident?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Incident>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Incident]s in the list and returns the inserted rows.
  ///
  /// The returned [Incident]s will have their `id` fields set.
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
  Future<List<Incident>> insert(
    _is.DatabaseSession session,
    List<Incident> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Incident>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Incident] and returns the inserted row.
  ///
  /// The returned [Incident] will have its `id` field set.
  Future<Incident> insertRow(
    _is.DatabaseSession session,
    Incident row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Incident>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Incident]s in the list and returns the resulting rows.
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
  /// The returned [Incident]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> upsert(
    _is.DatabaseSession session,
    List<Incident> rows, {
    required _is.ColumnSelections<IncidentTable> conflictColumns,
    _is.ColumnSelections<IncidentTable>? updateColumns,
    _is.WhereExpressionBuilder<IncidentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Incident>(
      rows,
      conflictColumns: conflictColumns(Incident.t),
      updateColumns: updateColumns?.call(Incident.t),
      updateWhere: updateWhere?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Incident] and returns the resulting row.
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
  /// The returned [Incident] will have its `id` field set.
  Future<Incident?> upsertRow(
    _is.DatabaseSession session,
    Incident row, {
    required _is.ColumnSelections<IncidentTable> conflictColumns,
    _is.ColumnSelections<IncidentTable>? updateColumns,
    _is.WhereExpressionBuilder<IncidentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Incident>(
      row,
      conflictColumns: conflictColumns(Incident.t),
      updateColumns: updateColumns?.call(Incident.t),
      updateWhere: updateWhere?.call(Incident.t),
      transaction: transaction,
    );
  }

  /// Updates all [Incident]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> update(
    _is.DatabaseSession session,
    List<Incident> rows, {
    _is.ColumnSelections<IncidentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Incident>(
      rows,
      columns: columns?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Incident]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Incident> updateRow(
    _is.DatabaseSession session,
    Incident row, {
    _is.ColumnSelections<IncidentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Incident>(
      row,
      columns: columns?.call(Incident.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Incident] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Incident?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<IncidentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Incident>(
      id,
      columnValues: columnValues(Incident.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Incident]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Incident>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IncidentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<IncidentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Incident>(
      columnValues: columnValues(Incident.t.updateTable),
      where: where(Incident.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Incident]s in the list and returns the deleted rows.
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
  Future<List<Incident>> delete(
    _is.DatabaseSession session,
    List<Incident> rows, {
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Incident>(
      rows,
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Incident].
  Future<Incident> deleteRow(
    _is.DatabaseSession session,
    Incident row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Incident>(
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
  Future<List<Incident>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IncidentTable> where,
    _is.OrderByBuilder<IncidentTable>? orderBy,
    _is.OrderByListBuilder<IncidentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Incident>(
      where: where(Incident.t),
      orderBy: orderBy?.call(Incident.t),
      orderByList: orderByList?.call(Incident.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IncidentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Incident>(
      where: where?.call(Incident.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Incident] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IncidentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Incident>(
      where: where(Incident.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
