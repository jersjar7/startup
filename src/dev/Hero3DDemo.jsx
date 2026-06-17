import React from 'react';
import { HeroScene } from '../landing/HeroScene';

// Dev-only preview (/dev/hero). A faithful replica of the live hero: the REAL,
// unchanged hero copy on the left, and the new brushed-steel Three.js scene
// dropped into the exact right-side slot the SVG occupies today (.hero-svg =
// absolute, right:0, width:60%, height:100%). This lets the look be approved
// before HeroScene touches the live landing. Nothing here ships to production.

const C = {
  cream: '#FFF9F0',
  charcoal: '#2C2C2C',
  ember: '#E8683A',
  gray500: '#6B6B6B',
};

const TOPICS = ['Structural Analysis', 'Fluid Mechanics', 'Transportation', 'Surveying', 'Geotechnical'];

function TopicLabel() {
  const [idx, setIdx] = React.useState(0);
  const [visible, setVisible] = React.useState(true);
  React.useEffect(() => {
    const cycle = setInterval(() => {
      setVisible(false);
      setTimeout(() => {
        setIdx((i) => (i + 1) % TOPICS.length);
        setVisible(true);
      }, 400);
    }, 3000);
    return () => clearInterval(cycle);
  }, []);
  return (
    <div style={{ position: 'absolute', top: 32, right: 56, display: 'flex', alignItems: 'center', gap: 8, zIndex: 2 }}>
      <span style={{ width: 6, height: 6, borderRadius: '50%', background: C.ember }} />
      <span
        style={{
          fontFamily: 'DM Sans, sans-serif',
          fontSize: '0.7rem',
          fontWeight: 600,
          letterSpacing: '0.08em',
          textTransform: 'uppercase',
          color: C.gray500,
          opacity: visible ? 1 : 0,
          transition: 'opacity 400ms cubic-bezier(0.23,1,0.32,1)',
        }}
      >
        {TOPICS[idx]}
      </span>
    </div>
  );
}

export function Hero3DDemo() {
  return (
    <div style={{ position: 'relative', minHeight: '100vh', background: C.cream, overflow: 'hidden' }}>
      {/* Right-side slot — exactly where .hero-svg lives (right:0, width:60%, height:100%) */}
      <div style={{ position: 'absolute', top: 0, right: 0, width: '60%', height: '100%', zIndex: 0 }}>
        <HeroScene />
      </div>

      <TopicLabel />

      {/* Real hero copy, left side, unchanged from landing.jsx */}
      <div
        style={{
          position: 'relative',
          zIndex: 1,
          maxWidth: 1100,
          margin: '0 auto',
          padding: '14vh 32px 0',
          pointerEvents: 'none',
        }}
      >
        <div style={{ maxWidth: 560 }}>
          <span
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: 10,
              fontFamily: 'DM Sans, sans-serif',
              fontSize: '0.7rem',
              fontWeight: 600,
              letterSpacing: '0.08em',
              textTransform: 'uppercase',
              color: C.ember,
            }}
          >
            <span style={{ width: 24, height: 2, background: C.ember, display: 'inline-block' }} />
            FE Civil Exam Prep
          </span>
          <h1
            style={{
              fontFamily: 'DM Sans, sans-serif',
              fontWeight: 700,
              fontSize: 'clamp(2.2rem, 4.4vw, 3.6rem)',
              color: C.charcoal,
              letterSpacing: '-0.03em',
              lineHeight: 1.08,
              margin: '20px 0 0',
            }}
          >
            Everything you need to walk into the FE ready.{' '}
            <span style={{ color: C.ember }}>Everything.</span>
          </h1>
          <p
            style={{
              fontFamily: 'Inter, sans-serif',
              color: C.charcoal,
              opacity: 0.72,
              fontSize: '1.1rem',
              lineHeight: 1.6,
              marginTop: 18,
              maxWidth: 460,
            }}
          >
            First attempt or a retake, you don't need to relearn everything. You need targeted
            practice on exactly what the exam tests.
          </p>
          <div style={{ marginTop: 26, pointerEvents: 'auto' }}>
            <button
              style={{
                background: C.ember,
                color: C.cream,
                border: 'none',
                borderRadius: 10,
                padding: '14px 26px',
                fontFamily: 'DM Sans, sans-serif',
                fontWeight: 700,
                fontSize: '1rem',
                cursor: 'pointer',
              }}
            >
              Get started →
            </button>
          </div>
        </div>
      </div>

      <div
        style={{
          position: 'absolute',
          bottom: 18,
          left: 24,
          fontFamily: 'Inter, sans-serif',
          fontSize: 12,
          opacity: 0.4,
          color: C.charcoal,
          zIndex: 2,
        }}
      >
        brushed-steel hero preview · /dev/hero
      </div>
    </div>
  );
}
