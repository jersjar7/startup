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
  const drumRef = React.useRef();     // winch drum (rotates with hammer cycle)
  const cableRef = React.useRef();     // hoist cable (scales with ram lift)
  const dustRef = React.useRef([]);   // recycled spoil-puff meshes
  const clodRefs = React.useRef([]);  // tumbling spoil clods on the trench wall
  const birdRefs = React.useRef([]);  // background birds (staggered phase)
  const hawkRef = React.useRef();     // lone hawk soaring a slow high circle
  const laserRef = React.useRef();    // line-of-sight laser material (faint pulse)
  const leafRefs = React.useRef([]);  // windblown leaf/seed specks drifting over the surface
  const settleDustRefs = React.useRef([]); // tiny consolidation-dust wisps at the footing/soil contact

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
  // slender driven piles carried down into the stiff layer. Shifted toward the
  // open (right) side of the notch so it sits clearly apart from the pile-driver
  // rig parked at the left of the cut.
  const pileXs = [-1.55, -1.2];
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
    { x: 1.9,  z: D / 2 - 0.5,  s: 0.62, kind: 'tree',     phase: 0.0 },
    { x: 3.2,  z: -0.55,        s: 0.56, kind: 'broadleaf', phase: 1.7 },
    { x: -2.9, z: -0.7,         s: 0.44, kind: 'shrub',    phase: 3.1 },
  ]), [D]);

  // Windblown leaf/seed specks shed from the swaying trees, drifting downwind
  // across the soil surface on staggered loops so the tree-sway ties to the
  // ground. Each starts near a tree's canopy and rides the wind to +x, fading
  // out before it reaches the edge, then loops. Animated in useFrame; no
  // per-frame allocation. Confined to the uncut front-right band so they never
  // float over the cutaway.
  const leaves = React.useMemo(() => ([
    { x0: 1.9,  y0: topSurface + 0.55, z: D / 2 - 0.55, phase: 0.0,  dur: 7.0 },
    { x0: 3.1,  y0: topSurface + 0.5,  z: -0.4,         phase: 2.6,  dur: 8.2 },
    { x0: 2.4,  y0: topSurface + 0.45, z: 0.35,         phase: 4.9,  dur: 6.4 },
    { x0: 1.5,  y0: topSurface + 0.5,  z: -0.8,         phase: 1.3,  dur: 7.6 },
  // eslint-disable-next-line react-hooks/exhaustive-deps
  ]), [topSurface, D]);

  // Surveyor walk path along the back surface (clear of the footing/cutaway),
  // nudged forward off the back strata so the figure is not flattened against it.
  const walk = { x0: -2.5, x1: 2.5, z: -D / 2 + 0.72 };

  // A planted survey level: a tripod + instrument set up on the back-right
  // surface, sighting toward the footing column. The walking surveyor paces
  // near it. A thin forest line-of-sight laser locks the 'survey' read (a
  // line, not an arrow — explicitly allowed).
  const instX = 2.55, instZ = -D / 2 + 0.5;            // planted level position
  const instY = topSurface + 0.16 + 0.92;              // instrument optical center
  const sightTarget = [0, footingTopY + 0.75, 0];      // aim at the steel column
  const sightFrom = [instX, instY, instZ];
  // Line-of-sight: midpoint, length, and yaw/pitch so a thin cylinder spans it.
  const sight = React.useMemo(() => {
    const dx = sightTarget[0] - sightFrom[0];
    const dy = sightTarget[1] - sightFrom[1];
    const dz = sightTarget[2] - sightFrom[2];
    const len = Math.hypot(dx, dy, dz);
    const mid = [sightFrom[0] + dx / 2, sightFrom[1] + dy / 2, sightFrom[2] + dz / 2];
    // Orient a Y-axis cylinder along the sight direction via a unit-vector quat.
    const dir = new THREE.Vector3(dx, dy, dz).normalize();
    const quat = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir);
    return { len, mid, quat };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // The pile-driver stands on the excavated cutaway floor.
  const cutFloorY = layers.arr[2].y - STRATA[2].H / 2 + 0.005;

  // Hammer drop cycle. Ram rises slowly then drops fast; impact at cyc≈1.
  const HAMMER_PERIOD = 2.6;
  const hammerLo = cutFloorY + 0.46;    // ram resting just above the pile head
  const hammerHi = hammerLo + 0.9;      // top of lift; stays under the crown sheave (~cutFloorY+1.62)

  useFrame((state) => {
    const t = state.clock.elapsedTime;

    // Pile-driver hammer: slow eased lift over the first ~88% of the cycle, then
    // a fast accelerating gravity-like drop over the last ~12% so the slam is
    // crisp. rise: 1 at the top of lift → 0 at impact.
    const cyc = (t % HAMMER_PERIOD) / HAMMER_PERIOD;     // 0..1
    let rise;
    if (cyc < 0.88) {
      rise = Math.pow(cyc / 0.88, 0.55);                 // eased lift to the top
    } else {
      const f = (cyc - 0.88) / 0.12;                     // 0..1 over the drop
      rise = 1 - f * f;                                  // accelerating fall
    }
    if (hammerRef.current) {
      hammerRef.current.position.y = hammerLo + (hammerHi - hammerLo) * rise;
    }
    // Impact pulse: peaks right at the drop (cyc≈1), decays sharply (~0.35s).
    const sinceImpact = (1 - cyc) * HAMMER_PERIOD;       // s since last impact
    const impact = Math.exp(-sinceImpact * 8.5);         // 1 → 0 quickly, snappy

    // Fresh pile under the hammer drives down on each blow, then eases back.
    if (driverPileRef.current) {
      driverPileRef.current.position.y = -0.08 * impact;
    }

    // Winch drum spins to pay out cable on the slow lift, then reels in fast on
    // the drop (couples visibly to the hammer cycle). Cable length tracks the
    // ram so the hoist line takes up / pays out with the blow.
    if (drumRef.current) {
      drumRef.current.rotation.y = -cyc * Math.PI * 4;
    }
    if (cableRef.current) {
      // Cable spans from the crown sheave down to the ram top: scale a unit
      // cylinder so it always bridges the gap (no per-frame allocation).
      const ramTop = hammerLo + (hammerHi - hammerLo) * rise + 0.18;
      const span = Math.max(0.02, (cutFloorY + 0.12 + 1.5) - ramTop);
      cableRef.current.scale.y = span;
      cableRef.current.position.y = ramTop + span / 2;
    }

    // Footing/column/pile group: slow consolidation creep + a perceptible dip on
    // each hammer blow (couples the rig's work to settlement). The signature
    // geotech motion — kept tasteful, not bouncy: the footing eases down a hair
    // per blow with a tiny coupled tilt so the settlement is actually felt.
    if (settleRef.current) {
      const bob = -0.018 - 0.012 * (0.5 - 0.5 * Math.cos(t * (Math.PI * 2) / 8));
      settleRef.current.position.y = bob - 0.032 * impact;
      settleRef.current.rotation.z = -0.006 * impact;   // tiny lean toward the rig
    }

    // Groundwater: each exposed waterline band reads as WET SOIL, not a neon
    // stripe. 'Wet' comes through specular — a slow roughness shimmer wave — and
    // only the faintest water-teal glint, never a glowing blue band. The
    // saturated soil tint below wtY carries the zone; the WaterMarker triangle
    // labels the datum. A single very subtle glint sweeps the front band so the
    // eye catches a traveling highlight on the waterline.
    for (let i = 0; i < wetBandRefs.current.length; i++) {
      const m = wetBandRefs.current[i];
      if (!m) continue;
      const ph = i * 1.7;
      // horizontal shimmer wave: slow roughness modulation reads as wet through
      // specular response rather than emissive color.
      m.roughness = 0.22 + 0.14 * (0.5 + 0.5 * Math.sin(t * 0.8 + ph));
      let emi = 0.018 + 0.018 * (0.5 + 0.5 * Math.sin(t * 1.2 + ph));
      if (i === 0 || i === 1) {
        // traveling glint sweeps the front face (i=0) and, slightly delayed, the
        // cutaway trench wall (i=1) so the phreatic surface reads as continuous
        // around the cut corner rather than only on the front face. Kept faint.
        const sweep = ((t - (i === 1 ? 0.6 : 0)) % 5) / 5;
        const here = 0.5;
        const g = Math.exp(-Math.pow((sweep - here) * 6, 2));
        emi += 0.05 * g;
      }
      m.emissiveIntensity = Math.min(0.09, emi) * opacity;
    }

    // Spoil dust: recycle a small pool of puffs near the hammer. The first
    // three rise and fade in the ~0.45s after each blow; the LAST one is a faint
    // lingering wisp that drifts slowly downwind the whole cycle so the rig
    // never looks idle between blows. Wind clock shared with the trees.
    const windDrift = 0.04 * Math.sin(t * 1.3);
    for (let i = 0; i < dustRef.current.length; i++) {
      const d = dustRef.current[i];
      if (!d) continue;
      if (i === dustRef.current.length - 1) {
        // lingering wisp: always faintly visible, slowly rising + drifting
        const wph = (t % 6) / 6;                          // 0..1 slow loop
        d.position.y = 0.06 + wph * 0.5;
        d.position.x = -0.06 + windDrift * 2.0;
        d.position.z = 0.02;
        const s = 0.05 + 0.1 * Math.sin(wph * Math.PI);
        d.scale.set(s, s, s);
        if (d.material) d.material.opacity = opacity * 0.16 * Math.sin(wph * Math.PI);
        d.visible = true;
        continue;
      }
      const life = Math.min(1, sinceImpact * 2.2);       // 0 at blow → 1 after ~0.45s
      const fade = (1 - life) * (sinceImpact < 0.5 ? 1 : 0);
      d.position.y = 0.05 + life * (0.4 + i * 0.06);
      d.position.x = (i - 1.5) * 0.09 + windDrift;
      d.position.z = ((i % 2) - 0.5) * 0.14;
      // Spike the puff scale right at the blow so the impact lands even in a
      // still frame, then let it grow + thin as it rises. Peak scale raised so
      // the blow registers in a static screenshot.
      const burst = Math.exp(-sinceImpact * 9);          // sharp spike at impact
      const s = 0.07 + life * 0.26 + 0.2 * burst;
      d.scale.set(s, s, s);
      if (d.material) d.material.opacity = opacity * 0.52 * fade;
      d.visible = fade > 0.01;
    }

    // Tiny spoil clods tumble down the exposed trench wall on each hammer blow,
    // reinforcing the driving impact. Each clod falls + rolls then resets.
    for (let i = 0; i < clodRefs.current.length; i++) {
      const c = clodRefs.current[i];
      if (!c) continue;
      // fall progresses with time-since-impact, staggered per clod
      const f = Math.min(1, Math.max(0, sinceImpact * 1.6 - i * 0.18));
      c.position.y = -f * (0.5 + i * 0.08);
      c.position.x = i * 0.04 * f;
      c.rotation.z = f * (4 + i);
      c.visible = f > 0.001 && f < 0.999;
      if (c.material) c.material.opacity = opacity * 0.9 * (1 - f);
    }

    // Trees sway in the wind, phase-varied (base sway + outer micro-flutter).
    // The tree nearest the rig (the shrub at index 2) gets a brief outward
    // shudder on each hammer blow so the ground impact propagates into the
    // vegetation (couples rig -> site). The shudder is a fast decaying ring.
    for (let i = 0; i < treeRefs.current.length; i++) {
      const g = treeRefs.current[i];
      if (!g) continue;
      const ph = trees[i] ? trees[i].phase : i;
      let z = 0.06 * Math.sin(t * 1.3 + ph) + 0.022 * Math.sin(t * 3.4 + ph);
      if (i === 2) {
        // decaying high-frequency shudder triggered by the blow
        z += 0.05 * impact * Math.sin(sinceImpact * 38);
      }
      g.rotation.z = z;
    }

    // Surveyor walks back and forth; eases the 180° turn near each end instead
    // of snapping, and bobs with stride.
    if (personRef.current) {
      const period = 11;
      const u = (t % period) / period;            // 0..1
      let tri = u < 0.5 ? u * 2 : 2 - u * 2;       // 0..1..0
      // Pause near the planted instrument at the +x end of the stride.
      const paused = u > 0.46 && u < 0.58;
      if (paused) tri = 1;                          // hold near the level
      personRef.current.position.x = walk.x0 + (walk.x1 - walk.x0) * tri;
      personRef.current.position.z = walk.z;
      // target heading: +x leg faces +PI/2, -x leg faces -PI/2; ease toward it
      const target = u < 0.5 ? Math.PI / 2 : -Math.PI / 2;
      let cur = personYawRef.current;
      let diff = target - cur;
      cur += diff * 0.12;                          // critically-damped-ish ease
      personYawRef.current = cur;
      personRef.current.rotation.y = cur;
      // bob with stride (stronger so the walk reads at tile scale); during the
      // pause the surveyor briefly crouches to sight the planted level, then
      // rises — reads as doing survey work rather than pacing.
      const stride = paused ? 0 : 0.045 * Math.abs(Math.sin(t * 6));
      // crouch dip: a gentle down-then-up over the pause window.
      const crouchU = paused ? (u - 0.46) / (0.58 - 0.46) : 0; // 0..1 across pause
      const crouch = paused ? 0.07 * Math.sin(crouchU * Math.PI) : 0;
      personRef.current.position.y = topSurface + 0.16 + stride - crouch;
    }

    // A small flock arcs across the back sky on staggered phases so some ambient
    // life is almost always on screen (no longer a once-per-17s event). Each
    // bird crosses on its own offset of a 10s loop, alternating direction.
    const FLOCK_PERIOD = 10;
    for (let i = 0; i < birdRefs.current.length; i++) {
      const b = birdRefs.current[i];
      if (!b) continue;
      const off = i * 0.31;                        // phase stagger
      const bp = ((t / FLOCK_PERIOD + off) % 1);   // 0..1
      const dir = i % 2 === 0 ? 1 : -1;            // alternate L→R / R→L
      const fly = smoothstep(0.05, 0.95, bp);
      b.visible = bp > 0.04 && bp < 0.96;
      b.position.x = dir * (-4.4 + fly * 8.8);
      b.position.y = topSurface + 0.85 + i * 0.12 + 0.22 * Math.sin(bp * Math.PI);
      b.position.z = -D / 2 - 0.7 - i * 0.25;
      b.rotation.y = dir > 0 ? -Math.PI / 2 : Math.PI / 2;
      b.rotation.z = 0.4 * Math.sin(t * 12 + i * 1.3);
    }

    // A lone hawk soars a slow, lazy circle high above the site — a calmer
    // layer of sky life distinct from the flapping flock. Wings held flat; the
    // body banks gently into the turn. 24s loop, large radius, stays in frame.
    if (hawkRef.current) {
      const hp = (t / 24) % 1;                  // 0..1 slow orbit
      const ang = hp * Math.PI * 2;
      hawkRef.current.position.x = Math.cos(ang) * 3.6;
      hawkRef.current.position.z = -D / 2 - 1.2 + Math.sin(ang) * 1.1;
      hawkRef.current.position.y = topSurface + 2.0 + 0.18 * Math.sin(ang * 2);
      // heading tangent to the circle + a gentle bank into the turn
      hawkRef.current.rotation.y = -ang;
      hawkRef.current.rotation.z = 0.3 * Math.cos(ang);
    }

    // Consolidation dust: tiny wisps drift up from the footing/soil contact as
    // it settles, reinforcing the settlement bob in a still-readable way. Each
    // rises + fades on its own slow staggered loop (no per-frame allocation).
    for (let i = 0; i < settleDustRefs.current.length; i++) {
      const d = settleDustRefs.current[i];
      if (!d) continue;
      const dur = 5.5 + i * 0.9;
      const p = ((t + i * 1.7) % dur) / dur;     // 0..1 slow loop
      d.position.y = p * 0.34;
      d.position.x = (i - 1) * 0.42 + 0.05 * Math.sin(t * 1.6 + i);
      const s = 0.05 + 0.09 * Math.sin(p * Math.PI);
      d.scale.set(s, s, s);
      if (d.material) d.material.opacity = opacity * 0.22 * Math.sin(p * Math.PI);
      d.visible = p > 0.02 && p < 0.98;
    }

    // Line-of-sight laser: a faint forest pulse so the optical line breathes.
    // Floor kept high enough to read at low scene opacity, capped so it never
    // becomes a glowing tube.
    if (laserRef.current) {
      laserRef.current.opacity = opacity * (0.28 + 0.12 * (0.5 + 0.5 * Math.sin(t * 2.2)));
    }

    // Windblown leaf/seed specks: each rides the wind from near a tree to +x and
    // gently down, tumbling, fading in then out over its own loop, then resets.
    // Ties the canopy sway to ground-level motion. Shares the wind clock.
    for (let i = 0; i < leafRefs.current.length; i++) {
      const g = leafRefs.current[i];
      if (!g) continue;
      const cfg = leaves[i];
      if (!cfg) continue;
      const p = ((t + cfg.phase) % cfg.dur) / cfg.dur;   // 0..1 loop
      const drift = p * 1.7;                              // travel downwind (+x)
      const flutter = 0.12 * Math.sin(t * 4 + i * 1.7);   // side flutter (z)
      g.position.x = cfg.x0 + drift + 0.08 * Math.sin(t * 2.3 + i);
      g.position.y = cfg.y0 - p * (cfg.y0 - (topSurface + 0.06)) - 0.04 * Math.sin(t * 5 + i);
      g.position.z = cfg.z + flutter;
      g.rotation.x = t * 3 + i;
      g.rotation.z = t * 2.2 + i * 0.6;
      // fade in over the first 12%, hold, fade out over the last 20%
      const a = p < 0.12 ? p / 0.12 : p > 0.8 ? (1 - p) / 0.2 : 1;
      if (g.children[0] && g.children[0].material) {
        g.children[0].material.opacity = opacity * 0.85 * a;
      }
      g.visible = a > 0.02;
    }
  });

  // Pile-driver location: in the open cutaway floor, left of and clear from the
  // in-place load-bearing group, driving a fresh pile of its own.
  const driverX = -2.45;          // pushed to the left edge of the cut, well clear of the in-place pile group
  const driverZ = D / 2 - 0.42;   // forward toward the open face, out of the deepest cutaway shadow

  return (
    <group position={[0, 0.05, 0]}>
      {layerMeshes}

      {/* Exposed inner faces of the cutaway — lifted in value so the embedded
          piles are not lost in shadow against the trench wall. */}
      <mesh position={[notchXc, layers.arr[1].y, D / 2 - notchD + 0.005]} receiveShadow>
        <boxGeometry args={[notchW, STRATA[0].H + STRATA[1].H + STRATA[2].H, 0.02]} />
        <meshStandardMaterial color="#83795f" metalness={0.04} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>
      <mesh position={[notchXc + notchW / 2 - 0.005, layers.arr[1].y, notchZc]} receiveShadow>
        <boxGeometry args={[0.02, STRATA[0].H + STRATA[1].H + STRATA[2].H, notchD]} />
        <meshStandardMaterial color="#766b53" metalness={0.04} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>
      {/* Floor of the cutaway (top of the 4th, uncut layer). */}
      <mesh position={[notchXc, layers.arr[2].y - STRATA[2].H / 2 + 0.005, notchZc]} receiveShadow rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[notchW, notchD]} />
        <meshStandardMaterial color="#726851" metalness={0.04} roughness={1} transparent={transparent} opacity={opacity} />
      </mesh>

      {/* Groundwater: thin wet bands sitting flush ON the exposed faces (front
          face + the two cutaway trench walls) at the water-table elevation. No
          slab cuts through the block; the saturated soil tint below wtY carries
          the zone. Each band shimmers subtly via its material ref. */}
      {/* Front face band (right of the notch). */}
      <mesh position={[-W / 2 + notchW + frontRightW / 2, wtY, D / 2 + 0.012]}>
        <boxGeometry args={[frontRightW - 0.04, 0.07, 0.02]} />
        <meshStandardMaterial ref={(m) => { wetBandRefs.current[0] = m; }} color={C_WET} emissive={C_WET} emissiveIntensity={0.03} metalness={0.5} roughness={0.28} transparent opacity={opacity * 0.92} />
      </mesh>
      {/* Cutaway back wall (z-facing trench wall) band. */}
      <mesh position={[notchXc, wtY, D / 2 - notchD + 0.016]}>
        <boxGeometry args={[notchW - 0.04, 0.06, 0.02]} />
        <meshStandardMaterial ref={(m) => { wetBandRefs.current[1] = m; }} color={C_WET} emissive={C_WET} emissiveIntensity={0.03} metalness={0.5} roughness={0.28} transparent opacity={opacity * 0.88} />
      </mesh>
      {/* Cutaway side wall (x-facing trench wall) band. */}
      <mesh position={[notchXc + notchW / 2 - 0.016, wtY, notchZc]}>
        <boxGeometry args={[0.02, 0.06, notchD - 0.04]} />
        <meshStandardMaterial ref={(m) => { wetBandRefs.current[2] = m; }} color={C_WET} emissive={C_WET} emissiveIntensity={0.03} metalness={0.5} roughness={0.28} transparent opacity={opacity * 0.88} />
      </mesh>
      {/* Right end face band. */}
      <mesh position={[W / 2 + 0.012, wtY, 0]}>
        <boxGeometry args={[0.02, 0.07, D - 0.04]} />
        <meshStandardMaterial ref={(m) => { wetBandRefs.current[3] = m; }} color={C_WET} emissive={C_WET} emissiveIntensity={0.03} metalness={0.5} roughness={0.28} transparent opacity={opacity * 0.88} />
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
            <React.Fragment key={`pile${px}-${j}`}>
              {/* Pale concrete pile carrying the footing — front row a touch
                  brighter than the back row to read as depth, both pale enough
                  to pop off the lifted trench wall. */}
              <Member a={[px, pileTop, pz]} b={[px, pileBottom, pz]} radius={0.135} color={(pz === pileZs[0]) ? CONCRETE : CONCRETE_DK} opacity={opacity} />
              {/* Faint forest contact ring at the pile head so the pale concrete
                  reads as embedded into the soil, not pasted on the wall. */}
              <mesh position={[px, pileTop - 0.02, pz]} castShadow>
                <cylinderGeometry args={[0.17, 0.17, 0.05, 14]} />
                <meshStandardMaterial color={C.forest} metalness={0.05} roughness={0.9} transparent opacity={opacity * 0.5} flatShading />
              </mesh>
            </React.Fragment>
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
        drumRef={drumRef}
        cableRef={cableRef}
        opacity={opacity}
      />

      {/* Spoil-dust pool kicked up at the driving point on each blow plus one
          lingering wisp (index 4) that drifts the whole cycle (recycled, no
          per-frame allocation). */}
      <group position={[driverX, cutFloorY, driverZ]}>
        {[0, 1, 2, 3, 4].map((i) => (
          <mesh key={`dust${i}`} ref={(m) => { dustRef.current[i] = m; }} visible={false}>
            <sphereGeometry args={[1, 7, 6]} />
            <meshStandardMaterial color="#8a8170" metalness={0} roughness={1} transparent opacity={0} />
          </mesh>
        ))}
      </group>

      {/* Tiny spoil clods that tumble down the exposed trench wall on each blow,
          parented to the trench face near the driving point. */}
      <group position={[notchXc + notchW / 2 - 0.05, cutFloorY + 0.55, notchZc]}>
        {[0, 1, 2].map((i) => (
          <mesh key={`clod${i}`} ref={(m) => { clodRefs.current[i] = m; }} visible={false} castShadow>
            <dodecahedronGeometry args={[0.035, 0]} />
            <meshStandardMaterial color="#6a604f" metalness={0.05} roughness={1} transparent opacity={0} flatShading />
          </mesh>
        ))}
      </group>

      {/* A small flock arcing across the back sky on staggered phases. */}
      {[0, 1, 2, 3].map((i) => (
        <group key={`bird${i}`} ref={(el) => { birdRefs.current[i] = el; }} visible={false}>
          <Bird opacity={opacity} />
        </group>
      ))}

      {/* A lone hawk soaring a slow high circle above the site (wings held
          flat; banks into the turn). A calmer sky layer than the flock. */}
      <group ref={hawkRef}>
        <Hawk opacity={opacity} />
      </group>

      {/* Consolidation-dust wisps drifting up from the footing/soil contact as
          it settles (recycled, animated in useFrame; no per-frame alloc). */}
      <group position={[0, topSurface + 0.02, footingD / 2 - 0.1]}>
        {[0, 1, 2].map((i) => (
          <mesh key={`settledust${i}`} ref={(m) => { settleDustRefs.current[i] = m; }} visible={false}>
            <sphereGeometry args={[1, 7, 6]} />
            <meshStandardMaterial color="#9b9183" metalness={0} roughness={1} transparent opacity={0} />
          </mesh>
        ))}
      </group>

      {/* Windblown leaf/seed specks shed from the swaying trees, drifting over
          the surface (recycled, animated in useFrame; no per-frame alloc). */}
      {leaves.map((lf, i) => (
        <group key={`leaf${i}`} ref={(el) => { leafRefs.current[i] = el; }} visible={false}>
          <mesh castShadow>
            <boxGeometry args={[0.1, 0.014, 0.075]} />
            <meshStandardMaterial color={i % 2 === 0 ? '#6a7a5a' : '#8a8d57'} metalness={0.05} roughness={0.95} transparent opacity={0} flatShading />
          </mesh>
        </group>
      ))}

      {/* Planted survey level (tripod + instrument) set up on the back-right
          surface, with a thin forest line-of-sight laser sighting the column. */}
      <SurveyLevel position={[instX, topSurface + 0.16, instZ]} opacity={opacity} />
      <mesh position={sight.mid} quaternion={sight.quat}>
        <cylinderGeometry args={[0.006, 0.006, sight.len, 6]} />
        <meshStandardMaterial
          ref={(m) => { laserRef.current = m; }}
          color={C.forest}
          emissive={C.forest}
          emissiveIntensity={0.6}
          metalness={0}
          roughness={0.5}
          transparent
          opacity={opacity * 0.3}
        />
      </mesh>

      {/* Surface vegetation — low-poly trees/shrubs that sway in the wind. */}
      {trees.map((tr, i) => (
        <Tree
          key={`tree${i}`}
          groupRef={(el) => { treeRefs.current[i] = el; }}
          x={tr.x}
          z={tr.z}
          baseY={topSurface}
          scale={tr.s}
          kind={tr.kind}
          opacity={opacity}
        />
      ))}

      {/* Surveyor walking the site, carrying a tripod/level over one shoulder
          so the figure reads as a surveyor rather than a pedestrian. */}
      <group ref={personRef} position={[walk.x0, topSurface + 0.16, walk.z]} rotation={[0, Math.PI / 2, 0]}>
        <Person scale={0.88} vest={C.sunbeam} hardHat={C.ember} ponytail armPose="hold" opacity={opacity} />
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
                <cylinderGeometry args={[0.15, 0.15, l.H, 20]} />
                <meshStandardMaterial color={l.color} metalness={0.12} roughness={0.88} transparent={transparent} opacity={opacity} flatShading />
              </mesh>,
            );
            cy += l.H;
          }
          return (
            <>
              {segs}
              {/* Steel sampler half-tube around the back of the core — lighter
                  so it frames the bands without dominating them. */}
              <mesh position={[0, baseY + coreH / 2, 0]} castShadow>
                <cylinderGeometry args={[0.185, 0.185, coreH, 24, 1, true, Math.PI * 0.35, Math.PI * 1.3]} />
                <meshStandardMaterial color={C.steelLt} metalness={0.7} roughness={0.38} side={2} transparent={transparent} opacity={opacity} />
              </mesh>
              {/* Tube shoe / cutting edge at the base. */}
              <mesh position={[0, baseY + 0.05, 0]} castShadow>
                <cylinderGeometry args={[0.19, 0.19, 0.1, 24]} />
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
function Tree({ groupRef, x, z, baseY, scale = 0.6, kind = 'tree', opacity = 1 }) {
  // Muted, dusty site vegetation: desaturated + warmed greens that sit quietly
  // within the earth palette (no crisp decorative conifer green).
  const trunk = '#5a4a35';
  const leafDk = '#43543f';
  const leafLt = '#6a7a5a';
  const trans = opacity < 1;
  const shrub = kind === 'shrub';
  const broadleaf = kind === 'broadleaf';
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
        ) : broadleaf ? (
          // Rounder broadleaf: a clustered lobed crown so all three trees are
          // not identical cones.
          <>
            <mesh position={[0, 0.34, 0]} castShadow>
              <sphereGeometry args={[0.42, 12, 10]} />
              <meshStandardMaterial color={leafDk} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
            </mesh>
            <mesh position={[0.26, 0.5, 0.06]} castShadow>
              <sphereGeometry args={[0.28, 12, 10]} />
              <meshStandardMaterial color={leafLt} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
            </mesh>
            <mesh position={[-0.24, 0.46, -0.05]} castShadow>
              <sphereGeometry args={[0.26, 12, 10]} />
              <meshStandardMaterial color={leafDk} metalness={0.05} roughness={0.95} transparent={trans} opacity={opacity} flatShading />
            </mesh>
            <mesh position={[0.02, 0.66, 0.0]} castShadow>
              <sphereGeometry args={[0.26, 12, 10]} />
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
function PileDriver({ x, z, baseY, pileBottom, hammerRef, pileRef, drumRef, cableRef, opacity = 1 }) {
  const trans = opacity < 1;
  const leaderH = 1.5;
  const railDX = 0.22;             // half-gap between the two guide rails (wider)
  const railT = 0.07;              // rail thickness (chunkier)
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

      {/* Twin guide rails (wider gap, chunkier section). */}
      {[-railDX, railDX].map((dx) => (
        <mesh key={`rail${dx}`} position={[dx, baseY + 0.12 + leaderH / 2, 0]} castShadow>
          <boxGeometry args={[railT, leaderH, 0.08]} />
          <meshStandardMaterial color={C.steel} metalness={0.75} roughness={0.38} transparent={trans} opacity={opacity} />
        </mesh>
      ))}
      {/* Cross-bracing rungs between the rails so the leader reads as a frame. */}
      {[0.28, 0.62, 0.96, 1.3].map((fy) => (
        <mesh key={`rung${fy}`} position={[0, baseY + 0.12 + fy, 0]} castShadow>
          <boxGeometry args={[railDX * 2, 0.035, 0.04]} />
          <meshStandardMaterial color={C.steelLt} metalness={0.6} roughness={0.45} transparent={trans} opacity={opacity} />
        </mesh>
      ))}
      {/* Crown block at the rail tops, carrying the sheave + winch line. */}
      <mesh position={[0, topY, 0]} castShadow>
        <boxGeometry args={[railDX * 2 + 0.1, 0.12, 0.14]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.6} roughness={0.45} transparent={trans} opacity={opacity} />
      </mesh>
      {/* Angled back A-frame leg bracing the leader so it reads as machinery,
          not a bare pole. */}
      <mesh position={[0, baseY + 0.12 + leaderH * 0.42, -0.42]} rotation={[0.62, 0, 0]} castShadow>
        <boxGeometry args={[0.07, leaderH * 0.95, 0.07]} />
        <meshStandardMaterial color={C.steel} metalness={0.7} roughness={0.42} transparent={trans} opacity={opacity} />
      </mesh>
      {/* A short tie strut from the back leg to the leader mid-height. */}
      <mesh position={[0, baseY + 0.12 + leaderH * 0.5, -0.2]} rotation={[1.2, 0, 0]} castShadow>
        <boxGeometry args={[0.05, 0.42, 0.05]} />
        <meshStandardMaterial color={C.steel} metalness={0.7} roughness={0.42} transparent={trans} opacity={opacity} />
      </mesh>

      {/* Winch drum mounted low on the back leg, axis left-right (along X). A
          static wrapper orients it; the inner group (drumRef) spins about its
          own axis (local Z, here mutated in useFrame) so the off-axis spoke
          makes the rotation read. */}
      <group position={[0, baseY + 0.34, -0.34]} rotation={[0, 0, Math.PI / 2]}>
        <group ref={drumRef}>
          <mesh castShadow>
            <cylinderGeometry args={[0.1, 0.1, 0.18, 14]} />
            <meshStandardMaterial color={C.steel} metalness={0.8} roughness={0.35} transparent={trans} opacity={opacity} />
          </mesh>
          {/* Two contrasting off-axis spoke marks 180° apart (one light, one
              dark) so the drum's rotation reads clearly as it pays out / reels
              in with the hammer cycle. Enlarged for tile-scale legibility. */}
          <mesh position={[0.075, 0, 0]} castShadow>
            <boxGeometry args={[0.07, 0.21, 0.05]} />
            <meshStandardMaterial color={C.steelLt} metalness={0.6} roughness={0.45} transparent={trans} opacity={opacity} />
          </mesh>
          <mesh position={[-0.075, 0, 0]} castShadow>
            <boxGeometry args={[0.07, 0.21, 0.05]} />
            <meshStandardMaterial color={C.ember} metalness={0.3} roughness={0.55} transparent={trans} opacity={opacity} />
          </mesh>
        </group>
      </group>

      {/* Hoist cable from the crown sheave down to the ram top — length tracks
          the ram via cableRef (scale.y of a unit cylinder). */}
      <mesh ref={cableRef} position={[0, baseY + 0.8, 0.0]}>
        <cylinderGeometry args={[0.012, 0.012, 1, 6]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.3} roughness={0.6} transparent opacity={opacity * 0.85} />
      </mesh>

      {/* Base sill / lead foot grounding the rig on the soil. */}
      <mesh position={[0, baseY + 0.08, -0.05]} castShadow>
        <boxGeometry args={[railDX * 2 + 0.26, 0.16, 0.42]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.55} roughness={0.5} transparent={trans} opacity={opacity} />
      </mesh>
      {/* Heavy ram riding between the rails — lightened to steelLt with a thicker
          silhouette so it is not a black void on cream and the drop reads at
          tile scale — animated via ref. */}
      <mesh ref={hammerRef} position={[0, baseY + 0.6, 0]} castShadow>
        <boxGeometry args={[railDX * 2 + 0.06, 0.46, 0.26]} />
        <meshStandardMaterial color={C.steelLt} metalness={0.8} roughness={0.36} transparent={trans} opacity={opacity} />
      </mesh>
    </group>
  );
}

// A tiny low-poly bird (body + two swept wings) carried in a parent group that
// arcs it across the back sky. The wing flap comes from the parent's rotation.z.
function Bird({ opacity = 1 }) {
  const trans = opacity < 1;
  // Warm steel-charcoal (#3d3a36) instead of pure charcoal so the birds read as
  // birds against the cream rather than as dark dust specks; slightly larger.
  const mat = <meshStandardMaterial color="#3d3a36" metalness={0.1} roughness={0.8} transparent={trans} opacity={opacity} flatShading />;
  return (
    <group scale={0.62}>
      <mesh castShadow><sphereGeometry args={[0.105, 8, 6]} />{mat}</mesh>
      <mesh position={[0, 0.02, 0.23]} rotation={[0.4, 0.4, 0]} castShadow>
        <boxGeometry args={[0.02, 0.07, 0.38]} />{mat}
      </mesh>
      <mesh position={[0, 0.02, -0.23]} rotation={[-0.4, -0.4, 0]} castShadow>
        <boxGeometry args={[0.02, 0.07, 0.38]} />{mat}
      </mesh>
    </group>
  );
}

// A lone hawk: a longer body with broad, flat, slightly swept-back wings held
// in a soaring glide (no flap) and a short fanned tail. Larger than a flock
// bird so it reads as a separate, calmer sky element. Honors `opacity`.
function Hawk({ opacity = 1 }) {
  const trans = opacity < 1;
  const mat = <meshStandardMaterial color="#4a463f" metalness={0.1} roughness={0.8} transparent={trans} opacity={opacity} flatShading />;
  return (
    <group scale={0.8}>
      {/* body */}
      <mesh castShadow><capsuleGeometry args={[0.06, 0.22, 4, 8]} /><meshStandardMaterial color="#4a463f" metalness={0.1} roughness={0.8} transparent={trans} opacity={opacity} flatShading /></mesh>
      {/* broad flat wings, swept slightly back */}
      <mesh position={[0.34, 0.02, 0.04]} rotation={[0, 0.18, 0.06]} castShadow>
        <boxGeometry args={[0.6, 0.02, 0.2]} />{mat}
      </mesh>
      <mesh position={[-0.34, 0.02, 0.04]} rotation={[0, -0.18, -0.06]} castShadow>
        <boxGeometry args={[0.6, 0.02, 0.2]} />{mat}
      </mesh>
      {/* fanned tail */}
      <mesh position={[0, 0, -0.22]} rotation={[0, 0, 0]} castShadow>
        <boxGeometry args={[0.16, 0.018, 0.16]} />{mat}
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
    <group position={[0.02, 0.82, -0.16]} rotation={[0, 0, -0.5]} scale={0.66}>
      {/* Three legs splayed wider from a common head so the tripod silhouette
          is unmistakable even at tile scale. */}
      {[-0.16, 0, 0.16].map((dz, i) => (
        <mesh key={i} position={[0, -0.4, dz]} rotation={[dz * 1.5, 0, 0.05]} castShadow>
          <cylinderGeometry args={[0.02, 0.02, 0.92, 6]} />{steel}
        </mesh>
      ))}
      {/* Instrument head. */}
      <mesh position={[0, 0.06, 0]} castShadow>
        <boxGeometry args={[0.13, 0.11, 0.13]} />
        <meshStandardMaterial color={C.steel} metalness={0.6} roughness={0.4} transparent={trans} opacity={opacity} />
      </mesh>
    </group>
  );
}

// A planted survey level: a tripod standing on the surface with a small
// telescope/level instrument on top, sighting toward the footing. Static —
// the thin forest line-of-sight laser (built in the scene) emanates from its
// optical center. Honors `opacity`.
function SurveyLevel({ position, opacity = 1 }) {
  const trans = opacity < 1;
  const legH = 0.92;
  // three legs splayed around a head ~0.9 above the ground
  const legs = [0, (Math.PI * 2) / 3, (Math.PI * 4) / 3];
  return (
    <group position={position}>
      {legs.map((a, i) => {
        const sx = Math.sin(a) * 0.22;
        const sz = Math.cos(a) * 0.22;
        // leg leans out from head (0,0.9,0) to foot (sx,0,sz)
        const midY = 0.9 / 2;
        const lean = Math.atan2(Math.hypot(sx, sz), 0.9);
        return (
          <mesh key={i} position={[sx / 2, midY, sz / 2]} rotation={[Math.cos(a) * lean, 0, -Math.sin(a) * lean]} castShadow>
            <cylinderGeometry args={[0.016, 0.016, legH, 6]} />
            <meshStandardMaterial color={C.steelLt} metalness={0.5} roughness={0.5} transparent={trans} opacity={opacity} />
          </mesh>
        );
      })}
      {/* Tribrach / head plate. */}
      <mesh position={[0, 0.9, 0]} castShadow>
        <cylinderGeometry args={[0.07, 0.08, 0.05, 12]} />
        <meshStandardMaterial color={C.steel} metalness={0.6} roughness={0.45} transparent={trans} opacity={opacity} />
      </mesh>
      {/* Telescope barrel of the level, aimed roughly toward the footing (-x). */}
      <mesh position={[-0.06, 0.98, 0]} rotation={[0, 0, Math.PI / 2]} castShadow>
        <cylinderGeometry args={[0.028, 0.028, 0.2, 12]} />
        <meshStandardMaterial color={C.charcoal} metalness={0.4} roughness={0.5} transparent={trans} opacity={opacity} />
      </mesh>
      {/* Eyepiece / focus knob accent. */}
      <mesh position={[0.06, 0.98, 0]} castShadow>
        <sphereGeometry args={[0.03, 10, 8]} />
        <meshStandardMaterial color={C.steel} metalness={0.6} roughness={0.4} transparent={trans} opacity={opacity} />
      </mesh>
    </group>
  );
}
