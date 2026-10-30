// The formula finder's data: every formula on the 15 topic pages, joined to
// its plain-language guide (what each symbol means, when to use it). The
// guides live in data/formula-guide/<chapter>.js, in the same order as the
// chapter's formulas, and each repeats the label so a drift is caught.
import { allTopics } from './content';
import mathematics from '../data/formula-guide/mathematics.js';
import statistics from '../data/formula-guide/statistics.js';
import ethics from '../data/formula-guide/ethics.js';
import economics from '../data/formula-guide/economics.js';
import statics from '../data/formula-guide/statics.js';
import dynamics from '../data/formula-guide/dynamics.js';
import mechanicsMaterials from '../data/formula-guide/mechanics-materials.js';
import materials from '../data/formula-guide/materials.js';
import fluidMechanics from '../data/formula-guide/fluid-mechanics.js';
import surveying from '../data/formula-guide/surveying.js';
import waterResources from '../data/formula-guide/water-resources.js';
import structural from '../data/formula-guide/structural.js';
import geotechnical from '../data/formula-guide/geotechnical.js';
import transportation from '../data/formula-guide/transportation.js';
import construction from '../data/formula-guide/construction.js';

export const GUIDES = {
  mathematics, statistics, ethics, economics, statics, dynamics,
  'mechanics-materials': mechanicsMaterials, materials,
  'fluid-mechanics': fluidMechanics, surveying, 'water-resources': waterResources,
  structural, geotechnical, transportation, construction,
};

export function slug(s) {
  return String(s).toLowerCase().replace(/['’]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

// Lowercase, no apostrophes, so "Manning's" and "mannings" find each other.
function norm(s) {
  return String(s || '').toLowerCase().replace(/['’]/g, '');
}

export function allFormulas() {
  const seen = new Set();
  return allTopics().flatMap((t) => t.formulas.map((f, i) => {
    const g = GUIDES[t.id]?.[i];
    const guide = g && g.label === f.label ? g : null;
    let id = `${t.id}-${slug(f.label)}`;
    if (seen.has(id)) id = `${id}-${i + 1}`;
    seen.add(id);
    return {
      id,
      chapterId: t.id,
      chapterName: t.name,
      accent: t.accent,
      latex: f.latex,
      label: f.label,
      page: f.page || '',
      inHandbook: f.inHandbook !== false,
      aliases: guide?.aliases || [],
      use: guide?.use || '',
      symbols: guide?.symbols || [],
      trap: guide?.trap || '',
    };
  }));
}

// Every word typed must appear somewhere: the name, the chapter, a search
// alias, or what one of its symbols means.
export function matches(f, query) {
  const words = norm(query).split(/\s+/).filter(Boolean);
  if (words.length === 0) return true;
  const hay = norm([f.label, f.chapterName, f.use, ...f.aliases, ...f.symbols.map((s) => s.means)].join(' '));
  return words.every((w) => hay.includes(w));
}
