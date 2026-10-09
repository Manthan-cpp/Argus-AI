import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shell/control_room_scaffold.dart';
import '../../features/home/home_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/monitor/monitor_screen.dart';
import '../../features/cameras/cameras_screen.dart';
import '../../features/zones/zone_editor_screen.dart';
import '../../features/rules/rule_studio_screen.dart';
import '../../features/incidents/incidents_screen.dart';
import '../../features/incidents/incident_detail_screen.dart';
import '../../features/escalation/escalation_screen.dart';
import '../../features/lab/detector_lab_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/about/about_screen.dart';
import '../../features/dev/kitchen_sink_screen.dart';
import '../../features/rooms/room_directory_screen.dart';
import '../../features/rooms/dispatch_room_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter argusRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ControlRoomScaffold(
          currentRoute: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/app/monitor',
          builder: (context, state) => const MonitorScreen(),
        ),
        GoRoute(
          path: '/app/cameras',
          builder: (context, state) => const CamerasScreen(),
          routes: [
            GoRoute(
              path: ':id/zones',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                return ZoneEditorScreen(cameraId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/app/rules',
          builder: (context, state) => const RuleStudioScreen(),
        ),
        GoRoute(
          path: '/app/incidents',
          builder: (context, state) => const IncidentsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                return IncidentDetailScreen(incidentId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/app/rooms',
          builder: (context, state) => const RoomDirectoryScreen(),
          routes: [
            GoRoute(
              path: ':code',
              builder: (context, state) {
                final code = state.pathParameters['code'] ?? 'ARG-7842';
                return DispatchRoomScreen(code: code);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/app/escalation',
          builder: (context, state) => const EscalationScreen(),
        ),
        GoRoute(
          path: '/app/lab',
          builder: (context, state) => const DetectorLabScreen(),
        ),
        GoRoute(
          path: '/app/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/dev/kitchen-sink',
          builder: (context, state) => const KitchenSinkScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AuthScreen(),
    ),
  ],
);
