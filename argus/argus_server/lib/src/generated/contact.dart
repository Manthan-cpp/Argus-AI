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

abstract class Contact
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Contact._({
    this.id,
    required this.workspaceId,
    required this.name,
    required this.role,
    required this.notifyInApp,
    this.telegramChatId,
    this.telegramLinkCode,
    this.isLinked,
    this.createdAt,
  });

  factory Contact({
    int? id,
    required int workspaceId,
    required String name,
    required String role,
    required bool notifyInApp,
    String? telegramChatId,
    String? telegramLinkCode,
    bool? isLinked,
    DateTime? createdAt,
  }) = _ContactImpl;

  factory Contact.fromJson(Map<String, dynamic> jsonSerialization) {
    return Contact(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      name: jsonSerialization['name'] as String,
      role: jsonSerialization['role'] as String,
      notifyInApp: _is.BoolJsonExtension.fromJson(
        jsonSerialization['notifyInApp'],
      ),
      telegramChatId: jsonSerialization['telegramChatId'] as String?,
      telegramLinkCode: jsonSerialization['telegramLinkCode'] as String?,
      isLinked: jsonSerialization['isLinked'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isLinked']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ContactTable();

  static const db = ContactRepository._();

  @override
  int? id;

  int workspaceId;

  String name;

  String role;

  bool notifyInApp;

  String? telegramChatId;

  String? telegramLinkCode;

  bool? isLinked;

  DateTime? createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Contact copyWith({
    int? id,
    int? workspaceId,
    String? name,
    String? role,
    bool? notifyInApp,
    String? telegramChatId,
    String? telegramLinkCode,
    bool? isLinked,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'role': role,
      'notifyInApp': notifyInApp,
      if (telegramChatId != null) 'telegramChatId': telegramChatId,
      if (telegramLinkCode != null) 'telegramLinkCode': telegramLinkCode,
      if (isLinked != null) 'isLinked': isLinked,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'role': role,
      'notifyInApp': notifyInApp,
      if (telegramChatId != null) 'telegramChatId': telegramChatId,
      if (telegramLinkCode != null) 'telegramLinkCode': telegramLinkCode,
      if (isLinked != null) 'isLinked': isLinked,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static ContactInclude include() {
    return ContactInclude._();
  }

  static ContactIncludeList includeList({
    _is.WhereExpressionBuilder<ContactTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ContactTable>? orderBy,
    _is.OrderByListBuilder<ContactTable>? orderByList,
    ContactInclude? include,
  }) {
    return ContactIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContactImpl extends Contact {
  _ContactImpl({
    int? id,
    required int workspaceId,
    required String name,
    required String role,
    required bool notifyInApp,
    String? telegramChatId,
    String? telegramLinkCode,
    bool? isLinked,
    DateTime? createdAt,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         name: name,
         role: role,
         notifyInApp: notifyInApp,
         telegramChatId: telegramChatId,
         telegramLinkCode: telegramLinkCode,
         isLinked: isLinked,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Contact copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? name,
    String? role,
    bool? notifyInApp,
    Object? telegramChatId = _Undefined,
    Object? telegramLinkCode = _Undefined,
    Object? isLinked = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return Contact(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      role: role ?? this.role,
      notifyInApp: notifyInApp ?? this.notifyInApp,
      telegramChatId: telegramChatId is String?
          ? telegramChatId
          : this.telegramChatId,
      telegramLinkCode: telegramLinkCode is String?
          ? telegramLinkCode
          : this.telegramLinkCode,
      isLinked: isLinked is bool? ? isLinked : this.isLinked,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class ContactUpdateTable extends _is.UpdateTable<ContactTable> {
  ContactUpdateTable(super.table);

  _is.ColumnValue<int, int> workspaceId(int value) => _is.ColumnValue(
    table.workspaceId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> role(String value) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<bool, bool> notifyInApp(bool value) => _is.ColumnValue(
    table.notifyInApp,
    value,
  );

  _is.ColumnValue<String, String> telegramChatId(String? value) =>
      _is.ColumnValue(
        table.telegramChatId,
        value,
      );

  _is.ColumnValue<String, String> telegramLinkCode(String? value) =>
      _is.ColumnValue(
        table.telegramLinkCode,
        value,
      );

  _is.ColumnValue<bool, bool> isLinked(bool? value) => _is.ColumnValue(
    table.isLinked,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ContactTable extends _is.Table<int?> {
  ContactTable({super.tableRelation}) : super(tableName: 'argus_contact') {
    updateTable = ContactUpdateTable(this);
    workspaceId = _is.ColumnInt(
      'workspaceId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    role = _is.ColumnString(
      'role',
      this,
    );
    notifyInApp = _is.ColumnBool(
      'notifyInApp',
      this,
    );
    telegramChatId = _is.ColumnString(
      'telegramChatId',
      this,
    );
    telegramLinkCode = _is.ColumnString(
      'telegramLinkCode',
      this,
    );
    isLinked = _is.ColumnBool(
      'isLinked',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ContactUpdateTable updateTable;

  late final _is.ColumnInt workspaceId;

  late final _is.ColumnString name;

  late final _is.ColumnString role;

  late final _is.ColumnBool notifyInApp;

  late final _is.ColumnString telegramChatId;

  late final _is.ColumnString telegramLinkCode;

  late final _is.ColumnBool isLinked;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    workspaceId,
    name,
    role,
    notifyInApp,
    telegramChatId,
    telegramLinkCode,
    isLinked,
    createdAt,
  ];
}

class ContactInclude extends _is.IncludeObject {
  ContactInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Contact.t;
}

class ContactIncludeList extends _is.IncludeList {
  ContactIncludeList._({
    _is.WhereExpressionBuilder<ContactTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Contact.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Contact.t;
}

class ContactRepository {
  const ContactRepository._();

  /// Returns a list of [Contact]s matching the given query parameters.
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
  Future<List<Contact>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ContactTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ContactTable>? orderBy,
    _is.OrderByListBuilder<ContactTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Contact>(
      where: where?.call(Contact.t),
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Contact] matching the given query parameters.
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
  Future<Contact?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ContactTable>? where,
    int? offset,
    _is.OrderByBuilder<ContactTable>? orderBy,
    _is.OrderByListBuilder<ContactTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Contact>(
      where: where?.call(Contact.t),
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Contact] by its [id] or null if no such row exists.
  Future<Contact?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Contact>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Contact]s in the list and returns the inserted rows.
  ///
  /// The returned [Contact]s will have their `id` fields set.
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
  Future<List<Contact>> insert(
    _is.DatabaseSession session,
    List<Contact> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Contact>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Contact] and returns the inserted row.
  ///
  /// The returned [Contact] will have its `id` field set.
  Future<Contact> insertRow(
    _is.DatabaseSession session,
    Contact row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Contact>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Contact]s in the list and returns the resulting rows.
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
  /// The returned [Contact]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Contact>> upsert(
    _is.DatabaseSession session,
    List<Contact> rows, {
    required _is.ColumnSelections<ContactTable> conflictColumns,
    _is.ColumnSelections<ContactTable>? updateColumns,
    _is.WhereExpressionBuilder<ContactTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Contact>(
      rows,
      conflictColumns: conflictColumns(Contact.t),
      updateColumns: updateColumns?.call(Contact.t),
      updateWhere: updateWhere?.call(Contact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Contact] and returns the resulting row.
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
  /// The returned [Contact] will have its `id` field set.
  Future<Contact?> upsertRow(
    _is.DatabaseSession session,
    Contact row, {
    required _is.ColumnSelections<ContactTable> conflictColumns,
    _is.ColumnSelections<ContactTable>? updateColumns,
    _is.WhereExpressionBuilder<ContactTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Contact>(
      row,
      conflictColumns: conflictColumns(Contact.t),
      updateColumns: updateColumns?.call(Contact.t),
      updateWhere: updateWhere?.call(Contact.t),
      transaction: transaction,
    );
  }

  /// Updates all [Contact]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Contact>> update(
    _is.DatabaseSession session,
    List<Contact> rows, {
    _is.ColumnSelections<ContactTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Contact>(
      rows,
      columns: columns?.call(Contact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Contact]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Contact> updateRow(
    _is.DatabaseSession session,
    Contact row, {
    _is.ColumnSelections<ContactTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Contact>(
      row,
      columns: columns?.call(Contact.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Contact] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Contact?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ContactUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Contact>(
      id,
      columnValues: columnValues(Contact.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Contact]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Contact>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ContactUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ContactTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ContactTable>? orderBy,
    _is.OrderByListBuilder<ContactTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Contact>(
      columnValues: columnValues(Contact.t.updateTable),
      where: where(Contact.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Contact]s in the list and returns the deleted rows.
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
  Future<List<Contact>> delete(
    _is.DatabaseSession session,
    List<Contact> rows, {
    _is.OrderByBuilder<ContactTable>? orderBy,
    _is.OrderByListBuilder<ContactTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Contact>(
      rows,
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Contact].
  Future<Contact> deleteRow(
    _is.DatabaseSession session,
    Contact row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Contact>(
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
  Future<List<Contact>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ContactTable> where,
    _is.OrderByBuilder<ContactTable>? orderBy,
    _is.OrderByListBuilder<ContactTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Contact>(
      where: where(Contact.t),
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ContactTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Contact>(
      where: where?.call(Contact.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Contact] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ContactTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Contact>(
      where: where(Contact.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
