// Chapter test bank: materials, version A. See docs/CHAPTER-TESTS.md.

const PROBLEMS = [
  // 01 · Mix design · hard · moisture correction with one wet and one dry aggregate
  {
    id: 'ct-materials-a-01',
    chapterId: 'materials',
    version: 'A',
    topic: 'Mix design of concrete and asphalt',
    type: 'computational',
    difficulty: 'hard',
    statement: 'A ready-mix plant batches the culvert headwall mix in the table on a saturated-surface-dry (SSD) basis. On the day of the pour the coarse aggregate stockpile is wet, but the fine aggregate stockpile is drier than SSD. The weight of water (lb) to add at the mixer per cubic yard is most nearly:',
    choices: [
      { id: 'c1', text: '237' },
      { id: 'c2', text: '245' },
      { id: 'c3', text: '269' },
      { id: 'c4', text: '301' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Subtracts the full stockpile moisture of both aggregates (2.4% and 0.5%) as free water, ignoring that part of it is absorbed and that the sand is below its absorption.',
      'Treats the dry sand like the wet gravel and subtracts its 12 lb as well, when the sand actually takes 12 lb out of the mix water.',
      'Correct: the coarse aggregate brings about 28 lb of free water (subtract) and the dry sand soaks up about 12 lb (add back): 285 - 28 + 12 = 269 lb.',
      'Adds the coarse aggregate\'s free water instead of subtracting it, and subtracts the sand\'s deficit instead of adding it: the signs are reversed.',
    ],
    eli5: 'The recipe assumes every stone is exactly "damp inside, dry on the surface". Today the gravel is dripping, so it carries extra water into the mixer and you pour less from the hose. The sand is thirsty, so it will drink some of the hose water and you must pour a little more to make up for it.',
    hint: 'For each aggregate the free water is its oven-dry weight times (moisture minus absorption). A negative value means the aggregate takes water from the mix.',
    steps: [
      { text: 'Oven-dry weight of each aggregate from its SSD weight.', latex: 'W_{OD,c} = \\dfrac{1{,}780}{1.008} = 1{,}765.9\\text{ lb}, \\quad W_{OD,f} = \\dfrac{1{,}240}{1.015} = 1{,}221.7\\text{ lb}' },
      { text: 'Free water carried by the coarse aggregate (moisture above absorption).', latex: '1{,}765.9\\,(0.024 - 0.008) = +28.3\\text{ lb}' },
      { text: 'Free water of the fine aggregate. It is below its absorption, so the value is negative: the sand absorbs water from the mix.', latex: '1{,}221.7\\,(0.005 - 0.015) = -12.2\\text{ lb}' },
      { text: 'Water to add at the mixer is the SSD design water minus the free water brought in by the aggregates.', latex: 'W_{add} = 285 - 28.3 - (-12.2) = 268.9 \\approx 269\\text{ lb}' },
    ],
    handbookPage: null,
    handbookFormula: 'W_{free} = W_{OD}\\,(MC - \\text{absorption}),\\quad W_{add} = W_{SSD\\,design} - \\sum W_{free}',
    traps: [
      'Using the total moisture content instead of moisture minus absorption: only the water above SSD is free to join the mix.',
      'Assuming every aggregate correction is subtracted. An aggregate drier than SSD needs extra water, so its correction is added.',
      'Mixing up the bases: absorption and moisture are percentages of the oven-dry weight, not of the SSD weight.',
    ],
    diagram: {
      component: 'CtMaterialsABatchTable',
      props: {
        cement: 600,
        water: 285,
        coarse: { ssd: 1780, absorption: 0.8, moisture: 2.4 },
        fine: { ssd: 1240, absorption: 1.5, moisture: 0.5 },
      },
    },
  },

  // 02 · Mix design · medium · absolute volume to find the sand weight
  {
    id: 'ct-materials-a-02',
    chapterId: 'materials',
    version: 'A',
    topic: 'Mix design of concrete and asphalt',
    type: 'computational',
    difficulty: 'medium',
    statement: 'A sidewalk mix is proportioned by the absolute volume method for 1 yd$^3$. Per cubic yard it has 564 lb of cement (specific gravity 3.15), 282 lb of water, 1,850 lb of SSD coarse aggregate (bulk SSD specific gravity 2.68) and 6% entrained air. The fine aggregate has a bulk SSD specific gravity of 2.62. The SSD weight of fine aggregate (lb) needed to complete the cubic yard is most nearly:',
    choices: [
      { id: 'c1', text: '417' },
      { id: 'c2', text: '1,133' },
      { id: 'c3', text: '1,159' },
      { id: 'c4', text: '1,398' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'Takes the 6% air as 6 ft$^3$ instead of 6% of 27 ft$^3$ (1.62 ft$^3$), which leaves far too little room for sand.',
      'Correct: the other ingredients fill 20.07 ft$^3$, the sand fills the remaining 6.93 ft$^3$, which weighs 6.93 x 2.62 x 62.4 = 1,133 lb.',
      'Finds the right sand volume but converts it to weight with the coarse aggregate\'s specific gravity (2.68) instead of the sand\'s (2.62).',
      'Forgets the entrained air, so the sand is given the 1.62 ft$^3$ that the air bubbles occupy.',
    ],
    eli5: 'A cubic yard is a 27 cubic foot box. Pour in the cement, the water, the gravel and the air bubbles, and measure how much room each one takes. Whatever room is left is for the sand. Then turn that space back into pounds using how heavy the sand is.',
    hint: 'Absolute volume of each ingredient is its weight divided by (specific gravity x 62.4 lb/ft$^3$). Air is a percent of the 27 ft$^3$.',
    steps: [
      { text: 'Absolute volume of cement, water and coarse aggregate.', latex: 'V_c = \\dfrac{564}{3.15(62.4)} = 2.87,\\quad V_w = \\dfrac{282}{62.4} = 4.52,\\quad V_{ca} = \\dfrac{1{,}850}{2.68(62.4)} = 11.06\\text{ ft}^3' },
      { text: 'Volume of entrained air.', latex: 'V_a = 0.06(27) = 1.62\\text{ ft}^3' },
      { text: 'The fine aggregate fills what is left of the cubic yard.', latex: 'V_{fa} = 27 - (2.87 + 4.52 + 11.06 + 1.62) = 6.93\\text{ ft}^3' },
      { text: 'Convert the volume to SSD weight with the sand\'s own specific gravity.', latex: 'W_{fa} = 6.93(2.62)(62.4) \\approx 1{,}133\\text{ lb}' },
    ],
    handbookPage: null,
    handbookFormula: 'V = \\dfrac{W}{SG\\,\\gamma_w},\\quad V_{fa} = 27 - \\sum V_{others}',
    traps: [
      'Leaving out the air: on an air-entrained mix it is a real share of the yard.',
      'Using the wrong specific gravity when converting the sand volume back to weight.',
      'Forgetting the 62.4 lb/ft$^3$ unit weight of water when dividing by specific gravity.',
    ],
    diagram: null,
  },

  // 03 · Mix design (asphalt) · medium · VFA from Gmb, Gmm, Gsb, Pb
  {
    id: 'ct-materials-a-03',
    chapterId: 'materials',
    version: 'A',
    topic: 'Mix design of concrete and asphalt',
    type: 'computational',
    difficulty: 'medium',
    statement: 'A Superpave trial specimen for a county road overlay has bulk specific gravity $G_{mb} = 2.352$ and maximum specific gravity $G_{mm} = 2.461$. The binder content is 5.2% by total weight of mix, and the aggregate bulk specific gravity is $G_{sb} = 2.665$. The voids filled with asphalt, VFA (%), is most nearly:',
    choices: [
      { id: 'c1', text: '11.9' },
      { id: 'c2', text: '27.1' },
      { id: 'c3', text: '62.3' },
      { id: 'c4', text: '72.9' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'Stops at VMA minus air voids (16.3 - 4.4 = 11.9%), which is the volume of effective binder, not the share of the VMA it fills.',
      'Inverts the ratio: air voids divided by VMA is the share of the VMA that is still empty.',
      'Computes VMA without the aggregate fraction $P_s$, getting 11.7% instead of 16.3%.',
      'Correct: $V_a$ = 4.43%, VMA = 16.33%, VFA = (16.33 - 4.43)/16.33 = 72.9%.',
    ],
    eli5: 'Picture the gaps between the stones in the compacted mix (VMA). Some of that gap space is filled with asphalt and the rest is air. VFA asks: of all the gap space, what share is asphalt? Find the total gaps, take away the air, and divide by the total gaps.',
    hint: 'Find the air voids from $G_{mb}$ and $G_{mm}$, the VMA from $G_{mb}$, $P_s$ and $G_{sb}$, then VFA = (VMA - $V_a$)/VMA.',
    steps: [
      { text: 'Air voids.', latex: 'V_a = 100\\left(1 - \\dfrac{G_{mb}}{G_{mm}}\\right) = 100\\left(1 - \\dfrac{2.352}{2.461}\\right) = 4.43\\%' },
      { text: 'Aggregate share of the mix is $P_s = 100 - 5.2 = 94.8\\%$. Voids in the mineral aggregate:', latex: 'VMA = 100 - \\dfrac{G_{mb}P_s}{G_{sb}} = 100 - \\dfrac{2.352(94.8)}{2.665} = 16.33\\%' },
      { text: 'Voids filled with asphalt.', latex: 'VFA = 100\\,\\dfrac{VMA - V_a}{VMA} = 100\\,\\dfrac{16.33 - 4.43}{16.33} = 72.9\\%' },
    ],
    handbookPage: null,
    handbookFormula: 'V_a = 100(1 - G_{mb}/G_{mm}),\\ VMA = 100 - G_{mb}P_s/G_{sb},\\ VFA = 100(VMA - V_a)/VMA',
    traps: [
      'Leaving $P_s$ out of the VMA formula: VMA is based on the aggregate share of the mix, not the whole mix.',
      'Confusing VMA, VFA and air voids: VFA is a share of VMA, not of the total volume.',
      'Using the binder content (5.2) where the aggregate content (94.8) belongs.',
    ],
    diagram: null,
  },

  // 04 · Test methods · easy · which test measures aggregate degradation
  {
    id: 'ct-materials-a-04',
    chapterId: 'materials',
    version: 'A',
    topic: 'Test methods and specifications',
    type: 'conceptual',
    difficulty: 'easy',
    statement: 'A quarry wants to sell crushed limestone as base course for a haul road. The specification limits how much the coarse aggregate may break down and wear when tumbled with steel spheres in a rotating drum. The test that measures this is the:',
    choices: [
      { id: 'c1', text: 'Los Angeles abrasion test' },
      { id: 'c2', text: 'Marshall stability test' },
      { id: 'c3', text: 'sand equivalent test' },
      { id: 'c4', text: 'Charpy V-notch test' },
    ],
    correctAnswerId: 'c1',
    choiceNotes: [
      'Correct: the Los Angeles test tumbles the aggregate with steel spheres and reports the percent of mass lost through a No. 12 sieve as a measure of toughness and abrasion resistance.',
      'Marshall stability is a load test on a compacted asphalt specimen, not on loose aggregate.',
      'The sand equivalent test measures the clay and fine dust in fine aggregate, not resistance to wear.',
      'Charpy measures the impact energy of a notched metal bar, mainly to find the ductile-to-brittle transition of steel.',
    ],
    eli5: 'Put the stones in a big drum with steel balls and spin it. Weak stones chip and turn to dust, strong ones stay whole. Weigh the dust: less dust means tougher rock.',
    hint: 'Which test uses a rotating drum and steel spheres?',
    steps: [
      { text: 'Resistance of coarse aggregate to impact and abrasion is measured by tumbling a graded sample with steel spheres in a rotating drum for a set number of revolutions.' },
      { text: 'The result is the percent loss: the mass that passes the No. 12 sieve afterwards divided by the original mass. That is the Los Angeles abrasion test.' },
    ],
    handbookPage: null,
    handbookFormula: '\\text{LA loss} = 100\\,\\dfrac{W_{original} - W_{retained\\,No.12}}{W_{original}}',
    traps: [
      'Picking a test that sounds like toughness but applies to a different material (Charpy for metals, Marshall for compacted asphalt).',
    ],
    diagram: null,
  },

  // 05 · Test methods · easy · what a rebound hammer can and cannot tell you
  {
    id: 'ct-materials-a-05',
    chapterId: 'materials',
    version: 'A',
    topic: 'Test methods and specifications',
    type: 'conceptual',
    difficulty: 'easy',
    statement: 'An engineer uses a rebound (Schmidt) hammer on the slabs of an older parking garage. Which statement about the readings is most appropriate?',
    choices: [
      { id: 'c1', text: 'They indicate surface hardness and need a core correlation to estimate strength.' },
      { id: 'c2', text: 'They give the in-place compressive strength directly, so no cores need drilling.' },
      { id: 'c3', text: 'They locate the reinforcing bars and measure the depth of concrete cover.' },
      { id: 'c4', text: 'They detect voids and cracks deep inside the slab from the time of travel of a pulse.' },
    ],
    correctAnswerId: 'c1',
    choiceNotes: [
      'Correct: the rebound number depends on the hardness of the top inch or so of concrete; it is good for finding weak or uneven areas, and it estimates strength only through a correlation with cores from the same concrete.',
      'The rebound number is affected by surface carbonation, moisture, finish and aggregate, so it cannot replace cores for strength.',
      'That is a cover meter (an electromagnetic device), not a rebound hammer.',
      'That is ultrasonic pulse velocity, which times a sound wave through the member.',
    ],
    eli5: 'The hammer bounces a spring-loaded plunger off the slab and measures how far it bounces back. A hard surface gives a big bounce. It only feels the skin of the slab, so it is great for saying "this area is softer than that one", but to turn bounces into psi you need to crush a few drilled cores and compare.',
    hint: 'The hammer only touches the surface.',
    steps: [
      { text: 'The rebound hammer measures the rebound of a spring-driven mass off the surface, which depends on the hardness of the near-surface concrete.' },
      { text: 'Surface conditions (carbonation, moisture, finish) change the reading, so the hammer is used to compare uniformity; strength estimates need a correlation with cores from the same structure.' },
    ],
    handbookPage: null,
    handbookFormula: '\\text{Rebound number} \\to \\text{surface hardness (correlate with cores for } f\'_c)',
    traps: [
      'Reading the hammer\'s strength chart as the in-place strength of the slab.',
      'Mixing up the nondestructive tests: rebound hammer (surface hardness), cover meter (rebar), pulse velocity (internal flaws).',
    ],
    diagram: null,
  },

  // 06 · Properties (metals) · medium · 0.2% offset yield from a curve
  {
    id: 'ct-materials-a-06',
    chapterId: 'materials',
    version: 'A',
    topic: 'Physical and mechanical properties',
    type: 'computational',
    difficulty: 'medium',
    statement: 'The figure shows the first part of the engineering stress-strain curve from a tension test on an aluminum alloy used for a pedestrian bridge railing. The yield strength (ksi) by the 0.2% offset method is most nearly:',
    choices: [
      { id: 'c1', text: '20' },
      { id: 'c2', text: '30' },
      { id: 'c3', text: '40' },
      { id: 'c4', text: '44' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Reads the curve at a total strain of 0.002 instead of drawing a line parallel to the elastic part from a strain of 0.002.',
      'The stress where the curve first bends away from a straight line: that is the proportional limit, which is lower than the offset yield strength.',
      'Correct: the elastic slope is 10,000 ksi; a line of that slope through a strain of 0.002 meets the curve at a strain of 0.006 and 40 ksi.',
      'Takes the highest stress shown on the chart, which is past yield and heading toward the tensile strength.',
    ],
    eli5: 'Metals do not have a sharp "now it bends for good" point, so engineers agree on a rule. Slide a copy of the straight starting line 0.002 to the right, and where it hits the curve is the yield strength. It is the stress that leaves the bar 0.2% longer after you let go.',
    hint: 'Find the slope of the straight part, then draw a line with that slope starting at a strain of 0.002 on the axis.',
    steps: [
      { text: 'Elastic slope from the straight part of the curve: 20 ksi at a strain of 0.002.', latex: 'E = \\dfrac{20\\text{ ksi}}{0.002} = 10{,}000\\text{ ksi}' },
      { text: 'Offset line: same slope, starting at a strain of 0.002.', latex: '\\sigma = 10{,}000\\,(\\varepsilon - 0.002)' },
      { text: 'The offset line passes through 20 ksi at 0.004, 30 ksi at 0.005 and 40 ksi at 0.006. The curve also passes through 40 ksi at a strain of 0.006, so they meet there.', latex: '\\sigma_y \\approx 40\\text{ ksi}' },
    ],
    handbookPage: 'p. 121',
    handbookFormula: '\\sigma = E\\varepsilon;\\ \\text{yield strength by the 0.2\\% offset method}',
    traps: [
      'Reading the stress at a total strain of 0.002 instead of drawing the offset line.',
      'Calling the proportional limit the yield strength.',
      'Drawing the offset line from the origin, or with a slope that does not match the elastic part.',
    ],
    diagram: {
      component: 'CtMaterialsAOffsetCurve',
      props: { E: 10000, sy: 40, n: 10, epsMax: 0.010, sMax: 50 },
    },
  },

  // 07 · Properties (concrete) · easy · creep
  {
    id: 'ct-materials-a-07',
    chapterId: 'materials',
    version: 'A',
    topic: 'Physical and mechanical properties',
    type: 'conceptual',
    difficulty: 'easy',
    statement: 'A precast concrete girder carries the same permanent dead load for years. Its strain keeps growing slowly with time even though the load, temperature and humidity around it do not change. This time-dependent deformation under sustained load is called:',
    choices: [
      { id: 'c1', text: 'fatigue' },
      { id: 'c2', text: 'drying shrinkage' },
      { id: 'c3', text: 'creep' },
      { id: 'c4', text: 'relaxation' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Fatigue is damage from repeated (cyclic) loading, not from a load that stays constant.',
      'Drying shrinkage comes from moisture loss and happens with or without load; here the humidity does not change and the strain is caused by the load.',
      'Correct: creep is deformation that keeps increasing with time under a constant sustained stress.',
      'Relaxation is the opposite case: the strain is held constant and the stress drops with time (for example in a prestressing strand).',
    ],
    eli5: 'Lean on a sponge with the same weight all day and it slowly squashes further, even though you are not pushing harder. Concrete does the same thing, very slowly, under its own permanent load. That slow squish is creep.',
    hint: 'Constant load, growing strain.',
    steps: [
      { text: 'The load is constant and the environment is unchanged, so neither cyclic loading nor moisture loss explains the growth.' },
      { text: 'Strain that increases with time at constant stress is creep (the Handbook lists it as time-dependent deformation under load).' },
    ],
    handbookPage: 'p. 121',
    handbookFormula: '\\text{Creep: time-dependent deformation under load}',
    traps: [
      'Confusing creep (constant stress, strain grows) with relaxation (constant strain, stress drops).',
      'Blaming shrinkage, which needs drying and does not need a load.',
    ],
    diagram: null,
  },

  // 08 · Mix design · hard · read w/cm from a chart, split cementitious
  {
    id: 'ct-materials-a-08',
    chapterId: 'materials',
    version: 'A',
    topic: 'Mix design of concrete and asphalt',
    type: 'computational',
    difficulty: 'hard',
    statement: 'A bridge abutment will be exposed to freezing and thawing with deicing salts, so its concrete must be air-entrained and reach an average 28-day strength of 4,500 psi. The supplier\'s trial-batch curves are shown. The mix needs 270 lb of water per cubic yard, and fly ash will make up 15% of the total cementitious materials by weight. The portland cement content (lb/yd$^3$) is most nearly:',
    choices: [
      { id: 'c1', text: '417' },
      { id: 'c2', text: '510' },
      { id: 'c3', text: '600' },
      { id: 'c4', text: '690' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'Reads the non-air-entrained curve (w/cm = 0.55), which overstates the strength this air-entrained mix will reach at a given ratio.',
      'Correct: the air-entrained curve gives w/cm = 0.45, so cementitious = 270/0.45 = 600 lb, of which 85% is cement: 510 lb.',
      'Stops at the total cementitious materials and forgets that 15% of it is fly ash.',
      'Adds 15% to the cementitious content instead of taking 15% of it as fly ash.',
    ],
    eli5: 'Air bubbles protect concrete from freezing but make it a little weaker, so it has to use the air-entrained curve, which needs less water per pound of cement. Read the ratio at 4,500 psi, work out how much "glue" (cement plus fly ash) goes with 270 lb of water, then keep the 85% that is cement.',
    hint: 'Use the curve that matches the exposure, then w/cm = water / (cement + fly ash).',
    steps: [
      { text: 'Freeze-thaw exposure needs air entrainment, so read the air-entrained curve at 4,500 psi.', latex: 'w/cm = 0.45' },
      { text: 'Total cementitious materials from the water content.', latex: 'cm = \\dfrac{270}{0.45} = 600\\text{ lb/yd}^3' },
      { text: 'Fly ash is 15% of the cementitious materials, so portland cement is 85%.', latex: 'c = 0.85(600) = 510\\text{ lb/yd}^3 \\quad (\\text{fly ash} = 90\\text{ lb})' },
    ],
    handbookPage: 'p. 125',
    handbookFormula: 'w/cm = \\dfrac{W_{water}}{W_{cement} + W_{fly\\,ash}}',
    traps: [
      'Reading the non-air-entrained curve for an air-entrained mix.',
      'Stopping at total cementitious materials when the question asks for cement only.',
      'Computing fly ash as 15% of the cement instead of 15% of the total cementitious materials.',
    ],
    diagram: {
      component: 'CtMaterialsAStrengthWc',
      props: {
        air: { fRef: 4500, wRef: 0.45, k: 2.79 },
        nonAir: { fRef: 4500, wRef: 0.55, k: 2.6 },
        wMin: 0.35, wMax: 0.75, fMin: 2000, fMax: 8000,
      },
    },
  },

  // 09 · Properties (aggregates in asphalt) · medium · rutting resistance
  {
    id: 'ct-materials-a-09',
    chapterId: 'materials',
    version: 'A',
    topic: 'Physical and mechanical properties',
    type: 'conceptual',
    difficulty: 'medium',
    statement: 'The hot-mix asphalt surface at a truck weigh station is rutting badly under slow, heavy wheel loads in summer. For the replacement mix, which change is most likely to improve rutting resistance?',
    choices: [
      { id: 'c1', text: 'Raise the binder content above the optimum to make the mix more flexible.' },
      { id: 'c2', text: 'Use a binder with a lower high-temperature performance grade.' },
      { id: 'c3', text: 'Allow more flat and elongated particles in the coarse aggregate.' },
      { id: 'c4', text: 'Replace the rounded river gravel with crushed, angular stone.' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'Extra binder fills the voids, lubricates the stone skeleton and causes bleeding and more rutting.',
      'A lower high-temperature grade is a softer binder at summer temperatures, which ruts more, not less.',
      'Flat and elongated particles break during compaction and under traffic and do not lock together well.',
      'Correct: crushed, angular faces interlock and give the stone skeleton internal friction, which is what resists permanent deformation.',
    ],
    eli5: 'Rutting is the mix slowly sliding out from under heavy tires on a hot day. Round pebbles roll past each other like marbles; broken stone with sharp faces locks together like a pile of bricks. Locked-together stone does not get pushed aside.',
    hint: 'Rutting resistance comes mostly from the stone skeleton, not the binder.',
    steps: [
      { text: 'Rutting is permanent deformation from shear flow of the mix at high temperature under slow, heavy loads.' },
      { text: 'Shear resistance comes from aggregate interlock (internal friction), which angular crushed faces provide; more or softer binder and weak flat particles all reduce it.' },
    ],
    handbookPage: null,
    handbookFormula: '\\text{Rut resistance} \\uparrow \\text{ with aggregate angularity and stiffer binder}',
    traps: [
      'Thinking more binder makes a stronger mix: above optimum it makes the mix unstable.',
      'Reading "lower grade" as stronger: the high-temperature grade must go up for hot, slow traffic.',
    ],
    diagram: null,
  },

  // 10 · Test methods · medium · fineness modulus from individual masses
  {
    id: 'ct-materials-a-10',
    chapterId: 'materials',
    version: 'A',
    topic: 'Test methods and specifications',
    type: 'computational',
    difficulty: 'medium',
    statement: 'A 500 g sample of concrete sand for a bridge deck is sieved, and the table lists the mass caught on each sieve and in the pan. The fineness modulus of the sand is most nearly:',
    choices: [
      { id: 'c1', text: '0.94' },
      { id: 'c2', text: '2.76' },
      { id: 'c3', text: '3.24' },
      { id: 'c4', text: '3.76' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'Adds the individual percents retained instead of the cumulative percents.',
      'Correct: cumulative percents retained are 0, 3, 15, 32, 54, 78 and 94; their sum is 276, and 276/100 = 2.76.',
      'Sums the cumulative percents passing instead of retained.',
      'Includes the pan (100%) in the sum; the pan is not one of the standard sieves.',
    ],
    eli5: 'Count how much sand gets stopped by each sieve, adding up as you go from coarse to fine. Add those running totals as percents and divide by 100. A bigger number means a coarser sand.',
    hint: 'Turn the masses into cumulative percent retained on each sieve from 3/8 in. down to No. 100, leave out the pan, add and divide by 100.',
    steps: [
      { text: 'Cumulative mass retained, from coarse to fine: 0, 15, 75, 160, 270, 390 and 470 g. As a percent of 500 g:', latex: '0,\\ 3,\\ 15,\\ 32,\\ 54,\\ 78,\\ 94\\ \\%' },
      { text: 'Fineness modulus: sum of cumulative percents retained on the standard sieves (pan excluded), divided by 100.', latex: 'FM = \\dfrac{0 + 3 + 15 + 32 + 54 + 78 + 94}{100} = \\dfrac{276}{100} = 2.76' },
    ],
    handbookPage: null,
    handbookFormula: 'FM = \\dfrac{\\sum \\text{cumulative \\% retained (3/8 in. to No. 100)}}{100}',
    traps: [
      'Using the percent retained on each sieve instead of the running (cumulative) total.',
      'Counting the pan as a sieve.',
      'Working with percent passing instead of percent retained.',
    ],
    diagram: {
      component: 'CtMaterialsASieveTable',
      props: {
        sieves: [
          ['3/8 in.', 0], ['No. 4', 15], ['No. 8', 60], ['No. 16', 85],
          ['No. 30', 110], ['No. 50', 120], ['No. 100', 80], ['Pan', 30],
        ],
      },
    },
  },
];

export default PROBLEMS;
