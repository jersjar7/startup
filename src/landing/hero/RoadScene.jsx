import React from 'react';
import * as THREE from 'three';
import { useFrame } from '@react-three/fiber';
import { C, Beam, Box, Person } from './primitives';

// FE topic: Transportation — a roadway carried over an earth CREST VERTICAL
// CURVE. The asphalt deck rides a parabolic crest seated into continuous
// embankment side-slopes (not a bridge span). The vertical-curve geometry is
// felt through the parabolic profile itself; it is now a LIVING road —
// vehicles drive up and over the crest in both lanes (each pitched to the
// local grade), one truck for size variety, roadside trees sway in the wind, a
// streetlight stands near the crest, and a pedestrian waits at the shoulder.
// An oncoming car cresting the apex conveys the restricted sight distance that
// the old diagrammatic arrows used to annotate. `opacity` cross-fades every
// material.

// Brand muted-earth grays for the embankment.
const SOIL = '#8a7c68';
const SOIL_DK = '#6f6253';
// Muted foliage greens (kept earthy, never neon).
const LEAF = '#4f6b4a';
const LEAF_DK = '#3c5639';
const TRUNK = '#5a4632';

// A small reusable vehicle (module-scope so its type is stable across the
// parent's opacity cross-fade re-renders). Built around its local origin; the
// traffic system positions/pitches the whole group via ref each frame.
const Vehicle = React.forwardRef(function Vehicle({ color, truck, opacity }, ref) {
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
      {/* tail-light hint (ember quad at the rear, reinforces travel sense) */}
      <Box position={[-L * 0.5, 0, W * 0.32]} size={[0.015, 0.05, 0.07]} color={C.ember} opacity={opacity} metalness={0.2} roughness={0.4} />
      <Box position={[-L * 0.5, 0, -W * 0.32]} size={[0.015, 0.05, 0.07]} color={C.ember} opacity={opacity} metalness={0.2} roughness={0.4} />
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
  const Embankment = ({ s }) => {
    const xa = s[0][0], xb = s[1][0];
    const xm = (xa + xb) / 2;
    const topY = (s[0][1] + s[1][1]) / 2;
    const h = topY - groundY;
    const len = Math.abs(xb - xa) + 0.06; // slight overlap to hide seams
    const baseHalf = topHalf + SLOPE * h;  // wider at grade
    // Cross-section in the y/z plane (extruded thickness = len along x).
    const shape = React.useMemo(() => {
      const sh = new THREE.Shape();
      sh.moveTo(-topHalf, topY);
      sh.lineTo(topHalf, topY);
      sh.lineTo(baseHalf, groundY);
      sh.lineTo(-baseHalf, groundY);
      sh.closePath();
      return sh;
    }, [topY, baseHalf]);
    return (
      <mesh position={[xm - len / 2, 0, 0]} rotation={[0, Math.PI / 2, 0]} castShadow receiveShadow>
        <extrudeGeometry args={[shape, { depth: len, bevelEnabled: false }]} />
        <meshStandardMaterial color={SOIL} metalness={0.05} roughness={0.97} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
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
  const TREES = React.useMemo(() => ([
    { x: -3.0, dropY: 1.55, zSign: 1, s: 0.78, phase: 0.0 },
    { x: -1.7, dropY: 1.05, zSign: -1, s: 0.7, phase: 1.3 },
    { x: 1.3, dropY: 1.0, zSign: 1, s: 0.74, phase: 2.1 },
    { x: 2.7, dropY: 1.45, zSign: -1, s: 0.8, phase: 0.7 },
    { x: 3.5, dropY: 1.7, zSign: 1, s: 0.62, phase: 3.0 },
  ]), []);

  // Roadside grass/shrub tufts at the embankment toe (instanced thin cones),
  // shearing in the same wind phase as the trees for a cohesive breeze.
  const grassRef = React.useRef();
  const GRASS = React.useMemo(() => {
    const out = [];
    for (let i = 0; i < 26; i++) {
      const x = -3.8 + (7.6 * i) / 25 + (i % 3) * 0.12;
      const zSign = i % 2 === 0 ? 1 : -1;
      const dropY = 1.62 + ((i * 7) % 5) * 0.06; // near the toe
      const topY = crest(x);
      const y = topY - dropY;
      const z = (zSign * fillHalfAtY(topY, y)) - zSign * 0.04; // tuck onto face
      out.push({ x, y, z, phase: (i % 7) * 0.9, s: 0.7 + (i % 4) * 0.12 });
    }
    return out;
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Two birds arcing slowly over the crest (instanced; sine bob, phase-varied).
  const birdRef = React.useRef();
  const cloudRef = React.useRef();
  // Truck exhaust puffs (refs to a few transparent sprites that rise + fade).
  const puffRefs = React.useRef([]);

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
    }
    // Sway tree canopies (rotation about z only; trunks fixed since canopy is a
    // child group pivoting near the trunk top). Single shared wind phase base.
    const wind = Math.sin(t * 1.1);
    for (let i = 0; i < TREES.length; i++) {
      const c = treeRefs.current[i];
      if (!c) continue;
      c.rotation.z = Math.sin(t * 1.1 + TREES[i].phase) * 0.07;
      c.rotation.x = Math.cos(t * 0.9 + TREES[i].phase) * 0.04;
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
    // Birds: slow looping arc over the crest, phase-varied, in-frame.
    if (birdRef.current) {
      for (let i = 0; i < 2; i++) {
        const ph = i * Math.PI; // opposite phase so they don't overlap
        const bx = Math.sin(t * 0.18 + ph) * 3.2;
        const by = 1.9 + Math.cos(t * 0.18 + ph) * 0.16 + 0.1 * Math.sin(t * 2.4 + ph);
        const flap = 0.5 + 0.4 * Math.sin(t * 7 + ph); // wing-beat as a roll
        // face travel direction (derivative sign of bx)
        const dir = Math.cos(t * 0.18 + ph) >= 0 ? 1 : -1;
        _euler.set(Math.PI / 2, 0, dir * (1.2) + flap * 0.2);
        _q.setFromEuler(_euler);
        _pos.set(bx, by, -0.2 + i * 0.5);
        _scl.set(0.6, 0.6, 0.6);
        _m4.compose(_pos, _q, _scl);
        birdRef.current.setMatrixAt(i, _m4);
      }
      birdRef.current.instanceMatrix.needsUpdate = true;
    }
    // Distant cloud band: very slow horizontal drift, wraps seamlessly.
    if (cloudRef.current) {
      // wrap across -6.5..+6.5 so the reset happens fully off-frame (no pop)
      const cx = ((t * 0.08 + 6.5) % 13) - 6.5;
      cloudRef.current.position.set(cx, 1.92, -1.2);
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
    // Streetlight lamp head: reads as 'lit' at small scale, dims cleanly with
    // opacity. Higher base so the glow registers at 0.62 tile scale.
    if (lampRef.current) {
      lampRef.current.emissiveIntensity = (0.9 + 0.15 * Math.sin(t * 1.7)) * opacity;
    }
  });

  // ---- Local helpers ---------------------------------------------------------

  // A low roadside conifer rooted into the embankment slope: a small earth root
  // flare anchors the base, a fixed trunk, and a canopy group that sways. The
  // canopy group's ref is registered so useFrame can rotate it about its base.
  const Tree = ({ x, dropY, zSign, s, idx }) => {
    const [baseY, z] = seatOnSlope(x, dropY, zSign);
    // tuck slightly inboard so the trunk bites the slope, not air
    const zIn = z - zSign * 0.06;
    return (
      <group position={[x, baseY, zIn]} scale={s}>
        {/* earth root flare to anchor the trunk to the slope */}
        <mesh position={[0, 0.03, 0]} receiveShadow>
          <cylinderGeometry args={[0.16, 0.22, 0.1, 10]} />
          <meshStandardMaterial color={SOIL_DK} metalness={0.04} roughness={0.98} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        <mesh position={[0, 0.38, 0]} castShadow>
          <cylinderGeometry args={[0.05, 0.07, 0.7, 8]} />
          <meshStandardMaterial color={TRUNK} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        <group ref={(el) => (treeRefs.current[idx] = el)} position={[0, 0.73, 0]}>
          <mesh position={[0, 0.28, 0]} castShadow>
            <coneGeometry args={[0.36, 0.7, 9]} />
            <meshStandardMaterial color={LEAF} metalness={0.04} roughness={0.92} flatShading transparent={opacity < 1} opacity={opacity} />
          </mesh>
          <mesh position={[0, 0.58, 0]} castShadow>
            <coneGeometry args={[0.26, 0.52, 9]} />
            <meshStandardMaterial color={LEAF_DK} metalness={0.04} roughness={0.92} flatShading transparent={opacity < 1} opacity={opacity} />
          </mesh>
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
        <Embankment key={`emb${i}`} s={s} />
      ))}
      {/* Darker toe band along grade to give the slope a base line and catch
          light differently from the lit upper face */}
      {data.deck.map((s, i) => {
        const xm = (s[0][0] + s[1][0]) / 2;
        const topY = (s[0][1] + s[1][1]) / 2;
        const baseHalf = topHalf + SLOPE * (topY - groundY);
        const len = Math.abs(s[1][0] - s[0][0]) + 0.06;
        return (
          <React.Fragment key={`toe${i}`}>
            <Box position={[xm, groundY + 0.04, baseHalf - 0.06]} size={[len, 0.08, 0.16]} color={SOIL_DK} opacity={opacity} metalness={0.05} roughness={0.98} />
            <Box position={[xm, groundY + 0.04, -baseHalf + 0.06]} size={[len, 0.08, 0.16]} color={SOIL_DK} opacity={opacity} metalness={0.05} roughness={0.98} />
          </React.Fragment>
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

      {/* Centerline: crisp yellow dashes lifted clear of the asphalt sheen so
          they read up-and-over the parabolic crest without z-fighting */}
      {data.stripe.map((s, i) => {
        const t = 0.72; // longer dash within each segment -> crisper read
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
        <Tree key={`tree${i}`} x={tr.x} dropY={tr.dropY} zSign={tr.zSign} s={tr.s} idx={i} />
      ))}

      {/* Roadside grass tufts at the embankment toe (instanced, wind-sheared) */}
      <instancedMesh ref={grassRef} args={[undefined, undefined, GRASS.length]} castShadow>
        <coneGeometry args={[0.05, 0.26, 5]} />
        <meshStandardMaterial color={LEAF_DK} metalness={0.03} roughness={0.95} flatShading transparent opacity={opacity} />
      </instancedMesh>

      {/* Two birds arcing slowly over the crest (instanced, sine bob) */}
      <instancedMesh ref={birdRef} args={[undefined, undefined, 2]}>
        <coneGeometry args={[0.05, 0.22, 3]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} flatShading transparent opacity={opacity} />
      </instancedMesh>

      {/* One slow distant cloud band drifting high above the crest */}
      <group ref={cloudRef}>
        {[[-0.5, 0, 0.42], [0.45, 0.12, 0.34], [0.0, -0.05, 0.3]].map((c, i) => (
          <mesh key={`cl${i}`} position={[c[0], c[1], 0]} scale={[c[2] * 2.2, c[2], c[2]]}>
            <sphereGeometry args={[1, 12, 10]} />
            <meshStandardMaterial color="#fbf4e8" metalness={0} roughness={1} transparent opacity={opacity * 0.5} />
          </mesh>
        ))}
      </group>

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
        {/* soft downward halo disc so the streetlight purpose is obvious */}
        <mesh position={[lampX, lampBaseY + 1.24, halfW - 0.42]} rotation={[Math.PI / 2, 0, 0]}>
          <circleGeometry args={[0.16, 20]} />
          <meshBasicMaterial color={C.sunbeam} transparent opacity={opacity * 0.32} depthWrite={false} side={THREE.DoubleSide} />
        </mesh>
      </group>

      {/* Truck exhaust: a few faint gray puffs rising + fading behind the cab */}
      {[0, 1, 2].map((i) => (
        <mesh key={`puff${i}`} ref={(el) => (puffRefs.current[i] = el)} position={[0, -10, 0]}>
          <sphereGeometry args={[1, 8, 7]} />
          <meshStandardMaterial color="#8f8a82" metalness={0} roughness={1} transparent opacity={0} depthWrite={false} />
        </mesh>
      ))}

      {/* Pedestrian at the near (camera-side) shoulder, standing plumb with feet
          on the locally-pitched shoulder surface; not pitched with grade */}
      <Person
        position={[3.0, crest(3.0) - 0.02, -(halfW + 0.34)]}
        rotation={[0, 1.6, 0]}
        scale={0.5}
        vest={C.forest}
        hardHat={C.sunbeam}
        opacity={opacity}
      />

      {/* Living traffic: vehicles driving up and over the crest in both lanes */}
      {VEHICLES.map((v, i) => (
        <Vehicle
          key={`veh${i}`}
          ref={(el) => (carRefs.current[i] = el)}
          color={v.color}
          truck={v.truck}
          opacity={opacity}
        />
      ))}
    </group>
  );
}
