import React from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { C, Box } from './primitives';

// FE topic: Fluid Mechanics — an open-channel flume with a floor and full-height
// side walls confining a body of water, a LIVING free surface whose crests
// advect downstream (+X) toward a sharp-crested weir, an upstream inflow pipe
// with a plunging jet + impact ripple, drifting debris carried faster down the
// channel centerline, a bobbing duck, a spilling weir nappe with foam, and a
// breeze-swayed reed tuft. No diagrammatic arrows. Every material honors `opacity`.

// Geometry shared across instanced debris (leaf-like flat disc) and reeds.
const LEAF_GEO = new THREE.CylinderGeometry(0.07, 0.07, 0.018, 10);

// Drifting debris: small flat discs carried downstream, faster mid-channel,
// recycling seamlessly from the upstream end. Animated via direct ref mutation.
function Debris({ surfaceY, xMin, xMax, halfD, opacity }) {
  const N = 6;
  const ref = React.useRef();
  const dummy = React.useMemo(() => new THREE.Object3D(), []);
  // Per-instance: lane (z fraction), phase, spin speed.
  const items = React.useMemo(
    () =>
      Array.from({ length: N }, (_, i) => ({
        zf: ((i * 0.37 + 0.13) % 1) * 2 - 1, // -1..1 across channel
        phase: (i / N),
        spin: 0.4 + (i % 3) * 0.25,
      })),
    []
  );
  useFrame((state) => {
    const m = ref.current;
    if (!m) return;
    const t = state.clock.elapsedTime;
    const span = xMax - xMin;
    for (let i = 0; i < N; i++) {
      const it = items[i];
      // Mid-channel (zf near 0) moves faster than near the walls.
      const speed = 0.42 - 0.22 * Math.abs(it.zf);
      const u = (it.phase + t * speed * 0.16) % 1;
      const x = xMin + u * span;
      const z = it.zf * (halfD - 0.28);
      const y = surfaceY + 0.04 + 0.025 * Math.sin(t * 1.4 + i);
      dummy.position.set(x, y, z);
      dummy.rotation.set(0, t * it.spin + i, 0);
      dummy.updateMatrix();
      m.setMatrixAt(i, dummy.matrix);
    }
    m.instanceMatrix.needsUpdate = true;
  });
  return (
    <instancedMesh ref={ref} args={[LEAF_GEO, undefined, N]} castShadow>
      <meshStandardMaterial color={C.forest} metalness={0.1} roughness={0.7} transparent opacity={opacity * 0.92} />
    </instancedMesh>
  );
}

// A small procedural duck bobbing in Y and drifting slowly downstream, then
// resetting upstream. Subtle, on-brand-charming, not cartoonish.
function Duck({ surfaceY, xMin, xMax, halfD, opacity }) {
  const ref = React.useRef();
  useFrame((state) => {
    const g = ref.current;
    if (!g) return;
    const t = state.clock.elapsedTime;
    const span = xMax - xMin;
    const u = (t * 0.035) % 1;
    g.position.x = xMin + u * span;
    g.position.y = surfaceY + 0.13 + 0.035 * Math.sin(t * 1.6);
    g.position.z = halfD * 0.34 + 0.05 * Math.sin(t * 0.7);
    g.rotation.y = 0.4 + 0.12 * Math.sin(t * 0.9);
    g.rotation.z = 0.05 * Math.sin(t * 1.6 + 0.6);
  });
  const body = { metalness: 0.15, roughness: 0.6 };
  return (
    <group ref={ref}>
      {/* Body */}
      <mesh rotation={[0, 0, Math.PI / 2]} castShadow>
        <capsuleGeometry args={[0.11, 0.16, 6, 12]} />
        <meshStandardMaterial color={C.steelLt} {...body} transparent opacity={opacity} />
      </mesh>
      {/* Tail flick */}
      <mesh position={[-0.16, 0.05, 0]} rotation={[0, 0, 0.6]} castShadow>
        <coneGeometry args={[0.05, 0.12, 8]} />
        <meshStandardMaterial color={C.steelLt} {...body} transparent opacity={opacity} />
      </mesh>
      {/* Neck + head */}
      <mesh position={[0.15, 0.12, 0]} castShadow>
        <sphereGeometry args={[0.075, 14, 14]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.2} roughness={0.55} transparent opacity={opacity} />
      </mesh>
      {/* Beak */}
      <mesh position={[0.235, 0.105, 0]} rotation={[0, 0, -Math.PI / 2]} castShadow>
        <coneGeometry args={[0.03, 0.08, 8]} />
        <meshStandardMaterial color={C.sunbeam} metalness={0.2} roughness={0.5} transparent opacity={opacity} />
      </mesh>
    </group>
  );
}

// A swaying reed tuft (thin tapered blades) at a wall corner, rocking in a
// light breeze via per-blade sin(t + phase) rotation.
function Reeds({ position, opacity }) {
  const blades = React.useMemo(
    () =>
      Array.from({ length: 5 }, (_, i) => ({
        x: (i - 2) * 0.045,
        z: ((i * 0.27) % 1 - 0.5) * 0.12,
        h: 0.34 + (i % 3) * 0.08,
        phase: i * 1.3,
        tone: i % 2 === 0 ? C.forest : '#5a6b4a',
      })),
    []
  );
  const refs = React.useRef([]);
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    for (let i = 0; i < blades.length; i++) {
      const r = refs.current[i];
      if (r) r.rotation.z = 0.12 * Math.sin(t * 1.3 + blades[i].phase);
    }
  });
  return (
    <group position={position}>
      {blades.map((b, i) => (
        <mesh
          key={i}
          ref={(el) => (refs.current[i] = el)}
          position={[b.x, b.h / 2, b.z]}
          castShadow
        >
          <coneGeometry args={[0.018, b.h, 6]} />
          <meshStandardMaterial color={b.tone} metalness={0.05} roughness={0.85} transparent opacity={opacity * 0.95} />
        </mesh>
      ))}
    </group>
  );
}

export function FluidScene({ opacity }) {
  const geoRef = React.useRef();
  const jetRef = React.useRef();
  const rippleRef = React.useRef();
  const nappeRef = React.useRef();
  const foamRef = React.useRef();
  const W = 8.2, D = 3.0, SX = 70, SY = 28;
  // Free-surface level sits mid-wall (well above the floor) for a real body of
  // water. A gentle tilt raises the upstream/gate end to read as backwater.
  const surfaceY = 0.06;
  const backwaterTilt = -0.045; // radians, about the channel-cross axis
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const g = geoRef.current;
    if (g) {
      const pos = g.attributes.position;
      for (let i = 0; i < pos.count; i++) {
        const x = pos.getX(i);
        const y = pos.getY(i);
        // Crests advect downstream (+X): low-amplitude traveling waves read as a
        // directed current, not surf. Finer ripples near the upstream jet (-X).
        const jetGain = Math.max(0, 1 - (x + 4) / 5); // strongest at the head
        const z =
          0.085 * Math.sin(x * 1.1 - t * 2.2) +
          0.05 * Math.sin(x * 2.3 - t * 3.1 + y * 0.6) +
          0.03 * Math.sin(y * 1.7 - t * 1.0) +
          0.04 * jetGain * Math.sin(x * 5.0 - t * 6.0);
        pos.setZ(i, z);
      }
      pos.needsUpdate = true;
      g.computeVertexNormals();
    }
    // Plunging jet: vertical shimmer via scaleY pulse + slight sway.
    if (jetRef.current) {
      jetRef.current.scale.y = 1 + 0.06 * Math.sin(t * 7.0);
      jetRef.current.rotation.z = -0.16 + 0.02 * Math.sin(t * 4.0);
    }
    // Jet impact ripple ring: expand + fade on a loop.
    if (rippleRef.current) {
      const cycle = (t * 0.9) % 1;
      const s = 0.3 + cycle * 1.6;
      rippleRef.current.scale.set(s, s, s);
      rippleRef.current.material.opacity = opacity * 0.5 * (1 - cycle);
    }
    // Weir nappe: gentle vertical streak jitter so the sheet reads as spilling.
    if (nappeRef.current) {
      nappeRef.current.position.y = nappeRef.current.userData.baseY + 0.012 * Math.sin(t * 9.0);
      nappeRef.current.scale.y = 1 + 0.05 * Math.sin(t * 6.0 + 1.0);
    }
    // Downstream foam patch churning at the nappe base.
    if (foamRef.current) {
      foamRef.current.scale.setScalar(1 + 0.12 * Math.sin(t * 5.0));
      foamRef.current.material.opacity = opacity * (0.4 + 0.15 * Math.sin(t * 5.0 + 0.7));
    }
  });

  const wallH = 0.82;
  const floorY = -0.42;
  const wallTopY = floorY + wallH;
  const innerHalfD = D / 2; // water sits inside the wall inner faces
  const waterW = W; // surface width leaves a thin lip of floor inside the walls

  const bedY = floorY + 0.04;
  // Channel extents that floating objects ride between (just inside the weir).
  const flowXMin = -W / 2 + 0.6;
  const flowXMax = W / 2 - 0.85;
  // Where the inflow jet plunges into the surface (matches the pipe mouth).
  const jetX = -W / 2 + 0.5;
  const jetZ = 0.55;
  const weirX = W / 2 - 0.55;

  return (
    <group position={[0, 0.05, 0]}>
      {/* Base slab */}
      <Box position={[0, floorY, 0]} size={[W + 0.3, 0.12, D + 0.3]} color={C.steel} opacity={opacity} metalness={0.7} roughness={0.45} />
      {/* Recessed inner floor step — breaks the slab read, signals a built channel */}
      <Box position={[0, floorY + 0.065, 0]} size={[W - 0.1, 0.05, D - 0.2]} color={C.steelLt} opacity={opacity} metalness={0.6} roughness={0.5} />
      {/* Support legs under the slab so it reads as a lab flume, not a tray */}
      {[[-W / 2 + 0.4, D / 2 - 0.3], [W / 2 - 0.4, D / 2 - 0.3], [-W / 2 + 0.4, -D / 2 + 0.3], [W / 2 - 0.4, -D / 2 + 0.3]].map(([lx, lz], i) => (
        <Box key={`leg${i}`} position={[lx, floorY - 0.32, lz]} size={[0.16, 0.55, 0.16]} color={C.steel} opacity={opacity} metalness={0.7} roughness={0.5} />
      ))}
      {/* Near side wall (front) */}
      <Box position={[0, floorY + wallH / 2, innerHalfD + 0.09]} size={[W + 0.3, wallH, 0.12]} color={C.steelLt} opacity={opacity} metalness={0.7} roughness={0.45} />
      {/* Far side wall (back) — darker so the water is visibly bounded on both sides */}
      <Box position={[0, floorY + wallH / 2, -innerHalfD - 0.09]} size={[W + 0.3, wallH, 0.12]} color={C.steel} opacity={opacity} metalness={0.7} roughness={0.4} />

      {/* Free surface — softer water material, tilted for backwater */}
      <mesh rotation={[-Math.PI / 2 + 0, 0, backwaterTilt]} position={[0, surfaceY, 0]} receiveShadow castShadow>
        <planeGeometry ref={geoRef} args={[waterW, D - 0.1, SX, SY]} />
        <meshStandardMaterial color={C.water} metalness={0.1} roughness={0.3} transparent opacity={opacity * 0.88} side={THREE.DoubleSide} />
      </mesh>
      {/* Near-wall water depth strip — gives the body visible thickness */}
      <Box position={[0, (surfaceY + bedY) / 2, innerHalfD - 0.04]} size={[waterW - 0.1, surfaceY - bedY, 0.06]} color={C.water} opacity={opacity * 0.55} metalness={0.1} roughness={0.35} />
      {/* Far-wall water depth strip — slightly bluer body */}
      <Box position={[0, (surfaceY + bedY) / 2, -innerHalfD + 0.04]} size={[waterW - 0.1, surfaceY - bedY, 0.06]} color={C.info} opacity={opacity * 0.4} metalness={0.1} roughness={0.4} />

      {/* Upstream inflow plumbing: vertical riser + elbow + downturned outlet */}
      <mesh position={[-W / 2 - 0.05, wallTopY + 0.42, 0.55]} castShadow>
        <cylinderGeometry args={[0.13, 0.13, 0.95, 18]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.85} roughness={0.32} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      {/* Elbow joint */}
      <mesh position={[-W / 2 - 0.05, wallTopY + 0.86, 0.55]} castShadow>
        <sphereGeometry args={[0.15, 16, 16]} />
        <meshStandardMaterial color={C.steel} metalness={0.85} roughness={0.35} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      {/* Horizontal-to-down outlet, angled so the mouth points into the channel head */}
      <mesh position={[-W / 2 + 0.14, wallTopY + 0.6, 0.55]} rotation={[0, 0, Math.PI / 2.7]} castShadow>
        <cylinderGeometry args={[0.13, 0.13, 0.78, 18]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.85} roughness={0.32} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      {/* Flange ring at the pipe mouth */}
      <mesh position={[-W / 2 + 0.42, wallTopY + 0.28, 0.55]} rotation={[Math.PI / 2, 0, Math.PI / 2.7]} castShadow>
        <torusGeometry args={[0.15, 0.035, 10, 20]} />
        <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.3} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      {/* Falling jet/plume — tapered cone of water from the mouth to the surface,
          live shimmer via scaleY pulse + slight sway. */}
      <mesh ref={jetRef} position={[jetX, (wallTopY + 0.18 + surfaceY) / 2, jetZ]} rotation={[0, 0, -0.16]} castShadow>
        <coneGeometry args={[0.13, wallTopY + 0.18 - surfaceY, 14, 1, true]} />
        <meshStandardMaterial color={C.water} metalness={0.1} roughness={0.25} transparent opacity={opacity * 0.7} side={THREE.DoubleSide} />
      </mesh>
      {/* Jet impact ripple — expanding + fading ring at the plunge point */}
      <mesh ref={rippleRef} position={[jetX, surfaceY + 0.015, jetZ]} rotation={[-Math.PI / 2, 0, 0]}>
        <torusGeometry args={[0.16, 0.022, 8, 28]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.1} roughness={0.4} transparent opacity={opacity * 0.5} />
      </mesh>

      {/* Downstream sharp-crested weir plate: vertical, full channel width,
          steel body with a thin sunbeam crest cap. Backs up the flow. */}
      <Box position={[W / 2 - 0.55, floorY + 0.06 + 0.85 / 2, 0]} size={[0.1, 0.85, D]} color={C.steel} opacity={opacity} metalness={0.8} roughness={0.32} />
      {/* Sunbeam crest accent strip on top of the weir plate */}
      <Box position={[W / 2 - 0.55, floorY + 0.06 + 0.85 + 0.025, 0]} size={[0.12, 0.05, D]} color={C.sunbeam} opacity={opacity} metalness={0.4} roughness={0.45} />
      {/* Thin overflow nappe spilling over the crest — live vertical streak jitter */}
      <mesh
        ref={(el) => {
          nappeRef.current = el;
          if (el) el.userData.baseY = floorY + 0.06 + 0.85 - 0.12;
        }}
        position={[W / 2 - 0.47, floorY + 0.06 + 0.85 - 0.12, 0]}
        rotation={[0, 0, -0.28]}
        castShadow
      >
        <boxGeometry args={[0.04, 0.32, D - 0.2]} />
        <meshStandardMaterial color={C.water} metalness={0.1} roughness={0.25} transparent opacity={opacity * 0.65} />
      </mesh>
      {/* Churning foam patch at the nappe base, downstream of the crest */}
      <mesh ref={foamRef} position={[weirX + 0.12, floorY + 0.18, 0]} castShadow>
        <sphereGeometry args={[0.18, 12, 10]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.05} roughness={0.7} transparent opacity={opacity * 0.45} />
      </mesh>

      {/* LIVING DETAIL: drifting debris, a bobbing duck, swaying bank reeds. */}
      <Debris surfaceY={surfaceY} xMin={flowXMin} xMax={flowXMax} halfD={innerHalfD} opacity={opacity} />
      <Duck surfaceY={surfaceY} xMin={flowXMin} xMax={flowXMax} halfD={innerHalfD} opacity={opacity} />
      <Reeds position={[-W / 2 + 0.5, wallTopY, -innerHalfD - 0.02]} opacity={opacity} />
    </group>
  );
}
