// Exam bank: surveying
// Auto-extracted from lesson files — 29 questions

const PROBLEMS = [
  {
    id: 'surv-adb-ex1',
    type: 'computational',
    statement: 'A surveyor measures a bearing of N 45° E from point A to point B, a distance of 200 m. What is the northing (latitude) of point B relative to A?',
    choices: [
      {
        id: 'c1',
        text: '100.0 m'
      },
      {
        id: 'c2',
        text: '141.4 m'
      },
      {
        id: 'c3',
        text: '173.2 m'
      },
      {
        id: 'c4',
        text: '200.0 m'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The latitude (northing) is the north-south component: distance times cosine of the bearing angle. $\\text{Lat} = 200 \\cos 45° = 200 \\times 0.7071 = 141.4$ m. The departure (easting) would be $200 \\sin 45° = 141.4$ m too, since it is a 45-degree bearing. Common trap is mixing up which trig function gives latitude vs departure.',
    hint: 'Latitude = distance times cosine of the bearing angle.',
    steps: [
      {
        text: 'For a bearing of N 45\\degree E:',
        latex: null
      },
      {
        text: 'Latitude (northing):',
        latex: '\\Delta N = d \\cos\\theta = 200 \\cos 45\\degree = 200 \\times 0.7071 = 141.4\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\text{Latitude} = d \\cos\\theta',
    videoUrl: null,
    traps: ['Using sine instead of cosine for latitude', 'Confusing bearing angle with azimuth'],
    diagram: null,
    lessonId: 'angles-distances-bearings',
    chapterId: 'surveying'
  },
  {
    id: 'surv-adb-ex2',
    type: 'conceptual',
    statement: 'The bearing S 30° W is equivalent to which azimuth?',
    choices: [
      {
        id: 'c1',
        text: '150°'
      },
      {
        id: 'c2',
        text: '210°'
      },
      {
        id: 'c3',
        text: '240°'
      },
      {
        id: 'c4',
        text: '330°'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'S 30° W means 30 degrees west of due south. Due south is 180° azimuth. Going 30 degrees toward west (clockwise from north) gives $180 + 30 = 210°$. The key is remembering that azimuth is measured clockwise from north (0°/360°).',
    hint: 'Due south is azimuth 180°. Which direction from south is "west"?',
    steps: [
      {
        text: 'S 30\\degree W means 30\\degree west of south.',
        latex: null
      },
      {
        text: 'Due south = 180\\degree azimuth.',
        latex: null
      },
      {
        text: 'West of south adds to the azimuth:',
        latex: '\\text{Azimuth} = 180\\degree + 30\\degree = 210\\degree'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: null,
    videoUrl: null,
    traps: ['Subtracting instead of adding for the SW quadrant', 'Confusing the quadrant directions'],
    diagram: null,
    lessonId: 'angles-distances-bearings',
    chapterId: 'surveying'
  },
  {
    id: 'surv-adb-ex3',
    type: 'computational',
    statement: 'A slope distance of $SD = 185.00 \\text{ ft}$ is measured at a vertical angle of $\\alpha = 12\\degree$ below horizontal. What is the vertical distance (elevation difference)?',
    choices: [
      {
        id: 'c1',
        text: '$38.44 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$-38.44 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$180.91 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$-180.91 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$VD = SD \\sin\\alpha = 185 \\times \\sin 12° = 185 \\times 0.2079 = 38.44$ ft. But the angle is below horizontal, so the elevation difference is negative (you are going downhill). $VD = -38.44$ ft. Choice A has the right magnitude but wrong sign. Choice C is the horizontal distance, not the vertical. Choice D applies the negative to the horizontal distance by mistake.',
    hint: 'Use $VD = SD \\sin\\alpha$ and watch the sign. Below horizontal means the target point is lower.',
    steps: [
      {
        text: 'Apply the vertical distance formula:',
        latex: 'VD = SD \\sin\\alpha = 185.00 \\times \\sin 12\\degree'
      },
      {
        text: 'Compute:',
        latex: 'VD = 185.00 \\times 0.2079 = 38.44 \\text{ ft}'
      },
      {
        text: 'The angle is below horizontal, so the target is lower:',
        latex: 'VD = -38.44 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: 'VD = SD \\sin\\alpha',
    videoUrl: null,
    traps: [
      'Ignoring the sign convention — below horizontal means negative elevation change',
      'Using cosine instead of sine for vertical distance'
    ],
    diagram: {
      component: 'SlopeDistance',
      props: {
        sd: 185,
        angle: 12,
        unit: 'ft',
        below: true
      }
    },
    lessonId: 'angles-distances-bearings',
    chapterId: 'surveying'
  },
  {
    id: 'surv-adb-ex4',
    type: 'computational',
    statement: 'A closed traverse has 6 sides. Five of the interior angles have been measured: $115\\degree$, $128\\degree$, $97\\degree$, $142\\degree$, and $108\\degree$. What must the sixth angle be for the traverse to close geometrically?',
    choices: [
      {
        id: 'c1',
        text: '$120\\degree$'
      },
      {
        id: 'c2',
        text: '$90\\degree$'
      },
      {
        id: 'c3',
        text: '$130\\degree$'
      },
      {
        id: 'c4',
        text: '$150\\degree$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'For a 6-sided polygon, the interior angles must sum to $(6 - 2) \\times 180 = 720°$. The five known angles sum to $115 + 128 + 97 + 142 + 108 = 590°$. The sixth angle $= 720 - 590 = 130°$. Choice A is close but arithmetically wrong. Choice B is a guess. Choice D overshoots because it uses $n \\times 180 = 1080°$ instead of $(n - 2) \\times 180 = 720°$.',
    hint: 'Find the theoretical sum of interior angles for a 6-sided polygon, then subtract the five known angles.',
    steps: [
      {
        text: 'Theoretical sum for a 6-sided polygon:',
        latex: '\\Sigma = (n - 2) \\times 180\\degree = (6 - 2) \\times 180\\degree = 720\\degree'
      },
      {
        text: 'Sum of five known angles:',
        latex: '115 + 128 + 97 + 142 + 108 = 590\\degree'
      },
      {
        text: 'Missing angle:',
        latex: '\\theta_6 = 720 - 590 = 130\\degree'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\Sigma \\text{interior angles} = (n-2) \\times 180\\degree',
    videoUrl: null,
    traps: [
      'Using $n \\times 180$ instead of $(n - 2) \\times 180$ for the theoretical sum',
      'Arithmetic errors when summing five angles quickly'
    ],
    diagram: null,
    lessonId: 'angles-distances-bearings',
    chapterId: 'surveying'
  },
  {
    id: 'surv-lev-ex1',
    type: 'computational',
    statement: 'A benchmark has an elevation of $320.00 \\text{ ft}$. A surveyor sets up a level and reads a backsight of $6.38 \\text{ ft}$ on the benchmark. The foresight on a new point X is $4.17 \\text{ ft}$. What is the elevation of point X?',
    choices: [
      {
        id: 'c1',
        text: '$309.45 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$317.79 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$330.55 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$322.21 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'First find the Height of Instrument: $HI = 320.00 + 6.38 = 326.38$ ft. Then subtract the foresight to get the new elevation: $\\text{Elev}_X = 326.38 - 4.17 = 322.21$ ft. Point X is higher than the benchmark because the FS reading is smaller than the BS reading. Choice A subtracts both. Choice B subtracts the BS instead of adding it. Choice C adds both readings.',
    hint: '$HI$ = known elevation + BS, then new elevation = $HI$ - FS.',
    steps: [
      {
        text: 'Height of Instrument:',
        latex: 'HI = 320.00 + 6.38 = 326.38 \\text{ ft}'
      },
      {
        text: 'Elevation of point X:',
        latex: '\\text{Elev}_X = 326.38 - 4.17 = 322.21 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'HI = \\text{Elev} + BS; \\quad \\text{Elev} = HI - FS',
    videoUrl: null,
    traps: ['Subtracting the backsight instead of adding it to the known elevation'],
    diagram: {
      component: 'LevelingSetup',
      props: {
        setups: 1,
        bmLabel: 'BM',
        targetLabel: 'X'
      }
    },
    lessonId: 'leveling',
    chapterId: 'surveying'
  },
  {
    id: 'surv-lev-ex2',
    type: 'computational',
    statement: 'Starting from BM-A (elevation $450.00 \\text{ ft}$), a level run records: BS = $3.82$ on BM-A, FS = $7.14$ on TP-1, BS = $6.55$ on TP-1, FS = $2.41$ on TP-2, BS = $4.90$ on TP-2, FS = $5.63$ on point C. What is the elevation of point C?',
    choices: [
      {
        id: 'c1',
        text: '$453.32 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$446.68 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$450.09 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$450.82 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Work through each setup. $HI_1 = 450.00 + 3.82 = 453.82$. $\\text{Elev}_{TP1} = 453.82 - 7.14 = 446.68$. $HI_2 = 446.68 + 6.55 = 453.23$. $\\text{Elev}_{TP2} = 453.23 - 2.41 = 450.82$. $HI_3 = 450.82 + 4.90 = 455.72$. $\\text{Elev}_C = 455.72 - 5.63 = 450.09$ ft. A shortcut is sum of BS minus sum of FS plus starting elevation: $(3.82 + 6.55 + 4.90) - (7.14 + 2.41 + 5.63) + 450 = 15.27 - 15.18 + 450 = 450.09$. Choice A reverses BS and FS. Choice B is the TP-1 elevation. Choice D is the TP-2 elevation.',
    hint: 'Process each setup: HI = elev + BS, new elev = HI - FS. Or use the shortcut: final elev = start elev + (sum BS - sum FS).',
    steps: [
      {
        text: 'Setup 1:',
        latex: 'HI_1 = 450.00 + 3.82 = 453.82; \\quad \\text{Elev}_{TP1} = 453.82 - 7.14 = 446.68'
      },
      {
        text: 'Setup 2:',
        latex: 'HI_2 = 446.68 + 6.55 = 453.23; \\quad \\text{Elev}_{TP2} = 453.23 - 2.41 = 450.82'
      },
      {
        text: 'Setup 3:',
        latex: 'HI_3 = 450.82 + 4.90 = 455.72; \\quad \\text{Elev}_C = 455.72 - 5.63 = 450.09 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'HI = \\text{Elev} + BS; \\quad \\text{Elev} = HI - FS',
    videoUrl: null,
    traps: [
      'Stopping at an intermediate turning point and reporting it as the final answer',
      'Carrying forward the wrong HI after a turning point'
    ],
    diagram: {
      component: 'LevelingSetup',
      props: {
        setups: 2,
        bmLabel: 'BM-A',
        targetLabel: 'C',
        tpLabel: 'TP-1'
      }
    },
    lessonId: 'leveling',
    chapterId: 'surveying'
  },
  {
    id: 'surv-lev-ex3',
    type: 'computational',
    statement: 'A level loop has a total distance of $9 \\text{ miles}$. The loop starts and closes on BM-7 (known elevation $812.45 \\text{ ft}$). The computed closing elevation is $812.57 \\text{ ft}$. If the allowable error is $C\\sqrt{M}$ with $C = 0.035 \\text{ ft}$, does the survey meet the tolerance?',
    choices: [
      {
        id: 'c1',
        text: 'Yes -- misclosure ($0.12 \\text{ ft}$) is greater than allowable ($0.105 \\text{ ft}$), so it fails'
      },
      {
        id: 'c2',
        text: 'No -- misclosure ($0.12 \\text{ ft}$) exceeds allowable ($0.105 \\text{ ft}$)'
      },
      {
        id: 'c3',
        text: 'Yes -- misclosure ($0.12 \\text{ ft}$) is less than allowable ($0.315 \\text{ ft}$)'
      },
      {
        id: 'c4',
        text: 'No -- misclosure ($1.20 \\text{ ft}$) exceeds allowable ($0.105 \\text{ ft}$)'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Misclosure $= |812.57 - 812.45| = 0.12$ ft. Allowable $= 0.035 \\times \\sqrt{9} = 0.035 \\times 3.0 = 0.105$ ft. Since $0.12 > 0.105$, the survey does NOT meet the tolerance and must be rerun. Choice A states the correct numbers but draws the wrong conclusion. Choice C uses $C \\times M$ instead of $C \\times \\sqrt{M}$. Choice D misreads the misclosure as 1.20 ft.',
    hint: 'Misclosure = |computed - known|. Allowable $= C\\sqrt{M}$. Compare the two values.',
    steps: [
      {
        text: 'Misclosure:',
        latex: '|812.57 - 812.45| = 0.12 \\text{ ft}'
      },
      {
        text: 'Allowable error:',
        latex: 'C\\sqrt{M} = 0.035\\sqrt{9} = 0.035 \\times 3.0 = 0.105 \\text{ ft}'
      },
      {
        text: 'Compare: $0.12 > 0.105$ -- survey fails tolerance and must be rerun.',
        latex: null
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: '\\text{Allowable} = C\\sqrt{M}',
    videoUrl: null,
    traps: [
      'Multiplying $C$ by $M$ instead of $\\sqrt{M}$',
      'Drawing the wrong pass/fail conclusion after computing correct values'
    ],
    diagram: null,
    lessonId: 'leveling',
    chapterId: 'surveying'
  },
  {
    id: 'surv-lev-ex4',
    type: 'conceptual',
    statement: 'During a differential leveling run, a surveyor moves the instrument to a new position. At the new setup, which rod reading is taken FIRST on the turning point?',
    choices: [
      {
        id: 'c1',
        text: 'A backsight, because the turning point is now a point of known elevation'
      },
      {
        id: 'c2',
        text: 'A foresight, because the turning point is ahead of the instrument'
      },
      {
        id: 'c3',
        text: 'Either reading can be taken first -- the order does not matter'
      },
      {
        id: 'c4',
        text: 'An intermediate sight, because the turning point is between setups'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'A turning point has TWO roles: it receives a foresight from the old instrument setup (which determines its elevation), then it receives a backsight from the new instrument setup (which establishes the new HI). After moving the instrument, the TP already has a known elevation from the previous foresight, so the first reading from the new position is a backsight on the TP. Choice B confuses the physical direction with the surveying definition. Choice C is wrong because order matters -- the FS must come before the instrument moves. Choice D confuses intermediate sights with turning points.',
    hint: 'Think about what "backsight" means: a reading on a point whose elevation is already known.',
    steps: [
      {
        text: 'From the old setup, the surveyor takes a foresight (FS) on the turning point, determining its elevation.',
        latex: null
      },
      {
        text: 'The instrument moves to a new position. The turning point now has a known elevation.',
        latex: null
      },
      {
        text: 'From the new setup, the surveyor reads a backsight (BS) on the turning point to establish the new HI:',
        latex: 'HI_{\\text{new}} = \\text{Elev}_{TP} + BS'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'HI = \\text{Elev} + BS',
    videoUrl: null,
    traps: [
      'Confusing the physical direction of the sight with the surveying definition of BS and FS'
    ],
    diagram: null,
    lessonId: 'leveling',
    chapterId: 'surveying'
  },
  {
    id: 'surv-tc-ex1',
    type: 'computational',
    statement: 'A traverse course has a length of $350 \\text{ m}$ and a bearing of S $55\\degree$ E. What is the departure?',
    choices: [
      {
        id: 'c1',
        text: '$-286.7 \\text{ m}$'
      },
      {
        id: 'c2',
        text: '$286.7 \\text{ m}$'
      },
      {
        id: 'c3',
        text: '$200.8 \\text{ m}$'
      },
      {
        id: 'c4',
        text: '$-200.8 \\text{ m}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Departure $= L \\sin\\theta = 350 \\times \\sin 55° = 350 \\times 0.8192 = 286.7$ m. The bearing is SE, so the departure is positive (eastward). The latitude would be negative (southward), but we only need the departure here. Choice A gets the sign wrong. Choice C uses cosine (that gives the latitude magnitude). Choice D uses cosine with a wrong sign.',
    hint: 'Departure = L sin(bearing angle). Check the quadrant to determine the sign: east is positive.',
    steps: [
      {
        text: 'Compute the departure magnitude:',
        latex: '\\text{Dep} = L \\sin\\theta = 350 \\times \\sin 55\\degree = 350 \\times 0.8192 = 286.7 \\text{ m}'
      },
      {
        text: 'S 55\\degree E is in the SE quadrant — departure is eastward (positive).',
        latex: null
      },
      {
        text: 'Final answer:',
        latex: '\\text{Dep} = +286.7 \\text{ m}'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\text{Dep} = L \\sin\\theta',
    videoUrl: null,
    traps: [
      'Confusing sine and cosine — departure uses sine, latitude uses cosine',
      'Getting the sign wrong for the SE quadrant'
    ],
    diagram: null,
    lessonId: 'traverse-computations',
    chapterId: 'surveying'
  },
  {
    id: 'surv-tc-ex2',
    type: 'computational',
    statement: 'A 4-sided closed traverse has courses with lengths $200$, $300$, $250$, and $150 \\text{ m}$. The sum of latitudes is $+0.12 \\text{ m}$ and the sum of departures is $-0.09 \\text{ m}$. What is the linear closure error?',
    choices: [
      {
        id: 'c1',
        text: '$0.03 \\text{ m}$'
      },
      {
        id: 'c2',
        text: '$0.21 \\text{ m}$'
      },
      {
        id: 'c3',
        text: '$0.15 \\text{ m}$'
      },
      {
        id: 'c4',
        text: '$0.105 \\text{ m}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Linear error $= \\sqrt{E_L^2 + E_D^2} = \\sqrt{0.12^2 + 0.09^2} = \\sqrt{0.0144 + 0.0081} = \\sqrt{0.0225} = 0.15$ m. This is a classic 3-4-5 right triangle relationship (0.09, 0.12, 0.15). Choice A subtracts the errors. Choice B adds the errors ($0.12 + 0.09 = 0.21$). Choice D averages them.',
    hint: 'The linear closure error combines both error components using the Pythagorean theorem.',
    steps: [
      {
        text: 'Combine the latitude and departure errors:',
        latex: 'E = \\sqrt{E_L^2 + E_D^2} = \\sqrt{0.12^2 + 0.09^2}'
      },
      {
        text: 'Compute:',
        latex: 'E = \\sqrt{0.0144 + 0.0081} = \\sqrt{0.0225} = 0.15 \\text{ m}'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\text{Linear error} = \\sqrt{E_L^2 + E_D^2}',
    videoUrl: null,
    traps: [
      'Adding the error components instead of using Pythagorean theorem',
      'Forgetting to square each error before adding'
    ],
    diagram: null,
    lessonId: 'traverse-computations',
    chapterId: 'surveying'
  },
  {
    id: 'surv-tc-ex3',
    type: 'conceptual',
    statement: 'A closed traverse has a precision ratio of $1:5{,}000$. Which of the following best describes what this means?',
    choices: [
      {
        id: 'c1',
        text: 'The traverse has 5,000 courses'
      },
      {
        id: 'c2',
        text: 'For every 5,000 units of traverse length, the position error is 1 unit'
      },
      {
        id: 'c3',
        text: 'The angular error is 1/5,000 of a degree'
      },
      {
        id: 'c4',
        text: 'The survey was completed in 1/5,000 of the expected time'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The precision ratio is the linear closure error divided by the total traverse length, expressed as 1:N. A ratio of 1:5,000 means that for every 5,000 feet (or meters) of traverse, the position closes to within 1 foot (or meter). Higher N means better precision. This is a standard way surveyors communicate how accurate a traverse closure is.',
    hint: 'Precision ratio = linear error / total length. Think about what the numerator and denominator represent.',
    steps: [
      {
        text: 'Precision ratio is defined as:',
        latex: '\\text{Precision} = \\frac{\\text{Linear error}}{\\text{Total traverse length}} = \\frac{1}{N}'
      },
      {
        text: 'For 1:5,000, the error is 1 unit per 5,000 units of traverse length.',
        latex: null
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\text{Precision} = \\frac{\\text{Linear error}}{\\Sigma L}',
    videoUrl: null,
    traps: [
      'Confusing precision ratio with angular error',
      'Thinking a larger denominator means worse precision (it means better)'
    ],
    diagram: null,
    lessonId: 'traverse-computations',
    chapterId: 'surveying'
  },
  {
    id: 'surv-tc-ex4',
    type: 'computational',
    statement: 'A closed traverse has $\\Sigma L = 1{,}500 \\text{ m}$, $E_L = +0.09 \\text{ m}$, and $E_D = -0.12 \\text{ m}$. A course with length $375 \\text{ m}$ has a raw departure of $+210.50 \\text{ m}$. What is the adjusted departure after applying the compass rule?',
    choices: [
      {
        id: 'c1',
        text: '$+210.53 \\text{ m}$'
      },
      {
        id: 'c2',
        text: '$+210.47 \\text{ m}$'
      },
      {
        id: 'c3',
        text: '$+210.80 \\text{ m}$'
      },
      {
        id: 'c4',
        text: '$+210.20 \\text{ m}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Compass rule departure correction $= -E_D \\times (L_i / \\Sigma L) = -(-0.12) \\times (375/1500) = +0.12 \\times 0.25 = +0.03$ m. Adjusted departure $= 210.50 + 0.03 = 210.53$ m. The negative departure error means the traverse drifted west, so we correct eastward (add). Choice B subtracts instead of adding. Choice C uses the full error. Choice D applies the latitude error to the departure.',
    hint: 'Compass rule correction for departure = -E_D * (course length / total length). The sign of the correction opposes the error.',
    steps: [
      {
        text: 'Departure correction for this course:',
        latex: '\\text{Corr}_{\\text{Dep}} = -E_D \\times \\frac{L_i}{\\Sigma L} = -(-0.12) \\times \\frac{375}{1{,}500}'
      },
      {
        text: 'Compute:',
        latex: '\\text{Corr}_{\\text{Dep}} = +0.12 \\times 0.25 = +0.03 \\text{ m}'
      },
      {
        text: 'Adjusted departure:',
        latex: '\\text{Dep}_{\\text{adj}} = 210.50 + 0.03 = 210.53 \\text{ m}'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\text{Corr}_{\\text{Dep}} = -E_D \\times \\frac{L_i}{\\Sigma L}',
    videoUrl: null,
    traps: [
      'Getting the sign of the correction wrong — correction opposes the error',
      'Applying the latitude error to the departure correction'
    ],
    diagram: null,
    lessonId: 'traverse-computations',
    chapterId: 'surveying'
  },
  {
    id: 'surv-ac-ex1',
    type: 'computational',
    statement: 'A triangle has vertices at $(0, 0)$, $(8, 0)$, and $(4, 6)$. What is the area using the coordinate method?',
    choices: [
      {
        id: 'c1',
        text: '$16 \\text{ sq units}$'
      },
      {
        id: 'c2',
        text: '$48 \\text{ sq units}$'
      },
      {
        id: 'c3',
        text: '$24 \\text{ sq units}$'
      },
      {
        id: 'c4',
        text: '$32 \\text{ sq units}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'Cross products: $(0 \\times 0 - 8 \\times 0) + (8 \\times 6 - 4 \\times 0) + (4 \\times 0 - 0 \\times 6) = 0 + 48 + 0 = 48$. Area $= |48|/2 = 24$ sq units. You can double-check: base = 8, height = 6, so $A = 8 \\times 6 / 2 = 24$. Choice A uses base times height / 3. Choice B forgets the 1/2. Choice D uses base times height / 1.5.',
    hint: 'Set up cross products for adjacent vertex pairs: sum of $(x_i y_{i+1} - x_{i+1} y_i)$, then take half the absolute value.',
    steps: [
      {
        text: 'List vertices and compute cross products:',
        latex: '\\sum = (0 \\cdot 0 - 8 \\cdot 0) + (8 \\cdot 6 - 4 \\cdot 0) + (4 \\cdot 0 - 0 \\cdot 6)'
      },
      {
        text: 'Simplify:',
        latex: '\\sum = 0 + 48 + 0 = 48'
      },
      {
        text: 'Area:',
        latex: 'A = \\frac{|48|}{2} = 24 \\text{ sq units}'
      }
    ],
    handbookPage: 'p. 280',
    handbookFormula: 'A = \\frac{1}{2}|\\sum(x_i y_{i+1} - x_{i+1} y_i)|',
    videoUrl: null,
    traps: ['Forgetting to divide by 2 — gives double the actual area', 'Reversing the cross product order'],
    diagram: {
      component: 'CoordinatePolygon',
      props: {
        vertices: [
          {
            x: 0,
            y: 0,
            label: 'A'
          },
          {
            x: 8,
            y: 0,
            label: 'B'
          },
          {
            x: 4,
            y: 6,
            label: 'C'
          }
        ]
      }
    },
    lessonId: 'area-computations',
    chapterId: 'surveying'
  },
  {
    id: 'surv-ac-ex2',
    type: 'computational',
    statement: 'Offsets from a baseline are measured at $25 \\text{ m}$ intervals: $0$, $10$, $14$, $11$, $6$, $0 \\text{ m}$. What is the area using the trapezoidal rule?',
    choices: [
      {
        id: 'c1',
        text: '$1{,}281 \\text{ m}^2$'
      },
      {
        id: 'c2',
        text: '$1{,}025 \\text{ m}^2$'
      },
      {
        id: 'c3',
        text: '$512.5 \\text{ m}^2$'
      },
      {
        id: 'c4',
        text: '$850 \\text{ m}^2$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Trapezoidal rule: $A = w[(h_1 + h_n)/2 + h_2 + h_3 + \\cdots + h_{n-1}]$. $A = 25[(0+0)/2 + 10 + 14 + 11 + 6] = 25 \\times 41 = 1025$ m². The first and last offsets are 0 so their average is 0, and the interior offsets are summed at full value. Choice A applies Simpson coefficients by mistake. Choice C divides the whole thing by 2. Choice D skips an interior offset.',
    hint: 'Average the first and last offsets, then add all interior offsets. Multiply by the common interval.',
    steps: [
      {
        text: 'Apply the trapezoidal rule:',
        latex: 'A = w\\left(\\frac{h_1 + h_n}{2} + h_2 + h_3 + h_4 + h_5\\right)'
      },
      {
        text: 'Substitute values:',
        latex: 'A = 25\\left(\\frac{0 + 0}{2} + 10 + 14 + 11 + 6\\right)'
      },
      {
        text: 'Compute:',
        latex: 'A = 25 \\times 41 = 1{,}025 \\text{ m}^2'
      }
    ],
    handbookPage: 'p. 280',
    handbookFormula: 'A = w\\left(\\frac{h_1 + h_n}{2} + h_2 + h_3 + \\cdots + h_{n-1}\\right)',
    videoUrl: null,
    traps: [
      'Averaging all offsets instead of only the first and last',
      'Forgetting to multiply by the interval width'
    ],
    diagram: {
      component: 'BaselineOffsets',
      props: {
        offsets: [
          0,
          10,
          14,
          11,
          6,
          0
        ],
        spacing: 25,
        unit: 'm'
      }
    },
    lessonId: 'area-computations',
    chapterId: 'surveying'
  },
  {
    id: 'surv-ac-ex3',
    type: 'computational',
    statement: 'Offsets from a baseline are measured at $10 \\text{ m}$ intervals: $0$, $5$, $8$, $6$, $0 \\text{ m}$. What is the area using Simpson’s 1/3 rule?',
    choices: [
      {
        id: 'c1',
        text: '$126.7 \\text{ m}^2$'
      },
      {
        id: 'c2',
        text: '$190.0 \\text{ m}^2$'
      },
      {
        id: 'c3',
        text: '$200 \\text{ m}^2$'
      },
      {
        id: 'c4',
        text: '$280.0 \\text{ m}^2$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Simpson\'s 1/3 rule: $A = (w/3)(h_1 + 4h_2 + 2h_3 + 4h_4 + h_5)$. We have 5 measurements (odd), so we have 4 intervals (even) — Simpson\'s applies. $A = (10/3)(0 + 4 \\times 5 + 2 \\times 8 + 4 \\times 6 + 0) = (10/3)(0 + 20 + 16 + 24 + 0) = (10/3)(60) = 200$ m². Choice A uses $w/3$ but misses the coefficients. Choice B (190) uses the trapezoidal rule. Choice D uses $w$ instead of $w/3$.',
    hint: 'Simpson’s 1/3 rule requires an odd number of offsets. The pattern of coefficients is 1, 4, 2, 4, 1.',
    steps: [
      {
        text: 'Verify: 5 offsets (odd count), so Simpson’s 1/3 rule applies.',
        latex: null
      },
      {
        text: 'Apply Simpson’s 1/3 rule:',
        latex: 'A = \\frac{w}{3}(h_1 + 4h_2 + 2h_3 + 4h_4 + h_5)'
      },
      {
        text: 'Substitute:',
        latex: 'A = \\frac{10}{3}(0 + 20 + 16 + 24 + 0) = \\frac{10}{3}(60)'
      },
      {
        text: 'Compute:',
        latex: 'A = \\frac{10}{3} \\times 60 = 200 \\text{ m}^2'
      }
    ],
    handbookPage: 'p. 280',
    handbookFormula: 'A = \\frac{w}{3}(h_1 + 4h_2 + 2h_3 + 4h_4 + \\cdots + h_n)',
    videoUrl: null,
    traps: [
      'Mixing up the 4-2-4 coefficient pattern',
      'Using Simpson’s rule with an even number of offsets (it requires odd)'
    ],
    diagram: {
      component: 'BaselineOffsets',
      props: {
        offsets: [
          0,
          5,
          8,
          6,
          0
        ],
        spacing: 10,
        unit: 'm'
      }
    },
    lessonId: 'area-computations',
    chapterId: 'surveying'
  },
  {
    id: 'surv-ac-ex4',
    type: 'conceptual',
    statement: 'A surveyor has 6 equally-spaced offset measurements along an irregular boundary. Which area computation method can NOT be directly applied?',
    choices: [
      {
        id: 'c1',
        text: 'Simpson’s 1/3 rule'
      },
      {
        id: 'c2',
        text: 'Trapezoidal rule'
      },
      {
        id: 'c3',
        text: 'Average end area method'
      },
      {
        id: 'c4',
        text: 'Both Simpson’s 1/3 rule and trapezoidal rule'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Simpson’s 1/3 rule requires an odd number of offset measurements (even number of intervals). With 6 measurements, you have an even number of offsets and 5 intervals (odd), so Simpson’s 1/3 rule cannot be applied directly. The trapezoidal rule works with any number of offsets. The average end area method is for volumes, not plan areas, but it has no even/odd restriction. The key constraint to remember is: Simpson’s 1/3 needs an ODD count of offsets.',
    hint: 'Think about which method has a restriction on the number of offsets being odd or even.',
    steps: [
      {
        text: 'Simpson’s 1/3 rule requires an odd number of offset measurements (even number of intervals).',
        latex: null
      },
      {
        text: '6 offsets = even count, so Simpson’s 1/3 rule cannot be applied directly.',
        latex: null
      },
      {
        text: 'The trapezoidal rule has no such restriction — it works with any number of offsets.',
        latex: null
      }
    ],
    handbookPage: 'p. 280',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing the requirement — Simpson’s needs odd offsets (even intervals), not the other way around'
    ],
    diagram: null,
    lessonId: 'area-computations',
    chapterId: 'surveying'
  },
  {
    id: 'surv-ev-ex1',
    type: 'computational',
    statement: 'Two adjacent cross-sections have areas $A_1 = 225 \\text{ ft}^2$ and $A_2 = 375 \\text{ ft}^2$, separated by $100 \\text{ ft}$. What is the volume by the average end area method, in cubic yards?',
    choices: [
      {
        id: 'c1',
        text: '$556 \\text{ yd}^3$'
      },
      {
        id: 'c2',
        text: '$30{,}000 \\text{ yd}^3$'
      },
      {
        id: 'c3',
        text: '$2{,}222 \\text{ yd}^3$'
      },
      {
        id: 'c4',
        text: '$1{,}111 \\text{ yd}^3$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: '$V = (L/2)(A_1 + A_2) = (100/2)(225 + 375) = 50 \\times 600 = 30000$ ft³. Convert to cubic yards: $30000 / 27 = 1111$ yd³. Choice A divides by 54 instead of 27. Choice B gives the volume in ft³, not yd³. Choice C forgets to divide $L$ by 2 (gets 60,000 ft³ / 27).',
    hint: 'Average end area: $V = (L/2)(A_1 + A_2)$, then divide by 27 to convert ft³ to yd³.',
    steps: [
      {
        text: 'Average end area volume:',
        latex: 'V = \\frac{100}{2}(225 + 375) = 50 \\times 600 = 30{,}000 \\text{ ft}^3'
      },
      {
        text: 'Convert to cubic yards:',
        latex: 'V = \\frac{30{,}000}{27} = 1{,}111 \\text{ yd}^3'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'V = \\frac{L}{2}(A_1 + A_2)',
    videoUrl: null,
    traps: ['Forgetting to convert from ft^3 to yd^3 by dividing by 27'],
    diagram: null,
    lessonId: 'earthwork-volumes',
    chapterId: 'surveying'
  },
  {
    id: 'surv-ev-ex2',
    type: 'computational',
    statement: 'Three cross-sections are taken at stations 0, 40 ft, and 80 ft with areas $A_1 = 150 \\text{ ft}^2$, $A_m = 280 \\text{ ft}^2$, and $A_2 = 350 \\text{ ft}^2$. What is the volume using the prismoidal formula?',
    choices: [
      {
        id: 'c1',
        text: '$20{,}000 \\text{ ft}^3$'
      },
      {
        id: 'c2',
        text: '$21{,}600 \\text{ ft}^3$'
      },
      {
        id: 'c3',
        text: '$10{,}400 \\text{ ft}^3$'
      },
      {
        id: 'c4',
        text: '$26{,}133 \\text{ ft}^3$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$V = (L/6)(A_1 + 4A_m + A_2) = (80/6)(150 + 4 \\times 280 + 350) = 13.333 \\times 1620 = 21600$ ft³. The total distance $L$ between the end sections is 80 ft, not 40. Choice A uses the average end area method: $(80/2)(150 + 350) = 20000$. Choice C uses $L = 40$ (half the total distance). Choice D uses $L/4$ with a different weighting.',
    hint: 'Prismoidal: $V = (L/6)(A_1 + 4A_m + A_2)$. The total length $L$ is 80 ft (from station 0 to station 80).',
    steps: [
      {
        text: 'Prismoidal formula:',
        latex: 'V = \\frac{L}{6}(A_1 + 4A_m + A_2) = \\frac{80}{6}(150 + 4 \\times 280 + 350)'
      },
      {
        text: 'Simplify:',
        latex: 'V = 13.333(150 + 1{,}120 + 350) = 13.333 \\times 1{,}620'
      },
      {
        text: 'Compute:',
        latex: 'V = 21{,}600 \\text{ ft}^3'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'V = \\frac{L}{6}(A_1 + 4A_m + A_2)',
    videoUrl: null,
    traps: [
      'Using the average end area formula instead of the prismoidal formula',
      'Using half the distance (40 ft) instead of the full distance (80 ft) between end sections'
    ],
    diagram: null,
    lessonId: 'earthwork-volumes',
    chapterId: 'surveying'
  },
  {
    id: 'surv-ev-ex3',
    type: 'computational',
    statement: 'A road project has cross-section areas at four stations spaced 100 ft apart:\n\nStation 0+00: $A = 0 \\text{ ft}^2$\nStation 1+00: $A = 300 \\text{ ft}^2$\nStation 2+00: $A = 500 \\text{ ft}^2$\nStation 3+00: $A = 200 \\text{ ft}^2$\n\nUsing the average end area method, what is the total volume in cubic yards?',
    choices: [
      {
        id: 'c1',
        text: '$3{,}704 \\text{ yd}^3$'
      },
      {
        id: 'c2',
        text: '$1{,}852 \\text{ yd}^3$'
      },
      {
        id: 'c3',
        text: '$3{,}333 \\text{ yd}^3$'
      },
      {
        id: 'c4',
        text: '$6{,}667 \\text{ yd}^3$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Apply average end area to each segment. $V_1 = (100/2)(0 + 300) = 15000$ ft³. $V_2 = (100/2)(300 + 500) = 40000$ ft³. $V_3 = (100/2)(500 + 200) = 35000$ ft³. Total $= 15000 + 40000 + 35000 = 90000$ ft³. Convert to cubic yards: $90000 / 27 = 3333$ yd³. Choice A includes an extra segment from a miscount. Choice B only computes two of the three segments. Choice D forgets to divide $L$ by 2 in each segment.',
    hint: 'Apply the average end area formula to each pair of adjacent stations, sum all segment volumes, then convert to cubic yards (divide by 27).',
    steps: [
      {
        text: 'Segment 1 (Sta 0+00 to 1+00):',
        latex: 'V_1 = \\frac{100}{2}(0 + 300) = 15{,}000 \\text{ ft}^3'
      },
      {
        text: 'Segment 2 (Sta 1+00 to 2+00):',
        latex: 'V_2 = \\frac{100}{2}(300 + 500) = 40{,}000 \\text{ ft}^3'
      },
      {
        text: 'Segment 3 (Sta 2+00 to 3+00):',
        latex: 'V_3 = \\frac{100}{2}(500 + 200) = 35{,}000 \\text{ ft}^3'
      },
      {
        text: 'Total volume:',
        latex: 'V = 15{,}000 + 40{,}000 + 35{,}000 = 90{,}000 \\text{ ft}^3 = \\frac{90{,}000}{27} = 3{,}333 \\text{ yd}^3'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'V = \\frac{L}{2}(A_1 + A_2)',
    videoUrl: null,
    traps: [
      'Computing only one or two segments instead of all three',
      'Forgetting to divide by 27 to convert ft^3 to yd^3'
    ],
    diagram: null,
    lessonId: 'earthwork-volumes',
    chapterId: 'surveying'
  },
  {
    id: 'surv-ev-ex4',
    type: 'conceptual',
    statement: 'A stockpile has a roughly conical shape with a base area of $2{,}000 \\text{ ft}^2$ and a height of $15 \\text{ ft}$. What is the estimated volume?',
    choices: [
      {
        id: 'c1',
        text: '$10{,}000 \\text{ ft}^3$'
      },
      {
        id: 'c2',
        text: '$30{,}000 \\text{ ft}^3$'
      },
      {
        id: 'c3',
        text: '$15{,}000 \\text{ ft}^3$'
      },
      {
        id: 'c4',
        text: '$5{,}000 \\text{ ft}^3$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'A cone (or pyramid) volume is $V = h \\times A_{base} / 3 = 15 \\times 2000 / 3 = 10000$ ft³. The 1/3 factor distinguishes a cone from a cylinder. Choice B uses $V = h \\times A$ (no 1/3 factor — that is a cylinder). Choice C uses $V = h \\times A / 2$ (average end area with $A_2 = 0$, which overcounts). Choice D divides by 6 instead of 3.',
    hint: 'A cone tapers to a point, so V = (h x A_base) / 3, not h x A.',
    steps: [
      {
        text: 'Volume of cone/pyramid:',
        latex: 'V = \\frac{h \\times A_{\\text{base}}}{3} = \\frac{15 \\times 2{,}000}{3}'
      },
      {
        text: 'Compute:',
        latex: 'V = \\frac{30{,}000}{3} = 10{,}000 \\text{ ft}^3'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'V = \\frac{h \\times A_{\\text{base}}}{3}',
    videoUrl: null,
    traps: [
      'Using $V = hA$ (cylinder formula) instead of the cone/pyramid formula with the 1/3 factor',
      'Using the average end area with $A_2 = 0$, which gives $hA/2$ instead of $hA/3$'
    ],
    diagram: null,
    lessonId: 'earthwork-volumes',
    chapterId: 'surveying'
  },
  {
    id: 'surv-hc-ex1',
    type: 'computational',
    statement: 'A horizontal curve has a radius $R = 1{,}200 \\text{ ft}$ and an intersection angle $I = 30\\degree$. What is the curve length $L$?',
    choices: [
      {
        id: 'c1',
        text: '$322 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$436 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$1{,}257 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$628 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: '$L = \\pi R I / 180 = \\pi \\times 1200 \\times 30 / 180 = 200\\pi = 628$ ft. Choice A uses $I/2$ instead of $I$ in the formula. Choice B computes the tangent distance $T$ instead of $L$. Choice C uses $I = 60°$ (doubles the angle).',
    hint: '$L = \\pi R I / 180$. Plug in $R = 1200$ and $I = 30°$.',
    steps: [
      {
        text: 'Curve length:',
        latex: 'L = \\frac{\\pi R I}{180} = \\frac{\\pi \\times 1{,}200 \\times 30}{180}'
      },
      {
        text: 'Simplify:',
        latex: 'L = \\frac{36{,}000\\pi}{180} = 200\\pi = 628 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'L = \\frac{\\pi R I}{180}',
    videoUrl: null,
    traps: ['Using I/2 instead of the full intersection angle I in the curve length formula'],
    diagram: {
      component: 'HorizontalCurve',
      props: {
        R: 1200,
        I: 30
      }
    },
    lessonId: 'horizontal-curves',
    chapterId: 'surveying'
  },
  {
    id: 'surv-hc-ex2',
    type: 'computational',
    statement: 'A horizontal curve has $R = 600 \\text{ ft}$ and $I = 90\\degree$. What is the middle ordinate $M$?',
    choices: [
      {
        id: 'c1',
        text: '$248.5 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$175.7 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$300.0 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$424.3 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$M = R(1 - \\cos(I/2)) = 600(1 - \\cos 45°) = 600(1 - 0.7071) = 600 \\times 0.2929 = 175.7$ ft. The middle ordinate is the distance from the curve midpoint to the long chord. Choice A uses $R(\\sec(I/2) - 1)$, which is the external distance $E$, not $M$. Choice C is simply $R/2$. Choice D uses $R \\cos 45°$ instead of $R(1 - \\cos 45°)$.',
    hint: '$M = R(1 - \\cos(I/2))$. Use half the intersection angle inside the cosine.',
    steps: [
      {
        text: 'Middle ordinate:',
        latex: 'M = R\\left(1 - \\cos\\frac{I}{2}\\right) = 600\\left(1 - \\cos 45\\degree\\right)'
      },
      {
        text: 'Evaluate:',
        latex: 'M = 600(1 - 0.7071) = 600 \\times 0.2929 = 175.7 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 303',
    handbookFormula: 'M = R\\left(1 - \\cos\\frac{I}{2}\\right)',
    videoUrl: null,
    traps: [
      'Using the full angle I instead of I/2 in the cosine',
      'Confusing middle ordinate M with external distance E'
    ],
    diagram: {
      component: 'HorizontalCurve',
      props: {
        R: 600,
        I: 90
      }
    },
    lessonId: 'horizontal-curves',
    chapterId: 'surveying'
  },
  {
    id: 'surv-hc-ex3',
    type: 'computational',
    statement: 'A horizontal curve has $D = 5\\degree$ and $I = 30\\degree$. The PI is at station $50+00$. What is the station of the PC?',
    choices: [
      {
        id: 'c1',
        text: '$47+00.00$'
      },
      {
        id: 'c2',
        text: '$53+07.05$'
      },
      {
        id: 'c3',
        text: '$46+92.95$'
      },
      {
        id: 'c4',
        text: '$44+00.00$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'First find $R$: $R = 5729.58 / 5 = 1145.92$ ft. Then the tangent distance: $T = R \\tan(I/2) = 1145.92 \\times \\tan 15° = 1145.92 \\times 0.2680 = 307.05$ ft. Station of PC $= PI - T = 5000 - 307.05 = 4692.95$ = station 46+92.95. Choice A rounds $T$ to 300 ft. Choice B adds $T$ to the PI instead of subtracting (that gives the PT via the tangent, not the PC). Choice D subtracts $L$ instead of $T$.',
    hint: 'Find $R$ from $D$, then $T = R \\tan(I/2)$. Station of PC = Station of PI $- T$.',
    steps: [
      {
        text: 'Radius:',
        latex: 'R = \\frac{5{,}729.58}{D} = \\frac{5{,}729.58}{5} = 1{,}145.92 \\text{ ft}'
      },
      {
        text: 'Tangent distance:',
        latex: 'T = R\\tan\\frac{I}{2} = 1{,}145.92 \\times \\tan 15\\degree = 1{,}145.92 \\times 0.2680 = 307.05 \\text{ ft}'
      },
      {
        text: 'Station of PC:',
        latex: '\\text{Sta PC} = 50+00 - 3+07.05 = 46+92.95'
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'T = R\\tan\\frac{I}{2}; \\quad R = \\frac{5{,}729.58}{D}',
    videoUrl: null,
    traps: [
      'Adding T to the PI station instead of subtracting it to find the PC',
      'Using the full angle I in the tangent formula instead of I/2'
    ],
    diagram: {
      component: 'HorizontalCurve',
      props: {
        R: 1146,
        I: 30
      }
    },
    lessonId: 'horizontal-curves',
    chapterId: 'surveying'
  },
  {
    id: 'surv-hc-ex4',
    type: 'conceptual',
    statement: 'A horizontal curve has PI at station $30+00$ and a tangent distance $T = 400 \\text{ ft}$. The curve length is $L = 750 \\text{ ft}$. A surveyor needs to lay out the curve. Which of the following correctly identifies the PC, PT, and the relationship between them?',
    choices: [
      {
        id: 'c1',
        text: 'PC at $26+00$, PT at $33+50$; the PT station is found by adding $L$ to the PC station, not by adding $T$ to the PI'
      },
      {
        id: 'c2',
        text: 'PC at $26+00$, PT at $34+00$; the PT station is found by adding $T$ to the PI'
      },
      {
        id: 'c3',
        text: 'PC at $26+00$, PT at $30+00$; the PT is always at the PI station'
      },
      {
        id: 'c4',
        text: 'PC at $30+00$, PT at $37+50$; the PC is at the PI and the PT is at PC + $L$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: '$PC = PI - T = 3000 - 400 = 2600$ = station 26+00. $PT = PC + L = 2600 + 750 = 3350$ = station 33+50. The key insight is that PT is found by adding the arc length $L$ to the PC station, NOT by adding $T$ to the PI. The tangent distance $T$ goes from the PI back to the PC (or forward to the PT along the tangent), but the actual curve station at the PT uses the arc distance $L$. Choice B adds $T$ to the PI for the PT (that gives a point on the tangent, not the curve). Choice C confuses the PT with the PI. Choice D places the PC at the PI.',
    hint: 'PC = PI - T. PT = PC + L (arc length along the curve). Do NOT compute PT as PI + T.',
    steps: [
      {
        text: 'Station of PC:',
        latex: '\\text{Sta PC} = \\text{Sta PI} - T = 30+00 - 4+00 = 26+00'
      },
      {
        text: 'Station of PT:',
        latex: '\\text{Sta PT} = \\text{Sta PC} + L = 26+00 + 7+50 = 33+50'
      },
      {
        text: 'Note: PT is NOT at PI + T = 30+00 + 4+00 = 34+00. The curve arc L and tangent T are different distances.',
        latex: null
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'L = \\frac{\\pi R I}{180}; \\quad T = R\\tan\\frac{I}{2}',
    videoUrl: null,
    traps: [
      'Computing PT as PI + T instead of PC + L -- T and L are different distances',
      'Confusing the PI with the PC or PT'
    ],
    diagram: {
      component: 'HorizontalCurve',
      props: {
        R: 1000,
        I: 40
      }
    },
    lessonId: 'horizontal-curves',
    chapterId: 'surveying'
  },
  {
    id: 'surv-vc-ex1',
    type: 'computational',
    statement: 'A vertical curve has $g_1 = +2\\%$, $g_2 = -2\\%$, $L = 400 \\text{ ft}$, and $Y_{PVC} = 150.0 \\text{ ft}$. What is the curve elevation at $x = 100 \\text{ ft}$ from the PVC?',
    choices: [
      {
        id: 'c1',
        text: '$152.0 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$151.5 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$150.0 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$148.0 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Plug into the curve formula: $Y = Y_{PVC} + g_1 x + [(g_2 - g_1)/(2L)]x^2$. The parabola constant $a = (-0.02 - 0.02)/(2 \\times 400) = -0.04/800 = -0.00005$. $Y = 150 + 0.02(100) + (-0.00005)(100^2) = 150 + 2.0 - 0.5 = 151.5$ ft. Choice A (152.0) is the tangent elevation, ignoring the parabolic correction. Choice C is the PVC elevation. Choice D subtracts the grade instead of adding it.',
    hint: 'Use the curve formula Y = Y_PVC + g_1 x + [(g_2 - g_1)/(2L)]x^2. Convert percent grades to decimals.',
    steps: [
      {
        text: 'Parabola constant:',
        latex: 'a = \\frac{g_2 - g_1}{2L} = \\frac{-0.02 - 0.02}{800} = -0.00005'
      },
      {
        text: 'Curve elevation at x = 100:',
        latex: 'Y = 150 + 0.02(100) + (-0.00005)(100^2)'
      },
      {
        text: 'Compute:',
        latex: 'Y = 150 + 2.0 - 0.5 = 151.5 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 301',
    handbookFormula: 'Y = Y_{PVC} + g_1 x + \\frac{g_2 - g_1}{2L} x^2',
    videoUrl: null,
    traps: ['Forgetting to convert percent grade to decimal (2% = 0.02, not 2)'],
    diagram: {
      component: 'VerticalCurveProfile',
      props: {
        g1: 2,
        g2: -2,
        L: 400,
        elevPVC: 150
      }
    },
    lessonId: 'vertical-curves',
    chapterId: 'surveying'
  },
  {
    id: 'surv-vc-ex2',
    type: 'computational',
    statement: 'A sag vertical curve has $g_1 = -2\\%$, $g_2 = +4\\%$, $L = 600 \\text{ ft}$, and $Y_{PVC} = 340.00 \\text{ ft}$. How far from the PVC is the low point, and what is the elevation there?',
    choices: [
      {
        id: 'c1',
        text: '$400 \\text{ ft from PVC, elevation } 338.00 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$300 \\text{ ft from PVC, elevation } 337.50 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$200 \\text{ ft from PVC, elevation } 338.00 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$200 \\text{ ft from PVC, elevation } 336.00 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The low point is at $x_m = -g_1 L/(g_2 - g_1) = -(-0.02)(600)/(0.04 - (-0.02)) = 12/0.06 = 200$ ft from the PVC. Elevation: $Y = 340 + (-0.02)(200) + [(0.04 - (-0.02))/(2 \\times 600)](200^2) = 340 - 4.0 + 2.0 = 338.00$ ft. Choice A uses $x_m = -g_2 L/(g_1 - g_2)$. Choice B puts the low point at $L/2$ (only true when $|g_1| = |g_2|$). Choice D gets the location right but computes the elevation using only the tangent.',
    hint: 'Low point is at $x_m = -g_1 L/(g_2 - g_1)$. Then plug $x_m$ into the curve elevation formula.',
    steps: [
      {
        text: 'Low point distance from PVC:',
        latex: 'x_m = \\frac{-g_1 L}{g_2 - g_1} = \\frac{-(-0.02)(600)}{0.04 - (-0.02)} = \\frac{12}{0.06} = 200 \\text{ ft}'
      },
      {
        text: 'Elevation at low point:',
        latex: 'Y = 340 + (-0.02)(200) + \\frac{0.06}{1{,}200}(200^2)'
      },
      {
        text: 'Compute:',
        latex: 'Y = 340 - 4.0 + 2.0 = 338.00 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 301',
    handbookFormula: 'x_m = \\frac{-g_1 L}{g_2 - g_1}',
    videoUrl: null,
    traps: [
      'Assuming the low point is at L/2 -- only true when the absolute values of the grades are equal',
      'Getting the sign wrong in the denominator (g_2 - g_1, not g_1 - g_2)'
    ],
    diagram: {
      component: 'VerticalCurveProfile',
      props: {
        g1: -2,
        g2: 4,
        L: 600,
        elevPVC: 340
      }
    },
    lessonId: 'vertical-curves',
    chapterId: 'surveying'
  },
  {
    id: 'surv-vc-ex3',
    type: 'computational',
    statement: 'A crest vertical curve has $g_1 = +3\\%$ and $g_2 = -5\\%$. The required stopping sight distance is $S = 500 \\text{ ft}$. Using the standard criteria ($h_1 = 3.50 \\text{ ft}$, $h_2 = 2.0 \\text{ ft}$) and assuming $S \\le L$, what is the minimum curve length?',
    choices: [
      {
        id: 'c1',
        text: '$1{,}855 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$927 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$556 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$463 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$A = |g_1 - g_2| = |3 - (-5)| = 8\\%$. For a crest curve with $S \\le L$ and standard criteria, $L = AS^2 / 2158 = 8 \\times 500^2 / 2158 = 2000000 / 2158 = 927$ ft. Since $L = 927 > S = 500$, the assumption $S \\le L$ is valid. Choice A uses the general formula denominator (1,079) instead of the standard criteria (2,158). Choice C uses $A = 5$ instead of 8. Choice D divides $L$ by 2.',
    hint: 'For a crest curve with $S \\le L$ and standard criteria, $L = AS^2 / 2158$. First find $A = |g_1 - g_2|$ in percent.',
    steps: [
      {
        text: 'Algebraic difference in grades:',
        latex: 'A = |g_1 - g_2| = |3 - (-5)| = 8\\%'
      },
      {
        text: 'Minimum curve length (S <= L):',
        latex: 'L = \\frac{AS^2}{2{,}158} = \\frac{8 \\times 500^2}{2{,}158}'
      },
      {
        text: 'Compute:',
        latex: 'L = \\frac{2{,}000{,}000}{2{,}158} = 927 \\text{ ft}'
      },
      {
        text: 'Check assumption: $L = 927 > S = 500$, so S <= L is valid.',
        latex: null
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'L = \\frac{AS^2}{2{,}158}',
    videoUrl: null,
    traps: [
      'Using the wrong denominator -- 2,158 is for standard criteria with h_1 = 3.5 and h_2 = 2.0',
      'Computing A incorrectly by not taking the absolute difference'
    ],
    diagram: null,
    lessonId: 'vertical-curves',
    chapterId: 'surveying'
  },
  {
    id: 'surv-vc-ex4',
    type: 'conceptual',
    statement: 'A crest vertical curve has $g_1 = +4\\%$ and $g_2 = -2\\%$. A designer needs a minimum rate of vertical curvature $K = 120$. What is the minimum curve length $L$?',
    choices: [
      {
        id: 'c1',
        text: '$720 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$480 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$240 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$20 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: '$K = L/A$, so $L = K \\times A$. First find $A = |g_1 - g_2| = |4 - (-2)| = 6\\%$. Then $L = 120 \\times 6 = 720$ ft. The $K$-value represents feet of curve per percent change in grade — a higher $K$ means a longer, gentler curve with better sight distance. Choice B uses $A = 4$ (only one grade, not the difference). Choice C uses $A = 2$. Choice D uses $K/A$ instead of $K \\times A$.',
    hint: 'K = L/A, so L = K x A. Remember that A = |g_1 - g_2| is in percent.',
    steps: [
      {
        text: 'Algebraic difference in grades:',
        latex: 'A = |g_1 - g_2| = |4 - (-2)| = 6\\%'
      },
      {
        text: 'Minimum curve length:',
        latex: 'L = K \\times A = 120 \\times 6 = 720 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 301',
    handbookFormula: 'K = \\frac{L}{A}',
    videoUrl: null,
    traps: [
      'Using only one grade instead of the algebraic difference A = |g_1 - g_2|',
      'Dividing K by A instead of multiplying'
    ],
    diagram: null,
    lessonId: 'vertical-curves',
    chapterId: 'surveying'
  },
  {
    id: 'surv-cg-ex1',
    type: 'computational',
    statement: 'Point A is at $(E, N) = (2{,}000, 3{,}000)$ and point B at $(2{,}600, 3{,}800)$ (ft). What is the straight-line distance from A to B?',
    choices: [
      { id: 'c1', text: '$1{,}000\\text{ ft}$' },
      { id: 'c2', text: '$1{,}400\\text{ ft}$' },
      { id: 'c3', text: '$700\\text{ ft}$' },
      { id: 'c4', text: '$500\\text{ ft}$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'ΔE = 600, ΔN = 800; distance = √(600² + 800²) = √(360,000 + 640,000) = √1,000,000 = 1,000 ft (a 6-8-10 triangle). Choice B adds the differences. Choice C averages them. Choice D halves ΔN.',
    hint: 'Distance = √(ΔE² + ΔN²).',
    steps: [
      { text: 'Differences:', latex: '\\Delta E = 600, \\quad \\Delta N = 800' },
      { text: 'Distance:', latex: 'L = \\sqrt{600^2 + 800^2} = 1{,}000\\text{ ft}' },
    ],
    handbookPage: null,
    handbookFormula: 'L = \\sqrt{\\Delta E^2 + \\Delta N^2}',
    videoUrl: null,
    traps: ['Adding ΔE and ΔN instead of using the Pythagorean distance', 'Swapping easting and northing'],
    diagram: null,
    lessonId: 'coordinate-geometry',
    chapterId: 'surveying'
  },
];

export default PROBLEMS;
