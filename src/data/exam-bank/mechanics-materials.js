// Exam bank: mechanics-materials
// Auto-extracted from lesson files — 33 questions

const PROBLEMS = [
  {
    id: 'mom-asd-ex1',
    type: 'computational',
    statement: 'A steel rod with a cross-sectional area of $500\\,\\text{mm}^2$ and length of $2\\,\\text{m}$ is subjected to a tensile force of $100\\,\\text{kN}$. If $E = 200\\,\\text{GPa}$, what is the elongation?',
    choices: [
      {
        id: 'c1',
        text: '0.5 mm'
      },
      {
        id: 'c2',
        text: '1.0 mm'
      },
      {
        id: 'c3',
        text: '2.0 mm'
      },
      {
        id: 'c4',
        text: '4.0 mm'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'Use $\\delta = PL/(AE)$. $P = 100{,}000$ N, $L = 2{,}000$ mm, $A = 500$ mm$^2$, $E = 200{,}000$ MPa. $\\delta = (100{,}000 \\times 2{,}000)/(500 \\times 200{,}000) = 200{,}000{,}000/100{,}000{,}000 = 2.0$ mm. The main trap is unit confusion -- make sure everything is in consistent units (N, mm, MPa).',
    hint: 'Use the deformation formula $\\delta = PL/(AE)$ with consistent units.',
    steps: [
      {
        text: 'Convert to consistent units: $P = 100{,}000$ N, $L = 2000$ mm, $A = 500$ mm$^2$, $E = 200{,}000$ MPa.',
        latex: null
      },
      {
        text: 'Apply the axial deformation formula:',
        latex: '\\delta = \\frac{PL}{AE} = \\frac{100{,}000 \\times 2000}{500 \\times 200{,}000}'
      },
      {
        text: 'Calculate:',
        latex: '\\delta = \\frac{200{,}000{,}000}{100{,}000{,}000} = 2.0\\,\\text{mm}'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: '\\delta = \\frac{PL}{AE}',
    videoUrl: null,
    traps: ['Unit mismatch between kN/m and mm/MPa', 'Forgetting to convert length to mm'],
    diagram: null,
    lessonId: 'axial-stress-strain-deformation',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-asd-ex2',
    type: 'conceptual',
    statement: 'A material is loaded beyond its yield point and then unloaded. The unloading path on the stress-strain curve:',
    choices: [
      {
        id: 'c1',
        text: 'Follows the original loading curve back to zero'
      },
      {
        id: 'c2',
        text: 'Is a horizontal line back to zero stress'
      },
      {
        id: 'c3',
        text: 'Follows a steeper slope than the original loading'
      },
      {
        id: 'c4',
        text: 'Is parallel to the initial elastic loading line'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'When you unload a material from beyond yield, it springs back elastically -- the unloading line has the same slope as the original elastic region (same $E$). But it does not return to zero strain -- there is permanent plastic deformation. The material "remembers" it was stretched. This is why the unloading line is parallel to, not on, the original curve.',
    hint: 'Think about what property governs the elastic springback during unloading.',
    steps: [
      {
        text: 'During unloading, the material recovers elastically with modulus $E$.',
        latex: null
      },
      {
        text: 'The unloading slope equals the original elastic slope ($E$), so it is parallel.',
        latex: null
      },
      {
        text: 'The offset between loading and unloading paths represents permanent plastic strain.',
        latex: null
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: '\\sigma = E\\varepsilon',
    videoUrl: null,
    traps: [
      'Thinking the material follows the same path back (it does not — plastic deformation is permanent)'
    ],
    diagram: null,
    lessonId: 'axial-stress-strain-deformation',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-asd-ex3',
    type: 'computational',
    statement: 'A composite bar consists of two segments connected end-to-end. Segment 1 is steel ($E = 200\\,\\text{GPa}$, $A = 400\\,\\text{mm}^2$, $L = 600\\,\\text{mm}$) and segment 2 is aluminum ($E = 70\\,\\text{GPa}$, $A = 800\\,\\text{mm}^2$, $L = 900\\,\\text{mm}$). An axial tensile force of $P = 50\\,\\text{kN}$ is applied to the assembly. What is the total elongation?',
    choices: [
      {
        id: 'c1',
        text: '0.375 mm'
      },
      {
        id: 'c2',
        text: '0.803 mm'
      },
      {
        id: 'c3',
        text: '1.18 mm'
      },
      {
        id: 'c4',
        text: '1.56 mm'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'For a multi-segment bar, you compute the deformation of each piece separately and add them up. Steel piece: $50{,}000 \\times 600 / (400 \\times 200{,}000) = 0.375$ mm. Aluminum piece: $50{,}000 \\times 900 / (800 \\times 70{,}000) = 0.803$ mm. Total $= 1.18$ mm. Choice A is just the steel part. Choice B is just the aluminum part. Choice D might come from using the same $E$ for both segments.',
    hint: 'Each segment has its own A and E. Sum the individual deformations: $\\delta_{total} = \\sum PL_i / (A_i E_i)$.',
    steps: [
      {
        text: 'Steel segment deformation:',
        latex: '\\delta_1 = \\frac{PL_1}{A_1 E_1} = \\frac{50{,}000 \\times 600}{400 \\times 200{,}000} = 0.375\\,\\text{mm}'
      },
      {
        text: 'Aluminum segment deformation:',
        latex: '\\delta_2 = \\frac{PL_2}{A_2 E_2} = \\frac{50{,}000 \\times 900}{800 \\times 70{,}000} = 0.803\\,\\text{mm}'
      },
      {
        text: 'Total elongation:',
        latex: '\\delta_{total} = 0.375 + 0.803 = 1.18\\,\\text{mm}'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: '\\delta_{total} = \\sum \\frac{P_i L_i}{A_i E_i}',
    videoUrl: null,
    traps: ['Only computing one segment and forgetting the other', 'Using the same $E$ for both materials'],
    diagram: {
      component: 'CompositeBar',
      props: {
        label1: 'Steel',
        length1: 600,
        label2: 'Aluminum',
        length2: 900,
        lengthUnit: 'mm',
        force: 50,
        forceUnit: 'kN'
      }
    },
    lessonId: 'axial-stress-strain-deformation',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-asd-ex4',
    type: 'computational',
    statement: 'An aluminum rod ($E = 70\\,\\text{GPa}$, $\\alpha = 23 \\times 10^{-6}\\,/\\degree\\text{C}$) is $800\\,\\text{mm}$ long with a cross-sectional area of $600\\,\\text{mm}^2$. It is placed between two rigid walls at $25\\degree\\text{C}$ with a $0.2\\,\\text{mm}$ gap at one end. If the temperature rises to $75\\degree\\text{C}$, what is the compressive stress in the rod?',
    choices: [
      {
        id: 'c1',
        text: '63.0 MPa'
      },
      {
        id: 'c2',
        text: '0 MPa (no stress develops)'
      },
      {
        id: 'c3',
        text: '80.5 MPa'
      },
      {
        id: 'c4',
        text: '17.5 MPa'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'This is a two-part thermal problem. First, check if the free expansion exceeds the gap. Free expansion $= \\alpha L \\Delta T = 23 \\times 10^{-6} \\times 800 \\times 50 = 0.92$ mm, which is bigger than the 0.2 mm gap, so the rod does contact the wall and stress develops. But only the expansion beyond the gap is restrained: $0.92 - 0.20 = 0.72$ mm. The compressive stress is $E \\times (\\delta_{restrained}/L) = 70{,}000 \\times (0.72/800) = 63.0$ MPa. Choice B assumes the gap means no stress ever develops (wrong -- the expansion exceeds the gap). Choice C ignores the gap entirely and uses the full thermal stress $E\\alpha\\Delta T = 80.5$ MPa. Choice D might come from using the wrong $\\alpha$ or $\\Delta T$.',
    hint: 'First check whether the free thermal expansion exceeds the gap. If it does, only the expansion beyond the gap is resisted by the walls.',
    steps: [
      {
        text: 'Temperature change:',
        latex: '\\Delta T = 75 - 25 = 50\\degree\\text{C}'
      },
      {
        text: 'Free thermal expansion:',
        latex: '\\delta_{free} = \\alpha L \\Delta T = 23 \\times 10^{-6} \\times 800 \\times 50 = 0.92\\,\\text{mm}'
      },
      {
        text: 'Since $\\delta_{free} = 0.92 > 0.20\\,\\text{mm gap}$, the rod contacts the wall. The restrained deformation is:',
        latex: '\\delta_{restrained} = 0.92 - 0.20 = 0.72\\,\\text{mm}'
      },
      {
        text: 'Compressive stress from the restrained portion:',
        latex: '\\sigma = E \\cdot \\frac{\\delta_{restrained}}{L} = 70{,}000 \\times \\frac{0.72}{800} = 63.0\\,\\text{MPa}'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: '\\delta_t = \\alpha L (T - T_0)',
    videoUrl: null,
    traps: [
      'Ignoring the gap and computing full thermal stress $E\\alpha\\Delta T = 80.5$ MPa',
      'Assuming zero stress because there is a gap, without checking if expansion exceeds the gap'
    ],
    diagram: {
      component: 'ThermalBar',
      props: {
        length: 800,
        lengthUnit: 'mm',
        gap: 0.2,
        gapUnit: 'mm'
      }
    },
    lessonId: 'axial-stress-strain-deformation',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-tor-ex1',
    type: 'computational',
    statement: 'A solid circular steel shaft has a diameter of $40\\text{ mm}$ and is subjected to a torque of $T = 400\\text{ N}{\\cdot}\\text{m}$. What is the maximum shear stress in the shaft?',
    choices: [
      {
        id: 'c1',
        text: '15.9 MPa'
      },
      {
        id: 'c2',
        text: '31.8 MPa'
      },
      {
        id: 'c3',
        text: '63.7 MPa'
      },
      {
        id: 'c4',
        text: '8.0 MPa'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Straight plug-and-chug with $\\tau = Tc/J$. For a solid shaft, $J = \\pi d^4/32$ and $c = d/2 = 20$ mm. $J = \\pi(40)^4/32 = 251{,}327$ mm$^4$. Then $\\tau = 400{,}000 \\times 20 / 251{,}327 = 31.8$ MPa. Choice A (15.9) comes from using $I = \\pi d^4/64$ instead of $J = \\pi d^4/32$ -- halves $J$ and thus halves the stress. Choice C (63.7) is what you get if you use $c = d = 40$ instead of $c = d/2 = 20$, doubling the answer. Choice D (8.0) comes from an error like using $d^3$ instead of $d^4$ in $J$.',
    hint: 'Remember that $c$ is the radius (not the diameter), and $J = \\pi d^4/32$ for a solid shaft.',
    steps: [
      {
        text: 'Polar moment of inertia:',
        latex: 'J = \\frac{\\pi d^4}{32} = \\frac{\\pi (40)^4}{32} = 251{,}327 \\text{ mm}^4'
      },
      {
        text: 'Outer radius: $c = d/2 = 20$ mm',
        latex: null
      },
      {
        text: 'Convert torque: $T = 400 \\text{ N}{\\cdot}\\text{m} = 400{,}000 \\text{ N}{\\cdot}\\text{mm}$',
        latex: null
      },
      {
        text: 'Max shear stress:',
        latex: '\\tau = \\frac{Tc}{J} = \\frac{400{,}000 \\times 20}{251{,}327} = 31.8 \\text{ MPa}'
      }
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\tau = \\frac{Tr}{J}',
    videoUrl: null,
    traps: [
      'Using diameter instead of radius for $c$ -- doubles the stress',
      'Using $I$ instead of $J$ -- halves the stress'
    ],
    diagram: null,
    lessonId: 'torsion',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-tor-ex2',
    type: 'computational',
    statement: 'A motor delivers $15\\text{ kW}$ of power to a solid circular shaft rotating at $300\\text{ rpm}$. What is the torque in the shaft?',
    choices: [
      {
        id: 'c1',
        text: '477 N$\\cdot$m'
      },
      {
        id: 'c2',
        text: '50 N$\\cdot$m'
      },
      {
        id: 'c3',
        text: '239 N$\\cdot$m'
      },
      {
        id: 'c4',
        text: '7{,}958 N$\\cdot$m'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Power and torque are related by $P = T\\omega$, where $\\omega$ is in rad/s. First convert rpm to rad/s: $\\omega = 300 \\times 2\\pi/60 = 31.42$ rad/s. Then $T = P/\\omega = 15{,}000 / 31.42 = 477$ N$\\cdot$m. Choice B (50) comes from dividing power by rpm directly without converting to rad/s. Choice C (239) comes from forgetting the 2 in the $2\\pi$ conversion (using $\\pi/60$ instead of $2\\pi/60$). Choice D (7,958) comes from multiplying $P$ by $\\omega$ instead of dividing.',
    hint: 'Convert rpm to rad/s first using $\\omega = \\text{rpm} \\times 2\\pi/60$, then use $T = P/\\omega$.',
    steps: [
      {
        text: 'Convert rotational speed to rad/s:',
        latex: '\\omega = 300 \\times \\frac{2\\pi}{60} = 31.42 \\text{ rad/s}'
      },
      {
        text: 'Solve for torque:',
        latex: 'T = \\frac{P}{\\omega} = \\frac{15{,}000}{31.42} = 477 \\text{ N}{\\cdot}\\text{m}'
      }
    ],
    handbookPage: 'p. 133',
    handbookFormula: 'T = \\frac{P}{\\omega}',
    videoUrl: null,
    traps: [
      'Dividing power by rpm without converting to rad/s',
      'Using $\\pi/60$ instead of $2\\pi/60$ for the rpm conversion'
    ],
    diagram: null,
    lessonId: 'torsion',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-tor-ex3',
    type: 'computational',
    statement: 'A hollow steel shaft ($G = 80\\text{ GPa}$) has an outer diameter of $100\\text{ mm}$, an inner diameter of $70\\text{ mm}$, and a length of $2\\text{ m}$. It is subjected to a torque of $T = 5\\text{ kN}{\\cdot}\\text{m}$. What is the angle of twist?',
    choices: [
      {
        id: 'c1',
        text: '$0.0105 \\text{ rad}$'
      },
      {
        id: 'c2',
        text: '$0.0335 \\text{ rad}$'
      },
      {
        id: 'c3',
        text: '$0.0051 \\text{ rad}$'
      },
      {
        id: 'c4',
        text: '$0.0168 \\text{ rad}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Use $\\phi = TL/(GJ)$, but first compute $J$ for the hollow shaft: $J = \\pi(d_o^4 - d_i^4)/32 = \\pi(100^4 - 70^4)/32 = 7{,}456{,}000$ mm$^4$. Then $\\phi = 5{,}000{,}000 \\times 2{,}000 / (80{,}000 \\times 7{,}456{,}000) = 0.0168$ rad. Choice A (0.0105) comes from using $J$ for the solid 100 mm shaft (ignoring the hollow core), which overestimates $J$. Choice B (0.0335) comes from using $I$ instead of $J$. Choice C (0.0051) comes from using the solid shaft $J$ and a shorter length.',
    hint: 'Compute $J$ for a hollow shaft using $J = \\pi(d_o^4 - d_i^4)/32$, then apply $\\phi = TL/(GJ)$.',
    steps: [
      {
        text: 'Polar moment of inertia (hollow):',
        latex: 'J = \\frac{\\pi(d_o^4 - d_i^4)}{32} = \\frac{\\pi(100^4 - 70^4)}{32} = 7{,}456{,}000 \\text{ mm}^4'
      },
      {
        text: 'Convert: $T = 5{,}000{,}000$ N$\\cdot$mm, $L = 2{,}000$ mm, $G = 80{,}000$ MPa',
        latex: null
      },
      {
        text: 'Angle of twist:',
        latex: '\\phi = \\frac{TL}{GJ} = \\frac{5{,}000{,}000 \\times 2{,}000}{80{,}000 \\times 7{,}456{,}000} = 0.0168 \\text{ rad}'
      }
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\phi = \\frac{TL}{GJ}',
    videoUrl: null,
    traps: [
      'Using $J$ for a solid shaft instead of the hollow formula -- underestimates the twist',
      'Forgetting to subtract the inner $d_i^4$ term in $J$'
    ],
    diagram: null,
    lessonId: 'torsion',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-tor-ex4',
    type: 'conceptual',
    statement: 'Two solid circular shafts are made of the same material and have the same length. Shaft A has diameter $d$ and Shaft B has diameter $2d$. If both are subjected to the same torque, what is the ratio of the maximum shear stress in Shaft A to that in Shaft B?',
    choices: [
      {
        id: 'c1',
        text: '2:1'
      },
      {
        id: 'c2',
        text: '4:1'
      },
      {
        id: 'c3',
        text: '8:1'
      },
      {
        id: 'c4',
        text: '16:1'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'For $\\tau = Tc/J$, where $c = d/2$ and $J = \\pi d^4/32$, you can write $\\tau = T(d/2) / (\\pi d^4/32) = 16T/(\\pi d^3)$. So $\\tau$ is proportional to $1/d^3$. When you double the diameter, the stress drops by $2^3 = 8$ times. That means Shaft A (smaller) has 8 times the stress of Shaft B (larger). Choice A (2:1) only accounts for the change in $c$. Choice B (4:1) only accounts for the change in $c^2$ or confuses with area scaling. Choice D (16:1) confuses this with a fourth-power relationship ($J$ scales as $d^4$, but $c/J$ scales as $1/d^3$).',
    hint: 'Express $\\tau_{max}$ in terms of $d$ by substituting $c = d/2$ and $J = \\pi d^4/32$ into $\\tau = Tc/J$.',
    steps: [
      {
        text: 'Simplify the torsion stress formula:',
        latex: '\\tau = \\frac{Tc}{J} = \\frac{T \\cdot (d/2)}{\\pi d^4/32} = \\frac{16T}{\\pi d^3}'
      },
      {
        text: 'Shear stress is proportional to $1/d^3$.',
        latex: null
      },
      {
        text: 'Ratio:',
        latex: '\\frac{\\tau_A}{\\tau_B} = \\frac{d_B^3}{d_A^3} = \\frac{(2d)^3}{d^3} = 8'
      }
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\tau = \\frac{Tc}{J}',
    videoUrl: null,
    traps: [
      'Only considering the change in $c$ (linear with $d$) and ignoring $J$ (fourth power of $d$)',
      'Confusing the $d^4$ scaling of $J$ with the $d^3$ scaling of $\\tau$'
    ],
    diagram: null,
    lessonId: 'torsion',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-ssd-ex1',
    type: 'computational',
    statement: 'During a tensile test, a steel specimen with an original gauge length of $50\\,\\text{mm}$ and original diameter of $12.5\\,\\text{mm}$ is loaded to $42\\,\\text{kN}$ within the elastic range. The measured elongation at this load is $0.171\\,\\text{mm}$. What is the modulus of elasticity of the steel?',
    choices: [
      {
        id: 'c1',
        text: '100 GPa'
      },
      {
        id: 'c2',
        text: '200 GPa'
      },
      {
        id: 'c3',
        text: '150 GPa'
      },
      {
        id: 'c4',
        text: '250 GPa'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'You need to find $E$ from test data. First get the stress: $\\sigma = P/A = 42{,}000 / (\\pi \\times 12.5^2 / 4) = 42{,}000 / 122.7 = 342.3$ MPa. Then get the strain: $\\varepsilon = \\delta/L = 0.171/50 = 0.00342$. Finally $E = \\sigma/\\varepsilon = 342.3 / 0.00342 = 100{,}000$ MPa $= 100$ GPa. Choice B (200 GPa) comes from a decimal error in the strain calculation. Choice C and D are common material values that might tempt guessing.',
    hint: 'Compute stress ($\\sigma = P/A$) and strain ($\\varepsilon = \\delta/L$), then use $E = \\sigma / \\varepsilon$.',
    steps: [
      {
        text: 'Cross-sectional area:',
        latex: 'A = \\frac{\\pi d^2}{4} = \\frac{\\pi (12.5)^2}{4} = 122.7\\,\\text{mm}^2'
      },
      {
        text: 'Stress:',
        latex: '\\sigma = \\frac{P}{A} = \\frac{42{,}000}{122.7} = 342.3\\,\\text{MPa}'
      },
      {
        text: 'Strain:',
        latex: '\\varepsilon = \\frac{\\delta}{L} = \\frac{0.171}{50} = 0.00342'
      },
      {
        text: 'Modulus of elasticity:',
        latex: 'E = \\frac{\\sigma}{\\varepsilon} = \\frac{342.3}{0.00342} \\approx 100{,}000\\,\\text{MPa} = 100\\,\\text{GPa}'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: 'E = \\frac{\\sigma}{\\varepsilon}',
    videoUrl: null,
    traps: [
      'Using diameter instead of radius in the area formula',
      'Forgetting to convert kN to N before computing stress'
    ],
    diagram: null,
    lessonId: 'stress-strain-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-ssd-ex2',
    type: 'computational',
    statement: 'A metal specimen has a modulus of elasticity $E = 110\\,\\text{GPa}$ and Poisson\'s ratio $\\nu = 0.34$. What is the shear modulus $G$ of the material?',
    choices: [
      {
        id: 'c1',
        text: '41.0 GPa'
      },
      {
        id: 'c2',
        text: '37.3 GPa'
      },
      {
        id: 'c3',
        text: '55.0 GPa'
      },
      {
        id: 'c4',
        text: '74.3 GPa'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Straight formula: $G = E / [2(1 + \\nu)] = 110 / [2(1.34)] = 110 / 2.68 = 41.0$ GPa. Choice B (37.3) comes from using $G = E/3$ (wrong formula). Choice C (55.0) comes from $G = E/2$ (forgetting the $1+\\nu$ part). Choice D (74.3) comes from $G = E/(1+\\nu)$ (forgetting the 2 in the denominator). This is one of the easiest formulas in MoM -- just do not forget any part of the denominator.',
    hint: 'There is a direct formula relating $E$, $G$, and $\\nu$.',
    steps: [
      {
        text: 'Apply the elastic constant relationship:',
        latex: 'G = \\frac{E}{2(1+\\nu)} = \\frac{110}{2(1+0.34)} = \\frac{110}{2.68} = 41.0\\,\\text{GPa}'
      }
    ],
    handbookPage: 'p. 130',
    handbookFormula: 'G = \\frac{E}{2(1+\\nu)}',
    videoUrl: null,
    traps: [
      'Using $G = E/2$ without the $(1+\\nu)$ factor gives 55.0 GPa',
      'Using $G = E/(1+\\nu)$ without the 2 gives 74.3 GPa'
    ],
    diagram: null,
    lessonId: 'stress-strain-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-ssd-ex3',
    type: 'computational',
    statement: 'A tensile test specimen has an original gauge length of $200\\,\\text{mm}$ and an original cross-sectional area of $130\\,\\text{mm}^2$. After fracture, the gauge length is $252\\,\\text{mm}$ and the area at the fracture surface is $82\\,\\text{mm}^2$. What is the percent reduction in area?',
    choices: [
      {
        id: 'c1',
        text: '26.0%'
      },
      {
        id: 'c2',
        text: '36.9%'
      },
      {
        id: 'c3',
        text: '58.5%'
      },
      {
        id: 'c4',
        text: '63.1%'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Percent reduction in area $= (A_0 - A_f)/A_0 \\times 100 = (130 - 82)/130 \\times 100 = 48/130 \\times 100 = 36.9\\%$. The percent elongation is $(252 - 200)/200 \\times 100 = 26\\%$ (choice A) -- that is a different ductility measure, not what they asked for. Choice C (58.5%) comes from using $A_f/A_0 \\times 100$ -- that is the remaining fraction, not the reduction. Choice D uses $(A_0 - A_f)/A_f$ instead of $(A_0 - A_f)/A_0$ -- dividing by the final area instead of the original.',
    hint: 'Percent reduction in area uses the original area in the denominator: $\\%RA = (A_0 - A_f) / A_0 \\times 100$.',
    steps: [
      {
        text: 'Percent reduction in area:',
        latex: '\\%RA = \\frac{A_0 - A_f}{A_0} \\times 100 = \\frac{130 - 82}{130} \\times 100 = 36.9\\%'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: '\\%RA = \\frac{A_0 - A_f}{A_0} \\times 100',
    videoUrl: null,
    traps: [
      'Computing percent elongation instead of percent reduction in area',
      'Using final area in the denominator instead of original area'
    ],
    diagram: null,
    lessonId: 'stress-strain-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-ssd-ex4',
    type: 'conceptual',
    statement: 'Two steel specimens are tested in tension. Specimen A has a well-defined upper and lower yield point followed by a long plastic plateau before strain hardening. Specimen B transitions gradually from elastic to plastic behavior with no distinct yield point. Which statement is most accurate?',
    choices: [
      {
        id: 'c1',
        text: 'Specimen A is high-carbon steel; Specimen B is mild (low-carbon) steel'
      },
      {
        id: 'c2',
        text: 'Both specimens are the same type of steel tested at different temperatures'
      },
      {
        id: 'c3',
        text: 'Specimen A has been cold-worked; Specimen B has not'
      },
      {
        id: 'c4',
        text: 'Specimen A is mild (low-carbon) steel; Specimen B is a high-strength alloy steel'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'Mild (low-carbon) steel is the classic material that shows a distinct upper and lower yield point with a yield plateau -- this is Specimen A. High-strength alloy steels and cold-worked metals typically show a gradual transition from elastic to plastic behavior without a sharp yield point, so engineers use the 0.2% offset method to define their yield strength. Choice A has the assignments backwards. Choice B is possible in theory but not the most accurate FE-relevant answer. Choice C is also backwards -- cold working actually removes the yield point, not creates it.',
    hint: 'Think about which type of steel shows a clear yield point with upper/lower yield and a plateau, versus which type requires the 0.2% offset method.',
    steps: [
      {
        text: 'Mild (low-carbon) steel exhibits a distinct upper and lower yield point with a pronounced yield plateau due to dislocation pinning by carbon atoms.',
        latex: null
      },
      {
        text: 'High-strength alloy steels and cold-worked metals have a gradual elastic-to-plastic transition. Their yield strength is defined using the 0.2% offset method.',
        latex: null
      },
      {
        text: 'Cold working removes the yield point from mild steel (Choice D is backwards).',
        latex: null
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: 'E = \\frac{\\sigma}{\\varepsilon}',
    videoUrl: null,
    traps: [
      'Confusing which steel type has the distinct yield point -- it is mild steel, not high-carbon',
      'Thinking cold working creates a yield point -- it actually removes it'
    ],
    diagram: null,
    lessonId: 'stress-strain-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-smd-ex1',
    type: 'computational',
    statement: 'A cantilever beam of length $3\\text{ m}$ carries a concentrated load of $12\\text{ kN}$ at its free end. What is the maximum bending moment in the beam?',
    choices: [
      {
        id: 'c1',
        text: '18 kN$\\cdot$m'
      },
      {
        id: 'c2',
        text: '36 kN$\\cdot$m'
      },
      {
        id: 'c3',
        text: '9 kN$\\cdot$m'
      },
      {
        id: 'c4',
        text: '4 kN$\\cdot$m'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'For a cantilever with a tip load, the max moment occurs at the fixed support and equals $P \\times L = 12 \\times 3 = 36$ kN$\\cdot$m. The moment is zero at the free end and increases linearly to $PL$ at the wall. Choice A (18) comes from using $PL/2$, which is the wrong formula (that is not a standard case). Choice C (9) comes from $PL/4$ (the simply supported midpoint formula, wrong support condition). Choice D (4) comes from $PL/L^2$ or some other error. Always identify the support type first -- cantilever moments are $PL$, not $PL/4$ or $PL/8$.',
    hint: 'For a cantilever beam, where does the maximum moment occur and what is the formula?',
    steps: [
      {
        text: 'Max moment at the fixed support:',
        latex: 'M_{max} = PL = 12 \\times 3 = 36 \\text{ kN}{\\cdot}\\text{m}'
      },
      {
        text: 'The moment diagram is a straight line from 0 at the free end to $PL$ at the wall.',
        latex: null
      }
    ],
    handbookPage: 'p. 140',
    handbookFormula: 'M_{max} = PL \\text{ (cantilever, tip load)}',
    videoUrl: null,
    traps: [
      'Using $PL/4$ (simply supported beam formula) instead of $PL$ for a cantilever',
      'Confusing the free end ($M = 0$) with the fixed end ($M = PL$)'
    ],
    diagram: { component: 'CantileverEndLoad', props: { length: 3, load: 12 } },
    lessonId: 'shear-moment-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-smd-ex2',
    type: 'computational',
    statement: 'A simply supported beam of length $10\\text{ m}$ carries a uniform distributed load of $w = 6\\text{ kN/m}$ over its entire span. What is the maximum shear force in the beam?',
    choices: [
      {
        id: 'c1',
        text: '30 kN'
      },
      {
        id: 'c2',
        text: '60 kN'
      },
      {
        id: 'c3',
        text: '15 kN'
      },
      {
        id: 'c4',
        text: '75 kN'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'For a simply supported beam with a UDL, each reaction equals $wL/2 = 6 \\times 10 / 2 = 30$ kN. The maximum shear occurs at the supports and equals the reaction: $V_{max} = 30$ kN. The shear diagram is a straight line from +30 at the left to $-30$ at the right, crossing zero at midspan. Choice B (60) is the total load $wL$, not the reaction. Choice C (15) comes from $wL/4$, confusing shear with something else. Choice D (75) comes from $wL^2/8$ (that is the max moment formula, not shear, and it does not even have the right units).',
    hint: 'The maximum shear in a simply supported beam with a UDL occurs at the supports. What is the reaction force?',
    steps: [
      {
        text: 'By symmetry, each reaction:',
        latex: 'R = \\frac{wL}{2} = \\frac{6 \\times 10}{2} = 30 \\text{ kN}'
      },
      {
        text: 'Maximum shear occurs at the supports:',
        latex: 'V_{max} = R = 30 \\text{ kN}'
      }
    ],
    handbookPage: 'p. 140',
    handbookFormula: 'V_{max} = \\frac{wL}{2}',
    videoUrl: null,
    traps: [
      'Reporting the total load $wL$ instead of the reaction $wL/2$',
      'Confusing the max shear formula with the max moment formula $wL^2/8$'
    ],
    diagram: { component: 'SSBeamUDL', props: { span: 10, w: 6 } },
    lessonId: 'shear-moment-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-smd-ex3',
    type: 'computational',
    statement: 'A simply supported beam of length $8\\text{ m}$ carries two concentrated loads: $P_1 = 20\\text{ kN}$ at $2\\text{ m}$ from the left support and $P_2 = 40\\text{ kN}$ at $6\\text{ m}$ from the left support. What is the maximum bending moment in the beam?',
    choices: [
      {
        id: 'c1',
        text: '70.0 kN$\\cdot$m'
      },
      {
        id: 'c2',
        text: '60.0 kN$\\cdot$m'
      },
      {
        id: 'c3',
        text: '80.0 kN$\\cdot$m'
      },
      {
        id: 'c4',
        text: '120 kN$\\cdot$m'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'First find the reactions. Sum moments about A: $R_B \\times 8 = 20 \\times 2 + 40 \\times 6 = 40 + 240 = 280$, so $R_B = 35$ kN. Then $R_A = 20 + 40 - 35 = 25$ kN. Check the moment at each load point: at $x = 2$ m, $M = 25 \\times 2 = 50$ kN$\\cdot$m. At $x = 6$ m, $M = 25 \\times 6 - 20 \\times 4 = 150 - 80 = 70$ kN$\\cdot$m (or from the right: $R_B \\times 2 = 35 \\times 2 = 70$). The maximum is 70 kN$\\cdot$m under the 40 kN load. Choice B (60) might come from an arithmetic error with the reactions. Choice C (80) comes from $R_B \\times (8-6)$ plus something wrong. Choice D (120) comes from adding the moments at both load points ($50 + 70$), which makes no physical sense.',
    hint: 'Find both reactions using equilibrium, then compute the moment at each load location. The maximum moment occurs under one of the loads.',
    steps: [
      {
        text: 'Sum moments about A:',
        latex: 'R_B \\times 8 = 20 \\times 2 + 40 \\times 6 = 280 \\implies R_B = 35 \\text{ kN}'
      },
      {
        text: 'Vertical equilibrium:',
        latex: 'R_A = 20 + 40 - 35 = 25 \\text{ kN}'
      },
      {
        text: 'Moment at $x = 2$ m:',
        latex: 'M_1 = 25 \\times 2 = 50 \\text{ kN}{\\cdot}\\text{m}'
      },
      {
        text: 'Moment at $x = 6$ m:',
        latex: 'M_2 = 25 \\times 6 - 20 \\times 4 = 70 \\text{ kN}{\\cdot}\\text{m}'
      },
      {
        text: 'Maximum moment: $M_{max} = 70$ kN$\\cdot$m (under the 40 kN load)',
        latex: null
      }
    ],
    handbookPage: 'p. 134',
    handbookFormula: 'M_2 - M_1 = \\int_{x_1}^{x_2} V(x)\\,dx',
    videoUrl: null,
    traps: [
      'Only checking the moment under one load and missing the larger one',
      'Using the full load instead of reactions to compute moments'
    ],
    diagram: {
      component: 'SSBeamTwoLoads',
      props: {
        span: 8,
        pos1: 2,
        load1: 20,
        pos2: 6,
        load2: 40
      }
    },
    lessonId: 'shear-moment-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-smd-ex4',
    type: 'conceptual',
    statement: 'On a shear diagram for a simply supported beam carrying a uniform distributed load, the shear is zero at a certain point. What is true about the bending moment at that same point?',
    choices: [
      {
        id: 'c1',
        text: 'The bending moment is also zero'
      },
      {
        id: 'c2',
        text: 'The bending moment changes sign'
      },
      {
        id: 'c3',
        text: 'The bending moment has a maximum or minimum value'
      },
      {
        id: 'c4',
        text: 'The bending moment has an inflection point'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The relationship $dM/dx = V$ means the slope of the moment diagram equals the shear. When $V = 0$, the slope of the moment diagram is zero, which means the moment is at a peak or valley (a local maximum or minimum). For a simply supported beam with UDL, $V = 0$ at midspan, and that is exactly where the moment reaches its maximum value. Choice A is wrong because $M$ is not zero where $V$ is zero ($M$ is at its peak there). Choice B is wrong because the moment does not change sign at that point -- it is at its maximum. Choice D describes a change in curvature of the deflection curve, which is related to $M$ changing sign, not $V$.',
    hint: 'Recall the relationship $dM/dx = V$. What happens to a function when its derivative is zero?',
    steps: [
      {
        text: 'From calculus, $V = dM/dx$. When $V = 0$, the slope of the moment diagram is zero.',
        latex: null
      },
      {
        text: 'A zero slope means the moment is at a local maximum or minimum (a critical point).',
        latex: null
      },
      {
        text: 'For a UDL on a simply supported beam, $V = 0$ at midspan, which is where $M_{max}$ occurs.',
        latex: null
      }
    ],
    handbookPage: 'p. 134',
    handbookFormula: 'V = \\frac{dM}{dx}',
    videoUrl: null,
    traps: [
      'Thinking that $M = 0$ where $V = 0$ -- these are different conditions',
      'Confusing a moment peak (where $V$ crosses zero) with a moment sign change (where $M$ crosses zero)'
    ],
    diagram: null,
    lessonId: 'shear-moment-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bss-ex1',
    type: 'computational',
    statement: 'A rectangular timber beam ($b = 150\\text{ mm}$, $h = 300\\text{ mm}$) carries a maximum bending moment of $M = 18\\text{ kN}{\\cdot}\\text{m}$. What is the maximum bending stress?',
    choices: [
      {
        id: 'c1',
        text: '4.0 MPa'
      },
      {
        id: 'c2',
        text: '16.0 MPa'
      },
      {
        id: 'c3',
        text: '8.0 MPa'
      },
      {
        id: 'c4',
        text: '2.67 MPa'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'Use $\\sigma = M/S$ where $S = bh^2/6$. $S = 150 \\times 300^2 / 6 = 150 \\times 90{,}000 / 6 = 2{,}250{,}000$ mm$^3$. Then $\\sigma = 18{,}000{,}000 / 2{,}250{,}000 = 8.0$ MPa. Choice A (4.0) comes from using $bh^3/12$ incorrectly or swapping $b$ and $h$. Choice B (16.0) comes from using $c = h = 300$ instead of $c = h/2 = 150$. Choice D (2.67) comes from dividing by $I$ without multiplying by $c$, or some other dimensional error.',
    hint: 'Use the section modulus shortcut: $S = bh^2/6$ and $\\sigma = M/S$.',
    steps: [
      {
        text: 'Section modulus:',
        latex: 'S = \\frac{bh^2}{6} = \\frac{150 \\times 300^2}{6} = 2{,}250{,}000 \\text{ mm}^3'
      },
      {
        text: 'Convert moment: $M = 18 \\times 10^6$ N$\\cdot$mm',
        latex: null
      },
      {
        text: 'Max bending stress:',
        latex: '\\sigma = \\frac{M}{S} = \\frac{18 \\times 10^6}{2{,}250{,}000} = 8.0 \\text{ MPa}'
      }
    ],
    handbookPage: 'p. 135',
    handbookFormula: '\\sigma = \\frac{Mc}{I}',
    videoUrl: null,
    traps: [
      'Using $c = h$ (full depth) instead of $c = h/2$ -- doubles the stress',
      'Swapping $b$ and $h$ in the $I = bh^3/12$ formula'
    ],
    diagram: { component: 'RectangleInertia', props: { width: 150, height: 300 } },
    lessonId: 'bending-shear-stresses',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bss-ex2',
    type: 'computational',
    statement: 'A rectangular beam ($200\\text{ mm}$ wide by $400\\text{ mm}$ deep) carries a maximum shear force of $V = 80\\text{ kN}$. What is the maximum transverse shear stress?',
    choices: [
      {
        id: 'c1',
        text: '1.00 MPa'
      },
      {
        id: 'c2',
        text: '1.50 MPa'
      },
      {
        id: 'c3',
        text: '2.00 MPa'
      },
      {
        id: 'c4',
        text: '3.00 MPa'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'For a rectangular section, use the shortcut $\\tau_{max} = 3V/(2A)$. $A = 200 \\times 400 = 80{,}000$ mm$^2$. $\\tau = 3 \\times 80{,}000 / (2 \\times 80{,}000) = 1.50$ MPa. Choice A (1.00) is just $V/A$, the average shear stress, forgetting the 3/2 factor. Choice C (2.00) might come from using $2V/A$. Choice D (3.00) uses $3V/A$, forgetting the 2 in the denominator. The 3/2 factor accounts for the parabolic distribution of shear stress in a rectangle.',
    hint: 'For a rectangular cross-section, there is a shortcut formula for the maximum shear stress at the neutral axis.',
    steps: [
      {
        text: 'Cross-sectional area:',
        latex: 'A = 200 \\times 400 = 80{,}000 \\text{ mm}^2'
      },
      {
        text: 'Max shear stress at the neutral axis:',
        latex: '\\tau_{max} = \\frac{3V}{2A} = \\frac{3 \\times 80{,}000}{2 \\times 80{,}000} = 1.50 \\text{ MPa}'
      }
    ],
    handbookPage: 'p. 135',
    handbookFormula: '\\tau = \\frac{VQ}{Ib}',
    videoUrl: null,
    traps: [
      'Using $V/A$ (average shear) instead of $3V/(2A)$ (max shear) for a rectangle',
      'Applying the $3V/(2A)$ shortcut to a non-rectangular section -- it only works for rectangles'
    ],
    diagram: { component: 'RectangleInertia', props: { width: 200, height: 400 } },
    lessonId: 'bending-shear-stresses',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bss-ex3',
    type: 'computational',
    statement: 'A steel W-shape beam has a section modulus of $S = 1{,}200 \\times 10^3\\text{ mm}^3$ and a cross-sectional area of $A = 8{,}500\\text{ mm}^2$. It carries a uniform distributed load that produces a maximum moment of $M = 300\\text{ kN}{\\cdot}\\text{m}$. What is the maximum bending stress?',
    choices: [
      {
        id: 'c1',
        text: '250 MPa'
      },
      {
        id: 'c2',
        text: '35.3 MPa'
      },
      {
        id: 'c3',
        text: '125 MPa'
      },
      {
        id: 'c4',
        text: '500 MPa'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'When $S$ is given directly (as it is for all steel shapes in tables), you skip $I$ and $c$ entirely. $\\sigma = M/S = 300{,}000{,}000 / 1{,}200{,}000 = 250$ MPa. Choice B (35.3) comes from dividing $M$ by $A$ instead of $S$ -- that gives an axial stress, not bending stress. Choice C (125) comes from dividing by $2S$, as if you halved the section modulus. Choice D (500) comes from using $S/2$ or some doubling error. The section modulus $S$ is the single most useful property for beam design -- it combines $I$ and $c$ into one number.',
    hint: 'When the section modulus $S$ is provided, the bending stress formula simplifies to $\\sigma = M/S$.',
    steps: [
      {
        text: 'Convert moment: $M = 300 \\times 10^6$ N$\\cdot$mm',
        latex: null
      },
      {
        text: 'Max bending stress:',
        latex: '\\sigma = \\frac{M}{S} = \\frac{300 \\times 10^6}{1{,}200 \\times 10^3} = 250 \\text{ MPa}'
      }
    ],
    handbookPage: 'p. 135',
    handbookFormula: '\\sigma = \\frac{M}{S}',
    videoUrl: null,
    traps: [
      'Dividing $M$ by $A$ instead of $S$ -- that gives axial stress, not bending stress',
      'Forgetting to convert kN$\\cdot$m to N$\\cdot$mm before dividing by $S$ in mm$^3$'
    ],
    diagram: null,
    lessonId: 'bending-shear-stresses',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bss-ex4',
    type: 'conceptual',
    statement: 'In a simply supported beam with a rectangular cross-section under a transverse load, where does the maximum transverse shear stress occur within the cross-section?',
    choices: [
      {
        id: 'c1',
        text: 'At the top fiber (outermost compression fiber)'
      },
      {
        id: 'c2',
        text: 'At the bottom fiber (outermost tension fiber)'
      },
      {
        id: 'c3',
        text: 'At the neutral axis'
      },
      {
        id: 'c4',
        text: 'At a point halfway between the neutral axis and the top fiber'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'Bending stress and shear stress peak at opposite locations in the cross-section. Bending stress is maximum at the extreme fibers (top and bottom) and zero at the neutral axis. Shear stress is the exact opposite -- it is maximum at the neutral axis and zero at the top and bottom surfaces. For a rectangular beam, the shear distribution is parabolic with the peak at the center. This is why the $3V/(2A)$ formula gives you the stress at the neutral axis. Choices A and B are where bending stress peaks, not shear. Choice D describes no special location in the parabolic distribution.',
    hint: 'Think about the shear stress distribution across a rectangular section. Where is the parabolic curve at its peak?',
    steps: [
      {
        text: 'Shear stress distribution in a rectangular beam is parabolic: zero at the outer fibers, maximum at the neutral axis.',
        latex: null
      },
      {
        text: 'This is the opposite of bending stress, which is maximum at the extreme fibers and zero at the neutral axis.',
        latex: null
      },
      {
        text: 'The maximum shear stress at the NA is:',
        latex: '\\tau_{max} = \\frac{3V}{2A} = 1.5 \\times \\frac{V}{A}'
      }
    ],
    handbookPage: 'p. 135',
    handbookFormula: '\\tau = \\frac{VQ}{Ib}',
    videoUrl: null,
    traps: [
      'Confusing the location of max bending stress (extreme fibers) with max shear stress (neutral axis)',
      'Assuming shear stress is uniform across the section'
    ],
    diagram: null,
    lessonId: 'bending-shear-stresses',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bd-ex1',
    type: 'computational',
    statement: 'A simply supported steel beam ($E = 200\\text{ GPa}$, $I = 40 \\times 10^6\\text{ mm}^4$) has a span of $5\\text{ m}$ and carries a uniform distributed load of $w = 10\\text{ kN/m}$ over its entire length. What is the maximum deflection at midspan?',
    choices: [
      {
        id: 'c1',
        text: '10.2 mm'
      },
      {
        id: 'c2',
        text: '5.09 mm'
      },
      {
        id: 'c3',
        text: '20.3 mm'
      },
      {
        id: 'c4',
        text: '40.7 mm'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Simply supported beam with UDL: $\\delta = 5wL^4 / (384EI)$. Note the 5 in the numerator and $L$ to the fourth power. $w = 10$ N/mm, $L = 5{,}000$ mm, $E = 200{,}000$ MPa, $I = 40 \\times 10^6$ mm$^4$. $\\delta = 5 \\times 10 \\times 5{,}000^4 / (384 \\times 200{,}000 \\times 40 \\times 10^6) = 10.2$ mm. Choice B (5.09) comes from forgetting the 5 in the numerator (using $wL^4/(384EI)$ instead of $5wL^4/(384EI)$). Choice C (20.3) comes from using $5wL^4/(192EI)$ (halving the denominator). Choice D (40.7) comes from using the cantilever formula $wL^4/(8EI)$.',
    hint: 'Look up the deflection formula for a simply supported beam with UDL. Do not forget the coefficient in the numerator.',
    steps: [
      {
        text: 'Convert: $w = 10$ N/mm, $L = 5{,}000$ mm, $E = 200{,}000$ MPa, $I = 40 \\times 10^6$ mm$^4$',
        latex: null
      },
      {
        text: 'Max deflection at midspan:',
        latex: '\\delta = \\frac{5wL^4}{384EI} = \\frac{5 \\times 10 \\times (5{,}000)^4}{384 \\times 200{,}000 \\times 40 \\times 10^6} = 10.2 \\text{ mm}'
      }
    ],
    handbookPage: 'p. 140',
    handbookFormula: '\\delta_{max} = \\frac{5wL^4}{384EI}',
    videoUrl: null,
    traps: [
      'Forgetting the 5 in the numerator of $5wL^4/(384EI)$ -- halves the deflection',
      'Using the cantilever UDL formula $wL^4/(8EI)$ instead of simply supported'
    ],
    diagram: { component: 'SSBeamUDL', props: { span: 5, w: 10 } },
    lessonId: 'beam-deflections',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bd-ex2',
    type: 'computational',
    statement: 'A cantilever beam ($E = 200\\text{ GPa}$, $I = 25 \\times 10^6\\text{ mm}^4$) is $2\\text{ m}$ long and carries a concentrated load of $P = 10\\text{ kN}$ at its free end. What is the maximum deflection?',
    choices: [
      {
        id: 'c1',
        text: '1.78 mm'
      },
      {
        id: 'c2',
        text: '5.33 mm'
      },
      {
        id: 'c3',
        text: '10.7 mm'
      },
      {
        id: 'c4',
        text: '0.333 mm'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Cantilever with a tip load: $\\delta = PL^3 / (3EI)$. $P = 10{,}000$ N, $L = 2{,}000$ mm. $\\delta = 10{,}000 \\times 2{,}000^3 / (3 \\times 200{,}000 \\times 25 \\times 10^6) = 5.33$ mm. Choice A (1.78) comes from using $PL^3/(9EI)$ or some factor error. Choice C (10.7) comes from using $PL^3/(1.5EI)$ (forgetting the 3 is already in there and doubling). Choice D (0.333) comes from using the simply supported formula $PL^3/(48EI)$ instead of the cantilever $PL^3/(3EI)$ -- that is 16 times smaller.',
    hint: 'Identify this as a cantilever with a tip load. The deflection formula has a small denominator compared to simply supported beams.',
    steps: [
      {
        text: 'Convert: $P = 10{,}000$ N, $L = 2{,}000$ mm',
        latex: null
      },
      {
        text: 'Max deflection at the free end:',
        latex: '\\delta = \\frac{PL^3}{3EI} = \\frac{10{,}000 \\times (2{,}000)^3}{3 \\times 200{,}000 \\times 25 \\times 10^6} = 5.33 \\text{ mm}'
      }
    ],
    handbookPage: 'p. 141',
    handbookFormula: '\\delta_{max} = \\frac{PL^3}{3EI}',
    videoUrl: null,
    traps: [
      'Using the simply supported formula $PL^3/(48EI)$ instead of the cantilever $PL^3/(3EI)$',
      'Mixing up the 3 in the denominator with another coefficient'
    ],
    diagram: { component: 'CantileverEndLoad', props: { length: 2, load: 10 } },
    lessonId: 'beam-deflections',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bd-ex3',
    type: 'computational',
    statement: 'A simply supported steel beam ($E = 200\\text{ GPa}$, $I = 60 \\times 10^6\\text{ mm}^4$) has a span of $4\\text{ m}$. It carries both a concentrated load of $P = 15\\text{ kN}$ at midspan and a uniform distributed load of $w = 6\\text{ kN/m}$ over the entire span. What is the total maximum deflection at midspan?',
    choices: [
      {
        id: 'c1',
        text: '1.67 mm'
      },
      {
        id: 'c2',
        text: '6.67 mm'
      },
      {
        id: 'c3',
        text: '3.33 mm'
      },
      {
        id: 'c4',
        text: '26.7 mm'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Use superposition: compute the deflection from each load separately, then add. The point load gives $\\delta_P = PL^3/(48EI) = 1.67$ mm. The UDL gives $\\delta_w = 5wL^4/(384EI) = 1.67$ mm. Total $= 1.67 + 1.67 = 3.33$ mm. Choice A (1.67) is only one of the two deflections -- you forgot the other load. Choice B (6.67) comes from doubling the answer or using the wrong coefficient. Choice D (26.7) comes from using the cantilever formula $PL^3/(3EI)$ for one of the loads. The most common mistake on this type of problem is computing only one load case and stopping there.',
    hint: 'When a beam has multiple load types, use superposition: calculate the deflection from each load separately and add them together.',
    steps: [
      {
        text: 'Deflection from point load:',
        latex: '\\delta_P = \\frac{PL^3}{48EI} = \\frac{15{,}000 \\times (4{,}000)^3}{48 \\times 200{,}000 \\times 60 \\times 10^6} = 1.67 \\text{ mm}'
      },
      {
        text: 'Deflection from UDL:',
        latex: '\\delta_w = \\frac{5wL^4}{384EI} = \\frac{5 \\times 6 \\times (4{,}000)^4}{384 \\times 200{,}000 \\times 60 \\times 10^6} = 1.67 \\text{ mm}'
      },
      {
        text: 'Total by superposition:',
        latex: '\\delta_{total} = 1.67 + 1.67 = 3.33 \\text{ mm}'
      }
    ],
    handbookPage: 'p. 140',
    handbookFormula: '\\delta = \\frac{PL^3}{48EI} + \\frac{5wL^4}{384EI}',
    videoUrl: null,
    traps: [
      'Only computing one of the two deflections and forgetting the other load',
      'Forgetting the 5 in the numerator of the UDL formula $5wL^4/(384EI)$'
    ],
    diagram: {
      component: 'SSBeamCombined',
      props: {
        span: 4,
        P: 15,
        w: 6
      }
    },
    lessonId: 'beam-deflections',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bd-ex4',
    type: 'conceptual',
    statement: 'A simply supported beam has a uniform load. If the span is doubled while everything else (w, E, I) remains constant, the maximum deflection will increase by a factor of:',
    choices: [
      {
        id: 'c1',
        text: '2'
      },
      {
        id: 'c2',
        text: '4'
      },
      {
        id: 'c3',
        text: '8'
      },
      {
        id: 'c4',
        text: '16'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'The deflection formula for a simply supported beam with UDL is $\\delta = 5wL^4 / (384EI)$. Deflection is proportional to $L^4$. Double the span and the deflection increases by $2^4 = 16$ times. This is why span length is so critical in beam design -- a modest increase in span causes deflection to explode. Choice A (2) only counts $L$ to the first power. Choice B (4) treats it as $L^2$. Choice C (8) treats it as $L^3$ (that is what happens with a point load, $PL^3/(48EI)$). The fourth-power dependence on $L$ is a direct consequence of the distributed load acting over a longer length.',
    hint: 'Look at the deflection formula for a UDL on a simply supported beam. What power of $L$ appears?',
    steps: [
      {
        text: 'Deflection formula:',
        latex: '\\delta = \\frac{5wL^4}{384EI}'
      },
      {
        text: 'Deflection is proportional to $L^4$.',
        latex: null
      },
      {
        text: 'Doubling $L$:',
        latex: '\\frac{\\delta_{2L}}{\\delta_L} = \\frac{(2L)^4}{L^4} = 2^4 = 16'
      }
    ],
    handbookPage: 'p. 140',
    handbookFormula: '\\delta_{max} = \\frac{5wL^4}{384EI}',
    videoUrl: null,
    traps: [
      'Confusing $L^4$ (UDL) with $L^3$ (point load) -- the exponent changes with load type',
      'Forgetting that $w$ stays constant (per unit length), so the total load also doubles, but that is already captured in the $L^4$ term'
    ],
    diagram: null,
    lessonId: 'beam-deflections',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-csm-ex1',
    type: 'computational',
    statement: 'At a point in a loaded member, the stress state is $\\sigma_x = 100\\text{ MPa}$, $\\sigma_y = -40\\text{ MPa}$, and $\\tau_{xy} = 0$. What is the maximum in-plane shear stress?',
    choices: [
      {
        id: 'c1',
        text: '30 MPa'
      },
      {
        id: 'c2',
        text: '70 MPa'
      },
      {
        id: 'c3',
        text: '50 MPa'
      },
      {
        id: 'c4',
        text: '140 MPa'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The max in-plane shear stress is $R$, the radius of Mohr\'s circle. $R = \\sqrt{((\\sigma_x - \\sigma_y)/2)^2 + \\tau_{xy}^2}$. With $\\tau_{xy} = 0$, $R = |\\sigma_x - \\sigma_y|/2 = |100 - (-40)|/2 = 140/2 = 70$ MPa. Choice A (30) is the center $C = (100 + (-40))/2 = 30$ -- that is the average normal stress, not the shear. Choice C (50) comes from using $|\\sigma_x + \\sigma_y|/2$ instead of the difference. Choice D (140) forgets to divide by 2. Even when $\\tau_{xy} = 0$, there can still be in-plane shear on a rotated plane.',
    hint: 'The in-plane max shear stress equals the radius $R$ of Mohr\'s circle. What is $R$ when $\\tau_{xy} = 0$?',
    steps: [
      {
        text: 'Center:',
        latex: 'C = \\frac{100 + (-40)}{2} = 30 \\text{ MPa}'
      },
      {
        text: 'Radius:',
        latex: 'R = \\sqrt{\\left(\\frac{100 - (-40)}{2}\\right)^2 + 0^2} = \\frac{140}{2} = 70 \\text{ MPa}'
      },
      {
        text: 'Max in-plane shear stress: $\\tau_{max} = R = 70$ MPa',
        latex: null
      }
    ],
    handbookPage: 'p. 132',
    handbookFormula: '\\tau_{max} = R = \\sqrt{\\left(\\frac{\\sigma_x - \\sigma_y}{2}\\right)^2 + \\tau_{xy}^2}',
    videoUrl: null,
    traps: [
      'Reporting the center $C = 30$ MPa instead of the radius $R = 70$ MPa',
      'Forgetting to divide by 2 when computing $R$ from $\\sigma_x - \\sigma_y$'
    ],
    diagram: {
      component: 'StressElement',
      props: {
        sigmaX: 100,
        sigmaY: -40,
        tauXY: 0
      }
    },
    lessonId: 'combined-stresses-mohrs-circle',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-csm-ex2',
    type: 'computational',
    statement: 'A stress element has $\\sigma_x = 50\\text{ MPa}$, $\\sigma_y = -30\\text{ MPa}$, and $\\tau_{xy} = 30\\text{ MPa}$. What is the maximum principal stress $\\sigma_1$?',
    choices: [
      {
        id: 'c1',
        text: '60 MPa'
      },
      {
        id: 'c2',
        text: '50 MPa'
      },
      {
        id: 'c3',
        text: '10 MPa'
      },
      {
        id: 'c4',
        text: '90 MPa'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: '$C = (50 + (-30))/2 = 10$ MPa. The half-difference is $(50 - (-30))/2 = 40$ MPa and $\\tau_{xy} = 30$ MPa. $R = \\sqrt{40^2 + 30^2} = \\sqrt{2{,}500} = 50$ (a clean 3-4-5 triangle scaled by 10). $\\sigma_1 = C + R = 10 + 50 = 60$ MPa. Choice C (10) is just the center $C$, which is the average normal stress, not the principal stress. Choice B (50) is just $\\sigma_x$ itself, ignoring the shear contribution. Choice D (90) comes from adding $\\sigma_x + \\tau_{xy}$ directly, which is not how stress transformation works.',
    hint: 'Compute the center $C$ and radius $R$ of Mohr\'s circle. Look for a Pythagorean triple.',
    steps: [
      {
        text: 'Center:',
        latex: 'C = \\frac{50 + (-30)}{2} = 10 \\text{ MPa}'
      },
      {
        text: 'Radius (3-4-5 triangle scaled by 10):',
        latex: 'R = \\sqrt{40^2 + 30^2} = \\sqrt{2{,}500} = 50 \\text{ MPa}'
      },
      {
        text: 'Maximum principal stress:',
        latex: '\\sigma_1 = C + R = 10 + 50 = 60 \\text{ MPa}'
      }
    ],
    handbookPage: 'p. 131',
    handbookFormula: '\\sigma_{1,2} = \\frac{\\sigma_x + \\sigma_y}{2} \\pm \\sqrt{\\left(\\frac{\\sigma_x - \\sigma_y}{2}\\right)^2 + \\tau_{xy}^2}',
    videoUrl: null,
    traps: [
      'Reporting the center $C$ instead of $C + R$ for $\\sigma_1$',
      'Adding $\\sigma_x + \\tau_{xy}$ directly -- stresses do not combine that way'
    ],
    diagram: {
      component: 'StressElement',
      props: {
        sigmaX: 50,
        sigmaY: -30,
        tauXY: 30
      }
    },
    lessonId: 'combined-stresses-mohrs-circle',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-csm-ex3',
    type: 'computational',
    statement: 'The principal stresses at a point are $\\sigma_1 = 90\\text{ MPa}$ (tension) and $\\sigma_2 = -30\\text{ MPa}$ (compression). For this plane stress condition ($\\sigma_3 = 0$), what is the absolute maximum shear stress?',
    choices: [
      {
        id: 'c1',
        text: '30 MPa'
      },
      {
        id: 'c2',
        text: '45 MPa'
      },
      {
        id: 'c3',
        text: '60 MPa'
      },
      {
        id: 'c4',
        text: '90 MPa'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'When $\\sigma_1$ and $\\sigma_2$ have opposite signs, the absolute max shear stress equals $(\\sigma_1 - \\sigma_3)/2$ where $\\sigma_3$ is the algebraically smallest principal stress. Here the three principal stresses in order are: $\\sigma_1 = 90$, $\\sigma_2 = 0$ (out of plane), $\\sigma_3 = -30$. So $\\tau_{abs\\,max} = (90 - (-30))/2 = 120/2 = 60$ MPa. This equals the in-plane value $R$ because the principal stresses have opposite signs. Choice A (30) is $|\\sigma_2|/2$. Choice B (45) is $\\sigma_1/2$. Choice D (90) is $\\sigma_1$ without dividing by 2.',
    hint: 'Order all three principal stresses (including $\\sigma_3 = 0$) algebraically. The absolute max shear uses the largest and smallest.',
    steps: [
      {
        text: 'Order principal stresses: $\\sigma_1 = 90$, $\\sigma_2 = 0$ (out-of-plane), $\\sigma_3 = -30$ MPa',
        latex: null
      },
      {
        text: 'Absolute maximum shear stress:',
        latex: '\\tau_{abs\\,max} = \\frac{\\sigma_1 - \\sigma_3}{2} = \\frac{90 - (-30)}{2} = 60 \\text{ MPa}'
      }
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\tau_{max} = \\frac{\\sigma_1 - \\sigma_3}{2}',
    videoUrl: null,
    traps: [
      'Using $\\sigma_1/2$ instead of $(\\sigma_1 - \\sigma_3)/2$ when $\\sigma_3$ is negative',
      'Forgetting to include the out-of-plane principal stress $\\sigma_3 = 0$ in the ordering'
    ],
    diagram: null,
    lessonId: 'combined-stresses-mohrs-circle',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-csm-ex4',
    type: 'conceptual',
    statement: 'On Mohr\'s circle, the principal stress planes are represented by the two points where the circle crosses the horizontal ($\\sigma$) axis. What is the angular separation between these two points ON the circle?',
    choices: [
      {
        id: 'c1',
        text: '45 degrees'
      },
      {
        id: 'c2',
        text: '90 degrees'
      },
      {
        id: 'c3',
        text: '360 degrees'
      },
      {
        id: 'c4',
        text: '180 degrees'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'Mohr\'s circle has a key rule: angles on the circle are DOUBLE the physical angles. The two principal stress directions are $90\\degree$ apart physically (they are always perpendicular in real space). On Mohr\'s circle, that $90\\degree$ is represented as $2 \\times 90 = 180\\degree$ -- the two points are on opposite ends of a diameter. This doubling convention is what makes Mohr\'s circle work. Choice A (45) confuses the physical angle of the max shear plane ($45\\degree$ from principal) with the angle on the circle. Choice B (90) uses the physical angle directly without doubling. Choice C (360) is a full revolution, which would bring you back to the same point.',
    hint: 'Remember that angles on Mohr\'s circle are double the physical rotation angle. Principal stress planes are perpendicular in reality.',
    steps: [
      {
        text: 'In reality, principal stress planes are $90\\degree$ apart (perpendicular).',
        latex: null
      },
      {
        text: 'On Mohr\'s circle, all physical angles are doubled: $2 \\times 90\\degree = 180\\degree$.',
        latex: null
      },
      {
        text: 'So the principal stresses appear at diametrically opposite points on the circle.',
        latex: null
      }
    ],
    handbookPage: 'p. 132',
    handbookFormula: '\\sigma_a = C + R, \\quad \\sigma_b = C - R',
    videoUrl: null,
    traps: [
      'Using the physical angle (90 degrees) instead of the doubled Mohr\'s circle angle (180 degrees)',
      'Confusing the angle to the max shear plane (45 degrees physical = 90 degrees on circle) with the angle between principal planes'
    ],
    diagram: null,
    lessonId: 'combined-stresses-mohrs-circle',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-cb-ex1',
    type: 'computational',
    statement: 'A steel column ($E = 200\\text{ GPa}$) is $3\\text{ m}$ long with both ends fixed. The minimum moment of inertia is $I_{min} = 10 \\times 10^6\\text{ mm}^4$. What is the critical buckling load?',
    choices: [
      {
        id: 'c1',
        text: '2{,}193 kN'
      },
      {
        id: 'c2',
        text: '8{,}772 kN'
      },
      {
        id: 'c3',
        text: '548 kN'
      },
      {
        id: 'c4',
        text: '35{,}089 kN'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Fixed-fixed means $K = 0.5$, so the effective length is $KL = 0.5 \\times 3{,}000 = 1{,}500$ mm. Then $P_{cr} = \\pi^2 EI / (KL)^2 = \\pi^2 \\times 200{,}000 \\times 10 \\times 10^6 / 1{,}500^2 = 8{,}773$ kN. Choice A (2,193) comes from using $K = 1.0$ (pinned-pinned) instead of $K = 0.5$. Choice C (548) comes from using $K = 2.0$ (fixed-free, the cantilever case). Choice D (35,089) comes from an error like using $K = 0.25$ or squaring $K$ incorrectly.',
    hint: 'What is the effective length factor $K$ for a column with both ends fixed?',
    steps: [
      {
        text: 'Effective length factor: $K = 0.5$ (fixed-fixed)',
        latex: null
      },
      {
        text: 'Effective length: $KL = 0.5 \\times 3{,}000 = 1{,}500$ mm',
        latex: null
      },
      {
        text: 'Critical buckling load:',
        latex: 'P_{cr} = \\frac{\\pi^2 EI}{(KL)^2} = \\frac{\\pi^2 \\times 200{,}000 \\times 10 \\times 10^6}{(1{,}500)^2} = 8{,}772 \\text{ kN}'
      }
    ],
    handbookPage: 'p. 136',
    handbookFormula: 'P_{cr} = \\frac{\\pi^2 EI}{(KL)^2}',
    videoUrl: null,
    traps: [
      'Using $K = 1.0$ (pinned-pinned) instead of $K = 0.5$ for fixed-fixed',
      'Forgetting to square $KL$ in the denominator'
    ],
    diagram: {
      component: 'ColumnSupports',
      props: {
        length: 3,
        topCondition: 'fixed',
        bottomCondition: 'fixed'
      }
    },
    lessonId: 'column-buckling',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-cb-ex2',
    type: 'computational',
    statement: 'A cantilever steel column ($E = 200\\text{ GPa}$, $I_{min} = 30 \\times 10^6\\text{ mm}^4$) is $4\\text{ m}$ long (fixed at the base, free at the top). What is the critical buckling load?',
    choices: [
      {
        id: 'c1',
        text: '3{,}701 kN'
      },
      {
        id: 'c2',
        text: '231 kN'
      },
      {
        id: 'c3',
        text: '925 kN'
      },
      {
        id: 'c4',
        text: '14{,}804 kN'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Fixed-free (cantilever column) has $K = 2.0$ -- the worst case. The effective length is $KL = 2.0 \\times 4{,}000 = 8{,}000$ mm. $P_{cr} = \\pi^2 \\times 200{,}000 \\times 30 \\times 10^6 / 8{,}000^2 = 925$ kN. Choice A (3,701) comes from using $K = 1.0$ (pinned-pinned). Choice B (231) comes from using $K = 4.0$ or some other error that doubles $K$ again. Choice D (14,804) comes from using $K = 0.5$ (fixed-fixed, the opposite extreme). $K = 2.0$ is easy to forget because it is the only $K$ greater than 1.',
    hint: 'A cantilever column is fixed-free. What is $K$ for this worst-case support condition?',
    steps: [
      {
        text: 'Effective length factor: $K = 2.0$ (fixed-free)',
        latex: null
      },
      {
        text: 'Effective length: $KL = 2.0 \\times 4{,}000 = 8{,}000$ mm',
        latex: null
      },
      {
        text: 'Critical buckling load:',
        latex: 'P_{cr} = \\frac{\\pi^2 EI}{(KL)^2} = \\frac{\\pi^2 \\times 200{,}000 \\times 30 \\times 10^6}{(8{,}000)^2} = 925 \\text{ kN}'
      }
    ],
    handbookPage: 'p. 136',
    handbookFormula: 'P_{cr} = \\frac{\\pi^2 EI}{(KL)^2}',
    videoUrl: null,
    traps: [
      'Using $K = 1.0$ instead of $K = 2.0$ for a cantilever column -- overestimates capacity by 4x',
      'Forgetting that $K = 2.0$ makes the effective length TWICE the actual length'
    ],
    diagram: {
      component: 'ColumnSupports',
      props: {
        length: 4,
        topCondition: 'free',
        bottomCondition: 'fixed'
      }
    },
    lessonId: 'column-buckling',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-cb-ex3',
    type: 'computational',
    statement: 'A steel column ($E = 200\\text{ GPa}$) has a cross-sectional area $A = 6{,}000\\text{ mm}^2$ and a minimum radius of gyration $r = 50\\text{ mm}$. It is $7\\text{ m}$ long with fixed-pinned end conditions ($K = 0.7$). What is the slenderness ratio, and what is the critical buckling stress?',
    choices: [
      {
        id: 'c1',
        text: '$KL/r = 98$, $\\sigma_{cr} = 206\\text{ MPa}$'
      },
      {
        id: 'c2',
        text: '$KL/r = 140$, $\\sigma_{cr} = 100.7\\text{ MPa}$'
      },
      {
        id: 'c3',
        text: '$KL/r = 98$, $\\sigma_{cr} = 51.7\\text{ MPa}$'
      },
      {
        id: 'c4',
        text: '$KL/r = 200$, $\\sigma_{cr} = 49.3\\text{ MPa}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'First compute the slenderness ratio: $KL/r = 0.7 \\times 7{,}000 / 50 = 4{,}900/50 = 98$. Then critical stress: $\\sigma_{cr} = \\pi^2 E / (KL/r)^2 = \\pi^2 \\times 200{,}000 / 98^2 = 206$ MPa. Choice B ($KL/r = 140$, $\\sigma_{cr} = 100.7$) uses $K = 1.0$ instead of 0.7: $KL/r = 7{,}000/50 = 140$. Choice C has the right slenderness but wrong stress (maybe using $E/2$). Choice D ($KL/r = 200$) uses $K = 2.0$ or $r$ incorrectly.',
    hint: 'Compute $KL/r$ first, then plug into $\\sigma_{cr} = \\pi^2 E / (KL/r)^2$.',
    steps: [
      {
        text: 'Slenderness ratio:',
        latex: '\\frac{KL}{r} = \\frac{0.7 \\times 7{,}000}{50} = 98'
      },
      {
        text: 'Critical buckling stress:',
        latex: '\\sigma_{cr} = \\frac{\\pi^2 E}{(KL/r)^2} = \\frac{\\pi^2 \\times 200{,}000}{98^2} = 206 \\text{ MPa}'
      }
    ],
    handbookPage: 'p. 136',
    handbookFormula: '\\sigma_{cr} = \\frac{\\pi^2 E}{(KL/r)^2}',
    videoUrl: null,
    traps: [
      'Using $K = 1.0$ instead of $K = 0.7$ for fixed-pinned conditions',
      'Forgetting to square the slenderness ratio in the denominator'
    ],
    diagram: { component: 'ColumnSupports', props: { length: 7, topCondition: 'pin', bottomCondition: 'fixed' } },
    lessonId: 'column-buckling',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-cb-ex4',
    type: 'conceptual',
    statement: 'Two identical steel columns have the same cross-section, material, and length. Column A has both ends pinned ($K = 1.0$). Column B has one end fixed and one end free ($K = 2.0$). What is the ratio of the critical buckling load of Column A to Column B?',
    choices: [
      {
        id: 'c1',
        text: '2:1'
      },
      {
        id: 'c2',
        text: '8:1'
      },
      {
        id: 'c3',
        text: '1:2'
      },
      {
        id: 'c4',
        text: '4:1'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: '$P_{cr} = \\pi^2 EI / (KL)^2$. Since $E$, $I$, and $L$ are the same for both columns, the ratio depends only on $1/(KL)^2 = 1/K^2$. Column A: $K = 1.0$, so $P_{cr,A}$ is proportional to $1/1^2 = 1$. Column B: $K = 2.0$, so $P_{cr,B}$ is proportional to $1/2^2 = 1/4$. The ratio $P_{cr,A} / P_{cr,B} = 1 / (1/4) = 4$. So the pinned-pinned column is 4 times stronger in buckling than the cantilever column. Choice A (2:1) only considers $K$ linearly, not $K^2$. Choice B (8:1) confuses this with a cubic relationship. Choice C (1:2) has the ratio inverted. The $K^2$ factor in the denominator is why end conditions matter so much for buckling.',
    hint: 'Since everything else is identical, the ratio depends only on $K$. How does $K$ appear in Euler\'s formula?',
    steps: [
      {
        text: 'Euler\'s formula: $P_{cr} = \\pi^2 EI / (KL)^2$. With $E$, $I$, $L$ constant:',
        latex: 'P_{cr} \\propto \\frac{1}{K^2}'
      },
      {
        text: 'Ratio:',
        latex: '\\frac{P_{cr,A}}{P_{cr,B}} = \\frac{K_B^2}{K_A^2} = \\frac{2^2}{1^2} = 4'
      }
    ],
    handbookPage: 'p. 136',
    handbookFormula: 'P_{cr} = \\frac{\\pi^2 EI}{(KL)^2}',
    videoUrl: null,
    traps: [
      'Forgetting that $K$ is squared in the denominator -- the ratio is $K^2$, not $K$',
      'Inverting the ratio -- the pinned column is stronger, not weaker, than the cantilever'
    ],
    diagram: null,
    lessonId: 'column-buckling',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-tsp-ex1',
    type: 'computational',
    statement: 'A steel beam has yield stress $F_y = 36\\text{ ksi}$ and plastic section modulus $Z = 50\\text{ in}^3$. What is its plastic moment?',
    choices: [
      { id: 'c1', text: '$150\\text{ kip·ft}$' },
      { id: 'c2', text: '$1{,}800\\text{ kip·ft}$' },
      { id: 'c3', text: '$75\\text{ kip·ft}$' },
      { id: 'c4', text: '$125\\text{ kip·ft}$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Mp = Fy·Z = 36 × 50 = 1,800 kip·in = 1,800/12 = 150 kip·ft. Choice B leaves it in kip·in. Choice C halves it. Choice D uses a smaller (elastic) modulus.',
    hint: 'Mp = Fy·Z, then convert kip·in to kip·ft (÷12).',
    steps: [
      { text: 'Plastic moment:', latex: 'M_p = 36 \\times 50 = 1{,}800\\text{ kip·in}' },
      { text: 'Convert:', latex: 'M_p = 1{,}800/12 = 150\\text{ kip·ft}' },
    ],
    handbookPage: 'p. 281',
    handbookFormula: 'M_p = F_y Z',
    videoUrl: null,
    traps: ['Leaving the answer in kip·in', 'Using the elastic section modulus S'],
    diagram: null,
    lessonId: 'transformed-sections-plastic',
    chapterId: 'mechanics-materials'
  },
];

export default PROBLEMS;
