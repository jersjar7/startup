import React from 'react';
import { C, Box, Node, Member, Person } from './primitives';

// FE topic: Surveying — undulating terrain with real elevation levels, a tripod
// total station with a telescope sighting down the line, the woman engineer
// leaning into the instrument, and a rodperson holding a striped leveling rod
// at the far extent, with the line of sight drawn between them. `opacity`
// cross-fades.

export function terrainH(x, z) {
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
  const yaw = Math.atan2(look[0] - x, look[2] - z);
  return (
    <group>
      {feet.map((f, i) => (
        <Member key={i} a={head} b={f} radius={0.028} color={C.steel} opacity={opacity} />
      ))}
      <Box position={[x, headY + 0.1, z]} size={[0.2, 0.22, 0.18]} color={C.steelLt} opacity={opacity} metalness={0.8} roughness={0.35} />
      <group position={[x, headY + 0.14, z]} rotation={[0, yaw, 0]}>
        <mesh position={[0, 0, 0.16]} rotation={[Math.PI / 2, 0, 0]} castShadow>
          <cylinderGeometry args={[0.045, 0.045, 0.34, 14]} />
          <meshStandardMaterial color={C.charcoal} metalness={0.6} roughness={0.4} transparent={opacity < 1} opacity={opacity} />
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

export function SurveyScene({ opacity }) {
  const g = -0.9;
  const station = { x: -2.6, z: 0.5 };
  const rod = { x: 3.0, z: -0.4 };
  const stationHead = [station.x, g + terrainH(station.x, station.z) + 1.19, station.z];
  return (
    <group position={[0, 0.15, 0]}>
      <Terrain opacity={opacity} />
      <TotalStation x={station.x} z={station.z} opacity={opacity} look={[rod.x, g + terrainH(rod.x, rod.z) + 1.4, rod.z]} />
      <StadiaRod x={rod.x} z={rod.z} opacity={opacity} />
      <Member a={stationHead} b={[rod.x, g + terrainH(rod.x, rod.z) + 0.9, rod.z]} radius={0.012} color={C.ember} emissive={C.ember} opacity={opacity * 0.9} />
      <Person
        position={[station.x - 0.55, g + terrainH(station.x - 0.55, station.z), station.z]}
        rotation={[0, Math.PI / 2 + 0.25, 0]}
        scale={0.62}
        vest={C.ember}
        ponytail
        hardHat={C.sunbeam}
        lean={0.5}
        armPose="sight"
        opacity={opacity}
      />
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
