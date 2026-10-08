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
import 'package:argus_server/src/generated/camera.dart' as _irrewps0;
import 'package:argus_server/src/generated/contact.dart' as _ikdntdes;
import 'package:argus_server/src/generated/evidence_upload.dart' as _isa1j3gg;
import 'package:argus_server/src/generated/future_calls.dart' as _ividxzou;
import 'package:argus_server/src/generated/rule_spec.dart' as _ihw84zwb;
import 'package:argus_server/src/generated/signal_batch.dart' as _iefjwdie;
import 'package:argus_server/src/generated/workspace_settings.dart'
    as _io4d1l6f;
import 'package:argus_server/src/generated/zone.dart' as _i8tshavy;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/audit_endpoint.dart' as _irhfmlkv;
import '../endpoints/camera_endpoint.dart' as _izyq4o13;
import '../endpoints/contact_endpoint.dart' as _iioqm6zp;
import '../endpoints/demo_endpoint.dart' as _irow5ity;
import '../endpoints/evidence_endpoint.dart' as _i2cvsm7u;
import '../endpoints/health_endpoint.dart' as _ica9y4w0;
import '../endpoints/incident_endpoint.dart' as _idvfe0v9;
import '../endpoints/rule_endpoint.dart' as _i1yhvvjn;
import '../endpoints/signal_endpoint.dart' as _iirj0uqq;
import '../endpoints/workspace_endpoint.dart' as _i9dwb32i;
import '../endpoints/zone_endpoint.dart' as _ieltocmn;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'audit': _irhfmlkv.AuditEndpoint()
        ..initialize(
          server,
          'audit',
          null,
        ),
      'camera': _izyq4o13.CameraEndpoint()
        ..initialize(
          server,
          'camera',
          null,
        ),
      'contact': _iioqm6zp.ContactEndpoint()
        ..initialize(
          server,
          'contact',
          null,
        ),
      'demo': _irow5ity.DemoEndpoint()
        ..initialize(
          server,
          'demo',
          null,
        ),
      'evidence': _i2cvsm7u.EvidenceEndpoint()
        ..initialize(
          server,
          'evidence',
          null,
        ),
      'health': _ica9y4w0.HealthEndpoint()
        ..initialize(
          server,
          'health',
          null,
        ),
      'incident': _idvfe0v9.IncidentEndpoint()
        ..initialize(
          server,
          'incident',
          null,
        ),
      'rule': _i1yhvvjn.RuleEndpoint()
        ..initialize(
          server,
          'rule',
          null,
        ),
      'signal': _iirj0uqq.SignalEndpoint()
        ..initialize(
          server,
          'signal',
          null,
        ),
      'workspace': _i9dwb32i.WorkspaceEndpoint()
        ..initialize(
          server,
          'workspace',
          null,
        ),
      'zone': _ieltocmn.ZoneEndpoint()
        ..initialize(
          server,
          'zone',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['audit'] = _is.EndpointConnector(
      name: 'audit',
      endpoint: endpoints['audit']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['audit'] as _irhfmlkv.AuditEndpoint).list(
                session,
                limit: params['limit'],
              ),
        ),
      },
    );
    connectors['camera'] = _is.EndpointConnector(
      name: 'camera',
      endpoint: endpoints['camera']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['camera'] as _izyq4o13.CameraEndpoint).list(
                session,
              ),
        ),
        'save': _is.MethodConnector(
          name: 'save',
          params: {
            'camera': _is.ParameterDescription(
              name: 'camera',
              type: _is.getType<_irrewps0.Camera>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['camera'] as _izyq4o13.CameraEndpoint).save(
                session,
                params['camera'],
              ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['camera'] as _izyq4o13.CameraEndpoint).delete(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['contact'] = _is.EndpointConnector(
      name: 'contact',
      endpoint: endpoints['contact']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['contact'] as _iioqm6zp.ContactEndpoint)
                  .list(session),
        ),
        'save': _is.MethodConnector(
          name: 'save',
          params: {
            'contact': _is.ParameterDescription(
              name: 'contact',
              type: _is.getType<_ikdntdes.Contact>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['contact'] as _iioqm6zp.ContactEndpoint).save(
                    session,
                    params['contact'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['contact'] as _iioqm6zp.ContactEndpoint).delete(
                    session,
                    params['id'],
                  ),
        ),
        'createTelegramLinkCode': _is.MethodConnector(
          name: 'createTelegramLinkCode',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['contact'] as _iioqm6zp.ContactEndpoint)
                  .createTelegramLinkCode(session),
        ),
      },
    );
    connectors['demo'] = _is.EndpointConnector(
      name: 'demo',
      endpoint: endpoints['demo']!,
      methodConnectors: {
        'seed': _is.MethodConnector(
          name: 'seed',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['demo'] as _irow5ity.DemoEndpoint).seed(session),
        ),
      },
    );
    connectors['evidence'] = _is.EndpointConnector(
      name: 'evidence',
      endpoint: endpoints['evidence']!,
      methodConnectors: {
        'upload': _is.MethodConnector(
          name: 'upload',
          params: {
            'upload': _is.ParameterDescription(
              name: 'upload',
              type: _is.getType<_isa1j3gg.EvidenceUpload>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['evidence'] as _i2cvsm7u.EvidenceEndpoint).upload(
                    session,
                    params['upload'],
                  ),
        ),
      },
    );
    connectors['health'] = _is.EndpointConnector(
      name: 'health',
      endpoint: endpoints['health']!,
      methodConnectors: {
        'ping': _is.MethodConnector(
          name: 'ping',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['health'] as _ica9y4w0.HealthEndpoint).ping(
                session,
              ),
        ),
      },
    );
    connectors['incident'] = _is.EndpointConnector(
      name: 'incident',
      endpoint: endpoints['incident']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'status': _is.ParameterDescription(
              name: 'status',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'severity': _is.ParameterDescription(
              name: 'severity',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'cameraId': _is.ParameterDescription(
              name: 'cameraId',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['incident'] as _idvfe0v9.IncidentEndpoint).list(
                    session,
                    status: params['status'],
                    severity: params['severity'],
                    cameraId: params['cameraId'],
                  ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['incident'] as _idvfe0v9.IncidentEndpoint).get(
                    session,
                    params['id'],
                  ),
        ),
        'acknowledge': _is.MethodConnector(
          name: 'acknowledge',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['incident'] as _idvfe0v9.IncidentEndpoint)
                  .acknowledge(
                    session,
                    params['id'],
                    note: params['note'],
                  ),
        ),
        'resolve': _is.MethodConnector(
          name: 'resolve',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['incident'] as _idvfe0v9.IncidentEndpoint).resolve(
                    session,
                    params['id'],
                    note: params['note'],
                  ),
        ),
        'markFalsePositive': _is.MethodConnector(
          name: 'markFalsePositive',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['incident'] as _idvfe0v9.IncidentEndpoint)
                  .markFalsePositive(
                    session,
                    params['id'],
                    note: params['note'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['incident'] as _idvfe0v9.IncidentEndpoint).delete(
                    session,
                    params['id'],
                  ),
        ),
        'deleteAll': _is.MethodConnector(
          name: 'deleteAll',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['incident'] as _idvfe0v9.IncidentEndpoint)
                  .deleteAll(session),
        ),
        'watch': _is.MethodStreamConnector(
          name: 'watch',
          params: {
            'sinceIncidentId': _is.ParameterDescription(
              name: 'sinceIncidentId',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['incident'] as _idvfe0v9.IncidentEndpoint).watch(
                session,
                sinceIncidentId: params['sinceIncidentId'],
              ),
        ),
      },
    );
    connectors['rule'] = _is.EndpointConnector(
      name: 'rule',
      endpoint: endpoints['rule']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['rule'] as _i1yhvvjn.RuleEndpoint).list(session),
        ),
        'save': _is.MethodConnector(
          name: 'save',
          params: {
            'rule': _is.ParameterDescription(
              name: 'rule',
              type: _is.getType<_ihw84zwb.RuleSpec>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['rule'] as _i1yhvvjn.RuleEndpoint).save(
                session,
                params['rule'],
              ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['rule'] as _i1yhvvjn.RuleEndpoint).delete(
                session,
                params['id'],
              ),
        ),
        'interpret': _is.MethodConnector(
          name: 'interpret',
          params: {
            'sentence': _is.ParameterDescription(
              name: 'sentence',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'cameraId': _is.ParameterDescription(
              name: 'cameraId',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['rule'] as _i1yhvvjn.RuleEndpoint).interpret(
                    session,
                    params['sentence'],
                    cameraId: params['cameraId'],
                  ),
        ),
        'dryRun': _is.MethodConnector(
          name: 'dryRun',
          params: {
            'rule': _is.ParameterDescription(
              name: 'rule',
              type: _is.getType<_ihw84zwb.RuleSpec>(),
              nullable: false,
            ),
            'replayClipId': _is.ParameterDescription(
              name: 'replayClipId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['rule'] as _i1yhvvjn.RuleEndpoint).dryRun(
                session,
                params['rule'],
                params['replayClipId'],
              ),
        ),
      },
    );
    connectors['signal'] = _is.EndpointConnector(
      name: 'signal',
      endpoint: endpoints['signal']!,
      methodConnectors: {
        'send': _is.MethodConnector(
          name: 'send',
          params: {
            'batch': _is.ParameterDescription(
              name: 'batch',
              type: _is.getType<_iefjwdie.SignalBatch>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['signal'] as _iirj0uqq.SignalEndpoint).send(
                session,
                params['batch'],
              ),
        ),
      },
    );
    connectors['workspace'] = _is.EndpointConnector(
      name: 'workspace',
      endpoint: endpoints['workspace']!,
      methodConnectors: {
        'ensure': _is.MethodConnector(
          name: 'ensure',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['workspace'] as _i9dwb32i.WorkspaceEndpoint)
                  .ensure(session),
        ),
        'updateSettings': _is.MethodConnector(
          name: 'updateSettings',
          params: {
            'settings': _is.ParameterDescription(
              name: 'settings',
              type: _is.getType<_io4d1l6f.WorkspaceSettings>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['workspace'] as _i9dwb32i.WorkspaceEndpoint)
                  .updateSettings(
                    session,
                    params['settings'],
                  ),
        ),
        'deleteWorkspaceData': _is.MethodConnector(
          name: 'deleteWorkspaceData',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['workspace'] as _i9dwb32i.WorkspaceEndpoint)
                  .deleteWorkspaceData(session),
        ),
      },
    );
    connectors['zone'] = _is.EndpointConnector(
      name: 'zone',
      endpoint: endpoints['zone']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'cameraId': _is.ParameterDescription(
              name: 'cameraId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['zone'] as _ieltocmn.ZoneEndpoint).list(
                session,
                params['cameraId'],
              ),
        ),
        'save': _is.MethodConnector(
          name: 'save',
          params: {
            'zone': _is.ParameterDescription(
              name: 'zone',
              type: _is.getType<_i8tshavy.Zone>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['zone'] as _ieltocmn.ZoneEndpoint).save(
                session,
                params['zone'],
              ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['zone'] as _ieltocmn.ZoneEndpoint).delete(
                session,
                params['id'],
              ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _ividxzou.FutureCalls();
  }
}
