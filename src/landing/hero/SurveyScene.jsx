import React from 'react';
import * as THREE from 'three';
import { useFrame } from '@react-three/fiber';
import { C, Box, Node, Person } from './primitives';

// FE topic: Surveying — graded ground with real elevation, a tripod-mounted
// TOTAL STATION (tribrach base + yoke standards + journaled telescope), the
// woman engineer leaning into the instrument, and a rodperson plumbing a
// graduated leveling rod at the far extent. The ember line of sight runs from
// the telescope objective to the rod face. Now a LIVING field vignette: low
// trees sway in the wind, clouds drift across the sky, birds arc overhead, the
// crew makes tiny steadying corrections, and a dog waits by the operator.
// `opacity` cross-fades everything.

export function terrainH(x, z) {
  return (
    0.34 * Math.sin(x * 0.6 + 0.4) +
    0.22 * Math.cos(z * 0.9 - 0.3) +
    0.14 * Math.sin((x - z) * 0.5) -
    0.04 * x
  );
}

const GROUND = -0.9;

// Earth/foliage palette (muted, on-brand greens + browns).
const LEAF_A = '#4e6f4a';
const LEAF_B = '#5f7d5a';
const BARK = '#5b4e40';
const CLOUD = '#FFFDF8';
const DOG = '#a8825a'; // warm tan coat so it separates from the soil/grass

// Shared wind-gust envelope: a slow 0..1 swell on a ~9s period that trees and
// grass both read, so a single gust crosses the whole field at once (the
// foliage breathes together rather than each clump doing its own thing). A base
// breeze keeps things alive between gusts. Pure function of time → no shared
// state, no allocation.
function windGust(t) {
  const g = Math.sin(t * (2 * Math.PI / 9));
  return 0.55 + 0.45 * g * g; // ranges ~0.55..1.0, peaking on each swell
}

// A tapered steel tripod leg: two stacked cylinders (thick at the head, thin at
// the foot) plus a pointed cone foot planted in the soil.
function TripodLeg({ a, b, opacity }) {
  const { midUp, midLo, footPos, len, quat } = React.useMemo(() => {
    const va = new THREE.Vector3(...a);
    const vb = new THREE.Vector3(...b);
    const dir = new THREE.Vector3().subVectors(vb, va);
    const length = dir.length();
    const ndir = dir.clone().normalize();
    const q = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, 1, 0), ndir);
    return {
      midUp: va.clone().addScaledVector(ndir, length * 0.25),
      midLo: va.clone().addScaledVector(ndir, length * 0.75),
      footPos: vb.clone().addScaledVector(ndir, 0.03),
      len: length,
      quat: q,
    };
  }, [a, b]);
  const mat = (
    <meshStandardMaterial color={C.steel} metalness={0.55} roughness={0.5} transparent={opacity < 1} opacity={opacity} />
  );
  return (
    <group>
      <mesh position={midUp} quaternion={quat} castShadow>
        <cylinderGeometry args={[0.034, 0.028, len * 0.5, 10]} />
        {mat}
      </mesh>
      <mesh position={midLo} quaternion={quat} castShadow>
        <cylinderGeometry args={[0.028, 0.02, len * 0.5, 10]} />
        {mat}
      </mesh>
      <mesh position={footPos} quaternion={quat} castShadow>
        <coneGeometry args={[0.028, 0.1, 10]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.5} roughness={0.5} transparent={opacity < 1} opacity={opacity} />
      </mesh>
    </group>
  );
}

function TotalStation({ x, z, opacity, look }) {
  const alidadeRef = React.useRef();
  const baseY = GROUND + terrainH(x, z);
  // Tripod head where the three legs converge and the tribrach sits.
  const headY = baseY + 1.0;
  const head = [x, headY, z];
  const feet = [
    [x + 0.4, baseY, z + 0.32],
    [x - 0.46, baseY, z + 0.26],
    [x + 0.08, baseY, z - 0.5],
  ];
  const yaw = Math.atan2(look[0] - x, look[2] - z);
  const steel = (m = 0.7, r = 0.3) => (
    <meshStandardMaterial color={C.steelLt} metalness={m} roughness={r} transparent={opacity < 1} opacity={opacity} />
  );
  // Aim dither + occasional discrete re-aim. The fine dither reads as settling;
  // every ~8s a brief small yaw step (gaussian bump) reads as the operator
  // swinging the alidade onto a new sight and locking on — "taking a shot."
  useFrame((state) => {
    if (!alidadeRef.current) return;
    const t = state.clock.elapsedTime;
    const dither = 0.01 * Math.sin(t * 0.6);
    const rcyc = (t % 8.0) - 3.5;
    const reaim = 0.06 * Math.exp(-(rcyc * rcyc) / 0.9) * Math.sin(t * 1.1);
    alidadeRef.current.rotation.y = yaw + dither + reaim;
  });
  return (
    <group>
      {feet.map((f, i) => (
        <TripodLeg key={i} a={head} b={f} opacity={opacity} />
      ))}

      {/* Tribrach: circular base disc on the tripod head */}
      <mesh position={[x, headY + 0.04, z]} castShadow>
        <cylinderGeometry args={[0.12, 0.13, 0.07, 20]} />
        {steel(0.6, 0.4)}
      </mesh>

      {/* Alidade: everything that yaws about the vertical axis */}
      <group ref={alidadeRef} position={[x, headY + 0.09, z]} rotation={[0, yaw, 0]}>
        {/* lower body of the instrument */}
        <mesh position={[0, 0.07, 0]} castShadow>
          <cylinderGeometry args={[0.1, 0.11, 0.1, 18]} />
          {steel(0.65, 0.35)}
        </mesh>
        {/* keypad face on the front (toward the rod, +z local) */}
        <mesh position={[0, 0.07, 0.105]} castShadow>
          <boxGeometry args={[0.13, 0.09, 0.02]} />
          <meshStandardMaterial color={C.charcoal} metalness={0.3} roughness={0.6} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        {/* two yoke standards rising from the body */}
        <mesh position={[-0.085, 0.21, 0]} castShadow>
          <boxGeometry args={[0.035, 0.2, 0.05]} />
          {steel(0.7, 0.3)}
        </mesh>
        <mesh position={[0.085, 0.21, 0]} castShadow>
          <boxGeometry args={[0.035, 0.2, 0.05]} />
          {steel(0.7, 0.3)}
        </mesh>
        {/* horizontal telescope journaled BETWEEN the standards (sights +z) */}
        <mesh position={[0, 0.27, 0.06]} rotation={[Math.PI / 2, 0, 0]} castShadow>
          <cylinderGeometry args={[0.045, 0.045, 0.3, 16]} />
          {steel(0.7, 0.3)}
        </mesh>
        {/* objective lens at the front tip of the telescope */}
        <mesh position={[0, 0.27, 0.21]} rotation={[Math.PI / 2, 0, 0]} castShadow>
          <cylinderGeometry args={[0.048, 0.048, 0.03, 16]} />
          <meshStandardMaterial color={C.charcoal} metalness={0.4} roughness={0.4} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        {/* eyepiece ember accent at the back */}
        <Node p={[0, 0.27, -0.16]} r={0.03} color={C.ember} emissive={C.ember} opacity={opacity} />
      </group>
    </group>
  );
}

// A graduated leveling rod: a WHITE rod face carrying classic survey graduation
// blocks — bold charcoal E-pattern marks every decimal, with a thin ember band
// only as an accent at each foot mark. Reads as a real stadia rod, not a
// candy-cane hazard pole.
const ROD_WHITE = '#F2EEE6';
function StadiaRod({ opacity }) {
  const segs = 13; // each segment is one tenth of a "foot"
  const h = 0.16;
  const w = 0.075;
  return (
    <group>
      {/* continuous white rod face the graduation blocks sit on */}
      <Box
        position={[0, (segs * h) / 2, 0]}
        size={[w, segs * h, 0.05]}
        color={ROD_WHITE}
        opacity={opacity}
        metalness={0.05}
        roughness={0.65}
      />
      {Array.from({ length: segs }).map((_, i) => {
        const footMark = i % 5 === 0; // every fifth tenth = a "foot" → ember accent
        // Charcoal graduation block on the white face. Alternate a solid block
        // and an E-pattern (block split by a white gap) so it reads graduated.
        const eGap = i % 2 === 1;
        return (
          <group key={i} position={[0, h / 2 + i * h, 0]}>
            {eGap ? (
              <>
                {/* E-pattern: two stacked charcoal bars with a white gap */}
                <Box
                  position={[0, h * 0.22, 0.001]}
                  size={[w * 0.82, h * 0.34, 0.052]}
                  color={C.charcoal}
                  opacity={opacity}
                  metalness={0.05}
                  roughness={0.7}
                />
                <Box
                  position={[0, -h * 0.22, 0.001]}
                  size={[w * 0.82, h * 0.34, 0.052]}
                  color={C.charcoal}
                  opacity={opacity}
                  metalness={0.05}
                  roughness={0.7}
                />
              </>
            ) : (
              <Box
                position={[0, 0, 0.001]}
                size={[w * 0.82, h * 0.44, 0.052]}
                color={C.charcoal}
                opacity={opacity}
                metalness={0.05}
                roughness={0.7}
              />
            )}
            {footMark && (
              // thin ember foot-mark band wrapping the rod as an accent only
              <Box
                position={[0, -h / 2 + 0.012, 0.002]}
                size={[w * 1.02, 0.022, 0.054]}
                color={C.ember}
                opacity={opacity}
                metalness={0.1}
                roughness={0.6}
              />
            )}
          </group>
        );
      })}
    </group>
  );
}

// ---------------------------------------------------------------------------
// LIVING DETAIL

// A low procedural tree: a short bark trunk plus 1-2 icosphere/cone canopies in
// muted foliage greens. The whole canopy group sways gently in the wind. Seated
// on terrainH so it sits on the graded surface.
function Tree({ x, z, scale = 1, phase = 0, distant = false, opacity }) {
  const canopyRef = React.useRef();
  const topRef = React.useRef();
  const baseY = GROUND + terrainH(x, z);
  // Slight per-tree variation in the side-lobe placement so silhouettes differ.
  const lobe = React.useMemo(() => {
    const a = phase * 1.7;
    return [Math.cos(a) * 0.2, 0.06 + 0.08 * ((phase % 1)), Math.sin(a) * 0.18];
  }, [phase]);
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    // shared gust swells the amplitude; distant crowns get a steadier, slower
    // parallax layer so the back of the field reads as a calmer breeze.
    const gust = windGust(t);
    const amp = distant ? 0.04 + 0.03 * gust : 0.05 + 0.05 * gust;
    const rate = distant ? 0.55 : 0.8;
    if (canopyRef.current) {
      canopyRef.current.rotation.z = amp * Math.sin(t * rate + phase);
      canopyRef.current.rotation.x = amp * 0.7 * Math.sin(t * (rate * 0.8) + phase * 1.3);
    }
    if (topRef.current) {
      // upper cluster lags in phase so the crown deforms rather than rotating
      // rigidly — the top tuft trails the main mass in the gust.
      topRef.current.rotation.z = amp * 0.85 * Math.sin(t * (rate * 1.2) + phase + 0.9);
      topRef.current.rotation.x = amp * 0.6 * Math.sin(t * (rate * 0.9) + phase * 1.3 + 0.6);
    }
  });
  const trunkH = 0.42 * scale;
  return (
    <group position={[x, baseY, z]} scale={scale}>
      <mesh position={[0, trunkH / 2, 0]} castShadow>
        <cylinderGeometry args={[0.035, 0.05, trunkH, 8]} />
        <meshStandardMaterial color={BARK} metalness={0.05} roughness={1} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
      {/* canopy pivots at the top of the trunk so it sways like a crown */}
      <group ref={canopyRef} position={[0, trunkH, 0]}>
        <mesh position={[0, 0.22, 0]} castShadow>
          <icosahedronGeometry args={[0.3, 0]} />
          <meshStandardMaterial color={LEAF_A} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
        </mesh>
        {/* a second, lower side lobe so the crown silhouette varies tree-to-tree */}
        <mesh position={[lobe[0], lobe[1], lobe[2]]} castShadow>
          <icosahedronGeometry args={[0.21, 0]} />
          <meshStandardMaterial color={LEAF_B} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
        </mesh>
        {/* upper tuft pivots about the main canopy with its own phase */}
        <group ref={topRef} position={[0, 0.22, 0]}>
          <mesh position={[0.12, 0.2, 0.05]} castShadow>
            <icosahedronGeometry args={[0.2, 0]} />
            <meshStandardMaterial color={LEAF_B} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
          </mesh>
        </group>
      </group>
    </group>
  );
}

// A soft cloud puff: a small cluster of flattened near-white spheres drifting
// slowly in +x and wrapping seamlessly. No metalness, low opacity.
function Cloud({ y, z, speed, offset, scale = 1, opacity }) {
  const ref = React.useRef();
  const span = 13;
  const puffs = React.useMemo(
    () => [
      [0, 0, 0, 0.5],
      [0.6, 0.04, 0.05, 0.4],
      [-0.58, 0.03, -0.04, 0.36],
      [0.26, 0.1, 0.02, 0.32],
      [-0.95, -0.02, 0.03, 0.26],
    ],
    [],
  );
  useFrame((state) => {
    if (!ref.current) return;
    const t = state.clock.elapsedTime;
    ref.current.position.x = ((t * speed + offset) % span) - span / 2;
  });
  const op = opacity * 0.5;
  return (
    <group ref={ref} position={[0, y, z]} scale={scale}>
      {/* flatter, wider puffs so the band reads as atmosphere, not balloons */}
      {puffs.map((p, i) => (
        <mesh key={i} position={[p[0], p[1], p[2]]} scale={[1.25, 0.42, 1]}>
          <sphereGeometry args={[p[3], 12, 8]} />
          <meshStandardMaterial color={CLOUD} metalness={0} roughness={1} transparent opacity={op} flatShading />
        </mesh>
      ))}
    </group>
  );
}

// A small flock of birds arcing overhead in a recognizable V formation. Each
// bird is FOUR instanced boxes: a tapered body, a head/tail nub, and two LONG
// THIN wings held near-horizontal at a shallow dihedral, so each reads as an
// unmistakable bird silhouette even in a frozen frame. The flock is kept SMALL
// (3 flapping + 1 distant glider) and WIDELY SPACED so the V reads as crisp
// separated silhouettes, never a dark blob. The whole flock shares ONE heading
// and travels as a loose cluster (lead bird out front, two trailing) across the
// upper frame, wrapping seamlessly. Wings flap slowly with a shallow, LEGIBLE
// dihedral (never a deep snap); phase varies per bird so the flock shimmers
// rather than pumping in lockstep. The flock sits higher and at a single
// forward z-band so it never reads as one mass with the clouds.
const BIRD_FLAP = 3; // flapping birds in the formation (uncluttered V)
const BIRD_COUNT = BIRD_FLAP + 1; // + 1 distant gliding bird
const PARTS_PER_BIRD = 4; // body + head + 2 wings
// Birds live at this z (toward camera); clouds sit at z <= -1.7, so the flock
// stays clearly in front of them.
const BIRD_Z = 0.9;
// Formation offsets (along/across heading), lead bird first → trailing V rows.
// Wider spread so the three birds read as distinct silhouettes in a clean V.
const FORMATION = [
  [0.0, 0.0],
  [-0.62, 0.56],
  [-0.62, -0.56],
];
function Birds({ opacity }) {
  const ref = React.useRef();
  const dummy = React.useMemo(() => new THREE.Object3D(), []);
  const total = BIRD_COUNT * PARTS_PER_BIRD;
  useFrame((state) => {
    if (!ref.current) return;
    const t = state.clock.elapsedTime;
    // shared flock travel: a slow horizontal drift across the upper-left frame,
    // wrapping seamlessly. Heading is fixed (gentle leftward glide) so the V
    // never tumbles; only x sweeps.
    const span = 11;
    const fcx = ((t * 0.34 + 2) % span) - span / 2 - 0.4;
    const fcy = 2.62 + 0.12 * Math.sin(t * 0.5); // higher band, clear of clouds
    const fHeading = Math.PI / 2 + 0.18; // travelling roughly +x, slight cant
    const cosH = Math.cos(fHeading);
    const sinH = Math.sin(fHeading);
    for (let b = 0; b < BIRD_COUNT; b++) {
      const glider = b === BIRD_COUNT - 1;
      let cx, cy, cz, flap, heading, halfSpan, lead;
      if (glider) {
        // a lone bird crossing low on a different path for natural variation:
        // gliding well below and behind the formation, slower, gentle dihedral.
        const gx = ((t * 0.26 + 7) % span) - span / 2 + 0.3;
        heading = Math.PI / 2 + 0.05;
        cx = gx;
        cy = 1.95 + 0.06 * Math.sin(t * 0.6); // low crossing, distinct from V
        cz = BIRD_Z + 0.6; // toward camera, well clear of clouds
        flap = 0.26; // gentle steady glide dihedral
        halfSpan = 0.19;
        lead = false;
      } else {
        // tucked into the shared formation, slight individual flap phase
        const off = FORMATION[b];
        cx = fcx + off[0] * sinH + off[1] * cosH;
        cy = fcy + off[0] * 0.0 + 0.03 * Math.sin(t * 1.2 + b);
        cz = BIRD_Z + off[0] * 0.1; // shallow z spread, all in the bird band
        heading = fHeading;
        // slow, shallow wingbeat with more dihedral so each bird's wings angle
        // clearly up off the body and the silhouette separates from neighbors.
        flap = 0.4 + 0.2 * Math.sin(t * 4 + b * 1.1);
        lead = b === 0;
        halfSpan = lead ? 0.22 : 0.19; // smaller overall so the V stays crisp
      }
      const ch = Math.cos(heading);
      const sh = Math.sin(heading);
      // body: a slim tapered box at the bird center, aligned to heading
      dummy.position.set(cx, cy, cz);
      dummy.rotation.set(0, heading, 0);
      dummy.scale.set(0.038, 0.03, halfSpan * 1.05);
      dummy.updateMatrix();
      ref.current.setMatrixAt(b * PARTS_PER_BIRD, dummy.matrix);
      // head/tail nub at the front of the body so direction reads
      dummy.position.set(cx + sh * halfSpan * 0.6, cy + 0.005, cz + ch * halfSpan * 0.6);
      dummy.rotation.set(0, heading, 0);
      dummy.scale.set(0.03, 0.025, halfSpan * 0.42);
      dummy.updateMatrix();
      ref.current.setMatrixAt(b * PARTS_PER_BIRD + 1, dummy.matrix);
      // two LONG THIN wings, near-horizontal with a shallow dihedral. Local +x
      // is the lateral (span) axis after the heading yaw; chord runs along local
      // +z. A longer span and narrower chord (with a chord-to-body gap) keeps
      // each wing as a clean line that doesn't merge into the body or its
      // neighbor. Offset the wing center outboard so it hinges at the shoulder.
      for (let w = 0; w < 2; w++) {
        const side = w === 0 ? 1 : -1;
        const reach = halfSpan * 0.85; // longer shoulder-to-wing-center reach
        dummy.position.set(
          cx + side * reach * ch,
          cy + 0.014 + reach * Math.sin(flap),
          cz - side * reach * sh,
        );
        dummy.rotation.set(0, heading, side * flap);
        // wing geometry: LONG span (local x), narrow chord (local z), thin (y).
        dummy.scale.set(halfSpan * 1.7, 0.01, halfSpan * 0.55);
        dummy.updateMatrix();
        ref.current.setMatrixAt(b * PARTS_PER_BIRD + 2 + w, dummy.matrix);
      }
    }
    ref.current.instanceMatrix.needsUpdate = true;
  });
  return (
    <instancedMesh ref={ref} args={[undefined, undefined, total]} castShadow>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} transparent={opacity < 1} opacity={opacity} flatShading />
    </instancedMesh>
  );
}

// A low-poly field dog on open ground near the crew: capsule body, box legs,
// sphere head with stub ears. Idle behavior loop — a gentle head bob plus an
// occasional look-around (periodic yaw turn) and a steady tail wag, all via ref
// rotation. Oriented broadside to camera so the head/tail/legs silhouette reads
// clearly. Scaled up so it registers as a charming focal accent.
function Dog({ x, z, opacity }) {
  const rootRef = React.useRef();
  const headRef = React.useRef();
  const tailRef = React.useRef();
  const baseY = GROUND + terrainH(x, z);
  const mat = (
    <meshStandardMaterial color={DOG} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
  );
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (rootRef.current) {
      // slow grazing drift: the dog ambles a short distance over a long (~14s)
      // loop, pads forward in little surges, then drifts back — reads as the
      // dog wandering the field rather than pivoting in place. Stays on terrain.
      const driftX = 0.5 * Math.sin(t * (2 * Math.PI / 14));
      const driftZ = 0.28 * Math.sin(t * (2 * Math.PI / 14) * 1.3 + 0.6);
      const px = x + driftX;
      const pz = z + driftZ;
      rootRef.current.position.x = px;
      rootRef.current.position.z = pz;
      // keep the feet on the graded surface as it moves; a faint padding bob
      // (small, quicker) layered over the slow follow of the terrain height.
      rootRef.current.position.y = GROUND + terrainH(px, pz) + 0.01 * Math.abs(Math.sin(t * 2.2));
      // gently swing the heading with the amble so it reads as walking, not
      // sliding; keep the yaw oscillation SMALL so the dog stays reliably
      // broadside to camera through the whole loop (never rotating toward the
      // camera and flattening the silhouette).
      rootRef.current.rotation.y = Math.PI * 0.5 + 0.08 * Math.cos(t * (2 * Math.PI / 14));
    }
    if (headRef.current) {
      headRef.current.rotation.x = 0.08 * Math.sin(t * 1.1);
      // occasional look-around: a smooth yaw turn that peaks then settles on a
      // ~6s cycle (gaussian bump), reading as the dog glancing about the field.
      const cyc = (t % 6.0) - 2.0;
      headRef.current.rotation.y = 0.6 * Math.exp(-(cyc * cyc) / 0.5) * Math.sin(t * 1.3);
    }
    if (tailRef.current) tailRef.current.rotation.z = 0.5 * Math.sin(t * 4.0);
  });
  return (
    <group ref={rootRef} position={[x, baseY, z]} rotation={[0, Math.PI * 0.5, 0]} scale={0.86}>
      {/* body */}
      <mesh position={[0, 0.22, 0]} rotation={[0, 0, Math.PI / 2]} castShadow>
        <capsuleGeometry args={[0.1, 0.26, 4, 8]} />
        {mat}
      </mesh>
      {/* four stub legs */}
      {[[-0.13, 0.1], [0.13, 0.1], [-0.13, -0.1], [0.13, -0.1]].map((p, i) => (
        <mesh key={i} position={[p[0], 0.06, p[1]]} castShadow>
          <boxGeometry args={[0.05, 0.16, 0.05]} />
          {mat}
        </mesh>
      ))}
      {/* head pivots up front */}
      <group ref={headRef} position={[0.24, 0.28, 0]}>
        <mesh position={[0.06, 0.04, 0]} castShadow>
          <sphereGeometry args={[0.1, 10, 8]} />
          {mat}
        </mesh>
        <mesh position={[0.16, 0.0, 0]} castShadow>
          <boxGeometry args={[0.1, 0.06, 0.07]} />
          {mat}
        </mesh>
        {/* ears */}
        <mesh position={[0.04, 0.12, 0.06]} castShadow>
          <boxGeometry args={[0.03, 0.07, 0.02]} />
          {mat}
        </mesh>
        <mesh position={[0.04, 0.12, -0.06]} castShadow>
          <boxGeometry args={[0.03, 0.07, 0.02]} />
          {mat}
        </mesh>
      </group>
      {/* tail wags at the back */}
      <group ref={tailRef} position={[-0.18, 0.26, 0]}>
        <mesh position={[-0.08, 0.04, 0]} rotation={[0, 0, 0.6]} castShadow>
          <cylinderGeometry args={[0.018, 0.03, 0.18, 6]} />
          {mat}
        </mesh>
      </group>
    </group>
  );
}

// A small instanced grass tuft: several thin tapered blades fanned from a point,
// each swaying in the wind on its own phase. Sits on terrainH so it hugs the
// graded surface. Enriches the foreground near the dog without clutter.
const GRASS = '#6f8a5e';
const GRASS_BLADES = 7;
function GrassTuft({ x, z, scale = 1, phase = 0, opacity }) {
  const ref = React.useRef();
  const dummy = React.useMemo(() => new THREE.Object3D(), []);
  const baseY = GROUND + terrainH(x, z);
  const blades = React.useMemo(
    () =>
      Array.from({ length: GRASS_BLADES }).map((_, i) => ({
        a: (i / GRASS_BLADES) * Math.PI * 2,
        r: 0.02 + 0.06 * ((i * 7) % GRASS_BLADES) / GRASS_BLADES,
        h: 0.2 + 0.08 * ((i * 3) % 5) / 5,
        ph: i * 1.3,
      })),
    [],
  );
  useFrame((state) => {
    if (!ref.current) return;
    const t = state.clock.elapsedTime;
    // shared gust swells the whole tuft's lean in step with the trees
    const gust = windGust(t);
    const swayAmp = 0.16 + 0.16 * gust;
    for (let i = 0; i < GRASS_BLADES; i++) {
      const bl = blades[i];
      const sway = swayAmp * Math.sin(t * 1.6 + phase + bl.ph);
      dummy.position.set(Math.cos(bl.a) * bl.r, bl.h / 2, Math.sin(bl.a) * bl.r);
      dummy.rotation.set(sway * Math.cos(bl.a), bl.a, sway * Math.sin(bl.a));
      dummy.scale.set(0.012, bl.h, 0.012);
      dummy.updateMatrix();
      ref.current.setMatrixAt(i, dummy.matrix);
    }
    ref.current.instanceMatrix.needsUpdate = true;
  });
  return (
    <instancedMesh ref={ref} args={[undefined, undefined, GRASS_BLADES]} position={[x, baseY, z]} scale={scale} castShadow>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color={GRASS} metalness={0.05} roughness={1} transparent={opacity < 1} opacity={opacity} flatShading />
    </instancedMesh>
  );
}

// A survey stake / traverse hub: a slim charcoal stake driven into the ground
// with a bright flagging ribbon tied near the top that flutters in the wind.
// Placed along the foreground traverse to read as a staked survey line tying
// the two stations together. The ribbon waves via a ref (no allocation).
function SurveyStake({ x, z, phase = 0, flag = C.sunbeam, opacity }) {
  const flagRef = React.useRef();
  const baseY = GROUND + terrainH(x, z);
  const stakeH = 0.34;
  useFrame((state) => {
    if (!flagRef.current) return;
    const t = state.clock.elapsedTime;
    const gust = windGust(t);
    // ribbon streams and flutters; amplitude swells with the shared gust so it
    // breathes in step with the trees and grass.
    flagRef.current.rotation.y = phase + (0.5 + 0.5 * gust) * 0.6 * Math.sin(t * 3.4 + phase);
    flagRef.current.rotation.z = -0.5 + 0.18 * Math.sin(t * 4.2 + phase * 1.7);
  });
  return (
    <group position={[x, baseY, z]}>
      {/* charcoal stake */}
      <mesh position={[0, stakeH / 2, 0]} rotation={[0.06, 0, 0.04]} castShadow>
        <cylinderGeometry args={[0.012, 0.016, stakeH, 6]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.85} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
      {/* fluttering flagging ribbon tied near the top */}
      <group ref={flagRef} position={[0, stakeH - 0.04, 0]}>
        <mesh position={[0.07, 0, 0]} castShadow>
          <boxGeometry args={[0.14, 0.05, 0.006]} />
          <meshStandardMaterial color={flag} metalness={0.05} roughness={0.8} transparent={opacity < 1} opacity={opacity} flatShading side={THREE.DoubleSide} />
        </mesh>
      </group>
    </group>
  );
}

export function SurveyScene({ opacity }) {
  const station = { x: -2.6, z: 0.5 };
  const rod = { x: 3.0, z: -0.4 };
  const rodBaseY = GROUND + terrainH(rod.x, rod.z);
  const stationBaseY = GROUND + terrainH(station.x, station.z);

  const rodGroupRef = React.useRef();
  const operatorRef = React.useRef();
  const reachArmRef = React.useRef();
  const sightRef = React.useRef();
  const sightMatRef = React.useRef(null);

  // Telescope objective lives in the station's yawed alidade group; recompute
  // its world position so the sight line truly emanates from the optical axis.
  const stHeadY = stationBaseY + 1.0;
  const yaw = Math.atan2(rod.x - station.x, rod.z - station.z);
  const objLocal = new THREE.Vector3(0, 0.27, 0.21); // matches telescope objective
  const objWorld = objLocal
    .clone()
    .applyEuler(new THREE.Euler(0, yaw, 0))
    .add(new THREE.Vector3(station.x, stHeadY + 0.09, station.z));

  // Pre-allocated scratch for the per-frame sight-line orientation (no
  // allocation inside useFrame). The line is a unit cylinder we translate,
  // rotate, and stretch each frame to span objective → live rod face.
  const sightFrom = React.useMemo(() => objWorld.clone(), [objWorld]);
  const sightTo = React.useMemo(() => new THREE.Vector3(), []);
  const sightMid = React.useMemo(() => new THREE.Vector3(), []);
  const sightDir = React.useMemo(() => new THREE.Vector3(), []);
  const sightUp = React.useMemo(() => new THREE.Vector3(0, 1, 0), []);
  const sightQuat = React.useMemo(() => new THREE.Quaternion(), []);

  // The rod-face target in the rod group's LOCAL space: on the face toward the
  // station (-x side of the white rod) at a readable graduation between the
  // foot blocks. Transformed to world by the live rod group matrix each frame
  // so the laser keeps landing true on the rod even as it plumbs/drifts.
  const rodFaceLocal = React.useMemo(() => new THREE.Vector3(-0.05, 1.05, 0), []);

  // Crew micro-motion + live-shot pulse. Tiny amplitudes so it reads as
  // steadying / breathing, not swaying.
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (rodGroupRef.current) {
      // steady plumbing sway, perceptible at this zoom
      const baseTilt = 0.03 * Math.sin(t * 1.3);
      // periodic plumb correction: a clear tilt-back every ~5s. A narrow
      // gaussian bump reads as the rodperson nudging the rod true, then
      // settling — now at a higher amplitude so it reads in a quick glance.
      const cyc = (t % 5.0) - 1.2; // peak ~1.2s into each cycle
      const bump = Math.exp(-(cyc * cyc) / 0.18);
      const correct = -0.085 * bump * Math.sin(t * 2.4);
      rodGroupRef.current.rotation.z = baseTilt + correct;
      rodGroupRef.current.rotation.x = 0.016 * Math.sin(t * 0.9 + 0.7);
      // a small arm/shoulder steadying adjustment synced to the correction:
      // the whole rod group nudges laterally a touch as the rodperson re-plumbs.
      rodGroupRef.current.position.x = rod.x + 0.03 * bump * Math.sin(t * 2.4 + 0.5);
    }
    if (operatorRef.current) {
      // subtle breathing rise about the group's base (already at stationBaseY)
      operatorRef.current.position.y = stationBaseY + 0.022 * Math.sin(t * 1.6);
      // the operator periodically reaches for a focus/tangent knob: a brief
      // downward dip + lean-in on a ~7s cycle (gaussian bump), reading as the
      // instrument being actively worked.
      const fcyc = (t % 7.0) - 3.0;
      const reach = Math.exp(-(fcyc * fcyc) / 0.4);
      operatorRef.current.position.y -= 0.05 * reach;
      operatorRef.current.position.z = station.z + 0.05 * reach;
      // articulate a dedicated forearm down to the focus/tangent knob in sync
      // with the reach beat, so the instrument reads as actively worked rather
      // than the whole body just dipping.
      if (reachArmRef.current) {
        reachArmRef.current.rotation.x = -0.2 - 0.9 * reach;
      }
    }
    // Orient the sight line each frame so it runs from the telescope objective
    // to the rod face's TRUE world position (the rod group plumbs and drifts at
    // runtime). Transform the local rod-face point by the rod group's live world
    // matrix, then translate/rotate/stretch the unit cylinder to span the gap.
    if (sightRef.current && rodGroupRef.current) {
      rodGroupRef.current.updateMatrixWorld();
      sightTo.copy(rodFaceLocal).applyMatrix4(rodGroupRef.current.matrixWorld);
      // matrixWorld includes the parent group's y+0.15 offset; objWorld is in
      // the parent group's local space, so add the same offset to keep both
      // endpoints in one coordinate space (the sight mesh is a child of the
      // parent group, so we want parent-local coords → subtract the 0.15 back).
      sightTo.y -= 0.15;
      sightMid.addVectors(sightFrom, sightTo).multiplyScalar(0.5);
      sightDir.subVectors(sightTo, sightFrom);
      const len = sightDir.length();
      sightDir.normalize();
      sightQuat.setFromUnitVectors(sightUp, sightDir);
      sightRef.current.position.copy(sightMid);
      sightRef.current.quaternion.copy(sightQuat);
      sightRef.current.scale.set(1, len, 1);
    }
    // pulse the laser emissive subtly
    if (!sightMatRef.current && sightRef.current && sightRef.current.material) {
      sightMatRef.current = sightRef.current.material;
    }
    if (sightMatRef.current) {
      sightMatRef.current.emissiveIntensity = 0.7 + 0.1 * Math.sin(t * 2);
    }
  });

  return (
    <group position={[0, 0.15, 0]}>
      <Terrain opacity={opacity} />

      {/* low trees/shrubs dressing the green lobe; off the worn path and clear
          of the sight line + frame edges. Bigger now so the landform gains
          scale, with a small stand clustered toward the rodperson so the right
          half no longer reads sparse. Per-index phase for natural wind; the
          back-row crowns drift on the steadier "distant" breeze layer. */}
      <Tree x={1.9} z={-1.55} scale={1.28} phase={0.0} distant opacity={opacity} />
      <Tree x={3.35} z={-1.65} scale={1.05} phase={1.7} distant opacity={opacity} />
      <Tree x={0.7} z={-1.75} scale={0.86} phase={3.1} distant opacity={opacity} />
      <Tree x={2.7} z={1.5} scale={0.95} phase={4.4} opacity={opacity} />
      <Tree x={-3.55} z={-1.5} scale={0.8} phase={2.2} distant opacity={opacity} />
      {/* small stand clustered near the rodperson (rod at x=3.0, z=-0.4) */}
      <Tree x={4.0} z={0.55} scale={0.92} phase={5.3} opacity={opacity} />
      <Tree x={3.7} z={1.15} scale={0.74} phase={2.9} opacity={opacity} />

      {/* drifting sky — settled lower and flatter, with some z-depth variation,
          so the band feels atmospheric and belongs above the terrain rather
          than floating as a detached layer */}
      <Cloud y={2.3} z={-2.2} speed={0.16} offset={0} scale={1.15} opacity={opacity} />
      <Cloud y={2.45} z={-2.7} speed={0.11} offset={5.5} scale={0.9} opacity={opacity} />
      <Cloud y={2.18} z={-1.7} speed={0.2} offset={9.0} scale={0.75} opacity={opacity} />
      {/* a higher, thinner wisp drifting faster the other way for sky parallax */}
      <Cloud y={2.75} z={-3.1} speed={-0.27} offset={3.0} scale={0.62} opacity={opacity} />
      <Birds opacity={opacity} />

      <TotalStation
        x={station.x}
        z={station.z}
        opacity={opacity}
        look={[rod.x, rodBaseY + 1.05, rod.z]}
      />

      {/* rod + rodperson share a steadying group so they plumb together */}
      <group ref={rodGroupRef} position={[rod.x, rodBaseY, rod.z]}>
        <StadiaRod opacity={opacity} />
        <Person
          position={[-0.16, 0, 0.04]}
          rotation={[0, -Math.PI / 2 - 0.12, 0]}
          scale={0.62}
          vest={C.steelLt}
          hardHat={C.sunbeam}
          armPose="hold"
          opacity={opacity}
        />
      </group>

      {/* optical line of sight: a thin ember laser (a line, not an arrow) that
          runs from the telescope objective and terminates cleanly on the rod
          face. A unit-height cylinder re-oriented every frame in useFrame so it
          tracks the rod's live plumbing/drift and always lands true on the rod
          between graduation blocks. */}
      <mesh ref={sightRef}>
        <cylinderGeometry args={[0.009, 0.009, 1, 8]} />
        <meshStandardMaterial
          color={C.ember}
          emissive={C.ember}
          emissiveIntensity={0.7}
          metalness={0.2}
          roughness={0.5}
          transparent
          opacity={opacity * 0.9}
        />
      </mesh>

      {/* instrument operator leaning into the eyepiece (breathing lean). The
          group carries the subtle vertical breathing; Person itself is a plain
          primitive that doesn't forward a ref. */}
      <group ref={operatorRef} position={[station.x - 0.46, stationBaseY, station.z + 0.02]}>
        <Person
          position={[0, 0, 0]}
          rotation={[0, Math.PI / 2 + 0.1, 0]}
          scale={0.72}
          vest={C.ember}
          ponytail
          hardHat={C.sunbeam}
          lean={0.62}
          armPose="sight"
          opacity={opacity}
        />
        {/* a dedicated reaching forearm to the focus/tangent knob: hinges at the
            shoulder (toward +x, the instrument side) and dips on the reach beat.
            Ember sleeve to read as the operator's arm, charcoal hand at the tip. */}
        <group ref={reachArmRef} position={[0.34, 0.78, 0.06]} rotation={[-0.2, 0, 0]}>
          <mesh position={[0.12, -0.02, 0]} rotation={[0, 0, -Math.PI / 2.2]} castShadow>
            <cylinderGeometry args={[0.026, 0.03, 0.34, 8]} />
            <meshStandardMaterial color={C.ember} metalness={0.1} roughness={0.7} transparent={opacity < 1} opacity={opacity} flatShading />
          </mesh>
          <mesh position={[0.26, -0.06, 0]} castShadow>
            <sphereGeometry args={[0.045, 8, 6]} />
            <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} transparent={opacity < 1} opacity={opacity} flatShading />
          </mesh>
        </group>
      </group>

      {/* staked traverse hubs marching across the foreground bare path, tying
          the station and rod stations together with bright flagging — reads as
          a real survey line and uses the otherwise-empty center */}
      <SurveyStake x={-1.5} z={1.1} phase={0.0} flag={C.sunbeam} opacity={opacity} />
      <SurveyStake x={-0.55} z={1.0} phase={1.4} flag={C.ember} opacity={opacity} />
      <SurveyStake x={0.45} z={0.85} phase={2.7} flag={C.sunbeam} opacity={opacity} />

      {/* a field dog on open GREEN ground (off the bare path), broadside to
          camera so its tan coat separates by hue and its silhouette reads as a
          charming focal accent */}
      <Dog x={0.7} z={1.45} opacity={opacity} />

      {/* a scatter of grass tufts across the worn-path foreground, grounding the
          dog and crew; per-tuft phase + the shared gust make the patch breathe */}
      <GrassTuft x={station.x + 1.15} z={station.z + 1.45} scale={1.05} phase={0.4} opacity={opacity} />
      <GrassTuft x={station.x + 2.1} z={station.z + 1.0} scale={0.9} phase={2.6} opacity={opacity} />
      <GrassTuft x={station.x + 0.4} z={station.z + 1.75} scale={0.95} phase={1.5} opacity={opacity} />
      <GrassTuft x={station.x + 2.85} z={station.z + 1.55} scale={0.8} phase={4.1} opacity={opacity} />
      <GrassTuft x={station.x + 1.6} z={station.z + 0.55} scale={0.72} phase={5.2} opacity={opacity} />
    </group>
  );
}

// Graded ground with mass: a displaced top surface plus an extruded soil skirt
// in a muted earth-gray, so the silhouette reads as a landform section rather
// than a floating sheet.
function Terrain({ opacity }) {
  const topRef = React.useRef();
  const W = 9.0, D = 4.6, SX = 90, SY = 48;
  React.useEffect(() => {
    const g = topRef.current;
    if (!g) return;
    const pos = g.attributes.position;
    for (let i = 0; i < pos.count; i++) {
      const x = pos.getX(i);
      const y = pos.getY(i);
      // Flatten displacement near the front/back edges so the slab silhouette
      // stays clean and reads as a graded section.
      const edge = 1 - Math.min(1, Math.abs(y) / (D / 2));
      const damp = 0.35 + 0.65 * edge;
      pos.setZ(i, terrainH(x, -y) * damp);
    }
    pos.needsUpdate = true;
    g.computeVertexNormals();
  }, []);

  // Soil skirt: a slab hung beneath the surface giving the landform thickness.
  const skirtY = -0.9 - 0.32;
  return (
    <group>
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.9, 0]} receiveShadow castShadow>
        <planeGeometry ref={topRef} args={[W, D, SX, SY]} />
        <meshStandardMaterial color="#5f7d5a" metalness={0.1} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
      {/* earth-gray soil mass under the surface */}
      <mesh position={[0, skirtY, 0]} receiveShadow castShadow>
        <boxGeometry args={[W * 0.985, 0.62, D * 0.96]} />
        <meshStandardMaterial color="#6b5f52" metalness={0.05} roughness={1} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
      {/* thinner darker base course for a layered cut look */}
      <mesh position={[0, skirtY - 0.34, 0]} receiveShadow castShadow>
        <boxGeometry args={[W * 0.95, 0.18, D * 0.92]} />
        <meshStandardMaterial color="#574d42" metalness={0.05} roughness={1} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
    </group>
  );
}
