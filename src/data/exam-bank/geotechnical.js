// Exam bank: geotechnical
// Auto-extracted from lesson files — 32 questions

const PROBLEMS = [
  {
    id: 'geo-pr-ex1',
    type: 'computational',
    statement: 'A soil sample has a void ratio $e = 0.65$ and specific gravity $G_s = 2.70$. What is the porosity $n$?',
    choices: [
      {
        id: 'c1',
        text: '$0.394$'
      },
      {
        id: 'c2',
        text: '$0.650$'
      },
      {
        id: 'c3',
        text: '$0.241$'
      },
      {
        id: 'c4',
        text: '$0.606$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Porosity relates to void ratio by $n = e/(1+e) = 0.65/(1+0.65) = 0.65/1.65 = 0.394$. Choice B (0.650) is the void ratio itself, not the porosity. Choice C (0.241) might come from $e/(1+G_s)$. Choice D (0.606) might come from $1/(1+e)$, which is the reciprocal relationship.',
    hint: 'Porosity $n = e/(1+e)$. This is one of the core phase-relation identities.',
    steps: [
      {
        text: 'Porosity from void ratio:',
        latex: 'n = \\frac{e}{1+e} = \\frac{0.65}{1+0.65} = \\frac{0.65}{1.65} = 0.394'
      }
    ],
    handbookPage: 'p. 259',
    handbookFormula: 'n = \\frac{e}{1+e}',
    videoUrl: null,
    traps: ['Confusing void ratio (e) with porosity (n) and reporting e as the answer'],
    diagram: null,
    lessonId: 'phase-relations',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-pr-ex2',
    type: 'conceptual',
    statement: 'A soil sample is tested and found to have a degree of saturation $S = 100\\%$. Which of the following statements is correct?',
    choices: [
      {
        id: 'c1',
        text: 'The soil contains no air and no water'
      },
      {
        id: 'c2',
        text: 'All void space is filled with water, and $e = \\omega G_s$'
      },
      {
        id: 'c3',
        text: 'The void ratio must equal 1.0'
      },
      {
        id: 'c4',
        text: 'The water content must equal $G_s$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'When $S = 100\\%$, the voids are completely filled with water (no air phase). The master relationship $Se = \\omega G_s$ simplifies to $e = \\omega G_s$. Choice A is backwards -- full saturation means all voids have water, not that the soil is completely dry. Choice C is wrong because $e$ depends on the soil structure, not saturation alone. Choice D mixes up the formula -- $\\omega = e/G_s$ at full saturation, not $\\omega = G_s$.',
    hint: 'At $S = 1$, the master relationship $Se = \\omega G_s$ simplifies. Think about what $S = 100\\%$ means physically for the void space.',
    steps: [
      {
        text: 'When $S = 100\\%$, all voids are water-filled (no air).',
        latex: null
      },
      {
        text: 'The master relationship simplifies:',
        latex: 'Se = \\omega G_s \\implies (1)e = \\omega G_s \\implies e = \\omega G_s'
      }
    ],
    handbookPage: 'p. 259',
    handbookFormula: 'Se = \\omega G_s',
    videoUrl: null,
    traps: [
      'Assuming full saturation forces a specific void ratio -- e depends on soil fabric, not saturation'
    ],
    diagram: null,
    lessonId: 'phase-relations',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-pr-ex3',
    type: 'computational',
    statement: 'A soil has total unit weight $\\gamma = 125 \\text{ pcf}$ and water content $\\omega = 22\\%$. What is the dry unit weight $\\gamma_d$?',
    choices: [
      {
        id: 'c1',
        text: '$27.5 \\text{ pcf}$'
      },
      {
        id: 'c2',
        text: '$97.5 \\text{ pcf}$'
      },
      {
        id: 'c3',
        text: '$125.0 \\text{ pcf}$'
      },
      {
        id: 'c4',
        text: '$102.5 \\text{ pcf}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Dry unit weight strips out the water: $\\gamma_d = \\gamma/(1+\\omega) = 125/(1+0.22) = 125/1.22 = 102.5$ pcf. Choice B (97.5) might come from subtracting $\\gamma \\times \\omega = 125 \\times 0.22 = 27.5$, giving $125 - 27.5 = 97.5$ -- that is wrong because the water content is based on the weight of solids, not total weight. Choice C (125) is the total unit weight, not dry. Choice A (27.5) is just $\\gamma \\times \\omega$, which has no physical meaning here.',
    hint: 'The formula $\\gamma_d = \\gamma/(1+\\omega)$ converts total unit weight to dry unit weight. Keep $\\omega$ as a decimal.',
    steps: [
      {
        text: 'Dry unit weight formula:',
        latex: '\\gamma_d = \\frac{\\gamma}{1+\\omega}'
      },
      {
        text: 'Substitute:',
        latex: '\\gamma_d = \\frac{125}{1+0.22} = \\frac{125}{1.22} = 102.5 \\text{ pcf}'
      }
    ],
    handbookPage: 'p. 259',
    handbookFormula: '\\gamma_d = \\frac{\\gamma}{1+\\omega}',
    videoUrl: null,
    traps: [
      'Subtracting $\\gamma \\times \\omega$ from $\\gamma$ instead of dividing -- water content is defined relative to solids weight, not total weight'
    ],
    diagram: null,
    lessonId: 'phase-relations',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-pr-ex4',
    type: 'conceptual',
    statement: 'A contractor measures the water content $\\omega$ and total unit weight $\\gamma$ of a compacted fill. Which sequence correctly determines the degree of saturation?',
    choices: [
      {
        id: 'c1',
        text: 'Compute $\\gamma_d = \\gamma \\times \\omega$, then $S = \\gamma_d / \\gamma$'
      },
      {
        id: 'c2',
        text: 'Compute $e = \\omega G_s$, then $S = e / (1+e)$'
      },
      {
        id: 'c3',
        text: 'Compute $\\gamma_d = \\gamma/(1+\\omega)$, then find $e$ from $\\gamma_d = G_s \\gamma_w/(1+e)$, then $S = \\omega G_s / e$'
      },
      {
        id: 'c4',
        text: 'Compute $n = \\omega / G_s$, then $S = n / (1-n)$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'To get $S$ you need $e$, and to get $e$ you need $\\gamma_d$. Step 1: $\\gamma_d = \\gamma/(1+\\omega)$ strips out the water weight. Step 2: rearranging $\\gamma_d = G_s \\gamma_w/(1+e)$ gives $e$. Step 3: $Se = \\omega G_s$ gives $S = \\omega G_s/e$. Choice B is wrong because $e = \\omega G_s$ only works at full saturation ($S = 1$), and then computing $n$ from $e$ is not $S$. Choice A makes up a formula -- $\\gamma_d$ is not $\\gamma \\times \\omega$. Choice D also fabricates a relationship.',
    hint: 'You need three steps: total to dry unit weight, dry unit weight to void ratio, then void ratio to saturation.',
    steps: [
      {
        text: 'Step 1 -- remove water weight:',
        latex: '\\gamma_d = \\frac{\\gamma}{1+\\omega}'
      },
      {
        text: 'Step 2 -- solve for void ratio:',
        latex: 'e = \\frac{G_s \\gamma_w}{\\gamma_d} - 1'
      },
      {
        text: 'Step 3 -- degree of saturation:',
        latex: 'S = \\frac{\\omega G_s}{e}'
      }
    ],
    handbookPage: 'p. 259-260',
    handbookFormula: 'S = \\frac{\\omega G_s}{e}',
    videoUrl: null,
    traps: [
      'Assuming $e = \\omega G_s$ without checking that $S = 1$ first -- that identity only holds for fully saturated soil'
    ],
    diagram: null,
    lessonId: 'phase-relations',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-sc-ex1',
    type: 'computational',
    statement: 'A sand has $D_{10} = 0.25 \\text{ mm}$, $D_{30} = 1.5 \\text{ mm}$, and $D_{60} = 10 \\text{ mm}$ with less than 5% fines. What is the coefficient of uniformity $C_u$?',
    choices: [
      {
        id: 'c1',
        text: '$40$'
      },
      {
        id: 'c2',
        text: '$6$'
      },
      {
        id: 'c3',
        text: '$0.90$'
      },
      {
        id: 'c4',
        text: '$4$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$C_u = D_{60}/D_{10} = 10/0.25 = 40$. This is a direct formula plug-in. Choice B (6) is the minimum $C_u$ threshold for well-graded sand, not the calculated value. Choice C (0.90) is the coefficient of concavity $C_c = (D_{30})^2/(D_{10} \\times D_{60})$. Choice D (4) is the minimum $C_u$ for well-graded gravel.',
    hint: '$C_u = D_{60}/D_{10}$. It measures how spread out the grain sizes are.',
    steps: [
      {
        text: 'Coefficient of uniformity:',
        latex: 'C_u = \\frac{D_{60}}{D_{10}} = \\frac{10}{0.25} = 40'
      }
    ],
    handbookPage: 'p. 267',
    handbookFormula: 'C_u = \\frac{D_{60}}{D_{10}}',
    videoUrl: null,
    traps: [
      'Confusing $C_u$ with $C_c$ -- $C_u$ uses only $D_{60}$ and $D_{10}$, while $C_c$ also uses $D_{30}$'
    ],
    diagram: null,
    lessonId: 'soil-classification',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-sc-ex2',
    type: 'conceptual',
    statement: 'A soil has 70% passing the No. 200 sieve, $LL = 40$, and $PI = 12$. On the USCS plasticity chart, the A-line value at $LL = 40$ is $PI_A = 0.73(40-20) = 14.6$. Since $PI = 12 < 14.6$, the soil plots below the A-line. What is the USCS classification?',
    choices: [
      {
        id: 'c1',
        text: '$\\text{CL}$'
      },
      {
        id: 'c2',
        text: '$\\text{ML}$'
      },
      {
        id: 'c3',
        text: '$\\text{SM}$'
      },
      {
        id: 'c4',
        text: '$\\text{MH}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '70% passing #200 means fine-grained. $LL = 40 < 50$ means low plasticity (L). The problem already tells you the soil plots below the A-line, which means silt (M). So the classification is ML (low-plasticity silt). Choice A (CL) would be above the A-line. Choice C (SM) is a coarse-grained soil with silty fines. Choice D (MH) requires $LL \\geq 50$.',
    hint: 'Follow the USCS decision tree: fine or coarse, then LL < or > 50, then above or below the A-line.',
    steps: [
      {
        text: '70% passes #200 -> fine-grained.',
        latex: null
      },
      {
        text: '$LL = 40 < 50$ -> low plasticity (L).',
        latex: null
      },
      {
        text: '$PI = 12 < PI_A = 14.6$ -> below A-line -> silt (M).',
        latex: null
      },
      {
        text: 'Classification: **ML** (low-plasticity silt).',
        latex: null
      }
    ],
    handbookPage: 'p. 267',
    handbookFormula: '\\text{A-line: } PI = 0.73(LL - 20)',
    videoUrl: null,
    traps: ['Confusing above/below the A-line -- above is clay (C), below is silt (M)'],
    diagram: null,
    lessonId: 'soil-classification',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-sc-ex3',
    type: 'conceptual',
    statement: 'A coarse-grained soil has 40% retained on the No. 4 sieve, 55% passing the No. 4 sieve and retained on the No. 200 sieve, and 5% passing the No. 200 sieve. The gradation coefficients are $C_u = 8$ and $C_c = 2.1$. What is the USCS classification?',
    choices: [
      {
        id: 'c1',
        text: '$\\text{SM}$'
      },
      {
        id: 'c2',
        text: '$\\text{GW}$'
      },
      {
        id: 'c3',
        text: '$\\text{SP}$'
      },
      {
        id: 'c4',
        text: '$\\text{SW}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Only 5% passes #200, so the soil is coarse-grained. Of the coarse fraction (95%), 55% passes the No. 4 sieve -- that is more than half, so it is a sand (S), not gravel (G). With < 5% fines, classify by gradation. For sand: $C_u \\geq 6$ ($8 \\geq 6$, passes) AND $1 \\leq C_c \\leq 3$ (2.1 is in range, passes). Both criteria met, so it is well-graded sand: SW. Choice B (GW) would require more than half the coarse fraction retained on the No. 4 sieve. Choice C (SP) would have one of the gradation criteria fail. Choice A (SM) requires > 12% fines.',
    hint: 'First decide sand vs. gravel (based on the No. 4 sieve split of the coarse fraction), then check both Cu and Cc.',
    steps: [
      {
        text: '5% passes #200 -> coarse-grained.',
        latex: null
      },
      {
        text: 'Of the coarse fraction: more than half passes No. 4 -> sand (S).',
        latex: null
      },
      {
        text: '$C_u = 8 \\geq 6$ \\checkmark and $C_c = 2.1$ in 1-3 range \\checkmark -> well-graded.',
        latex: null
      },
      {
        text: 'Classification: **SW** (well-graded sand).',
        latex: null
      }
    ],
    handbookPage: 'p. 267',
    handbookFormula: 'C_u = \\frac{D_{60}}{D_{10}}, \\quad C_c = \\frac{(D_{30})^2}{D_{10} \\times D_{60}}',
    videoUrl: null,
    traps: [
      'Classifying as gravel because 40% is retained on No. 4 -- the split is based on the coarse fraction, not total'
    ],
    diagram: null,
    lessonId: 'soil-classification',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-sc-ex4',
    type: 'computational',
    statement: 'A fine-grained soil has $LL = 62$ and $PL = 25$. Compute the plasticity index and determine whether the soil plots above or below the A-line. What is the USCS classification?',
    choices: [
      {
        id: 'c1',
        text: '$\\text{CL}$'
      },
      {
        id: 'c2',
        text: '$\\text{MH}$'
      },
      {
        id: 'c3',
        text: '$\\text{CH}$'
      },
      {
        id: 'c4',
        text: '$\\text{OH}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: '$PI = LL - PL = 62 - 25 = 37$. The soil is fine-grained with $LL = 62 > 50$, so it is high plasticity (H). A-line at $LL = 62$: $PI_A = 0.73(62 - 20) = 0.73(42) = 30.7$. Actual $PI = 37 > 30.7$, so it plots above the A-line -- clay (C). Classification: CH (fat clay). Choice B (MH) would be below the A-line. Choice A (CL) requires $LL < 50$. Choice D (OH) is organic soil, which requires comparing oven-dried LL to natural LL -- not determinable from this data alone.',
    hint: 'Compute PI = LL - PL, then compare it to the A-line value at the given LL.',
    steps: [
      {
        text: 'Plasticity index:',
        latex: 'PI = LL - PL = 62 - 25 = 37'
      },
      {
        text: '$LL = 62 > 50$ -> high plasticity (H).',
        latex: null
      },
      {
        text: 'A-line check:',
        latex: 'PI_A = 0.73(62 - 20) = 0.73 \\times 42 = 30.7'
      },
      {
        text: '$PI = 37 > 30.7$ -> above A-line -> clay (C). Classification: **CH**.',
        latex: null
      }
    ],
    handbookPage: 'p. 267',
    handbookFormula: 'PI = LL - PL, \\quad \\text{A-line: } PI = 0.73(LL - 20)',
    videoUrl: null,
    traps: [
      'Choosing MH because LL > 50 -- the LL = 50 line separates L from H, but you still need the A-line to decide clay vs. silt',
      'Selecting OH without evidence of organic content'
    ],
    diagram: null,
    lessonId: 'soil-classification',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-es-ex1',
    type: 'conceptual',
    statement: 'A uniform surcharge $q$ is placed on the ground surface above a saturated clay layer. Which statement correctly describes the effect on effective stress at a point within the clay?',
    choices: [
      {
        id: 'c1',
        text: 'Effective stress increases by $2q$ because both total stress and pore pressure increase by $q$'
      },
      {
        id: 'c2',
        text: 'Both total stress and pore pressure increase by $q$, so effective stress is unchanged'
      },
      {
        id: 'c3',
        text: 'The surcharge has no effect below the water table'
      },
      {
        id: 'c4',
        text: 'Total stress increases by $q$ at all depths, but pore pressure is unchanged, so effective stress increases by $q$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'A surface surcharge adds $q$ to the total vertical stress at every depth. However, it does not change the hydrostatic pore water pressure ($u = \\gamma_w \\times h_w$ is unchanged). Since $\\sigma\' = \\sigma - u$, the effective stress increases by $q$. Choice B describes an undrained loading response in the short term, but the question is about the static equilibrium condition. Choice C is wrong because surcharge absolutely affects stress below the WT. Choice A invents a $2q$ increase that has no basis.',
    hint: 'Apply $\\sigma\' = \\sigma - u$. The surcharge adds to $\\sigma$ but not to hydrostatic $u$.',
    steps: [
      {
        text: 'A surcharge $q$ adds to total stress at all depths:',
        latex: '\\sigma = q + \\gamma H'
      },
      {
        text: 'Hydrostatic pore pressure depends only on water depth:',
        latex: 'u = \\gamma_w h_w \\quad (\\text{unchanged by } q)'
      },
      {
        text: 'Therefore:',
        latex: '\\sigma\' = \\sigma - u \\implies \\Delta\\sigma\' = q'
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: '\\sigma\' = \\sigma - u',
    videoUrl: null,
    traps: [
      'Thinking the surcharge increases pore pressure under static (drained) conditions -- it does not affect hydrostatic $u$'
    ],
    diagram: null,
    lessonId: 'effective-stress',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-es-ex2',
    type: 'computational',
    statement: 'A 12-ft-thick saturated clay layer has $\\gamma_{sat} = 118 \\text{ pcf}$ with the water table at the ground surface. What is the effective vertical stress at a depth of 8 ft?',
    choices: [
      {
        id: 'c1',
        text: '$944 \\text{ psf}$'
      },
      {
        id: 'c2',
        text: '$445 \\text{ psf}$'
      },
      {
        id: 'c3',
        text: '$499 \\text{ psf}$'
      },
      {
        id: 'c4',
        text: '$1{,}416 \\text{ psf}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$\\sigma = \\gamma_{sat} \\times h = 118 \\times 8 = 944$ psf. $u = \\gamma_w \\times h = 62.4 \\times 8 = 499.2$ psf. $\\sigma\' = 944 - 499 = 445$ psf. Or use the shortcut: $\\sigma\' = \\gamma\' \\times h = (118 - 62.4) \\times 8 = 55.6 \\times 8 = 444.8 \\approx 445$ psf. Choice A (944) is the total stress. Choice C (499) is the pore water pressure. Choice D (1,416) would come from using the full 12 ft instead of 8 ft.',
    hint: '$\\sigma\' = \\sigma - u$. Compute total stress and pore pressure at 8 ft depth, then subtract.',
    steps: [
      {
        text: 'Total stress at 8 ft:',
        latex: '\\sigma = 118 \\times 8 = 944 \\text{ psf}'
      },
      {
        text: 'Pore water pressure:',
        latex: 'u = 62.4 \\times 8 = 499 \\text{ psf}'
      },
      {
        text: 'Effective stress:',
        latex: '\\sigma\' = 944 - 499 = 445 \\text{ psf}'
      }
    ],
    handbookPage: 'p. 263',
    handbookFormula: '\\sigma\' = \\sigma - u',
    videoUrl: null,
    traps: [
      'Computing stress at 12 ft (bottom of layer) instead of 8 ft as asked',
      'Reporting total stress as the answer without subtracting pore pressure'
    ],
    diagram: null,
    lessonId: 'effective-stress',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-es-ex3',
    type: 'conceptual',
    statement: 'At a site, the water table drops by 5 ft due to pumping. The soil above the new water table was previously saturated and is now moist with $\\gamma_{moist} = 110 \\text{ pcf}$. What happens to the effective stress at a point 20 ft below the original water table?',
    choices: [
      {
        id: 'c1',
        text: 'Effective stress decreases because the water table dropped'
      },
      {
        id: 'c2',
        text: 'Effective stress stays the same because sigma and u both decrease equally'
      },
      {
        id: 'c3',
        text: 'Effective stress increases because pore pressure decreases more than total stress decreases'
      },
      {
        id: 'c4',
        text: 'Effective stress is unaffected because the point is still below the water table'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'When the WT drops 5 ft, pore pressure at our point decreases by $\\gamma_w \\times 5 = 62.4 \\times 5 = 312$ psf. Total stress changes because the 5-ft zone above went from saturated (~120 pcf) to moist (110 pcf), so total stress decreases by about $(120 - 110) \\times 5 = 50$ psf. Since $\\sigma\' = \\sigma - u$, and $u$ decreased by 312 while $\\sigma$ decreased by only 50, the net change in effective stress is +262 psf -- it increases. Choice B is wrong because $\\sigma$ and $u$ do not decrease equally. Choice A confuses direction. Choice D ignores that the WT position affects pore pressure at all depths below it.',
    hint: 'Compare the change in total stress vs. the change in pore pressure. Whichever changes more controls the direction of effective stress change.',
    steps: [
      {
        text: 'Pore pressure decrease at depth:',
        latex: '\\Delta u = -\\gamma_w \\times 5 = -312 \\text{ psf}'
      },
      {
        text: 'Total stress decrease (saturated to moist):',
        latex: '\\Delta \\sigma \\approx -(\\gamma_{sat} - \\gamma_{moist}) \\times 5 \\approx -50 \\text{ psf}'
      },
      {
        text: 'Effective stress change:',
        latex: '\\Delta \\sigma\' = \\Delta \\sigma - \\Delta u = -50 - (-312) = +262 \\text{ psf (increase)}'
      }
    ],
    handbookPage: 'p. 263-264',
    handbookFormula: '\\sigma\' = \\sigma - u',
    videoUrl: null,
    traps: [
      'Assuming total stress and pore pressure decrease equally -- $\\gamma_w$ is much larger than the difference between saturated and moist unit weights'
    ],
    diagram: null,
    lessonId: 'effective-stress',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-es-ex4',
    type: 'computational',
    statement: 'A profile has 4 ft of dry sand ($\\gamma = 105 \\text{ pcf}$), then 6 ft of saturated sand ($\\gamma_{sat} = 120 \\text{ pcf}$), then 10 ft of saturated clay ($\\gamma_{sat} = 115 \\text{ pcf}$). The water table is at the top of the saturated sand. A $150 \\text{ psf}$ surcharge sits on the surface. What is the effective stress at the bottom of the clay?',
    choices: [
      {
        id: 'c1',
        text: '$998 \\text{ psf}$'
      },
      {
        id: 'c2',
        text: '$2{,}440 \\text{ psf}$'
      },
      {
        id: 'c3',
        text: '$1{,}292 \\text{ psf}$'
      },
      {
        id: 'c4',
        text: '$1{,}442 \\text{ psf}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'Total stress: $\\sigma = 150 + 105(4) + 120(6) + 115(10) = 150 + 420 + 720 + 1{,}150 = 2{,}440$ psf. Pore pressure: $u = 62.4(6 + 10) = 62.4(16) = 998$ psf. Effective: $\\sigma\' = 2{,}440 - 998 = 1{,}442$ psf. Choice B (2,440) is the total stress without subtracting pore pressure. Choice C (1,292) forgot to include the surcharge ($2{,}290 - 998 = 1{,}292$). Choice A (998) is just the pore water pressure.',
    hint: 'Total stress = surcharge + weight of all three layers. Pore pressure = $\\gamma_w$ times total water depth below WT.',
    steps: [
      {
        text: 'Total stress:',
        latex: '\\sigma = 150 + 105(4) + 120(6) + 115(10) = 150 + 420 + 720 + 1{,}150 = 2{,}440 \\text{ psf}'
      },
      {
        text: 'Pore water pressure (16 ft below WT):',
        latex: 'u = 62.4 \\times 16 = 998 \\text{ psf}'
      },
      {
        text: 'Effective stress:',
        latex: '\\sigma\' = 2{,}440 - 998 = 1{,}442 \\text{ psf}'
      }
    ],
    handbookPage: 'p. 263-264',
    handbookFormula: '\\sigma\' = \\sigma - u',
    videoUrl: null,
    traps: [
      'Forgetting to include the surcharge in total stress',
      'Computing pore pressure using only the clay thickness (10 ft) instead of the full depth below the WT (16 ft)'
    ],
    diagram: {
      component: 'SoilProfile',
      props: {
        layers: [
          {
            name: 'Dry Sand',
            h: 4,
            gamma: 105,
            saturated: false
          },
          {
            name: 'Sat. Sand',
            h: 6,
            gamma: 120,
            saturated: true
          },
          {
            name: 'Sat. Clay',
            h: 10,
            gamma: 115,
            saturated: true
          }
        ],
        wtDepth: 4,
        surcharge: 150,
        depthUnit: 'ft',
        weightUnit: 'pcf'
      }
    },
    lessonId: 'effective-stress',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-con-ex1',
    type: 'computational',
    statement: 'A normally consolidated clay has $C_c = 0.35$, $e_0 = 0.80$, and $H_0 = 8 \\text{ ft}$. The effective stress increases from $\\sigma_0\' = 2{,}000 \\text{ psf}$ to $\\sigma_0\' + \\Delta\\sigma = 4{,}000 \\text{ psf}$. What is the consolidation settlement?',
    choices: [
      {
        id: 'c1',
        text: '$5.6 \\text{ in.}$'
      },
      {
        id: 'c2',
        text: '$11.2 \\text{ in.}$'
      },
      {
        id: 'c3',
        text: '$2.8 \\text{ in.}$'
      },
      {
        id: 'c4',
        text: '$18.7 \\text{ in.}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'NC clay uses Case 2: $\\Delta H = H_0/(1+e_0) \\times C_c \\times \\log((p_0+\\Delta p)/p_0) = 8/(1.80) \\times 0.35 \\times \\log(4000/2000) = 4.444 \\times 0.35 \\times \\log(2) = 4.444 \\times 0.35 \\times 0.3010 = 0.468$ ft $= 5.6$ in. Choice B (11.2) forgets to divide by $(1+e_0)$. Choice C (2.8) might use $C_r$ instead of $C_c$. Choice D (18.7) uses $\\ln$ instead of $\\log_{10}$.',
    hint: 'NC clay means Case 2 with $C_c$. Remember $\\log$ is base-10 (common logarithm).',
    steps: [
      {
        text: 'NC clay -> Case 2:',
        latex: '\\Delta H = \\frac{H_0}{1+e_0} C_c \\log \\frac{\\sigma_0\' + \\Delta\\sigma}{\\sigma_0\'}'
      },
      {
        text: 'Substitute:',
        latex: '\\Delta H = \\frac{8}{1.80} \\times 0.35 \\times \\log \\frac{4{,}000}{2{,}000} = 4.444 \\times 0.35 \\times 0.3010'
      },
      {
        text: 'Compute:',
        latex: '\\Delta H = 0.468 \\text{ ft} = 5.6 \\text{ in.}'
      }
    ],
    handbookPage: 'p. 261',
    handbookFormula: '\\Delta H = \\frac{H_0}{1+e_0} C_c \\log \\frac{p_0 + \\Delta p}{p_0}',
    videoUrl: null,
    traps: [
      'Using $\\ln$ (natural log) instead of $\\log_{10}$ -- the consolidation formula uses common logarithm'
    ],
    diagram: null,
    lessonId: 'consolidation',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-con-ex2',
    type: 'conceptual',
    statement: 'A clay layer is drained on top (sand) and sits on impermeable rock at the bottom. The layer is 20 ft thick. What is the drainage path length $H_{dr}$ for computing the time factor $T_v$?',
    choices: [
      {
        id: 'c1',
        text: '$10 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$20 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$40 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$5 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'With sand on top (permeable) and rock on bottom (impermeable), water can only drain upward -- this is one-way drainage. For one-way drainage, $H_{dr}$ equals the full layer thickness: $H_{dr} = H = 20$ ft. Choice A (10 ft) would be correct for two-way drainage ($H_{dr} = H/2$), but that requires permeable boundaries on both sides. Choice C (40 ft) doubles the thickness for no reason. Choice D (5 ft) divides by 4, which is not a valid drainage path.',
    hint: 'Count the number of drainage faces. One-way: $H_{dr} = H$. Two-way: $H_{dr} = H/2$.',
    steps: [
      {
        text: 'Top boundary: sand (permeable) -> drainage face.',
        latex: null
      },
      {
        text: 'Bottom boundary: rock (impermeable) -> no drainage.',
        latex: null
      },
      {
        text: 'One-way drainage:',
        latex: 'H_{dr} = H = 20 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 262',
    handbookFormula: 'T_v = \\frac{c_v \\cdot t}{H_{dr}^2}',
    videoUrl: null,
    traps: [
      'Automatically halving the thickness -- $H_{dr} = H/2$ only applies for two-way drainage with permeable boundaries on both sides'
    ],
    diagram: {
      component: 'ConsolidationLayer',
      props: {
        thickness: 20,
        topPermeable: true,
        bottomPermeable: false,
        topLabel: 'Sand',
        bottomLabel: 'Rock',
        unit: 'ft'
      }
    },
    lessonId: 'consolidation',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-con-ex3',
    type: 'computational',
    statement: 'A clay layer has $c_v = 0.40 \\text{ ft}^2\\text{/day}$ and two-way drainage with $H_{dr} = 8 \\text{ ft}$. Using $T_v = 0.848$ for $U = 90\\%$, how many days for 90% consolidation?',
    choices: [
      {
        id: 'c1',
        text: '$17 \\text{ days}$'
      },
      {
        id: 'c2',
        text: '$542 \\text{ days}$'
      },
      {
        id: 'c3',
        text: '$136 \\text{ days}$'
      },
      {
        id: 'c4',
        text: '$68 \\text{ days}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$t = T_v \\times H_{dr}^2 / c_v = 0.848 \\times 64 / 0.40 = 54.27 / 0.40 = 135.7 \\approx 136$ days. Choice B (542) uses the full layer thickness $H = 16$ ft instead of $H_{dr} = 8$ ft (quadruples the time). Choice A (17) might divide by $H_{dr}$ instead of $H_{dr}^2$. Choice D (68) divides the correct answer by 2 for no reason.',
    hint: 'Rearrange $T_v = c_v t / H_{dr}^2$ to solve for $t$. Make sure you use $H_{dr}$, not the full thickness.',
    steps: [
      {
        text: 'Solve for time:',
        latex: 't = \\frac{T_v \\cdot H_{dr}^2}{c_v} = \\frac{0.848 \\times 8^2}{0.40}'
      },
      {
        text: 'Compute:',
        latex: 't = \\frac{0.848 \\times 64}{0.40} = \\frac{54.3}{0.40} = 136 \\text{ days}'
      }
    ],
    handbookPage: 'p. 262',
    handbookFormula: 'T_v = \\frac{c_v \\cdot t}{H_{dr}^2}',
    videoUrl: null,
    traps: [
      'Using the full layer thickness $H$ instead of $H_{dr}$ -- for two-way drainage, $H_{dr} = H/2$',
      'Confusing $T_v$ values -- $T_v = 0.197$ is for $U = 50\\%$, not 90%'
    ],
    diagram: null,
    lessonId: 'consolidation',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-con-ex4',
    type: 'conceptual',
    statement: 'An overconsolidated clay has $p_0\' = 1{,}500 \\text{ psf}$ and $p_c = 3{,}000 \\text{ psf}$. A new fill increases stress by $\\Delta\\sigma = 1{,}000 \\text{ psf}$. Which consolidation case applies, and which compression index controls the settlement?',
    choices: [
      {
        id: 'c1',
        text: 'Case 1 with $C_c$, because all consolidation uses the compression index'
      },
      {
        id: 'c2',
        text: 'Case 2 (normally consolidated) with $C_c$, because the soil is being loaded'
      },
      {
        id: 'c3',
        text: 'Case 3 (crosses $p_c$) with both $C_r$ and $C_c$'
      },
      {
        id: 'c4',
        text: 'Case 1 (entirely in recompression) with $C_r$, because $p_0\' + \\Delta\\sigma = 2{,}500 < p_c = 3{,}000$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'The final stress is $p_0 + \\Delta p = 1{,}500 + 1{,}000 = 2{,}500$ psf. Since $2{,}500 < p_c = 3{,}000$, the entire stress increase stays below the preconsolidation pressure. This is Case 1 -- entirely in the recompression range. The applicable index is $C_r$ (recompression), not $C_c$ (virgin compression). Case 2 applies only to NC clay ($p_0 \\geq p_c$). Case 3 applies when the final stress crosses $p_c$ ($p_0 < p_c < p_0 + \\Delta p$). Choice A is wrong because Case 1 uses $C_r$, not $C_c$.',
    hint: 'Compare $p_0 + \\Delta\\sigma$ to $p_c$. If the final stress stays below $p_c$, the soil remains overconsolidated.',
    steps: [
      {
        text: 'Check final stress:',
        latex: 'p_0 + \\Delta\\sigma = 1{,}500 + 1{,}000 = 2{,}500 \\text{ psf}'
      },
      {
        text: 'Compare to $p_c$:',
        latex: '2{,}500 < 3{,}000 \\implies \\text{stress stays below } p_c'
      },
      {
        text: 'Case 1 applies: use $C_r$ for the entire settlement.',
        latex: null
      }
    ],
    handbookPage: 'p. 261',
    handbookFormula: '\\Delta H = \\frac{H_0}{1+e_0} C_r \\log \\frac{p_0 + \\Delta p}{p_0}',
    videoUrl: null,
    traps: [
      'Automatically using $C_c$ for any consolidation problem -- $C_r$ applies when stress stays below $p_c$',
      'Confusing Case 1 with Case 3 -- Case 3 requires the final stress to exceed $p_c$'
    ],
    diagram: null,
    lessonId: 'consolidation',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-ss-ex1',
    type: 'computational',
    statement: 'A granular soil ($c\' = 0$) has an effective friction angle $\\phi\' = 35\\degree$. What is the shear strength on a plane where the effective normal stress is $\\sigma_N\' = 2{,}000 \\text{ psf}$?',
    choices: [
      {
        id: 'c1',
        text: '$1{,}400 \\text{ psf}$'
      },
      {
        id: 'c2',
        text: '$2{,}000 \\text{ psf}$'
      },
      {
        id: 'c3',
        text: '$1{,}148 \\text{ psf}$'
      },
      {
        id: 'c4',
        text: '$700 \\text{ psf}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$\\tau_f = c\' + \\sigma_N\' \\tan(\\phi\') = 0 + 2{,}000 \\times \\tan(35\\degree) = 2{,}000 \\times 0.7002 = 1{,}400$ psf. Choice B (2,000) is the normal stress, not the shear strength. Choice C (1,148) might come from using $\\sin(35\\degree)$ instead of $\\tan(35\\degree)$. Choice D (700) divides the answer by 2 for no reason.',
    hint: 'For granular soil, $c = 0$. Shear strength is purely frictional: $\\tau = \\sigma_N \\tan(\\phi)$.',
    steps: [
      {
        text: 'Mohr-Coulomb with $c\' = 0$:',
        latex: '\\tau_f = \\sigma_N\' \\tan \\phi\' = 2{,}000 \\times \\tan 35\\degree'
      },
      {
        text: 'Compute:',
        latex: '\\tau_f = 2{,}000 \\times 0.7002 = 1{,}400 \\text{ psf}'
      }
    ],
    handbookPage: 'p. 263',
    handbookFormula: '\\tau_f = c + \\sigma_N \\tan \\phi',
    videoUrl: null,
    traps: [
      'Using $\\sin(\\phi)$ or $\\cos(\\phi)$ instead of $\\tan(\\phi)$ in the Mohr-Coulomb equation'
    ],
    diagram: null,
    lessonId: 'shear-strength',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-ss-ex2',
    type: 'conceptual',
    statement: 'A saturated clay is loaded rapidly, and the engineer selects undrained parameters ($c_u$, $\\phi_u = 0$). Which statement best describes why $\\phi_u = 0$?',
    choices: [
      {
        id: 'c1',
        text: 'Clay particles are flat and smooth, so there is no frictional resistance'
      },
      {
        id: 'c2',
        text: 'Under undrained loading, excess pore pressure absorbs the stress change so effective stress on the failure plane does not change, making shear strength independent of applied normal stress'
      },
      {
        id: 'c3',
        text: 'The friction angle is always zero for any clay soil regardless of drainage'
      },
      {
        id: 'c4',
        text: 'Water between particles acts as a lubricant, eliminating all friction'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'In undrained loading of a saturated clay, any increase in total stress is carried entirely by excess pore water pressure. The effective stress on the failure plane stays the same, so the shear strength does not change with the applied confining pressure -- hence $\\phi_u = 0$ in total-stress terms. Choice A is wrong because clay does have friction in drained conditions ($\\phi\'$ is typically 20-30 degrees). Choice C is wrong because drained analysis uses nonzero $\\phi\'$. Choice D is a misconception -- water does not eliminate friction in the soil skeleton.',
    hint: 'Think about what happens to pore pressure when you load saturated clay quickly. Does effective stress change?',
    steps: [
      {
        text: 'Under undrained conditions in saturated clay, $\\Delta u = \\Delta \\sigma$.',
        latex: null
      },
      {
        text: 'Effective stress change:',
        latex: '\\Delta \\sigma\' = \\Delta \\sigma - \\Delta u = 0'
      },
      {
        text: 'Since $\\sigma\'$ does not change, $\\tau_f$ is constant regardless of applied total stress -> $\\phi_u = 0$.',
        latex: null
      }
    ],
    handbookPage: 'p. 262-263',
    handbookFormula: '\\tau_f = c_u \\quad (\\phi_u = 0)',
    videoUrl: null,
    traps: [
      'Thinking clay has zero friction angle under all conditions -- $\\phi_u = 0$ applies only to undrained total-stress analysis'
    ],
    diagram: null,
    lessonId: 'shear-strength',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-ss-ex3',
    type: 'computational',
    statement: 'A drained triaxial test on a cohesionless sand gives $\\sigma_1\' = 9{,}000 \\text{ psf}$ and $\\sigma_3\' = 3{,}000 \\text{ psf}$ at failure. What is the effective friction angle $\\phi\'$?',
    choices: [
      {
        id: 'c1',
        text: '$26.6\\degree$'
      },
      {
        id: 'c2',
        text: '$45\\degree$'
      },
      {
        id: 'c3',
        text: '$30\\degree$'
      },
      {
        id: 'c4',
        text: '$19.5\\degree$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'For $c = 0$: $\\sin(\\phi) = (\\sigma_1 - \\sigma_3)/(\\sigma_1 + \\sigma_3) = (9{,}000 - 3{,}000)/(9{,}000 + 3{,}000) = 6{,}000/12{,}000 = 0.50$. $\\phi = \\arcsin(0.50) = 30\\degree$. Choice B (45) might come from computing the stress ratio $\\sigma_1/\\sigma_3 = 3$ and misusing it. Choice A (26.6) is $\\arctan(0.50)$ -- a common error from using tan instead of sin. Choice D (19.5) might come from $\\arcsin(\\sigma_3/\\sigma_1)$.',
    hint: 'For a cohesionless soil: $\\sin(\\phi) = (\\sigma_1 - \\sigma_3)/(\\sigma_1 + \\sigma_3)$.',
    steps: [
      {
        text: 'For $c = 0$:',
        latex: '\\sin \\phi = \\frac{\\sigma_1 - \\sigma_3}{\\sigma_1 + \\sigma_3} = \\frac{9{,}000 - 3{,}000}{9{,}000 + 3{,}000} = \\frac{6{,}000}{12{,}000} = 0.50'
      },
      {
        text: 'Friction angle:',
        latex: '\\phi = \\arcsin(0.50) = 30\\degree'
      }
    ],
    handbookPage: 'p. 262',
    handbookFormula: '\\sin \\phi = \\frac{\\sigma_1 - \\sigma_3}{\\sigma_1 + \\sigma_3}',
    videoUrl: null,
    traps: [
      'Using $\\arctan$ instead of $\\arcsin$ -- the Mohr circle relationship gives $\\sin(\\phi)$, not $\\tan(\\phi)$',
      'Computing $\\sigma_1/\\sigma_3 = 3$ and using $\\arctan(3)$ or $\\arcsin(3)$'
    ],
    diagram: null,
    lessonId: 'shear-strength',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-ss-ex4',
    type: 'conceptual',
    statement: 'Two UU triaxial tests on identical saturated clay specimens give the same undrained shear strength $c_u = 1{,}000 \\text{ psf}$, even though the confining pressures were $\\sigma_3 = 2{,}000 \\text{ psf}$ and $\\sigma_3 = 4{,}000 \\text{ psf}$. Which explanation is most correct?',
    choices: [
      {
        id: 'c1',
        text: 'The specimens consolidated under the higher pressure before shearing, so both reached the same strength'
      },
      {
        id: 'c2',
        text: 'The tests were performed incorrectly; different confining pressures must produce different strengths'
      },
      {
        id: 'c3',
        text: 'The clay was overconsolidated, which makes it insensitive to confining pressure'
      },
      {
        id: 'c4',
        text: 'In a UU test on saturated clay ($\\phi_u = 0$), the confining pressure generates equal excess pore pressure, so effective stress at failure is the same in both tests'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'In a UU test on saturated clay, the sample is not allowed to drain. Any increase in confining pressure goes entirely to pore pressure, so the effective stress does not change. Since strength depends on effective stress, both specimens have the same shear strength regardless of the confining pressure. This is why the Mohr envelope is a horizontal line ($\\phi_u = 0$) with $\\tau_f = c_u$. Choice B is wrong -- this is exactly expected behavior. Choice C is wrong -- even NC clays behave this way in UU tests. Choice A describes a CU or CD test, not UU.',
    hint: 'In a UU test, neither the confining stage nor the shearing stage allows drainage. What happens to pore pressure when you increase total stress on a saturated sample?',
    steps: [
      {
        text: 'In a UU test on saturated clay, $B = 1$ (Skempton\'s B-value):',
        latex: '\\Delta u = \\Delta \\sigma_3'
      },
      {
        text: 'Effective confining stress is unchanged:',
        latex: '\\sigma_3\' = \\sigma_3 - u = \\text{constant}'
      },
      {
        text: 'Same $\\sigma_3\'$ -> same strength -> $c_u$ is independent of $\\sigma_3$.',
        latex: null
      }
    ],
    handbookPage: 'p. 262-263',
    handbookFormula: '\\tau_f = c_u \\quad (\\phi_u = 0)',
    videoUrl: null,
    traps: [
      'Thinking higher confining pressure always produces higher strength -- that is true for drained tests but not for undrained tests on saturated clay'
    ],
    diagram: null,
    lessonId: 'shear-strength',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-bc-ex1',
    type: 'computational',
    statement: 'A strip footing is 1.5 m wide, founded at a depth of 1.0 m in a cohesive soil with $c = 80\\,\\text{kPa}$, $\\phi = 0°$, and $\\gamma = 18\\,\\text{kN/m}^3$. Using Terzaghi\'s equation with $N_c = 5.7$, $N_q = 1.0$, $N_\\gamma = 0$, what is the ultimate bearing capacity?',
    choices: [
      {
        id: 'c1',
        text: '456 kPa'
      },
      {
        id: 'c2',
        text: '474 kPa'
      },
      {
        id: 'c3',
        text: '512 kPa'
      },
      {
        id: 'c4',
        text: '546 kPa'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'For a strip footing: $q_u = cN_c + qN_q + 0.5\\gamma B N_\\gamma$. With $\\phi = 0$, $N_\\gamma = 0$ so the third term drops out. $q$ (overburden) $= \\gamma D = 18 \\times 1.0 = 18$ kPa. $q_u = 80(5.7) + 18(1.0) + 0 = 456 + 18 = 474$ kPa. The trap is forgetting the overburden pressure term ($qN_q$).',
    hint: 'Use Terzaghi\'s bearing capacity equation for a strip footing.',
    steps: [
      {
        text: 'Terzaghi\'s equation for strip footing:',
        latex: 'q_u = cN_c + qN_q + \\frac{1}{2}\\gamma B N_\\gamma'
      },
      {
        text: 'Overburden pressure:',
        latex: 'q = \\gamma D_f = 18 \\times 1.0 = 18\\,\\text{kPa}'
      },
      {
        text: 'Substitute:',
        latex: 'q_u = 80(5.7) + 18(1.0) + 0 = 456 + 18 = 474\\,\\text{kPa}'
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: 'q_u = cN_c + qN_q + \\frac{1}{2}\\gamma B N_\\gamma',
    videoUrl: null,
    traps: ['Forgetting the overburden term $qN_q$', 'Using depth instead of width for the $N_\\gamma$ term'],
    diagram: {
      component: 'FootingSection',
      props: {
        width: 1.5,
        depth: 1,
        unit: 'm'
      }
    },
    lessonId: 'bearing-capacity',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-bc-ex2',
    type: 'conceptual',
    statement: 'In Terzaghi\'s bearing capacity equation, increasing the depth of the footing primarily affects the bearing capacity through:',
    choices: [
      {
        id: 'c1',
        text: 'The cohesion term ($cN_c$)'
      },
      {
        id: 'c2',
        text: 'The overburden term ($qN_q$)'
      },
      {
        id: 'c3',
        text: 'The width term ($0.5\\gamma B N_\\gamma$)'
      },
      {
        id: 'c4',
        text: 'All three terms equally'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The overburden pressure $q = \\gamma D_f$. When you increase the depth $D_f$, $q$ increases, which directly increases the $qN_q$ term. The cohesion term depends on soil properties (not depth), and the width term depends on footing width $B$ (not depth). So deeper footings have higher bearing capacity primarily because of the increased overburden.',
    hint: 'Which term in the equation contains the foundation depth?',
    steps: [
      {
        text: 'The overburden pressure $q = \\gamma D_f$ increases with depth.',
        latex: null
      },
      {
        text: 'This directly increases the $qN_q$ term in the bearing capacity equation.',
        latex: null
      },
      {
        text: 'The other terms ($cN_c$ and $0.5\\gamma BN_\\gamma$) are independent of depth.',
        latex: null
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: 'q_u = cN_c + qN_q + \\frac{1}{2}\\gamma B N_\\gamma',
    videoUrl: null,
    traps: ['Thinking depth affects the width term (it does not — B is width, not depth)'],
    diagram: null,
    lessonId: 'bearing-capacity',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-bc-ex3',
    type: 'conceptual',
    statement: 'A strip footing is designed with a factor of safety of 3 against bearing capacity failure. If the water table rises from well below the footing to the ground surface, the allowable bearing capacity will:',
    choices: [
      {
        id: 'c1',
        text: 'Increase because buoyancy reduces soil weight'
      },
      {
        id: 'c2',
        text: 'Decrease because effective unit weight replaces total unit weight'
      },
      {
        id: 'c3',
        text: 'Remain unchanged because the FS is the same'
      },
      {
        id: 'c4',
        text: 'Decrease only if the soil is cohesionless'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The bearing capacity equation uses the effective unit weight of the soil. When the water table rises to the surface, you replace the total unit weight with the buoyant unit weight ($\\gamma_{sat} - \\gamma_w$), which is roughly half the original value. This reduces both the overburden term ($\\gamma D_f N_q$) and the width term ($0.5\\gamma B N_\\gamma$), lowering $q_{ult}$ and therefore $q_{allow}$. This happens regardless of whether the soil has cohesion or not, because the $\\gamma$ terms affect all soils.',
    hint: 'Think about what happens to the unit weight terms in the bearing capacity equation when the soil is submerged.',
    steps: [
      {
        text: 'Below the water table, effective unit weight replaces total unit weight:',
        latex: '\\gamma\' = \\gamma_{sat} - \\gamma_w'
      },
      {
        text: 'Since $\\gamma\' < \\gamma$, both the $\\gamma D_f N_q$ and $0.5\\gamma B N_\\gamma$ terms decrease.',
        latex: null
      },
      {
        text: 'This reduces $q_{ult}$ and therefore $q_{allow} = q_{ult}/FS$.',
        latex: null
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: 'q_u = cN_c + qN_q + \\frac{1}{2}\\gamma B N_\\gamma',
    videoUrl: null,
    traps: [
      'Thinking buoyancy helps the footing — it actually reduces bearing capacity',
      'Assuming the cohesion term is affected by the water table — c is a soil property, not a function of gamma'
    ],
    diagram: null,
    lessonId: 'bearing-capacity',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-bc-ex4',
    type: 'computational',
    statement: 'A 2.0 m wide strip footing is founded at a depth of 1.5 m in soil with $c = 25\\,\\text{kPa}$, $\\phi = 20°$, and $\\gamma = 17\\,\\text{kN/m}^3$. Given $N_c = 14.83$, $N_q = 6.40$, $N_\\gamma = 5.39$. The water table is well below the footing. What is the allowable bearing capacity using $FS = 3$?',
    choices: [
      {
        id: 'c1',
        text: '209 kPa'
      },
      {
        id: 'c2',
        text: '570 kPa'
      },
      {
        id: 'c3',
        text: '370 kPa'
      },
      {
        id: 'c4',
        text: '155 kPa'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Compute each term of Terzaghi\'s equation. $cN_c = 25(14.83) = 370.8$ kPa. The overburden $q = \\gamma D_f = 17(1.5) = 25.5$ kPa, so $qN_q = 25.5(6.40) = 163.2$ kPa. The width term $= 0.5(17)(2.0)(5.39) = 91.6$ kPa. Total $q_{ult} = 370.8 + 163.2 + 91.6 = 625.6$ kPa. Divide by FS: $q_{allow} = 625.6/3 = 208.5 \\approx 209$ kPa. Choice B (570) is close to $q_{ult}$ without dividing by FS. Choice C (370) is just the cohesion term. Choice D (155) uses the wrong factors.',
    hint: 'Compute all three terms of Terzaghi\'s equation, sum them for qult, then divide by FS = 3.',
    steps: [
      {
        text: 'Cohesion term:',
        latex: 'cN_c = 25 \\times 14.83 = 370.8\\,\\text{kPa}'
      },
      {
        text: 'Overburden pressure:',
        latex: 'q = \\gamma D_f = 17 \\times 1.5 = 25.5\\,\\text{kPa}'
      },
      {
        text: 'Overburden term:',
        latex: 'qN_q = 25.5 \\times 6.40 = 163.2\\,\\text{kPa}'
      },
      {
        text: 'Width term:',
        latex: '\\tfrac{1}{2}\\gamma B N_\\gamma = 0.5 \\times 17 \\times 2.0 \\times 5.39 = 91.6\\,\\text{kPa}'
      },
      {
        text: 'Ultimate bearing capacity:',
        latex: 'q_{ult} = 370.8 + 163.2 + 91.6 = 625.6\\,\\text{kPa}'
      },
      {
        text: 'Allowable:',
        latex: 'q_{allow} = \\frac{625.6}{3} = 208.5 \\approx 209\\,\\text{kPa}'
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: 'q_u = cN_c + qN_q + \\frac{1}{2}\\gamma B N_\\gamma',
    videoUrl: null,
    traps: [
      'Reporting $q_{ult}$ instead of $q_{allow}$ -- the problem asks for allowable with $FS = 3$',
      'Forgetting the 1/2 factor on the $N_\\gamma$ term'
    ],
    diagram: {
      component: 'FootingSection',
      props: {
        width: 2,
        depth: 1.5,
        unit: 'm'
      }
    },
    lessonId: 'bearing-capacity',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-lep-ex1',
    type: 'conceptual',
    statement: 'A rigid basement wall is poured against soil and cannot move. Which earth pressure condition applies?',
    choices: [
      {
        id: 'c1',
        text: 'Both active and passive simultaneously'
      },
      {
        id: 'c2',
        text: 'Active ($K_a$), because it is the minimum pressure'
      },
      {
        id: 'c3',
        text: 'Passive ($K_p$), because the wall resists the soil'
      },
      {
        id: 'c4',
        text: 'At-rest ($K_0$), because the wall does not move'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'The at-rest condition ($K_0$) applies when a wall is perfectly rigid and does not deflect. Active pressure ($K_a$) develops only when the wall moves away from the soil, allowing the soil to expand. Passive pressure ($K_p$) develops when the wall pushes into the soil. A rigid basement wall that cannot deform experiences at-rest pressure. Choice B is wrong because active requires wall movement away. Choice C is wrong because passive requires wall movement into the soil. Choice A is not a real condition.',
    hint: 'Active requires wall movement away from soil. Passive requires movement into soil. No movement means at-rest.',
    steps: [
      {
        text: 'No wall movement -> at-rest condition.',
        latex: null
      },
      {
        text: 'The applicable coefficient is:',
        latex: 'K_0 \\approx 1 - \\sin \\phi'
      },
      {
        text: 'Relationship: $K_a < K_0 < K_p$.',
        latex: null
      }
    ],
    handbookPage: 'p. 263',
    handbookFormula: 'K_0 = 1 - \\sin \\phi',
    videoUrl: null,
    traps: [
      'Designing a rigid wall for active pressure -- $K_a$ underestimates the real force on an unyielding wall'
    ],
    diagram: null,
    lessonId: 'lateral-earth-pressure',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-lep-ex2',
    type: 'computational',
    statement: 'A 20-ft-tall retaining wall has backfill with $\\phi\' = 30\\degree$, $\\gamma = 110 \\text{ pcf}$, and $c = 0$. What is the total active force per foot of wall?',
    choices: [
      {
        id: 'c1',
        text: '$14{,}670 \\text{ lb/ft}$'
      },
      {
        id: 'c2',
        text: '$7{,}330 \\text{ lb/ft}$'
      },
      {
        id: 'c3',
        text: '$22{,}000 \\text{ lb/ft}$'
      },
      {
        id: 'c4',
        text: '$3{,}670 \\text{ lb/ft}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$K_a = \\tan^2(45\\degree - 30\\degree/2) = \\tan^2(30\\degree) = (1/\\sqrt{3})^2 = 1/3 = 0.333$. $P_a = 0.5 \\times K_a \\times \\gamma \\times H^2 = 0.5 \\times 0.333 \\times 110 \\times 400 = 7{,}333 \\approx 7{,}330$ lb/ft. Choice A (14,670) forgets the 1/2 factor. Choice C (22,000) uses $K_p = 3$ instead of $K_a = 1/3$. Choice D (3,670) halves the answer again incorrectly.',
    hint: '$K_a = \\tan^2(45\\degree - \\phi/2)$, then $P_a = 0.5 \\times K_a \\times \\gamma \\times H^2$.',
    steps: [
      {
        text: 'Active coefficient:',
        latex: 'K_a = \\tan^2(45\\degree - 15\\degree) = \\tan^2(30\\degree) = \\frac{1}{3}'
      },
      {
        text: 'Active force:',
        latex: 'P_a = \\frac{1}{2} \\times \\frac{1}{3} \\times 110 \\times 20^2 = \\frac{1}{2} \\times \\frac{1}{3} \\times 110 \\times 400 = 7{,}330 \\text{ lb/ft}'
      }
    ],
    handbookPage: 'p. 263',
    handbookFormula: 'P_a = \\frac{1}{2} K_a \\gamma H^2',
    videoUrl: null,
    traps: [
      'Forgetting the 1/2 factor for the triangular pressure distribution',
      'Using (45 + phi/2) instead of (45 - phi/2), which gives Kp instead of Ka'
    ],
    diagram: {
      component: 'RetainingWall',
      props: {
        height: 20,
        unit: 'ft'
      }
    },
    lessonId: 'lateral-earth-pressure',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-lep-ex3',
    type: 'conceptual',
    statement: 'A student computes $K_a = 2.5$ for a soil with $\\phi\' = 25\\degree$. Which statement identifies the error?',
    choices: [
      {
        id: 'c1',
        text: 'The student used degrees instead of radians in the calculator'
      },
      {
        id: 'c2',
        text: 'The formula was applied correctly; $K_a = 2.5$ is reasonable'
      },
      {
        id: 'c3',
        text: 'The student used $\\tan^2(45\\degree + \\phi/2)$ instead of $\\tan^2(45\\degree - \\phi/2)$, computing $K_p$ instead of $K_a$'
      },
      {
        id: 'c4',
        text: 'The student forgot to square the tangent term'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$K_a$ must always be less than 1 (active pressure is less than vertical stress). If $K_a = 2.5$, the student swapped the sign and computed $K_p$ instead. The correct $K_a = \\tan^2(45\\degree - 25\\degree/2) = \\tan^2(32.5\\degree) = 0.406$. Check: $K_a \\times K_p = 1$, so $K_p = 1/0.406 = 2.46 \\approx 2.5$. Choice B is wrong because $K_a > 1$ is physically impossible for cohesionless soil. Choice A is unlikely to produce exactly 2.5. Choice D: forgetting to square would give $\\tan(32.5\\degree) = 0.637$, not 2.5.',
    hint: 'Ka is always less than 1 and Kp is always greater than 1. If your Ka exceeds 1, you swapped the sign.',
    steps: [
      {
        text: 'Correct active coefficient:',
        latex: 'K_a = \\tan^2(45\\degree - 12.5\\degree) = \\tan^2(32.5\\degree) = 0.406'
      },
      {
        text: 'The student computed:',
        latex: 'K_p = \\tan^2(45\\degree + 12.5\\degree) = \\tan^2(57.5\\degree) = 2.46 \\approx 2.5'
      },
      {
        text: 'Sanity check: $K_a < 1 < K_p$ and $K_a \\times K_p = 1$.',
        latex: null
      }
    ],
    handbookPage: 'p. 263',
    handbookFormula: 'K_a = \\tan^2(45\\degree - \\phi/2), \\quad K_p = \\tan^2(45\\degree + \\phi/2)',
    videoUrl: null,
    traps: [
      'Swapping the + and - signs in the Rankine formulas -- always check that Ka < 1 and Kp > 1'
    ],
    diagram: null,
    lessonId: 'lateral-earth-pressure',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-lep-ex4',
    type: 'computational',
    statement: 'A normally consolidated soil has $\\phi\' = 30\\degree$. Compute both $K_a$ and $K_0$, and determine the ratio $K_0 / K_a$.',
    choices: [
      {
        id: 'c1',
        text: '$K_a = 0.333,\\; K_0 = 0.577,\\; K_0/K_a = 1.73$'
      },
      {
        id: 'c2',
        text: '$K_a = 0.500,\\; K_0 = 0.333,\\; K_0/K_a = 0.67$'
      },
      {
        id: 'c3',
        text: '$K_a = 0.333,\\; K_0 = 0.333,\\; K_0/K_a = 1.00$'
      },
      {
        id: 'c4',
        text: '$K_a = 0.333,\\; K_0 = 0.500,\\; K_0/K_a = 1.50$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: '$K_a = \\tan^2(45\\degree - 15\\degree) = \\tan^2(30\\degree) = 1/3 = 0.333$. $K_0 = 1 - \\sin(30\\degree) = 1 - 0.50 = 0.500$. Ratio $= 0.500/0.333 = 1.50$. This means a rigid wall ($K_0$) experiences 50% more force than a wall that can yield into the active condition ($K_a$). Choice B swaps $K_a$ and $K_0$. Choice C incorrectly assumes $K_0 = K_a$. Choice A uses $\\tan(30\\degree) = 0.577$ as $K_0$ instead of $1 - \\sin(30\\degree)$.',
    hint: '$K_a$ uses $\\tan^2(45\\degree - \\phi/2)$. $K_0$ uses $1 - \\sin(\\phi)$. Compute both and divide.',
    steps: [
      {
        text: 'Active coefficient:',
        latex: 'K_a = \\tan^2(45\\degree - 15\\degree) = \\frac{1}{3} = 0.333'
      },
      {
        text: 'At-rest coefficient (NC soil):',
        latex: 'K_0 = 1 - \\sin 30\\degree = 1 - 0.50 = 0.500'
      },
      {
        text: 'Ratio:',
        latex: '\\frac{K_0}{K_a} = \\frac{0.500}{0.333} = 1.50'
      }
    ],
    handbookPage: 'p. 263',
    handbookFormula: 'K_a = \\tan^2(45\\degree - \\phi/2), \\quad K_0 = 1 - \\sin \\phi',
    videoUrl: null,
    traps: [
      'Confusing the $K_0$ formula with $K_a$ -- $K_0 = 1 - \\sin(\\phi)$ is a separate relationship',
      'Using $\\tan(\\phi)$ instead of $\\sin(\\phi)$ in the $K_0$ formula'
    ],
    diagram: null,
    lessonId: 'lateral-earth-pressure',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-rw-ex1',
    type: 'computational',
    statement: 'A retaining wall has a total sliding resistance of $\\Sigma F_R = 6{,}000 \\text{ lb/ft}$ and the horizontal driving force is $\\Sigma F_D = 3{,}000 \\text{ lb/ft}$. What is the factor of safety against sliding?',
    choices: [
      {
        id: 'c1',
        text: '$2.0$'
      },
      {
        id: 'c2',
        text: '$0.50$'
      },
      {
        id: 'c3',
        text: '$3{,}000$'
      },
      {
        id: 'c4',
        text: '$1.0$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$FS_{sliding} = $ resisting forces / driving forces $= 6{,}000/3{,}000 = 2.0$. This is a direct ratio. Choice B (0.50) inverts the ratio (driving/resisting). Choice C (3,000) subtracts instead of dividing. Choice D (1.0) might come from thinking they are equal.',
    hint: 'FS(sliding) = sum of resisting forces / sum of driving forces.',
    steps: [
      {
        text: 'Factor of safety against sliding:',
        latex: 'FS = \\frac{\\Sigma F_R}{\\Sigma F_D} = \\frac{6{,}000}{3{,}000} = 2.0'
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: 'FS_{\\text{sliding}} = \\frac{\\Sigma F_R}{\\Sigma F_D}',
    videoUrl: null,
    traps: ['Inverting the ratio -- FS is always resisting/driving, not driving/resisting'],
    diagram: null,
    lessonId: 'retaining-walls',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-rw-ex2',
    type: 'conceptual',
    statement: 'For a gravity retaining wall, the resultant vertical force on the base has eccentricity $e = B/4$. What does this indicate about the base pressure distribution?',
    choices: [
      {
        id: 'c1',
        text: 'The resultant is within the middle third, producing a trapezoidal distribution'
      },
      {
        id: 'c2',
        text: 'The resultant is at the center of the base, producing uniform pressure'
      },
      {
        id: 'c3',
        text: 'The resultant falls outside the middle third ($e > B/6$), so tension develops at the heel and the trapezoidal formula does not apply'
      },
      {
        id: 'c4',
        text: 'The eccentricity has no effect on the pressure distribution'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The middle-third rule says the resultant must fall within $B/6$ of the center for the entire base to be in compression. Here $e = B/4 = 0.25B$, and $B/6 = 0.167B$. Since $0.25B > 0.167B$, the resultant is outside the middle third. This means the heel side has theoretical tension, but soil cannot take tension, so the actual pressure redistributes to a triangular distribution on the toe side only. Choice B applies when $e = 0$. Choice A applies when $e \\leq B/6$. Choice D is wrong because eccentricity directly controls pressure distribution.',
    hint: 'Compare e to B/6. If e > B/6, the resultant is outside the middle third.',
    steps: [
      {
        text: 'Middle third limit:',
        latex: '\\frac{B}{6} = 0.167B'
      },
      {
        text: 'Given eccentricity:',
        latex: 'e = \\frac{B}{4} = 0.250B > 0.167B'
      },
      {
        text: 'Result: outside the middle third -> tension at heel -> trapezoidal formula invalid.',
        latex: null
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: 'q_{\\text{toe}} = \\frac{\\Sigma V}{B}\\left(1 + \\frac{6e}{B}\\right)',
    videoUrl: null,
    traps: [
      'Applying the trapezoidal formula when $e > B/6$ -- the formula assumes no tension and is only valid for $e \\leq B/6$'
    ],
    diagram: null,
    lessonId: 'retaining-walls',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-rw-ex3',
    type: 'computational',
    statement: 'A retaining wall has $\\Sigma V = 10{,}000 \\text{ lb/ft}$, $B = 10 \\text{ ft}$, $\\Sigma M_R = 60{,}000 \\text{ lb-ft/ft}$, and $M_O = 20{,}000 \\text{ lb-ft/ft}$. What is the maximum toe pressure?',
    choices: [
      {
        id: 'c1',
        text: '$1{,}000 \\text{ psf}$'
      },
      {
        id: 'c2',
        text: '$1{,}600 \\text{ psf}$'
      },
      {
        id: 'c3',
        text: '$2{,}000 \\text{ psf}$'
      },
      {
        id: 'c4',
        text: '$4{,}000 \\text{ psf}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'First find where the resultant hits the base: $\\bar{x} = (M_R - M_O)/V = (60{,}000 - 20{,}000)/10{,}000 = 4.0$ ft from the toe. Eccentricity: $e = B/2 - \\bar{x} = 5.0 - 4.0 = 1.0$ ft. Check: $B/6 = 10/6 = 1.67$ ft, and $e = 1.0 < 1.67$, so the middle-third rule is satisfied. Toe pressure: $q_{toe} = (V/B)(1 + 6e/B) = (10{,}000/10)(1 + 6(1.0)/10) = 1{,}000(1 + 0.60) = 1{,}000 \\times 1.60 = 1{,}600$ psf. Choice A (1,000) ignores eccentricity. Choice C (2,000) uses $e = B/6 = 1.67$. Choice D (4,000) might use an incorrect formula.',
    hint: 'Find $\\bar{x}$, then $e = B/2 - \\bar{x}$, then $q_{toe} = (V/B)(1 + 6e/B)$.',
    steps: [
      {
        text: 'Location of resultant:',
        latex: '\\bar{x} = \\frac{60{,}000 - 20{,}000}{10{,}000} = 4.0 \\text{ ft from toe}'
      },
      {
        text: 'Eccentricity:',
        latex: 'e = 5.0 - 4.0 = 1.0 \\text{ ft}'
      },
      {
        text: 'Check: $e = 1.0 < B/6 = 1.67$ \\checkmark',
        latex: null
      },
      {
        text: 'Toe pressure:',
        latex: 'q_{\\text{toe}} = \\frac{10{,}000}{10}\\left(1 + \\frac{6 \\times 1.0}{10}\\right) = 1{,}000 \\times 1.60 = 1{,}600 \\text{ psf}'
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: 'q_{\\text{toe}} = \\frac{\\Sigma V}{B}\\left(1 + \\frac{6e}{B}\\right)',
    videoUrl: null,
    traps: [
      'Using $V/B$ as the final answer without accounting for eccentricity',
      'Confusing $\\bar{x}$ (distance from toe) with $e$ (distance from center)'
    ],
    diagram: {
      component: 'WallBase',
      props: {
        baseWidth: 10,
        unit: 'ft'
      }
    },
    lessonId: 'retaining-walls',
    chapterId: 'geotechnical'
  },
  {
    id: 'geo-rw-ex4',
    type: 'conceptual',
    statement: 'A gravity retaining wall has $FS_{\\text{overturning}} = 2.5$ and $FS_{\\text{sliding}} = 1.2$. The minimum required FS values are 2.0 for overturning and 1.5 for sliding. Which stability check controls the design?',
    choices: [
      {
        id: 'c1',
        text: 'Neither check controls because the wall passes overturning'
      },
      {
        id: 'c2',
        text: 'Overturning controls because it has the larger required FS'
      },
      {
        id: 'c3',
        text: 'Both checks pass because the actual FS values exceed 1.0'
      },
      {
        id: 'c4',
        text: 'Sliding controls -- $FS_{\\text{sliding}} = 1.2 < 1.5$ required, so the wall fails the sliding check even though overturning is adequate'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'You must check each failure mode against its own required FS. Overturning: $2.5 \\geq 2.0$, so it passes. Sliding: $1.2 < 1.5$, so it fails. Even though overturning is fine, the wall is inadequate because sliding does not meet the minimum FS. You could add a key (shear key) at the base or widen the footing to increase sliding resistance. Choice B ignores that each check has a different threshold. Choice C is wrong because $FS > 1.0$ is not sufficient -- each mode has a specific required FS. Choice A incorrectly assumes passing one check means the wall is stable overall.',
    hint: 'Compare each FS to its own minimum requirement. The wall is only adequate if ALL checks pass.',
    steps: [
      {
        text: 'Overturning check:',
        latex: 'FS_{\\text{ot}} = 2.5 \\geq 2.0 \\; \\checkmark'
      },
      {
        text: 'Sliding check:',
        latex: 'FS_{\\text{sl}} = 1.2 < 1.5 \\; \\times'
      },
      {
        text: 'Sliding governs -- the wall needs redesign to increase sliding resistance.',
        latex: null
      }
    ],
    handbookPage: 'p. 264',
    handbookFormula: 'FS_{\\text{sliding}} = \\frac{\\Sigma F_R}{\\Sigma F_D}',
    videoUrl: null,
    traps: [
      'Assuming FS > 1.0 is always sufficient -- each failure mode has its own minimum FS requirement',
      'Thinking that passing one stability check means the wall is safe overall'
    ],
    diagram: null,
    lessonId: 'retaining-walls',
    chapterId: 'geotechnical'
  },
];

export default PROBLEMS;
