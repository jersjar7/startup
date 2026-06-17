import React from 'react';
import * as THREE from 'three';
import { useFrame } from '@react-three/fiber';
import { C, Box, Member, Person, smoothstep } from './primitives';

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
// `wetColor` is the saturated tint used below the water table so the phreatic
// zone reads as darker, wetter soil instead of a floating slab.
const STRATA = [
  { color: '#9b9183', wet: '#6f675b', H: 0.34 }, // topsoil — light tan, thin
  { color: '#857a64', wet: '#5d5544', H: 0.5 },  // sand — warm gray-brown
  { color: '#6a5f4c', wet: '#4a4234', H: 0.66 }, // clay — darker, thicker
  { color: '#574d3d', wet: '#3e372b', H: 0.56 }, // stiff clay — deep brown
  { color: '#4b4640', wet: '#363230', H: 0.5 },  // dense sand / weathered rock
];

// Brand concrete + steel tones for the structural members (kept off the
// muted-earth soil palette so footing/piles read as built, not geology).
const CONCRETE = '#cfc7ba';   // warm cast-in-place concrete (footing/piers/piles)
const CONCRETE_DK = '#b9b0a1'; // shaded pile / pedestal step
const C_WET = '#2f6f7a';      // groundwater (= C.water)

export function GeoScene({ opacity }) {
  const settleRef = React.useRef();   // footing + column + pile group
  const wetBandRefs = React.useRef([]); // wet-face shimmer materials
  const treeRefs = React.useRef([]);  // canopy sway groups
  const personRef = React.useRef();   // walking surveyor
  const personYawRef = React.useRef(Math.PI / 2);
  const hammerRef = React.useRef();   // pile-driver hammer block
  const driverPileRef = React.useRef(); // fresh pile under the hammer
  const dustRef = React.useRef([]);   // recycled spoil-puff meshes
  const birdRef = React.useRef();     // background bird

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

  // Pile group sits inside the cutaway so it is fully visible: a 2x2 grid of
  // slender driven piles carried down into the stiff layer.
  const pileXs = [-1.75, -0.95];
  const pileZs = [D / 2 - 0.42, D / 2 - 1.02];
  const pileTop = topSurface - STRATA[0].H + 0.02; // just under the footing seat
  const pileBottom = layers.arr[3].y;              // driven into the stiff layer
  const footingTopY = topSurface + 0.16;
  const footingW = 2.0, footingD = 1.8;

  // Groundwater table elevation — sits within the clay band (3rd layer down).
  const wtY = layers.arr[2].y + layers.arr[2].H / 2;

  // Per-layer color: layers fully below the water table read as the wet tint;
  // a layer straddling the table is split into a dry upper and wet lower half.
  const colorAt = (l) => (l.y + l.H / 2 <= wtY + 1e-4 ? l.wet : l.color);

  // Each soil layer is split into the full back slab plus a narrower front
  // strip, with the front-left corner of the upper layers omitted to form the
  // stepped cutaway that exposes the piles. Layers crossing the water table are
  // additionally split horizontally into a dry crown and a saturated base so the
  // phreatic zone reads inside the soil rather than as a floating slab.
  const soilMat = (color) => (
    <meshStandardMaterial color={color} metalness={0.1} roughness={0.92} transparent={transparent} opacity={opacity} flatShading />
  );
  const layerMeshes = [];
  // Helper: emit a box that is auto-split at wtY into dry/wet sub-boxes.
  const emitSplit = (key, cx, w, l, cz, d) => {
    const top = l.y + l.H / 2, bot = l.y - l.H / 2;
    if (wtY <= bot + 1e-4 || wtY >= top - 1e-4) {
      // wholly dry or wholly wet
      const col = wtY >= top - 1e-4 ? l.wet : l.color;
      layerMeshes.push(
        <mesh key={key} position={[cx, l.y, cz]} castShadow receiveShadow>
          <boxGeometry args={[w, l.H, d]} />
          {soilMat(col)}
        </mesh>,
      );
      return;
    }
    const dryH = top - wtY, wetH = wtY - bot;
    layerMeshes.push(
      <mesh key={`${key}-dry`} position={[cx, wtY + dryH / 2, cz]} castShadow receiveShadow>
        <boxGeometry args={[w, dryH, d]} />
        {soilMat(l.color)}
      </mesh>,
      <mesh key={`${key}-wet`} position={[cx, bot + wetH / 2, cz]} castShadow receiveShadow>
        <boxGeometry args={[w, wetH, d]} />
        {soilMat(l.wet)}
      </mesh>,
    );
  };
  const backD = D - notchD;
  const frontRightW = W - notchW;
  layers.arr.forEach((l, i) => {
    const cut = i < 3; // top three layers get the notch carved out
    if (!cut) {
      emitSplit(`g${i}`, 0, W, l, 0, D);
      return;
    }
    emitSplit(`g${i}-back`, 0, W, l, -D / 2 + backD / 2, backD);
    emitSplit(`g${i}-front`, -W / 2 + notchW + frontRightW / 2, frontRightW, l, D / 2 - notchD / 2, notchD);
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

  // The pile-driver stands on the excavated cutaway floor.
  const cutFloorY = layers.arr[2].y - STRATA[2].H / 2 + 0.005;

  // Hammer drop cycle. Ram rises slowly then drops fast; impact at cyc≈1.
  const HAMMER_PERIOD = 2.6;
  const hammerLo = cutFloorY + 0.5;     // ram resting just above the pile head
  const hammerHi = hammerLo + 0.62;     // top of lift

  useFrame((state) => {
    const t = state.clock.elapsedTime;

    // Pile-driver hammer: slow lift (eased), sharp drop on a loop.
    const cyc = (t % HAMMER_PERIOD) / HAMMER_PERIOD;     // 0..1
    const rise = cyc < 0.8 ? Math.pow(cyc / 0.8, 0.6) : 1 - (cyc - 0.8) / 0.2;
    if (hammerRef.current) {
      hammerRef.current.position.y = hammerLo + (hammerHi - hammerLo) * rise;
    }
    // Impact pulse: peaks right at the drop (cyc≈1), decays over ~0.4s.
    const sinceImpact = (1 - cyc) * HAMMER_PERIOD;       // s since last impact
    const impact = Math.exp(-sinceImpact * 7);           // 1 → 0 quickly

    // Fresh pile under the hammer dips a few mm on each blow, then eases back.
    if (driverPileRef.current) {
      driverPileRef.current.position.y = -0.05 * impact;
    }

    // Footing/column/pile group: slow consolidation creep + a synced micro-dip
    // on each hammer blow (couples the rig's work to settlement).
    if (settleRef.current) {
      const bob = -0.018 - 0.012 * (0.5 - 0.5 * Math.cos(t * (Math.PI * 2) / 8));
      settleRef.current.position.y = bob - 0.012 * impact;
    }

    // Groundwater: a faint specular/roughness shimmer band on the exposed wet
    // faces only — water reads without any floating sheet.
    for (let i = 0; i < wetBandRefs.current.length; i++) {
      const m = wetBandRefs.current[i];
      if (!m) continue;
      m.roughness = 0.28 + 0.12 * (0.5 + 0.5 * Math.sin(t * 0.9 + i * 1.7));
    }

    // Spoil dust: recycle a small pool of puffs near the hammer. They rise and
    // fade in the ~0.4s after each blow (no per-frame allocation).
    for (let i = 0; i < dustRef.current.length; i++) {
      const d = dustRef.current[i];
      if (!d) continue;
      const life = Math.min(1, sinceImpact * 2.2);       // 0 at blow → 1 after ~0.45s
      const fade = (1 - life) * (sinceImpact < 0.5 ? 1 : 0);
      d.position.y = 0.05 + life * (0.32 + i * 0.05);
      d.position.x = (i - 1.5) * 0.07;
      d.position.z = ((i % 2) - 0.5) * 0.12;
      const s = 0.04 + life * 0.16;
      d.scale.set(s, s, s);
      if (d.material) d.material.opacity = opacity * 0.4 * fade;
      d.visible = fade > 0.01;
    }

    // Trees sway in the wind, phase-varied (base sway + outer micro-flutter).
    for (let i = 0; i < treeRefs.current.length; i++) {
      const g = treeRefs.current[i];
      if (!g) continue;
      const ph = trees[i] ? trees[i].phase : i;
      g.rotation.z = 0.06 * Math.sin(t * 1.3 + ph) + 0.022 * Math.sin(t * 3.4 + ph);
    }

    // Surveyor walks back and forth; eases the 180° turn near each end instead
    // of snapping, and bobs with stride.
    if (personRef.current) {
      const period = 11;
      const u = (t % period) / period;            // 0..1
      const tri = u < 0.5 ? u * 2 : 2 - u * 2;     // 0..1..0
      personRef.current.position.x = walk.x0 + (walk.x1 - walk.x0) * tri;
      personRef.current.position.z = walk.z;
      // target heading: +x leg faces +PI/2, -x leg faces -PI/2; ease toward it
      const target = u < 0.5 ? Math.PI / 2 : -Math.PI / 2;
      let cur = personYawRef.current;
      let diff = target - cur;
      cur += diff * 0.12;                          // critically-damped-ish ease
      personYawRef.current = cur;
      personRef.current.rotation.y = cur;
      personRef.current.position.y = topSurface + 0.16 + 0.02 * Math.abs(Math.sin(t * 6));
    }

    // A single bird arcs across the back occasionally for life.
    if (birdRef.current) {
      const bp = (t % 17) / 17;                    // long loop
      const fly = smoothstep(0.15, 0.85, bp);
      birdRef.current.visible = bp > 0.12 && bp < 0.9;
      birdRef.current.position.x = -4.4 + fly * 8.8;
      birdRef.current.position.y = topSurface + 1.7 + 0.35 * Math.sin(bp * Math.PI);
      birdRef.current.position.z = -D / 2 - 0.8;
      birdRef.current.rotation.y = -Math.PI / 2;
      // wing flap
      birdRef.current.rotation.z = 0.4 * Math.sin(t * 12);
    }
  });

  // Pile-driver location: in the open cutaway floor, left of and clear from the
  // in-place load-bearing group, driving a fresh pile of its own.
  const driverX = -2.35;
  const driverZ = D / 2 - 0.55;

  return (
    <group position={[0, 0.05, 0]}>
      {layerMeshes}

      {/* Exposed inner faces of the cutaway — lifted in value so the embedded
          piles are not lost in shadow against the trench wall. */}
      <mesh position={[notchXc, layers.arr[1].y, D / 2 - notchD + 0.005]} receiveShadow>
        <boxGeometry args={[notchW, STRATA[0].H + STRATA[1].H + STRATA[2].H, 0.02]} />
        <meshStandardMaterial color="#564f44" metalness={0.05} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>
      <mesh position={[notchXc + notchW / 2 - 0.005, layers.arr[1].y, notchZc]} receiveShadow>
        <boxGeometry args={[0.02, STRATA[0].H + STRATA[1].H + STRATA[2].H, notchD]} />
        <meshStandardMaterial color="#4d473d" metalness={0.05} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>
      {/* Floor of the cutaway (top of the 4th, uncut layer). */}
      <mesh position={[notchXc, layers.arr[2].y - STRATA[2].H / 2 + 0.005, notchZc]} receiveShadow rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[notchW, notchD]} />
        <meshStandardMaterial color="#4a443b" metalness={0.05} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>

      {/* Groundwater: thin wet bands sitting flush ON the exposed faces (front
          face + the two cutaway trench walls) at the water-table elevation. No
          slab cuts through the block; the saturated soil tint below wtY carries
          the zone. Each band shimmers subtly via its material ref. */}
      {/* Front face band (right of the notch). */}
      <mesh position={[-W / 2 + notchW + frontRightW / 2, wtY, D / 2 + 0.012]}>
        <boxGeometry args={[frontRightW - 0.04, 0.07, 0.02]} />
        <meshStandardMaterial ref={(m) => { wetBandRefs.current[0] = m; }} color={C_WET} metalness={0.35} roughness={0.3} transparent opacity={opacity * 0.9} />
      </mesh>
      {/* Cutaway back wall (z-facing trench wall) band. */}
      <mesh position={[notchXc, wtY, D / 2 - notchD + 0.016]}>
        <boxGeometry args={[notchW - 0.04, 0.06, 0.02]} />
        <meshStandardMaterial ref={(m) => { wetBandRefs.current[1] = m; }} color={C_WET} metalness={0.35} roughness={0.3} transparent opacity={opacity * 0.85} />
      </mesh>
      {/* Cutaway side wall (x-facing trench wall) band. */}
      <mesh position={[notchXc + notchW / 2 - 0.016, wtY, notchZc]}>
        <boxGeometry args={[0.02, 0.06, notchD - 0.04]} />
        <meshStandardMaterial ref={(m) => { wetBandRefs.current[2] = m; }} color={C_WET} metalness={0.35} roughness={0.3} transparent opacity={opacity * 0.85} />
      </mesh>
      {/* Right end face band. */}
      <mesh position={[W / 2 + 0.012, wtY, 0]}>
        <boxGeometry args={[0.02, 0.07, D - 0.04]} />
        <meshStandardMaterial ref={(m) => { wetBandRefs.current[3] = m; }} color={C_WET} metalness={0.35} roughness={0.3} transparent opacity={opacity * 0.85} />
      </mesh>
      {/* Classic downward water-table triangle marker, datum-aligned to the band
          on the front-right exposed face. */}
      <WaterMarker position={[W / 2 - 1.0, wtY + 0.26, D / 2 + 0.02]} opacity={opacity} />

      {/* The footing + pile cap + driven pile group settle together under load —
          a slow consolidation creep plus a micro-dip on each hammer blow,
          driven in useFrame (replaces the old load arrow). */}
      <group ref={settleRef}>
        {/* Driven pile group: a visible 2x2 grid of slender CONCRETE piles, pale
            against the lifted trench wall so the 'footing on piles' load path
            is unmistakable. */}
        {pileXs.map((px) =>
          pileZs.map((pz, j) => (
            <Member key={`pile${px}-${j}`} a={[px, pileTop, pz]} b={[px, pileBottom, pz]} radius={0.135} color={(px === pileXs[1]) ? CONCRETE : CONCRETE_DK} opacity={opacity} />
          )),
        )}
        {/* Pile cap: a low concrete slab spanning all four pile heads, tying the
            footing → cap → piles load path together. */}
        <Box
          position={[(pileXs[0] + pileXs[1]) / 2, pileTop + 0.09, (pileZs[0] + pileZs[1]) / 2]}
          size={[Math.abs(pileXs[0] - pileXs[1]) + 0.5, 0.18, Math.abs(pileZs[0] - pileZs[1]) + 0.5]}
          color={CONCRETE} opacity={opacity} metalness={0.04} roughness={0.95}
        />

        {/* Spread footing (cast concrete) — warm off-white, high roughness, near
            zero metalness, with a stepped pedestal so it reads cast-in-place. */}
        <Box position={[0, footingTopY, 0]} size={[footingW, 0.3, footingD]} color={CONCRETE} opacity={opacity} metalness={0.03} roughness={0.95} />
        <Box position={[0, footingTopY + 0.2, 0]} size={[footingW - 0.5, 0.12, footingD - 0.5]} color={CONCRETE_DK} opacity={opacity} metalness={0.03} roughness={0.95} />
        {/* Steel baseplate at the column joint reads as a structural connection. */}
        <Box position={[0, footingTopY + 0.28, 0]} size={[0.66, 0.04, 0.66]} color={C.steel} opacity={opacity} metalness={0.6} roughness={0.4} />
        {/* Column / pier — slimmer than the footing, steel so it contrasts the
            concrete below it. */}
        <Box position={[0, footingTopY + 0.3 + 0.45, 0]} size={[0.46, 0.9, 0.46]} color={C.steelLt} opacity={opacity} metalness={0.45} roughness={0.45} />
      </group>

      {/* Pile-driver: a twin-rail leader with a ram riding between the rails,
          driving a fresh concrete pile directly beneath the hammer. The ram
          rises slowly and drops fast; each blow dips the pile head. */}
      <PileDriver
        x={driverX}
        z={driverZ}
        baseY={cutFloorY}
        pileBottom={pileBottom}
        hammerRef={hammerRef}
        pileRef={driverPileRef}
        opacity={opacity}
      />

      {/* Spoil-dust pool kicked up at the driving point on each blow (recycled,
          no per-frame allocation). */}
      <group position={[driverX, cutFloorY, driverZ]}>
        {[0, 1, 2, 3].map((i) => (
          <mesh key={`dust${i}`} ref={(m) => { dustRef.current[i] = m; }} visible={false}>
            <sphereGeometry args={[1, 7, 6]} />
            <meshStandardMaterial color="#8a8170" metalness={0} roughness={1} transparent opacity={0} />
          </mesh>
        ))}
      </group>

      {/* A single bird arcing across the back sky for life. */}
      <group ref={birdRef} visible={false}>
        <Bird opacity={opacity} />
      </group>

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

      {/* Surveyor walking the site, carrying a tripod/level over one shoulder
          so the figure reads as a surveyor rather than a pedestrian. */}
      <group ref={personRef} position={[walk.x0, topSurface + 0.16, walk.z]} rotation={[0, Math.PI / 2, 0]}>
        <Person scale={0.62} vest={C.sunbeam} hardHat={C.ember} ponytail armPose="hold" opacity={opacity} />
        <CarriedTripod opacity={opacity} />
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

// Pile-driver rig: a twin-rail leader frame with a heavy ram riding between the
// rails, driving a fresh concrete pile directly beneath it. The ram Y is
// animated by `hammerRef`; the fresh pile's group Y is dipped by `pileRef` on
// each blow. Honors `opacity`.
function PileDriver({ x, z, baseY, pileBottom, hammerRef, pileRef, opacity = 1 }) {
  const trans = opacity < 1;
  const leaderH = 1.5;
  const railDX = 0.16;             // half-gap between the two guide rails
  const topY = baseY + 0.12 + leaderH;
  const freshPileTopY = baseY + 0.12; // fresh pile head sits at grade
  return (
    <group position={[x, 0, z]}>
      {/* Fresh concrete pile being driven, directly under the ram. */}
      <group ref={pileRef}>
        <Member a={[0, freshPileTopY, 0]} b={[0, pileBottom + 0.2, 0]} radius={0.13} color={CONCRETE} opacity={opacity} />
        {/* Drive cap on the pile head. */}
        <mesh position={[0, freshPileTopY + 0.03, 0]} castShadow>
          <cylinderGeometry args={[0.16, 0.16, 0.06, 16]} />
          <meshStandardMaterial color={C.steel} metalness={0.7} roughness={0.4} transparent={trans} opacity={opacity} />
        </mesh>
      </group>

      {/* Twin guide rails. */}
      {[-railDX, railDX].map((dx) => (
        <mesh key={`rail${dx}`} position={[dx, baseY + 0.12 + leaderH / 2, 0]} castShadow>
          <boxGeometry args={[0.05, leaderH, 0.06]} />
          <meshStandardMaterial color={C.steel} metalness={0.75} roughness={0.38} transparent={trans} opacity={opacity} />
        </mesh>
      ))}
      {/* Crown brace tying the rail tops together. */}
      <mesh position={[0, topY, 0]} castShadow>
        <boxGeometry args={[railDX * 2 + 0.08, 0.08, 0.1]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.6} roughness={0.45} transparent={trans} opacity={opacity} />
      </mesh>
      {/* Base sill / lead foot grounding the rig on the soil. */}
      <mesh position={[0, baseY + 0.08, 0]} castShadow>
        <boxGeometry args={[railDX * 2 + 0.18, 0.16, 0.24]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.55} roughness={0.5} transparent={trans} opacity={opacity} />
      </mesh>
      {/* Heavy ram riding between the rails — animated via ref. */}
      <mesh ref={hammerRef} position={[0, baseY + 0.6, 0]} castShadow>
        <boxGeometry args={[railDX * 2 - 0.04, 0.36, 0.2]} />
        <meshStandardMaterial color="#3a3a3a" metalness={0.85} roughness={0.32} transparent={trans} opacity={opacity} />
      </mesh>
    </group>
  );
}

// A tiny low-poly bird (body + two swept wings) carried in a parent group that
// arcs it across the back sky. The wing flap comes from the parent's rotation.z.
function Bird({ opacity = 1 }) {
  const trans = opacity < 1;
  const mat = <meshStandardMaterial color={C.charcoal} metalness={0.1} roughness={0.8} transparent={trans} opacity={opacity} flatShading />;
  return (
    <group scale={0.5}>
      <mesh castShadow><sphereGeometry args={[0.09, 8, 6]} />{mat}</mesh>
      <mesh position={[0, 0.02, 0.22]} rotation={[0.4, 0.4, 0]} castShadow>
        <boxGeometry args={[0.02, 0.06, 0.34]} />{mat}
      </mesh>
      <mesh position={[0, 0.02, -0.22]} rotation={[-0.4, -0.4, 0]} castShadow>
        <boxGeometry args={[0.02, 0.06, 0.34]} />{mat}
      </mesh>
    </group>
  );
}

// A surveyor's tripod/level carried over the shoulder: three splayed legs and a
// small head, angled as if shouldered. Local to the carrying group. Honors
// `opacity`.
function CarriedTripod({ opacity = 1 }) {
  const trans = opacity < 1;
  const steel = (
    <meshStandardMaterial color={C.steelLt} metalness={0.5} roughness={0.5} transparent={trans} opacity={opacity} />
  );
  return (
    <group position={[0.02, 0.78, -0.16]} rotation={[0, 0, -0.5]} scale={0.62}>
      {/* Three legs splayed from a common head. */}
      {[-0.12, 0, 0.12].map((dz, i) => (
        <mesh key={i} position={[0, -0.32, dz]} rotation={[dz * 1.2, 0, 0.05]} castShadow>
          <cylinderGeometry args={[0.018, 0.018, 0.72, 6]} />{steel}
        </mesh>
      ))}
      {/* Instrument head. */}
      <mesh position={[0, 0.06, 0]} castShadow>
        <boxGeometry args={[0.12, 0.1, 0.12]} />
        <meshStandardMaterial color={C.steel} metalness={0.6} roughness={0.4} transparent={trans} opacity={opacity} />
      </mesh>
    </group>
  );
}
