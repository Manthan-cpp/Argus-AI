import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class UserEndpoint extends Endpoint {
  String _hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    return sha256.convert(bytes).toString();
  }

  Future<UserProfile> signUp(
    Session session,
    String fullName,
    String password,
  ) async {
    final cleanName = fullName.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Full name cannot be empty.');
    }
    if (password.trim().isEmpty) {
      throw ArgumentError('Password cannot be empty.');
    }

    final existingUsers = await UserProfile.db.find(
      session,
      where: (t) => t.fullName.ilike(cleanName),
    );

    final hasPassword = existingUsers.any(
      (u) => u.passwordHash != null && u.passwordHash!.isNotEmpty,
    );
    if (hasPassword) {
      throw StateError(
        'An account named "$cleanName" already exists. Please switch to "Sign In" to access your account.',
      );
    }

    final hash = _hashPassword(password);
    final ws = await WorkspaceEndpoint().ensure(session);

    if (existingUsers.isNotEmpty) {
      final user = existingUsers.first;
      final updated = user.copyWith(passwordHash: hash);
      return await UserProfile.db.updateRow(session, updated);
    }

    final newUser = UserProfile(
      workspaceId: ws.id!,
      fullName: cleanName,
      passwordHash: hash,
      role: 'member',
      createdAt: DateTime.now(),
    );
    return await UserProfile.db.insertRow(session, newUser);
  }

  Future<UserProfile> login(
    Session session,
    String fullName,
    String password,
  ) async {
    final cleanName = fullName.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Full name cannot be empty.');
    }
    if (password.trim().isEmpty) {
      throw ArgumentError('Password cannot be empty.');
    }

    final users = await UserProfile.db.find(
      session,
      where: (t) => t.fullName.ilike(cleanName),
    );

    if (users.isEmpty) {
      throw StateError('Account "$cleanName" was not found. Please check your spelling or create a new account.');
    }

    final targetUser = users.firstWhere(
      (u) => u.passwordHash != null && u.passwordHash!.isNotEmpty,
      orElse: () => users.first,
    );

    final hash = _hashPassword(password);
    if (targetUser.passwordHash != null && targetUser.passwordHash!.isNotEmpty) {
      if (targetUser.passwordHash != hash) {
        throw StateError('Incorrect password for "$cleanName". Please check your password and try again.');
      }
    } else {
      targetUser.passwordHash = hash;
      await UserProfile.db.updateRow(session, targetUser);
    }

    return targetUser;
  }

  Future<UserProfile?> getCurrentUser(
    Session session, {
    String? fullName,
  }) async {
    if (fullName != null && fullName.trim().isNotEmpty) {
      final cleanName = fullName.trim();
      final users = await UserProfile.db.find(
        session,
        where: (t) => t.fullName.ilike(cleanName),
      );
      if (users.isEmpty) return null;
      return users.firstWhere(
        (u) => u.passwordHash != null && u.passwordHash!.isNotEmpty,
        orElse: () => users.first,
      );
    }
    return null;
  }

  Future<bool> resetData(Session session) async {
    // Purges all mock/test records cleanly
    await session.db.unsafeExecute(
      'TRUNCATE TABLE room_message, room_member, dispatch_room, user_profile RESTART IDENTITY CASCADE;',
    );
    return true;
  }
}
