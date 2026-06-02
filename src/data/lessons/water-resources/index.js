import openChannelFlow from './open-channel-flow';
import energyCriticalFlow from './energy-critical-flow';
import pipeSystemsWeirs from './pipe-systems-weirs';
import rainfallRunoff from './rainfall-runoff';
import hydrographWatershed from './hydrograph-watershed';
import groundwaterWells from './groundwater-wells';
import pumpsWaterDistribution from './pumps-water-distribution';
import waterQuality from './water-quality';
import waterTreatment from './water-treatment';
import drinkingWaterTreatment from './drinking-water-treatment';
import waterQualityStandards from './water-quality-standards';

export default [
  { subtopicId: 'hydraulics', lessons: [openChannelFlow, energyCriticalFlow, pipeSystemsWeirs, pumpsWaterDistribution] },
  { subtopicId: 'hydrology-groundwater', lessons: [rainfallRunoff, hydrographWatershed, groundwaterWells] },
  { subtopicId: 'water-quality-treatment', lessons: [waterQuality, waterTreatment, drinkingWaterTreatment, waterQualityStandards] },
];
