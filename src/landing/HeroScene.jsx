import React from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Environment, ContactShadows, Lightformer } from '@react-three/drei';
import * as THREE from 'three';

// Brushed-steel hero animation (concept 1). Replaces the right-side HeroSvg with
// a 3D scene that cycles the same five FE Civil topics, each a detailed
// volumetric object under studio lighting with soft contact shadows and ember
// accents. Same 15s / 5-phase (3s each) cadence as TopicLabel.

const C = {
  cream: '#FFF9F0',
  charcoal: '#2C2C2C',
  steel: '#4c4c4c',
  steelLt: '#6f6f6f',
  ember: '#E8683A',
  forest: '#2D7A5F',
  sunbeam: '#F5B731',
  water: '#2f6f7a',
  info: '#3B82B8',
  skin: '#d8a983',
  hair: '#43301f',
  asphalt: '#3b3b3b',
};

const Y = new THREE.Vector3(0, 1, 0);
const X = new THREE.Vector3(1, 0, 0);

const P = (x, y, z = 0) => [(x - 600) / 95, (430 - y) / 95, z];

// ── Shared primitives ───────────────────────────────────────────────────────

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
      <cylinderGeometry args={[radius, radius, len, 12]} />
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

// A simple box solid.
function Box({ position, size, color = C.steel, opacity = 1, metalness = 0.85, roughness = 0.4, rotation }) {
  return (
    <mesh position={position} rotation={rotation} castShadow receiveShadow>
      <boxGeometry args={size} />
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

function Arrow({ from, to, radius = 0.035, color = C.ember, opacity = 1 }) {
  const { shaftMid, shaftLen, headPos, quat } = React.useMemo(() => {
    const va = new THREE.Vector3(...from);
    const vb = new THREE.Vector3(...to);
    const dir = new THREE.Vector3().subVectors(vb, va);
    const ndir = dir.clone().normalize();
    const headLen = 0.2;
    const end = vb.clone().addScaledVector(ndir, -headLen);
    const q = new THREE.Quaternion().setFromUnitVectors(Y, ndir);
    return {
      shaftMid: va.clone().add(end).multiplyScalar(0.5),
      shaftLen: Math.max(0.001, va.distanceTo(end)),
      headPos: vb.clone().addScaledVector(ndir, -headLen / 2),
      quat: q,
    };
  }, [from, to]);
  return (
    <group>
      <mesh position={shaftMid} quaternion={quat} castShadow>
        <cylinderGeometry args={[radius, radius, shaftLen, 12]} />
        <meshStandardMaterial color={color} emissive={color} emissiveIntensity={1.4} metalness={0.2} roughness={0.5} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <mesh position={headPos} quaternion={quat} castShadow>
        <coneGeometry args={[radius * 3, 0.2, 14]} />
        <meshStandardMaterial color={color} emissive={color} emissiveIntensity={1.4} metalness={0.2} roughness={0.5} transparent={opacity < 1} opacity={opacity} />
      </mesh>
    </group>
  );
}

// A low-poly human figure. `lean` bends the torso forward (to sight a scope);
// `ponytail` reads as the woman engineer; `hardHat` colors the helmet.
function Person({ position = [0, 0, 0], rotation = [0, 0, 0], scale = 1, vest = C.ember, ponytail = false, hardHat = C.sunbeam, lean = 0, armPose = 'down', opacity = 1 }) {
  const mat = (color, metalness = 0.15, roughness = 0.75) => (
    <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
  );
  // arm rotations by pose
  const armL = armPose === 'sight' ? [1.15, 0, 0.25] : armPose === 'hold' ? [2.4, 0, 0.1] : [0.18, 0, 0.22];
  const armR = armPose === 'sight' ? [1.15, 0, -0.25] : armPose === 'hold' ? [0.2, 0, -0.15] : [0.18, 0, -0.22];
  return (
    <group position={position} rotation={rotation} scale={scale}>
      {/* legs */}
      <mesh position={[-0.1, 0.34, 0]} castShadow><capsuleGeometry args={[0.075, 0.5, 4, 10]} />{mat('#34373b')}</mesh>
      <mesh position={[0.1, 0.34, 0]} castShadow><capsuleGeometry args={[0.075, 0.5, 4, 10]} />{mat('#34373b')}</mesh>
      <group position={[0, 0.66, 0]} rotation={[lean, 0, 0]}>
        {/* torso (hi-vis vest) */}
        <mesh position={[0, 0.27, 0]} castShadow><capsuleGeometry args={[0.135, 0.34, 4, 12]} />{mat(vest, 0.2, 0.6)}</mesh>
        {/* arms */}
        <mesh position={[-0.19, 0.32, 0.02]} rotation={armL} castShadow><capsuleGeometry args={[0.05, 0.36, 4, 10]} />{mat(vest, 0.2, 0.6)}</mesh>
        <mesh position={[0.19, 0.32, 0.02]} rotation={armR} castShadow><capsuleGeometry args={[0.05, 0.36, 4, 10]} />{mat(vest, 0.2, 0.6)}</mesh>
        {/* neck + head */}
        <mesh position={[0, 0.56, 0.02]} castShadow><sphereGeometry args={[0.115, 16, 16]} />{mat(C.skin)}</mesh>
        {/* ponytail behind the head */}
        {ponytail && (
          <mesh position={[0, 0.55, -0.13]} rotation={[0.55, 0, 0]} castShadow>
            <capsuleGeometry args={[0.045, 0.22, 4, 8]} />{mat(C.hair)}
          </mesh>
        )}
        {/* hard hat */}
        <mesh position={[0, 0.62, 0.02]} castShadow>
          <sphereGeometry args={[0.13, 16, 14, 0, Math.PI * 2, 0, Math.PI / 2]} />{mat(hardHat, 0.1, 0.5)}
        </mesh>
        <mesh position={[0, 0.62, 0.12]} castShadow><boxGeometry args={[0.18, 0.02, 0.1]} />{mat(hardHat, 0.1, 0.5)}</mesh>
      </group>
    </group>
  );
}

function smoothstep(e0, e1, x) {
  const t = Math.max(0, Math.min(1, (x - e0) / (e1 - e0)));
  return t * t * (3 - 2 * t);
}

// ── 1. Structural — 3D truss bridge with deck + pin/roller supports ──────────

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
  const left = P(200, 500, 0);
  const right = P(1000, 500, 0);
  const deckY = P(200, 500, 0)[1];
  return { members, nodes, arrows, dz, left, right, deckY, spanX: [P(200, 500, 0)[0], P(1000, 500, 0)[0]] };
}

function TrussScene({ opacity }) {
  const d = React.useMemo(() => trussData(), []);
  const [x0, x1] = d.spanX;
  const deckMid = (x0 + x1) / 2;
  return (
    <group>
      {d.members.map((m, i) => (
        <Member key={i} a={m[0]} b={m[1]} radius={0.055} color={C.steel} opacity={opacity} />
      ))}
      {d.nodes.map((n, i) => (
        <Node key={`n${i}`} p={n} r={0.1} color={C.forest} opacity={opacity} />
      ))}
      {/* roadway deck spanning the bottom chords */}
      <Box position={[deckMid, d.deckY + 0.02, 0]} size={[x1 - x0, 0.06, 2 * d.dz]} color={C.steelLt} opacity={opacity} metalness={0.6} roughness={0.5} />
      {/* load arrows on the front top chord */}
      {d.arrows.map((a, i) => (
        <Arrow key={`a${i}`} from={[a[0], a[1] + 0.95, a[2]]} to={[a[0], a[1] + 0.16, a[2]]} opacity={opacity} />
      ))}
      {/* abutments + pin (left) and roller (right) supports */}
      <Box position={[d.left[0], d.deckY - 0.34, 0]} size={[0.5, 0.4, 2 * d.dz + 0.3]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />
      <Box position={[d.right[0], d.deckY - 0.34, 0]} size={[0.5, 0.4, 2 * d.dz + 0.3]} color="#5d564c" opacity={opacity} metalness={0.1} roughness={0.9} />
      {/* pin support: triangle bracket */}
      <mesh position={[d.left[0], d.deckY - 0.13, 0]} rotation={[0, 0, 0]} castShadow>
        <coneGeometry args={[0.16, 0.22, 4]} />
        <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.34} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      {/* roller support: triangle + rollers */}
      <mesh position={[d.right[0], d.deckY - 0.1, 0]} castShadow>
        <coneGeometry args={[0.16, 0.18, 4]} />
        <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.34} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      {[-0.45, 0, 0.45].map((z, i) => (
        <mesh key={`r${i}`} position={[d.right[0], d.deckY - 0.21, z]} rotation={[0, 0, Math.PI / 2]} castShadow>
          <cylinderGeometry args={[0.05, 0.05, 0.18, 12]} />
          <meshStandardMaterial color={C.steel} metalness={0.9} roughness={0.3} transparent={opacity < 1} opacity={opacity} />
        </mesh>
      ))}
    </group>
  );
}

// ── 2. Fluid — an open-channel flume: floor + walls, inflow, weir, profile ───

function FluidScene({ opacity }) {
  const geoRef = React.useRef();
  const W = 8.2, D = 3.0, SX = 70, SY = 28;
  useFrame((state) => {
    const g = geoRef.current;
    if (!g) return;
    const t = state.clock.elapsedTime;
    const pos = g.attributes.position;
    for (let i = 0; i < pos.count; i++) {
      const x = pos.getX(i);
      const y = pos.getY(i);
      const z =
        0.18 * Math.sin(x * 1.2 + t * 1.7) +
        0.11 * Math.sin(y * 1.7 - t * 1.15) +
        0.06 * Math.sin((x + y) * 2.2 + t * 2.2);
      pos.setZ(i, z);
    }
    pos.needsUpdate = true;
    g.computeVertexNormals();
  });
  const wallH = 0.7;
  return (
    <group position={[0, 0.05, 0]}>
      {/* channel floor */}
      <Box position={[0, -0.42, 0]} size={[W + 0.3, 0.12, D + 0.3]} color={C.steel} opacity={opacity} metalness={0.7} roughness={0.45} />
      {/* side walls */}
      <Box position={[0, -0.42 + wallH / 2, D / 2 + 0.09]} size={[W + 0.3, wallH, 0.12]} color={C.steelLt} opacity={opacity} metalness={0.7} roughness={0.45} />
      <Box position={[0, -0.42 + wallH / 2, -D / 2 - 0.09]} size={[W + 0.3, wallH, 0.12]} color={C.steelLt} opacity={opacity} metalness={0.7} roughness={0.45} />
      {/* free surface */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} receiveShadow castShadow>
        <planeGeometry ref={geoRef} args={[W, D, SX, SY]} />
        <meshStandardMaterial color={C.water} metalness={0.45} roughness={0.12} transparent opacity={opacity * 0.9} side={THREE.DoubleSide} />
      </mesh>
      {/* upstream inflow pipe + falling stream */}
      <mesh position={[-W / 2 - 0.15, 0.55, 0.6]} rotation={[0, 0, Math.PI / 2.4]} castShadow>
        <cylinderGeometry args={[0.16, 0.16, 0.9, 16]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.85} roughness={0.35} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <Box position={[-W / 2 + 0.18, 0.1, 0.6]} size={[0.16, 0.7, 0.22]} color={C.water} opacity={opacity * 0.8} metalness={0.4} roughness={0.15} rotation={[0, 0, -0.25]} />
      {/* downstream weir / sluice gate */}
      <Box position={[W / 2 - 0.2, 0.08, 0]} size={[0.1, 0.7, D]} color={C.steel} opacity={opacity} metalness={0.9} roughness={0.3} />
      <Box position={[W / 2 - 0.2, 0.5, 0]} size={[0.16, 0.18, D + 0.1]} color={C.sunbeam} opacity={opacity} metalness={0.3} roughness={0.5} />
      {/* velocity profile: arrows growing toward the surface */}
      {[0.0, 0.18, 0.34, 0.46].map((h, i) => (
        <Arrow key={`v${i}`} from={[-1.4, -0.25 + h, -0.7]} to={[-1.4 + 0.5 + i * 0.45, -0.25 + h, -0.7]} radius={0.03} opacity={opacity} />
      ))}
    </group>
  );
}

// ── 3. Transportation — road deck over a crest, guardrails, slopes, a car ────

function RoadScene({ opacity }) {
  const data = React.useMemo(() => {
    const N = 26;
    const x0 = -4.0, x1 = 4.0;
    const crest = (x) => 1.0 - 0.082 * x * x;
    const pts = [];
    for (let i = 0; i <= N; i++) {
      const x = x0 + ((x1 - x0) * i) / N;
      pts.push([x, crest(x), 0]);
    }
    const deck = [], stripe = [];
    for (let i = 0; i < pts.length - 1; i++) {
      deck.push([pts[i], pts[i + 1]]);
      if (i % 2 === 0) stripe.push([pts[i], pts[i + 1]]);
    }
    // guardrail posts along both edges
    const posts = [];
    for (let i = 0; i <= N; i += 3) posts.push(pts[i]);
    return { pts, deck, stripe, posts, crest, apex: [0, crest(0), 0], x0, x1 };
  }, []);
  const halfW = 0.95;
  return (
    <group position={[0, -0.1, 0]}>
      {data.deck.map((s, i) => (
        <Beam key={`d${i}`} a={s[0]} b={s[1]} width={1.9} thickness={0.16} color={C.asphalt} opacity={opacity} metalness={0.2} roughness={0.8} />
      ))}
      {/* edge lines (cream) + dashed centerline (sunbeam) */}
      {data.deck.map((s, i) => (
        <React.Fragment key={`e${i}`}>
          <Beam a={[s[0][0], s[0][1] + 0.09, halfW - 0.08]} b={[s[1][0], s[1][1] + 0.09, halfW - 0.08]} width={0.08} thickness={0.03} color={C.cream} opacity={opacity} metalness={0.1} roughness={0.7} />
          <Beam a={[s[0][0], s[0][1] + 0.09, -halfW + 0.08]} b={[s[1][0], s[1][1] + 0.09, -halfW + 0.08]} width={0.08} thickness={0.03} color={C.cream} opacity={opacity} metalness={0.1} roughness={0.7} />
        </React.Fragment>
      ))}
      {data.stripe.map((s, i) => (
        <Beam key={`s${i}`} a={[s[0][0], s[0][1] + 0.09, 0]} b={[s[1][0], s[1][1] + 0.09, 0]} width={0.12} thickness={0.03} color={C.sunbeam} opacity={opacity} metalness={0.3} roughness={0.5} />
      ))}
      {/* guardrails: posts + a continuous rail on each side */}
      {data.posts.map((p, i) => (
        <React.Fragment key={`p${i}`}>
          <Box position={[p[0], p[1] + 0.18, halfW]} size={[0.05, 0.34, 0.05]} color={C.steelLt} opacity={opacity} />
          <Box position={[p[0], p[1] + 0.18, -halfW]} size={[0.05, 0.34, 0.05]} color={C.steelLt} opacity={opacity} />
        </React.Fragment>
      ))}
      {data.deck.map((s, i) => (
        <React.Fragment key={`g${i}`}>
          <Beam a={[s[0][0], s[0][1] + 0.32, halfW]} b={[s[1][0], s[1][1] + 0.32, halfW]} width={0.06} thickness={0.07} color={C.steel} opacity={opacity} />
          <Beam a={[s[0][0], s[0][1] + 0.32, -halfW]} b={[s[1][0], s[1][1] + 0.32, -halfW]} width={0.06} thickness={0.07} color={C.steel} opacity={opacity} />
        </React.Fragment>
      ))}
      {/* earth side-slopes under the deck ends */}
      <mesh position={[data.x0 + 0.2, data.crest(data.x0) - 0.7, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.9, 1.2, 2.1]} />
        <meshStandardMaterial color="#6f685d" metalness={0.1} roughness={0.95} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <mesh position={[data.x1 - 0.2, data.crest(data.x1) - 0.7, 0]} castShadow receiveShadow>
        <boxGeometry args={[0.9, 1.2, 2.1]} />
        <meshStandardMaterial color="#6f685d" metalness={0.1} roughness={0.95} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      {/* PVI marker + sight-distance arrow over the hump */}
      <Node p={[data.apex[0], data.apex[1] + 0.16, 0]} r={0.1} color={C.sunbeam} emissive={C.sunbeam} opacity={opacity} />
      <Arrow from={[-2.3, 1.5, 0]} to={[2.3, 1.5, 0]} opacity={opacity} />
      {/* a car cresting the curve */}
      <group position={[0.7, data.crest(0.7) + 0.2, 0]}>
        <Box position={[0, 0, 0]} size={[0.7, 0.18, 0.5]} color={C.ember} opacity={opacity} metalness={0.4} roughness={0.4} />
        <Box position={[-0.03, 0.16, 0]} size={[0.36, 0.18, 0.42]} color={C.ember} opacity={opacity} metalness={0.4} roughness={0.4} />
        {[[0.22, -0.1, 0.26], [0.22, -0.1, -0.26], [-0.24, -0.1, 0.26], [-0.24, -0.1, -0.26]].map((w, i) => (
          <mesh key={i} position={w} rotation={[Math.PI / 2, 0, 0]} castShadow>
            <cylinderGeometry args={[0.1, 0.1, 0.07, 14]} />
            <meshStandardMaterial color="#1f1f1f" metalness={0.3} roughness={0.6} transparent={opacity < 1} opacity={opacity} />
          </mesh>
        ))}
      </group>
    </group>
  );
}

// ── 4. Surveying — terrain levels + tripod total station + crew ──────────────

function terrainH(x, z) {
  return (
    0.34 * Math.sin(x * 0.6 + 0.4) +
    0.22 * Math.cos(z * 0.9 - 0.3) +
    0.14 * Math.sin((x - z) * 0.5) -
    0.04 * x
  );
}

function Terrain({ opacity }) {
  const geoRef = React.useRef();
  const W = 9.0, D = 4.6, SX = 90, SY = 48;
  React.useEffect(() => {
    const g = geoRef.current;
    if (!g) return;
    const pos = g.attributes.position;
    for (let i = 0; i < pos.count; i++) {
      // plane is in XY before the -90° X rotation: x→x, y→-z(world)
      const x = pos.getX(i);
      const y = pos.getY(i);
      pos.setZ(i, terrainH(x, -y));
    }
    pos.needsUpdate = true;
    g.computeVertexNormals();
  }, []);
  return (
    <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.9, 0]} receiveShadow castShadow>
      <planeGeometry ref={geoRef} args={[W, D, SX, SY]} />
      <meshStandardMaterial color="#5f7d5a" metalness={0.1} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
    </mesh>
  );
}

function TotalStation({ x, z, opacity, look }) {
  const g = -0.9;
  const baseY = g + terrainH(x, z);
  const headY = baseY + 1.05;
  const head = [x, headY, z];
  const feet = [
    [x + 0.42, baseY, z + 0.3],
    [x - 0.48, baseY, z + 0.24],
    [x + 0.06, baseY, z - 0.5],
  ];
  // scope yaw toward the look target (in xz)
  const yaw = Math.atan2(look[0] - x, look[2] - z);
  return (
    <group>
      {feet.map((f, i) => (
        <Member key={i} a={head} b={f} radius={0.028} color={C.steel} opacity={opacity} />
      ))}
      {/* instrument body */}
      <Box position={[x, headY + 0.1, z]} size={[0.2, 0.22, 0.18]} color={C.steelLt} opacity={opacity} metalness={0.8} roughness={0.35} />
      {/* telescope, pointed at the rod */}
      <group position={[x, headY + 0.14, z]} rotation={[0, yaw, 0]}>
        <mesh position={[0, 0, 0.16]} rotation={[Math.PI / 2, 0, 0]} castShadow>
          <cylinderGeometry args={[0.045, 0.045, 0.34, 14]} />
          <meshStandardMaterial color={C.charcoal || '#2C2C2C'} metalness={0.6} roughness={0.4} transparent={opacity < 1} opacity={opacity} />
        </mesh>
      </group>
      <Node p={[x, headY + 0.14, z]} r={0.05} color={C.ember} emissive={C.ember} opacity={opacity} />
    </group>
  );
}

function StadiaRod({ x, z, opacity }) {
  const g = -0.9;
  const baseY = g + terrainH(x, z);
  const segs = 9;
  const h = 0.2;
  return (
    <group position={[x, baseY, z]}>
      {Array.from({ length: segs }).map((_, i) => (
        <Box key={i} position={[0, h / 2 + i * h, 0]} size={[0.09, h, 0.05]} color={i % 2 === 0 ? C.cream : C.ember} opacity={opacity} metalness={0.1} roughness={0.6} />
      ))}
    </group>
  );
}

function SurveyScene({ opacity }) {
  const g = -0.9;
  const station = { x: -2.6, z: 0.5 };
  const rod = { x: 3.0, z: -0.4 };
  const stationHead = [station.x, g + terrainH(station.x, station.z) + 1.19, station.z];
  const rodTop = [rod.x, g + terrainH(rod.x, rod.z) + 1.4, rod.z];
  return (
    <group position={[0, 0.15, 0]}>
      <Terrain opacity={opacity} />
      <TotalStation x={station.x} z={station.z} opacity={opacity} look={[rod.x, rodTop[1], rod.z]} />
      <StadiaRod x={rod.x} z={rod.z} opacity={opacity} />
      {/* line of sight (ember) from scope to the rod reading */}
      <Member a={stationHead} b={[rod.x, g + terrainH(rod.x, rod.z) + 0.9, rod.z]} radius={0.012} color={C.ember} emissive={C.ember} opacity={opacity * 0.9} />
      {/* the woman engineer, sighting through the station */}
      <Person
        position={[station.x - 0.55, g + terrainH(station.x - 0.55, station.z) , station.z]}
        rotation={[0, Math.PI / 2 + 0.25, 0]}
        scale={0.62}
        vest={C.ember}
        ponytail
        hardHat={C.sunbeam}
        lean={0.5}
        armPose="sight"
        opacity={opacity}
      />
      {/* the rodperson, holding the staff at the far extent */}
      <Person
        position={[rod.x - 0.32, g + terrainH(rod.x - 0.32, rod.z), rod.z + 0.05]}
        rotation={[0, -Math.PI / 2 - 0.2, 0]}
        scale={0.62}
        vest={C.forest}
        hardHat={C.cream}
        armPose="hold"
        opacity={opacity}
      />
    </group>
  );
}

// ── 5. Geotechnical — strata + footing on piles, water table, borehole core ──

function GeoScene({ opacity }) {
  const layers = React.useMemo(() => {
    const colors = ['#8a8278', '#6f685d', '#7c7468', '#5a544c', '#675f55'];
    const W = 7.4, D = 2.8, H = 0.5;
    const arr = [];
    let y = -1.55;
    for (let i = 0; i < colors.length; i++) {
      arr.push({ y: y + H / 2, color: colors[i], W, D, H });
      y += H;
    }
    return { arr, topY: y, W, D, H };
  }, []);
  const topSurface = layers.topY;
  const pileBottom = layers.arr[1].y; // piles reach the 2nd-from-bottom stratum
  const pileXs = [-0.6, 0.6];
  const pileZs = [-0.5, 0.5];
  return (
    <group position={[0, 0.05, 0]}>
      {layers.arr.map((l, i) => (
        <mesh key={`g${i}`} position={[0, l.y, 0]} castShadow receiveShadow>
          <boxGeometry args={[l.W, l.H, l.D]} />
          <meshStandardMaterial color={l.color} metalness={0.12} roughness={0.9} transparent={opacity < 1} opacity={opacity} flatShading />
        </mesh>
      ))}
      {/* groundwater table: a translucent blue sheet across an upper stratum */}
      <Box position={[0, layers.arr[2].y + 0.26, 0]} size={[layers.W + 0.04, 0.02, layers.D + 0.04]} color={C.info} opacity={opacity * 0.45} metalness={0.2} roughness={0.2} />
      {/* spread footing + column */}
      <Box position={[0, topSurface + 0.16, 0]} size={[1.9, 0.32, 1.7]} color={C.steelLt} opacity={opacity} metalness={0.6} roughness={0.5} />
      <Box position={[0, topSurface + 0.32 + 0.45, 0]} size={[0.55, 0.9, 0.55]} color={C.steel} opacity={opacity} metalness={0.9} roughness={0.34} />
      {/* driven piles carrying the footing down through the strata */}
      {pileXs.map((px) =>
        pileZs.map((pz, j) => (
          <Member key={`pile${px}-${j}`} a={[px, topSurface + 0.1, pz]} b={[px, pileBottom, pz]} radius={0.08} color={C.steel} opacity={opacity} />
        )),
      )}
      {/* settlement arrows at the footing */}
      <Arrow from={[0, topSurface + 2.25, 0]} to={[0, topSurface + 1.42, 0]} opacity={opacity} />
      {/* borehole core sample beside the block, banded to match the strata */}
      <group position={[layers.W / 2 + 0.5, 0, layers.D / 2 - 0.4]}>
        {layers.arr.map((l, i) => (
          <mesh key={`core${i}`} position={[0, l.y + 0.9, 0]} castShadow>
            <cylinderGeometry args={[0.12, 0.12, l.H, 18]} />
            <meshStandardMaterial color={l.color} metalness={0.15} roughness={0.85} transparent={opacity < 1} opacity={opacity} />
          </mesh>
        ))}
      </group>
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

  // Sit in the right of the slot, clear of the headline on the left, small
  // enough that the widest topic does not bleed off the right edge.
  return (
    <group ref={grp} position={[-0.15, -0.3, 0]} scale={0.62}>
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
