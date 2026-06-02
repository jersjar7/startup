import stoppingSightDistance from './stopping-sight-distance';
import verticalCurves from './vertical-curves';
import horizontalCurves from './horizontal-curves';
import signalTiming from './signal-timing';
import trafficFlow from './traffic-flow';
import capacityLos from './capacity-los';
import pavementDesign from './pavement-design';
import earthwork from './earthwork';
import travelDemand from './travel-demand';
import rigidPavement from './rigid-pavement';
import trafficControlDevices from './traffic-control-devices';

export default [
  {
    subtopicId: 'geometric-design',
    lessons: [stoppingSightDistance, verticalCurves, horizontalCurves],
  },
  {
    subtopicId: 'traffic-engineering',
    lessons: [signalTiming, trafficFlow, capacityLos],
  },
  {
    subtopicId: 'planning-operations',
    lessons: [travelDemand, trafficControlDevices],
  },
  {
    subtopicId: 'pavement-earthwork',
    lessons: [pavementDesign, earthwork, rigidPavement],
  },
];
