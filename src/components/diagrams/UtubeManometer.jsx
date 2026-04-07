import React from 'react';
import { DimensionLine, DashedLine, Label } from './primitives';

/**
 * U-tube manometer connecting a pressurized line to the atmosphere.
 *
 * Two modes:
 *  1. Simple differential (h only): height difference between mercury surfaces
 *  2. Dual-height (h1 + h2): both heights measured from pipe connection level
 *
 * Shows: U-tube container, mercury fill, surface lines, height dimensions.
 * Dual mode adds: pipe stub on left leg, h₁/h₂ from pipe connection datum.
 * Does NOT show: pressure, SG, gamma (in problem text).
 */
export function UtubeManometer({
  h = 250,
  h1 = 0,
  h2 = 0,
  unit = 'mm',
}) {
  const isDual = h1 > 0 && h2 > 0;
  const W = isDual ? 500 : 420;
  const H = isDual ? 250 : 220;

  // ── U-tube geometry ──
  const wallT = 3;
  const bore = 24;
  const legGap = 56;
  const bendR = 18;

  // Shift tube right in dual mode for pipe + h₁ room on the left
  const uCx = isDual ? 260 : 205;

  // Bore centers
  const leftCx = uCx - legGap / 2 - bore / 2;
  const rightCx = uCx + legGap / 2 + bore / 2;

  // Outer wall edges
  const outerLL = leftCx - bore / 2 - wallT;
  const outerLR = leftCx + bore / 2 + wallT;
  const outerRL = rightCx - bore / 2 - wallT;
  const outerRR = rightCx + bore / 2 + wallT;

  // Inner bore edges
  const innerLL = leftCx - bore / 2;
  const innerLR = leftCx + bore / 2;
  const innerRL = rightCx - bore / 2;
  const innerRR = rightCx + bore / 2;

  // Vertical positions
  const topY = 36;
  const bendOuterY = isDual ? 210 : 190;
  const bendInnerY = bendOuterY - 16;
  const innerBendR = 10;

  // ── Mercury levels ──
  const maxH = isDual ? Math.max(h1, h2) : h;
  const pixelRange = isDual ? 90 : 70;
  const scale = pixelRange / maxH;

  // Pipe connection reference (dual mode)
  const pipeRefY = 150;

  let hgLeftY, hgRightY;
  if (isDual) {
    // h1 = mercury above pipe on left (tank) side
    // h2 = mercury above pipe on right (atm) side — taller column
    hgLeftY = pipeRefY - h1 * scale;
    hgRightY = pipeRefY - h2 * scale;
  } else {
    // Simple mode: left (air) side is HIGHER, right (atm) side is LOWER
    const midLevel = bendInnerY - 30;
    hgRightY = midLevel;
    hgLeftY = midLevel - h * scale;
  }

  // ── Pipe stub (dual mode) ──
  const pipeLen = 55;
  const pipeBore = 12;
  const pipeY = pipeRefY;
  const pipeX = outerLL - pipeLen;

  // ── Build paths ──

  const outerBendR = bendR;
  const outerPath = [
    `M ${outerLL},${topY}`,
    `V ${bendOuterY - outerBendR}`,
    `A ${outerBendR},${outerBendR} 0 0 0 ${outerLL + outerBendR},${bendOuterY}`,
    `H ${outerRR - outerBendR}`,
    `A ${outerBendR},${outerBendR} 0 0 0 ${outerRR},${bendOuterY - outerBendR}`,
    `V ${topY}`,
  ].join(' ');

  const innerPath = [
    `M ${outerLR},${topY}`,
    `V ${bendInnerY - innerBendR}`,
    `A ${innerBendR},${innerBendR} 0 0 0 ${outerLR + innerBendR},${bendInnerY}`,
    `H ${outerRL - innerBendR}`,
    `A ${innerBendR},${innerBendR} 0 0 0 ${outerRL},${bendInnerY - innerBendR}`,
    `V ${topY}`,
  ].join(' ');

  const fillOuterR = outerBendR - wallT;
  const fillOuterBotY = bendOuterY - wallT;
  const fillPath = [
    `M ${innerLL},${hgLeftY}`,
    `V ${fillOuterBotY - fillOuterR}`,
    `A ${fillOuterR},${fillOuterR} 0 0 0 ${innerLL + fillOuterR},${fillOuterBotY}`,
    `H ${innerRR - fillOuterR}`,
    `A ${fillOuterR},${fillOuterR} 0 0 0 ${innerRR},${fillOuterBotY - fillOuterR}`,
    `V ${hgRightY}`,
    `H ${innerRL}`,
    `V ${bendInnerY - innerBendR}`,
    `A ${innerBendR},${innerBendR} 0 0 1 ${innerRL - innerBendR},${bendInnerY}`,
    `H ${innerLR + innerBendR}`,
    `A ${innerBendR},${innerBendR} 0 0 1 ${innerLR},${bendInnerY - innerBendR}`,
    `V ${hgLeftY}`,
    'Z',
  ].join(' ');

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`U-tube manometer with mercury, ${isDual ? `h\u2081=${h1}, h\u2082=${h2}` : `h=${h}`} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Mercury fill */}
      <path d={fillPath} fill="rgba(140,155,180,0.45)" />

      {/* 2. Container walls */}
      <path d={outerPath} fill="none" stroke="var(--charcoal)" strokeWidth={2}
        strokeLinejoin="round" />
      <path d={innerPath} fill="none" stroke="var(--charcoal)" strokeWidth={2}
        strokeLinejoin="round" />

      {/* 3. Mercury surface lines */}
      <line x1={innerLL} y1={hgLeftY} x2={innerLR} y2={hgLeftY}
        stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={innerRL} y1={hgRightY} x2={innerRR} y2={hgRightY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 4. Pipe stub — dual mode only */}
      {isDual && (
        <>
          <line x1={pipeX} y1={pipeY - pipeBore / 2} x2={outerLL} y2={pipeY - pipeBore / 2}
            stroke="var(--charcoal)" strokeWidth={2} />
          <line x1={pipeX} y1={pipeY + pipeBore / 2} x2={outerLL} y2={pipeY + pipeBore / 2}
            stroke="var(--charcoal)" strokeWidth={2} />
          <line x1={pipeX} y1={pipeY - pipeBore / 2} x2={pipeX} y2={pipeY + pipeBore / 2}
            stroke="var(--charcoal)" strokeWidth={2} />
          <Label x={pipeX + pipeLen / 2} y={pipeY + pipeBore / 2 + 14}
            fontSize={9} color="var(--gray-500)">
            Tank
          </Label>
        </>
      )}

      {/* 5. Labels */}
      <Label x={rightCx} y={topY - 14}
        fontSize={9} color="var(--gray-500)">
        Atm
      </Label>

      <Label x={uCx} y={bendOuterY + 16}
        fontSize={9} color="var(--gray-400)" italic>
        Mercury
      </Label>

      {/* 6. Height dimensions */}
      {isDual ? (
        <>
          {/* h₁ — left of pipe, from pipe connection to left mercury surface */}
          <DimensionLine
            x1={pipeX - 14} y1={pipeY}
            x2={pipeX - 14} y2={hgLeftY}
            label={`h\u2081 = ${h1} ${unit}`} offset={-36} fontSize={9} />
          <DashedLine x1={pipeX - 22} y1={pipeY} x2={pipeX} y2={pipeY} />
          <DashedLine x1={pipeX - 22} y1={hgLeftY} x2={pipeX} y2={hgLeftY} />

          {/* h₂ — right of right leg, from pipe connection level to mercury surface */}
          <DimensionLine
            x1={outerRR + 18} y1={pipeY}
            x2={outerRR + 18} y2={hgRightY}
            label={`h\u2082 = ${h2} ${unit}`} offset={30} fontSize={9} />
          <DashedLine x1={outerRR + 8} y1={pipeY} x2={outerRR + 26} y2={pipeY} />
          <DashedLine x1={outerRR + 8} y1={hgRightY} x2={outerRR + 26} y2={hgRightY} />
        </>
      ) : (
        <>
          {/* h dimension — between the two mercury surfaces */}
          <DimensionLine
            x1={outerRR + 36} y1={hgRightY}
            x2={outerRR + 36} y2={hgLeftY}
            label={`h = ${h} ${unit}`} offset={42} fontSize={10} />
          <DashedLine x1={innerLR + 2} y1={hgLeftY}
            x2={outerRR + 44} y2={hgLeftY} />
          <DashedLine x1={innerRR + 2} y1={hgRightY}
            x2={outerRR + 44} y2={hgRightY} />
        </>
      )}
    </svg>
  );
}
