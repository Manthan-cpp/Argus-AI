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

abstract class DispatchRoom
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DispatchRoom._({
    this.id,
    required this.workspaceId,
    required this.name,
    required this.code,
    this.description,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    required this.cameraIds,
    required this.isActive,
  });

  factory DispatchRoom({
    int? id,
    required int workspaceId,
    required String name,
    required String code,
    String? description,
    required int createdById,
    required String createdByName,
    required DateTime createdAt,
    required List<int> cameraIds,
    required bool isActive,
  }) = _DispatchRoomImpl;

  factory DispatchRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return DispatchRoom(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      name: jsonSerialization['name'] as String,
      code: jsonSerialization['code'] as String,
      description: jsonSerialization['description'] as String?,
      createdById: jsonSerialization['createdById'] as int,
      createdByName: jsonSerialization['createdByName'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      cameraIds: _iggnejrg.Protocol().deserialize<List<int>>(
        jsonSerialization['cameraIds'],
      ),
      isActive: _is.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  static final t = DispatchRoomTable();

  static const db = DispatchRoomRepository._();

  @override
  int? id;

  int workspaceId;

  String name;

  String code;

  String? description;

  int createdById;

  String createdByName;

  DateTime createdAt;

  List<int> cameraIds;

  bool isActive;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DispatchRoom]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DispatchRoom copyWith({
    int? id,
    int? workspaceId,
    String? name,
    String? code,
    String? description,
    int? createdById,
    String? createdByName,
    DateTime? createdAt,
    List<int>? cameraIds,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DispatchRoom',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'code': code,
      if (description != null) 'description': description,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdAt': createdAt.toJson(),
      'cameraIds': cameraIds.toJson(),
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DispatchRoom',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'code': code,
      if (description != null) 'description': description,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdAt': createdAt.toJson(),
      'cameraIds': cameraIds.toJson(),
      'isActive': isActive,
    };
  }

  static DispatchRoomInclude include() {
    return DispatchRoomInclude._();
  }

  static DispatchRoomIncludeList includeList({
    _is.WhereExpressionBuilder<DispatchRoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DispatchRoomTable>? orderBy,
    _is.OrderByListBuilder<DispatchRoomTable>? orderByList,
    DispatchRoomInclude? include,
  }) {
    return DispatchRoomIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DispatchRoom.t),
      orderByList: orderByList?.call(DispatchRoom.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DispatchRoomImpl extends DispatchRoom {
  _DispatchRoomImpl({
    int? id,
    required int workspaceId,
    required String name,
    required String code,
    String? description,
    required int createdById,
    required String createdByName,
    required DateTime createdAt,
    required List<int> cameraIds,
    required bool isActive,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         name: name,
         code: code,
         description: description,
         createdById: createdById,
         createdByName: createdByName,
         createdAt: createdAt,
         cameraIds: cameraIds,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [DispatchRoom]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DispatchRoom copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? name,
    String? code,
    Object? description = _Undefined,
    int? createdById,
    String? createdByName,
    DateTime? createdAt,
    List<int>? cameraIds,
    bool? isActive,
  }) {
    return DispatchRoom(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description is String? ? description : this.description,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      cameraIds: cameraIds ?? this.cameraIds.map((e0) => e0).toList(),
      isActive: isActive ?? this.isActive,
    );
  }
}

class DispatchRoomUpdateTable extends _is.UpdateTable<DispatchRoomTable> {
  DispatchRoomUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> code(String value) => _is.ColumnValue(
    table.code,
    value,
  );

  _is.ColumnValue<String, String> description(String? value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<int, int> createdById(int value) => _is.ColumnValue(
    table.createdById,
    value,
  );

  _is.ColumnValue<String, String> createdByName(String value) =>
      _is.ColumnValue(
        table.createdByName,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<List<int>, List<int>> cameraIds(List<int> value) =>
      _is.ColumnValue(
        table.cameraIds,
        value,
      );

  _is.ColumnValue<bool, bool> isActive(bool value) => _is.ColumnValue(
    table.isActive,
    value,
  );
}

class DispatchRoomTable extends _is.Table<int?> {
  DispatchRoomTable({super.tableRelation}) : super(tableName: 'dispatch_room') {
    updateTable = DispatchRoomUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    code = _is.ColumnString(
      'code',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    createdById = _is.ColumnInt(
      'createdById',
      this,
    );
    createdByName = _is.ColumnString(
      'createdByName',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    cameraIds = _is.ColumnSerializable<List<int>>(
      'cameraIds',
      this,
    );
    isActive = _is.ColumnBool(
      'isActive',
      this,
    );
  }

  late final DispatchRoomUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnString name;

  late final _is.ColumnString code;

  late final _is.ColumnString description;

  late final _is.ColumnInt createdById;

  late final _is.ColumnString createdByName;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnSerializable<List<int>> cameraIds;

  late final _is.ColumnBool isActive;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    name,
    code,
    description,
    createdById,
    createdByName,
    createdAt,
    cameraIds,
    isActive,
  ];
}

class DispatchRoomInclude extends _is.IncludeObject {
  DispatchRoomInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DispatchRoom.t;
}

class DispatchRoomIncludeList extends _is.IncludeList {
  DispatchRoomIncludeList._({
    _is.WhereExpressionBuilder<DispatchRoomTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DispatchRoom.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DispatchRoom.t;
}

class DispatchRoomRepository {
  const DispatchRoomRepository._();

  /// Returns a list of [DispatchRoom]s matching the given query parameters.
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
  Future<List<DispatchRoom>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DispatchRoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DispatchRoomTable>? orderBy,
    _is.OrderByListBuilder<DispatchRoomTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DispatchRoom>(
      where: where?.call(DispatchRoom.t),
      orderBy: orderBy?.call(DispatchRoom.t),
      orderByList: orderByList?.call(DispatchRoom.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DispatchRoom] matching the given query parameters.
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
  Future<DispatchRoom?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DispatchRoomTable>? where,
    int? offset,
    _is.OrderByBuilder<DispatchRoomTable>? orderBy,
    _is.OrderByListBuilder<DispatchRoomTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DispatchRoom>(
      where: where?.call(DispatchRoom.t),
      orderBy: orderBy?.call(DispatchRoom.t),
      orderByList: orderByList?.call(DispatchRoom.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DispatchRoom] by its [id] or null if no such row exists.
  Future<DispatchRoom?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DispatchRoom>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DispatchRoom]s in the list and returns the inserted rows.
  ///
  /// The returned [DispatchRoom]s will have their `id` fields set.
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
  Future<List<DispatchRoom>> insert(
    _is.DatabaseSession session,
    List<DispatchRoom> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DispatchRoom>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DispatchRoom] and returns the inserted row.
  ///
  /// The returned [DispatchRoom] will have its `id` field set.
  Future<DispatchRoom> insertRow(
    _is.DatabaseSession session,
    DispatchRoom row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DispatchRoom>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DispatchRoom]s in the list and returns the resulting rows.
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
  /// The returned [DispatchRoom]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DispatchRoom>> upsert(
    _is.DatabaseSession session,
    List<DispatchRoom> rows, {
    required _is.ColumnSelections<DispatchRoomTable> conflictColumns,
    _is.ColumnSelections<DispatchRoomTable>? updateColumns,
    _is.WhereExpressionBuilder<DispatchRoomTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DispatchRoom>(
      rows,
      conflictColumns: conflictColumns(DispatchRoom.t),
      updateColumns: updateColumns?.call(DispatchRoom.t),
      updateWhere: updateWhere?.call(DispatchRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DispatchRoom] and returns the resulting row.
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
  /// The returned [DispatchRoom] will have its `id` field set.
  Future<DispatchRoom?> upsertRow(
    _is.DatabaseSession session,
    DispatchRoom row, {
    required _is.ColumnSelections<DispatchRoomTable> conflictColumns,
    _is.ColumnSelections<DispatchRoomTable>? updateColumns,
    _is.WhereExpressionBuilder<DispatchRoomTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DispatchRoom>(
      row,
      conflictColumns: conflictColumns(DispatchRoom.t),
      updateColumns: updateColumns?.call(DispatchRoom.t),
      updateWhere: updateWhere?.call(DispatchRoom.t),
      transaction: transaction,
    );
  }

  /// Updates all [DispatchRoom]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DispatchRoom>> update(
    _is.DatabaseSession session,
    List<DispatchRoom> rows, {
    _is.ColumnSelections<DispatchRoomTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DispatchRoom>(
      rows,
      columns: columns?.call(DispatchRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DispatchRoom]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DispatchRoom> updateRow(
    _is.DatabaseSession session,
    DispatchRoom row, {
    _is.ColumnSelections<DispatchRoomTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DispatchRoom>(
      row,
      columns: columns?.call(DispatchRoom.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DispatchRoom] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DispatchRoom?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DispatchRoomUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DispatchRoom>(
      id,
      columnValues: columnValues(DispatchRoom.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DispatchRoom]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DispatchRoom>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DispatchRoomUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DispatchRoomTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DispatchRoomTable>? orderBy,
    _is.OrderByListBuilder<DispatchRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DispatchRoom>(
      columnValues: columnValues(DispatchRoom.t.updateTable),
      where: where(DispatchRoom.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DispatchRoom.t),
      orderByList: orderByList?.call(DispatchRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DispatchRoom]s in the list and returns the deleted rows.
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
  Future<List<DispatchRoom>> delete(
    _is.DatabaseSession session,
    List<DispatchRoom> rows, {
    _is.OrderByBuilder<DispatchRoomTable>? orderBy,
    _is.OrderByListBuilder<DispatchRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DispatchRoom>(
      rows,
      orderBy: orderBy?.call(DispatchRoom.t),
      orderByList: orderByList?.call(DispatchRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DispatchRoom].
  Future<DispatchRoom> deleteRow(
    _is.DatabaseSession session,
    DispatchRoom row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DispatchRoom>(
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
  Future<List<DispatchRoom>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DispatchRoomTable> where,
    _is.OrderByBuilder<DispatchRoomTable>? orderBy,
    _is.OrderByListBuilder<DispatchRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DispatchRoom>(
      where: where(DispatchRoom.t),
      orderBy: orderBy?.call(DispatchRoom.t),
      orderByList: orderByList?.call(DispatchRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DispatchRoomTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DispatchRoom>(
      where: where?.call(DispatchRoom.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DispatchRoom] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DispatchRoomTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DispatchRoom>(
      where: where(DispatchRoom.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
