import React from 'react';
import { Label } from '../../primitives';

/**
 * Profile through an overflow spillway passing the design flood.
 * Shows: reservoir, spillway crest with its elevation, the design-flood
 * water surface, head H over the crest (unknown, no value), freeboard from
 * the design-flood water surface to the top of the dam.
 * Does NOT show: the value of H or the top-of-dam elevation.
 */
export function CtWaterResourcesASpillway({ crestEl = 842.0, freeboard = 3.0, headDraw = 5.4 }) {
  const s = 12; // px per ft
  const crestY = 128;
  const wsY = crestY - headDraw * s;
  const topY = wsY - freeboard * s;
  const baseY = crestY + 80;
  const faceX = 190; // upstream face
  const crestX = faceX + 16;
  const toeX = 318;
  const dimX = 112;

  const concrete = `M ${faceX},${baseY} L ${faceX},${crestY + 10}
    Q ${faceX + 2},${crestY} ${crestX},${crestY}
    Q ${crestX + 24},${crestY} ${crestX + 40},${crestY + 18}
    L ${toeX - 18},${baseY - 12} Q ${toeX - 8},${baseY} ${toeX + 6},${baseY} Z`;
  const hp = headDraw * s;
  // Drawdown curve: falls steadily from the reservoir level, over the crest, down the face
  const nappeTop = `M ${faceX - 50},${wsY} C ${faceX - 5},${wsY} ${crestX + 24},${crestY - 0.5 * hp + 6} ${crestX + 54},${crestY + 6}
    L ${toeX - 26},${baseY - 26} Q ${toeX - 12},${baseY - 13} ${toeX + 30},${baseY - 9}`;

  return (
    <svg viewBox={`0 0 400 ${baseY + 16}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Spillway profile, crest elevation ${crestEl} ft, freeboard ${freeboard} ft above the design-flood water surface`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Reservoir and flow over the crest */}
      <path d={`M 14,${wsY} L ${faceX - 50},${wsY} ${nappeTop.slice(nappeTop.indexOf('C'))} L ${toeX + 30},${baseY} L 14,${baseY} Z`}
        fill="var(--info)" fillOpacity={0.18} />
      <path d={`M 14,${wsY} L ${faceX - 50},${wsY} ${nappeTop.slice(nappeTop.indexOf('C'))}`} fill="none" stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={`${46},${wsY - 11} ${58},${wsY - 11} ${52},${wsY - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />
      <Label x={60} y={wsY + 34} color="var(--info)" fontSize={12}>reservoir</Label>

      {/* Spillway concrete */}
      <path d={concrete} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.2} strokeLinejoin="round" />
      <line x1={10} y1={baseY} x2={392} y2={baseY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 27 }, (_, i) => (
        <line key={i} x1={16 + i * 14} y1={baseY + 2} x2={10 + i * 14} y2={baseY + 9} stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Top of dam (embankment beyond the spillway) */}
      <line x1={faceX - 60} y1={topY} x2={toeX + 20} y2={topY} stroke="var(--charcoal)" strokeWidth={1.4} strokeDasharray="7,4" />
      <Label x={toeX + 20} y={topY - 12} color="var(--charcoal)" fontSize={12} anchor="end">top of dam (embankment beyond)</Label>

      {/* Crest elevation */}
      <Label x={faceX - 8} y={crestY + 16} color="var(--charcoal)" fontSize={12} anchor="end">{`crest El. ${crestEl.toFixed(1)} ft`}</Label>

      {/* Head over crest and freeboard, measured upstream */}
      <line x1={dimX - 6} y1={crestY} x2={faceX - 2} y2={crestY} stroke="var(--gray-500)" strokeWidth={0.8} strokeDasharray="3,3" />
      <line x1={dimX - 6} y1={topY} x2={faceX - 64} y2={topY} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={dimX} y1={topY} x2={dimX} y2={crestY} stroke="var(--gray-500)" strokeWidth={1} />
      {[topY, wsY, crestY].map((yy) => (
        <line key={yy} x1={dimX - 4} y1={yy + 4} x2={dimX + 4} y2={yy - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      ))}
      <Label x={dimX + 8} y={(wsY + crestY) / 2} color="var(--charcoal)" fontSize={13} italic anchor="start">H</Label>
      <Label x={dimX - 8} y={(topY + wsY) / 2} color="var(--charcoal)" fontSize={12} anchor="end">{`${freeboard.toFixed(1)} ft`}</Label>
      <Label x={dimX + 8} y={(topY + wsY) / 2} color="var(--gray-500)" fontSize={11} anchor="start">freeboard</Label>
    </svg>
  );
}
