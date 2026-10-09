/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:argus_client/src/protocol/audit_entry.dart' as _ikvg5xfi;
import 'package:argus_client/src/protocol/camera.dart' as _i20qtz6o;
import 'package:argus_client/src/protocol/contact.dart' as _is7rcw5z;
import 'package:argus_client/src/protocol/dispatch_room.dart' as _ic2gvio8;
import 'package:argus_client/src/protocol/incident.dart' as _i1aq5e6k;
import 'package:argus_client/src/protocol/room_member.dart' as _is3b1078;
import 'package:argus_client/src/protocol/room_message.dart' as _iy4hi5ej;
import 'package:argus_client/src/protocol/rule_spec.dart' as _iu4sgp9a;
import 'package:argus_client/src/protocol/zone.dart' as _igytwnus;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'audit_entry.dart' as _i1613bfs;
import 'bbox_n.dart' as _izkg6gr4;
import 'camera.dart' as _imwagalw;
import 'client_config.dart' as _iz7lq8go;
import 'contact.dart' as _id7ivncr;
import 'demo_seed_result.dart' as _ie4ytcen;
import 'detector_lab_report.dart' as _iai3zb4w;
import 'dispatch_room.dart' as _ip18i18x;
import 'dry_run_result.dart' as _i89uufof;
import 'escalation_payload.dart' as _iqlp7fhc;
import 'evidence_upload.dart' as _iuxz12ty;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'health_info.dart' as _ib4ibs59;
import 'incident.dart' as _iy4wsyyx;
import 'incident_detail.dart' as _i99u8ngz;
import 'incident_event.dart' as _icglyrab;
import 'incident_update.dart' as _if56ikdy;
import 'lab_clip_result.dart' as _ie6zb0fp;
import 'parse_result.dart' as _i717k81t;
import 'person_signal.dart' as _izlx5iyl;
import 'point_n.dart' as _ixjrd72v;
import 'retention_payload.dart' as _i1ksi047;
import 'room_member.dart' as _ii94tgib;
import 'room_message.dart' as _i2z40emo;
import 'rule_action.dart' as _ie2yorw3;
import 'rule_conditions.dart' as _ibwozmvt;
import 'rule_escalation.dart' as _ig7l9g0k;
import 'rule_spec.dart' as _ixr8yfub;
import 'rule_trigger.dart' as _iszxsrqr;
import 'rule_verify.dart' as _i0rdyykc;
import 'signal_ack.dart' as _izylj8v7;
import 'signal_batch.dart' as _iboycj1l;
import 'signal_event.dart' as _ixpqzu9p;
import 'time_window.dart' as _idjbqmwg;
import 'user_profile.dart' as _ir2mn8w1;
import 'verification_info.dart' as _iv8f4ltc;
import 'workspace.dart' as _io6eoug6;
import 'workspace_settings.dart' as _i88empjm;
import 'zone.dart' as _ixcxr4o1;
export 'audit_entry.dart';
export 'bbox_n.dart';
export 'camera.dart';
export 'client_config.dart';
export 'contact.dart';
export 'demo_seed_result.dart';
export 'detector_lab_report.dart';
export 'dispatch_room.dart';
export 'dry_run_result.dart';
export 'escalation_payload.dart';
export 'evidence_upload.dart';
export 'greetings/greeting.dart';
export 'health_info.dart';
export 'incident.dart';
export 'incident_detail.dart';
export 'incident_event.dart';
export 'incident_update.dart';
export 'lab_clip_result.dart';
export 'parse_result.dart';
export 'person_signal.dart';
export 'point_n.dart';
export 'retention_payload.dart';
export 'room_member.dart';
export 'room_message.dart';
export 'rule_action.dart';
export 'rule_conditions.dart';
export 'rule_escalation.dart';
export 'rule_spec.dart';
export 'rule_trigger.dart';
export 'rule_verify.dart';
export 'signal_ack.dart';
export 'signal_batch.dart';
export 'signal_event.dart';
export 'time_window.dart';
export 'user_profile.dart';
export 'verification_info.dart';
export 'workspace.dart';
export 'workspace_settings.dart';
export 'zone.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i1613bfs.AuditEntry) {
      return _i1613bfs.AuditEntry.fromJson(data) as T;
    }
    if (t == _izkg6gr4.BBoxN) {
      return _izkg6gr4.BBoxN.fromJson(data) as T;
    }
    if (t == _imwagalw.Camera) {
      return _imwagalw.Camera.fromJson(data) as T;
    }
    if (t == _iz7lq8go.ClientConfig) {
      return _iz7lq8go.ClientConfig.fromJson(data) as T;
    }
    if (t == _id7ivncr.Contact) {
      return _id7ivncr.Contact.fromJson(data) as T;
    }
    if (t == _ie4ytcen.DemoSeedResult) {
      return _ie4ytcen.DemoSeedResult.fromJson(data) as T;
    }
    if (t == _iai3zb4w.DetectorLabReport) {
      return _iai3zb4w.DetectorLabReport.fromJson(data) as T;
    }
    if (t == _ip18i18x.DispatchRoom) {
      return _ip18i18x.DispatchRoom.fromJson(data) as T;
    }
    if (t == _i89uufof.DryRunResult) {
      return _i89uufof.DryRunResult.fromJson(data) as T;
    }
    if (t == _iqlp7fhc.EscalationPayload) {
      return _iqlp7fhc.EscalationPayload.fromJson(data) as T;
    }
    if (t == _iuxz12ty.EvidenceUpload) {
      return _iuxz12ty.EvidenceUpload.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _ib4ibs59.HealthInfo) {
      return _ib4ibs59.HealthInfo.fromJson(data) as T;
    }
    if (t == _iy4wsyyx.Incident) {
      return _iy4wsyyx.Incident.fromJson(data) as T;
    }
    if (t == _i99u8ngz.IncidentDetail) {
      return _i99u8ngz.IncidentDetail.fromJson(data) as T;
    }
    if (t == _icglyrab.IncidentEvent) {
      return _icglyrab.IncidentEvent.fromJson(data) as T;
    }
    if (t == _if56ikdy.IncidentUpdate) {
      return _if56ikdy.IncidentUpdate.fromJson(data) as T;
    }
    if (t == _ie6zb0fp.LabClipResult) {
      return _ie6zb0fp.LabClipResult.fromJson(data) as T;
    }
    if (t == _i717k81t.ParseResult) {
      return _i717k81t.ParseResult.fromJson(data) as T;
    }
    if (t == _izlx5iyl.PersonSignal) {
      return _izlx5iyl.PersonSignal.fromJson(data) as T;
    }
    if (t == _ixjrd72v.PointN) {
      return _ixjrd72v.PointN.fromJson(data) as T;
    }
    if (t == _i1ksi047.RetentionPayload) {
      return _i1ksi047.RetentionPayload.fromJson(data) as T;
    }
    if (t == _ii94tgib.RoomMember) {
      return _ii94tgib.RoomMember.fromJson(data) as T;
    }
    if (t == _i2z40emo.RoomMessage) {
      return _i2z40emo.RoomMessage.fromJson(data) as T;
    }
    if (t == _ie2yorw3.RuleAction) {
      return _ie2yorw3.RuleAction.fromJson(data) as T;
    }
    if (t == _ibwozmvt.RuleConditions) {
      return _ibwozmvt.RuleConditions.fromJson(data) as T;
    }
    if (t == _ig7l9g0k.RuleEscalation) {
      return _ig7l9g0k.RuleEscalation.fromJson(data) as T;
    }
    if (t == _ixr8yfub.RuleSpec) {
      return _ixr8yfub.RuleSpec.fromJson(data) as T;
    }
    if (t == _iszxsrqr.RuleTrigger) {
      return _iszxsrqr.RuleTrigger.fromJson(data) as T;
    }
    if (t == _i0rdyykc.RuleVerify) {
      return _i0rdyykc.RuleVerify.fromJson(data) as T;
    }
    if (t == _izylj8v7.SignalAck) {
      return _izylj8v7.SignalAck.fromJson(data) as T;
    }
    if (t == _iboycj1l.SignalBatch) {
      return _iboycj1l.SignalBatch.fromJson(data) as T;
    }
    if (t == _ixpqzu9p.SignalEvent) {
      return _ixpqzu9p.SignalEvent.fromJson(data) as T;
    }
    if (t == _idjbqmwg.TimeWindow) {
      return _idjbqmwg.TimeWindow.fromJson(data) as T;
    }
    if (t == _ir2mn8w1.UserProfile) {
      return _ir2mn8w1.UserProfile.fromJson(data) as T;
    }
    if (t == _iv8f4ltc.VerificationInfo) {
      return _iv8f4ltc.VerificationInfo.fromJson(data) as T;
    }
    if (t == _io6eoug6.Workspace) {
      return _io6eoug6.Workspace.fromJson(data) as T;
    }
    if (t == _i88empjm.WorkspaceSettings) {
      return _i88empjm.WorkspaceSettings.fromJson(data) as T;
    }
    if (t == _ixcxr4o1.Zone) {
      return _ixcxr4o1.Zone.fromJson(data) as T;
    }
    if (t == _isc.getType<_i1613bfs.AuditEntry?>()) {
      return (data != null ? _i1613bfs.AuditEntry.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izkg6gr4.BBoxN?>()) {
      return (data != null ? _izkg6gr4.BBoxN.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_imwagalw.Camera?>()) {
      return (data != null ? _imwagalw.Camera.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iz7lq8go.ClientConfig?>()) {
      return (data != null ? _iz7lq8go.ClientConfig.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_id7ivncr.Contact?>()) {
      return (data != null ? _id7ivncr.Contact.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ie4ytcen.DemoSeedResult?>()) {
      return (data != null ? _ie4ytcen.DemoSeedResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iai3zb4w.DetectorLabReport?>()) {
      return (data != null ? _iai3zb4w.DetectorLabReport.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ip18i18x.DispatchRoom?>()) {
      return (data != null ? _ip18i18x.DispatchRoom.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i89uufof.DryRunResult?>()) {
      return (data != null ? _i89uufof.DryRunResult.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iqlp7fhc.EscalationPayload?>()) {
      return (data != null ? _iqlp7fhc.EscalationPayload.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iuxz12ty.EvidenceUpload?>()) {
      return (data != null ? _iuxz12ty.EvidenceUpload.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ib4ibs59.HealthInfo?>()) {
      return (data != null ? _ib4ibs59.HealthInfo.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iy4wsyyx.Incident?>()) {
      return (data != null ? _iy4wsyyx.Incident.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i99u8ngz.IncidentDetail?>()) {
      return (data != null ? _i99u8ngz.IncidentDetail.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_icglyrab.IncidentEvent?>()) {
      return (data != null ? _icglyrab.IncidentEvent.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_if56ikdy.IncidentUpdate?>()) {
      return (data != null ? _if56ikdy.IncidentUpdate.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ie6zb0fp.LabClipResult?>()) {
      return (data != null ? _ie6zb0fp.LabClipResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i717k81t.ParseResult?>()) {
      return (data != null ? _i717k81t.ParseResult.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izlx5iyl.PersonSignal?>()) {
      return (data != null ? _izlx5iyl.PersonSignal.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixjrd72v.PointN?>()) {
      return (data != null ? _ixjrd72v.PointN.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i1ksi047.RetentionPayload?>()) {
      return (data != null ? _i1ksi047.RetentionPayload.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ii94tgib.RoomMember?>()) {
      return (data != null ? _ii94tgib.RoomMember.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i2z40emo.RoomMessage?>()) {
      return (data != null ? _i2z40emo.RoomMessage.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ie2yorw3.RuleAction?>()) {
      return (data != null ? _ie2yorw3.RuleAction.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ibwozmvt.RuleConditions?>()) {
      return (data != null ? _ibwozmvt.RuleConditions.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ig7l9g0k.RuleEscalation?>()) {
      return (data != null ? _ig7l9g0k.RuleEscalation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixr8yfub.RuleSpec?>()) {
      return (data != null ? _ixr8yfub.RuleSpec.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iszxsrqr.RuleTrigger?>()) {
      return (data != null ? _iszxsrqr.RuleTrigger.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i0rdyykc.RuleVerify?>()) {
      return (data != null ? _i0rdyykc.RuleVerify.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izylj8v7.SignalAck?>()) {
      return (data != null ? _izylj8v7.SignalAck.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iboycj1l.SignalBatch?>()) {
      return (data != null ? _iboycj1l.SignalBatch.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixpqzu9p.SignalEvent?>()) {
      return (data != null ? _ixpqzu9p.SignalEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_idjbqmwg.TimeWindow?>()) {
      return (data != null ? _idjbqmwg.TimeWindow.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ir2mn8w1.UserProfile?>()) {
      return (data != null ? _ir2mn8w1.UserProfile.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iv8f4ltc.VerificationInfo?>()) {
      return (data != null ? _iv8f4ltc.VerificationInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_io6eoug6.Workspace?>()) {
      return (data != null ? _io6eoug6.Workspace.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i88empjm.WorkspaceSettings?>()) {
      return (data != null ? _i88empjm.WorkspaceSettings.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixcxr4o1.Zone?>()) {
      return (data != null ? _ixcxr4o1.Zone.fromJson(data) : null) as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_ie6zb0fp.LabClipResult>) {
      return (data as List)
              .map((e) => deserialize<_ie6zb0fp.LabClipResult>(e))
              .toList()
          as T;
    }
    if (t == List<_icglyrab.IncidentEvent>) {
      return (data as List)
              .map((e) => deserialize<_icglyrab.IncidentEvent>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_idjbqmwg.TimeWindow>) {
      return (data as List)
              .map((e) => deserialize<_idjbqmwg.TimeWindow>(e))
              .toList()
          as T;
    }
    if (t == List<_ie2yorw3.RuleAction>) {
      return (data as List)
              .map((e) => deserialize<_ie2yorw3.RuleAction>(e))
              .toList()
          as T;
    }
    if (t == List<_ig7l9g0k.RuleEscalation>) {
      return (data as List)
              .map((e) => deserialize<_ig7l9g0k.RuleEscalation>(e))
              .toList()
          as T;
    }
    if (t == List<_ixpqzu9p.SignalEvent>) {
      return (data as List)
              .map((e) => deserialize<_ixpqzu9p.SignalEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_izlx5iyl.PersonSignal>) {
      return (data as List)
              .map((e) => deserialize<_izlx5iyl.PersonSignal>(e))
              .toList()
          as T;
    }
    if (t == List<_ixjrd72v.PointN>) {
      return (data as List)
              .map((e) => deserialize<_ixjrd72v.PointN>(e))
              .toList()
          as T;
    }
    if (t == List<_ikvg5xfi.AuditEntry>) {
      return (data as List)
              .map((e) => deserialize<_ikvg5xfi.AuditEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i20qtz6o.Camera>) {
      return (data as List)
              .map((e) => deserialize<_i20qtz6o.Camera>(e))
              .toList()
          as T;
    }
    if (t == List<_is7rcw5z.Contact>) {
      return (data as List)
              .map((e) => deserialize<_is7rcw5z.Contact>(e))
              .toList()
          as T;
    }
    if (t == List<_i1aq5e6k.Incident>) {
      return (data as List)
              .map((e) => deserialize<_i1aq5e6k.Incident>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == _isc.getType<List<int>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<int>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_ic2gvio8.DispatchRoom>) {
      return (data as List)
              .map((e) => deserialize<_ic2gvio8.DispatchRoom>(e))
              .toList()
          as T;
    }
    if (t == List<_is3b1078.RoomMember>) {
      return (data as List)
              .map((e) => deserialize<_is3b1078.RoomMember>(e))
              .toList()
          as T;
    }
    if (t == List<_iy4hi5ej.RoomMessage>) {
      return (data as List)
              .map((e) => deserialize<_iy4hi5ej.RoomMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_iu4sgp9a.RuleSpec>) {
      return (data as List)
              .map((e) => deserialize<_iu4sgp9a.RuleSpec>(e))
              .toList()
          as T;
    }
    if (t == List<_igytwnus.Zone>) {
      return (data as List).map((e) => deserialize<_igytwnus.Zone>(e)).toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i1613bfs.AuditEntry => 'AuditEntry',
      _izkg6gr4.BBoxN => 'BBoxN',
      _imwagalw.Camera => 'Camera',
      _iz7lq8go.ClientConfig => 'ClientConfig',
      _id7ivncr.Contact => 'Contact',
      _ie4ytcen.DemoSeedResult => 'DemoSeedResult',
      _iai3zb4w.DetectorLabReport => 'DetectorLabReport',
      _ip18i18x.DispatchRoom => 'DispatchRoom',
      _i89uufof.DryRunResult => 'DryRunResult',
      _iqlp7fhc.EscalationPayload => 'EscalationPayload',
      _iuxz12ty.EvidenceUpload => 'EvidenceUpload',
      _izw8z7ou.Greeting => 'Greeting',
      _ib4ibs59.HealthInfo => 'HealthInfo',
      _iy4wsyyx.Incident => 'Incident',
      _i99u8ngz.IncidentDetail => 'IncidentDetail',
      _icglyrab.IncidentEvent => 'IncidentEvent',
      _if56ikdy.IncidentUpdate => 'IncidentUpdate',
      _ie6zb0fp.LabClipResult => 'LabClipResult',
      _i717k81t.ParseResult => 'ParseResult',
      _izlx5iyl.PersonSignal => 'PersonSignal',
      _ixjrd72v.PointN => 'PointN',
      _i1ksi047.RetentionPayload => 'RetentionPayload',
      _ii94tgib.RoomMember => 'RoomMember',
      _i2z40emo.RoomMessage => 'RoomMessage',
      _ie2yorw3.RuleAction => 'RuleAction',
      _ibwozmvt.RuleConditions => 'RuleConditions',
      _ig7l9g0k.RuleEscalation => 'RuleEscalation',
      _ixr8yfub.RuleSpec => 'RuleSpec',
      _iszxsrqr.RuleTrigger => 'RuleTrigger',
      _i0rdyykc.RuleVerify => 'RuleVerify',
      _izylj8v7.SignalAck => 'SignalAck',
      _iboycj1l.SignalBatch => 'SignalBatch',
      _ixpqzu9p.SignalEvent => 'SignalEvent',
      _idjbqmwg.TimeWindow => 'TimeWindow',
      _ir2mn8w1.UserProfile => 'UserProfile',
      _iv8f4ltc.VerificationInfo => 'VerificationInfo',
      _io6eoug6.Workspace => 'Workspace',
      _i88empjm.WorkspaceSettings => 'WorkspaceSettings',
      _ixcxr4o1.Zone => 'Zone',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('argus.', '');
    }

    switch (data) {
      case _i1613bfs.AuditEntry():
        return 'AuditEntry';
      case _izkg6gr4.BBoxN():
        return 'BBoxN';
      case _imwagalw.Camera():
        return 'Camera';
      case _iz7lq8go.ClientConfig():
        return 'ClientConfig';
      case _id7ivncr.Contact():
        return 'Contact';
      case _ie4ytcen.DemoSeedResult():
        return 'DemoSeedResult';
      case _iai3zb4w.DetectorLabReport():
        return 'DetectorLabReport';
      case _ip18i18x.DispatchRoom():
        return 'DispatchRoom';
      case _i89uufof.DryRunResult():
        return 'DryRunResult';
      case _iqlp7fhc.EscalationPayload():
        return 'EscalationPayload';
      case _iuxz12ty.EvidenceUpload():
        return 'EvidenceUpload';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _ib4ibs59.HealthInfo():
        return 'HealthInfo';
      case _iy4wsyyx.Incident():
        return 'Incident';
      case _i99u8ngz.IncidentDetail():
        return 'IncidentDetail';
      case _icglyrab.IncidentEvent():
        return 'IncidentEvent';
      case _if56ikdy.IncidentUpdate():
        return 'IncidentUpdate';
      case _ie6zb0fp.LabClipResult():
        return 'LabClipResult';
      case _i717k81t.ParseResult():
        return 'ParseResult';
      case _izlx5iyl.PersonSignal():
        return 'PersonSignal';
      case _ixjrd72v.PointN():
        return 'PointN';
      case _i1ksi047.RetentionPayload():
        return 'RetentionPayload';
      case _ii94tgib.RoomMember():
        return 'RoomMember';
      case _i2z40emo.RoomMessage():
        return 'RoomMessage';
      case _ie2yorw3.RuleAction():
        return 'RuleAction';
      case _ibwozmvt.RuleConditions():
        return 'RuleConditions';
      case _ig7l9g0k.RuleEscalation():
        return 'RuleEscalation';
      case _ixr8yfub.RuleSpec():
        return 'RuleSpec';
      case _iszxsrqr.RuleTrigger():
        return 'RuleTrigger';
      case _i0rdyykc.RuleVerify():
        return 'RuleVerify';
      case _izylj8v7.SignalAck():
        return 'SignalAck';
      case _iboycj1l.SignalBatch():
        return 'SignalBatch';
      case _ixpqzu9p.SignalEvent():
        return 'SignalEvent';
      case _idjbqmwg.TimeWindow():
        return 'TimeWindow';
      case _ir2mn8w1.UserProfile():
        return 'UserProfile';
      case _iv8f4ltc.VerificationInfo():
        return 'VerificationInfo';
      case _io6eoug6.Workspace():
        return 'Workspace';
      case _i88empjm.WorkspaceSettings():
        return 'WorkspaceSettings';
      case _ixcxr4o1.Zone():
        return 'Zone';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AuditEntry') {
      return deserialize<_i1613bfs.AuditEntry>(data['data']);
    }
    if (dataClassName == 'BBoxN') {
      return deserialize<_izkg6gr4.BBoxN>(data['data']);
    }
    if (dataClassName == 'Camera') {
      return deserialize<_imwagalw.Camera>(data['data']);
    }
    if (dataClassName == 'ClientConfig') {
      return deserialize<_iz7lq8go.ClientConfig>(data['data']);
    }
    if (dataClassName == 'Contact') {
      return deserialize<_id7ivncr.Contact>(data['data']);
    }
    if (dataClassName == 'DemoSeedResult') {
      return deserialize<_ie4ytcen.DemoSeedResult>(data['data']);
    }
    if (dataClassName == 'DetectorLabReport') {
      return deserialize<_iai3zb4w.DetectorLabReport>(data['data']);
    }
    if (dataClassName == 'DispatchRoom') {
      return deserialize<_ip18i18x.DispatchRoom>(data['data']);
    }
    if (dataClassName == 'DryRunResult') {
      return deserialize<_i89uufof.DryRunResult>(data['data']);
    }
    if (dataClassName == 'EscalationPayload') {
      return deserialize<_iqlp7fhc.EscalationPayload>(data['data']);
    }
    if (dataClassName == 'EvidenceUpload') {
      return deserialize<_iuxz12ty.EvidenceUpload>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'HealthInfo') {
      return deserialize<_ib4ibs59.HealthInfo>(data['data']);
    }
    if (dataClassName == 'Incident') {
      return deserialize<_iy4wsyyx.Incident>(data['data']);
    }
    if (dataClassName == 'IncidentDetail') {
      return deserialize<_i99u8ngz.IncidentDetail>(data['data']);
    }
    if (dataClassName == 'IncidentEvent') {
      return deserialize<_icglyrab.IncidentEvent>(data['data']);
    }
    if (dataClassName == 'IncidentUpdate') {
      return deserialize<_if56ikdy.IncidentUpdate>(data['data']);
    }
    if (dataClassName == 'LabClipResult') {
      return deserialize<_ie6zb0fp.LabClipResult>(data['data']);
    }
    if (dataClassName == 'ParseResult') {
      return deserialize<_i717k81t.ParseResult>(data['data']);
    }
    if (dataClassName == 'PersonSignal') {
      return deserialize<_izlx5iyl.PersonSignal>(data['data']);
    }
    if (dataClassName == 'PointN') {
      return deserialize<_ixjrd72v.PointN>(data['data']);
    }
    if (dataClassName == 'RetentionPayload') {
      return deserialize<_i1ksi047.RetentionPayload>(data['data']);
    }
    if (dataClassName == 'RoomMember') {
      return deserialize<_ii94tgib.RoomMember>(data['data']);
    }
    if (dataClassName == 'RoomMessage') {
      return deserialize<_i2z40emo.RoomMessage>(data['data']);
    }
    if (dataClassName == 'RuleAction') {
      return deserialize<_ie2yorw3.RuleAction>(data['data']);
    }
    if (dataClassName == 'RuleConditions') {
      return deserialize<_ibwozmvt.RuleConditions>(data['data']);
    }
    if (dataClassName == 'RuleEscalation') {
      return deserialize<_ig7l9g0k.RuleEscalation>(data['data']);
    }
    if (dataClassName == 'RuleSpec') {
      return deserialize<_ixr8yfub.RuleSpec>(data['data']);
    }
    if (dataClassName == 'RuleTrigger') {
      return deserialize<_iszxsrqr.RuleTrigger>(data['data']);
    }
    if (dataClassName == 'RuleVerify') {
      return deserialize<_i0rdyykc.RuleVerify>(data['data']);
    }
    if (dataClassName == 'SignalAck') {
      return deserialize<_izylj8v7.SignalAck>(data['data']);
    }
    if (dataClassName == 'SignalBatch') {
      return deserialize<_iboycj1l.SignalBatch>(data['data']);
    }
    if (dataClassName == 'SignalEvent') {
      return deserialize<_ixpqzu9p.SignalEvent>(data['data']);
    }
    if (dataClassName == 'TimeWindow') {
      return deserialize<_idjbqmwg.TimeWindow>(data['data']);
    }
    if (dataClassName == 'UserProfile') {
      return deserialize<_ir2mn8w1.UserProfile>(data['data']);
    }
    if (dataClassName == 'VerificationInfo') {
      return deserialize<_iv8f4ltc.VerificationInfo>(data['data']);
    }
    if (dataClassName == 'Workspace') {
      return deserialize<_io6eoug6.Workspace>(data['data']);
    }
    if (dataClassName == 'WorkspaceSettings') {
      return deserialize<_i88empjm.WorkspaceSettings>(data['data']);
    }
    if (dataClassName == 'Zone') {
      return deserialize<_ixcxr4o1.Zone>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('argus', this);
    _iacc.Protocol().registerHostProtocol('argus', this);
  }

  @override
  String getModuleName() => 'argus';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
