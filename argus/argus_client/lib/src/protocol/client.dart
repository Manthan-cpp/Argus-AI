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
import 'dart:async' as _ida;
import 'package:argus_client/src/protocol/audit_entry.dart' as _ikvg5xfi;
import 'package:argus_client/src/protocol/camera.dart' as _i20qtz6o;
import 'package:argus_client/src/protocol/contact.dart' as _is7rcw5z;
import 'package:argus_client/src/protocol/demo_seed_result.dart' as _imfiludm;
import 'package:argus_client/src/protocol/dispatch_room.dart' as _ic2gvio8;
import 'package:argus_client/src/protocol/dry_run_result.dart' as _i6u54chj;
import 'package:argus_client/src/protocol/evidence_upload.dart' as _i09kivnj;
import 'package:argus_client/src/protocol/greetings/greeting.dart' as _ij1oemww;
import 'package:argus_client/src/protocol/health_info.dart' as _iguyn466;
import 'package:argus_client/src/protocol/incident.dart' as _i1aq5e6k;
import 'package:argus_client/src/protocol/incident_detail.dart' as _iibtzi3y;
import 'package:argus_client/src/protocol/incident_update.dart' as _iy5lsfoy;
import 'package:argus_client/src/protocol/parse_result.dart' as _itpxon2j;
import 'package:argus_client/src/protocol/room_member.dart' as _is3b1078;
import 'package:argus_client/src/protocol/room_message.dart' as _iy4hi5ej;
import 'package:argus_client/src/protocol/rule_spec.dart' as _iu4sgp9a;
import 'package:argus_client/src/protocol/signal_ack.dart' as _idevjgfk;
import 'package:argus_client/src/protocol/signal_batch.dart' as _if0pbfo6;
import 'package:argus_client/src/protocol/user_profile.dart' as _i7qokifa;
import 'package:argus_client/src/protocol/workspace.dart' as _ijok4rmj;
import 'package:argus_client/src/protocol/zone.dart' as _igytwnus;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointAudit extends _isc.EndpointRef {
  EndpointAudit(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'audit';

  _ida.Future<List<_ikvg5xfi.AuditEntry>> list({required int limit}) =>
      caller.callServerEndpoint<List<_ikvg5xfi.AuditEntry>>(
        'audit',
        'list',
        {'limit': limit},
      );
}

/// {@category Endpoint}
class EndpointCamera extends _isc.EndpointRef {
  EndpointCamera(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'camera';

  _ida.Future<List<_i20qtz6o.Camera>> list({int? workspaceId}) =>
      caller.callServerEndpoint<List<_i20qtz6o.Camera>>(
        'camera',
        'list',
        {'workspaceId': workspaceId},
      );

  _ida.Future<_i20qtz6o.Camera> save(
    _i20qtz6o.Camera camera, {
    int? workspaceId,
  }) => caller.callServerEndpoint<_i20qtz6o.Camera>(
    'camera',
    'save',
    {
      'camera': camera,
      'workspaceId': workspaceId,
    },
  );

  _ida.Future<void> delete(int id) => caller.callServerEndpoint<void>(
    'camera',
    'delete',
    {'id': id},
  );
}

/// {@category Endpoint}
class EndpointContact extends _isc.EndpointRef {
  EndpointContact(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'contact';

  _ida.Future<List<_is7rcw5z.Contact>> list() =>
      caller.callServerEndpoint<List<_is7rcw5z.Contact>>(
        'contact',
        'list',
        {},
      );

  _ida.Future<_is7rcw5z.Contact> save(_is7rcw5z.Contact contact) =>
      caller.callServerEndpoint<_is7rcw5z.Contact>(
        'contact',
        'save',
        {'contact': contact},
      );

  _ida.Future<void> delete(int id) => caller.callServerEndpoint<void>(
    'contact',
    'delete',
    {'id': id},
  );
}

/// {@category Endpoint}
class EndpointDemo extends _isc.EndpointRef {
  EndpointDemo(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'demo';

  _ida.Future<_imfiludm.DemoSeedResult> seed() =>
      caller.callServerEndpoint<_imfiludm.DemoSeedResult>(
        'demo',
        'seed',
        {},
      );
}

/// {@category Endpoint}
class EndpointEvidence extends _isc.EndpointRef {
  EndpointEvidence(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'evidence';

  _ida.Future<void> upload(_i09kivnj.EvidenceUpload upload) =>
      caller.callServerEndpoint<void>(
        'evidence',
        'upload',
        {'upload': upload},
      );
}

/// {@category Endpoint}
class EndpointHealth extends _isc.EndpointRef {
  EndpointHealth(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'health';

  _ida.Future<_iguyn466.HealthInfo> ping() =>
      caller.callServerEndpoint<_iguyn466.HealthInfo>(
        'health',
        'ping',
        {},
      );
}

/// {@category Endpoint}
class EndpointIncident extends _isc.EndpointRef {
  EndpointIncident(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'incident';

  _ida.Stream<_iy5lsfoy.IncidentUpdate> watch({int? sinceIncidentId}) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_iy5lsfoy.IncidentUpdate>,
        _iy5lsfoy.IncidentUpdate
      >(
        'incident',
        'watch',
        {'sinceIncidentId': sinceIncidentId},
        {},
      );

  _ida.Future<List<_i1aq5e6k.Incident>> list({
    int? workspaceId,
    String? status,
    String? severity,
    int? cameraId,
  }) => caller.callServerEndpoint<List<_i1aq5e6k.Incident>>(
    'incident',
    'list',
    {
      'workspaceId': workspaceId,
      'status': status,
      'severity': severity,
      'cameraId': cameraId,
    },
  );

  _ida.Future<_iibtzi3y.IncidentDetail> get(int id) =>
      caller.callServerEndpoint<_iibtzi3y.IncidentDetail>(
        'incident',
        'get',
        {'id': id},
      );

  _ida.Future<_i1aq5e6k.Incident> acknowledge(
    int id, {
    String? note,
  }) => caller.callServerEndpoint<_i1aq5e6k.Incident>(
    'incident',
    'acknowledge',
    {
      'id': id,
      'note': note,
    },
  );

  _ida.Future<_i1aq5e6k.Incident> resolve(
    int id, {
    String? note,
  }) => caller.callServerEndpoint<_i1aq5e6k.Incident>(
    'incident',
    'resolve',
    {
      'id': id,
      'note': note,
    },
  );

  _ida.Future<_i1aq5e6k.Incident> markFalsePositive(
    int id, {
    String? note,
  }) => caller.callServerEndpoint<_i1aq5e6k.Incident>(
    'incident',
    'markFalsePositive',
    {
      'id': id,
      'note': note,
    },
  );

  _ida.Future<bool> delete(int id) => caller.callServerEndpoint<bool>(
    'incident',
    'delete',
    {'id': id},
  );

  _ida.Future<bool> deleteAll({int? workspaceId}) =>
      caller.callServerEndpoint<bool>(
        'incident',
        'deleteAll',
        {'workspaceId': workspaceId},
      );
}

/// {@category Endpoint}
class EndpointRoom extends _isc.EndpointRef {
  EndpointRoom(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'room';

  _ida.Future<_ic2gvio8.DispatchRoom> createRoom(
    String name, {
    String? description,
    List<int>? cameraIds,
    int? workspaceId,
    required String creatorName,
    required String creatorRole,
  }) => caller.callServerEndpoint<_ic2gvio8.DispatchRoom>(
    'room',
    'createRoom',
    {
      'name': name,
      'description': description,
      'cameraIds': cameraIds,
      'workspaceId': workspaceId,
      'creatorName': creatorName,
      'creatorRole': creatorRole,
    },
  );

  _ida.Future<_ic2gvio8.DispatchRoom?> joinRoom(
    String code, {
    required String userName,
  }) => caller.callServerEndpoint<_ic2gvio8.DispatchRoom?>(
    'room',
    'joinRoom',
    {
      'code': code,
      'userName': userName,
    },
  );

  _ida.Future<bool> deleteRoom(
    int roomId, {
    required String userName,
  }) => caller.callServerEndpoint<bool>(
    'room',
    'deleteRoom',
    {
      'roomId': roomId,
      'userName': userName,
    },
  );

  _ida.Future<_ic2gvio8.DispatchRoom> updateRoom(
    int roomId, {
    required String userName,
    String? name,
    String? description,
    List<int>? cameraIds,
  }) => caller.callServerEndpoint<_ic2gvio8.DispatchRoom>(
    'room',
    'updateRoom',
    {
      'roomId': roomId,
      'userName': userName,
      'name': name,
      'description': description,
      'cameraIds': cameraIds,
    },
  );

  _ida.Future<List<_ic2gvio8.DispatchRoom>> listRooms({
    int? workspaceId,
    String? userName,
  }) => caller.callServerEndpoint<List<_ic2gvio8.DispatchRoom>>(
    'room',
    'listRooms',
    {
      'workspaceId': workspaceId,
      'userName': userName,
    },
  );

  _ida.Future<_ic2gvio8.DispatchRoom?> getRoom(
    int roomId, {
    String? userName,
  }) => caller.callServerEndpoint<_ic2gvio8.DispatchRoom?>(
    'room',
    'getRoom',
    {
      'roomId': roomId,
      'userName': userName,
    },
  );

  _ida.Future<_ic2gvio8.DispatchRoom?> getRoomByCode(String code) =>
      caller.callServerEndpoint<_ic2gvio8.DispatchRoom?>(
        'room',
        'getRoomByCode',
        {'code': code},
      );

  _ida.Future<_ic2gvio8.DispatchRoom?> getRoomForWorkspace(
    int workspaceId, {
    String? userName,
  }) => caller.callServerEndpoint<_ic2gvio8.DispatchRoom?>(
    'room',
    'getRoomForWorkspace',
    {
      'workspaceId': workspaceId,
      'userName': userName,
    },
  );

  _ida.Future<List<_is3b1078.RoomMember>> listMembers(int roomId) =>
      caller.callServerEndpoint<List<_is3b1078.RoomMember>>(
        'room',
        'listMembers',
        {'roomId': roomId},
      );
}

/// {@category Endpoint}
class EndpointRoomMessage extends _isc.EndpointRef {
  EndpointRoomMessage(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'roomMessage';

  _ida.Stream<_iy4hi5ej.RoomMessage> watch(int roomId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_iy4hi5ej.RoomMessage>,
        _iy4hi5ej.RoomMessage
      >(
        'roomMessage',
        'watch',
        {'roomId': roomId},
        {},
      );

  _ida.Future<_iy4hi5ej.RoomMessage> sendMessage(
    int roomId,
    String content, {
    String? senderName,
    String? senderRole,
    int? senderId,
  }) => caller.callServerEndpoint<_iy4hi5ej.RoomMessage>(
    'roomMessage',
    'sendMessage',
    {
      'roomId': roomId,
      'content': content,
      'senderName': senderName,
      'senderRole': senderRole,
      'senderId': senderId,
    },
  );

  _ida.Future<List<_iy4hi5ej.RoomMessage>> listMessages(
    int roomId, {
    int? limit,
  }) => caller.callServerEndpoint<List<_iy4hi5ej.RoomMessage>>(
    'roomMessage',
    'listMessages',
    {
      'roomId': roomId,
      'limit': limit,
    },
  );

  _ida.Future<_iy4hi5ej.RoomMessage> postAlert(
    int roomId, {
    required String content,
    required String cameraName,
    required String severity,
    int? incidentId,
  }) => caller.callServerEndpoint<_iy4hi5ej.RoomMessage>(
    'roomMessage',
    'postAlert',
    {
      'roomId': roomId,
      'content': content,
      'cameraName': cameraName,
      'severity': severity,
      'incidentId': incidentId,
    },
  );
}

/// {@category Endpoint}
class EndpointRule extends _isc.EndpointRef {
  EndpointRule(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'rule';

  _ida.Future<List<_iu4sgp9a.RuleSpec>> list() =>
      caller.callServerEndpoint<List<_iu4sgp9a.RuleSpec>>(
        'rule',
        'list',
        {},
      );

  _ida.Future<_iu4sgp9a.RuleSpec> save(_iu4sgp9a.RuleSpec rule) =>
      caller.callServerEndpoint<_iu4sgp9a.RuleSpec>(
        'rule',
        'save',
        {'rule': rule},
      );

  _ida.Future<void> delete(int id) => caller.callServerEndpoint<void>(
    'rule',
    'delete',
    {'id': id},
  );

  _ida.Future<_itpxon2j.ParseResult> interpret(
    String sentence, {
    int? cameraId,
  }) => caller.callServerEndpoint<_itpxon2j.ParseResult>(
    'rule',
    'interpret',
    {
      'sentence': sentence,
      'cameraId': cameraId,
    },
  );

  _ida.Future<_i6u54chj.DryRunResult> dryRun(
    _iu4sgp9a.RuleSpec rule,
    String replayClipId,
  ) => caller.callServerEndpoint<_i6u54chj.DryRunResult>(
    'rule',
    'dryRun',
    {
      'rule': rule,
      'replayClipId': replayClipId,
    },
  );
}

/// {@category Endpoint}
class EndpointSignal extends _isc.EndpointRef {
  EndpointSignal(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'signal';

  _ida.Future<_idevjgfk.SignalAck> send(_if0pbfo6.SignalBatch batch) =>
      caller.callServerEndpoint<_idevjgfk.SignalAck>(
        'signal',
        'send',
        {'batch': batch},
      );
}

/// {@category Endpoint}
class EndpointUser extends _isc.EndpointRef {
  EndpointUser(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  _ida.Future<_i7qokifa.UserProfile> signUp(
    String fullName,
    String password,
  ) => caller.callServerEndpoint<_i7qokifa.UserProfile>(
    'user',
    'signUp',
    {
      'fullName': fullName,
      'password': password,
    },
  );

  _ida.Future<_i7qokifa.UserProfile> login(
    String fullName,
    String password,
  ) => caller.callServerEndpoint<_i7qokifa.UserProfile>(
    'user',
    'login',
    {
      'fullName': fullName,
      'password': password,
    },
  );

  _ida.Future<_i7qokifa.UserProfile?> getCurrentUser({String? fullName}) =>
      caller.callServerEndpoint<_i7qokifa.UserProfile?>(
        'user',
        'getCurrentUser',
        {'fullName': fullName},
      );

  _ida.Future<bool> resetData() => caller.callServerEndpoint<bool>(
    'user',
    'resetData',
    {},
  );
}

/// {@category Endpoint}
class EndpointWorkspace extends _isc.EndpointRef {
  EndpointWorkspace(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'workspace';

  _ida.Future<_ijok4rmj.Workspace> ensure() =>
      caller.callServerEndpoint<_ijok4rmj.Workspace>(
        'workspace',
        'ensure',
        {},
      );

  _ida.Future<_ijok4rmj.Workspace> createWorkspace(
    String name, {
    String? description,
    required String creatorName,
  }) => caller.callServerEndpoint<_ijok4rmj.Workspace>(
    'workspace',
    'createWorkspace',
    {
      'name': name,
      'description': description,
      'creatorName': creatorName,
    },
  );

  _ida.Future<_ijok4rmj.Workspace?> joinWorkspace(
    String code, {
    required String userName,
  }) => caller.callServerEndpoint<_ijok4rmj.Workspace?>(
    'workspace',
    'joinWorkspace',
    {
      'code': code,
      'userName': userName,
    },
  );

  _ida.Future<List<_ijok4rmj.Workspace>> listUserWorkspaces({
    required String userName,
  }) => caller.callServerEndpoint<List<_ijok4rmj.Workspace>>(
    'workspace',
    'listUserWorkspaces',
    {'userName': userName},
  );

  _ida.Future<_ijok4rmj.Workspace?> getWorkspace(
    int workspaceId, {
    String? userName,
  }) => caller.callServerEndpoint<_ijok4rmj.Workspace?>(
    'workspace',
    'getWorkspace',
    {
      'workspaceId': workspaceId,
      'userName': userName,
    },
  );

  _ida.Future<_ijok4rmj.Workspace> updateWorkspace(
    int workspaceId, {
    required String userName,
    String? name,
    String? description,
  }) => caller.callServerEndpoint<_ijok4rmj.Workspace>(
    'workspace',
    'updateWorkspace',
    {
      'workspaceId': workspaceId,
      'userName': userName,
      'name': name,
      'description': description,
    },
  );

  _ida.Future<bool> deleteWorkspace(
    int workspaceId, {
    required String userName,
  }) => caller.callServerEndpoint<bool>(
    'workspace',
    'deleteWorkspace',
    {
      'workspaceId': workspaceId,
      'userName': userName,
    },
  );

  _ida.Future<bool> resetAllData() => caller.callServerEndpoint<bool>(
    'workspace',
    'resetAllData',
    {},
  );
}

/// {@category Endpoint}
class EndpointZone extends _isc.EndpointRef {
  EndpointZone(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'zone';

  _ida.Future<List<_igytwnus.Zone>> list(int cameraId) =>
      caller.callServerEndpoint<List<_igytwnus.Zone>>(
        'zone',
        'list',
        {'cameraId': cameraId},
      );

  _ida.Future<_igytwnus.Zone> save(_igytwnus.Zone zone) =>
      caller.callServerEndpoint<_igytwnus.Zone>(
        'zone',
        'save',
        {'zone': zone},
      );

  _ida.Future<void> delete(int id) => caller.callServerEndpoint<void>(
    'zone',
    'delete',
    {'id': id},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_ij1oemww.Greeting> hello(String name) =>
      caller.callServerEndpoint<_ij1oemww.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    audit = EndpointAudit(this);
    camera = EndpointCamera(this);
    contact = EndpointContact(this);
    demo = EndpointDemo(this);
    evidence = EndpointEvidence(this);
    health = EndpointHealth(this);
    incident = EndpointIncident(this);
    room = EndpointRoom(this);
    roomMessage = EndpointRoomMessage(this);
    rule = EndpointRule(this);
    signal = EndpointSignal(this);
    user = EndpointUser(this);
    workspace = EndpointWorkspace(this);
    zone = EndpointZone(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAudit audit;

  late final EndpointCamera camera;

  late final EndpointContact contact;

  late final EndpointDemo demo;

  late final EndpointEvidence evidence;

  late final EndpointHealth health;

  late final EndpointIncident incident;

  late final EndpointRoom room;

  late final EndpointRoomMessage roomMessage;

  late final EndpointRule rule;

  late final EndpointSignal signal;

  late final EndpointUser user;

  late final EndpointWorkspace workspace;

  late final EndpointZone zone;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'audit': audit,
    'camera': camera,
    'contact': contact,
    'demo': demo,
    'evidence': evidence,
    'health': health,
    'incident': incident,
    'room': room,
    'roomMessage': roomMessage,
    'rule': rule,
    'signal': signal,
    'user': user,
    'workspace': workspace,
    'zone': zone,
    'greeting': greeting,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
