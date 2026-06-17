import React from 'react';
import * as THREE from 'three';
import { C, Box, Member, Arrow } from './primitives';

// FE topic: Geotechnical — solid stacked soil strata with a spread footing and
// column carried into the soil on driven piles, a groundwater table, a
// settlement load arrow, and a banded borehole core sample beside the block.
// The front-left corner is cut away (stepped notch) so the driven pile group is
// exposed and "footing on piles" reads at a glance. `opacity` cross-fades.

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
          the faces so it survives downsampling. */}
      <Box
        position={[0, wtY, 0]}
        size={[W + 0.06, 0.05, D + 0.06]}
        color={C.water}
        opacity={opacity * 0.72}
        metalness={0.25}
        roughness={0.15}
      />
      {/* Classic downward water-table triangle marker on the front-right face. */}
      <WaterMarker position={[W / 2 - 1.0, wtY + 0.22, D / 2 + 0.015]} opacity={opacity} />

      {/* Driven pile group, exposed in the cutaway — ember so it pops against
          the brown soil. Caps tie the group into the footing. */}
      {pileXs.map((px) =>
        pileZs.map((pz, j) => (
          <React.Fragment key={`pile${px}-${j}`}>
            <Member a={[px, pileTop, pz]} b={[px, pileBottom, pz]} radius={0.1} color={C.ember} opacity={opacity} />
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

      {/* Settlement / service load arrow. */}
      <Arrow from={[0, topSurface + 2.25, 0]} to={[0, topSurface + 1.42, 0]} opacity={opacity} />

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
