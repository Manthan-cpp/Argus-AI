/**
 * ARGUS AI - Real-time On-Device Vision Engine & Bridge
 * 
 * Runs client-side MediaPipe Tasks Vision (ObjectDetector + PoseLandmarker)
 * via WebAssembly. Computes spatial geometry, IoU centroid tracking,
 * point-in-polygon zone checks, fall heuristics, and privacy head-blurring.
 * 
 * Zero third-party runtime fetches. Zero unblurred video uploaded.
 */

(function (window) {
  'use strict';

  // --- Point-in-polygon ray casting ---
  function pointInPolygon(px, py, polygon) {
    if (!polygon || polygon.length < 3) return false;
    let inside = false;
    for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      const xi = polygon[i].x, yi = polygon[i].y;
      const xj = polygon[j].x, yj = polygon[j].y;
      const intersect = ((yi > py) !== (yj > py)) &&
        (px < (xj - xi) * (py - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  // --- IoU Bounding Box Overlap ---
  function computeIoU(b1, b2) {
    const xLeft = Math.max(b1.x, b2.x);
    const yTop = Math.max(b1.y, b2.y);
    const xRight = Math.min(b1.x + b1.w, b2.x + b2.w);
    const yBottom = Math.min(b1.y + b1.h, b2.y + b2.h);
    if (xRight <= xLeft || yBottom <= yTop) return 0.0;
    const intersection = (xRight - xLeft) * (yBottom - yTop);
    const union = (b1.w * b1.h) + (b2.w * b2.h) - intersection;
    return union > 0 ? intersection / union : 0.0;
  }

  // --- Bounding Box Spatial Similarity (IoU + Centroid + Ground Proximity) ---
  function computeBboxSimilarity(b1, b2) {
    const iou = computeIoU(b1, b2);
    if (iou >= 0.25) return 1.0 + iou;

    const cx1 = b1.x + b1.w / 2;
    const cy1 = b1.y + b1.h / 2;
    const cx2 = b2.x + b2.w / 2;
    const cy2 = b2.y + b2.h / 2;
    const dist = Math.hypot(cx1 - cx2, cy1 - cy2);

    if (iou >= 0.08 && dist < 0.16) return 0.8 + iou;

    // Ground contact proximity (bottom-center of bbox):
    // When an upright person collapses or sits, their horizontal position on the floor remains nearly identical!
    const footX1 = cx1;
    const footY1 = b1.y + b1.h;
    const footX2 = cx2;
    const footY2 = b2.y + b2.h;
    const footDist = Math.hypot(footX1 - footX2, footY1 - footY2);
    if (footDist < 0.16) {
      return 0.85 + (0.16 - footDist);
    }

    const diag = Math.hypot(b2.w, b2.h);
    const maxAllowableDist = Math.max(0.08, Math.min(0.24, diag * 1.6));
    if (dist < maxAllowableDist) {
      const score = 0.5 * (1.0 - dist / maxAllowableDist);
      const area1 = b1.w * b1.h;
      const area2 = b2.w * b2.h;
      const ratio = Math.min(area1, area2) / Math.max(area1, area2, 1e-6);
      if (ratio > 0.15) {
        return score + ratio * 0.35;
      }
    }
    return 0.0;
  }

  class ArgusVisionEngine {
    constructor() {
      this.isInitialized = false;
      this.isRunning = false;
      this.mode = 'live'; // 'live' | 'replay'
      this.videoEl = null;
      this.canvasEl = null;
      this.ctx = null;
      
      // Configuration & Paths
      this.wasmBaseUrl = 'vision/vendor/wasm';
      this.detectorModelPath = 'vision/models/efficientdet_lite0.tflite';
      this.poseModelPath = 'vision/models/pose_landmarker_lite.task';
      
      // MediaPipe instances
      this.objectDetector = null;
      this.poseLandmarker = null;
      this.hasMediaPipeLoaded = false;
      this._lastDetectorTimestamp = 0;
      this._lastPoseTimestamp = 0;
      this.procCanvas = null;
      this.procCtx = null;
      
      // State
      this.zones = [];
      this.tracks = new Map(); // trackId -> Track
      this.nextTrackId = 1;
      this.stream = null;
      
      // Callbacks
      this.signalCallback = null;
      this.statusCallback = null;
      
      // Timing & Telemetry
      this.targetFps = 8;
      this.lastFrameTime = 0;
      this.frameCount = 0;
      this.measuredFps = 0.0;
      this.avgLatencyMs = 0.0;
      this.degradeLevel = 0; // 0: full, 1: alternate pose, 2: low resolution
      
      // Replay
      this.isRecording = false;
      this.recordedBatches = [];
      this.replayBatches = [];
      this.replayTimer = null;
      this.replayIndex = 0;
      
      // Batch emission
      this.lastBatchSentAt = 0;
      this.batchSeq = 1;
      this.lastEmittedStateHash = '';
      
      // Bound handlers
      this._processFrame = this._processFrame.bind(this);
    }

    notifyStatus(status, detail) {
      if (this.statusCallback) {
        const payload = { status, detail, fps: this.measuredFps, latencyMs: this.avgLatencyMs };
        try {
          this.statusCallback(JSON.stringify(payload));
        } catch (_) {
          try { this.statusCallback(payload); } catch (e) {}
        }
      }
    }

    async init(rawOptions = {}) {
      let options = rawOptions;
      if (typeof options === 'string') {
        try { options = JSON.parse(options); } catch (e) { options = {}; }
      }
      if (options && options.wasmBaseUrl) this.wasmBaseUrl = options.wasmBaseUrl;
      if (options && options.detectorModelPath) this.detectorModelPath = options.detectorModelPath;
      if (options && options.poseModelPath) this.poseModelPath = options.poseModelPath;

      this.notifyStatus('initializing', 'Loading on-device vision WASM and models...');

      try {
        // Attempt loading MediaPipe Tasks Vision bundle
        if (window.FilesetResolver && (window.ObjectDetector || window.tasksVision?.ObjectDetector)) {
          const visionPkg = window.tasksVision || window;
          const vision = await visionPkg.FilesetResolver.forVisionTasks(this.wasmBaseUrl);
          
          this.objectDetector = await visionPkg.ObjectDetector.createFromOptions(vision, {
            baseOptions: {
              modelAssetPath: this.detectorModelPath,
              delegate: 'GPU'
            },
            runningMode: 'IMAGE',
            scoreThreshold: 0.15,
            categoryAllowlist: ['person']
          });

          this.poseLandmarker = await visionPkg.PoseLandmarker.createFromOptions(vision, {
            baseOptions: {
              modelAssetPath: this.poseModelPath,
              delegate: 'GPU'
            },
            runningMode: 'IMAGE',
            numPoses: 8,
            minPoseDetectionConfidence: 0.15,
            minPosePresenceConfidence: 0.15,
            minTrackingConfidence: 0.15
          });

          this.hasMediaPipeLoaded = true;
          this.notifyStatus('ready', 'MediaPipe WebAssembly & models loaded (GPU accelerated)');
        } else {
          // If vendor script not loaded via global script tag yet, try dynamic import
          try {
            const visionPkg = await import('./vendor/vision_bundle.mjs');
            const vision = await visionPkg.FilesetResolver.forVisionTasks(this.wasmBaseUrl);
            
            this.objectDetector = await visionPkg.ObjectDetector.createFromOptions(vision, {
              baseOptions: {
                modelAssetPath: this.detectorModelPath,
                delegate: 'GPU'
              },
              runningMode: 'IMAGE',
              scoreThreshold: 0.15,
              categoryAllowlist: ['person']
            });

            this.poseLandmarker = await visionPkg.PoseLandmarker.createFromOptions(vision, {
              baseOptions: {
                modelAssetPath: this.poseModelPath,
                delegate: 'GPU'
              },
              runningMode: 'IMAGE',
              numPoses: 8,
              minPoseDetectionConfidence: 0.15,
              minPosePresenceConfidence: 0.15,
              minTrackingConfidence: 0.15
            });

            this.hasMediaPipeLoaded = true;
            this.notifyStatus('ready', 'MediaPipe WebAssembly models loaded successfully');
          } catch (importErr) {
            console.warn('[ArgusVision] Real MediaPipe bundle import failed, using resilient visual fallback:', importErr);
            this.hasMediaPipeLoaded = false;
            this.notifyStatus('fallback', 'Running in resilient simulation mode (WebGL/WASM fallback)');
          }
        }
      } catch (err) {
        console.warn('[ArgusVision] MediaPipe init error, enabling fallback:', err);
        this.hasMediaPipeLoaded = false;
        this.notifyStatus('fallback', 'MediaPipe models unavailable; visual simulation active');
      }

      this.isInitialized = true;
      return true;
    }

    attach(rawOptions = {}) {
      let options = rawOptions;
      if (typeof options === 'string') {
        try { options = JSON.parse(options); } catch (e) { options = {}; }
      }
      const { videoId, canvasId, videoElement, canvasElement } = options || {};
      this.videoEl = videoElement || (videoId ? document.getElementById(videoId) : null);
      this.canvasEl = canvasElement || (canvasId ? document.getElementById(canvasId) : null);

      if (this.canvasEl) {
        this.ctx = this.canvasEl.getContext('2d', { willReadFrequently: true });
      }

      return !!(this.videoEl && this.canvasEl);
    }

    setZones(zones) {
      if (typeof zones === 'string') {
        try {
          this.zones = JSON.parse(zones);
        } catch (e) {
          console.error('[ArgusVision] Failed to parse zones JSON:', e);
        }
      } else if (Array.isArray(zones)) {
        this.zones = zones;
      }
    }

    onSignals(cb) {
      this.signalCallback = cb;
    }

    onStatus(cb) {
      this.statusCallback = cb;
    }

    async start(rawOptions = {}) {
      let options = rawOptions;
      if (typeof options === 'string') {
        try {
          options = JSON.parse(options);
        } catch (e) {
          console.error('[ArgusVision] Failed to parse start options:', e);
          options = {};
        }
      }
      const { targetFps = 8, sourceKind = 'webcam', sourceUrl = null } = options || {};
      console.log('[ArgusVision] Pipeline starting. sourceKind:', sourceKind, 'sourceUrl:', sourceUrl);

      // ALWAYS stop any existing hardware webcam stream so it never leaks onto screen
      if (this.stream) {
        this.stream.getTracks().forEach(t => t.stop());
        this.stream = null;
      }

      if (!this.videoEl) {
        this.videoEl = document.getElementById('argus-video-element');
        this.canvasEl = document.getElementById('argus-canvas-element');
        if (this.canvasEl) {
          this.ctx = this.canvasEl.getContext('2d', { willReadFrequently: true });
        }
      }

      if (!this.videoEl) {
        // Auto-create video and canvas elements if HtmlElementView hasn't finished mounting
        const container = document.getElementById('argus-vision-container') || document.createElement('div');
        container.id = 'argus-vision-container';
        if (!container.parentElement) {
          container.style.position = 'relative';
          container.style.width = '100%';
          container.style.height = '100%';
          document.body.appendChild(container);
        }

        this.videoEl = document.createElement('video');
        this.videoEl.id = 'argus-video-element';
        this.videoEl.autoplay = true;
        this.videoEl.playsInline = true;
        this.videoEl.muted = true;
        this.videoEl.style.width = '100%';
        this.videoEl.style.height = '100%';
        this.videoEl.style.objectFit = 'contain';
        container.appendChild(this.videoEl);

        this.canvasEl = document.createElement('canvas');
        this.canvasEl.id = 'argus-canvas-element';
        this.canvasEl.style.position = 'absolute';
        this.canvasEl.style.top = '0';
        this.canvasEl.style.left = '0';
        this.canvasEl.style.width = '100%';
        this.canvasEl.style.height = '100%';
        this.canvasEl.style.pointerEvents = 'none';
        container.appendChild(this.canvasEl);

        this.ctx = this.canvasEl.getContext('2d', { willReadFrequently: true });
      }

      this.targetFps = targetFps;
      this.isRunning = true;
      this.frameCount = 0;
      this.tracks.clear();

      if (sourceKind === 'file') {
        // 100% detach webcam MediaStream
        this.videoEl.pause();
        this.videoEl.srcObject = null;

        if (!sourceUrl || sourceUrl === 'local' || sourceUrl.trim() === '') {
          this.notifyStatus('error', 'No video file selected for this camera. Please click "Change MP4".');
          throw new Error('No local video file selected');
        }

        this.videoEl.src = sourceUrl;
        this.videoEl.loop = false; // Do NOT loop automatically
        this.videoEl.muted = true;
        this.videoEl.playsInline = true;
        this.videoEl.autoplay = true;

        if (this._onVideoEnded) this.videoEl.removeEventListener('ended', this._onVideoEnded);
        this._onVideoEnded = () => {
          console.log('[ArgusVision] Video ended. Resetting tracks and canvas overlay.');
          this.isRunning = false;
          this.tracks.clear();
          if (this.ctx && this.canvasEl) {
            this.ctx.clearRect(0, 0, this.canvasEl.width, this.canvasEl.height);
          }
          this.notifyStatus('ended', 'Video playback ended. Click Replay to play again.');
          // Emit clean reset batch to clear Flutter telemetry
          if (this.signalCallback) {
            const resetBatch = {
              cameraId: 1,
              sentAtMs: Date.now(),
              seq: this.batchSeq++,
              signals: [{
                tsMs: Date.now(),
                kind: 'reset',
                personCount: 0,
                persons: []
              }]
            };
            try { this.signalCallback(JSON.stringify(resetBatch)); } catch (_) {
              try { this.signalCallback(resetBatch); } catch (e) {}
            }
          }
        };
        this.videoEl.addEventListener('ended', this._onVideoEnded);

        if (this._onVideoPlay) this.videoEl.removeEventListener('play', this._onVideoPlay);
        this._onVideoPlay = () => {
          console.log('[ArgusVision] Video started. Resetting fresh tracks.');
          this.tracks.clear();
          if (this.ctx && this.canvasEl) {
            this.ctx.clearRect(0, 0, this.canvasEl.width, this.canvasEl.height);
          }
        };
        this.videoEl.addEventListener('play', this._onVideoPlay);

        try {
          await this.videoEl.play();
          this.notifyStatus('running', 'Video file playing: ' + sourceUrl);
        } catch (playErr) {
          console.warn('[ArgusVision] video.play() waiting for canplay:', playErr);
          try {
            await new Promise((resolve, reject) => {
              const onCanPlay = () => {
                this.videoEl.removeEventListener('canplay', onCanPlay);
                this.videoEl.removeEventListener('error', onError);
                resolve();
              };
              const onError = () => {
                this.videoEl.removeEventListener('canplay', onCanPlay);
                this.videoEl.removeEventListener('error', onError);
                reject(new Error('Failed to load video file. Please re-select the MP4 file.'));
              };
              if (this.videoEl.readyState >= 3) {
                resolve();
              } else {
                this.videoEl.addEventListener('canplay', onCanPlay);
                this.videoEl.addEventListener('error', onError);
                this.videoEl.load();
              }
            });
            await this.videoEl.play();
            this.notifyStatus('running', 'Video file playing: ' + sourceUrl);
          } catch (retryErr) {
            this.notifyStatus('error', retryErr.message);
            throw retryErr;
          }
        }
      } else if (sourceKind === 'webcam') {
        this.videoEl.pause();
        this.videoEl.src = '';
        this.videoEl.removeAttribute('src');

        try {
          const constraints = {
            video: {
              width: { ideal: 1280 },
              height: { ideal: 720 },
              facingMode: 'user'
            },
            audio: false
          };
          this.stream = await navigator.mediaDevices.getUserMedia(constraints);
          this.videoEl.srcObject = this.stream;
          await this.videoEl.play();
          this.notifyStatus('running', 'Live webcam feed connected');
        } catch (err) {
          this.notifyStatus('error', 'Camera access denied or unavailable: ' + err.message);
          throw err;
        }
      } else {
        console.warn('[ArgusVision] Unknown sourceKind:', sourceKind);
      }

      this._scheduleNextFrame();
      return true;
    }

    stop() {
      this.isRunning = false;
      if (this.stream) {
        this.stream.getTracks().forEach(t => t.stop());
        this.stream = null;
      }
      if (this.videoEl) {
        this.videoEl.pause();
        this.videoEl.srcObject = null;
        this.videoEl.src = '';
        this.videoEl.removeAttribute('src');
      }
      if (this.ctx && this.canvasEl) {
        this.ctx.clearRect(0, 0, this.canvasEl.width, this.canvasEl.height);
      }
      if (this.replayTimer) {
        clearInterval(this.replayTimer);
        this.replayTimer = null;
      }
      this.notifyStatus('stopped', 'Vision pipeline stopped');
    }

    setMode(mode) {
      this.mode = mode; // 'live' or 'replay'
      this.notifyStatus(mode, 'Switched to ' + mode + ' mode');
    }

    _scheduleNextFrame() {
      if (!this.isRunning) return;
      if ('requestVideoFrameCallback' in this.videoEl) {
        this.videoEl.requestVideoFrameCallback(this._processFrame);
      } else {
        requestAnimationFrame(this._processFrame);
      }
    }

    async _processFrame(nowMs) {
      if (!this.isRunning) return;
      if (this.videoEl && this.videoEl.ended) return;

      const now = performance.now();
      const minInterval = 1000 / this.targetFps;
      if (now - this.lastFrameTime < minInterval) {
        this._scheduleNextFrame();
        return;
      }

      // If video was seeked backwards (user restarted or replayed), reset tracks
      if (this.videoEl && this.videoEl.currentTime < (this._lastVideoCurrentTime || 0) - 0.5) {
        this.tracks.clear();
      }
      if (this.videoEl) {
        this._lastVideoCurrentTime = this.videoEl.currentTime;
      }

      const frameStartTime = performance.now();
      this.frameCount++;
      this.lastFrameTime = now;

      // Ensure canvas resolution matches video display
      this._syncCanvasSize();

      let detectedPersons = [];

      if (this.hasMediaPipeLoaded && this.objectDetector && this.videoEl.readyState >= 2) {
        try {
          const vw = this.videoEl.videoWidth || 640;
          const vh = this.videoEl.videoHeight || 480;

          // Prepare intermediate processing canvas for reliable frame capture
          if (!this.procCanvas) {
            this.procCanvas = document.createElement('canvas');
          }
          const procW = Math.min(vw, 1280);
          const procH = Math.min(vh, 720);
          if (this.procCanvas.width !== procW || this.procCanvas.height !== procH) {
            this.procCanvas.width = procW;
            this.procCanvas.height = procH;
            this.procCtx = this.procCanvas.getContext('2d', { willReadFrequently: true });
          }

          // Blit current video frame to processing canvas
          this.procCtx.drawImage(this.videoEl, 0, 0, procW, procH);

          // 1. Primary detection: ObjectDetector (runs on procCanvas)
          const detections = this.objectDetector.detect(this.procCanvas);
          detectedPersons = this._extractPersons(detections, procW, procH);
          
          // 2. Secondary detection: PoseLandmarker (runs on procCanvas)
          if (this.poseLandmarker) {
            const poseResult = this.poseLandmarker.detect(this.procCanvas);
            this._matchPosesToDetections(detectedPersons, poseResult);
          }

          // Deduplicate and fuse overlapping multi-pass detections
          detectedPersons = this._filterOverlappingDetections(detectedPersons);
        } catch (inferenceErr) {
          console.warn('[ArgusVision] Frame inference glitch:', inferenceErr);
        }
      } else {
        // Fallback simulated tracking for testing or headless environments
        detectedPersons = this._generateSimulatedDetections(now);
      }

      // Update multi-object tracker
      this._updateTracker(detectedPersons, now);

      // Compute geometric signals and heuristics
      const personSignals = this._computeSignals(now);

      // Draw high-DPI canvas overlay
      this._drawOverlay(personSignals);

      // Emit batched signals
      this._maybeEmitBatch(personSignals, now);

      // Telemetry calculation
      const frameDuration = performance.now() - frameStartTime;
      this.avgLatencyMs = this.avgLatencyMs === 0 ? frameDuration : (this.avgLatencyMs * 0.9 + frameDuration * 0.1);
      this.measuredFps = 1000 / Math.max(frameDuration, minInterval);

      this._scheduleNextFrame();
    }

    _syncCanvasSize() {
      if (!this.canvasEl || !this.videoEl) return;
      const w = this.videoEl.videoWidth || this.videoEl.clientWidth || 640;
      const h = this.videoEl.videoHeight || this.videoEl.clientHeight || 480;
      if (this.canvasEl.width !== w || this.canvasEl.height !== h) {
        this.canvasEl.width = w;
        this.canvasEl.height = h;
      }
    }

    _extractPersons(detections, procW, procH) {
      if (!detections || !detections.detections) return [];
      const pw = procW || (this.procCanvas ? this.procCanvas.width : (this.videoEl ? this.videoEl.videoWidth : 1));
      const ph = procH || (this.procCanvas ? this.procCanvas.height : (this.videoEl ? this.videoEl.videoHeight : 1));
      const persons = [];

      for (const d of detections.detections) {
        const cat = d.categories?.find(c => c.categoryName === 'person') ||
                    (d.categories?.[0]?.categoryName === 'person' ? d.categories[0] : null);
        if (!cat) continue;

        const b = d.boundingBox;
        if (!b) continue;

        // Normalize to 0.0 .. 1.0 with robust clamping
        const nx = Math.max(0, Math.min(0.99, b.originX / pw));
        const ny = Math.max(0, Math.min(0.99, b.originY / ph));
        const nw = Math.max(0.01, Math.min(1.0 - nx, b.width / pw));
        const nh = Math.max(0.01, Math.min(1.0 - ny, b.height / ph));

        // Filter out floor reflection / light artifact bounding boxes:
        // Standing and walking humans are vertically oriented (aspect nw/nh <= 1.0).
        // Flat horizontal boxes on the floor (aspect > 1.20) with low confidence (< 0.35)
        // are specular reflections on polished tile surfaces.
        // (Legitimate fallen humans are accurately captured by PoseLandmarker).
        const asp = nw / Math.max(0.01, nh);
        if (asp > 1.20 && cat.score < 0.35) {
          continue;
        }

        persons.push({
          bboxN: { x: nx, y: ny, w: nw, h: nh },
          confidence: cat.score,
          poseLandmarks: null
        });
      }
      return persons;
    }

    _matchPosesToDetections(persons, poseResult) {
      if (!poseResult || !poseResult.landmarks || poseResult.landmarks.length === 0) return;
      
      for (const pose of poseResult.landmarks) {
        // Calculate pose centroid and bounding box from key visible landmarks
        let cx = 0, cy = 0, count = 0;
        let minX = 1, minY = 1, maxX = 0, maxY = 0;

        for (const lm of pose) {
          const vis = (lm.visibility !== undefined) ? lm.visibility : 1.0;
          const pres = (lm.presence !== undefined) ? lm.presence : 1.0;
          if (vis > 0.20 && pres > 0.20) {
            cx += lm.x;
            cy += lm.y;
            count++;
            if (lm.x < minX) minX = lm.x;
            if (lm.x > maxX) maxX = lm.x;
            if (lm.y < minY) minY = lm.y;
            if (lm.y > maxY) maxY = lm.y;
          }
        }
        if (count < 4) continue;
        cx /= count;
        cy /= count;

        // Find matching person bbox
        let bestPerson = null;
        let bestDist = Infinity;
        for (const p of persons) {
          const pcx = p.bboxN.x + p.bboxN.w / 2;
          const pcy = p.bboxN.y + p.bboxN.h / 2;
          const dist = Math.hypot(cx - pcx, cy - pcy);
          const isInside = cx >= p.bboxN.x - 0.05 && cx <= p.bboxN.x + p.bboxN.w + 0.05 &&
                           cy >= p.bboxN.y - 0.05 && cy <= p.bboxN.y + p.bboxN.h + 0.05;
          if ((isInside || dist < 0.25) && dist < bestDist) {
            bestDist = dist;
            bestPerson = p;
          }
        }

        if (bestPerson) {
          if (!bestPerson.poseLandmarks) {
            bestPerson.poseLandmarks = pose;
          }
          // Expand/refine bounding box if pose covers ankles/head better
          const pMinX = Math.min(bestPerson.bboxN.x, minX - 0.015);
          const pMaxX = Math.max(bestPerson.bboxN.x + bestPerson.bboxN.w, maxX + 0.015);
          const pMinY = Math.min(bestPerson.bboxN.y, minY - 0.02);
          const pMaxY = Math.max(bestPerson.bboxN.y + bestPerson.bboxN.h, maxY + 0.02);
          const nx = Math.max(0, pMinX);
          const ny = Math.max(0, pMinY);
          bestPerson.bboxN = {
            x: nx,
            y: ny,
            w: Math.min(1.0 - nx, pMaxX - pMinX),
            h: Math.min(1.0 - ny, pMaxY - pMinY)
          };
        } else {
          // Dual-pass synthesis: person detected by pose landmarker, but missed by object detector!
          const spanW = maxX - minX;
          const spanH = maxY - minY;
          if (spanH > 0.04) {
            const padX = Math.max(0.018, spanW * 0.22);
            const padY = Math.max(0.02, spanH * 0.12);
            const nx = Math.max(0, minX - padX);
            const ny = Math.max(0, minY - padY);
            const nw = Math.min(1.0 - nx, spanW + 2 * padX);
            const nh = Math.min(1.0 - ny, spanH + 2 * padY);

            persons.push({
              bboxN: { x: nx, y: ny, w: nw, h: nh },
              confidence: 0.88,
              poseLandmarks: pose,
              isSynthesized: true
            });
          }
        }
      }
    }

    _filterOverlappingDetections(detections) {
      if (detections.length <= 1) return detections;
      const sorted = [...detections].sort((a, b) => b.confidence - a.confidence);
      const filtered = [];

      for (const cur of sorted) {
        let isDuplicate = false;
        for (const prev of filtered) {
          const iou = computeIoU(cur.bboxN, prev.bboxN);
          if (iou > 0.50) {
            if (!prev.poseLandmarks && cur.poseLandmarks) {
              prev.poseLandmarks = cur.poseLandmarks;
            }
            isDuplicate = true;
            break;
          }
        }
        if (!isDuplicate) {
          filtered.push(cur);
        }
      }
      return filtered;
    }

    _generateSimulatedDetections(now) {
      // Deterministic synthetic track for zero-GPU environments and preview
      const t = (now / 1000) % 12; // 12 second loop
      const x = 0.35 + 0.25 * Math.sin(t * 0.5);
      const isFalling = t > 6 && t < 9;
      const y = isFalling ? 0.65 : 0.28;
      const w = isFalling ? 0.38 : 0.16;
      const h = isFalling ? 0.18 : 0.52;

      return [{
        bboxN: { x, y, w, h },
        confidence: 0.94,
        poseLandmarks: null,
        isSimulated: true,
        isFalling
      }];
    }

    _updateTracker(detectedPersons, now) {
      // Bipartite matching with combined IoU + Centroid proximity
      const candidatePairs = [];

      for (let i = 0; i < detectedPersons.length; i++) {
        for (const [trackId, track] of this.tracks.entries()) {
          const score = computeBboxSimilarity(detectedPersons[i].bboxN, track.bboxN);
          if (score >= 0.30) {
            candidatePairs.push({ detIndex: i, trackId, score });
          }
        }
      }

      // Sort candidate matches by highest similarity first
      candidatePairs.sort((a, b) => b.score - a.score);

      const matchedDets = new Set();
      const matchedTracks = new Set();
      const finalMatches = [];

      for (const pair of candidatePairs) {
        if (!matchedDets.has(pair.detIndex) && !matchedTracks.has(pair.trackId)) {
          matchedDets.add(pair.detIndex);
          matchedTracks.add(pair.trackId);
          finalMatches.push(pair);
        }
      }

      // 1. Update matched tracks with EMA smoothing
      for (const m of finalMatches) {
        const det = detectedPersons[m.detIndex];
        const track = this.tracks.get(m.trackId);
        const alpha = 0.65; // Exponential Moving Average smoothing factor

        track.bboxN = {
          x: track.bboxN.x * (1 - alpha) + det.bboxN.x * alpha,
          y: track.bboxN.y * (1 - alpha) + det.bboxN.y * alpha,
          w: track.bboxN.w * (1 - alpha) + det.bboxN.w * alpha,
          h: track.bboxN.h * (1 - alpha) + det.bboxN.h * alpha,
        };
        track.confidence = track.confidence * 0.3 + det.confidence * 0.7;
        if (det.poseLandmarks) track.poseLandmarks = det.poseLandmarks;
        track.lastSeenMs = now;
      }

      // 2. Initialize new tracks for unmatched detections
      for (let i = 0; i < detectedPersons.length; i++) {
        if (!matchedDets.has(i)) {
          const det = detectedPersons[i];
          const newId = this.nextTrackId++;
          this.tracks.set(newId, {
            trackId: newId,
            bboxN: { ...det.bboxN },
            footN: { x: det.bboxN.x + det.bboxN.w / 2, y: det.bboxN.y + det.bboxN.h },
            zoneIds: [],
            confidence: det.confidence,
            poseLandmarks: det.poseLandmarks,
            firstSeenMs: now,
            lastSeenMs: now,
            smoothCx: det.bboxN.x + det.bboxN.w / 2,
            smoothCy: det.bboxN.y + det.bboxN.h / 2,
            motionScore: 0.05,
            motionlessStartMs: null,
            motionlessMs: 0,
            movingFramesCount: 0,
            fallScore: 0.0,
            hasFallen: false,
            fallenSinceMs: null,
            uprightFramesCount: 0,
            history: []
          });
        }
      }

      // 3. Age out tracks unseen for > 1.8 seconds (1800 ms)
      for (const [trackId, track] of this.tracks.entries()) {
        if (!matchedTracks.has(trackId)) {
          if (now - track.lastSeenMs > 1800) {
            this.tracks.delete(trackId);
          }
        }
      }
    }

    _computeSignals(now) {
      const signals = [];

      for (const [trackId, track] of this.tracks.entries()) {
        const b = track.bboxN;
        const pose = track.poseLandmarks;

        // 1. Foot Point calculation (pose ankle midpoint or bbox bottom-centre)
        let footX = b.x + b.w / 2;
        let footY = b.y + b.h;

        if (pose && pose[27] && pose[28] && pose[27].visibility > 0.4 && pose[28].visibility > 0.4) {
          footX = (pose[27].x + pose[28].x) / 2;
          footY = (pose[27].y + pose[28].y) / 2;
        }
        track.footN = { x: footX, y: footY };

        // 2. Point-in-polygon zone checks
        const matchedZoneIds = [];
        for (const zone of this.zones) {
          if (pointInPolygon(footX, footY, zone.polygon)) {
            matchedZoneIds.push(zone.id);
          }
        }
        track.zoneIds = matchedZoneIds;

        // 3. Motion & Velocity Tracking with EMA smoothing & Hysteresis
        const rawCx = b.x + b.w / 2;
        const rawCy = b.y + b.h / 2;
        const aspect = b.w / Math.max(0.01, b.h);

        // Smooth centroid to cancel pixel jitter
        track.smoothCx = (track.smoothCx !== undefined) ? (track.smoothCx * 0.70 + rawCx * 0.30) : rawCx;
        track.smoothCy = (track.smoothCy !== undefined) ? (track.smoothCy * 0.70 + rawCy * 0.30) : rawCy;

        // Record history for displacement & transition checks
        track.history.push({ t: now, cx: track.smoothCx, cy: track.smoothCy, w: b.w, h: b.h, aspect });
        // Retain 3 seconds of history
        track.history = track.history.filter(h => now - h.t <= 3000);

        // Measure displacement over the last ~1.0 second (sample between 0.7s and 1.5s ago)
        let sample1s = track.history.find(h => (now - h.t) >= 700 && (now - h.t) <= 1500);
        if (!sample1s && track.history.length > 0) sample1s = track.history[0];

        const elapsedSec = sample1s ? Math.max(0.2, (now - sample1s.t) / 1000) : 1.0;
        const dist = sample1s ? Math.hypot(track.smoothCx - sample1s.cx, track.smoothCy - sample1s.cy) : 0.0;
        const velocityNormPerSec = dist / elapsedSec;
        track.motionScore = Math.min(1.0, velocityNormPerSec * 4.0);

        // Stationary detection threshold:
        // A lying down or collapsed subject has higher horizontal span so detection box edge jitter is slightly larger;
        // walking people move at > 0.04 per second.
        const isLyingOrFallen = (aspect >= 0.95 || track.hasFallen);
        const stationaryThreshold = isLyingOrFallen ? 0.045 : 0.030;
        const isStationary = velocityNormPerSec < stationaryThreshold;

        // Jitter-proof motionless accumulation:
        if (isStationary) {
          track.movingFramesCount = 0;
          if (!track.motionlessStartMs) {
            track.motionlessStartMs = now;
          }
          track.motionlessMs = Math.max(0, now - track.motionlessStartMs);
        } else {
          // Require at least 5 consecutive moving frames (~600ms) to reset motionless state
          // This prevents single-frame noise/jitter from wiping out accumulated motionless seconds!
          track.movingFramesCount = (track.movingFramesCount || 0) + 1;
          if (track.movingFramesCount >= 5) {
            track.motionlessStartMs = null;
            track.motionlessMs = 0;
          }
        }

        // 4. Fall & Sustained Posture Calculation
        let torsoAngleDeg = 0;
        let hipDropRatio = 0;
        let shoulderX = 0, shoulderY = 0, hipX = 0, hipY = 0;

        if (pose && pose[11] && pose[12] && pose[23] && pose[24]) {
          shoulderX = (pose[11].x + pose[12].x) / 2;
          shoulderY = (pose[11].y + pose[12].y) / 2;
          hipX = (pose[23].x + pose[24].x) / 2;
          hipY = (pose[23].y + pose[24].y) / 2;

          const dx = shoulderX - hipX;
          const dy = shoulderY - hipY;
          torsoAngleDeg = Math.atan2(Math.abs(dx), -dy) * (180 / Math.PI);

          if (sample1s && sample1s.hipY !== undefined) {
            hipDropRatio = Math.max(0, (hipY - sample1s.hipY) / Math.max(0.1, b.h));
          }
        }

        if (track.history.length > 0) {
          track.history[track.history.length - 1].hipY = hipY;
        }

        // Check if person was upright earlier (aspect < 0.85 in past 0.3s to 3.0s)
        const wasUprightBefore = track.history.some(h => (now - h.t > 300) && h.aspect < 0.85);

        // Dynamic collapse score (active drop event)
        const aspectInverted = (aspect > 0.95 && wasUprightBefore) ? 1.0 : 0.0;
        const dynamicDropScore = (0.45 * aspectInverted) +
                                 (0.35 * Math.min(1.0, Math.max(0, hipDropRatio / 0.35))) +
                                 (0.25 * Math.min(1.0, Math.max(0, torsoAngleDeg / 65.0)));

        // Static horizontal / prone posture cues:
        // Must require verified human pose keypoints or confirmed prior upright history!
        // This prevents inanimate horizontal floor objects (tile reflections, shadows) from ever triggering a fall.
        const isHorizontalBbox = aspect >= 1.15;
        const isHorizontalTorso = pose && torsoAngleDeg >= 50;
        const isPronePose = !!(pose && Math.abs(shoulderY - hipY) < 0.14 && Math.abs(shoulderX - hipX) > 0.08);

        let staticProneScore = 0.0;
        if (isHorizontalBbox && isHorizontalTorso && pose) {
          staticProneScore = Math.min(0.95, 0.75 + Math.min(0.20, (aspect - 1.0) * 0.15));
        } else if (isPronePose) {
          staticProneScore = Math.min(0.92, 0.70 + Math.min(0.22, (aspect - 0.9) * 0.15));
        } else if (wasUprightBefore && isHorizontalBbox && dynamicDropScore >= 0.50) {
          staticProneScore = 0.75;
        }

        // Trigger fall latch if dynamic drop OR prone posture detected
        if (dynamicDropScore >= 0.60 || staticProneScore >= 0.70) {
          track.hasFallen = true;
          if (!track.fallenSinceMs) track.fallenSinceMs = now;
        }

        // Sustained lying check: is the person still on the ground?
        const isStillDown = isHorizontalBbox || isPronePose || (aspect > 0.85 && (torsoAngleDeg > 40 || track.motionlessMs > 1000));

        let computedFall = 0.0;
        if (track.hasFallen && isStillDown) {
          // Person has fallen and is still lying on the ground!
          // Sustain high fall score (85% - 95%) so it never drops back down while lying!
          const targetScore = Math.max(0.85, staticProneScore);
          computedFall = Math.max(targetScore, (track.fallScore || 0) * 0.98);
          track.uprightFramesCount = 0;
          if (track.fallenSinceMs) {
            const downDuration = Math.max(0, now - track.fallenSinceMs);
            if (downDuration > track.motionlessMs) {
              track.motionlessMs = downDuration;
            }
          }
        } else if (track.hasFallen && !isStillDown) {
          // Person might be standing back up: require 8 consecutive frames (~1s) of upright posture before unlatching
          const isUpright = aspect < 0.65 && (torsoAngleDeg < 35 || !pose);
          if (isUpright) {
            track.uprightFramesCount = (track.uprightFramesCount || 0) + 1;
            if (track.uprightFramesCount >= 8) {
              track.hasFallen = false;
              track.fallenSinceMs = null;
              computedFall = 0.0;
            } else {
              computedFall = 0.45;
            }
          } else {
            computedFall = 0.65;
          }
        } else {
          // Normal standing or walking person
          computedFall = Math.max(dynamicDropScore, staticProneScore);
        }

        if (track.isFalling) computedFall = 0.92; // Ensure simulated fall triggers
        track.fallScore = Number(Math.max(0.0, Math.min(1.0, computedFall)).toFixed(2));

        signals.push({
          trackId,
          bboxN: b,
          footN: track.footN,
          zoneIds: track.zoneIds,
          aspect: Number(aspect.toFixed(2)),
          torsoAngleDeg: Number(torsoAngleDeg.toFixed(1)),
          hipDropRatio: Number(hipDropRatio.toFixed(2)),
          motionScore: Number(track.motionScore.toFixed(3)),
          fallScore: Number(track.fallScore.toFixed(2)),
          motionlessMs: Math.round(track.motionlessMs),
          confidence: Number(track.confidence.toFixed(2)),
          poseLandmarks: track.poseLandmarks
        });
      }

      return signals;
    }

    _drawSkeleton(landmarks, w, h, color) {
      if (!landmarks || landmarks.length === 0) return;
      const connections = [
        [11, 12], [11, 23], [12, 24], [23, 24], // Torso
        [11, 13], [13, 15],                      // Left arm
        [12, 14], [14, 16],                      // Right arm
        [23, 25], [25, 27],                      // Left leg
        [24, 26], [26, 28]                       // Right leg
      ];
      this.ctx.save();
      this.ctx.strokeStyle = this._hexToRgba(color, 0.70);
      this.ctx.lineWidth = 1.8;
      for (const [i, j] of connections) {
        const p1 = landmarks[i];
        const p2 = landmarks[j];
        if (p1 && p2) {
          const v1 = (p1.visibility !== undefined) ? p1.visibility : 1.0;
          const v2 = (p2.visibility !== undefined) ? p2.visibility : 1.0;
          if (v1 > 0.22 && v2 > 0.22) {
            this.ctx.beginPath();
            this.ctx.moveTo(p1.x * w, p1.y * h);
            this.ctx.lineTo(p2.x * w, p2.y * h);
            this.ctx.stroke();
          }
        }
      }
      // Joint nodes
      this.ctx.fillStyle = color;
      const keypoints = [0, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28];
      for (const idx of keypoints) {
        const pt = landmarks[idx];
        if (pt) {
          const v = (pt.visibility !== undefined) ? pt.visibility : 1.0;
          if (v > 0.22) {
            this.ctx.beginPath();
            this.ctx.arc(pt.x * w, pt.y * h, 2.5, 0, Math.PI * 2);
            this.ctx.fill();
          }
        }
      }
      this.ctx.restore();
    }

    _drawOverlay(personSignals) {
      if (!this.ctx || !this.canvasEl) return;
      const w = this.canvasEl.width;
      const h = this.canvasEl.height;

      this.ctx.clearRect(0, 0, w, h);

      // 1. Draw Zones with transparent fills and sharp borders
      for (const zone of this.zones) {
        if (!zone.polygon || zone.polygon.length < 3) continue;

        const color = zone.color || (zone.kind === 'restricted' ? '#F43F5E' : '#38BDF8');
        this.ctx.beginPath();
        this.ctx.moveTo(zone.polygon[0].x * w, zone.polygon[0].y * h);
        for (let i = 1; i < zone.polygon.length; i++) {
          this.ctx.lineTo(zone.polygon[i].x * w, zone.polygon[i].y * h);
        }
        this.ctx.closePath();

        // 18% translucent fill
        this.ctx.fillStyle = this._hexToRgba(color, 0.18);
        this.ctx.fill();

        // Border
        this.ctx.strokeStyle = color;
        this.ctx.lineWidth = 2;
        this.ctx.stroke();

        // Zone Name Tag
        const labelX = zone.polygon[0].x * w;
        const labelY = zone.polygon[0].y * h;
        this.ctx.fillStyle = color;
        this.ctx.font = '600 11px sans-serif';
        this.ctx.fillText(zone.name.toUpperCase(), labelX + 6, Math.max(16, labelY - 6));
      }

      // 2. Draw Detected Persons
      for (const p of personSignals) {
        try {
          const bx = p.bboxN.x * w;
          const by = p.bboxN.y * h;
          const bw = p.bboxN.w * w;
          const bh = p.bboxN.h * h;

          const isAlarm = p.fallScore >= 0.6 || (p.zoneIds.length > 0 && p.fallScore > 0.3);
          const boxColor = isAlarm ? '#F43F5E' : '#38BDF8';

          // Draw posture skeleton if pose landmarks are detected
          if (p.poseLandmarks) {
            this._drawSkeleton(p.poseLandmarks, w, h, boxColor);
          }

          // Translucent cybernetic fill
          this.ctx.fillStyle = this._hexToRgba(boxColor, 0.08);
          this.ctx.fillRect(bx, by, bw, bh);

          // Bounding box outline
          this.ctx.strokeStyle = boxColor;
          this.ctx.lineWidth = 2.0;
          this.ctx.strokeRect(bx, by, bw, bh);

          // Corner accents
          this._drawBoxCorners(bx, by, bw, bh, boxColor);

          // Header Pill: Track ID + Confidence
          const label = `ID ${p.trackId} ${(p.confidence * 100).toFixed(0)}%`;
          this.ctx.font = 'bold 11px monospace';
          const textWidth = this.ctx.measureText(label).width;
          const pillW = Math.max(76, textWidth + 12);
          const pillY = Math.max(0, by - 20);

          this.ctx.fillStyle = boxColor;
          this.ctx.fillRect(bx, pillY, pillW, 18);
          this.ctx.fillStyle = '#0B0E13';
          this.ctx.fillText(label, bx + 6, pillY + 13);

          // Foot Anchor Dot with glowing radar ring
          this.ctx.beginPath();
          this.ctx.arc(p.footN.x * w, p.footN.y * h, 3.5, 0, Math.PI * 2);
          this.ctx.fillStyle = boxColor;
          this.ctx.fill();

          this.ctx.beginPath();
          this.ctx.arc(p.footN.x * w, p.footN.y * h, 6.5, 0, Math.PI * 2);
          this.ctx.strokeStyle = this._hexToRgba(boxColor, 0.5);
          this.ctx.lineWidth = 1.2;
          this.ctx.stroke();

          // Alarm status tags (keep within visible canvas bounds)
          let tagY = by + bh + 16;
          if (by + bh > h - 35) {
            tagY = Math.max(32, by - 6);
          }
          if (p.fallScore >= 0.6) {
            this._drawTag('FALL SUSPECTED', bx, tagY, '#F43F5E');
            tagY += 18;
          }
          if (p.motionlessMs >= 2000) {
            this._drawTag(`MOTIONLESS ${(p.motionlessMs / 1000).toFixed(0)}s`, bx, tagY, '#FBBF24');
            tagY += 18;
          }
          if (p.zoneIds.length > 0) {
            this._drawTag('ZONE INTRUSION', bx, tagY, '#FB923C');
          }
        } catch (drawErr) {
          console.warn('[ArgusVision] Draw person error:', drawErr);
        }
      }
    }

    _drawBoxCorners(x, y, w, h, color) {
      const len = 12;
      this.ctx.strokeStyle = color;
      this.ctx.lineWidth = 3;
      // Top-left
      this.ctx.beginPath();
      this.ctx.moveTo(x, y + len); this.ctx.lineTo(x, y); this.ctx.lineTo(x + len, y);
      this.ctx.stroke();
      // Top-right
      this.ctx.beginPath();
      this.ctx.moveTo(x + w - len, y); this.ctx.lineTo(x + w, y); this.ctx.lineTo(x + w, y + len);
      this.ctx.stroke();
      // Bottom-left
      this.ctx.beginPath();
      this.ctx.moveTo(x, y + h - len); this.ctx.lineTo(x, y + h); this.ctx.lineTo(x + len, y + h);
      this.ctx.stroke();
      // Bottom-right
      this.ctx.beginPath();
      this.ctx.moveTo(x + w - len, y + h); this.ctx.lineTo(x + w, y + h); this.ctx.lineTo(x + w, y + h - len);
      this.ctx.stroke();
    }

    _drawTag(text, x, y, bg) {
      this.ctx.font = 'bold 10px monospace';
      const textWidth = this.ctx.measureText(text).width;
      this.ctx.fillStyle = bg;
      this.ctx.fillRect(x, y - 12, textWidth + 10, 15);
      this.ctx.fillStyle = '#0B0E13';
      this.ctx.fillText(text, x + 5, y - 1);
    }

    _hexToRgba(hex, alpha) {
      hex = hex.replace('#', '');
      if (hex.length === 3) hex = hex.split('').map(c => c + c).join('');
      const r = parseInt(hex.substring(0, 2), 16) || 0;
      const g = parseInt(hex.substring(2, 4), 16) || 0;
      const b = parseInt(hex.substring(4, 6), 16) || 0;
      return `rgba(${r}, ${g}, ${b}, ${alpha})`;
    }

    _maybeEmitBatch(personSignals, now) {
      if (!this.signalCallback) return;

      // Determine if state changed or heartbeat time reached
      const stateHash = JSON.stringify(personSignals.map(p => ({
        id: p.trackId,
        zones: p.zoneIds,
        fall: p.fallScore >= 0.6,
        motionless: p.motionlessMs > 3000
      })));

      const stateChanged = stateHash !== this.lastEmittedStateHash;
      const timeSinceLast = now - this.lastBatchSentAt;
      const isHeartbeat = timeSinceLast >= 2000;

      if ((stateChanged && timeSinceLast >= 450) || isHeartbeat) {
        this.lastEmittedStateHash = stateHash;
        this.lastBatchSentAt = now;

        const clientPersons = personSignals.map(p => ({
          trackId: p.trackId,
          bboxN: p.bboxN,
          footN: p.footN,
          zoneIds: p.zoneIds,
          aspect: p.aspect,
          torsoAngleDeg: p.torsoAngleDeg,
          hipDropRatio: p.hipDropRatio,
          motionScore: p.motionScore,
          fallScore: p.fallScore,
          motionlessMs: p.motionlessMs,
          confidence: p.confidence
        }));

        const batch = {
          cameraId: 1,
          sentAtMs: Date.now(),
          seq: this.batchSeq++,
          signals: [{
            tsMs: Date.now(),
            kind: stateChanged ? 'change' : 'heartbeat',
            personCount: clientPersons.length,
            persons: clientPersons
          }]
        };

        if (this.isRecording) {
          this.recordedBatches.push(batch);
        }

        try {
          this.signalCallback(JSON.stringify(batch));
        } catch (_) {
          try { this.signalCallback(batch); } catch (cbErr) {
            console.error('[ArgusVision] Signal callback error:', cbErr);
          }
        }
      }
    }

    // --- Privacy Snapshot with Guaranteed Head Blurring ---
    async snapshot({ blurHead = true, maxWidth = 640, quality = 0.75 } = {}) {
      if (!this.videoEl) return null;

      const vw = this.videoEl.videoWidth || 640;
      const vh = this.videoEl.videoHeight || 480;
      const scale = Math.min(1.0, maxWidth / vw);
      const sw = Math.round(vw * scale);
      const sh = Math.round(vh * scale);

      const offCanvas = document.createElement('canvas');
      offCanvas.width = sw;
      offCanvas.height = sh;
      const offCtx = offCanvas.getContext('2d');

      // Draw original video frame
      offCtx.drawImage(this.videoEl, 0, 0, sw, sh);

      // Blur human heads & faces by default (Privacy by design)
      if (blurHead) {
        for (const [trackId, track] of this.tracks.entries()) {
          const b = track.bboxN;
          let headX, headY, headW, headH;

          // Check if pose landmarks for the face (nose: 0, eyes: 1-6, ears: 7-8, mouth: 9-10) are present
          let facePoints = [];
          if (track.poseLandmarks && Array.isArray(track.poseLandmarks)) {
            for (let i = 0; i <= 10; i++) {
              const lm = track.poseLandmarks[i];
              if (lm && (lm.visibility === undefined || lm.visibility > 0.25)) {
                facePoints.push(lm);
              }
            }
          }

          if (facePoints.length >= 2) {
            // Landmark-based face bounding box
            const minX = Math.min(...facePoints.map(p => p.x));
            const maxX = Math.max(...facePoints.map(p => p.x));
            const minY = Math.min(...facePoints.map(p => p.y));
            const maxY = Math.max(...facePoints.map(p => p.y));

            const cx = (minX + maxX) / 2;
            const cy = (minY + maxY) / 2;
            const spanW = Math.max((maxX - minX) * 1.8, b.w * 0.7);
            const spanH = Math.max((maxY - minY) * 2.0, b.h * 0.58);

            headX = Math.max(0, Math.round((cx - spanW / 2) * sw));
            headY = Math.max(0, Math.round((cy - spanH * 0.52) * sh));
            headW = Math.min(sw - headX, Math.round(spanW * sw));
            headH = Math.min(sh - headY, Math.round(spanH * sh));
          } else {
            // Fallback: estimate from person bounding box.
            // In webcam / desk scenarios (aspect ratio > 0.45 or close up), face takes top 65% of the box.
            const isUpperBody = (b.w / b.h > 0.45) || (b.h < 0.75);
            const heightFraction = isUpperBody ? 0.65 : 0.42;

            headX = Math.max(0, Math.round((b.x + b.w * 0.05) * sw));
            headY = Math.max(0, Math.round(b.y * sh));
            headW = Math.min(sw - headX, Math.round(b.w * 0.90 * sw));
            headH = Math.min(sh - headY, Math.round(b.h * heightFraction * sh));
          }

          // Apply heavy pixelation / box blur filter to protect privacy
          try {
            offCtx.save();
            const pxSize = 12;
            const tempC = document.createElement('canvas');
            tempC.width = Math.max(1, Math.round(headW / pxSize));
            tempC.height = Math.max(1, Math.round(headH / pxSize));
            const tempCtx = tempC.getContext('2d');
            tempCtx.drawImage(offCanvas, headX, headY, headW, headH, 0, 0, tempC.width, tempC.height);

            offCtx.imageSmoothingEnabled = false;
            offCtx.drawImage(tempC, 0, 0, tempC.width, tempC.height, headX, headY, headW, headH);
            offCtx.restore();
          } catch (blurErr) {
            console.warn('[ArgusVision] Canvas blur exception, using solid fill fallback:', blurErr);
            offCtx.fillStyle = 'rgba(0, 0, 0, 0.85)';
            offCtx.fillRect(headX, headY, headW, headH);
          }
        }
      }

      return offCanvas.toDataURL('image/jpeg', quality);
    }

    // --- Ephemeral Upper-Body Crop for Optional Cloud Verification ---
    async verificationCrop({ trackId, quality = 0.8 } = {}) {
      if (!this.videoEl) return null;
      const track = this.tracks.get(trackId);
      if (!track) return null;

      const vw = this.videoEl.videoWidth || 640;
      const vh = this.videoEl.videoHeight || 480;
      const b = track.bboxN;

      const cropX = Math.max(0, b.x * vw);
      const cropY = Math.max(0, b.y * vh);
      const cropW = Math.min(vw - cropX, b.w * vw);
      const cropH = Math.min(vh - cropY, b.h * 0.55 * vh); // Upper body

      const cropCanvas = document.createElement('canvas');
      cropCanvas.width = Math.min(320, cropW);
      cropCanvas.height = Math.min(320, cropH);
      const cropCtx = cropCanvas.getContext('2d');

      cropCtx.drawImage(this.videoEl, cropX, cropY, cropW, cropH, 0, 0, cropCanvas.width, cropCanvas.height);
      return cropCanvas.toDataURL('image/jpeg', quality);
    }

    getStats() {
      return {
        fps: Number(this.measuredFps.toFixed(1)),
        latencyMs: Math.round(this.avgLatencyMs),
        trackCount: this.tracks.size,
        mode: this.mode,
        degradeLevel: this.degradeLevel,
        isMediaPipeLoaded: this.hasMediaPipeLoaded
      };
    }

    recordReplay(enable) {
      this.isRecording = enable;
      if (enable) {
        this.recordedBatches = [];
        this.notifyStatus('recording', 'Recording detector signal timeline...');
      } else {
        this.notifyStatus('idle', `Recorded ${this.recordedBatches.length} signal batches`);
      }
    }

    getRecordedReplay() {
      return {
        clipId: 'user_recorded_' + Date.now(),
        recordedAt: new Date().toISOString(),
        fps: this.targetFps,
        batchCount: this.recordedBatches.length,
        batches: this.recordedBatches
      };
    }

    loadReplay(replayData) {
      if (typeof replayData === 'string') {
        try { replayData = JSON.parse(replayData); } catch (e) {}
      }
      this.replayBatches = replayData.batches || [];
      this.replayIndex = 0;
      this.setMode('replay');

      if (this.replayTimer) clearInterval(this.replayTimer);
      this.replayTimer = setInterval(() => {
        if (!this.isRunning || this.replayBatches.length === 0) return;
        const batch = this.replayBatches[this.replayIndex];
        this.replayIndex = (this.replayIndex + 1) % this.replayBatches.length;

        if (this.signalCallback) {
          try {
            this.signalCallback(typeof batch === 'string' ? batch : JSON.stringify(batch));
          } catch (_) {
            this.signalCallback(batch);
          }
        }
      }, 500);
    }
  }

  // Expose global instance on window
  window.argusVision = new ArgusVisionEngine();

})(window);
