import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

export function StressElement({ sigmaX = 80, sigmaY = -20, tauXY = 0 }) {
  const cx = 180;
  const cy = 125;
  const half = 45;
  const arrowLen = 40;
  const gap = 4;
  const shearOff = 5;

  /* Element corners */
  const left = cx - half;
  const right = cx + half;
  const top = cy - half;
  const bottom = cy + half;

  /* Show/hide shear based on whether tauXY is nonzero */
  const hasShear = tauXY !== 0;

  /* Format stress label: include sign for negative */
  const fmtSigma = (v) => {
    if (v === 0) return '0';
    return `${v}`;
  };

  return (
    <svg viewBox="0 0 360 260" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Stress element: σx = ${sigmaX} MPa, σy = ${sigmaY} MPa, τxy = ${tauXY} MPa`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowStress" color="var(--charcoal)" size={7} />
      {hasShear && (
        <ArrowMarkerDefs id="arrowShear" color="var(--ember)" size={6} />
      )}

      {/* Element square */}
      <rect x={left} y={top} width={half * 2} height={half * 2}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={1} />

      {/* σx arrows — horizontal, pointing outward for tension, inward for compression */}
      {sigmaX !== 0 && (
        <>
          {/* Right face */}
          <ForceArrow
            x1={sigmaX > 0 ? right + gap : right + gap + arrowLen}
            y1={cy}
            x2={sigmaX > 0 ? right + gap + arrowLen : right + gap}
            y2={cy}
            markerId="arrowStress" strokeWidth={2} />
          <Label x={right + gap + arrowLen + 8} y={cy}
            anchor="start" bold color="var(--charcoal)" fontSize={11}>
            {fmtSigma(sigmaX)}
          </Label>

          {/* Left face */}
          <ForceArrow
            x1={sigmaX > 0 ? left - gap : left - gap - arrowLen}
            y1={cy}
            x2={sigmaX > 0 ? left - gap - arrowLen : left - gap}
            y2={cy}
            markerId="arrowStress" strokeWidth={2} />
          <Label x={left - gap - arrowLen - 8} y={cy}
            anchor="end" bold color="var(--charcoal)" fontSize={11}>
            {fmtSigma(sigmaX)}
          </Label>
        </>
      )}

      {/* σy arrows — vertical, pointing outward for tension, inward for compression */}
      {sigmaY !== 0 && (
        <>
          {/* Top face */}
          <ForceArrow
            x1={cx}
            y1={sigmaY > 0 ? top - gap : top - gap - arrowLen}
            x2={cx}
            y2={sigmaY > 0 ? top - gap - arrowLen : top - gap}
            markerId="arrowStress" strokeWidth={2} />
          <Label x={cx} y={top - gap - arrowLen - 10}
            bold color="var(--charcoal)" fontSize={11}>
            {fmtSigma(sigmaY)}
          </Label>

          {/* Bottom face */}
          <ForceArrow
            x1={cx}
            y1={sigmaY > 0 ? bottom + gap : bottom + gap + arrowLen}
            x2={cx}
            y2={sigmaY > 0 ? bottom + gap + arrowLen : bottom + gap}
            markerId="arrowStress" strokeWidth={2} />
          <Label x={cx} y={bottom + gap + arrowLen + 12}
            bold color="var(--charcoal)" fontSize={11}>
            {fmtSigma(sigmaY)}
          </Label>
        </>
      )}

      {/* τxy arrows — shear on each face, offset slightly from edges */}
      {hasShear && (
        <>
          {/* Right face — upward for positive τxy */}
          <ForceArrow
            x1={right + shearOff} y1={tauXY > 0 ? cy + arrowLen / 2 : cy - arrowLen / 2}
            x2={right + shearOff} y2={tauXY > 0 ? cy - arrowLen / 2 : cy + arrowLen / 2}
            color="var(--ember)" markerId="arrowShear" strokeWidth={1.5} />

          {/* Left face — downward for positive τxy */}
          <ForceArrow
            x1={left - shearOff} y1={tauXY > 0 ? cy - arrowLen / 2 : cy + arrowLen / 2}
            x2={left - shearOff} y2={tauXY > 0 ? cy + arrowLen / 2 : cy - arrowLen / 2}
            color="var(--ember)" markerId="arrowShear" strokeWidth={1.5} />

          {/* Top face — rightward for positive τxy */}
          <ForceArrow
            x1={tauXY > 0 ? cx - arrowLen / 2 : cx + arrowLen / 2} y1={top - shearOff}
            x2={tauXY > 0 ? cx + arrowLen / 2 : cx - arrowLen / 2} y2={top - shearOff}
            color="var(--ember)" markerId="arrowShear" strokeWidth={1.5} />

          {/* Bottom face — leftward for positive τxy */}
          <ForceArrow
            x1={tauXY > 0 ? cx + arrowLen / 2 : cx - arrowLen / 2} y1={bottom + shearOff}
            x2={tauXY > 0 ? cx - arrowLen / 2 : cx + arrowLen / 2} y2={bottom + shearOff}
            color="var(--ember)" markerId="arrowShear" strokeWidth={1.5} />

          {/* Shear label — top-right corner */}
          <Label x={right + 10} y={top - 12}
            anchor="start" italic color="var(--ember)" fontSize={11}>
            {'τ = '}{Math.abs(tauXY)}
          </Label>
        </>
      )}

      {/* Axis labels */}
      <Label x={right + gap + arrowLen + 8} y={cy + 14}
        anchor="start" italic color="var(--gray-400)" fontSize={10}>
        x
      </Label>
      <Label x={cx + 12} y={top - gap - arrowLen - 10}
        anchor="start" italic color="var(--gray-400)" fontSize={10}>
        y
      </Label>

      {/* Units note */}
      <Label x={cx} y={bottom + gap + arrowLen + 32}
        fontSize={9} color="var(--gray-400)">
        (MPa)
      </Label>
    </svg>
  );
}
