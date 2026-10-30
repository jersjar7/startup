// Isometric projection shared by the 3D figures of this set (not a figure).
// x points out to the lower left, y to the lower right, z up: right-handed.
const C30 = Math.cos(Math.PI / 6);

export function iso(ox, oy, s, [x, y, z]) {
  return { x: ox + s * C30 * (y - x), y: oy + s * (0.5 * (x + y) - z) };
}
