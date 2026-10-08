# Argus 👁️ — Real-Time Assistive Safety Workflows for Cameras

> **Describe a safety rule in a sentence. Argus watches the camera, creates evidence-backed incidents, alerts the right person, and escalates if nobody responds.**

Built for **Build Something Real: The Serverpod Hackathon** (15 Sep – 14 Oct 2026).

---

## 🌟 Key Highlights

- **Natural Language Rule Studio:** Convert natural English rules into reactive safety automations with visual workflow DAG representations.
- **Privacy-by-Design on-device Vision:** Uses client-side WebAssembly (MediaPipe) to track people and estimate body pose. Raw video **never** leaves the browser.
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

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (≥ 3.24)
- Dart SDK (≥ 3.5)
- Serverpod CLI (`dart pub global activate serverpod_cli`)
- Google Chrome

### Running Locally

```bash
# 1. Start Serverpod backend
cd argus_server
serverpod start

# 2. Run Flutter Web client
cd ../argus_flutter
flutter run -d chrome
```

---

## 🔒 Privacy & Disclosure

- **Assistive Tool Notice:** Argus is an assistive alerting tool, **not a certified life-safety system**.
- **No Face Recognition:** Argus does not identify individuals or retain biometric profiles. Evidence images blur human heads by default.
- **AI Disclosure:** Built with coding assistance from Google Antigravity. Rule translation and optional verification leverage Google Gemini API.
