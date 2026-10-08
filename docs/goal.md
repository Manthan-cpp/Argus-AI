# Argus — Goal & Purpose

## Executive Summary
Argus turns ordinary cameras into automated safety workflows. Using a single English sentence, a supervisor defines a safety policy. The client browser performs local detection (MediaPipe WASM), and the Serverpod backend evaluates rules, stores blurred evidence incidents, and triggers automated escalations.

## Hackathon Target
- **Event:** Build Something Real — The Serverpod Hackathon
- **Deadline:** 14 October 2026, 23:59 CEST
- **Backend Stack:** Serverpod 4 (Dart) + Postgres + Serverpod Cloud
- **Frontend Stack:** Flutter Web + MediaPipe Vision (WASM) + Riverpod + GoRouter

## Core Objectives
1. **Zero-Friction Demo:** Instant "Open Demo" button that seeds realistic workspaces (S1–S4) without requiring an account or mandatory webcam permissions.
2. **Deep Serverpod Utilization:**
   - Serverpod ORM & Postgres for workspace, cameras, zones, rules, and incident tracking.
   - Serverpod Streaming for live incident feeds on the monitor.
   - Serverpod Future Calls for multi-stage escalation policies and retention cleanup.
   - Serverpod File Upload for encrypted/blurred evidence snapshot storage.
   - Serverpod Auth for anonymous guest sessions.
3. **Immersive Control Room UI/UX:**
   - Dark, high-density, mission-critical aesthetic with luminous cyan accent (`#38BDF8`).
   - Dynamic mouse-tracking glow, smooth stagger-reveal animations, and scroll interactions.
   - Interactive Rule Studio with visual workflow graph generation.
   - Live Monitor with real-time zone and pose overlays.
4. **Honesty & Assistive Labeling:** Clear confidence meters, "unverified" status flags, and the Detector Lab publishing exact precision/recall metrics.
