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

    final isEmail = cleanName.contains('@');
    final existingUsers = await UserProfile.db.find(
      session,
      where: (t) =>
          t.fullName.ilike(cleanName) |
          t.email.ilike(cleanName),
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
      final updated = user.copyWith(
        passwordHash: hash,
        email: isEmail ? cleanName : user.email,
      );
      return await UserProfile.db.updateRow(session, updated);
    }

    // Check if user already exists as an owner or member in an active workspace
    final existingWs = await Workspace.db.findFirstRow(
      session,
      where: (t) => t.ownerUserId.ilike(cleanName) & t.isActive.equals(true),
    );
    final existingMember = await WorkspaceMember.db.findFirstRow(
      session,
      where: (t) => t.userName.ilike(cleanName),
    );

    final targetWsId = existingWs?.id ?? existingMember?.workspaceId ?? ws.id!;
    final assignedRole = existingWs != null
        ? 'organizer'
        : (existingMember?.userRole ?? 'member');

    final newUser = UserProfile(
      workspaceId: targetWsId,
      fullName: cleanName,
      email: isEmail ? cleanName : null,
      passwordHash: hash,
      role: assignedRole,
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

    final isEmail = cleanName.contains('@');
    final users = await UserProfile.db.find(
      session,
      where: (t) =>
          t.fullName.ilike(cleanName) |
          t.email.ilike(cleanName),
    );

    if (users.isEmpty) {
      // Check if user exists in WorkspaceMember or Workspace.
      // This protects accounts if user_profile was cleared, orphaned, or created via invite.
      final members = await WorkspaceMember.db.find(
        session,
        where: (t) => t.userName.ilike(cleanName),
      );
      final workspaces = await Workspace.db.find(
        session,
        where: (t) => t.ownerUserId.ilike(cleanName) & t.isActive.equals(true),
      );

      if (members.isNotEmpty || workspaces.isNotEmpty) {
        final targetWsId = workspaces.isNotEmpty
            ? workspaces.first.id!
            : members.first.workspaceId;
        final canonicalName = workspaces.isNotEmpty
            ? workspaces.first.ownerUserId
            : members.first.userName;
        final assignedRole = workspaces.isNotEmpty
            ? 'organizer'
            : members.first.userRole;

        final hash = _hashPassword(password);
        final reconstituted = UserProfile(
          workspaceId: targetWsId,
          fullName: canonicalName,
          email: isEmail ? cleanName : null,
          passwordHash: hash,
          role: assignedRole,
          createdAt: DateTime.now(),
        );
        return await UserProfile.db.insertRow(session, reconstituted);
      }

      throw StateError(
        'Account "$cleanName" was not found. Please check your spelling or create a new account.',
      );
    }

    final targetUser = users.firstWhere(
      (u) => u.passwordHash != null && u.passwordHash!.isNotEmpty,
      orElse: () => users.first,
    );

    final hash = _hashPassword(password);
    if (targetUser.passwordHash != null && targetUser.passwordHash!.isNotEmpty) {
      if (targetUser.passwordHash != hash) {
        throw StateError(
          'Incorrect password for "$cleanName". Please check your password and try again.',
        );
      }
    } else {
      // If profile was created without a password hash (e.g. joined via code or workspace invitation),
      // attach the password hash now so future logins succeed seamlessly.
      final updated = targetUser.copyWith(
        passwordHash: hash,
        email: isEmail ? cleanName : targetUser.email,
      );
      return await UserProfile.db.updateRow(session, updated);
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
        where: (t) =>
            t.fullName.ilike(cleanName) |
            t.email.ilike(cleanName),
      );
      if (users.isNotEmpty) {
        return users.firstWhere(
          (u) => u.passwordHash != null && u.passwordHash!.isNotEmpty,
          orElse: () => users.first,
        );
      }

      // Check if user exists in Workspace / WorkspaceMember
      final existingWs = await Workspace.db.findFirstRow(
        session,
        where: (t) => t.ownerUserId.ilike(cleanName) & t.isActive.equals(true),
      );
      final existingMember = await WorkspaceMember.db.findFirstRow(
        session,
        where: (t) => t.userName.ilike(cleanName),
      );
      if (existingWs != null || existingMember != null) {
        final targetWsId = existingWs?.id ?? existingMember!.workspaceId;
        final assignedRole = existingWs != null
            ? 'organizer'
            : existingMember!.userRole;
        final profile = UserProfile(
          workspaceId: targetWsId,
          fullName: existingWs?.ownerUserId ?? existingMember!.userName,
          role: assignedRole,
          createdAt: DateTime.now(),
        );
        return await UserProfile.db.insertRow(session, profile);
      }
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
