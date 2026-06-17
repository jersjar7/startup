import React from 'react';
import * as THREE from 'three';
import { C, Box, Node, Member, Person } from './primitives';

// FE topic: Surveying — graded ground with real elevation, a tripod-mounted
// TOTAL STATION (tribrach base + yoke standards + journaled telescope), the
// woman engineer leaning into the instrument, and a rodperson plumbing a
// graduated leveling rod at the far extent. The ember line of sight runs from
// the telescope objective to the rod face. `opacity` cross-fades everything.

export function terrainH(x, z) {
  return (
    0.34 * Math.sin(x * 0.6 + 0.4) +
    0.22 * Math.cos(z * 0.9 - 0.3) +
    0.14 * Math.sin((x - z) * 0.5) -
    0.04 * x
  );
}

const GROUND = -0.9;

// A tapered steel tripod leg: two stacked cylinders (thick at the head, thin at
// the foot) plus a pointed cone foot planted in the soil.
function TripodLeg({ a, b, opacity }) {
  const { midUp, midLo, footPos, len, quat } = React.useMemo(() => {
    const va = new THREE.Vector3(...a);
    const vb = new THREE.Vector3(...b);
    const dir = new THREE.Vector3().subVectors(vb, va);
    const length = dir.length();
    const ndir = dir.clone().normalize();
    const q = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, 1, 0), ndir);
    return {
      midUp: va.clone().addScaledVector(ndir, length * 0.25),
      midLo: va.clone().addScaledVector(ndir, length * 0.75),
      footPos: vb.clone().addScaledVector(ndir, 0.03),
      len: length,
      quat: q,
    };
  }, [a, b]);
  const mat = (
    <meshStandardMaterial color={C.steel} metalness={0.55} roughness={0.5} transparent={opacity < 1} opacity={opacity} />
  );
  return (
    <group>
      <mesh position={midUp} quaternion={quat} castShadow>
        <cylinderGeometry args={[0.034, 0.028, len * 0.5, 10]} />
        {mat}
      </mesh>
      <mesh position={midLo} quaternion={quat} castShadow>
        <cylinderGeometry args={[0.028, 0.02, len * 0.5, 10]} />
        {mat}
      </mesh>
      <mesh position={footPos} quaternion={quat} castShadow>
        <coneGeometry args={[0.028, 0.1, 10]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.5} roughness={0.5} transparent={opacity < 1} opacity={opacity} />
      </mesh>
    </group>
  );
}

function TotalStation({ x, z, opacity, look }) {
  const baseY = GROUND + terrainH(x, z);
  // Tripod head where the three legs converge and the tribrach sits.
  const headY = baseY + 1.0;
  const head = [x, headY, z];
  const feet = [
    [x + 0.4, baseY, z + 0.32],
    [x - 0.46, baseY, z + 0.26],
    [x + 0.08, baseY, z - 0.5],
  ];
  const yaw = Math.atan2(look[0] - x, look[2] - z);
  const steel = (m = 0.7, r = 0.3) => (
    <meshStandardMaterial color={C.steelLt} metalness={m} roughness={r} transparent={opacity < 1} opacity={opacity} />
  );
  return (
    <group>
      {feet.map((f, i) => (
        <TripodLeg key={i} a={head} b={f} opacity={opacity} />
      ))}

      {/* Tribrach: circular base disc on the tripod head */}
      <mesh position={[x, headY + 0.04, z]} castShadow>
        <cylinderGeometry args={[0.12, 0.13, 0.07, 20]} />
        {steel(0.6, 0.4)}
      </mesh>

      {/* Alidade: everything that yaws about the vertical axis */}
      <group position={[x, headY + 0.09, z]} rotation={[0, yaw, 0]}>
        {/* lower body of the instrument */}
        <mesh position={[0, 0.07, 0]} castShadow>
          <cylinderGeometry args={[0.1, 0.11, 0.1, 18]} />
          {steel(0.65, 0.35)}
        </mesh>
        {/* keypad face on the front (toward the rod, +z local) */}
        <mesh position={[0, 0.07, 0.105]} castShadow>
          <boxGeometry args={[0.13, 0.09, 0.02]} />
          <meshStandardMaterial color={C.charcoal} metalness={0.3} roughness={0.6} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        {/* two yoke standards rising from the body */}
        <mesh position={[-0.085, 0.21, 0]} castShadow>
          <boxGeometry args={[0.035, 0.2, 0.05]} />
          {steel(0.7, 0.3)}
        </mesh>
        <mesh position={[0.085, 0.21, 0]} castShadow>
          <boxGeometry args={[0.035, 0.2, 0.05]} />
          {steel(0.7, 0.3)}
        </mesh>
        {/* horizontal telescope journaled BETWEEN the standards (sights +z) */}
        <mesh position={[0, 0.27, 0.06]} rotation={[Math.PI / 2, 0, 0]} castShadow>
          <cylinderGeometry args={[0.045, 0.045, 0.3, 16]} />
          {steel(0.7, 0.3)}
        </mesh>
        {/* objective lens at the front tip of the telescope */}
        <mesh position={[0, 0.27, 0.21]} rotation={[Math.PI / 2, 0, 0]} castShadow>
          <cylinderGeometry args={[0.048, 0.048, 0.03, 16]} />
          <meshStandardMaterial color={C.charcoal} metalness={0.4} roughness={0.4} transparent={opacity < 1} opacity={opacity} />
        </mesh>
        {/* eyepiece ember accent at the back */}
        <Node p={[0, 0.27, -0.16]} r={0.03} color={C.ember} emissive={C.ember} opacity={opacity} />
      </group>
    </group>
  );
}

// A standard graduated leveling rod: tall, thin, alternating ember/cream bands
// with thin charcoal graduation ticks, colored top band so the tip reads.
function StadiaRod({ x, z, opacity }) {
  const baseY = GROUND + terrainH(x, z);
  const segs = 13;
  const h = 0.16;
  const w = 0.07;
  return (
    <group position={[x, baseY, z]}>
      {Array.from({ length: segs }).map((_, i) => {
        // topmost band (i === segs-1) colored so the tip reads
        const colored = i % 2 === 1 || i === segs - 1;
        return (
          <group key={i} position={[0, h / 2 + i * h, 0]}>
            <Box
              position={[0, 0, 0]}
              size={[w, h, 0.045]}
              color={colored ? C.ember : C.cream}
              opacity={opacity}
              metalness={0.1}
              roughness={0.6}
            />
            {/* graduation tick at the top of each band, facing -x (the station) */}
            <Box
              position={[-w / 2 - 0.001, h / 2 - 0.012, 0]}
              size={[0.012, 0.012, 0.046]}
              color={C.charcoal}
              opacity={opacity}
              metalness={0.1}
              roughness={0.7}
            />
          </group>
        );
      })}
    </group>
  );
}

export function SurveyScene({ opacity }) {
  const station = { x: -2.6, z: 0.5 };
  const rod = { x: 3.0, z: -0.4 };
  const rodBaseY = GROUND + terrainH(rod.x, rod.z);
  const stationBaseY = GROUND + terrainH(station.x, station.z);

  // Telescope objective lives in the station's yawed alidade group; recompute
  // its world position so the sight line truly emanates from the optical axis.
  const stHeadY = stationBaseY + 1.0;
  const yaw = Math.atan2(rod.x - station.x, rod.z - station.z);
  const objLocal = new THREE.Vector3(0, 0.27, 0.21); // matches telescope objective
  const objWorld = objLocal
    .clone()
    .applyEuler(new THREE.Euler(0, yaw, 0))
    .add(new THREE.Vector3(station.x, stHeadY + 0.09, station.z));

  // Land the sight line on the rod FACE (-x side, toward the station) at a
  // readable graduation height.
  const rodFace = [rod.x - 0.04, rodBaseY + 1.05, rod.z];

  return (
    <group position={[0, 0.15, 0]}>
      <Terrain opacity={opacity} />

      <TotalStation
        x={station.x}
        z={station.z}
        opacity={opacity}
        look={[rod.x, rodBaseY + 1.05, rod.z]}
      />

      <StadiaRod x={rod.x} z={rod.z} opacity={opacity} />

      {/* optical line of sight: from the telescope objective to the rod face */}
      <Member
        a={[objWorld.x, objWorld.y, objWorld.z]}
        b={rodFace}
        radius={0.01}
        color={C.ember}
        emissive={C.ember}
        opacity={opacity * 0.9}
      />

      {/* instrument operator leaning into the eyepiece */}
      <Person
        position={[station.x - 0.55, stationBaseY, station.z]}
        rotation={[0, Math.PI / 2 + 0.25, 0]}
        scale={0.62}
        vest={C.ember}
        ponytail
        hardHat={C.sunbeam}
        lean={0.5}
        armPose="sight"
        opacity={opacity}
      />

      {/* rodperson plumbing the leveling rod: overlapping the rod, hand on the
          shaft, facing the instrument (-x). Steel coveralls + sunbeam hardhat
          keep the figure off the terrain green. */}
      <Person
        position={[rod.x - 0.16, rodBaseY, rod.z + 0.04]}
        rotation={[0, -Math.PI / 2 - 0.12, 0]}
        scale={0.62}
        vest={C.steelLt}
        hardHat={C.sunbeam}
        armPose="hold"
        opacity={opacity}
      />
    </group>
  );
}

// Graded ground with mass: a displaced top surface plus an extruded soil skirt
// in a muted earth-gray, so the silhouette reads as a landform section rather
// than a floating sheet.
function Terrain({ opacity }) {
  const topRef = React.useRef();
  const W = 9.0, D = 4.6, SX = 90, SY = 48;
  React.useEffect(() => {
    const g = topRef.current;
    if (!g) return;
    const pos = g.attributes.position;
    for (let i = 0; i < pos.count; i++) {
      const x = pos.getX(i);
      const y = pos.getY(i);
      // Flatten displacement near the front/back edges so the slab silhouette
      // stays clean and reads as a graded section.
      const edge = 1 - Math.min(1, Math.abs(y) / (D / 2));
      const damp = 0.35 + 0.65 * edge;
      pos.setZ(i, terrainH(x, -y) * damp);
    }
    pos.needsUpdate = true;
    g.computeVertexNormals();
  }, []);

  // Soil skirt: a slab hung beneath the surface giving the landform thickness.
  const skirtY = -0.9 - 0.32;
  return (
    <group>
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.9, 0]} receiveShadow castShadow>
        <planeGeometry ref={topRef} args={[W, D, SX, SY]} />
        <meshStandardMaterial color="#5f7d5a" metalness={0.1} roughness={0.95} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
      {/* earth-gray soil mass under the surface */}
      <mesh position={[0, skirtY, 0]} receiveShadow castShadow>
        <boxGeometry args={[W * 0.985, 0.62, D * 0.96]} />
        <meshStandardMaterial color="#6b5f52" metalness={0.05} roughness={1} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
      {/* thinner darker base course for a layered cut look */}
      <mesh position={[0, skirtY - 0.34, 0]} receiveShadow castShadow>
        <boxGeometry args={[W * 0.95, 0.18, D * 0.92]} />
        <meshStandardMaterial color="#574d42" metalness={0.05} roughness={1} transparent={opacity < 1} opacity={opacity} flatShading />
      </mesh>
    </group>
  );
}
