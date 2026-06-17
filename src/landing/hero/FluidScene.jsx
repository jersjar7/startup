import React from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';
import { C, Box, Arrow } from './primitives';

// FE topic: Fluid Mechanics — an open-channel flume with a floor and full-height
// side walls confining a body of water, an animated free surface
// (vertex-displaced) tilted to suggest backwater, an upstream inflow pipe with a
// falling jet, a downstream sharp-crested weir plate, and a logarithmic velocity
// profile traced by an ember envelope curve. Every material honors `opacity`.

// A thin emissive ember tube tracing a polyline of [x,y,z] points — used to draw
// the concave u(y) velocity-profile envelope connecting the arrow tips.
function ProfileCurve({ points, radius = 0.022, color = C.ember, opacity = 1 }) {
  const geo = React.useMemo(() => {
    const curve = new THREE.CatmullRomCurve3(points.map((p) => new THREE.Vector3(...p)));
    return new THREE.TubeGeometry(curve, 40, radius, 8, false);
  }, [points, radius]);
  return (
    <mesh geometry={geo} castShadow>
      <meshStandardMaterial
        color={color}
        emissive={color}
        emissiveIntensity={1.2}
        metalness={0.2}
        roughness={0.5}
        transparent={opacity < 1}
        opacity={opacity}
      />
    </mesh>
  );
}

export function FluidScene({ opacity }) {
  const geoRef = React.useRef();
  const W = 8.2, D = 3.0, SX = 70, SY = 28;
  // Free-surface level sits mid-wall (well above the floor) for a real body of
  // water. A gentle tilt raises the upstream/gate end to read as backwater.
  const surfaceY = 0.06;
  const backwaterTilt = -0.045; // radians, about the channel-cross axis
  useFrame((state) => {
    const g = geoRef.current;
    if (!g) return;
    const t = state.clock.elapsedTime;
    const pos = g.attributes.position;
    for (let i = 0; i < pos.count; i++) {
      const x = pos.getX(i);
      const y = pos.getY(i);
      const z =
        0.22 * Math.sin(x * 1.2 + t * 1.7) +
        0.13 * Math.sin(y * 1.7 - t * 1.15) +
        0.07 * Math.sin((x + y) * 2.2 + t * 2.2);
      pos.setZ(i, z);
    }
    pos.needsUpdate = true;
    g.computeVertexNormals();
  });

  const wallH = 0.82;
  const floorY = -0.42;
  const wallTopY = floorY + wallH;
  const innerHalfD = D / 2; // water sits inside the wall inner faces
  const waterW = W; // surface width leaves a thin lip of floor inside the walls

  // Logarithmic velocity profile u(y): short near the bed, long near the
  // surface. Tails share a common bed line; tips traced by an envelope curve.
  const bedY = floorY + 0.04;
  const profX = -2.2;      // anchored against the near wall, upstream-ish
  const profZ = innerHalfD - 0.18;
  const surfRelY = surfaceY; // top of profile near the free surface
  const uMax = 1.7;
  const samples = [0.08, 0.26, 0.46, 0.68, 0.92]; // fractional height up the column
  const profile = samples.map((f) => {
    const yy = bedY + f * (surfRelY - bedY);
    // log-law-ish: u grows quickly off the bed then flattens near the surface
    const u = 0.35 + uMax * Math.log(1 + 9 * f) / Math.log(10);
    return { y: yy, len: u };
  });
  const envelopePts = profile.map((p) => [profX + p.len, p.y, profZ]);

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
      {/* Falling jet/plume — tapered cone of water from the mouth to the surface */}
      <mesh position={[-W / 2 + 0.5, (wallTopY + 0.18 + surfaceY) / 2, 0.55]} rotation={[0, 0, -0.16]} castShadow>
        <coneGeometry args={[0.13, wallTopY + 0.18 - surfaceY, 14, 1, true]} />
        <meshStandardMaterial color={C.water} metalness={0.1} roughness={0.25} transparent opacity={opacity * 0.7} side={THREE.DoubleSide} />
      </mesh>

      {/* Downstream sharp-crested weir plate: vertical, full channel width,
          steel body with a thin sunbeam crest cap. Backs up the flow. */}
      <Box position={[W / 2 - 0.55, floorY + 0.06 + 0.85 / 2, 0]} size={[0.1, 0.85, D]} color={C.steel} opacity={opacity} metalness={0.8} roughness={0.32} />
      {/* Sunbeam crest accent strip on top of the weir plate */}
      <Box position={[W / 2 - 0.55, floorY + 0.06 + 0.85 + 0.025, 0]} size={[0.12, 0.05, D]} color={C.sunbeam} opacity={opacity} metalness={0.4} roughness={0.45} />
      {/* Thin overflow nappe spilling over the crest */}
      <mesh position={[W / 2 - 0.47, floorY + 0.06 + 0.85 - 0.12, 0]} rotation={[0, 0, -0.28]} castShadow>
        <boxGeometry args={[0.04, 0.32, D - 0.2]} />
        <meshStandardMaterial color={C.water} metalness={0.1} roughness={0.25} transparent opacity={opacity * 0.65} />
      </mesh>

      {/* Logarithmic velocity profile against the near wall: tails on a common
          bed line, increasing length toward the surface, tips traced by an
          ember envelope curve. */}
      {profile.map((p, i) => (
        <Arrow key={`v${i}`} from={[profX, p.y, profZ]} to={[profX + p.len, p.y, profZ]} radius={0.028} opacity={opacity} />
      ))}
      {/* Vertical bed origin line for the profile */}
      <mesh position={[profX, (bedY + surfRelY) / 2, profZ]} castShadow>
        <cylinderGeometry args={[0.012, 0.012, surfRelY - bedY, 8]} />
        <meshStandardMaterial color={C.ember} emissive={C.ember} emissiveIntensity={0.8} metalness={0.2} roughness={0.5} transparent={opacity < 1} opacity={opacity * 0.7} />
      </mesh>
      <ProfileCurve points={envelopePts} opacity={opacity * 0.95} />
    </group>
  );
}
