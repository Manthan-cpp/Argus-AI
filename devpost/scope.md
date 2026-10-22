---
doc: scope
status: approved
---

# Argus AI

Autonomous visual threat interception and tactical safety dispatch platform powered by edge computer vision and a high-concurrency Dart engine.

## The Unique Kernel
Argus AI transforms passive surveillance cameras into active, sub-second threat sentinels. Instead of recording tragedies for post-mortem investigations, it combines 33-point biomechanical pose tracking and sub-pixel polygon geofencing to detect falls and unauthorized boundary breaches in real time, instantly firing automated escalation state machines.

## Who It's For
An industrial facility safety officer, warehouse operations supervisor, or transit security dispatcher who is responsible for monitoring dozens of camera perspectives and cannot afford human fatigue delays during active life-safety emergencies.

## The Core Loop
1. Operator launches the interactive control room and connects a live camera feed or simulated test sequence.
2. Operator establishes monitored spatial safety zones by drawing custom polygon vertices directly onto the camera view.
3. The on-device vision pipeline tracks human bodies and skeletal landmarks at 60 FPS.
4. When a posture collapse (fall) or restricted boundary intersection occurs, an alert is triggered in $<100\text{ ms}$.
5. The dispatcher acknowledges the incident, triggering tactical dispatch protocols and stopping the automatic escalation timer.

## Inspiration & Identity
* **Aesthetic:** Tactical Security Operations Center (SOC)—high-contrast dark mode, pitch-black canvas, luminous status beacons, and crisp monospace telemetry.
* **Tone:** Authoritative, high-precision, mission-critical, assistive.
* **References:** Military command-and-control heads-up displays, real-time industrial telemetry monitors.

## Why This Matters to the Learner
Over 1 billion surveillance cameras operate globally, yet security personnel miss up to 95% of critical incidents after 20 minutes of screen fatigue. Proving that an intelligent agent and client-side vision pipeline can actively intercept life-safety threats before they turn fatal is a massive engineering milestone.

## What "Working" Looks Like
A running Flutter application showing a live camera feed with real-time skeletal landmark overlays. When a worker falls or crosses into an operator-defined restricted zone:
* The system detects the condition instantly without human intervention.
* The zone strobes red with a computed kinematic threat score.
* A high-priority incident card appears in the dispatch queue with an active countdown timer.
* A single click or command acknowledges the alert and logs the verified evidence snapshot.

## The POC Boundary
* **Included:**
  * Real-time camera feed ingestion (live webcam and pre-recorded industrial test clips).
  * 33-point skeletal pose estimation and fall kinematic scoring ($<200\text{ ms}$ latency).
  * Interactive canvas polygon zone drawing and sub-pixel point-in-polygon collision math.
  * Natural language rule compilation translating English safety policies into active triggers.
  * Tactical control room console with real-time incident queues and acknowledgment workflows.
  * Distributed pure-Dart backend managing state synchronization and persistent escalation timers.

## Later
* Integration with physical facility hardware (magnetic door locks, strobe sirens, turnstiles).
* Multi-site clustered mesh deployment across thousands of distributed edge nodes.
* Automated emergency dispatch packets forwarded to municipal first responder gateways.

## Explicitly Cut
* **Facial Recognition & Identity Profiling:** Omitted by design to protect civil liberties and worker privacy; tracking is strictly skeletal and geometric.
* **Complex Multi-Camera Re-Identification:** Cut from the proof of concept to focus strictly on zero-latency single-frame zone and posture interception.
