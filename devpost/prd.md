---
doc: prd
status: approved
---

# Argus AI — Product Requirements

An autonomous spatial vision and threat interception platform for facility safety dispatchers and operational control rooms.  
*Source:* `scope.md > Who It's For`, `scope.md > The Unique Kernel`.

## The Core Journey
1. **Accessing the Console:** The operator opens the Argus Control Room in a browser or desktop client.
2. **Selecting a Facility Perspective:** The operator navigates to the active camera fleet and selects a designated monitored camera stream.
3. **Defining the Spatial Boundary:** The operator draws an arbitrary polygon directly over the video frame, defining a hazardous or restricted zone (e.g., "Crane Swing Perimeter" or "Subway Track Line").
4. **Arming the Safety Policy:** The operator selects or types a safety rule in plain English (e.g., *"If a person falls in Zone 1 for more than 4 seconds, trigger Critical Alert"*). The system compiles this into an active state machine.
5. **Real-Time Automated Interception:** A worker stumbles and collapses into the zone. Within $<100\text{ ms}$, the edge vision engine flags the fall posture, detects boundary penetration, and raises a Critical Incident.
6. **Tactical Response:** An alert tone sounds, the incident queue strobes in high-contrast crimson, and an escalation countdown timer begins.
7. **Resolution:** The operator clicks **Acknowledge**, which halts the automated escalation countdown, captures a forensic snapshot, and logs the response.

## Screens and Layout
The application features a dark-themed, high-density tactical layout divided into three core operational surfaces:

1. **Operations Hub & Camera Fleet:**
   * Grid view of connected camera feeds with live resolution, framerate, and operational health badges.
   * Quick-launch controls to open specific video channels.
2. **Interactive Live Monitor & Spatial Canvas:**
   * Central primary video player running at 60 FPS.
   * CanvasKit overlay rendering 33-point skeletal landmark joints, bounding boxes, and custom polygon zones.
   * Real-time kinematic telemetry sidebar: Fall Score ($0.0 - 1.0$), Aspect Ratio, Motionless Duration timer, and Active Rule status.
   * Interactive Zone Editor mode enabling polygon vertex placement and drag adjustment.
3. **Tactical Dispatch Room & Incident Queue:**
   * Priority-sorted feed of active unresolved alerts tagged by severity (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`).
   * Forensic evidence viewer with incident timestamp, camera ID, zone name, and captured snapshot.
   * One-click action controls: **Acknowledge**, **Resolve**, and **Mark False Positive**.

## Look and Feel
* **Palette:** Strict Pitch Black (`#000000`), Raised Charcoal (`#0A0A0A`), and High-Contrast Pure White (`#FFFFFF`).
* **Accents & Severity Scale:** Emerald Green (`#34D399`) for secure states, Amber (`#FBBF24`) for warnings, and Crimson Rose (`#F43F5E`) for critical life-safety alarms.
* **Typography:** Clean geometric sans-serif for headings (Sora / Inter) paired with high-legibility monospace fonts for coordinates, frame counters, and kinematic scores.
* **Density:** High information density, minimal decorative fluff, optimized for rapid situational awareness under stress.

## Features and Behavior

### 1. Edge Computer Vision & Pose Inference
* Runs on-device landmark inference processing 33 biomechanical joints at up to 60 FPS.
* Computes horizontal-to-vertical aspect ratios and vertical velocity vectors to score fall probability.
* Evaluates stillness timers: sustained low-motion horizontal states trigger confirmed medical alerts.

### 2. Arbitrary Polygon Spatial Geofencing
* Operators click on live video feeds to place custom polygon vertices.
* Executes ray-casting point-in-polygon tests on human foot and centroid coordinates.
* Instant visual feedback: zone borders glow translucent yellow on approach and turn solid crimson upon penetration.

### 3. Natural Language Safety Rule Studio
* Operators input plain-English policy sentences.
* The deterministic compiler extracts trigger conditions, signal types (`person_in_zone`, `fall`, `rapid_motion`), minimum confidence thresholds, and dwell times.
* Generates an immutable reactive rule object ready for evaluation.

### 4. Incident Management & Escalation Timers
* Incidents are automatically logged with unique IDs, camera sources, and timestamps.
* Each incident initiates an automated countdown timer.
* If an incident is not acknowledged within the required threshold, the state machine marks it for escalated emergency dispatch.

## States and Boundaries
* **Clean State:** Zero cameras or facilities initialized; clean onboarding prompt directing the operator to connect a feed or load demo scenarios.
* **Monitoring State:** Camera feed live, video stream active, skeletal landmarks tracking smoothly, zero active violations.
* **Active Alert State:** Immediate visual and acoustic alert; incident row flashes in dispatch queue; countdown timer counts down.
* **Acknowledged State:** Operator confirms awareness; escalation timer stops; incident marked with acknowledgment timestamp.
* **Resolved State:** Situation cleared; incident archived into historical audit log.

## Product Decisions
* **Client-Side Video Processing:** Video streams are analyzed locally on the edge client to prevent massive network bandwidth saturation and guarantee sub-100ms response times.
* **Shared Pure-Dart Domain Layer:** Geometric calculations, polygon algorithms, and rule evaluations are implemented in pure Dart, ensuring identical mathematical results across client and backend.
* **Assistive AI Philosophy:** The platform alerts and empowers human operators rather than making irreversible autonomous real-world actions without oversight.

## What We're Building (POC Scope)
* Complete end-to-end operational control room in Flutter.
* Real-time MediaPipe skeletal tracking and custom polygon collision detection.
* Live incident generation, countdown escalation, and acknowledgment.
* Demo test sequences verifying fall detection and zone incursion scenarios.

## Deferred From the POC
* Cloud multi-region server clustering.
* Integration with physical sirens and automated door actuators.
* Automated SMS/cellular broadcast alerts.

## Possible Later Enhancements
* Multi-camera trajectory tracking across complex facility campuses.
* Direct integration with enterprise thermal imaging sensors.

## Non-Goals
* General-purpose facial recognition or social identity scoring.
* High-latency cloud video encoding.

## Open Questions
* None blocking the proof-of-concept build; all technical interfaces are validated.
