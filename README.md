<div align="center">

# 👁️ ARGUS AI
### *Autonomous Visual Threat Interception & Tactical Safety Workflows*
**Real-Time Computer Vision · Distributed Dart Backend Engine · Flutter Tactical Control Room**

[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Full--Stack%20Dart-purple?style=for-the-badge)](#-full-stack-dart--flutter-architecture)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

<br/>

![Argus AI](screenshots/TOP.png)

<br/>

> **"I OBSERVE. Every shadow. Every angle. At millisecond precision.**  
> **I EXECUTE. Active perimeter defense. Zero delay. Zero breach."**

---

</div>

## 📑 Quick Navigation
[The Problem](#-the-problem-the-tragic-reality-of-modern-cctv) • [The Solution](#-the-solution-machine-speed-threat-interception) • [Threat Matrix](#-god-tier-threat-detection-matrix) • [Full-Stack Architecture](#-full-stack-dart--flutter-architecture) • [System Workflow](#-end-to-end-system-workflow) • [Control Room Showcase](#-interactive-control-room-showcase) • [Quick Start](#-quick-start)

---

## 🛑 The Problem: The Tragic Reality of Modern CCTV

Over **1 billion surveillance cameras** watch the planet today. Trillions of dollars have been poured into optics, wiring, and storage. Yet, practically every single camera deployed is nothing more than a **passive digital gravestone**.

Traditional security infrastructure suffers from three catastrophic failures:

```
┌────────────────────────────────────────────────────────────────────────┐
│                      THE PASSIVE MONITORING PARADOX                    │
├──────────────────────────┬─────────────────────────────────────────────┤
│ 1. The Post-Mortem Flaw  │ CCTV only records tragedies—it never stops  │
│                          │ them. It helps police write incident        │
│                          │ reports after the damage is already done.   │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 2. Human Fatigue Limit   │ Studies prove that after just 20 minutes    │
│                          │ of watching multiple screens, security      │
│                          │ guards miss up to 95% of critical threats.  │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 3. Fatal Response Lag    │ In an active breach, industrial fall, or    │
│                          │ weapon threat, seconds determine life and   │
│                          │ death. Manual human dispatches take minutes.│
└──────────────────────────┴─────────────────────────────────────────────┘
```

When a lone factory technician collapses into heavy machinery, when an unauthorized masked intruder breaches a high-security vault, or when a commuter slips onto electrified transit tracks—**nobody is looking at the right screen at the right second.** The cameras record the catastrophe in flawless 4K, completely powerless to intervene.

---

## ⚡ The Solution: Machine-Speed Threat Interception

**Argus AI redefines surveillance from passive recording to autonomous, active defense.**

By unifying high-performance on-device computer vision with the raw distributed power of **a high-concurrency Dart backend engine**, Argus transforms dumb video streams into living, thinking security sentinels that reason in sub-seconds and take instant real-world action.

![Autonomous Execution](screenshots/autonomous_execution.png)

### 🌍 Real-Life High-Stakes Scenarios

#### 1. The Lone Worker Industrial Collapse (Zero-Delay Medical Dispatch)
* **Scenario:** A worker collapses in a remote manufacturing wing due to toxic fume inhalation or electrical shock.
* **Argus Action:** 33-point biomechanical skeletal tracking detects horizontal posture (`FALL SCORE: 85%`) and tracks motionless duration. At exactly $4.8$ seconds of immobility, Argus triggers a Critical Medical Emergency, fires localized audio beacons, unlocks emergency perimeter gates, and streams live telemetry to first responders.

#### 2. Critical Transit Perimeter Breach & Track Fall (Metro Platform)
* **Scenario:** A passenger stumbles or deliberately crosses past the yellow caution line into the high-voltage track zone.
* **Argus Action:** Real-time sub-pixel spatial polygon geofencing identifies human body centroid penetration in <35ms. The distributed Dart engine immediately signals rail switchboard systems, halts approaching automated trains, and blasts targeted directional alarms.

#### 3. Armed Vault Breach & Masked Infiltration (Bank / Sovereign Site)
* **Scenario:** An unauthorized group wearing facial concealment and brandishing tactical weapons enters a restricted financial repository after hours.
* **Argus Action:** Face concealment detection flags masked intruders, while neural object detectors identify drawn firearms. The backend state machine immediately seals motorized magnetic airlocks, trips silent police alarms, and dispatches encrypted multi-angle incident bundles to SWAT command rooms.

#### 4. Hazardous Industrial PPE Non-Compliance (Construction & Energy)
* **Scenario:** A subcontractor enters a high-risk crane swing perimeter without a hardhat or high-visibility vest.
* **Argus Action:** Real-time PPE inspection verifies worker equipment upon entering the spatial zone. The crane’s power circuit is safely interlocked until the operator verifies the zone is clear.

---

## 🎯 Target Audience & Verticals
* 🏭 **Industrial & Warehouses:** Worker fall detection, OSHA/PPE compliance, and heavy machinery hazard zones.
* 🚆 **Transit Hubs (Airports, Metros):** Track intrusion prevention, platform boundary violations, and crowd stampede intervention.
* 🏥 **Healthcare & Senior Care:** Immediate slip/fall alerts and patient wandering monitoring with strict zero-biometric privacy.
* 🏦 **High-Security Facilities & Data Centers:** Vault access control, anti-tailgating verification, and off-hour breach interception.

---

## 🥋 God-Tier Threat Detection Matrix

Argus AI features an end-to-end vision sensory matrix executing complex spatial, temporal, and kinematic rules at 60 FPS:

```
 ┌───────────────────────────┬───────────────────────────┬───────────────────────────┐
 │ 🦺 PPE Compliance         │ 𥷮 Concealed Identity     │ 🔫 Weapon & Threat        │
 │ Hardhats, high-vis vests, │ Balaclavas, ski masks,    │ Firearms, long guns,      │
 │ safety goggles, gloves.   │ unauthorized coverings.   │ bladed tactical threats.  │
 ├───────────────────────────┼───────────────────────────┼───────────────────────────┤
 │ 🤸 33-Point Pose / Falls  │ 🏃 Panic & Stampede       │ 📐 Sub-Pixel Geofencing   │
 │ Biomechanical joint slip, │ Instant velocity vectors, │ Arbitrary N-point spatial │
 │ fall scoring, immobility. │ crowd surge & stampede.   │ polygon intrusion zones.  │
 ├───────────────────────────┼───────────────────────────┼───────────────────────────┤
 │ 🧳 Abandoned Luggage      │ ⏳ Loitering & Stalking   │ 🚪 Tailgating & Direction │
 │ Unattended bags, packages,│ Prolonged dwell time in   │ Counter-flow detection,   │
 │ perimeter drops.          │ sensitive access sectors. │ piggybacking airlocks.    │
 └───────────────────────────┴───────────────────────────┴───────────────────────────┘
```

> **Plain-English Rule Studio:** Operators formulate safety policies in conversational English (*"If a person falls and stays down > 4s, trigger emergency alarm"*). Argus compiles this via a deterministic grammar parser into an immutable reactive state machine.

---

## 🚀 Full-Stack Dart & Flutter Architecture

Argus AI unifies client and server in **100% pure Dart**, eliminating serialization overhead, language barriers, and impedance mismatches:

* **⚡ Ultra-High Concurrency Streaming WebSockets:** Ingests live telemetry, 33-point skeletal vectors, and bounding box batches with sub-35ms WebSocket incident downlink.
* **⏱️ Persistent Escalation State Machines:** Multi-tier countdown escalation chains persist across restarts:
  $$\text{Incident Triggered} \xrightarrow{15s} \text{Supervisor Ping} \xrightarrow{30s} \text{Facility Alarm} \xrightarrow{60s} \text{Autonomous 911 Dispatch}$$
* **📦 Shared Domain Engine (`argus_engine`):** Jordan curve theorem ray-casting math, rule ASTs, and grammar parsers run identically on client and server with compile-time type safety.
* **🛡️ Multi-Tenant Cryptographic Isolation:** PostgreSQL ORM with role-based cryptographic invite codes (`ORGANIZER`, `SUPERVISOR`, `GUARD`) and immutable audit logs.
* **🤖 Multimodal AI Verification:** Zero-latency snapshot verification pipelines feeding privacy-preserved frames to Google Gemini for secondary confirmation before sirens sound.

---

## 🔄 End-to-End System Workflow

```mermaid
sequenceDiagram
    autonumber
    participant Camera as 📹 IP Camera / CCTV
    participant Edge as 🧠 Flutter Edge Vision (MediaPipe)
    participant Server as ⚡ Distributed Dart Backend Engine
    participant Postgres as 🗄️ PostgreSQL Database
    participant AI as 🤖 Gemini Multimodal AI
    participant SOC as 🛡️ Tactical Dispatch Console

    Camera->>Edge: 60 FPS Video Stream
    Edge->>Edge: On-Device 33-Pt Pose & Geometry Collision
    Edge->>Server: Ingest Telemetry Stream via Binary WebSockets
    Server->>Server: Pure-Dart Grammar Rule Evaluation
    alt Safety Rule Violated (e.g. Fall / Track Breach)
        Server->>Postgres: Persist Incident & Evidence Snapshot
        Server->>AI: Trigger Asynchronous Multimodal Verification
        Server->>Server: Schedule Persistent Escalation Timer
        Server-->>SOC: Broadcast Real-Time WebSocket Incident Stream
        SOC->>SOC: Trigger Visual Alarm & Strobe Banner
        alt Guard Acknowledges within 30s
            SOC->>Server: Resolve / Acknowledge Incident
            Server->>Server: Cancel Escalation Timer
        else Guard Misses Incident
            Server->>Server: Timer Fires -> Escalate to 911 & Sound Siren
        end
    end
```

---

## 📸 Interactive Control Room Showcase

<div align="center">

| Tactical Operations Hub | Interactive Spatial Geofencing |
| :---: | :---: |
| <img src="screenshots/connected_cameras.png" width="460" alt="Connected Camera Fleet" /><br/><sub><b>Connected Camera Fleet & RTSP Hub</b> — Real-time multi-feed surveillance matrix</sub> | <img src="screenshots/zone_polygon_editor.png" width="460" alt="Polygon Zone Editor" /><br/><sub><b>CanvasKit Polygon Zone Editor</b> — Click-and-drag sub-pixel vertex boundaries</sub> |
| **Biomechanical Fall & Pose Scoring** | **Critical Perimeter Breach Detection** |
| <img src="screenshots/fall_and_stampede.png" width="460" alt="Fall & Pose Tracking" /><br/><sub><b>33-Pt Skeletal Pose Tracking</b> — Real-time kinematic fall scoring ($w/h > 1.8$) at 60 FPS</sub> | <img src="screenshots/live_monitor_telemetry.png" width="460" alt="Live Monitor Telemetry" /><br/><sub><b>Perimeter Violation & Track Intrusion</b> — Sub-35ms centroid boundary collision</sub> |
| **Natural Language Rule Studio** | **Multi-Tenant Facility Command** |
| <img src="screenshots/natural_language_rules.png" width="460" alt="Natural Language Rules" /><br/><sub><b>Natural Language Policy Compiler</b> — Converts plain English into reactive rules</sub> | <img src="screenshots/facility_command.png" width="460" alt="Facility Command" /><br/><sub><b>Multi-Tenant Facility Command</b> — Role-based security access control</sub> |

</div>

---

## 🗺️ Production Scaling Roadmap

| System Pillar | Architecture Milestone | Impact & Scale |
| :--- | :--- | :--- |
| **Edge Ingestion** | **Global RTSP / ONVIF Gateway:** Binary WebSockets ingesting raw video streams directly into memory | **10,000+ Concurrent Streams** with sub-35ms pipeline latency |
| **Cross-Camera Memory** | **Distributed Re-Identification:** Redis cluster + PostgreSQL `pgvector` for instant entity tracking | **1M+ Events Searched in <100ms** across 500+ facility cameras |
| **Incident Automation** | **Zero-Human Dispatch:** Persistent task timers, automated 911 packets, and physical airlock locks | **<3 Second Response** with multi-angle verified AI telemetry |
| **Sovereign Mesh** | **Federated Clustered Dart Mesh:** Zero-trust multi-region deployment with hardware-level encryption | **99.999% SLA** monitoring 500,000+ edge endpoints nationwide |

---

## 🛠️ Quick Start

### 1. Launch Backend Server
```bash
cd argus/argus_server
docker compose up -d    # (Optional) Postgres & Redis containers
dart bin/main.dart      # Boots on port 8080 (WebSockets) and 8082 (Web)
```

### 2. Launch Tactical Control Room
```bash
cd argus/argus_flutter
flutter pub get
flutter run -d chrome --web-renderer canvaskit
```
*Quick launchers available: `scripts/start_all.bat` (Windows) or `bash scripts/start_server.sh` (macOS/Linux).*

---

## 📂 Repository Structure

```
Argus-AI/
├── argus/
│   ├── argus_engine/       # Pure-Dart core: geometric ray-casting, rule AST & grammar compiler
│   ├── argus_server/       # High-performance Dart backend: streaming endpoints, escalation workers
│   ├── argus_client/       # Type-safe client protocol library
│   └── argus_flutter/      # Tactical control room UI (CanvasKit, Riverpod, Cyber theme)
├── devpost/                # Devpost Learn specification suite (scope, PRD, spec, checklist, app-map)
├── screenshots/            # UI captures & system architecture graphics
└── scripts/                # Instant launch scripts (Windows, macOS, Linux)
```

---

## 🔒 Privacy, License & Community

* **Privacy-by-Design:** Facial biometric profiling is explicitly omitted. Evidence snapshots apply automated algorithmic blurring to human heads to preserve worker privacy.
* **Assistive Safety Notice:** Argus AI is an assistive decision-support platform designed to augment security personnel and first responders.
* **License:** Licensed under the [MIT License](LICENSE). Contributions welcome via our [Contributing Guide](CONTRIBUTING.md).
* **Acknowledgments:** Built with the Dart & Flutter teams (CanvasKit engine) and Google MediaPipe / Gemini.

<div align="center">
<br/>
<b>👁️ ARGUS AI — Vision That Never Blinks. Protection That Never Sleeps.</b>
</div>
