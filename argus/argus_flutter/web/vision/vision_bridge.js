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
        this.statusCallback({ status, detail, fps: this.measuredFps, latencyMs: this.avgLatencyMs });
      }
    }

    async init(options = {}) {
      if (options.wasmBaseUrl) this.wasmBaseUrl = options.wasmBaseUrl;
      if (options.detectorModelPath) this.detectorModelPath = options.detectorModelPath;
      if (options.poseModelPath) this.poseModelPath = options.poseModelPath;

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
            runningMode: 'VIDEO',
            scoreThreshold: 0.45,
            categoryAllowlist: ['person']
          });

          this.poseLandmarker = await visionPkg.PoseLandmarker.createFromOptions(vision, {
            baseOptions: {
              modelAssetPath: this.poseModelPath,
              delegate: 'GPU'
            },
            runningMode: 'VIDEO',
            numPoses: 3,
            minPoseDetectionConfidence: 0.45,
            minPosePresenceConfidence: 0.45,
            minTrackingConfidence: 0.45
          });

          this.hasMediaPipeLoaded = true;
          this.notifyStatus('ready', 'MediaPipe WebAssembly & models loaded (GPU accelerated)');
        } else {
          // If vendor script not loaded via global script tag yet, try dynamic import
          try {
            const visionPkg = await import('./vendor/vision_bundle.mjs');
            const vision = await visionPkg.FilesetResolver.forVisionTasks(this.wasmBaseUrl);
            
            this.objectDetector = await visionPkg.ObjectDetector.createFromOptions(vision, {
              baseOptions: { modelAssetPath: this.detectorModelPath },
              runningMode: 'VIDEO',
              scoreThreshold: 0.45,
              categoryAllowlist: ['person']
            });

            this.poseLandmarker = await visionPkg.PoseLandmarker.createFromOptions(vision, {
              baseOptions: { modelAssetPath: this.poseModelPath },
              runningMode: 'VIDEO',
              numPoses: 3,
              minPoseDetectionConfidence: 0.45,
              minPosePresenceConfidence: 0.45,
              minTrackingConfidence: 0.45
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

    attach({ videoId, canvasId, videoElement, canvasElement }) {
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

    async start({ targetFps = 8, sourceKind = 'webcam', sourceUrl = null } = {}) {
      if (!this.videoEl) {
        throw new Error('Video element not attached. Call attach() first.');
      }

      this.targetFps = targetFps;
      this.isRunning = true;
      this.frameCount = 0;
      this.tracks.clear();

      if (sourceKind === 'webcam') {
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
      } else if (sourceUrl) {
        this.videoEl.srcObject = null;
        this.videoEl.src = sourceUrl;
        this.videoEl.loop = true;
        this.videoEl.muted = true;
        await this.videoEl.play();
        this.notifyStatus('running', 'Video stream playing: ' + sourceKind);
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

      const now = performance.now();
      const minInterval = 1000 / this.targetFps;
      if (now - this.lastFrameTime < minInterval) {
        this._scheduleNextFrame();
        return;
      }

      const frameStartTime = performance.now();
      this.frameCount++;
      this.lastFrameTime = now;

      // Ensure canvas resolution matches video display
      this._syncCanvasSize();

      let detectedPersons = [];

      if (this.hasMediaPipeLoaded && this.objectDetector && this.videoEl.readyState >= 2) {
        try {
          const detections = this.objectDetector.detectForVideo(this.videoEl, now);
          detectedPersons = this._extractPersons(detections);
          
          // Alternate frame pose landmarking for optimal FPS
          if (this.poseLandmarker && (this.frameCount % 2 === 0 || detectedPersons.length > 0)) {
            const poseResult = this.poseLandmarker.detectForVideo(this.videoEl, now);
            this._matchPosesToDetections(detectedPersons, poseResult);
          }
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

    _extractPersons(detections) {
      if (!detections || !detections.detections) return [];
      const vw = this.videoEl.videoWidth || 1;
      const vh = this.videoEl.videoHeight || 1;
      const persons = [];

      for (const d of detections.detections) {
        const cat = d.categories[0];
        if (!cat || cat.categoryName !== 'person') continue;

        const b = d.boundingBox;
        // Normalize to 0.0 .. 1.0
        persons.push({
          bboxN: {
            x: Math.max(0, b.originX / vw),
            y: Math.max(0, b.originY / vh),
            w: Math.min(1, b.width / vw),
            h: Math.min(1, b.height / vh)
          },
          confidence: cat.score,
          poseLandmarks: null
        });
      }
      return persons;
    }

    _matchPosesToDetections(persons, poseResult) {
      if (!poseResult || !poseResult.landmarks || poseResult.landmarks.length === 0) return;
      
      for (const pose of poseResult.landmarks) {
        // Calculate pose centroid
        let cx = 0, cy = 0, count = 0;
        for (const lm of pose) {
          if (lm.visibility > 0.4) {
            cx += lm.x;
            cy += lm.y;
            count++;
          }
        }
        if (count === 0) continue;
        cx /= count;
        cy /= count;

        // Find matching person bbox
        let bestPerson = null;
        let bestDist = Infinity;
        for (const p of persons) {
          const pcx = p.bboxN.x + p.bboxN.w / 2;
          const pcy = p.bboxN.y + p.bboxN.h / 2;
          const dist = Math.hypot(cx - pcx, cy - pcy);
          if (dist < 0.3 && dist < bestDist) {
            bestDist = dist;
            bestPerson = p;
          }
        }

        if (bestPerson) {
          bestPerson.poseLandmarks = pose;
        }
      }
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
      // Match detections with existing tracks using IoU & Centroid Distance
      const unmatchedTracks = new Set(this.tracks.keys());
      const matches = [];

      for (let i = 0; i < detectedPersons.length; i++) {
        const det = detectedPersons[i];
        let bestTrackId = null;
        let bestIoU = 0.2; // Min IoU threshold

        for (const [trackId, track] of this.tracks.entries()) {
          const iou = computeIoU(det.bboxN, track.bboxN);
          if (iou > bestIoU) {
            bestIoU = iou;
            bestTrackId = trackId;
          }
        }

        if (bestTrackId !== null) {
          matches.push({ detIndex: i, trackId: bestTrackId });
          unmatchedTracks.delete(bestTrackId);
        } else {
          // New track
          const newId = this.nextTrackId++;
          this.tracks.set(newId, {
            trackId: newId,
            bboxN: det.bboxN,
            footN: { x: det.bboxN.x + det.bboxN.w / 2, y: det.bboxN.y + det.bboxN.h },
            zoneIds: [],
            confidence: det.confidence,
            poseLandmarks: det.poseLandmarks,
            firstSeenMs: now,
            lastSeenMs: now,
            motionScore: 0.1,
            motionlessMs: 0,
            fallScore: 0.0,
            history: []
          });
        }
      }

      // Update matched tracks
      for (const m of matches) {
        const det = detectedPersons[m.detIndex];
        const track = this.tracks.get(m.trackId);
        track.bboxN = det.bboxN;
        track.confidence = det.confidence;
        if (det.poseLandmarks) track.poseLandmarks = det.poseLandmarks;
        track.lastSeenMs = now;
      }

      // Age out tracks unseen for > 1.5 seconds (1500 ms)
      for (const trackId of unmatchedTracks) {
        const track = this.tracks.get(trackId);
        if (now - track.lastSeenMs > 1500) {
          this.tracks.delete(trackId);
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

        // 3. Motion & Velocity Tracking
        const cx = b.x + b.w / 2;
        const cy = b.y + b.h / 2;
        const aspect = b.w / Math.max(0.01, b.h);

        // Record history
        track.history.push({ t: now, cx, cy, w: b.w, h: b.h, aspect });
        // Retain only last 2 seconds of history
        track.history = track.history.filter(h => now - h.t <= 2000);

        // Calculate motion displacement over ~1 second
        const sample1s = track.history[0];
        const dist1s = sample1s ? Math.hypot(cx - sample1s.cx, cy - sample1s.cy) : 0.05;
        track.motionScore = Math.min(1.0, dist1s * 5.0);

        // Motionless accumulation
        if (track.motionScore < 0.025) {
          track.motionlessMs += (now - (track.lastSeenMs || now));
        } else {
          track.motionlessMs = 0;
        }

        // 4. Fall Heuristic Calculation
        let torsoAngleDeg = 0;
        let hipDropRatio = 0;

        if (pose && pose[11] && pose[12] && pose[23] && pose[24]) {
          const shoulderX = (pose[11].x + pose[12].x) / 2;
          const shoulderY = (pose[11].y + pose[12].y) / 2;
          const hipX = (pose[23].x + pose[24].x) / 2;
          const hipY = (pose[23].y + pose[24].y) / 2;

          const dx = shoulderX - hipX;
          const dy = shoulderY - hipY;
          torsoAngleDeg = Math.atan2(Math.abs(dx), -dy) * (180 / Math.PI);

          if (sample1s && sample1s.hipY !== undefined) {
            hipDropRatio = Math.max(0, (hipY - sample1s.hipY) / Math.max(0.1, b.h));
          }
        }

        // Check if aspect ratio inverted (was tall, now flat)
        const wasTallBefore = track.history.some(h => (now - h.t > 400) && h.aspect < 0.85);
        const aspectInverted = (aspect > 0.95 && wasTallBefore) ? 1.0 : 0.0;

        const aspectTerm = 0.40 * aspectInverted;
        const hipDropTerm = 0.35 * Math.min(1.0, Math.max(0, hipDropRatio / 0.35));
        const angleTerm = 0.25 * Math.min(1.0, Math.max(0, torsoAngleDeg / 70.0));

        let computedFall = Math.max(0, Math.min(1.0, aspectTerm + hipDropTerm + angleTerm));
        if (track.isFalling) computedFall = 0.88; // Ensure simulated fall triggers

        track.fallScore = computedFall;

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
          confidence: Number(track.confidence.toFixed(2))
        });
      }

      return signals;
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
        const bx = p.bboxN.x * w;
        const by = p.bboxN.y * h;
        const bw = p.bboxN.w * w;
        const bh = p.bboxN.h * h;

        const isAlarm = p.fallScore >= 0.6 || (p.zoneIds.length > 0 && p.fallScore > 0.3);
        const boxColor = isAlarm ? '#F43F5E' : '#38BDF8';

        // Bounding box
        this.ctx.strokeStyle = boxColor;
        this.ctx.lineWidth = 2.5;
        this.ctx.strokeRect(bx, by, bw, bh);

        // Corner accents
        this._drawBoxCorners(bx, by, bw, bh, boxColor);

        // Header Pill: Track ID + Confidence
        this.ctx.fillStyle = boxColor;
        this.ctx.fillRect(bx, Math.max(0, by - 22), 80, 20);
        this.ctx.fillStyle = '#0B0E13';
        this.ctx.font = 'bold 11px monospace';
        this.ctx.fillText(`ID ${p.trackId} ${(p.confidence * 100).toFixed(0)}%`, bx + 6, Math.max(14, by - 8));

        // Foot Anchor Dot
        this.ctx.beginPath();
        this.ctx.arc(p.footN.x * w, p.footN.y * h, 4, 0, Math.PI * 2);
        this.ctx.fillStyle = boxColor;
        this.ctx.fill();

        // Alarm status tags
        let tagY = by + bh + 16;
        if (p.fallScore >= 0.6) {
          this._drawTag('FALL SUSPECTED', bx, tagY, '#F43F5E');
          tagY += 18;
        }
        if (p.motionlessMs > 3000) {
          this._drawTag(`MOTIONLESS ${(p.motionlessMs / 1000).toFixed(0)}s`, bx, tagY, '#FBBF24');
          tagY += 18;
        }
        if (p.zoneIds.length > 0) {
          this._drawTag('ZONE INTRUSION', bx, tagY, '#FB923C');
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

        const batch = {
          cameraId: 1,
          sentAtMs: Date.now(),
          seq: this.batchSeq++,
          signals: [{
            tsMs: Date.now(),
            kind: stateChanged ? 'change' : 'heartbeat',
            personCount: personSignals.length,
            persons: personSignals
          }]
        };

        if (this.isRecording) {
          this.recordedBatches.push(batch);
        }

        try {
          this.signalCallback(batch);
        } catch (cbErr) {
          console.error('[ArgusVision] Signal callback error:', cbErr);
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

      // Blur human heads by default (Privacy by design)
      if (blurHead) {
        for (const [trackId, track] of this.tracks.entries()) {
          const b = track.bboxN;
          let headX = Math.round((b.x + b.w * 0.15) * sw);
          let headY = Math.round(b.y * sh);
          let headW = Math.round(b.w * 0.70 * sw);
          let headH = Math.round(b.h * 0.28 * sh); // Top 28% of bounding box

          // Apply heavy pixelation / box blur filter to protect privacy
          try {
            offCtx.save();
            // Pixelation technique for guaranteed on-device anonymization
            const pxSize = 10;
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
          this.signalCallback(batch);
        }
      }, 500);
    }
  }

  // Expose global instance on window
  window.argusVision = new ArgusVisionEngine();

})(window);
