import React from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { C, P, Member, Box, Node, Person } from './primitives';

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

// The literal live load looping across the deck. Two distinct silhouettes:
// `kind="sedan"` (ember, tall stepped greenhouse) and `kind="truck"` (a low
// muted-steel flatbed with a forward cab + flat rear bed) so the two vehicles
// are never mistaken for the same gray box. Scaled up ~30% over the prior rig
// so they survive the 0.62 tile downscale. Wheels spin; the body faces travel.
// `dir` = +1 (left->right) or -1. Travel range hugs the deck so a vehicle is
// visibly ON the span for most of the loop.
function Vehicle({ x0, x1, deckTopY, z, dir, kind, bodyColor, speed, phase, opacity }) {
  const group = React.useRef();
  const wheels = React.useRef([]);
  // Tight margin: the loop spends most of its time ON the deck, not offscreen.
  const margin = 0.5;
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
  const wheelR = 0.092;
  const bodyY = wheelR + 0.1;
  const halfL = 0.55; // half body length (X) — ~30% longer than before
  const bodyW = 0.42;
  const isTruck = kind === 'truck';
  return (
    <group ref={group}>
      {/* lower body — long, low */}
      <mesh position={[0, bodyY, 0]} castShadow>
        <boxGeometry args={[2 * halfL, 0.19, bodyW]} />
        {mat(bodyColor, 0.5, 0.35)}
      </mesh>
      {isTruck ? (
        <>
          {/* forward cab — tall chunky block at the nose so the truck reads
              cab-then-bed even at tile scale (raised + taller for contrast) */}
          <mesh position={[halfL - 0.22, bodyY + 0.28, 0]} castShadow>
            <boxGeometry args={[0.38, 0.4, bodyW - 0.01]} />
            {mat(bodyColor, 0.45, 0.4)}
          </mesh>
          {/* dark flat bed deck behind the cab — darkened for value separation */}
          <mesh position={[-0.18, bodyY + 0.13, 0]} castShadow>
            <boxGeometry args={[0.6, 0.07, bodyW + 0.02]} />
            {mat('#4a4f52', 0.4, 0.5)}
          </mesh>
          {/* chunky cargo block on the bed => unmistakable freight mass */}
          <mesh position={[-0.24, bodyY + 0.3, 0]} castShadow>
            <boxGeometry args={[0.42, 0.3, bodyW - 0.04]} />
            {mat('#6a6f73', 0.4, 0.55)}
          </mesh>
          {/* low side rails on the bed (darker so they don't muddy the mass) */}
          {[bodyW / 2, -bodyW / 2].map((zz, i) => (
            <mesh key={`rail${i}`} position={[0.12, bodyY + 0.19, zz]} castShadow>
              <boxGeometry args={[0.26, 0.07, 0.03]} />
              {mat('#3f4346', 0.5, 0.4)}
            </mesh>
          ))}
          {/* big windshield on the forward cab */}
          <mesh position={[halfL - 0.05, bodyY + 0.34, 0]} rotation={[0, 0, -0.32]} castShadow>
            <boxGeometry args={[0.05, 0.26, bodyW - 0.07]} />
            {mat('#aaccdd', 0.6, 0.15)}
          </mesh>
        </>
      ) : (
        <>
          {/* sloped hood front — wedge so the nose is clearly the front */}
          <mesh position={[halfL - 0.04, bodyY + 0.11, 0]} castShadow>
            <boxGeometry args={[0.24, 0.08, bodyW - 0.02]} />
            {mat(bodyColor, 0.5, 0.35)}
          </mesh>
          {/* cab / greenhouse — taller, stepped-down so the silhouette reads as a car */}
          <mesh position={[-0.08, bodyY + 0.2, 0]} castShadow>
            <boxGeometry args={[0.56, 0.21, bodyW - 0.05]} />
            {mat(bodyColor, 0.45, 0.4)}
          </mesh>
          {/* windshield — bright info-blue glint angled at the front of the cab */}
          <mesh position={[0.16, bodyY + 0.21, 0]} rotation={[0, 0, -0.5]} castShadow>
            <boxGeometry args={[0.05, 0.2, bodyW - 0.08]} />
            {mat('#bcd8e8', 0.6, 0.12)}
          </mesh>
          {/* rear window glint */}
          <mesh position={[-0.36, bodyY + 0.2, 0]} rotation={[0, 0, 0.45]}>
            <boxGeometry args={[0.04, 0.17, bodyW - 0.08]} />
            {mat('#8fb0c2', 0.6, 0.18)}
          </mesh>
        </>
      )}
      {/* headlights — pale glints at the nose for front/back legibility */}
      {[0.16, -0.16].map((zz, i) => (
        <mesh key={`hl${i}`} position={[halfL + 0.05, bodyY, zz]}>
          <boxGeometry args={[0.04, 0.06, 0.07]} />
          {mat('#f3ead4', 0.2, 0.4)}
        </mesh>
      ))}
      {/* taillights — small ember glints at the rear */}
      {[0.16, -0.16].map((zz, i) => (
        <mesh key={`tl${i}`} position={[-halfL - 0.03, bodyY, zz]}>
          <boxGeometry args={[0.04, 0.06, 0.07]} />
          {mat(C.ember, 0.2, 0.4)}
        </mesh>
      ))}
      {/* four wheels */}
      {[[halfL - 0.18, 0.22], [halfL - 0.18, -0.22], [-halfL + 0.18, 0.22], [-halfL + 0.18, -0.22]].map((w, i) => (
        <mesh
          key={`wh${i}`}
          ref={(el) => { wheels.current[i] = el; }}
          position={[w[0], wheelR, w[1]]}
          rotation={[Math.PI / 2, 0, 0]}
          castShadow
        >
          <cylinderGeometry args={[wheelR, wheelR, 0.09, 14]} />
          {mat('#22211f', 0.3, 0.7)}
        </mesh>
      ))}
    </group>
  );
}

// A small 3-bird skein gliding across the sky on a slow looping path, clustered
// so they read as a flock. Each bird is a slim charcoal body flanked by two
// flat, wide, tapered wings held in a shallow swept-back dihedral. The wings
// are thin TRIANGLES (wider at the shoulder, tapering to a point at the tip)
// extruded once and shared, so the silhouette is a clean gliding gull, never a
// spiky asterisk. The flap is calm and low-amplitude (~0.35 ± 0.18 rad) and
// the wings ride a coherent shallow dihedral so they never cross into a caret.
function BirdFlock({ x0, x1, topY, opacity }) {
  const COUNT = 3;
  const left = React.useRef();
  const right = React.useRef();
  const body = React.useRef();
  // Allocate scratch object once — no per-frame allocation.
  const scratch = React.useMemo(() => ({ dummy: new THREE.Object3D() }), []);
  // Flat tapered wing: a thin triangle in the X-Z plane, hinged at the shoulder
  // (origin) and sweeping out toward -Z (the tip) and back along -X. Built once.
  const wingGeom = React.useMemo(() => {
    const shape = new THREE.Shape();
    // Shoulder at origin; broad leading edge, tapering to a swept tip.
    shape.moveTo(0.06, 0);      // leading edge near body
    shape.lineTo(-0.05, -0.34); // swept-back pointed tip
    shape.lineTo(-0.12, -0.02); // trailing edge back at the body
    shape.closePath();
    const g = new THREE.ExtrudeGeometry(shape, { depth: 0.012, bevelEnabled: false });
    // Lay the flat triangle into the X-Z plane (extrude is along Z by default).
    g.rotateX(-Math.PI / 2);
    return g;
  }, []);
  React.useEffect(() => () => wingGeom.dispose(), [wingGeom]);
  // Tight cluster offsets (a loose skein) layered over the shared glide path.
  const cluster = React.useMemo(() => [
    { dx: 0.0, dy: 0.0, dz: 0.0 },
    { dx: -0.34, dy: 0.12, dz: 0.28 },
    { dx: -0.34, dy: 0.12, dz: -0.28 },
  ], []);
  // Constrain the glide path so the flock travels ACROSS the truss span itself
  // (roughly mid-span ± a margin), never out into the far-left dead cream.
  const mid = (x0 + x1) / 2;
  const halfPath = (x1 - x0) * 0.42;
  const lo = mid - halfPath;
  const span = 2 * halfPath;
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (!left.current || !right.current || !body.current) return;
    // One shared glide head; birds hang off it as a cluster so they stay a flock.
    const u = ((t * 0.05) % 1 + 1) % 1;
    const headX = lo + u * span;
    // Altitude dips toward mid-path so the skein clearly passes the structure,
    // then lifts away — reads as a bird crossing the bridge, not a static speck.
    const dip = -Math.sin(u * Math.PI) * 0.22;
    const headY = topY + dip + Math.sin(t * 0.5) * 0.1;
    // Gentle bank as the skein crosses (roll about travel axis), tasteful.
    const bank = Math.sin(t * 0.5) * 0.18;
    for (let i = 0; i < COUNT; i++) {
      const c = cluster[i];
      const px = headX + c.dx;
      const py = headY + c.dy + Math.sin(t * 0.9 + i * 2.1) * 0.05;
      const pz = c.dz + Math.sin(t * 0.35 + i) * 0.12;
      // Calm, low-amplitude flap about a shallow resting dihedral; phase varies
      // per bird so the flock ripples naturally. Stays in a gentle ~0.17..0.53
      // band so the wings read as a smooth glide, never a spiky star.
      const flap = 0.35 + Math.sin(t * 3.2 + i * 1.7) * 0.18;
      const { dummy } = scratch;
      // Slim body between the wings (long axis along travel = X), banked.
      dummy.position.set(px, py, pz);
      dummy.rotation.set(bank, 0, 0);
      dummy.scale.set(1, 1, 1);
      dummy.updateMatrix();
      body.current.setMatrixAt(i, dummy.matrix);
      // Left wing — flat triangle hinged at the shoulder, dihedral about X.
      // Tip points toward -Z; positive roll lifts it into the V.
      dummy.position.set(px, py + 0.012, pz - 0.02);
      dummy.rotation.set(bank, 0, flap);
      dummy.updateMatrix();
      left.current.setMatrixAt(i, dummy.matrix);
      // Right wing — mirrored across Z (scale Z by -1, opposite roll).
      dummy.position.set(px, py + 0.012, pz + 0.02);
      dummy.rotation.set(bank, 0, -flap);
      dummy.scale.set(1, 1, -1);
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
        <capsuleGeometry args={[0.022, 0.18, 3, 6]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} transparent={opacity < 1} opacity={opacity} />
      </instancedMesh>
      <instancedMesh ref={left} args={[wingGeom, undefined, COUNT]}>
        <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} side={THREE.DoubleSide} transparent={opacity < 1} opacity={opacity} />
      </instancedMesh>
      <instancedMesh ref={right} args={[wingGeom, undefined, COUNT]}>
        <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} side={THREE.DoubleSide} transparent={opacity < 1} opacity={opacity} />
      </instancedMesh>
    </group>
  );
}

// A pair of slack utility/stay lines running just above the top chord. Each is
// an open lathe-free catenary approximated by a thin cylinder whose sag is
// driven by a tiny useFrame sine — non-rigid ambient life. Built once from a
// CatmullRom tube so we only animate a single group's Y bob (cheap, seamless).
function StayLines({ x0, x1, y, dz, opacity }) {
  const meshes = React.useRef([]);
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
      return new THREE.TubeGeometry(curve, 28, 0.018, 6, false);
    };
    return [mk(dz * 0.55, 0.24), mk(-dz * 0.55, 0.3)];
  }, [x0, x1, y, dz]);
  React.useEffect(() => () => geom.forEach((g) => g.dispose()), [geom]);
  // Each line breathes on its own phase + amplitude so the wind reads as wind,
  // not a rigid translation of both cables in lockstep.
  const params = React.useMemo(() => [
    { freq: 0.9, amp: 0.06, phase: 0.0, roll: 0.008 },
    { freq: 0.7, amp: 0.085, phase: 1.7, roll: 0.006 },
  ], []);
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    for (let i = 0; i < meshes.current.length; i++) {
      const m = meshes.current[i];
      if (!m) continue;
      const p = params[i];
      m.position.y = Math.sin(t * p.freq + p.phase) * p.amp;
      m.rotation.z = Math.sin(t * p.freq * 0.6 + p.phase) * p.roll;
    }
  });
  return (
    <group>
      {geom.map((gg, i) => (
        <mesh key={`stay${i}`} geometry={gg} ref={(el) => { meshes.current[i] = el; }}>
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
  const debris = React.useRef();
  const ripples = React.useRef();
  const DEBRIS = 5;
  const RIPPLES = 3;
  const scratch = React.useMemo(() => ({ dummy: new THREE.Object3D() }), []);
  // Per-speck lane (z) + phase so they drift downstream (+x) at different rates.
  const lanes = React.useMemo(() => [
    { z: -0.85, phase: 0.0, speed: 0.03 },
    { z: -0.4, phase: 0.55, speed: 0.026 },
    { z: 0.1, phase: 0.2, speed: 0.034 },
    { z: 0.55, phase: 0.7, speed: 0.024 },
    { z: 1.0, phase: 0.42, speed: 0.038 },
  ], []);
  // Elongated faint ripple streaks scrolling downstream to read as current.
  const rippleLanes = React.useMemo(() => [
    { z: -0.65, phase: 0.3, speed: 0.045 },
    { z: 0.2, phase: 0.8, speed: 0.05 },
    { z: 0.85, phase: 0.05, speed: 0.04 },
  ], []);
  const lo = midX - width / 2 + 0.4;
  const drift = width - 0.8;
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const m = mesh.current;
    if (m) {
      m.position.z = Math.sin(t * 0.18) * 0.06;
      // Stronger, never-dim base so the river clearly reads as water.
      m.material.opacity = opacity * (0.68 + Math.sin(t * 0.5) * 0.04);
    }
    if (debris.current) {
      for (let i = 0; i < DEBRIS; i++) {
        const ln = lanes[i];
        const u = ((t * ln.speed + ln.phase) % 1 + 1) % 1;
        const { dummy } = scratch;
        dummy.position.set(lo + u * drift, 0.01, ln.z + Math.sin(t * 0.4 + i) * 0.12);
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
        dummy.position.set(lo + u * drift, 0.005, ln.z + Math.sin(t * 0.3 + i * 1.3) * 0.08);
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
        <planeGeometry args={[width, depth, 1, 1]} />
        <meshStandardMaterial color={C.water} metalness={0.5} roughness={0.25} transparent opacity={opacity * 0.68} />
      </mesh>
      {/* slow drifting debris specks just above the surface => current */}
      <group position={[0, y + 0.02, 0]}>
        <instancedMesh ref={debris} args={[undefined, undefined, DEBRIS]}>
          <boxGeometry args={[0.22, 0.025, 0.07]} />
          <meshStandardMaterial color="#5a6b62" metalness={0.2} roughness={0.7} transparent opacity={opacity * 0.75} />
        </instancedMesh>
      </group>
      {/* faint elongated ripple streaks scrolling downstream => legible current */}
      <group position={[0, y + 0.012, 0]}>
        <instancedMesh ref={ripples} args={[undefined, undefined, RIPPLES]}>
          <boxGeometry args={[0.7, 0.006, 0.04]} />
          <meshStandardMaterial color="#7d97a0" metalness={0.4} roughness={0.4} transparent opacity={opacity * 0.4} />
        </instancedMesh>
      </group>
      {/* faint forest bank edges on the far/near sides reinforce the river read */}
      {[-(depth / 2) + 0.18, (depth / 2) - 0.18].map((zz, i) => (
        <mesh key={`bank${i}`} position={[midX, y + 0.005, zz]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
          <planeGeometry args={[width, 0.6, 1, 1]} />
          <meshStandardMaterial color="#35513f" metalness={0.05} roughness={0.92} transparent opacity={opacity * 0.7} />
        </mesh>
      ))}
    </group>
  );
}

// A lone pedestrian strolling slowly along the near fascia walkway — a second,
// human scale of life beside the vehicle traffic. Walks the full span and back
// (ping-pong) on a slow loop, facing travel, with a faint stride bob. Motion is
// driven by mutating the group ref each frame (no React state, no allocation).
function Pedestrian({ x0, x1, y, z, speed, opacity }) {
  const group = React.useRef();
  const margin = 0.3;
  const lo = x0 + margin;
  const span = (x1 - margin) - lo;
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const g = group.current;
    if (!g) return;
    // Triangle wave 0..1..0 for a seamless there-and-back stroll.
    const raw = ((t * speed) % 1 + 1) % 1;
    const tri = raw < 0.5 ? raw * 2 : 2 - raw * 2;
    g.position.x = lo + tri * span;
    g.position.y = y + Math.abs(Math.sin(t * 3.0)) * 0.012; // tiny stride bob
    g.position.z = z;
    // Face the direction of travel (forward on the way out, reversed on return).
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
          opposing one is a muted-steel flatbed truck so the two silhouettes are
          distinguishable, not two near-identical boxes. The tight travel margin
          keeps the ember sedan visibly mid-span for most of its loop. */}
      <Vehicle x0={x0} x1={x1} deckTopY={deckY + deckThick / 2} z={0.3} dir={1} kind="sedan" bodyColor={C.ember} speed={0.061} phase={0.78} opacity={opacity} />
      <Vehicle x0={x0} x1={x1} deckTopY={deckY + deckThick / 2} z={-0.3} dir={-1} kind="truck" bodyColor="#9aa0a4" speed={0.047} phase={0.74} opacity={opacity} />

      {/* Near-side walkway: a thin raised curb strip running the span just inside
          the fascia, so the strolling pedestrian visibly walks ON a sidewalk
          rather than floating at the deck edge. */}
      <Box position={[deckMid, deckY + deckThick / 2 + 0.015, 0.72]} size={[spanLen, 0.05, 0.34]} color="#8a8278" opacity={opacity} metalness={0.05} roughness={0.9} />
      {/* low curb lip on the outboard side of the walkway */}
      <Box position={[deckMid, deckY + deckThick / 2 + 0.05, 0.9]} size={[spanLen, 0.07, 0.04]} color={C.charcoal} opacity={opacity} metalness={0.2} roughness={0.7} />

      {/* A lone pedestrian strolling the near walkway — a slower, human scale of
          life beside the vehicle traffic. Sits on the curb strip just inside the
          near fascia so they walk the span without clipping the truss web. */}
      <Pedestrian x0={x0} x1={x1} y={deckY + deckThick / 2 + 0.04} z={0.72} speed={0.026} opacity={opacity} />

      {/* Slack stay/utility lines along the top chord that sway in the wind —
          cheap non-rigid ambient life so the vignette isn't just two sliders. */}
      <StayLines x0={(350 - 600) / 95} x1={(850 - 600) / 95} y={d.nodes.reduce((m, n) => Math.max(m, n[1]), -99) + 0.16} dz={d.dz} opacity={opacity} />

      {/* Ambient sky life: a small flock skimming just above the top chord.
          Lowered from 2.0 so the birds read against the bridge, not empty cream. */}
      <BirdFlock x0={x0} x1={x1} topY={1.72} opacity={opacity} />

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
