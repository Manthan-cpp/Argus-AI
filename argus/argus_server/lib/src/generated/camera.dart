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
import 'package:serverpod/serverpod.dart' as _is;

abstract class Camera implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Camera._({
    this.id,
    required this.workspaceId,
    required this.name,
    required this.sourceKind,
    required this.sourceRef,
    required this.enabled,
    required this.createdAt,
    this.lastSignalAt,
    required this.status,
  });

  factory Camera({
    int? id,
    required int workspaceId,
    required String name,
    required String sourceKind,
    required String sourceRef,
    required bool enabled,
    required DateTime createdAt,
    DateTime? lastSignalAt,
    required String status,
  }) = _CameraImpl;

  factory Camera.fromJson(Map<String, dynamic> jsonSerialization) {
    return Camera(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      name: jsonSerialization['name'] as String,
      sourceKind: jsonSerialization['sourceKind'] as String,
      sourceRef: jsonSerialization['sourceRef'] as String,
      enabled: _is.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lastSignalAt: jsonSerialization['lastSignalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSignalAt'],
            ),
      status: jsonSerialization['status'] as String,
    );
  }

  static final t = CameraTable();

  static const db = CameraRepository._();

  @override
  int? id;

  int workspaceId;

  String name;

  String sourceKind;

  String sourceRef;

  bool enabled;

  DateTime createdAt;

  DateTime? lastSignalAt;

  String status;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Camera]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Camera copyWith({
    int? id,
    int? workspaceId,
    String? name,
    String? sourceKind,
    String? sourceRef,
    bool? enabled,
    DateTime? createdAt,
    DateTime? lastSignalAt,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Camera',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'sourceKind': sourceKind,
      'sourceRef': sourceRef,
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
      if (lastSignalAt != null) 'lastSignalAt': lastSignalAt?.toJson(),
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Camera',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'sourceKind': sourceKind,
      'sourceRef': sourceRef,
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
      if (lastSignalAt != null) 'lastSignalAt': lastSignalAt?.toJson(),
      'status': status,
    };
  }

  static CameraInclude include() {
    return CameraInclude._();
  }

  static CameraIncludeList includeList({
    _is.WhereExpressionBuilder<CameraTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CameraTable>? orderBy,
    _is.OrderByListBuilder<CameraTable>? orderByList,
    CameraInclude? include,
  }) {
    return CameraIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Camera.t),
      orderByList: orderByList?.call(Camera.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CameraImpl extends Camera {
  _CameraImpl({
    int? id,
    required int workspaceId,
    required String name,
    required String sourceKind,
    required String sourceRef,
    required bool enabled,
    required DateTime createdAt,
    DateTime? lastSignalAt,
    required String status,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         name: name,
         sourceKind: sourceKind,
         sourceRef: sourceRef,
         enabled: enabled,
         createdAt: createdAt,
         lastSignalAt: lastSignalAt,
         status: status,
       );

  /// Returns a shallow copy of this [Camera]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Camera copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? name,
    String? sourceKind,
    String? sourceRef,
    bool? enabled,
    DateTime? createdAt,
    Object? lastSignalAt = _Undefined,
    String? status,
  }) {
    return Camera(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceRef: sourceRef ?? this.sourceRef,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      lastSignalAt: lastSignalAt is DateTime?
          ? lastSignalAt
          : this.lastSignalAt,
      status: status ?? this.status,
    );
  }
}

class CameraUpdateTable extends _is.UpdateTable<CameraTable> {
  CameraUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> sourceKind(String value) => _is.ColumnValue(
    table.sourceKind,
    value,
  );

  _is.ColumnValue<String, String> sourceRef(String value) => _is.ColumnValue(
    table.sourceRef,
    value,
  );

  _is.ColumnValue<bool, bool> enabled(bool value) => _is.ColumnValue(
    table.enabled,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastSignalAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSignalAt,
        value,
      );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );
}

class CameraTable extends _is.Table<int?> {
  CameraTable({super.tableRelation}) : super(tableName: 'argus_camera') {
    updateTable = CameraUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    sourceKind = _is.ColumnString(
      'sourceKind',
      this,
    );
    sourceRef = _is.ColumnString(
      'sourceRef',
      this,
    );
    enabled = _is.ColumnBool(
      'enabled',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    lastSignalAt = _is.ColumnDateTime(
      'lastSignalAt',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
  }

  late final CameraUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnString name;

  late final _is.ColumnString sourceKind;

  late final _is.ColumnString sourceRef;

  late final _is.ColumnBool enabled;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime lastSignalAt;

  late final _is.ColumnString status;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    name,
    sourceKind,
    sourceRef,
    enabled,
    createdAt,
    lastSignalAt,
    status,
  ];
}

class CameraInclude extends _is.IncludeObject {
  CameraInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Camera.t;
}

class CameraIncludeList extends _is.IncludeList {
  CameraIncludeList._({
    _is.WhereExpressionBuilder<CameraTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Camera.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Camera.t;
}

class CameraRepository {
  const CameraRepository._();

  /// Returns a list of [Camera]s matching the given query parameters.
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
  Future<List<Camera>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CameraTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CameraTable>? orderBy,
    _is.OrderByListBuilder<CameraTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Camera>(
      where: where?.call(Camera.t),
      orderBy: orderBy?.call(Camera.t),
      orderByList: orderByList?.call(Camera.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Camera] matching the given query parameters.
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
  Future<Camera?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CameraTable>? where,
    int? offset,
    _is.OrderByBuilder<CameraTable>? orderBy,
    _is.OrderByListBuilder<CameraTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Camera>(
      where: where?.call(Camera.t),
      orderBy: orderBy?.call(Camera.t),
      orderByList: orderByList?.call(Camera.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Camera] by its [id] or null if no such row exists.
  Future<Camera?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Camera>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Camera]s in the list and returns the inserted rows.
  ///
  /// The returned [Camera]s will have their `id` fields set.
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
  Future<List<Camera>> insert(
    _is.DatabaseSession session,
    List<Camera> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Camera>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Camera] and returns the inserted row.
  ///
  /// The returned [Camera] will have its `id` field set.
  Future<Camera> insertRow(
    _is.DatabaseSession session,
    Camera row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Camera>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Camera]s in the list and returns the resulting rows.
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
  /// The returned [Camera]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Camera>> upsert(
    _is.DatabaseSession session,
    List<Camera> rows, {
    required _is.ColumnSelections<CameraTable> conflictColumns,
    _is.ColumnSelections<CameraTable>? updateColumns,
    _is.WhereExpressionBuilder<CameraTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Camera>(
      rows,
      conflictColumns: conflictColumns(Camera.t),
      updateColumns: updateColumns?.call(Camera.t),
      updateWhere: updateWhere?.call(Camera.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Camera] and returns the resulting row.
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
  /// The returned [Camera] will have its `id` field set.
  Future<Camera?> upsertRow(
    _is.DatabaseSession session,
    Camera row, {
    required _is.ColumnSelections<CameraTable> conflictColumns,
    _is.ColumnSelections<CameraTable>? updateColumns,
    _is.WhereExpressionBuilder<CameraTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Camera>(
      row,
      conflictColumns: conflictColumns(Camera.t),
      updateColumns: updateColumns?.call(Camera.t),
      updateWhere: updateWhere?.call(Camera.t),
      transaction: transaction,
    );
  }

  /// Updates all [Camera]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Camera>> update(
    _is.DatabaseSession session,
    List<Camera> rows, {
    _is.ColumnSelections<CameraTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Camera>(
      rows,
      columns: columns?.call(Camera.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Camera]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Camera> updateRow(
    _is.DatabaseSession session,
    Camera row, {
    _is.ColumnSelections<CameraTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Camera>(
      row,
      columns: columns?.call(Camera.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Camera] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Camera?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CameraUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Camera>(
      id,
      columnValues: columnValues(Camera.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Camera]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Camera>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CameraUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CameraTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CameraTable>? orderBy,
    _is.OrderByListBuilder<CameraTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Camera>(
      columnValues: columnValues(Camera.t.updateTable),
      where: where(Camera.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Camera.t),
      orderByList: orderByList?.call(Camera.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Camera]s in the list and returns the deleted rows.
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
  Future<List<Camera>> delete(
    _is.DatabaseSession session,
    List<Camera> rows, {
    _is.OrderByBuilder<CameraTable>? orderBy,
    _is.OrderByListBuilder<CameraTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Camera>(
      rows,
      orderBy: orderBy?.call(Camera.t),
      orderByList: orderByList?.call(Camera.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Camera].
  Future<Camera> deleteRow(
    _is.DatabaseSession session,
    Camera row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Camera>(
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
  Future<List<Camera>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CameraTable> where,
    _is.OrderByBuilder<CameraTable>? orderBy,
    _is.OrderByListBuilder<CameraTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Camera>(
      where: where(Camera.t),
      orderBy: orderBy?.call(Camera.t),
      orderByList: orderByList?.call(Camera.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CameraTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Camera>(
      where: where?.call(Camera.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Camera] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CameraTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Camera>(
      where: where(Camera.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
