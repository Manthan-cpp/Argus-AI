# Architecture & Design Decisions

## D-1 Detection in Browser, Rules on Server (2026-10-08)
- **Context:** Streaming raw CCTV/webcam video feeds to a cloud server is expensive, bandwidth-heavy, requires server-side GPUs, and violates camera privacy.
- **Decision:** All computer vision detection (MediaPipe person & pose) runs strictly on-device in the browser via WebAssembly. The browser emits only low-bandwidth, non-identifying geometric signals (`SignalBatch`). The Serverpod backend evaluates rules, stores incidents, and orchestrates escalation.
- **Consequences:** Zero cloud video bandwidth, low server resource footprint (runs on Serverpod free tier), privacy by design.

## D-2 Unary Uplink + Streaming Downlink (2026-10-08)
- **Context:** Signal transmission from browser to server versus incident delivery from server to browser.
- **Decision:** Signals are transmitted via batched unary HTTP calls (`SignalEndpoint.send`) every ~500ms on state changes or 2s heartbeats. Real-time updates to dashboards use Serverpod streaming methods (`IncidentEndpoint.watch`).
- **Consequences:** Resilient uplink that tolerates intermittent network jitter without breaking long-lived sockets, while giving judges a true real-time streaming experience.

## D-3 Gemini -> Grammar -> Form Tri-stage Pipeline (2026-10-08)
- **Context:** Translating plain-language safety rules into deterministic `RuleSpec` objects.
- **Decision:** Tri-stage pipeline: (1) Server-side Gemini proxy (structured JSON output), (2) pure-Dart grammar parser in `argus_engine` as offline/quota-exhausted fallback, (3) visual form builder if sentence is ambiguous.
- **Consequences:** Reliable execution regardless of API quotas; zero disruption when offline; full transparency as the UI always shows the parsed workflow nodes.

## D-4 Cloud Verification Opt-In & Privacy Safeguards (2026-10-08)
- **Context:** AI Studio free-tier terms allow human review/training on inputs.
- **Decision:** Cloud verification (Gemini Vision) is OFF by default. Stored snapshots have heads blurred by default using pose landmarks. When cloud verification is enabled, ephemeral crops (<=60 KB) are sent and immediately discarded. No biometric or facial recognition is ever implemented.
- **Consequences:** Full compliance with hackathon and API terms, protecting user privacy.

## D-5 Safe Third-Party Dependencies (2026-10-08)
- **Context:** Licensing restrictions in hackathon rules and open-source ecosystems (avoiding viral AGPL models).
- **Decision:** Standardize on Apache 2.0 / MIT models and libraries: Google MediaPipe Tasks Vision (EfficientDet-Lite0, Pose Landmarker Lite).
- **Consequences:** Clean licensing compliance without AGPL encumbrance.
