// Oblique 3D projection shared by the version B vector figures.
// x points toward the viewer (drawn down-left, foreshortened), y to the right,
// z up: a right-handed set as statics texts draw it.
export function makeProjector(ox, oy, s, k = 0.55) {
  const cx = Math.cos(Math.PI / 6);
  const sx = Math.sin(Math.PI / 6);
  return ([x, y, z]) => ({
    x: ox + s * (y - k * x * cx),
    y: oy - s * (z - k * x * sx),
  });
}

// True isometric: x down-left, y down-right (both 30 degrees below the
// horizontal), z up. Used where a plane rising along y would otherwise be
// seen edge-on.
export function makeIsometric(ox, oy, s) {
  const c = Math.cos(Math.PI / 6);
  return ([x, y, z]) => ({
    x: ox + s * c * (y - x),
    y: oy + s * (0.5 * (x + y) - z),
  });
}

export const fmt = (v) => (v < 0 ? `−${Math.abs(v)}` : `${v}`);
