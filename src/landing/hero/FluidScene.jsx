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
const LEAF_GEO = new THREE.CylinderGeometry(0.12, 0.08, 0.016, 8);
// Reused color objects so per-instance tinting allocates nothing per frame.
const _leafCols = ['#2D7A5F', '#5a6b4a', '#b07a35', '#caa44a'].map((c) => new THREE.Color(c));

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
        // A couple ride the center glint lane (zf~0) so the drift direction is
        // legible against the brighter water; the rest spread across the channel.
        zf: (i === 0 || i === 3) ? (i === 0 ? 0.04 : -0.06) : ((i * 0.37 + 0.13) % 1) * 2 - 1,
        phase: (i / N),
        spin: 0.4 + (i % 3) * 0.25,
        col: i % 4, // mix of green + autumn tones
        snag: i === 2 || i === 5, // a couple briefly snag near the weir
      })),
    []
  );
  // Tint instances once on mount; cheap and avoids per-frame allocation.
  React.useEffect(() => {
    const m = ref.current;
    if (!m) return;
    for (let i = 0; i < N; i++) m.setColorAt(i, _leafCols[items[i].col]);
    if (m.instanceColor) m.instanceColor.needsUpdate = true;
  }, [items]);
  useFrame((state) => {
    const m = ref.current;
    if (!m) return;
    const t = state.clock.elapsedTime;
    const span = xMax - xMin;
    for (let i = 0; i < N; i++) {
      const it = items[i];
      // Mid-channel (zf near 0) moves faster than near the walls.
      const speed = 0.42 - 0.22 * Math.abs(it.zf);
      let u = (it.phase + t * speed * 0.16) % 1;
      // Snagging leaves linger + spin in place in the weir backwater (u high).
      let spinBoost = 0;
      if (it.snag && u > 0.82) {
        u = 0.82 + (u - 0.82) * 0.25; // slow crawl over the last stretch
        spinBoost = 2.4;
      }
      const x = xMin + u * span;
      const z = it.zf * (halfD - 0.28);
      const y = surfaceY + 0.05 + 0.025 * Math.sin(t * 1.4 + i);
      dummy.position.set(x, y, z);
      // Tilt slightly off-horizontal so discs catch the studio light.
      dummy.rotation.set(0.32 * Math.sin(t * 0.9 + i), t * (it.spin + spinBoost) + i, 0.28);
      dummy.updateMatrix();
      m.setMatrixAt(i, dummy.matrix);
    }
    m.instanceMatrix.needsUpdate = true;
  });
  return (
    <instancedMesh ref={ref} args={[LEAF_GEO, undefined, N]} castShadow>
      <meshStandardMaterial metalness={0.1} roughness={0.7} transparent opacity={opacity * 0.95} />
    </instancedMesh>
  );
}

// A small procedural duck bobbing in Y and drifting slowly downstream, then
// resetting upstream, trailing a faint V-shaped wake. Warm earth tone so it
// reads against the steel walls. Subtle, on-brand-charming, not cartoonish.
const DUCK_BODY = '#caa46a'; // warm sandy buff, reads bright against the water
function Duck({ surfaceY, xMin, xMax, halfD, opacity }) {
  const ref = React.useRef();
  const headRef = React.useRef();
  const wakeL = React.useRef();
  const wakeR = React.useRef();
  const crossRef = React.useRef();
  useFrame((state) => {
    const g = ref.current;
    if (!g) return;
    const t = state.clock.elapsedTime;
    const span = xMax - xMin;
    const u = (t * 0.035) % 1;
    g.position.x = xMin + u * span;
    g.position.y = surfaceY + 0.15 + 0.04 * Math.sin(t * 1.6);
    g.position.z = halfD * 0.1 + 0.05 * Math.sin(t * 0.7);
    g.rotation.y = 0.5 + 0.1 * Math.sin(t * 0.9);
    g.rotation.z = 0.05 * Math.sin(t * 1.6 + 0.6);
    // Occasional feeding head-dip on a long period: brief downward tuck.
    if (headRef.current) {
      const dipCyc = (t * 0.11) % 1;
      const dip = dipCyc > 0.82 ? Math.sin((dipCyc - 0.82) / 0.18 * Math.PI) : 0;
      headRef.current.rotation.z = -0.9 * dip;
    }
    // V-wake breathes slightly so it reads as drift, not a static decal.
    const k = 1 + 0.12 * Math.sin(t * 2.0);
    if (wakeL.current) wakeL.current.scale.set(k, 1, 1);
    if (wakeR.current) wakeR.current.scale.set(k, 1, 1);
    // Secondary cross-ripple where the wake nears the wall: pulse + fade.
    if (crossRef.current) {
      const cc = (t * 0.8 + 0.3) % 1;
      const cs = 0.4 + cc * 1.0;
      crossRef.current.scale.set(cs, cs, cs);
      crossRef.current.material.opacity = opacity * 0.32 * (1 - cc);
    }
  });
  const body = { metalness: 0.12, roughness: 0.62 };
  const scale = 1.7; // larger so it reads instantly as a duck at tile scale
  return (
    <group ref={ref}>
      <group scale={scale}>
        {/* Body */}
        <mesh rotation={[0, 0, Math.PI / 2]} castShadow>
          <capsuleGeometry args={[0.12, 0.18, 6, 12]} />
          <meshStandardMaterial color={DUCK_BODY} {...body} transparent opacity={opacity} />
        </mesh>
        {/* Tail flick */}
        <mesh position={[-0.18, 0.07, 0]} rotation={[0, 0, 0.7]} castShadow>
          <coneGeometry args={[0.055, 0.13, 8]} />
          <meshStandardMaterial color={DUCK_BODY} {...body} transparent opacity={opacity} />
        </mesh>
        {/* Neck + head group (pivots forward for the feeding dip) — mallard green */}
        <group ref={headRef} position={[0.16, 0.11, 0]}>
          {/* Head — larger relative to body so the silhouette reads */}
          <mesh position={[0.04, 0.06, 0]} castShadow>
            <sphereGeometry args={[0.1, 16, 16]} />
            <meshStandardMaterial color={C.forest} metalness={0.18} roughness={0.5} transparent opacity={opacity} />
          </mesh>
          {/* Eye dot — dark, on the near side so it catches the viewer */}
          <mesh position={[0.085, 0.09, 0.075]} castShadow>
            <sphereGeometry args={[0.022, 10, 10]} />
            <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.4} transparent opacity={opacity} />
          </mesh>
          {/* Flatter spatulate bill pointing forward */}
          <mesh position={[0.16, 0.04, 0]} rotation={[0, 0, -0.12]} scale={[1, 0.5, 1.3]} castShadow>
            <sphereGeometry args={[0.06, 12, 12]} />
            <meshStandardMaterial color={C.sunbeam} metalness={0.2} roughness={0.5} transparent opacity={opacity} />
          </mesh>
        </group>
      </group>
      {/* V-shaped wake: two thin tilted strips trailing behind the body */}
      <mesh ref={wakeL} position={[-0.3, -0.12, 0.12]} rotation={[-Math.PI / 2, 0, 0.32]}>
        <planeGeometry args={[0.42, 0.02]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.05} roughness={0.6} transparent opacity={opacity * 0.45} side={THREE.DoubleSide} />
      </mesh>
      <mesh ref={wakeR} position={[-0.3, -0.12, -0.12]} rotation={[-Math.PI / 2, 0, -0.32]}>
        <planeGeometry args={[0.42, 0.02]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.05} roughness={0.6} transparent opacity={opacity * 0.45} side={THREE.DoubleSide} />
      </mesh>
      {/* Secondary cross-ripple toward the near wall where the wake reflects */}
      <mesh ref={crossRef} position={[-0.34, -0.13, 0.34]} rotation={[-Math.PI / 2, 0, 0]}>
        <torusGeometry args={[0.12, 0.014, 8, 24]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.05} roughness={0.6} transparent opacity={opacity * 0.3} />
      </mesh>
    </group>
  );
}

// A swaying reed tuft (thin tapered blades) at a wall corner, rocking in a
// light breeze via per-blade sin(t + phase) rotation.
function Reeds({ position, opacity }) {
  const blades = React.useMemo(
    () =>
      Array.from({ length: 10 }, (_, i) => ({
        x: (i - 4.5) * 0.05,
        z: ((i * 0.31) % 1 - 0.5) * 0.18,
        // Last two blades stand noticeably taller (seed-head stalks).
        h: (i >= 8 ? 0.7 : 0.34) + ((i * 7) % 5) * 0.06,
        phase: i * 1.1,
        amp: 0.16 + (i % 3) * 0.04,
        tone: i % 2 === 0 ? C.forest : '#5a6b4a',
        seed: i >= 8, // tall stalks get a brown seed head
      })),
    []
  );
  const refs = React.useRef([]);
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    for (let i = 0; i < blades.length; i++) {
      const r = refs.current[i];
      if (r) r.rotation.z = blades[i].amp * Math.sin(t * 1.3 + blades[i].phase);
    }
  });
  return (
    <group position={position}>
      {blades.map((b, i) => (
        <group
          key={i}
          ref={(el) => (refs.current[i] = el)}
          position={[b.x, 0, b.z]}
        >
          <mesh position={[0, b.h / 2, 0]} castShadow>
            <coneGeometry args={[0.018, b.h, 6]} />
            <meshStandardMaterial color={b.tone} metalness={0.05} roughness={0.85} transparent opacity={opacity * 0.95} />
          </mesh>
          {b.seed && (
            <mesh position={[0, b.h + 0.04, 0]} scale={[1, 1.8, 1]} castShadow>
              <sphereGeometry args={[0.035, 8, 8]} />
              <meshStandardMaterial color={'#8a6a3a'} metalness={0.05} roughness={0.9} transparent opacity={opacity * 0.95} />
            </mesh>
          )}
        </group>
      ))}
    </group>
  );
}

// A small cluster of tiny spheres popping at the jet impact point — each on its
// own short phase so the plunge reads as a churning splash, not a dot.
function Splash({ x, y, z, opacity }) {
  const refs = React.useRef([]);
  const drops = React.useMemo(
    () =>
      Array.from({ length: 4 }, (_, i) => ({
        ox: (i - 1.5) * 0.05,
        oz: ((i % 2) * 2 - 1) * 0.05,
        phase: i / 4,
        r: 0.026 + (i % 2) * 0.008,
      })),
    []
  );
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    for (let i = 0; i < drops.length; i++) {
      const m = refs.current[i];
      if (!m) continue;
      const cyc = (t * 1.9 + drops[i].phase) % 1; // short pop loop
      const arc = Math.sin(cyc * Math.PI);
      const lift = arc * 0.08; // low, tight pop — never a hovering wedge
      m.position.set(x + drops[i].ox, y + lift, z + drops[i].oz);
      const s = 0.5 + 0.5 * arc;
      m.scale.setScalar(s);
      // Vanish completely at top/bottom of the cycle so nothing floats statically.
      m.material.opacity = opacity * 0.8 * arc * arc;
    }
  });
  return (
    <>
      {drops.map((d, i) => (
        <mesh key={i} ref={(el) => (refs.current[i] = el)}>
          <sphereGeometry args={[d.r, 8, 8]} />
          <meshStandardMaterial color={'#eef2f0'} metalness={0.05} roughness={0.65} transparent opacity={opacity * 0.7} />
        </mesh>
      ))}
    </>
  );
}

// Churning whitewater foam at the nappe base — a cluster of jittering off-white
// low-roughness spheres, each pulsing on its own phase.
function Foam({ x, y, z, opacity }) {
  const refs = React.useRef([]);
  const blobs = React.useMemo(
    () =>
      Array.from({ length: 4 }, (_, i) => ({
        ox: ((i % 2) * 2 - 1) * 0.1,
        oz: (i - 1.5) * 0.5,
        r: 0.17 + (i % 3) * 0.04,
        phase: i * 0.9,
      })),
    []
  );
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    for (let i = 0; i < blobs.length; i++) {
      const m = refs.current[i];
      if (!m) continue;
      const b = blobs[i];
      m.position.set(x + b.ox, y + 0.03 * Math.sin(t * 4.0 + b.phase), z + b.oz);
      m.scale.setScalar(1 + 0.18 * Math.sin(t * 5.0 + b.phase));
      m.material.opacity = opacity * (0.7 + 0.18 * Math.sin(t * 5.0 + b.phase + 0.6));
    }
  });
  return (
    <>
      {blobs.map((b, i) => (
        <mesh key={i} ref={(el) => (refs.current[i] = el)} castShadow>
          <sphereGeometry args={[b.r, 12, 10]} />
          <meshStandardMaterial color={'#fafcfb'} metalness={0.03} roughness={0.88} transparent opacity={opacity * 0.7} />
        </mesh>
      ))}
    </>
  );
}

// Tiny foam flecks born at the jet impact that advect downstream (+X) and
// dissipate, extending the inflow churn across the channel. Instanced + cheap.
const FLECK_GEO = new THREE.SphereGeometry(0.042, 8, 8);
function Bubbles({ x0, surfaceY, span, halfD, opacity }) {
  const N = 10;
  const ref = React.useRef();
  const dummy = React.useMemo(() => new THREE.Object3D(), []);
  const items = React.useMemo(
    () =>
      Array.from({ length: N }, (_, i) => ({
        phase: i / N,
        zf: ((i * 0.41 + 0.2) % 1) * 2 - 1,
        wob: 0.8 + (i % 4) * 0.3,
      })),
    []
  );
  useFrame((state) => {
    const m = ref.current;
    if (!m) return;
    const t = state.clock.elapsedTime;
    for (let i = 0; i < N; i++) {
      const it = items[i];
      const u = (it.phase + t * 0.13) % 1; // 0 at jet, 1 well downstream
      const x = x0 + u * span;
      const z = it.zf * (halfD - 0.4) * Math.min(1, u * 3 + 0.2);
      const y = surfaceY + 0.045 + 0.015 * Math.sin(t * it.wob + i);
      dummy.position.set(x, y, z);
      // Shrink as it dissipates downstream.
      dummy.scale.setScalar(Math.max(0.0001, 1 - u));
      dummy.updateMatrix();
      m.setMatrixAt(i, dummy.matrix);
    }
    m.instanceMatrix.needsUpdate = true;
    // Whole cluster fades with topic opacity.
    m.material.opacity = opacity * 0.7;
  });
  return (
    <instancedMesh ref={ref} args={[FLECK_GEO, undefined, N]}>
      <meshStandardMaterial color={'#f6faf9'} metalness={0.04} roughness={0.72} transparent opacity={opacity * 0.7} />
    </instancedMesh>
  );
}

// A dragonfly hovering over the surface: slow lazy figure-8 drift, slight bob,
// and fast wing flicker via scaleY. Tiny secondary life, kept subtle + on-brand.
function Dragonfly({ surfaceY, xc, zc, opacity }) {
  const ref = React.useRef();
  const wingL = React.useRef();
  const wingR = React.useRef();
  useFrame((state) => {
    const g = ref.current;
    if (!g) return;
    const t = state.clock.elapsedTime;
    // Lazy figure-8 path over the channel, well within frame.
    g.position.x = xc + 0.9 * Math.sin(t * 0.35);
    g.position.z = zc + 0.5 * Math.sin(t * 0.7);
    g.position.y = surfaceY + 0.62 + 0.06 * Math.sin(t * 1.4);
    g.rotation.y = 0.35 * Math.cos(t * 0.35) + Math.PI / 2;
    // Fast wing flicker (collapse along span so it shimmers, not flaps wildly).
    const f = 0.4 + 0.6 * Math.abs(Math.sin(t * 22));
    if (wingL.current) wingL.current.scale.x = f;
    if (wingR.current) wingR.current.scale.x = f;
  });
  return (
    <group ref={ref}>
      {/* Slender body */}
      <mesh rotation={[0, 0, Math.PI / 2]} castShadow>
        <capsuleGeometry args={[0.012, 0.16, 4, 8]} />
        <meshStandardMaterial color={C.info} metalness={0.2} roughness={0.5} transparent opacity={opacity * 0.9} />
      </mesh>
      {/* Two wing pairs, thin translucent strips */}
      <mesh ref={wingL} position={[0.02, 0.01, 0.06]} rotation={[Math.PI / 2, 0, 0]}>
        <planeGeometry args={[0.13, 0.04]} />
        <meshStandardMaterial color={'#dfeef0'} metalness={0.05} roughness={0.4} transparent opacity={opacity * 0.4} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>
      <mesh ref={wingR} position={[0.02, 0.01, -0.06]} rotation={[Math.PI / 2, 0, 0]}>
        <planeGeometry args={[0.13, 0.04]} />
        <meshStandardMaterial color={'#dfeef0'} metalness={0.05} roughness={0.4} transparent opacity={opacity * 0.4} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>
    </group>
  );
}

export function FluidScene({ opacity }) {
  const geoRef = React.useRef();
  const jetRef = React.useRef();
  const rippleRef = React.useRef();
  const nappeRef = React.useRef();
  const glintRef = React.useRef();
  const W = 8.2, D = 3.0, SX = 70, SY = 28;
  // Free-surface level sits mid-wall (well above the floor) for a real body of
  // water. A gentle tilt raises the upstream/gate end to read as backwater.
  const surfaceY = 0.13;
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
          0.16 * Math.sin(x * 1.1 - t * 2.2) +
          0.08 * Math.sin(x * 2.3 - t * 3.1 + y * 0.6) +
          0.04 * Math.sin(y * 1.7 - t * 1.0) +
          0.05 * jetGain * Math.sin(x * 5.0 - t * 6.0);
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
    // Advecting specular highlight band: a brighter strip that travels in +X
    // across the surface so the directed downstream current is unmistakable.
    if (glintRef.current) {
      const xMinG = -3.6, xMaxG = 3.4;
      const u = (t * 0.12) % 1;
      glintRef.current.position.x = xMinG + u * (xMaxG - xMinG);
      // Fade in/out at the ends so the recycle never pops.
      const edge = Math.sin(u * Math.PI);
      glintRef.current.material.opacity = opacity * 0.6 * edge;
    }
    // Jet impact ripple ring: expand + fade on a loop.
    if (rippleRef.current) {
      const cycle = (t * 0.9) % 1;
      const s = 0.3 + cycle * 1.8;
      rippleRef.current.scale.set(s, s, s);
      rippleRef.current.material.opacity = opacity * 0.85 * (1 - cycle);
    }
    // Weir nappe: gentle vertical streak jitter so the sheet reads as spilling.
    if (nappeRef.current) {
      nappeRef.current.position.y = nappeRef.current.userData.baseY + 0.012 * Math.sin(t * 9.0);
      nappeRef.current.scale.y = 1 + 0.05 * Math.sin(t * 6.0 + 1.0);
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

      {/* Free surface — high-roughness, low-metalness colored water so the
          studio env stops blowing it out; deep teal base reads as liquid. */}
      <mesh rotation={[-Math.PI / 2 + 0, 0, backwaterTilt]} position={[0, surfaceY, 0]} receiveShadow castShadow>
        <planeGeometry ref={geoRef} args={[waterW, D - 0.1, SX, SY]} />
        <meshStandardMaterial color={'#4a8e98'} emissive={C.water} emissiveIntensity={0.24} metalness={0.06} roughness={0.5} transparent opacity={opacity * 0.95} side={THREE.DoubleSide} />
      </mesh>
      {/* Advecting specular glint band — a brighter strip travelling +X so the
          directed downstream current is unmistakable against the darker water. */}
      <mesh ref={glintRef} rotation={[-Math.PI / 2, 0, backwaterTilt]} position={[0, surfaceY + 0.02, 0]}>
        <planeGeometry args={[0.7, D - 0.3]} />
        <meshStandardMaterial color={'#f3fafb'} emissive={'#dceaec'} emissiveIntensity={0.35} metalness={0.1} roughness={0.35} transparent opacity={opacity * 0.6} side={THREE.DoubleSide} depthWrite={false} />
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
      <mesh ref={jetRef} position={[jetX, (wallTopY + 0.18 + surfaceY) / 2, jetZ]} rotation={[Math.PI, 0, -0.16]} castShadow>
        <coneGeometry args={[0.16, wallTopY + 0.18 - surfaceY, 16, 1, true]} />
        <meshStandardMaterial color={'#cdd9da'} emissive={C.water} emissiveIntensity={0.1} metalness={0.08} roughness={0.4} transparent opacity={opacity * 0.85} side={THREE.DoubleSide} />
      </mesh>
      {/* Splash cluster at the plunge point — tiny popping foam droplets */}
      <Splash x={jetX} y={surfaceY + 0.04} z={jetZ} opacity={opacity} />
      {/* Jet impact ripple — expanding + fading high-contrast ring */}
      <mesh ref={rippleRef} position={[jetX, surfaceY + 0.02, jetZ]} rotation={[-Math.PI / 2, 0, 0]}>
        <torusGeometry args={[0.16, 0.045, 10, 32]} />
        <meshStandardMaterial color={'#f0f5f4'} metalness={0.05} roughness={0.55} transparent opacity={opacity * 0.85} />
      </mesh>

      {/* Downstream sharp-crested weir plate: vertical, full channel width,
          steel body with a thin sunbeam crest cap. Backs up the flow. */}
      <Box position={[W / 2 - 0.55, floorY + 0.06 + 0.85 / 2, 0]} size={[0.1, 0.85, D]} color={C.steel} opacity={opacity} metalness={0.8} roughness={0.32} />
      {/* Sunbeam crest line on top of the weir plate — proud + full width so the
          horizontal sharp crest is unmistakable as a flow-control structure */}
      <Box position={[W / 2 - 0.55, floorY + 0.06 + 0.85 + 0.045, 0]} size={[0.22, 0.09, D]} color={C.sunbeam} opacity={opacity} metalness={0.4} roughness={0.45} />
      {/* Thin overflow nappe spilling FROM the crest top down the downstream face */}
      <mesh
        ref={(el) => {
          nappeRef.current = el;
          if (el) el.userData.baseY = floorY + 0.06 + 0.85 - 0.18;
        }}
        position={[W / 2 - 0.49, floorY + 0.06 + 0.85 - 0.18, 0]}
        rotation={[0, 0, -0.32]}
        castShadow
      >
        <boxGeometry args={[0.05, 0.46, D - 0.16]} />
        <meshStandardMaterial color={'#dceef0'} emissive={'#cfe3e5'} emissiveIntensity={0.2} metalness={0.08} roughness={0.34} transparent opacity={opacity * 0.88} />
      </mesh>
      {/* Churning whitewater foam cluster at the nappe base */}
      <Foam x={weirX + 0.12} y={floorY + 0.18} z={0} opacity={opacity} />

      {/* LIVING DETAIL: drifting debris, foam flecks, a bobbing duck, reeds. */}
      <Bubbles x0={jetX + 0.2} surfaceY={surfaceY} span={flowXMax - jetX - 0.2} halfD={innerHalfD} opacity={opacity} />
      <Debris surfaceY={surfaceY} xMin={flowXMin} xMax={flowXMax} halfD={innerHalfD} opacity={opacity} />
      <Duck surfaceY={surfaceY} xMin={flowXMin} xMax={flowXMax} halfD={innerHalfD} opacity={opacity} />
      <Reeds position={[-W / 2 + 0.5, wallTopY, -innerHalfD - 0.02]} opacity={opacity} />
      {/* Tiny secondary life: a dragonfly hovering over mid-channel */}
      <Dragonfly surfaceY={surfaceY} xc={0.4} zc={-0.3} opacity={opacity} />
    </group>
  );
}
