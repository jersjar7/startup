import React from 'react';
import { Label } from './primitives';

/**
 * Beam deflection curve with inflection point where curvature changes direction.
 * Shows: horizontal reference line, curved deflection below, inflection marker, region labels.
 * Does NOT show: the x-value of the inflection point (that's the answer).
 */
export function BeamInflection({ length = 12 }) {
  const W = 360;
  const H = 200;
  const pad = 30;

  const beamX1 = pad + 20;
  const beamX2 = W - pad - 20;
  const beamW = beamX2 - beamX1;
  const refY = 70;          // undeflected reference line
  const maxDeflect = 50;    // max deflection below reference

  // Inflection at ~1/3 of the beam visually
  const inflectFrac = 0.33;
  const inflectX = beamX1 + beamW * inflectFrac;

  // Generate deflection curve points
  // Cubic shape: concave down on left, concave up on right of inflection
  const points = [];
  const N = 60;
  for (let i = 0; i <= N; i++) {
    const t = i / N;
    const x = beamX1 + t * beamW;
    // Normalized cubic: peaks near middle, changes curvature at inflectFrac
    const normalized = t * (1 - t);
    // Bias the curve to change concavity around inflectFrac
    const cubicBias = -Math.pow(t - inflectFrac, 3) * 8 + normalized;
    const deflection = Math.max(0, cubicBias * maxDeflect * 3);
    const y = refY + deflection;
    points.push(`${x.toFixed(1)},${y.toFixed(1)}`);
  }

  // Inflection point on the curve
  const inflectT = inflectFrac;
  const inflectNorm = inflectT * (1 - inflectT);
  const inflectCubic = -Math.pow(inflectT - inflectFrac, 3) * 8 + inflectNorm;
  const inflectY = refY + Math.max(0, inflectCubic * maxDeflect * 3);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Beam deflection curve with inflection point along ${length} m beam`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Undeflected reference line (dashed) */}
      <line x1={beamX1} y1={refY} x2={beamX2} y2={refY}
        stroke="var(--gray-400)" strokeWidth={1.5} strokeDasharray="6,4" />

      {/* Deflection curve */}
      <polyline points={points.join(' ')}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Inflection point marker */}
      <circle cx={inflectX} cy={inflectY} r={5}
        fill="var(--ember)" stroke="white" strokeWidth={2} />

      {/* Vertical dashed line at inflection */}
      <line x1={inflectX} y1={refY - 12} x2={inflectX} y2={inflectY + 30}
        stroke="var(--ember)" strokeWidth={1} strokeDasharray="3,3" />

      {/* Region labels */}
      <Label x={beamX1 + (inflectX - beamX1) / 2} y={H - pad - 10}
        fontSize={10} color="var(--gray-500)" italic>
        concave down
      </Label>
      <Label x={inflectX + (beamX2 - inflectX) / 2} y={H - pad - 10}
        fontSize={10} color="var(--gray-500)" italic>
        concave up
      </Label>

      {/* Inflection label */}
      <Label x={inflectX} y={refY - 22} fontSize={10} color="var(--ember)" bold>
        inflection point
      </Label>

      {/* Support dots at beam ends */}
      <circle cx={beamX1} cy={refY} r={3} fill="var(--charcoal)" />
      <circle cx={beamX2} cy={refY} r={3} fill="var(--charcoal)" />

      {/* Beam length label */}
      <Label x={(beamX1 + beamX2) / 2} y={refY - 12} fontSize={10} color="var(--gray-400)">
        {length} m
      </Label>
    </svg>
  );
}
