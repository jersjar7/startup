import React from 'react';
import { Label } from '../../primitives';

/**
 * Section through a dry detention pond at its outlet riser, pond full to the
 * design high-water level. The orifice is in the upstream wall of the riser
 * and discharges freely into it.
 * Shows: high-water elevation, orifice centerline elevation, pond bottom
 * elevation.
 * Does NOT show: the orifice diameter or the head (left for the student).
 */
export function CtWaterResourcesBPondOutlet({ elHwl = 108.0, elOrifice = 101.0, elBottom = 99.0, orificeDraw = 0.9 }) {
  const s = 13; // px per ft
  const bottomY = 172;
  const Y = (el) => bottomY - (el - elBottom) * s;
  const hwlY = Y(elHwl);
  const oY = Y(elOrifice);
  const oR = (orificeDraw * s) / 2;
  const rUp = 262; // riser upstream wall (outer face)
  const wall = 7;
  const rDn = 296; // riser downstream wall (outer face)
  const riserTop = hwlY - 16;
  const slopeTop = 24;
  const pipeTop = bottomY + 9;
  const pipeBot = bottomY + 21;
  const embToe = 316;
  const embCrestL = 352;
  const crestY = riserTop - 18;

  return (
    <svg viewBox={`0 0 420 ${pipeBot + 28}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Detention pond outlet: high water El. ${elHwl} ft, orifice centerline El. ${elOrifice} ft, pond bottom El. ${elBottom} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Embankment */}
      <polygon points={`${embToe},${bottomY} ${embCrestL},${crestY} 412,${crestY} 412,${bottomY}`} fill="var(--cream-dark)" />
      <polyline points={`${embToe},${bottomY} ${embCrestL},${crestY} 412,${crestY}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />

      {/* Pond water */}
      <polygon points={`${slopeTop},${hwlY} ${rUp},${hwlY} ${rUp},${bottomY} ${slopeTop + (bottomY - hwlY) * 0.32},${bottomY}`} fill="var(--info)" fillOpacity={0.18} />
      <line x1={slopeTop} y1={hwlY} x2={rUp} y2={hwlY} stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={`${150},${hwlY - 11} ${162},${hwlY - 11} ${156},${hwlY - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />
      <Label x={slopeTop + 4} y={hwlY - 22} color="var(--charcoal)" fontSize={12} anchor="start">{`design high water El. ${elHwl.toFixed(1)} ft`}</Label>

      {/* Pond side slope and bottom */}
      <polyline points={`${slopeTop - 14},${hwlY - 44} ${slopeTop + (bottomY - hwlY) * 0.32},${bottomY} ${embToe},${bottomY}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.8} />
      <Label x={130} y={bottomY + 16} color="var(--charcoal)" fontSize={12}>{`pond bottom El. ${elBottom.toFixed(1)} ft`}</Label>

      {/* Riser */}
      <rect x={rUp} y={riserTop} width={wall} height={oY - oR - riserTop} fill="var(--gray-400)" stroke="var(--charcoal)" strokeWidth={1.4} />
      <rect x={rUp} y={oY + oR} width={wall} height={pipeBot - (oY + oR)} fill="var(--gray-400)" stroke="var(--charcoal)" strokeWidth={1.4} />
      <rect x={rDn - wall} y={riserTop} width={wall} height={pipeTop - riserTop} fill="var(--gray-400)" stroke="var(--charcoal)" strokeWidth={1.4} />
      <line x1={rUp} y1={pipeBot} x2={rDn - wall} y2={pipeBot} stroke="var(--charcoal)" strokeWidth={1.4} />
      <Label x={(rUp + rDn) / 2} y={riserTop - 12} color="var(--charcoal)" fontSize={12}>riser</Label>

      {/* Free-falling jet inside the riser */}
      <path d={`M ${rUp + wall},${oY} Q ${rUp + wall + 14},${oY + 2} ${rUp + wall + 18},${pipeTop - 2}`} fill="none" stroke="var(--info)" strokeWidth={2} />

      {/* Outlet pipe through the embankment */}
      <line x1={rDn} y1={pipeTop} x2={412} y2={pipeTop} stroke="var(--charcoal)" strokeWidth={1.6} />
      <line x1={rDn - wall} y1={pipeBot} x2={412} y2={pipeBot} stroke="var(--charcoal)" strokeWidth={1.6} />
      <Label x={372} y={pipeBot + 14} color="var(--charcoal)" fontSize={11}>outlet pipe</Label>

      {/* Orifice centerline */}
      <line x1={rUp - 70} y1={oY} x2={rUp - 4} y2={oY} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="5,3" />
      <Label x={rUp - 76} y={oY - 10} color="var(--charcoal)" fontSize={12} anchor="end">orifice C.L.</Label>
      <Label x={rUp - 76} y={oY + 6} color="var(--charcoal)" fontSize={12} anchor="end">{`El. ${elOrifice.toFixed(1)} ft`}</Label>
    </svg>
  );
}
