# Dependencies & Licensing

All third-party libraries, models, and tools used in Argus are strictly free, open-source, and compliant with hackathon guidelines.

| Name | Role | License | Source | Notes |
|---|---|---|---|---|
| **Serverpod 4** | Backend application server | BSD-3-Clause | pub.dev / GitHub | Core framework |
| **Flutter & Dart SDK** | Web frontend | BSD-3-Clause | flutter.dev | Web target |
| **MediaPipe Tasks Vision** | Client-side vision inference | Apache 2.0 | `@mediapipe/tasks-vision@1.1.0` | Vendored offline in `web/vision/vendor` (WASM + JS) |
| **EfficientDet-Lite0** | Object detection (person) | Apache 2.0 | Google Storage | `web/vision/models/efficientdet_lite0.tflite` (float32, 13.2 MB) |
| **Pose Landmarker (Lite)** | Body pose estimation | Apache 2.0 | Google Storage | `web/vision/models/pose_landmarker_lite.task` (float16, 5.5 MB) |
| **Google Gemini API** | Natural language interpretation & vision verification | Free Tier TOS | Google AI Studio | Server-side proxy only |
| **flutter_riverpod** | State management | MIT | pub.dev | Reactive architecture |
| **go_router** | Declarative routing | BSD-3-Clause | pub.dev | URL deep linking |
| **fl_chart** | Signal & incident charts | MIT | pub.dev | Interactive graphs |
| **flutter_animate** | Micro-interactions & animations | MIT | pub.dev | Fluid motion design |
