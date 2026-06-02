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
  SSBeamUDL: { span: 8, w: 5 },
  SSBeamCombined: { span: 6, P: 24, w: 4 },
  IBeamSection: { depth: 300, flangeW: 150, flangeT: 20, webT: 10 },
  StressElement: { sigmaX: 60, sigmaY: 0, tauXY: 40 },
  ColumnSupports: { length: 4, topCondition: 'pin', bottomCondition: 'pin' },
  RoadGrade: { run: 300, rise: 6 },
  TwoPointElevation: { dist: 30, angleA: 25, angleB: 42 },
  ForceComponents: { force: 12, angle: 40, unit: 'kN' },
  BeamInflection: { length: 12 },
  MomentVector3D: { rx: 3, ry: 4, fz: -50 },
  TrianglePlotVectors: { ux: 4, uy: 0, vx: 2, vy: 3 },
  NormalDistCurve: { mean: 4500, sd: 300, threshold: 4000 },
  RegressionResidual: { residual: -1.8 },
  SkewnessChart: { mean: 50, median: 45, mode: 42 },
  HypothesisRegion: { alpha: 0.05, tCrit: 1.753, tStat: 2.4 },
  SinkingFundCFD: { n: 10, F: 500000, rate: 6 },
  GradientCashFlow: { base: 10000, gradient: 2000, n: 10, rate: 8 },
  AnnualWorthComparison: { costX: 30000, omX: 8000, salvX: 4000, nX: 6, labelX: 'Pump X', costY: 50000, omY: 5000, salvY: 8000, nY: 12, labelY: 'Pump Y', rate: 10 },
  CrateCablePull: { mass: 60, tension: 400, angle: 30 },
  StackedBlocks: { massTop: 4, massBot: 12 },
  BlockSpringCompress: { mass: 4, velocity: 6, stiffness: 800 },
  HorizontalThrow: { height: 45, velocity: 12 },
  CollisionDiagram: { massA: 3, massB: 5, velA: 10, velB: -4 },
  ThermalBar: { length: 1.0, lengthUnit: 'm', gap: 0 },
  SSBeamTwoLoads: { span: 8, pos1: 2, load1: 20, pos2: 6, load2: 40 },
  CompositeBar: { label1: 'Steel', length1: 600, label2: 'Aluminum', length2: 900, lengthUnit: 'mm', force: 50, forceUnit: 'kN' },
  UtubeManometer: { h: 250, unit: 'mm' },
  SubmergedGate: { width: 2, height: 3, topDepth: 0, unit: 'm' },
  PipeBend: { angle: 90, diameter: 0.3, velocity: 4, pressure: 200 },
  SlopeDistance: { sd: 250, angle: 8, unit: 'm' },
  LevelingSetup: { setups: 1, bmLabel: 'BM', targetLabel: 'A' },
  HorizontalCurve: { R: 1000, I: 40 },
  VerticalCurveProfile: { g1: 4, g2: -2, L: 600, elevPVC: 100 },
  BaselineOffsets: { offsets: [0, 8, 12, 10, 0], spacing: 20, unit: 'm' },
  CoordinatePolygon: { vertices: [{ x: 0, y: 0, label: 'A' }, { x: 6, y: 0, label: 'B' }, { x: 3, y: 4, label: 'C' }] },
  RectangularChannel: { b: 4, y: 2, unit: 'ft' },
  TrapezoidalChannel: { b: 3, y: 1.5, z: 2, unit: 'm' },
  HydraulicJump: { y1: 0.4, Fr1: 3.0 },
  RectangularWeir: { L: 5, H: 1.5, unit: 'ft', contracted: false },
  VNotchWeir: { H: 2.0, angle: 90, unit: 'ft' },
  UnconfinedWell: { h1: 40, h2: 60, r1: 0.5, r2: 200, unit: 'ft' },
  ConfinedWell: { h1: 25, h2: 30, b: 20, r1: 10, r2: 100, unit: 'm' },
  InfluenceLineSS: { type: 'moment', L: 30, a: 15, unit: 'ft' },
  RCBeamSection: { b: 12, d: 18, numBars: 3, unit: 'in.' },
  RCColumnSection: { w: 16, h: 16, numBars: 8, shape: 'square', unit: 'in.' },
  TensionPlateNet: { width: 10, thickness: 0.5, numBolts: 2, boltDia: 0.875, unit: 'in.' },
  LTBCurve: { Mp: 500, Mr: 300, Lp: 8, Lr: 25, Lb: 15, unit: 'ft' },
  TrussSchematic: { variant: 'warren7', leftSupport: 'pin', rightSupport: 'roller' },
  FrameSchematic: { variant: 'portal', leftSupport: 'pin', rightSupport: 'fixed' },
  SoilProfile: { layers: [{ name: 'Dry Sand', h: 5, gamma: 110, saturated: false }, { name: 'Sat. Clay', h: 8, gamma: 120, saturated: true }], wtDepth: 5, depthUnit: 'ft', weightUnit: 'pcf' },
  RetainingWall: { height: 15, unit: 'ft' },
  FootingSection: { width: 4, depth: 3, unit: 'ft' },
  WallBase: { baseWidth: 8, resultantPos: 3.0, unit: 'ft' },
  ConsolidationLayer: { thickness: 20, topPermeable: true, bottomPermeable: false, topLabel: 'Sand', bottomLabel: 'Rock', unit: 'ft' },
  PavementStack: { surface: { a: 0.44, D: 3, label: 'HMA Surface' }, base: { a: 0.14, D: 8, m: 1.0, label: 'Crushed Stone Base' }, subbase: { a: 0.11, D: 10, m: 1.0, label: 'Granular Subbase' } },
  EarthworkSection: { A1: 200, A2: 300, Am: 240, L: 100 },
  CpmNetwork: { variant: 'fiveActivity', durations: { A: 3, B: 4, C: 2, D: 6, E: 3 } },
  CantileverEndLoad: { length: 3, load: 10, unit: 'kN' },
  ProppedCantilever: { length: 8, w: 12, unit: 'kN/m' },
  FixedFixedBeam: { span: 6, w: 10, unit: 'kN/m' },
  TrussJointFBD: { load: 500, angle: 45, unit: 'lb' },
  ProctorCurve: {},
  PileCapacity: {},
  InfiniteSlope: { beta: 25 },
  SlopeWedge: { alpha: 25 },
  FlowNet: {},
  PumpSystem: {},
  FilterBed: {},
  SignShapes: {},
  GravityModelZones: {},
  RigidPavementJoint: {},
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
  SSBeamUDL: 'MoM L4 Shear/Moment — Q2',
  SSBeamCombined: 'MoM L6 Deflections — Q3',
  IBeamSection: 'MoM L5 Bending/Shear — Q3',
  StressElement: 'MoM L7 Mohr\'s Circle — Q1-Q3',
  ColumnSupports: 'MoM L8 Buckling — Q1-Q3',
  RoadGrade: 'Math — Straight Lines Q1',
  TwoPointElevation: 'Math — Right Triangle Trig Q3',
  ForceComponents: 'Math — Right Triangle Trig Q2',
  BeamInflection: 'Math — Applications Deriv Q3',
  MomentVector3D: 'Math — Cross Product Q2',
  TrianglePlotVectors: 'Math — Cross Product Q3',
  NormalDistCurve: 'Stat — Distributions Q3',
  RegressionResidual: 'Stat — Regression Ex4',
  SkewnessChart: 'Stat — Central Tendency Ex2',
  HypothesisRegion: 'Stat — Hypothesis Test Q2',
  SinkingFundCFD: 'Econ — Equivalence Q1',
  GradientCashFlow: 'Econ — Equivalence Q3',
  AnnualWorthComparison: 'Econ — PW/FW/AW Q3',
  CrateCablePull: 'Dyn L3 Force & Accel — Ex3',
  StackedBlocks: 'Dyn L3 Force & Accel — Ex4',
  BlockSpringCompress: 'Dyn L4 Work Energy — Ex4',
  HorizontalThrow: 'Dyn L1 Particle Kin — Ex4',
  CollisionDiagram: 'Dyn L5 Impulse — Ex2/Ex3',
  ThermalBar: 'MoM L1 Axial — Q3/Ex4',
  SSBeamTwoLoads: 'MoM L4 Shear/Moment — Ex3',
  CompositeBar: 'MoM L1 Axial — Ex3',
  UtubeManometer: 'Fluids L2 Hydrostatic — Q3/Ex3',
  SubmergedGate: 'Fluids L3 Forces — Q1/Q2/Ex2',
  PipeBend: 'Fluids L6 Momentum — Q2/Ex2',
  SlopeDistance: 'Surv L1 Angles — Q2/Ex3',
  LevelingSetup: 'Surv L2 Leveling — Q1/Q2/Ex1/Ex2',
  HorizontalCurve: 'Surv L6 Horiz Curves — Q2/Q3/Ex1-Ex4',
  VerticalCurveProfile: 'Surv L7 Vert Curves — Q1-Q3/Ex1-Ex2',
  BaselineOffsets: 'Surv L4 Area — Q3/Ex2/Ex3',
  CoordinatePolygon: 'Surv L4 Area — Q1/Q2/Ex1',
  RectangularChannel: 'WR L1 OCF — Q1/Ex4',
  TrapezoidalChannel: 'WR L1 OCF — Ex2',
  HydraulicJump: 'WR L2 Energy — Q3/Ex3',
  RectangularWeir: 'WR L3 Weirs — Q1/Ex2',
  VNotchWeir: 'WR L3 Weirs — Q2',
  UnconfinedWell: 'WR L4 Groundwater — Q2',
  ConfinedWell: 'WR L4 Groundwater — Q3/Ex2',
  InfluenceLineSS: 'Str L2 Influence Lines — Q1-Q3/Ex1-Ex4',
  RCBeamSection: 'Str L3 RC Flexure — Q1/Ex1/Ex2',
  RCColumnSection: 'Str L4 RC Columns — Q1-Q3/Ex1/Ex3',
  TensionPlateNet: 'Str L8 Tension — Q2/Q3/Ex1/Ex3',
  LTBCurve: 'Str L6 Steel Beams — Q3/Ex4',
  TrussSchematic: 'Str L1 Determinacy — Q1/Q3/Ex1',
  FrameSchematic: 'Str L1 Determinacy — Q2/Ex3',
  SoilProfile: 'Geo L2 Effective Stress — Q2/Q3/Ex4',
  RetainingWall: 'Geo L3 Lateral Pressure — Q2/Q3/Ex2',
  FootingSection: 'Geo L4 Bearing Capacity — Q2/Q3/Ex1/Ex4',
  WallBase: 'Geo L5 Retaining Walls — Q2/Q3/Ex3',
  ConsolidationLayer: 'Geo L6 Consolidation — Ex2',
  PavementStack: 'Trans L7 Pavement — Q1/Ex1',
  EarthworkSection: 'Trans L8 Earthwork — Q1-Q3/Ex1/Ex3',
  CpmNetwork: 'Const L3 Fwd/Bwd — Q1-Q3/Ex3, L5 Float Q3, L1 CPM Q3',
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
