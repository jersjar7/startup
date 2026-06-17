import React from 'react';
import { C, Beam, Box, Node, Arrow } from './primitives';

// FE topic: Transportation — an asphalt road deck over a crest vertical curve
// with edge lines, a dashed centerline, guardrails, earth side-slopes, a PVI
// marker, a sight-distance arrow, and a car cresting the curve. `opacity`
// cross-fades.

export function RoadScene({ opacity }) {
  const data = React.useMemo(() => {
    const N = 26;
    const x0 = -4.0, x1 = 4.0;
    const crest = (x) => 1.0 - 0.082 * x * x;
    const pts = [];
    for (let i = 0; i <= N; i++) {
      const x = x0 + ((x1 - x0) * i) / N;
      pts.push([x, crest(x), 0]);
    }
    const deck = [], stripe = [];
    for (let i = 0; i < pts.length - 1; i++) {
      deck.push([pts[i], pts[i + 1]]);
      if (i % 2 === 0) stripe.push([pts[i], pts[i + 1]]);
    }
    const posts = [];
    for (let i = 0; i <= N; i += 3) posts.push(pts[i]);
    return { pts, deck, stripe, posts, crest, apex: [0, crest(0), 0], x0, x1 };
  }, []);
  const halfW = 0.95;
  return (
    <group position={[0, -0.1, 0]}>
      {data.deck.map((s, i) => (
        <Beam key={`d${i}`} a={s[0]} b={s[1]} width={1.9} thickness={0.16} color={C.asphalt} opacity={opacity} metalness={0.2} roughness={0.8} />
      ))}
      {data.deck.map((s, i) => (
        <React.Fragment key={`e${i}`}>
          <Beam a={[s[0][0], s[0][1] + 0.09, halfW - 0.08]} b={[s[1][0], s[1][1] + 0.09, halfW - 0.08]} width={0.08} thickness={0.03} color={C.cream} opacity={opacity} metalness={0.1} roughness={0.7} />
          <Beam a={[s[0][0], s[0][1] + 0.09, -halfW + 0.08]} b={[s[1][0], s[1][1] + 0.09, -halfW + 0.08]} width={0.08} thickness={0.03} color={C.cream} opacity={opacity} metalness={0.1} roughness={0.7} />
        </React.Fragment>
      ))}
      {data.stripe.map((s, i) => (
        <Beam key={`s${i}`} a={[s[0][0], s[0][1] + 0.09, 0]} b={[s[1][0], s[1][1] + 0.09, 0]} width={0.12} thickness={0.03} color={C.sunbeam} opacity={opacity} metalness={0.3} roughness={0.5} />
      ))}
      {data.posts.map((p, i) => (
        <React.Fragment key={`p${i}`}>
          <Box position={[p[0], p[1] + 0.18, halfW]} size={[0.05, 0.34, 0.05]} color={C.steelLt} opacity={opacity} />
          <Box position={[p[0], p[1] + 0.18, -halfW]} size={[0.05, 0.34, 0.05]} color={C.steelLt} opacity={opacity} />
        </React.Fragment>
      ))}
      {data.deck.map((s, i) => (
        <React.Fragment key={`g${i}`}>
          <Beam a={[s[0][0], s[0][1] + 0.32, halfW]} b={[s[1][0], s[1][1] + 0.32, halfW]} width={0.06} thickness={0.07} color={C.steel} opacity={opacity} />
          <Beam a={[s[0][0], s[0][1] + 0.32, -halfW]} b={[s[1][0], s[1][1] + 0.32, -halfW]} width={0.06} thickness={0.07} color={C.steel} opacity={opacity} />
        </React.Fragment>
      ))}
      <mesh position={[data.x0 + 0.2, data.crest(data.x0) - 0.7, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.9, 1.2, 2.1]} />
        <meshStandardMaterial color="#6f685d" metalness={0.1} roughness={0.95} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <mesh position={[data.x1 - 0.2, data.crest(data.x1) - 0.7, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.9, 1.2, 2.1]} />
        <meshStandardMaterial color="#6f685d" metalness={0.1} roughness={0.95} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <Node p={[data.apex[0], data.apex[1] + 0.16, 0]} r={0.1} color={C.sunbeam} emissive={C.sunbeam} opacity={opacity} />
      <Arrow from={[-2.3, 1.5, 0]} to={[2.3, 1.5, 0]} opacity={opacity} />
      <group position={[0.7, data.crest(0.7) + 0.2, 0]}>
        <Box position={[0, 0, 0]} size={[0.7, 0.18, 0.5]} color={C.ember} opacity={opacity} metalness={0.4} roughness={0.4} />
        <Box position={[-0.03, 0.16, 0]} size={[0.36, 0.18, 0.42]} color={C.ember} opacity={opacity} metalness={0.4} roughness={0.4} />
        {[[0.22, -0.1, 0.26], [0.22, -0.1, -0.26], [-0.24, -0.1, 0.26], [-0.24, -0.1, -0.26]].map((w, i) => (
          <mesh key={i} position={w} rotation={[Math.PI / 2, 0, 0]} castShadow>
            <cylinderGeometry args={[0.1, 0.1, 0.07, 14]} />
            <meshStandardMaterial color="#1f1f1f" metalness={0.3} roughness={0.6} transparent={opacity < 1} opacity={opacity} />
          </mesh>
        ))}
      </group>
    </group>
  );
}
