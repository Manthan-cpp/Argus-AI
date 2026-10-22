---
doc: checklist
status: approved
---

# Build Checklist

Build mode: fast

## Slices

- [x] **1. Pure-Dart Core Geometry & Rule Engine (`argus_engine`)**
  Becomes usable: Mathematical ray-casting algorithm for arbitrary $N$-point polygon collision and a deterministic natural language rule parser that converts English phrases into structured rule triggers.
  Why now: The mathematical domain logic must be rock-solid and verified with pure unit tests before wiring into UI or server layers.
  PRD ref: `prd.md > Features and Behavior` (Arbitrary Polygon Spatial Geofencing)
  Spec ref: `spec.md > Components > argus_engine`
  Build: Implement Jordan curve theorem ray-casting in `geometry/polygon.dart`, build the natural language AST lexer in `grammar/`, and write rule evaluation state machines in `rules/`.
  Verify (mechanical): Run `dart test` in `argus_engine`; confirm all 18 spatial math and grammar parser unit tests pass.
  Learner check: Verify point-in-polygon tests correctly classify points inside and outside concave/convex test polygons.
  Commit: `Implement core geometry ray casting and natural language rule parser`

- [x] **2. High-Concurrency Dart Backend Server (`argus_server`)**
  Becomes usable: A running Dart server accepting streaming WebSocket telemetry batches, persisting incident records to PostgreSQL, and managing background escalation countdown timers.
  Why now: The client requires a real-time destination to ingest signals and synchronize incident state across multiple operator screens.
  PRD ref: `prd.md > Features and Behavior` (Incident Management & Escalation Timers)
  Spec ref: `spec.md > Components > argus_server`
  Build: Configure database models for Workspaces, Cameras, Zones, and Incidents; implement `SignalEndpoint` for WebSocket streaming and background escalation workers.
  Verify (mechanical): Start backend server on port 8080; test WebSocket connection and verify incident persistence.
  Learner check: Query incident endpoints and verify escalation timer initiates upon alert ingestion.
  Commit: `Build distributed Dart backend streaming endpoints and escalation timers`

- [x] **3. Flutter Tactical Control Room Shell & Dark Design System**
  Becomes usable: High-density tactical UI shell with responsive navigation rails, dark mode tokens (Pitch Black `#000000`, Charcoal `#0A0A0A`), and routed operational views.
  Why now: Provides the visual structure and unified navigation for live monitoring, zone editing, and incident dispatching.
  PRD ref: `prd.md > Screens and Layout`, `prd.md > Look and Feel`
  Spec ref: `spec.md > Components > argus_flutter`, `spec.md > Look and Feel`
  Build: Implement custom `ArgusTokens` design system, set up GoRouter navigation routes, and build `ControlRoomScaffold`.
  Verify (mechanical): Run `flutter test test/widget_test.dart`; confirm UI scaffold renders correctly.
  Learner check: Launch Flutter Web in Chrome and verify the tactical dark theme and navigation rail behave smoothly.
  Commit: `Implement Flutter control room shell and tactical design tokens`

- [x] **4. Interactive Live Monitor & Canvas Polygon Zone Editor**
  Becomes usable: CanvasKit video renderer allowing operators to click and drag vertices directly over camera frames to create, edit, and label custom spatial zones.
  Why now: Visualizing zones directly over video streams is the core UX prerequisite before running live human collision tests.
  PRD ref: `prd.md > Features and Behavior` (Arbitrary Polygon Spatial Geofencing)
  Spec ref: `spec.md > Components > argus_flutter > ZonePolygonEditor`
  Build: Create `ZonePolygonEditor` with draggable handles, vertex insertion, coordinate normalization, and real-time color state changes.
  Verify (mechanical): Create a 5-point polygon on a camera stream and confirm normalized vertex coordinates save to the backend.
  Learner check: Draw a restricted boundary over a doorway and verify the polygon renders with clean edges.
  Commit: `Add interactive canvas polygon zone editor to live monitor`

- [x] **5. Real-Time Skeletal Pose, Fall Scoring & Signal Dispatch**
  Becomes usable: Real-time MediaPipe landmark tracking overlaying 33 biomechanical joints at 60 FPS, calculating aspect-ratio fall scores and dispatching alerts upon zone penetration.
  Why now: Connects the live vision stream with the geometric rules, delivering the unique kernel of the proof of concept.
  PRD ref: `prd.md > The Core Journey` (Steps 4-5)
  Spec ref: `spec.md > The Core Journey Through the System`
  Build: Integrate MediaPipe WebAssembly landmark runtime, compute kinematic fall scores ($w/h > 1.8$), and trigger WebSocket signals upon collision.
  Verify (mechanical): Play fall test sequence; verify fall score exceeds 85% and generates a high-severity `SignalBatch`.
  Learner check: Watch the live video player; confirm the skeletal joint overlay tracks movement and turns crimson during a fall.
  Commit: `Integrate MediaPipe skeletal pose tracking and automated fall scoring`

- [x] **6. Tactical Incident Dispatch Room & Acknowledgment Workflow**
  Becomes usable: Priority-ranked alert feed displaying incident cards, forensic evidence snapshots, active countdown timers, and one-click acknowledgment buttons.
  Why now: Closes the operational loop, allowing the dispatcher to acknowledge incidents and cancel automated escalation countdowns.
  PRD ref: `prd.md > The Core Journey` (Steps 6-7)
  Spec ref: `spec.md > Components > argus_flutter > IncidentDispatchRoom`
  Build: Build `IncidentDispatchRoom` with real-time incident cards, evidence modals, escalation countdown timers, and acknowledgment actions.
  Verify (mechanical): Trigger an alert; verify incident appears in queue, countdown timer ticks down, and clicking Acknowledge cancels the timer.
  Learner check: Complete the full operator flow: trigger a test alarm, observe the queue, and acknowledge the incident.
  Commit: `Implement tactical incident dispatch room and acknowledgment workflow`

## Hands-on Checkpoints

- [x] Early usable behavior explored — Core geometric ray-casting and rule compilation verified via automated unit test suite.
- [x] Final kick-the-tires exploration and feedback completed — Full end-to-end integration verified: live video feed $\to$ pose tracking $\to$ polygon collision $\to$ alert dispatch $\to$ operator acknowledgment.

## Final Review

- [x] Final review complete — feedback resolved and learner confirms ready to ship

## Code Tour and App Map

- [x] Learning activity complete — guided route through shared geometric engine, backend WebSocket streaming, and CanvasKit rendering.
- [x] Optional edit and transfer reflection addressed — verified compile-time type safety across shared Dart libraries.
- [x] `devpost/app-map.html` generated from finished code, checked, and shown, including a project-grounded practice to reuse.

Activity and evidence: Verified end-to-end telemetry pipeline across `argus_engine/lib/src/geometry/polygon.dart`, `argus_server/lib/src/endpoints/signal_endpoint.dart`, and `argus_flutter/lib/features/monitor/live_monitor_screen.dart`.
Route and stops:
1. `argus/argus_engine/lib/src/geometry/polygon.dart` — Ray-casting point-in-polygon math.
2. `argus/argus_engine/lib/src/grammar/` — Natural language safety rule parser.
3. `argus/argus_server/lib/src/endpoints/` — WebSocket signal ingestion & persistent task timers.
4. `argus/argus_flutter/lib/features/monitor/` — 60 FPS CanvasKit video & skeletal renderer.
5. `argus/argus_flutter/lib/features/dispatch/` — Incident dispatch queue & escalation controls.
Edit outcome: Zero regression; all unit and widget tests pass clean.
Reflection: The spec-driven development process prevented architectural drift and ensured seamless data contracts between edge vision and backend dispatch.
Activity mode: Live app and editor with interactive companion app map.

## Revisions
*(No plan revisions required; the build strictly satisfied the approved PRD and technical specification).*
