import React from 'react';
import { Canvas, useThree } from '@react-three/fiber';
import { Environment, ContactShadows, Lightformer } from '@react-three/drei';
import { TrussScene } from '../landing/hero/TrussScene';
import { FluidScene } from '../landing/hero/FluidScene';
import { RoadScene } from '../landing/hero/RoadScene';
import { SurveyScene } from '../landing/hero/SurveyScene';
import { GeoScene } from '../landing/hero/GeoScene';

// Dev-only (/dev/hero-tile?t=0..4). Renders ONE hero topic statically at full
// opacity, framed large and centered, for review. Includes a Pause/Resume
// control (canvas switches to on-demand rendering, freezing the animation) and
// topic tabs so each of the five scenes can be inspected and annotated.
// Keyboard: Space = pause/resume, ArrowLeft/Right = switch topic.
// Never shipped to production (gated behind import.meta.env.DEV in app.jsx).

const SCENES = [
  { name: 'Structural Analysis', short: 'Truss', C: TrussScene },
  { name: 'Fluid Mechanics', short: 'Fluid', C: FluidScene },
  { name: 'Transportation', short: 'Road', C: RoadScene },
  { name: 'Surveying', short: 'Survey', C: SurveyScene },
  { name: 'Geotechnical', short: 'Geo', C: GeoScene },
];

// Force a single render when topic or pause state changes, so switching scenes
// while paused (frameloop="demand") still draws the new/frozen frame.
function Rerender({ dep }) {
  const invalidate = useThree((s) => s.invalidate);
  React.useEffect(() => {
    invalidate();
  }, [dep, invalidate]);
  return null;
}

export function HeroTiles() {
  const initial = Number(new URLSearchParams(window.location.search).get('t') || 0);
  const [t, setT] = React.useState(Math.max(0, Math.min(4, initial)));
  const [paused, setPaused] = React.useState(false);
  const { name, C: Scene } = SCENES[t];

  React.useEffect(() => {
    const onKey = (e) => {
      if (e.code === 'Space') {
        e.preventDefault();
        setPaused((p) => !p);
      } else if (e.code === 'ArrowRight') {
        setT((v) => (v + 1) % SCENES.length);
      } else if (e.code === 'ArrowLeft') {
        setT((v) => (v + SCENES.length - 1) % SCENES.length);
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  const tab = (active) => ({
    fontFamily: 'DM Sans, sans-serif',
    fontWeight: 600,
    fontSize: 13,
    padding: '8px 14px',
    borderRadius: 10,
    border: `1px solid ${active ? '#E8683A' : 'rgba(44,44,44,0.18)'}`,
    background: active ? '#E8683A' : '#FFFFFF',
    color: active ? '#FFF9F0' : '#2C2C2C',
    cursor: 'pointer',
  });

  return (
    <div style={{ position: 'fixed', inset: 0, background: '#FFF9F0' }}>
      <Canvas
        frameloop={paused ? 'demand' : 'always'}
        camera={{ position: [0, 1.7, 10.5], fov: 40 }}
        dpr={[1, 2]}
        gl={{ alpha: true, antialias: true }}
        shadows
      >
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
        <Rerender dep={`${t}:${paused}`} />
      </Canvas>

      <div style={{ position: 'absolute', top: 18, left: 22, fontFamily: 'DM Sans, sans-serif', fontWeight: 700, fontSize: 20, color: '#2C2C2C' }}>
        {name}
        {paused && <span style={{ marginLeft: 12, fontSize: 13, fontWeight: 600, color: '#E8683A' }}>PAUSED</span>}
      </div>

      <div
        style={{
          position: 'absolute',
          bottom: 24,
          left: '50%',
          transform: 'translateX(-50%)',
          display: 'flex',
          alignItems: 'center',
          gap: 8,
          padding: 8,
          background: 'rgba(255,249,240,0.85)',
          borderRadius: 14,
          boxShadow: '0 4px 16px rgba(44,44,44,0.1)',
          backdropFilter: 'blur(4px)',
        }}
      >
        {SCENES.map((s, i) => (
          <button key={s.short} onClick={() => setT(i)} style={tab(i === t)}>
            {s.short}
          </button>
        ))}
        <div style={{ width: 1, height: 24, background: 'rgba(44,44,44,0.15)', margin: '0 4px' }} />
        <button
          onClick={() => setPaused((p) => !p)}
          style={{
            fontFamily: 'DM Sans, sans-serif',
            fontWeight: 700,
            fontSize: 13,
            padding: '8px 18px',
            borderRadius: 10,
            border: 'none',
            background: '#2C2C2C',
            color: '#FFF9F0',
            cursor: 'pointer',
          }}
        >
          {paused ? 'Resume' : 'Pause'}
        </button>
      </div>

      <div style={{ position: 'absolute', bottom: 70, left: '50%', transform: 'translateX(-50%)', fontFamily: 'Inter, sans-serif', fontSize: 11, color: 'rgba(44,44,44,0.45)' }}>
        Space = pause · ← → = switch topic
      </div>
    </div>
  );
}
