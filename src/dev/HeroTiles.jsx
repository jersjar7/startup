import React from 'react';
import { Canvas } from '@react-three/fiber';
import { Environment, ContactShadows, Lightformer } from '@react-three/drei';
import { TrussScene } from '../landing/hero/TrussScene';
import { FluidScene } from '../landing/hero/FluidScene';
import { RoadScene } from '../landing/hero/RoadScene';
import { SurveyScene } from '../landing/hero/SurveyScene';
import { GeoScene } from '../landing/hero/GeoScene';

// Dev-only (/dev/hero-tile?t=0..4). Renders ONE hero topic statically at full
// opacity, framed large and centered, for clean per-topic review captures.
// Never shipped to production (gated behind import.meta.env.DEV in app.jsx).

const SCENES = [
  { name: 'Structural Analysis', C: TrussScene },
  { name: 'Fluid Mechanics', C: FluidScene },
  { name: 'Transportation', C: RoadScene },
  { name: 'Surveying', C: SurveyScene },
  { name: 'Geotechnical', C: GeoScene },
];

export function HeroTiles() {
  const t = Number(new URLSearchParams(window.location.search).get('t') || 0);
  const { name, C: Scene } = SCENES[Math.max(0, Math.min(4, t))];
  return (
    <div style={{ position: 'fixed', inset: 0, background: '#FFF9F0' }}>
      <Canvas camera={{ position: [0, 1.7, 10.5], fov: 40 }} dpr={[1, 2]} gl={{ alpha: true, antialias: true }} shadows>
        <ambientLight intensity={0.55} />
        <directionalLight position={[5, 8, 6]} intensity={1.2} castShadow shadow-mapSize={[2048, 2048]} />
        <directionalLight position={[-6, 3, -4]} intensity={0.4} color="#E8683A" />
        <group rotation={[0.1, -0.5, 0]} position={[0, -0.3, 0]}>
          <Scene opacity={1} />
        </group>
        <ContactShadows position={[0, -2.6, 0]} opacity={0.32} scale={20} blur={2.6} far={7} color="#2C2C2C" />
        <Environment resolution={256}>
          <Lightformer intensity={2.6} position={[0, 5, -6]} scale={[12, 12, 1]} color="#FFF9F0" />
          <Lightformer intensity={1.4} position={[-6, 2, 2]} scale={[6, 8, 1]} color="#ffffff" />
          <Lightformer intensity={0.9} position={[6, -1, 3]} scale={[6, 6, 1]} color="#F5B731" />
          <Lightformer intensity={0.7} position={[3, 4, 4]} scale={[4, 4, 1]} color="#E8683A" />
        </Environment>
      </Canvas>
      <div style={{ position: 'absolute', top: 18, left: 22, fontFamily: 'DM Sans, sans-serif', fontWeight: 700, fontSize: 20, color: '#2C2C2C' }}>
        {name}
      </div>
    </div>
  );
}
