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
  // Tiny aim dither so the instrument reads as being fine-aimed / settling.
  useFrame((state) => {
    if (!alidadeRef.current) return;
    const t = state.clock.elapsedTime;
    alidadeRef.current.rotation.y = yaw + 0.01 * Math.sin(t * 0.6);
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
      [0.45, 0.06, 0.05, 0.38],
      [-0.42, 0.04, -0.04, 0.34],
      [0.18, 0.16, 0.02, 0.3],
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
      {puffs.map((p, i) => (
        <mesh key={i} position={[p[0], p[1], p[2]]} scale={[1, 0.6, 1]}>
          <sphereGeometry args={[p[3], 12, 8]} />
          <meshStandardMaterial color={CLOUD} metalness={0} roughness={1} transparent opacity={op} flatShading />
        </mesh>
      ))}
    </group>
  );
}

// A small flock of birds: unmistakable V shapes (two stretched wing boxes per
// bird) instanced along a slow looping arc high in the frame, on a z band well
// in FRONT of the cloud band so they never overlap the puffs. Each bird leads
// by a phase offset; a clear flap keeps motion obvious even in a still. One
// extra bird glides on a slower, separate arc for depth.
const BIRD_FLAP = 4; // flapping birds in the flock
const BIRD_COUNT = BIRD_FLAP + 1; // + 1 distant gliding bird
function Birds({ opacity }) {
  const ref = React.useRef();
  const dummy = React.useMemo(() => new THREE.Object3D(), []);
  // one instanced mesh of wing boxes, two wings per bird.
  const total = BIRD_COUNT * 2;
  useFrame((state) => {
    if (!ref.current) return;
    const t = state.clock.elapsedTime;
    for (let b = 0; b < BIRD_COUNT; b++) {
      const glider = b === BIRD_COUNT - 1;
      const ph = (b / BIRD_FLAP) * Math.PI * 2;
      let cx, cy, cz, flap, heading;
      if (glider) {
        // distant slower glide, no flap, higher + further back than the flock
        const a = t * 0.1 + 1.3;
        cx = 3.6 * Math.cos(a) + 0.3;
        cy = 2.5 + 0.1 * Math.sin(a);
        cz = -0.6 + 1.0 * Math.sin(a);
        flap = 0.32; // fixed gentle dihedral
        heading = a + Math.PI / 2;
      } else {
        // slow looping arc across the upper frame, in front of the clouds
        const a = t * 0.2 + ph;
        cx = 3.2 * Math.cos(a) - 0.4;
        cy = 1.95 + 0.2 * Math.sin(a * 1.3 + ph);
        cz = 0.4 + 1.2 * Math.sin(a); // z band ~ -0.8 .. +1.6, ahead of clouds
        flap = 0.65 * Math.sin(t * 6 + ph) + 0.35; // pronounced wing dihedral
        heading = a + Math.PI / 2;
      }
      const half = glider ? 0.13 : 0.16; // wing half-span (bigger, clearer V)
      for (let w = 0; w < 2; w++) {
        const side = w === 0 ? 1 : -1;
        dummy.position.set(cx + side * half * Math.cos(heading), cy, cz + side * half * Math.sin(heading));
        dummy.rotation.set(0, heading, side * flap);
        dummy.scale.set(glider ? 0.26 : 0.3, 0.022, 0.05);
        dummy.updateMatrix();
        ref.current.setMatrixAt(b * 2 + w, dummy.matrix);
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

// A small low-poly dog seated near the operator: capsule body, box legs, sphere
// head with stub ears. Gentle head bob + tail wag via ref rotation. Scaled
// small so it never crowds the crew.
function Dog({ x, z, opacity }) {
  const headRef = React.useRef();
  const tailRef = React.useRef();
  const baseY = GROUND + terrainH(x, z);
  const mat = (
    <meshStandardMaterial color={DOG} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
  );
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (headRef.current) headRef.current.rotation.x = 0.08 * Math.sin(t * 1.1);
    if (tailRef.current) tailRef.current.rotation.z = 0.5 * Math.sin(t * 4.0);
  });
  return (
    <group position={[x, baseY, z]} rotation={[0, Math.PI * 0.65, 0]} scale={0.57}>
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

export function SurveyScene({ opacity }) {
  const station = { x: -2.6, z: 0.5 };
  const rod = { x: 3.0, z: -0.4 };
  const rodBaseY = GROUND + terrainH(rod.x, rod.z);
  const stationBaseY = GROUND + terrainH(station.x, station.z);

  const rodGroupRef = React.useRef();
  const operatorRef = React.useRef();
  const sightGroupRef = React.useRef();
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

  // Land the sight line on the rod FACE (-x side, toward the station) at a
  // readable graduation height. The line stays anchored here; only the station
  // body micro-aims, so the laser keeps landing true on the rod.
  const rodFace = [rod.x - 0.04, rodBaseY + 1.05, rod.z];

  // Crew micro-motion + live-shot pulse. Tiny amplitudes so it reads as
  // steadying / breathing, not swaying.
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (rodGroupRef.current) {
      // steady plumbing sway, slightly more perceptible than before
      const baseTilt = 0.022 * Math.sin(t * 1.3);
      // occasional lateral plumbing correction: a brief tilt-back every ~5s.
      // A narrow gaussian bump on a 5s cycle reads as the rodperson nudging the
      // rod true, then settling — catches the eye within a quick glance.
      const cyc = (t % 5.0) - 1.2; // peak ~1.2s into each cycle
      const correct = -0.05 * Math.exp(-(cyc * cyc) / 0.18) * Math.sin(t * 2.4);
      rodGroupRef.current.rotation.z = baseTilt + correct;
      rodGroupRef.current.rotation.x = 0.014 * Math.sin(t * 0.9 + 0.7);
    }
    if (operatorRef.current) {
      // subtle breathing rise about the group's base (already at stationBaseY)
      operatorRef.current.position.y = stationBaseY + 0.018 * Math.sin(t * 1.6);
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

      {/* drifting sky — pushed higher and further back so the cloud band sits
          clearly behind/above the bird flight band */}
      <Cloud y={2.55} z={-2.3} speed={0.16} offset={0} scale={1.1} opacity={opacity} />
      <Cloud y={2.78} z={-2.6} speed={0.11} offset={5.5} scale={0.85} opacity={opacity} />
      <Cloud y={2.4} z={-2.0} speed={0.2} offset={9.0} scale={0.7} opacity={opacity} />
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

      {/* a dog waiting near the crew, seated on the green lobe (not dark soil)
          so its warm tan coat reads clearly */}
      <Dog x={station.x + 1.0} z={station.z + 0.85} opacity={opacity} />
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
