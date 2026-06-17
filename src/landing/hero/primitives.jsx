import React from 'react';
import * as THREE from 'three';

// Shared building blocks + brand palette for the hero 3D scenes. Each topic
// scene (truss, fluid, road, survey, geo) imports from here. Keep new
// topic-specific geometry inside the topic's own module; only add a helper here
// when more than one topic needs it.

export const C = {
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

export const Y = new THREE.Vector3(0, 1, 0);
export const X = new THREE.Vector3(1, 0, 0);

// Map the SVG truss layout space (0..1200 x, 0..800 y) into centered 3D units.
export const P = (x, y, z = 0) => [(x - 600) / 95, (430 - y) / 95, z];

export function smoothstep(e0, e1, x) {
  const t = Math.max(0, Math.min(1, (x - e0) / (e1 - e0)));
  return t * t * (3 - 2 * t);
}

// A steel cylinder oriented between two 3D points (default axis +Y).
export function Member({ a, b, radius = 0.05, color = C.steel, opacity = 1, emissive }) {
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

// A solid steel box spanning between two points (thickness on Y, width on Z).
export function Beam({ a, b, width = 1.0, thickness = 0.18, color = C.steel, opacity = 1, metalness = 0.85, roughness = 0.4 }) {
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

export function Box({ position, size, color = C.steel, opacity = 1, metalness = 0.85, roughness = 0.4, rotation, flatShading = false }) {
  return (
    <mesh position={position} rotation={rotation} castShadow receiveShadow>
      <boxGeometry args={size} />
      <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} flatShading={flatShading} transparent={opacity < 1} opacity={opacity} />
    </mesh>
  );
}

export function Node({ p, r = 0.11, color = C.forest, opacity = 1, metalness = 0.5, roughness = 0.4, emissive }) {
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
export function Arrow({ from, to, radius = 0.035, color = C.ember, opacity = 1 }) {
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
// `ponytail` reads as the woman engineer; `hardHat` colors the helmet;
// `armPose` is 'down' | 'sight' | 'hold'.
export function Person({ position = [0, 0, 0], rotation = [0, 0, 0], scale = 1, vest = C.ember, ponytail = false, hardHat = C.sunbeam, lean = 0, armPose = 'down', opacity = 1 }) {
  const mat = (color, metalness = 0.15, roughness = 0.75) => (
    <meshStandardMaterial color={color} metalness={metalness} roughness={roughness} transparent={opacity < 1} opacity={opacity} />
  );
  const armL = armPose === 'sight' ? [1.15, 0, 0.25] : armPose === 'hold' ? [2.4, 0, 0.1] : [0.18, 0, 0.22];
  const armR = armPose === 'sight' ? [1.15, 0, -0.25] : armPose === 'hold' ? [0.2, 0, -0.15] : [0.18, 0, -0.22];
  return (
    <group position={position} rotation={rotation} scale={scale}>
      <mesh position={[-0.1, 0.34, 0]} castShadow><capsuleGeometry args={[0.075, 0.5, 4, 10]} />{mat('#34373b')}</mesh>
      <mesh position={[0.1, 0.34, 0]} castShadow><capsuleGeometry args={[0.075, 0.5, 4, 10]} />{mat('#34373b')}</mesh>
      <group position={[0, 0.66, 0]} rotation={[lean, 0, 0]}>
        <mesh position={[0, 0.27, 0]} castShadow><capsuleGeometry args={[0.135, 0.34, 4, 12]} />{mat(vest, 0.2, 0.6)}</mesh>
        <mesh position={[-0.19, 0.32, 0.02]} rotation={armL} castShadow><capsuleGeometry args={[0.05, 0.36, 4, 10]} />{mat(vest, 0.2, 0.6)}</mesh>
        <mesh position={[0.19, 0.32, 0.02]} rotation={armR} castShadow><capsuleGeometry args={[0.05, 0.36, 4, 10]} />{mat(vest, 0.2, 0.6)}</mesh>
        <mesh position={[0, 0.56, 0.02]} castShadow><sphereGeometry args={[0.115, 16, 16]} />{mat(C.skin)}</mesh>
        {ponytail && (
          <mesh position={[0, 0.55, -0.13]} rotation={[0.55, 0, 0]} castShadow>
            <capsuleGeometry args={[0.045, 0.22, 4, 8]} />{mat(C.hair)}
          </mesh>
        )}
        <mesh position={[0, 0.62, 0.02]} castShadow>
          <sphereGeometry args={[0.13, 16, 14, 0, Math.PI * 2, 0, Math.PI / 2]} />{mat(hardHat, 0.1, 0.5)}
        </mesh>
        <mesh position={[0, 0.62, 0.12]} castShadow><boxGeometry args={[0.18, 0.02, 0.1]} />{mat(hardHat, 0.1, 0.5)}</mesh>
      </group>
    </group>
  );
}
