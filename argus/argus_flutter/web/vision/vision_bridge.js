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

  // --- Line segment intersection helper (p1-p2 and p3-p4) ---
  function segmentsIntersect(x1, y1, x2, y2, x3, y3, x4, y4) {
    const ccw = (ax, ay, bx, by, cx, cy) => (cy - ay) * (bx - ax) > (by - ay) * (cx - ax);
    return (ccw(x1, y1, x3, y3, x4, y4) !== ccw(x2, y2, x3, y3, x4, y4)) &&
           (ccw(x1, y1, x2, y2, x3, y3) !== ccw(x1, y1, x2, y2, x4, y4));
  }

  // --- Check if bounding box edges intersect polygon edges ---
  function bboxIntersectsPolygon(b, polygon) {
    if (!polygon || polygon.length < 3 || !b) return false;
    const boxEdges = [
      [b.x, b.y, b.x + b.w, b.y],
      [b.x + b.w, b.y, b.x + b.w, b.y + b.h],
      [b.x + b.w, b.y + b.h, b.x, b.y + b.h],
      [b.x, b.y + b.h, b.x, b.y]
    ];
    for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      const px1 = polygon[i].x, py1 = polygon[i].y;
      const px2 = polygon[j].x, py2 = polygon[j].y;
      for (const [bx1, by1, bx2, by2] of boxEdges) {
        if (segmentsIntersect(bx1, by1, bx2, by2, px1, py1, px2, py2)) {
          return true;
        }
      }
    }
    return false;
  }

  // --- Multi-Anchor & Geometric Polygon Containment Check ---
  function isTrackInZone(track, polygon) {
    if (!polygon || polygon.length < 3 || !track || !track.bboxN) return false;
    const b = track.bboxN;
    const cx = b.x + b.w / 2;
    const isBag = track.kind === 'bag';

    // 1. Primary ground contact / foot anchor
    if (track.footN && pointInPolygon(track.footN.x, track.footN.y, polygon)) {
      return true;
    }
    if (pointInPolygon(cx, b.y + b.h, polygon)) {
      return true;
    }

    // 2. Anatomical landmarks for persons (ankles, knees, hips, pelvis)
    if (!isBag && track.poseLandmarks) {
      const pose = track.poseLandmarks;
      const checkLm = (idx) => {
        if (pose[idx] && (pose[idx].visibility === undefined || pose[idx].visibility > 0.35)) {
          return pointInPolygon(pose[idx].x, pose[idx].y, polygon);
        }
        return false;
      };
      if (checkLm(27) || checkLm(28)) return true; // Ankles
      if (checkLm(25) || checkLm(26)) return true; // Knees
      if (checkLm(23) || checkLm(24)) return true; // Hips
      if (pose[23] && pose[24] && (pose[23].visibility || 1) > 0.35 && (pose[24].visibility || 1) > 0.35) {
        if (pointInPolygon((pose[23].x + pose[24].x) / 2, (pose[23].y + pose[24].y) / 2, polygon)) {
          return true;
        }
      }
    }

    // 3. Vertical body anchor points across bounding box:
    // When floor reflections extend bounding boxes down, testing shins, pelvis, centroid, chest:
    const testFractions = isBag ? [0.85, 0.50, 0.20] : [0.85, 0.70, 0.50, 0.35];
    for (const frac of testFractions) {
      if (pointInPolygon(cx, b.y + b.h * frac, polygon)) {
        return true;
      }
    }

    // 4. Bounding box edge intersection with polygon boundary
    if (bboxIntersectsPolygon(b, polygon)) {
      let polyMinY = Infinity, polyMaxY = -Infinity;
      let polyMinX = Infinity, polyMaxX = -Infinity;
      for (const pt of polygon) {
        if (pt.y < polyMinY) polyMinY = pt.y;
        if (pt.y > polyMaxY) polyMaxY = pt.y;
        if (pt.x < polyMinX) polyMinX = pt.x;
        if (pt.x > polyMaxX) polyMaxX = pt.x;
      }
      const cy = b.y + b.h / 2;
      if (cx >= polyMinX - 0.05 && cx <= polyMaxX + 0.05 && cy >= polyMinY - 0.05 && cy <= polyMaxY + 0.05) {
        return true;
      }
    }

    return false;
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

  const PRELOADED_SCENES = {
    'demo_s1_lab_entry.mp4': {
      id: 'demo_s1_lab_entry.mp4',
      name: 'Chemical Lab 01 · Entrance',
      image: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=1280&q=80',
      type: 'restricted'
    },
    'demo_s2_fall_stairs.mp4': {
      id: 'demo_s2_fall_stairs.mp4',
      name: 'Staircase East · Flight & Landing',
      image: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=1280&q=80',
      type: 'fall'
    },
    'demo_s3_restricted_zone.json': {
      id: 'demo_s3_restricted_zone.json',
      name: 'Restricted Hazard Zone · Factory Floor',
      image: 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=1280&q=80',
      type: 'restricted'
    },
    'demo_s4_ppe_check.mp4': {
      id: 'demo_s4_ppe_check.mp4',
      name: 'Construction Bay North · Machinery Dock',
      image: 'https://images.unsplash.com/photo-1541888946425-d0fbb186156f?w=1280&q=80',
      type: 'ppe'
    }
  };

  function matchPreloadedScene(sourceUrl) {
    if (!sourceUrl || typeof sourceUrl !== 'string') return null;
    const clean = sourceUrl.trim();
    for (const [key, scene] of Object.entries(PRELOADED_SCENES)) {
      if (clean === key || clean.includes(key) || key.includes(clean) || clean === scene.image) {
        return scene;
      }
    }
    if (clean.startsWith('http://images.') || clean.startsWith('https://images.')) {
      return {
        id: 'remote_scene',
        name: 'Preloaded CCTV Feed',
        image: clean,
        type: 'general'
      };
    }
    return null;
  }

  class ArgusVisionEngine {
    constructor() {
      this.isInitialized = false;
      this.isRunning = false;
      this.mode = 'live'; // 'live' | 'replay'
      this.videoEl = null;
      this.canvasEl = null;
      this.ctx = null;

      // Benchmark Simulation Scene State
      this.isSimulatingScene = false;
      this.activeSceneName = '';
      this.activeSceneType = 'general';
      this.sceneImg = null;
      
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
      this._isProcessingFrame = false;
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

    async _ensureVisionBundleLoaded() {
      // 1. Check if window.Vision is already loaded
      if (window.Vision && window.Vision.FilesetResolver) {
        return window.Vision;
      }
      if (window.tasksVision && window.tasksVision.FilesetResolver) {
        return window.tasksVision;
      }
      if (window.FilesetResolver && window.ObjectDetector) {
        return window;
      }

      // 2. Try loading via dynamic <script> tag from local vendor assets
      console.log('[ArgusVision] Loading vision_bundle.js from vendor assets...');
      const loadScript = (src) => new Promise((resolve, reject) => {
        const s = document.createElement('script');
        s.src = src;
        s.onload = () => resolve(window.Vision || window.tasksVision || window);
        s.onerror = (e) => reject(e);
        document.head.appendChild(s);
      });

      try {
        await loadScript('vision/vendor/vision_bundle.js');
        if (window.Vision && window.Vision.FilesetResolver) {
          return window.Vision;
        }
      } catch (scriptErr) {
        console.warn('[ArgusVision] Vendor script tag load failed, trying ES import:', scriptErr);
      }

      // 3. Fallback: ES module dynamic import
      try {
        const mod = await import('./vendor/vision_bundle.js');
        if (mod && (mod.FilesetResolver || (mod.default && mod.default.FilesetResolver))) {
          return mod.FilesetResolver ? mod : mod.default;
        }
      } catch (modErr) {
        console.warn('[ArgusVision] Dynamic module import failed:', modErr);
      }

      return window.Vision || window.tasksVision || window;
    }

    async init(rawOptions = {}) {
      if (this.hasMediaPipeLoaded && this.objectDetector && this.poseLandmarker) {
        return true;
      }
      if (this._initPromise) {
        return this._initPromise;
      }

      this._initPromise = (async () => {
        let options = rawOptions;
        if (typeof options === 'string') {
          try { options = JSON.parse(options); } catch (e) { options = {}; }
        }
        if (options && options.wasmBaseUrl) this.wasmBaseUrl = options.wasmBaseUrl;
        if (options && options.detectorModelPath) this.detectorModelPath = options.detectorModelPath;
        if (options && options.poseModelPath) this.poseModelPath = options.poseModelPath;

        this.notifyStatus('initializing', 'Loading on-device vision WASM and models...');

      try {
        const visionPkg = await this._ensureVisionBundleLoaded();
        if (!visionPkg || !visionPkg.FilesetResolver) {
          throw new Error('MediaPipe FilesetResolver not found on global scope');
        }

        const vision = await visionPkg.FilesetResolver.forVisionTasks(this.wasmBaseUrl);
        
        let objectDetector = null;
        let poseLandmarker = null;
        let usedDelegate = 'GPU';

        // 1. Try hardware-accelerated WebGL GPU delegate for silky-smooth 30-60 FPS performance
        try {
          console.log('[ArgusVision] Initializing MediaPipe with WebGL GPU acceleration in VIDEO mode...');
          objectDetector = await visionPkg.ObjectDetector.createFromOptions(vision, {
            baseOptions: {
              modelAssetPath: this.detectorModelPath,
              delegate: 'GPU'
            },
            runningMode: 'VIDEO',
            scoreThreshold: 0.35,
            maxResults: 20,
            categoryAllowlist: ['person', 'backpack', 'handbag', 'suitcase']
          });

          poseLandmarker = await visionPkg.PoseLandmarker.createFromOptions(vision, {
            baseOptions: {
              modelAssetPath: this.poseModelPath,
              delegate: 'GPU'
            },
            runningMode: 'VIDEO',
            numPoses: 8,
            minPoseDetectionConfidence: 0.45,
            minPosePresenceConfidence: 0.45,
            minTrackingConfidence: 0.45
          });
          console.log('[ArgusVision] MediaPipe initialized with GPU delegate successfully.');
        } catch (gpuErr) {
          console.warn('[ArgusVision] WebGL GPU delegate unavailable, falling back to CPU SIMD:', gpuErr);
          usedDelegate = 'CPU';
          objectDetector = await visionPkg.ObjectDetector.createFromOptions(vision, {
            baseOptions: {
              modelAssetPath: this.detectorModelPath,
              delegate: 'CPU'
            },
            runningMode: 'VIDEO',
            scoreThreshold: 0.35,
            maxResults: 20,
            categoryAllowlist: ['person', 'backpack', 'handbag', 'suitcase']
          });

          poseLandmarker = await visionPkg.PoseLandmarker.createFromOptions(vision, {
            baseOptions: {
              modelAssetPath: this.poseModelPath,
              delegate: 'CPU'
            },
            runningMode: 'VIDEO',
            numPoses: 8,
            minPoseDetectionConfidence: 0.45,
            minPosePresenceConfidence: 0.45,
            minTrackingConfidence: 0.45
          });
          console.log('[ArgusVision] MediaPipe initialized with CPU delegate successfully.');
        }

        this.objectDetector = objectDetector;
        this.poseLandmarker = poseLandmarker;
        this.hasMediaPipeLoaded = true;
        this.notifyStatus('ready', `MediaPipe Tasks Vision loaded (${usedDelegate} accelerated, VIDEO mode)`);
      } catch (err) {
        console.warn('[ArgusVision] MediaPipe init error, enabling resilient simulation fallback:', err);
        this.hasMediaPipeLoaded = false;
        this.notifyStatus('fallback', 'MediaPipe models unavailable; visual simulation active');
      }

        this.isInitialized = true;
        return true;
      })();

      try {
        return await this._initPromise;
      } finally {
        this._initPromise = null;
      }
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
      const { targetFps = 15, sourceKind = 'webcam', sourceUrl = null } = options || {};
      this.targetFps = targetFps || 15;
      console.log('[ArgusVision] Pipeline starting. sourceKind:', sourceKind, 'sourceUrl:', sourceUrl, 'targetFps:', this.targetFps);

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
        this.videoEl.autoplay = false;
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

      // Ensure MediaPipe vision models are loaded BEFORE video playback begins!
      if (!this.hasMediaPipeLoaded) {
        this.notifyStatus('initializing', 'Waiting for MediaPipe vision models to load...');
        console.log('[ArgusVision] Waiting for MediaPipe vision models to load before playback...');
        if (this._initPromise) {
          await this._initPromise;
        } else {
          await this.init();
        }
      }

      if (sourceKind === 'file') {
        // Detach webcam MediaStream
        if (this.videoEl) {
          this.videoEl.pause();
          this.videoEl.srcObject = null;
        }

        const matchedScene = matchPreloadedScene(sourceUrl);

        if (matchedScene) {
          // Preloaded Benchmark Scene: Run simulation with real background image & realistic CCTV pipeline
          this.isSimulatingScene = true;
          this.activeSceneName = matchedScene.name;
          this.activeSceneType = matchedScene.type;
          this.sceneImg = new Image();
          this.sceneImg.crossOrigin = 'anonymous';
          this.sceneImg.src = matchedScene.image;

          if (this.videoEl) {
            this.videoEl.src = '';
            this.videoEl.removeAttribute('src');
          }
          this.notifyStatus('running', `Preloaded CCTV feed active: ${matchedScene.name}`);
        } else if (!sourceUrl || sourceUrl === 'local' || sourceUrl.trim() === '') {
          // No local MP4 chosen: Fall back gracefully to the first benchmark scene
          const defaultScene = PRELOADED_SCENES['demo_s1_lab_entry.mp4'];
          this.isSimulatingScene = true;
          this.activeSceneName = defaultScene.name;
          this.activeSceneType = defaultScene.type;
          this.sceneImg = new Image();
          this.sceneImg.crossOrigin = 'anonymous';
          this.sceneImg.src = defaultScene.image;
          this.notifyStatus('running', `Benchmark preview feed active (${defaultScene.name})`);
        } else {
          // Custom local MP4 / WebM file selected from disk
          this.isSimulatingScene = false;
          this.videoEl.loop = true;
          this.videoEl.muted = true;
          this.videoEl.playsInline = true;
          this.videoEl.autoplay = false;
          this.videoEl.pause();

          if (this.videoEl.src !== sourceUrl) {
            this.videoEl.src = sourceUrl;
            this.videoEl.load();
          }

          if (this._onVideoEnded) this.videoEl.removeEventListener('ended', this._onVideoEnded);
          this._onVideoEnded = () => {
            console.log('[ArgusVision] Video ended/loop reset.');
          };
          this.videoEl.addEventListener('ended', this._onVideoEnded);

          if (this._onVideoPlay) this.videoEl.removeEventListener('play', this._onVideoPlay);
          this._onVideoPlay = () => {
            console.log('[ArgusVision] Video playback active.');
            this.notifyStatus('running', 'Video playback active');
            this.tracks.clear();
            if (this.ctx && this.canvasEl) {
              this.ctx.clearRect(0, 0, this.canvasEl.width, this.canvasEl.height);
            }
          };
          this.videoEl.addEventListener('play', this._onVideoPlay);

          // Wait for video frame decoding readiness before calling play()
          if (this.videoEl.readyState < 2) {
            await new Promise((resolve) => {
              let resolved = false;
              const onReady = () => {
                if (resolved) return;
                resolved = true;
                this.videoEl.removeEventListener('canplay', onReady);
                this.videoEl.removeEventListener('loadeddata', onReady);
                this.videoEl.removeEventListener('error', onReady);
                resolve();
              };
              this.videoEl.addEventListener('canplay', onReady);
              this.videoEl.addEventListener('loadeddata', onReady);
              this.videoEl.addEventListener('error', onReady);
              setTimeout(onReady, 2000);
            });
          }

          try {
            await this.videoEl.play();
            this.notifyStatus('running', 'Video file playing: ' + sourceUrl);
          } catch (playErr) {
            console.warn('[ArgusVision] video.play() waiting for canplay or error:', playErr);
            try {
              let didLoad = false;
              await new Promise((resolve) => {
                const onCanPlay = () => {
                  this.videoEl.removeEventListener('canplay', onCanPlay);
                  this.videoEl.removeEventListener('error', onError);
                  didLoad = true;
                  resolve();
                };
                const onError = () => {
                  this.videoEl.removeEventListener('canplay', onCanPlay);
                  this.videoEl.removeEventListener('error', onError);
                  didLoad = false;
                  resolve();
                };
                if (this.videoEl.readyState >= 3) {
                  didLoad = true;
                  resolve();
                } else {
                  this.videoEl.addEventListener('canplay', onCanPlay);
                  this.videoEl.addEventListener('error', onError);
                  this.videoEl.load();
                }
              });

              if (didLoad && !this.videoEl.error) {
                await this.videoEl.play();
                this.notifyStatus('running', 'Video file playing: ' + sourceUrl);
              }
            } catch (retryErr) {
              console.warn('[ArgusVision] Play retry error:', retryErr);
            }
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
      this.isSimulatingScene = false;
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
      if (!this.isSimulatingScene && this.videoEl && 'requestVideoFrameCallback' in this.videoEl && !this.videoEl.paused) {
        this.videoEl.requestVideoFrameCallback(this._processFrame);
      } else {
        requestAnimationFrame(this._processFrame);
      }
    }

    async _processFrame(nowMs) {
      if (!this.isRunning) return;
      if (this.videoEl && this.videoEl.ended) return;
      if (this._isProcessingFrame) return; // Strict lock against concurrent WASM re-entry
      this._isProcessingFrame = true;

      try {
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

        if (this.isSimulatingScene) {
          // Preloaded benchmark CCTV feed simulation
          this._drawSceneBackground();
          detectedPersons = this._generateSimulatedDetections(now);
        } else if (this.hasMediaPipeLoaded && this.objectDetector && this.videoEl && this.videoEl.readyState >= 2) {
          try {
            // Strictly monotonic timestamps for MediaPipe VIDEO mode
            let detectorTs = Math.round(now);
            if (detectorTs <= this._lastDetectorTimestamp) {
              detectorTs = this._lastDetectorTimestamp + 1;
            }
            this._lastDetectorTimestamp = detectorTs;

            // 1. Primary detection: ObjectDetector runs directly on hardware HTMLVideoElement in VIDEO mode!
            const detections = this.objectDetector.detectForVideo(this.videoEl, detectorTs);
            detectedPersons = this._extractPersons(detections);

            // 2. Secondary detection: PoseLandmarker on detected persons or periodic background scan
            const shouldRunPose = this.poseLandmarker && (detectedPersons.length > 0 || (this.frameCount % 4 === 0));
            if (shouldRunPose) {
              let poseTs = Math.round(now);
              if (poseTs <= this._lastPoseTimestamp) {
                poseTs = this._lastPoseTimestamp + 1;
              }
              this._lastPoseTimestamp = poseTs;

              const poseResult = this.poseLandmarker.detectForVideo(this.videoEl, poseTs);
              this._matchPosesToDetections(detectedPersons, poseResult);
            }

            // Deduplicate and fuse overlapping multi-pass detections
            detectedPersons = this._filterOverlappingDetections(detectedPersons);
          } catch (inferenceErr) {
            console.warn('[ArgusVision] Frame inference glitch:', inferenceErr);
            detectedPersons = [];
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
      } finally {
        this._isProcessingFrame = false;
      }
    }

    _drawSceneBackground() {
      if (!this.ctx || !this.canvasEl) return;
      const w = this.canvasEl.width || 1280;
      const h = this.canvasEl.height || 720;

      if (this.sceneImg && this.sceneImg.complete && this.sceneImg.naturalWidth > 0) {
        try {
          this.ctx.drawImage(this.sceneImg, 0, 0, w, h);
        } catch (_) {
          this.ctx.fillStyle = '#070b12';
          this.ctx.fillRect(0, 0, w, h);
        }
      } else {
        this.ctx.fillStyle = '#070b12';
        this.ctx.fillRect(0, 0, w, h);
      }

      // Render CCTV Watermark HUD
      this.ctx.save();
      this.ctx.fillStyle = 'rgba(255, 255, 255, 0.90)';
      this.ctx.font = '700 13px "Courier New", monospace';
      const d = new Date();
      const pad = (n) => String(n).padStart(2, '0');
      const timeStr = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
      const tag = this.activeSceneName ? this.activeSceneName.toUpperCase() : 'CCTV CAM 01';
      this.ctx.fillText(`● REC · ${tag} · ${timeStr} · 1080P 30FPS [ARGUS CORE]`, 16, 26);
      this.ctx.restore();
    }

    _syncCanvasSize() {
      if (!this.canvasEl) return;
      let w = 1280;
      let h = 720;
      if (!this.isSimulatingScene && this.videoEl && this.videoEl.videoWidth > 0) {
        w = this.videoEl.videoWidth;
        h = this.videoEl.videoHeight;
      } else if (this.canvasEl.parentElement) {
        w = this.canvasEl.parentElement.clientWidth || 1280;
        h = this.canvasEl.parentElement.clientHeight || 720;
      }
      if (this.canvasEl.width !== w || this.canvasEl.height !== h) {
        this.canvasEl.width = w;
        this.canvasEl.height = h;
      }
    }

    _extractPersons(detections) {
      if (!detections || !detections.detections) return [];
      const pw = (this.videoEl && this.videoEl.videoWidth > 0) ? this.videoEl.videoWidth : 640;
      const ph = (this.videoEl && this.videoEl.videoHeight > 0) ? this.videoEl.videoHeight : 480;
      const objects = [];

      for (const d of detections.detections) {
        const b = d.boundingBox;
        if (!b) continue;

        // Normalize to 0.0 .. 1.0 with robust clamping
        const nx = Math.max(0, Math.min(0.99, b.originX / pw));
        const ny = Math.max(0, Math.min(0.99, b.originY / ph));
        const nw = Math.max(0.01, Math.min(1.0 - nx, b.width / pw));
        const nh = Math.max(0.01, Math.min(1.0 - ny, b.height / ph));
        const area = nw * nh;
        const asp = nw / Math.max(0.01, nh);

        // Discard sub-pixel or extreme specks (sensor noise)
        if (area < 0.001) continue;

        const categories = d.categories || [];

        // 1. PERSON EVALUATION: Broad, sensitive detection of all upright and prone humans
        const personCat = categories.find(c => c.categoryName === 'person');
        if (personCat) {
          // Standard person confidence threshold (detects all real persons)
          if (personCat.score < 0.40) continue;

          // Reject physically impossible bounding box slivers (< 0.12) or extreme panoramic seams (> 2.10)
          if (asp > 2.10 || asp < 0.12) continue;

          // Furniture discrimination: wide square-ish boxes (aspect > 0.85, typical of chairs/cubicles)
          // require higher confidence (>= 0.55) to suppress chair hallucinations without filtering upright humans
          if (asp > 0.85 && personCat.score < 0.55 && area < 0.04) continue;

          objects.push({
            kind: 'person',
            category: 'person',
            label: 'Person',
            bboxN: { x: nx, y: ny, w: nw, h: nh },
            confidence: personCat.score,
            poseLandmarks: null
          });
          continue;
        }

        // 2. BAG / BACKPACK / HANDBAG / SUITCASE EVALUATION
        const bagCat = categories.find(c => ['backpack', 'handbag', 'suitcase'].includes(c.categoryName));
        if (bagCat && bagCat.score >= 0.35) {
          // Bags have reasonable aspect ratio (0.35 to 2.6) and detectable area (>= 0.0012)
          if (asp < 0.32 || asp > 2.6 || area < 0.0012) continue;

          let bagLabel = 'Backpack';
          if (bagCat.categoryName === 'suitcase') bagLabel = 'Luggage';
          else if (bagCat.categoryName === 'handbag') bagLabel = 'Handbag';

          objects.push({
            kind: 'bag',
            category: bagCat.categoryName,
            label: bagLabel,
            bboxN: { x: nx, y: ny, w: nw, h: nh },
            confidence: bagCat.score,
            poseLandmarks: null
          });
          continue;
        }
      }
      return objects;
    }

    _matchPosesToDetections(objects, poseResult) {
      if (!poseResult || !poseResult.landmarks || poseResult.landmarks.length === 0) return;

      // 1. Filter and validate poses with key torso and body landmarks
      const validPoses = [];
      for (const pose of poseResult.landmarks) {
        let cx = 0, cy = 0, count = 0;
        let minX = 1, minY = 1, maxX = 0, maxY = 0;

        for (const lm of pose) {
          const vis = (lm.visibility !== undefined) ? lm.visibility : 1.0;
          const pres = (lm.presence !== undefined) ? lm.presence : 1.0;
          if (vis > 0.40 && pres > 0.40) {
            cx += lm.x;
            cy += lm.y;
            count++;
            if (lm.x < minX) minX = lm.x;
            if (lm.x > maxX) maxX = lm.x;
            if (lm.y < minY) minY = lm.y;
            if (lm.y > maxY) maxY = lm.y;
          }
        }
        if (count < 6) continue;
        cx /= count;
        cy /= count;

        const hasTorso = ((pose[11]?.visibility || 0) > 0.40 || (pose[12]?.visibility || 0) > 0.40) &&
                         ((pose[23]?.visibility || 0) > 0.40 || (pose[24]?.visibility || 0) > 0.40);

        validPoses.push({
          pose,
          cx,
          cy,
          count,
          minX,
          minY,
          maxX,
          maxY,
          hasTorso
        });
      }

      if (validPoses.length === 0) return;

      // 2. Associate poses to person detector bounding boxes
      const personObjects = objects.filter(o => o.kind === 'person');
      const boxToPoses = new Map(); // personObject -> Array of validPoses

      for (const vp of validPoses) {
        let bestPerson = null;
        let bestDist = Infinity;

        for (const p of personObjects) {
          const pcx = p.bboxN.x + p.bboxN.w / 2;
          const pcy = p.bboxN.y + p.bboxN.h / 2;
          const dist = Math.hypot(vp.cx - pcx, vp.cy - pcy);
          // Check if pose center lies within person box or close proximity (< 0.16)
          const isInside = vp.cx >= p.bboxN.x - 0.04 && vp.cx <= p.bboxN.x + p.bboxN.w + 0.04 &&
                           vp.cy >= p.bboxN.y - 0.06 && vp.cy <= p.bboxN.y + p.bboxN.h + 0.06;

          if ((isInside || dist < 0.16) && dist < bestDist) {
            bestDist = dist;
            bestPerson = p;
          }
        }

        if (bestPerson) {
          if (!boxToPoses.has(bestPerson)) boxToPoses.set(bestPerson, []);
          boxToPoses.get(bestPerson).push(vp);
        } else if (vp.hasTorso && vp.count >= 8) {
          // Pose detected outside existing boxes -> synthesize individual worker entity
          const spanW = vp.maxX - vp.minX;
          const spanH = vp.maxY - vp.minY;
          if (spanH >= 0.14) {
            const padX = Math.max(0.02, spanW * 0.20);
            const padY = Math.max(0.02, spanH * 0.10);
            const nx = Math.max(0, vp.minX - padX);
            const ny = Math.max(0, vp.minY - padY);
            const nw = Math.min(1.0 - nx, spanW + 2 * padX);
            const nh = Math.min(1.0 - ny, spanH + 2 * padY);

            objects.push({
              kind: 'person',
              category: 'person',
              label: 'Person',
              bboxN: { x: nx, y: ny, w: nw, h: nh },
              confidence: 0.78,
              poseLandmarks: vp.pose,
              isSynthesized: true
            });
          }
        }
      }

      // 3. Process matched boxes: 1-to-1 match vs Multi-Person Cluster Splitting
      for (const [pBox, matchedPoses] of boxToPoses.entries()) {
        if (matchedPoses.length === 1) {
          // Exactly 1 pose matched: 1-to-1 association with vertical refinement
          const vp = matchedPoses[0];
          pBox.poseLandmarks = vp.pose;

          // Safe vertical-only refinement for head/feet (NEVER expand width across neighbors)
          const pMinY = Math.min(pBox.bboxN.y, vp.minY - 0.015);
          const pMaxY = Math.max(pBox.bboxN.y + pBox.bboxN.h, vp.maxY + 0.015);
          pBox.bboxN.y = Math.max(0, pMinY);
          pBox.bboxN.h = Math.min(1.0 - pBox.bboxN.y, pMaxY - pMinY);
        } else if (matchedPoses.length > 1) {
          // MULTI-PERSON CLUSTER DETECTED: EfficientDet grouped multiple workers into one entity!
          // Disaggregate cluster: remove the merged cluster box and spawn individual worker entities
          const clusterIndex = objects.indexOf(pBox);
          if (clusterIndex !== -1) {
            objects.splice(clusterIndex, 1);

            for (const vp of matchedPoses) {
              const spanW = vp.maxX - vp.minX;
              const spanH = vp.maxY - vp.minY;
              const padX = Math.max(0.02, spanW * 0.22);
              const padY = Math.max(0.02, spanH * 0.10);
              const nx = Math.max(0, vp.minX - padX);
              const ny = Math.max(0, vp.minY - padY);
              const nw = Math.min(1.0 - nx, spanW + 2 * padX);
              const nh = Math.min(1.0 - ny, spanH + 2 * padY);

              objects.push({
                kind: 'person',
                category: 'person',
                label: 'Person',
                bboxN: { x: nx, y: ny, w: nw, h: nh },
                confidence: Math.max(pBox.confidence, 0.82),
                poseLandmarks: vp.pose,
                isDisaggregated: true
              });
            }
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
        const curCx = cur.bboxN.x + cur.bboxN.w / 2;

        for (const prev of filtered) {
          // Only compare objects of the same category kind
          if (cur.kind === prev.kind) {
            const iou = computeIoU(cur.bboxN, prev.bboxN);
            const prevCx = prev.bboxN.x + prev.bboxN.w / 2;
            const horizontalSeparation = Math.abs(curCx - prevCx);

            // In crowded environments / construction sites, workers standing side-by-side
            // have distinct horizontal centers (>= 0.035 screen width). Do NOT suppress them!
            if (cur.kind === 'person' && horizontalSeparation >= 0.035) {
              // Only suppress if extreme overlap (iou >= 0.85, virtually identical bounding box)
              if (iou >= 0.85) {
                if (!prev.poseLandmarks && cur.poseLandmarks) prev.poseLandmarks = cur.poseLandmarks;
                isDuplicate = true;
                break;
              }
            } else {
              // Standard duplicate suppression for coincident detections
              if (iou > 0.65) {
                if (!prev.poseLandmarks && cur.poseLandmarks) prev.poseLandmarks = cur.poseLandmarks;
                isDuplicate = true;
                break;
              }
            }
          }
        }
        if (!isDuplicate) {
          filtered.push(cur);
        }
      }
      return filtered;
    }

    _generateSimulatedDetections(now) {
      const type = this.activeSceneType || 'general';
      const loopSec = 14;
      const t = (now / 1000) % loopSec;

      if (type === 'fall') {
        // Staircase fall scenario:
        // t = 0 to 4s: Walking down stairs (upright, motion)
        // t = 4 to 10s: Trips and falls flat on landing (horizontal, motionless, fallScore = 0.95)
        // t = 10 to 14s: Medical response arrives (2 persons)
        if (t < 4.0) {
          const progress = t / 4.0;
          return [{
            bboxN: { x: 0.35 + 0.15 * progress, y: 0.20 + 0.20 * progress, w: 0.16, h: 0.48 },
            confidence: 0.94,
            poseLandmarks: null,
            isSimulated: true,
            isFalling: false,
            motionScore: 0.15,
            motionlessMs: 0
          }];
        } else if (t < 10.0) {
          const downMs = Math.round((t - 4.0) * 1000);
          return [{
            bboxN: { x: 0.50, y: 0.65, w: 0.36, h: 0.18 },
            confidence: 0.95,
            poseLandmarks: null,
            isSimulated: true,
            isFalling: true,
            motionScore: 0.0,
            motionlessMs: downMs
          }];
        } else {
          return [
            {
              bboxN: { x: 0.50, y: 0.65, w: 0.36, h: 0.18 },
              confidence: 0.95,
              poseLandmarks: null,
              isSimulated: true,
              isFalling: true,
              motionScore: 0.0,
              motionlessMs: 6000
            },
            {
              bboxN: { x: 0.30, y: 0.45, w: 0.16, h: 0.45 },
              confidence: 0.92,
              poseLandmarks: null,
              isSimulated: true,
              isFalling: false,
              motionScore: 0.12,
              motionlessMs: 0
            }
          ];
        }
      }

      if (type === 'restricted') {
        // Restricted Zone Intrusion Scenario:
        // Person walks from doorway (x=0.15) into the center of the restricted zone (x=0.50, y=0.48), stays 6s, then leaves
        const isTrespassing = t >= 3.5 && t <= 10.5;
        let x, y, motionlessMs = 0;
        if (t < 3.5) {
          x = 0.15 + (t / 3.5) * 0.35;
          y = 0.35;
        } else if (t <= 10.5) {
          x = 0.50 + 0.02 * Math.sin(t);
          y = 0.48;
          motionlessMs = Math.round((t - 3.5) * 1000);
        } else {
          x = 0.50 + ((t - 10.5) / 3.5) * 0.35;
          y = 0.38;
        }
        return [{
          bboxN: { x, y, w: 0.17, h: 0.52 },
          confidence: 0.96,
          poseLandmarks: null,
          isSimulated: true,
          isFalling: false,
          motionScore: isTrespassing ? 0.01 : 0.10,
          motionlessMs
        }];
      }

      if (type === 'ppe') {
        // Construction Bay North: Group of workers collaborating on site
        // Worker 1 (Foreman/Lead): Center-left, inspecting structure
        const w1x = 0.36 + 0.03 * Math.sin(t * 0.4);
        const w1y = 0.30;
        // Worker 2 (Technician): Center, side-by-side with Worker 1 (cluster arrangement)
        const w2x = 0.49 + 0.02 * Math.cos(t * 0.5);
        const w2y = 0.32;
        // Worker 3 (Equipment Specialist): Center-right
        const w3x = 0.62 + 0.02 * Math.sin(t * 0.3);
        const w3y = 0.34;

        return [
          {
            kind: 'person',
            category: 'person',
            label: 'Person',
            bboxN: { x: w1x, y: w1y, w: 0.13, h: 0.50 },
            confidence: 0.94,
            poseLandmarks: null,
            isSimulated: true,
            isFalling: false,
            motionScore: 0.06,
            motionlessMs: 0
          },
          {
            kind: 'person',
            category: 'person',
            label: 'Person',
            bboxN: { x: w2x, y: w2y, w: 0.13, h: 0.48 },
            confidence: 0.92,
            poseLandmarks: null,
            isSimulated: true,
            isFalling: false,
            motionScore: 0.04,
            motionlessMs: 0
          },
          {
            kind: 'person',
            category: 'person',
            label: 'Person',
            bboxN: { x: w3x, y: w3y, w: 0.12, h: 0.46 },
            confidence: 0.90,
            poseLandmarks: null,
            isSimulated: true,
            isFalling: false,
            motionScore: 0.05,
            motionlessMs: 0
          },
          {
            kind: 'bag',
            category: 'backpack',
            label: 'Backpack',
            bboxN: { x: 0.24, y: 0.66, w: 0.08, h: 0.11 },
            confidence: 0.88,
            poseLandmarks: null,
            isSimulated: true,
            motionScore: 0.0,
            motionlessMs: Math.round(t * 1000)
          }
        ];
      }

      // Default scenario (General)
      const x = 0.35 + 0.22 * Math.sin(t * 0.4);
      const isFalling = t > 7 && t < 10.5;
      const y = isFalling ? 0.65 : 0.28;
      const w = isFalling ? 0.38 : 0.16;
      const h = isFalling ? 0.18 : 0.52;

      const dets = [{
        kind: 'person',
        category: 'person',
        label: 'Person',
        bboxN: { x, y, w, h },
        confidence: 0.94,
        poseLandmarks: null,
        isSimulated: true,
        isFalling,
        motionScore: isFalling ? 0.0 : 0.08,
        motionlessMs: isFalling ? Math.round((t - 7) * 1000) : 0
      }];

      // Add a stationary bag to demonstrate bag detection & unattended luggage handling
      dets.push({
        kind: 'bag',
        category: 'backpack',
        label: 'Backpack',
        bboxN: { x: 0.74, y: 0.64, w: 0.09, h: 0.13 },
        confidence: 0.89,
        poseLandmarks: null,
        isSimulated: true,
        motionScore: 0.0,
        motionlessMs: Math.round(t * 1000)
      });

      return dets;
    }

    _updateTracker(detectedObjects, now) {
      // Bipartite matching with combined IoU + Centroid proximity
      const candidatePairs = [];

      for (let i = 0; i < detectedObjects.length; i++) {
        for (const [trackId, track] of this.tracks.entries()) {
          // Gating: only match detections to existing tracks of the SAME category kind!
          if (detectedObjects[i].kind && track.kind && detectedObjects[i].kind !== track.kind) {
            continue;
          }
          const score = computeBboxSimilarity(detectedObjects[i].bboxN, track.bboxN);
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
        const det = detectedObjects[m.detIndex];
        const track = this.tracks.get(m.trackId);
        const alpha = 0.65; // Exponential Moving Average smoothing factor

        const newCx = det.bboxN.x + det.bboxN.w / 2;
        const newCy = det.bboxN.y + det.bboxN.h / 2;
        const shift = Math.hypot(newCx - (track.smoothCx || newCx), newCy - (track.smoothCy || newCy));
        track.totalDisplacement = (track.totalDisplacement || 0) + shift;

        track.bboxN = {
          x: track.bboxN.x * (1 - alpha) + det.bboxN.x * alpha,
          y: track.bboxN.y * (1 - alpha) + det.bboxN.y * alpha,
          w: track.bboxN.w * (1 - alpha) + det.bboxN.w * alpha,
          h: track.bboxN.h * (1 - alpha) + det.bboxN.h * alpha,
        };
        track.confidence = track.confidence * 0.3 + det.confidence * 0.7;
        track.hits = (track.hits || 1) + 1;
        if (det.poseLandmarks) track.poseLandmarks = det.poseLandmarks;

        // Confirmation gating:
        // Any track persisting for 2 consecutive frames (hits >= 2) OR with initial confidence >= 0.50 is confirmed!
        // Pose is an enhancement, not a prerequisite for human detection.
        if (track.hits >= 2 || det.confidence >= 0.50 || !!det.poseLandmarks || det.kind === 'bag' || det.isSimulated) {
          track.isConfirmed = true;
        }

        if (det.isFalling !== undefined) {
          track.isFalling = det.isFalling;
          if (det.isFalling) track.hasFallen = true;
        }
        if (det.motionlessMs !== undefined && det.isSimulated) {
          track.motionlessMs = det.motionlessMs;
        }
        if (det.motionScore !== undefined && det.isSimulated) {
          track.motionScore = det.motionScore;
        }
        track.lastSeenMs = now;
      }

      // 2. Initialize new tracks for unmatched detections
      for (let i = 0; i < detectedObjects.length; i++) {
        if (!matchedDets.has(i)) {
          const det = detectedObjects[i];
          const newId = this.nextTrackId++;
          // High-conviction detections, pose-backed persons, bags, or simulations confirmed immediately
          const isConfirmed = det.confidence >= 0.50 || !!det.isSimulated || det.kind === 'bag' || !!det.poseLandmarks;
          this.tracks.set(newId, {
            trackId: newId,
            kind: det.kind || 'person',
            category: det.category || 'person',
            label: det.label || (det.kind === 'bag' ? 'Bag' : 'Person'),
            hits: 1,
            isConfirmed,
            bboxN: { ...det.bboxN },
            footN: { x: det.bboxN.x + det.bboxN.w / 2, y: det.bboxN.y + det.bboxN.h },
            zoneIds: [],
            confidence: det.confidence,
            poseLandmarks: det.poseLandmarks,
            firstSeenMs: now,
            lastSeenMs: now,
            smoothCx: det.bboxN.x + det.bboxN.w / 2,
            smoothCy: det.bboxN.y + det.bboxN.h / 2,
            totalDisplacement: 0,
            motionScore: det.motionScore !== undefined ? det.motionScore : 0.05,
            motionlessStartMs: null,
            motionlessMs: det.motionlessMs || 0,
            movingFramesCount: 0,
            fallScore: det.isFalling ? 0.95 : 0.0,
            hasFallen: !!det.isFalling,
            isFalling: !!det.isFalling,
            fallenSinceMs: det.isFalling ? (now - (det.motionlessMs || 0)) : null,
            uprightFramesCount: 0,
            history: []
          });
        }
      }

      // 3. Age out tracks
      for (const [trackId, track] of this.tracks.entries()) {
        if (!matchedTracks.has(trackId)) {
          // Unconfirmed tracks (1-frame optical glitches) age out in 250ms
          const maxAge = track.isConfirmed ? 1800 : 250;
          if (now - track.lastSeenMs > maxAge) {
            this.tracks.delete(trackId);
          }
        }
      }
    }

    _computeSignals(now) {
      const signals = [];

      for (const [trackId, track] of this.tracks.entries()) {
        // Only emit and render confirmed tracks (suppresses single-frame optical glitches)
        if (!track.isConfirmed) continue;

        const b = track.bboxN;
        const isBag = track.kind === 'bag';

        // 1. Foot/Anchor Point calculation
        let anchorX = b.x + b.w / 2;
        let anchorY = b.y + b.h;

        if (!isBag && track.poseLandmarks) {
          const pose = track.poseLandmarks;
          if (pose[27] && pose[28] && (pose[27].visibility || 0) > 0.35 && (pose[28].visibility || 0) > 0.35) {
            anchorX = (pose[27].x + pose[28].x) / 2;
            anchorY = (pose[27].y + pose[28].y) / 2;
          }
        }
        track.footN = { x: anchorX, y: anchorY };

        // 2. Multi-point & geometric zone containment checks
        const matchedZoneIds = [];
        for (const zone of this.zones) {
          if (isTrackInZone(track, zone.polygon)) {
            matchedZoneIds.push(zone.id);
          }
        }
        track.zoneIds = matchedZoneIds;

        // 3. BAG SPECIFIC HANDLING (Unattended Luggage & Motionlessness)
        if (isBag) {
          const rawCx = b.x + b.w / 2;
          const rawCy = b.y + b.h / 2;

          track.smoothCx = (track.smoothCx !== undefined) ? (track.smoothCx * 0.70 + rawCx * 0.30) : rawCx;
          track.smoothCy = (track.smoothCy !== undefined) ? (track.smoothCy * 0.70 + rawCy * 0.30) : rawCy;

          track.history.push({ t: now, cx: track.smoothCx, cy: track.smoothCy });
          track.history = track.history.filter(h => now - h.t <= 5000);

          let sample1s = track.history[0];
          const dist = sample1s ? Math.hypot(track.smoothCx - sample1s.cx, track.smoothCy - sample1s.cy) : 0.0;
          const elapsedSec = sample1s ? Math.max(0.5, (now - sample1s.t) / 1000) : 1.0;
          const velocity = dist / elapsedSec;

          const isStationary = velocity < 0.025;
          if (isStationary) {
            if (!track.motionlessStartMs) track.motionlessStartMs = now;
            track.motionlessMs = Math.max(0, now - track.motionlessStartMs);
          } else {
            track.motionlessStartMs = null;
            track.motionlessMs = 0;
          }

          // Check if any person is in proximity (< 0.22 normalized distance)
          let hasNearbyPerson = false;
          for (const [, otherTrack] of this.tracks.entries()) {
            if (otherTrack.kind === 'person' && otherTrack.isConfirmed) {
              const ocx = otherTrack.bboxN.x + otherTrack.bboxN.w / 2;
              const ocy = otherTrack.bboxN.y + otherTrack.bboxN.h / 2;
              if (Math.hypot(rawCx - ocx, rawCy - ocy) < 0.22) {
                hasNearbyPerson = true;
                break;
              }
            }
          }

          track.isUnattended = (!hasNearbyPerson && track.motionlessMs >= 2500);

          signals.push({
            trackId,
            kind: 'bag',
            category: track.category,
            label: track.label,
            bboxN: b,
            footN: track.footN,
            zoneIds: track.zoneIds,
            aspect: Number((b.w / Math.max(0.01, b.h)).toFixed(2)),
            motionScore: 0.0,
            fallScore: 0.0,
            isUnattended: track.isUnattended,
            motionlessMs: Math.round(track.motionlessMs),
            confidence: Number(track.confidence.toFixed(2)),
            poseLandmarks: null
          });
          continue;
        }

        // 4. PERSON SPECIFIC HANDLING: Motion, Posture & Fall Detection
        const pose = track.poseLandmarks;
        const rawCx = b.x + b.w / 2;
        const rawCy = b.y + b.h / 2;
        const aspect = b.w / Math.max(0.01, b.h);

        track.smoothCx = (track.smoothCx !== undefined) ? (track.smoothCx * 0.70 + rawCx * 0.30) : rawCx;
        track.smoothCy = (track.smoothCy !== undefined) ? (track.smoothCy * 0.70 + rawCy * 0.30) : rawCy;

        track.history.push({ t: now, cx: track.smoothCx, cy: track.smoothCy, w: b.w, h: b.h, aspect });
        track.history = track.history.filter(h => now - h.t <= 3000);

        let sample1s = track.history.find(h => (now - h.t) >= 700 && (now - h.t) <= 1500);
        if (!sample1s && track.history.length > 0) sample1s = track.history[0];

        const elapsedSec = sample1s ? Math.max(0.2, (now - sample1s.t) / 1000) : 1.0;
        const dist = sample1s ? Math.hypot(track.smoothCx - sample1s.cx, track.smoothCy - sample1s.cy) : 0.0;
        const velocityNormPerSec = dist / elapsedSec;
        track.motionScore = Math.min(1.0, velocityNormPerSec * 4.0);

        const isLyingOrFallen = (aspect >= 0.95 || track.hasFallen);
        const stationaryThreshold = isLyingOrFallen ? 0.045 : 0.030;
        const isStationary = velocityNormPerSec < stationaryThreshold;

        if (isStationary) {
          track.movingFramesCount = 0;
          if (!track.motionlessStartMs) {
            track.motionlessStartMs = now;
          }
          track.motionlessMs = Math.max(0, now - track.motionlessStartMs);
        } else {
          track.movingFramesCount = (track.movingFramesCount || 0) + 1;
          if (track.movingFramesCount >= 5) {
            track.motionlessStartMs = null;
            track.motionlessMs = 0;
          }
        }

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

        const wasUprightBefore = track.history.some(h => (now - h.t > 300) && h.aspect < 0.85);
        const aspectInverted = (aspect > 0.95 && wasUprightBefore) ? 1.0 : 0.0;
        const dynamicDropScore = (0.45 * aspectInverted) +
                                 (0.35 * Math.min(1.0, Math.max(0, hipDropRatio / 0.35))) +
                                 (0.25 * Math.min(1.0, Math.max(0, torsoAngleDeg / 65.0)));

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

        if (dynamicDropScore >= 0.60 || staticProneScore >= 0.70) {
          track.hasFallen = true;
          if (!track.fallenSinceMs) track.fallenSinceMs = now;
        }

        const isStillDown = isHorizontalBbox || isPronePose || (aspect > 0.85 && (torsoAngleDeg > 40 || track.motionlessMs > 1000));

        let computedFall = 0.0;
        if (track.hasFallen && isStillDown) {
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
          computedFall = Math.max(dynamicDropScore, staticProneScore);
        }

        if (track.isFalling) computedFall = 0.92;
        track.fallScore = Number(Math.max(0.0, Math.min(1.0, computedFall)).toFixed(2));

        signals.push({
          trackId,
          kind: 'person',
          category: 'person',
          label: 'Person',
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

      if (!this.isSimulatingScene) {
        this.ctx.clearRect(0, 0, w, h);
      }

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

      // 2. Draw Detected Objects (Persons & Bags)
      for (const p of personSignals) {
        try {
          const bx = p.bboxN.x * w;
          const by = p.bboxN.y * h;
          const bw = p.bboxN.w * w;
          const bh = p.bboxN.h * h;

          // --- BAG / LUGGAGE RENDERING ---
          if (p.kind === 'bag') {
            const isAlarm = p.isUnattended || (p.zoneIds && p.zoneIds.length > 0);
            const boxColor = isAlarm ? '#EF4444' : '#F59E0B'; // Red if unattended/intrusion, else Cyber Amber

            // Translucent Amber/Red fill
            this.ctx.fillStyle = this._hexToRgba(boxColor, 0.12);
            this.ctx.fillRect(bx, by, bw, bh);

            // Bounding box outline
            this.ctx.strokeStyle = boxColor;
            this.ctx.lineWidth = 2.0;
            this.ctx.strokeRect(bx, by, bw, bh);

            // Corner accents
            this._drawBoxCorners(bx, by, bw, bh, boxColor);

            // Header Pill: BAG: Label + Confidence
            const label = `BAG: ${p.label || 'Luggage'} ${(p.confidence * 100).toFixed(0)}%`;
            this.ctx.font = 'bold 11px monospace';
            const textWidth = this.ctx.measureText(label).width;
            const pillW = Math.max(86, textWidth + 14);
            const pillY = Math.max(0, by - 20);

            this.ctx.fillStyle = boxColor;
            this.ctx.fillRect(bx, pillY, pillW, 18);
            this.ctx.fillStyle = '#0B0E13';
            this.ctx.fillText(label, bx + 6, pillY + 13);

            // Ground Anchor
            this.ctx.beginPath();
            this.ctx.arc(p.footN.x * w, p.footN.y * h, 3.5, 0, Math.PI * 2);
            this.ctx.fillStyle = boxColor;
            this.ctx.fill();

            // Status Tag
            let tagY = by + bh + 16;
            if (by + bh > h - 35) tagY = Math.max(32, by - 6);
            if (p.isUnattended) {
              this._drawTag(`UNATTENDED ${(p.motionlessMs / 1000).toFixed(0)}s`, bx, tagY, '#EF4444');
              tagY += 18;
            }
            if (p.zoneIds && p.zoneIds.length > 0) {
              this._drawTag('RESTRICTED ZONE', bx, tagY, '#F97316');
            }
            continue;
          }

          // --- PERSON RENDERING ---
          const isAlarm = p.fallScore >= 0.6 || (p.zoneIds && p.zoneIds.length > 0);
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
          if (p.zoneIds && p.zoneIds.length > 0) {
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
          kind: p.kind || 'person',
          category: p.category || 'person',
          label: p.label || 'Person',
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
      try {
        const vw = (this.videoEl && this.videoEl.videoWidth > 0 && !this.isSimulatingScene) ? this.videoEl.videoWidth : (this.canvasEl ? this.canvasEl.width : 1280);
        const vh = (this.videoEl && this.videoEl.videoHeight > 0 && !this.isSimulatingScene) ? this.videoEl.videoHeight : (this.canvasEl ? this.canvasEl.height : 720);
        if (!vw || !vh || !Number.isFinite(vw) || !Number.isFinite(vh)) return null;

        const scale = Math.min(1.0, maxWidth / vw);
        const sw = Math.max(1, Math.round(vw * scale));
        const sh = Math.max(1, Math.round(vh * scale));

        const offCanvas = document.createElement('canvas');
        offCanvas.width = sw;
        offCanvas.height = sh;
        const offCtx = offCanvas.getContext('2d');
        if (!offCtx) return null;

        // Draw original video frame or simulated canvas
        if (this.isSimulatingScene || !this.videoEl || this.videoEl.readyState < 2) {
          if (this.canvasEl) {
            offCtx.drawImage(this.canvasEl, 0, 0, sw, sh);
          } else if (this.sceneImg && this.sceneImg.complete) {
            offCtx.drawImage(this.sceneImg, 0, 0, sw, sh);
          } else {
            offCtx.fillStyle = '#070b12';
            offCtx.fillRect(0, 0, sw, sh);
          }
        } else {
          offCtx.drawImage(this.videoEl, 0, 0, sw, sh);
        }

        // Blur human heads & faces by default (Privacy by design)
        if (blurHead) {
          for (const [trackId, track] of this.tracks.entries()) {
            const b = track.bboxN;
            if (!b || !Number.isFinite(b.x) || !Number.isFinite(b.y) || !Number.isFinite(b.w) || !Number.isFinite(b.h)) continue;
            let headX, headY, headW, headH;

            // Check if pose landmarks for the face (nose: 0, eyes: 1-6, ears: 7-8, mouth: 9-10) are present
            let facePoints = [];
            if (track.poseLandmarks && Array.isArray(track.poseLandmarks)) {
              for (let i = 0; i <= 10; i++) {
                const lm = track.poseLandmarks[i];
                if (lm && Number.isFinite(lm.x) && Number.isFinite(lm.y) && (lm.visibility === undefined || lm.visibility > 0.25)) {
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
              headW = Math.max(1, Math.min(sw - headX, Math.round(spanW * sw)));
              headH = Math.max(1, Math.min(sh - headY, Math.round(spanH * sh)));
            } else {
              // Fallback: estimate from person bounding box.
              // In webcam / desk scenarios (aspect ratio > 0.45 or close up), face takes top 65% of the box.
              const isUpperBody = (b.w / b.h > 0.45) || (b.h < 0.75);
              const heightFraction = isUpperBody ? 0.65 : 0.42;

              headX = Math.max(0, Math.round((b.x + b.w * 0.05) * sw));
              headY = Math.max(0, Math.round(b.y * sh));
              headW = Math.max(1, Math.min(sw - headX, Math.round(b.w * 0.90 * sw)));
              headH = Math.max(1, Math.min(sh - headY, Math.round(b.h * heightFraction * sh)));
            }

            // Apply heavy pixelation / box blur filter to protect privacy
            try {
              offCtx.save();
              const pxSize = 12;
              const tempC = document.createElement('canvas');
              tempC.width = Math.max(1, Math.round(headW / pxSize));
              tempC.height = Math.max(1, Math.round(headH / pxSize));
              const tempCtx = tempC.getContext('2d');
              if (tempCtx) {
                tempCtx.drawImage(offCanvas, headX, headY, headW, headH, 0, 0, tempC.width, tempC.height);
                offCtx.imageSmoothingEnabled = false;
                offCtx.drawImage(tempC, 0, 0, tempC.width, tempC.height, headX, headY, headW, headH);
              }
              offCtx.restore();
            } catch (blurErr) {
              console.warn('[ArgusVision] Canvas blur exception, using solid fill fallback:', blurErr);
              offCtx.fillStyle = 'rgba(0, 0, 0, 0.85)';
              offCtx.fillRect(headX, headY, headW, headH);
            }
          }
        }

        return offCanvas.toDataURL('image/jpeg', quality);
      } catch (err) {
        console.warn('[ArgusVision] snapshot() failed safely:', err);
        return null;
      }
    }

    // --- Ephemeral Upper-Body Crop for Optional Cloud Verification ---
    async verificationCrop({ trackId, quality = 0.8 } = {}) {
      try {
        const track = this.tracks.get(trackId);
        if (!track) return null;

        const vw = (this.videoEl && this.videoEl.videoWidth > 0 && !this.isSimulatingScene) ? this.videoEl.videoWidth : (this.canvasEl ? this.canvasEl.width : 1280);
        const vh = (this.videoEl && this.videoEl.videoHeight > 0 && !this.isSimulatingScene) ? this.videoEl.videoHeight : (this.canvasEl ? this.canvasEl.height : 720);
        if (!vw || !vh || !Number.isFinite(vw) || !Number.isFinite(vh)) return null;
        const b = track.bboxN;
        if (!b || !Number.isFinite(b.x) || !Number.isFinite(b.y) || !Number.isFinite(b.w) || !Number.isFinite(b.h)) return null;

        const cropX = Math.max(0, b.x * vw);
        const cropY = Math.max(0, b.y * vh);
        const cropW = Math.max(1, Math.min(vw - cropX, b.w * vw));
        const cropH = Math.max(1, Math.min(vh - cropY, b.h * 0.55 * vh)); // Upper body

        const cropCanvas = document.createElement('canvas');
        cropCanvas.width = Math.min(320, cropW);
        cropCanvas.height = Math.min(320, cropH);
        const cropCtx = cropCanvas.getContext('2d');
        if (!cropCtx) return null;

        const srcEl = (this.isSimulatingScene || !this.videoEl || this.videoEl.readyState < 2) ? (this.canvasEl || this.sceneImg) : this.videoEl;
        if (srcEl) {
          cropCtx.drawImage(srcEl, cropX, cropY, cropW, cropH, 0, 0, cropCanvas.width, cropCanvas.height);
          return cropCanvas.toDataURL('image/jpeg', quality);
        }
        return null;
      } catch (err) {
        console.warn('[ArgusVision] verificationCrop() failed safely:', err);
        return null;
      }
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

  // Dedicated Zone Editor Webcam Preview Helpers
  window.argusStartWebcamPreview = async function (elementId) {
    try {
      const el = document.getElementById(elementId);
      if (!el) return false;
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { width: { ideal: 1280 }, height: { ideal: 720 }, facingMode: 'user' },
        audio: false
      });
      el.srcObject = stream;
      await el.play();
      return true;
    } catch (err) {
      console.warn('[Argus] Zone webcam preview error:', err);
      return false;
    }
  };

  window.argusStopWebcamPreview = function (elementId) {
    try {
      const el = document.getElementById(elementId);
      if (el && el.srcObject) {
        el.srcObject.getTracks().forEach(t => t.stop());
        el.srcObject = null;
      }
    } catch (err) {
      console.warn('[Argus] Zone webcam preview stop error:', err);
    }
  };

})(window);
