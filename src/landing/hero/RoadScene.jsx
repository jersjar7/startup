import React from 'react';
import * as THREE from 'three';
import { useFrame } from '@react-three/fiber';
import { C, Beam, Box } from './primitives';

// FE topic: Transportation — a roadway carried over an earth CREST VERTICAL
// CURVE. The asphalt deck rides a parabolic crest seated into continuous
// embankment side-slopes (not a bridge span). The vertical-curve geometry is
// felt through the parabolic profile itself; it is now a LIVING road —
// vehicles drive up and over the crest in both lanes (each pitched to the
// local grade), one truck for size variety, roadside trees sway in the wind, a
// streetlight stands near the crest, and a pedestrian walks the shoulder.
// An oncoming car cresting the apex conveys the restricted sight distance that
// the old diagrammatic arrows used to annotate. `opacity` cross-fades every
// material.

// Brand muted-earth grays for the embankment. SOIL lightened toward a sunlit
// compacted-earth tone (the old #8a7c68 read muddy under this lighting); a
// lighter lit-crown tone and a darker toe tone give the slope tonal depth.
const SOIL = '#9d8c73';      // sunlit earth (base / mid slope)
const SOIL_LT = '#a99878';   // lit crown / upper face (low contrast w/ SOIL)
const SOIL_DK = '#8a7a64';   // shaded toe / grade break (gentle, not muddy)
const ROCK = '#857a6c';      // riprap / loose rock at the toe
// Muted foliage greens (kept earthy, never neon).
const LEAF = '#4f6b4a';
const LEAF_DK = '#3c5639';
const LEAF_BROAD = '#5c7350'; // rounder broadleaf canopy
const TRUNK = '#5a4632';

// A small reusable vehicle (module-scope so its type is stable across the
// parent's opacity cross-fade re-renders). Built around its local origin; the
// traffic system positions/pitches the whole group via ref each frame.
const Vehicle = React.forwardRef(function Vehicle({ color, truck, opacity, tailRefCb }, ref) {
  const L = truck ? 0.92 : 0.66;        // body length (x)
  const W = truck ? 0.46 : 0.42;        // width (z)
  const bodyH = truck ? 0.2 : 0.14;
  const cabH = truck ? 0.26 : 0.15;
  const wheelR = truck ? 0.1 : 0.085;
  const wx = L * 0.32, wz = W * 0.5 - 0.02;
  const met = 0.45, rgh = 0.38;
  return (
    <group ref={ref}>
      {/* lower body */}
      <Box position={[0, 0, 0]} size={[L, bodyH, W]} color={color} opacity={opacity} metalness={met} roughness={rgh} />
      {/* cabin: trucks get a tall box cab forward + long flat cargo deck */}
      {truck ? (
        <>
          <Box position={[L * 0.3, bodyH / 2 + cabH / 2, 0]} size={[L * 0.3, cabH, W * 0.92]} color={color} opacity={opacity} metalness={met} roughness={rgh} />
          <Box position={[-L * 0.18, bodyH / 2 + 0.12, 0]} size={[L * 0.55, 0.18, W * 0.96]} color="#9a9486" opacity={opacity} metalness={0.2} roughness={0.7} />
          <Box position={[L * 0.45, bodyH / 2 + cabH * 0.6, 0]} size={[0.04, cabH * 0.55, W * 0.78]} rotation={[0, 0, -0.35]} color={C.info} opacity={opacity} metalness={0.3} roughness={0.25} />
        </>
      ) : (
        <>
          <Box position={[-0.05, bodyH, 0]} size={[L * 0.52, cabH, W * 0.86]} color={color} opacity={opacity} metalness={met} roughness={rgh} />
          <Box position={[L * 0.2, bodyH, 0]} size={[0.04, cabH * 0.8, W * 0.8]} rotation={[0, 0, -0.5]} color={C.info} opacity={opacity} metalness={0.3} roughness={0.25} />
          <Box position={[-0.05, bodyH + 0.01, W * 0.44]} size={[L * 0.4, cabH * 0.66, 0.01]} color="#1c1c1c" opacity={opacity} metalness={0.4} roughness={0.3} />
          <Box position={[-0.05, bodyH + 0.01, -W * 0.44]} size={[L * 0.4, cabH * 0.66, 0.01]} color="#1c1c1c" opacity={opacity} metalness={0.4} roughness={0.3} />
        </>
      )}
      {/* tail-lights: emissive ember quads at the rear; their emissive rises as
          a brake flare while the vehicle pitches down the far side of the crest */}
      {[[W * 0.32], [-W * 0.32]].map((tz, i) => (
        <mesh key={`tl${i}`} position={[-L * 0.5, 0, tz[0]]}>
          <boxGeometry args={[0.015, 0.05, 0.07]} />
          <meshStandardMaterial
            ref={(el) => tailRefCb && tailRefCb(i, el)}
            color={C.ember}
            emissive={C.ember}
            emissiveIntensity={0.25 * opacity}
            metalness={0.2}
            roughness={0.4}
            transparent={opacity < 1}
            opacity={opacity}
          />
        </mesh>
      ))}
      {/* headlights: pale emissive quads at the FRONT so travel direction is
          unambiguous (the oncoming car visibly approaches the crest) */}
      {[[W * 0.32], [-W * 0.32]].map((hz, i) => (
        <mesh key={`hl${i}`} position={[L * 0.5, 0.01, hz[0]]}>
          <boxGeometry args={[0.015, 0.05, 0.07]} />
          <meshStandardMaterial color="#fffaf0" emissive="#fff3d6" emissiveIntensity={0.9 * opacity} metalness={0.2} roughness={0.3} transparent={opacity < 1} opacity={opacity} />
        </mesh>
      ))}
      {/* wheels tucked under the body, with steel hubs */}
      {[[wx, wz], [wx, -wz], [-wx, wz], [-wx, -wz]].map((w, i) => (
        <group key={i} position={[w[0], -bodyH * 0.55, w[1]]} rotation={[Math.PI / 2, 0, 0]}>
          <mesh castShadow>
            <cylinderGeometry args={[wheelR, wheelR, 0.06, 16]} />
            <meshStandardMaterial color="#1b1b1b" metalness={0.2} roughness={0.7} transparent={opacity < 1} opacity={opacity} />
          </mesh>
          <mesh position={[0, w[1] > 0 ? 0.031 : -0.031, 0]}>
            <cylinderGeometry args={[wheelR * 0.5, wheelR * 0.5, 0.006, 14]} />
            <meshStandardMaterial color={C.steelLt} metalness={0.8} roughness={0.35} transparent={opacity < 1} opacity={opacity} />
          </mesh>
        </group>
      ))}
    </group>
  );
});

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
  const crest = data.crest, dcrest = data.dcrest;
  const x0 = data.x0, x1 = data.x1, span = x1 - x0;

  // Battered (~2:1) earth fill. Crown half-width = topHalf at deck level; the
  // side-slope kicks out by SLOPE * height on each side down to grade. This lets
  // us sample the slope SURFACE z at any (x, y) so trees/grass sit ON the fill.
  const topHalf = halfW + 0.06;   // crown half-width at deck level
  const SLOPE = 0.55;             // run/rise (~2:1 batter)
  // Half-width of the trapezoid at a given world Y for a deck top at topY.
  const fillHalfAtY = (topY, y) => topHalf + SLOPE * Math.max(0, topY - y);
  // Seat a roadside object onto the slope face: given world x and how far down
  // the slope (dropY below crest) we want it, return its z on the +z face.
  const seatOnSlope = (x, dropY, zSign) => {
    const topY = crest(x);
    const y = topY - dropY;
    const z = zSign * fillHalfAtY(topY, y);
    return [y, z];
  };

  // A trapezoidal earth-fill cross-section under one deck segment: a 4-sided
  // prism (extruded along x) whose top edge = roadway crown and whose base
  // batters out to grade on both sides. Reads as a graded side-slope, not a wall.
  const Embankment = ({ s, idx }) => {
    const xa = s[0][0], xb = s[1][0];
    const xm = (xa + xb) / 2;
    const topY = (s[0][1] + s[1][1]) / 2;
    const h = topY - groundY;
    const len = Math.abs(xb - xa) + 0.06; // slight overlap to hide seams
    const baseHalf = topHalf + SLOPE * h;  // wider at grade
    // crown break: where the lit upper face hands off to the mid slope
    const crownY = topY - h * 0.34;
    const crownHalf = topHalf + SLOPE * (topY - crownY);
    // Lower trapezoid (mid slope -> toe) and upper crown band, so we get a
    // two-tone vertical (lit crown vs darker body) instead of a flat slab.
    const lower = React.useMemo(() => {
      const sh = new THREE.Shape();
      sh.moveTo(-crownHalf, crownY);
      sh.lineTo(crownHalf, crownY);
      sh.lineTo(baseHalf, groundY);
      sh.lineTo(-baseHalf, groundY);
      sh.closePath();
      return sh;
    }, [crownY, crownHalf, baseHalf]);
    const upper = React.useMemo(() => {
      const sh = new THREE.Shape();
      sh.moveTo(-topHalf, topY);
      sh.lineTo(topHalf, topY);
      sh.lineTo(crownHalf, crownY);
      sh.lineTo(-crownHalf, crownY);
      sh.closePath();
      return sh;
    }, [topY, crownY, crownHalf]);
    // No per-segment tonal jitter: every segment shares the SAME body/crown
    // tone so adjacent segments blend into one continuous graded slope instead
    // of alternating light/dark vertical columns. The only tonal variation is
    // the single horizontal crown band (lit upper face vs. mid-slope body),
    // which reads as depth, not corduroy. Lower face is smooth-shaded.
    return (
      <group position={[xm - len / 2, 0, 0]} rotation={[0, Math.PI / 2, 0]}>
        <mesh castShadow receiveShadow>
          <extrudeGeometry args={[lower, { depth: len, bevelEnabled: false }]} />
          <meshStandardMaterial color={SOIL} metalness={0.05} roughness={0.97} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        <mesh position={[0, 0, 0.001]} castShadow receiveShadow>
          <extrudeGeometry args={[upper, { depth: len, bevelEnabled: false }]} />
          <meshStandardMaterial color={SOIL_LT} metalness={0.05} roughness={0.96} transparent={opacity < 1} opacity={opacity} />
        </mesh>
      </group>
    );
  };

  // ---- Living traffic system -------------------------------------------------
  // Each vehicle samples crest(x) for height and dcrest(x) for pitch so it hugs
  // and tilts with the road. x wraps x0..x1 for a seamless loop; phase varied by
  // index. Right lane (z=+0.45) travels +x, left lane (z=-0.45) travels -x.
  const VEHICLES = React.useMemo(() => ([
    // dir: +1 right lane, -1 left lane. speed in units/s. truck = taller/slower.
    { color: '#cf4b39', dir: +1, speed: 0.62, phase: 0.00, truck: false, z: 0.45 },
    { color: '#d9d3c4', dir: +1, speed: 0.55, phase: 0.46, truck: false, z: 0.45 },
    { color: '#3f5d6e', dir: +1, speed: 0.40, phase: 0.78, truck: true, z: 0.45 },
    { color: '#7c8a93', dir: -1, speed: 0.60, phase: 0.18, truck: false, z: -0.45 },
    { color: C.ember, dir: -1, speed: 0.52, phase: 0.62, truck: false, z: -0.45 },
  ]), []);

  const carRefs = React.useRef([]);
  const tailRefs = React.useRef([]); // tailRefs.current[vehicleIdx][lightIdx]
  const treeRefs = React.useRef([]);
  const lampRef = React.useRef();

  // Reusable scratch objects — allocate once, never inside the frame loop.
  const _euler = React.useMemo(() => new THREE.Euler(), []);
  const _m4 = React.useMemo(() => new THREE.Matrix4(), []);
  const _q = React.useMemo(() => new THREE.Quaternion(), []);
  const _pos = React.useMemo(() => new THREE.Vector3(), []);
  const _scl = React.useMemo(() => new THREE.Vector3(1, 1, 1), []);

  // Roadside trees rooted into the embankment side-slope. dropY = how far below
  // the local crest the base sits; zSign picks the +/- face. z is computed from
  // the slope surface so each tree sits ON the fill. Kept within frame envelope.
  // Clustered, mixed-species roadside trees. `broad` swaps the conifer cones
  // for a rounder broadleaf canopy. Nearest (camera-side, zSign -1) upscaled so
  // canopy sway reads at tile scale. Clusters: lower-left, mid, lower-right.
  // `lean` (radians) tilts the whole tree outward from the slope normal so it
  // doesn't read as a flat stamp; `gust` scales its wind response for variety.
  const TREES = React.useMemo(() => ([
    // lower-left cluster
    { x: -3.4, dropY: 1.7, zSign: -1, s: 1.14, phase: 0.0, broad: true, lean: 0.14, gust: 1.0 },
    { x: -3.0, dropY: 1.5, zSign: 1, s: 0.74, phase: 0.6, broad: false, lean: 0.08, gust: 0.8 },
    { x: -2.6, dropY: 1.95, zSign: -1, s: 0.9, phase: 1.4, broad: false, lean: 0.1, gust: 1.0 },
    // mid (camera-side, larger) — one tree gets a stronger gust envelope
    { x: -1.7, dropY: 1.05, zSign: -1, s: 0.98, phase: 1.3, broad: true, lean: 0.12, gust: 1.8 },
    { x: 1.3, dropY: 1.0, zSign: 1, s: 0.7, phase: 2.1, broad: false, lean: 0.07, gust: 0.9 },
    // lower-right cluster
    { x: 2.5, dropY: 1.5, zSign: -1, s: 1.08, phase: 0.7, broad: true, lean: 0.13, gust: 1.0 },
    { x: 2.9, dropY: 1.85, zSign: -1, s: 0.8, phase: 2.6, broad: false, lean: 0.09, gust: 1.1 },
    { x: 3.5, dropY: 1.7, zSign: 1, s: 0.62, phase: 3.0, broad: false, lean: 0.06, gust: 0.85 },
  ]), []);

  // Roadside grass/shrub tufts at the embankment toe (instanced thin cones),
  // shearing in the same wind phase as the trees for a cohesive breeze.
  const grassRef = React.useRef();
  const GRASS = React.useMemo(() => {
    const out = [];
    for (let i = 0; i < 52; i++) {
      const x = -3.85 + (7.7 * i) / 51 + (i % 3) * 0.1;
      const zSign = i % 2 === 0 ? 1 : -1;
      // spread tufts up the slope a little, not just at the toe
      const dropY = 1.25 + ((i * 7) % 6) * 0.1;
      const topY = crest(x);
      const y = topY - dropY;
      const z = (zSign * fillHalfAtY(topY, y)) - zSign * 0.04; // tuck onto face
      // camera-side (zSign -1) tufts run larger so the near toe fills + ripples
      const big = zSign < 0 ? 0.35 : 0;
      out.push({ x, y, z, phase: (i % 7) * 0.9, s: 0.66 + (i % 4) * 0.12 + big });
    }
    return out;
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Riprap rock scatter at the embankment toe (static, set once). Irregular
  // clumps along both toe lines with jittered size/spin so they read as loose
  // rock, not a band. Matrices written once on first frame via riprapDone flag.
  const riprapRef = React.useRef();
  const riprapDone = React.useRef(false);
  const RIPRAP = React.useMemo(() => {
    const out = [];
    for (let i = 0; i < 40; i++) {
      const x = -3.9 + (7.8 * i) / 39 + ((i * 13) % 5) * 0.05;
      const zSign = i % 2 === 0 ? 1 : -1;
      const topY = crest(x);
      const baseHalf = topHalf + SLOPE * (topY - groundY);
      const z = zSign * (baseHalf - 0.04 - ((i * 7) % 4) * 0.05);
      const y = groundY + 0.04 + ((i * 5) % 3) * 0.02;
      out.push({ x, y, z, s: 0.55 + ((i * 11) % 6) * 0.12, rot: (i * 1.7) % 6.28 });
    }
    return out;
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Drifting dust/leaf specks near the trees, riding the same wind phase.
  const dustRef = React.useRef();
  const DUST = React.useMemo(() => {
    const out = [];
    for (let i = 0; i < 10; i++) {
      const x = -3.2 + (6.4 * i) / 9 + ((i * 3) % 4) * 0.1;
      const zSign = i % 2 === 0 ? 1 : -1;
      const topY = crest(x);
      const y = topY - 0.5 - ((i * 7) % 5) * 0.12;
      const z = zSign * (topHalf + SLOPE * (topY - y) + 0.1);
      out.push({ x, y, z, phase: (i % 5) * 1.2, amp: 0.18 + (i % 3) * 0.06 });
    }
    return out;
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Two birds gliding over the crest (groups + wings flapped, phase-varied).
  const birdRefs = React.useRef([]);
  const wingLRefs = React.useRef([]);
  const wingRRefs = React.useRef([]);
  const cloudRef = React.useRef();
  const cloudRef2 = React.useRef();
  // Walking pedestrian on the camera-side shoulder (animated via ref group).
  const pedRef = React.useRef();
  const pedTorsoRef = React.useRef();
  const pedArmLRef = React.useRef();
  const pedArmRRef = React.useRef();
  const pedLegLRef = React.useRef();
  const pedLegRRef = React.useRef();
  // Truck exhaust puffs (refs to a few transparent sprites that rise + fade).
  const puffRefs = React.useRef([]);
  // Tyre dust trail kicked up behind the fastest car (instanced specks that
  // each loop on their own phase, trailing back along -travel and settling).
  const dustTrailRef = React.useRef();
  const FAST_IDX = 0; // VEHICLES[0] is the fastest right-lane car
  const DUSTTRAIL_N = 14;

  useFrame((state) => {
    const t = state.clock.elapsedTime;
    // Drive vehicles along the profile.
    for (let i = 0; i < VEHICLES.length; i++) {
      const v = VEHICLES[i];
      const g = carRefs.current[i];
      if (!g) continue;
      // progress 0..1 looping; offset by phase; direction flips travel sense.
      let p = (v.phase + (t * v.speed) / span) % 1;
      if (p < 0) p += 1;
      const x = v.dir > 0 ? x0 + p * span : x1 - p * span;
      const y = crest(x);
      const grade = dcrest(x);
      g.position.set(x, y + (v.truck ? 0.22 : 0.18), v.z);
      // pitch: nose follows travel direction; tilt up entry grade, down exit.
      // rotation about z; for -x travel the car faces -x so negate.
      const pitch = Math.atan(grade) * v.dir;
      _euler.set(0, v.dir > 0 ? 0 : Math.PI, pitch);
      g.rotation.copy(_euler);
      // brake-light flare on the descent: when traveling downgrade (grade*dir<0)
      // raise tail-light emissive, ramped by how steep the descent is.
      const descent = Math.max(0, -grade * v.dir); // >0 only on the down side
      const glow = (0.25 + Math.min(1, descent * 3) * 1.4) * opacity;
      const tl = tailRefs.current[i];
      if (tl) {
        if (tl[0]) tl[0].emissiveIntensity = glow;
        if (tl[1]) tl[1].emissiveIntensity = glow;
      }
    }
    // Sway tree canopies (rotation about z only; trunks fixed since canopy is a
    // child group pivoting near the trunk top). Single shared wind phase base.
    const wind = Math.sin(t * 1.1);
    for (let i = 0; i < TREES.length; i++) {
      const c = treeRefs.current[i];
      if (!c) continue;
      // low-frequency gust envelope (0.4..1.0+) so the breeze swells and eases
      // instead of being perfectly periodic; scaled per tree by its `gust`.
      const env = (0.7 + 0.3 * Math.sin(t * 0.27 + TREES[i].phase * 1.7)) * TREES[i].gust;
      c.rotation.z = Math.sin(t * 1.1 + TREES[i].phase) * 0.07 * env;
      c.rotation.x = Math.cos(t * 0.9 + TREES[i].phase) * 0.04 * env;
    }
    // Grass tufts: shear with the same breeze (tilt about z), instanced.
    if (grassRef.current) {
      for (let i = 0; i < GRASS.length; i++) {
        const tf = GRASS[i];
        const shear = Math.sin(t * 1.1 + tf.phase) * 0.18 + 0.05 * wind;
        _euler.set(0, 0, shear);
        _q.setFromEuler(_euler);
        _pos.set(tf.x, tf.y + 0.13 * tf.s, tf.z);
        _scl.set(tf.s, tf.s, tf.s);
        _m4.compose(_pos, _q, _scl);
        grassRef.current.setMatrixAt(i, _m4);
      }
      grassRef.current.instanceMatrix.needsUpdate = true;
    }
    // Birds: slow looping arc over the crest, phase-varied, in-frame. Each
    // bird's group flies the arc; wings flap by rotating the wing sub-groups.
    for (let i = 0; i < 3; i++) {
      const g = birdRefs.current[i];
      if (!g) continue;
      // bird 2 is the distant depth bird: higher, wider, slower arc.
      const distant = i === 2;
      const ph = i * 2.094; // 120deg apart so they never bunch
      const sp = distant ? 0.1 : 0.18;
      const ax = distant ? 3.8 : 3.0;
      const baseY = distant ? 2.75 : 2.2;            // clear sky, above clouds
      const bx = Math.sin(t * sp + ph) * ax;
      const by = baseY + Math.cos(t * sp + ph) * (distant ? 0.1 : 0.16) + 0.07 * Math.sin(t * 2.4 + ph);
      // face travel direction (sign of horizontal velocity)
      const dir = Math.cos(t * sp + ph) >= 0 ? 1 : -1;
      g.position.set(bx, by, distant ? -0.9 : -0.3 + i * 0.5);
      g.rotation.y = dir > 0 ? 0 : Math.PI;
      const flap = Math.sin(t * (distant ? 4.5 : 7) + ph) * (distant ? 0.32 : 0.5);
      // flap about x ON TOP of the fixed dihedral (the wing groups' rotation.z)
      const wl = wingLRefs.current[i];
      const wr = wingRRefs.current[i];
      if (wl) wl.rotation.x = -flap;
      if (wr) wr.rotation.x = flap;
    }
    // Riprap matrices: write once (static scatter) on the first frame.
    if (riprapRef.current && !riprapDone.current) {
      for (let i = 0; i < RIPRAP.length; i++) {
        const r = RIPRAP[i];
        _euler.set(r.rot, r.rot * 0.7, r.rot * 1.3);
        _q.setFromEuler(_euler);
        _pos.set(r.x, r.y, r.z);
        _scl.set(r.s, r.s * 0.7, r.s);
        _m4.compose(_pos, _q, _scl);
        riprapRef.current.setMatrixAt(i, _m4);
      }
      riprapRef.current.instanceMatrix.needsUpdate = true;
      riprapDone.current = true;
    }
    // Drifting dust/leaf specks: small orbiting bob on the wind phase.
    if (dustRef.current) {
      for (let i = 0; i < DUST.length; i++) {
        const d = DUST[i];
        const dx = d.x + Math.sin(t * 0.9 + d.phase) * d.amp;
        const dy = d.y + Math.cos(t * 1.3 + d.phase) * d.amp * 0.7 + 0.04 * wind;
        _euler.set(t + d.phase, t * 0.6, 0);
        _q.setFromEuler(_euler);
        _pos.set(dx, dy, d.z);
        _scl.setScalar(1);
        _m4.compose(_pos, _q, _scl);
        dustRef.current.setMatrixAt(i, _m4);
      }
      dustRef.current.instanceMatrix.needsUpdate = true;
    }
    // Distant cloud bands: very slow horizontal drift, wrap seamlessly off
    // frame. Two bands at different depth/speed give parallax.
    if (cloudRef.current) {
      const cx = ((t * 0.05 + 7) % 14) - 7;
      cloudRef.current.position.set(cx, 3.35, -4.6);
    }
    if (cloudRef2.current) {
      const cx = ((t * 0.03 + 9 + 7) % 14) - 7;
      cloudRef2.current.position.set(cx, 3.75, -5.6);
    }
    // Truck exhaust: small gray puffs rise behind the cab and fade on a loop.
    // Truck is VEHICLES[2]; read its current world pose from its ref.
    const truckG = carRefs.current[2];
    if (truckG) {
      for (let i = 0; i < puffRefs.current.length; i++) {
        const p = puffRefs.current[i];
        if (!p) continue;
        const cyc = (t * 0.8 + i * 0.45) % 1; // 0..1 loop
        // start just behind+above the cab, drift up and back, fade out
        const back = 0.55 + cyc * 0.5;   // drift back along -travel as it ages
        const rise = 0.32 + cyc * 0.5;   // and rise
        const bx = truckG.position.x - (VEHICLES[2].dir > 0 ? back : -back);
        p.position.set(bx, truckG.position.y + rise, truckG.position.z);
        const sc = 0.06 + cyc * 0.14;
        p.scale.setScalar(sc);
        if (p.material) p.material.opacity = opacity * (1 - cyc) * 0.45;
      }
    }
    // Tyre dust trail behind the fastest car: each speck loops on its own
    // phase, born just behind the rear wheels at the car's current pose, then
    // drifting back (-travel) and up while shrinking — sells a dry, fast road.
    const fastG = carRefs.current[FAST_IDX];
    if (dustTrailRef.current && fastG) {
      const dir = VEHICLES[FAST_IDX].dir;
      for (let i = 0; i < DUSTTRAIL_N; i++) {
        const cyc = (t * 1.3 + i * (1 / DUSTTRAIL_N)) % 1; // 0..1 age
        const back = 0.4 + cyc * 0.7;                       // drift back as it ages
        const rise = cyc * 0.3;                             // and lift a little
        const dx = fastG.position.x - dir * back + Math.sin(t * 6 + i) * 0.03;
        const dy = fastG.position.y - 0.16 + rise + Math.sin(t * 5 + i * 2) * 0.02;
        const dz = fastG.position.z + (i % 2 === 0 ? 0.12 : -0.12);
        _pos.set(dx, dy, dz);
        _euler.set(t * 2 + i, t + i, 0);
        _q.setFromEuler(_euler);
        const sc = (0.05 + cyc * 0.16) * (1 - cyc); // grow then vanish
        _scl.setScalar(Math.max(0.001, sc));
        _m4.compose(_pos, _q, _scl);
        dustTrailRef.current.setMatrixAt(i, _m4);
      }
      dustTrailRef.current.instanceMatrix.needsUpdate = true;
    }
    // Streetlight lamp head: reads as 'lit' at small scale, dims cleanly with
    // opacity. Higher base so the glow registers at 0.62 tile scale.
    if (lampRef.current) {
      lampRef.current.emissiveIntensity = (0.9 + 0.15 * Math.sin(t * 1.7)) * opacity;
    }
    // Pedestrian: slow walk along the camera-side shoulder on a short ping-pong
    // path (triangle wave so they turn around without a pop), limbs swinging.
    if (pedRef.current) {
      const pedZ = -(halfW + 0.36);
      const period = 16;                 // seconds for a full there-and-back
      const u = (t % period) / period;   // 0..1
      const tri = u < 0.5 ? u * 2 : 2 - u * 2; // 0..1..0 triangle
      const xMin = 1.6, xMax = 3.2;
      const px = xMin + (xMax - xMin) * tri;
      const facing = u < 0.5 ? 1 : -1;   // +x then -x
      const py = crest(px) - 0.02;
      pedRef.current.position.set(px, py, pedZ);
      // base heading along the walk; near each turnaround (tri ~ 1, the far end)
      // hold a brief yaw toward the road (oncoming traffic) so the pause reads
      // as intent rather than a mechanical bounce.
      const heading = facing > 0 ? Math.PI / 2 : -Math.PI / 2;
      // toward the road (+z, away from camera) is yaw 0; blend a partial turn
      // toward it during the hold at the far end of the path.
      const lookHold = Math.max(0, (tri - 0.86) / 0.14); // 0..1 in the last bit
      pedRef.current.rotation.y = heading * (1 - 0.7 * lookHold);
      // limb swing + gentle torso bob; freeze swing near the turnaround
      const moving = Math.min(1, Math.abs(u - 0.5) * 6); // ~0 at turns
      const gait = Math.sin(t * 4.4) * 0.5 * moving;
      if (pedLegLRef.current) pedLegLRef.current.rotation.z = gait;
      if (pedLegRRef.current) pedLegRRef.current.rotation.z = -gait;
      if (pedArmLRef.current) pedArmLRef.current.rotation.z = -gait * 0.8;
      if (pedArmRRef.current) pedArmRRef.current.rotation.z = gait * 0.8;
      if (pedTorsoRef.current) pedTorsoRef.current.position.y = 0.4 + Math.abs(Math.sin(t * 4.4)) * 0.02 * moving;
    }
  });

  // ---- Local helpers ---------------------------------------------------------

  // A low roadside conifer rooted into the embankment slope: a small earth root
  // flare anchors the base, a fixed trunk, and a canopy group that sways. The
  // canopy group's ref is registered so useFrame can rotate it about its base.
  const Tree = ({ x, dropY, zSign, s, idx, broad, lean = 0.1 }) => {
    const [baseY, z] = seatOnSlope(x, dropY, zSign);
    // bite the base a touch INTO the slope so the root flare buries cleanly,
    // then lean the whole tree OUTWARD (about x) so the canopy stands proud of
    // the face instead of lying flat on it. zSign picks which face we lean off.
    const zIn = z - zSign * 0.1;
    return (
      <group position={[x, baseY, zIn]} rotation={[zSign * lean, 0, 0]} scale={s}>
        {/* earth root flare to anchor the trunk to the slope */}
        <mesh position={[0, 0.03, 0]} receiveShadow>
          <cylinderGeometry args={[0.17, 0.24, 0.14, 10]} />
          <meshStandardMaterial color={SOIL_DK} metalness={0.04} roughness={0.98} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        <mesh position={[0, 0.38, 0]} castShadow>
          <cylinderGeometry args={[0.05, 0.07, 0.7, 8]} />
          <meshStandardMaterial color={TRUNK} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        <group ref={(el) => (treeRefs.current[idx] = el)} position={[0, 0.73, 0]}>
          {broad ? (
            // rounder broadleaf canopy: a cluster of overlapping spheres built
            // UP and OUT so it reads as a full 3D crown (never a flat disc)
            <>
              <mesh position={[0, 0.5, 0]} castShadow>
                <sphereGeometry args={[0.4, 12, 10]} />
                <meshStandardMaterial color={LEAF_BROAD} metalness={0.04} roughness={0.93} flatShading transparent={opacity < 1} opacity={opacity} />
              </mesh>
              <mesh position={[-0.24, 0.3, 0.1]} castShadow>
                <sphereGeometry args={[0.3, 11, 9]} />
                <meshStandardMaterial color={LEAF} metalness={0.04} roughness={0.93} flatShading transparent={opacity < 1} opacity={opacity} />
              </mesh>
              <mesh position={[0.26, 0.34, -0.08]} castShadow>
                <sphereGeometry args={[0.31, 11, 9]} />
                <meshStandardMaterial color={LEAF_DK} metalness={0.04} roughness={0.93} flatShading transparent={opacity < 1} opacity={opacity} />
              </mesh>
              <mesh position={[0.05, 0.68, 0.04]} castShadow>
                <sphereGeometry args={[0.24, 11, 9]} />
                <meshStandardMaterial color={LEAF_BROAD} metalness={0.04} roughness={0.93} flatShading transparent={opacity < 1} opacity={opacity} />
              </mesh>
              <mesh position={[-0.05, 0.12, -0.12]} castShadow>
                <sphereGeometry args={[0.26, 11, 9]} />
                <meshStandardMaterial color={LEAF_DK} metalness={0.04} roughness={0.93} flatShading transparent={opacity < 1} opacity={opacity} />
              </mesh>
            </>
          ) : (
            <>
              <mesh position={[0, 0.28, 0]} castShadow>
                <coneGeometry args={[0.36, 0.7, 9]} />
                <meshStandardMaterial color={LEAF} metalness={0.04} roughness={0.92} flatShading transparent={opacity < 1} opacity={opacity} />
              </mesh>
              <mesh position={[0, 0.58, 0]} castShadow>
                <coneGeometry args={[0.26, 0.52, 9]} />
                <meshStandardMaterial color={LEAF_DK} metalness={0.04} roughness={0.92} flatShading transparent={opacity < 1} opacity={opacity} />
              </mesh>
            </>
          )}
        </group>
      </group>
    );
  };

  // Streetlight near the crest: charcoal/steel pole + cantilever arm + lamp.
  const lampX = -0.7;
  const lampBaseY = crest(lampX) + 0.08;

  return (
    <group position={[0, -0.1, 0]}>
      {/* Continuous graded earth fill: one battered trapezoid per deck segment,
          side-slopes running to grade (reads as a hill/embankment, not a wall) */}
      {data.deck.map((s, i) => (
        <Embankment key={`emb${i}`} s={s} idx={i} />
      ))}
      {/* Riprap scatter at the toe: irregular low rock clumps replace the old
          corrugated boxy band, giving a believable, non-geometric grade break */}
      <instancedMesh ref={riprapRef} args={[undefined, undefined, RIPRAP.length]} castShadow receiveShadow>
        <dodecahedronGeometry args={[0.12, 0]} />
        <meshStandardMaterial color={ROCK} metalness={0.04} roughness={0.97} flatShading transparent opacity={opacity} />
      </instancedMesh>

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

      {/* Centerline: crisp yellow dashes lifted clear of the asphalt sheen so
          they read up-and-over the parabolic crest without z-fighting */}
      {data.stripe.map((s, i) => {
        const t = 0.45; // shorter dash -> clear gaps read as a broken skip line
        const ax = s[0][0], bx = s[1][0];
        const ay = s[0][1], by = s[1][1];
        const mx0 = ax + (bx - ax) * (0.5 - t / 2), my0 = ay + (by - ay) * (0.5 - t / 2);
        const mx1 = ax + (bx - ax) * (0.5 + t / 2), my1 = ay + (by - ay) * (0.5 + t / 2);
        return (
          <Beam key={`s${i}`} a={[mx0, my0 + 0.095, 0]} b={[mx1, my1 + 0.095, 0]} width={0.1} thickness={0.018} color={C.sunbeam} opacity={opacity} metalness={0.05} roughness={0.85} />
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

      {/* Roadside trees rooted into & swaying on the embankment side-slopes */}
      {TREES.map((tr, i) => (
        <Tree key={`tree${i}`} x={tr.x} dropY={tr.dropY} zSign={tr.zSign} s={tr.s} idx={i} broad={tr.broad} lean={tr.lean} />
      ))}

      {/* Drifting dust/leaf specks near the trees (instanced, wind-borne) */}
      <instancedMesh ref={dustRef} args={[undefined, undefined, DUST.length]}>
        <tetrahedronGeometry args={[0.03, 0]} />
        <meshStandardMaterial color={LEAF_DK} metalness={0.02} roughness={0.95} flatShading transparent opacity={opacity * 0.7} />
      </instancedMesh>

      {/* Roadside grass tufts at the embankment toe (instanced, wind-sheared) */}
      <instancedMesh ref={grassRef} args={[undefined, undefined, GRASS.length]} castShadow>
        <coneGeometry args={[0.05, 0.26, 5]} />
        <meshStandardMaterial color={LEAF_DK} metalness={0.03} roughness={0.95} flatShading transparent opacity={opacity} />
      </instancedMesh>

      {/* Two birds gliding over the crest: shallow V silhouette (two thin
          angled wing boxes + a slim body); whole group flown + wings flapped
          via refs each frame */}
      {[0, 1, 2].map((i) => (
        <group key={`bird${i}`} ref={(el) => (birdRefs.current[i] = el)}>
          {/* slim body + slight head taper */}
          <Box position={[0, 0, 0]} size={[0.2, 0.045, 0.07]} color={C.charcoal} opacity={opacity} metalness={0.1} roughness={0.8} />
          <Box position={[0.13, 0.005, 0]} size={[0.07, 0.035, 0.05]} color={C.charcoal} opacity={opacity} metalness={0.1} roughness={0.8} />
          {/* wings: each wing group carries a fixed positive dihedral (rotate up
              about z) so the swept-back V silhouette reads even at small scale;
              useFrame flaps them about x on top of this base pose */}
          <group ref={(el) => (wingLRefs.current[i] = el)} position={[0, 0.01, 0.035]} rotation={[0, 0, 0.18]}>
            <Box position={[-0.02, 0, 0.16]} size={[0.1, 0.028, 0.32]} color={C.charcoal} opacity={opacity} metalness={0.1} roughness={0.8} />
          </group>
          <group ref={(el) => (wingRRefs.current[i] = el)} position={[0, 0.01, -0.035]} rotation={[0, 0, 0.18]}>
            <Box position={[-0.02, 0, -0.16]} size={[0.1, 0.028, 0.32]} color={C.charcoal} opacity={opacity} metalness={0.1} roughness={0.8} />
          </group>
        </group>
      ))}

      {/* Distant, soft, high cloud bands: flattened + feathered with many low
          overlapping spheres so the silhouette reads as wispy atmospheric haze
          well behind and above the road, not opaque blobs at deck level. Two
          bands at different depth/speed drift for parallax. */}
      {[
        { ref: cloudRef, op: 0.18, puffs: [[-0.9, 0.05, 0.4], [-0.2, -0.04, 0.5], [0.5, 0.08, 0.4], [1.1, -0.02, 0.32], [0.0, 0.12, 0.27]] },
        { ref: cloudRef2, op: 0.12, puffs: [[-0.7, 0.04, 0.37], [0.1, -0.03, 0.45], [0.8, 0.06, 0.34], [-1.2, 0.0, 0.24]] },
      ].map((band, bi) => (
        <group key={`cloud${bi}`} ref={band.ref}>
          {band.puffs.map((c, i) => (
            <mesh key={`cl${i}`} position={[c[0], c[1], 0]} scale={[c[2] * 2.4, c[2] * 0.38, c[2] * 1.0]}>
              <sphereGeometry args={[1, 12, 8]} />
              <meshStandardMaterial color="#fdf7ec" metalness={0} roughness={1} transparent opacity={opacity * band.op} depthWrite={false} />
            </mesh>
          ))}
        </group>
      ))}

      {/* Streetlight near the crest: pole + cantilever arm + sunbeam lamp head */}
      <group>
        <mesh position={[lampX, lampBaseY + 0.7, halfW + 0.18]} castShadow>
          <cylinderGeometry args={[0.035, 0.045, 1.4, 10]} />
          <meshStandardMaterial color={C.charcoal} metalness={0.6} roughness={0.45} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        <Beam a={[lampX, lampBaseY + 1.38, halfW + 0.18]} b={[lampX, lampBaseY + 1.38, halfW - 0.42]} width={0.04} thickness={0.04} color={C.charcoal} opacity={opacity} metalness={0.6} roughness={0.45} />
        <mesh position={[lampX, lampBaseY + 1.32, halfW - 0.42]} castShadow>
          <boxGeometry args={[0.16, 0.07, 0.12]} />
          <meshStandardMaterial
            ref={lampRef}
            color={C.sunbeam}
            emissive={C.sunbeam}
            emissiveIntensity={0.9 * opacity}
            metalness={0.3}
            roughness={0.4}
            transparent={opacity < 1}
            opacity={opacity}
          />
        </mesh>
        {/* faint downward light CONE from the lamp head toward the deck so the
            'this is a luminaire' read survives at 0.62 tile scale (open cone,
            wide at the deck, transparent, no depth write so it never occludes) */}
        <mesh position={[lampX, lampBaseY + 0.74, halfW - 0.42]} rotation={[Math.PI, 0, 0]}>
          <coneGeometry args={[0.42, 1.1, 18, 1, true]} />
          <meshBasicMaterial color={C.sunbeam} transparent opacity={opacity * 0.1} depthWrite={false} side={THREE.DoubleSide} />
        </mesh>
        {/* soft downward halo disc on the deck so the streetlight purpose is
            obvious — enlarged so it registers at small tile scale */}
        <mesh position={[lampX, crest(lampX) + 0.1, halfW - 0.42]} rotation={[Math.PI / 2, 0, 0]}>
          <circleGeometry args={[0.4, 24]} />
          <meshBasicMaterial color={C.sunbeam} transparent opacity={opacity * 0.22} depthWrite={false} side={THREE.DoubleSide} />
        </mesh>
        {/* small bright halo right at the lamp head */}
        <mesh position={[lampX, lampBaseY + 1.32, halfW - 0.42]} rotation={[Math.PI / 2, 0, 0]}>
          <circleGeometry args={[0.2, 20]} />
          <meshBasicMaterial color={C.sunbeam} transparent opacity={opacity * 0.28} depthWrite={false} side={THREE.DoubleSide} />
        </mesh>
      </group>

      {/* Tyre dust trail behind the fastest car: faint warm-gray specks that
          trail back and settle, animated per-instance via ref each frame */}
      <instancedMesh ref={dustTrailRef} args={[undefined, undefined, DUSTTRAIL_N]}>
        <tetrahedronGeometry args={[0.7, 0]} />
        <meshStandardMaterial color="#b7ac98" metalness={0} roughness={1} flatShading transparent opacity={opacity * 0.4} depthWrite={false} />
      </instancedMesh>

      {/* Truck exhaust: a few faint gray puffs rising + fading behind the cab */}
      {[0, 1, 2].map((i) => (
        <mesh key={`puff${i}`} ref={(el) => (puffRefs.current[i] = el)} position={[0, -10, 0]}>
          <sphereGeometry args={[1, 8, 7]} />
          <meshStandardMaterial color="#8f8a82" metalness={0} roughness={1} transparent opacity={0} depthWrite={false} />
        </mesh>
      ))}

      {/* Walking pedestrian on the near (camera-side) shoulder: a locally-built
          figure whose whole group is moved along a short looping path and whose
          limbs swing via refs, so it is no longer the one frozen living thing */}
      <group ref={pedRef} scale={0.5}>
        {/* legs (swing fore/aft about the hip) */}
        <group ref={pedLegLRef} position={[0, 0.4, 0.07]}>
          <Box position={[0, -0.2, 0]} size={[0.1, 0.4, 0.1]} color={C.charcoal} opacity={opacity} metalness={0.1} roughness={0.85} />
        </group>
        <group ref={pedLegRRef} position={[0, 0.4, -0.07]}>
          <Box position={[0, -0.2, 0]} size={[0.1, 0.4, 0.1]} color={C.charcoal} opacity={opacity} metalness={0.1} roughness={0.85} />
        </group>
        {/* torso (subtle walk bob via ref) + safety vest */}
        <group ref={pedTorsoRef} position={[0, 0.4, 0]}>
          <Box position={[0, 0.22, 0]} size={[0.16, 0.42, 0.22]} color={C.forest} opacity={opacity} metalness={0.1} roughness={0.8} />
          {/* arms swing opposite the legs */}
          <group ref={pedArmLRef} position={[0, 0.4, 0.14]}>
            <Box position={[0, -0.16, 0]} size={[0.07, 0.34, 0.07]} color={C.forest} opacity={opacity} metalness={0.1} roughness={0.8} />
          </group>
          <group ref={pedArmRRef} position={[0, 0.4, -0.14]}>
            <Box position={[0, -0.16, 0]} size={[0.07, 0.34, 0.07]} color={C.forest} opacity={opacity} metalness={0.1} roughness={0.8} />
          </group>
          {/* head + hard hat */}
          <mesh position={[0, 0.56, 0]} castShadow>
            <sphereGeometry args={[0.1, 12, 10]} />
            <meshStandardMaterial color="#caa987" metalness={0.05} roughness={0.7} transparent={opacity < 1} opacity={opacity} />
          </mesh>
          <mesh position={[0, 0.63, 0]} castShadow>
            <sphereGeometry args={[0.12, 12, 8, 0, Math.PI * 2, 0, Math.PI / 2]} />
            <meshStandardMaterial color={C.sunbeam} metalness={0.1} roughness={0.6} transparent={opacity < 1} opacity={opacity} />
          </mesh>
        </group>
      </group>

      {/* Living traffic: vehicles driving up and over the crest in both lanes */}
      {VEHICLES.map((v, i) => (
        <Vehicle
          key={`veh${i}`}
          ref={(el) => (carRefs.current[i] = el)}
          color={v.color}
          truck={v.truck}
          opacity={opacity}
          tailRefCb={(li, el) => {
            if (!tailRefs.current[i]) tailRefs.current[i] = [];
            tailRefs.current[i][li] = el;
          }}
        />
      ))}
    </group>
  );
}
