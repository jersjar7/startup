import React from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { C, Box, Arrow } from './primitives';

// FE topic: Fluid Mechanics — an open-channel flume with a floor and walls, an
// animated free surface (vertex-displaced), an upstream inflow pipe, a
// downstream weir/sluice gate, and a velocity profile. `opacity` cross-fades.

export function FluidScene({ opacity }) {
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
      <Box position={[0, -0.42, 0]} size={[W + 0.3, 0.12, D + 0.3]} color={C.steel} opacity={opacity} metalness={0.7} roughness={0.45} />
      <Box position={[0, -0.42 + wallH / 2, D / 2 + 0.09]} size={[W + 0.3, wallH, 0.12]} color={C.steelLt} opacity={opacity} metalness={0.7} roughness={0.45} />
      <Box position={[0, -0.42 + wallH / 2, -D / 2 - 0.09]} size={[W + 0.3, wallH, 0.12]} color={C.steelLt} opacity={opacity} metalness={0.7} roughness={0.45} />
      <mesh rotation={[-Math.PI / 2, 0, 0]} receiveShadow castShadow>
        <planeGeometry ref={geoRef} args={[W, D, SX, SY]} />
        <meshStandardMaterial color={C.water} metalness={0.45} roughness={0.12} transparent opacity={opacity * 0.9} side={THREE.DoubleSide} />
      </mesh>
      <mesh position={[-W / 2 - 0.15, 0.55, 0.6]} rotation={[0, 0, Math.PI / 2.4]} castShadow>
        <cylinderGeometry args={[0.16, 0.16, 0.9, 16]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.85} roughness={0.35} transparent={opacity < 1} opacity={opacity} />
      </mesh>
      <Box position={[-W / 2 + 0.18, 0.1, 0.6]} size={[0.16, 0.7, 0.22]} color={C.water} opacity={opacity * 0.8} metalness={0.4} roughness={0.15} rotation={[0, 0, -0.25]} />
      <Box position={[W / 2 - 0.2, 0.08, 0]} size={[0.1, 0.7, D]} color={C.steel} opacity={opacity} metalness={0.9} roughness={0.3} />
      <Box position={[W / 2 - 0.2, 0.5, 0]} size={[0.16, 0.18, D + 0.1]} color={C.sunbeam} opacity={opacity} metalness={0.3} roughness={0.5} />
      {[0.0, 0.18, 0.34, 0.46].map((h, i) => (
        <Arrow key={`v${i}`} from={[-1.4, -0.25 + h, -0.7]} to={[-1.4 + 0.5 + i * 0.45, -0.25 + h, -0.7]} radius={0.03} opacity={opacity} />
      ))}
    </group>
  );
}
