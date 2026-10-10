import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argus_flutter/main.dart';
import 'package:argus_flutter/app/theme/severity_scale.dart';
import 'package:argus_flutter/core/widgets/status_badge.dart';
import 'package:argus_flutter/core/widgets/workflow_graph_view.dart';
import 'package:argus_client/argus_client.dart';

import 'package:argus_flutter/data/repository_provider.dart';

import 'package:argus_flutter/data/mock/mock_argus_repository.dart';
import 'package:argus_flutter/features/rooms/room_providers.dart';

void main() {
  testWidgets('App renders Home screen with Facility Operations Hub auth barrier', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useMockOverrideProvider.overrideWith((ref) => true),
        ],
        child: const ArgusApp(),
      ),
    );

    // Let entrance animations run without waiting for repeating beacon
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Brand Logo
    expect(find.text('Argus'), findsWidgets);

    // Verify Facility Hub Auth barrier
    expect(
      find.textContaining('Sign in or register an account to manage your security facilities'),
      findsOneWidget,
    );

    // Verify Sign In CTA
    expect(find.text('Sign In or Create Account'), findsOneWidget);
  });

  testWidgets('App renders Home screen with facilities hub and operational guide when signed in', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockArgusRepository();
    await mockRepo.signUp('Test User', 'testpass123');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useMockOverrideProvider.overrideWith((ref) => true),
          argusRepositoryProvider.overrideWithValue(mockRepo),
          currentUserProvider.overrideWith((ref) {
            final notifier = CurrentUserNotifier(ref);
            notifier.state = AsyncValue.data(
              UserProfile(
                id: 1,
                workspaceId: 1,
                fullName: 'Test User',
                role: 'member',
                createdAt: DateTime.now(),
              ),
            );
            return notifier;
          }),
        ],
        child: const ArgusApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Home — Facility Operations Command'), findsOneWidget);
    expect(find.text('Operational Architecture & Getting Started'), findsOneWidget);
    expect(find.text('Deploy or Join Facility'), findsOneWidget);
    expect(find.text('Connect CCTV & Video Feeds'), findsOneWidget);
  });

  testWidgets('StatusBadge renders severity icons and labels accurately', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              StatusBadge.fromSeverity(SeverityLevel.low),
              StatusBadge.fromSeverity(SeverityLevel.critical),
              StatusBadge.mock(),
            ],
          ),
        ),
      ),
    );

    expect(find.text('LOW'), findsOneWidget);
    expect(find.text('CRITICAL'), findsOneWidget);
    expect(find.text('MOCK DATA'), findsOneWidget);
  });

  testWidgets('WorkflowGraphView renders all pipeline nodes for a rule', (WidgetTester tester) async {
    final testRule = RuleSpec(
      id: 1,
      workspaceId: 1,
      name: 'Test Fall Rule',
      enabled: true,
      cameraIds: const [1],
      trigger: RuleTrigger(
        signal: 'fall_suspected',
        minDurationSec: 10,
        minConfidence: 0.6,
      ),
      conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
      severity: 'high',
      verify: RuleVerify(enabled: false, kind: 'generic'),
      actions: [RuleAction(kind: 'create_incident', paramsJson: '{}')],
      cooldownSec: 60,
      escalation: [RuleEscalation(afterSec: 120, notify: 'Supervisor', message: 'Escalate')],
      sourceText: 'If someone falls, alert supervisor',
      parsedBy: 'grammar',
      createdAt: DateTime.now(),
      version: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkflowGraphView(rule: testRule),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CAMERA'), findsOneWidget);
    expect(find.text('DETECT'), findsOneWidget);
    expect(find.text('ZONE'), findsOneWidget);
    expect(find.text('CONDITION'), findsOneWidget);
    expect(find.text('VERIFY'), findsOneWidget);
    expect(find.text('ACTIONS'), findsOneWidget);
    expect(find.text('ESCALATION'), findsOneWidget);
  });
}
