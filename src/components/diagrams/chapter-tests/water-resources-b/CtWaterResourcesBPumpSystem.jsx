import React from 'react';
import { Label } from '../../primitives';

/**
 * Lift station: wet well, pump in a dry pit, force main up a hillside into
 * a ground storage tank. Not to scale.
 * Shows: the water surface elevations in the wet well and the tank.
 * Does NOT show: the total head, the power or the losses (given in the stem).
 */
export function CtWaterResourcesBPumpSystem({ elWell = 102.0, elTank = 186.0 }) {
  const gY = 150; // ground at the lift station
  const hillTop = 96;
  const ws = 178; // wet well water surface
  const tankL = 290;
  const tankR = 380;
  const tankTop = 30;
  const tankWs = 48;
  const ground = `8,${gY} 20,${gY} M 110,${gY} L 125,${gY} M 205,${gY} L 260,${hillTop} L 412,${hillTop}`;
  const tri = (x, y) => `${x - 6},${y - 11} ${x + 6},${y - 11} ${x},${y - 3}`;

  return (
    <svg viewBox="0 0 420 246" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Lift station: wet well water surface El. ${elWell} ft, storage tank water surface El. ${elTank} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Ground surface */}
      <path d={`M ${ground}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />

      {/* Wet well */}
      <rect x={20} y={ws} width={90} height={230 - ws} fill="var(--info)" fillOpacity={0.18} />
      <polyline points={`20,${gY} 20,230 110,230 110,${gY}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.4} />
      <line x1={20} y1={ws} x2={110} y2={ws} stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={tri(36, ws)} fill="none" stroke="var(--info)" strokeWidth={1.4} />
      <Label x={65} y={140} color="var(--charcoal)" fontSize={12} bold>wet well</Label>
      <Label x={65} y={194} color="var(--charcoal)" fontSize={12}>{`El. ${elWell.toFixed(1)} ft`}</Label>

      {/* Dry pit and pump */}
      <polyline points={`125,${gY} 125,230 205,230 205,${gY}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.4} />
      <polyline points={`60,224 60,214 140,214`} fill="none" stroke="var(--charcoal)" strokeWidth={3} strokeLinejoin="round" />
      <line x1={53} y1={224} x2={67} y2={224} stroke="var(--charcoal)" strokeWidth={3} />
      <circle cx={152} cy={212} r={12} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={2.2} />
      <Label x={152} y={213} color="var(--charcoal)" fontSize={12} bold>P</Label>
      <Label x={170} y={213} color="var(--charcoal)" fontSize={11} anchor="start">pump</Label>

      {/* Force main */}
      <polyline points={`152,200 152,164 213,164 275,116 300,116 300,96`} fill="none" stroke="var(--charcoal)" strokeWidth={3} strokeLinejoin="round" />

      {/* Storage tank */}
      <rect x={tankL} y={tankWs} width={tankR - tankL} height={hillTop - tankWs} fill="var(--info)" fillOpacity={0.18} />
      <polyline points={`${tankL},${tankTop} ${tankL},${hillTop} ${tankR},${hillTop} ${tankR},${tankTop}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.4} />
      <line x1={tankL} y1={tankWs} x2={tankR} y2={tankWs} stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={tri(360, tankWs)} fill="none" stroke="var(--info)" strokeWidth={1.4} />
      <Label x={(tankL + tankR) / 2} y={16} color="var(--charcoal)" fontSize={12} bold>storage tank</Label>
      <Label x={tankL - 8} y={tankWs} color="var(--charcoal)" fontSize={12} anchor="end">{`El. ${elTank.toFixed(1)} ft`}</Label>

      <Label x={412} y={238} color="var(--gray-500)" fontSize={11} anchor="end">NOT TO SCALE</Label>
    </svg>
  );
}
