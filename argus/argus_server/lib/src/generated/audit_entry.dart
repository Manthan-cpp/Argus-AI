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

abstract class AuditEntry
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AuditEntry._({
    this.id,
    required this.workspaceId,
    required this.at,
    required this.actor,
    required this.action,
    required this.targetKind,
    required this.targetId,
    required this.detail,
  });

  factory AuditEntry({
    int? id,
    required int workspaceId,
    required DateTime at,
    required String actor,
    required String action,
    required String targetKind,
    required int targetId,
    required String detail,
  }) = _AuditEntryImpl;

  factory AuditEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditEntry(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      at: _is.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
      actor: jsonSerialization['actor'] as String,
      action: jsonSerialization['action'] as String,
      targetKind: jsonSerialization['targetKind'] as String,
      targetId: jsonSerialization['targetId'] as int,
      detail: jsonSerialization['detail'] as String,
    );
  }

  static final t = AuditEntryTable();

  static const db = AuditEntryRepository._();

  @override
  int? id;

  int workspaceId;

  DateTime at;

  String actor;

  String action;

  String targetKind;

  int targetId;

  String detail;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AuditEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AuditEntry copyWith({
    int? id,
    int? workspaceId,
    DateTime? at,
    String? actor,
    String? action,
    String? targetKind,
    int? targetId,
    String? detail,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditEntry',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'at': at.toJson(),
      'actor': actor,
      'action': action,
      'targetKind': targetKind,
      'targetId': targetId,
      'detail': detail,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuditEntry',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'at': at.toJson(),
      'actor': actor,
      'action': action,
      'targetKind': targetKind,
      'targetId': targetId,
      'detail': detail,
    };
  }

  static AuditEntryInclude include() {
    return AuditEntryInclude._();
  }

  static AuditEntryIncludeList includeList({
    _is.WhereExpressionBuilder<AuditEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEntryTable>? orderBy,
    _is.OrderByListBuilder<AuditEntryTable>? orderByList,
    AuditEntryInclude? include,
  }) {
    return AuditEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuditEntry.t),
      orderByList: orderByList?.call(AuditEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditEntryImpl extends AuditEntry {
  _AuditEntryImpl({
    int? id,
    required int workspaceId,
    required DateTime at,
    required String actor,
    required String action,
    required String targetKind,
    required int targetId,
    required String detail,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         at: at,
         actor: actor,
         action: action,
         targetKind: targetKind,
         targetId: targetId,
         detail: detail,
       );

  /// Returns a shallow copy of this [AuditEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AuditEntry copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    DateTime? at,
    String? actor,
    String? action,
    String? targetKind,
    int? targetId,
    String? detail,
  }) {
    return AuditEntry(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      at: at ?? this.at,
      actor: actor ?? this.actor,
      action: action ?? this.action,
      targetKind: targetKind ?? this.targetKind,
      targetId: targetId ?? this.targetId,
      detail: detail ?? this.detail,
    );
  }
}

class AuditEntryUpdateTable extends _is.UpdateTable<AuditEntryTable> {
  AuditEntryUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> at(DateTime value) => _is.ColumnValue(
    table.at,
    value,
  );

  _is.ColumnValue<String, String> actor(String value) => _is.ColumnValue(
    table.actor,
    value,
  );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<String, String> targetKind(String value) => _is.ColumnValue(
    table.targetKind,
    value,
  );

  _is.ColumnValue<int, int> targetId(int value) => _is.ColumnValue(
    table.targetId,
    value,
  );

  _is.ColumnValue<String, String> detail(String value) => _is.ColumnValue(
    table.detail,
    value,
  );
}

class AuditEntryTable extends _is.Table<int?> {
  AuditEntryTable({super.tableRelation})
    : super(tableName: 'argus_audit_entry') {
    updateTable = AuditEntryUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    at = _is.ColumnDateTime(
      'at',
      this,
    );
    actor = _is.ColumnString(
      'actor',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    targetKind = _is.ColumnString(
      'targetKind',
      this,
    );
    targetId = _is.ColumnInt(
      'targetId',
      this,
    );
    detail = _is.ColumnString(
      'detail',
      this,
    );
  }

  late final AuditEntryUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnDateTime at;

  late final _is.ColumnString actor;

  late final _is.ColumnString action;

  late final _is.ColumnString targetKind;

  late final _is.ColumnInt targetId;

  late final _is.ColumnString detail;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    at,
    actor,
    action,
    targetKind,
    targetId,
    detail,
  ];
}

class AuditEntryInclude extends _is.IncludeObject {
  AuditEntryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AuditEntry.t;
}

class AuditEntryIncludeList extends _is.IncludeList {
  AuditEntryIncludeList._({
    _is.WhereExpressionBuilder<AuditEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AuditEntry.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AuditEntry.t;
}

class AuditEntryRepository {
  const AuditEntryRepository._();

  /// Returns a list of [AuditEntry]s matching the given query parameters.
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
  Future<List<AuditEntry>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEntryTable>? orderBy,
    _is.OrderByListBuilder<AuditEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AuditEntry>(
      where: where?.call(AuditEntry.t),
      orderBy: orderBy?.call(AuditEntry.t),
      orderByList: orderByList?.call(AuditEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AuditEntry] matching the given query parameters.
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
  Future<AuditEntry?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEntryTable>? where,
    int? offset,
    _is.OrderByBuilder<AuditEntryTable>? orderBy,
    _is.OrderByListBuilder<AuditEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AuditEntry>(
      where: where?.call(AuditEntry.t),
      orderBy: orderBy?.call(AuditEntry.t),
      orderByList: orderByList?.call(AuditEntry.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AuditEntry] by its [id] or null if no such row exists.
  Future<AuditEntry?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AuditEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AuditEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [AuditEntry]s will have their `id` fields set.
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
  Future<List<AuditEntry>> insert(
    _is.DatabaseSession session,
    List<AuditEntry> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AuditEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AuditEntry] and returns the inserted row.
  ///
  /// The returned [AuditEntry] will have its `id` field set.
  Future<AuditEntry> insertRow(
    _is.DatabaseSession session,
    AuditEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AuditEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AuditEntry]s in the list and returns the resulting rows.
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
  /// The returned [AuditEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEntry>> upsert(
    _is.DatabaseSession session,
    List<AuditEntry> rows, {
    required _is.ColumnSelections<AuditEntryTable> conflictColumns,
    _is.ColumnSelections<AuditEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<AuditEntryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AuditEntry>(
      rows,
      conflictColumns: conflictColumns(AuditEntry.t),
      updateColumns: updateColumns?.call(AuditEntry.t),
      updateWhere: updateWhere?.call(AuditEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AuditEntry] and returns the resulting row.
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
  /// The returned [AuditEntry] will have its `id` field set.
  Future<AuditEntry?> upsertRow(
    _is.DatabaseSession session,
    AuditEntry row, {
    required _is.ColumnSelections<AuditEntryTable> conflictColumns,
    _is.ColumnSelections<AuditEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<AuditEntryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AuditEntry>(
      row,
      conflictColumns: conflictColumns(AuditEntry.t),
      updateColumns: updateColumns?.call(AuditEntry.t),
      updateWhere: updateWhere?.call(AuditEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [AuditEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEntry>> update(
    _is.DatabaseSession session,
    List<AuditEntry> rows, {
    _is.ColumnSelections<AuditEntryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AuditEntry>(
      rows,
      columns: columns?.call(AuditEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AuditEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AuditEntry> updateRow(
    _is.DatabaseSession session,
    AuditEntry row, {
    _is.ColumnSelections<AuditEntryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AuditEntry>(
      row,
      columns: columns?.call(AuditEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AuditEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AuditEntry?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AuditEntryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AuditEntry>(
      id,
      columnValues: columnValues(AuditEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AuditEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEntry>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AuditEntryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AuditEntryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEntryTable>? orderBy,
    _is.OrderByListBuilder<AuditEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AuditEntry>(
      columnValues: columnValues(AuditEntry.t.updateTable),
      where: where(AuditEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuditEntry.t),
      orderByList: orderByList?.call(AuditEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AuditEntry]s in the list and returns the deleted rows.
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
  Future<List<AuditEntry>> delete(
    _is.DatabaseSession session,
    List<AuditEntry> rows, {
    _is.OrderByBuilder<AuditEntryTable>? orderBy,
    _is.OrderByListBuilder<AuditEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AuditEntry>(
      rows,
      orderBy: orderBy?.call(AuditEntry.t),
      orderByList: orderByList?.call(AuditEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AuditEntry].
  Future<AuditEntry> deleteRow(
    _is.DatabaseSession session,
    AuditEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AuditEntry>(
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
  Future<List<AuditEntry>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AuditEntryTable> where,
    _is.OrderByBuilder<AuditEntryTable>? orderBy,
    _is.OrderByListBuilder<AuditEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AuditEntry>(
      where: where(AuditEntry.t),
      orderBy: orderBy?.call(AuditEntry.t),
      orderByList: orderByList?.call(AuditEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEntryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AuditEntry>(
      where: where?.call(AuditEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AuditEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AuditEntryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AuditEntry>(
      where: where(AuditEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
