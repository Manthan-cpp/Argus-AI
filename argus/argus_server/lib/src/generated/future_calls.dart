/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: depend_on_referenced_packages

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:argus_server/src/generated/escalation_payload.dart'
    as _i64kknlw;
import 'package:argus_server/src/generated/retention_payload.dart' as _ipxidxzh;
import 'package:clock/clock.dart' as _io0w16m8;
import 'package:serverpod/serverpod.dart' as _is;
import '../future_calls/incident_escalation_call.dart' as _i0i0l1ru;
import '../future_calls/retention_cleanup_call.dart' as _iwvgfueg;

/// Invokes a future call.
typedef _InvokeFutureCall =
    Future<void> Function(String name, _is.SerializableModel? object);

extension ServerpodFutureCallsGetter on _is.Serverpod {
  /// Generated future calls.
  FutureCalls get futureCalls => FutureCalls();
}

class FutureCalls extends _is.FutureCallDispatch<_FutureCallRef> {
  FutureCalls._();

  factory FutureCalls() {
    return _instance;
  }

  static final FutureCalls _instance = FutureCalls._();

  _is.FutureCallManager? _futureCallManager;

  String? _serverId;

  String get _effectiveServerId {
    if (_serverId == null) {
      throw StateError('FutureCalls is not initialized.');
    }
    return _serverId!;
  }

  _is.FutureCallManager get _effectiveFutureCallManager {
    if (_futureCallManager == null) {
      throw StateError('FutureCalls is not initialized.');
    }
    return _futureCallManager!;
  }

  @override
  void initialize(
    _is.FutureCallManager futureCallManager,
    String serverId,
  ) {
    var registeredFutureCalls = <String, _is.InvokableFutureCall>{
      'IncidentEscalationCallInvokeFutureCall':
          IncidentEscalationCallInvokeFutureCall(),
      'RetentionCleanupCallInvokeFutureCall':
          RetentionCleanupCallInvokeFutureCall(),
    };
    _futureCallManager = futureCallManager;
    _serverId = serverId;
    for (final entry in registeredFutureCalls.entries) {
      _futureCallManager?.registerFutureCall(entry.value, entry.key);
    }
  }

  @override
  _FutureCallRef callAtTime(
    DateTime time, {
    String? identifier,
  }) {
    return _FutureCallRef(
      (name, object) {
        return _effectiveFutureCallManager.scheduleFutureCall(
          name,
          object,
          time,
          _effectiveServerId,
          identifier,
        );
      },
    );
  }

  @override
  _FutureCallRef callWithDelay(
    Duration delay, {
    String? identifier,
  }) {
    return _FutureCallRef(
      (name, object) {
        return _effectiveFutureCallManager.scheduleFutureCall(
          name,
          object,
          DateTime.now().toUtc().add(delay),
          _effectiveServerId,
          identifier,
        );
      },
    );
  }

  @override
  _is.RecurringFutureCallDispatch<_FutureCallRef> callRecurring({
    String? identifier,
  }) {
    return _RecurringFutureCallDispatchImpl(
      _effectiveFutureCallManager,
      _effectiveServerId,
      identifier,
    );
  }

  @override
  Future<void> cancel(String identifier) async {
    await _effectiveFutureCallManager.cancelFutureCall(identifier);
  }
}

class _RecurringFutureCallDispatchImpl
    extends _is.RecurringFutureCallDispatch<_FutureCallRef> {
  _RecurringFutureCallDispatchImpl(
    this._futureCallManager,
    this._serverId,
    this._identifier,
  );

  final _is.FutureCallManager _futureCallManager;

  final String _serverId;

  final String? _identifier;

  @override
  _FutureCallRef cron(String cronExpression) {
    return _FutureCallRef(
      (name, object) {
        return _futureCallManager.scheduleFutureCall(
          name,
          object,
          _is.Cron.parse(cronExpression).nextTime(),
          _serverId,
          _identifier,
          scheduling: _is.CronFutureCallScheduling(cron: cronExpression),
        );
      },
    );
  }

  @override
  _FutureCallRef every(
    Duration interval, {
    DateTime? start,
  }) {
    final now = _io0w16m8.clock.now().toUtc();
    return _FutureCallRef(
      (name, object) {
        return _futureCallManager.scheduleFutureCall(
          name,
          object,
          start ?? now.add(interval),
          _serverId,
          _identifier,
          scheduling: _is.IntervalFutureCallScheduling(
            interval: interval,
            start: start,
          ),
        );
      },
    );
  }
}

class _FutureCallRef {
  _FutureCallRef(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  late final incidentEscalationCall =
      _IncidentEscalationCallFutureCallDispatcher(_invokeFutureCall);

  late final retentionCleanupCall = _RetentionCleanupCallFutureCallDispatcher(
    _invokeFutureCall,
  );
}

class _IncidentEscalationCallFutureCallDispatcher {
  _IncidentEscalationCallFutureCallDispatcher(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  Future<void> invoke(_i64kknlw.EscalationPayload? payload) {
    return _invokeFutureCall(
      'IncidentEscalationCallInvokeFutureCall',
      payload,
    );
  }
}

class _RetentionCleanupCallFutureCallDispatcher {
  _RetentionCleanupCallFutureCallDispatcher(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  Future<void> invoke(_ipxidxzh.RetentionPayload? payload) {
    return _invokeFutureCall(
      'RetentionCleanupCallInvokeFutureCall',
      payload,
    );
  }
}

class IncidentEscalationCallInvokeFutureCall
    extends _is.FutureCall<_i64kknlw.EscalationPayload>
    implements _is.InvokableFutureCall<_i64kknlw.EscalationPayload> {
  @override
  _ida.Future<void> invoke(
    _is.Session session,
    _i64kknlw.EscalationPayload? payload,
  ) async {
    await _i0i0l1ru.IncidentEscalationCall().invoke(
      session,
      payload,
    );
  }
}

class RetentionCleanupCallInvokeFutureCall
    extends _is.FutureCall<_ipxidxzh.RetentionPayload>
    implements _is.InvokableFutureCall<_ipxidxzh.RetentionPayload> {
  @override
  _ida.Future<void> invoke(
    _is.Session session,
    _ipxidxzh.RetentionPayload? payload,
  ) async {
    await _iwvgfueg.RetentionCleanupCall().invoke(
      session,
      payload,
    );
  }
}
