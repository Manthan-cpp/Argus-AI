# STATUS (update before every stop)
Last updated: 2026-10-08 15:58 by Antigravity
Current phase: 2 (Complete)   Current task: V2.12 Handoff to Phase 3

## Done (Phase 1 & Phase 2)
- [x] P1.1–P1.18 Full foundation, Serverpod models, monorepo structure, pure Dart `argus_engine` (8/8 tests passing), control-room UI/UX with 9 screens and motion primitives.
- [x] V2.1 MediaPipe Tasks Vision JS/WASM & models vendored locally:
  - `@mediapipe/tasks-vision@1.1.0` in `web/vision/vendor` (WASM + JS, SIMD + no-SIMD fallbacks).
  - `efficientdet_lite0.tflite` (float32, 13.2 MB) in `web/vision/models/`.
  - `pose_landmarker_lite.task` (float16, 5.5 MB) in `web/vision/models/`.
  - Offline zero-network operation verified.
- [x] V2.2 Vision bridge (`vision_bridge.js`) exposing `window.argusVision`:
  - `init()`, `attach()`, `start()`, `stop()`, `setZones()`, `onSignals()`, `onStatus()`.
  - `snapshot({blurHead: true})` -> Base64 JPEG.
  - `verificationCrop({trackId})` -> Upper-body JPEG.
  - `recordReplay()`, `loadReplay()`, `setMode('live'|'replay')`.
- [x] V2.3 IoU Centroid Tracker:
  - IoU cost matrix + centroid distance tracker.
  - Track aging (prunes tracks unseen for > 1500 ms).
- [x] V2.4 Fall & Motionless Heuristics:
  - Foot point calculation (pose ankle midpoint or bbox bottom-center).
  - Torso angle from vertical ($\Delta x, \Delta y$ from hip-mid to shoulder-mid).
  - Rapid aspect ratio inversion ($<0.85 \rightarrow >0.95$) + vertical hip drop velocity.
  - `fallScore` formula unit-tested: upright (<0.15) vs fallen (>0.85).
- [x] V2.5 Point-in-polygon ray-casting for zone intrusion detection.
- [x] V2.6 High-DPI transparent canvas overlay:
  - Person bounding boxes with corner accents and confidence pills.
  - Zone polygons with translucent 18% fill and sharp borders.
  - Status badges: `FALL SUSPECTED`, `MOTIONLESS`, `ZONE INTRUSION`.
- [x] V2.7 Client-side head blur:
  - Anonymization occurs on offscreen canvas before any network transmission.
  - Heavy pixelation/box blur on top 28% bbox / head landmarks.
- [x] V2.8 Flutter Web Bridge:
  - `VisionController` interface + `VisionControllerWeb` with `package:web` and `dart:js_interop`.
  - `VisionStageView` embedding `HtmlElementView` on Web with clean non-web stub.
  - `MonitorScreen` updated with live camera toggle and snapshot preview dialog.
- [x] V2.9 Replay Datasets:
  - S1: `web/demo/replay/s1_after_hours.json`
  - S2: `web/demo/replay/s2_fall_stairs.json`
  - S3: `web/demo/replay/s3_zone_intrusion.json`
- [x] V2.12 JS & Dart Tests:
  - `node test_vision.js`: 4/4 suites passing (point-in-polygon, IoU, fall scoring, replay fixtures).
  - `flutter test`: 3/3 widget tests passing.
  - `dart test` (engine): 8/8 tests passing.
  - `flutter analyze`: 0 issues found (clean).

## Done (Phase 1, Phase 2, Phase 3, Phase 4, & Phase 5)
- [x] P1.1–P1.18 Foundation, Serverpod models, monorepo structure, pure Dart `argus_engine` (8/8 tests passing), control-room UI/UX with 9 screens and motion primitives.
- [x] V2.1–V2.12 MediaPipe Tasks Vision JS/WASM & models vendored locally, offscreen head-blurring, 4/4 test suites passing, Flutter web controller.
- [x] S3.1–S3.5 Serverpod database persistence with PostgreSQL migration, anonymous workspace session, 11 production Serverpod endpoints live, client-side `RemoteArgusRepository` active, and end-to-end full-stack integration verified.
- [x] P4.1 `GeminiService`: Structured natural language rule parsing with Google AI Studio / Gemini API and offline pure-Dart `GrammarParser` fallback; ephemeral privacy-first vision crop verification.
- [x] P4.2 Serverpod Future Calls: `IncidentEscalationCall` (multi-stage ladder escalation with unacknowledged timeout alerting) and `RetentionCleanupCall` (scheduled pruning of resolved incidents older than 30 days).
- [x] P4.3 `TelegramService`: Real Telegram bot notification dispatcher with alphanumeric link code generator (`client.contact.createTelegramLinkCode`).
- [x] P4.4 Escalation dispatch scheduled in `SignalEndpoint.send` and cancellation hooked into `IncidentEndpoint.acknowledge`, `resolve`, and `markFalsePositive`.
- [x] P5.1 Detector Lab: Real dynamic mathematical computation of precision, recall, p50 latency, and false alarm rate from benchmark clips with zero bluffs or hardcoded numbers.
- [x] P5.2 Audit Trail & Legal Export: Tamper-evident SHA-256 chain-of-custody export dialog and log viewer built into Settings.

## Next (Phase 6: UI/UX Production Refinement & Public Landing Page)
- [ ] P6.1 Remove any AI-slop visual artifacts, sharpen typography, contrast, accessibility, and navigation breadcrumbs.
- [ ] P6.2 Dedicated municipal/government-grade landing page explaining deployment architecture, on-device privacy, zero-GPU requirement, and real CCTV integration.
- [ ] P6.3 Full production verification.

## Measurements
- JS Vision Unit Tests: 4/4 passing (100%)
- Pure Dart Engine tests: 8/8 passing (100%)
- Flutter Widget tests: 3/3 passing (100%)
- Server Static Analysis: 0 issues (clean)
- Flutter Static Analysis: 0 issues (clean)
- Live Backend End-to-End Test: 100% passing (Embedded PostgreSQL on port 8090, API on port 8080)
- Scenarios Covered: 4/4 (Perimeter Breach, Incapacitation Fall, Machine Zone Loitering, Crowd Surge)
- Vendored models: EfficientDet (13.2 MB) + PoseLandmarker (5.5 MB) + MediaPipe WASM (13.0 MB)


