# Methodology & Signal Heuristics

## Overview
Argus evaluates real-time safety signals locally in the client using geometry calculations derived from MediaPipe bounding boxes and 33 pose landmark keypoints.

## Signals & Calculations

### 1. Foot Point & Zone Containment
- When ankle keypoints (landmarks 27 & 28) have confidence $\ge 0.5$, the ground contact point is their midpoint.
- Fallback: bottom-center of the detected person bounding box.
- Containment in user-defined polygons uses a standard ray-casting point-in-polygon algorithm in normalized coordinates ($0.0 \dots 1.0$).

### 2. Motion Score & Motionless Duration
- Normalized displacement of bounding box center and upper-body landmarks over a 1.0s sliding window.
- When motion is below threshold ($0.02$), `motionlessMs` accumulates.

### 3. Fall Detection Heuristic
- **Aspect Ratio change:** Rapid transition from height > width to width > height ($aspect > 1.0$).
- **Hip Drop Ratio:** Rapid descent of hip midpoint relative to person height within a 1.0s window.
- **Torso Angle:** Deviation of the shoulder-midpoint to hip-midpoint vector from vertical.
$$fallScore = \text{clamp}(0.40 \cdot [aspect > 1.0] + 0.35 \cdot \min(1.0, hipDrop / 0.35) + 0.25 \cdot \min(1.0, torsoAngle / 70^\circ), 0.0, 1.0)$$
- Suspected fall is flagged when $fallScore \ge 0.60$.

## Known Edge Cases & Mitigation
- **Sitting / crouching:** mitigated by requiring a rapid drop velocity and post-fall motionless duration for high severity.
- **Bending over:** mitigated by posture duration threshold (must remain prone).
- **Camera angle extremes:** high-angle / overhead cameras alter aspect ratios; detector lab metrics document precision/recall per camera viewpoint.
