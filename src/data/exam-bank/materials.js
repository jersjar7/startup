// Exam bank: materials
// Auto-extracted from lesson files — 32 questions

const PROBLEMS = [
  {
    id: 'mat-ssmb-ex1',
    type: 'conceptual',
    statement: 'On a typical engineering stress-strain curve for a ductile metal, which point represents the ultimate tensile strength (UTS)?',
    choices: [
      {
        id: 'c1',
        text: 'The slope of the initial linear portion of the curve'
      },
      {
        id: 'c2',
        text: 'The maximum stress on the engineering stress-strain curve'
      },
      {
        id: 'c3',
        text: 'The stress at which the specimen fractures'
      },
      {
        id: 'c4',
        text: 'The stress at the 0.2% offset intersection'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The ultimate tensile strength is simply the highest point (peak stress) on the engineering stress-strain curve. After UTS, necking begins and the engineering stress drops even though the true stress keeps increasing. Choice A describes the elastic modulus, not strength. Choice C is the fracture stress, which is lower than UTS on the engineering curve because the cross-section has necked down. Choice D describes the yield strength determined by the offset method.',
    hint: 'UTS stands for ultimate tensile strength -- think about where on the curve the stress reaches its maximum value.',
    steps: [
      {
        text: 'The engineering stress-strain curve rises through the elastic region, passes through yield, and continues to increase due to strain hardening.',
        latex: null
      },
      {
        text: 'UTS is the peak (maximum) engineering stress on the curve, occurring just before necking begins.',
        latex: null
      },
      {
        text: 'After UTS, engineering stress decreases because the original cross-sectional area $A_0$ no longer represents the actual neck area.',
        latex: null
      }
    ],
    handbookPage: 'p. 121',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing UTS (peak stress) with fracture stress (final point on the curve)',
      'Confusing UTS with yield strength (0.2% offset)'
    ],
    diagram: null,
    lessonId: 'stress-strain-material-behavior',
    chapterId: 'materials'
  },
  {
    id: 'mat-ssmb-ex2',
    type: 'computational',
    statement: 'A steel rod ($E = 200\\,\\text{GPa}$) with an original gauge length of $L_0 = 200\\,\\text{mm}$ is subjected to a tensile stress of $250\\,\\text{MPa}$ within the elastic range. What is the elongation of the rod?',
    choices: [
      {
        id: 'c1',
        text: '$0.25\\,\\text{mm}$'
      },
      {
        id: 'c2',
        text: '$2.5\\,\\text{mm}$'
      },
      {
        id: 'c3',
        text: '$0.025\\,\\text{mm}$'
      },
      {
        id: 'c4',
        text: '$1.25\\,\\text{mm}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Use Hooke\'s law to find strain first, then multiply by gauge length. $\\varepsilon = \\sigma/E = 250/200{,}000 = 0.00125$. Then $\\Delta L = \\varepsilon \\times L_0 = 0.00125 \\times 200 = 0.25$ mm. Choice B (2.5) uses $E = 20$ GPa instead of 200 GPa — off by a factor of 10. Choice C (0.025) uses $L = 20$ mm instead of 200 mm. Choice D (1.25) forgets to convert GPa to MPa and computes $250/200 \\times 200/200$.',
    hint: 'Find strain from Hooke\'s law first, then multiply by gauge length to get elongation.',
    steps: [
      {
        text: 'Strain from Hooke\'s law:',
        latex: '\\varepsilon = \\frac{\\sigma}{E} = \\frac{250}{200{,}000} = 1.25 \\times 10^{-3}'
      },
      {
        text: 'Elongation:',
        latex: '\\Delta L = \\varepsilon \\cdot L_0 = 1.25 \\times 10^{-3} \\times 200 = 0.25\\,\\text{mm}'
      }
    ],
    handbookPage: 'p. 121',
    handbookFormula: '\\sigma = E\\varepsilon',
    videoUrl: null,
    traps: [
      'Forgetting to convert GPa to MPa (200 GPa = 200,000 MPa) before dividing',
      'Using the wrong gauge length or misplacing a decimal'
    ],
    diagram: null,
    lessonId: 'stress-strain-material-behavior',
    chapterId: 'materials'
  },
  {
    id: 'mat-ssmb-ex3',
    type: 'conceptual',
    statement: 'Two materials are being compared: Material A has $E = 200\\,\\text{GPa}$ and $\\sigma_y = 250\\,\\text{MPa}$. Material B has $E = 70\\,\\text{GPa}$ and $\\sigma_y = 480\\,\\text{MPa}$. Which statement is correct?',
    choices: [
      {
        id: 'c1',
        text: 'Material A is both stiffer and stronger than Material B'
      },
      {
        id: 'c2',
        text: 'Material A is stiffer but Material B is stronger'
      },
      {
        id: 'c3',
        text: 'Material B is both stiffer and stronger than Material A'
      },
      {
        id: 'c4',
        text: 'Material B is stiffer but Material A is stronger'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Stiffness and strength are different properties. Stiffness is measured by elastic modulus $E$ — how much a material resists deformation. Strength is measured by yield stress — how much stress it can carry before permanent deformation. Material A ($E = 200$ GPa) is stiffer because it has the higher modulus. Material B ($\\sigma_y = 480$ MPa) is stronger because it has the higher yield strength. These are independent properties. A classic example: steel is stiffer than aluminum, but some aluminum alloys have higher yield strength than mild steel.',
    hint: 'Stiffness is about elastic modulus (E), strength is about yield stress. They are independent properties.',
    steps: [
      {
        text: 'Compare stiffness (elastic modulus): $E_A = 200\\,\\text{GPa} > E_B = 70\\,\\text{GPa}$. Material A is stiffer.',
        latex: null
      },
      {
        text: 'Compare strength (yield stress): $\\sigma_{y,B} = 480\\,\\text{MPa} > \\sigma_{y,A} = 250\\,\\text{MPa}$. Material B is stronger.',
        latex: null
      },
      {
        text: 'Stiffness and strength are independent properties -- a material can be stiff but weak, or flexible but strong.',
        latex: null
      }
    ],
    handbookPage: 'p. 121',
    handbookFormula: '\\sigma = E\\varepsilon',
    videoUrl: null,
    traps: [
      'Assuming that a stiffer material is automatically stronger -- stiffness and strength are independent',
      'Confusing elastic modulus (resistance to deformation) with yield strength (resistance to permanent deformation)'
    ],
    diagram: null,
    lessonId: 'stress-strain-material-behavior',
    chapterId: 'materials'
  },
  {
    id: 'mat-ssmb-ex4',
    type: 'conceptual',
    statement: 'During a tensile test of a ductile steel specimen, the engineering stress-strain curve shows a decrease in stress after the ultimate tensile strength (UTS). What is the primary reason for this apparent stress drop?',
    choices: [
      {
        id: 'c1',
        text: 'The material is losing strength due to internal cracking throughout the specimen'
      },
      {
        id: 'c2',
        text: 'The engineering stress is calculated using the original cross-sectional area, which does not account for localized necking'
      },
      {
        id: 'c3',
        text: 'The testing machine reduces the applied load after UTS is reached'
      },
      {
        id: 'c4',
        text: 'The strain hardening reverses and the material softens uniformly'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'After UTS, the specimen begins to neck -- the deformation concentrates in one narrow region and the local cross-section shrinks rapidly. Engineering stress uses the original area $A_0$, so it appears to drop. But the true stress (using the actual instantaneous area) continues to increase until fracture. The machine does not reduce load; load actually does decrease because the neck area shrinks faster than the material strain-hardens. The material is not softening uniformly or cracking throughout -- the deformation simply localizes into a neck.',
    hint: 'Think about what area is used in the engineering stress calculation and what physically happens to the specimen after UTS.',
    steps: [
      {
        text: 'Engineering stress is defined as $\\sigma = F / A_0$, using the original cross-sectional area.',
        latex: null
      },
      {
        text: 'After UTS, necking begins: deformation localizes in a small region, and the actual cross-section shrinks rapidly.',
        latex: null
      },
      {
        text: 'The load $F$ decreases because the neck area shrinks faster than strain hardening can compensate, so $\\sigma = F/A_0$ drops.',
        latex: null
      },
      {
        text: 'True stress $\\sigma_T = F/A_{\\text{actual}}$ continues to increase until fracture.',
        latex: null
      }
    ],
    handbookPage: 'p. 121',
    handbookFormula: '\\sigma_T = \\frac{F}{A}',
    videoUrl: null,
    traps: [
      'Thinking the material actually gets weaker after UTS -- the true stress keeps rising',
      'Assuming the testing machine reduces load intentionally -- the load drop is a natural consequence of necking'
    ],
    diagram: null,
    lessonId: 'stress-strain-material-behavior',
    chapterId: 'materials'
  },
  {
    id: 'mat-hif-ex1',
    type: 'conceptual',
    statement: 'A structural engineer is selecting steel for a bridge in northern Alaska where winter temperatures routinely reach $-40\\degree\\text{C}$. A Charpy V-notch impact test is performed at several temperatures. Which result is most critical for this application?',
    choices: [
      {
        id: 'c1',
        text: 'The energy absorbed at room temperature'
      },
      {
        id: 'c2',
        text: 'The ductile-to-brittle transition temperature (DBTT) relative to the service temperature'
      },
      {
        id: 'c3',
        text: 'The Brinell hardness number of the steel'
      },
      {
        id: 'c4',
        text: 'The fatigue endurance limit of the steel'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The whole point of the Charpy test at multiple temperatures is to find the DBTT -- the temperature below which the steel becomes brittle and absorbs very little energy before fracturing. For a bridge in Alaska at -40 degrees C, you need a steel whose DBTT is well below -40 degrees C, or the steel could fracture in a brittle manner during service. Room temperature results are irrelevant because the bridge will not be at room temperature in winter. Hardness and fatigue are important but do not address the cold-temperature brittleness concern.',
    hint: 'The Charpy test is specifically designed to evaluate a material\'s behavior at different temperatures. What temperature-related property does it reveal?',
    steps: [
      {
        text: 'The Charpy impact test measures energy absorption as a function of temperature.',
        latex: null
      },
      {
        text: 'BCC metals (carbon steel) exhibit a ductile-to-brittle transition at a specific temperature (DBTT).',
        latex: null
      },
      {
        text: 'For cold-climate service, the DBTT must be below the minimum service temperature to ensure ductile behavior.',
        latex: null
      }
    ],
    handbookPage: 'p. 122',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Checking only room-temperature impact energy -- irrelevant for cold-climate service',
      'Confusing hardness testing (surface property) with impact testing (toughness property)'
    ],
    diagram: null,
    lessonId: 'hardness-impact-fatigue',
    chapterId: 'materials'
  },
  {
    id: 'mat-hif-ex2',
    type: 'computational',
    statement: 'A plain carbon steel specimen has a Brinell Hardness Number (BHN) of $250$. Using the approximate BHN-to-tensile strength relationship, the estimated ultimate tensile strength in US Customary units is most nearly:',
    choices: [
      {
        id: 'c1',
        text: '$125{,}000\\,\\text{psi}$'
      },
      {
        id: 'c2',
        text: '$862\\,\\text{MPa}$'
      },
      {
        id: 'c3',
        text: '$72\\,\\text{psi}$'
      },
      {
        id: 'c4',
        text: '$500{,}000\\,\\text{psi}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'For US Customary units, the BHN-to-TS relationship is $\\text{TS (psi)} = 500 \\times \\text{BHN}$. So $TS = 500 \\times 250 = 125{,}000$ psi. Choice B (862 MPa) uses the SI formula ($3.45 \\times 250$) but reports in MPa — the question asks for US Customary. Choice C (72) divides BHN by 3.45 instead of multiplying by 500. Choice D (500,000) multiplies BHN by 2,000 instead of 500.',
    hint: 'The handbook gives two versions of the BHN-TS formula: one in MPa (multiply by 3.45) and one in psi (multiply by 500). The question asks for US Customary units.',
    steps: [
      {
        text: 'US Customary BHN-TS relationship for plain carbon steels:',
        latex: 'TS\\,(\\text{psi}) \\approx 500 \\times BHN'
      },
      {
        text: 'Substitute:',
        latex: 'TS = 500 \\times 250 = 125{,}000\\,\\text{psi}'
      }
    ],
    handbookPage: 'p. 122',
    handbookFormula: 'TS\\,(\\text{psi}) \\approx 500 \\times BHN',
    videoUrl: null,
    traps: [
      'Using the SI formula (3.45 times BHN) when the question asks for psi',
      'Confusing the conversion factors between the two unit systems'
    ],
    diagram: null,
    lessonId: 'hardness-impact-fatigue',
    chapterId: 'materials'
  },
  {
    id: 'mat-hif-ex3',
    type: 'conceptual',
    statement: 'A steel highway bridge experiences millions of stress cycles from truck traffic at a stress amplitude well below the steel\'s yield strength. After 15 years of service, cracks are discovered at a welded connection. What failure mechanism is most likely responsible?',
    choices: [
      {
        id: 'c1',
        text: 'Creep failure due to sustained loading'
      },
      {
        id: 'c2',
        text: 'Fatigue failure from repeated cyclic loading below yield'
      },
      {
        id: 'c3',
        text: 'Corrosion-induced uniform thinning of the section'
      },
      {
        id: 'c4',
        text: 'Yielding due to overload beyond the design capacity'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Fatigue is failure under repeated cyclic loading at stresses below the yield strength. It is the most common cause of structural failure in components subjected to vibration or repeated loading -- highway bridges under truck traffic are a textbook example. Cracks typically initiate at stress concentrations like welded connections. Creep requires sustained high temperatures (not typical for bridges). Corrosion causes section loss, not cracking at welds specifically. Yielding requires stress above yield, but the problem states the stress is well below yield.',
    hint: 'What failure mechanism causes cracking at stresses below yield strength after millions of load cycles?',
    steps: [
      {
        text: 'Fatigue is failure under repeated cyclic loading at stresses below the static yield strength.',
        latex: null
      },
      {
        text: 'Cracks initiate at stress concentrations (weld toes, notches, holes) and propagate with each load cycle.',
        latex: null
      },
      {
        text: 'Welded connections are particularly susceptible because the weld geometry creates stress concentrations and residual stresses.',
        latex: null
      }
    ],
    handbookPage: 'p. 122',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking that stresses below yield cannot cause failure -- fatigue failure occurs below yield with enough cycles',
      'Confusing fatigue with creep -- creep requires sustained high temperature, not cyclic loading'
    ],
    diagram: null,
    lessonId: 'hardness-impact-fatigue',
    chapterId: 'materials'
  },
  {
    id: 'mat-hif-ex4',
    type: 'conceptual',
    statement: 'An engineer is comparing the fatigue behavior of a steel component and an aluminum component for a vibrating machine foundation. Both are subjected to the same cyclic stress amplitude. Which statement about fatigue life is correct?',
    choices: [
      {
        id: 'c1',
        text: 'Both steel and aluminum have a definite endurance limit below which fatigue failure will not occur'
      },
      {
        id: 'c2',
        text: 'Steel has a definite endurance limit; aluminum does not and will eventually fail at any cyclic stress given enough cycles'
      },
      {
        id: 'c3',
        text: 'Aluminum has a definite endurance limit; steel does not'
      },
      {
        id: 'c4',
        text: 'Neither steel nor aluminum has an endurance limit -- both will eventually fail under any cyclic stress'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'Steel (and other ferrous metals) exhibit a definite endurance limit -- a stress amplitude below which the material can survive essentially infinite cycles without failure, typically 40-50% of UTS. Aluminum and other non-ferrous metals do NOT have a true endurance limit. Their S-N curves continue to slope downward, meaning they will eventually fail at any cyclic stress if given enough cycles. For aluminum, engineers use a "fatigue strength at N cycles" (often 10^7 or 10^8 cycles) instead of an endurance limit. This is a classic FE distinction.',
    hint: 'Ferrous vs. non-ferrous metals behave very differently on an S-N (stress vs. number of cycles) curve. One levels off; the other keeps dropping.',
    steps: [
      {
        text: 'Steel (ferrous): The S-N curve flattens at a definite endurance limit, typically 40-50% of UTS. Below this stress, infinite fatigue life.',
        latex: null
      },
      {
        text: 'Aluminum (non-ferrous): The S-N curve never fully flattens. There is no true endurance limit -- fatigue failure can occur at any stress with enough cycles.',
        latex: null
      },
      {
        text: 'For aluminum, engineers report "fatigue strength" at a specified number of cycles (e.g., $10^7$ cycles) instead of an endurance limit.',
        latex: null
      }
    ],
    handbookPage: 'p. 122',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Assuming all metals have an endurance limit -- only ferrous metals do',
      'Thinking aluminum is "better" because it is lighter -- it has worse fatigue behavior due to the lack of an endurance limit'
    ],
    diagram: null,
    lessonId: 'hardness-impact-fatigue',
    chapterId: 'materials'
  },
  {
    id: 'mat-tpp-ex1',
    type: 'conceptual',
    statement: 'Cold working a metal (such as drawing steel wire through a die) increases which of the following properties?',
    choices: [
      {
        id: 'c1',
        text: 'Ductility and elongation at fracture'
      },
      {
        id: 'c2',
        text: 'Yield strength and hardness'
      },
      {
        id: 'c3',
        text: 'Electrical conductivity and thermal conductivity'
      },
      {
        id: 'c4',
        text: 'Grain size and toughness'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Cold working plastically deforms metal at room temperature, introducing dislocations that pile up and block further slip. This makes the material harder and stronger (higher yield strength and hardness) but less ductile -- it can no longer stretch as far before breaking. Ductility and elongation decrease, not increase. Electrical and thermal conductivity slightly decrease because dislocations scatter electrons. Grain size is distorted (grains elongate), not increased, and toughness typically decreases.',
    hint: 'Think about what happens to a metal\'s ability to deform further after it has already been permanently deformed.',
    steps: [
      {
        text: 'Cold working introduces dislocations into the crystal structure.',
        latex: null
      },
      {
        text: 'More dislocations means more resistance to further plastic deformation, so yield strength and hardness increase.',
        latex: null
      },
      {
        text: 'The trade-off: ductility (percent elongation) decreases because the material has already used up some of its deformation capacity.',
        latex: null
      }
    ],
    handbookPage: 'p. 116',
    handbookFormula: '\\%CW = \\frac{A_0 - A_f}{A_0} \\times 100',
    videoUrl: null,
    traps: [
      'Thinking cold working improves all mechanical properties -- it increases strength but decreases ductility',
      'Confusing cold working with annealing, which restores ductility'
    ],
    diagram: null,
    lessonId: 'thermal-processing-phase-diagrams',
    chapterId: 'materials'
  },
  {
    id: 'mat-tpp-ex2',
    type: 'computational',
    statement: 'An aluminum railing ($\\alpha = 23 \\times 10^{-6}\\text{ /}\\degree\\text{C}$) is $6\\,\\text{m}$ long and installed at $20\\degree\\text{C}$. On a hot day the temperature reaches $55\\degree\\text{C}$. What is the thermal expansion of the railing?',
    choices: [
      {
        id: 'c1',
        text: '$4.83\\,\\text{mm}$'
      },
      {
        id: 'c2',
        text: '$7.59\\,\\text{mm}$'
      },
      {
        id: 'c3',
        text: '$0.48\\,\\text{mm}$'
      },
      {
        id: 'c4',
        text: '$48.3\\,\\text{mm}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Use the thermal expansion formula: $\\Delta L = \\alpha L \\Delta T$. The temperature change is $55 - 20 = 35$ degrees C. Then $\\Delta L = 23 \\times 10^{-6} \\times 6{,}000 \\times 35 = 4.83$ mm. Choice B (7.59) uses $\\Delta T = 55$ degrees C (the final temperature instead of the change). Choice C (0.48) uses $L = 0.6$ m without converting to mm consistently. Choice D (48.3) is off by a factor of 10 — possibly using $\\alpha = 230 \\times 10^{-6}$.',
    hint: 'Temperature change is the difference between final and initial temperatures. Make sure your units are consistent.',
    steps: [
      {
        text: 'Temperature change:',
        latex: '\\Delta T = 55 - 20 = 35\\degree\\text{C}'
      },
      {
        text: 'Thermal expansion:',
        latex: '\\Delta L = \\alpha L \\Delta T = 23 \\times 10^{-6} \\times 6{,}000 \\times 35 = 4.83\\,\\text{mm}'
      }
    ],
    handbookPage: 'p. 126',
    handbookFormula: '\\Delta L = \\alpha L \\Delta T',
    videoUrl: null,
    traps: [
      'Using the final temperature (55) instead of the temperature change (35) as delta T',
      'Mixing up length units -- using meters for length but expecting mm in the answer without converting'
    ],
    diagram: null,
    lessonId: 'thermal-processing-phase-diagrams',
    chapterId: 'materials'
  },
  {
    id: 'mat-tpp-ex3',
    type: 'conceptual',
    statement: 'A cold-worked copper sheet is heated to progressively higher temperatures. During the recrystallization stage, which combination of changes occurs?',
    choices: [
      {
        id: 'c1',
        text: 'Strength increases and ductility decreases'
      },
      {
        id: 'c2',
        text: 'Strength decreases and ductility is restored as new strain-free grains form'
      },
      {
        id: 'c3',
        text: 'Both strength and ductility increase simultaneously'
      },
      {
        id: 'c4',
        text: 'No change in mechanical properties until the melting point is reached'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Annealing a cold-worked metal goes through three stages: recovery, recrystallization, and grain growth. During recrystallization, new strain-free grains nucleate and grow, replacing the deformed grains. This removes the dislocations that were making the material strong but brittle. The result: strength and hardness drop back down (closer to the annealed state), and ductility is restored. You are essentially undoing the cold work. Strength and ductility do not both increase -- they trade off. And properties change well below the melting point.',
    hint: 'Recrystallization replaces deformed grains with new strain-free grains. Think about what that does to the properties that cold working changed.',
    steps: [
      {
        text: 'Cold working increases strength by introducing dislocations, but reduces ductility.',
        latex: null
      },
      {
        text: 'During recrystallization, new strain-free grains nucleate and consume the deformed grains, removing most dislocations.',
        latex: null
      },
      {
        text: 'Result: strength and hardness decrease back toward the pre-cold-worked values, while ductility is restored.',
        latex: null
      }
    ],
    handbookPage: 'p. 116',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking recrystallization improves both strength and ductility -- it reverses cold work, trading strength for ductility',
      'Confusing recovery (partial stress relief, no new grains) with recrystallization (new grains form)'
    ],
    diagram: null,
    lessonId: 'thermal-processing-phase-diagrams',
    chapterId: 'materials'
  },
  {
    id: 'mat-tpp-ex4',
    type: 'conceptual',
    statement: 'A steel component is quenched from the austenite region to form martensite, then tempered at $400\\degree\\text{C}$. How does tempering change the properties compared to the as-quenched martensite?',
    choices: [
      {
        id: 'c1',
        text: 'Hardness increases further and ductility decreases'
      },
      {
        id: 'c2',
        text: 'Hardness increases and the steel becomes austenitic'
      },
      {
        id: 'c3',
        text: 'Hardness decreases somewhat while toughness and ductility improve'
      },
      {
        id: 'c4',
        text: 'The martensite transforms back to ferrite and austenite with no change in hardness'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'As-quenched martensite is extremely hard but very brittle -- too brittle for most structural applications. Tempering (reheating to a moderate temperature like 400 degrees C) allows some of the carbon atoms trapped in the distorted BCT lattice to diffuse out and form fine carbide particles. This relieves internal stresses, slightly reduces hardness, and significantly improves toughness and ductility. The result is a material that is still much harder than annealed steel but much tougher than as-quenched martensite. Tempering does not re-form austenite (that requires much higher temperatures) and it does not increase hardness.',
    hint: 'Tempering is a controlled reheat of quenched martensite. It is done specifically to address the brittleness problem of as-quenched martensite.',
    steps: [
      {
        text: 'As-quenched martensite: extremely hard but very brittle (low toughness, low ductility).',
        latex: null
      },
      {
        text: 'Tempering at moderate temperature allows carbon to diffuse from the supersaturated BCT lattice, forming fine carbides.',
        latex: null
      },
      {
        text: 'Result: hardness decreases somewhat, but toughness and ductility improve significantly -- an engineering trade-off.',
        latex: null
      },
      {
        text: 'Higher tempering temperatures give more ductility but less hardness; the engineer selects the tempering temperature based on the required balance.',
        latex: null
      }
    ],
    handbookPage: 'p. 116',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking tempering increases hardness further -- it deliberately sacrifices some hardness for toughness',
      'Confusing tempering with austenitizing -- tempering is done at much lower temperatures and does not re-form austenite'
    ],
    diagram: null,
    lessonId: 'thermal-processing-phase-diagrams',
    chapterId: 'materials'
  },
  {
    id: 'mat-cmd-ex1',
    type: 'conceptual',
    statement: 'A contractor wants to increase the workability (slump) of a concrete mix without reducing its 28-day compressive strength. Which approach is most appropriate?',
    choices: [
      {
        id: 'c1',
        text: 'Replace coarse aggregate with fine aggregate'
      },
      {
        id: 'c2',
        text: 'Add more water to the mix'
      },
      {
        id: 'c3',
        text: 'Increase the cement content while keeping water constant'
      },
      {
        id: 'c4',
        text: 'Add a superplasticizer (high-range water reducer)'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'A superplasticizer (high-range water reducer) increases workability by dispersing cement particles, making the concrete flow more easily without adding extra water. Since you are not adding water, the W/C ratio stays the same and strength is preserved. Choice B (more water) increases slump but raises the W/C ratio, which lowers strength -- this is the classic mistake. Choice C (more cement) would actually lower the W/C ratio and increase strength, but it does not directly improve workability and is expensive. Choice A (more fines) increases water demand and can reduce workability or require more water.',
    hint: 'The only way to increase slump without changing the W/C ratio is to use a chemical admixture that makes the mix more fluid.',
    steps: [
      {
        text: 'Workability (slump) can be increased by adding water, but that raises W/C and lowers strength.',
        latex: null
      },
      {
        text: 'Superplasticizers increase fluidity without adding water, keeping W/C unchanged.',
        latex: null
      },
      {
        text: 'Strength depends on W/C, so maintaining the same W/C preserves strength.',
        latex: null
      }
    ],
    handbookPage: 'p. 125',
    handbookFormula: 'W/C = \\frac{\\text{weight of water}}{\\text{weight of cement}}',
    videoUrl: null,
    traps: [
      'Thinking that adding water is acceptable because it does increase slump -- it does, but at the cost of strength'
    ],
    diagram: null,
    lessonId: 'concrete-mix-design',
    chapterId: 'materials'
  },
  {
    id: 'mat-cmd-ex2',
    type: 'computational',
    statement: 'A concrete mix contains $350 \\text{ kg/m}^3$ of cement and $175 \\text{ kg/m}^3$ of water. The engineer adds a water-reducing admixture that allows a $15\\%$ reduction in water content while maintaining the same workability. What is the new W/C ratio?',
    choices: [
      {
        id: 'c1',
        text: '$0.575$'
      },
      {
        id: 'c2',
        text: '$0.50$'
      },
      {
        id: 'c3',
        text: '$0.425$'
      },
      {
        id: 'c4',
        text: '$0.35$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'First, the original W/C = 175/350 = 0.50. The admixture reduces water by 15%, so the new water content is $175 \\times (1 - 0.15) = 175 \\times 0.85 = 148.75$ kg/m$^3$. The cement stays the same at 350 kg/m$^3$ (only water changed). The new W/C = 148.75/350 = 0.425. Choice B (0.50) is the original ratio before the admixture. Choice A (0.575) adds 15% instead of subtracting it. Choice D (0.35) incorrectly reduces the W/C ratio itself by 0.15, rather than reducing the water content by 15%.',
    hint: 'Reduce the water weight by 15%, keep cement the same, then recalculate W/C.',
    steps: [
      {
        text: 'Original W/C ratio:',
        latex: 'W/C = \\frac{175}{350} = 0.50'
      },
      {
        text: 'New water content after 15% reduction:',
        latex: 'W_{\\text{new}} = 175 \\times 0.85 = 148.75 \\text{ kg/m}^3'
      },
      {
        text: 'New W/C ratio (cement unchanged):',
        latex: 'W/C_{\\text{new}} = \\frac{148.75}{350} = 0.425'
      }
    ],
    handbookPage: 'p. 125',
    handbookFormula: 'W/C = \\frac{\\text{weight of water}}{\\text{weight of cement}}',
    videoUrl: null,
    traps: [
      'Subtracting 0.15 from the W/C ratio directly (0.50 - 0.15 = 0.35) instead of reducing the water content by 15%',
      'Adding 15% to water instead of subtracting it'
    ],
    diagram: null,
    lessonId: 'concrete-mix-design',
    chapterId: 'materials'
  },
  {
    id: 'mat-cmd-ex3',
    type: 'conceptual',
    statement: 'Air-entrained concrete is specified for a bridge deck in a region with harsh winters. Compared to non-air-entrained concrete at the same W/C ratio, the air-entrained mix will have:',
    choices: [
      {
        id: 'c1',
        text: 'Higher compressive strength and better freeze-thaw durability'
      },
      {
        id: 'c2',
        text: 'Lower compressive strength but better freeze-thaw durability'
      },
      {
        id: 'c3',
        text: 'Lower compressive strength and lower freeze-thaw durability'
      },
      {
        id: 'c4',
        text: 'The same compressive strength but better freeze-thaw durability'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Air entrainment introduces tiny bubbles (4-7% by volume) into the concrete mix. These bubbles serve as pressure-relief chambers when water inside the concrete freezes and expands, dramatically improving freeze-thaw durability. However, the air voids reduce the solid cross-section of the paste, so compressive strength drops slightly compared to a non-air-entrained mix at the same W/C. This is a deliberate trade-off: you accept a small strength reduction for much better durability in freeze-thaw environments. Choice A is wrong because strength goes down, not up. Choice C reverses the durability benefit. Choice D sounds reasonable but the strength reduction is real and well-documented in the handbook.',
    hint: 'Air bubbles relieve internal pressure from freezing water, but they also represent voids that reduce the load-carrying cross section.',
    steps: [
      {
        text: 'Air entrainment adds 4-7% air voids by volume to the concrete.',
        latex: null
      },
      {
        text: 'The voids relieve expansion pressure when pore water freezes, improving freeze-thaw durability.',
        latex: null
      },
      {
        text: 'The voids also reduce the solid volume of paste, lowering compressive strength at the same W/C.',
        latex: null
      }
    ],
    handbookPage: 'p. 125',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Assuming air entrainment has no downside -- it does reduce compressive strength slightly',
      'Thinking that "better durability" means "better in every way"'
    ],
    diagram: null,
    lessonId: 'concrete-mix-design',
    chapterId: 'materials'
  },
  {
    id: 'mat-cmd-ex4',
    type: 'conceptual',
    statement: 'A concrete pour is scheduled during a hot summer day with ambient temperatures exceeding $35^\\circ\\text{C}$ ($95^\\circ\\text{F}$). The ready-mix supplier recommends adding an admixture to prevent premature setting during the extended delivery time. Which admixture type is most appropriate?',
    choices: [
      {
        id: 'c1',
        text: 'Retarder'
      },
      {
        id: 'c2',
        text: 'Accelerator'
      },
      {
        id: 'c3',
        text: 'Air-entraining agent'
      },
      {
        id: 'c4',
        text: 'Superplasticizer'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'High temperatures speed up cement hydration, causing concrete to set faster than expected. This is a problem during long deliveries or large pours because the concrete may begin to stiffen in the truck before it can be placed. A retarder slows the hydration reaction, giving more working time. This is standard practice for hot-weather concreting. Choice B (accelerator) does the opposite -- it speeds up setting, which would make the problem worse. Accelerators are used in cold weather, not hot. Choice C (air-entraining agent) improves freeze-thaw durability but does not address setting time. Choice D (superplasticizer) improves workability but does not delay setting -- in fact, many superplasticizers can slightly accelerate initial stiffening. The question is hard because students need to connect the environmental condition (hot weather) to the correct admixture category and distinguish retarders from the other types.',
    hint: 'Hot weather accelerates hydration. You need an admixture that slows the chemical reaction, not one that improves flow or adds air.',
    steps: [
      {
        text: 'Hot weather accelerates cement hydration, causing premature setting.',
        latex: null
      },
      {
        text: 'A retarder slows the hydration reaction, extending working time.',
        latex: null
      },
      {
        text: 'Accelerators do the opposite (used in cold weather). Air-entrainers and superplasticizers address different properties.',
        latex: null
      }
    ],
    handbookPage: 'p. 125',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Choosing an accelerator because it sounds like it would "help" -- accelerators make hot-weather problems worse',
      'Picking a superplasticizer because the concrete seems hard to work with -- slump loss from heat is a setting issue, not just a flow issue'
    ],
    diagram: null,
    lessonId: 'concrete-mix-design',
    chapterId: 'materials'
  },
  {
    id: 'mat-ccs-ex1',
    type: 'conceptual',
    statement: 'Concrete gains strength through the chemical reaction between cement and water. This process is called:',
    choices: [
      {
        id: 'c1',
        text: 'Hydration'
      },
      {
        id: 'c2',
        text: 'Carbonation'
      },
      {
        id: 'c3',
        text: 'Calcination'
      },
      {
        id: 'c4',
        text: 'Oxidation'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Hydration is the chemical reaction between Portland cement and water that produces calcium silicate hydrate (C-S-H) gel, which is the primary binder that gives concrete its strength. This reaction requires water to continue, which is why moist curing is so important. Choice B (carbonation) is a different process where atmospheric CO$_2$ reacts with calcium hydroxide in cured concrete -- it can lower the pH and reduce corrosion protection for rebar, but it is not the strength-gaining reaction. Choice C (calcination) is the heating of limestone to produce cement clinker during manufacturing -- it happens in the kiln, not in placed concrete. Choice D (oxidation) is a general chemistry term for electron loss (like rusting), not the cement-water reaction.',
    hint: 'The reaction that gives concrete its strength involves water chemically combining with cement compounds.',
    steps: [
      {
        text: 'Cement + water = hydration reaction, producing C-S-H gel (the binder).',
        latex: null
      },
      {
        text: 'Hydration requires continuous moisture, which is why curing conditions matter.',
        latex: null
      },
      {
        text: 'Carbonation, calcination, and oxidation are unrelated processes.',
        latex: null
      }
    ],
    handbookPage: 'p. 125',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing hydration (cement + water in placed concrete) with calcination (heating limestone during cement manufacturing)'
    ],
    diagram: null,
    lessonId: 'concrete-curing-strength',
    chapterId: 'materials'
  },
  {
    id: 'mat-ccs-ex2',
    type: 'conceptual',
    statement: 'Concrete has a 28-day compressive strength of $5{,}000 \\text{ psi}$. Its tensile strength is most nearly:',
    choices: [
      {
        id: 'c1',
        text: '$50 \\text{ psi}$'
      },
      {
        id: 'c2',
        text: '$2{,}500 \\text{ psi}$'
      },
      {
        id: 'c3',
        text: '$5{,}000 \\text{ psi}$'
      },
      {
        id: 'c4',
        text: '$400$ to $600 \\text{ psi}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Concrete\'s tensile strength is approximately 8-12% of its compressive strength. For $f\'_c = 5{,}000$ psi: the low end is $0.08 \\times 5{,}000 = 400$ psi and the high end is $0.12 \\times 5{,}000 = 600$ psi. This is why concrete must be reinforced with steel in tension zones -- it simply cannot handle significant tensile loads on its own. Choice B (2,500 psi) assumes tensile strength is 50% of compressive -- way too high. Choice C (5,000 psi) assumes they are equal -- concrete is dramatically weaker in tension than compression. Choice A (50 psi) is only 1% of compressive strength, which is too low even for concrete.',
    hint: 'Concrete is strong in compression but weak in tension. The tensile-to-compressive strength ratio is roughly 1:10.',
    steps: [
      {
        text: 'Tensile strength of concrete is approximately 8-12% of compressive strength.',
        latex: null
      },
      {
        text: 'Low estimate:',
        latex: '0.08 \\times 5{,}000 = 400 \\text{ psi}'
      },
      {
        text: 'High estimate:',
        latex: '0.12 \\times 5{,}000 = 600 \\text{ psi}'
      }
    ],
    handbookPage: 'p. 125',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Overestimating tensile strength -- concrete is extremely weak in tension relative to compression',
      'Forgetting the 8-12% ratio and guessing that tensile strength is about half of compressive'
    ],
    diagram: null,
    lessonId: 'concrete-curing-strength',
    chapterId: 'materials'
  },
  {
    id: 'mat-ccs-ex3',
    type: 'computational',
    statement: 'A concrete mix is designed for $f\'_c = 5{,}000 \\text{ psi}$ at 28 days under continuous moist curing. The contractor stops moist curing after 3 days and leaves the concrete exposed to air. According to the FE Handbook, concrete moist-cured for only 3 days reaches approximately $55\\%$ of the continuously moist-cured 28-day strength. The expected 28-day strength of this partially cured concrete is most nearly:',
    choices: [
      {
        id: 'c1',
        text: '$9{,}090 \\text{ psi}$'
      },
      {
        id: 'c2',
        text: '$2{,}750 \\text{ psi}$'
      },
      {
        id: 'c3',
        text: '$4{,}450 \\text{ psi}$'
      },
      {
        id: 'c4',
        text: '$5{,}000 \\text{ psi}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The concrete was designed to reach 5,000 psi under continuous moist curing, but the contractor only cured it for 3 days. According to the handbook, stopping moist curing at 3 days means the concrete reaches only about 55% of the full 28-day moist-cured strength: $0.55 \\times 5{,}000 = 2{,}750$ psi. That is a massive reduction -- it will not meet the design strength. Choice A (9,090 psi) divides instead of multiplies: 5,000/0.55. Choice C (4,450 psi) subtracts 55% of the strength loss (5,000 - 550 = 4,450), confusing the percentage with a small deduction. Choice D (5,000 psi) ignores the curing effect entirely.',
    hint: 'Stopping moist curing early means the concrete reaches only a fraction of its full potential strength. Multiply, do not divide.',
    steps: [
      {
        text: 'Design strength under continuous moist curing:',
        latex: 'f\'_c = 5{,}000 \\text{ psi}'
      },
      {
        text: 'Curing factor for 3-day moist curing then air: approximately 0.55',
        latex: null
      },
      {
        text: 'Expected field strength:',
        latex: 'f\'_{c,\\text{field}} = 0.55 \\times 5{,}000 = 2{,}750 \\text{ psi}'
      }
    ],
    handbookPage: 'p. 125',
    handbookFormula: '\\text{Concrete strength vs. curing conditions (graph)}',
    videoUrl: null,
    traps: [
      'Dividing by 0.55 instead of multiplying -- gives 9,090 psi, which would mean early curing removal somehow increases strength',
      'Assuming the 55% is a small penalty rather than a severe one'
    ],
    diagram: null,
    lessonId: 'concrete-curing-strength',
    chapterId: 'materials'
  },
  {
    id: 'mat-ccs-ex4',
    type: 'conceptual',
    statement: 'A structural engineer is reviewing cylinder break results for a concrete slab. The 28-day results from one batch show $f\'_c = 3{,}800 \\text{ psi}$, which is below the specified $4{,}000 \\text{ psi}$. Which of the following is the most appropriate next step?',
    choices: [
      {
        id: 'c1',
        text: 'Accept the concrete as placed since 3,800 psi is close enough to 4,000 psi'
      },
      {
        id: 'c2',
        text: 'Demolish and replace the entire slab immediately'
      },
      {
        id: 'c3',
        text: 'Take cores from the in-place concrete and test them to evaluate the actual structural capacity'
      },
      {
        id: 'c4',
        text: 'Increase the curing duration to allow the concrete to reach 4,000 psi'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'When cylinder breaks fall below the specified $f\'_c$, the first step is to investigate the actual in-place strength before making costly decisions. Core testing (ASTM C42) extracts samples from the structure itself and provides a more representative measure of the concrete that was actually placed and cured in the field. Cylinders are cured under ideal lab conditions, so they may not reflect field conditions exactly -- and the difference can go either way. Choice B (demolish) is premature and expensive; you need evidence that the structure is actually deficient, not just that one batch of cylinders was low. Choice A (accept as-is) is not appropriate without engineering justification -- you cannot just ignore specification non-compliance. Choice D (more curing) is unrealistic at 28 days; most of the strength gain has already occurred, and going from 3,800 to 4,000 psi through additional curing past 28 days is unlikely to fully close that gap.',
    hint: 'Cylinder results represent lab-cured specimens, not necessarily the actual structure. The next step is to evaluate what is actually in place.',
    steps: [
      {
        text: 'Cylinder breaks below the specified strength trigger an investigation, not immediate demolition.',
        latex: null
      },
      {
        text: 'Core testing (ASTM C42) evaluates the actual in-place concrete strength.',
        latex: null
      },
      {
        text: 'Core results, combined with structural analysis, determine if the concrete is acceptable or must be replaced.',
        latex: null
      },
      {
        text: 'Accepting without investigation or demolishing without evidence are both inappropriate responses.',
        latex: null
      }
    ],
    handbookPage: 'p. 125',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Jumping to demolition without investigation -- core testing may show the in-place concrete is adequate',
      'Assuming additional curing past 28 days will significantly close a strength deficit -- strength gain beyond 28 days is minimal'
    ],
    diagram: null,
    lessonId: 'concrete-curing-strength',
    chapterId: 'materials'
  },
  {
    id: 'mat-cm-ex1',
    type: 'computational',
    statement: 'A composite material consists of 60% glass fiber ($E_f = 72\\,\\text{GPa}$) and 40% epoxy matrix ($E_m = 3.5\\,\\text{GPa}$) by volume. What is the longitudinal modulus of the composite using the rule of mixtures?',
    choices: [
      {
        id: 'c1',
        text: '30.2 GPa'
      },
      {
        id: 'c2',
        text: '37.8 GPa'
      },
      {
        id: 'c3',
        text: '44.6 GPa'
      },
      {
        id: 'c4',
        text: '72.0 GPa'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The rule of mixtures for longitudinal modulus is simply $E_c = V_f E_f + V_m E_m$. So $E_c = 0.60(72) + 0.40(3.5) = 43.2 + 1.4 = 44.6$ GPa. The trap is using the inverse rule of mixtures (which applies to the transverse direction, not longitudinal).',
    hint: 'Use the rule of mixtures for the longitudinal (iso-strain) direction.',
    steps: [
      {
        text: 'Rule of mixtures for longitudinal modulus:',
        latex: 'E_c = V_f E_f + V_m E_m'
      },
      {
        text: 'Substitute:',
        latex: 'E_c = 0.60(72) + 0.40(3.5) = 43.2 + 1.4'
      },
      {
        text: 'Result:',
        latex: 'E_c = 44.6\\,\\text{GPa}'
      }
    ],
    handbookPage: 'p. 120',
    handbookFormula: 'E_c = V_f E_f + V_m E_m',
    videoUrl: null,
    traps: [
      'Using the inverse rule (transverse) instead of direct rule (longitudinal)',
      'Confusing weight fraction with volume fraction'
    ],
    diagram: null,
    lessonId: 'composite-materials',
    chapterId: 'materials'
  },
  {
    id: 'mat-cm-ex2',
    type: 'conceptual',
    statement: 'Which of the following best describes why fiber-reinforced composites are strongest in the fiber direction?',
    choices: [
      {
        id: 'c1',
        text: 'The matrix material is stronger than the fibers'
      },
      {
        id: 'c2',
        text: 'Load is transferred through the matrix to the high-strength fibers via shear'
      },
      {
        id: 'c3',
        text: 'The fibers prevent the matrix from deforming in any direction'
      },
      {
        id: 'c4',
        text: 'The composite has isotropic properties in all directions'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'In a fiber composite, the fibers carry the load (they are much stronger and stiffer). The matrix transfers load to the fibers through interfacial shear. That is why composites are strongest along the fiber direction — the fibers are aligned to carry axial load. Perpendicular to fibers, the weaker matrix dominates. This is why composites are anisotropic, not isotropic.',
    hint: 'Think about the role of fibers vs. matrix in carrying load.',
    steps: [
      {
        text: 'Fibers are strong and stiff; the matrix is weaker but binds the fibers.',
        latex: null
      },
      {
        text: 'The matrix transfers applied load to the fibers through interfacial shear stress.',
        latex: null
      },
      {
        text: 'In the fiber direction, fibers carry most of the load, making the composite strongest in that direction.',
        latex: null
      }
    ],
    handbookPage: 'p. 120',
    handbookFormula: null,
    videoUrl: null,
    traps: ['Thinking composites are isotropic — they are anisotropic (direction-dependent)'],
    diagram: null,
    lessonId: 'composite-materials',
    chapterId: 'materials'
  },
  {
    id: 'mat-cm-ex3',
    type: 'conceptual',
    statement: 'In a unidirectional fiber-reinforced composite, the elastic modulus measured perpendicular to the fibers is significantly lower than the modulus measured parallel to the fibers. Which statement best explains this difference?',
    choices: [
      {
        id: 'c1',
        text: 'The fibers are weaker in the transverse direction'
      },
      {
        id: 'c2',
        text: 'The volume fraction of fibers is lower in the transverse direction'
      },
      {
        id: 'c3',
        text: 'Perpendicular loading follows the isostress (Reuss) model, where the weak matrix dominates the response'
      },
      {
        id: 'c4',
        text: 'The matrix carries all the load in both directions'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'When you load parallel to fibers, both phases strain equally (isostrain) and the stiff fibers dominate, giving a high composite modulus. When you load perpendicular, both phases carry the same stress (isostress) but strain differently. The soft matrix deforms much more, dragging the composite modulus down toward the matrix value. The reciprocal formula $1/E_c = f_1/E_1 + f_2/E_2$ always gives a lower result than the additive formula. The volume fraction does not change with direction -- the composite is the same material either way.',
    hint: 'Think about which averaging model applies in each direction: additive (isostrain) vs. reciprocal (isostress).',
    steps: [
      {
        text: 'Parallel to fibers: isostrain condition. Both phases have equal strain; the stiffer fibers dominate.',
        latex: 'E_{c,\\parallel} = f_f E_f + f_m E_m'
      },
      {
        text: 'Perpendicular to fibers: isostress condition. Both phases carry equal stress; the compliant matrix dominates.',
        latex: '\\frac{1}{E_{c,\\perp}} = \\frac{f_f}{E_f} + \\frac{f_m}{E_m}'
      },
      {
        text: 'The reciprocal formula always yields a lower composite modulus than the additive formula for the same constituents.',
        latex: null
      }
    ],
    handbookPage: 'p. 123',
    handbookFormula: '\\frac{1}{E_c} = \\frac{f_1}{E_1} + \\frac{f_2}{E_2}',
    videoUrl: null,
    traps: [
      'Thinking the volume fraction changes with loading direction -- it does not',
      'Confusing isostrain (parallel) with isostress (perpendicular) conditions'
    ],
    diagram: null,
    lessonId: 'composite-materials',
    chapterId: 'materials'
  },
  {
    id: 'mat-cm-ex4',
    type: 'conceptual',
    statement: 'A civil engineer is evaluating whether to wrap deteriorated concrete bridge columns with carbon fiber reinforced polymer (CFRP) sheets. Which of the following is the primary structural benefit of the CFRP wrap?',
    choices: [
      {
        id: 'c1',
        text: 'It increases the compressive strength of the concrete by chemically bonding with the cement paste'
      },
      {
        id: 'c2',
        text: 'It provides confinement pressure that increases the axial load capacity and ductility of the column'
      },
      {
        id: 'c3',
        text: 'It replaces the function of internal reinforcing steel so the corroded rebar can be removed'
      },
      {
        id: 'c4',
        text: 'It reduces the thermal expansion of the column, preventing cracking from temperature changes'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'CFRP wraps work by confining the concrete column. When the column is loaded axially, it tries to expand laterally (Poisson effect). The stiff carbon fibers resist that lateral expansion, creating a confining pressure that increases both the axial strength and ductility of the confined concrete. The wrap does not chemically bond with cement paste or replace rebar. Internal steel is still needed for flexural and shear capacity. The thermal expansion benefit is negligible compared to the confinement effect.',
    hint: 'Think about what happens when a column under axial load tries to expand laterally and a stiff wrap resists that expansion.',
    steps: [
      {
        text: 'Under axial compression, concrete expands laterally due to the Poisson effect.',
        latex: null
      },
      {
        text: 'The CFRP wrap resists lateral expansion, creating a passive confining pressure around the column.',
        latex: null
      },
      {
        text: 'Confined concrete has higher compressive strength and significantly greater ductility than unconfined concrete.',
        latex: null
      }
    ],
    handbookPage: 'p. 123',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking the wrap chemically bonds to concrete -- it provides mechanical confinement, not chemical strengthening',
      'Assuming CFRP wrap replaces rebar -- rebar is still needed for bending and shear resistance'
    ],
    diagram: null,
    lessonId: 'composite-materials',
    chapterId: 'materials'
  },
  {
    id: 'mat-cms-ex1',
    type: 'conceptual',
    statement: 'For corrosion to occur on a metal surface, four components must be present. Which of the following is NOT one of the four requirements for electrochemical corrosion?',
    choices: [
      {
        id: 'c1',
        text: 'An anode'
      },
      {
        id: 'c2',
        text: 'A cathode'
      },
      {
        id: 'c3',
        text: 'An electrolyte'
      },
      {
        id: 'c4',
        text: 'An external power source'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'The four requirements for galvanic corrosion are: an anode, a cathode, an electrolyte, and an electrical connection (metallic path) between the anode and cathode. An external power source is NOT required -- galvanic corrosion generates its own driving voltage from the difference in electrochemical potential between the two metals. An external power source is used in impressed-current cathodic protection, which is a method of preventing corrosion, not a requirement for it to occur. Choices A, B, and C are all legitimate requirements.',
    hint: 'Galvanic corrosion is driven by the electrochemical potential difference between dissimilar metals -- no battery or external circuit is needed.',
    steps: [
      {
        text: 'The four requirements for corrosion: (1) anode, (2) cathode, (3) electrolyte, (4) electrical connection between anode and cathode.',
        latex: null
      },
      {
        text: 'An external power source is not required -- the potential difference between the metals drives the reaction naturally.',
        latex: null
      },
      {
        text: 'Impressed current (external power) is a corrosion prevention method, not a corrosion requirement.',
        latex: null
      }
    ],
    handbookPage: 'p. 116',
    handbookFormula: 'M^0 \\rightarrow M^{n+} + ne^-',
    videoUrl: null,
    traps: [
      'Confusing impressed-current cathodic protection (a prevention method) with a corrosion requirement'
    ],
    diagram: null,
    lessonId: 'corrosion-material-selection',
    chapterId: 'materials'
  },
  {
    id: 'mat-cms-ex2',
    type: 'computational',
    statement: 'A plain carbon steel component has a Brinell hardness number (BHN) of 200. Using the approximate relationship from the FE Handbook, the estimated tensile strength is most nearly:',
    choices: [
      {
        id: 'c1',
        text: '$700 \\text{ MPa}$'
      },
      {
        id: 'c2',
        text: '$100{,}000 \\text{ psi}$'
      },
      {
        id: 'c3',
        text: '$57 \\text{ psi}$'
      },
      {
        id: 'c4',
        text: '$400{,}000 \\text{ psi}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The FE Handbook (p. 122) gives the approximation: $\\text{TS (psi)} \\approx 500 \\times \\text{BHN}$. Plugging in: $500 \\times 200 = 100{,}000$ psi. Choice A (700 MPa) uses the metric approximation $\\text{TS (MPa)} \\approx 3.5 \\times \\text{BHN} = 3.5 \\times 200 = 700$ MPa. That is also a correct conversion, but the question asks for the answer using the handbook relationship, and 100,000 psi is the direct result. Choice C (57 psi) divides BHN by something nonsensical. Choice D (400,000 psi) uses an incorrect multiplier of 2,000.',
    hint: 'The FE Handbook gives a direct multiplier to convert BHN to tensile strength in psi for plain carbon steels.',
    steps: [
      {
        text: 'Handbook relationship for plain carbon steels:',
        latex: '\\text{TS (psi)} \\approx 500 \\times \\text{BHN}'
      },
      {
        text: 'Substitute BHN = 200:',
        latex: '\\text{TS} \\approx 500 \\times 200 = 100{,}000 \\text{ psi}'
      }
    ],
    handbookPage: 'p. 122',
    handbookFormula: '\\text{TS(psi)} \\simeq 500 \\text{ BHN}',
    videoUrl: null,
    traps: [
      'Using the metric conversion (3.5 BHN) when the answer choices are in psi',
      'Dividing instead of multiplying'
    ],
    diagram: null,
    lessonId: 'corrosion-material-selection',
    chapterId: 'materials'
  },
  {
    id: 'mat-cms-ex3',
    type: 'conceptual',
    statement: 'A buried steel pipeline is protected by attaching zinc anodes at regular intervals along its length. This corrosion protection strategy is best described as:',
    choices: [
      {
        id: 'c1',
        text: 'Anodic protection'
      },
      {
        id: 'c2',
        text: 'Impressed-current cathodic protection'
      },
      {
        id: 'c3',
        text: 'Sacrificial anode cathodic protection'
      },
      {
        id: 'c4',
        text: 'Passivation'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Attaching a more active metal (zinc) to the structure you want to protect (steel pipeline) is called sacrificial anode cathodic protection. The zinc is more active than steel in the galvanic series, so it corrodes preferentially while the steel becomes the cathode and is protected. Choice B (impressed-current) uses an external DC power supply and inert anodes -- there is no external power source described here. Choice A (anodic protection) is a different technique that uses a controlled external current to form a passive film on the structure -- the opposite concept. Choice D (passivation) refers to forming a protective oxide layer (like on stainless steel), not attaching sacrificial metals.',
    hint: 'When a more active metal is physically attached to protect a less active metal, the active metal "sacrifices" itself.',
    steps: [
      {
        text: 'Zinc is more active (anodic) than steel in the galvanic series.',
        latex: null
      },
      {
        text: 'The zinc corrodes preferentially, making the steel the cathode (protected).',
        latex: null
      },
      {
        text: 'This is sacrificial anode cathodic protection -- no external power needed.',
        latex: null
      }
    ],
    handbookPage: 'p. 116',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing sacrificial anode protection with impressed-current protection -- the key difference is whether external power is used'
    ],
    diagram: null,
    lessonId: 'corrosion-material-selection',
    chapterId: 'materials'
  },
  {
    id: 'mat-cms-ex4',
    type: 'conceptual',
    statement: 'Cold working a metal (plastic deformation at room temperature) has which of the following effects on its mechanical properties?',
    choices: [
      {
        id: 'c1',
        text: 'Increases both strength and ductility'
      },
      {
        id: 'c2',
        text: 'Decreases strength and increases ductility'
      },
      {
        id: 'c3',
        text: 'Increases strength and decreases ductility'
      },
      {
        id: 'c4',
        text: 'Decreases both strength and ductility'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The FE Handbook (p. 116) states directly: "Cold working (plastically deforming) a metal increases strength and lowers ductility." This is because cold working introduces dislocations into the crystal structure, which makes it harder for further deformation to occur (higher strength) but also reduces the material\'s ability to deform before fracture (lower ductility). This is a classic trade-off in materials science. Choice B is exactly backwards. Choice A sounds appealing but violates the fundamental strength-ductility trade-off. Choice D is wrong on both counts. The question is hard because students often confuse cold working with heat treatment (annealing), which does the opposite -- it relieves internal stresses and restores ductility at the cost of strength.',
    hint: 'Cold working introduces dislocations that resist further deformation. Think about what that means for both strength and the ability to stretch.',
    steps: [
      {
        text: 'Cold working = plastic deformation at temperatures below the recrystallization temperature.',
        latex: null
      },
      {
        text: 'Dislocation density increases, making further slip more difficult.',
        latex: null
      },
      {
        text: 'Result: higher yield and tensile strength, but lower ductility (less elongation before fracture).',
        latex: null
      },
      {
        text: 'Annealing (heating) reverses this effect through recovery, recrystallization, and grain growth.',
        latex: null
      }
    ],
    handbookPage: 'p. 116',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing cold working with annealing -- annealing restores ductility and lowers strength',
      'Thinking that stronger always means tougher -- cold-worked metals are stronger but more brittle'
    ],
    diagram: null,
    lessonId: 'corrosion-material-selection',
    chapterId: 'materials'
  },
  {
    id: 'mat-agg-ex1',
    type: 'computational',
    statement: 'A coarse aggregate sample weighs $1{,}020\\text{ g}$ saturated-surface-dry and $1{,}000\\text{ g}$ oven-dry. What is its absorption?',
    choices: [
      { id: 'c1', text: '$2.0\\%$' },
      { id: 'c2', text: '$1.96\\%$' },
      { id: 'c3', text: '$20\\%$' },
      { id: 'c4', text: '$0.2\\%$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Absorption = (SSD − OD)/OD × 100 = (1,020 − 1,000)/1,000 × 100 = 20/1,000 × 100 = 2.0%. Choice B divides by SSD weight. Choice C forgets to divide by the mass. Choice D drops a factor of 10.',
    hint: 'Absorption = (SSD − oven-dry)/oven-dry × 100.',
    steps: [
      { text: 'Water absorbed:', latex: '1{,}020 - 1{,}000 = 20\\text{ g}' },
      { text: 'Divide by dry mass:', latex: '\\frac{20}{1{,}000} \\times 100 = 2.0\\%' },
    ],
    handbookPage: null,
    handbookFormula: '\\text{Absorption} = (W_{SSD} - W_{OD})/W_{OD} \\times 100',
    videoUrl: null,
    traps: [
      'Dividing by the SSD weight instead of the oven-dry weight',
      'Reporting the raw water mass instead of a percentage',
    ],
    diagram: null,
    lessonId: 'aggregate-properties',
    chapterId: 'materials'
  },
  {
    id: 'mat-asp-ex1',
    type: 'computational',
    statement: 'A compacted asphalt mix has bulk specific gravity $G_{mb} = 2.350$ and theoretical maximum specific gravity $G_{mm} = 2.470$. What is the air void content?',
    choices: [
      { id: 'c1', text: '$4.9\\%$' },
      { id: 'c2', text: '$5.1\\%$' },
      { id: 'c3', text: '$12.0\\%$' },
      { id: 'c4', text: '$0.95\\%$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'V_a = 100 × (Gmm − Gmb)/Gmm = 100 × (2.470 − 2.350)/2.470 = 100 × 0.120/2.470 = 4.9%. Choice B divides by Gmb instead of Gmm. Choice C forgets to divide by Gmm. Choice D inverts the fraction.',
    hint: 'Air voids = 100 × (Gmm − Gmb)/Gmm.',
    steps: [
      { text: 'Difference:', latex: 'G_{mm} - G_{mb} = 2.470 - 2.350 = 0.120' },
      { text: 'Air voids:', latex: 'V_a = 100 \\times \\frac{0.120}{2.470} = 4.9\\%' },
    ],
    handbookPage: null,
    handbookFormula: 'V_a = 100(G_{mm} - G_{mb})/G_{mm}',
    videoUrl: null,
    traps: [
      'Dividing by G_mb instead of G_mm',
      'Swapping the two specific gravities',
    ],
    diagram: null,
    lessonId: 'asphalt-mix-design',
    chapterId: 'materials'
  },
  {
    id: 'mat-wm-ex1',
    type: 'computational',
    statement: 'A timber specimen weighs $108\\text{ lb}$ as received and $90\\text{ lb}$ after oven drying. What is its moisture content?',
    choices: [
      { id: 'c1', text: '$20\\%$' },
      { id: 'c2', text: '$16.7\\%$' },
      { id: 'c3', text: '$18\\%$' },
      { id: 'c4', text: '$83\\%$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'MC = (wet − OD)/OD × 100 = (108 − 90)/90 × 100 = 18/90 × 100 = 20%. Choice B divides by the wet weight (108). Choice C reports the raw water mass. Choice D divides oven-dry by wet.',
    hint: 'Moisture content = (wet − oven-dry)/oven-dry × 100.',
    steps: [
      { text: 'Water mass:', latex: '108 - 90 = 18\\text{ lb}' },
      { text: 'Divide by oven-dry mass:', latex: '\\frac{18}{90} \\times 100 = 20\\%' },
    ],
    handbookPage: null,
    handbookFormula: 'MC = (W_{wet} - W_{OD})/W_{OD} \\times 100',
    videoUrl: null,
    traps: [
      'Dividing by the wet weight instead of the oven-dry weight',
      'Reporting the raw water mass as the moisture content',
    ],
    diagram: null,
    lessonId: 'wood-masonry',
    chapterId: 'materials'
  },
  {
    id: 'mat-wm-ex2',
    type: 'conceptual',
    statement: 'A masonry specification calls for the strongest available mortar to resist high compressive and lateral loads. Which mortar type should be specified?',
    choices: [
      { id: 'c1', text: 'Type M' },
      { id: 'c2', text: 'Type N' },
      { id: 'c3', text: 'Type O' },
      { id: 'c4', text: 'Type S' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Mortar types run M, S, N, O from strongest to weakest, so Type M has the highest compressive strength and is specified where strength governs. Type S is second. Types N and O are progressively weaker, general-purpose and interior mortars.',
    hint: 'Strength order M > S > N > O ("MaSoN wOrK").',
    steps: [
      { text: 'Mortar strength order: M > S > N > O.', latex: null },
      { text: 'The strongest is Type M.', latex: null },
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Picking Type S or N as the strongest',
      'Assuming alphabetical order tracks strength',
    ],
    diagram: null,
    lessonId: 'wood-masonry',
    chapterId: 'materials'
  },
];

export default PROBLEMS;
