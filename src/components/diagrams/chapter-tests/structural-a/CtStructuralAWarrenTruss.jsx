import React from 'react';
import { Arrowhead, T, Pin, Roller, Dim, Ext, INK, LOAD } from './CtStructuralAParts';

/**
 * Parallel-chord Warren truss (no verticals). Bottom joints L0..Ln at panel
 * points, top joints U1..Un at mid-panel. Equal loads hang from the listed
 * bottom joints. Pin at L0, roller at Ln. Drawn to scale.
 */
export function CtStructuralAWarrenTruss({
  panels = 4, panelFt = 12, heightFt = 8, load = 18, loadedJoints = [1, 2, 3],
}) {
  const s = 336 / (panels * panelFt);
  const ox = 44;
  const by = 92;
  const h = heightFt * s;
  const ty = by - h;
  const L = Array.from({ length: panels + 1 }, (_, i) => ox + i * panelFt * s);
  const U = Array.from({ length: panels }, (_, i) => ox + (i + 0.5) * panelFt * s);
  const xEnd = L[panels];
  const dimX = xEnd + 34;
  const dimY = by + 70;
  const W = dimX + 44;
  const H = dimY + 22;
  const mk = 'ctStrAWarrenArrow';

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Warren truss, ${panels} panels at ${panelFt} ft, height ${heightFt} ft, ${load} kip loads at bottom joints`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} /></defs>

      {/* chords */}
      <line x1={L[0]} y1={by} x2={xEnd} y2={by} stroke={INK} strokeWidth={2.4} />
      <line x1={U[0]} y1={ty} x2={U[panels - 1]} y2={ty} stroke={INK} strokeWidth={2.4} />
      {/* diagonals */}
      {U.map((ux, i) => (
        <g key={i}>
          <line x1={L[i]} y1={by} x2={ux} y2={ty} stroke={INK} strokeWidth={2} />
          <line x1={ux} y1={ty} x2={L[i + 1]} y2={by} stroke={INK} strokeWidth={2} />
        </g>
      ))}
      {/* joints */}
      {L.map((x, i) => <circle key={`l${i}`} cx={x} cy={by} r={2.8} fill={INK} />)}
      {U.map((x, i) => <circle key={`u${i}`} cx={x} cy={ty} r={2.8} fill={INK} />)}

      {/* supports */}
      <Pin x={L[0]} y={by + 1} />
      <Roller x={xEnd} y={by + 1} />

      {/* joint labels */}
      {U.map((x, i) => <T key={`ut${i}`} x={x} y={ty - 13} bold size={12}>{`U${i + 1}`}</T>)}
      <T x={L[0] - 11} y={by - 9} anchor="end" bold size={12}>L0</T>
      <T x={xEnd + 11} y={by - 9} anchor="start" bold size={12}>{`L${panels}`}</T>
      {L.slice(1, panels).map((x, k) => (
        <T key={`lt${k}`} x={x - 7} y={by + 13} anchor="end" bold size={12}>{`L${k + 1}`}</T>
      ))}

      {/* loads */}
      {loadedJoints.map((j) => (
        <g key={`p${j}`}>
          <line x1={L[j]} y1={by + 5} x2={L[j]} y2={by + 38} stroke={LOAD} strokeWidth={2}
            markerEnd={`url(#${mk})`} />
          <T x={L[j]} y={by + 50} color={LOAD} bold size={12}>{`${load} kips`}</T>
        </g>
      ))}

      {/* overall length */}
      <Ext x1={L[0]} y1={by + 32} x2={L[0]} y2={dimY + 5} />
      <Ext x1={xEnd} y1={by + 32} x2={xEnd} y2={dimY + 5} />
      <Dim x1={L[0]} y1={dimY} x2={xEnd} y2={dimY} label={`${panels} panels @ ${panelFt} ft = ${panels * panelFt} ft`} side="below" gap={12} />

      {/* height */}
      <Ext x1={U[panels - 1] + 6} y1={ty} x2={dimX + 5} y2={ty} />
      <Ext x1={xEnd + 30} y1={by} x2={dimX + 5} y2={by} />
      <Dim x1={dimX} y1={ty} x2={dimX} y2={by} label={`${heightFt} ft`} side="right" />
    </svg>
  );
}
