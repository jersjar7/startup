import React from 'react';
import * as THREE from 'three';
import { useFrame } from '@react-three/fiber';
import { C, Box, Member, Person } from './primitives';

// FE topic: Geotechnical — solid stacked soil strata with a spread footing and
// column carried into the soil on driven piles, a groundwater table, and a
// banded borehole core sample beside the block. The front-left corner is cut
// away (stepped notch) so the driven pile group is exposed and "footing on
// piles" reads at a glance. A living site: the footing slowly settles under
// load, the water table shimmers, surface trees sway, a surveyor walks the
// site, and a pile-driver hammer rises and drops on a loop. `opacity`
// cross-fades.

// Distinct soil units (topsoil → sand → clay → stiff clay → dense sand/rock),
// widened in value/hue across the muted-earth range and given per-layer
// thickness so they read as geology, not machined banding. Listed top → bottom.
const STRATA = [
  { color: '#9b9183', H: 0.34 }, // topsoil — light tan, thin
  { color: '#857a64', H: 0.5 },  // sand — warm gray-brown
  { color: '#6a5f4c', H: 0.66 }, // clay — darker, thicker
  { color: '#574d3d', H: 0.56 }, // stiff clay — deep brown
  { color: '#4b4640', H: 0.5 },  // dense sand / weathered rock — gritty gray-brown
];

export function GeoScene({ opacity }) {
  const settleRef = React.useRef();   // footing + column + pile group
  const waterRef = React.useRef();    // groundwater slab
  const waterMatRef = React.useRef();
  const treeRefs = React.useRef([]);  // canopy sway groups
  const personRef = React.useRef();   // walking surveyor
  const hammerRef = React.useRef();   // pile-driver hammer block

  const layers = React.useMemo(() => {
    const W = 7.4, D = 2.8;
    const arr = [];
    // Build bottom → top so the stack sits with its base near y = -1.6.
    let y = -1.6;
    for (let i = STRATA.length - 1; i >= 0; i--) {
      const s = STRATA[i];
      arr.unshift({ y: y + s.H / 2, color: s.color, H: s.H });
      y += s.H;
    }
    return { arr, topY: y, W, D };
  }, []);

  const { W, D } = layers;
  const topSurface = layers.topY;
  const transparent = opacity < 1;

  // Front-left cutaway: the corner block is recessed so the embedded piles show.
  // Notch occupies the front-left of the upper strata (where the pile group is).
  const notchW = 2.7;          // x extent of the cut (from left edge inward)
  const notchD = 1.35;         // z depth of the cut (from front face inward)
  const notchXc = -W / 2 + notchW / 2;   // center x of removed corner
  const notchZc = D / 2 - notchD / 2;    // center z (toward +Z front face)

  // Pile group sits inside the cutaway so it is fully visible.
  const pileXs = [-1.55, -0.7];
  const pileZs = [D / 2 - 0.45, D / 2 - 1.05];
  const pileTop = topSurface - STRATA[0].H + 0.02; // just under the footing seat
  const pileBottom = layers.arr[3].y;              // driven into the stiff layer
  const footingTopY = topSurface + 0.16;
  const footingW = 2.0, footingD = 1.8;

  // Groundwater table elevation — sits within the clay band (3rd layer down).
  const wtY = layers.arr[2].y + layers.arr[2].H / 2;

  // Each soil layer is split into the full back slab plus a narrower front
  // strip, with the front-left corner of the upper layers omitted to form the
  // stepped cutaway that exposes the piles.
  const layerMeshes = [];
  layers.arr.forEach((l, i) => {
    const cut = i < 3; // top three layers get the notch carved out
    const mat = (
      <meshStandardMaterial
        color={l.color}
        metalness={0.1}
        roughness={0.92}
        transparent={transparent}
        opacity={opacity}
        flatShading
      />
    );
    if (!cut) {
      layerMeshes.push(
        <mesh key={`g${i}`} position={[0, l.y, 0]} castShadow receiveShadow>
          <boxGeometry args={[W, l.H, D]} />
          {mat}
        </mesh>,
      );
      return;
    }
    // Back slab: full width, depth = D - notchD, pushed to the back (−Z).
    const backD = D - notchD;
    layerMeshes.push(
      <mesh key={`g${i}-back`} position={[0, l.y, -D / 2 + backD / 2]} castShadow receiveShadow>
        <boxGeometry args={[W, l.H, backD]} />
        <meshStandardMaterial color={l.color} metalness={0.1} roughness={0.92} transparent={transparent} opacity={opacity} flatShading />
      </mesh>,
    );
    // Front-right strip: fills the front band to the right of the notch.
    const frontRightW = W - notchW;
    layerMeshes.push(
      <mesh key={`g${i}-front`} position={[-W / 2 + notchW + frontRightW / 2, l.y, D / 2 - notchD / 2]} castShadow receiveShadow>
        <boxGeometry args={[frontRightW, l.H, notchD]} />
        <meshStandardMaterial color={l.color} metalness={0.1} roughness={0.92} transparent={transparent} opacity={opacity} flatShading />
      </mesh>,
    );
  });

  // Surface vegetation: a few low-poly trees/shrubs on top of the soil, placed
  // on the uncut front-right band and along the back so they never float over
  // the cutaway. Phase-varied sway.
  const trees = React.useMemo(() => ([
    { x: 1.9,  z: D / 2 - 0.5,  s: 0.62, kind: 'tree',  phase: 0.0 },
    { x: 3.2,  z: -0.55,        s: 0.5,  kind: 'tree',  phase: 1.7 },
    { x: -2.9, z: -0.7,         s: 0.44, kind: 'shrub', phase: 3.1 },
  ]), [D]);

  // Surveyor walk path along the back surface (clear of the footing/cutaway).
  const walk = { x0: -2.7, x1: 2.7, z: -D / 2 + 0.45 };

  useFrame((state) => {
    const t = state.clock.elapsedTime;

    // Slow settlement bob of the footing/column/pile group — conveys the
    // service load formerly shown by the arrow. A few mm, ~8s period.
    if (settleRef.current) {
      settleRef.current.position.y = -0.018 - 0.014 * (0.5 - 0.5 * Math.cos(t * (Math.PI * 2) / 8));
    }

    // Groundwater shimmer: a tiny vertical bob plus a gentle roughness ripple
    // so it reads wet while staying a clean horizontal datum.
    if (waterRef.current) {
      waterRef.current.position.y = wtY + 0.012 * Math.sin(t * 1.1);
    }
    if (waterMatRef.current) {
      waterMatRef.current.roughness = 0.15 + 0.07 * (0.5 + 0.5 * Math.sin(t * 0.9 + 1.2));
    }

    // Trees sway in the wind, phase-varied.
    for (let i = 0; i < treeRefs.current.length; i++) {
      const g = treeRefs.current[i];
      if (!g) continue;
      const ph = trees[i] ? trees[i].phase : i;
      g.rotation.z = 0.06 * Math.sin(t * 1.3 + ph) + 0.02 * Math.sin(t * 2.7 + ph);
    }

    // Surveyor walks back and forth; turns at each end (ping-pong via triangle
    // wave) and faces the direction of travel.
    if (personRef.current) {
      const period = 11;
      const u = (t % period) / period;            // 0..1
      const tri = u < 0.5 ? u * 2 : 2 - u * 2;     // 0..1..0
      personRef.current.position.x = walk.x0 + (walk.x1 - walk.x0) * tri;
      personRef.current.position.z = walk.z;
      personRef.current.rotation.y = u < 0.5 ? Math.PI / 2 : -Math.PI / 2;
      // subtle bob to suggest a stride
      personRef.current.position.y = topSurface + 0.16 + 0.02 * Math.abs(Math.sin(t * 6));
    }

    // Pile-driver hammer: slow lift, sharp drop on a loop (eased sawtooth).
    if (hammerRef.current) {
      const cyc = (t % 2.6) / 2.6;                 // 0..1
      // rise across 0..0.8 (eased), drop fast across 0.8..1
      const rise = cyc < 0.8 ? Math.pow(cyc / 0.8, 0.6) : 1 - (cyc - 0.8) / 0.2;
      hammerRef.current.position.y = topSurface + 0.5 + 0.62 * rise;
    }
  });

  // Geometry for the pile-driver leader, placed above the front-most pile head.
  const driverX = pileXs[1];
  const driverZ = pileZs[0];

  return (
    <group position={[0, 0.05, 0]}>
      {layerMeshes}

      {/* Exposed inner faces of the cutaway, tinted slightly darker so the cut
          reads as a freshly excavated trench wall rather than open air. */}
      <mesh position={[notchXc, layers.arr[1].y, D / 2 - notchD]} receiveShadow>
        <boxGeometry args={[notchW, STRATA[0].H + STRATA[1].H + STRATA[2].H, 0.02]} />
        <meshStandardMaterial color="#3f3a32" metalness={0.05} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>
      <mesh position={[notchXc + notchW / 2, layers.arr[1].y, notchZc]} receiveShadow>
        <boxGeometry args={[0.02, STRATA[0].H + STRATA[1].H + STRATA[2].H, notchD]} />
        <meshStandardMaterial color="#3f3a32" metalness={0.05} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>
      {/* Floor of the cutaway (top of the 4th, uncut layer). */}
      <mesh position={[notchXc, layers.arr[2].y - STRATA[2].H / 2 + 0.005, notchZc]} receiveShadow rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[notchW, notchD]} />
        <meshStandardMaterial color="#4a443b" metalness={0.05} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>

      {/* Groundwater table — a wet band in C.water, thick and protruding from
          the faces so it survives downsampling. Gently shimmers via ref. */}
      <mesh ref={waterRef} position={[0, wtY, 0]} castShadow receiveShadow>
        <boxGeometry args={[W + 0.06, 0.05, D + 0.06]} />
        <meshStandardMaterial
          ref={waterMatRef}
          color={C.water}
          metalness={0.25}
          roughness={0.15}
          transparent
          opacity={opacity * 0.72}
        />
      </mesh>
      {/* Classic downward water-table triangle marker on the front-right face. */}
      <WaterMarker position={[W / 2 - 1.0, wtY + 0.22, D / 2 + 0.015]} opacity={opacity} />

      {/* The footing + column + driven pile group settle together under load —
          a slow vertical bob driven in useFrame replaces the old load arrow. */}
      <group ref={settleRef}>
        {/* Driven pile group, exposed in the cutaway. A slightly desaturated
            ember so the piles pop but read as structural members, not candy. */}
        {pileXs.map((px) =>
          pileZs.map((pz, j) => (
            <React.Fragment key={`pile${px}-${j}`}>
              <Member a={[px, pileTop, pz]} b={[px, pileBottom, pz]} radius={0.1} color="#c25530" opacity={opacity} />
              <Box position={[px, pileTop + 0.02, pz]} size={[0.26, 0.06, 0.26]} color={C.steelLt} opacity={opacity} metalness={0.6} roughness={0.5} />
            </React.Fragment>
          )),
        )}

        {/* Spread footing (concrete) — seated over the pile group. */}
        <Box position={[0, footingTopY, 0]} size={[footingW, 0.32, footingD]} color={C.steelLt} opacity={opacity} metalness={0.25} roughness={0.7} />
        {/* Steel baseplate at the footing-column joint reads as a connection. */}
        <Box position={[0, footingTopY + 0.17, 0]} size={[0.74, 0.04, 0.74]} color={C.steel} opacity={opacity} metalness={0.55} roughness={0.45} />
        {/* Column / pier — lighter steel at lower metalness so it is not a black
            monolith against the light footing. */}
        <Box position={[0, footingTopY + 0.19 + 0.45, 0]} size={[0.55, 0.9, 0.55]} color={C.steelLt} opacity={opacity} metalness={0.4} roughness={0.5} />
      </group>

      {/* Pile-driver: a thin leader mast over the front pile head with a hammer
          block that rises slowly and drops on a loop — the topical 'driving
          load' source that replaces the diagrammatic arrow. */}
      <PileDriver
        x={driverX}
        z={driverZ}
        baseY={topSurface}
        hammerRef={hammerRef}
        opacity={opacity}
      />

      {/* Surface vegetation — low-poly trees/shrubs that sway in the wind. */}
      {trees.map((tr, i) => (
        <Tree
          key={`tree${i}`}
          groupRef={(el) => { treeRefs.current[i] = el; }}
          x={tr.x}
          z={tr.z}
          baseY={topSurface}
          scale={tr.s}
          shrub={tr.kind === 'shrub'}
          opacity={opacity}
        />
      ))}

      {/* Surveyor walking the site (reuses the shared Person helper). */}
      <group ref={personRef} position={[walk.x0, topSurface + 0.16, walk.z]} rotation={[0, Math.PI / 2, 0]}>
        <Person scale={0.62} vest={C.sunbeam} hardHat={C.ember} ponytail opacity={opacity} />
      </group>

      {/* Borehole core sample: a banded core quoting the block's strata, wrapped
          in a steel half-shell sampler and seated on the cream with a contact
          shadow so it reads as a sample, not a floating stick. */}
      <group position={[W / 2 + 0.55, 0, D / 2 - 0.5]}>
        {(() => {
          const coreH = layers.arr.reduce((s, l) => s + l.H, 0);
          const baseY = -1.6;
          let cy = baseY;
          const segs = [];
          // bottom → top so the core's band order matches the block.
          for (let i = layers.arr.length - 1; i >= 0; i--) {
            const l = layers.arr[i];
            segs.push(
              <mesh key={`core${i}`} position={[0, cy + l.H / 2, 0]} castShadow>
                <cylinderGeometry args={[0.13, 0.13, l.H, 20]} />
                <meshStandardMaterial color={l.color} metalness={0.12} roughness={0.88} transparent={transparent} opacity={opacity} flatShading />
              </mesh>,
            );
            cy += l.H;
          }
          return (
            <>
              {segs}
              {/* Steel sampler half-tube around the back of the core. */}
              <mesh position={[0, baseY + coreH / 2, 0]} castShadow>
                <cylinderGeometry args={[0.165, 0.165, coreH, 24, 1, true, Math.PI * 0.35, Math.PI * 1.3]} />
                <meshStandardMaterial color={C.steelLt} metalness={0.85} roughness={0.3} side={2} transparent={transparent} opacity={opacity} />
              </mesh>
              {/* Tube shoe / cutting edge at the base. */}
              <mesh position={[0, baseY + 0.05, 0]} castShadow>
                <cylinderGeometry args={[0.17, 0.17, 0.1, 24]} />
                <meshStandardMaterial color={C.steel} metalness={0.85} roughness={0.32} transparent={transparent} opacity={opacity} />
              </mesh>
              {/* Ground base disc seats the core and grounds its contact shadow. */}
              <mesh position={[0, baseY - 0.005, 0]} receiveShadow>
                <cylinderGeometry args={[0.28, 0.3, 0.06, 28]} />
                <meshStandardMaterial color={C.steel} metalness={0.4} roughness={0.6} transparent={transparent} opacity={opacity} />
              </mesh>
            </>
          );
        })()}
      </group>

      {/* Stronger contact shadow under the soil mass so the heavy block sits on
          the cream rather than floating. */}
      <mesh position={[-0.1, -1.605, 0.15]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
        <planeGeometry args={[W + 1.0, D + 1.0]} />
        <meshStandardMaterial color={C.charcoal} transparent opacity={opacity * 0.18} roughness={1} metalness={0} />
      </mesh>
    </group>
  );
}

// Downward-pointing groundwater-table triangle marker (filled triangle on a
// thin slab) — the classic geotech waterline symbol. Honors `opacity`.
function WaterMarker({ position, opacity }) {
  const geom = React.useMemo(() => {
    const shape = new THREE.Shape();
    const w = 0.22, h = 0.26;
    shape.moveTo(-w, h);
    shape.lineTo(w, h);
    shape.lineTo(0, 0);
    shape.closePath();
    return new THREE.ExtrudeGeometry(shape, { depth: 0.03, bevelEnabled: false });
  }, []);
  return (
    <mesh position={position} geometry={geom} castShadow>
      <meshStandardMaterial color={C.water} metalness={0.2} roughness={0.4} transparent opacity={Math.min(1, opacity)} />
    </mesh>
  );
}

// Low-poly tree (or shrub): a tapered trunk plus stacked cone/sphere canopy in
// muted earth greens. The canopy group is pivoted at the trunk base so an
// outer ref can sway it in the wind. Honors `opacity`.
function Tree({ groupRef, x, z, baseY, scale = 0.6, shrub = false, opacity = 1 }) {
  const trunk = '#5a4a35';
  const leafDk = '#3a5a42';
  const leafLt = '#557a55';
  const trans = opacity < 1;
  return (
    <group position={[x, baseY, z]} scale={scale}>
      {/* Trunk stays put; only the canopy group sways (pivot at its base). */}
      {!shrub && (
        <mesh position={[0, 0.42, 0]} castShadow>
          <cylinderGeometry args={[0.05, 0.085, 0.84, 8]} />
          <meshStandardMaterial color={trunk} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
        </mesh>
      )}
      <group ref={groupRef} position={[0, shrub ? 0.05 : 0.78, 0]}>
        {shrub ? (
          <>
            <mesh position={[0, 0.28, 0]} castShadow>
              <sphereGeometry args={[0.36, 12, 10]} />
              <meshStandardMaterial color={leafDk} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
            </mesh>
            <mesh position={[0.22, 0.18, 0.12]} castShadow>
              <sphereGeometry args={[0.24, 12, 10]} />
              <meshStandardMaterial color={leafLt} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
            </mesh>
          </>
        ) : (
          <>
            <mesh position={[0, 0.18, 0]} castShadow>
              <coneGeometry args={[0.46, 0.7, 9]} />
              <meshStandardMaterial color={leafDk} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
            </mesh>
            <mesh position={[0, 0.52, 0]} castShadow>
              <coneGeometry args={[0.36, 0.6, 9]} />
              <meshStandardMaterial color={leafLt} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
            </mesh>
            <mesh position={[0, 0.82, 0]} castShadow>
              <coneGeometry args={[0.24, 0.5, 9]} />
              <meshStandardMaterial color={leafDk} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
            </mesh>
          </>
        )}
      </group>
    </group>
  );
}

// Pile-driver leader: a thin vertical mast with a steel hammer block whose Y is
// animated by an external ref (rises slowly, drops fast). Honors `opacity`.
function PileDriver({ x, z, baseY, hammerRef, opacity = 1 }) {
  const trans = opacity < 1;
  const leaderH = 1.1;
  return (
    <group position={[x, 0, z]}>
      {/* Leader mast. */}
      <mesh position={[0.16, baseY + 0.16 + leaderH / 2, 0]} castShadow>
        <boxGeometry args={[0.05, leaderH, 0.05]} />
        <meshStandardMaterial color={C.steel} metalness={0.7} roughness={0.4} transparent={trans} opacity={opacity} />
      </mesh>
      {/* Short base sill grounding the leader on the soil. */}
      <mesh position={[0.16, baseY + 0.08, 0]} castShadow>
        <boxGeometry args={[0.22, 0.16, 0.22]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.55} roughness={0.5} transparent={trans} opacity={opacity} />
      </mesh>
      {/* Hammer block — animated via ref (initial Y reset each frame). */}
      <mesh ref={hammerRef} position={[0, baseY + 0.6, 0]} castShadow>
        <boxGeometry args={[0.26, 0.3, 0.26]} />
        <meshStandardMaterial color={C.steel} metalness={0.8} roughness={0.35} transparent={trans} opacity={opacity} />
      </mesh>
    </group>
  );
}
