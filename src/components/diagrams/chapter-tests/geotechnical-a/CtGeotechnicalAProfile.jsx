import React from 'react';
import { ArrowMarkerDefs } from '../../primitives';
import { SOIL_TINT, SubText, WaterMark, SurfaceHatch, VDim } from './ctGeoAParts';

/**
 * Layered soil profile drawn to scale: layer thicknesses, the unit weights and
 * properties the question gives, one or more water tables and an optional
 * wide surface load. Shows only givens, never a computed stress.
 *
 * layers: [{ name, lines: [...], h, kind: 'sand'|'clay'|'gravel'|'silt'|'rock', open }]
 *   open: the layer continues below the drawing (no thickness shown).
 * waterTables: [{ depth, label }]
 * saturatedBelow: depth below which the soil is tinted as saturated (or null)
 * load: label for a wide uniform surface load (or null)
 */
export function CtGeotechnicalAProfile({
  layers = [],
  waterTables = [],
  saturatedBelow = null,
  load = null,
  unit = 'ft',
  maxPx = 230,
}) {
  const W = 380;
  const colL = 76;
  const colR = 366;
  const top = load ? 62 : (waterTables.some((w) => w.depth * 1 < 1.5) ? 30 : 14);
  const total = layers.reduce((s, l) => s + l.h, 0);
  const sc = Math.min(maxPx / total, 14);
  let y = top;
  const rows = layers.map((l) => {
    const r = { ...l, py: y, ph: l.h * sc };
    y += l.h * sc;
    return r;
  });
  const bottom = y;
  const H = bottom + 12;
  const wts = waterTables.map((w) => ({ ...w, y: top + w.depth * sc }));

  // Place each layer's label block in the largest band not crossed by a water table.
  const lineGap = 16;
  const blockY = (r) => {
    const n = 1 + (r.lines ? r.lines.length : 0);
    const blockH = (n - 1) * lineGap;
    let bands = [[r.py + 6, r.py + r.ph - 6]];
    for (const w of wts) {
      const near = w.y > top && w.y - top < 26;
      const lo = near ? w.y - 8 : w.y - 22;
      const hi = near ? w.y + 24 : w.y + 12;
      bands = bands.flatMap(([a, b]) => {
        if (hi <= a || lo >= b) return [[a, b]];
        const out = [];
        if (lo > a) out.push([a, lo]);
        if (hi < b) out.push([hi, b]);
        return out;
      });
    }
    bands.sort((p, q) => (q[1] - q[0]) - (p[1] - p[0]));
    const [a, b] = bands[0] || [r.py, r.py + r.ph];
    return (a + b) / 2 - blockH / 2;
  };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Soil profile with ${layers.length} layers${wts.length ? ' and water table' : ''}`}
      style={{ width: '100%', height: 'auto' }}>
      {load && <ArrowMarkerDefs id="ctGeoAProfArrow" color="var(--ember)" size={7} />}

      {rows.map((r, i) => (
        <g key={i}>
          <rect x={colL} y={r.py} width={colR - colL} height={r.ph}
            fill="var(--gray-400)" fillOpacity={SOIL_TINT[r.kind] ?? 0.12} />
          {saturatedBelow !== null && r.py + r.ph > top + saturatedBelow * sc && (
            <rect x={colL} y={Math.max(r.py, top + saturatedBelow * sc)} width={colR - colL}
              height={r.py + r.ph - Math.max(r.py, top + saturatedBelow * sc)}
              fill="var(--info)" fillOpacity={0.08} />
          )}
          <line x1={colL} y1={r.py} x2={colL} y2={r.py + r.ph} stroke="var(--charcoal)" strokeWidth={1.4} />
          <line x1={colR} y1={r.py} x2={colR} y2={r.py + r.ph} stroke="var(--charcoal)" strokeWidth={1.4} />
          {i > 0 && <line x1={colL} y1={r.py} x2={colR} y2={r.py} stroke="var(--charcoal)" strokeWidth={1.4} />}
          {r.open
            ? <line x1={colL} y1={r.py + r.ph} x2={colR} y2={r.py + r.ph} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="6,4" />
            : i === rows.length - 1 && <line x1={colL} y1={r.py + r.ph} x2={colR} y2={r.py + r.ph} stroke="var(--charcoal)" strokeWidth={1.4} />}
          {!r.open && <VDim x={colL - 16} y1={r.py} y2={r.py + r.ph} label={`${r.h} ${unit}`} />}
          {(() => {
            const by = blockY(r);
            return (
              <g>
                <SubText x={colL + 12} y={by} bold>{r.name}</SubText>
                {(r.lines || []).map((t, k) => (
                  <SubText key={k} x={colL + 12} y={by + (k + 1) * lineGap} color="var(--gray-500)">{t}</SubText>
                ))}
              </g>
            );
          })()}
        </g>
      ))}

      {/* Ground surface */}
      <line x1={colL - 4} y1={top} x2={colR + 4} y2={top} stroke="var(--charcoal)" strokeWidth={2} />
      {!load && <SurfaceHatch x1={colL} x2={colR} y={top} step={22} len={6} />}

      {/* Water tables. One at the surface is the ground line itself: only the
          symbol sits on it, so the dashed line does not hide the ground. */}
      {wts.map((w, i) => (
        <g key={i}>
          {w.y > top && <line x1={colL} y1={w.y} x2={colR} y2={w.y} stroke="var(--info)" strokeWidth={1.5} strokeDasharray="7,4" />}
          <WaterMark x={colR - 22} y={w.y} />
          <SubText x={colR - 34} y={w.y > top && w.y - top < 26 ? w.y + 13 : w.y - 9} color="var(--info)" anchor="end" size={12}>{w.label || 'WT'}</SubText>
        </g>
      ))}

      {/* Wide surface load */}
      {load && (
        <g>
          <line x1={colL + 10} y1={top - 30} x2={colR - 10} y2={top - 30} stroke="var(--ember)" strokeWidth={1.5} />
          {Array.from({ length: 9 }, (_, i) => {
            const x = colL + 10 + i * ((colR - colL - 20) / 8);
            return <line key={i} x1={x} y1={top - 30} x2={x} y2={top - 3} stroke="var(--ember)" strokeWidth={1.5}
              markerEnd="url(#ctGeoAProfArrow)" />;
          })}
          <SubText x={(colL + colR) / 2} y={top - 44} color="var(--ember)" anchor="middle" bold>{load}</SubText>
        </g>
      )}
    </svg>
  );
}
