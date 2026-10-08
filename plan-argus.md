# ARGUS — Master Build Plan (`plan.md`)

> **Argus** turns an ordinary camera into a safety workflow. A user writes a safety rule in a sentence; the browser detects people and body pose locally; a Serverpod backend evaluates the rule, creates an incident with evidence, alerts the right person, and escalates if nobody responds.
> Built first for **Build Something Real: The Serverpod Hackathon**; designed to be reusable for other hackathons.
> Stack: **Serverpod 4 (Dart backend) + Flutter web + a small JavaScript vision module (MediaPipe)**. Free tiers only. Optional LLM help from the **Gemini API free tier**, always behind a server-side proxy with fallbacks.

**Document version:** 1.0 · **Written:** 2026-10-08 · **Owner:** Manthan (solo) · **Hard deadline:** 14 Oct 2026, 23:59 CEST (no extensions; judging 15–20 Oct; winners 22 Oct)
**Companion docs:** `docs/goal.md` (written after the owner's review of this plan) · `docs/STATUS.md` · `docs/DECISIONS.md` · `docs/HACKATHONS.md` · `docs/DEPENDENCIES.md` · `docs/METHODOLOGY.md` · `docs/SUBMISSION.md` · `docs/FEEDBACK.md`

---

## 0. HOW ANY AI AGENT MUST USE THIS DOCUMENT (read first)

This file is the single source of truth. Any AI coding agent, in any session, must be able to pick up **any phase** without prior chat history.

### 0.1 Resume protocol
1. Read sections **0–8** (rules, product, stack, architecture, contracts, specs). They apply to every phase.
2. Open `docs/STATUS.md` (create it from Appendix A if missing). It says what is done, in progress, blocked.
3. Read **only your target phase** (sections 9–14) and the *Handoff* block of the previous phase.
4. Do tasks in order. Every task has acceptance criteria. Write tests with the code.
5. If you must change a contract (sections 7–8) or a decision, update **this file** and append to `docs/DECISIONS.md` in the same change.
6. Before stopping: update `docs/STATUS.md` (done / next / known issues / exact run commands / measurements).

### 0.2 Non-negotiable rules for every agent
- **Never fake detections or results in production paths.** Mock data lives only in `argus_flutter/lib/data/mock/` and test fixtures, and the UI shows a visible `MOCK DATA` badge whenever mock mode is active. "Replay mode" (section 8.7) is allowed only because it replays *real recorded detector output* and is labelled as such.
- **Be honest in UI, README and video:** Argus is an *assistive alerting tool*, **not a certified safety system**. Detection is heuristic and imperfect. Show confidence and "unverified" states. Publish measured accuracy on our own test clips (Detector Lab, section 12).
- **LLM use is optional, bounded and server-side.** The Gemini API key lives only in the server's gitignored `config/passwords.yaml`. Never expose it to the browser. The LLM is called **only** (a) when a user interprets a rule sentence and (b) when an incident triggers and verification is enabled — **never per video frame**. Every LLM path has a non-LLM fallback.
- **Do not evade API quotas.** Gemini quotas are per Google Cloud *project*, not per key; creating many keys does not help, and creating many projects/accounts to dodge limits is quota evasion that can breach the API terms. The hackathon rules require third-party APIs to be used in accordance with their terms. Use one project, a rate limiter, caching, a circuit breaker, and graceful fallback.
- **No face recognition. No biometric identification.** Ever. Evidence stored by the server has the head region blurred by default.
- **Originality:** write all code in this repo yourself. **Do not copy code from Cameron or any other project** (the Cameron GitHub link on Devpost returned 404, so no license is visible; the concept — natural-language rule → camera detection → real-world action — is free to reimplement). Third-party packages/models are allowed if licence-compatible and recorded in `docs/DEPENDENCIES.md`. **Avoid AGPL-licensed detector weights (e.g. YOLOv8-derived)** unless the owner explicitly accepts AGPL obligations.
- **Zero cost.** Only free tiers/open source. No secrets in git.
- **Disclose AI assistance** in the README and submission text (hackathon rule).
- **Serverpod syntax must be verified, not recalled.** Serverpod 4 ships agent skills and an MCP server with projects created by `serverpod quickstart`; use them and https://docs.serverpod.dev for exact model/endpoint/auth/streaming/file-upload syntax. Code sketches in this file are *illustrative*.

### 0.3 Definition of Done (every task)
Compiles; `dart analyze` / `flutter analyze` clean; tests written and passing; no hard-coded colours/strings outside the token/copy layers (UI tasks); no secrets; `docs/STATUS.md` updated.

---

## 1. PRODUCT

### 1.1 One-liner and pitch
"Describe a safety rule in a sentence. Argus watches the camera, creates evidence-backed incidents, alerts the right person, and escalates if nobody responds."

Pitch (judges): *Cameras already observe, but they don't understand what an organisation wants to prevent. Argus lets a supervisor describe a rule in plain language, turns it into a visible workflow, detects the event on-device, preserves blurred evidence, and drives the response — with a Serverpod backend doing the rules, incidents, escalation and live updates.*

### 1.2 The problem and the user (hackathon "Usefulness" criterion)
- **User:** a safety/site supervisor at a small organisation — care home, campus lab, workshop, construction site, warehouse — who has cameras but nobody watching them.
- **Problem:** incidents (a person falls and stays down, someone enters a restricted area after hours, a worker enters a hazard zone) are noticed late or never. Falls alone are the second leading cause of unintentional injury deaths worldwide (~684,000 fatal falls per year; over 80% in low- and middle-income countries; highest rates in adults over 60), per the WHO falls fact sheet (https://www.who.int/news-room/fact-sheets/detail/falls). Faster notice and escalation matter.
- **Why now / why this way:** on-device detection (no cloud video), plain-language rules, and a transparent incident workflow — no custom development or expensive systems.
- *Scope honesty:* we address **assistive alerting**, not guaranteed prevention. We have **not** researched sector-specific statistics beyond the WHO fall data; add sources to `docs/METHODOLOGY.md` if more are used.

### 1.3 Demo scenarios (build and film these four; each is a real, repeatable clip)
| ID | Scenario | Signals used | Rule sentence (example) |
|---|---|---|---|
| S1 | After-hours lab entry | person-in-zone + time window | "If anyone enters the lab after 8 pm, take a snapshot and alert the supervisor." |
| S2 | Fall near stairs + not getting up | fall_suspected + motionless | "If someone falls near the staircase and stays down for 20 seconds, alert security and escalate after 2 minutes." |
| S3 | Restricted zone intrusion | person-in-zone + dwell time | "If a person stays in the red zone for more than 5 seconds, create a high-severity incident." |
| S4 *(stretch)* | Helmet missing in work zone | person-in-zone + head-crop verification | "If a person in the work zone isn't wearing a helmet, save evidence and alert the site manager." |

### 1.4 Parity with Cameron (concept-level only) and Argus additions
| Cameron (public Devpost description) | Argus |
|---|---|
| Natural-language rule → visual workflow | **Rule Studio**: sentence → structured rule (Gemini → grammar parser → form builder fallback) shown as an editable visual workflow |
| Browser-side object detection + video analysis | **Vision module**: MediaPipe person detection + pose in the browser; geometry signals; optional server-side Gemini vision check on trigger only |
| Email / SMS / voice / push alerts | In-app live feed, browser notifications, optional Telegram bot (free). No SMS/voice (cost) |
| Workflow logs | **Incident timeline + audit log** |
| Everything in the browser/localStorage | **Serverpod backend**: Postgres, rule engine, streaming, escalation, retention |
| *(additions)* | **Detector Lab** (measured accuracy on our own clips), **replay mode**, **privacy by design** (local detection, head-blur evidence, opt-in cloud verification), **escalation policies**, **false-positive feedback loop** |

### 1.5 What Argus will NOT do (state this in the app and README)
Free-form unrestricted natural-language rules (only supported patterns); reliable helmet detection without verification; multi-camera scale; face recognition; certified safety guarantees; video storage (only short-lived snapshots).

---

## 2. HACKATHON RULES THAT CONSTRAIN DESIGN (from the Official Rules; the PDF on BuilderBase is authoritative)

- **Serverpod must be the backend**; the Project must be a working full-stack app built on the Serverpod stack. No tracks.
- **New Projects Only:** newly created **during 15 Sep 2026 17:30 – 14 Oct 2026 23:59 CEST**, and original work of the entrant. No reuse of prior projects (e.g. SignSpeak).
- **Third-party integrations** (SDKs, APIs, data, models) must be used in accordance with their terms/licences.
- **AI coding tools allowed and encouraged — must be disclosed** in the text description.
- **Submission requires:** repo URL (private repo created under Serverpod's GitHub org by the hackathon site, **or** own private repo shared with `viktor@serverpod.dev`, `alexander@serverpod.dev`, `isak@serverpod.dev`); text description (features, functionality, how it was built); build/run instructions; **demo video < 2 minutes** on public YouTube/Vimeo showing the app on its target device, no third-party trademarks or copyrighted music.
- **Testing access:** a working project (website link, functioning demo, or test build) must be accessible, free of charge, through the end of judging (20 Oct). If private, include credentials. Judges may judge from description + video alone.
- **Judging (weights):** Does it work **30%** (core flow completes, nothing critical faked) · Use of the Serverpod stack **25%** (real work, not a static page) · Craft & technical creativity **25%** (rough fine, careless not) · Usefulness **20%** (clear user, clear problem). Stage 1 pass/fail: fits theme + reasonable use of Serverpod. Presentation quality is not scored separately.
- **Multiple submissions** by one entrant must be substantially different from each other.
- **Optional prizes:** Most Valuable Feedback ($500 cash + $500 credits; needs the feedback form during the period; actionable Serverpod feedback) and Best Hackathon Post (public post identifying the hackathon). Rules questions: nate@builderbase.com.

**Design consequences:** the golden path must work with **zero login**; Serverpod features must visibly do real work (streaming, DB, future calls, file storage, auth, web hosting); the app must be polished; accuracy claims must be measured and honest.

### 2.1 Reuse across other hackathons
Each other hackathon has its own rules (often "new project during the event", originality, allowed tech). Before submitting elsewhere, record its rules in `docs/HACKATHONS.md` (name, dates, new-project rule, required tech, submission needs, status). Keep the project **modular** so variants are possible: the JS vision module, the rule schema, and the pure-Dart `argus_engine` are backend-agnostic; only the endpoints/ORM glue is Serverpod-specific. Do not assume a project built for this hackathon is eligible elsewhere.

---

## 3. TECH STACK AND ENVIRONMENT

| Layer | Choice | Notes |
|---|---|---|
| Backend | **Serverpod 4.x** (Dart) | Needs Flutter ≥ 3.44.4 / Dart 3.12.2 per the quickstart. Install: `dart install serverpod_cli`; create: `serverpod quickstart argus` (choose coding agent so skills/MCP are installed); dev: `serverpod start` (embedded Postgres, hot reload); `serverpod generate`; `serverpod create-migration`; deploy: `serverpod cloud launch` |
| Frontend | **Flutter web** (Chrome) | Web is the demo target. Do **not** install Android Studio/SDK. Dev machine is Windows (App Studio is a macOS beta — use the CLI) |
| Vision | **JavaScript module** using **MediaPipe Tasks Vision** (WASM, runs on CPU/WebGL in the browser) | Object Detector (EfficientDet-Lite0, COCO 80 classes incl. *person*, Apache 2.0; 320×320 input; int8 variant listed at ~29 ms CPU on Google's benchmark device) + Pose Landmarker (lite). Models and WASM bundled as static assets (no runtime dependency on third-party hosting). **No GPU required** |
| Realtime | Serverpod **streaming methods** for the dashboard feed (downlink). Signal **uplink uses batched unary calls** (robust) — upgrade to streaming only if time allows | If the socket drops, streams close on both sides → client must reconnect and resume |
| Long jobs/timers | Serverpod **future calls** | Escalation timers, async verification, Telegram dispatch, retention sweep |
| DB | Postgres (embedded in dev; Serverpod Cloud DB in prod) | |
| Files | Serverpod **file uploads**; default storage is the database | Default request size limit means large files are rejected even if `maxFileSize` is larger — evidence snapshots must stay small (≤ ~200 KB JPEG); never upload video |
| Auth | Serverpod auth, **anonymous guest** by default | No login wall. Verify setup in docs/skills |
| LLM (optional) | **Gemini API free tier** via server proxy | Free tier: limits are per project and model (≈5–15 requests/min for text models as of 2026 — confirm in AI Studio); no SLA; **free-tier prompts/outputs may be reviewed by humans and used to train Google products** → people images are sent only with explicit opt-in. Configure the model name in `config/` (do not hard-code; models change) |
| Alerts | In-app stream; Browser Notifications API; optional **Telegram Bot API** (free) | No SMS/voice/email in MVP |
| State mgmt | `flutter_riverpod` · routing `go_router` · charts `fl_chart` · animation `flutter_animate` | |
| JS ↔ Flutter | `dart:js_interop` + `HtmlElementView` (host `<video>` and overlay `<canvas>`); the JS module exposes `window.argusVision` | See section 8.2 |
| Hosting | **Serverpod Cloud** (free one-month trial, no card; $5/mo Starter after) — create so the trial covers through 22 Oct 2026. Serves API + Flutter web build | CPU/RAM/DB limits unknown until tested (measure early) |
| Fonts | Sora (display), Inter (body), JetBrains Mono (mono), bundled | |

---

## 4. ARCHITECTURE

```
 BROWSER (Flutter web + JS vision module)
   Flutter UI ──► Riverpod ──► ArgusRepository (interface)
                                 ├─ MockArgusRepository   (Phase 1 only)
                                 └─ RemoteArgusRepository (Phase 3+, uses argus_client)
   <video> (webcam | MP4 | demo clip) ──► vision module (JS)
        MediaPipe ObjectDetector + PoseLandmarker ──► tracker ──► geometry signals ──► SignalEvent batches (every ~500 ms, state changes + 2 s heartbeat)
        snapshot() with head-blur ──► evidence upload (only when the server says an incident needs it)
                         │  typed Serverpod client (generated)       ▲ stream: IncidentUpdate
                         ▼                                           │
 SERVERPOD (argus_server)
   endpoints: rule · camera · zone · signal · incident · evidence · demo · health
   argus_engine (pure Dart): schema validation · grammar parser · rule state machines · escalation planner
   services: GeminiProxy (rate limit + cache + circuit breaker) · TelegramService · EvidenceService
   future calls: escalation steps · verification · notification dispatch · retention sweep
   Postgres: workspaces, cameras, zones, rules, incidents, incident events, audit log, signal log (short retention)
```

**Key decisions (record changes in DECISIONS.md):**
1. **Detection runs in the browser; rules run on the server.** The browser emits *signals* (geometric facts); the server decides whether a *rule* fires. This keeps video private, avoids server GPUs, and makes Serverpod the real decision-maker.
2. **Pure-Dart `argus_engine` package** (no Serverpod/Flutter imports): rule schema, validation, grammar parser, per-rule state machines, escalation planning. Unit-testable and reusable.
3. **Contracts first:** DTOs are `.spy.yaml` models created in Phase 1 (non-table) so mock and real backends return the same generated classes; Phase 3 adds `table:`.
4. **Unary batch uplink, streaming downlink:** simpler and more robust; judges see live streaming on the dashboard.
5. **Replay mode** (real recorded detector output, labelled) guarantees a working demo on weak devices/no camera.
6. **Resource limits (free tier):** ≤ 5 cameras, ≤ 30 rules, ≤ 20 signal batches/sec per workspace, ≤ 1 verification/10 s per workspace, evidence ≤ 200 KB, retention 7 days.

---

## 5. REPOSITORY LAYOUT (create in Phase 1; keep stable)

```
argus/                         # git root
  README.md  LICENSE  docs/ (this plan.md, goal.md, STATUS.md, DECISIONS.md, HACKATHONS.md, DEPENDENCIES.md, METHODOLOGY.md, SUBMISSION.md, FEEDBACK.md)
  argus_engine/                    # pure Dart: lib/src/{schema,parser,rules,escalation,util}/ + test/
  argus_server/                # Serverpod server: lib/src/{endpoints,models,services,future_calls,web}/ + config/ (passwords.yaml gitignored) + test/
  argus_client/                # generated
  argus_flutter/
    lib/ app/{router,shell,theme}/  core/{widgets,utils,copy}/  data/{argus_repository.dart,mock/,remote/}/
         features/{home,cameras,monitor,zones,rules,incidents,escalation,lab,settings,about,auth}/  vision/{vision_bridge.dart,overlay.dart}
    web/ vision/{vision_bridge.js,tracker.js,signals.js,snapshot.js,vendor/(mediapipe wasm+js),models/(.tflite/.task)}  demo/(clips + replay json)
    assets/ fonts/ images/ demo_rules/  test/ integration_test/
  tools/ eval/ (labelled test clips metadata, eval script)  record_replay/ (script/page to record detector output)
```
(Folder names generated by `serverpod quickstart` take precedence; keep the structure of `features/`, `data/`, `vision/`, and the separate `argus_engine`.)

---

## 6. DOMAIN MODEL (Serverpod `.spy.yaml` DTOs — defined in Phase 1 as non-table models, frozen after Phase 1, tables added in Phase 3)

Verify exact YAML syntax in Serverpod docs/skills. Keep names and fields consistent across mock, server, client and UI.

- `Workspace{id, ownerUserId, name, createdAt, settings}` · `WorkspaceSettings{cloudVerification=false, blurEvidence=true, retentionDays=7, browserNotifications, telegramLinked, timezone}` · `Contact{id, workspaceId, name, role, telegramChatId?, notifyInApp}`
- `Camera{id, workspaceId, name, sourceKind(webcam|file|demo|replay), sourceRef, enabled, createdAt, lastSignalAt, status(offline|online|replay)}`
- `PointN{x,y}` (normalised 0..1) · `Zone{id, cameraId, name, kind(restricted|work|stairs|custom), color, polygon[PointN], createdAt}`
- `RuleSpec{id, workspaceId, name, enabled, cameraIds[], trigger, conditions, severity(low|medium|high|critical), verify, actions[], cooldownSec, escalation[], sourceText, parsedBy(gemini|grammar|manual), createdAt, version}`
  - `trigger{signal(person_in_zone|fall_suspected|motionless|person_count|ppe_check), zoneId?, minDurationSec, minConfidence, minCount?, ppe?(helmet)}`
  - `conditions{timeWindows[{start:"HH:mm", end:"HH:mm"}], daysOfWeek[], timezone}`
  - `verify{enabled, kind(helmet|person_down|generic)}` · `actions[{kind(in_app|browser|telegram|snapshot|create_incident), params}]` · `escalation[{afterSec, notify(contactId|role), message}]`
- `ParseResult{spec?, parsedBy, confidence, warnings[], unsupportedReason?, alternatives[]}`
- `SignalBatch{cameraId, sentAtMs, seq, signals[SignalEvent]}` · `SignalEvent{tsMs, kind(heartbeat|change), personCount, persons[PersonSignal]}` · `PersonSignal{trackId, bboxN{x,y,w,h}, footN{x,y}, zoneIds[], torsoAngleDeg?, hipDropRatio?, aspect, motionScore, fallScore, motionlessMs, confidence}` · `SignalAck{accepted, needEvidenceFor[incidentId], serverTimeMs}`
- `Incident{id, workspaceId, cameraId, ruleId, ruleSnapshotJson, severity, status(open|acknowledged|resolved|false_positive), openedAt, ackedAt?, resolvedAt?, evidenceFileKey?, verification{status(not_requested|pending|confirmed|rejected|unverified), reason?, model?}, summary, signalContextJson, assignedTo?}`
- `IncidentEvent{id, incidentId, at, kind(opened|evidence_added|verified|notified|escalated|acknowledged|resolved|false_positive|note), detail}` · `IncidentUpdate{incident, event?}` (stream payload)
- `AuditEntry{id, workspaceId, at, actor, action, targetKind, targetId, detail}`
- `EvidenceUpload{incidentId, snapshotJpegBase64 | ByteData, verificationCropJpeg? (ephemeral, never stored)}`
- `DetectorLabReport{clips[{clipId, scenario, expectedEvents, detectedEvents, tp, fp, fn, latencyMsP50}], precision, recall, generatedAt, notes}`
- `DemoSeedResult{workspaceId, cameraIds[], ruleIds[]}` · `HealthInfo{version, engineVersion, geminiState(available|limited|off), quotaNote, queueDepth}` · `ClientConfig{limits, features}`

---

## 7. API CONTRACTS

### 7.1 Flutter data layer — `ArgusRepository` (Phase 1 defines; Phase 3 implements remotely)
```dart
abstract class ArgusRepository {
  // Workspace & demo
  Future<Workspace> ensureWorkspace();                         // anonymous guest
  Future<DemoSeedResult> seedDemo();                           // cameras + zones + rules + replay clips
  Future<ClientConfig> getConfig();
  Future<WorkspaceSettings> updateSettings(WorkspaceSettings s);
  Future<void> deleteWorkspaceData();

  // Cameras & zones
  Future<List<Camera>> listCameras();  Future<Camera> saveCamera(Camera c);  Future<void> deleteCamera(int id);
  Future<List<Zone>> listZones(int cameraId);  Future<Zone> saveZone(Zone z);  Future<void> deleteZone(int id);

  // Rules
  Future<ParseResult> interpretRule(String sentence, {int? cameraId});     // Gemini -> grammar -> form
  Future<List<RuleSpec>> listRules();  Future<RuleSpec> saveRule(RuleSpec r);  Future<void> deleteRule(int id);
  Future<DryRunResult> dryRunRule(RuleSpec r, String replayClipId);        // run rule against a recorded clip

  // Live pipeline
  Future<SignalAck> sendSignals(SignalBatch batch);
  Future<void> uploadEvidence(EvidenceUpload upload);
  Stream<IncidentUpdate> watchIncidents({int? sinceIncidentId});

  // Incidents
  Future<List<Incident>> listIncidents({IncidentFilter? filter});
  Future<IncidentDetail> getIncident(int id);                               // incident + events + evidence url
  Future<Incident> acknowledge(int id, {String? note});
  Future<Incident> resolve(int id, {String? note});
  Future<Incident> markFalsePositive(int id, {String? note});

  // Contacts & escalation, lab, audit
  Future<List<Contact>> listContacts();  Future<Contact> saveContact(Contact c);  Future<void> deleteContact(int id);
  Future<String> createTelegramLinkCode();
  Future<DetectorLabReport?> getLabReport();  Future<void> saveLabReport(DetectorLabReport r);
  Future<List<AuditEntry>> listAudit({int limit = 100});
  Future<HealthInfo> health();
}
```

### 7.2 Serverpod endpoints (thin wrappers over `argus_engine` and services; each takes `Session` first; verify syntax in docs)
`WorkspaceEndpoint` (ensure, settings, delete) · `CameraEndpoint` / `ZoneEndpoint` (CRUD, owner-scoped) · `RuleEndpoint` (`interpret`, CRUD, `dryRun`) · `SignalEndpoint.send(SignalBatch)` (validate, rate-limit, run rule engine, return `SignalAck`) · `EvidenceEndpoint.upload` (file upload API; JPEG only, ≤ 200 KB; server applies blur policy if client blur is missing) · `IncidentEndpoint` (`watch` → **Stream<IncidentUpdate>**, list, get, acknowledge, resolve, markFalsePositive) · `ContactEndpoint` · `DemoEndpoint.seed` · `LabEndpoint` · `AuditEndpoint` · `HealthEndpoint.ping`.
All queries are **owner-scoped** (workspace = anonymous user). Typed `SerializableException`s: `ValidationError`, `QuotaExceeded`, `RateLimited`, `NotFound`, `Unauthorized`, `UpstreamUnavailable` (never leak stack traces).

### 7.3 Streaming contract
`IncidentEndpoint.watch(Session, {sinceIncidentId})` emits `IncidentUpdate` for any incident/event change in the caller's workspace. Client reconnects with exponential backoff and resumes via `sinceIncidentId`. Handle idle-timeout/closed-stream exceptions; show "Reconnecting…" in the UI.

---

## 8. SPECIFICATIONS (normative)

### 8.1 Rule schema, parsing pipeline, grammar
**Pipeline (`RuleEndpoint.interpret`):** (1) if Gemini is enabled/available → send sentence + workspace context (zone/camera names) to the Gemini proxy (8.5), expect **JSON only**, validate strictly against the `RuleSpec` schema (reject unknown fields/enums; coerce times; resolve zone names to ids; fill defaults); (2) otherwise or on failure → **grammar parser** in `argus_engine`; (3) otherwise → return a partially filled `ParseResult` with `unsupportedReason` so the **form builder** opens prefilled. The UI **always shows the parsed rule as a visual workflow and requires user confirmation** before saving. Show the `parsedBy` badge and confidence. Cache by hash(workspace zones + sentence).
**Grammar patterns the parser must support (≥ 12; fixtures in tests):**
1. `if (anyone|a person|someone) enters <zone> [after|before|between <time> ...] <actions>`
2. `if (anyone|a person) stays in <zone> for (more than|over) <N> seconds ...`
3. `if (anyone|someone) falls [near|in|at] <zone> [and stays down for <N> seconds] ...`
4. `if no one moves for <N> seconds in <zone> ...` (motionless)
5. `if more than <N> people are in <zone> ...` (person_count)
6. `if a person in <zone> isn't wearing a helmet ...` (ppe_check; requires cloud verification opt-in)
7. Time clauses: `after 8 pm`, `before 6 am`, `between 10 pm and 5 am`, `on weekdays`, `at night` (22:00–06:00), `outside working hours` (configurable 09:00–18:00)
8. Actions: `take a snapshot`, `alert <contact|role>`, `notify <contact>`, `create an incident`, `send a Telegram message`, `escalate after <N> (seconds|minutes)`, severity words (`low|medium|high|critical`, `urgent` → high)
Tolerate case, punctuation, "and", "then", synonyms (`restricted area` = zone kind restricted). Return confidence and warnings for guesses.

### 8.2 Vision module (`web/vision/`) and Flutter bridge
**Public API:** `window.argusVision = { init({modelBaseUrl, wasmBaseUrl}), attach({videoId, canvasId}), start({targetFps=8}), stop(), setZones(zonesJson), onSignals(callback), snapshot({blurHead=true, maxWidth=640, quality=0.7}) -> Uint8Array(JPEG), verificationCrop({trackId}) -> Uint8Array(JPEG)|null, getStats(), recordReplay(on), loadReplay(json), setMode('live'|'replay') }`.
**Pipeline per frame** (use `requestVideoFrameCallback`): MediaPipe `ObjectDetector` (EfficientDet-Lite0, VIDEO mode, `person` class, score ≥ 0.5) → centroid/IoU **tracker** (assign `trackId`; drop after 1.5 s unseen) → MediaPipe `PoseLandmarker` (lite; run on alternate frames; `numPoses` up to 3) matched to tracks by bbox overlap → **signal computation** (8.3) → overlay drawing on a transparent `<canvas>` (boxes, trackId, skeleton, zones, fall/motionless badges) → batching/emission.
**Hosting:** all models, `.wasm` and JS bundled under `web/vision/vendor` and `web/vision/models` (no runtime third-party fetches; record licences). Model files: EfficientDet-Lite0 `.tflite` and Pose Landmarker lite `.task` from Google's MediaPipe model storage — **verify current URLs and licences when downloading** and note them in `DEPENDENCIES.md`.
**Flutter bridge:** Flutter registers a view factory for an `HtmlElementView` hosting `<video>` + overlay `<canvas>` (positioned/sized together); calls into `window.argusVision` via `dart:js_interop`; receives `onSignals` callbacks (JS → Dart) and forwards batches to `ArgusRepository.sendSignals`. Zone editing happens in Flutter on a frozen frame (normalised polygons); Flutter calls `setZones`.
**Performance budget:** ≥ 8 fps end-to-end on a mid-range laptop CPU in Chrome; degrade ladder (smaller input → alternate-frame pose → detector-only → 3 fps) and show a "Performance mode" chip. Camera access (`getUserMedia`) needs a secure context (HTTPS or localhost).

### 8.3 Signals (computed in JS; the server never sees video)
- **Foot point** = pose ankle midpoint when confident, else bbox bottom-centre. **Zone membership** = point-in-polygon on the foot point; `zoneIds[]` per person.
- **motionScore** = normalised displacement of bbox centre and pose landmarks over the last ~1 s; **motionlessMs** = continuous time below a threshold (initial 0.02; tune).
- **Fall heuristic (initial parameters — TUNE on our own clips and record the final values in METHODOLOGY.md):** `aspect` = bbox w/h; `hipDropRatio` = (hipY_now − hipY_1s_ago)/personHeight; `torsoAngleDeg` = angle of shoulder-mid→hip-mid vector from vertical. `fallScore = clamp(0.4·[aspect>1.0 after being <0.8 within 1 s] + 0.35·min(1, hipDropRatio/0.35) + 0.25·min(1, torsoAngle/70), 0, 1)`; `fall_suspected` when `fallScore ≥ 0.6` and stays until the person is upright again. Known false-positive sources: bending, sitting, crouching, side-on/overhead camera angles — document them.
- **Emission:** send a `SignalBatch` every ~500 ms containing the latest state **only if** something changed (zone enter/exit, personCount change, a threshold crossing for fall/motionless) or as a **heartbeat every 2 s**. Never send video or frames except via `uploadEvidence`.

### 8.4 Rule engine (`argus_engine/lib/src/rules/`) — deterministic and unit-tested
Per `(rule, camera)` state machine evaluated on every accepted `SignalBatch`:
`IDLE → ARMED(since t0)` when the **condition is active** (trigger signal true for any person with `confidence ≥ minConfidence`, and the time-window/day condition holds in the workspace timezone) → `FIRED` when active continuously ≥ `minDurationSec` (creates an incident, starts `COOLDOWN` for `cooldownSec`) → back to `IDLE` after **hysteresis** (condition inactive for 1.5 s) and cooldown. Compound triggers (e.g. fall then motionless ≥ N s) are expressed as ordered stages with a maximum gap. **Dedupe:** at most one open incident per `(rule, camera, zone)`; a repeat during an open incident appends an `IncidentEvent` instead. **Staleness:** no batch for 10 s → camera `offline`; all `ARMED` states reset. **Time handling:** all window checks use the workspace timezone (client sends IANA tz); support windows crossing midnight. Provide a pure function `evaluate(ruleState, batch, now) → (newState, effects[])`; effects are `OpenIncident`, `AppendEvent`, `ScheduleEscalation`, `RequestEvidence`, `Notify`.

### 8.5 Gemini proxy (`services/gemini_proxy.dart`)
- Key from `config/passwords.yaml` only; model name from config (default to a current free-tier Flash/Flash-Lite model — **confirm availability in AI Studio**; do not hard-code a model).
- **Token bucket** default 4 requests/min (below the lowest free limit), daily cap, ≤ 2 in flight, 8 s timeout, max 2 retries with jitter for 5xx only; on 429 **open a circuit for 60 s** (honour retry-after) and fall back; cache parse results 24 h and verification results by snapshot hash; never log keys or images; expose `geminiState` and counters via `HealthEndpoint`.
- Prompt skeletons live in `argus_server/lib/src/services/prompts/` as constants: *interpret* (system: output only JSON matching schema; allowed enums; zone names; temperature 0) and *verify* (system: answer only JSON `{"answer":"yes|no|unclear","confidence":0..1,"reason":"<=20 words"}`).
- **Unit-test the proxy with a fake HTTP client** (no live calls in tests).

### 8.6 Verification, evidence and privacy
1. A fired rule **opens the incident immediately** (`verification.status = pending` if verify enabled and workspace `cloudVerification = true`, else `not_requested`). Never block alerting on verification.
2. The `SignalAck.needEvidenceFor` tells the browser to capture. The browser calls `snapshot({blurHead:true})` (blur drawn using pose head landmarks; fallback: blur the top 25% of the person's bbox) and uploads via `EvidenceEndpoint`. If verification is enabled, it also sends an **ephemeral `verificationCrop`** (upper-body crop, ≤ 60 KB) in the same request; the server forwards it to Gemini and **discards it** (not stored, not logged).
3. Verification result `confirmed | rejected | unverified` is appended as an `IncidentEvent`; `rejected` lowers severity and flags the incident for review (do not auto-delete). Quota/circuit open → `unverified` and alert anyway.
4. **Cloud verification is OFF by default**, gated by an explicit consent toggle that states: cloud images go to Google's Gemini API free tier, where inputs may be reviewed and used to improve Google products. S4 (helmet) is unavailable while it is off; the UI explains why.
5. No face recognition. Evidence retention default 7 days; hourly sweep (future call); "Delete my data" removes everything for the workspace.

### 8.7 Replay mode
`recordReplay(true)` while a clip plays through the **real** detector stores every emitted `SignalBatch` with timestamps as JSON (`{clipId, durationMs, fps, batches[]}`); the file is saved under `web/demo/replay/`. `setMode('replay')` plays the same clip video and feeds the recorded batches at the recorded times, so the rest of the system behaves identically. Camera status shows `REPLAY` and the monitor shows a visible label "Replay of recorded detector output". Uses: demo fallback on weak devices, deterministic tests, **Detector Lab** metrics, and `dryRunRule`. Replay is never presented as live detection.

### 8.8 Escalation and notifications
When an incident opens, schedule one future call per `escalation` step at `openedAt + afterSec`. When it fires: if the incident is still `open` (not acknowledged), notify the target (`in_app` broadcast always; `telegram` if the contact is linked), append an `escalated` event, and schedule the next step. Acknowledge/resolve makes later steps no-ops. **Telegram (optional):** bot token in `passwords.yaml`; link flow = user gets a code in the app and sends it to the bot; messages: severity, rule name, camera, time, short link to the incident; rate-limit 20/min; failures recorded as events, never fatal. **Browser notifications:** request permission on first rule save; show for new incidents while the dashboard is open.

---

## 9. PHASE 1 — FOUNDATION + COMPLETE UI/UX (mock data, every screen)

**Time-box (guidance):** ≤ 1.5 working days. **Goal:** a Serverpod + Flutter project in which **every screen, state and interaction of the final product exists, looks finished, and runs on mock data** behind `ArgusRepository`. Later phases swap data sources and add depth; they must **not** need to redesign any screen.
**Prerequisites:** Flutter ≥ 3.44.4, `dart install serverpod_cli`, Chrome. **Inputs:** sections 0–8.

### 9.1 Deliverables
1. Serverpod project scaffolded (`serverpod quickstart argus`, pick the coding agent so skills/MCP install), repo layout per section 5, git initialised, `.gitignore` covering `config/passwords.yaml`, an empty pure-Dart `argus_engine` package with a smoke test.
2. Design system (tokens, dark+light themes, severity scale, core widgets) and a debug-only `/dev/kitchen-sink`.
3. App shell, routing, **all screens in 9.5** with loading / empty / error / disconnected / permission-denied states.
4. All DTOs from section 6 as `.spy.yaml` (non-table), `serverpod generate` run, generated client in use.
5. `ArgusRepository` interface (7.1) + `MockArgusRepository` (9.7) providing scripted scenarios S1–S4.
6. Docs skeleton: `docs/STATUS.md`, `DECISIONS.md`, `HACKATHONS.md`, `DEPENDENCIES.md`, README skeleton, `SUBMISSION.md` with the demo-video storyboard (14.1, D6.4).
7. Widget tests + golden screenshots for key screens.

### 9.2 Task list (in order)
- **P1.1 Scaffold & verify:** create project; `serverpod start` once to confirm the stack runs; commit.
- **P1.2 Tokens + theme:** `tokens.dart`, `theme.dart`, `severity_scale.dart` (9.3); fonts as assets.
- **P1.3 Shell + routing:** `go_router` routes (9.4), responsive scaffold (side rail ≥ 1200 px; bottom nav < 768 px), command palette (Ctrl/Cmd+K), toast system, error boundary, connection-status chip.
- **P1.4 Models:** write all DTOs as `.spy.yaml`; `serverpod generate`; keep field names from section 6.
- **P1.5 Repository + mock:** interface (7.1) and `MockArgusRepository` (9.7), provided by Riverpod; `MOCK DATA` banner whenever active.
- **P1.6 Components:** severity/status chips, workflow-node widget, progress ring, video-overlay container (placeholder), polygon editor, timeline chart (`fl_chart`), data table, empty-state panel, skeletons, dialogs/drawers/sheets, tooltips, stepper-free forms with validation.
- **P1.7 Home** · **P1.8 Live Monitor** · **P1.9 Cameras + Zone editor** · **P1.10 Rule Studio** · **P1.11 Incidents + Incident detail** · **P1.12 Escalation & contacts** · **P1.13 Detector Lab** · **P1.14 Settings** · **P1.15 About/Methodology + Auth screen**.
- **P1.16 Responsive + accessibility pass** (9.9).
- **P1.17 Tests:** widget tests for key components and each screen's states; golden tests (dark theme) for Home, Monitor, Zone editor, Rule Studio, Incidents, Incident detail, Lab, Settings, About.
- **P1.18 Handoff:** update STATUS.md; list every `// MOCK:` marker; list assumptions Phase 2/3 must satisfy.

### 9.3 Design system (normative)
**Mood:** calm, trustworthy "control room" — dark, quiet, information-dense but uncluttered; colour is reserved for **severity** and **interactive accent**. No generic purple-gradient AI look.
**Colour tokens (dark default):** `bg.base #0B0E13` · `bg.raised #11161E` · `bg.overlay #171D27` · `border.subtle #212A37` · `border.strong #2E3A4B` · `text.primary #E8EDF5` · `text.secondary #A1AEC2` · `text.tertiary #6A778B` · **accent `#38BDF8`** (interactive) · `accent.ink #031A26` · `focus #38BDF8` (2 px ring) · success `#34D399` · info `#60A5FA`.
**Severity scale (never rely on colour alone — always icon + label):** low `#60A5FA` (info icon) · medium `#FBBF24` (warning triangle) · high `#FB923C` (alert) · critical `#F43F5E` (siren). **Status chips:** open (accent outline), acknowledged (amber), resolved (green), false positive (grey, strike icon). **Detection overlay colours:** person box `#38BDF8`; zone fill 18% alpha by zone kind (restricted `#F43F5E`, work `#FBBF24`, stairs `#A78BFA`, custom `#2DD4BF`); fall badge `#F43F5E`; motionless badge `#FBBF24`.
**Light theme:** `bg.base #F5F7FA`, `bg.raised #FFFFFF`, `text.primary #0E1520`; AA-checked; document derivations in `tokens.dart`.
**Typography:** Sora 600 (display), Inter 400/500/600 (body), JetBrains Mono (ids, timestamps, numbers). Scale 12/14/16/20/24/32/48. Tabular figures for metrics.
**Spacing/radius/elevation:** 4-pt grid (4, 8, 12, 16, 24, 32, 48); radius 8 controls, 12 cards, 20 sheets; borders + subtle inner glow instead of heavy shadows.
**Motion:** 120 / 240 / 480 ms; `easeOutCubic`; `reduceMotion` flag (OS + Settings) disables decorative animation. **Copy voice:** concise, calm, specific; never alarmist; always show confidence and "unverified" honestly. Centralise strings in `core/copy/strings.dart`.

### 9.4 Routes
`/` Home · `/auth` · `/app/monitor` · `/app/cameras` · `/app/cameras/:id/zones` · `/app/rules` · `/app/incidents` · `/app/incidents/:id` · `/app/escalation` · `/app/lab` · `/app/settings` · `/about` · `/dev/kitchen-sink` (debug). Deep links preserve the selected camera/incident.

### 9.5 Screen specifications

**A. Home (`/`)** — Hero with a short animation of a sentence typing and turning into workflow nodes (CSS/CustomPainter; paused if `reduceMotion`). Headline: "Describe a safety rule. Argus watches, documents, and escalates." Primary CTA **Open the demo** (creates a guest workspace and seeds S1–S4 — no login), secondary **Start with an empty workspace**. Four **scenario cards** (S1–S4) each with a looping thumbnail, the example sentence, and "Try this". Sections: How it works (4 steps), **Privacy by design** (on-device detection, blurred evidence, no face recognition, opt-in cloud check), **Honest limits** (assistive, not certified), footer (Methodology, AI-assistance disclosure, hackathon note).

**B. Live Monitor (`/app/monitor`)** — Left/center: **video stage** (HtmlElementView in Phase 2; static/looping clip + Flutter-drawn mock overlay in Phase 1) with camera selector, source switcher (Webcam / Upload MP4 / Demo clip / Replay), play/pause, performance-mode chip, `REPLAY` or `LIVE` or `MOCK` label, zones and boxes overlay, signal chips under the video (persons, in-zone, fall score, motionless timer). Right rail: **Rule status list** (each rule shows Idle / Armed with a progress ring toward `minDurationSec` / Fired / Cooldown) and **Live incidents** (compact cards). Bottom: **Event log** (timestamped signals and decisions, filterable, monospace). A fired rule slides in a toast with severity, rule name, and "Open incident". Empty states: no camera yet → guided "Add a camera" card; webcam blocked → instructions; model loading → skeleton + progress.

**C. Cameras (`/app/cameras`) and Zone editor (`/app/cameras/:id/zones`)** — Grid of camera cards (name, source kind, status online/offline/replay, last signal, zone count, rule count). Add-camera dialog: choose source (Webcam, Upload MP4, Demo clip S1–S4), name. **Zone editor:** frozen frame; click to add polygon points, click first point to close, drag handles, double-click to delete a point; side list of zones (rename, kind, colour, delete, duplicate); preset templates (Doorway, Staircase, Danger area, Lab); snap-to-edge; undo/redo; validation (≥ 3 points, no self-intersection); coordinates stored normalised 0..1.

**D. Rule Studio (`/app/rules`)** — Top: large **sentence input** with example chips (S1–S4), an **AI interpretation toggle** with state badge (Gemini available / limited / off — from `HealthInfo`), and **Interpret**. Below: the **parsed rule as a horizontal workflow graph** — `Camera → Detect → Zone → Time/Condition → Verify → Actions → Escalation` — each node is editable via popover (zone picker, duration, time windows with midnight-crossing support, severity, verification kind, action chips, escalation steps); shows `parsedBy` badge (Gemini / Grammar / Manual) and a **confidence meter**; warnings list ("I assumed 'the lab' = Zone Lab"); unsupported sentence → friendly message + prefilled **form builder**. Buttons: **Dry run on clip** (choose a replay clip; shows a timeline of when the rule would fire), **Save rule**. Lower section: saved rules list (enable toggle, severity chip, cameras, last fired, edit, duplicate, delete). Always requires explicit confirmation before saving.

**E. Incidents (`/app/incidents`) and detail (`/app/incidents/:id`)** — Stats strip: open, acknowledged, median time-to-acknowledge, false-positive rate. Filters: status, severity, camera, rule, date. List/card toggle; each row has thumbnail (blurred), severity chip, rule, camera, age, status; live-updating (stream) with a subtle new-item highlight. **Detail:** evidence image with a "faces/heads blurred" notice; rule fired + parameter snapshot; **signal timeline** (personCount, fallScore, motionless over the 30 s around the event); **verification card** (not requested / pending / confirmed / rejected / unverified, reason, "AI-assisted" label, model name); **escalation timeline** (planned vs executed steps with timestamps); notes; actions **Acknowledge / Resolve / Mark false positive** (confirm dialog; false-positive feeds the Lab and rule tuning hints); audit entries.

**F. Escalation (`/app/escalation`)** — Contacts CRUD (name, role, in-app notify, Telegram link status). **Escalation policy editor:** visual steps ("after 60 s → notify Supervisor", "after 180 s → notify Security Lead"), per-severity templates, test-notify button. **Telegram card:** generate link code, instructions, linked/unlinked state.

**G. Detector Lab (`/app/lab`)** — Table of recorded test clips: scenario, expected events, detected events, TP / FP / FN, median latency; tiles for precision and recall per scenario; **Run on replay clips** button; notes on method and limits; export Markdown/JSON. Empty state explains how to record and label clips. (Phase 1 shows mock numbers with a `MOCK DATA` badge; real numbers arrive in Phase 4.)

**H. Settings (`/app/settings`)** — **Privacy:** cloud verification toggle (off by default) with the consent text from 8.6, blur evidence (on), retention days (1–7). **Notifications:** browser permission, Telegram. **Performance mode** (auto/low/high). Timezone. Theme (dark/light/system), reduce motion. **Delete all my data** (typed confirmation).

**I. About / Methodology (`/about`)** — What Argus is and is not; how detection works (MediaPipe on-device), the fall heuristic and its known failure modes, what the server decides, how Gemini is used and when, privacy and retention, **measured accuracy** (links to Lab), WHO falls reference, AI-assistance disclosure, licences, limits ("assistive alerting, not a certified safety system").

**J. Auth (`/auth`)** — Explains guest mode (anonymous, data tied to this browser), optional sign-in placeholder (not required).

**Global UX:** command palette (new rule, add camera, open incident), toasts, offline/reconnecting banner, error boundary with copy-diagnostics, skeleton loaders, destructive-action confirmations, keyboard shortcuts (`g m` monitor, `g i` incidents, `n` new rule, `a` acknowledge, `?` help).

### 9.6 Key interaction details
- Severity is always icon + label + colour. Incident cards show age ("2m 14s") updating live.
- The workflow graph is the product's signature visual: nodes animate in left-to-right on interpret, with the matched sentence fragments highlighted in the input.
- Zone polygons and detection boxes are drawn in normalised coordinates so they survive resizing.
- Fired-rule toast includes **Open** and **Acknowledge** buttons; acknowledging cancels visual alarms.

### 9.7 Mock repository specification
- Deterministic scripted timelines for S1–S4 that emit `SignalBatch`es (person enters zone; fall then motionless; dwell in red zone; helmet case) at realistic timing; mock rule engine stand-in that opens incidents; seeded incident history (≈ 20, mixed statuses); placeholder blurred-silhouette evidence images labelled MOCK; canned `ParseResult`s for the example sentences with `parsedBy: gemini` flagged MOCK; latency simulation 100–400 ms; stream emits incident updates.
- Everything is **throwaway** and replaced in Phase 3. Add a code banner and the visible `MOCK DATA` badge. Never present it as real.

### 9.8 Interaction/state rules
Every async view has loading (skeleton), empty (purposeful), error (message + retry + copy diagnostics), disconnected ("Reconnecting… resumed") and permission-denied (camera) states. Wizard-like flows keep draft state in Riverpod. Rules can't be saved while invalid. Undo for deletes (5 s snackbar).

### 9.9 Responsive and accessibility requirements
Breakpoints: ≥ 1200 desktop (rail + 2 panes), 768–1199 tablet (collapsible panes), < 768 mobile (bottom nav: Monitor, Incidents, Rules, More; incidents-first for the "supervisor on the move" story). WCAG AA contrast; visible focus ring; full keyboard navigation (including the zone editor via keyboard nudge); semantic labels for video/overlay with a text alternative of current signals; touch targets ≥ 44 px; text scaling to 200% on non-canvas screens; `reduceMotion` respected; severity never colour-only.

### 9.10 Acceptance criteria (Phase 1)
- [ ] `serverpod start` runs the app; `flutter build web` succeeds.
- [ ] All routes reachable; the flow **Open demo → Monitor → scripted S2 fall → toast → Incident detail → Acknowledge** works on mock data.
- [ ] Rule Studio: interpret an example sentence → editable workflow graph → dry-run (mock) → save.
- [ ] Zone editor works with mouse and keyboard and persists normalised polygons (mock).
- [ ] Every screen has loading/empty/error states demonstrable (debug toggle or kitchen sink).
- [ ] Dark + light themes verified; no hard-coded colours outside token files (grep check); strings via `strings.dart`.
- [ ] Golden tests for the 9 key screens; `flutter analyze` clean; widget tests pass.
- [ ] `MOCK DATA` badge visible whenever the mock repo is active.
- [ ] STATUS.md, DECISIONS.md, HACKATHONS.md, DEPENDENCIES.md, README skeleton exist.

### 9.11 Cut line
**Must:** shell, Monitor, Cameras+Zone editor, Rule Studio, Incidents+detail, Settings, About, dark theme, desktop+mobile layouts. **Should:** Escalation screen, Lab screen, light theme, command palette. **Could:** hero animation polish, keyboard shortcuts, goldens beyond the core five.

### 9.12 Handoff
List generated DTO names, repository methods the mock implements, all `// MOCK:` markers, measured Flutter web build size, open UI issues.

---

## 10. PHASE 2 — VISION MODULE + FLUTTER BRIDGE (real detection in the browser, no backend dependency)

**Time-box (guidance):** ≤ 1 working day. **Goal:** replace the Phase 1 video placeholder with the **real** on-device pipeline: detect people, track them, compute pose/zone/fall/motionless signals, draw the overlay, take blurred snapshots, and record/replay signals — all inside the browser. **Prerequisites:** Phase 1 complete. **Inputs:** sections 8.2, 8.3, 8.7.

### 10.1 Tasks
- **V2.1 Assets:** download MediaPipe Tasks Vision JS/WASM, EfficientDet-Lite0 `.tflite`, Pose Landmarker lite `.task`; place under `web/vision/vendor` and `web/vision/models`; record versions, URLs and licences in `docs/DEPENDENCIES.md`. Verify there are **no third-party network requests** at runtime.
- **V2.2 Module skeleton:** `vision_bridge.js` exposing the API in 8.2 with a mode switch (`live`/`replay`).
- **V2.3 Detection loop + tracker:** `requestVideoFrameCallback`, person-only filtering, IoU/centroid tracker, track ageing.
- **V2.4 Pose + signals:** pose on alternate frames, matching to tracks, foot point, `motionScore`, `motionlessMs`, `fallScore` per 8.3 (parameterised in one config object).
- **V2.5 Zones:** `setZones`, point-in-polygon, per-person `zoneIds`.
- **V2.6 Overlay:** transparent canvas drawing (boxes, ids, skeleton, zones, badges); high-DPI aware.
- **V2.7 Snapshot + blur:** `snapshot({blurHead})` using head landmarks (fallback: top 25% of bbox); `verificationCrop(trackId)` (upper body, small JPEG).
- **V2.8 Flutter bridge:** `HtmlElementView` hosting `<video>` + `<canvas>`; `dart:js_interop` calls; JS→Dart signal callback; wire the Monitor screen to webcam, MP4 upload, and demo clips; permission and error states; Performance-mode chip fed by `getStats()`.
- **V2.9 Replay recorder/player:** per 8.7; `web/demo/replay/*.json`; `REPLAY` label.
- **V2.10 Clips + tuning (owner + agent):** film and label the test clips (Appendix C protocol); tune thresholds on them; write final values and known failure modes into `docs/METHODOLOGY.md`.
- **V2.11 Performance pass:** profile in Chrome; implement the degrade ladder; record fps/latency numbers in STATUS.md.
- **V2.12 JS tests:** unit tests (Node/Vitest or simple harness) for tracker, point-in-polygon, geometry, fall scoring on synthetic landmark sequences, batching/heartbeat logic.

### 10.2 Acceptance criteria
- [ ] ≥ 8 fps end-to-end on a mid-range laptop CPU in Chrome (record device + numbers); degrade ladder works.
- [ ] On the filmed S1–S3 clips the signal timelines match expectations (zone entry time, fall suspected, motionless crossing) within ±1 s; false alarms on negative clips are listed in METHODOLOGY.md.
- [ ] Snapshots have blurred heads (visually verified on 10+ frames); no unblurred image is produced unless `verificationCrop` is called explicitly.
- [ ] Replay JSON reproduces the same signal timeline as the live run on the same clip (within timing tolerance).
- [ ] No third-party network requests at runtime (DevTools check); webcam permission-denied and model-load-failure states are handled.

### 10.3 Cut line
**Must:** V2.1–V2.8, V2.9 basic, V2.10 for S1–S3. **Should:** V2.11, V2.12. **Could:** S4 clip, alternate-frame pose optimisation beyond the ladder.

### 10.4 Handoff
Document the JS API with examples, the signal JSON sample, measured performance, tuned parameters, and the list of recorded clips with labels.

---

## 11. PHASE 3 — RULE ENGINE + SERVERPOD BACKEND + FULL-STACK INTEGRATION (the core loop, no mock)

**Time-box (guidance):** ≤ 1.5 working days. **Goal:** the golden path works end-to-end on real data: **browser signals → Serverpod rule engine → incident + evidence → live dashboard → acknowledge**. This phase shows Serverpod doing real work. **Prerequisites:** Phases 1–2. **Inputs:** sections 4, 6–8.

### 11.1 Tasks
- **S3.1 `argus_engine`:** schema classes/validators, **grammar parser** (8.1, ≥ 40 fixture sentences), **rule state machines** (8.4), escalation planner (8.8). Pure Dart, deterministic. Tests: truth tables, midnight-crossing windows, dedupe, staleness, cooldown/hysteresis, compound (fall→motionless) stages.
- **S3.2 Tables + migrations:** add `table:` to Workspace, Contact, Camera, Zone, RuleSpec (JSON column or normalised), Incident, IncidentEvent, AuditEntry, SignalLog (short retention). Index `(workspaceId, openedAt)`, `(incidentId, at)`. Run `serverpod generate` and `serverpod create-migration`; verify syntax in docs/skills.
- **S3.3 Auth + ownership:** anonymous guest sign-in; `WorkspaceEndpoint.ensure`; all queries scoped to the caller's workspace; ownership tests.
- **S3.4 Endpoints:** Camera, Zone, Rule (CRUD; `interpret` = grammar only for now), `SignalEndpoint.send`, Incident (list/get/ack/resolve/false-positive/**watch stream**), Evidence upload, Contact, Demo.seed, Health, Audit.
- **S3.5 Signal handling:** validate and size-limit batches; per-workspace rate limit (≤ 20 batches/s); load rule/zone config from an in-memory cache with invalidation; run the engine; execute effects (open incident, append events, request evidence); return `SignalAck`.
- **S3.6 Evidence flow:** `needEvidenceFor` → browser snapshot → upload (≤ 200 KB JPEG; reject others; server re-blurs top bbox region if the client marks blur missing) → `evidenceFileKey` → URL in incident detail. Note the file-upload default request-size limit.
- **S3.7 Streaming + reconnect:** `IncidentEndpoint.watch`; client backoff + resume (`sinceIncidentId`); "Reconnecting…" UI.
- **S3.8 `RemoteArgusRepository`:** implement every method; switch via one provider; remove the MOCK badge when remote; keep mock only for tests and `--dart-define=USE_MOCK=true`.
- **S3.9 Tests:** engine unit tests; endpoint tests (Serverpod test tooling — verify API); streaming test (send → receive update → disconnect → resume); ownership test; integration test: replay S1 clip → incident visible on dashboard.

### 11.2 Acceptance criteria
- [ ] With `serverpod start`: open the demo, run the S1 clip live (or via replay) → within ~1.5 s of the rule condition completing, an incident appears on the dashboard with a blurred snapshot; **no mock code on this path**.
- [ ] Acknowledge/resolve/false-positive work and persist; incident timeline shows events.
- [ ] Restart the server mid-session: incidents persist; engine state resets safely; the client reconnects and recovers.
- [ ] A second anonymous user cannot read the first user's data (tested).
- [ ] Rate limits and size limits enforced with friendly errors.

### 11.3 Cut line
**Must:** S3.1–S3.8 for scenarios S1–S3. **Should:** S3.9 full tests, audit log. **Could:** persistent engine state recovery beyond safe reset.

### 11.4 Handoff
Endpoint list with examples, DB schema sketch, how to reset the DB, measured signal-to-dashboard latency, known issues.

---

## 12. PHASE 4 — INTELLIGENCE AND RESPONSE (Gemini, verification, escalation, Telegram, Detector Lab)

**Time-box (guidance):** ≤ 1 working day. **Goal:** deliver the features that make Argus feel like Cameron-class "describe it and it acts" while staying honest: LLM-assisted rule interpretation and verification (bounded, optional), escalation that actually executes, optional Telegram, and **measured accuracy**. **Prerequisites:** Phase 3. **Inputs:** 8.1, 8.5, 8.6, 8.8.

### 12.1 Tasks
- **I4.1 Gemini proxy:** implement 8.5 (token bucket, circuit breaker, cache, timeouts, state exposure); tests with a fake HTTP client; `geminiState` in `HealthInfo`. Key in `passwords.yaml` only; the owner creates the key in Google AI Studio.
- **I4.2 Interpret pipeline:** Gemini → strict validation → grammar fallback → form builder; UI shows `parsedBy` and confidence; always confirm before save; negative tests with malformed/hostile model output.
- **I4.3 Verification (opt-in):** ephemeral `verificationCrop` → Gemini vision → `confirmed/rejected/unverified` events; S4 helmet scenario enabled only when consent toggle is on; never persist or log the crop; test that nothing is stored.
- **I4.4 Escalation:** future calls per step; no-op after acknowledge; in-app broadcast; incident timeline shows planned vs executed; tests with a controllable clock.
- **I4.5 Telegram (optional):** bot token config, link-code flow, send with rate limit; failures recorded as events.
- **I4.6 Browser notifications:** permission flow; notification for new incidents while the dashboard is open.
- **I4.7 Dry run on clip:** run the engine over a recorded replay JSON and show when the rule would fire.
- **I4.8 Detector Lab (real):** runner executes the pipeline/engine over labelled replay clips (`tools/eval/labels.json`), computes TP/FP/FN, precision/recall, median latency; saves `DetectorLabReport`; UI shows it; export Markdown/JSON. **These numbers are published in the README and video.**
- **I4.9 False-positive loop:** marking a false positive records context; the rule detail shows tuning hints (e.g. "raise minimum duration to 5 s").
- **I4.10 Demo seeding:** `DemoEndpoint.seed` creates cameras, zones, rules and replay clips for S1–S4; the **Open the demo** button reaches a working state in one click, with live-webcam as an optional extra.

### 12.2 Acceptance criteria
- [ ] Typing each example sentence produces a correct, editable rule via Gemini (when available) **and** via the grammar fallback when Gemini is switched off or rate-limited (tested by forcing 429).
- [ ] With verification on, an S4 clip yields a confirmed/rejected event with a visible reason; with it off, S4 is clearly unavailable and nothing is sent to the cloud (verified by network inspection).
- [ ] An unacknowledged S2 incident escalates on schedule; acknowledging cancels later steps.
- [ ] Detector Lab shows real, reproducible metrics on the filmed clips.
- [ ] Gemini quota exhaustion degrades gracefully (UI badge "AI limited", features keep working).

### 12.3 Cut line
**Must:** I4.1, I4.2, I4.4, I4.8, I4.10. **Should:** I4.3, I4.7, I4.9. **Could:** I4.5, I4.6.

### 12.4 Handoff
Document prompts, quota behaviour, escalation semantics, Lab method and numbers, and any prompt/model changes in DECISIONS.md.

---

## 13. PHASE 5 — HARDENING, PRIVACY, QUALITY, POLISH

**Time-box (guidance):** ≤ 0.5 working day. **Goal:** make the golden path bulletproof, private, accessible and honest. "Does it work" is 30% of the score.

### 13.1 Tasks
- **Q5.1 Soak test:** script that opens the demo and runs S1–S3 replays repeatedly with acknowledgements/resolves; zero crashes; stable memory (dispose video/WASM/streams/timers); record p95 times.
- **Q5.2 Performance:** Flutter web bundle size/startup; precompute/seed everything for instant demo start; loading skeletons > 300 ms waits; verify the degrade ladder on a low-end profile (Chrome CPU throttling).
- **Q5.3 Limits & abuse protection:** rate limits per workspace/IP (session info), quotas (cameras/rules/incidents), upload checks (type/size), input validation, request-size caps, verification limiter.
- **Q5.4 Privacy audit:** confirm no unblurred images are stored or logged, `verificationCrop` is never persisted, no third-party requests except server→Gemini/Telegram, secrets absent from client bundle and git history; retention sweep and delete-my-data tested.
- **Q5.5 Accessibility:** keyboard-only pass, screen-reader pass on non-video screens, contrast, reduce-motion, 200% text scale.
- **Q5.6 Tests:** fill gaps; refresh goldens; **fresh-clone test** following the README exactly on a clean folder.
- **Q5.7 Error UX:** friendly messages for camera blocked, model failed to load, offline, Gemini limited, upload rejected, stream disconnected.
- **Q5.8 Honesty pass:** limits text on Home/About/README; every AI-assisted surface labelled; no claim of certified safety; accuracy numbers match the Lab.
- **Q5.9 Visual polish:** spacing/typography consistency, micro-interactions, favicon/app icon, social preview, README screenshots.
- **Q5.10 Optional auth:** Google/GitHub sign-in if time allows; anonymous remains default.

### 13.2 Acceptance criteria
- [ ] Soak passes (no crash, no leaks); no console errors on the golden path.
- [ ] README fresh-clone test succeeds in < 15 minutes.
- [ ] No critical accessibility issues on Home, Monitor, Rules, Incidents.
- [ ] Privacy audit checklist fully ticked and recorded in STATUS.md.

### 13.3 Cut line
**Must:** Q5.1, Q5.3 basics, Q5.4, Q5.6, Q5.7, Q5.8. **Should:** Q5.2, Q5.5, Q5.9. **Could:** Q5.10.

---

## 14. PHASE 6 — DEPLOY, DOCUMENT, SUBMIT

**Time-box (guidance):** ≤ 0.5 working day, started early enough to leave a safety margin before the deadline. **Goal:** a live, judge-accessible deployment and a complete submission.

### 14.1 Tasks
- **D6.1 Deploy:** create the Serverpod Cloud project (free trial; confirm it covers through 22 Oct), enable the database, `serverpod cloud launch`; set secrets (Gemini/Telegram) via Cloud config, never git. Verify web app, API, streaming, migrations, anonymous auth, file uploads. **Measure** CPU/memory/DB behaviour with the demo; adjust limits. *(Do a throwaway early deploy during Phase 3 to catch environment issues.)*
- **D6.2 Production smoke test:** from a clean browser profile/incognito on desktop and mobile width: Open demo → S1/S2 replay → incident → acknowledge; webcam works over HTTPS; Gemini-off fallback works.
- **D6.3 README:** what/why, GIF/screenshots, features, architecture diagram, **Serverpod features used** (streaming, ORM + migrations, future calls, file uploads, auth, web hosting, Cloud), build/run instructions (`dart install serverpod_cli`, `serverpod start`, tests), **AI-assistance disclosure**, privacy and limits, measured accuracy, licence, credits (MediaPipe, WHO reference, Cameron concept inspiration).
- **D6.4 Demo video (< 2 min, public on YouTube/Vimeo, no copyrighted music, no third-party trademarks; shows the app on its target device):** storyboard — 0:00–0:10 problem (WHO fall statistic, one line) · 0:10–0:35 type a rule sentence → workflow graph → save · 0:35–1:05 clip S1: person enters zone after hours → incident on the dashboard with blurred snapshot → toast · 1:05–1:30 clip S2: fall → escalation timer → acknowledge (show phone-width view) · 1:30–1:50 Detector Lab numbers + privacy (on-device detection, blurred evidence, opt-in cloud) · 1:50–2:00 Serverpod recap + AI disclosure + honesty line. Film the screen at 1080p; narrate calmly; do not rely on production polish (not scored separately).
- **D6.5 Submission text:** features; how it was built (Serverpod 4 + Flutter web + MediaPipe module + pure-Dart engine); **AI disclosure** (state which tools assisted); testing instructions (public URL, "Open the demo", no login); repo URL (hackathon-created private repo, or own repo shared with the three judge emails).
- **D6.6 Prize extras:** submit the **Most Valuable Feedback** form (actionable Serverpod SDK/docs/tooling feedback from `docs/FEEDBACK.md`); publish a **public build post** clearly identifying the hackathon.
- **D6.7 Final rules checklist** (all must be true) and **submit early**; re-open the submission page to verify all fields; keep the deployment untouched until after judging except for fixing breakage.

### 14.2 Final rules checklist
- [ ] Project created during 15 Sep – 14 Oct 2026 (git history shows it); original work; no code copied from Cameron or others.
- [ ] Serverpod is the backend; app is full-stack and works; third-party integrations used within their terms (MediaPipe, Gemini free tier, Telegram).
- [ ] Repo accessible to judges; contains all source, assets, instructions.
- [ ] Text description includes features, how it was built, **AI tool disclosure**.
- [ ] Build/run instructions work from a clean machine.
- [ ] Demo video < 2 min, public, shows the app on its device, no third-party trademarks/copyrighted music.
- [ ] Public working link without login; deployment alive through 22 Oct; replay mode works without a camera.
- [ ] Submitted before 14 Oct 2026 23:59 CEST.

---

## 15. CROSS-CUTTING ENGINEERING STANDARDS
- **Git:** small commits, conventional messages (`feat:`, `fix:`, `chore:`, `docs:`, `test:`); commit after each task; tag `phase-N-complete`.
- **Code:** `flutter_lints`/`lints`; `dart format`; files ≲ 400 lines; no `print` (use logging); public APIs documented.
- **Testing pyramid:** engine unit/property tests (most) → endpoint tests → JS unit tests → widget + golden tests → one integration test for the golden path → Detector Lab for detection accuracy.
- **Security:** secrets only in gitignored config / Cloud secrets; validate inputs server-side; owner scoping on every query; no sensitive data in logs; Gemini key never in the client bundle.
- **Privacy:** local detection; blurred stored evidence; 7-day retention; delete-my-data; opt-in cloud verification; no face recognition.
- **Docs:** keep `docs/STATUS.md` current; decisions in `DECISIONS.md`; dependency licences in `DEPENDENCIES.md`; rule checks per hackathon in `HACKATHONS.md`.
- **Feedback log:** whenever Serverpod docs/tooling cause friction, append to `docs/FEEDBACK.md`.

---

## 16. RISK REGISTER

| Risk | Impact | Mitigation |
|---|---|---|
| Flutter web ↔ JS vision wiring (video element, overlay, callbacks) is fiddly | Core demo broken | Do it first in Phase 2 with a thin bridge; keep drawing in JS; test early on Chrome; keep replay mode as fallback |
| Fall heuristic false alarms (bending, sitting, odd camera angles) | Credibility | Tune on own clips incl. negatives; publish metrics; show confidence; require motionless confirmation for high severity; document failure modes |
| Browser performance on judges' machines | "Doesn't work" | Degrade ladder; replay mode; preloaded clips; test with CPU throttling |
| Gemini quota/availability/terms | LLM features fail | Rate limiter, cache, circuit breaker, fallbacks (grammar → form); never evade quotas; label "AI limited" |
| Free-tier Gemini data use (people images) | Privacy | Cloud verification off by default, consent text, ephemeral crops, demo with own clips |
| Serverpod Cloud free-tier limits unknown | Slow/failed runs | Early throwaway deploy; measure; small payloads; limits; replay mode |
| Helmet detection reliability | Over-claiming | S4 is stretch, gated behind verification; clearly labelled; not a headline claim |
| Serverpod 4 syntax/API drift vs memory | Wasted time | Use agent skills + MCP + docs; log friction in FEEDBACK.md |
| Rules interpretation (originality, reuse across hackathons) | Disqualification | Clean-room build, git history, `HACKATHONS.md`; ask nate@builderbase.com for clarifications before the deadline |
| Scope (many moving parts) | Unfinished core | Cut lines per phase; the golden path (S1–S3, no Gemini, replay) is the minimum shippable product |
| Cameron-like "wow" depends on LLM | Less flashy | Make the sentence→workflow moment polished; show escalation and measured accuracy; honest craft |

**Minimum shippable product (if time runs short):** Phases 1–3 for S1–S3 with replay mode + grammar parser + live dashboard + README + video. Everything else is additive.

---

## 17. APPENDICES

### Appendix A — `docs/STATUS.md` template
```
# STATUS (update before every stop)
Last updated: <date/time> by <agent/session>
Current phase: <n>   Current task: <id>
## Done
- [x] P1.1 … (commit <sha>)
## In progress
- [ ] …
## Next
- …
## Known issues / blockers
- …
## How to run right now
- commands…
## Measurements
- Vision fps/latency: …  Signal→dashboard latency: …  Cloud limits: …  Lab precision/recall: …
## Mock markers remaining
- file:line …
## Privacy audit checklist
- [ ] no unblurred images stored  [ ] crops never persisted  [ ] no third-party runtime requests  [ ] secrets not in client/git
```

### Appendix B — `docs/DECISIONS.md` entry format
```
## D-<number> <title> (<date>)
Context: …  Decision: …  Alternatives considered: …  Consequences: …  Affects: plan.md §…
```
Seed entries to write in Phase 1: D-1 detection in browser/rules on server; D-2 unary uplink + streaming downlink; D-3 Gemini → grammar → form pipeline; D-4 cloud verification opt-in; D-5 avoid AGPL detector weights.

### Appendix C — Owner-only tasks (an AI agent cannot do these)
1. **Film test clips** (start in Phase 1): scenarios S1–S3 (+S4 if attempting) with **≥ 3 positive takes and ≥ 3 negative takes each** (negatives: sitting down, bending to pick something up, walking past a zone, a second person, low light). Fixed camera, 16:9, 640×360–720p, 15–30 s each, H.264 MP4 without audio, **≤ 5 MB each**. Only film consenting people; no third-party logos/trademarks visible; stage falls **only onto a crash mat or controlled lowering to a soft surface** — never risk injury. Write `tools/eval/labels.json` with expected event times per clip.
2. Create a **Gemini API key** in Google AI Studio (free tier) and put it in `argus_server/config/passwords.yaml`; confirm the model name available to the project.
3. (Optional) Create a **Telegram bot** with BotFather and add the token to `passwords.yaml`.
4. Create the **Serverpod Cloud** account/project; run the early throwaway deploy; later the real deploy.
5. Register on **BuilderBase** for the hackathon and request/create the submission repo; record and upload the demo video; publish the build post; submit the feedback form.

### Appendix D — Glossary
**Signal:** a geometric fact computed in the browser (e.g. person in zone, fall suspected). **Rule:** structured condition + actions + escalation. **Incident:** a fired rule with evidence, status and timeline. **Zone:** a normalised polygon on a camera view. **Replay:** recorded real detector output replayed as if live (always labelled). **Verification:** optional cloud check of a trigger by a vision-language model. **Detector Lab:** measured accuracy on our own labelled clips.

### Appendix E — References
- Serverpod 4 release notes: https://serverpod.dev/blog/serverpod-4 · Docs: https://docs.serverpod.dev (quickstart, streaming methods, file uploads, models, future calls, auth)
- Hackathon page: https://builderbase.dev/event/build-something-real-the-serverpod-hackathon (Official Rules PDF is authoritative)
- WHO falls fact sheet: https://www.who.int/news-room/fact-sheets/detail/falls
- MediaPipe Object Detector (EfficientDet-Lite0, COCO): https://ai.google.dev/edge/mediapipe/solutions/vision/object_detector · Pose Landmarker docs on the same site
- Gemini API rate limits and pricing: https://ai.google.dev/gemini-api/docs/rate-limits (quotas are per project, not per key; confirm free-tier model eligibility and data-use terms in AI Studio)
- Concept inspiration only (no code reuse): Cameron, UC Berkeley AI Hackathon 2025 — https://devpost.com/software/cameron-9biv60

### Appendix F — Open items for the owner before Phase 1
1. Confirm the four demo scenarios (S1–S4) and that you can film clips.
2. Confirm that Telegram alerts are optional, not required.
3. Confirm the name **Argus** (the many-eyed watchman of Greek myth). It is a common name, so check availability on GitHub, domains and app stores before publishing, and consider a distinguishing subtitle such as "Argus — safety workflows for cameras".
4. Review this plan; then `docs/goal.md` is written from sections 1–2 and 14.
