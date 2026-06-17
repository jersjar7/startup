import React from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { C, P, Member, Box, Node } from './primitives';

// FE topic: Structural Analysis — a 3D Warren/Pratt through-truss bridge with a
// roadway deck, abutments, and the two boundary conditions a truss problem
// hinges on: a PINNED support (left) and a ROLLER support (right). `opacity`
// drives the cross-fade between hero topics, so every material honors it.

// Slightly desaturated forest node; the ember accent now lives on the crossing
// vehicle (the literal live load) and small details rather than diagram arrows.
const NODE = '#2f6f59';
const DECK = '#7c746a'; // muted earth gray asphalt/concrete, not brushed steel

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
  // Transverse cross members tying the two truss planes (top + bottom chords).
  for (let i = 0; i < bF.length; i++) members.push({ a: bF[i], b: bB[i], chord: false });
  for (let i = 0; i < tF.length; i++) members.push({ a: tF[i], b: tB[i], chord: false });
  // Top-plane X-bracing across each panel — reinforces the 3D through-truss read.
  const bracing = [];
  for (let i = 0; i < tF.length - 1; i++) {
    bracing.push({ a: tF[i], b: tB[i + 1], chord: false });
    bracing.push({ a: tB[i], b: tF[i + 1], chord: false });
  }
  // End portal frames (diagonal knee braces at each end of the through-truss).
  bracing.push({ a: tF[0], b: bB[0], chord: false }, { a: tB[0], b: bF[0], chord: false });
  bracing.push({ a: tF[4], b: bB[5], chord: false }, { a: tB[4], b: bF[5], chord: false });

  const left = P(200, 500, 0);
  const right = P(1000, 500, 0);
  const deckY = left[1];
  return {
    members, bracing, nodes, dz, left, right, deckY,
    spanX: [left[0], right[0]],
    bottomFront: bF, bottomBack: bB,
  };
}

// PINNED support: charcoal shoe + a steel hinge pin (cylinder across Z) seated
// in a downward triangular bracket. Reads as a fixed pin in silhouette.
function PinSupport({ x, y, dz, opacity }) {
  const shoeTop = y - 0.34;
  const mat = (color, metalness, roughness) => (
    <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
  );
  return (
    <group position={[x, 0, 0]}>
      {/* charcoal base shoe sitting on the abutment */}
      <mesh position={[0, shoeTop, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.46, 0.16, 2 * dz + 0.26]} />
        {mat(C.charcoal, 0.2, 0.7)}
      </mesh>
      {/* triangular bracket, apex up toward the chord (the pinned wedge) */}
      <mesh position={[0, shoeTop + 0.27, 0]} rotation={[0, Math.PI / 4, 0]} castShadow>
        <coneGeometry args={[0.27, 0.4, 4]} />
        {mat(C.steel, 0.9, 0.34)}
      </mesh>
      {/* hinge pin through the apex, axis across Z */}
      <mesh position={[0, shoeTop + 0.42, 0]} rotation={[Math.PI / 2, 0, 0]} castShadow>
        <cylinderGeometry args={[0.075, 0.075, 2 * dz + 0.1, 16]} />
        {mat(C.steelLt, 0.95, 0.28)}
      </mesh>
    </group>
  );
}

// ROLLER support: charcoal channel baseplate carrying three steel rollers
// (axes across Z) under a top plate — the classic roller boundary condition.
function RollerSupport({ x, y, dz, opacity }) {
  const baseTop = y - 0.34;
  const mat = (color, metalness, roughness) => (
    <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
  );
  const rollerR = 0.085;
  return (
    <group position={[x, 0, 0]}>
      {/* charcoal channel baseplate */}
      <mesh position={[0, baseTop, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.5, 0.12, 2 * dz + 0.26]} />
        {mat(C.charcoal, 0.2, 0.7)}
      </mesh>
      {/* three rollers seated in the channel */}
      {[-0.15, 0, 0.15].map((ox, i) => (
        <mesh key={`roll${i}`} position={[ox, baseTop + 0.12 + rollerR, 0]} rotation={[Math.PI / 2, 0, 0]} castShadow>
          <cylinderGeometry args={[rollerR, rollerR, 2 * dz + 0.1, 18]} />
          {mat(C.steelLt, 0.95, 0.26)}
        </mesh>
      ))}
      {/* top bearing plate resting on the rollers, carrying the chord */}
      <mesh position={[0, baseTop + 0.12 + 2 * rollerR + 0.05, 0]} castShadow>
        <boxGeometry args={[0.5, 0.1, 2 * dz + 0.2]} />
        {mat(C.steel, 0.9, 0.32)}
      </mesh>
    </group>
  );
}

// A small box-body vehicle (the literal live load) that loops across the deck
// centerline. Wheels spin; body color is ember for the lead car, muted steel
// for the opposing one. `dir` = +1 (left->right) or -1; faces travel direction.
function Vehicle({ x0, x1, deckTopY, z, dir, bodyColor, speed, phase, opacity }) {
  const group = React.useRef();
  const wheels = React.useRef([]);
  // Travel range with a small offscreen margin so entry/exit is seamless.
  const margin = 1.1;
  const lo = x0 - margin;
  const span = (x1 + margin) - lo;
  const mat = (color, metalness, roughness) => (
    <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
  );
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const g = group.current;
    if (!g) return;
    // Normalized progress 0..1, wrapped; flip travel by dir.
    let u = ((t * speed + phase) % 1 + 1) % 1;
    if (dir < 0) u = 1 - u;
    g.position.x = lo + u * span;
    g.position.y = deckTopY;
    g.position.z = z;
    g.rotation.y = dir > 0 ? 0 : Math.PI;
    const spin = -t * speed * span * 1.4;
    for (const w of wheels.current) if (w) w.rotation.z = spin;
  });
  const wheelR = 0.07;
  const bodyY = wheelR + 0.085;
  // Longer + narrower than before so the silhouette reads unmistakably as a
  // car from the 3/4 hero angle rather than a colored cube.
  const halfL = 0.42; // half body length (X)
  return (
    <group ref={group}>
      {/* lower body — long, low, narrow */}
      <mesh position={[0, bodyY, 0]} castShadow>
        <boxGeometry args={[2 * halfL, 0.15, 0.34]} />
        {mat(bodyColor, 0.5, 0.35)}
      </mesh>
      {/* sloped hood front — small wedge so the nose is clearly the front */}
      <mesh position={[halfL - 0.02, bodyY + 0.085, 0]} castShadow>
        <boxGeometry args={[0.18, 0.06, 0.33]} />
        {mat(bodyColor, 0.5, 0.35)}
      </mesh>
      {/* cab / greenhouse, set toward the rear, narrower than the body */}
      <mesh position={[-0.08, bodyY + 0.13, 0]} castShadow>
        <boxGeometry args={[0.4, 0.13, 0.3]} />
        {mat(bodyColor, 0.45, 0.4)}
      </mesh>
      {/* windshield — bright info-blue glint angled at the front of the cab,
          high contrast so the cab read pops at tile scale */}
      <mesh position={[0.11, bodyY + 0.14, 0]} rotation={[0, 0, -0.5]} castShadow>
        <boxGeometry args={[0.035, 0.13, 0.27]} />
        {mat('#aaccdd', 0.6, 0.15)}
      </mesh>
      {/* rear window glint */}
      <mesh position={[-0.27, bodyY + 0.135, 0]} rotation={[0, 0, 0.45]}>
        <boxGeometry args={[0.03, 0.11, 0.27]} />
        {mat('#8fb0c2', 0.6, 0.18)}
      </mesh>
      {/* headlights — pale glints at the nose for front/back legibility */}
      {[0.13, -0.13].map((z, i) => (
        <mesh key={`hl${i}`} position={[halfL + 0.04, bodyY, z]}>
          <boxGeometry args={[0.03, 0.05, 0.06]} />
          {mat('#f3ead4', 0.2, 0.4)}
        </mesh>
      ))}
      {/* taillights — small ember glints at the rear */}
      {[0.13, -0.13].map((z, i) => (
        <mesh key={`tl${i}`} position={[-halfL - 0.02, bodyY, z]}>
          <boxGeometry args={[0.03, 0.05, 0.06]} />
          {mat(C.ember, 0.2, 0.4)}
        </mesh>
      ))}
      {/* four wheels */}
      {[[0.26, 0.18], [0.26, -0.18], [-0.26, 0.18], [-0.26, -0.18]].map((w, i) => (
        <mesh
          key={`wh${i}`}
          ref={(el) => { wheels.current[i] = el; }}
          position={[w[0], wheelR, w[1]]}
          rotation={[Math.PI / 2, 0, 0]}
          castShadow
        >
          <cylinderGeometry args={[wheelR, wheelR, 0.07, 14]} />
          {mat('#22211f', 0.3, 0.7)}
        </mesh>
      ))}
    </group>
  );
}

// A small flock of instanced birds drifting across the sky on a slow looping
// path, per-index phase. Each bird now has a slim charcoal BODY between two
// wings so it reads as a recognizable gliding silhouette, not a stray speck.
// Flap amplitude is damped (~0.4 rad) and phase-staggered so they don't beat
// in unison. The flock skims just above the top chord rather than floating in
// empty space.
function BirdFlock({ x0, x1, topY, opacity }) {
  const COUNT = 4;
  const left = React.useRef();
  const right = React.useRef();
  const body = React.useRef();
  // Allocate scratch object once — no per-frame allocation.
  const scratch = React.useMemo(() => ({ dummy: new THREE.Object3D() }), []);
  const lo = x0 - 1.4;
  const span = (x1 + 1.4) - lo;
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (!left.current || !right.current || !body.current) return;
    for (let i = 0; i < COUNT; i++) {
      const phase = i / COUNT;
      const u = ((t * 0.045 + phase) % 1 + 1) % 1;
      const px = lo + u * span;
      // Skim just above the top chord; gentle bob, slight per-index lift.
      const py = topY + Math.sin(t * 0.6 + i * 1.7) * 0.12 + i * 0.07;
      const pz = -0.55 + i * 0.42 + Math.sin(t * 0.3 + i) * 0.2;
      // Damped flap, staggered phase so the four don't beat together.
      const flap = 0.18 + Math.sin(t * 5.2 + i * 1.9) * 0.34;
      const { dummy } = scratch;
      // Slim body between the wings (long axis along travel = X).
      dummy.position.set(px, py, pz);
      dummy.rotation.set(0, 0, 0);
      dummy.scale.set(1, 1, 1);
      dummy.updateMatrix();
      body.current.setMatrixAt(i, dummy.matrix);
      // Left wing — swept back along -Z, flaps up about the body line.
      dummy.position.set(px, py + 0.01, pz - 0.085);
      dummy.rotation.set(flap, 0, 0);
      dummy.updateMatrix();
      left.current.setMatrixAt(i, dummy.matrix);
      // Right wing — mirrored.
      dummy.position.set(px, py + 0.01, pz + 0.085);
      dummy.rotation.set(-flap, 0, 0);
      dummy.updateMatrix();
      right.current.setMatrixAt(i, dummy.matrix);
    }
    body.current.instanceMatrix.needsUpdate = true;
    left.current.instanceMatrix.needsUpdate = true;
    right.current.instanceMatrix.needsUpdate = true;
  });
  return (
    <group>
      {/* slim charcoal body */}
      <instancedMesh ref={body} args={[undefined, undefined, COUNT]}>
        <capsuleGeometry args={[0.022, 0.11, 3, 6]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} transparent={opacity < 1} opacity={opacity} />
      </instancedMesh>
      <instancedMesh ref={left} args={[undefined, undefined, COUNT]}>
        <boxGeometry args={[0.06, 0.012, 0.15]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} transparent={opacity < 1} opacity={opacity} />
      </instancedMesh>
      <instancedMesh ref={right} args={[undefined, undefined, COUNT]}>
        <boxGeometry args={[0.06, 0.012, 0.15]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} transparent={opacity < 1} opacity={opacity} />
      </instancedMesh>
    </group>
  );
}

// A pair of slack utility/stay lines running just above the top chord. Each is
// an open lathe-free catenary approximated by a thin cylinder whose sag is
// driven by a tiny useFrame sine — non-rigid ambient life. Built once from a
// CatmullRom tube so we only animate a single group's Y bob (cheap, seamless).
function StayLines({ x0, x1, y, dz, opacity }) {
  const group = React.useRef();
  const geom = React.useMemo(() => {
    const mk = (zOff, sag) => {
      const pts = [];
      const segs = 14;
      for (let s = 0; s <= segs; s++) {
        const f = s / segs;
        const x = x0 + f * (x1 - x0);
        // Parabolic sag, zero at the two anchor ends.
        const droop = Math.sin(f * Math.PI) * sag;
        pts.push(new THREE.Vector3(x, y - droop, zOff));
      }
      const curve = new THREE.CatmullRomCurve3(pts);
      return new THREE.TubeGeometry(curve, 28, 0.012, 5, false);
    };
    return [mk(dz * 0.55, 0.16), mk(-dz * 0.55, 0.2)];
  }, [x0, x1, y, dz]);
  React.useEffect(() => () => geom.forEach((g) => g.dispose()), [geom]);
  useFrame((state) => {
    const g = group.current;
    if (!g) return;
    // Tiny vertical sway so the slack lines breathe in the wind.
    g.position.y = Math.sin(state.clock.elapsedTime * 0.9) * 0.025;
    g.rotation.z = Math.sin(state.clock.elapsedTime * 0.5) * 0.004;
  });
  return (
    <group ref={group}>
      {geom.map((gg, i) => (
        <mesh key={`stay${i}`} geometry={gg}>
          <meshStandardMaterial color={C.steelLt} metalness={0.7} roughness={0.45} transparent opacity={opacity * 0.85} />
        </mesh>
      ))}
    </group>
  );
}

// A faint, gently-drifting water plane well below the deck so the truss is
// visibly spanning something rather than floating over blank cream. A subtle
// vertex-free shimmer is faked by a slow material-side opacity breathe plus a
// small Z drift, keeping it cheap and seamless.
function WaterDatum({ midX, width, y, depth, opacity }) {
  const mesh = React.useRef();
  useFrame((state) => {
    const m = mesh.current;
    if (!m) return;
    const t = state.clock.elapsedTime;
    m.position.z = Math.sin(t * 0.18) * 0.06;
    m.material.opacity = opacity * (0.34 + Math.sin(t * 0.5) * 0.03);
  });
  return (
    <mesh ref={mesh} position={[midX, y, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
      <planeGeometry args={[width, depth, 1, 1]} />
      <meshStandardMaterial color={C.water} metalness={0.5} roughness={0.25} transparent opacity={opacity * 0.34} />
    </mesh>
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
      {/* Truss members: heavier top/bottom chords, lighter web/bracing */}
      {d.members.map((m, i) => (
        <Member key={i} a={m.a} b={m.b} radius={m.chord ? 0.09 : 0.062} color={C.steel} opacity={opacity} />
      ))}
      {d.bracing.map((m, i) => (
        <Member key={`br${i}`} a={m.a} b={m.b} radius={0.045} color={C.steelLt} opacity={opacity} />
      ))}
      {d.nodes.map((n, i) => (
        <Node key={`n${i}`} p={n} r={0.085} color={NODE} opacity={opacity} metalness={0.35} roughness={0.5} />
      ))}

      {/* Roadway deck: matte earth-gray slab with thickness */}
      <Box position={[deckMid, deckY, 0]} size={[spanLen, deckThick, 2 * d.dz]} color={DECK} opacity={opacity} metalness={0.05} roughness={0.85} />
      {/* Charcoal fascia edge beams down each long side */}
      {[fasciaZ, -fasciaZ].map((z, i) => (
        <Box key={`fas${i}`} position={[deckMid, deckY - 0.02, z]} size={[spanLen, deckThick + 0.06, 0.07]} color={C.charcoal} opacity={opacity} metalness={0.25} roughness={0.6} />
      ))}
      {/* Transverse floor beams under the deck tying the two bottom chords */}
      {d.bottomFront.map((bf, i) => (
        <Member key={`fb${i}`} a={[bf[0], deckY - deckThick / 2 - 0.04, fasciaZ]} b={[bf[0], deckY - deckThick / 2 - 0.04, -fasciaZ]} radius={0.05} color={C.steel} opacity={opacity} />
      ))}

      {/* Live load: two vehicles crossing the deck in opposite lanes, kept near
          the deck centerline (z=±0.26) so they clear the truss web diagonals
          (in the planes at z=±0.9) instead of passing behind them. The lead car
          is ember (brand accent now lives here, not on diagram arrows); the
          opposing one is muted steel so only one ember body shows at a time.
          Staggered phases keep an ember car on the deck most of the time. */}
      <Vehicle x0={x0} x1={x1} deckTopY={deckY + deckThick / 2} z={0.26} dir={1} bodyColor={C.ember} speed={0.085} phase={0} opacity={opacity} />
      <Vehicle x0={x0} x1={x1} deckTopY={deckY + deckThick / 2} z={-0.26} dir={-1} bodyColor="#9aa0a4" speed={0.07} phase={0.45} opacity={opacity} />

      {/* Slack stay/utility lines along the top chord that sway in the wind —
          cheap non-rigid ambient life so the vignette isn't just two sliders. */}
      <StayLines x0={(350 - 600) / 95} x1={(850 - 600) / 95} y={d.nodes.reduce((m, n) => Math.max(m, n[1]), -99) + 0.16} dz={d.dz} opacity={opacity} />

      {/* Ambient sky life: a small flock skimming just above the top chord.
          Lowered from 2.0 so the birds read against the bridge, not empty cream. */}
      <BirdFlock x0={x0} x1={x1} topY={1.55} opacity={opacity} />

      {/* Faint water datum well below the deck so the span visibly crosses
          something; gentle drift keeps it alive without clutter. */}
      <WaterDatum midX={deckMid} width={spanLen + 1.4} y={d.deckY - 1.45} depth={2 * d.dz + 2.2} opacity={opacity} />

      {/* Abutments under each support */}
      <Box position={[d.left[0], d.deckY - 0.62, 0]} size={[0.6, 0.5, 2 * d.dz + 0.34]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />
      <Box position={[d.right[0], d.deckY - 0.62, 0]} size={[0.6, 0.5, 2 * d.dz + 0.34]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />

      {/* Boundary conditions: pin (left) vs roller (right) */}
      <PinSupport x={d.left[0]} y={d.deckY} dz={d.dz} opacity={opacity} />
      <RollerSupport x={d.right[0]} y={d.deckY} dz={d.dz} opacity={opacity} />
    </group>
  );
}
