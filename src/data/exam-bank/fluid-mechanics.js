// Exam bank: fluid-mechanics
// Auto-extracted from lesson files — 32 questions

const PROBLEMS = [
  {
    id: 'flu-fp-ex1',
    type: 'computational',
    statement: 'An oil has a density of $\\rho = 870\\,\\text{kg/m}^3$. What is its specific weight? Use $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$870\\,\\text{N/m}^3$'
      },
      {
        id: 'c2',
        text: '$8{,}535\\,\\text{N/m}^3$'
      },
      {
        id: 'c3',
        text: '$88.7\\,\\text{N/m}^3$'
      },
      {
        id: 'c4',
        text: '$8{,}535\\,\\text{kg/m}^3$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Specific weight is density times gravitational acceleration: $\\gamma = \\rho \\times g = 870 \\times 9.81 = 8{,}534.7$ N/m³. Choice A confuses density with specific weight (forgot to multiply by $g$). Choice C divides by $g$ instead of multiplying. Choice D has the right number but wrong units — specific weight is force per volume (N/m³), not mass per volume.',
    hint: 'Specific weight relates to density by $\\gamma = \\rho g$. Make sure your answer has force units.',
    steps: [
      {
        text: 'Apply the definition:',
        latex: '\\gamma = \\rho g = 870 \\times 9.81'
      },
      {
        text: 'Compute:',
        latex: '\\gamma = 8{,}535\\,\\text{N/m}^3'
      }
    ],
    handbookPage: 'p. 176',
    handbookFormula: '\\gamma = \\rho g',
    videoUrl: null,
    traps: ['Confusing density (kg/m³) with specific weight (N/m³)', 'Forgetting to multiply by $g$'],
    diagram: null,
    lessonId: 'fluid-properties',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-fp-ex2',
    type: 'computational',
    statement: 'A plate slides over a $0.5\\,\\text{mm}$ oil film at $1.2\\,\\text{m/s}$. The dynamic viscosity of the oil is $\\mu = 0.04\\,\\text{Pa}\\cdot\\text{s}$. Assuming a linear velocity profile, what is the shear stress on the plate?',
    choices: [
      {
        id: 'c1',
        text: '$9.6\\,\\text{Pa}$'
      },
      {
        id: 'c2',
        text: '$0.096\\,\\text{Pa}$'
      },
      {
        id: 'c3',
        text: '$96\\,\\text{Pa}$'
      },
      {
        id: 'c4',
        text: '$960\\,\\text{Pa}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'For a linear profile, the velocity gradient is $dv/dy = v/\\delta$. Convert the gap: $0.5$ mm $= 0.0005$ m. Then $dv/dy = 1.2/0.0005 = 2{,}400$ s⁻¹. Shear stress: $\\tau = \\mu \\times dv/dy = 0.04 \\times 2{,}400 = 96$ Pa. Choice B forgets to convert mm to m (uses $\\delta = 0.5$ m). Choice A uses $\\delta = 0.005$ m. Choice D uses $\\delta = 0.00005$ m.',
    hint: 'Convert the film thickness to meters before computing the velocity gradient $dv/dy = v/\\delta$.',
    steps: [
      {
        text: 'Convert film thickness:',
        latex: '\\delta = 0.5\\,\\text{mm} = 0.0005\\,\\text{m}'
      },
      {
        text: 'Velocity gradient (linear profile):',
        latex: '\\frac{dv}{dy} = \\frac{v}{\\delta} = \\frac{1.2}{0.0005} = 2{,}400\\,\\text{s}^{-1}'
      },
      {
        text: 'Shear stress:',
        latex: '\\tau = \\mu \\frac{dv}{dy} = 0.04 \\times 2{,}400 = 96\\,\\text{Pa}'
      }
    ],
    handbookPage: 'p. 176',
    handbookFormula: '\\tau = \\mu \\frac{dv}{dy}',
    videoUrl: null,
    traps: [
      'Forgetting to convert mm to m for the film thickness',
      'Using kinematic viscosity instead of dynamic viscosity'
    ],
    diagram: null,
    lessonId: 'fluid-properties',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-fp-ex3',
    type: 'computational',
    statement: 'A fluid has a kinematic viscosity of $\\nu = 5 \\times 10^{-4}\\,\\text{m}^2/\\text{s}$ and a density of $\\rho = 900\\,\\text{kg/m}^3$. What is its dynamic (absolute) viscosity?',
    choices: [
      {
        id: 'c1',
        text: '$0.45\\,\\text{Pa}\\cdot\\text{s}$'
      },
      {
        id: 'c2',
        text: '$5.56 \\times 10^{-7}\\,\\text{Pa}\\cdot\\text{s}$'
      },
      {
        id: 'c3',
        text: '$4.5\\,\\text{Pa}\\cdot\\text{s}$'
      },
      {
        id: 'c4',
        text: '$0.045\\,\\text{Pa}\\cdot\\text{s}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Kinematic viscosity is $\\nu = \\mu/\\rho$, so $\\mu = \\nu \\times \\rho = 5 \\times 10^{-4} \\times 900 = 0.45$ Pa·s. Choice B divides $\\nu$ by $\\rho$ instead of multiplying. Choice C is off by a factor of 10 (maybe used $\\nu = 5 \\times 10^{-3}$). Choice D is off by a factor of 10 in the other direction. The key is remembering which way the formula goes: multiply $\\nu$ by $\\rho$ to get $\\mu$.',
    hint: 'Rearrange $\\nu = \\mu / \\rho$ to solve for $\\mu$.',
    steps: [
      {
        text: 'From the definition of kinematic viscosity:',
        latex: '\\nu = \\frac{\\mu}{\\rho} \\quad \\Rightarrow \\quad \\mu = \\nu \\rho'
      },
      {
        text: 'Substitute:',
        latex: '\\mu = 5 \\times 10^{-4} \\times 900 = 0.45\\,\\text{Pa}\\cdot\\text{s}'
      }
    ],
    handbookPage: 'p. 176',
    handbookFormula: '\\nu = \\frac{\\mu}{\\rho}',
    videoUrl: null,
    traps: [
      'Dividing $\\nu$ by $\\rho$ instead of multiplying — gives a tiny number',
      'Mixing up which viscosity is which (dynamic vs. kinematic)'
    ],
    diagram: null,
    lessonId: 'fluid-properties',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-fp-ex4',
    type: 'conceptual',
    statement: 'Which statement correctly describes the difference between dynamic viscosity ($\\mu$) and kinematic viscosity ($\\nu$)?',
    choices: [
      {
        id: 'c1',
        text: '$\\mu$ has units of m$^2$/s and accounts for fluid density; $\\nu$ has units of Pa$\\cdot$s'
      },
      {
        id: 'c2',
        text: '$\\nu = \\mu / \\rho$; kinematic viscosity removes the density dependence so it can be used directly in the Reynolds number'
      },
      {
        id: 'c3',
        text: 'They are identical for water because water has a density of 1,000 kg/m$^3$'
      },
      {
        id: 'c4',
        text: '$\\mu$ applies only to gases while $\\nu$ applies only to liquids'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'Kinematic viscosity is dynamic viscosity divided by density: $\\nu = \\mu/\\rho$. It is called "kinematic" because its units (m²/s) involve only length and time — no mass. This makes it convenient for the Reynolds number, $Re = vD/\\nu$. Choice A reverses the units. Choice C is wrong because they are never numerically equal in SI ($\\mu$ for water is about $0.001$ Pa·s while $\\nu$ is about $1 \\times 10^{-6}$ m²/s). Choice D is wrong because both types apply to all fluids.',
    hint: 'Think about what dividing by density does to the units of viscosity.',
    steps: [
      {
        text: 'Dynamic viscosity $\\mu$ has units of Pa$\\cdot$s = kg/(m$\\cdot$s).',
        latex: null
      },
      {
        text: 'Kinematic viscosity divides out density:',
        latex: '\\nu = \\frac{\\mu}{\\rho} \\quad \\Rightarrow \\quad \\text{units: } \\frac{\\text{kg/(m}\\cdot\\text{s)}}{\\text{kg/m}^3} = \\text{m}^2/\\text{s}'
      },
      {
        text: 'The Reynolds number uses kinematic viscosity directly: $Re = vD/\\nu$.',
        latex: null
      }
    ],
    handbookPage: 'p. 176',
    handbookFormula: '\\nu = \\frac{\\mu}{\\rho}',
    videoUrl: null,
    traps: [
      'Reversing the units of $\\mu$ and $\\nu$',
      'Thinking they are numerically equal for water in SI units'
    ],
    diagram: null,
    lessonId: 'fluid-properties',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-hp-ex1',
    type: 'computational',
    statement: 'A swimming pool is open to the atmosphere. What is the gauge pressure at the bottom of the deep end, where $h = 3.5\\,\\text{m}$? Use $\\gamma_w = 9{,}810\\,\\text{N/m}^3$.',
    choices: [
      {
        id: 'c1',
        text: '$34{,}335\\,\\text{kPa}$'
      },
      {
        id: 'c2',
        text: '$34.34\\,\\text{kPa}$'
      },
      {
        id: 'c3',
        text: '$135.6\\,\\text{kPa}$'
      },
      {
        id: 'c4',
        text: '$3.434\\,\\text{kPa}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Gauge pressure at depth $h$ in an open tank is $P = \\gamma \\times h = 9{,}810 \\times 3.5 = 34{,}335$ Pa $= 34.34$ kPa. The surface is open to atmosphere so gauge pressure there is zero. Choice A forgets to convert Pa to kPa. Choice C adds atmospheric pressure (making it absolute instead of gauge). Choice D divides by 10,000 instead of 1,000.',
    hint: 'Gauge pressure at the free surface of an open tank is zero. At depth $h$, $P_{\\text{gauge}} = \\gamma h$.',
    steps: [
      {
        text: 'Gauge pressure at depth:',
        latex: 'P = \\gamma h = 9{,}810 \\times 3.5 = 34{,}335\\,\\text{Pa}'
      },
      {
        text: 'Convert to kPa:',
        latex: 'P = \\frac{34{,}335}{1{,}000} = 34.34\\,\\text{kPa}'
      }
    ],
    handbookPage: 'p. 177',
    handbookFormula: 'P_2 - P_1 = \\gamma h',
    videoUrl: null,
    traps: [
      'Forgetting to convert Pa to kPa',
      'Adding atmospheric pressure when the problem asks for gauge pressure'
    ],
    diagram: null,
    lessonId: 'hydrostatic-pressure',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-hp-ex2',
    type: 'computational',
    statement: 'A closed tank contains glycerin ($SG = 1.26$) with a gauge pressure of $35\\,\\text{kPa}$ acting on the liquid surface. What is the gauge pressure at a point $2.5\\,\\text{m}$ below the surface? Use $\\gamma_w = 9{,}810\\,\\text{N/m}^3$.',
    choices: [
      {
        id: 'c1',
        text: '$59.5\\,\\text{kPa}$'
      },
      {
        id: 'c2',
        text: '$30.9\\,\\text{kPa}$'
      },
      {
        id: 'c3',
        text: '$65.9\\,\\text{kPa}$'
      },
      {
        id: 'c4',
        text: '$167.2\\,\\text{kPa}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'First find the specific weight of glycerin: $\\gamma = SG \\times \\gamma_w = 1.26 \\times 9{,}810 = 12{,}361$ N/m³. The hydrostatic pressure increase over 2.5 m is $12{,}361 \\times 2.5 = 30{,}902$ Pa $= 30.9$ kPa. The gauge pressure at depth is the surface pressure plus the hydrostatic increase: $35 + 30.9 = 65.9$ kPa. Choice B gives only the hydrostatic column and forgets the surface pressure. Choice A uses $\\gamma_w$ instead of $\\gamma_{\\text{glycerin}}$. Choice D adds atmospheric pressure on top (computing absolute instead of gauge).',
    hint: 'The total gauge pressure at depth equals the surface gauge pressure plus $\\gamma_{\\text{glycerin}} \\times h$.',
    steps: [
      {
        text: 'Specific weight of glycerin:',
        latex: '\\gamma_{\\text{gly}} = 1.26 \\times 9{,}810 = 12{,}361\\,\\text{N/m}^3'
      },
      {
        text: 'Hydrostatic pressure increase:',
        latex: '\\Delta P = \\gamma_{\\text{gly}} \\times h = 12{,}361 \\times 2.5 = 30{,}902\\,\\text{Pa} = 30.9\\,\\text{kPa}'
      },
      {
        text: 'Gauge pressure at depth:',
        latex: 'P_{\\text{gauge}} = 35 + 30.9 = 65.9\\,\\text{kPa}'
      }
    ],
    handbookPage: 'p. 177',
    handbookFormula: 'P_2 - P_1 = \\gamma h',
    videoUrl: null,
    traps: [
      'Using $\\gamma_w$ instead of $\\gamma_{\\text{glycerin}}$ — ignoring the specific gravity',
      'Forgetting to add the surface pressure to the hydrostatic increase'
    ],
    diagram: null,
    lessonId: 'hydrostatic-pressure',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-hp-ex3',
    type: 'computational',
    statement: 'A simple U-tube manometer is connected to a pressurized tank containing water. The manometer fluid is mercury ($SG = 13.6$). The mercury on the tank side rises $h_1 = 150\\,\\text{mm}$ above the pipe connection. The mercury on the open (atmospheric) side is $h_2 = 450\\,\\text{mm}$ above the pipe connection. What is the gauge pressure at the pipe connection? Use $\\gamma_w = 9{,}810\\,\\text{N/m}^3$.',
    choices: [
      {
        id: 'c1',
        text: '$38.6\\,\\text{kPa}$'
      },
      {
        id: 'c2',
        text: '$2.94\\,\\text{kPa}$'
      },
      {
        id: 'c3',
        text: '$59.9\\,\\text{kPa}$'
      },
      {
        id: 'c4',
        text: '$40.0\\,\\text{kPa}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Walk from the open (atmospheric) side to the pipe connection. On the open side, go down 0.45 m of mercury (adds pressure). On the tank side, go up 0.15 m of mercury and 0.15 m of water to reach the pipe (subtracts pressure). Setting $P_{\\text{atm}} = 0$ gauge: $0 + \\gamma_{Hg}(0.45) = P + \\gamma_{Hg}(0.15) + \\gamma_w(0.15)$. So $P = \\gamma_{Hg}(0.30) - \\gamma_w(0.15) = 133{,}416(0.30) - 9{,}810(0.15) = 40{,}025 - 1{,}472 = 38{,}553$ Pa $= 38.6$ kPa. The water column on the tank side matters — it subtracts about 1.5 kPa. Choice B uses $\\gamma_w$ for the entire column instead of $\\gamma_{Hg}$. Choice C ignores the water column and uses the full 0.45 m of mercury. Choice D ignores the water column correction (gets 40.0 kPa).',
    hint: 'Walk from the atmospheric side to the tank side, adding pressure going down and subtracting going up. Use $\\gamma_{Hg} = SG \\times \\gamma_w$.',
    steps: [
      {
        text: 'Specific weight of mercury:',
        latex: '\\gamma_{Hg} = 13.6 \\times 9{,}810 = 133{,}416\\,\\text{N/m}^3'
      },
      {
        text: 'Walk from the open side to the pipe. At the open side, go down $0.45\\,\\text{m}$ of mercury, then up $0.15\\,\\text{m}$ of mercury and $0.15\\,\\text{m}$ of water:',
        latex: 'P_{\\text{atm}} + \\gamma_{Hg}(0.45) = P + \\gamma_{Hg}(0.15) + \\gamma_w(0.15)'
      },
      {
        text: 'Solve for gauge pressure ($P_{\\text{atm}} = 0$ gauge):',
        latex: 'P = \\gamma_{Hg}(0.30) - \\gamma_w(0.15) = 133{,}416(0.30) - 9{,}810(0.15)'
      },
      {
        text: 'Compute:',
        latex: 'P = 40{,}025 - 1{,}472 = 38{,}553\\,\\text{Pa} \\approx 38.6\\,\\text{kPa}'
      }
    ],
    handbookPage: 'p. 178',
    handbookFormula: 'P_0 = P_2 + \\gamma_2 h_2 - \\gamma_1 h_1',
    videoUrl: null,
    traps: [
      'Forgetting the water column above the mercury on the tank side',
      'Using $\\gamma_w$ instead of $\\gamma_{Hg}$ for the mercury column'
    ],
    diagram: {
      component: 'UtubeManometer',
      props: {
        h1: 150,
        h2: 450,
        unit: 'mm'
      }
    },
    lessonId: 'hydrostatic-pressure',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-hp-ex4',
    type: 'conceptual',
    statement: 'Two tanks of water are open to the atmosphere. Tank 1 has a surface area of $10\\,\\text{m}^2$ and a depth of $2\\,\\text{m}$. Tank 2 has a surface area of $50\\,\\text{m}^2$ and a depth of $2\\,\\text{m}$. How do the gauge pressures at the bottom of each tank compare?',
    choices: [
      {
        id: 'c1',
        text: 'Tank 2 has five times the pressure because it holds more water'
      },
      {
        id: 'c2',
        text: 'The pressures are equal because gauge pressure depends only on depth, not on the container shape or volume'
      },
      {
        id: 'c3',
        text: 'Tank 1 has higher pressure because the same weight acts on a smaller area'
      },
      {
        id: 'c4',
        text: 'The pressures are equal only if both tanks contain the same fluid at the same temperature'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'Hydrostatic pressure depends only on depth and fluid specific weight: $P = \\gamma \\times h$. The container shape, surface area, and total volume of water do not matter. Both tanks have the same depth (2 m) and the same fluid (water), so the gauge pressures at the bottom are identical. This is sometimes called the hydrostatic paradox. Choice A confuses total force (which does depend on area) with pressure. Choice C tries to apply $P = F/A$ using weight, which does not apply to fluid pressure — that reasoning works for solids on a surface, not fluids. Choice D adds an unnecessary condition; both tanks already contain the same fluid (water).',
    hint: 'Recall that $P = \\gamma h$ has no term for area or volume.',
    steps: [
      {
        text: 'Hydrostatic gauge pressure at the bottom of any open tank:',
        latex: 'P = \\gamma h'
      },
      {
        text: 'Both tanks have the same fluid and the same depth, so:',
        latex: 'P_1 = P_2 = \\gamma_w \\times 2\\,\\text{m}'
      },
      {
        text: 'The total FORCE on the bottom differs (F = P * A_bottom), but the PRESSURE does not.',
        latex: null
      }
    ],
    handbookPage: 'p. 177',
    handbookFormula: 'P_2 - P_1 = \\gamma h',
    videoUrl: null,
    traps: [
      'Confusing pressure with total force -- pressure is independent of area',
      'Trying to apply P = W/A (weight over area) reasoning from solid mechanics'
    ],
    diagram: null,
    lessonId: 'hydrostatic-pressure',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-hfb-ex1',
    type: 'computational',
    statement: 'A vertical circular gate with diameter $D = 1.2\\,\\text{m}$ is submerged in water with its center (centroid) at a depth of $h_C = 4\\,\\text{m}$ below the surface. What is the resultant hydrostatic force on the gate? Use $\\gamma_w = 9{,}810\\,\\text{N/m}^3$.',
    choices: [
      {
        id: 'c1',
        text: '$22.2\\,\\text{kN}$'
      },
      {
        id: 'c2',
        text: '$11.1\\,\\text{kN}$'
      },
      {
        id: 'c3',
        text: '$88.8\\,\\text{kN}$'
      },
      {
        id: 'c4',
        text: '$44.4\\,\\text{kN}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'The resultant force is $F = \\gamma \\times h_C \\times A$. Area of a circle: $A = \\pi D^2/4 = \\pi \\times 1.2^2/4 = 1.131$ m². $F = 9{,}810 \\times 4 \\times 1.131 = 44{,}342$ N $= 44.3$ kN, approximately 44.4 kN. Choice B uses $h_C = 1$ m instead of 4 m. Choice C uses $h_C = 8$ m (doubled). Choice A uses $h_C = 2$ m.',
    hint: 'The resultant force uses the pressure at the centroid: $F_R = \\gamma h_C A$. Use the area of a circle.',
    steps: [
      {
        text: 'Gate area:',
        latex: 'A = \\frac{\\pi D^2}{4} = \\frac{\\pi(1.2)^2}{4} = 1.131\\,\\text{m}^2'
      },
      {
        text: 'Resultant force:',
        latex: 'F_R = \\gamma h_C A = 9{,}810 \\times 4 \\times 1.131 = 44{,}342\\,\\text{N} \\approx 44.4\\,\\text{kN}'
      }
    ],
    handbookPage: 'p. 179',
    handbookFormula: 'F_R = \\gamma h_C A',
    videoUrl: null,
    traps: [
      'Using the top or bottom of the gate instead of the centroid depth',
      'Using the diameter in the force formula instead of computing the area first'
    ],
    diagram: null,
    lessonId: 'hydrostatic-forces-buoyancy',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-hfb-ex2',
    type: 'computational',
    statement: 'A vertical rectangular gate is $1.5\\,\\text{m}$ wide and $2\\,\\text{m}$ tall. Its top edge is $3\\,\\text{m}$ below the water surface. How far below the surface does the resultant hydrostatic force act? Use $I_{xC} = bh^3/12$.',
    choices: [
      {
        id: 'c1',
        text: '$4.08\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$4.0\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$3.33\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$5.0\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The centroid of the gate is at $h_C = 3 + 2/2 = 4.0$ m below the surface. For a vertical surface $y_C = h_C = 4.0$ m. $I_{xC} = bh^3/12 = 1.5(2)^3/12 = 1.0$ m⁴. $A = 1.5 \\times 2 = 3.0$ m². Center of pressure: $y_{CP} = y_C + I_{xC}/(y_C \\times A) = 4.0 + 1.0/(4.0 \\times 3.0) = 4.0 + 0.0833 = 4.083$ m. Choice B gives the centroid (not the center of pressure). Choice C puts the centroid at $3 + 2/6$ (one-third from the top). Choice D uses the bottom of the gate.',
    hint: 'The centroid of the gate is not at the surface -- it is at $3 + h/2$ below the surface. Then apply the center of pressure formula.',
    steps: [
      {
        text: 'Centroid depth below surface:',
        latex: 'y_C = 3 + \\frac{2}{2} = 4.0\\,\\text{m}'
      },
      {
        text: 'Centroidal moment of inertia:',
        latex: 'I_{xC} = \\frac{bh^3}{12} = \\frac{1.5(2)^3}{12} = 1.0\\,\\text{m}^4'
      },
      {
        text: 'Gate area:',
        latex: 'A = 1.5 \\times 2 = 3.0\\,\\text{m}^2'
      },
      {
        text: 'Center of pressure:',
        latex: 'y_{CP} = y_C + \\frac{I_{xC}}{y_C A} = 4.0 + \\frac{1.0}{4.0 \\times 3.0} = 4.0 + 0.083 = 4.08\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 179',
    handbookFormula: 'y_{CP} = y_C + \\frac{I_{xC}}{y_C A}',
    videoUrl: null,
    traps: [
      'Forgetting to add the 3 m submergence when computing the centroid depth',
      'Reporting the centroid instead of the center of pressure'
    ],
    diagram: {
      component: 'SubmergedGate',
      props: {
        width: 1.5,
        height: 2,
        topDepth: 3,
        unit: 'm'
      }
    },
    lessonId: 'hydrostatic-forces-buoyancy',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-hfb-ex3',
    type: 'computational',
    statement: 'A concrete cube ($\\gamma_c = 23{,}500\\,\\text{N/m}^3$) with side length $s = 0.5\\,\\text{m}$ is fully submerged in water ($\\gamma_w = 9{,}810\\,\\text{N/m}^3$). What is the tension in the cable holding it to the bottom if the cube tends to sink?',
    choices: [
      {
        id: 'c1',
        text: '$2.94\\,\\text{kN}$'
      },
      {
        id: 'c2',
        text: '$1.71\\,\\text{kN}$'
      },
      {
        id: 'c3',
        text: 'No cable tension needed; the cube sinks on its own'
      },
      {
        id: 'c4',
        text: '$1.22\\,\\text{kN}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Volume: $V = 0.5^3 = 0.125$ m³. Weight: $W = \\gamma_c \\times V = 23{,}500 \\times 0.125 = 2{,}937.5$ N. Buoyant force: $F_B = \\gamma_w \\times V = 9{,}810 \\times 0.125 = 1{,}226.3$ N. Since $W > F_B$ ($2{,}937.5 > 1{,}226.3$), the cube sinks. A cable holding it to the bottom would go slack because gravity already keeps it down. No cable tension is needed. The question is a trap — it asks about a cable holding the cube to the bottom, but since concrete is denser than water, the cube stays down on its own. Choice B computes $W - F_B$. Choice A gives the weight alone. Choice D gives the buoyant force alone.',
    hint: 'Before computing cable tension, check whether the object actually floats. Compare its weight to the buoyant force.',
    steps: [
      {
        text: 'Volume of the cube:',
        latex: 'V = s^3 = 0.5^3 = 0.125\\,\\text{m}^3'
      },
      {
        text: 'Weight of the cube:',
        latex: 'W = \\gamma_c V = 23{,}500 \\times 0.125 = 2{,}937.5\\,\\text{N}'
      },
      {
        text: 'Buoyant force:',
        latex: 'F_B = \\gamma_w V = 9{,}810 \\times 0.125 = 1{,}226.3\\,\\text{N}'
      },
      {
        text: 'Since $W > F_B$, the cube sinks. No cable tension is needed to hold it down.',
        latex: null
      }
    ],
    handbookPage: 'p. 179',
    handbookFormula: 'F_B = \\gamma V_{\\text{displaced}}',
    videoUrl: null,
    traps: [
      'Blindly computing cable tension without checking if the object floats',
      'Confusing which direction the net force acts -- concrete is denser than water'
    ],
    diagram: null,
    lessonId: 'hydrostatic-forces-buoyancy',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-hfb-ex4',
    type: 'conceptual',
    statement: 'A flat plate is submerged vertically in water. As the plate is pushed deeper (without changing its orientation), what happens to the distance between its centroid and its center of pressure?',
    choices: [
      {
        id: 'c1',
        text: 'The distance increases because pressure increases with depth'
      },
      {
        id: 'c2',
        text: 'The distance decreases because the offset $I_{xC}/(y_C A)$ shrinks as $y_C$ grows'
      },
      {
        id: 'c3',
        text: 'The distance stays the same because it depends only on the plate geometry'
      },
      {
        id: 'c4',
        text: 'The distance decreases to zero and then increases again'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'The center of pressure offset from the centroid is $I_{xC}/(y_C \\times A)$. The moment of inertia $I_{xC}$ and area $A$ are fixed properties of the plate shape. As the plate goes deeper, $y_C$ increases, making the denominator larger and the offset smaller. In the limit, at very large depth the center of pressure essentially coincides with the centroid because the pressure distribution becomes nearly uniform across the plate height. Choice A gets the reasoning backwards. Choice C ignores the $y_C$ term in the denominator. Choice D is wrong — the offset never increases again once the plate goes deeper.',
    hint: 'Look at the formula $y_{CP} - y_C = I_{xC}/(y_C A)$ and consider what happens to the right side as $y_C$ gets large.',
    steps: [
      {
        text: 'Center of pressure offset:',
        latex: 'y_{CP} - y_C = \\frac{I_{xC}}{y_C A}'
      },
      {
        text: '$I_{xC}$ and $A$ are constants of the plate geometry.',
        latex: null
      },
      {
        text: 'As $y_C$ increases (plate goes deeper), the offset decreases toward zero.',
        latex: null
      }
    ],
    handbookPage: 'p. 179',
    handbookFormula: 'y_{CP} = y_C + \\frac{I_{xC}}{y_C A}',
    videoUrl: null,
    traps: [
      'Thinking the offset is constant because $I_{xC}$ and $A$ are constants — $y_C$ is in the denominator',
      'Confusing pressure increase with offset increase'
    ],
    diagram: null,
    lessonId: 'hydrostatic-forces-buoyancy',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-cb-ex1',
    type: 'computational',
    statement: 'Water flows through a pipe that reduces from $D_1 = 200\\,\\text{mm}$ to $D_2 = 100\\,\\text{mm}$. If the velocity in the larger section is $v_1 = 3\\,\\text{m/s}$, what is the velocity in the smaller section?',
    choices: [
      {
        id: 'c1',
        text: '$12\\,\\text{m/s}$'
      },
      {
        id: 'c2',
        text: '$6\\,\\text{m/s}$'
      },
      {
        id: 'c3',
        text: '$48\\,\\text{m/s}$'
      },
      {
        id: 'c4',
        text: '$0.75\\,\\text{m/s}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Continuity says $A_1 v_1 = A_2 v_2$. Since $A = \\pi D^2/4$, the $\\pi/4$ cancels: $v_2 = v_1 \\times (D_1/D_2)^2 = 3 \\times (200/100)^2 = 3 \\times 4 = 12$ m/s. Choice B uses the diameter ratio to the first power (3 x 2 = 6) instead of squaring it. Choice C squares the ratio twice (3 x 16 = 48). Choice D inverts the ratio (3 x 0.25 = 0.75).',
    hint: 'Use the continuity equation. The velocity ratio equals the SQUARE of the diameter ratio, since area goes as $D^2$.',
    steps: [
      {
        text: 'Apply continuity:',
        latex: 'A_1 v_1 = A_2 v_2'
      },
      {
        text: 'For circular pipes, $A = \\pi D^2/4$, so:',
        latex: 'v_2 = v_1 \\times \\left(\\frac{D_1}{D_2}\\right)^2'
      },
      {
        text: 'Calculate:',
        latex: 'v_2 = 3 \\times \\left(\\frac{200}{100}\\right)^2 = 3 \\times 4 = 12\\,\\text{m/s}'
      }
    ],
    handbookPage: 'p. 176',
    handbookFormula: 'A_1 V_1 = A_2 V_2',
    videoUrl: null,
    traps: [
      'Using the diameter ratio to the first power instead of squaring it (gives 6 m/s)',
      'Inverting the ratio (D_2/D_1) instead of (D_1/D_2) (gives 0.75 m/s)'
    ],
    diagram: null,
    lessonId: 'continuity-bernoulli',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-cb-ex2',
    type: 'conceptual',
    statement: 'In Bernoulli\'s equation, as fluid velocity increases in a horizontal pipe, the static pressure:',
    choices: [
      {
        id: 'c1',
        text: 'Increases'
      },
      {
        id: 'c2',
        text: 'Decreases'
      },
      {
        id: 'c3',
        text: 'Remains constant'
      },
      {
        id: 'c4',
        text: 'Depends on the fluid density'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Bernoulli\'s equation shows that for horizontal flow, $P + \\frac{1}{2}\\rho v^2 = \\text{constant}$. If velocity goes up, the dynamic pressure term increases, so static pressure must decrease to keep the total constant. This is the Venturi effect — it is why airplane wings generate lift and why spray bottles work.',
    hint: 'Think about the trade-off between pressure and velocity in Bernoulli\'s equation.',
    steps: [
      {
        text: 'For horizontal flow, Bernoulli simplifies to:',
        latex: 'P + \\frac{1}{2}\\rho v^2 = \\text{constant}'
      },
      {
        text: 'If $v$ increases, $\\frac{1}{2}\\rho v^2$ increases.',
        latex: null
      },
      {
        text: 'Therefore $P$ must decrease to maintain the constant total.',
        latex: null
      }
    ],
    handbookPage: 'p. 176',
    handbookFormula: 'P_1 + \\frac{1}{2}\\rho v_1^2 + \\rho g z_1 = P_2 + \\frac{1}{2}\\rho v_2^2 + \\rho g z_2',
    videoUrl: null,
    traps: ['Thinking higher velocity means higher pressure (the opposite is true)'],
    diagram: null,
    lessonId: 'continuity-bernoulli',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-cb-ex3',
    type: 'computational',
    statement: 'Water ($\\rho = 1{,}000\\,\\text{kg/m}^3$) flows through a horizontal pipe that narrows from $D_1 = 250\\,\\text{mm}$ to $D_2 = 125\\,\\text{mm}$. The velocity in the larger section is $v_1 = 2\\,\\text{m/s}$ and the pressure there is $P_1 = 200\\,\\text{kPa}$. What is the pressure at the smaller section? Assume frictionless flow.',
    choices: [
      {
        id: 'c1',
        text: '$200\\,\\text{kPa}$'
      },
      {
        id: 'c2',
        text: '$170\\,\\text{kPa}$'
      },
      {
        id: 'c3',
        text: '$230\\,\\text{kPa}$'
      },
      {
        id: 'c4',
        text: '$192\\,\\text{kPa}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'First use continuity to find $v_2$: $v_2 = v_1 \\times (D_1/D_2)^2 = 2 \\times (250/125)^2 = 2 \\times 4 = 8$ m/s. Then Bernoulli for a horizontal pipe: $P_2 = P_1 + \\rho/2 \\times (v_1^2 - v_2^2) = 200{,}000 + 500 \\times (4 - 64) = 200{,}000 - 30{,}000 = 170{,}000$ Pa $= 170$ kPa. Pressure drops because velocity increases at the constriction. Choice A assumes no pressure change. Choice C adds instead of subtracting. Choice D uses the diameter ratio to the first power instead of squaring it.',
    hint: 'Use continuity to find $v_2$ first, then apply Bernoulli with $z_1 = z_2$. Pressure drops where velocity increases.',
    steps: [
      {
        text: 'Find $v_2$ from continuity:',
        latex: 'v_2 = v_1 \\left(\\frac{D_1}{D_2}\\right)^2 = 2 \\times \\left(\\frac{250}{125}\\right)^2 = 2 \\times 4 = 8\\,\\text{m/s}'
      },
      {
        text: 'Bernoulli (horizontal, no friction):',
        latex: 'P_2 = P_1 + \\frac{\\rho}{2}(v_1^2 - v_2^2) = 200{,}000 + 500(4 - 64)'
      },
      {
        text: 'Solve:',
        latex: 'P_2 = 200{,}000 - 30{,}000 = 170{,}000\\,\\text{Pa} = 170\\,\\text{kPa}'
      }
    ],
    handbookPage: 'p. 180',
    handbookFormula: '\\frac{P_1}{\\gamma} + \\frac{v_1^2}{2g} + z_1 = \\frac{P_2}{\\gamma} + \\frac{v_2^2}{2g} + z_2',
    videoUrl: null,
    traps: [
      'Using the diameter ratio to the first power instead of squaring it for continuity',
      'Adding the velocity term instead of subtracting -- pressure drops where velocity increases'
    ],
    diagram: null,
    lessonId: 'continuity-bernoulli',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-cb-ex4',
    type: 'computational',
    statement: 'A reservoir feeds water through a pipe that exits as a free jet $12\\,\\text{m}$ below the reservoir surface. The pipe has a friction head loss of $h_f = 1.8\\,\\text{m}$. Using the energy equation and $g = 9.81\\,\\text{m/s}^2$, what is the jet exit velocity? Assume the surface velocity is negligible and both surfaces are at atmospheric pressure.',
    choices: [
      {
        id: 'c1',
        text: '$15.3\\,\\text{m/s}$'
      },
      {
        id: 'c2',
        text: '$14.1\\,\\text{m/s}$'
      },
      {
        id: 'c3',
        text: '$16.6\\,\\text{m/s}$'
      },
      {
        id: 'c4',
        text: '$10.1\\,\\text{m/s}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'This is Torricelli but with friction. The energy equation gives $z_1 = v_2^2/(2g) + z_2 + h_f$. Setting $z_2 = 0$ and $z_1 = 12$ m: $12 = v_2^2/(2 \\times 9.81) + 0 + 1.8$, so $v_2^2/19.62 = 10.2$, $v_2^2 = 200.1$, $v_2 = 14.1$ m/s. Without friction you would get $\\sqrt{2 \\times 9.81 \\times 12} = 15.3$ m/s — that is the trap answer. The friction steals energy, so the actual jet velocity is lower.',
    hint: 'Use the energy equation (Bernoulli + $h_f$). The friction loss reduces the available head from 12 m to $(12 - h_f)$.',
    steps: [
      {
        text: 'Energy equation ($P_1 = P_2 = 0$ gauge, $v_1 \\approx 0$, $z_2 = 0$):',
        latex: 'z_1 = \\frac{v_2^2}{2g} + h_f'
      },
      {
        text: 'Solve for exit velocity:',
        latex: 'v_2 = \\sqrt{2g(z_1 - h_f)} = \\sqrt{2(9.81)(12 - 1.8)}'
      },
      {
        text: 'Compute:',
        latex: 'v_2 = \\sqrt{2(9.81)(10.2)} = \\sqrt{200.1} = 14.1\\,\\text{m/s}'
      }
    ],
    handbookPage: 'p. 180',
    handbookFormula: '\\frac{P_1}{\\gamma} + \\frac{v_1^2}{2g} + z_1 = \\frac{P_2}{\\gamma} + \\frac{v_2^2}{2g} + z_2 + h_f',
    videoUrl: null,
    traps: [
      'Ignoring the friction loss and using pure Torricelli — gives 15.3 m/s instead of 14.1',
      'Adding $h_f$ instead of subtracting it from the available head'
    ],
    diagram: null,
    lessonId: 'continuity-bernoulli',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-pfh-ex1',
    type: 'computational',
    statement: 'Oil ($\\nu = 4.5 \\times 10^{-4}\\,\\text{m}^2/\\text{s}$) flows through a $D = 0.05\\,\\text{m}$ pipe at $v = 0.8\\,\\text{m/s}$. What is the friction factor $f$?',
    choices: [
      {
        id: 'c1',
        text: '$7.2$'
      },
      {
        id: 'c2',
        text: '$0.018$'
      },
      {
        id: 'c3',
        text: '$0.18$'
      },
      {
        id: 'c4',
        text: '$0.72$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'First check the Reynolds number: $Re = vD/\\nu = 0.8 \\times 0.05 / (4.5 \\times 10^{-4}) = 0.04/(4.5 \\times 10^{-4}) = 88.9$. Since $Re < 2{,}100$, the flow is laminar, so $f = 64/Re = 64/88.9 = 0.72$. No Moody diagram needed. Choice B uses $f = 64/Re$ but with $Re = 3{,}556$ (wrong units somewhere). Choice C divides by 10 extra. Choice A multiplies 64 by $Re$ instead of dividing.',
    hint: 'Compute the Reynolds number first. If $Re < 2{,}100$, the flow is laminar and $f = 64/Re$.',
    steps: [
      {
        text: 'Reynolds number:',
        latex: 'Re = \\frac{vD}{\\nu} = \\frac{0.8 \\times 0.05}{4.5 \\times 10^{-4}} = \\frac{0.04}{4.5 \\times 10^{-4}} = 88.9'
      },
      {
        text: 'Since $Re = 88.9 < 2{,}100$, flow is laminar:',
        latex: 'f = \\frac{64}{Re} = \\frac{64}{88.9} = 0.72'
      }
    ],
    handbookPage: 'p. 181',
    handbookFormula: 'f = \\frac{64}{Re} \\quad (\\text{laminar})',
    videoUrl: null,
    traps: [
      'Jumping to the Moody diagram without checking Re first -- this is laminar flow',
      'Using the wrong viscosity (dynamic vs. kinematic) in the Re formula'
    ],
    diagram: null,
    lessonId: 'pipe-flow-head-loss',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-pfh-ex2',
    type: 'computational',
    statement: 'Water flows at $v = 1.5\\,\\text{m/s}$ through a $D = 0.15\\,\\text{m}$, $L = 200\\,\\text{m}$ horizontal pipe. The Darcy friction factor is $f = 0.025$. What is the pressure drop due to friction? Use $\\rho = 1{,}000\\,\\text{kg/m}^3$ and $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$3.83\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$37.5\\,\\text{kPa}$'
      },
      {
        id: 'c3',
        text: '$375\\,\\text{kPa}$'
      },
      {
        id: 'c4',
        text: '$18.75\\,\\text{kPa}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'First find head loss: $h_f = f(L/D)(v^2/2g) = 0.025 \\times (200/0.15) \\times (1.5^2/(2 \\times 9.81)) = 0.025 \\times 1{,}333.3 \\times 0.1147 = 3.823$ m. To get pressure drop: $\\Delta P = \\gamma \\times h_f = \\rho g h_f = 1{,}000 \\times 9.81 \\times 3.823 = 37{,}504$ Pa $= 37.5$ kPa. Choice A gives the head loss in meters but the question asks for pressure drop. Choice C forgot to convert from Pa to kPa. Choice D uses $f/2$ instead of $f$.',
    hint: 'Compute head loss using Darcy-Weisbach, then convert to pressure: $\\Delta P = \\gamma h_f = \\rho g h_f$.',
    steps: [
      {
        text: 'Head loss:',
        latex: 'h_f = f \\frac{L}{D} \\frac{v^2}{2g} = 0.025 \\times \\frac{200}{0.15} \\times \\frac{1.5^2}{2(9.81)}'
      },
      {
        text: 'Compute:',
        latex: 'h_f = 0.025 \\times 1{,}333.3 \\times 0.1147 = 3.82\\,\\text{m}'
      },
      {
        text: 'Convert to pressure drop:',
        latex: '\\Delta P = \\rho g h_f = 1{,}000 \\times 9.81 \\times 3.82 = 37{,}500\\,\\text{Pa} = 37.5\\,\\text{kPa}'
      }
    ],
    handbookPage: 'p. 182',
    handbookFormula: 'h_f = f \\frac{L}{D} \\frac{v^2}{2g}',
    videoUrl: null,
    traps: [
      'Giving the answer in meters of head when the problem asks for pressure in kPa',
      'Forgetting to convert Pa to kPa'
    ],
    diagram: null,
    lessonId: 'pipe-flow-head-loss',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-pfh-ex3',
    type: 'computational',
    statement: 'A $D = 0.3\\,\\text{m}$ pipe carries water at $v = 2\\,\\text{m/s}$. The pipe is $L = 500\\,\\text{m}$ long with $f = 0.018$ and includes a sharp entrance ($C = 0.5$), three $90\\degree$ elbows ($C = 0.9$ each), and an exit ($C = 1.0$). What is the total head loss? Use $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$6.97\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$6.12\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$0.81\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$7.74\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Velocity head $= v^2/(2g) = 4/19.62 = 0.2039$ m. Major loss: $h_f = f(L/D)(v^2/2g) = 0.018 \\times (500/0.3) \\times 0.2039 = 0.018 \\times 1{,}666.7 \\times 0.2039 = 6.117$ m. Minor losses: $\\Sigma C = 0.5 + 3(0.9) + 1.0 = 0.5 + 2.7 + 1.0 = 4.2$. $h_{\\text{minor}} = 4.2 \\times 0.2039 = 0.856$ m. Total $= 6.117 + 0.856 = 6.97$ m. Choice B is the major loss only (forgot minors). Choice C is the minor loss only (forgot major). Choice D uses four elbows instead of three.',
    hint: 'Total head loss = major (friction) + minor (fittings). Compute the velocity head once and use it for both.',
    steps: [
      {
        text: 'Velocity head:',
        latex: '\\frac{v^2}{2g} = \\frac{2^2}{2(9.81)} = 0.2039\\,\\text{m}'
      },
      {
        text: 'Major (friction) loss:',
        latex: 'h_f = f \\frac{L}{D} \\frac{v^2}{2g} = 0.018 \\times \\frac{500}{0.3} \\times 0.2039 = 6.12\\,\\text{m}'
      },
      {
        text: 'Sum of minor loss coefficients:',
        latex: '\\Sigma C = 0.5 + 3(0.9) + 1.0 = 4.2'
      },
      {
        text: 'Minor losses:',
        latex: 'h_{\\text{minor}} = 4.2 \\times 0.2039 = 0.86\\,\\text{m}'
      },
      {
        text: 'Total head loss:',
        latex: 'h_{\\text{total}} = 6.12 + 0.86 = 6.97\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 182',
    handbookFormula: 'h_{f,\\text{total}} = f \\frac{L}{D} \\frac{v^2}{2g} + \\Sigma C \\frac{v^2}{2g}',
    videoUrl: null,
    traps: [
      'Forgetting to include the entrance and exit losses in the minor loss sum',
      'Counting the wrong number of elbows'
    ],
    diagram: null,
    lessonId: 'pipe-flow-head-loss',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-pfh-ex4',
    type: 'conceptual',
    statement: 'A textbook gives the friction factor for a certain pipe as $f_F = 0.005$. This is the Fanning friction factor. What Darcy friction factor should you use in the FE handbook formula $h_f = f(L/D)(v^2/2g)$?',
    choices: [
      {
        id: 'c1',
        text: '$f = 0.00125$'
      },
      {
        id: 'c2',
        text: '$f = 0.005$'
      },
      {
        id: 'c3',
        text: '$f = 0.020$'
      },
      {
        id: 'c4',
        text: '$f = 0.010$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The Darcy friction factor is four times the Fanning friction factor: $f_{\\text{Darcy}} = 4 \\times f_{\\text{Fanning}}$. So $f = 4 \\times 0.005 = 0.020$. The FE handbook and the Moody diagram both use the Darcy factor. If you accidentally use the Fanning factor in the Darcy-Weisbach equation, your head loss will be four times too small. Choice B uses the Fanning factor directly (wrong by 4x). Choice A divides by 4 instead of multiplying. Choice D multiplies by 2 instead of 4.',
    hint: 'The Darcy friction factor is four times the Fanning friction factor: $f_{\\text{Darcy}} = 4 f_{\\text{Fanning}}$.',
    steps: [
      {
        text: 'Relationship between Darcy and Fanning:',
        latex: 'f_{\\text{Darcy}} = 4 f_{\\text{Fanning}}'
      },
      {
        text: 'Convert:',
        latex: 'f = 4 \\times 0.005 = 0.020'
      },
      {
        text: 'The FE handbook uses the Darcy friction factor in the Darcy-Weisbach equation.',
        latex: null
      }
    ],
    handbookPage: 'p. 182',
    handbookFormula: 'h_f = f \\frac{L}{D} \\frac{v^2}{2g}',
    videoUrl: null,
    traps: [
      'Using the Fanning factor directly in the Darcy-Weisbach equation — answer is 4x too small',
      'Dividing instead of multiplying by 4'
    ],
    diagram: null,
    lessonId: 'pipe-flow-head-loss',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-me-ex1',
    type: 'computational',
    statement: 'A water jet ($\\rho = 1{,}000\\,\\text{kg/m}^3$) with velocity $v = 20\\,\\text{m/s}$ and diameter $D = 50\\,\\text{mm}$ strikes a fixed flat plate perpendicular to the jet ($90\\degree$ deflection). What is the force on the plate?',
    choices: [
      {
        id: 'c1',
        text: '$39.3\\,\\text{N}$'
      },
      {
        id: 'c2',
        text: '$393\\,\\text{N}$'
      },
      {
        id: 'c3',
        text: '$1{,}571\\,\\text{N}$'
      },
      {
        id: 'c4',
        text: '$785\\,\\text{N}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'For a jet hitting a flat plate at 90 degrees, the exit flow has no component in the original jet direction. The x-momentum is fully destroyed. $F = \\rho Q v = \\rho A v^2$. Area: $A = \\pi(0.05)^2/4 = 0.001963$ m². $F = 1{,}000 \\times 0.001963 \\times 20^2 = 1{,}000 \\times 0.001963 \\times 400 = 785$ N. Choice B uses $F = \\rho A v$ (forgets to square velocity). Choice C doubles the answer (that would be a 180-degree reversal). Choice A forgets to convert mm to m for the diameter.',
    hint: 'For a flat plate perpendicular to the jet, all x-momentum is absorbed. $F = \\rho A v^2$.',
    steps: [
      {
        text: 'Jet area:',
        latex: 'A = \\frac{\\pi(0.05)^2}{4} = 1.963 \\times 10^{-3}\\,\\text{m}^2'
      },
      {
        text: 'Force (all x-momentum absorbed by the plate):',
        latex: 'F = \\rho A v^2 = 1{,}000 \\times 1.963 \\times 10^{-3} \\times 20^2 = 785\\,\\text{N}'
      }
    ],
    handbookPage: 'p. 186',
    handbookFormula: '\\Sigma F = \\rho Q(v_2 - v_1)',
    videoUrl: null,
    traps: [
      'Doubling the force -- that is for a 180-degree reversal, not a 90-degree plate',
      'Forgetting to convert mm to m for the jet diameter'
    ],
    diagram: null,
    lessonId: 'momentum-equation',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-me-ex2',
    type: 'computational',
    statement: 'Water ($\\rho = 1{,}000\\,\\text{kg/m}^3$) flows through a horizontal $45\\degree$ pipe bend with constant diameter $D = 0.2\\,\\text{m}$. The velocity is $v = 3\\,\\text{m/s}$ and the gauge pressure is $P = 150\\,\\text{kPa}$ throughout the bend. What is the magnitude of the resultant force on the bend?',
    choices: [
      {
        id: 'c1',
        text: '$3.82\\,\\text{kN}$'
      },
      {
        id: 'c2',
        text: '$4.71\\,\\text{kN}$'
      },
      {
        id: 'c3',
        text: '$5.00\\,\\text{kN}$'
      },
      {
        id: 'c4',
        text: '$0.28\\,\\text{kN}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'For a 45-degree bend with constant diameter and pressure: $A = \\pi(0.2)^2/4 = 0.03142$ m². $Q = Av = 0.03142 \\times 3 = 0.09425$ m³/s. $PA = 150{,}000 \\times 0.03142 = 4{,}712$ N. $\\rho Qv = 1{,}000 \\times 0.09425 \\times 3 = 283$ N. For a constant-diameter bend at angle $\\alpha$, $F_x = (PA + \\rho Qv)(1 - \\cos\\alpha)$ and $F_y = (PA + \\rho Qv)\\sin\\alpha$. $F_x = 4{,}995(1 - 0.7071) = 4{,}995 \\times 0.2929 = 1{,}463$ N. $F_y = 4{,}995 \\times 0.7071 = 3{,}532$ N. Resultant: $F_R = \\sqrt{1{,}463^2 + 3{,}532^2} = 3{,}823$ N $= 3.82$ kN. Choice B gives $PA$ only (ignoring momentum direction). Choice C gives $PA + \\rho Qv$ without resolving components. Choice D only includes the momentum term.',
    hint: 'For a constant-diameter bend, both pressure and momentum contribute. Resolve into x and y components and find the resultant.',
    steps: [
      {
        text: 'Pipe area:',
        latex: 'A = \\frac{\\pi(0.2)^2}{4} = 0.03142\\,\\text{m}^2'
      },
      {
        text: 'Flow rate:',
        latex: 'Q = Av = 0.03142 \\times 3 = 0.09425\\,\\text{m}^3/\\text{s}'
      },
      {
        text: 'x-component:',
        latex: 'F_x = (PA + \\rho Qv)(1 - \\cos 45\\degree) = (4{,}712 + 283)(0.2929) = 1{,}463\\,\\text{N}'
      },
      {
        text: 'y-component:',
        latex: 'F_y = (PA + \\rho Qv)\\sin 45\\degree = 4{,}995 \\times 0.7071 = 3{,}532\\,\\text{N}'
      },
      {
        text: 'Resultant:',
        latex: 'F_R = \\sqrt{1{,}463^2 + 3{,}532^2} = 3{,}823\\,\\text{N} \\approx 3.82\\,\\text{kN}'
      }
    ],
    handbookPage: 'p. 186',
    handbookFormula: 'P_1 A_1 - P_2 A_2 \\cos\\alpha - F_x = Q\\rho(v_2 \\cos\\alpha - v_1)',
    videoUrl: null,
    traps: [
      'Forgetting the pressure forces -- they are usually much larger than the momentum forces',
      'Using the bend angle incorrectly in the cosine and sine terms'
    ],
    diagram: {
      component: 'PipeBend',
      props: {
        angle: 45,
        diameter: 0.2,
        velocity: 3,
        pressure: 150
      }
    },
    lessonId: 'momentum-equation',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-me-ex3',
    type: 'computational',
    statement: 'A horizontal pipe reducer narrows from $D_1 = 300\\,\\text{mm}$ to $D_2 = 150\\,\\text{mm}$. Water ($\\rho = 1{,}000\\,\\text{kg/m}^3$) enters at $v_1 = 2\\,\\text{m/s}$ with $P_1 = 250\\,\\text{kPa}$. The exit pressure is $P_2 = 220\\,\\text{kPa}$. What is the net axial force on the reducer? (Positive in the flow direction.)',
    choices: [
      {
        id: 'c1',
        text: '$0.85\\,\\text{kN}$ (in the flow direction)'
      },
      {
        id: 'c2',
        text: '$17.7\\,\\text{kN}$ (in the flow direction)'
      },
      {
        id: 'c3',
        text: '$12.9\\,\\text{kN}$ (in the flow direction)'
      },
      {
        id: 'c4',
        text: '$3.89\\,\\text{kN}$ (against the flow direction)'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$A_1 = \\pi(0.3)^2/4 = 0.07069$ m². $A_2 = \\pi(0.15)^2/4 = 0.01767$ m². By continuity: $v_2 = v_1 \\times (A_1/A_2) = 2 \\times 4 = 8$ m/s. $Q = A_1 \\times v_1 = 0.07069 \\times 2 = 0.1414$ m³/s. Momentum equation in x (flow direction): $F = P_1 A_1 - P_2 A_2 - \\rho Q(v_2 - v_1)$. $P_1 A_1 = 250{,}000 \\times 0.07069 = 17{,}672$ N. $P_2 A_2 = 220{,}000 \\times 0.01767 = 3{,}888$ N. $\\rho Q(v_2 - v_1) = 1{,}000 \\times 0.1414 \\times (8 - 2) = 848$ N. $F = 17{,}672 - 3{,}888 - 848 = 12{,}936$ N $= 12.9$ kN. The net force acts in the flow direction because the large inlet pressure face pushes harder than the small outlet face and the momentum increase combined. Choice B gives $P_1 A_1$ alone. Choice A gives only the momentum change. Choice D gives $P_2 A_2$ in the wrong direction.',
    hint: 'Use continuity to find $v_2$, then apply the momentum equation. Include pressure forces on both faces.',
    steps: [
      {
        text: 'Areas:',
        latex: 'A_1 = \\frac{\\pi(0.3)^2}{4} = 0.07069\\,\\text{m}^2, \\quad A_2 = \\frac{\\pi(0.15)^2}{4} = 0.01767\\,\\text{m}^2'
      },
      {
        text: 'Exit velocity by continuity:',
        latex: 'v_2 = v_1 \\frac{A_1}{A_2} = 2 \\times 4 = 8\\,\\text{m/s}'
      },
      {
        text: 'Flow rate:',
        latex: 'Q = A_1 v_1 = 0.07069 \\times 2 = 0.1414\\,\\text{m}^3/\\text{s}'
      },
      {
        text: 'Momentum equation in x:',
        latex: 'F = P_1 A_1 - P_2 A_2 - \\rho Q(v_2 - v_1)'
      },
      {
        text: 'Compute:',
        latex: 'F = 17{,}672 - 3{,}888 - 848 = 12{,}936\\,\\text{N} \\approx 12.9\\,\\text{kN}'
      }
    ],
    handbookPage: 'p. 186',
    handbookFormula: '\\Sigma F = \\rho Q(v_2 - v_1)',
    videoUrl: null,
    traps: [
      'Forgetting the pressure forces on both the inlet and outlet faces',
      'Not using continuity to find the exit velocity before applying momentum'
    ],
    diagram: null,
    lessonId: 'momentum-equation',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-me-ex4',
    type: 'conceptual',
    statement: 'A water jet strikes a flat plate at $90\\degree$. If the jet velocity is doubled while the jet diameter stays the same, what happens to the force on the plate?',
    choices: [
      {
        id: 'c1',
        text: 'The force doubles'
      },
      {
        id: 'c2',
        text: 'The force quadruples'
      },
      {
        id: 'c3',
        text: 'The force increases by a factor of $\\sqrt{2}$'
      },
      {
        id: 'c4',
        text: 'The force stays the same because area is unchanged'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'For a jet on a flat plate, $F = \\rho A v^2$. The area $A$ stays the same and $\\rho$ is constant, so $F$ is proportional to $v^2$. If velocity doubles, the force increases by $2^2 = 4$. The velocity appears twice: once in the flow rate $Q = Av$ and once in the momentum per unit volume $\\rho v$. Doubling $v$ doubles both $Q$ and the momentum flux, giving a factor of 4. Choice A only accounts for one factor of $v$. Choice C confuses with an energy relationship. Choice D ignores velocity entirely.',
    hint: 'Write the force as $F = \\rho A v^2$ and identify the exponent on $v$.',
    steps: [
      {
        text: 'Force on a flat plate perpendicular to a jet:',
        latex: 'F = \\rho A v^2'
      },
      {
        text: 'Velocity appears squared, so doubling $v$:',
        latex: 'F_{\\text{new}} = \\rho A (2v)^2 = 4 \\rho A v^2 = 4 F_{\\text{original}}'
      }
    ],
    handbookPage: 'p. 186',
    handbookFormula: 'F = \\rho Q v = \\rho A v^2',
    videoUrl: null,
    traps: [
      'Thinking force is proportional to $v$ (linear) — it is proportional to $v^2$',
      'Forgetting that $Q$ itself depends on $v$, so doubling $v$ doubles both $Q$ and the momentum per unit volume'
    ],
    diagram: null,
    lessonId: 'momentum-equation',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-fm-ex1',
    type: 'computational',
    statement: 'A Pitot-static tube in an air duct reads a stagnation pressure of $P_0 = 101.8\\,\\text{kPa}$ and a static pressure of $P_s = 101.3\\,\\text{kPa}$. What is the air velocity? Use $\\rho_{\\text{air}} = 1.2\\,\\text{kg/m}^3$.',
    choices: [
      {
        id: 'c1',
        text: '$408\\,\\text{m/s}$'
      },
      {
        id: 'c2',
        text: '$20.4\\,\\text{m/s}$'
      },
      {
        id: 'c3',
        text: '$0.913\\,\\text{m/s}$'
      },
      {
        id: 'c4',
        text: '$28.9\\,\\text{m/s}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: '$\\Delta P = P_0 - P_s = 101.8 - 101.3 = 0.5$ kPa $= 500$ Pa. $v = \\sqrt{2 \\times \\Delta P/\\rho} = \\sqrt{2 \\times 500/1.2} = \\sqrt{833.3} = 28.87$ m/s, approximately 28.9 m/s. Choice B forgets the factor of 2 under the root (gets $\\sqrt{500/1.2} = \\sqrt{416.7} = 20.4$). Choice C does not convert kPa to Pa (uses 0.5 instead of 500). Choice A uses $\\rho = 0.006$ or some other error making the denominator too small.',
    hint: 'Convert the pressure difference to Pa before plugging in. Remember the factor of 2 in $v = \\sqrt{2\\Delta P/\\rho}$.',
    steps: [
      {
        text: 'Pressure difference:',
        latex: '\\Delta P = 101.8 - 101.3 = 0.5\\,\\text{kPa} = 500\\,\\text{Pa}'
      },
      {
        text: 'Pitot tube velocity:',
        latex: 'v = \\sqrt{\\frac{2 \\Delta P}{\\rho}} = \\sqrt{\\frac{2 \\times 500}{1.2}} = \\sqrt{833.3}'
      },
      {
        text: 'Compute:',
        latex: 'v = 28.9\\,\\text{m/s}'
      }
    ],
    handbookPage: 'p. 194',
    handbookFormula: 'v = \\sqrt{\\frac{2(P_0 - P_s)}{\\rho}}',
    videoUrl: null,
    traps: [
      'Forgetting to convert kPa to Pa — off by a factor of $\\sqrt{1{,}000}$',
      'Dropping the factor of 2 under the radical'
    ],
    diagram: null,
    lessonId: 'flow-measurement',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-fm-ex2',
    type: 'computational',
    statement: 'A horizontal venturi meter has $D_1 = 200\\,\\text{mm}$ and $D_2 = 100\\,\\text{mm}$. The pressure difference is $P_1 - P_2 = 25\\,\\text{kPa}$, and $C_v = 0.97$. What is the flow rate? Use $\\gamma = 9{,}810\\,\\text{N/m}^3$.',
    choices: [
      {
        id: 'c1',
        text: '$0.223\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c2',
        text: '$0.0573\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c3',
        text: '$0.0556\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c4',
        text: '$0.0139\\,\\text{m}^3/\\text{s}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$A_1 = \\pi(0.2)^2/4 = 0.03142$ m². $A_2 = \\pi(0.1)^2/4 = 0.007854$ m². Pressure head $= 25{,}000/9{,}810 = 2.548$ m. Area ratio term: $(A_2/A_1)^2 = (D_2/D_1)^4 = (0.5)^4 = 0.0625$. So $1 - 0.0625 = 0.9375$. Under the root: $2g \\times 2.548/0.9375 = 19.62 \\times 2.548/0.9375 = 50.01/0.9375 = 53.34$. $\\sqrt{53.34} = 7.304$. $Q = 0.97 \\times 0.007854 \\times 7.304 = 0.0556$ m³/s. Choice B omits the velocity coefficient (uses $C_v = 1.0$ giving 0.0573). Choice A uses $A_1$ instead of $A_2$. Choice D uses $(A_2/A_1)$ to the first power instead of squared.',
    hint: 'Convert the pressure drop to head, compute the area ratio correction, and use the throat area $A_2$.',
    steps: [
      {
        text: 'Throat area:',
        latex: 'A_2 = \\frac{\\pi(0.1)^2}{4} = 7.854 \\times 10^{-3}\\,\\text{m}^2'
      },
      {
        text: 'Pressure head:',
        latex: 'h = \\frac{\\Delta P}{\\gamma} = \\frac{25{,}000}{9{,}810} = 2.548\\,\\text{m}'
      },
      {
        text: 'Area ratio correction:',
        latex: '1 - \\left(\\frac{D_2}{D_1}\\right)^4 = 1 - (0.5)^4 = 0.9375'
      },
      {
        text: 'Flow rate:',
        latex: 'Q = C_v A_2 \\sqrt{\\frac{2g \\cdot h}{0.9375}} = 0.97 \\times 7.854 \\times 10^{-3} \\times \\sqrt{\\frac{50.0}{0.9375}}'
      },
      {
        text: 'Compute:',
        latex: 'Q = 0.97 \\times 7.854 \\times 10^{-3} \\times 7.30 = 0.0556\\,\\text{m}^3/\\text{s}'
      }
    ],
    handbookPage: 'p. 195',
    handbookFormula: 'Q = C_v A_2 \\sqrt{\\frac{2g\\left(\\frac{P_1 - P_2}{\\gamma}\\right)}{1 - \\left(\\frac{A_2}{A_1}\\right)^2}}',
    videoUrl: null,
    traps: [
      'Forgetting to square the area ratio in the denominator',
      'Using the upstream area instead of the throat area'
    ],
    diagram: null,
    lessonId: 'flow-measurement',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-fm-ex3',
    type: 'computational',
    statement: 'An orifice plate with diameter $d_0 = 40\\,\\text{mm}$ is installed in a $D = 100\\,\\text{mm}$ horizontal pipe carrying water ($\\gamma = 9{,}810\\,\\text{N/m}^3$). The pressure drop is $\\Delta P = 20\\,\\text{kPa}$ and the orifice discharge coefficient is $C = 0.61$. What is the flow rate?',
    choices: [
      {
        id: 'c1',
        text: '$0.00802\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c2',
        text: '$0.00489\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c3',
        text: '$0.0306\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c4',
        text: '$0.00300\\,\\text{m}^3/\\text{s}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$A_0 = \\pi(0.04)^2/4 = 0.001257$ m². $A_1 = \\pi(0.1)^2/4 = 0.007854$ m². $(A_0/A_1)^2 = (0.001257/0.007854)^2 = (0.16)^2 = 0.02560$. Actually $\\beta = d_0/D = 40/100 = 0.4$, so $\\beta^4 = 0.0256$. $1 - \\beta^4 = 0.9744$. $h = \\Delta P/\\gamma = 20{,}000/9{,}810 = 2.039$ m. Under the root: $2g \\times h/(1 - \\beta^4) = 19.62 \\times 2.039/0.9744 = 40.01/0.9744 = 41.06$. $\\sqrt{41.06} = 6.408$. $Q = C \\times A_0 \\times \\sqrt{\\ldots} = 0.61 \\times 0.001257 \\times 6.408 = 0.004915$ m³/s, approximately 0.00489 m³/s. Choice A uses $C = 1.0$. Choice C uses the pipe area instead of the orifice area. Choice D drops the area ratio correction.',
    hint: 'Use the orifice area $A_0$ (not the pipe area). The discharge coefficient $C$ accounts for the vena contracta.',
    steps: [
      {
        text: 'Orifice area:',
        latex: 'A_0 = \\frac{\\pi(0.04)^2}{4} = 1.257 \\times 10^{-3}\\,\\text{m}^2'
      },
      {
        text: 'Diameter ratio:',
        latex: '\\beta = \\frac{d_0}{D} = 0.4, \\quad \\beta^4 = 0.0256'
      },
      {
        text: 'Pressure head:',
        latex: 'h = \\frac{20{,}000}{9{,}810} = 2.039\\,\\text{m}'
      },
      {
        text: 'Flow rate:',
        latex: 'Q = C A_0 \\sqrt{\\frac{2g \\cdot h}{1 - \\beta^4}} = 0.61 \\times 1.257 \\times 10^{-3} \\times \\sqrt{\\frac{40.0}{0.9744}}'
      },
      {
        text: 'Compute:',
        latex: 'Q = 0.61 \\times 1.257 \\times 10^{-3} \\times 6.41 = 0.00489\\,\\text{m}^3/\\text{s}'
      }
    ],
    handbookPage: 'p. 195',
    handbookFormula: 'Q = C A_0 \\sqrt{\\frac{2g\\left(\\frac{P_1 - P_2}{\\gamma}\\right)}{1 - \\left(\\frac{A_0}{A_1}\\right)^2}}',
    videoUrl: null,
    traps: [
      'Using the pipe area instead of the orifice area',
      'Forgetting the discharge coefficient C -- gives the ideal flow rate'
    ],
    diagram: null,
    lessonId: 'flow-measurement',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-fm-ex4',
    type: 'conceptual',
    statement: 'A venturi meter has a discharge coefficient $C_v = 0.98$ and an orifice plate in the same pipe has a discharge coefficient $C = 0.62$. Which statement best explains the difference?',
    choices: [
      {
        id: 'c1',
        text: 'The venturi has a higher coefficient because its gradual contraction minimizes flow separation and energy loss'
      },
      {
        id: 'c2',
        text: 'The orifice has a lower coefficient because it measures a smaller portion of the flow'
      },
      {
        id: 'c3',
        text: 'The coefficients are interchangeable and the difference is due to manufacturing tolerance'
      },
      {
        id: 'c4',
        text: 'The orifice has a lower coefficient because it is installed at a different location in the pipe'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'A venturi meter has a smooth, gradual contraction followed by a gradual expansion. This streamlined shape keeps the flow attached to the walls, minimizing turbulent losses and vena contracta effects. The result is a coefficient close to 1.0 (typically 0.95 to 0.99). An orifice plate has a sharp edge that causes the flow to separate and contract into a vena contracta downstream. This abrupt geometry causes significant energy loss and a much lower discharge coefficient (typically 0.60 to 0.65). Choice B is wrong — both devices measure the full pipe flow. Choice C is wrong — the difference is fundamental to the geometry, not manufacturing. Choice D is wrong — location does not explain the coefficient difference.',
    hint: 'Think about what happens to the flow as it passes through each device. A sharp edge causes more separation than a gradual contraction.',
    steps: [
      {
        text: 'A venturi has a gradual contraction and expansion, keeping flow attached.',
        latex: null
      },
      {
        text: 'An orifice plate has a sharp edge, causing flow separation and a vena contracta.',
        latex: null
      },
      {
        text: 'More separation means more deviation from ideal Bernoulli behavior, hence a lower coefficient.',
        latex: null
      }
    ],
    handbookPage: 'p. 195',
    handbookFormula: 'Q = C A \\sqrt{\\frac{2g \\Delta h}{1 - (A_2/A_1)^2}}',
    videoUrl: null,
    traps: [
      'Thinking the coefficients are interchangeable or arbitrary',
      'Confusing the discharge coefficient with measurement accuracy'
    ],
    diagram: null,
    lessonId: 'flow-measurement',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-das-ex1',
    type: 'computational',
    statement: 'The drag force $F_D$ on a sphere depends on the fluid density $\\rho$, velocity $v$, diameter $D$, and dynamic viscosity $\\mu$. Using the Buckingham Pi theorem, how many independent dimensionless groups govern this problem?',
    choices: [
      {
        id: 'c1',
        text: '$4$'
      },
      {
        id: 'c2',
        text: '$1$'
      },
      {
        id: 'c3',
        text: '$3$'
      },
      {
        id: 'c4',
        text: '$2$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Count the variables: $F_D$, $\\rho$, $v$, $D$, $\\mu$ = 5 variables. The basic dimensions involved are mass (M), length (L), and time (T), so $r = 3$. By Buckingham Pi: $k = n - r = 5 - 3 = 2$. So there are 2 dimensionless groups. One is typically the drag coefficient $C_D = F_D/(0.5 \\rho v^2 A)$ and the other is the Reynolds number $Re = \\rho v D/\\mu$. Choice B ($k = 1$) subtracts one too many. Choice C uses $r = 2$ instead of 3. Choice A counts all variables as dimensionless groups.',
    hint: 'Count the variables ($n$), count the base dimensions ($r = 3$ for M, L, T), and subtract.',
    steps: [
      {
        text: 'Variables: $F_D, \\rho, v, D, \\mu$:',
        latex: 'n = 5'
      },
      {
        text: 'Base dimensions (M, L, T):',
        latex: 'r = 3'
      },
      {
        text: 'Buckingham Pi:',
        latex: 'k = n - r = 5 - 3 = 2'
      }
    ],
    handbookPage: 'p. 196',
    handbookFormula: 'k = n - r',
    videoUrl: null,
    traps: [
      'Miscounting the variables -- make sure to include the dependent variable (F_D)',
      'Using r = 2 if you forget that force involves mass, length, AND time'
    ],
    diagram: null,
    lessonId: 'dimensional-analysis-similitude',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-das-ex2',
    type: 'computational',
    statement: 'A 1:16 scale model of a spillway is tested using Froude similitude with the same fluid. The prototype discharge is $Q_p = 500\\,\\text{m}^3/\\text{s}$. What model discharge is required?',
    choices: [
      {
        id: 'c1',
        text: '$0.488\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c2',
        text: '$31.25\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c3',
        text: '$1.953\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c4',
        text: '$0.122\\,\\text{m}^3/\\text{s}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Under Froude similitude, velocity scales as $\\sqrt{L_r}$ where $L_r$ is the length ratio. Since $Q = Av$, area scales as $L_r^2$ and velocity as $L_r^{1/2}$, so $Q$ scales as $L_r^{5/2}$. $L_r = 1/16$. $Q_m = Q_p \\times L_r^{5/2} = 500 \\times (1/16)^{5/2} = 500 \\times 1/(16^{2.5}) = 500/(256 \\times 4) = 500/1{,}024 = 0.488$ m³/s. Choice B divides by 16 only (uses $L_r^1$). Choice C divides by $16^2 = 256$ (uses $L_r^2$). Choice D divides by $16^3 = 4{,}096$ (uses $L_r^3$).',
    hint: 'Under Froude similitude, $Q$ scales as $L_r^{5/2}$ because $Q = Av$ and area scales as $L_r^2$ while velocity scales as $L_r^{1/2}$.',
    steps: [
      {
        text: 'Froude velocity scale:',
        latex: 'v_r = \\sqrt{L_r} = \\sqrt{1/16} = 1/4'
      },
      {
        text: 'Area scale:',
        latex: 'A_r = L_r^2 = (1/16)^2 = 1/256'
      },
      {
        text: 'Flow rate scale:',
        latex: 'Q_r = A_r \\cdot v_r = L_r^{5/2} = (1/16)^{5/2} = \\frac{1}{1{,}024}'
      },
      {
        text: 'Model discharge:',
        latex: 'Q_m = 500 \\times \\frac{1}{1{,}024} = 0.488\\,\\text{m}^3/\\text{s}'
      }
    ],
    handbookPage: 'p. 196',
    handbookFormula: 'Fr_m = Fr_p',
    videoUrl: null,
    traps: [
      'Using $Q_r = L_r$ instead of $L_r^{5/2}$',
      'Forgetting that area scales as $L_r^2$ and velocity scales as $L_r^{1/2}$'
    ],
    diagram: null,
    lessonId: 'dimensional-analysis-similitude',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-das-ex3',
    type: 'computational',
    statement: 'A 1:20 scale model of a bridge pier is tested in a wind tunnel. Using Reynolds similitude with the same fluid ($\\nu_m = \\nu_p$), the model experiences a drag force of $F_m = 80\\,\\text{N}$. What is the prototype drag force?',
    choices: [
      {
        id: 'c1',
        text: '$1{,}600\\,\\text{N}$'
      },
      {
        id: 'c2',
        text: '$32{,}000\\,\\text{N}$'
      },
      {
        id: 'c3',
        text: '$80\\,\\text{N}$'
      },
      {
        id: 'c4',
        text: '$4\\,\\text{N}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Under Reynolds similitude with the same fluid, $v_m L_m = v_p L_p$, so $v_m = v_p \\times (L_p/L_m) = 20 v_p$. Force $= \\rho v^2 L^2$ (from dimensional analysis). So $F_r = (v_m/v_p)^2 \\times (L_m/L_p)^2 = 20^2 \\times (1/20)^2 = 400/400 = 1$. The force ratio is 1 — the model force equals the prototype force. $F_p = 80$ N. This is a non-obvious result: with the same fluid and Reynolds similitude, the force on the model equals the force on the prototype. Choice B multiplies by 400. Choice A multiplies by 20. Choice D divides by 20.',
    hint: 'Force scales as $\\rho v^2 L^2$. Under Reynolds similitude with the same fluid, $v_m/v_p = L_p/L_m$. Work out the combined scaling.',
    steps: [
      {
        text: 'Reynolds similitude (same fluid):',
        latex: 'v_m = v_p \\frac{L_p}{L_m} = 20\\,v_p'
      },
      {
        text: 'Force scaling:',
        latex: '\\frac{F_m}{F_p} = \\frac{\\rho_m v_m^2 L_m^2}{\\rho_p v_p^2 L_p^2} = 1 \\times \\left(\\frac{v_m}{v_p}\\right)^2 \\times \\left(\\frac{L_m}{L_p}\\right)^2'
      },
      {
        text: 'Substitute:',
        latex: '\\frac{F_m}{F_p} = 20^2 \\times \\left(\\frac{1}{20}\\right)^2 = 1'
      },
      {
        text: 'Therefore:',
        latex: 'F_p = F_m = 80\\,\\text{N}'
      }
    ],
    handbookPage: 'p. 196',
    handbookFormula: 'Re_m = Re_p',
    videoUrl: null,
    traps: [
      'Scaling force by the length ratio alone -- force involves velocity squared AND length squared',
      'Forgetting that the model velocity is much higher than the prototype velocity under Reynolds similitude'
    ],
    diagram: null,
    lessonId: 'dimensional-analysis-similitude',
    chapterId: 'fluid-mechanics'
  },
  {
    id: 'flu-das-ex4',
    type: 'conceptual',
    statement: 'An engineer needs to build a physical model of an open-channel spillway. Which dimensionless number must be matched between the model and the prototype for dynamic similarity?',
    choices: [
      {
        id: 'c1',
        text: 'Reynolds number, because viscous forces dominate in open channels'
      },
      {
        id: 'c2',
        text: 'Froude number, because gravity forces dominate in open-channel flows'
      },
      {
        id: 'c3',
        text: 'Both Reynolds and Froude numbers must be matched simultaneously'
      },
      {
        id: 'c4',
        text: 'Mach number, because compressibility effects matter at spillway velocities'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'Open-channel flows (spillways, weirs, rivers) are governed by gravity. The Froude number $Fr = v/\\sqrt{gL}$ is the ratio of inertial to gravitational forces. For dynamic similarity in gravity-driven flows, the model must match the prototype Froude number. Reynolds number is for viscous-dominated flows (pipe flow, drag on submerged bodies). Matching both simultaneously at a reduced scale with the same fluid is generally impossible. Mach number is for compressible flow (high-speed aerodynamics), which is irrelevant for water.',
    hint: 'Ask: what is the dominant restoring force? In open channels, it is gravity, and gravity is associated with the Froude number.',
    steps: [
      {
        text: 'Open-channel flow is governed by gravity (free-surface effects).',
        latex: null
      },
      {
        text: 'The Froude number captures the ratio of inertial to gravitational forces:',
        latex: 'Fr = \\frac{v}{\\sqrt{gL}}'
      },
      {
        text: 'For spillway models, match $Fr_m = Fr_p$ (Froude similitude).',
        latex: null
      }
    ],
    handbookPage: 'p. 196',
    handbookFormula: 'Fr = \\frac{v}{\\sqrt{gl}}',
    videoUrl: null,
    traps: [
      'Choosing Reynolds number -- that is for viscous-dominated (closed conduit) problems',
      'Thinking you must match both Re and Fr -- this is generally impossible at reduced scale with the same fluid'
    ],
    diagram: null,
    lessonId: 'dimensional-analysis-similitude',
    chapterId: 'fluid-mechanics'
  },
];

export default PROBLEMS;
