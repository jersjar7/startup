// Exam bank: structural
// Auto-extracted from lesson files — 32 questions

const PROBLEMS = [
  {
    id: 'str-ds-ex1',
    type: 'computational',
    statement: 'A planar truss has 9 members, 6 joints, and 3 external reactions. Is the truss statically determinate?',
    choices: [
      {
        id: 'c1',
        text: 'No, it is statically indeterminate by 2 degrees'
      },
      {
        id: 'c2',
        text: 'No, it is statically indeterminate by 1 degree'
      },
      {
        id: 'c3',
        text: 'No, it is unstable'
      },
      {
        id: 'c4',
        text: 'Yes, it is statically determinate'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'For a truss: $m + r = 2j$ for determinate. Here: $9 + 3 = 12$, and $2(6) = 12$. Since $m + r = 2j$, the truss is statically determinate. If $m + r > 2j$, it is indeterminate. If $m + r < 2j$, it is unstable.',
    hint: 'Check if $m + r = 2j$ for a truss.',
    steps: [
      {
        text: 'Determinacy condition for a planar truss:',
        latex: 'm + r = 2j'
      },
      {
        text: 'Check: $m + r = 9 + 3 = 12$, and $2j = 2(6) = 12$.',
        latex: null
      },
      {
        text: 'Since $12 = 12$, the truss is statically determinate.',
        latex: null
      }
    ],
    handbookPage: 'p. 259',
    handbookFormula: 'm + r = 2j \\quad \\text{(determinate)}',
    videoUrl: null,
    traps: ['Confusing the truss formula (m+r=2j) with the beam/frame formula (3m+r=3j+c)'],
    diagram: {
      component: 'TrussSchematic',
      props: {
        variant: 'pratt6',
        leftSupport: 'pin',
        rightSupport: 'roller'
      }
    },
    lessonId: 'determinacy-stability',
    chapterId: 'structural'
  },
  {
    id: 'str-ds-ex2',
    type: 'conceptual',
    statement: 'A structure is externally stable but has $m + r > 2j$. This means the structure is:',
    choices: [
      {
        id: 'c1',
        text: 'Unstable'
      },
      {
        id: 'c2',
        text: 'Statically determinate'
      },
      {
        id: 'c3',
        text: 'Statically indeterminate'
      },
      {
        id: 'c4',
        text: 'A mechanism'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'When $m + r > 2j$, there are more unknowns than equilibrium equations. The structure has redundant members or supports -- it is statically indeterminate. You would need compatibility equations in addition to equilibrium to solve it. The degree of indeterminacy is $(m + r) - 2j$.',
    hint: 'What happens when there are more unknowns than equilibrium equations?',
    steps: [
      {
        text: '$m + r > 2j$ means more unknowns than equations of equilibrium.',
        latex: null
      },
      {
        text: 'The structure has redundant members/supports and is statically indeterminate.',
        latex: null
      },
      {
        text: 'Degree of indeterminacy = $(m + r) - 2j$.',
        latex: null
      }
    ],
    handbookPage: 'p. 259',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing indeterminacy with instability — indeterminate means too many supports, unstable means too few'
    ],
    diagram: null,
    lessonId: 'determinacy-stability',
    chapterId: 'structural'
  },
  {
    id: 'str-ds-ex3',
    type: 'computational',
    statement: 'A plane frame has $m = 5$ members, $j = 6$ joints, and two internal hinges ($c = 2$). The supports consist of two pin supports and one roller. What is the degree of static indeterminacy?',
    choices: [
      {
        id: 'c1',
        text: '1'
      },
      {
        id: 'c2',
        text: '0 (statically determinate)'
      },
      {
        id: 'c3',
        text: '2'
      },
      {
        id: 'c4',
        text: '3'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'For frames, compare $3m + r$ to $3j + c$. Reactions: two pins give $2 + 2 = 4$, one roller gives 1, so $r = 5$. Then $3m + r = 3(5) + 5 = 20$, and $3j + c = 3(6) + 2 = 20$. Since $20 = 20$, the frame is statically determinate (degree = 0). Each internal hinge provides one extra condition equation, which reduces the degree of indeterminacy. Without those two hinges, the frame would be indeterminate to the 2nd degree.',
    hint: 'Count reactions from all supports, then use the frame formula $3m + r$ vs $3j + c$.',
    steps: [
      {
        text: 'Count reactions:',
        latex: 'r = 2(2) + 1 = 5 \\text{ (two pins + one roller)}'
      },
      {
        text: 'Frame left side:',
        latex: '3m + r = 3(5) + 5 = 20'
      },
      {
        text: 'Frame right side:',
        latex: '3j + c = 3(6) + 2 = 20'
      },
      {
        text: 'Degree of indeterminacy:',
        latex: '20 - 20 = 0 \\quad \\text{(statically determinate)}'
      }
    ],
    handbookPage: 'p. 259',
    handbookFormula: '3m + r = 3j + c \\implies \\text{Statically determinate}',
    videoUrl: null,
    traps: [
      'Forgetting to include internal hinges in the condition equations (c) — each hinge adds one equation',
      'Mixing up the truss formula (m + r vs 2j) with the frame formula (3m + r vs 3j + c)'
    ],
    diagram: {
      component: 'FrameSchematic',
      props: {
        variant: 'twobay',
        leftSupport: 'pin',
        midSupport: 'roller',
        rightSupport: 'pin',
        hinges: ['left', 'right']
      }
    },
    lessonId: 'determinacy-stability',
    chapterId: 'structural'
  },
  {
    id: 'str-ds-ex4',
    type: 'conceptual',
    statement: 'A planar truss satisfies $m + r > 2j$. However, all external reactions pass through a single point. What is the correct classification?',
    choices: [
      {
        id: 'c1',
        text: 'Unstable — concurrent reactions cannot maintain equilibrium'
      },
      {
        id: 'c2',
        text: 'Stable and statically indeterminate'
      },
      {
        id: 'c3',
        text: 'Stable and statically determinate'
      },
      {
        id: 'c4',
        text: 'Indeterminate unless a moment equation is added'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'The numerical count $m + r > 2j$ suggests indeterminacy, but that equation is only a necessary condition for stability, not a sufficient one. If all reaction lines of action pass through a single point (concurrent reactions), the structure cannot resist a moment about that point. Apply the moment equilibrium equation $\\Sigma M = 0$ at that point and you get 0 = something nonzero, which is impossible. The structure is geometrically unstable regardless of how many extra members or reactions it has. Always check the arrangement of reactions, not just the count.',
    hint: 'The determinacy equation is necessary but not sufficient. What happens if you sum moments about the point where all reactions intersect?',
    steps: [
      {
        text: 'The count $m + r > 2j$ suggests indeterminacy.',
        latex: null
      },
      {
        text: 'But all reactions pass through one point (concurrent).',
        latex: null
      },
      {
        text: '$\\Sigma M$ about that point cannot be satisfied for arbitrary loading — the structure is geometrically unstable.',
        latex: null
      },
      {
        text: 'Geometric instability overrides the numerical count.',
        latex: null
      }
    ],
    handbookPage: 'p. 259',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Assuming the numerical count alone guarantees stability — arrangement of reactions matters',
      'Confusing concurrent reactions (all through one point) with parallel reactions (all in one direction) — both cause instability'
    ],
    diagram: null,
    lessonId: 'determinacy-stability',
    chapterId: 'structural'
  },
  {
    id: 'str-lc-ex1',
    type: 'computational',
    statement: 'A roof beam supports $D = 15 \\text{ kips}$ and a roof live load $L_r = 20 \\text{ kips}$. No floor live load, snow, wind, or seismic. What is the factored load using LRFD Combination 3 ($1.2D + 1.6L_r$)?',
    choices: [
      {
        id: 'c1',
        text: '$35 \\text{ kips}$'
      },
      {
        id: 'c2',
        text: '$50 \\text{ kips}$'
      },
      {
        id: 'c3',
        text: '$21 \\text{ kips}$'
      },
      {
        id: 'c4',
        text: '$56 \\text{ kips}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Combination 3 with only roof live load active is $1.2D + 1.6L_r = 1.2(15) + 1.6(20) = 18 + 32 = 50$ kips. Choice A (35) is the unfactored sum $D + L_r = 15 + 20$. Choice C (21) is Combination 1: $1.4D = 1.4(15) = 21$. Choice D (56) comes from applying 1.6 to both loads: $1.6(15) + 1.6(20) = 56$, but dead load gets 1.2, not 1.6.',
    hint: 'Apply the load factors directly: 1.2 on D and 1.6 on $L_r$.',
    steps: [
      {
        text: 'LRFD Combination 3 (no floor live load):',
        latex: '1.2D + 1.6L_r'
      },
      {
        text: 'Substitute:',
        latex: '1.2(15) + 1.6(20) = 18 + 32'
      },
      {
        text: 'Factored load:',
        latex: '= 50 \\text{ kips}'
      }
    ],
    handbookPage: 'p. 272',
    handbookFormula: '1.2D + 1.6(L_r \\text{ or } S \\text{ or } R) + (L \\text{ or } 0.5W)',
    videoUrl: null,
    traps: [
      'Applying 1.6 to dead load instead of 1.2 — dead load always gets the lower factor'
    ],
    diagram: null,
    lessonId: 'load-combinations',
    chapterId: 'structural'
  },
  {
    id: 'str-lc-ex2',
    type: 'conceptual',
    statement: 'In LRFD, why does dead load receive a lower load factor (1.2) than live load (1.6)?',
    choices: [
      {
        id: 'c1',
        text: 'Dead load is more predictable; live load has greater statistical variability'
      },
      {
        id: 'c2',
        text: 'Dead load is always smaller than live load'
      },
      {
        id: 'c3',
        text: 'ASCE 7 assigns factors based on load duration, not uncertainty'
      },
      {
        id: 'c4',
        text: 'Dead load only acts during construction, so it needs a smaller factor'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Load factors in LRFD reflect the uncertainty in predicting each load magnitude. Dead load (self-weight of structure, permanent fixtures) can be calculated accurately from material densities and dimensions, so its variability is low — hence a 1.2 factor. Live load (people, furniture, stored goods) is much harder to predict and varies widely over a building\'s life, so it gets the larger 1.6 factor. Choice B is wrong because dead load can easily exceed live load in some structures. Choice C confuses duration with uncertainty. Choice D is incorrect — dead load acts permanently, not just during construction.',
    hint: 'Think about which load can be estimated more reliably from engineering calculations.',
    steps: [
      {
        text: 'Dead load is computed from known material weights and geometry — low uncertainty.',
        latex: null
      },
      {
        text: 'Live load depends on occupancy and use — high variability over the structure\'s life.',
        latex: null
      },
      {
        text: 'Higher uncertainty → higher load factor to maintain a consistent safety margin.',
        latex: null
      }
    ],
    handbookPage: 'p. 272',
    handbookFormula: '1.2D + 1.6L',
    videoUrl: null,
    traps: [
      'Assuming load factors are based on magnitude rather than uncertainty — a small but uncertain load still gets a high factor'
    ],
    diagram: null,
    lessonId: 'load-combinations',
    chapterId: 'structural'
  },
  {
    id: 'str-lc-ex3',
    type: 'computational',
    statement: 'An interior beam ($K_{LL} = 2$) supports one floor with a tributary area of $A_T = 1{,}200 \\text{ ft}^2$. The unreduced live load is $L_o = 80 \\text{ psf}$. What is the reduced live load?',
    choices: [
      {
        id: 'c1',
        text: '$40 \\text{ psf}$'
      },
      {
        id: 'c2',
        text: '$44 \\text{ psf}$'
      },
      {
        id: 'c3',
        text: '$80 \\text{ psf}$'
      },
      {
        id: 'c4',
        text: '$20 \\text{ psf}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$L = L_o(0.25 + 15/\\sqrt{K_{LL} \\cdot A_T}) = 80(0.25 + 15/\\sqrt{2 \\times 1200}) = 80(0.25 + 15/\\sqrt{2400}) = 80(0.25 + 15/49.0) = 80(0.25 + 0.306) = 80(0.556) = 44.5 \\approx 44$ psf. Check minimum: for one floor, $L \\geq 0.50 L_o = 40$ psf. Since $44 > 40$, the reduction is valid. Choice A (40) is the minimum allowed — it would only apply if the formula gave a value below 40. Choice C (80) is the unreduced load. Choice D (20) misapplies $0.25 \\times L_o$.',
    hint: 'Use $L = L_o(0.25 + 15/\\sqrt{K_{LL} A_T})$ with $K_{LL} = 2$ for beams, then check the one-floor minimum.',
    steps: [
      {
        text: 'Influence area:',
        latex: 'K_{LL} \\cdot A_T = 2 \\times 1{,}200 = 2{,}400 \\text{ ft}^2'
      },
      {
        text: 'Reduction formula:',
        latex: 'L = 80\\left(0.25 + \\frac{15}{\\sqrt{2{,}400}}\\right) = 80(0.25 + 0.306) = 80(0.556)'
      },
      {
        text: 'Reduced live load:',
        latex: 'L = 44.5 \\approx 44 \\text{ psf}'
      },
      {
        text: 'Check: $L \\geq 0.50 L_o = 40$ psf. Since $44 > 40$, OK.',
        latex: null
      }
    ],
    handbookPage: 'p. 272',
    handbookFormula: 'L = L_o \\left(0.25 + \\frac{15}{\\sqrt{K_{LL} A_T}}\\right)',
    videoUrl: null,
    traps: [
      'Using $K_{LL} = 4$ (column value) instead of $K_{LL} = 2$ (beam value)',
      'Skipping the minimum live load check — the formula can over-reduce if the influence area is very large'
    ],
    diagram: null,
    lessonId: 'load-combinations',
    chapterId: 'structural'
  },
  {
    id: 'str-lc-ex4',
    type: 'conceptual',
    statement: 'A column supports $D = 50 \\text{ kips}$, $L = 30 \\text{ kips}$, and $S = 60 \\text{ kips}$. In LRFD Combination 2, $L$ gets the 1.6 factor. In Combination 3, $S$ gets the 1.6 factor. Which combination controls and why?',
    choices: [
      {
        id: 'c1',
        text: 'Combination 1 ($70 \\text{ kips}$) — dead load alone is the critical case'
      },
      {
        id: 'c2',
        text: 'Combination 2 ($138 \\text{ kips}$) — Combination 2 always controls for gravity loading'
      },
      {
        id: 'c3',
        text: 'Combination 3 ($186 \\text{ kips}$) — snow dominates floor live load, so the 1.6 factor on $S$ produces a larger total'
      },
      {
        id: 'c4',
        text: 'They are equal because $D$ has the same factor in both'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'Combo 2: $1.2(50) + 1.6(30) + 0.5(60) = 60 + 48 + 30 = 138$ kips. Combo 3: $1.2(50) + 1.6(60) + 1.0(30) = 60 + 96 + 30 = 186$ kips. Combo 3 controls at 186 kips because snow ($S = 60$) is much larger than floor live load ($L = 30$), so putting the 1.6 factor on snow amplifies the dominant transient load. Choice B assumes Combo 2 always governs — that is only true when floor live load exceeds snow. You must always evaluate multiple combinations and pick the largest.',
    hint: 'Compute both combinations. The 1.6 factor amplifies whichever load it multiplies — when $S > L$, putting 1.6 on $S$ produces more.',
    steps: [
      {
        text: 'Combo 2:',
        latex: '1.2(50) + 1.6(30) + 0.5(60) = 60 + 48 + 30 = 138 \\text{ kips}'
      },
      {
        text: 'Combo 3:',
        latex: '1.2(50) + 1.6(60) + 1.0(30) = 60 + 96 + 30 = 186 \\text{ kips}'
      },
      {
        text: 'Combo 3 controls ($186 > 138$) because snow is the dominant transient load.',
        latex: null
      }
    ],
    handbookPage: 'p. 272',
    handbookFormula: '1.2D + 1.6(L_r \\text{ or } S \\text{ or } R) + (L \\text{ or } 0.5W)',
    videoUrl: null,
    traps: [
      'Assuming Combination 2 always controls — it only does when floor live load exceeds roof/snow loads',
      'Forgetting to include the companion load in Combination 3 ($L$ at factor 1.0)'
    ],
    diagram: null,
    lessonId: 'load-combinations',
    chapterId: 'structural'
  },
  {
    id: 'str-il-ex1',
    type: 'computational',
    statement: 'A simply supported beam spans $L = 20 \\text{ ft}$. Using the influence line for the left reaction $R_A$, what is the IL ordinate when a unit load is placed $5 \\text{ ft}$ from the left support?',
    choices: [
      {
        id: 'c1',
        text: '$0.25$'
      },
      {
        id: 'c2',
        text: '$0.75$'
      },
      {
        id: 'c3',
        text: '$1.00$'
      },
      {
        id: 'c4',
        text: '$0.50$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The influence line ordinate for the left reaction at position $x$ from the left support is $(L - x)/L$. At $x = 5$ ft: $(20 - 5)/20 = 15/20 = 0.75$. This means when a unit load sits 5 ft from A, the left reaction carries 75% of it. Choice A (0.25) uses $x/L$ instead of $(L - x)/L$ -- that would be the reaction at B. Choice C (1.0) is the ordinate when the load is directly over A ($x = 0$).',
    hint: 'The IL for $R_A$ is linear from 1.0 at A to 0 at B. The ordinate at position $x$ from A is $(L - x)/L$.',
    steps: [
      {
        text: 'IL ordinate for left reaction:',
        latex: '\\eta = \\frac{L - x}{L} = \\frac{20 - 5}{20} = 0.75'
      }
    ],
    handbookPage: 'p. 268',
    handbookFormula: '\\eta_{R_A}(x) = \\frac{L - x}{L}',
    videoUrl: null,
    traps: ['Using x/L instead of (L - x)/L — that gives the right reaction, not the left'],
    diagram: {
      component: 'InfluenceLineSS',
      props: {
        type: 'reaction',
        L: 20,
        a: 5,
        unit: 'ft'
      }
    },
    lessonId: 'influence-lines',
    chapterId: 'structural'
  },
  {
    id: 'str-il-ex2',
    type: 'conceptual',
    statement: 'For a simply supported beam, where does the influence line for bending moment at a section located at distance $a$ from the left support have its maximum ordinate?',
    choices: [
      {
        id: 'c1',
        text: 'Directly at the section, with ordinate $a(L - a)/L$'
      },
      {
        id: 'c2',
        text: 'At midspan, with ordinate $L/4$'
      },
      {
        id: 'c3',
        text: 'At the left support, with ordinate 1.0'
      },
      {
        id: 'c4',
        text: 'At the right support, with ordinate 1.0'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The influence line for bending moment at a section is triangular. It goes from 0 at both supports to a peak at the section itself. The peak ordinate is $a(L - a)/L$. This means to produce the maximum moment at that section, you place the load directly at the section. Choice B ($L/4$) is only correct when the section happens to be at midspan ($a = L/2$, giving $L/4$). Choices C and D describe the reaction influence line, not the moment influence line.',
    hint: 'The IL for moment at a section forms a triangle — think about where the peak of that triangle occurs.',
    steps: [
      {
        text: 'The IL for moment at section $a$ is triangular, peaking at the section.',
        latex: null
      },
      {
        text: 'Peak ordinate:',
        latex: '\\eta_{\\max} = \\frac{a(L - a)}{L}'
      },
      {
        text: 'At midspan ($a = L/2$):',
        latex: '\\eta = \\frac{(L/2)(L/2)}{L} = \\frac{L}{4}'
      }
    ],
    handbookPage: 'p. 268',
    handbookFormula: '\\eta_M = \\frac{a(L - a)}{L} \\text{ at the section}',
    videoUrl: null,
    traps: [
      'Assuming the peak is always L/4 — that is only true at midspan',
      'Confusing the moment IL (triangular, peaks at the section) with the reaction IL (linear, peaks at the support)'
    ],
    diagram: {
      component: 'InfluenceLineSS',
      props: {
        type: 'moment',
        L: 20,
        a: 5,
        unit: 'ft'
      }
    },
    lessonId: 'influence-lines',
    chapterId: 'structural'
  },
  {
    id: 'str-il-ex3',
    type: 'computational',
    statement: 'A simply supported beam spans $L = 30 \\text{ ft}$. A uniform distributed load of $w = 2 \\text{ kip/ft}$ covers the entire span. Using the influence line for moment at midspan, what is the maximum bending moment at midspan?',
    choices: [
      {
        id: 'c1',
        text: '$450 \\text{ kip-ft}$'
      },
      {
        id: 'c2',
        text: '$112.5 \\text{ kip-ft}$'
      },
      {
        id: 'c3',
        text: '$225 \\text{ kip-ft}$'
      },
      {
        id: 'c4',
        text: '$150 \\text{ kip-ft}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'For a distributed load, the effect equals the load intensity times the area under the IL over the loaded region. The IL for midspan moment is a triangle with base $L = 30$ ft and peak $L/4 = 7.5$ ft. Area $= (1/2)(30)(7.5) = 112.5$ ft$^2$. Moment $= w \\times \\text{Area} = 2 \\times 112.5 = 225$ kip-ft. You can verify: $M = wL^2/8 = 2(30)^2/8 = 225$ kip-ft -- same answer. Choice B (112.5) forgets to multiply by $w$. Choice A (450) doubles the triangle area. Choice D (150) uses $L/4 = 7.5$ as the area instead of computing the triangle area.',
    hint: 'For a distributed load, multiply the load intensity by the area under the IL diagram. The IL is a triangle with base L and peak L/4.',
    steps: [
      {
        text: 'IL peak ordinate at midspan:',
        latex: '\\eta_{\\max} = \\frac{L}{4} = \\frac{30}{4} = 7.5 \\text{ ft}'
      },
      {
        text: 'Area under IL triangle:',
        latex: 'A_{IL} = \\frac{1}{2} \\times L \\times \\eta_{\\max} = \\frac{1}{2}(30)(7.5) = 112.5 \\text{ ft}^2'
      },
      {
        text: 'Maximum moment:',
        latex: 'M = w \\times A_{IL} = 2 \\times 112.5 = 225 \\text{ kip-ft}'
      }
    ],
    handbookPage: 'p. 268',
    handbookFormula: 'M = w \\times \\text{Area under IL}',
    videoUrl: null,
    traps: [
      'Using P times ordinate (for concentrated loads) instead of w times area (for distributed loads)',
      'Computing the area of the triangle incorrectly — remember it is (1/2)(base)(height)'
    ],
    diagram: {
      component: 'InfluenceLineSS',
      props: {
        type: 'moment',
        L: 30,
        a: 15,
        unit: 'ft'
      }
    },
    lessonId: 'influence-lines',
    chapterId: 'structural'
  },
  {
    id: 'str-il-ex4',
    type: 'conceptual',
    statement: 'A simply supported beam has a section at the quarter point ($a = L/4$). The influence line for shear at that section has a positive ordinate of $+0.75$ just to the right and a negative ordinate of $-0.25$ just to the left. To maximize the positive shear using a single moving concentrated load, where should the load be placed?',
    choices: [
      {
        id: 'c1',
        text: 'At the right support'
      },
      {
        id: 'c2',
        text: 'At midspan'
      },
      {
        id: 'c3',
        text: 'Just to the left of the section'
      },
      {
        id: 'c4',
        text: 'Just to the right of the section'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'The IL for shear at a section jumps by 1.0 at the section. On the right side of the section, the ordinate is positive and maximum just to the right of the cut ($+0.75$), decreasing linearly to 0 at the right support. On the left side, ordinates are negative. To maximize the positive shear, place the load where the positive ordinate is largest — that is just to the right of the section. Placing the load at midspan gives a smaller positive ordinate (the IL decreases linearly from the section to the right support). Placing it just to the left gives the maximum negative shear ($-0.25$), not positive. At the right support, the ordinate is 0.',
    hint: 'The IL for positive shear is largest immediately to the right of the section and decreases linearly toward the right support.',
    steps: [
      {
        text: 'IL for shear at section $a = L/4$:',
        latex: null
      },
      {
        text: 'Just right of section: $\\eta = 1 - a/L = 1 - 0.25 = +0.75$ (maximum positive)',
        latex: null
      },
      {
        text: 'Just left of section: $\\eta = -a/L = -0.25$ (negative)',
        latex: null
      },
      {
        text: 'At supports: $\\eta = 0$',
        latex: null
      },
      {
        text: 'Maximum positive shear occurs when the load is just to the right of the section.',
        latex: null
      }
    ],
    handbookPage: 'p. 268',
    handbookFormula: '\\eta^+ = 1 - \\frac{a}{L}, \\quad \\eta^- = -\\frac{a}{L}',
    videoUrl: null,
    traps: [
      'Placing the load at midspan — the IL ordinate at midspan is less than the ordinate just right of the section unless the section is at midspan',
      'Confusing positive and negative shear — the jump in the IL occurs at the section, and the sign changes there'
    ],
    diagram: {
      component: 'InfluenceLineSS',
      props: {
        type: 'shear',
        L: 20,
        a: 5,
        unit: 'ft'
      }
    },
    lessonId: 'influence-lines',
    chapterId: 'structural'
  },
  {
    id: 'str-rfs-ex1',
    type: 'computational',
    statement: 'A singly reinforced beam has $b = 14 \\text{ in.}$, $d = 22 \\text{ in.}$, $A_s = 4.00 \\text{ in}^2$, $f_y = 60 \\text{ ksi}$, and $f_c\' = 3 \\text{ ksi}$. What is the stress block depth $a$?',
    choices: [
      {
        id: 'c1',
        text: '$4.00 \\text{ in.}$'
      },
      {
        id: 'c2',
        text: '$5.71 \\text{ in.}$'
      },
      {
        id: 'c3',
        text: '$7.56 \\text{ in.}$'
      },
      {
        id: 'c4',
        text: '$6.72 \\text{ in.}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: '$a = A_s f_y / (0.85 f_c\' b) = 4.00 \\times 60 / (0.85 \\times 3 \\times 14) = 240/35.7 = 6.72$ in. Choice B (5.71) could come from $A_s f_y / (f_c\' b) = 240/42 = 5.71$ if you forget the 0.85 -- that is the trap. Choice C (7.56) uses $b = 12$ instead of 14. Choice A (4.00) is just $A_s$ -- a nonsensical substitution.',
    hint: '$a = A_s f_y / (0.85 f_c\' b)$. Make sure to include the 0.85 factor in the denominator.',
    steps: [
      {
        text: 'Stress block depth:',
        latex: 'a = \\frac{A_s f_y}{0.85 f_c\' b} = \\frac{4.00 \\times 60}{0.85 \\times 3 \\times 14}'
      },
      {
        text: 'Compute:',
        latex: 'a = \\frac{240}{35.7} = 6.72 \\text{ in.}'
      }
    ],
    handbookPage: 'p. 275',
    handbookFormula: 'a = \\frac{A_s f_y}{0.85 f_c\' b}',
    videoUrl: null,
    traps: [
      'Forgetting the 0.85 coefficient in the denominator — this would overestimate $a$ and underestimate the moment arm'
    ],
    diagram: {
      component: 'RCBeamSection',
      props: {
        b: 14,
        d: 22,
        numBars: 4,
        unit: 'in.'
      }
    },
    lessonId: 'rc-flexure-shear',
    chapterId: 'structural'
  },
  {
    id: 'str-rfs-ex2',
    type: 'conceptual',
    statement: 'In the ACI flexure formula $M_n = A_s f_y (d - a/2)$, the term $(d - a/2)$ represents the internal moment arm. Why is it measured from the centroid of tension steel to half the stress block depth rather than to the top of the beam?',
    choices: [
      {
        id: 'c1',
        text: 'The resultant concrete compression force acts at the centroid of the Whitney stress block, which is at $a/2$ from the top'
      },
      {
        id: 'c2',
        text: 'The concrete is assumed to carry no tension, so only the top half matters'
      },
      {
        id: 'c3',
        text: 'The stress block depth $a$ always equals $d$, making the arm $d/2$'
      },
      {
        id: 'c4',
        text: 'ACI uses $d - a/2$ as a safety reduction, not an actual moment arm'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The Whitney stress block replaces the actual nonlinear compression zone with a uniform rectangular block of depth $a$. The resultant compressive force $C = 0.85 f_c\' b a$ acts at the centroid of this rectangle, which is $a/2$ from the compression face. The tension force $T = A_s f_y$ acts at the centroid of the steel, located at depth $d$. The moment is force times lever arm: $M_n = T \\times (d - a/2)$. Choice B is partially true (concrete ignores tension) but does not explain the lever arm formula. Choice C is wrong — $a$ is much smaller than $d$ in typical designs. Choice D is wrong — this is a real mechanics derivation, not an arbitrary reduction.',
    hint: 'Think about where the resultant compression force acts in a uniform rectangular stress block.',
    steps: [
      {
        text: 'Whitney stress block: uniform stress $0.85 f_c\'$ over depth $a$.',
        latex: null
      },
      {
        text: 'Compression resultant acts at centroid:',
        latex: '\\text{depth} = \\frac{a}{2} \\text{ from top}'
      },
      {
        text: 'Moment arm = distance between C and T:',
        latex: 'jd = d - \\frac{a}{2}'
      }
    ],
    handbookPage: 'p. 275',
    handbookFormula: 'M_n = A_s f_y \\left(d - \\frac{a}{2}\\right)',
    videoUrl: null,
    traps: [
      'Using $d$ instead of $(d - a/2)$ as the moment arm — this overestimates capacity by ignoring the offset of the compression resultant'
    ],
    diagram: {
      component: 'RCBeamSection',
      props: {
        b: 12,
        d: 18,
        numBars: 3,
        unit: 'in.'
      }
    },
    lessonId: 'rc-flexure-shear',
    chapterId: 'structural'
  },
  {
    id: 'str-rfs-ex3',
    type: 'computational',
    statement: 'A concrete beam has $b_w = 16 \\text{ in.}$, $d = 26 \\text{ in.}$, and $f_c\' = 5{,}000 \\text{ psi}$ (normal weight). What is the design concrete shear capacity $\\phi V_c$?',
    choices: [
      {
        id: 'c1',
        text: '$58.9 \\text{ kips}$'
      },
      {
        id: 'c2',
        text: '$44.2 \\text{ kips}$'
      },
      {
        id: 'c3',
        text: '$5.9 \\text{ kips}$'
      },
      {
        id: 'c4',
        text: '$29.5 \\text{ kips}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$V_c = 2\\lambda\\sqrt{f_c\'} \\cdot b_w d = 2(1.0)\\sqrt{5000} \\times 16 \\times 26 = 2(70.71)(416) = 58{,}830$ lb $= 58.8$ kips. $\\phi V_c = 0.75 \\times 58.8 = 44.1 \\approx 44.2$ kips. Choice A (58.9) is $V_c$ without the $\\phi$ factor. Choice C (5.9) uses $\\sqrt{f_c\'}$ in ksi: $\\sqrt{5} = 2.236$, then $2(2.236)(416) = 1{,}860$ lb $= 1.86$ kips — way too low. Actually, 5.9 might come from $2\\sqrt{5}(16)(26)/1000 = 5.87$, confirming the ksi vs. psi trap. Choice D (29.5) halves $V_c$ somehow, perhaps using $\\lambda = 0.75$ for lightweight concrete when it should be 1.0 for normal weight.',
    hint: 'Use $V_c = 2\\sqrt{f_c\'} \\cdot b_w d$ with $f_c\'$ in psi. Then multiply by $\\phi = 0.75$.',
    steps: [
      {
        text: 'Concrete shear:',
        latex: 'V_c = 2(1.0)\\sqrt{5{,}000} \\times 16 \\times 26 = 2(70.71)(416)'
      },
      {
        text: 'Result:',
        latex: 'V_c = 58{,}830 \\text{ lb} = 58.8 \\text{ kips}'
      },
      {
        text: 'Design capacity:',
        latex: '\\phi V_c = 0.75 \\times 58.8 = 44.2 \\text{ kips}'
      }
    ],
    handbookPage: 'p. 276',
    handbookFormula: 'V_c = 2\\lambda \\sqrt{f_c\'} \\, b_w d',
    videoUrl: null,
    traps: [
      'Using $f_c\'$ in ksi instead of psi — this produces an answer 1,000 times too small',
      'Forgetting $\\phi = 0.75$ for shear — always apply the resistance factor'
    ],
    diagram: null,
    lessonId: 'rc-flexure-shear',
    chapterId: 'structural'
  },
  {
    id: 'str-rfs-ex4',
    type: 'conceptual',
    statement: 'A concrete beam has $V_u = 15 \\text{ kips}$ at the critical section and $\\phi V_c = 30 \\text{ kips}$. What is the shear reinforcement requirement?',
    choices: [
      {
        id: 'c1',
        text: 'Design stirrups for computed $V_s$ — $V_u > \\phi V_c$'
      },
      {
        id: 'c2',
        text: 'No stirrups needed — $V_u \\leq \\phi V_c/2$'
      },
      {
        id: 'c3',
        text: 'Provide minimum stirrups — $\\phi V_c/2 < V_u \\leq \\phi V_c$'
      },
      {
        id: 'c4',
        text: 'Enlarge the section — concrete cannot carry any shear at all'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: '$\\phi V_c/2 = 30/2 = 15$ kips. Since $V_u = 15 = \\phi V_c/2$, the code says provide minimum stirrups. The threshold is: $V_u \\leq \\phi V_c/2$ means no stirrups; $\\phi V_c/2 < V_u \\leq \\phi V_c$ means minimum stirrups; $V_u > \\phi V_c$ means design stirrups for $V_s$. With $V_u$ right at the boundary of $\\phi V_c/2$, minimum stirrups are required. Choice B is close but the boundary condition includes equality at $\\phi V_c/2$ on the "minimum stirrups" side per ACI practice. Choice A would require $V_u > 30$. Choice D is wrong — concrete absolutely carries shear through $V_c$.',
    hint: 'Compare $V_u$ to both $\\phi V_c/2$ and $\\phi V_c$ to determine which shear reinforcement zone applies.',
    steps: [
      {
        text: 'Compute thresholds:',
        latex: '\\phi V_c/2 = 30/2 = 15 \\text{ kips}'
      },
      {
        text: '$V_u = 15$ kips $= \\phi V_c/2 = 15$ kips. At this boundary, provide minimum stirrups.',
        latex: null
      },
      {
        text: 'If $V_u > \\phi V_c = 30$, then stirrups with computed $V_s$ would be required.',
        latex: null
      }
    ],
    handbookPage: 'p. 276',
    handbookFormula: 'V_u \\leq \\phi V_c/2 \\text{ (no stirrups)}, \\quad V_u > \\phi V_c \\text{ (computed } V_s\\text{)}',
    videoUrl: null,
    traps: [
      'Confusing the three shear zones — there are three distinct requirements depending on the $V_u$/$\\phi V_c$ ratio',
      'Comparing $V_u$ to $V_c$ instead of $\\phi V_c$ — always use the factored capacity for comparison'
    ],
    diagram: null,
    lessonId: 'rc-flexure-shear',
    chapterId: 'structural'
  },
  {
    id: 'str-rcc-ex1',
    type: 'computational',
    statement: 'A short tied column is $14 \\text{ in.} \\times 14 \\text{ in.}$ with 4 #8 bars ($A_{st} = 3.16 \\text{ in}^2$), $f_c\' = 4 \\text{ ksi}$, and $f_y = 60 \\text{ ksi}$. What is the maximum design axial load $\\phi P_n$?',
    choices: [
      {
        id: 'c1',
        text: '$845 \\text{ kips}$'
      },
      {
        id: 'c2',
        text: '$440 \\text{ kips}$'
      },
      {
        id: 'c3',
        text: '$549 \\text{ kips}$'
      },
      {
        id: 'c4',
        text: '$676 \\text{ kips}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: '$A_g = 14 \\times 14 = 196$ in$^2$. $\\phi P_n = 0.80(0.65)[0.85(4)(196 - 3.16) + 3.16(60)] = 0.52[3.4(192.84) + 189.6] = 0.52[655.7 + 189.6] = 0.52(845.3) = 440$ kips. Choice A (845) is the value inside the brackets without applying the 0.80 or $\\phi$ factors. Choice C (549) applies only $\\phi = 0.65$: $0.65 \\times 845.3 = 549$. Choice D (676) applies only $0.80$: $0.80 \\times 845.3 = 676$. You need BOTH factors for tied columns.',
    hint: 'Use $\\phi P_n = 0.80\\phi[0.85 f_c\'(A_g - A_{st}) + A_{st} f_y]$ with $\\phi = 0.65$ for tied columns.',
    steps: [
      {
        text: 'Gross area:',
        latex: 'A_g = 14 \\times 14 = 196 \\text{ in}^2'
      },
      {
        text: 'Inside brackets:',
        latex: '0.85(4)(196 - 3.16) + 3.16(60) = 655.7 + 189.6 = 845.3 \\text{ kips}'
      },
      {
        text: 'Apply factors:',
        latex: '\\phi P_n = 0.80(0.65)(845.3) = 0.52 \\times 845.3 = 440 \\text{ kips}'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\phi P_n = 0.80\\phi \\left[0.85 f_c\'(A_g - A_{st}) + A_{st} f_y\\right]',
    videoUrl: null,
    traps: [
      'Forgetting the 0.80 accidental eccentricity factor — it only applies to columns, not beams'
    ],
    diagram: {
      component: 'RCColumnSection',
      props: {
        w: 14,
        h: 14,
        numBars: 4,
        shape: 'square',
        unit: 'in.'
      }
    },
    lessonId: 'rc-columns',
    chapterId: 'structural'
  },
  {
    id: 'str-rcc-ex2',
    type: 'conceptual',
    statement: 'The ACI column capacity formula includes a 0.80 factor for tied columns (0.85 for spiral columns). What does this factor account for?',
    choices: [
      {
        id: 'c1',
        text: 'A material safety factor equivalent to the resistance factor $\\phi$'
      },
      {
        id: 'c2',
        text: 'The difference in concrete strength between cylinders and the actual column'
      },
      {
        id: 'c3',
        text: 'The weight of the column itself, which reduces its load-carrying capacity'
      },
      {
        id: 'c4',
        text: 'Accidental eccentricity — columns never truly carry pure concentric axial load'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'In practice, no column carries a perfectly centered axial load. Construction tolerances, member crookedness, and load eccentricities introduce bending even when the design intent is pure compression. The 0.80 factor (0.85 for spiral columns) reduces the theoretical capacity to account for this inevitable moment. Spiral columns get a slightly more favorable factor because spirals provide better confinement and ductility, allowing the column to maintain capacity under eccentric loading. Choice B describes the 0.85 $f_c\'$ coefficient in the stress block, not the 0.80 column factor. Choice C is wrong — self-weight is handled through loads, not capacity reduction. Choice A confuses it with $\\phi$, which is a separate reliability factor.',
    hint: 'Think about whether a column in a real building ever carries load at the exact center of its cross-section.',
    steps: [
      {
        text: 'Real columns always have some eccentricity from construction tolerances and load path imperfections.',
        latex: null
      },
      {
        text: 'Tied columns: 0.80 factor. Spiral columns: 0.85 (better confinement).',
        latex: null
      },
      {
        text: 'This factor is separate from $\\phi$ — both are applied: $\\phi P_n = 0.80\\phi[\\ldots]$',
        latex: null
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\phi P_n = 0.80\\phi \\left[0.85 f_c\'(A_g - A_{st}) + A_{st} f_y\\right]',
    videoUrl: null,
    traps: [
      'Confusing the 0.80 factor with the 0.85 in $0.85 f_c\'$ — the 0.85 on $f_c\'$ accounts for concrete strength differences between test cylinders and the actual structure'
    ],
    diagram: null,
    lessonId: 'rc-columns',
    chapterId: 'structural'
  },
  {
    id: 'str-rcc-ex3',
    type: 'computational',
    statement: 'A short spiral column is $20 \\text{ in.}$ in diameter with 6 #9 bars ($A_{st} = 6.00 \\text{ in}^2$), $f_c\' = 5 \\text{ ksi}$, and $f_y = 60 \\text{ ksi}$. What is $\\phi P_n$? (Use $\\phi = 0.75$ and the 0.85 factor for spiral columns.)',
    choices: [
      {
        id: 'c1',
        text: '$1{,}670 \\text{ kips}$'
      },
      {
        id: 'c2',
        text: '$1{,}065 \\text{ kips}$'
      },
      {
        id: 'c3',
        text: '$869 \\text{ kips}$'
      },
      {
        id: 'c4',
        text: '$1{,}253 \\text{ kips}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$A_g = \\pi(10)^2 = 314.2$ in$^2$. Inner bracket: $0.85(5)(314.2 - 6.0) + 6.0(60) = 4.25(308.2) + 360 = 1{,}310 + 360 = 1{,}670$ kips. $\\phi P_n = 0.85(0.75)(1{,}670) = 0.6375 \\times 1{,}670 = 1{,}065$ kips. Choice A (1,670) is the value inside the brackets without the 0.85 and $\\phi$ factors. Choice C (869) uses $0.52$ (tied column factors: $0.80 \\times 0.65$) instead of $0.6375$ (spiral factors: $0.85 \\times 0.75$). Choice D (1,253) applies only $\\phi = 0.75$ without the 0.85 accidental eccentricity factor.',
    hint: 'For circular columns, $A_g = \\pi r^2$. Use the spiral column formula: $0.85\\phi[0.85 f_c\'(A_g - A_{st}) + A_{st} f_y]$ with $\\phi = 0.75$.',
    steps: [
      {
        text: 'Gross area:',
        latex: 'A_g = \\pi \\left(\\frac{20}{2}\\right)^2 = 314.2 \\text{ in}^2'
      },
      {
        text: 'Inside brackets:',
        latex: '0.85(5)(314.2 - 6.0) + 6.0(60) = 1{,}310 + 360 = 1{,}670 \\text{ kips}'
      },
      {
        text: 'Apply factors:',
        latex: '\\phi P_n = 0.85(0.75)(1{,}670) = 0.6375 \\times 1{,}670 = 1{,}065 \\text{ kips}'
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\phi P_n = 0.85\\phi \\left[0.85 f_c\'(A_g - A_{st}) + A_{st} f_y\\right]',
    videoUrl: null,
    traps: [
      'Using 0.80 (tied column factor) instead of 0.85 (spiral column factor)',
      'Using $\\phi = 0.65$ (tied) instead of $\\phi = 0.75$ (spiral)'
    ],
    diagram: {
      component: 'RCColumnSection',
      props: {
        diameter: 20,
        numBars: 6,
        shape: 'circular',
        unit: 'in.'
      }
    },
    lessonId: 'rc-columns',
    chapterId: 'structural'
  },
  {
    id: 'str-rcc-ex4',
    type: 'conceptual',
    statement: 'A concrete column has $\\varepsilon_t = 0.0015$ (net tensile strain in the extreme tension steel). What is the section classification and the correct $\\phi$ factor for a tied column?',
    choices: [
      {
        id: 'c1',
        text: 'Transition zone ($0.002 < \\varepsilon_t < 0.005$), interpolate $\\phi$'
      },
      {
        id: 'c2',
        text: 'Tension-controlled ($\\varepsilon_t \\geq 0.005$), $\\phi = 0.90$'
      },
      {
        id: 'c3',
        text: 'Compression-controlled ($\\varepsilon_t \\leq 0.002$), $\\phi = 0.65$'
      },
      {
        id: 'c4',
        text: 'Cannot be determined without knowing $f_c\'$ and $f_y$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'ACI classifies sections by the net tensile strain $\\varepsilon_t$ in the extreme tension reinforcement at nominal strength. If $\\varepsilon_t \\leq 0.002$, the section is compression-controlled -- the concrete crushes before the steel yields significantly. For tied columns, $\\phi = 0.65$. If $\\varepsilon_t \\geq 0.005$, the section is tension-controlled with $\\phi = 0.90$. Between 0.002 and 0.005 is the transition zone, where $\\phi$ is interpolated. Here, $\\varepsilon_t = 0.0015 < 0.002$, so the section is compression-controlled. Choice B requires $\\varepsilon_t \\geq 0.005$. Choice A requires $\\varepsilon_t$ between 0.002 and 0.005. Choice D is wrong -- the classification depends only on strain, not material properties.',
    hint: 'Compare $\\varepsilon_t$ to the ACI thresholds: 0.002 (compression-controlled boundary) and 0.005 (tension-controlled boundary).',
    steps: [
      {
        text: '$\\varepsilon_t = 0.0015 \\leq 0.002$ — compression-controlled.',
        latex: null
      },
      {
        text: 'For tied columns:',
        latex: '\\phi = 0.65'
      },
      {
        text: 'For spiral columns: $\\phi = 0.75$ (but the problem specifies tied).',
        latex: null
      }
    ],
    handbookPage: 'p. 278',
    handbookFormula: '\\varepsilon_t \\leq 0.002 \\implies \\phi = 0.65 \\text{ (tied)}',
    videoUrl: null,
    traps: [
      'Confusing the strain thresholds — 0.002 is the compression-controlled limit, 0.005 is the tension-controlled limit',
      'Using $\\phi = 0.90$ for all column sections — this only applies to tension-controlled sections like beams'
    ],
    diagram: null,
    lessonId: 'rc-columns',
    chapterId: 'structural'
  },
  {
    id: 'str-sb-ex1',
    type: 'computational',
    statement: 'A fully braced W-shape has $Z_x = 96 \\text{ in}^3$ and $F_y = 50 \\text{ ksi}$. What is the LRFD design flexural strength $\\phi_b M_n$?',
    choices: [
      {
        id: 'c1',
        text: '$240 \\text{ kip-ft}$'
      },
      {
        id: 'c2',
        text: '$400 \\text{ kip-ft}$'
      },
      {
        id: 'c3',
        text: '$360 \\text{ kip-ft}$'
      },
      {
        id: 'c4',
        text: '$288 \\text{ kip-ft}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'With full bracing, $M_n = M_p = F_y Z_x = 50 \\times 96 = 4{,}800$ kip-in $= 400$ kip-ft. Then $\\phi_b M_n = 0.90 \\times 400 = 360$ kip-ft. Choice B (400) is the nominal capacity without $\\phi_b$. Choice A (240) is the ASD allowable: $M_p / \\Omega_b = 400/1.67 = 240$. Choice D (288) comes from using $S_x$ instead of $Z_x$ (a typical $S_x/Z_x$ ratio of about 0.89 would give roughly this).',
    hint: '$M_p = F_y Z_x$, then multiply by $\\phi_b = 0.90$. Convert kip-in to kip-ft by dividing by 12.',
    steps: [
      {
        text: 'Plastic moment:',
        latex: 'M_p = F_y Z_x = 50 \\times 96 = 4{,}800 \\text{ kip-in} = 400 \\text{ kip-ft}'
      },
      {
        text: 'LRFD design strength:',
        latex: '\\phi_b M_n = 0.90 \\times 400 = 360 \\text{ kip-ft}'
      }
    ],
    handbookPage: 'p. 281',
    handbookFormula: 'M_n = M_p = F_y Z_x',
    videoUrl: null,
    traps: [
      'Reporting nominal $M_p$ instead of design $\\phi_b M_p$ — always include the resistance factor for LRFD'
    ],
    diagram: null,
    lessonId: 'steel-beams',
    chapterId: 'structural'
  },
  {
    id: 'str-sb-ex2',
    type: 'conceptual',
    statement: 'A W-shape beam has full lateral bracing and $F_y = 50 \\text{ ksi}$. The elastic section modulus is $S_x = 100 \\text{ in}^3$ and the plastic section modulus is $Z_x = 112 \\text{ in}^3$. Which modulus should be used for the LRFD plastic moment capacity?',
    choices: [
      {
        id: 'c1',
        text: '$Z_x = 112 \\text{ in}^3$ — the plastic modulus is used for LRFD strength design'
      },
      {
        id: 'c2',
        text: '$S_x = 100 \\text{ in}^3$ — the elastic modulus is always more conservative'
      },
      {
        id: 'c3',
        text: 'Either one — they give the same design strength after applying $\\phi$'
      },
      {
        id: 'c4',
        text: '$S_x$ for compact sections, $Z_x$ for non-compact sections'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'For LRFD, the plastic moment capacity is $M_p = F_y Z_x$, using the plastic section modulus. The plastic modulus accounts for the full cross-section reaching yield stress, which is the actual failure mode for compact sections with full bracing. $S_x$ (elastic modulus) is used in the lateral-torsional buckling formula as the lower-bound term ($0.7 F_y S_x$) and in ASD. Using $S_x$ for the plastic moment underestimates capacity by about 10–15% for typical W-shapes. Choice B is more conservative but incorrect for LRFD — LRFD is calibrated to use $Z_x$. Choice D has it backwards.',
    hint: 'LRFD uses plastic moment capacity, which requires the section modulus that corresponds to full yielding of the cross-section.',
    steps: [
      {
        text: '$Z_x$ = plastic section modulus: assumes entire cross-section yields.',
        latex: null
      },
      {
        text: '$S_x$ = elastic section modulus: assumes linear stress distribution up to first yield.',
        latex: null
      },
      {
        text: 'LRFD plastic moment:',
        latex: 'M_p = F_y Z_x = 50 \\times 112 = 5{,}600 \\text{ kip-in} = 467 \\text{ kip-ft}'
      }
    ],
    handbookPage: 'p. 281',
    handbookFormula: 'M_n = F_y Z_x',
    videoUrl: null,
    traps: [
      'Using $S_x$ instead of $Z_x$ for the plastic moment — $S_x$ is for elastic/ASD calculations and the LTB formula',
      'Assuming more conservative always means correct — LRFD is calibrated to use $Z_x$'
    ],
    diagram: null,
    lessonId: 'steel-beams',
    chapterId: 'structural'
  },
  {
    id: 'str-sb-ex3',
    type: 'computational',
    statement: 'A W-shape has $d = 14 \\text{ in.}$, $t_w = 0.415 \\text{ in.}$, and $F_y = 50 \\text{ ksi}$. With $C_{v1} = 1.0$ and $\\phi_v = 1.00$, what is the LRFD design shear strength $\\phi_v V_n$?',
    choices: [
      {
        id: 'c1',
        text: '$291 \\text{ kips}$'
      },
      {
        id: 'c2',
        text: '$174 \\text{ kips}$'
      },
      {
        id: 'c3',
        text: '$350 \\text{ kips}$'
      },
      {
        id: 'c4',
        text: '$145 \\text{ kips}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$A_w = d \\times t_w = 14 \\times 0.415 = 5.81$ in$^2$. $V_n = 0.6 F_y A_w C_{v1} = 0.6(50)(5.81)(1.0) = 174.3 \\approx 174$ kips. With $\\phi_v = 1.00$: $\\phi_v V_n = 174$ kips. Choice A (291) uses $F_y A_w = 50 \\times 5.81 = 291$ without the $0.6$ factor. Choice C (350) uses the full section area instead of web area. Choice D (145) incorrectly uses $\\phi_v = 0.90$ or applies $0.5 F_y$ instead of $0.6 F_y$.',
    hint: 'Shear capacity uses the web area $A_w = d \\times t_w$ and $V_n = 0.6 F_y A_w C_{v1}$.',
    steps: [
      {
        text: 'Web area:',
        latex: 'A_w = d \\times t_w = 14 \\times 0.415 = 5.81 \\text{ in}^2'
      },
      {
        text: 'Nominal shear:',
        latex: 'V_n = 0.6 F_y A_w C_{v1} = 0.6(50)(5.81)(1.0) = 174 \\text{ kips}'
      },
      {
        text: 'Design shear ($\\phi_v = 1.00$):',
        latex: '\\phi_v V_n = 1.00 \\times 174 = 174 \\text{ kips}'
      }
    ],
    handbookPage: 'p. 281',
    handbookFormula: 'V_n = 0.6 F_y A_w C_{v1}',
    videoUrl: null,
    traps: [
      'Using the full cross-sectional area instead of web area $A_w = d \\times t_w$',
      'Forgetting the 0.6 coefficient — shear yield stress is $0.6 F_y$, not $F_y$'
    ],
    diagram: null,
    lessonId: 'steel-beams',
    chapterId: 'structural'
  },
  {
    id: 'str-sb-ex4',
    type: 'conceptual',
    statement: 'A W-shape beam has $M_p = 600 \\text{ kip-ft}$, $L_p = 10 \\text{ ft}$, and $L_r = 30 \\text{ ft}$. The unbraced length is $L_b = 10 \\text{ ft}$. A second identical beam has $L_b = 20 \\text{ ft}$ with $C_b = 1.0$. How do their nominal flexural strengths compare?',
    choices: [
      {
        id: 'c1',
        text: 'The second beam has elastic LTB since $L_b > L_r$'
      },
      {
        id: 'c2',
        text: 'Both beams reach $M_p = 600$ because they use the same section'
      },
      {
        id: 'c3',
        text: 'Both are reduced by LTB because neither is continuously braced'
      },
      {
        id: 'c4',
        text: 'The first beam reaches $M_p = 600$; the second is reduced below $M_p$ by inelastic LTB'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'The first beam has $L_b = 10 = L_p$, so it is fully braced and reaches $M_n = M_p = 600$ kip-ft. The second beam has $L_p = 10 < L_b = 20 \\leq L_r = 30$, so it falls in the inelastic LTB zone. Its capacity is reduced by the linear interpolation formula: $M_n = M_p - (M_p - 0.7 F_y S_x)(L_b - L_p)/(L_r - L_p) < M_p$. Choice B ignores the effect of unbraced length — same section does not mean same capacity if bracing conditions differ. Choice C is wrong because the first beam meets $L_b \\leq L_p$. Choice A is wrong because $L_b = 20 < L_r = 30$, so it is inelastic LTB, not elastic.',
    hint: 'Compare $L_b$ to $L_p$ and $L_r$ for each beam. If $L_b \\leq L_p$, full $M_p$. If $L_p < L_b \\leq L_r$, inelastic LTB reduces capacity.',
    steps: [
      {
        text: 'Beam 1: $L_b = 10 \\leq L_p = 10$ — no LTB, $M_n = M_p = 600$ kip-ft.',
        latex: null
      },
      {
        text: 'Beam 2: $L_p = 10 < L_b = 20 \\leq L_r = 30$ — inelastic LTB zone.',
        latex: null
      },
      {
        text: 'Beam 2 capacity is reduced:',
        latex: 'M_n = M_p - (M_p - 0.7F_yS_x)\\frac{20 - 10}{30 - 10} < M_p'
      }
    ],
    handbookPage: 'p. 281',
    handbookFormula: 'M_n = C_b\\left[M_p - (M_p - 0.7F_yS_x)\\frac{L_b - L_p}{L_r - L_p}\\right] \\leq M_p',
    videoUrl: null,
    traps: [
      'Assuming the same section always gives the same capacity — bracing conditions can reduce flexural strength significantly',
      'Confusing $L_b = L_p$ (full capacity) with $L_b > L_p$ (LTB reduction)'
    ],
    diagram: {
      component: 'LTBCurve',
      props: {
        Mp: 600,
        Mr: 360,
        Lp: 10,
        Lr: 30,
        Lb: 10,
        Lb2: 20,
        unit: 'ft'
      }
    },
    lessonId: 'steel-beams',
    chapterId: 'structural'
  },
  {
    id: 'str-sc-ex1',
    type: 'computational',
    statement: 'A steel column has pin-pin supports ($K = 1.0$), an unbraced length of $10 \\text{ ft}$, and $r_y = 1.50 \\text{ in.}$ What is the slenderness ratio $KL/r_y$?',
    choices: [
      {
        id: 'c1',
        text: '$40$'
      },
      {
        id: 'c2',
        text: '$120$'
      },
      {
        id: 'c3',
        text: '$6.7$'
      },
      {
        id: 'c4',
        text: '$80$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Convert $KL$ to inches: $1.0 \\times 10 \\times 12 = 120$ in. Then $KL/r_y = 120/1.50 = 80$. Choice B (120) is $KL$ in inches without dividing by $r$. Choice C (6.7) reverses the fraction: $r/(KL) \\times 1000$ or uses feet without converting. Choice A (40) forgets to convert feet to inches: $10/1.50 \\approx 6.7$, or uses $r_x$ instead.',
    hint: 'Convert the unbraced length from feet to inches before dividing by $r_y$.',
    steps: [
      {
        text: 'Effective length:',
        latex: 'KL = 1.0 \\times 10 \\times 12 = 120 \\text{ in.}'
      },
      {
        text: 'Slenderness ratio:',
        latex: '\\frac{KL}{r_y} = \\frac{120}{1.50} = 80'
      }
    ],
    handbookPage: 'p. 281',
    handbookFormula: '\\frac{KL}{r}',
    videoUrl: null,
    traps: ['Forgetting to convert feet to inches — $r$ is always given in inches on the FE'],
    diagram: null,
    lessonId: 'steel-columns',
    chapterId: 'structural'
  },
  {
    id: 'str-sc-ex2',
    type: 'conceptual',
    statement: 'A cantilever column has a recommended effective length factor $K = 2.10$. A pin-pin column has $K = 1.0$. If both have the same physical length and cross-section, which has the lower design compressive strength?',
    choices: [
      {
        id: 'c1',
        text: 'Both have the same strength because they have the same cross-section'
      },
      {
        id: 'c2',
        text: 'The pin-pin column — its lower $K$ means less restraint and lower capacity'
      },
      {
        id: 'c3',
        text: 'The cantilever — its larger $K$ produces a higher $KL/r$, reducing $\\phi_c F_{cr}$'
      },
      {
        id: 'c4',
        text: 'The cantilever — but only because it has a different $\\phi_c$ factor'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The effective length factor $K$ converts the physical length into an equivalent pin-pin length for buckling. A cantilever ($K = 2.10$) has an effective length more than twice the physical length because one end is free to translate. This dramatically increases $KL/r$, which reduces the critical buckling stress $F_{cr}$. The pin-pin column ($K = 1.0$) buckles over exactly its physical length. Higher $KL/r$ always means lower strength. Choice B confuses $K$ with restraint — lower $K$ actually means MORE restraint (better support conditions). Choice A ignores the role of end conditions. Choice D is wrong because $\\phi_c = 0.90$ for both.',
    hint: 'Higher $K$ means a longer effective length for buckling. Longer effective length means higher $KL/r$ and lower critical stress.',
    steps: [
      {
        text: 'Cantilever:',
        latex: 'KL/r = 2.10 L/r'
      },
      {
        text: 'Pin-pin:',
        latex: 'KL/r = 1.0 L/r'
      },
      {
        text: 'Since $2.10 L/r > 1.0 L/r$, the cantilever has higher slenderness and lower $F_{cr}$.',
        latex: null
      }
    ],
    handbookPage: 'p. 287',
    handbookFormula: 'K = 2.10 \\text{ (fixed-free)}, \\quad K = 1.0 \\text{ (pin-pin)}',
    videoUrl: null,
    traps: [
      'Thinking lower $K$ means less stability — it is the opposite; lower $K$ means better end restraint and more stability'
    ],
    diagram: null,
    lessonId: 'steel-columns',
    chapterId: 'structural'
  },
  {
    id: 'str-sc-ex3',
    type: 'computational',
    statement: 'A W10x49 column ($A_g = 14.4 \\text{ in}^2$, $r_y = 2.54 \\text{ in.}$) has fixed-pin supports ($K = 0.80$) and an unbraced length of $16 \\text{ ft}$. Using $F_y = 50 \\text{ ksi}$ and AISC Table 4-14 ($\\phi_c F_{cr} = 38.3 \\text{ ksi}$ at $KL/r = 60$), what is the LRFD design compressive strength?',
    choices: [
      {
        id: 'c1',
        text: '$720 \\text{ kips}$'
      },
      {
        id: 'c2',
        text: '$552 \\text{ kips}$'
      },
      {
        id: 'c3',
        text: '$648 \\text{ kips}$'
      },
      {
        id: 'c4',
        text: '$383 \\text{ kips}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$KL = 0.80 \\times 16 \\times 12 = 153.6$ in. $KL/r_y = 153.6/2.54 = 60.5 \\approx 60$. From the table at $KL/r = 60$: $\\phi_c F_{cr} = 38.3$ ksi. $\\phi_c P_n = 38.3 \\times 14.4 = 551.5 \\approx 552$ kips. Choice A (720) is $F_y \\times A_g = 50 \\times 14.4 = 720$, ignoring buckling. Choice C (648) is $0.90 \\times 720 = 648$, applying only $\\phi$ without buckling reduction. Choice D (383) might use the wrong area or an incorrect table value.',
    hint: 'Compute $KL/r_y$, look up $\\phi_c F_{cr}$ from the table, then multiply by $A_g$.',
    steps: [
      {
        text: 'Effective length:',
        latex: 'KL = 0.80 \\times 16 \\times 12 = 153.6 \\text{ in.}'
      },
      {
        text: 'Slenderness:',
        latex: '\\frac{KL}{r_y} = \\frac{153.6}{2.54} = 60.5 \\approx 60'
      },
      {
        text: 'From AISC Table 4-14:',
        latex: '\\phi_c F_{cr} = 38.3 \\text{ ksi}'
      },
      {
        text: 'Design strength:',
        latex: '\\phi_c P_n = 38.3 \\times 14.4 = 552 \\text{ kips}'
      }
    ],
    handbookPage: 'p. 288',
    handbookFormula: '\\phi_c P_n = \\phi_c F_{cr} \\times A_g',
    videoUrl: null,
    traps: [
      'Using $F_y$ directly instead of the table value $\\phi_c F_{cr}$ — buckling reduces the effective stress',
      'Applying $\\phi_c = 0.90$ again on top of $\\phi_c F_{cr}$ — the table value already includes $\\phi_c$'
    ],
    diagram: null,
    lessonId: 'steel-columns',
    chapterId: 'structural'
  },
  {
    id: 'str-sc-ex4',
    type: 'conceptual',
    statement: 'A W-shape column has $r_x = 6.0 \\text{ in.}$ and $r_y = 2.0 \\text{ in.}$ The column is braced at every $12 \\text{ ft}$ in the strong axis and at every $6 \\text{ ft}$ in the weak axis (both pin-pin, $K = 1.0$). Which axis controls buckling?',
    choices: [
      {
        id: 'c1',
        text: 'Neither controls — check only the axis with the larger $r$ value'
      },
      {
        id: 'c2',
        text: 'Strong axis controls because it has the longer unbraced length'
      },
      {
        id: 'c3',
        text: 'Weak axis controls because $r_y < r_x$, regardless of bracing'
      },
      {
        id: 'c4',
        text: 'Strong axis ($KL/r_x = 24$) and weak axis ($KL/r_y = 36$) — weak axis controls with the larger ratio'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'Strong axis: $KL/r_x = (1.0 \\times 12 \\times 12)/6.0 = 144/6.0 = 24$. Weak axis: $KL/r_y = (1.0 \\times 6 \\times 12)/2.0 = 72/2.0 = 36$. The weak axis has the larger slenderness ratio ($36 > 24$), so it controls. Even though the weak axis has a shorter unbraced length (6 ft vs. 12 ft), $r_y$ is so much smaller than $r_x$ that it still produces the larger $KL/r$. Choice B only considers length, not the radius of gyration. Choice C states the conclusion correctly but for the wrong reason — you must compute both ratios, not assume. Choice A is backwards — check the axis with the LARGER $KL/r$, not the larger $r$.',
    hint: 'Compute $KL/r$ for both axes using their respective unbraced lengths. The larger ratio governs.',
    steps: [
      {
        text: 'Strong axis:',
        latex: '\\frac{KL}{r_x} = \\frac{1.0 \\times 12 \\times 12}{6.0} = 24'
      },
      {
        text: 'Weak axis:',
        latex: '\\frac{KL}{r_y} = \\frac{1.0 \\times 6 \\times 12}{2.0} = 36'
      },
      {
        text: 'Weak axis controls ($36 > 24$) despite having the shorter unbraced length.',
        latex: null
      }
    ],
    handbookPage: 'p. 281',
    handbookFormula: '\\text{Controlling: } \\max\\left(\\frac{KL}{r_x}, \\frac{KL}{r_y}\\right)',
    videoUrl: null,
    traps: [
      'Assuming the longer unbraced length always controls — the radius of gyration matters just as much',
      'Checking only one axis — you must compute $KL/r$ for both axes and use the larger value'
    ],
    diagram: null,
    lessonId: 'steel-columns',
    chapterId: 'structural'
  },
  {
    id: 'str-st-ex1',
    type: 'computational',
    statement: 'A flat bar ($3/8 \\text{ in.} \\times 8 \\text{ in.}$) has two $3/4 \\text{-in.}$ diameter bolts at the same cross-section. What is the net area $A_n$?',
    choices: [
      {
        id: 'c1',
        text: '$2.63 \\text{ in}^2$'
      },
      {
        id: 'c2',
        text: '$2.44 \\text{ in}^2$'
      },
      {
        id: 'c3',
        text: '$3.00 \\text{ in}^2$'
      },
      {
        id: 'c4',
        text: '$2.34 \\text{ in}^2$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Each bolt hole subtracts $d_b + 1/8\\text{"} = 3/4 + 1/8 = 7/8 = 0.875$ in. from the gross width. With two holes: net width $= 8 - 2(0.875) = 8 - 1.75 = 6.25$ in. Then $A_n = 6.25 \\times 3/8 = 6.25 \\times 0.375 = 2.34$ in$^2$. Choice B (2.44) subtracts only $d_b = 0.75$ per hole without the 1/8" addition: $(8 - 1.50)(0.375) = 2.44$. Choice C (3.00) is the gross area with no deductions. Choice A (2.63) subtracts only one hole instead of two.',
    hint: 'Subtract $(d_b + 1/8\\text{"})$ for each hole from the gross width, then multiply by thickness.',
    steps: [
      {
        text: 'Effective hole diameter:',
        latex: 'd_h = d_b + \\frac{1}{8}\\text{"} = \\frac{3}{4} + \\frac{1}{8} = \\frac{7}{8} = 0.875 \\text{ in.}'
      },
      {
        text: 'Net width:',
        latex: 'b_n = 8 - 2(0.875) = 6.25 \\text{ in.}'
      },
      {
        text: 'Net area:',
        latex: 'A_n = 6.25 \\times 0.375 = 2.34 \\text{ in}^2'
      }
    ],
    handbookPage: 'p. 282',
    handbookFormula: 'A_n = \\left[b_g - \\Sigma\\left(d_b + \\tfrac{1}{8}\\text{ in.}\\right)\\right] t',
    videoUrl: null,
    traps: [
      'Forgetting the 1/8" addition for clearance and damage — the hole is larger than the bolt'
    ],
    diagram: {
      component: 'TensionPlateNet',
      props: {
        width: 8,
        thickness: 0.375,
        numBolts: 2,
        boltDia: 0.75,
        unit: 'in.'
      }
    },
    lessonId: 'steel-tension',
    chapterId: 'structural'
  },
  {
    id: 'str-st-ex2',
    type: 'conceptual',
    statement: 'Why does AISC use a lower resistance factor ($\\phi = 0.75$) for tensile rupture than for tensile yielding ($\\phi = 0.90$)?',
    choices: [
      {
        id: 'c1',
        text: 'Rupture is a sudden, brittle failure with no warning, so a larger safety margin is needed'
      },
      {
        id: 'c2',
        text: 'Rupture uses a higher material strength ($F_u$), so the factor must compensate'
      },
      {
        id: 'c3',
        text: 'Rupture only occurs in low-grade steels that need extra conservatism'
      },
      {
        id: 'c4',
        text: 'The lower factor accounts for bolt hole drilling inaccuracy'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Yielding spreads across the gross section gradually — the member elongates and gives visible warning before failure. Rupture, on the other hand, happens suddenly at the weakest net section with little plastic deformation. Because rupture is a more dangerous failure mode (no warning, no redistribution), AISC applies a lower resistance factor to build in a larger safety margin. Choice B confuses material strength with reliability philosophy. Choice C is wrong — rupture can occur in any grade of steel. Choice D is partially related (hole deductions matter) but the fundamental reason is the brittle failure mode.',
    hint: 'Think about which failure mode gives more warning and allows load redistribution.',
    steps: [
      {
        text: 'Yielding: gradual, ductile — the member stretches visibly before failure.',
        latex: null
      },
      {
        text: 'Rupture: sudden, brittle — fracture at the net section with little warning.',
        latex: null
      },
      {
        text: 'More dangerous failure modes get lower $\\phi$ factors to increase the safety margin.',
        latex: null
      }
    ],
    handbookPage: 'p. 283',
    handbookFormula: '\\phi_y = 0.90 \\text{ (yielding)}, \\quad \\phi_t = 0.75 \\text{ (rupture)}',
    videoUrl: null,
    traps: [
      'Thinking the lower factor is just to offset the higher $F_u$ value — the reason is fundamentally about failure mode ductility'
    ],
    diagram: null,
    lessonId: 'steel-tension',
    chapterId: 'structural'
  },
  {
    id: 'str-st-ex3',
    type: 'computational',
    statement: 'A flat bar ($5/8 \\text{ in.} \\times 10 \\text{ in.}$) has three $7/8 \\text{-in.}$ bolts at one cross-section. $F_y = 36 \\text{ ksi}$, $F_u = 58 \\text{ ksi}$, $U = 1.0$. What is the LRFD design tensile capacity?',
    choices: [
      {
        id: 'c1',
        text: '$203 \\text{ kips}$'
      },
      {
        id: 'c2',
        text: '$190 \\text{ kips}$'
      },
      {
        id: 'c3',
        text: '$225 \\text{ kips}$'
      },
      {
        id: 'c4',
        text: '$254 \\text{ kips}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$A_g = 10 \\times 0.625 = 6.25$ in$^2$. Each hole: $7/8 + 1/8 = 1.0$ in. $A_n = [10 - 3(1.0)] \\times 0.625 = 7.0 \\times 0.625 = 4.375$ in$^2$. With $U = 1.0$: $A_e = 4.375$ in$^2$. Yielding: $\\phi P_n = 0.90 \\times 36 \\times 6.25 = 202.5$ kips. Rupture: $\\phi P_n = 0.75 \\times 58 \\times 4.375 = 190$ kips. Controlling = min(202.5, 190) = 190 kips (rupture governs). Choice A (203) is the yielding value, but that is the larger capacity — the smaller one controls. Choice C (225) uses $F_y \\times A_g$ without the $\\phi$ factor. Choice D (254) is $F_u \\times A_n$ without $\\phi$.',
    hint: 'Check both yielding ($\\phi_y F_y A_g$) and rupture ($\\phi_t F_u A_e$). The smaller value controls.',
    steps: [
      {
        text: 'Gross area:',
        latex: 'A_g = 10 \\times 0.625 = 6.25 \\text{ in}^2'
      },
      {
        text: 'Net area (3 holes at 1.0 in. each):',
        latex: 'A_n = (10 - 3.0)(0.625) = 4.375 \\text{ in}^2'
      },
      {
        text: 'Yielding:',
        latex: '\\phi_y P_n = 0.90 \\times 36 \\times 6.25 = 202.5 \\text{ kips}'
      },
      {
        text: 'Rupture:',
        latex: '\\phi_t P_n = 0.75 \\times 58 \\times 4.375 = 190 \\text{ kips}'
      },
      {
        text: 'Controlling: $\\min(202.5, 190) = 190$ kips (rupture governs).',
        latex: null
      }
    ],
    handbookPage: 'p. 283',
    handbookFormula: '\\text{Yielding: } \\phi_y P_n = 0.90 F_y A_g; \\quad \\text{Rupture: } \\phi_t P_n = 0.75 F_u A_e',
    videoUrl: null,
    traps: [
      'Picking the larger capacity instead of the smaller — the weaker limit state controls',
      'Forgetting to add 1/8" to each bolt diameter for hole size'
    ],
    diagram: {
      component: 'TensionPlateNet',
      props: {
        width: 10,
        thickness: 0.625,
        numBolts: 3,
        boltDia: 0.875,
        unit: 'in.'
      }
    },
    lessonId: 'steel-tension',
    chapterId: 'structural'
  },
  {
    id: 'str-st-ex4',
    type: 'conceptual',
    statement: 'An angle connected by bolts through only one leg is used as a tension brace. Compared to a flat bar connected through its full width (both with the same $A_n$), how does the angle\'s effective net area $A_e$ differ?',
    choices: [
      {
        id: 'c1',
        text: '$A_e$ is the same — $U = 1.0$ for all tension members'
      },
      {
        id: 'c2',
        text: '$A_e$ is larger because the unconnected leg adds extra capacity'
      },
      {
        id: 'c3',
        text: '$A_e$ is smaller because the shear lag factor $U < 1.0$ reduces the effective area for the unconnected leg'
      },
      {
        id: 'c4',
        text: '$A_e$ is smaller because angles use a different $\\phi$ factor'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'When a tension member is connected through only part of its cross-section (like an angle bolted through one leg), the stress does not distribute uniformly across the full section. The unconnected leg experiences "shear lag" — it cannot fully develop its tensile capacity before the connection ends. AISC accounts for this with the shear lag factor $U = 1 - \\bar{x}/L$, where $\\bar{x}$ is the distance from the connection plane to the centroid of the member and $L$ is the connection length. For a flat bar bolted through its full width, all elements are connected so $U = 1.0$. For an angle connected through one leg, $U < 1.0$, reducing $A_e = U \\cdot A_n$. Choice B is backwards. Choice A is only true for fully connected members. Choice D confuses shear lag with resistance factors.',
    hint: 'Shear lag means not all of the cross-section can develop full stress when only part of it is connected.',
    steps: [
      {
        text: 'For a flat bar connected through its full width: $U = 1.0$.',
        latex: null
      },
      {
        text: 'For an angle connected through one leg:',
        latex: 'U = 1 - \\frac{\\bar{x}}{L} < 1.0'
      },
      {
        text: 'Effective net area:',
        latex: 'A_e = U \\cdot A_n \\quad (\\text{reduced by shear lag})'
      }
    ],
    handbookPage: 'p. 282',
    handbookFormula: 'A_e = U \\cdot A_n',
    videoUrl: null,
    traps: [
      'Assuming $U = 1.0$ for all shapes — it equals 1.0 only when all cross-sectional elements are connected',
      'Confusing shear lag reduction with resistance factor reduction — they are separate concepts'
    ],
    diagram: null,
    lessonId: 'steel-tension',
    chapterId: 'structural'
  },
  {
    id: 'str-tam-ex1',
    type: 'computational',
    statement: 'At a truss joint, an $8\\text{ kN}$ vertical (downward) load is resisted by a horizontal member and a diagonal member inclined at $60^\\circ$ above the horizontal. What is the force in the diagonal?',
    choices: [
      { id: 'c1', text: '$9.24\\text{ kN}$' },
      { id: 'c2', text: '$8.0\\text{ kN}$' },
      { id: 'c3', text: '$6.93\\text{ kN}$' },
      { id: 'c4', text: '$16.0\\text{ kN}$' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Only the diagonal resists the vertical load. $\\sum F_y = 0$: $F\\sin 60^\\circ = 8$, so $F = 8/0.866 = 9.24\\text{ kN}$. Choice C (6.93) multiplies by sin 60° instead of dividing. Choice B forgets the angle entirely.',
    hint: 'Only the diagonal has a vertical component: F·sin60° = 8.',
    steps: [
      { text: '$\\sum F_y = 0$ at the joint: the diagonal carries the vertical load.', latex: null },
      { text: 'Solve:', latex: 'F = \\frac{8}{\\sin 60^\\circ} = \\frac{8}{0.866} = 9.24\\text{ kN}' }
    ],
    handbookPage: null,
    handbookFormula: '\\sum F_y = 0',
    videoUrl: null,
    traps: [
      'Multiplying by sin 60° instead of dividing (6.93 kN)',
      'Ignoring the inclination and reporting 8 kN'
    ],
    diagram: null,
    lessonId: 'truss-analysis-methods',
    chapterId: 'structural'
  },
  {
    id: 'str-tam-ex2',
    type: 'computational',
    statement: 'A vertical section through a parallel-chord truss cuts a diagonal inclined at $45^\\circ$. The net vertical shear carried across that section is $20\\text{ kN}$. What is the force in the diagonal?',
    choices: [
      { id: 'c1', text: '$28.3\\text{ kN}$' },
      { id: 'c2', text: '$20\\text{ kN}$' },
      { id: 'c3', text: '$14.1\\text{ kN}$' },
      { id: 'c4', text: '$40\\text{ kN}$' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Only the diagonal has a vertical component, so it carries the section shear: $F\\sin 45^\\circ = 20$, giving $F = 20/0.707 = 28.3\\text{ kN}$. Choice C (14.1) multiplies by sin 45° instead of dividing.',
    hint: 'The diagonal’s vertical component equals the section shear.',
    steps: [
      { text: 'Method of sections, vertical equilibrium: only the diagonal resists shear.', latex: null },
      { text: 'Solve:', latex: 'F = \\frac{20}{\\sin 45^\\circ} = \\frac{20}{0.707} = 28.3\\text{ kN}' }
    ],
    handbookPage: null,
    handbookFormula: '\\sum F_y = 0',
    videoUrl: null,
    traps: [
      'Multiplying by sin 45° (14.1) instead of dividing',
      'Reporting the shear (20) as the member force'
    ],
    diagram: null,
    lessonId: 'truss-analysis-methods',
    chapterId: 'structural'
  },
  {
    id: 'str-dvw-ex1',
    type: 'computational',
    statement: 'A simply supported beam of length $L = 5\\text{ m}$ carries a uniformly distributed load $w = 8\\text{ kN/m}$. With $EI = 25{,}000\\text{ kN·m}^2$, what is the maximum deflection?',
    choices: [
      { id: 'c1', text: '$2.6\\text{ mm}$' },
      { id: 'c2', text: '$1.3\\text{ mm}$' },
      { id: 'c3', text: '$4.2\\text{ mm}$' },
      { id: 'c4', text: '$10.4\\text{ mm}$' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Simple span under UDL: $\\delta = 5wL^4/384EI = 5(8)(5^4)/(384 \\times 25{,}000) = 25{,}000/9{,}600{,}000 = 0.0026\\text{ m} = 2.6\\text{ mm}$. Choice C uses the point-load formula; Choice D drops the 384 constant.',
    hint: 'Simple span, UDL → 5wL⁴/384EI (note the L⁴).',
    steps: [
      { text: 'Standard case: simple span, UDL.', latex: null },
      { text: 'Apply:', latex: '\\delta = \\frac{5wL^4}{384EI} = \\frac{5(8)(5)^4}{384(25{,}000)}' },
      { text: 'Compute:', latex: '\\delta = \\frac{25{,}000}{9{,}600{,}000} = 0.0026\\text{ m} = 2.6\\text{ mm}' }
    ],
    handbookPage: null,
    handbookFormula: '\\delta_{\\max} = \\frac{5wL^4}{384EI}',
    videoUrl: null,
    traps: [
      'Using the point-load formula (PL³/48EI) for a distributed load',
      'Using L³ instead of L⁴ for a distributed load'
    ],
    diagram: null,
    lessonId: 'deflection-virtual-work',
    chapterId: 'structural'
  },
  {
    id: 'str-ind-ex1',
    type: 'computational',
    statement: 'A beam is fixed (built in) at both ends with no internal hinges. What is its degree of static indeterminacy?',
    choices: [
      { id: 'c1', text: '3' },
      { id: 'c2', text: '1' },
      { id: 'c3', text: '2' },
      { id: 'c4', text: '6' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Each fixed end gives 3 reactions (H, V, M), so $r = 6$. A planar beam has 3 equilibrium equations, so $DSI = 6 - 3 = 3$. Choice B (1) is a propped cantilever, not fixed-fixed. Choice D (6) forgets to subtract the equilibrium equations.',
    hint: 'Two fixed ends = 6 reactions; subtract 3 equilibrium equations.',
    steps: [
      { text: 'Reactions: 3 at each fixed end → $r = 6$.', latex: null },
      { text: '$DSI = r - 3 = 6 - 3 = 3$.', latex: null }
    ],
    handbookPage: null,
    handbookFormula: 'DSI = r - 3',
    videoUrl: null,
    traps: [
      'Confusing a fixed-fixed beam (DSI 3) with a propped cantilever (DSI 1)',
      'Forgetting to subtract the 3 equilibrium equations'
    ],
    diagram: null,
    lessonId: 'indeterminate-structures',
    chapterId: 'structural'
  },
];

export default PROBLEMS;
