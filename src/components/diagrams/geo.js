/* ═══════════════════════════════════════
   geo.js — Geometry utilities for engineering SVG diagrams.

   The core problem: engineering diagrams use y-up (origin at bottom-left),
   but SVG uses y-down (origin at top-left). Every trig operation, every
   coordinate placement, every arc path must account for this flip.

   These utilities handle the flip once, correctly, so diagram components
   never do manual y-negation.
   ═══════════════════════════════════════ */

/* ── Angle conversion ── */

/** Degrees → radians */
export const deg = (d) => (d * Math.PI) / 180;

/** Radians → degrees */
export const rad2deg = (r) => (r * 180) / Math.PI;

/* ── Coordinate conversion ── */

/**
 * Polar coordinate → SVG point.
 *
 * Angle is in degrees, measured counter-clockwise from the positive x-axis
 * (standard math convention: 0° = east, 90° = north).
 *
 * Automatically handles SVG y-down:
 *   x = cx + r·cos(θ)
 *   y = cy - r·sin(θ)   ← negated for SVG
 *
 * @param {number} cx  SVG x of center
 * @param {number} cy  SVG y of center
 * @param {number} r   Radius in pixels
 * @param {number} angleDeg  Angle in degrees (CCW from east)
 * @returns {{ x: number, y: number }}
 */
export function polar(cx, cy, r, angleDeg) {
  const a = deg(angleDeg);
  return {
    x: cx + r * Math.cos(a),
    y: cy - r * Math.sin(a),
  };
}

/**
 * Engineering y → SVG y.
 *
 * In engineering, y = 0 is at the bottom and increases upward.
 * This converts an engineering y-value to an SVG y-coordinate.
 *
 * Example: A T-section is 100mm tall, drawn with SVG top at oy = 30.
 *   The centroid is 70mm from the bottom.
 *   SVG y = engY(30, 100, 70) = 30 + 100 - 70 = 60
 *
 * @param {number} svgTop    SVG y of the top of the drawing area
 * @param {number} totalH    Total height of the drawing area (in SVG px)
 * @param {number} yFromBot  Distance from the bottom (in SVG px, already scaled)
 * @returns {number} SVG y-coordinate
 */
export function engY(svgTop, totalH, yFromBot) {
  return svgTop + totalH - yFromBot;
}

/* ── SVG path builders ── */

/**
 * SVG arc path string.
 *
 * Draws an arc from startDeg to endDeg (both CCW from east, standard math).
 * Handles SVG y-flip internally.
 *
 * @param {number} cx  SVG x of arc center
 * @param {number} cy  SVG y of arc center
 * @param {number} r   Arc radius in pixels
 * @param {number} startDeg  Start angle (degrees, CCW from east)
 * @param {number} endDeg    End angle (degrees, CCW from east)
 * @returns {string} SVG path `d` attribute value
 */
export function arcPath(cx, cy, r, startDeg, endDeg) {
  const s = polar(cx, cy, r, startDeg);
  const e = polar(cx, cy, r, endDeg);
  const span = endDeg - startDeg;
  const large = Math.abs(span) > 180 ? 1 : 0;
  // CCW in math convention = clockwise in SVG (sweep-flag 0)
  const sweep = span > 0 ? 0 : 1;
  return `M ${s.x},${s.y} A ${r},${r} 0 ${large} ${sweep} ${e.x},${e.y}`;
}

/* ── Point math ── */

/**
 * Midpoint between two points.
 */
export function mid(x1, y1, x2, y2) {
  return { x: (x1 + x2) / 2, y: (y1 + y2) / 2 };
}

/**
 * Distance between two points.
 */
export function dist(x1, y1, x2, y2) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  return Math.sqrt(dx * dx + dy * dy);
}

/**
 * Move a point by a distance along a unit direction vector.
 *
 * @param {number} x  Start x
 * @param {number} y  Start y
 * @param {number} dx Direction x (unit or scaled)
 * @param {number} dy Direction y (unit or scaled)
 * @param {number} distance  How far to move
 * @returns {{ x: number, y: number }}
 */
export function move(x, y, dx, dy, distance) {
  const len = Math.sqrt(dx * dx + dy * dy);
  if (len === 0) return { x, y };
  return {
    x: x + (dx / len) * distance,
    y: y + (dy / len) * distance,
  };
}

/**
 * Perpendicular offset from a line.
 * Returns the perpendicular displacement vector (rotated 90° CCW in screen space).
 * Useful for placing labels alongside lines.
 *
 * Positive dist = left side of the line (when walking from p1 to p2).
 *
 * @param {number} x1 Line start x
 * @param {number} y1 Line start y
 * @param {number} x2 Line end x
 * @param {number} y2 Line end y
 * @param {number} dist Perpendicular distance (px)
 * @returns {{ dx: number, dy: number }}
 */
export function perpOffset(x1, y1, x2, y2, dist) {
  const lx = x2 - x1;
  const ly = y2 - y1;
  const len = Math.sqrt(lx * lx + ly * ly);
  if (len === 0) return { dx: 0, dy: 0 };
  return {
    dx: (-ly / len) * dist,
    dy: (lx / len) * dist,
  };
}

/* ── Rotation / basis vectors ── */

/**
 * Basis vectors for an inclined surface in SVG coordinates.
 *
 * Given a surface inclined at `angleDeg` from horizontal (0° = flat floor,
 * 90° = vertical wall), returns four named direction vectors.
 *
 * All vectors are unit vectors in SVG coordinate space (y-down).
 *
 * @param {number} angleDeg  Inclination angle (degrees from horizontal)
 * @returns {{ uphill, downhill, outward, inward }}
 *   - uphill:   along the surface, going up-right
 *   - downhill: along the surface, going down-left
 *   - outward:  perpendicular to surface, pointing away (above the surface)
 *   - inward:   perpendicular to surface, pointing into (below the surface)
 */
export function basis(angleDeg) {
  const a = deg(angleDeg);
  const c = Math.cos(a);
  const s = Math.sin(a);
  return {
    uphill:   { x:  c, y: -s },   // along surface, going up-right
    downhill: { x: -c, y:  s },   // along surface, going down-left
    outward:  { x: -s, y: -c },   // perpendicular, away from surface
    inward:   { x:  s, y:  c },   // perpendicular, into surface
  };
}

/**
 * Apply a basis vector: from point (px, py), move `distance` pixels
 * along the given direction vector.
 *
 * @param {number} px  Start x
 * @param {number} py  Start y
 * @param {{ x: number, y: number }} dir  Direction vector (unit)
 * @param {number} distance  How far to move (px)
 * @returns {{ x: number, y: number }}
 */
export function along(px, py, dir, distance) {
  return {
    x: px + dir.x * distance,
    y: py + dir.y * distance,
  };
}

/* ── Composite helpers ── */

/**
 * Compute a rectangle's corners on an inclined surface.
 *
 * The rectangle is centered at (cx, cy) on the surface.
 * `halfW` is half the width along the surface.
 * `h` is the full height perpendicular to the surface.
 * The rectangle sits ON the surface (extends outward from it).
 *
 * Returns 4 corners in order: bottom-left, bottom-right, top-right, top-left
 * (where "bottom" = on the surface, "top" = away from surface).
 *
 * @param {number} cx  Center x (on the surface)
 * @param {number} cy  Center y (on the surface)
 * @param {number} halfW  Half-width along surface
 * @param {number} h  Height perpendicular to surface
 * @param {number} angleDeg  Surface inclination (degrees)
 * @returns {Array<{ x: number, y: number }>}
 */
export function rectOnSurface(cx, cy, halfW, h, angleDeg) {
  const b = basis(angleDeg);
  return [
    along(along(cx, cy, b.downhill, halfW).x, along(cx, cy, b.downhill, halfW).y, b.outward, 0),
    along(along(cx, cy, b.uphill, halfW).x, along(cx, cy, b.uphill, halfW).y, b.outward, 0),
    along(along(cx, cy, b.uphill, halfW).x, along(cx, cy, b.uphill, halfW).y, b.outward, h),
    along(along(cx, cy, b.downhill, halfW).x, along(cx, cy, b.downhill, halfW).y, b.outward, h),
  ];
}

/* ── Standard constants ── */

/**
 * Standard pixel values for consistent diagram styling.
 * Use these instead of magic numbers.
 */
export const K = {
  // Force arrows
  ARROW_LEN: 50,           // Default force arrow length (px)
  ARROW_GAP: 4,            // Gap between arrowhead and shape surface
  ARROW_STROKE: 2,         // Arrow line thickness
  COMPONENT_ARROW_LEN: 40, // Component force arrow length

  // Labels
  LABEL_OFFSET: 14,        // Label distance from anchor point
  LABEL_FONT: 12,          // Default label font size
  LABEL_FONT_SM: 10,       // Small label font size

  // Dimensions
  DIM_OFFSET: 16,          // Dimension line distance from shape edge
  TICK_SIZE: 5,            // Dimension line end ticks

  // Supports
  SUPPORT_SIZE: 16,        // Pin/roller support triangle size

  // Angle arcs
  ARC_RADIUS: 28,          // Default angle arc radius
  ARC_LABEL_OFFSET: 12,    // Label distance beyond arc

  // Right-angle markers
  MARKER_SIZE: 10,         // Right-angle square size

  // Layout
  PADDING: 30,             // SVG viewBox padding around content
};
