import React from 'react';
import * as THREE from 'three';
import { useFrame } from '@react-three/fiber';
import { C, Box, Node, Member, Person } from './primitives';

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
function Tree({ x, z, scale = 1, phase = 0, opacity }) {
  const canopyRef = React.useRef();
  const topRef = React.useRef();
  const baseY = GROUND + terrainH(x, z);
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (canopyRef.current) {
      // larger, perceptible wind sway of the whole crown
      canopyRef.current.rotation.z = 0.07 * Math.sin(t * 0.8 + phase);
      canopyRef.current.rotation.x = 0.05 * Math.sin(t * 0.65 + phase * 1.3);
    }
    if (topRef.current) {
      // upper cluster lags in phase so the crown deforms rather than rotating
      // rigidly — the top tuft trails the main mass in the gust.
      topRef.current.rotation.z = 0.06 * Math.sin(t * 0.95 + phase + 0.9);
      topRef.current.rotation.x = 0.04 * Math.sin(t * 0.72 + phase * 1.3 + 0.6);
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
// bird is THREE instanced boxes: a central body plus two stretched wings held
// at a deep dihedral, so each reads as an unmistakable bird silhouette even in
// a frozen frame. The whole flock shares ONE heading and travels as a tight
// cluster (lead bird out front, the rest tucked behind in offset rows) across
// the upper frame, wrapping seamlessly. One extra bird glides far back for
// depth. Wings flap with a clear dihedral; phase varies per bird so the flock
// shimmers rather than pumping in lockstep.
const BIRD_FLAP = 5; // flapping birds in the formation
const BIRD_COUNT = BIRD_FLAP + 1; // + 1 distant gliding bird
const PARTS_PER_BIRD = 3; // body + 2 wings
// Formation offsets (along/across heading), lead bird first → trailing V rows.
const FORMATION = [
  [0.0, 0.0],
  [-0.34, 0.30],
  [-0.34, -0.30],
  [-0.7, 0.58],
  [-0.7, -0.58],
];
function Birds({ opacity }) {
  const ref = React.useRef();
  const dummy = React.useMemo(() => new THREE.Object3D(), []);
  const total = BIRD_COUNT * PARTS_PER_BIRD;
  useFrame((state) => {
    if (!ref.current) return;
    const t = state.clock.elapsedTime;
    // shared flock travel: one slow arc, one common heading
    const fa = t * 0.2 + 1.0;
    const fHeading = fa + Math.PI / 2;
    const cosH = Math.cos(fHeading);
    const sinH = Math.sin(fHeading);
    const fcx = 3.2 * Math.cos(fa) - 0.4;
    const fcy = 2.05 + 0.18 * Math.sin(fa * 1.2);
    const fcz = 0.4 + 1.2 * Math.sin(fa);
    for (let b = 0; b < BIRD_COUNT; b++) {
      const glider = b === BIRD_COUNT - 1;
      let cx, cy, cz, flap, heading, half, lead;
      if (glider) {
        // distant slower glide, gentle fixed dihedral, higher + further back
        const a = t * 0.1 + 1.3;
        heading = a + Math.PI / 2;
        cx = 3.6 * Math.cos(a) + 0.3;
        cy = 2.55 + 0.1 * Math.sin(a);
        cz = -1.0 + 1.0 * Math.sin(a);
        flap = 0.38;
        half = 0.13;
        lead = false;
      } else {
        // tucked into the shared formation, slight individual flap phase
        const off = FORMATION[b];
        // along-heading and across-heading offsets in the xz plane
        cx = fcx + off[0] * sinH + off[1] * cosH;
        cz = fcz + off[0] * cosH - off[1] * sinH;
        cy = fcy + 0.04 * Math.sin(t * 1.5 + b);
        heading = fHeading;
        flap = 0.7 * Math.sin(t * 6 + b * 1.1) + 0.5; // deep, clear V dihedral
        lead = b === 0;
        half = lead ? 0.2 : 0.16; // lead bird a touch larger
      }
      const ch = Math.cos(heading);
      const sh = Math.sin(heading);
      // body: a small box at the bird center, aligned to heading
      dummy.position.set(cx, cy, cz);
      dummy.rotation.set(0, heading, 0);
      dummy.scale.set(0.06, 0.03, half * 0.7);
      dummy.updateMatrix();
      ref.current.setMatrixAt(b * PARTS_PER_BIRD, dummy.matrix);
      // two wings, swept back from the body at the flap dihedral
      for (let w = 0; w < 2; w++) {
        const side = w === 0 ? 1 : -1;
        dummy.position.set(cx + side * half * ch, cy + 0.01, cz + side * half * sh);
        dummy.rotation.set(0, heading, side * flap);
        dummy.scale.set(glider ? 0.26 : 0.3, 0.02, 0.05);
        dummy.updateMatrix();
        ref.current.setMatrixAt(b * PARTS_PER_BIRD + 1 + w, dummy.matrix);
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
  const headRef = React.useRef();
  const tailRef = React.useRef();
  const baseY = GROUND + terrainH(x, z);
  const mat = (
    <meshStandardMaterial color={DOG} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
  );
  useFrame((state) => {
    const t = state.clock.elapsedTime;
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
    <group position={[x, baseY, z]} rotation={[0, Math.PI * 0.5, 0]} scale={0.72}>
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
        r: 0.02 + 0.05 * ((i * 7) % GRASS_BLADES) / GRASS_BLADES,
        h: 0.16 + 0.06 * ((i * 3) % 5) / 5,
        ph: i * 1.3,
      })),
    [],
  );
  useFrame((state) => {
    if (!ref.current) return;
    const t = state.clock.elapsedTime;
    for (let i = 0; i < GRASS_BLADES; i++) {
      const bl = blades[i];
      const sway = 0.22 * Math.sin(t * 1.6 + phase + bl.ph);
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

export function SurveyScene({ opacity }) {
  const station = { x: -2.6, z: 0.5 };
  const rod = { x: 3.0, z: -0.4 };
  const rodBaseY = GROUND + terrainH(rod.x, rod.z);
  const stationBaseY = GROUND + terrainH(station.x, station.z);

  const rodGroupRef = React.useRef();
  const operatorRef = React.useRef();
  const sightGroupRef = React.useRef();
  const sightMatRef = React.useRef(null);
  const hitMatRef = React.useRef();

  // Telescope objective lives in the station's yawed alidade group; recompute
  // its world position so the sight line truly emanates from the optical axis.
  const stHeadY = stationBaseY + 1.0;
  const yaw = Math.atan2(rod.x - station.x, rod.z - station.z);
  const objLocal = new THREE.Vector3(0, 0.27, 0.21); // matches telescope objective
  const objWorld = objLocal
    .clone()
    .applyEuler(new THREE.Euler(0, yaw, 0))
    .add(new THREE.Vector3(station.x, stHeadY + 0.09, station.z));

  // Land the sight line on the rod FACE (-x side, toward the station) at a
  // readable graduation height. The line stays anchored here; only the station
  // body micro-aims, so the laser keeps landing true on the rod.
  const rodFace = [rod.x - 0.04, rodBaseY + 1.05, rod.z];

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
    }
    // find the sight-line mesh material once, then pulse its emissive
    if (!sightMatRef.current && sightGroupRef.current) {
      sightGroupRef.current.traverse((o) => {
        if (o.isMesh && o.material) sightMatRef.current = o.material;
      });
    }
    if (sightMatRef.current) {
      sightMatRef.current.emissiveIntensity = 0.8 + 0.15 * Math.sin(t * 2);
    }
    if (hitMatRef.current) {
      // the hit glow pulses in step with the beam, slightly out of phase so it
      // shimmers like a spot landing true on the rod face
      hitMatRef.current.emissiveIntensity = 1.0 + 0.4 * Math.sin(t * 2 + 0.6);
    }
  });

  return (
    <group position={[0, 0.15, 0]}>
      <Terrain opacity={opacity} />

      {/* low trees/shrubs dressing the green lobe; off the worn path and clear
          of the sight line + frame edges. Per-index phase for natural wind. */}
      <Tree x={1.9} z={-1.55} scale={1.05} phase={0.0} opacity={opacity} />
      <Tree x={3.4} z={-1.7} scale={0.85} phase={1.7} opacity={opacity} />
      <Tree x={0.7} z={-1.75} scale={0.7} phase={3.1} opacity={opacity} />
      <Tree x={2.7} z={1.55} scale={0.78} phase={4.4} opacity={opacity} />
      <Tree x={-3.6} z={-1.5} scale={0.66} phase={2.2} opacity={opacity} />

      {/* drifting sky — settled lower and flatter, with some z-depth variation,
          so the band feels atmospheric and belongs above the terrain rather
          than floating as a detached layer */}
      <Cloud y={2.3} z={-2.2} speed={0.16} offset={0} scale={1.15} opacity={opacity} />
      <Cloud y={2.45} z={-2.7} speed={0.11} offset={5.5} scale={0.9} opacity={opacity} />
      <Cloud y={2.18} z={-1.7} speed={0.2} offset={9.0} scale={0.75} opacity={opacity} />
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

      {/* optical line of sight: from the telescope objective to the rod face.
          Wrapped in a group so we can pulse the emissive without ref-forwarding
          into the shared primitive. */}
      <group ref={sightGroupRef}>
        <Member
          a={[objWorld.x, objWorld.y, objWorld.z]}
          b={rodFace}
          radius={0.01}
          color={C.ember}
          emissive={C.ember}
          opacity={opacity * 0.9}
        />
      </group>
      {/* a small ember hit-glow where the sight line lands on the rod face,
          pulsing with the beam to reinforce the shot landing true */}
      <mesh position={[rodFace[0] - 0.02, rodFace[1], rodFace[2]]}>
        <sphereGeometry args={[0.028, 12, 10]} />
        <meshStandardMaterial
          ref={hitMatRef}
          color={C.ember}
          emissive={C.ember}
          emissiveIntensity={1.0}
          metalness={0.1}
          roughness={0.5}
          transparent
          opacity={opacity * 0.92}
        />
      </mesh>

      {/* instrument operator leaning into the eyepiece (breathing lean). The
          group carries the subtle vertical breathing; Person itself is a plain
          primitive that doesn't forward a ref. */}
      <group ref={operatorRef} position={[station.x - 0.55, stationBaseY, station.z]}>
        <Person
          position={[0, 0, 0]}
          rotation={[0, Math.PI / 2 + 0.25, 0]}
          scale={0.62}
          vest={C.ember}
          ponytail
          hardHat={C.sunbeam}
          lean={0.5}
          armPose="sight"
          opacity={opacity}
        />
      </group>

      {/* a field dog on open green ground out from behind the operator, broadside
          to camera so its silhouette reads as a charming focal accent */}
      <Dog x={station.x + 1.6} z={station.z + 1.2} opacity={opacity} />

      {/* a couple of grass tufts enriching the foreground around the dog */}
      <GrassTuft x={station.x + 1.15} z={station.z + 1.45} scale={1.0} phase={0.4} opacity={opacity} />
      <GrassTuft x={station.x + 2.1} z={station.z + 1.0} scale={0.85} phase={2.6} opacity={opacity} />
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
