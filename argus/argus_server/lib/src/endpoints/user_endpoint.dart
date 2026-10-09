import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class UserEndpoint extends Endpoint {
  Future<UserProfile> login(
    Session session,
    String fullName,
    String role, {
    String? email,
  }) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final userEmail = (email != null && email.isNotEmpty)
        ? email
        : '${fullName.toLowerCase().replaceAll(' ', '.')}@argus.ai';

    var user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.email.equals(userEmail) & t.workspaceId.equals(ws.id!),
    );

    if (user != null) {
      final updated = user.copyWith(fullName: fullName, role: role);
      return await UserProfile.db.updateRow(session, updated);
    }

    final newUser = UserProfile(
      workspaceId: ws.id!,
      fullName: fullName,
      email: userEmail,
      role: role,
      createdAt: DateTime.now(),
    );
    return await UserProfile.db.insertRow(session, newUser);
  }

  Future<UserProfile> getCurrentUser(Session session) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    var user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(ws.id!),
      orderBy: (t) => t.id,
    );

    if (user != null) return user;

    final defaultAdmin = UserProfile(
      workspaceId: ws.id!,
      fullName: 'Head Organizer',
      email: 'organizer@argus.ai',
      role: 'organizer',
      createdAt: DateTime.now(),
    );
    return await UserProfile.db.insertRow(session, defaultAdmin);
  }
}
