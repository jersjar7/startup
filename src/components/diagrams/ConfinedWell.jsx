import React from 'react';
import { DashedLine, DimensionLine, Label } from './primitives';

/**
 * Confined aquifer well drawdown (Thiem equation).
 *
 * Shows: confining layers (top and bottom), aquifer of thickness b,
 *        piezometric surface (dashed, curves down near well),
 *        pumping well, TWO observation wells at r1 and r2,
 *        h1/h2 piezometric heights, r1/r2 distances.
 *
 * Does NOT show: computed Q (student solves).
 */
export function ConfinedWell({
  h1 = 25,
  h2 = 30,
  b = 20,
  r1 = 10,
  r2 = 100,
  unit = 'm',
}) {
  const W = 500;
  const HH = 310;

  // Layout
  const groundY = 30;
  const confTopY = 70;
  const confTopH = 20;
  const aquiferTopY = confTopY + confTopH;
  const aquiferBotY = 220;
  const confBotY = aquiferBotY;
  const confBotH = 20;

  const leftX = 30;
  const rightX = W - 30;

  // Scale piezometric heights — h1/h2 from aquifer bottom
  const maxH = Math.max(h1, h2) * 1.1;
  const hScale = (aquiferBotY - groundY + 20) / maxH;
  const h1Px = h1 * hScale;
  const h2Px = h2 * hScale;

  const piezoObs1Y = aquiferBotY - h1Px;
  const piezoObs2Y = aquiferBotY - h2Px;

  // X positions — pumping well, obs1 (at r1), obs2 (at r2)
  const wellX = 100;
  const obs1X = 210;
  const obs2X = 380;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Confined well drawdown, h1=${h1} ${unit} at r1=${r1} ${unit}, h2=${h2} ${unit} at r2=${r2} ${unit}, b=${b} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Bottom confining layer */}
      <rect x={leftX} y={confBotY} width={rightX - leftX} height={confBotH}
        fill="rgba(140,130,120,0.20)" stroke="var(--charcoal)" strokeWidth={1} />
      {Array.from({ length: 16 }, (_, i) => {
        const hx = leftX + 8 + i * 28;
        return (
          <line key={`b${i}`} x1={hx} y1={confBotY + 2} x2={hx + 14} y2={confBotY + confBotH - 2}
            stroke="var(--gray-400)" strokeWidth={0.8} />
        );
      })}

      {/* 2. Aquifer fill */}
      <rect x={leftX} y={aquiferTopY} width={rightX - leftX} height={aquiferBotY - aquiferTopY}
        fill="rgba(180,160,130,0.12)" />

      {/* 3. Aquifer water fill (fully saturated) */}
      <rect x={leftX} y={aquiferTopY} width={rightX - leftX} height={aquiferBotY - aquiferTopY}
        fill="rgba(160,210,240,0.15)" />

      {/* 4. Top confining layer */}
      <rect x={leftX} y={confTopY} width={rightX - leftX} height={confTopH}
        fill="rgba(140,130,120,0.20)" stroke="var(--charcoal)" strokeWidth={1} />
      {Array.from({ length: 16 }, (_, i) => {
        const hx = leftX + 8 + i * 28;
        return (
          <line key={`t${i}`} x1={hx} y1={confTopY + 2} x2={hx + 14} y2={confTopY + confTopH - 2}
            stroke="var(--gray-400)" strokeWidth={0.8} />
        );
      })}

      {/* 5. Ground surface */}
      <line x1={leftX} y1={groundY} x2={rightX} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Overburden fill */}
      <rect x={leftX} y={groundY} width={rightX - leftX} height={confTopY - groundY}
        fill="rgba(180,160,130,0.08)" />

      {/* 6. Piezometric surface (dashed, curves down near well) */}
      {/* Right side: from far right through obs2 and obs1 toward well */}
      <path d={`M ${rightX},${piezoObs2Y - 3}
        Q ${obs2X + 30},${piezoObs2Y - 1} ${obs2X},${piezoObs2Y}
        Q ${(obs1X + obs2X) / 2},${(piezoObs1Y + piezoObs2Y) / 2 + 4} ${obs1X},${piezoObs1Y}
        Q ${(wellX + obs1X) / 2},${piezoObs1Y + 12} ${wellX + 4},${piezoObs1Y + 16}`}
        fill="none" stroke="var(--info)" strokeWidth={1.5} strokeDasharray="6,4" />
      {/* Left side mirror */}
      <path d={`M ${wellX - 4},${piezoObs1Y + 16}
        Q ${(leftX + wellX) / 2},${piezoObs1Y + 12} ${leftX},${piezoObs2Y - 3}`}
        fill="none" stroke="var(--info)" strokeWidth={1.5} strokeDasharray="6,4" />

      {/* Static piezometric surface */}
      <DashedLine x1={leftX} y1={piezoObs2Y - 10} x2={rightX} y2={piezoObs2Y - 10}
        color="var(--gray-400)" strokeWidth={1} dasharray="4,4" />
      <Label x={rightX - 4} y={piezoObs2Y - 18}
        fontSize={7} color="var(--gray-400)" anchor="end">
        Static piezo.
      </Label>

      {/* 7. Pumping well */}
      <rect x={wellX - 3} y={groundY - 8} width={6} height={aquiferBotY - groundY + 8}
        fill="white" stroke="var(--charcoal)" strokeWidth={1.5} />
      <path d={`M ${wellX},${groundY - 4} L ${wellX - 5},${groundY - 14} L ${wellX + 5},${groundY - 14} Z`}
        fill="var(--charcoal)" />

      {/* 8. Observation well 1 (at r1) */}
      <line x1={obs1X} y1={groundY - 4} x2={obs1X} y2={aquiferBotY}
        stroke="var(--charcoal)" strokeWidth={1.5} />
      <circle cx={obs1X} cy={groundY - 4} r={2} fill="var(--charcoal)" />

      {/* 9. Observation well 2 (at r2) */}
      <line x1={obs2X} y1={groundY - 4} x2={obs2X} y2={aquiferBotY}
        stroke="var(--charcoal)" strokeWidth={1.5} />
      <circle cx={obs2X} cy={groundY - 4} r={2} fill="var(--charcoal)" />

      {/* 10. h1 dimension (at obs1) */}
      <DimensionLine x1={obs1X - 18} y1={aquiferBotY} x2={obs1X - 18} y2={piezoObs1Y}
        label={`h\u2081 = ${h1}`} offset={-22} fontSize={8} />

      {/* 11. h2 dimension (at obs2) */}
      <DimensionLine x1={obs2X + 18} y1={aquiferBotY} x2={obs2X + 18} y2={piezoObs2Y}
        label={`h\u2082 = ${h2}`} offset={18} fontSize={8} />

      {/* 12. Aquifer thickness b */}
      <DimensionLine x1={rightX - 8} y1={aquiferTopY} x2={rightX - 8} y2={aquiferBotY}
        label={`b = ${b}`} offset={16} fontSize={8} />

      {/* 13. r1 dimension */}
      <DimensionLine x1={wellX} y1={aquiferBotY + confBotH + 10} x2={obs1X} y2={aquiferBotY + confBotH + 10}
        label={`r\u2081 = ${r1} ${unit}`} offset={12} fontSize={8} />

      {/* 14. r2 dimension */}
      <DimensionLine x1={wellX} y1={aquiferBotY + confBotH + 30} x2={obs2X} y2={aquiferBotY + confBotH + 30}
        label={`r\u2082 = ${r2} ${unit}`} offset={12} fontSize={8} />

      {/* 15. Labels */}
      <Label x={wellX} y={groundY - 20} fontSize={8} color="var(--charcoal)" bold>
        Well
      </Label>
      <Label x={obs1X} y={groundY - 14} fontSize={8} color="var(--charcoal)" bold>
        Obs. 1
      </Label>
      <Label x={obs2X} y={groundY - 14} fontSize={8} color="var(--charcoal)" bold>
        Obs. 2
      </Label>
      <Label x={(leftX + wellX) / 2} y={(aquiferTopY + aquiferBotY) / 2}
        fontSize={8} color="var(--gray-400)">
        Aquifer
      </Label>
    </svg>
  );
}
