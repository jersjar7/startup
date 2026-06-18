import React from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { C } from './primitives';

// FE topic: Fluid Mechanics — a NATURAL open river channel cut into the ground.
// A long earthen channel with sloped trapezoidal banks (soil + grass, not steel
// walls), a living free surface whose crests advect downstream, drifting leaves,
// a paddling duck, swaying reeds + bank grass, a few rocks, and a dragonfly. No
// man-made plumbing or weir. Every material honors `opacity` for the cross-fade.

// ── Channel cross-section (in the Z–Y plane), extruded along X (the flow) ──────
const L = 10.5;          // channel length (flow direction X) — long
const HALF_BED = 0.7;    // half width of the channel bed (Z)
const BANK_RUN = 1.3;    // horizontal run of each sloped bank (Z)
const HALF_TOP = 2.9;    // half width of the ground surface (Z)
const GROUND_Y = 0.45;   // bank top / ground level
const BED_Y = -0.55;     // channel bed
const BLOCK_BOTTOM = -1.05;
const WATER_Y = 0.05;    // free-surface level (partially fills the channel)
// Water half-width at the surface (interpolated up the sloped bank).
const WATER_F = (WATER_Y - BED_Y) / (GROUND_Y - BED_Y);
const WATER_HALF = HALF_BED + WATER_F * BANK_RUN;

const LEAF_GEO = new THREE.CylinderGeometry(0.12, 0.08, 0.016, 8);
const _leafCols = ['#2D7A5F', '#5a6b4a', '#b07a35', '#caa44a'].map((c) => new THREE.Color(c));
const GRASS_GEO = new THREE.ConeGeometry(0.03, 0.26, 5);
const _grassCols = ['#5b6b42', '#6f7a4a', '#485836'].map((c) => new THREE.Color(c));

// The earthen channel: a trapezoidal-notch cross-section extruded along X.
function EarthChannel({ opacity }) {
  const geo = React.useMemo(() => {
    const s = new THREE.Shape();
    // (lateral Z, vertical Y) — solid ground with a trapezoidal channel notch.
    s.moveTo(-HALF_TOP, BLOCK_BOTTOM);
    s.lineTo(HALF_TOP, BLOCK_BOTTOM);
    s.lineTo(HALF_TOP, GROUND_Y);
    s.lineTo(HALF_BED + BANK_RUN, GROUND_Y);
    s.lineTo(HALF_BED, BED_Y);
    s.lineTo(-HALF_BED, BED_Y);
    s.lineTo(-HALF_BED - BANK_RUN, GROUND_Y);
    s.lineTo(-HALF_TOP, GROUND_Y);
    s.closePath();
    const g = new THREE.ExtrudeGeometry(s, { depth: L, bevelEnabled: false, curveSegments: 1 });
    g.translate(0, 0, -L / 2); // center along the flow axis
    g.rotateY(Math.PI / 2); // extrude axis -> world X (flow); section -> Z–Y
    g.computeVertexNormals();
    return g;
  }, []);
  React.useEffect(() => () => geo.dispose(), [geo]);
  return (
    <mesh geometry={geo} receiveShadow castShadow>
      <meshStandardMaterial color="#6f6750" metalness={0.04} roughness={0.96} flatShading transparent={opacity < 1} opacity={opacity} />
    </mesh>
  );
}

// Grassy mantle on the banks: instanced cones sown up both slopes and onto the
// ground tops, above the waterline, each swaying on its own phase.
function BankGrass({ opacity }) {
  const ref = React.useRef();
  const dummy = React.useMemo(() => new THREE.Object3D(), []);
  const tufts = React.useMemo(() => {
    const arr = [];
    for (let i = 0; i < 44; i++) {
      const side = i % 2 === 0 ? -1 : 1;
      const a = 0.64 + Math.random() * 0.5; // up the slope, above waterline
      const aa = Math.min(a, 1);
      const z = side * (HALF_BED + aa * BANK_RUN + (a > 1 ? (a - 1) * 0.7 : 0));
      const y = BED_Y + aa * (GROUND_Y - BED_Y);
      const x = (Math.random() - 0.5) * (L - 1.0);
      arr.push({
        x, y, z,
        h: 0.16 + Math.random() * 0.2,
        phase: Math.random() * 6.28,
        amp: 0.1 + Math.random() * 0.12,
        tiltZ: (Math.random() - 0.5) * 0.25,
        col: i % 3,
      });
    }
    return arr;
  }, []);
  React.useEffect(() => {
    const m = ref.current;
    if (!m) return;
    for (let i = 0; i < tufts.length; i++) m.setColorAt(i, _grassCols[tufts[i].col]);
    if (m.instanceColor) m.instanceColor.needsUpdate = true;
  }, [tufts]);
  useFrame((state) => {
    const m = ref.current;
    if (!m) return;
    const t = state.clock.elapsedTime;
    for (let i = 0; i < tufts.length; i++) {
      const tf = tufts[i];
      dummy.position.set(tf.x, tf.y + tf.h / 2, tf.z);
      dummy.scale.set(1, tf.h / 0.26, 1);
      dummy.rotation.set(0, 0, tf.tiltZ + tf.amp * Math.sin(t * 1.4 + tf.phase));
      dummy.updateMatrix();
      m.setMatrixAt(i, dummy.matrix);
    }
    m.instanceMatrix.needsUpdate = true;
  });
  return (
    <instancedMesh ref={ref} args={[GRASS_GEO, undefined, tufts.length]} castShadow>
      <meshStandardMaterial metalness={0.04} roughness={0.92} transparent opacity={opacity * 0.96} />
    </instancedMesh>
  );
}

// A handful of boulders: a riffle cluster in the bed + a couple on the banks.
function Rocks({ opacity }) {
  const rocks = React.useMemo(() => {
    const cols = ['#7a756b', '#665f54', '#8a857a'];
    return [
      { p: [1.4, BED_Y + 0.12, 0.1], s: 0.2, c: 0 },
      { p: [1.7, BED_Y + 0.1, -0.35], s: 0.15, c: 1 },
      { p: [1.1, BED_Y + 0.09, 0.45], s: 0.13, c: 2 },
      { p: [-2.6, BED_Y + 0.14, -0.2], s: 0.18, c: 1 },
      { p: [-3.3, GROUND_Y - 0.02, -1.7], s: 0.26, c: 0 },
      { p: [3.4, GROUND_Y - 0.02, 1.6], s: 0.22, c: 2 },
    ].map((r, i) => ({ ...r, rot: [i * 1.1, i * 0.7, i * 0.5] }));
  }, []);
  return (
    <>
      {rocks.map((r, i) => (
        <mesh key={i} position={r.p} rotation={r.rot} scale={r.s} castShadow receiveShadow>
          <dodecahedronGeometry args={[1, 0]} />
          <meshStandardMaterial color={['#7a756b', '#665f54', '#8a857a'][r.c]} metalness={0.05} roughness={0.95} flatShading transparent={opacity < 1} opacity={opacity} />
        </mesh>
      ))}
    </>
  );
}

// Drifting leaves carried downstream, faster mid-channel, recycling upstream.
function Debris({ surfaceY, xMin, xMax, halfD, opacity }) {
  const N = 7;
  const ref = React.useRef();
  const dummy = React.useMemo(() => new THREE.Object3D(), []);
  const items = React.useMemo(
    () => Array.from({ length: N }, (_, i) => ({
      zf: ((i * 0.37 + 0.13) % 1) * 2 - 1,
      phase: i / N,
      spin: 0.4 + (i % 3) * 0.25,
      col: i % 4,
    })),
    [],
  );
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
      const speed = 0.42 - 0.22 * Math.abs(it.zf);
      const u = (it.phase + t * speed * 0.14) % 1;
      const x = xMin + u * span;
      const z = it.zf * (halfD - 0.2);
      const y = surfaceY + 0.04 + 0.025 * Math.sin(t * 1.4 + i);
      dummy.position.set(x, y, z);
      dummy.rotation.set(0.3 * Math.sin(t * 0.9 + i), t * it.spin + i, 0.28);
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

const DUCK_BODY = '#caa46a';
function Duck({ surfaceY, xMin, xMax, halfD, opacity }) {
  const ref = React.useRef();
  const headRef = React.useRef();
  const wakeL = React.useRef();
  const wakeR = React.useRef();
  const shedRef = React.useRef();
  useFrame((state) => {
    const g = ref.current;
    if (!g) return;
    const t = state.clock.elapsedTime;
    const span = xMax - xMin;
    const u = (t * 0.035) % 1;
    g.position.x = xMin + u * span;
    g.position.y = surfaceY + 0.12 + 0.04 * Math.sin(t * 1.6);
    g.position.z = -halfD * 0.04 + 0.05 * Math.sin(t * 0.7);
    g.rotation.y = 0.5 + 0.1 * Math.sin(t * 0.9);
    g.rotation.z = 0.05 * Math.sin(t * 1.6 + 0.6);
    if (headRef.current) {
      const dipCyc = (t * 0.11) % 1;
      const dip = dipCyc > 0.82 ? Math.sin(((dipCyc - 0.82) / 0.18) * Math.PI) : 0;
      headRef.current.rotation.z = -0.9 * dip;
    }
    const k = 1 + 0.12 * Math.sin(t * 2.0);
    if (wakeL.current) wakeL.current.scale.set(k, 1, 1);
    if (wakeR.current) wakeR.current.scale.set(k, 1, 1);
    if (shedRef.current) {
      const rc = (t * 0.45) % 1;
      const rs = 0.25 + rc * 1.4;
      shedRef.current.scale.set(rs, rs, rs);
      shedRef.current.material.opacity = opacity * 0.28 * (1 - rc);
    }
  });
  const body = { metalness: 0.12, roughness: 0.62 };
  return (
    <group ref={ref}>
      <group scale={1.3}>
        <mesh rotation={[0, 0, Math.PI / 2]} castShadow>
          <capsuleGeometry args={[0.12, 0.18, 6, 12]} />
          <meshStandardMaterial color={DUCK_BODY} {...body} transparent opacity={opacity} />
        </mesh>
        <mesh position={[-0.18, 0.07, 0]} rotation={[0, 0, 0.7]} castShadow>
          <coneGeometry args={[0.055, 0.13, 8]} />
          <meshStandardMaterial color={DUCK_BODY} {...body} transparent opacity={opacity} />
        </mesh>
        <group ref={headRef} position={[0.16, 0.11, 0]}>
          <mesh position={[0.04, 0.06, 0]} castShadow>
            <sphereGeometry args={[0.1, 16, 16]} />
            <meshStandardMaterial color={C.forest} metalness={0.18} roughness={0.5} transparent opacity={opacity} />
          </mesh>
          <mesh position={[0.085, 0.09, 0.075]} castShadow>
            <sphereGeometry args={[0.022, 10, 10]} />
            <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.4} transparent opacity={opacity} />
          </mesh>
          <mesh position={[0.16, 0.04, 0]} rotation={[0, 0, -0.12]} scale={[1, 0.5, 1.3]} castShadow>
            <sphereGeometry args={[0.06, 12, 12]} />
            <meshStandardMaterial color={C.sunbeam} metalness={0.2} roughness={0.5} transparent opacity={opacity} />
          </mesh>
        </group>
      </group>
      <mesh ref={wakeL} position={[-0.3, -0.1, 0.12]} rotation={[-Math.PI / 2, 0, 0.32]}>
        <planeGeometry args={[0.42, 0.02]} />
        <meshStandardMaterial color="#cfe0e2" metalness={0.05} roughness={0.6} transparent opacity={opacity * 0.3} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>
      <mesh ref={wakeR} position={[-0.3, -0.1, -0.12]} rotation={[-Math.PI / 2, 0, -0.32]}>
        <planeGeometry args={[0.42, 0.02]} />
        <meshStandardMaterial color="#cfe0e2" metalness={0.05} roughness={0.6} transparent opacity={opacity * 0.3} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>
      <mesh ref={shedRef} position={[0, -0.1, 0]} rotation={[-Math.PI / 2, 0, 0]}>
        <torusGeometry args={[0.16, 0.012, 8, 32]} />
        <meshStandardMaterial color="#cfe0e2" metalness={0.05} roughness={0.6} transparent opacity={opacity * 0.28} depthWrite={false} />
      </mesh>
    </group>
  );
}

// A reed clump at the waterline, blades + seed-head stalks swaying in a breeze.
function Reeds({ position, opacity }) {
  const blades = React.useMemo(
    () => Array.from({ length: 9 }, (_, i) => ({
      x: (i - 4) * 0.05,
      z: ((i * 0.31) % 1 - 0.5) * 0.18,
      h: (i >= 7 ? 0.62 : 0.32) + ((i * 7) % 5) * 0.05,
      phase: i * 1.1,
      amp: 0.16 + (i % 3) * 0.04,
      tone: i % 2 === 0 ? C.forest : '#5a6b4a',
      seed: i >= 7,
    })),
    [],
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
        <group key={i} ref={(el) => (refs.current[i] = el)} position={[b.x, 0, b.z]}>
          <mesh position={[0, b.h / 2, 0]} castShadow>
            <coneGeometry args={[0.018, b.h, 6]} />
            <meshStandardMaterial color={b.tone} metalness={0.05} roughness={0.85} transparent opacity={opacity * 0.95} />
          </mesh>
          {b.seed && (
            <mesh position={[0, b.h + 0.04, 0]} scale={[1, 1.8, 1]} castShadow>
              <sphereGeometry args={[0.032, 8, 8]} />
              <meshStandardMaterial color="#8a6a3a" metalness={0.05} roughness={0.9} transparent opacity={opacity * 0.95} />
            </mesh>
          )}
        </group>
      ))}
    </group>
  );
}

function Dragonfly({ surfaceY, xc, zc, opacity }) {
  const ref = React.useRef();
  const wingL = React.useRef();
  const wingR = React.useRef();
  useFrame((state) => {
    const g = ref.current;
    if (!g) return;
    const t = state.clock.elapsedTime;
    g.position.x = xc + 1.4 * Math.sin(t * 0.35);
    g.position.z = zc + 0.5 * Math.sin(t * 0.7);
    g.position.y = surfaceY + 0.6 + 0.06 * Math.sin(t * 1.4);
    g.rotation.y = 0.35 * Math.cos(t * 0.35) + Math.PI / 2;
    const f = 0.4 + 0.6 * Math.abs(Math.sin(t * 22));
    if (wingL.current) wingL.current.scale.x = f;
    if (wingR.current) wingR.current.scale.x = f;
  });
  return (
    <group ref={ref}>
      <mesh rotation={[0, 0, Math.PI / 2]} castShadow>
        <capsuleGeometry args={[0.012, 0.16, 4, 8]} />
        <meshStandardMaterial color={C.info} metalness={0.2} roughness={0.5} transparent opacity={opacity * 0.9} />
      </mesh>
      <mesh ref={wingL} position={[0.02, 0.01, 0.06]} rotation={[Math.PI / 2, 0, 0]}>
        <planeGeometry args={[0.13, 0.04]} />
        <meshStandardMaterial color="#dfeef0" metalness={0.05} roughness={0.4} transparent opacity={opacity * 0.4} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>
      <mesh ref={wingR} position={[0.02, 0.01, -0.06]} rotation={[Math.PI / 2, 0, 0]}>
        <planeGeometry args={[0.13, 0.04]} />
        <meshStandardMaterial color="#dfeef0" metalness={0.05} roughness={0.4} transparent opacity={opacity * 0.4} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>
    </group>
  );
}

export function FluidScene({ opacity }) {
  const geoRef = React.useRef();
  const glintRef = React.useRef();
  const waterW = 2 * WATER_HALF;
  const waterL = L - 0.5;
  const SX = 84, SY = 18;
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const g = geoRef.current;
    if (g) {
      const pos = g.attributes.position;
      for (let i = 0; i < pos.count; i++) {
        const x = pos.getX(i);
        const y = pos.getY(i);
        // Crests advect downstream (+X): a directed current, not surf.
        const z =
          0.085 * Math.sin(x * 1.1 - t * 2.2) +
          0.05 * Math.sin(x * 2.3 - t * 3.1 + y * 0.6) +
          0.03 * Math.sin(y * 1.7 - t * 1.0);
        pos.setZ(i, z);
      }
      pos.needsUpdate = true;
      g.computeVertexNormals();
    }
    if (glintRef.current) {
      const u = (t * 0.1) % 1;
      glintRef.current.position.x = -waterL / 2 + u * waterL;
      glintRef.current.material.opacity = opacity * 0.4 * Math.sin(u * Math.PI);
    }
  });

  const flowXMin = -waterL / 2 + 0.4;
  const flowXMax = waterL / 2 - 0.4;

  return (
    <group position={[0, 0.05, 0]}>
      {/* The earthen channel cut into the ground (sloped trapezoidal banks) */}
      <EarthChannel opacity={opacity} />
      <BankGrass opacity={opacity} />
      <Rocks opacity={opacity} />

      {/* Free surface — semi-transparent natural water; the soil bed shows
          through. Crests advect downstream for a directed current. */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, WATER_Y, 0]} receiveShadow>
        <planeGeometry ref={geoRef} args={[waterL, waterW, SX, SY]} />
        <meshStandardMaterial color="#3f7c84" emissive={C.water} emissiveIntensity={0.12} metalness={0.05} roughness={0.5} transparent opacity={opacity * 0.84} side={THREE.DoubleSide} />
      </mesh>
      {/* Advecting glint band so the downstream current direction reads */}
      <mesh ref={glintRef} rotation={[-Math.PI / 2, 0, 0]} position={[0, WATER_Y + 0.02, 0]}>
        <planeGeometry args={[0.7, waterW - 0.2]} />
        <meshStandardMaterial color="#eaf5f6" emissive="#dceaec" emissiveIntensity={0.3} metalness={0.1} roughness={0.4} transparent opacity={opacity * 0.4} side={THREE.DoubleSide} depthWrite={false} />
      </mesh>

      {/* Living detail */}
      <Debris surfaceY={WATER_Y} xMin={flowXMin} xMax={flowXMax} halfD={WATER_HALF} opacity={opacity} />
      <Duck surfaceY={WATER_Y} xMin={flowXMin} xMax={flowXMax} halfD={WATER_HALF} opacity={opacity} />
      <Reeds position={[-2.0, WATER_Y - 0.02, -(WATER_HALF + 0.05)]} opacity={opacity} />
      <Reeds position={[2.6, WATER_Y - 0.02, WATER_HALF + 0.05]} opacity={opacity} />
      <Dragonfly surfaceY={WATER_Y} xc={0.2} zc={-0.2} opacity={opacity} />
    </group>
  );
}
