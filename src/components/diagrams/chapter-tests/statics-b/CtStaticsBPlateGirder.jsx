import React from 'react';
import { Label } from '../../primitives';

/**
 * Unsymmetric welded plate girder: top flange bt x tt, web tw x hw, bottom
 * flange bb x tb, drawn to scale (web thickness drawn at a 3 px minimum).
 * Shows: plate sizes and total depth.
 * Does NOT show: the centroid or I.
 */
export function CtStaticsBPlateGirder({ bt = 12, tt = 1, tw = 0.5, hw = 40, bb = 16, tb = 1.5, unit = 'in' }) {
  const S = 5;
  const cx = 92;
  const oy = 20;
  const total = tt + hw + tb;
  const yTopB = oy + tt * S;
  const yBotT = yTopB + hw * S;
  const yBot = yBotT + tb * S;
  const TW = Math.max(tw * S, 3);
  const gray = 'var(--gray-500)';
  const rect = (x, y, w, h) => <rect x={x} y={y} width={w} height={h} fill="var(--gray-200)" stroke="var(--charcoal)" strokeWidth={1.4} />;
  const dx = cx - (bb * S) / 2 - 26;
  const lx = cx + (bb * S) / 2 + 28;

  return (
    <svg viewBox={`0 0 ${lx + 136} ${yBot + 22}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Plate girder: top flange ${bt} by ${tt} ${unit}, web ${tw} by ${hw} ${unit}, bottom flange ${bb} by ${tb} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>
      {rect(cx - (bt * S) / 2, oy, bt * S, tt * S)}
      {rect(cx - TW / 2, yTopB, TW, hw * S)}
      {rect(cx - (bb * S) / 2, yBotT, bb * S, tb * S)}

      {/* Total depth */}
      <line x1={dx} y1={oy} x2={dx} y2={yBot} stroke={gray} strokeWidth={1} />
      <line x1={cx - (bt * S) / 2 - 4} y1={oy} x2={dx - 5} y2={oy} stroke={gray} strokeWidth={1} />
      <line x1={cx - (bb * S) / 2 - 4} y1={yBot} x2={dx - 5} y2={yBot} stroke={gray} strokeWidth={1} />
      <Label x={dx - 11} y={(oy + yBot) / 2} rotate={-90}>{`${total} ${unit} total`}</Label>

      {/* Leaders and plate sizes */}
      <line x1={cx + (bt * S) / 2 - 8} y1={oy + (tt * S) / 2} x2={lx - 4} y2={oy + 8} stroke={gray} strokeWidth={1} />
      <Label x={lx} y={oy + 2} anchor="start" color="var(--charcoal)">top flange</Label>
      <Label x={lx} y={oy + 17} anchor="start">{`${bt} ${unit} × ${tt} ${unit}`}</Label>

      <line x1={cx + TW / 2} y1={(yTopB + yBotT) / 2 - 30} x2={lx - 4} y2={(yTopB + yBotT) / 2 - 30} stroke={gray} strokeWidth={1} />
      <Label x={lx} y={(yTopB + yBotT) / 2 - 37} anchor="start" color="var(--charcoal)">web</Label>
      <Label x={lx} y={(yTopB + yBotT) / 2 - 22} anchor="start">{`${tw} ${unit} × ${hw} ${unit}`}</Label>

      <line x1={cx + (bb * S) / 2 - 8} y1={yBotT + (tb * S) / 2} x2={lx - 4} y2={yBotT - 14} stroke={gray} strokeWidth={1} />
      <Label x={lx} y={yBotT - 28} anchor="start" color="var(--charcoal)">bottom flange</Label>
      <Label x={lx} y={yBotT - 13} anchor="start">{`${bb} ${unit} × ${tb} ${unit}`}</Label>
    </svg>
  );
}
