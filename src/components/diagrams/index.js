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
};
