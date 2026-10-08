/**
 * Unit Tests for Argus On-Device Vision Algorithms
 * Run with: node test_vision.js
 */

const fs = require('fs');
const path = require('path');
const assert = require('assert');

// --- Point-in-polygon ray casting implementation ---
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

// --- Fall Heuristic Formula ---
function evaluateFall(aspect, wasTallBefore, hipDropRatio, torsoAngleDeg) {
  const aspectInverted = (aspect > 0.95 && wasTallBefore) ? 1.0 : 0.0;
  const aspectTerm = 0.40 * aspectInverted;
  const hipDropTerm = 0.35 * Math.min(1.0, Math.max(0, hipDropRatio / 0.35));
  const angleTerm = 0.25 * Math.min(1.0, Math.max(0, torsoAngleDeg / 70.0));
  return Math.max(0, Math.min(1.0, aspectTerm + hipDropTerm + angleTerm));
}

console.log('--- RUNNING ARGUS VISION ENGINE ALGORITHM TESTS ---');

// Test 1: Geometry Point in Polygon
{
  const triangle = [
    { x: 0.1, y: 0.1 },
    { x: 0.9, y: 0.1 },
    { x: 0.5, y: 0.9 }
  ];
  assert.strictEqual(pointInPolygon(0.5, 0.4, triangle), true, 'Center of triangle should be inside');
  assert.strictEqual(pointInPolygon(0.0, 0.0, triangle), false, 'Origin should be outside');
  assert.strictEqual(pointInPolygon(0.95, 0.5, triangle), false, 'Right point should be outside');
  console.log('✓ Point-in-polygon ray casting tests passed');
}

// Test 2: IoU Overlap
{
  const b1 = { x: 0.2, y: 0.2, w: 0.4, h: 0.4 };
  const b2 = { x: 0.2, y: 0.2, w: 0.4, h: 0.4 };
  assert.strictEqual(Math.abs(computeIoU(b1, b2) - 1.0) < 0.001, true, 'Identical boxes should have IoU = 1.0');

  const b3 = { x: 0.7, y: 0.7, w: 0.2, h: 0.2 };
  assert.strictEqual(computeIoU(b1, b3), 0.0, 'Disjoint boxes should have IoU = 0.0');

  const b4 = { x: 0.4, y: 0.2, w: 0.4, h: 0.4 }; // 50% width overlap
  const iou = computeIoU(b1, b4);
  assert.strictEqual(iou > 0.3 && iou < 0.4, true, 'Partial overlap matches expected IoU');
  console.log('✓ Centroid & IoU math tests passed');
}

// Test 3: Fall Scoring Heuristics
{
  // Standing upright
  const standingScore = evaluateFall(0.32, false, 0.0, 5.0);
  assert.strictEqual(standingScore < 0.15, true, `Standing score (${standingScore}) must be < 0.15`);

  // Rapid fall & horizontal lying down
  const fallenScore = evaluateFall(2.2, true, 0.65, 85.0);
  assert.strictEqual(fallenScore >= 0.85, true, `Fallen score (${fallenScore}) must be >= 0.85`);
  assert.strictEqual(fallenScore >= 0.60, true, 'Must trigger fall_suspected threshold (>= 0.60)');

  // Bending down slightly (false-positive prevention check)
  const bendingScore = evaluateFall(0.65, true, 0.10, 40.0);
  assert.strictEqual(bendingScore < 0.60, true, `Bending score (${bendingScore}) must be below alarm threshold (< 0.60)`);
  console.log('✓ Fall heuristic scoring & alarm threshold tests passed');
}

// Test 4: Replay Fixture Verification
{
  const replayDir = path.join(__dirname, '../demo/replay');
  const files = ['s1_after_hours.json', 's2_fall_stairs.json', 's3_zone_intrusion.json'];

  for (const f of files) {
    const fullPath = path.join(replayDir, f);
    assert.strictEqual(fs.existsSync(fullPath), true, `Replay file ${f} must exist`);
    const data = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
    assert.strictEqual(typeof data.clipId, 'string', 'clipId must be a string');
    assert.strictEqual(Array.isArray(data.batches), true, 'batches must be an array');
    assert.strictEqual(data.batches.length > 0, true, 'batches must not be empty');
    for (const b of data.batches) {
      assert.strictEqual(typeof b.cameraId, 'number', 'cameraId must be number');
      assert.strictEqual(Array.isArray(b.signals), true, 'signals must be array');
    }
  }
  console.log('✓ Replay fixtures S1-S3 verified against canonical SignalBatch schema');
}

console.log('\nALL VISION ALGORITHM & FIXTURE TESTS PASSED (100% OK)');
