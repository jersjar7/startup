import React from 'react';
import { DashedLine, DimensionLine, Label } from './primitives';

/**
 * Unconfined aquifer well drawdown (Dupuit equation).
 *
 * Shows: aquifer with curved water table (cone of depression),
 *        pumping well, observation well, h1/h2 heights, r1/r2 distances.
 *        r1 is the well casing radius; h1 is measured at the well.
 *
 * Does NOT show: computed Q (student solves).
 */
export function UnconfinedWell({
  h1 = 40,
  h2 = 60,
  r1 = 0.5,
  r2 = 200,
  unit = 'ft',
}) {
  const W = 460;
  const HH = 310;

  // Layout
  const groundY = 60;
  const aquiferBotY = 240;
  const aquiferH = aquiferBotY - groundY;

  // Scale heights proportionally
  const maxH = Math.max(h1, h2) * 1.15;
  const hScale = (aquiferH - 20) / maxH;

  const h1Px = h1 * hScale;
  const h2Px = h2 * hScale;

  const staticWtY = aquiferBotY - h2Px - 10; // static water table slightly above h2

  // X positions
  const wellX = 140;
  const obsX = 340;
  const leftX = 30;
  const rightX = W - 30;

  // Water table Y at well and obs well (measured from aquifer bottom)
  const wtWellY = aquiferBotY - h1Px;
  const wtObsY = aquiferBotY - h2Px;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Unconfined well drawdown, h1=${h1} ${unit} at r1=${r1} ${unit}, h2=${h2} ${unit} at r2=${r2} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Aquifer fill */}
      <rect x={leftX} y={groundY} width={rightX - leftX} height={aquiferBotY - groundY}
        fill="rgba(180,160,130,0.12)" />

      {/* 2. Water fill below water table */}
      <path d={`M ${leftX},${wtObsY - 5}
        Q ${leftX + 40},${wtObsY - 4} ${wellX - 20},${wtWellY + 8}
        L ${wellX - 4},${wtWellY}
        L ${wellX - 4},${aquiferBotY}
        L ${leftX},${aquiferBotY} Z`}
        fill="rgba(160,210,240,0.20)" />
      <path d={`M ${wellX + 4},${wtWellY}
        L ${wellX + 4},${aquiferBotY}
        L ${rightX},${aquiferBotY}
        L ${rightX},${wtObsY - 5}
        Q ${obsX + 40},${wtObsY - 3} ${obsX},${wtObsY}
        Q ${wellX + 60},${wtWellY + 15} ${wellX + 20},${wtWellY + 4}
        L ${wellX + 4},${wtWellY} Z`}
        fill="rgba(160,210,240,0.20)" />

      {/* 3. Aquifer bottom */}
      <line x1={leftX} y1={aquiferBotY} x2={rightX} y2={aquiferBotY}
        stroke="var(--charcoal)" strokeWidth={2} />
      {/* Bottom hatching */}
      {Array.from({ length: 18 }, (_, i) => {
        const hx = leftX + 10 + i * 24;
        return (
          <line key={i} x1={hx} y1={aquiferBotY} x2={hx + 10} y2={aquiferBotY + 8}
            stroke="var(--gray-400)" strokeWidth={1} />
        );
      })}

      {/* 4. Ground surface */}
      <line x1={leftX} y1={groundY} x2={rightX} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 5. Curved water table (cone of depression) */}
      <path d={`M ${leftX},${wtObsY - 5}
        Q ${leftX + 40},${wtObsY - 4} ${wellX - 20},${wtWellY + 8}
        L ${wellX - 4},${wtWellY}`}
        fill="none" stroke="var(--info)" strokeWidth={1.5} />
      <path d={`M ${wellX + 4},${wtWellY}
        Q ${wellX + 60},${wtWellY + 15} ${obsX},${wtObsY}
        Q ${obsX + 40},${wtObsY - 3} ${rightX},${wtObsY - 5}`}
        fill="none" stroke="var(--info)" strokeWidth={1.5} />

      {/* 6. Static water table (dashed) */}
      <DashedLine x1={leftX} y1={staticWtY} x2={rightX} y2={staticWtY}
        color="var(--gray-400)" strokeWidth={1} dasharray="6,4" />
      <Label x={rightX - 4} y={staticWtY - 8}
        fontSize={7} color="var(--gray-400)" anchor="end">
        Static W.T.
      </Label>

      {/* 7. Pumping well */}
      <rect x={wellX - 3} y={groundY - 10} width={6} height={aquiferBotY - groundY + 10}
        fill="white" stroke="var(--charcoal)" strokeWidth={1.5} />
      {/* Pump symbol (arrow up) */}
      <path d={`M ${wellX},${groundY - 6} L ${wellX - 5},${groundY - 16} L ${wellX + 5},${groundY - 16} Z`}
        fill="var(--charcoal)" />

      {/* 8. Observation well */}
      <line x1={obsX} y1={groundY - 6} x2={obsX} y2={aquiferBotY}
        stroke="var(--charcoal)" strokeWidth={1.5} />
      <circle cx={obsX} cy={groundY - 6} r={2} fill="var(--charcoal)" />

      {/* 9. h1 dimension */}
      <DimensionLine x1={wellX - 22} y1={aquiferBotY} x2={wellX - 22} y2={wtWellY}
        label={`h\u2081 = ${h1}`} offset={-22} fontSize={8} />

      {/* 10. h2 dimension */}
      <DimensionLine x1={obsX + 18} y1={aquiferBotY} x2={obsX + 18} y2={wtObsY}
        label={`h\u2082 = ${h2}`} offset={18} fontSize={8} />

      {/* 11. r1 label */}
      <Label x={(wellX + wellX + 20) / 2} y={aquiferBotY + 18}
        fontSize={8} color="var(--gray-500)">
        r{'\u2081'} = {r1} {unit}
      </Label>

      {/* 12. r2 dimension (horizontal) */}
      <DimensionLine x1={wellX} y1={aquiferBotY + 30} x2={obsX} y2={aquiferBotY + 30}
        label={`r\u2082 = ${r2} ${unit}`} offset={12} fontSize={8} />

      {/* 13. Labels */}
      <Label x={wellX} y={groundY - 22} fontSize={8} color="var(--charcoal)" bold>
        Well
      </Label>
      <Label x={obsX} y={groundY - 16} fontSize={8} color="var(--charcoal)" bold>
        Obs. Well
      </Label>
    </svg>
  );
}
