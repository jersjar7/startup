import { RightTriangle } from './RightTriangle';
import { ForceAtAngle } from './ForceAtAngle';
import { CableGeometry } from './CableGeometry';
import { CraneBoom } from './CraneBoom';
import { SimplySupportedBeam } from './SimplySupportedBeam';
import { CantileverBeam } from './CantileverBeam';
import { BeamWithCouple } from './BeamWithCouple';
import { ZeroForceJoint } from './ZeroForceJoint';
import { TriangularTruss } from './TriangularTruss';
import { PrattTruss } from './PrattTruss';
import { BlockFlat } from './BlockFlat';
import { BeltPulley } from './BeltPulley';
import { BlockOnRamp } from './BlockOnRamp';
import { TSection } from './TSection';
import { PlateWithHole } from './PlateWithHole';
import { BuiltUpSection } from './BuiltUpSection';
import { RectangleInertia } from './RectangleInertia';
import { ParallelAxisRect } from './ParallelAxisRect';
import { ProjectileLaunch } from './ProjectileLaunch';
import { CarOnCurve } from './CarOnCurve';
import { CylinderParallelAxis } from './CylinderParallelAxis';
import { BlockOnIncline } from './BlockOnIncline';
import { DiskTangentialForce } from './DiskTangentialForce';
import { RampDrop } from './RampDrop';
import { SpringMass } from './SpringMass';
import { SSBeamUDL } from './SSBeamUDL';
import { SSBeamCombined } from './SSBeamCombined';
import { IBeamSection } from './IBeamSection';
import { StressElement } from './StressElement';
import { ColumnSupports } from './ColumnSupports';
import { RoadGrade } from './RoadGrade';
import { TwoPointElevation } from './TwoPointElevation';
import { ForceComponents } from './ForceComponents';
import { BeamInflection } from './BeamInflection';
import { MomentVector3D } from './MomentVector3D';
import { TrianglePlotVectors } from './TrianglePlotVectors';
import { NormalDistCurve } from './NormalDistCurve';
import { RegressionResidual } from './RegressionResidual';
import { SkewnessChart } from './SkewnessChart';
import { HypothesisRegion } from './HypothesisRegion';
import { SinkingFundCFD } from './SinkingFundCFD';
import { GradientCashFlow } from './GradientCashFlow';
import { AnnualWorthComparison } from './AnnualWorthComparison';
import { CrateCablePull } from './CrateCablePull';
import { StackedBlocks } from './StackedBlocks';
import { BlockSpringCompress } from './BlockSpringCompress';
import { HorizontalThrow } from './HorizontalThrow';
import { CollisionDiagram } from './CollisionDiagram';
import { ThermalBar } from './ThermalBar';
import { SSBeamTwoLoads } from './SSBeamTwoLoads';
import { CompositeBar } from './CompositeBar';
import { UtubeManometer } from './UtubeManometer';
import { SubmergedGate } from './SubmergedGate';
import { PipeBend } from './PipeBend';
import { SlopeDistance } from './SlopeDistance';
import { LevelingSetup } from './LevelingSetup';
import { HorizontalCurve } from './HorizontalCurve';
import { VerticalCurveProfile } from './VerticalCurveProfile';
import { BaselineOffsets } from './BaselineOffsets';
import { CoordinatePolygon } from './CoordinatePolygon';
import { RectangularChannel } from './RectangularChannel';
import { TrapezoidalChannel } from './TrapezoidalChannel';
import { HydraulicJump } from './HydraulicJump';
import { RectangularWeir } from './RectangularWeir';
import { VNotchWeir } from './VNotchWeir';
import { UnconfinedWell } from './UnconfinedWell';
import { ConfinedWell } from './ConfinedWell';
import { InfluenceLineSS } from './InfluenceLineSS';
import { RCBeamSection } from './RCBeamSection';
import { RCColumnSection } from './RCColumnSection';
import { TensionPlateNet } from './TensionPlateNet';
import { LTBCurve } from './LTBCurve';
import { TrussSchematic } from './TrussSchematic';
import { FrameSchematic } from './FrameSchematic';
import { SoilProfile } from './SoilProfile';
import { RetainingWall } from './RetainingWall';
import { FootingSection } from './FootingSection';
import { WallBase } from './WallBase';
import { ConsolidationLayer } from './ConsolidationLayer';
import { PavementStack } from './PavementStack';
import { EarthworkSection } from './EarthworkSection';
import { CpmNetwork } from './CpmNetwork';
import { CantileverEndLoad } from './CantileverEndLoad';
import { ProppedCantilever } from './ProppedCantilever';
import { FixedFixedBeam } from './FixedFixedBeam';
import { TrussJointFBD } from './TrussJointFBD';
import { ProctorCurve } from './ProctorCurve';
import { PileCapacity } from './PileCapacity';
import { InfiniteSlope } from './InfiniteSlope';
import { SlopeWedge } from './SlopeWedge';
import { FlowNet } from './FlowNet';
import { PumpSystem } from './PumpSystem';
import { FilterBed } from './FilterBed';
import { SignShapes } from './SignShapes';
import { GravityModelZones } from './GravityModelZones';
import { RigidPavementJoint } from './RigidPavementJoint';
import { AsphaltVolumetrics } from './AsphaltVolumetrics';
import { SieveStack } from './SieveStack';
import { NewtonTangent } from './NewtonTangent';
import { CompositeSection } from './CompositeSection';
import { CashFlowIRR } from './CashFlowIRR';
import { LeverMachine } from './LeverMachine';
import { CoordinateInverse } from './CoordinateInverse';

export const DIAGRAM_REGISTRY = {
  RightTriangle,
  ForceAtAngle,
  CableGeometry,
  CraneBoom,
  SimplySupportedBeam,
  CantileverBeam,
  BeamWithCouple,
  ZeroForceJoint,
  TriangularTruss,
  PrattTruss,
  BlockFlat,
  BeltPulley,
  BlockOnRamp,
  TSection,
  PlateWithHole,
  BuiltUpSection,
  RectangleInertia,
  ParallelAxisRect,
  ProjectileLaunch,
  CarOnCurve,
  CylinderParallelAxis,
  BlockOnIncline,
  DiskTangentialForce,
  RampDrop,
  SpringMass,
  SSBeamUDL,
  SSBeamCombined,
  IBeamSection,
  StressElement,
  ColumnSupports,
  RoadGrade,
  TwoPointElevation,
  ForceComponents,
  BeamInflection,
  MomentVector3D,
  TrianglePlotVectors,
  NormalDistCurve,
  RegressionResidual,
  SkewnessChart,
  HypothesisRegion,
  SinkingFundCFD,
  GradientCashFlow,
  AnnualWorthComparison,
  CrateCablePull,
  StackedBlocks,
  BlockSpringCompress,
  HorizontalThrow,
  CollisionDiagram,
  ThermalBar,
  SSBeamTwoLoads,
  CompositeBar,
  UtubeManometer,
  SubmergedGate,
  PipeBend,
  SlopeDistance,
  LevelingSetup,
  HorizontalCurve,
  VerticalCurveProfile,
  BaselineOffsets,
  CoordinatePolygon,
  RectangularChannel,
  TrapezoidalChannel,
  HydraulicJump,
  RectangularWeir,
  VNotchWeir,
  UnconfinedWell,
  ConfinedWell,
  InfluenceLineSS,
  RCBeamSection,
  RCColumnSection,
  TensionPlateNet,
  LTBCurve,
  TrussSchematic,
  FrameSchematic,
  SoilProfile,
  RetainingWall,
  FootingSection,
  WallBase,
  ConsolidationLayer,
  PavementStack,
  EarthworkSection,
  CpmNetwork,
  CantileverEndLoad,
  ProppedCantilever,
  FixedFixedBeam,
  TrussJointFBD,
  ProctorCurve,
  PileCapacity,
  InfiniteSlope,
  SlopeWedge,
  FlowNet,
  PumpSystem,
  FilterBed,
  SignShapes,
  GravityModelZones,
  RigidPavementJoint,
  AsphaltVolumetrics,
  SieveStack,
  NewtonTangent,
  CompositeSection,
  CashFlowIRR,
  LeverMachine,
  CoordinateInverse,
};
