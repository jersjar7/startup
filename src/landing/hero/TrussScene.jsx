import React from 'react';
import { C, P, Member, Beam, Box, Node, Arrow } from './primitives';

// FE topic: Structural Analysis — a 3D Warren truss bridge with a roadway deck,
// abutments, and pin/roller supports (the boundary conditions a truss problem
// shows). `opacity` drives the cross-fade between topics.

function trussData() {
  const xs = [200, 350, 500, 650, 800, 1000];
  const top = [350, 500, 650, 800, 850];
  const dz = 0.9;
  const bottom = (z) => xs.map((x) => P(x, 500, z));
  const tops = (z) => top.map((x) => P(x, 320, z));
  const members = [];
  const nodes = [];
  for (const z of [dz, -dz]) {
    const b = bottom(z);
    const t = tops(z);
    for (let i = 0; i < b.length - 1; i++) members.push([b[i], b[i + 1]]);
    for (let i = 0; i < t.length - 1; i++) members.push([t[i], t[i + 1]]);
    members.push([b[0], t[0]], [b[1], t[0]], [b[1], t[1]], [b[2], t[1]], [b[2], t[2]], [b[3], t[2]], [b[3], t[3]], [b[4], t[3]], [b[4], t[4]], [b[5], t[4]]);
    nodes.push(...b, ...t);
  }
  const bF = bottom(dz), bB = bottom(-dz), tF = tops(dz), tB = tops(-dz);
  for (let i = 0; i < bF.length; i++) members.push([bF[i], bB[i]]);
  for (let i = 0; i < tF.length; i++) members.push([tF[i], tB[i]]);
  const arrows = [P(500, 320, dz), P(650, 320, dz), P(800, 320, dz)];
  const left = P(200, 500, 0);
  const right = P(1000, 500, 0);
  const deckY = P(200, 500, 0)[1];
  return { members, nodes, arrows, dz, left, right, deckY, spanX: [P(200, 500, 0)[0], P(1000, 500, 0)[0]] };
}

export function TrussScene({ opacity }) {
  const d = React.useMemo(() => trussData(), []);
  const [x0, x1] = d.spanX;
  const deckMid = (x0 + x1) / 2;
  return (
    <group>
      {d.members.map((m, i) => (
        <Member key={i} a={m[0]} b={m[1]} radius={0.055} color={C.steel} opacity={opacity} />
      ))}
      {d.nodes.map((n, i) => (
        <Node key={`n${i}`} p={n} r={0.1} color={C.forest} opacity={opacity} />
      ))}
      <Box position={[deckMid, d.deckY + 0.02, 0]} size={[x1 - x0, 0.06, 2 * d.dz]} color={C.steelLt} opacity={opacity} metalness={0.6} roughness={0.5} />
      {d.arrows.map((a, i) => (
        <Arrow key={`a${i}`} from={[a[0], a[1] + 0.95, a[2]]} to={[a[0], a[1] + 0.16, a[2]]} opacity={opacity} />
      ))}
      <Box position={[d.left[0], d.deckY - 0.34, 0]} size={[0.5, 0.4, 2 * d.dz + 0.3]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />
      <Box position={[d.right[0], d.deckY - 0.34, 0]} size={[0.5, 0.4, 2 * d.dz + 0.3]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />
      <mesh position={[d.left[0], d.deckY - 0.13, 0]} castShadow>
        <coneGeometry args={[0.16, 0.22, 4]} />
        <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.34} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <mesh position={[d.right[0], d.deckY - 0.1, 0]} castShadow>
        <coneGeometry args={[0.16, 0.18, 4]} />
        <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.34} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      {[-0.45, 0, 0.45].map((z, i) => (
        <mesh key={`r${i}`} position={[d.right[0], d.deckY - 0.21, z]} rotation={[0, 0, Math.PI / 2]} castShadow>
          <cylinderGeometry args={[0.05, 0.05, 0.18, 12]} />
          <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.3} transparent={opacity < 1} opacity={opacity} />
        </mesh>
      ))}
    </group>
  );
}
