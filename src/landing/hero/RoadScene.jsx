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

  // A trapezoidal embankment slab under a deck segment, running down to grade.
  const Embankment = ({ s, zSign }) => {
    const xa = s[0][0], xb = s[1][0];
    const xm = (xa + xb) / 2;
    const topY = (s[0][1] + s[1][1]) / 2;
    const h = topY - groundY;
    const cy = (topY + groundY) / 2;
    const len = Math.abs(xb - xa) + 0.06; // slight overlap to hide seams
    return (
      <mesh position={[xm, cy, zSign * (halfW - 0.18)]} castShadow receiveShadow>
        <boxGeometry args={[len, h, 0.42]} />
        <meshStandardMaterial color={SOIL} metalness={0.05} roughness={0.96} transparent={opacity < 1} opacity={opacity} />
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

  // Reusable scratch vectors — allocate once, never inside the frame loop.
  const _euler = React.useMemo(() => new THREE.Euler(), []);

  // Roadside trees on the embankment side-slopes. Kept within frame envelope.
  const TREES = React.useMemo(() => ([
    { x: -3.0, z: 1.35, s: 0.9, phase: 0.0 },
    { x: -1.7, z: -1.4, s: 0.78, phase: 1.3 },
    { x: 1.5, z: 1.42, s: 0.85, phase: 2.1 },
    { x: 2.8, z: -1.35, s: 0.95, phase: 0.7 },
    { x: 3.6, z: 1.3, s: 0.7, phase: 3.0 },
  ]), []);

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
    // child group pivoting near the trunk top).
    for (let i = 0; i < TREES.length; i++) {
      const c = treeRefs.current[i];
      if (!c) continue;
      c.rotation.z = Math.sin(t * 1.1 + TREES[i].phase) * 0.07;
      c.rotation.x = Math.cos(t * 0.9 + TREES[i].phase) * 0.04;
    }
    // Streetlight lamp: very subtle steady breathing glow (no neon flicker).
    if (lampRef.current) {
      lampRef.current.emissiveIntensity = (0.55 + 0.1 * Math.sin(t * 1.7)) * opacity;
    }
  });

  // ---- Local helpers ---------------------------------------------------------

  // A low roadside tree: fixed trunk + a canopy group that sways. The canopy
  // group's ref is registered so useFrame can rotate it about its base.
  const Tree = ({ x, z, s, idx }) => {
    const baseY = groundY + 0.02;
    return (
      <group position={[x, baseY, z]} scale={s}>
        <mesh position={[0, 0.35, 0]} castShadow>
          <cylinderGeometry args={[0.05, 0.07, 0.7, 8]} />
          <meshStandardMaterial color={TRUNK} metalness={0.05} roughness={0.95} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        <group ref={(el) => (treeRefs.current[idx] = el)} position={[0, 0.7, 0]}>
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
      {/* Continuous earth embankment under the road (reads as a hill, not a span) */}
      {data.deck.map((s, i) => (
        <React.Fragment key={`emb${i}`}>
          <Embankment s={s} zSign={1} />
          <Embankment s={s} zSign={-1} />
        </React.Fragment>
      ))}
      {/* Embankment crown core directly beneath the centerline */}
      {data.deck.map((s, i) => {
        const xm = (s[0][0] + s[1][0]) / 2;
        const topY = (s[0][1] + s[1][1]) / 2;
        const h = topY - groundY;
        return (
          <mesh key={`core${i}`} position={[xm, (topY + groundY) / 2, 0]} receiveShadow>
            <boxGeometry args={[Math.abs(s[1][0] - s[0][0]) + 0.06, h, 2 * halfW]} />
            <meshStandardMaterial color={SOIL_DK} metalness={0.05} roughness={0.98} transparent={opacity < 1} opacity={opacity} />
          </mesh>
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

      {/* Centerline: short, thin, matte dashes flush to the asphalt */}
      {data.stripe.map((s, i) => {
        const t = 0.55; // 0.55 dash within each ~0.2-unit segment -> short duty cycle
        const ax = s[0][0], bx = s[1][0];
        const ay = s[0][1], by = s[1][1];
        const mx0 = ax + (bx - ax) * (0.5 - t / 2), my0 = ay + (by - ay) * (0.5 - t / 2);
        const mx1 = ax + (bx - ax) * (0.5 + t / 2), my1 = ay + (by - ay) * (0.5 + t / 2);
        return (
          <Beam key={`s${i}`} a={[mx0, my0 + 0.087, 0]} b={[mx1, my1 + 0.087, 0]} width={0.09} thickness={0.015} color={C.sunbeam} opacity={opacity} metalness={0.05} roughness={0.85} />
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

      {/* Roadside trees swaying on the embankment side-slopes */}
      {TREES.map((tr, i) => (
        <Tree key={`tree${i}`} x={tr.x} z={tr.z} s={tr.s} idx={i} />
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
            emissiveIntensity={0.55 * opacity}
            metalness={0.3}
            roughness={0.4}
            transparent={opacity < 1}
            opacity={opacity}
          />
        </mesh>
      </group>

      {/* Pedestrian at the shoulder near a guardrail end, for human scale */}
      <Person
        position={[3.0, crest(3.0) + 0.09, halfW + 0.34]}
        rotation={[0, -1.2, 0]}
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
