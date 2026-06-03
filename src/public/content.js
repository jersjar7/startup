// Content source for the public, crawlable FE Civil pages.
// Everything here is assembled from already-vetted app data (chapter context,
// subtopic applications, handbook-referenced formulas, common traps) — no new
// FE material is authored here. Sample problems are pulled verbatim from the
// question bank.
import { CHAPTERS } from '../data/chapters.js';

import mathematics from '../data/chapters/mathematics.js';
import statistics from '../data/chapters/statistics.js';
import ethics from '../data/chapters/ethics.js';
import economics from '../data/chapters/economics.js';
import statics from '../data/chapters/statics.js';
import dynamics from '../data/chapters/dynamics.js';
import mechanicsMaterials from '../data/chapters/mechanics-materials.js';
import materials from '../data/chapters/materials.js';
import fluidMechanics from '../data/chapters/fluid-mechanics.js';
import surveying from '../data/chapters/surveying.js';
import waterResources from '../data/chapters/water-resources.js';
import structural from '../data/chapters/structural.js';
import geotechnical from '../data/chapters/geotechnical.js';
import transportation from '../data/chapters/transportation.js';
import construction from '../data/chapters/construction.js';

const DETAIL = {
  mathematics, statistics, ethics, economics, statics, dynamics,
  'mechanics-materials': mechanicsMaterials, materials,
  'fluid-mechanics': fluidMechanics, surveying, 'water-resources': waterResources,
  structural, geotechnical, transportation, construction,
};

// Curated, verbatim sample problems (statement + ELI5) per topic. Pulled from
// the question bank. Statics is wired for the exemplar; the rest are filled in
// as the marketing pages roll out.
const SAMPLES = {
  statics: [
    {
      statement: 'A guy wire anchoring a utility pole exerts a 2,600 N force directed along a line that runs 5 m horizontally and 12 m vertically. What is the horizontal component of the force?',
      answer: '1,000 N',
      eli5: 'When a force direction is given by geometry (rise and run), resolve it with that geometry: the hypotenuse is $R=\\sqrt{5^2+12^2}=13$ m, so $F_x=(5/13)\\times 2{,}600 = 1{,}000$ N. This is a 5-12-13 right triangle — a pattern the FE loves to reuse.',
    },
    {
      statement: 'Two forces act at a gusset plate: $F_1 = 300$ N horizontal and $F_2 = 400$ N vertical. What is the magnitude of the resultant?',
      answer: '500 N',
      eli5: 'A 3-4-5 triangle in disguise. $R=\\sqrt{300^2+400^2}=\\sqrt{250{,}000}=500$ N, at $\\theta=\\arctan(400/300)=53.1^\\circ$ above horizontal.',
    },
  ],
};

export const TOPIC_IDS = CHAPTERS.filter((c) => DETAIL[c.id]).map((c) => c.id);

export function getTopic(id) {
  const meta = CHAPTERS.find((c) => c.id === id);
  const detail = DETAIL[id];
  if (!meta || !detail) return null;
  return {
    id,
    name: meta.name,
    num: meta.num,
    questionRange: meta.qs,
    accent: meta.accent,
    context: detail.context || '',
    subtopics: detail.subtopics || [],
    formulas: detail.formulas || [],
    traps: detail.traps || [],
    samples: SAMPLES[id] || [],
  };
}

export function allTopics() {
  return TOPIC_IDS.map(getTopic).filter(Boolean);
}

// Facts for the exam guide. Public, non-proprietary exam logistics.
export const EXAM_FACTS = {
  questions: 110,
  durationLabel: '6 hours total (5 hours 20 minutes of testing)',
  delivery: 'Computer-based (CBT) at Pearson VUE test centers, year-round',
  reference: 'NCEES FE Reference Handbook (searchable PDF provided on-screen)',
  body: 'NCEES',
};
