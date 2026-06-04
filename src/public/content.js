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
  'mathematics': [
    { statement: 'A tunnel centerline runs from coordinates $(100, 200)$ to $(400, 500)$. What is the length of the tunnel in meters?', answer: '424.3 m', eli5: 'Use the distance formula. The horizontal run is 300, the vertical rise is 300. Plug into $d = \\sqrt{300^2 + 300^2} = \\sqrt{180{,}000} = 424.3$ m. Common mistake is adding the components ($300 + 300 = 600$) instead of using the distance formula.' },
    { statement: 'Two lines have slopes $m_1 = 3$ and $m_2 = -\\frac{1}{3}$. Which statement is correct?', answer: 'The lines are perpendicular', eli5: 'Two lines are perpendicular when their slopes are negative reciprocals. Check: $3 \\times (-1/3) = -1$. That confirms they are perpendicular. Parallel lines have equal slopes, and coincident means they are the same line.' },
  ],
  'statistics': [
    { statement: 'A series of concrete cylinder tests yields compressive strengths (psi): 4200, 4350, 4100, 4500, 4250. What is the sample standard deviation?', answer: '152 psi', eli5: 'First find the mean: $(4200+4350+4100+4500+4250)/5 = 4280$. Then compute each deviation squared, sum them, divide by $n-1$ (since it is sample, not population), and take the square root. The answer is about 152 psi. The trap is dividing by $n$ instead of $n-1$.' },
    { statement: 'A dataset has a mean of 50, a median of 45, and a mode of 42. What can be said about the distribution?', answer: 'It is skewed right (positively skewed)', eli5: 'When the mean is greater than the median and the median is greater than the mode, the distribution is skewed right (positively skewed). Think of it as a tail pulling the mean to the right. Left skew would have mean < median < mode.' },
  ],
  'ethics': [
    { statement: 'An engineer discovers that a contractor has substituted lower-grade steel in a bridge project to cut costs. The substitution does not meet the design specifications. What is the engineer\'s primary obligation?', answer: 'Hold the public safety paramount and report to the appropriate authority', eli5: 'The NCEES Model Rules make it crystal clear: the engineer\'s paramount obligation is to protect public health, safety, and welfare. When safety is at stake, you report to the appropriate authority. You do not negotiate, wait, or let cost considerations override safety.' },
    { statement: 'Under the NCEES Model Rules, which of the following is considered "practice of engineering"?', answer: 'Performing engineering analysis and design that affects public safety', eli5: 'The practice of engineering specifically involves applying engineering principles in analysis, design, or consultation that affects public safety. Operating equipment, selling software, and teaching are not "practice of engineering" as defined by the Model Rules, even though they are related to the field.' },
  ],
  'economics': [
    { statement: 'A civil engineering firm sets aside 15,000 dollars in a reserve account earning 8% annual interest. If the money is left untouched, what will it be worth in 5 years?', answer: '22,040 dollars', eli5: 'This is the most basic time-value-of-money problem: you have money now ($P$) and want to know what it grows to ($F$). Use the compound amount factor $(F/P)$. Multiply $15{,}000 \\times (1.08)^5 = 15{,}000 \\times 1.4693 = 22{,}040$. Answer A (21,000) comes from using simple interest ($15{,}000 \\times 0.08 \\times 5 = 6{,}000$, then adding to 15,000 = 21,000). Answer C uses the wrong number of years or the wrong rate. Answer D overshoots, possibly by applying the rate twice somewhere.' },
    { statement: 'A public works department takes out a loan of 200,000 dollars for a new dump truck at 10% annual interest. The loan will be repaid in 8 equal annual payments at the end of each year. What is the annual payment amount?', answer: '37,490 dollars', eli5: 'You have a present amount (the loan) and need to find equal annual payments that pay it off. This is the capital recovery factor $(A/P)$. Look up $(A/P,\\, 10\\%,\\, 8) = 0.18744$ in the 10% table and multiply by 200,000. Answer A (25,000) divides 200,000 by 8 and ignores interest entirely. Answer C might use $(A/F)$ instead of $(A/P)$ — that is for a sinking fund, not a loan. Answer D uses the wrong factor or adds interest on top of the payment.' },
  ],
  'dynamics': [
    { statement: 'A truck accelerates uniformly from $10\\,\\text{m/s}$ to $30\\,\\text{m/s}$ over a distance of $200\\,\\text{m}$. What is the acceleration?', answer: '$2.0\\,\\text{m/s}^2$', eli5: 'You have initial velocity, final velocity, and distance — but no time. That combination screams v-squared equation. Plug in and solve for a. Choice A comes from dividing the velocity difference by the distance (20/200). Choice C comes from squaring velocity difference divided by distance incorrectly.' },
    { statement: 'A projectile is launched from ground level at $40\\,\\text{m/s}$ at $45\\degree$ above the horizontal. What is the total horizontal range? Use $g = 9.81\\,\\text{m/s}^2$.', answer: '$163.1\\,\\text{m}$', eli5: 'For range, you can either use the range formula $R = v_0^2 \\sin(2\\theta) / g$, or work it from first principles: find time of flight from the vertical equation, then multiply by horizontal velocity. At 45 degrees, $\\sin(90°) = 1$, so $R = v_0^2 / g$. Choice B comes from using $v_0 \\sin 45°$ instead of $v_0^2$. Choice D comes from doubling the correct answer — maybe computing total distance incorrectly.' },
  ],
  'mechanics-materials': [
    { statement: 'A steel rod with a cross-sectional area of $500\\,\\text{mm}^2$ and length of $2\\,\\text{m}$ is subjected to a tensile force of $100\\,\\text{kN}$. If $E = 200\\,\\text{GPa}$, what is the elongation?', answer: '2.0 mm', eli5: 'Use $\\delta = PL/(AE)$. $P = 100{,}000$ N, $L = 2{,}000$ mm, $A = 500$ mm$^2$, $E = 200{,}000$ MPa. $\\delta = (100{,}000 \\times 2{,}000)/(500 \\times 200{,}000) = 200{,}000{,}000/100{,}000{,}000 = 2.0$ mm. The main trap is unit confusion -- make sure everything is in consistent units (N, mm, MPa).' },
    { statement: 'A material is loaded beyond its yield point and then unloaded. The unloading path on the stress-strain curve:', answer: 'Is parallel to the initial elastic loading line', eli5: 'When you unload a material from beyond yield, it springs back elastically -- the unloading line has the same slope as the original elastic region (same $E$). But it does not return to zero strain -- there is permanent plastic deformation. The material "remembers" it was stretched. This is why the unloading line is parallel to, not on, the original curve.' },
  ],
  'materials': [
    { statement: 'On a typical engineering stress-strain curve for a ductile metal, which point represents the ultimate tensile strength (UTS)?', answer: 'The maximum stress on the engineering stress-strain curve', eli5: 'The ultimate tensile strength is simply the highest point (peak stress) on the engineering stress-strain curve. After UTS, necking begins and the engineering stress drops even though the true stress keeps increasing. Choice A describes the elastic modulus, not strength. Choice C is the fracture stress, which is lower than UTS on the engineering curve because the cross-section has necked down. Choice D describes the yield strength determined by the offset method.' },
    { statement: 'A steel rod ($E = 200\\,\\text{GPa}$) with an original gauge length of $L_0 = 200\\,\\text{mm}$ is subjected to a tensile stress of $250\\,\\text{MPa}$ within the elastic range. What is the elongation of the rod?', answer: '$0.25\\,\\text{mm}$', eli5: 'Use Hooke\'s law to find strain first, then multiply by gauge length. $\\varepsilon = \\sigma/E = 250/200{,}000 = 0.00125$. Then $\\Delta L = \\varepsilon \\times L_0 = 0.00125 \\times 200 = 0.25$ mm. Choice B (2.5) uses $E = 20$ GPa instead of 200 GPa — off by a factor of 10. Choice C (0.025) uses $L = 20$ mm instead of 200 mm. Choice D (1.25) forgets to convert GPa to MPa and computes $250/200 \\times 200/200$.' },
  ],
  'fluid-mechanics': [
    { statement: 'An oil has a density of $\\rho = 870\\,\\text{kg/m}^3$. What is its specific weight? Use $g = 9.81\\,\\text{m/s}^2$.', answer: '$8{,}535\\,\\text{N/m}^3$', eli5: 'Specific weight is density times gravitational acceleration: $\\gamma = \\rho \\times g = 870 \\times 9.81 = 8{,}534.7$ N/m³. Choice A confuses density with specific weight (forgot to multiply by $g$). Choice C divides by $g$ instead of multiplying. Choice D has the right number but wrong units — specific weight is force per volume (N/m³), not mass per volume.' },
    { statement: 'A plate slides over a $0.5\\,\\text{mm}$ oil film at $1.2\\,\\text{m/s}$. The dynamic viscosity of the oil is $\\mu = 0.04\\,\\text{Pa}\\cdot\\text{s}$. Assuming a linear velocity profile, what is the shear stress on the plate?', answer: '$96\\,\\text{Pa}$', eli5: 'For a linear profile, the velocity gradient is $dv/dy = v/\\delta$. Convert the gap: $0.5$ mm $= 0.0005$ m. Then $dv/dy = 1.2/0.0005 = 2{,}400$ s⁻¹. Shear stress: $\\tau = \\mu \\times dv/dy = 0.04 \\times 2{,}400 = 96$ Pa. Choice B forgets to convert mm to m (uses $\\delta = 0.5$ m). Choice A uses $\\delta = 0.005$ m. Choice D uses $\\delta = 0.00005$ m.' },
  ],
  'surveying': [
    { statement: 'A surveyor measures a bearing of N 45° E from point A to point B, a distance of 200 m. What is the northing (latitude) of point B relative to A?', answer: '141.4 m', eli5: 'The latitude (northing) is the north-south component: distance times cosine of the bearing angle. $\\text{Lat} = 200 \\cos 45° = 200 \\times 0.7071 = 141.4$ m. The departure (easting) would be $200 \\sin 45° = 141.4$ m too, since it is a 45-degree bearing. Common trap is mixing up which trig function gives latitude vs departure.' },
    { statement: 'The bearing S 30° W is equivalent to which azimuth?', answer: '210°', eli5: 'S 30° W means 30 degrees west of due south. Due south is 180° azimuth. Going 30 degrees toward west (clockwise from north) gives $180 + 30 = 210°$. The key is remembering that azimuth is measured clockwise from north (0°/360°).' },
  ],
  'water-resources': [
    { statement: 'Manning\'s equation uses the factor $K = 1.486$ in US Customary units and $K = 1.0$ in SI units. What happens to the computed discharge if an engineer accidentally uses $K = 1.0$ with US Customary inputs?', answer: 'The discharge is underestimated by about 33%', eli5: 'If you use $K = 1.0$ instead of 1.486, you get $Q_{wrong} = Q_{correct}/1.486$, which means your answer is about 67% of the correct value. That is an underestimate of about 33%. This is a classic FE trap because forgetting the conversion factor does not produce an obviously wrong answer. Choice A reverses the direction of the error. Choice C ignores the factor entirely. Choice D confuses the percentage.' },
    { statement: 'A trapezoidal earth channel ($n = 0.022$) has a bottom width of $b = 3\\,\\text{m}$, side slopes of 2H:1V, and a flow depth of $y = 1.5\\,\\text{m}$ on a slope of $S = 0.0004$. What is the discharge?', answer: '$7.8\\,\\text{m}^3/\\text{s}$', eli5: 'For a trapezoid with 2:1 side slopes: $A = (b + zy)y = (3 + 2 \\times 1.5)(1.5) = 6 \\times 1.5 = 9.0$ m$^2$. $P = b + 2y\\sqrt{1 + z^2} = 3 + 2(1.5)\\sqrt{1 + 4} = 3 + 3\\sqrt{5} = 3 + 6.708 = 9.708$ m. $R_H = 9.0/9.708 = 0.927$ m. SI units so $K = 1.0$. $Q = (1/0.022)(9.0)(0.927)^{2/3}(0.0004)^{1/2} = 45.45 \\times 9.0 \\times 0.951 \\times 0.02 = 7.8$ m$^3$/s. Choice A omits the side slopes from the area. Choice B uses $K = 1.486$ (wrong for SI). Choice D uses the bottom width alone for the wetted perimeter.' },
  ],
  'structural': [
    { statement: 'A planar truss has 9 members, 6 joints, and 3 external reactions. Is the truss statically determinate?', answer: 'Yes, it is statically determinate', eli5: 'For a truss: $m + r = 2j$ for determinate. Here: $9 + 3 = 12$, and $2(6) = 12$. Since $m + r = 2j$, the truss is statically determinate. If $m + r > 2j$, it is indeterminate. If $m + r < 2j$, it is unstable.' },
    { statement: 'A structure is externally stable but has $m + r > 2j$. This means the structure is:', answer: 'Statically indeterminate', eli5: 'When $m + r > 2j$, there are more unknowns than equilibrium equations. The structure has redundant members or supports -- it is statically indeterminate. You would need compatibility equations in addition to equilibrium to solve it. The degree of indeterminacy is $(m + r) - 2j$.' },
  ],
  'geotechnical': [
    { statement: 'A soil sample has a void ratio $e = 0.65$ and specific gravity $G_s = 2.70$. What is the porosity $n$?', answer: '$0.394$', eli5: 'Porosity relates to void ratio by $n = e/(1+e) = 0.65/(1+0.65) = 0.65/1.65 = 0.394$. Choice B (0.650) is the void ratio itself, not the porosity. Choice C (0.241) might come from $e/(1+G_s)$. Choice D (0.606) might come from $1/(1+e)$, which is the reciprocal relationship.' },
    { statement: 'A soil sample is tested and found to have a degree of saturation $S = 100\\%$. Which of the following statements is correct?', answer: 'All void space is filled with water, and $e = \\omega G_s$', eli5: 'When $S = 100\\%$, the voids are completely filled with water (no air phase). The master relationship $Se = \\omega G_s$ simplifies to $e = \\omega G_s$. Choice A is backwards -- full saturation means all voids have water, not that the soil is completely dry. Choice C is wrong because $e$ depends on the soil structure, not saturation alone. Choice D mixes up the formula -- $\\omega = e/G_s$ at full saturation, not $\\omega = G_s$.' },
  ],
  'transportation': [
    { statement: 'A designer is computing SSD for a road with a $6\\%$ upgrade. Compared to a level road at the same design speed, what happens to the SSD?', answer: 'SSD decreases because gravity assists braking on an uphill grade', eli5: 'On an uphill grade, gravity pulls the vehicle backward, helping the brakes slow it down. In the formula, a positive $G$ makes the denominator $30(a/32.2 + G)$ larger, which makes the braking distance fraction smaller. The reaction distance is unchanged (grade does not affect perception-reaction time), but the braking distance is shorter. Choice A reverses the effect of uphill. Choice C ignores the grade term entirely. Choice D wrongly claims grade affects reaction time.' },
    { statement: 'When computing the minimum length of a sag vertical curve, the headlight criterion is used instead of the driver eye height criterion used for crest curves. Why?', answer: 'On a sag curve at night, the line of sight is not blocked by the road surface -- the limiting factor is how far the headlights illuminate the road ahead', eli5: 'On a crest curve, the road surface itself blocks the driver from seeing objects beyond the hill -- so the sight distance depends on eye height and object height. On a sag curve, you can see over the valley during the day with no obstruction. But at night, you can only see as far as your headlights illuminate. The headlight beam angle (about 1 degree upward) and the mounting height determine how far down the sag the beam reaches. Choice A is wrong because sag curves are not always shorter. Choice C is incomplete -- it only addresses daytime. Choice D is wrong because the nighttime case governs the design.' },
  ],
  'construction': [
    { statement: 'In a CPM network using Activity-on-Node (AON) notation, what do the arrows between boxes represent?', answer: 'Dependency relationships between activities', eli5: 'In AON notation, the boxes (nodes) represent activities. The arrows between boxes show logical dependencies — which activity must come before another. This is the opposite of Activity-on-Arrow (AOA), where the arrows represent the activities themselves. Resource assignments and durations are shown inside the nodes, not on the arrows.' },
    { statement: 'Activity B has a Start-to-Start (SS) relationship with Activity A. Activity A starts on day 4. Activity B has a duration of 6 days. Which statement is correct?', answer: 'B can start no earlier than day 4 (when A starts)', eli5: 'Start-to-Start means B cannot start until A starts. Since A starts on day 4, B can start no earlier than day 4. SS does not mean they finish together (that would be Finish-to-Finish). It does not mean B waits for A to finish (that would be Finish-to-Start). And SS has nothing to do with matching durations — B can be longer or shorter than A.' },
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
    icon: meta.icon,
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
