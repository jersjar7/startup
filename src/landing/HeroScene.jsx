import React from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Environment, ContactShadows, Lightformer } from '@react-three/drei';
import * as THREE from 'three';

// Brushed-steel hero animation (concept 1). Replaces the right-side HeroSvg with
// a 3D scene that cycles the same five FE Civil topics, each as a real
// volumetric object under studio lighting with soft contact shadows and ember
// accents. Same 15s / 5-phase (3s each) cadence as TopicLabel, so the label
// stays in sync.

const C = {
  cream: '#FFF9F0',
  steel: '#4c4c4c',
  ember: '#E8683A',
  forest: '#2D7A5F',
  sunbeam: '#F5B731',
  water: '#2f6f7a',
};

const Y = new THREE.Vector3(0, 1, 0);
const X = new THREE.Vector3(1, 0, 0);

// Map the SVG truss layout space (0..1200 x, 0..800 y) into centered 3D units.
const P = (x, y, z = 0) => [(x - 600) / 95, (430 - y) / 95, z];

// ── Shared primitives ───────────────────────────────────────────────────────

// A steel cylinder oriented between two 3D points (axis = +Y by default).
function Member({ a, b, radius = 0.05, color = C.steel, opacity = 1, emissive }) {
  const { mid, len, quat } = React.useMemo(() => {
    const va = new THREE.Vector3(...a);
    const vb = new THREE.Vector3(...b);
    const dir = new THREE.Vector3().subVectors(vb, va);
    const length = dir.length();
    const m = new THREE.Vector3().addVectors(va, vb).multiplyScalar(0.5);
    const q = new THREE.Quaternion().setFromUnitVectors(Y, dir.clone().normalize());
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

// A solid steel box spanning between two points, with given cross-section
// (thickness on Y, width on Z). Used for the road deck and footings.
function Beam({ a, b, width = 1.0, thickness = 0.18, color = C.steel, opacity = 1, metalness = 0.85, roughness = 0.4 }) {
  const { mid, len, quat } = React.useMemo(() => {
    const va = new THREE.Vector3(...a);
    const vb = new THREE.Vector3(...b);
    const dir = new THREE.Vector3().subVectors(vb, va);
    const length = dir.length();
    const m = new THREE.Vector3().addVectors(va, vb).multiplyScalar(0.5);
    const q = new THREE.Quaternion().setFromUnitVectors(X, dir.clone().normalize());
    return { mid: m, len: length, quat: q };
  }, [a, b]);
  return (
    <mesh position={mid} quaternion={quat} castShadow receiveShadow>
      <boxGeometry args={[len, thickness, width]} />
      <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
    </mesh>
  );
}

function Node({ p, r = 0.11, color = C.forest, opacity = 1, metalness = 0.5, roughness = 0.4, emissive }) {
  return (
    <mesh position={p} castShadow>
      <sphereGeometry args={[r, 18, 18]} />
      <meshStandardMaterial
        color={color}
        metalness={metalness}
        roughness={roughness}
        emissive={emissive || '#000000'}
        emissiveIntensity={emissive ? 1.1 : 0}
        transparent={opacity < 1}
        opacity={opacity}
      />
    </mesh>
  );
}

// A glowing ember arrow from `from` to `to` (shaft + cone head), any direction.
function Arrow({ from, to, radius = 0.035, color = C.ember, opacity = 1 }) {
  const { shaftMid, shaftLen, headPos, quat } = React.useMemo(() => {
    const va = new THREE.Vector3(...from);
    const vb = new THREE.Vector3(...to);
    const dir = new THREE.Vector3().subVectors(vb, va);
    const ndir = dir.clone().normalize();
    const headLen = 0.22;
    const end = vb.clone().addScaledVector(ndir, -headLen);
    const q = new THREE.Quaternion().setFromUnitVectors(Y, ndir);
    return {
      shaftMid: va.clone().add(end).multiplyScalar(0.5),
      shaftLen: Math.max(0.001, va.distanceTo(end)),
      headPos: vb.clone().addScaledVector(ndir, -headLen / 2),
      quat: q,
    };
  }, [from, to]);
  const mat = (
    <meshStandardMaterial color={color} emissive={color} emissiveIntensity={1.4} metalness={0.2} roughness={0.5} transparent={opacity < 1} opacity={opacity} />
  );
  return (
    <group>
      <mesh position={shaftMid} quaternion={quat} castShadow>
        <cylinderGeometry args={[radius, radius, shaftLen, 12]} />
        {mat}
      </mesh>
      <mesh position={headPos} quaternion={quat} castShadow>
        <coneGeometry args={[radius * 3, 0.22, 14]} />
        {React.cloneElement(mat)}
      </mesh>
    </group>
  );
}

function smoothstep(e0, e1, x) {
  const t = Math.max(0, Math.min(1, (x - e0) / (e1 - e0)));
  return t * t * (3 - 2 * t);
}

// ── 1. Structural — 3D Warren box truss with load arrows ─────────────────────

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
    for (let i = 0; i < b.length - 1; i++) members.push([b[i], b[i + 1]]);
    for (let i = 0; i < t.length - 1; i++) members.push([t[i], t[i + 1]]);
    members.push([b[0], t[0]], [b[1], t[0]], [b[1], t[1]], [b[2], t[1]], [b[2], t[2]], [b[3], t[2]], [b[3], t[3]], [b[4], t[3]], [b[4], t[4]], [b[5], t[4]]);
    nodes.push(...b, ...t);
  }
  const bF = bottom(dz), bB = bottom(-dz), tF = tops(dz), tB = tops(-dz);
  for (let i = 0; i < bF.length; i++) members.push([bF[i], bB[i]]);
  for (let i = 0; i < tF.length; i++) members.push([tF[i], tB[i]]);
  const arrows = [P(500, 320, dz), P(650, 320, dz), P(800, 320, dz)];
  return { members, nodes, arrows };
}

function TrussScene({ opacity }) {
  const { members, nodes, arrows } = React.useMemo(() => trussData(), []);
  return (
    <group>
      {members.map((m, i) => (
        <Member key={i} a={m[0]} b={m[1]} radius={0.055} color={C.steel} opacity={opacity} />
      ))}
      {nodes.map((n, i) => (
        <Node key={`n${i}`} p={n} color={C.forest} opacity={opacity} />
      ))}
      {arrows.map((a, i) => (
        <Arrow key={`a${i}`} from={[a[0], a[1] + 0.95, a[2]]} to={[a[0], a[1] + 0.16, a[2]]} opacity={opacity} />
      ))}
    </group>
  );
}

// ── 2. Fluid — a rippling liquid surface with flow arrows ────────────────────

function FluidScene({ opacity }) {
  const geoRef = React.useRef();
  const W = 8.6, D = 3.4, SX = 72, SY = 30;
  useFrame((state) => {
    const g = geoRef.current;
    if (!g) return;
    const t = state.clock.elapsedTime;
    const pos = g.attributes.position;
    for (let i = 0; i < pos.count; i++) {
      const x = pos.getX(i);
      const y = pos.getY(i);
      const z =
        0.20 * Math.sin(x * 1.15 + t * 1.6) +
        0.12 * Math.sin(y * 1.7 - t * 1.15) +
        0.06 * Math.sin((x + y) * 2.2 + t * 2.1);
      pos.setZ(i, z);
    }
    pos.needsUpdate = true;
    g.computeVertexNormals();
  });
  return (
    <group position={[0, 0.1, 0]}>
      {/* The free surface (plane laid flat, displaced vertically). */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} receiveShadow castShadow>
        <planeGeometry ref={geoRef} args={[W, D, SX, SY]} />
        <meshStandardMaterial
          color={C.water}
          metalness={0.45}
          roughness={0.12}
          transparent
          opacity={opacity * 0.92}
          side={THREE.DoubleSide}
        />
      </mesh>
      {/* Shallow basin walls to read as a channel of fluid. */}
      <Beam a={[-W / 2, -0.18, D / 2]} b={[W / 2, -0.18, D / 2]} width={0.12} thickness={0.42} color={C.steel} opacity={opacity} />
      <Beam a={[-W / 2, -0.18, -D / 2]} b={[W / 2, -0.18, -D / 2]} width={0.12} thickness={0.42} color={C.steel} opacity={opacity} />
      {/* Flow direction arrows skimming the surface. */}
      <Arrow from={[-2.6, 0.55, -0.8]} to={[-1.0, 0.55, -0.8]} opacity={opacity} />
      <Arrow from={[0.0, 0.55, 0.7]} to={[1.6, 0.55, 0.7]} opacity={opacity} />
      <Arrow from={[1.0, 0.55, -0.5]} to={[2.6, 0.55, -0.5]} opacity={opacity} />
    </group>
  );
}

// ── 3. Transportation — a 3D road deck over a crest vertical curve ───────────

function RoadScene({ opacity }) {
  const segs = React.useMemo(() => {
    const N = 26;
    const x0 = -4.0, x1 = 4.0;
    const crest = (x) => 1.05 - 0.085 * x * x; // PVI apex at x=0
    const pts = [];
    for (let i = 0; i <= N; i++) {
      const x = x0 + ((x1 - x0) * i) / N;
      pts.push([x, crest(x), 0]);
    }
    const deck = [];
    const stripe = [];
    for (let i = 0; i < pts.length - 1; i++) {
      deck.push([pts[i], pts[i + 1]]);
      if (i % 2 === 0) stripe.push([pts[i], pts[i + 1]]); // dashed centerline
    }
    return { deck, stripe, apex: [0, crest(0), 0] };
  }, []);
  return (
    <group position={[0, -0.15, 0]}>
      {segs.deck.map((s, i) => (
        <Beam key={`d${i}`} a={s[0]} b={s[1]} width={1.7} thickness={0.16} color={C.steel} opacity={opacity} />
      ))}
      {segs.stripe.map((s, i) => (
        <Beam
          key={`s${i}`}
          a={[s[0][0], s[0][1] + 0.10, 0]}
          b={[s[1][0], s[1][1] + 0.10, 0]}
          width={0.13}
          thickness={0.04}
          color={C.sunbeam}
          opacity={opacity}
          metalness={0.3}
          roughness={0.5}
        />
      ))}
      {/* PVI marker at the crest + a sight-distance arrow over the hump. */}
      <Node p={[segs.apex[0], segs.apex[1] + 0.16, 0]} r={0.12} color={C.sunbeam} emissive={C.sunbeam} opacity={opacity} />
      <Arrow from={[-2.2, 1.5, 0]} to={[2.2, 1.5, 0]} opacity={opacity} />
    </group>
  );
}

// ── 4. Surveying — vertical stations + triangulated sight lines on terrain ───

function SurveyScene({ opacity }) {
  const { stations, lines } = React.useMemo(() => {
    const g = -0.85; // ground level
    const defs = [
      { x: -3.2, z: 0.3, h: 1.55 },
      { x: 0.5, z: -1.45, h: 1.15 },
      { x: 3.1, z: 0.7, h: 1.35 },
      { x: -0.7, z: 1.55, h: 0.95 },
    ];
    const stations = defs.map((d) => ({ base: [d.x, g, d.z], top: [d.x, g + d.h, d.z] }));
    const t = stations.map((s) => s.top);
    const lines = [
      [t[0], t[1]], [t[1], t[2]], [t[2], t[0]], [t[1], t[3]], [t[3], t[0]],
    ];
    return { stations, lines, ground: g };
  }, []);
  return (
    <group position={[0, 0.1, 0]}>
      {/* Faint ground plane the stations sit on. */}
      <mesh position={[0, -0.86, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
        <planeGeometry args={[9, 4.2]} />
        <meshStandardMaterial color={C.cream} metalness={0.1} roughness={0.9} transparent opacity={opacity * 0.5} side={THREE.DoubleSide} />
      </mesh>
      {/* Triangulated sight lines (steel). */}
      {lines.map((l, i) => (
        <Member key={`l${i}`} a={l[0]} b={l[1]} radius={0.028} color={C.steel} opacity={opacity} />
      ))}
      {/* Stations: vertical pole + sunbeam beacon. */}
      {stations.map((s, i) => (
        <group key={`st${i}`}>
          <Member a={s.base} b={s.top} radius={0.045} color={C.steel} opacity={opacity} />
          <Node p={s.top} r={0.13} color={C.sunbeam} emissive={C.sunbeam} opacity={opacity} />
          <Node p={s.base} r={0.08} color={C.forest} opacity={opacity} />
        </group>
      ))}
    </group>
  );
}

// ── 5. Geotechnical — solid stacked soil strata + a bearing footing ──────────

function GeoScene({ opacity }) {
  const layers = React.useMemo(() => {
    const colors = ['#8a8278', '#6f685d', '#7c7468', '#5a544c', '#675f55'];
    const W = 7.6, D = 2.8, H = 0.5;
    const arr = [];
    let y = -1.55;
    for (let i = 0; i < colors.length; i++) {
      arr.push({ y: y + H / 2, color: colors[i], W, D, H });
      y += H;
    }
    return { arr, topY: y };
  }, []);
  const topSurface = layers.topY; // top of the highest slab
  return (
    <group position={[0, 0.05, 0]}>
      {layers.arr.map((l, i) => (
        <mesh key={`g${i}`} position={[0, l.y, 0]} castShadow receiveShadow>
          <boxGeometry args={[l.W, l.H, l.D]} />
          <meshStandardMaterial color={l.color} metalness={0.15} roughness={0.85} transparent={opacity < 1} opacity={opacity} />
        </mesh>
      ))}
      {/* Spread footing + column bearing on the surface. */}
      <mesh position={[0, topSurface + 0.16, 0]} castShadow receiveShadow>
        <boxGeometry args={[1.9, 0.32, 1.7]} />
        <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.34} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <mesh position={[0, topSurface + 0.32 + 0.45, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.55, 0.9, 0.55]} />
        <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.34} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <Arrow from={[0, topSurface + 2.35, 0]} to={[0, topSurface + 1.4, 0]} opacity={opacity} />
    </group>
  );
}

const TOPICS = [TrussScene, FluidScene, RoadScene, SurveyScene, GeoScene];

function Cycler({ reduced }) {
  const grp = React.useRef();
  const [phase, setPhase] = React.useState(0);
  const opacityRef = React.useRef(1);
  const [, force] = React.useReducer((n) => n + 1, 0);

  useFrame((state) => {
    const t = state.clock.elapsedTime;
    const idx = Math.min(4, Math.floor((t % 15) / 3));
    if (idx !== phase) setPhase(idx);
    const local = (t % 15) % 3;
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

  const Scene = TOPICS[phase];

  // Shift right + scale down so the structure sits in the right of the slot and
  // clears the headline copy on the left.
  return (
    <group ref={grp} position={[1.7, -0.3, 0]} scale={0.78}>
      <Scene opacity={opacityRef.current} />
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
