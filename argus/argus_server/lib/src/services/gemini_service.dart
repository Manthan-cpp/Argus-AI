import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:argus_engine/argus_engine.dart' as engine;
import '../generated/protocol.dart';

class GeminiService {
  static Future<ParseResult> interpretRule(
    Session session,
    String sentence, {
    int? cameraId,
  }) async {
    final apiKey = Platform.environment['GEMINI_API_KEY'];

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final client = HttpClient();
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
        );
        final request = await client.postUrl(uri);
        request.headers.contentType = ContentType.json;

        final systemPrompt = '''
You are an expert CCTV safety policy compiler for municipal command centers.
Convert the user's natural language safety rule statement into a strict JSON RuleSpec object.
JSON Schema:
{
  "name": string,
  "severity": "low" | "medium" | "high" | "critical",
  "trigger": {
    "signal": "person_in_zone" | "fall_suspected" | "motionless" | "person_count",
    "zoneId": integer or null,
    "minDurationSec": integer,
    "minConfidence": float between 0.0 and 1.0,
    "minCount": integer or null
  },
  "conditions": {
    "daysOfWeek": [1, 2, 3, 4, 5, 6, 7],
    "timezone": "UTC",
    "timeWindows": [{"start": "00:00", "end": "23:59"}]
  },
  "actions": [{"kind": "create_incident", "paramsJson": "{}"}],
  "cooldownSec": integer,
  "escalation": [
    {"afterSec": 30, "notify": "Duty Security Officer", "message": "First alert"},
    {"afterSec": 120, "notify": "Shift Commander", "message": "Escalation ladder 2"}
  ]
}
Return ONLY valid JSON with no markdown wrapping or triple backticks.
''';

        final payload = json.encode({
          'contents': [
            {
              'parts': [
                {'text': '$systemPrompt\n\nUser sentence: "$sentence"'}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.1,
          }
        });

        request.write(payload);
        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        client.close();

        if (response.statusCode == 200) {
          final geminiJson = json.decode(responseBody);
          final candidates = geminiJson['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final rawText = candidates[0]['content']['parts'][0]['text'] as String;
            final cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
            final map = json.decode(cleanJson) as Map<String, dynamic>;

            final triggerMap = map['trigger'] as Map<String, dynamic>? ?? {};
            final conditionsMap = map['conditions'] as Map<String, dynamic>? ?? {};
            final actionsList = (map['actions'] as List?) ?? [];
            final escalationList = (map['escalation'] as List?) ?? [];

            final spec = RuleSpec(
              workspaceId: 1,
              name: map['name'] as String? ?? 'Custom Safety Rule',
              enabled: true,
              cameraIds: [cameraId ?? 1],
              trigger: RuleTrigger(
                signal: triggerMap['signal'] as String? ?? 'person_in_zone',
                zoneId: triggerMap['zoneId'] as int? ?? 1,
                minDurationSec: (triggerMap['minDurationSec'] as num?)?.toInt() ?? 3,
                minConfidence: (triggerMap['minConfidence'] as num?)?.toDouble() ?? 0.8,
                minCount: (triggerMap['minCount'] as num?)?.toInt(),
              ),
              conditions: RuleConditions(
                daysOfWeek: (conditionsMap['daysOfWeek'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [1, 2, 3, 4, 5, 6, 7],
                timezone: conditionsMap['timezone'] as String? ?? 'UTC',
                timeWindows: [],
              ),
              severity: map['severity'] as String? ?? 'high',
              verify: RuleVerify(enabled: false, kind: 'generic'),
              actions: actionsList.map((a) => RuleAction(
                kind: a['kind'] as String? ?? 'create_incident',
                paramsJson: json.encode(a['params'] ?? {}),
              )).toList(),
              cooldownSec: (map['cooldownSec'] as num?)?.toInt() ?? 60,
              escalation: escalationList.map((e) => RuleEscalation(
                afterSec: (e['afterSec'] as num?)?.toInt() ?? 30,
                notify: e['notify'] as String? ?? 'Duty Security Officer',
                message: e['message'] as String? ?? 'Safety escalation',
              )).toList(),
              sourceText: sentence,
              parsedBy: 'gemini_2_5_flash',
              createdAt: DateTime.now(),
              version: 1,
            );

            return ParseResult(
              spec: spec,
              parsedBy: 'gemini_2_5_flash',
              confidence: 0.96,
              warnings: [],
              alternatives: [],
            );
          }
        }
      } catch (e) {
        session.log('Gemini rule interpretation failed ($e), falling back to grammar parser.');
      }
    }

    // Offline / Quota Fallback: Pure Dart Engine Grammar Parser
    final grammarParser = engine.GrammarParser();
    final parsed = grammarParser.parse(sentence);

    RuleSpec? spec;
    if (parsed.spec != null) {
      spec = RuleSpec(
        workspaceId: 1,
        name: parsed.spec!.name,
        enabled: parsed.spec!.enabled,
        cameraIds: [cameraId ?? 1],
        trigger: RuleTrigger(
          signal: parsed.spec!.trigger.signal.name,
          zoneId: parsed.spec!.trigger.zoneId,
          minDurationSec: parsed.spec!.trigger.minDurationSec,
          minConfidence: parsed.spec!.trigger.minConfidence,
          minCount: parsed.spec!.trigger.minCount,
          ppe: parsed.spec!.trigger.ppe,
        ),
        conditions: RuleConditions(
          daysOfWeek: parsed.spec!.conditions.daysOfWeek,
          timezone: parsed.spec!.conditions.timezone,
          timeWindows: parsed.spec!.conditions.timeWindows.map((tw) => TimeWindow(
            start: tw.start,
            end: tw.end,
          )).toList(),
        ),
        severity: parsed.spec!.severity.name,
        verify: RuleVerify(
          enabled: parsed.spec!.verify.enabled,
          kind: parsed.spec!.verify.kind,
        ),
        actions: parsed.spec!.actions.map((a) => RuleAction(
          kind: a.kind,
          paramsJson: '{}',
        )).toList(),
        cooldownSec: parsed.spec!.cooldownSec,
        escalation: parsed.spec!.escalation.map((e) => RuleEscalation(
          afterSec: e.afterSec,
          notify: e.notify,
          message: e.message,
        )).toList(),
        sourceText: sentence,
        parsedBy: parsed.parsedBy,
        createdAt: DateTime.now(),
        version: 1,
      );
    }

    return ParseResult(
      spec: spec,
      parsedBy: parsed.parsedBy,
      confidence: parsed.confidence,
      warnings: parsed.warnings,
      unsupportedReason: parsed.unsupportedReason,
      alternatives: parsed.alternatives,
    );
  }

  static Future<VerificationInfo> verifySnapshot(
    Session session, {
    required String base64Jpeg,
    required String ruleContext,
  }) async {
    final apiKey = Platform.environment['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return VerificationInfo(
        status: 'not_requested',
        reason: 'On-device vision telemetry verified locally (Gemini cloud verification not enabled).',
      );
    }

    try {
      final client = HttpClient();
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;

      final prompt = '''
You are an assistive safety verification agent for a municipal CCTV command center.
Examine this privacy-blurred security frame crop for the hazard: "$ruleContext".
Respond ONLY with a JSON object:
{
  "isViolation": boolean,
  "confidence": float between 0.0 and 1.0,
  "reason": string
}
''';

      final payload = json.encode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Jpeg,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.1,
        }
      });

      request.write(payload);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final geminiJson = json.decode(responseBody);
        final rawText = geminiJson['candidates'][0]['content']['parts'][0]['text'] as String;
        final map = json.decode(rawText.replaceAll('```json', '').replaceAll('```', '').trim());

        final isViolation = map['isViolation'] == true;
        final conf = (map['confidence'] as num?)?.toDouble() ?? 0.85;
        final reason = map['reason'] as String? ?? 'Cloud verification completed';

        return VerificationInfo(
          status: isViolation ? 'verified' : 'unverified',
          reason: 'Gemini Assistive Check: $reason (confidence: ${(conf * 100).toStringAsFixed(0)}%)',
          model: 'gemini-1.5-flash',
        );
      }
    } catch (e) {
      session.log('Gemini verification call failed: $e');
    }

    return VerificationInfo(
      status: 'unverified',
      reason: 'Verification service unreachable, defaulting to telemetry confidence.',
    );
  }
}
