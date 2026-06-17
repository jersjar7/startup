import React from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Grid, Line } from '@react-three/drei';
import { useNavigate } from 'react-router-dom';

// Three.js hero PROTOTYPE (dev-only, /dev/hero). The drawing board comes alive:
// an engineering grid ground (the drafting surface) with a 3D wireframe bridge
// truss floating above it, slowly turning with mouse parallax. The 3D means
// something here, it's the structure FE Civil candidates actually analyze.

const C = { cream: '#FFF9F0', charcoal: '#2C2C2C', ember: '#E8683A', forest: '#2D7A5F' };

// A 3D Warren bridge truss: two side trusses + cross bracing. Returns line
// members (charcoal body, ember top chords) and joint nodes.
function buildBridge(bays = 7, span = 14, height = 2.4, width = 2.8) {
  const dx = span / bays;
  const hz = width / 2;
  const bF = [];
  const bB = [];
  const tF = [];
  const tB = [];
  for (let i = 0; i <= bays; i++) {
    const x = i * dx - span / 2;
    bF.push([x, 0, hz]);
    bB.push([x, 0, -hz]);
  }
  for (let i = 0; i < bays; i++) {
    const x = i * dx - span / 2 + dx / 2;
    tF.push([x, height, hz]);
    tB.push([x, height, -hz]);
  }
  const charcoal = [];
  const ember = [];
  const chord = (arr, top) => {
    for (let i = 0; i < arr.length - 1; i++) (top ? ember : charcoal).push([arr[i], arr[i + 1]]);
  };
  chord(bF, false);
  chord(bB, false);
  chord(tF, true);
  chord(tB, true);
  const diag = (b, t) => {
    for (let i = 0; i < bays; i++) {
      charcoal.push([b[i], t[i]]);
      charcoal.push([t[i], b[i + 1]]);
    }
  };
  diag(bF, tF);
  diag(bB, tB);
  for (let i = 0; i <= bays; i++) charcoal.push([bF[i], bB[i]]); // deck cross-beams
  for (let i = 0; i < bays; i++) charcoal.push([tF[i], tB[i]]); // top cross-bracing
  return { charcoal, ember, nodes: [...bF, ...bB] };
}

function Bridge() {
  const g = React.useRef();
  const { charcoal, ember, nodes } = React.useMemo(() => buildBridge(), []);
  const reduced = React.useRef(
    typeof window !== 'undefined' && window.matchMedia?.('(prefers-reduced-motion: reduce)').matches,
  ).current;

  useFrame((state) => {
    const grp = g.current;
    if (!grp) return;
    if (reduced) {
      grp.rotation.y = -0.4;
      grp.rotation.x = 0.12;
      return;
    }
    const t = state.clock.elapsedTime;
    grp.rotation.y = Math.sin(t * 0.16) * 0.45 - 0.3 + state.pointer.x * 0.25;
    grp.rotation.x = 0.1 + state.pointer.y * 0.1;
    grp.position.y = 1.5 + Math.sin(t * 0.5) * 0.12;
  });

  return (
    <group ref={g} position={[0, 1.5, 0]}>
      {charcoal.map((p, i) => (
        <Line key={`c${i}`} points={p} color={C.charcoal} lineWidth={1.5} />
      ))}
      {ember.map((p, i) => (
        <Line key={`e${i}`} points={p} color={C.ember} lineWidth={2.6} />
      ))}
      {nodes.map((n, i) => (
        <mesh key={`n${i}`} position={n}>
          <sphereGeometry args={[0.075, 12, 12]} />
          <meshStandardMaterial color={C.forest} />
        </mesh>
      ))}
    </group>
  );
}

function Scene() {
  return (
    <>
      <color attach="background" args={[C.cream]} />
      <fog attach="fog" args={[C.cream, 16, 32]} />
      <ambientLight intensity={0.85} />
      <directionalLight position={[6, 9, 5]} intensity={0.55} />
      <Bridge />
      <Grid
        position={[0, 0, 0]}
        args={[44, 44]}
        cellSize={1}
        cellThickness={0.6}
        cellColor="#9DBFAE"
        sectionSize={5}
        sectionThickness={1}
        sectionColor={C.forest}
        fadeDistance={28}
        fadeStrength={1.6}
        infiniteGrid
      />
    </>
  );
}

export function Hero3DDemo() {
  const navigate = useNavigate();
  return (
    <div style={{ position: 'fixed', inset: 0, background: C.cream }}>
      <Canvas camera={{ position: [0, 4.6, 12], fov: 40 }} dpr={[1, 1.8]} gl={{ antialias: true }}>
        <Scene />
      </Canvas>
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          padding: '0 8%',
          pointerEvents: 'none',
        }}
      >
        <div
          style={{
            fontFamily: 'DM Sans, sans-serif',
            fontWeight: 800,
            fontSize: 'clamp(2rem, 5vw, 4rem)',
            color: C.charcoal,
            letterSpacing: '-0.03em',
            lineHeight: 1.05,
            maxWidth: 680,
          }}
        >
          Everything you need to
          <br />
          walk into the FE <span style={{ color: C.ember }}>ready.</span>
        </div>
        <p
          style={{
            fontFamily: 'Inter, sans-serif',
            color: C.charcoal,
            opacity: 0.72,
            fontSize: '1.1rem',
            marginTop: 16,
            maxWidth: 460,
          }}
        >
          Lessons, 1,126 practice problems, and a plan, built on the structures you will actually be tested on.
        </p>
        <div style={{ marginTop: 24, pointerEvents: 'auto' }}>
          <button
            onClick={() => navigate('/login')}
            style={{
              background: C.ember,
              color: C.cream,
              border: 'none',
              borderRadius: 999,
              padding: '14px 28px',
              fontFamily: 'DM Sans, sans-serif',
              fontWeight: 700,
              fontSize: '1rem',
              cursor: 'pointer',
            }}
          >
            Get started →
          </button>
        </div>
        <div
          style={{
            position: 'absolute',
            bottom: 22,
            left: '8%',
            fontFamily: 'Inter, sans-serif',
            fontSize: 12,
            opacity: 0.4,
            color: C.charcoal,
          }}
        >
          three.js hero prototype · /dev/hero
        </div>
      </div>
    </div>
  );
}
