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

abstract class RoomMember
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RoomMember._({
    this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.joinedAt,
  });

  factory RoomMember({
    int? id,
    required int roomId,
    required int userId,
    required String userName,
    required String userRole,
    required DateTime joinedAt,
  }) = _RoomMemberImpl;

  factory RoomMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomMember(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      userId: jsonSerialization['userId'] as int,
      userName: jsonSerialization['userName'] as String,
      userRole: jsonSerialization['userRole'] as String,
      joinedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['joinedAt'],
      ),
    );
  }

  static final t = RoomMemberTable();

  static const db = RoomMemberRepository._();

  @override
  int? id;

  int roomId;

  int userId;

  String userName;

  String userRole;

  DateTime joinedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RoomMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RoomMember copyWith({
    int? id,
    int? roomId,
    int? userId,
    String? userName,
    String? userRole,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomMember',
      if (id != null) 'id': id,
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomMember',
      if (id != null) 'id': id,
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'joinedAt': joinedAt.toJson(),
    };
  }

  static RoomMemberInclude include() {
    return RoomMemberInclude._();
  }

  static RoomMemberIncludeList includeList({
    _is.WhereExpressionBuilder<RoomMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomMemberTable>? orderBy,
    _is.OrderByListBuilder<RoomMemberTable>? orderByList,
    RoomMemberInclude? include,
  }) {
    return RoomMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomMember.t),
      orderByList: orderByList?.call(RoomMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomMemberImpl extends RoomMember {
  _RoomMemberImpl({
    int? id,
    required int roomId,
    required int userId,
    required String userName,
    required String userRole,
    required DateTime joinedAt,
  }) : super._(
         id: id,
         roomId: roomId,
         userId: userId,
         userName: userName,
         userRole: userRole,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [RoomMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RoomMember copyWith({
    Object? id = _Undefined,
    int? roomId,
    int? userId,
    String? userName,
    String? userRole,
    DateTime? joinedAt,
  }) {
    return RoomMember(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class RoomMemberUpdateTable extends _is.UpdateTable<RoomMemberTable> {
  RoomMemberUpdateTable(super.table);

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<int, int> userId(int value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> userName(String value) => _is.ColumnValue(
    table.userName,
    value,
  );

  _is.ColumnValue<String, String> userRole(String value) => _is.ColumnValue(
    table.userRole,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _is.ColumnValue(
        table.joinedAt,
        value,
      );
}

class RoomMemberTable extends _is.Table<int?> {
  RoomMemberTable({super.tableRelation}) : super(tableName: 'room_member') {
    updateTable = RoomMemberUpdateTable(this);
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    userId = _is.ColumnInt(
      'userId',
      this,
    );
    userName = _is.ColumnString(
      'userName',
      this,
    );
    userRole = _is.ColumnString(
      'userRole',
      this,
    );
    joinedAt = _is.ColumnDateTime(
      'joinedAt',
      this,
    );
  }

  late final RoomMemberUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnInt userId;

  late final _is.ColumnString userName;

  late final _is.ColumnString userRole;

  late final _is.ColumnDateTime joinedAt;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    userId,
    userName,
    userRole,
    joinedAt,
  ];
}

class RoomMemberInclude extends _is.IncludeObject {
  RoomMemberInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RoomMember.t;
}

class RoomMemberIncludeList extends _is.IncludeList {
  RoomMemberIncludeList._({
    _is.WhereExpressionBuilder<RoomMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RoomMember.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RoomMember.t;
}

class RoomMemberRepository {
  const RoomMemberRepository._();

  /// Returns a list of [RoomMember]s matching the given query parameters.
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
  Future<List<RoomMember>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomMemberTable>? orderBy,
    _is.OrderByListBuilder<RoomMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RoomMember>(
      where: where?.call(RoomMember.t),
      orderBy: orderBy?.call(RoomMember.t),
      orderByList: orderByList?.call(RoomMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RoomMember] matching the given query parameters.
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
  Future<RoomMember?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomMemberTable>? where,
    int? offset,
    _is.OrderByBuilder<RoomMemberTable>? orderBy,
    _is.OrderByListBuilder<RoomMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RoomMember>(
      where: where?.call(RoomMember.t),
      orderBy: orderBy?.call(RoomMember.t),
      orderByList: orderByList?.call(RoomMember.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RoomMember] by its [id] or null if no such row exists.
  Future<RoomMember?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RoomMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RoomMember]s in the list and returns the inserted rows.
  ///
  /// The returned [RoomMember]s will have their `id` fields set.
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
  Future<List<RoomMember>> insert(
    _is.DatabaseSession session,
    List<RoomMember> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RoomMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RoomMember] and returns the inserted row.
  ///
  /// The returned [RoomMember] will have its `id` field set.
  Future<RoomMember> insertRow(
    _is.DatabaseSession session,
    RoomMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RoomMember>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RoomMember]s in the list and returns the resulting rows.
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
  /// The returned [RoomMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomMember>> upsert(
    _is.DatabaseSession session,
    List<RoomMember> rows, {
    required _is.ColumnSelections<RoomMemberTable> conflictColumns,
    _is.ColumnSelections<RoomMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomMemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RoomMember>(
      rows,
      conflictColumns: conflictColumns(RoomMember.t),
      updateColumns: updateColumns?.call(RoomMember.t),
      updateWhere: updateWhere?.call(RoomMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RoomMember] and returns the resulting row.
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
  /// The returned [RoomMember] will have its `id` field set.
  Future<RoomMember?> upsertRow(
    _is.DatabaseSession session,
    RoomMember row, {
    required _is.ColumnSelections<RoomMemberTable> conflictColumns,
    _is.ColumnSelections<RoomMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomMemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RoomMember>(
      row,
      conflictColumns: conflictColumns(RoomMember.t),
      updateColumns: updateColumns?.call(RoomMember.t),
      updateWhere: updateWhere?.call(RoomMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [RoomMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomMember>> update(
    _is.DatabaseSession session,
    List<RoomMember> rows, {
    _is.ColumnSelections<RoomMemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RoomMember>(
      rows,
      columns: columns?.call(RoomMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RoomMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RoomMember> updateRow(
    _is.DatabaseSession session,
    RoomMember row, {
    _is.ColumnSelections<RoomMemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RoomMember>(
      row,
      columns: columns?.call(RoomMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoomMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RoomMember?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RoomMemberUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RoomMember>(
      id,
      columnValues: columnValues(RoomMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RoomMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomMember>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RoomMemberUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RoomMemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomMemberTable>? orderBy,
    _is.OrderByListBuilder<RoomMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RoomMember>(
      columnValues: columnValues(RoomMember.t.updateTable),
      where: where(RoomMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomMember.t),
      orderByList: orderByList?.call(RoomMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RoomMember]s in the list and returns the deleted rows.
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
  Future<List<RoomMember>> delete(
    _is.DatabaseSession session,
    List<RoomMember> rows, {
    _is.OrderByBuilder<RoomMemberTable>? orderBy,
    _is.OrderByListBuilder<RoomMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RoomMember>(
      rows,
      orderBy: orderBy?.call(RoomMember.t),
      orderByList: orderByList?.call(RoomMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RoomMember].
  Future<RoomMember> deleteRow(
    _is.DatabaseSession session,
    RoomMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RoomMember>(
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
  Future<List<RoomMember>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomMemberTable> where,
    _is.OrderByBuilder<RoomMemberTable>? orderBy,
    _is.OrderByListBuilder<RoomMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RoomMember>(
      where: where(RoomMember.t),
      orderBy: orderBy?.call(RoomMember.t),
      orderByList: orderByList?.call(RoomMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomMemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RoomMember>(
      where: where?.call(RoomMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RoomMember] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomMemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RoomMember>(
      where: where(RoomMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
