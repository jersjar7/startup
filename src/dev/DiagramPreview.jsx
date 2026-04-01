import React from 'react';
import { DIAGRAM_REGISTRY } from '../components/diagrams';

/* Default props for each diagram — matches the lesson data */
const DEFAULTS = {
  RightTriangle: { angle: 35 },
  ForceAtAngle: { force: 500, angle: 35 },
  CableGeometry: { horiz: 5, vert: 12, force: 1300 },
  CraneBoom: { length: 10, angle: 40, load: 5000 },
  SimplySupportedBeam: { span: 8, loadPos: 3, load: 12 },
  CantileverBeam: { length: 4, loadIntensity: 3 },
  BeamWithCouple: { span: 10, loadPos: 4, load: 20, couplePos: 7, couple: 10 },
  ZeroForceJoint: {},
  TriangularTruss: { span: 6, height: 4, load: 10 },
  PrattTruss: { panels: 3, panelWidth: 3, height: 4, load: 24, loadPanel: 2 },
  BlockFlat: { weight: 500, mu: 0.40 },
  BeltPulley: { mu: 0.30, slackT: 200, wrapDeg: 180 },
  BlockOnRamp: { weight: 800, angle: 25, mu: 0.50 },
  TSection: { flangeW: 120, flangeH: 20, webW: 20, webH: 80, showCentroid: false },
  PlateWithHole: { plateW: 300, plateH: 200, holeDia: 60, holeX: 150, holeY: 150 },
  BuiltUpSection: { botW: 200, botH: 30, webW: 30, webH: 140, topW: 150, topH: 30 },
  RectangleInertia: { width: 150, height: 300 },
  ParallelAxisRect: { width: 50, height: 100 },
  ProjectileLaunch: { v0: 20, angle: 60 },
  CarOnCurve: { radius: 200, speed: 30, accelT: 2 },
  CylinderParallelAxis: { mass: 12, radius: 0.2, distance: 0.5 },
  BlockOnIncline: { weight: 500, angle: 30 },
  DiskTangentialForce: { mass: 10, radius: 0.3, force: 15 },
  RampDrop: { height: 3, mass: 5 },
  SpringMass: { mass: 50, stiffness: 800 },
};

/* Lesson mapping for context */
const LESSON_MAP = {
  RightTriangle: 'Math — Trig',
  ForceAtAngle: 'L1 Force Systems — Q1',
  CableGeometry: 'L1 Force Systems — Q2',
  CraneBoom: 'L1 Force Systems — Q3',
  SimplySupportedBeam: 'L2 Equilibrium — Q1',
  CantileverBeam: 'L2 Equilibrium — Q2',
  BeamWithCouple: 'L2 Equilibrium — Q3',
  ZeroForceJoint: 'L3 Trusses — Q1',
  TriangularTruss: 'L3 Trusses — Q2',
  PrattTruss: 'L3 Trusses — Q3',
  BlockFlat: 'L4 Friction — Q1',
  BeltPulley: 'L4 Friction — Q2',
  BlockOnRamp: 'L4 Friction — Q3',
  TSection: 'L5 Centroids — Q1 / L6 Inertia — Q3',
  PlateWithHole: 'L5 Centroids — Q2',
  BuiltUpSection: 'L5 Centroids — Q3',
  RectangleInertia: 'L6 Inertia — Q1',
  ParallelAxisRect: 'L6 Inertia — Q2',
  ProjectileLaunch: 'Dyn L1 Particle Kin — Q2',
  CarOnCurve: 'Dyn L1 Particle Kin — Q3',
  CylinderParallelAxis: 'Dyn L2 Rigid Body — Q3',
  BlockOnIncline: 'Dyn L3 Force & Accel — Q2',
  DiskTangentialForce: 'Dyn L3 Force & Accel — Q3',
  RampDrop: 'Dyn L4 Work Energy — Q1',
  SpringMass: 'Dyn L6 Vibrations — Q1',
};

export function DiagramPreview() {
  const entries = Object.entries(DIAGRAM_REGISTRY);

  return (
    <main style={{
      padding: '2rem',
      maxWidth: '1200px',
      margin: '0 auto',
      fontFamily: 'var(--font-body)',
    }}>
      <h1 style={{
        fontFamily: 'var(--font-heading)',
        fontSize: '1.5rem',
        fontWeight: 700,
        color: 'var(--charcoal)',
        marginBottom: '0.5rem',
      }}>
        Diagram Preview
      </h1>
      <p style={{
        fontSize: '0.85rem',
        color: 'var(--gray-500)',
        marginBottom: '2rem',
      }}>
        {entries.length} registered diagrams — rendered with default props from lesson data
      </p>

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(380px, 1fr))',
        gap: '1.5rem',
      }}>
        {entries.map(([name, Component]) => (
          <div key={name} style={{
            background: 'white',
            borderRadius: '10px',
            boxShadow: '0 1px 3px rgba(44,44,44,0.04), 0 4px 16px rgba(44,44,44,0.06)',
            overflow: 'hidden',
          }}>
            {/* Header */}
            <div style={{
              padding: '0.75rem 1rem',
              borderBottom: '1px solid var(--gray-100)',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
            }}>
              <span style={{
                fontFamily: 'var(--font-mono)',
                fontSize: '0.78rem',
                fontWeight: 600,
                color: 'var(--charcoal)',
              }}>
                {name}
              </span>
              <span style={{
                fontFamily: 'var(--font-body)',
                fontSize: '0.7rem',
                color: 'var(--gray-400)',
              }}>
                {LESSON_MAP[name] || ''}
              </span>
            </div>

            {/* Diagram */}
            <div style={{
              padding: '1rem',
              backgroundColor: '#FDFCF8',
              backgroundImage: [
                'linear-gradient(rgba(100,160,140,0.08) 1px, transparent 1px)',
                'linear-gradient(90deg, rgba(100,160,140,0.08) 1px, transparent 1px)',
                'linear-gradient(rgba(100,160,140,0.04) 1px, transparent 1px)',
                'linear-gradient(90deg, rgba(100,160,140,0.04) 1px, transparent 1px)',
              ].join(','),
              backgroundSize: '50px 50px, 50px 50px, 10px 10px, 10px 10px',
              maxWidth: '420px',
              margin: '0 auto',
            }}>
              <Component {...(DEFAULTS[name] || {})} />
            </div>

            {/* Props */}
            <div style={{
              padding: '0.5rem 1rem',
              borderTop: '1px solid var(--gray-100)',
            }}>
              <code style={{
                fontFamily: 'var(--font-mono)',
                fontSize: '0.65rem',
                color: 'var(--gray-400)',
                lineHeight: 1.5,
                display: 'block',
                whiteSpace: 'pre-wrap',
                wordBreak: 'break-all',
              }}>
                {JSON.stringify(DEFAULTS[name] || {}, null, 0)}
              </code>
            </div>
          </div>
        ))}
      </div>
    </main>
  );
}
