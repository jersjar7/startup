import React from 'react';
import { DashedLine, Label } from './primitives';

/**
 * Differential leveling profile — instrument with sight lines to rods.
 *
 * Shows: ground terrain, instrument on tripod, rod at BM and target point,
 *        horizontal sight line (dashed), BS/FS labels, point labels.
 *
 * Supports 1 or 2 instrument setups (with turning point).
 *
 * Does NOT show: computed HI, computed elevations (student solves).
 */
export function LevelingSetup({
  setups = 1,
  bmLabel = 'BM',
  targetLabel = 'A',
  tpLabel = 'TP-1',
}) {
  const isSingle = setups <= 1;
  const W = isSingle ? 380 : 460;
  const H = 200;

  // Ground profile — gentle undulation
  const groundY = 150;
  const groundLeft = 20;
  const groundRight = W - 20;

  // Point x-positions
  let bmX, instX, tpX, inst2X, targetX;
  if (isSingle) {
    bmX = 60;
    instX = 180;
    targetX = 320;
  } else {
    bmX = 40;
    instX = 120;
    tpX = 210;
    inst2X = 300;
    targetX = 400;
  }

  // Ground offsets for terrain variety
  const groundBmY = groundY;
  const groundTpY = isSingle ? groundY : groundY + 11;
  const groundTargetY = groundY - 2;

  // Instrument height above ground
  const instH = 28;

  // Rod height
  const rodH = 50;

  // Instrument sight line Y — mid-height of level body (rect is 6px tall)
  const sightY1 = groundBmY - instH + 3;

  // ── Iconic level instrument ──
  const drawInstrument = (ix, gy) => {
    const top = gy - instH;
    const legSpread = 14;
    return (
      <g>
        {/* Tripod legs */}
        <line x1={ix - legSpread} y1={gy} x2={ix} y2={top + 6}
          stroke="var(--charcoal)" strokeWidth={1.5} />
        <line x1={ix + legSpread} y1={gy} x2={ix} y2={top + 6}
          stroke="var(--charcoal)" strokeWidth={1.5} />
        <line x1={ix} y1={gy} x2={ix} y2={top + 6}
          stroke="var(--charcoal)" strokeWidth={1.5} />
        {/* Level body */}
        <rect x={ix - 10} y={top} width={20} height={6} rx={1}
          fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.5} />
      </g>
    );
  };

  // ── Rod ──
  const drawRod = (rx, gy, label, reading, side) => {
    const rodTop = gy - rodH;
    return (
      <g>
        {/* Rod line */}
        <line x1={rx} y1={gy} x2={rx} y2={rodTop}
          stroke="var(--charcoal)" strokeWidth={2} />
        {/* Rod base tick */}
        <line x1={rx - 4} y1={gy} x2={rx + 4} y2={gy}
          stroke="var(--charcoal)" strokeWidth={2} />
        {/* Reading label */}
        <Label x={rx} y={rodTop - 10}
          fontSize={9} color="var(--gray-500)">
          {reading}
        </Label>
        {/* Point label */}
        <Label x={rx} y={gy + 14}
          fontSize={9} color="var(--charcoal)" bold>
          {label}
        </Label>
      </g>
    );
  };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Differential leveling setup with ${setups} instrument setup${setups > 1 ? 's' : ''}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Ground line — gentle undulation */}
      <path d={isSingle
        ? `M ${groundLeft},${groundBmY} Q ${(bmX + instX) / 2},${groundY - 3} ${instX},${groundY} Q ${(instX + targetX) / 2},${groundY + 3} ${groundRight},${groundTargetY}`
        : `M ${groundLeft},${groundBmY} Q ${bmX + 30},${groundY - 2} ${instX},${groundY} Q ${(instX + tpX) / 2},${groundY + 6} ${tpX},${groundTpY} Q ${(tpX + inst2X) / 2},${groundY + 2} ${inst2X},${groundY} Q ${(inst2X + targetX) / 2},${groundY - 4} ${groundRight},${groundTargetY}`
      }
        fill="none" stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* 2. Instruments */}
      {drawInstrument(instX, groundY)}
      {!isSingle && drawInstrument(inst2X, groundY)}

      {/* 3. Sight lines */}
      <DashedLine x1={bmX} y1={sightY1} x2={isSingle ? targetX : tpX} y2={sightY1}
        color="var(--gray-400)" strokeWidth={1} />
      {!isSingle && (() => {
        const sight2Y = groundY - instH + 3;
        return (
          <DashedLine x1={tpX} y1={sight2Y} x2={targetX} y2={sight2Y}
            color="var(--gray-400)" strokeWidth={1} />
        );
      })()}

      {/* 4. Rods */}
      {drawRod(bmX, groundBmY, bmLabel, 'BS', 'left')}
      {isSingle && drawRod(targetX, groundTargetY, targetLabel, 'FS', 'right')}
      {!isSingle && (
        <>
          {drawRod(tpX, groundTpY, tpLabel, 'FS / BS', 'center')}
          {drawRod(targetX, groundTargetY, targetLabel, 'FS', 'right')}
        </>
      )}

      {/* 5. BS / FS annotations along sight line */}
      <Label x={(bmX + instX) / 2} y={sightY1 - 10}
        fontSize={8} color="var(--ember)" bold>
        BS
      </Label>
      {isSingle ? (
        <Label x={(instX + targetX) / 2} y={sightY1 - 10}
          fontSize={8} color="var(--ember)" bold>
          FS
        </Label>
      ) : (
        <>
          <Label x={(instX + tpX) / 2} y={sightY1 - 10}
            fontSize={8} color="var(--ember)" bold>
            FS
          </Label>
          {(() => {
            const sight2Y = groundY - instH + 3;
            return (
              <>
                <Label x={(tpX + inst2X) / 2} y={sight2Y - 10}
                  fontSize={8} color="var(--ember)" bold>
                  BS
                </Label>
                <Label x={(inst2X + targetX) / 2} y={sight2Y - 10}
                  fontSize={8} color="var(--ember)" bold>
                  FS
                </Label>
              </>
            );
          })()}
        </>
      )}

      {/* Disclaimer */}
      <text x={W / 2} y={H - 4} textAnchor="middle"
        fontFamily="var(--font-body)" fontSize={7} fontStyle="italic"
        fill="var(--gray-400)">
        Illustration only — not to scale
      </text>
    </svg>
  );
}
