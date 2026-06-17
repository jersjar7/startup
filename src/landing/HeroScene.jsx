import React from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Environment, ContactShadows, Lightformer } from '@react-three/drei';
import * as THREE from 'three';

// Brushed-steel hero animation (concept 1). Replaces the right-side HeroSvg with
// a 3D scene that cycles the same five FE Civil topics, each as a steel
// structure under studio lighting with soft contact shadows and ember accents.
// Same 15s / 5-phase (3s each) cadence as TopicLabel, so the label stays synced.

const C = { cream: '#FFF9F0', steel: '#4c4c4c', ember: '#E8683A', forest: '#2D7A5F', sunbeam: '#F5B731' };

// Map the SVG layout space (0..1200 x, 0..800 y) into centered 3D units.
const P = (x, y, z = 0) => [(x - 600) / 95, (430 - y) / 95, z];

// A single steel member: a thin cylinder oriented between two 3D points.
function Member({ a, b, radius = 0.05, color = C.steel, opacity = 1, emissive }) {
  const { mid, len, quat } = React.useMemo(() => {
    const va = new THREE.Vector3(...a);
    const vb = new THREE.Vector3(...b);
    const dir = new THREE.Vector3().subVectors(vb, va);
    const length = dir.length();
    const m = new THREE.Vector3().addVectors(va, vb).multiplyScalar(0.5);
    const q = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir.clone().normalize());
    return { mid: m, len: length, quat: q };
  }, [a, b]);
  return (
    <mesh position={mid} quaternion={quat} castShadow>
      <cylinderGeometry args={[radius, radius, len, 10]} />
      <meshStandardMaterial
        color={color}
        metalness={emissive ? 0.2 : 0.9}
        roughness={emissive ? 0.5 : 0.34}
        emissive={emissive || '#000000'}
        emissiveIntensity={emissive ? 1.4 : 0}
        transparent={opacity < 1}
        opacity={opacity}
      />
    </mesh>
  );
}

function Node({ p, r = 0.11, color = C.forest, opacity = 1 }) {
  return (
    <mesh position={p} castShadow>
      <sphereGeometry args={[r, 16, 16]} />
      <meshStandardMaterial color={color} metalness={0.5} roughness={0.4} transparent={opacity < 1} opacity={opacity} />
    </mesh>
  );
}

// An ember load arrow (shaft + cone head), gently glowing.
function ForceArrow({ at, opacity = 1 }) {
  const [x, y, z] = at;
  return (
    <group position={[x, y, z]}>
      <Member a={[x, y + 0.78, z]} b={[x, y + 0.14, z]} radius={0.035} color={C.ember} emissive={C.ember} opacity={opacity} />
      <mesh position={[x, y + 0.06, z]} castShadow>
        <coneGeometry args={[0.11, 0.22, 14]} />
        <meshStandardMaterial color={C.ember} emissive={C.ember} emissiveIntensity={1.4} transparent={opacity < 1} opacity={opacity} />
      </mesh>
    </group>
  );
}

// ── Topic geometries (members + nodes + arrows), reusing the proven SVG layouts ──

// 3D Warren box truss with downward load arrows.
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
    for (let i = 0; i < b.length - 1; i++) members.push([b[i], b[i + 1]]); // bottom chord
    for (let i = 0; i < t.length - 1; i++) members.push([t[i], t[i + 1]]); // top chord
    // diagonals (Warren-ish, following the SVG)
    members.push([b[0], t[0]], [b[1], t[0]], [b[1], t[1]], [b[2], t[1]], [b[2], t[2]], [b[3], t[2]], [b[3], t[3]], [b[4], t[3]], [b[4], t[4]], [b[5], t[4]]);
    nodes.push(...b, ...t);
  }
  // cross-members front<->back at the bottom + top
  const bF = bottom(dz);
  const bB = bottom(-dz);
  const tF = tops(dz);
  const tB = tops(-dz);
  for (let i = 0; i < bF.length; i++) members.push([bF[i], bB[i]]);
  for (let i = 0; i < tF.length; i++) members.push([tF[i], tB[i]]);
  // Loads sit on the front top chord (z = dz) so they read as resting on the
  // truss rather than floating at mid-depth.
  const arrows = [P(500, 320, dz), P(650, 320, dz), P(800, 320, dz)];
  return { members, nodes, arrows };
}

// Sample a 2D curve y=f(x) into a steel polyline at a given depth.
function curve(fn, x0, x1, steps, z = 0) {
  const pts = [];
  for (let i = 0; i <= steps; i++) {
    const x = x0 + ((x1 - x0) * i) / steps;
    pts.push(P(x, fn(x), z));
  }
  const members = [];
  for (let i = 0; i < pts.length - 1; i++) members.push([pts[i], pts[i + 1]]);
  return { members, pts };
}

function fluidData() {
  const members = [];
  const wave = (amp, base, ph) => (x) => base + Math.sin((x / 1000) * Math.PI * 2 + ph) * amp;
  for (let i = 0; i < 4; i++) {
    const { members: m } = curve(wave(28, 300 + i * 90, i * 0.7), 180, 1020, 40, (i - 1.5) * 0.5);
    members.push(...m);
  }
  return { members, nodes: [], arrows: [], thin: true, accent: C.forest };
}

function roadData() {
  // crest vertical curve: parabola apex
  const { members, pts } = curve((x) => 500 - Math.max(0, 120 - ((x - 600) ** 2) / 1700), 250, 950, 40);
  // grade tangents
  members.push([P(250, 500), P(600, 350)], [P(600, 350), P(950, 500)]);
  members.push([P(200, 560, 0), P(1000, 560, 0)]); // baseline
  const nodes = [pts[0], pts[pts.length - 1], P(600, 386)];
  return { members, nodes, arrows: [], accent: C.sunbeam };
}

function surveyData() {
  const A = P(300, 560), B = P(600, 280), D = P(900, 540), E = P(460, 460), F = P(760, 440);
  const members = [[A, B], [B, D], [D, A], [B, E], [E, F], [F, B], [E, D]];
  return { members, nodes: [A, B, D, E, F], arrows: [], accent: C.forest };
}

function geoData() {
  const members = [];
  for (let i = 0; i < 5; i++) {
    const { members: m } = curve((x) => 360 + i * 70 + Math.sin(x / 200) * 8, 180, 1020, 28, (i - 2) * 0.25);
    members.push(...m);
  }
  const foundation = [P(460, 320), P(740, 320)];
  members.push(foundation);
  return { members, nodes: [P(460, 320), P(740, 320)], arrows: [], accent: C.sunbeam };
}

const TOPICS = [trussData, fluidData, roadData, surveyData, geoData];

function Structure({ data, opacity }) {
  const radius = data.thin ? 0.03 : 0.055;
  return (
    <group>
      {data.members.map((m, i) => (
        <Member key={i} a={m[0]} b={m[1]} radius={radius} color={C.steel} opacity={opacity} />
      ))}
      {(data.nodes || []).map((n, i) => (
        <Node key={`n${i}`} p={n} color={data.accent || C.forest} opacity={opacity} />
      ))}
      {(data.arrows || []).map((a, i) => (
        <ForceArrow key={`a${i}`} at={a} opacity={opacity} />
      ))}
    </group>
  );
}

function smoothstep(e0, e1, x) {
  const t = Math.max(0, Math.min(1, (x - e0) / (e1 - e0)));
  return t * t * (3 - 2 * t);
}

function Cycler({ reduced }) {
  const grp = React.useRef();
  const [phase, setPhase] = React.useState(0);
  const data = React.useMemo(() => TOPICS[phase](), [phase]);
  const opacityRef = React.useRef(1);
  const [, force] = React.useReducer((n) => n + 1, 0);

  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const idx = Math.min(4, Math.floor((t % 15) / 3));
    if (idx !== phase) setPhase(idx);
    const local = (t % 15) % 3; // 0..3 within a phase
    const op = Math.min(smoothstep(0, 0.5, local), 1 - smoothstep(2.5, 3, local));
    if (Math.abs(op - opacityRef.current) > 0.02) {
      opacityRef.current = op;
      force();
    }
    if (grp.current) {
      grp.current.rotation.y = reduced ? -0.35 : Math.sin(t * 0.18) * 0.4 - 0.15 + state.pointer.x * 0.3;
      grp.current.rotation.x = reduced ? 0.12 : 0.08 + state.pointer.y * 0.1;
      grp.current.position.y = reduced ? -0.3 : -0.3 + Math.sin(t * 0.5) * 0.1;
    }
  });

  // Shift right + scale down so the structure sits in the right of the slot and
  // clears the headline copy on the left; lowered so the load arrows clear the top.
  return (
    <group ref={grp} position={[1.7, -0.3, 0]} scale={0.78}>
      <Structure data={data} opacity={opacityRef.current} />
    </group>
  );
}

export function HeroScene() {
  const reduced =
    typeof window !== 'undefined' && window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;
  return (
    <Canvas
      camera={{ position: [0, 2.2, 9.5], fov: 38 }}
      dpr={[1, 1.8]}
      gl={{ alpha: true, antialias: true }}
      shadows
      style={{ width: '100%', height: '100%' }}
    >
      <ambientLight intensity={0.55} />
      <directionalLight position={[5, 8, 6]} intensity={1.2} castShadow shadow-mapSize={[1024, 1024]} />
      <directionalLight position={[-6, 3, -4]} intensity={0.4} color={C.ember} />
      <Cycler reduced={reduced} />
      <ContactShadows position={[0, -2.4, 0]} opacity={0.32} scale={18} blur={2.6} far={6} color="#2C2C2C" />
      {/* Self-contained studio environment — gives the steel its metallic
          reflections without fetching an HDR from an external CDN. */}
      <Environment resolution={256}>
        <Lightformer intensity={2.6} position={[0, 5, -6]} scale={[12, 12, 1]} color="#FFF9F0" />
        <Lightformer intensity={1.4} position={[-6, 2, 2]} scale={[6, 8, 1]} color="#ffffff" />
        <Lightformer intensity={0.9} position={[6, -1, 3]} scale={[6, 6, 1]} color="#F5B731" />
        <Lightformer intensity={0.7} position={[3, 4, 4]} scale={[4, 4, 1]} color="#E8683A" />
      </Environment>
    </Canvas>
  );
}
