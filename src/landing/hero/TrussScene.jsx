import React from 'react';
import { useFrame } from '@react-three/fiber';
import { RoundedBox } from '@react-three/drei';
import * as THREE from 'three';
import { C, P, Member, Box, Node, Person } from './primitives';

// FE topic: Structural Analysis — a 3D Warren/Pratt through-truss bridge with a
// roadway deck, abutments, and the two boundary conditions a truss problem
// hinges on: a PINNED support (left) and a ROLLER support (right). The live load
// is literal: cars cross the deck while a river flows underneath, across the
// span. `opacity` drives the cross-fade between hero topics.

const NODE = '#2f6f59';
const DECK = '#7c746a'; // muted earth gray asphalt/concrete

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
    for (let i = 0; i < b.length - 1; i++) members.push({ a: b[i], b: b[i + 1], chord: true });
    for (let i = 0; i < t.length - 1; i++) members.push({ a: t[i], b: t[i + 1], chord: true });
    const web = [[b[0], t[0]], [b[1], t[0]], [b[1], t[1]], [b[2], t[1]], [b[2], t[2]], [b[3], t[2]], [b[3], t[3]], [b[4], t[3]], [b[4], t[4]], [b[5], t[4]]];
    for (const [a, c] of web) members.push({ a, b: c, chord: false });
    nodes.push(...b, ...t);
  }
  const bF = bottom(dz), bB = bottom(-dz), tF = tops(dz), tB = tops(-dz);
  for (let i = 0; i < bF.length; i++) members.push({ a: bF[i], b: bB[i], chord: false });
  for (let i = 0; i < tF.length; i++) members.push({ a: tF[i], b: tB[i], chord: false });
  const bracing = [];
  for (let i = 0; i < tF.length - 1; i++) {
    bracing.push({ a: tF[i], b: tB[i + 1], chord: false });
    bracing.push({ a: tB[i], b: tF[i + 1], chord: false });
  }
  bracing.push({ a: tF[0], b: bB[0], chord: false }, { a: tB[0], b: bF[0], chord: false });
  bracing.push({ a: tF[4], b: bB[5], chord: false }, { a: tB[4], b: bF[5], chord: false });

  const left = P(200, 500, 0);
  const right = P(1000, 500, 0);
  const deckY = left[1];
  return { members, bracing, nodes, dz, left, right, deckY, spanX: [left[0], right[0]], bottomFront: bF };
}

function PinSupport({ x, y, dz, opacity }) {
  const shoeTop = y - 0.34;
  const mat = (color, metalness, roughness) => (
    <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
  );
  return (
    <group position={[x, 0, 0]}>
      <mesh position={[0, shoeTop, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.46, 0.16, 2 * dz + 0.26]} />
        {mat(C.charcoal, 0.2, 0.7)}
      </mesh>
      <mesh position={[0, shoeTop + 0.27, 0]} rotation={[0, Math.PI / 4, 0]} castShadow>
        <coneGeometry args={[0.27, 0.4, 4]} />
        {mat(C.steel, 0.9, 0.34)}
      </mesh>
      <mesh position={[0, shoeTop + 0.42, 0]} rotation={[Math.PI / 2, 0, 0]} castShadow>
        <cylinderGeometry args={[0.075, 0.075, 2 * dz + 0.1, 16]} />
        {mat(C.steelLt, 0.95, 0.28)}
      </mesh>
    </group>
  );
}

function RollerSupport({ x, y, dz, opacity }) {
  const baseTop = y - 0.34;
  const mat = (color, metalness, roughness) => (
    <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
  );
  const rollerR = 0.085;
  return (
    <group position={[x, 0, 0]}>
      <mesh position={[0, baseTop, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.5, 0.12, 2 * dz + 0.26]} />
        {mat(C.charcoal, 0.2, 0.7)}
      </mesh>
      {[-0.15, 0, 0.15].map((ox, i) => (
        <mesh key={`roll${i}`} position={[ox, baseTop + 0.12 + rollerR, 0]} rotation={[Math.PI / 2, 0, 0]} castShadow>
          <cylinderGeometry args={[rollerR, rollerR, 2 * dz + 0.1, 18]} />
          {mat(C.steelLt, 0.95, 0.26)}
        </mesh>
      ))}
      <mesh position={[0, baseTop + 0.12 + 2 * rollerR + 0.05, 0]} castShadow>
        <boxGeometry args={[0.5, 0.1, 2 * dz + 0.2]} />
        {mat(C.steel, 0.9, 0.32)}
      </mesh>
    </group>
  );
}

// The literal live load looping across the deck. Rounded body (RoundedBox) with
// a stepped greenhouse, a windshield + rear window + side windows, so it reads
// as a real car, not a box. Wheels are wrapped in a spin group whose axle is
// along Z (the car's width): rolling = rotating that group about Z, so the tyres
// turn toward the direction of travel at a speed matched to the body's motion.
// `dir` = +1 (left->right) or -1; `kind` = 'sedan' | 'truck'.
function Vehicle({ x0, x1, deckTopY, z, dir, kind, bodyColor, speed, phase, opacity }) {
  const group = React.useRef();
  const wheels = React.useRef([]);
  // Travel a good way past each abutment so the car drives onto the approach
  // roadway (which extends beyond the bridge) rather than off the deck edge.
  const margin = 1.2;
  const lo = x0 - margin;
  const span = (x1 + margin) - lo;
  const mat = (color, metalness, roughness) => (
    <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
  );
  const glass = (color) => (
    <meshStandardMaterial color={color} metalness={0.6} roughness={0.12} transparent opacity={opacity * 0.9} />
  );
  const wheelR = 0.1;
  const bodyY = wheelR + 0.07;
  const halfL = 0.55;
  const bodyW = 0.42;
  const isTruck = kind === 'truck';
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const g = group.current;
    if (!g) return;
    let u = ((t * speed + phase) % 1 + 1) % 1;
    if (dir < 0) u = 1 - u;
    g.position.set(lo + u * span, deckTopY, z);
    g.rotation.y = dir > 0 ? 0 : Math.PI;
    // Roll the wheels about their Z axle, matched to linear travel speed so they
    // turn in the direction the car is moving (negative = forward roll).
    const spin = -t * speed * span / wheelR;
    for (const w of wheels.current) if (w) w.rotation.z = spin;
  });
  const wheelPos = [[halfL - 0.2, 0.205], [halfL - 0.2, -0.205], [-halfL + 0.2, 0.205], [-halfL + 0.2, -0.205]];
  const greenhouseZ = bodyW - 0.05;
  return (
    <group ref={group}>
      {/* lower body — rounded */}
      <RoundedBox args={[2 * halfL, 0.2, bodyW]} radius={0.07} smoothness={3} position={[0, bodyY, 0]} castShadow>
        {mat(bodyColor, 0.5, 0.35)}
      </RoundedBox>
      {isTruck ? (
        <>
          {/* forward cab */}
          <RoundedBox args={[0.36, 0.4, bodyW - 0.01]} radius={0.06} smoothness={3} position={[halfL - 0.22, bodyY + 0.28, 0]} castShadow>
            {mat(bodyColor, 0.45, 0.4)}
          </RoundedBox>
          {/* cab windshield + side windows */}
          <mesh position={[halfL - 0.04, bodyY + 0.34, 0]} rotation={[0, 0, -0.34]}>
            <boxGeometry args={[0.04, 0.22, bodyW - 0.08]} />
            {glass('#bcd8e8')}
          </mesh>
          {[bodyW / 2 - 0.01, -bodyW / 2 + 0.01].map((zz, i) => (
            <mesh key={`tsw${i}`} position={[halfL - 0.22, bodyY + 0.3, zz]}>
              <boxGeometry args={[0.22, 0.18, 0.012]} />
              {glass('#a9cad8')}
            </mesh>
          ))}
          {/* flat bed + cargo */}
          <RoundedBox args={[0.6, 0.07, bodyW + 0.02]} radius={0.03} smoothness={2} position={[-0.18, bodyY + 0.13, 0]} castShadow>
            {mat('#4a4f52', 0.4, 0.5)}
          </RoundedBox>
          <RoundedBox args={[0.42, 0.3, bodyW - 0.04]} radius={0.04} smoothness={2} position={[-0.24, bodyY + 0.3, 0]} castShadow>
            {mat('#6a6f73', 0.4, 0.55)}
          </RoundedBox>
        </>
      ) : (
        <>
          {/* rounded hood */}
          <RoundedBox args={[0.3, 0.11, bodyW - 0.02]} radius={0.045} smoothness={3} position={[halfL - 0.07, bodyY + 0.11, 0]} castShadow>
            {mat(bodyColor, 0.5, 0.35)}
          </RoundedBox>
          {/* rounded greenhouse / cab */}
          <RoundedBox args={[0.6, 0.22, greenhouseZ]} radius={0.08} smoothness={4} position={[-0.07, bodyY + 0.22, 0]} castShadow>
            {mat(bodyColor, 0.45, 0.4)}
          </RoundedBox>
          {/* windshield */}
          <mesh position={[0.21, bodyY + 0.24, 0]} rotation={[0, 0, -0.52]}>
            <boxGeometry args={[0.04, 0.19, greenhouseZ - 0.04]} />
            {glass('#bcd8e8')}
          </mesh>
          {/* rear window */}
          <mesh position={[-0.36, bodyY + 0.23, 0]} rotation={[0, 0, 0.5]}>
            <boxGeometry args={[0.04, 0.17, greenhouseZ - 0.04]} />
            {glass('#9fc0d0')}
          </mesh>
          {/* side windows on both flanks */}
          {[greenhouseZ / 2, -greenhouseZ / 2].map((zz, i) => (
            <mesh key={`sw${i}`} position={[-0.06, bodyY + 0.25, zz]}>
              <boxGeometry args={[0.34, 0.13, 0.012]} />
              {glass('#a9cad8')}
            </mesh>
          ))}
        </>
      )}
      {/* headlights / taillights for travel direction */}
      {[0.16, -0.16].map((zz, i) => (
        <mesh key={`hl${i}`} position={[halfL + 0.04, bodyY, zz]}>
          <boxGeometry args={[0.04, 0.06, 0.07]} />
          {mat('#f3ead4', 0.2, 0.4)}
        </mesh>
      ))}
      {[0.16, -0.16].map((zz, i) => (
        <mesh key={`tl${i}`} position={[-halfL - 0.02, bodyY, zz]}>
          <boxGeometry args={[0.04, 0.06, 0.07]} />
          {mat(C.ember, 0.2, 0.4)}
        </mesh>
      ))}
      {/* wheels — each in a spin group whose axle is along Z (rolls toward travel) */}
      {wheelPos.map((w, i) => (
        <group key={`wh${i}`} ref={(el) => { wheels.current[i] = el; }} position={[w[0], wheelR, w[1]]}>
          <mesh rotation={[Math.PI / 2, 0, 0]} castShadow>
            <cylinderGeometry args={[wheelR, wheelR, 0.1, 18]} />
            {mat('#1c1b1a', 0.3, 0.7)}
          </mesh>
          {/* hubcap on the outboard face */}
          <mesh rotation={[Math.PI / 2, 0, 0]} position={[0, 0, w[1] > 0 ? 0.052 : -0.052]}>
            <cylinderGeometry args={[0.042, 0.042, 0.02, 12]} />
            {mat(C.steelLt, 0.85, 0.3)}
          </mesh>
        </group>
      ))}
    </group>
  );
}

// A faint water plane well below the deck. The river flows ACROSS and UNDER the
// bridge — i.e. along Z (perpendicular to the span), passing beneath the deck
// from one side to the other and out past both faces. Banks of green land sit at
// the two X ends (under the abutments). Debris + ripple streaks advect along +Z
// to read the current direction.
function WaterDatum({ midX, spanLen, y, opacity }) {
  const mesh = React.useRef();
  const debris = React.useRef();
  const ripples = React.useRef();
  const DEBRIS = 5;
  const RIPPLES = 3;
  const scratch = React.useMemo(() => ({ dummy: new THREE.Object3D() }), []);
  const channelW = spanLen + 0.4; // X extent (river width, spanned by the bridge)
  const riverLen = 5.2; // Z extent = the flow direction, runs past the deck
  const loZ = -riverLen / 2;
  // Each lane sits at a fixed X across the channel and drifts downstream (+Z).
  const lanes = React.useMemo(() => [
    { x: -channelW * 0.32, phase: 0.0, speed: 0.05 },
    { x: -channelW * 0.13, phase: 0.55, speed: 0.044 },
    { x: channelW * 0.04, phase: 0.2, speed: 0.056 },
    { x: channelW * 0.2, phase: 0.7, speed: 0.04 },
    { x: channelW * 0.34, phase: 0.42, speed: 0.06 },
  ], [channelW]);
  const rippleLanes = React.useMemo(() => [
    { x: -channelW * 0.22, phase: 0.3, speed: 0.07 },
    { x: channelW * 0.06, phase: 0.8, speed: 0.075 },
    { x: channelW * 0.28, phase: 0.05, speed: 0.065 },
  ], [channelW]);
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const m = mesh.current;
    if (m) m.material.opacity = opacity * (0.68 + Math.sin(t * 0.5) * 0.04);
    if (debris.current) {
      for (let i = 0; i < DEBRIS; i++) {
        const ln = lanes[i];
        const u = ((t * ln.speed + ln.phase) % 1 + 1) % 1;
        const { dummy } = scratch;
        dummy.position.set(midX + ln.x + Math.sin(t * 0.4 + i) * 0.08, 0.01, loZ + u * riverLen);
        dummy.rotation.set(0, t * 0.2 + i, 0);
        dummy.scale.set(1, 1, 1);
        dummy.updateMatrix();
        debris.current.setMatrixAt(i, dummy.matrix);
      }
      debris.current.instanceMatrix.needsUpdate = true;
    }
    if (ripples.current) {
      for (let i = 0; i < RIPPLES; i++) {
        const ln = rippleLanes[i];
        const u = ((t * ln.speed + ln.phase) % 1 + 1) % 1;
        const { dummy } = scratch;
        dummy.position.set(midX + ln.x, 0.005, loZ + u * riverLen);
        dummy.rotation.set(0, 0, 0);
        dummy.scale.set(1, 1, 1);
        dummy.updateMatrix();
        ripples.current.setMatrixAt(i, dummy.matrix);
      }
      ripples.current.instanceMatrix.needsUpdate = true;
    }
  });
  return (
    <group>
      <mesh ref={mesh} position={[midX, y, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
        <planeGeometry args={[channelW, riverLen, 1, 1]} />
        <meshStandardMaterial color={C.water} metalness={0.5} roughness={0.25} transparent opacity={opacity * 0.68} />
      </mesh>
      {/* debris specks drifting downstream (+Z), elongated along the flow */}
      <group position={[0, y + 0.02, 0]}>
        <instancedMesh ref={debris} args={[undefined, undefined, DEBRIS]}>
          <boxGeometry args={[0.07, 0.025, 0.22]} />
          <meshStandardMaterial color="#5a6b62" metalness={0.2} roughness={0.7} transparent opacity={opacity * 0.75} />
        </instancedMesh>
      </group>
      {/* faint ripple streaks elongated along Z (the current) */}
      <group position={[0, y + 0.012, 0]}>
        <instancedMesh ref={ripples} args={[undefined, undefined, RIPPLES]}>
          <boxGeometry args={[0.05, 0.006, 0.7]} />
          <meshStandardMaterial color="#7d97a0" metalness={0.4} roughness={0.4} transparent opacity={opacity * 0.4} />
        </instancedMesh>
      </group>
      {/* green banks at the two X ends (under the abutments), running along Z */}
      {[midX - channelW / 2 - 0.1, midX + channelW / 2 + 0.1].map((bx, i) => (
        <mesh key={`bank${i}`} position={[bx, y + 0.006, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
          <planeGeometry args={[0.9, riverLen + 0.8, 1, 1]} />
          <meshStandardMaterial color="#3f6048" metalness={0.05} roughness={0.92} transparent opacity={opacity * 0.8} />
        </mesh>
      ))}
    </group>
  );
}

// A lone pedestrian strolling the near fascia walkway — a slower, human scale of
// life beside the vehicle traffic. Walks the span and back (ping-pong).
function Pedestrian({ x0, x1, y, z, speed, opacity }) {
  const group = React.useRef();
  const margin = 0.3;
  const lo = x0 + margin;
  const span = (x1 - margin) - lo;
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const g = group.current;
    if (!g) return;
    const raw = ((t * speed) % 1 + 1) % 1;
    const tri = raw < 0.5 ? raw * 2 : 2 - raw * 2;
    g.position.x = lo + tri * span;
    g.position.y = y + Math.abs(Math.sin(t * 3.0)) * 0.012;
    g.position.z = z;
    g.rotation.y = raw < 0.5 ? Math.PI / 2 : -Math.PI / 2;
  });
  return (
    <group ref={group}>
      <Person scale={0.34} vest={C.sunbeam} hardHat={C.charcoal} armPose="down" opacity={opacity} />
    </group>
  );
}

export function TrussScene({ opacity }) {
  const d = React.useMemo(() => trussData(), []);
  const [x0, x1] = d.spanX;
  const deckMid = (x0 + x1) / 2;
  const spanLen = x1 - x0;
  const deckY = d.deckY + 0.04;
  const deckThick = 0.14;
  const fasciaZ = d.dz + 0.04;
  return (
    <group>
      {d.members.map((m, i) => (
        <Member key={i} a={m.a} b={m.b} radius={m.chord ? 0.09 : 0.062} color={C.steel} opacity={opacity} />
      ))}
      {d.bracing.map((m, i) => (
        <Member key={`br${i}`} a={m.a} b={m.b} radius={0.045} color={C.steelLt} opacity={opacity} />
      ))}
      {d.nodes.map((n, i) => (
        <Node key={`n${i}`} p={n} r={0.085} color={NODE} opacity={opacity} metalness={0.35} roughness={0.5} />
      ))}

      {/* Roadway deck */}
      <Box position={[deckMid, deckY, 0]} size={[spanLen, deckThick, 2 * d.dz]} color={DECK} opacity={opacity} metalness={0.05} roughness={0.85} />
      {[fasciaZ, -fasciaZ].map((z, i) => (
        <Box key={`fas${i}`} position={[deckMid, deckY - 0.02, z]} size={[spanLen, deckThick + 0.06, 0.07]} color={C.charcoal} opacity={opacity} metalness={0.25} roughness={0.6} />
      ))}
      {d.bottomFront.map((bf, i) => (
        <Member key={`fb${i}`} a={[bf[0], deckY - deckThick / 2 - 0.04, fasciaZ]} b={[bf[0], deckY - deckThick / 2 - 0.04, -fasciaZ]} radius={0.05} color={C.steel} opacity={opacity} />
      ))}

      {/* Approach roadway on each end: the asphalt continues past the abutments
          onto an earth embankment that carries it down to grade, so traffic
          stays on the road instead of floating off the deck once it leaves the
          truss. */}
      {[-1, 1].map((s) => {
        const end = s < 0 ? x0 : x1;
        const aLen = 1.6;
        const cx = end + (s * aLen) / 2;
        const groundY = d.deckY - 1.45;
        const top = deckY - deckThick / 2;
        const embH = top - groundY;
        return (
          <group key={`appr${s}`}>
            <Box position={[cx, deckY, 0]} size={[aLen, deckThick, 2 * d.dz]} color={DECK} opacity={opacity} metalness={0.05} roughness={0.85} />
            {[fasciaZ, -fasciaZ].map((z, i) => (
              <Box key={`af${i}`} position={[cx, deckY - 0.02, z]} size={[aLen, deckThick + 0.06, 0.07]} color={C.charcoal} opacity={opacity} metalness={0.25} roughness={0.6} />
            ))}
            <Box position={[cx, groundY + embH / 2, 0]} size={[aLen + 0.2, embH, 2 * d.dz + 0.34]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />
          </group>
        );
      })}

      {/* Live load: an ember sedan and a muted-steel truck crossing in opposite
          lanes, kept near the deck centerline so they clear the truss web. */}
      <Vehicle x0={x0} x1={x1} deckTopY={deckY + deckThick / 2} z={0.3} dir={1} kind="sedan" bodyColor={C.ember} speed={0.061} phase={0.78} opacity={opacity} />
      <Vehicle x0={x0} x1={x1} deckTopY={deckY + deckThick / 2} z={-0.3} dir={-1} kind="truck" bodyColor="#9aa0a4" speed={0.047} phase={0.74} opacity={opacity} />

      {/* Near-side walkway + curb, with a pedestrian strolling it */}
      <Box position={[deckMid, deckY + deckThick / 2 + 0.015, 0.72]} size={[spanLen, 0.05, 0.34]} color="#8a8278" opacity={opacity} metalness={0.05} roughness={0.9} />
      <Box position={[deckMid, deckY + deckThick / 2 + 0.05, 0.9]} size={[spanLen, 0.07, 0.04]} color={C.charcoal} opacity={opacity} metalness={0.2} roughness={0.7} />
      <Pedestrian x0={x0} x1={x1} y={deckY + deckThick / 2 + 0.04} z={0.72} speed={0.026} opacity={opacity} />

      {/* The river the bridge crosses — flows along Z, under and across the span */}
      <WaterDatum midX={deckMid} spanLen={spanLen} y={d.deckY - 1.45} opacity={opacity} />

      {/* Abutments + boundary conditions */}
      <Box position={[d.left[0], d.deckY - 0.62, 0]} size={[0.6, 0.5, 2 * d.dz + 0.34]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />
      <Box position={[d.right[0], d.deckY - 0.62, 0]} size={[0.6, 0.5, 2 * d.dz + 0.34]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />
      <PinSupport x={d.left[0]} y={d.deckY} dz={d.dz} opacity={opacity} />
      <RollerSupport x={d.right[0]} y={d.deckY} dz={d.dz} opacity={opacity} />
    </group>
  );
}
