import React from 'react';
import { C, Beam, Box, Node, Arrow } from './primitives';

// FE topic: Transportation — a roadway carried over an earth CREST VERTICAL
// CURVE. The asphalt deck rides a parabolic crest seated into continuous
// embankment side-slopes (not a bridge span). The defining geometry is made
// explicit: the two entry/exit grade tangents meeting at the PVI (high point),
// a staked PVI marker, and a low eye-height sight-distance line that grazes the
// crest and breaks at the apex (line of sight obstructed over the hill).
// `opacity` cross-fades every material.

// Brand muted-earth grays for the embankment.
const SOIL = '#8a7c68';
const SOIL_DK = '#6f6253';

export function RoadScene({ opacity }) {
  const data = React.useMemo(() => {
    const N = 40;
    const x0 = -4.0, x1 = 4.0;
    const crest = (x) => 1.0 - 0.082 * x * x;
    const dcrest = (x) => -2 * 0.082 * x; // slope of the profile (grade)
    const pts = [];
    for (let i = 0; i <= N; i++) {
      const x = x0 + ((x1 - x0) * i) / N;
      pts.push([x, crest(x), 0]);
    }
    const deck = [], stripe = [];
    for (let i = 0; i < pts.length - 1; i++) {
      deck.push([pts[i], pts[i + 1]]);
      // shorter on/off duty cycle: one short dash every other segment
      if (i % 2 === 0) stripe.push([pts[i], pts[i + 1]]);
    }
    const posts = [];
    for (let i = 0; i <= N; i += 4) posts.push(pts[i]);
    return { pts, deck, stripe, posts, crest, dcrest, apex: [0, crest(0), 0], x0, x1 };
  }, []);
  const halfW = 0.95;
  const groundY = -1.55; // flat groundline the embankment meets

  // A trapezoidal embankment slab under a deck segment, running down to grade.
  const Embankment = ({ s, zSign }) => {
    const xa = s[0][0], xb = s[1][0];
    const xm = (xa + xb) / 2;
    const topY = (s[0][1] + s[1][1]) / 2;
    const h = topY - groundY;
    const cy = (topY + groundY) / 2;
    const len = Math.abs(xb - xa) + 0.06; // slight overlap to hide seams
    return (
      <mesh position={[xm, cy, zSign * (halfW - 0.18)]} castShadow receiveShadow>
        <boxGeometry args={[len, h, 0.42]} />
        <meshStandardMaterial color={SOIL} metalness={0.05} roughness={0.96} transparent={opacity < 1} opacity={opacity} />
      </mesh>
    );
  };

  // Sight-line eye height above pavement and the two broken segments.
  const eye = 0.34;
  const dx = 2.6;
  const slEntry = { from: [-dx, data.crest(-dx) + eye, 0], to: [-0.15, data.apex[1] + eye - 0.04, 0] };
  const slExit = { from: [0.15, data.apex[1] + eye - 0.04, 0], to: [dx, data.crest(dx) + eye, 0] };

  // Tangent guide lines (entry/exit grades) extended to meet at the PVI.
  const tanLen = 2.3;
  const slopeL = data.dcrest(-1.6), slopeR = data.dcrest(1.6);
  const pviY = data.apex[1] + 0.22;
  const tanL = { a: [-tanLen, pviY - slopeL * tanLen, 0], b: [0, pviY, 0] };
  const tanR = { a: [0, pviY, 0], b: [tanLen, pviY - slopeR * tanLen, 0] };

  return (
    <group position={[0, -0.1, 0]}>
      {/* Continuous earth embankment under the road (reads as a hill, not a span) */}
      {data.deck.map((s, i) => (
        <React.Fragment key={`emb${i}`}>
          <Embankment s={s} zSign={1} />
          <Embankment s={s} zSign={-1} />
        </React.Fragment>
      ))}
      {/* Embankment crown core directly beneath the centerline */}
      {data.deck.map((s, i) => {
        const xm = (s[0][0] + s[1][0]) / 2;
        const topY = (s[0][1] + s[1][1]) / 2;
        const h = topY - groundY;
        return (
          <mesh key={`core${i}`} position={[xm, (topY + groundY) / 2, 0]} receiveShadow>
            <boxGeometry args={[Math.abs(s[1][0] - s[0][0]) + 0.06, h, 2 * halfW]} />
            <meshStandardMaterial color={SOIL_DK} metalness={0.05} roughness={0.98} transparent={opacity < 1} opacity={opacity} />
          </mesh>
        );
      })}

      {/* Asphalt deck (smoothed, N=40) */}
      {data.deck.map((s, i) => (
        <Beam key={`d${i}`} a={s[0]} b={s[1]} width={1.9} thickness={0.16} color={C.asphalt} opacity={opacity} metalness={0.2} roughness={0.8} />
      ))}

      {/* Edge lines */}
      {data.deck.map((s, i) => (
        <React.Fragment key={`e${i}`}>
          <Beam a={[s[0][0], s[0][1] + 0.085, halfW - 0.08]} b={[s[1][0], s[1][1] + 0.085, halfW - 0.08]} width={0.07} thickness={0.02} color={C.cream} opacity={opacity} metalness={0.05} roughness={0.8} />
          <Beam a={[s[0][0], s[0][1] + 0.085, -halfW + 0.08]} b={[s[1][0], s[1][1] + 0.085, -halfW + 0.08]} width={0.07} thickness={0.02} color={C.cream} opacity={opacity} metalness={0.05} roughness={0.8} />
        </React.Fragment>
      ))}

      {/* Centerline: short, thin, matte dashes flush to the asphalt */}
      {data.stripe.map((s, i) => {
        const t = 0.55; // 0.55 dash within each ~0.2-unit segment -> short duty cycle
        const ax = s[0][0], bx = s[1][0];
        const ay = s[0][1], by = s[1][1];
        const mx0 = ax + (bx - ax) * (0.5 - t / 2), my0 = ay + (by - ay) * (0.5 - t / 2);
        const mx1 = ax + (bx - ax) * (0.5 + t / 2), my1 = ay + (by - ay) * (0.5 + t / 2);
        return (
          <Beam key={`s${i}`} a={[mx0, my0 + 0.087, 0]} b={[mx1, my1 + 0.087, 0]} width={0.09} thickness={0.015} color={C.sunbeam} opacity={opacity} metalness={0.05} roughness={0.85} />
        );
      })}

      {/* Double-rail steel guardrail standing off the deck edge */}
      {data.posts.map((p, i) => (
        <React.Fragment key={`p${i}`}>
          <Box position={[p[0], p[1] + 0.2, halfW]} size={[0.05, 0.4, 0.05]} color={C.steelLt} opacity={opacity} />
          <Box position={[p[0], p[1] + 0.2, -halfW]} size={[0.05, 0.4, 0.05]} color={C.steelLt} opacity={opacity} />
        </React.Fragment>
      ))}
      {data.deck.map((s, i) => (
        <React.Fragment key={`g${i}`}>
          <Beam a={[s[0][0], s[0][1] + 0.39, halfW]} b={[s[1][0], s[1][1] + 0.39, halfW]} width={0.06} thickness={0.07} color={C.steel} opacity={opacity} />
          <Beam a={[s[0][0], s[0][1] + 0.39, -halfW]} b={[s[1][0], s[1][1] + 0.39, -halfW]} width={0.06} thickness={0.07} color={C.steel} opacity={opacity} />
          <Beam a={[s[0][0], s[0][1] + 0.26, halfW]} b={[s[1][0], s[1][1] + 0.26, halfW]} width={0.05} thickness={0.05} color={C.steelLt} opacity={opacity} />
          <Beam a={[s[0][0], s[0][1] + 0.26, -halfW]} b={[s[1][0], s[1][1] + 0.26, -halfW]} width={0.05} thickness={0.05} color={C.steelLt} opacity={opacity} />
        </React.Fragment>
      ))}

      {/* PVI geometry: two grade tangents meeting at the high point */}
      <Beam a={tanL.a} b={tanL.b} width={0.025} thickness={0.025} color={C.sunbeam} opacity={opacity} metalness={0.1} roughness={0.6} />
      <Beam a={tanR.a} b={tanR.b} width={0.025} thickness={0.025} color={C.sunbeam} opacity={opacity} metalness={0.1} roughness={0.6} />
      {/* Vertical stake from deck up to the PVI marker */}
      <Box position={[0, (data.apex[1] + 0.085 + pviY) / 2, 0]} size={[0.025, pviY - (data.apex[1] + 0.085), 0.025]} color={C.sunbeam} opacity={opacity} metalness={0.1} roughness={0.6} />
      <Node p={[0, pviY, 0]} r={0.15} color={C.sunbeam} emissive={C.sunbeam} opacity={opacity} />

      {/* Sight-distance: low eye-height line over the crest, broken at the apex */}
      <Arrow from={slEntry.from} to={slEntry.to} radius={0.03} opacity={opacity} />
      <Arrow from={slExit.from} to={slExit.to} radius={0.03} opacity={opacity} />

      {/* Small passenger car, within one lane, cresting the curve */}
      <group position={[0.7, data.crest(0.7) + 0.18, 0]}>
        {/* lower body */}
        <Box position={[0, 0, 0]} size={[0.66, 0.14, 0.42]} color={C.ember} opacity={opacity} metalness={0.45} roughness={0.38} />
        {/* raked cabin (shorter at front) */}
        <Box position={[-0.05, 0.14, 0]} size={[0.34, 0.15, 0.36]} color={C.ember} opacity={opacity} metalness={0.45} roughness={0.38} />
        {/* windshield strip (info-blue glass) */}
        <Box position={[0.13, 0.14, 0]} size={[0.04, 0.12, 0.34]} rotation={[0, 0, -0.5]} color={C.info} opacity={opacity} metalness={0.3} roughness={0.25} />
        {/* dark side window insets */}
        <Box position={[-0.05, 0.15, 0.185]} size={[0.26, 0.1, 0.01]} color="#1c1c1c" opacity={opacity} metalness={0.4} roughness={0.3} />
        <Box position={[-0.05, 0.15, -0.185]} size={[0.26, 0.1, 0.01]} color="#1c1c1c" opacity={opacity} metalness={0.4} roughness={0.3} />
        {/* wheels tucked under the body, with steel hubs */}
        {[[0.22, 0.21], [0.22, -0.21], [-0.24, 0.21], [-0.24, -0.21]].map((w, i) => (
          <group key={i} position={[w[0], -0.09, w[1]]} rotation={[Math.PI / 2, 0, 0]}>
            <mesh castShadow>
              <cylinderGeometry args={[0.085, 0.085, 0.06, 16]} />
              <meshStandardMaterial color="#1b1b1b" metalness={0.2} roughness={0.7} transparent={opacity < 1} opacity={opacity} />
            </mesh>
            <mesh position={[0, w[1] > 0 ? 0.031 : -0.031, 0]}>
              <cylinderGeometry args={[0.04, 0.04, 0.006, 14]} />
              <meshStandardMaterial color={C.steelLt} metalness={0.8} roughness={0.35} transparent={opacity < 1} opacity={opacity} />
            </mesh>
          </group>
        ))}
      </group>
    </group>
  );
}
