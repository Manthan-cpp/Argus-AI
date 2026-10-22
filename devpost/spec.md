---
doc: spec
status: approved
---

# Argus AI — Technical Spec

## How This Works, In Plain Language
Argus AI operates on a clean, distributed three-tier architecture:
1. **The Edge Vision Engine:** Ingests live video frames from IP cameras or local webcams. It uses a lightweight neural pose model to identify human joints (head, shoulders, hips, knees, ankles) and bounding boxes.
2. **The Spatial Geometry Engine:** Calculates whether a person's footpoint or centroid intersects with operator-drawn polygon zones on the screen using a ray-casting collision algorithm. At the same time, it evaluates posture angles and stillness to detect sudden falls.
3. **The Backend State Machine & Dispatch Room:** When a rule is broken, the edge client transmits a lightweight telemetry packet to the Dart backend server over WebSockets. The server persists the incident in PostgreSQL, starts an automated countdown timer, and broadcasts the event to all connected control room consoles. When an operator clicks acknowledge, the escalation timer is stopped and the event is recorded.

Why this shape: Performing computer vision on the client/edge avoids streaming gigabytes of raw video over the network. Only low-bandwidth structured signals (coordinates, bounding boxes, rule triggers) are transmitted to the server.

## The Core Journey Through the System
1. **Operator Opens Interface:** Flutter Web/Desktop initializes the application shell and establishes a persistent WebSocket connection to the Dart backend server.
2. **Zone Creation:** Operator clicks on the live camera viewport. The coordinates are normalized to $(x, y) \in [0.0, 1.0]$ and stored as an ordered polygon vertex list.
3. **Continuous Vision Loop:** Every frame ($16.6\text{ ms}$ at 60 FPS), MediaPipe pose estimation extracts 33 normalized landmarks.
4. **Local Evaluation:**
   * Aspect ratio = $\frac{\text{width}}{\text{height}}$. If aspect ratio $>1.8$ and vertical velocity changes rapidly, fall probability spikes.
   * Point-in-polygon ray-casting tests whether foot landmarks fall within any restricted zone polygon.
5. **Signal Dispatch:** When a condition meets the rule threshold, a `SignalBatch` JSON payload is sent over the WebSocket to `/signal/send`.
6. **Backend Processing:** The backend evaluates the batch against active `RuleSpec` definitions, creates an `Incident` in PostgreSQL, and schedules a persistent escalation timer.
7. **Operator Resolution:** The incident appears in the UI. Operator clicks **Acknowledge**, sending `/incident/acknowledge` to stop the timer.

## Stack
* **Frontend Framework:** Flutter 3.24+ (Web CanvasKit / Desktop).
* **Backend Runtime:** Pure Dart 3.5+ high-concurrency server.
* **Database & Persistence:** PostgreSQL with relational ORM and JSON serialization.
* **Computer Vision & Pose Inference:** MediaPipe Pose Landmark Estimation compiled for WebAssembly / Edge ML.
* **State Management:** Riverpod 2.6 for declarative, reactive UI data binding.
* **Routing:** GoRouter 14.8 for deep-linked tactical screens (`/monitor`, `/rules`, `/dispatch`, `/facilities`).
* **Design & Typography:** Google Fonts (Sora, Inter, JetBrains Mono) with custom monochrome design tokens.

## Where It Runs and How Someone Tries It
* **Runtime:** Web browser (Google Chrome with hardware acceleration) and local Dart backend process.
* **Prerequisites:** Flutter SDK $\ge 3.24$, Dart SDK $\ge 3.5$, PostgreSQL (or Docker Compose).
* **Execution Commands:**
  ```bash
  # 1. Start the Dart Backend Server
  cd argus/argus_server
  dart bin/main.dart

  # 2. Launch the Flutter Control Room
  cd argus/argus_flutter
  flutter run -d chrome --web-renderer canvaskit
  ```
* **One-Click Launch:** On Windows, double-click `scripts/start_all.bat`.

## Look and Feel
* **Theme:** Strict tactical dark palette. Pitch-black base (`#000000`), raised charcoal cards (`#0A0A0A`), and border strokes (`#262626`).
* **Accents:** Pure high-contrast white text (`#FFFFFF`) with functional state colors: Crimson (`#F43F5E`) for critical danger, Amber (`#FBBF24`) for warning, Emerald (`#34D399`) for safe.
* **Typography:** Sora for bold headers, Inter for readable UI text, and JetBrains Mono for coordinates, frame rates, and telemetry readouts.

## Components

### 1. `argus_engine` (Shared Domain Library)
* **Point-in-Polygon Evaluator:** Implements Jordan curve theorem ray-casting to evaluate arbitrary $N$-point convex and concave polygons.
* **Grammar & Rule Compiler:** Natural language AST lexer and parser transforming policy strings into typed rule triggers.
* **Kinematic Evaluator:** Analyzes skeletal aspect ratios, centroid displacement vectors, and motionless duration timers.

### 2. `argus_flutter` (Tactical Control Room UI)
* **`LiveMonitorScreen`:** CanvasKit video renderer with real-time skeletal overlays, interactive zone drawing tools, and telemetry HUD.
* **`ZonePolygonEditor`:** Interactive vertex editor allowing operators to create, edit, drag, and label custom zones.
* **`IncidentDispatchRoom`:** Real-time alert feed displaying priority cards, evidence images, and escalation countdown bars.
* **`NaturalLanguageRuleStudio`:** Interactive rule creator with instant syntactic feedback and AST visualization.

### 3. `argus_server` (Distributed Backend Engine)
* **`SignalEndpoint`:** High-throughput streaming endpoint ingesting client telemetry batches over WebSockets.
* **`IncidentEndpoint`:** CRUD operations for incident lifecycle (create, acknowledge, resolve, false-positive).
* **`EscalationWorker`:** Persistent background timers executing automated escalation chains if alerts go unacknowledged.

## Data Model
* **`Workspace` (Facility):** Represents a secure physical site with name, code, and role-based cryptographic keys.
* **`Camera`:** Represents a video feed stream with RTSP URL, location tag, and status.
* **`Zone`:** Stores camera ID, zone kind (`restricted`, `hazard`, `warning`), and ordered polygon vertex coordinates `List<PointN>`.
* **`RuleSpec`:** Defines trigger signal (`fall`, `person_in_zone`, `running`), target zone ID, min duration, and severity level.
* **`Incident`:** Records triggered rule, camera ID, severity, timestamp, evidence image snapshot, acknowledgment state, and resolution notes.

## File Structure
```
Argus-AI/
├── devpost/                    # Official Devpost planning & learning artifacts
│   ├── learner-profile.md      # Developer context & pacing interview
│   ├── scope.md                # Project kernel & POC boundary definition
│   ├── prd.md                  # Product requirements & user journeys
│   ├── spec.md                 # Technical blueprint & system architecture
│   ├── checklist.md            # Verified build slice checklist
│   └── app-map.html            # Interactive visual architecture diagram
├── argus/
│   ├── argus_engine/           # Shared pure-Dart geometry & rule AST parser
│   │   ├── lib/src/geometry/   # Ray-casting point-in-polygon algorithms
│   │   ├── lib/src/grammar/    # Natural language lexer & AST compiler
│   │   └── lib/src/rules/      # Kinematic state machine & rule evaluator
│   ├── argus_server/           # High-concurrency Dart backend service
│   │   ├── lib/src/endpoints/  # WebSockets & RPC endpoints
│   │   └── bin/main.dart       # Server entry point
│   ├── argus_client/           # Client communication protocol library
│   └── argus_flutter/          # Interactive tactical control room
│       ├── lib/app/            # App shell, routing & dark design tokens
│       ├── lib/features/       # Live monitor, zone editor, incident dispatch
│       └── web/                # CanvasKit web runner & MediaPipe assets
├── screenshots/                # System architecture diagrams & UI captures
├── scripts/                    # Cross-platform launch & setup scripts
└── README.md                   # Master repository documentation
```

## External Services and Dependencies
* **MediaPipe Pose ML:** On-device WebAssembly pose model for 33-point skeletal landmark detection (zero cloud API cost).
* **PostgreSQL:** Relational database storing facilities, cameras, zones, and audited incident records.
* **WebSockets:** Bi-directional event stream for real-time telemetry and instant alert downlinks.

## Important Failure Modes
* **Camera Stream Disconnection:** UI immediately flags camera card with `OFFLINE` amber indicator and attempts automatic reconnection with exponential backoff.
* **High Occlusion / Partial Body Detection:** Kinematic fall scorer requires minimum confidence ($>0.6$) across core hip and shoulder landmarks to prevent false positive fall alerts from seated workers.
* **Network Partition Between Edge and Server:** Edge client continues local visual alarming on the operator's display and buffers signals locally until the backend connection is restored.

## What Was Simplified and Why
* **Single-Camera Polygon Geofencing** instead of 3D multi-camera sensor fusion: Sized for a responsive, proof-of-concept demonstration that runs entirely in standard web browsers without specialized multi-camera calibration rigs.
* **Simulated & Pre-Recorded Industrial Video Streams** alongside live webcam feeds: Enables reproducible, deterministic evaluation of dangerous scenarios (falls, intrusions) without endangering real workers during testing.
