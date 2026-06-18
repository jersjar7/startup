import React from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Environment, ContactShadows, Lightformer } from '@react-three/drei';
import { smoothstep } from './hero/primitives';
import { TrussScene } from './hero/TrussScene';
import { FluidScene } from './hero/FluidScene';
import { RoadScene } from './hero/RoadScene';
import { SurveyScene } from './hero/SurveyScene';
import { GeoScene } from './hero/GeoScene';

// Brushed-steel hero animation (concept 1). Replaces the right-side HeroSvg with
// a 3D scene that cycles the five FE Civil topics, each a detailed volumetric
// object under studio lighting with soft contact shadows and ember accents.
// Same 15s / 5-phase (3s each) cadence as TopicLabel. Each topic lives in its
// own module under ./hero so it can be iterated on independently.

// Each topic carries its own scale so the larger scenes (the truss with its
// approach roads, and the long river channel) fit the slot without bleeding off
// the edge, while the others keep their size.
const TOPICS = [
  { comp: TrussScene, scale: 0.5 },
  { comp: FluidScene, scale: 0.54 },
  { comp: RoadScene, scale: 0.62 },
  { comp: SurveyScene, scale: 0.62 },
  { comp: GeoScene, scale: 0.62 },
];

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

  const { comp: Scene, scale } = TOPICS[phase];

  // Sit in the right of the slot, clear of the headline on the left, small
  // enough that the widest topic does not bleed off the right edge.
  return (
    <group ref={grp} position={[-0.15, -0.3, 0]} scale={scale}>
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
      <directionalLight position={[-6, 3, -4]} intensity={0.4} color="#E8683A" />
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
