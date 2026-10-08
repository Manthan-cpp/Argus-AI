# Argus 👁️ — Real-Time Assistive Safety Workflows for Cameras

> **Describe a safety rule in a sentence. Argus watches the camera, creates evidence-backed incidents, alerts the right person, and escalates if nobody responds.**

Built for **Build Something Real: The Serverpod Hackathon** (15 Sep – 14 Oct 2026).

---

## 🌟 Key Highlights

- **Natural Language Rule Studio:** Convert natural English rules into reactive safety automations with visual workflow DAG representations.
- **Privacy-by-Design On-Device Vision:** Uses client-side WebAssembly (MediaPipe) to track people and estimate body pose. Raw video **never** leaves the browser.
- **Serverpod 4 Backend Engine:**
  - Real-time **Streaming** incident downlink to supervisor consoles.
  - **Future Calls** orchestrating multi-stage escalation timeouts.
  - **Postgres ORM** with clean relational models and audit logging.
  - **File storage** for privacy-blurred evidence snapshots.
- **Detector Lab:** Transparent, honest precision/recall measurement on real test clips.
- **Zero Cost / No GPU required:** Runs smoothly on standard CPU hardware using open-source, non-AGPL models.

---

## 🏛️ Architecture

```
 BROWSER (Flutter Web + JS MediaPipe Vision)
   Flutter UI ──► Riverpod ──► ArgusRepository (Mock / Remote Serverpod)
   <video> (webcam | MP4 | demo clips) ──► vision module (JS)
        MediaPipe ObjectDetector + PoseLandmarker ──► tracker ──► geometry signals ──► SignalEvent batches
        snapshot() with head-blur ──► evidence upload (only when incident triggers)
                         │  typed Serverpod client (generated)       ▲ stream: IncidentUpdate
                         ▼                                           │
 SERVERPOD (argus_server)
   endpoints: rule · camera · zone · signal · incident · evidence · demo · health
   argus_engine (pure Dart): schema validation · grammar parser · rule state machines · escalation planner
   services: GeminiProxy (rate-limited + circuit breaker) · TelegramService · EvidenceService
   future calls: escalation steps · retention sweep
   Postgres: workspaces, cameras, zones, rules, incidents, audit log
```

---

## 📂 Repository Structure

```
Argus-AI/
├── argus/
│   ├── argus_engine/     # 100% pure Dart geometry, grammar compiler & rule state machine
│   ├── argus_server/     # Serverpod 4 backend (ORM models, migrations, endpoints, future calls)
│   ├── argus_client/     # Generated client library for Serverpod protocol
│   └── argus_flutter/    # Flutter control-room frontend (dark cyber theme, motion effects)
├── docs/                 # Architectural specifications, decisions, and methodology
├── scripts/              # Fast startup scripts for Windows, macOS, and Linux
├── LICENSE               # Apache 2.0 open-source license
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (≥ 3.24)
- Dart SDK (≥ 3.5)
- Serverpod CLI (`dart pub global activate serverpod_cli`)
- Google Chrome

### Running Locally

```bash
# 1. Start Serverpod backend
cd argus/argus_server
serverpod start --no-docker

# 2. Run Flutter Web client (in a new terminal)
cd ../argus_flutter
flutter run -d chrome
```

### 1-Click Launchers

For convenience on developer machines:
* **Windows:** Double-click `scripts/start_all.bat` (or run `scripts/start_server.bat` and `scripts/start_flutter.bat`).
* **macOS / Linux:** Run `bash scripts/start_server.sh` and `bash scripts/start_flutter.sh`.

---

## 🔒 Privacy & Disclosure

- **Assistive Tool Notice:** Argus is an assistive alerting tool, **not a certified life-safety system**.
- **No Face Recognition:** Argus does not identify individuals or retain biometric profiles. Evidence images blur human heads by default.
- **AI Disclosure:** Built with coding assistance from Google Antigravity. Rule translation and optional verification leverage Google Gemini API.

---

## 📄 License

Licensed under the [Apache License, Version 2.0](LICENSE).
