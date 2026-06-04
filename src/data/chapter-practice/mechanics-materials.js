// Chapter practice: Mechanics of Materials (17 questions, 2 per lesson)

const PROBLEMS = [
  {
    id: 'mom-asd-cp1',
    type: 'computational',
    statement: 'A steel tie rod ($E = 200\\,\\text{GPa}$, yield strength $\\sigma_y = 250\\,\\text{MPa}$) must carry an axial tensile load of $80\\,\\text{kN}$ with a factor of safety of $2.5$ against yielding. What is the minimum required cross-sectional area?',
    choices: [
      { id: 'c1', text: '$320\\,\\text{mm}^2$' },
      { id: 'c2', text: '$800\\,\\text{mm}^2$' },
      { id: 'c3', text: '$128\\,\\text{mm}^2$' },
      { id: 'c4', text: '$200\\,\\text{mm}^2$' }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The allowable stress is the yield strength divided by the factor of safety: $\\sigma_{allow} = 250/2.5 = 100$ MPa. Then size the area so the working stress does not exceed it: $A = P/\\sigma_{allow} = 80{,}000/100 = 800$ mm$^2$. The 128 mm$^2$ option multiplies the yield strength by the factor of safety instead of dividing, giving an allowable of 625 MPa. The 320 mm$^2$ option uses the full $\\sigma_y = 250$ MPa with no factor of safety. The 200 mm$^2$ option divides by an allowable of 400 MPa, a mix-up of the numbers.',
    hint: 'First reduce the yield strength by the factor of safety to get the allowable stress, then use $A = P/\\sigma_{allow}$.',
    steps: [
      {
        text: 'Allowable stress:',
        latex: '\\sigma_{allow} = \\frac{\\sigma_y}{FS} = \\frac{250}{2.5} = 100\\,\\text{MPa}'
      },
      {
        text: 'Required area:',
        latex: 'A = \\frac{P}{\\sigma_{allow}} = \\frac{80{,}000}{100} = 800\\,\\text{mm}^2'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: '\\sigma_{allow} = \\frac{\\sigma_y}{FS}, \\quad A = \\frac{P}{\\sigma_{allow}}',
    videoUrl: null,
    traps: [
      'Multiplying the yield strength by the factor of safety instead of dividing',
      'Forgetting to apply the factor of safety and using the full yield strength'
    ],
    diagram: null,
    lessonId: 'axial-stress-strain-deformation',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-asd-cp2',
    type: 'computational',
    statement: 'A steel bar ($E = 200\\,\\text{GPa}$, coefficient of thermal expansion $\\alpha = 12 \\times 10^{-6}/{}^\\circ\\text{C}$) is fixed rigidly between two immovable walls with no initial stress. The temperature is then raised uniformly by $40\\,{}^\\circ\\text{C}$. What is the magnitude of the resulting (compressive) thermal stress in the bar?',
    choices: [
      { id: 'c1', text: '$48\\,\\text{MPa}$' },
      { id: 'c2', text: '$2.4\\,\\text{MPa}$' },
      { id: 'c3', text: '$96\\,\\text{MPa}$' },
      { id: 'c4', text: '$192\\,\\text{MPa}$' }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'When a bar is fully restrained, it cannot expand, so the walls develop just enough stress to cancel the free thermal strain $\\varepsilon_T = \\alpha\\,\\Delta T$. The induced stress is $\\sigma = E\\,\\alpha\\,\\Delta T$, independent of the length and area. $\\sigma = 200{,}000 \\times 12 \\times 10^{-6} \\times 40 = 96$ MPa (compression). The 2.4 MPa option drops the $\\Delta T$ factor, computing $E\\alpha$ only. The 48 MPa option uses half the temperature change ($20\\,{}^\\circ$C) by mistake. The 192 MPa option doubles the temperature change. Note the stress does not depend on the bar length because both ends are fully fixed.',
    hint: 'A fully restrained bar develops $\\sigma = E\\,\\alpha\\,\\Delta T$; length and area drop out.',
    steps: [
      {
        text: 'Free thermal strain if the bar were unrestrained:',
        latex: '\\varepsilon_T = \\alpha\\,\\Delta T = 12 \\times 10^{-6} \\times 40 = 4.8 \\times 10^{-4}'
      },
      {
        text: 'Full restraint forces an equal and opposite mechanical strain, giving:',
        latex: '\\sigma = E\\,\\alpha\\,\\Delta T = 200{,}000 \\times 12 \\times 10^{-6} \\times 40 = 96\\,\\text{MPa}'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: '\\sigma = E\\,\\alpha\\,\\Delta T',
    videoUrl: null,
    traps: [
      'Computing $E\\alpha$ but forgetting to multiply by the temperature change',
      'Assuming the thermal stress depends on the bar length or cross-sectional area'
    ],
    diagram: { component: 'ThermalBar', props: { length: 1, lengthUnit: 'm', gap: 0 } },
    lessonId: 'axial-stress-strain-deformation',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-tor-cp1',
    type: 'computational',
    statement: 'A solid circular shaft transmits a torque of $T = 1.2\\,\\text{kN}{\\cdot}\\text{m}$. If the allowable shear stress is $\\tau_{allow} = 60\\,\\text{MPa}$, what is the minimum required shaft diameter?',
    choices: [
      { id: 'c1', text: '$58.8\\,\\text{mm}$' },
      { id: 'c2', text: '$46.7\\,\\text{mm}$' },
      { id: 'c3', text: '$37.1\\,\\text{mm}$' },
      { id: 'c4', text: '$23.4\\,\\text{mm}$' }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'For a solid shaft, $\\tau = Tc/J = 16T/(\\pi d^3)$. Solve for $d$: $d = \\left(16T/(\\pi \\tau)\\right)^{1/3}$. With $T = 1{,}200{,}000$ N$\\cdot$mm and $\\tau = 60$ MPa: $d = \\left(16 \\times 1{,}200{,}000/(\\pi \\times 60)\\right)^{1/3} = (101{,}859)^{1/3} = 46.7$ mm. The 58.8 mm option uses $32T/(\\pi\\tau)$ under the cube root, doubling the coefficient (the $J$ value rather than $J/c$). The 37.1 mm option uses $8T/(\\pi\\tau)$, halving the coefficient. The 23.4 mm option solves for the radius and reports it as the diameter.',
    hint: 'Start from $\\tau = 16T/(\\pi d^3)$ for a solid shaft and solve for $d$.',
    steps: [
      {
        text: 'Solid-shaft shear stress in terms of diameter:',
        latex: '\\tau = \\frac{Tc}{J} = \\frac{16T}{\\pi d^3}'
      },
      {
        text: 'Solve for the diameter:',
        latex: 'd = \\left(\\frac{16T}{\\pi \\tau}\\right)^{1/3} = \\left(\\frac{16 \\times 1{,}200{,}000}{\\pi \\times 60}\\right)^{1/3}'
      },
      {
        text: 'Evaluate:',
        latex: 'd = (101{,}859)^{1/3} = 46.7\\,\\text{mm}'
      }
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\tau = \\frac{16T}{\\pi d^3}',
    videoUrl: null,
    traps: [
      'Using $32T/(\\pi\\tau)$ under the cube root instead of $16T/(\\pi\\tau)$',
      'Solving for the radius and reporting it as the diameter'
    ],
    diagram: null,
    lessonId: 'torsion',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-tor-cp2',
    type: 'conceptual',
    statement: 'A solid circular shaft of diameter $d$ is replaced by a hollow shaft of the same material and the same outer diameter $d$, with an inner diameter of $0.5d$. For the same applied torque, how does the maximum shear stress in the hollow shaft compare to that in the solid shaft?',
    choices: [
      { id: 'c1', text: 'It is about 6.7% higher' },
      { id: 'c2', text: 'It is exactly the same' },
      { id: 'c3', text: 'It is 50% higher' },
      { id: 'c4', text: 'It is about 6.7% lower' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Since $\\tau = Tc/J$ and both shafts have the same outer radius $c = d/2$ and the same $T$, the stress depends only on $J$. The hollow shaft has a smaller $J$ because material is removed from the core, so its stress is higher. $J_{solid} = \\pi d^4/32$ and $J_{hollow} = \\pi(d^4 - (0.5d)^4)/32 = \\pi d^4(1 - 0.0625)/32 = 0.9375\\,J_{solid}$. The stress ratio is $1/0.9375 = 1.067$, so about 6.7% higher. The "exactly the same" choice assumes removing core material near the axis does not matter -- it matters a little because $J$ drops slightly. The "50% higher" choice overestimates the effect. The "6.7% lower" choice has the direction backwards: removing material lowers $J$, which raises stress.',
    hint: 'Same $T$ and same outer $c$, so compare $J$. Removing the inner core lowers $J$, which raises the stress.',
    steps: [
      {
        text: 'Polar moments of inertia:',
        latex: 'J_{hollow} = \\frac{\\pi(d^4 - (0.5d)^4)}{32} = 0.9375\\,\\frac{\\pi d^4}{32} = 0.9375\\,J_{solid}'
      },
      {
        text: 'Stress ratio (same $T$ and $c$):',
        latex: '\\frac{\\tau_{hollow}}{\\tau_{solid}} = \\frac{J_{solid}}{J_{hollow}} = \\frac{1}{0.9375} = 1.067'
      },
      {
        text: 'The hollow shaft stress is about 6.7% higher.',
        latex: null
      }
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\tau = \\frac{Tc}{J}, \\quad J = \\frac{\\pi(d_o^4 - d_i^4)}{32}',
    videoUrl: null,
    traps: [
      'Assuming material near the axis carries no torque, so removing it changes nothing',
      'Getting the direction backwards -- a smaller $J$ raises stress, not lowers it'
    ],
    diagram: null,
    lessonId: 'torsion',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-ssd-cp1',
    type: 'computational',
    statement: 'A round aluminum bar ($E = 70\\,\\text{GPa}$, $\\nu = 0.33$) with an original diameter of $25\\,\\text{mm}$ carries an axial tensile stress of $140\\,\\text{MPa}$. What is the decrease in diameter caused by the lateral (Poisson) contraction?',
    choices: [
      { id: 'c1', text: '$0.0500\\,\\text{mm}$' },
      { id: 'c2', text: '$0.0066\\,\\text{mm}$' },
      { id: 'c3', text: '$0.0606\\,\\text{mm}$' },
      { id: 'c4', text: '$0.0165\\,\\text{mm}$' }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Axial strain comes first: $\\varepsilon_{axial} = \\sigma/E = 140/70{,}000 = 0.0020$. The lateral strain is $\\varepsilon_{lat} = -\\nu\\,\\varepsilon_{axial} = -0.33 \\times 0.0020 = -0.00066$. The diameter change is $\\Delta d = \\varepsilon_{lat} \\times d = -0.00066 \\times 25 = -0.0165$ mm (a decrease). The 0.0066 mm option reports the lateral strain times 10, forgetting to multiply by the full diameter. The 0.0500 mm option applies the axial strain to the diameter without the Poisson factor. The 0.0606 mm option divides by $\\nu$ instead of multiplying.',
    hint: 'Find the axial strain $\\sigma/E$, multiply by $-\\nu$ for lateral strain, then multiply by the diameter.',
    steps: [
      {
        text: 'Axial strain:',
        latex: '\\varepsilon_{axial} = \\frac{\\sigma}{E} = \\frac{140}{70{,}000} = 0.0020'
      },
      {
        text: 'Lateral strain:',
        latex: '\\varepsilon_{lat} = -\\nu\\,\\varepsilon_{axial} = -0.33 \\times 0.0020 = -0.00066'
      },
      {
        text: 'Diameter decrease:',
        latex: '\\Delta d = \\varepsilon_{lat}\\,d = 0.00066 \\times 25 = 0.0165\\,\\text{mm}'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: '\\nu = -\\frac{\\varepsilon_{lat}}{\\varepsilon_{axial}}',
    videoUrl: null,
    traps: [
      'Forgetting to multiply the lateral strain by the original diameter',
      'Omitting the Poisson ratio and applying the axial strain directly to the diameter'
    ],
    diagram: null,
    lessonId: 'stress-strain-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-ssd-cp2',
    type: 'computational',
    statement: 'A steel with a modulus of elasticity $E = 200\\,\\text{GPa}$ has a proportional limit of $300\\,\\text{MPa}$. Assuming linear-elastic behavior up to the proportional limit, what is the modulus of resilience (the strain energy per unit volume stored up to the proportional limit)?',
    choices: [
      { id: 'c1', text: '$0.450\\,\\text{MJ/m}^3$' },
      { id: 'c2', text: '$0.225\\,\\text{MJ/m}^3$' },
      { id: 'c3', text: '$1.50\\,\\text{MJ/m}^3$' },
      { id: 'c4', text: '$0.150\\,\\text{MJ/m}^3$' }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The modulus of resilience is the area under the linear part of the stress-strain curve, a triangle: $u_r = \\sigma_{pl}^2/(2E)$. With $\\sigma_{pl} = 300$ MPa and $E = 200{,}000$ MPa: $u_r = 300^2/(2 \\times 200{,}000) = 90{,}000/400{,}000 = 0.225$ MPa $= 0.225$ MJ/m$^3$ (since 1 MPa equals 1 MJ/m$^3$). The 0.450 MJ/m^3 choice forgets the factor of one-half for the triangular area. The 0.150 MJ/m^3 choice uses $\\sigma^2/(3E)$. The 1.50 MJ/m^3 choice treats the strain energy as $\\sigma \\times \\varepsilon$ at the limit without the one-half factor and with a unit slip.',
    hint: 'Modulus of resilience is the triangular area under the elastic line: $u_r = \\sigma^2/(2E)$.',
    steps: [
      {
        text: 'Modulus of resilience (triangular elastic area):',
        latex: 'u_r = \\frac{\\sigma_{pl}^2}{2E} = \\frac{300^2}{2 \\times 200{,}000}'
      },
      {
        text: 'Evaluate (1 MPa equals 1 MJ per cubic metre):',
        latex: 'u_r = \\frac{90{,}000}{400{,}000} = 0.225\\,\\text{MPa} = 0.225\\,\\text{MJ/m}^3'
      }
    ],
    handbookPage: 'p. 129',
    handbookFormula: 'u_r = \\frac{\\sigma_{pl}^2}{2E}',
    videoUrl: null,
    traps: [
      'Forgetting the factor of one-half for the triangular area under the elastic line',
      'Forgetting to square the stress in the numerator'
    ],
    diagram: null,
    lessonId: 'stress-strain-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-smd-cp1',
    type: 'computational',
    statement: 'A cantilever beam of length $4\\,\\text{m}$ carries a uniform distributed load of $w = 9\\,\\text{kN/m}$ over its entire span. What is the maximum bending moment at the fixed support?',
    choices: [
      { id: 'c1', text: '$72\\,\\text{kN}{\\cdot}\\text{m}$' },
      { id: 'c2', text: '$36\\,\\text{kN}{\\cdot}\\text{m}$' },
      { id: 'c3', text: '$18\\,\\text{kN}{\\cdot}\\text{m}$' },
      { id: 'c4', text: '$144\\,\\text{kN}{\\cdot}\\text{m}$' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'For a cantilever with a UDL over its full length, the maximum moment is at the fixed support and equals $wL^2/2 = 9 \\times 4^2/2 = 9 \\times 16/2 = 72$ kN$\\cdot$m. You can also picture the total load $wL = 36$ kN acting at the centroid $L/2 = 2$ m from the wall: $M = 36 \\times 2 = 72$. The 36 kN$\\cdot$m option uses $wL^2/4$, the wrong coefficient. The 18 kN$\\cdot$m option uses the simply supported $wL^2/8$ formula -- wrong support condition. The 144 kN$\\cdot$m option uses $wL^2$ without the factor of one-half.',
    hint: 'For a cantilever with a UDL, the fixed-end moment is $wL^2/2$, not $wL^2/8$.',
    steps: [
      {
        text: 'Maximum moment at the fixed support:',
        latex: 'M_{max} = \\frac{wL^2}{2} = \\frac{9 \\times 4^2}{2} = 72\\,\\text{kN}{\\cdot}\\text{m}'
      },
      {
        text: 'Check by resultant: total load $wL = 36$ kN at $L/2 = 2$ m gives $36 \\times 2 = 72$ kN$\\cdot$m.',
        latex: null
      }
    ],
    handbookPage: 'p. 140',
    handbookFormula: 'M_{max} = \\frac{wL^2}{2} \\text{ (cantilever, full UDL)}',
    videoUrl: null,
    traps: [
      'Using the simply supported formula $wL^2/8$ for a cantilever',
      'Dropping the factor of one-half and using $wL^2$'
    ],
    diagram: {
      component: 'CantileverBeam',
      props: {
        length: 4,
        loadIntensity: 9
      }
    },
    lessonId: 'shear-moment-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-smd-cp2',
    type: 'computational',
    statement: 'A simply supported beam of length $6\\,\\text{m}$ carries a uniform distributed load of $w = 8\\,\\text{kN/m}$ over only the left half of the span (from the left support to midspan). What is the left support reaction?',
    choices: [
      { id: 'c1', text: '$12\\,\\text{kN}$' },
      { id: 'c2', text: '$24\\,\\text{kN}$' },
      { id: 'c3', text: '$6\\,\\text{kN}$' },
      { id: 'c4', text: '$18\\,\\text{kN}$' }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'The total load is $w \\times (L/2) = 8 \\times 3 = 24$ kN, and its resultant acts at the centroid of the loaded region, $1.5$ m from the left support. Take moments about the right support (B) to find the left reaction $R_A$: the resultant is $6 - 1.5 = 4.5$ m from B, so $R_A \\times 6 = 24 \\times 4.5 = 108$, giving $R_A = 18$ kN. The 12 kN choice splits the total load evenly ($24/2$), ignoring that the load is closer to A. The 24 kN choice reports the entire load as the reaction. The 6 kN choice is the right reaction $R_B = 24 - 18 = 6$ kN, the other support.',
    hint: 'Replace the partial UDL with its resultant ($w \\times L/2$) at its centroid, then sum moments about the far support.',
    steps: [
      {
        text: 'Resultant of the partial load:',
        latex: 'W = w \\cdot \\frac{L}{2} = 8 \\times 3 = 24\\,\\text{kN at } 1.5\\,\\text{m from A}'
      },
      {
        text: 'Sum moments about B (resultant is $4.5$ m from B):',
        latex: 'R_A \\times 6 = 24 \\times 4.5 = 108'
      },
      {
        text: 'Solve for the left reaction:',
        latex: 'R_A = \\frac{108}{6} = 18\\,\\text{kN}'
      }
    ],
    handbookPage: 'p. 134',
    handbookFormula: '\\sum M = 0, \\quad W = w \\cdot L_{loaded}',
    videoUrl: null,
    traps: [
      'Splitting the total load equally between the supports when the load is not symmetric',
      'Reporting the far (right) reaction instead of the requested left reaction'
    ],
    diagram: null,
    lessonId: 'shear-moment-diagrams',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bss-cp1',
    type: 'computational',
    statement: 'A simply supported timber beam carries loads that produce a maximum bending moment of $M = 24\\,\\text{kN}{\\cdot}\\text{m}$. If the allowable bending stress is $\\sigma_{allow} = 12\\,\\text{MPa}$, what is the minimum required section modulus?',
    choices: [
      { id: 'c1', text: '$0.5 \\times 10^6\\,\\text{mm}^3$' },
      { id: 'c2', text: '$288 \\times 10^6\\,\\text{mm}^3$' },
      { id: 'c3', text: '$1.0 \\times 10^6\\,\\text{mm}^3$' },
      { id: 'c4', text: '$2.0 \\times 10^6\\,\\text{mm}^3$' }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Rearrange $\\sigma = M/S$ to $S = M/\\sigma_{allow}$. Convert the moment: $M = 24 \\times 10^6$ N$\\cdot$mm. Then $S = 24 \\times 10^6 / 12 = 2.0 \\times 10^6$ mm$^3$. The 288 million choice multiplies $M \\times \\sigma$ instead of dividing. The 0.5 million choice divides by 48 (mixing in some other factor). The 1.0 million choice divides by 24 MPa, doubling the allowable stress by mistake.',
    hint: 'Rearrange $\\sigma = M/S$ to solve for $S$, and convert kN-m to N-mm first.',
    steps: [
      {
        text: 'Convert moment: $M = 24\\,\\text{kN}{\\cdot}\\text{m} = 24 \\times 10^6\\,\\text{N}{\\cdot}\\text{mm}$.',
        latex: null
      },
      {
        text: 'Required section modulus:',
        latex: 'S = \\frac{M}{\\sigma_{allow}} = \\frac{24 \\times 10^6}{12} = 2.0 \\times 10^6\\,\\text{mm}^3'
      }
    ],
    handbookPage: 'p. 135',
    handbookFormula: 'S = \\frac{M}{\\sigma_{allow}}',
    videoUrl: null,
    traps: [
      'Multiplying moment by allowable stress instead of dividing',
      'Forgetting to convert the moment from kN-m to N-mm'
    ],
    diagram: null,
    lessonId: 'bending-shear-stresses',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bss-cp2',
    type: 'computational',
    statement: 'A solid circular shaft used as a beam has a diameter of $80\\,\\text{mm}$ and carries a maximum bending moment of $M = 3\\,\\text{kN}{\\cdot}\\text{m}$. What is the maximum bending stress?',
    choices: [
      { id: 'c1', text: '$29.8\\,\\text{MPa}$' },
      { id: 'c2', text: '$59.7\\,\\text{MPa}$' },
      { id: 'c3', text: '$119\\,\\text{MPa}$' },
      { id: 'c4', text: '$74.6\\,\\text{MPa}$' }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'For a solid circle, the section modulus is $S = \\pi d^3/32 = \\pi(80)^3/32 = 50{,}265$ mm$^3$. Then $\\sigma = M/S = 3{,}000{,}000/50{,}265 = 59.7$ MPa. The 29.8 MPa choice uses $S = \\pi d^3/16$ (the torsion-style modulus with $J$, doubling $S$ and halving the stress). The 119 MPa choice uses $c = d = 80$ instead of $c = d/2 = 40$, doubling the stress. The 74.6 MPa choice uses $S = \\pi d^3/40$ from a memory slip on the coefficient.',
    hint: 'For a solid circular section, the bending section modulus is $S = \\pi d^3/32$. Then $\\sigma = M/S$.',
    steps: [
      {
        text: 'Section modulus of a solid circle:',
        latex: 'S = \\frac{\\pi d^3}{32} = \\frac{\\pi (80)^3}{32} = 50{,}265\\,\\text{mm}^3'
      },
      {
        text: 'Convert moment: $M = 3 \\times 10^6$ N$\\cdot$mm.',
        latex: null
      },
      {
        text: 'Maximum bending stress:',
        latex: '\\sigma = \\frac{M}{S} = \\frac{3 \\times 10^6}{50{,}265} = 59.7\\,\\text{MPa}'
      }
    ],
    handbookPage: 'p. 135',
    handbookFormula: 'S = \\frac{\\pi d^3}{32}, \\quad \\sigma = \\frac{M}{S}',
    videoUrl: null,
    traps: [
      'Using the polar (torsion) modulus $\\pi d^3/16$ instead of the bending modulus $\\pi d^3/32$',
      'Using $c = d$ instead of $c = d/2$ for the extreme fibre distance'
    ],
    diagram: null,
    lessonId: 'bending-shear-stresses',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bd-cp1',
    type: 'computational',
    statement: 'A simply supported steel beam ($E = 200\\,\\text{GPa}$) has a span of $6\\,\\text{m}$ and carries a concentrated load of $P = 30\\,\\text{kN}$ at midspan. The deflection at midspan must not exceed $L/360$. What is the minimum moment of inertia $I$ required?',
    choices: [
      { id: 'c1', text: '$648 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c2', text: '$20.3 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c3', text: '$40.5 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c4', text: '$81.0 \\times 10^6\\,\\text{mm}^4$' }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The deflection limit is $\\delta_{allow} = L/360 = 6{,}000/360 = 16.67$ mm. The midspan deflection for a central point load is $\\delta = PL^3/(48EI)$, so $I = PL^3/(48E\\,\\delta_{allow})$. With $P = 30{,}000$ N, $L = 6{,}000$ mm, $E = 200{,}000$ MPa: $I = 30{,}000 \\times 6{,}000^3/(48 \\times 200{,}000 \\times 16.67) = 6.48 \\times 10^{15}/1.60 \\times 10^8 = 40.5 \\times 10^6$ mm$^4$. The 648 option uses the cantilever formula $PL^3/(3EI)$ instead of $PL^3/(48EI)$ -- a factor of 16 too large. The 20.3 option uses a coefficient of 96 in the denominator (doubling 48) -- the same value you would also get from a looser $L/180$ limit. The 81.0 option uses a coefficient of 24 in the denominator instead of 48 (equivalently a tighter $L/720$ limit), doubling the required $I$.',
    hint: 'Set $\\delta = PL^3/(48EI)$ equal to $L/360$ and solve for $I$.',
    steps: [
      {
        text: 'Allowable deflection:',
        latex: '\\delta_{allow} = \\frac{L}{360} = \\frac{6{,}000}{360} = 16.67\\,\\text{mm}'
      },
      {
        text: 'Rearrange the midspan point-load deflection formula:',
        latex: 'I = \\frac{PL^3}{48E\\,\\delta_{allow}} = \\frac{30{,}000 \\times (6{,}000)^3}{48 \\times 200{,}000 \\times 16.67}'
      },
      {
        text: 'Evaluate:',
        latex: 'I = \\frac{6.48 \\times 10^{15}}{1.60 \\times 10^8} = 40.5 \\times 10^6\\,\\text{mm}^4'
      }
    ],
    handbookPage: 'p. 140',
    handbookFormula: '\\delta = \\frac{PL^3}{48EI}',
    videoUrl: null,
    traps: [
      'Using the cantilever formula $PL^3/(3EI)$ for a simply supported beam',
      'Using the wrong deflection coefficient (for example 24 instead of 48 in the denominator)'
    ],
    diagram: {
      component: 'SimplySupportedBeam',
      props: {
        span: 6,
        loadPos: 3,
        load: 30
      }
    },
    lessonId: 'beam-deflections',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-bd-cp2',
    type: 'conceptual',
    statement: 'A cantilever beam carries a concentrated load $P$ at its free end. A second identical cantilever (same $P$, $E$, $I$) is built half as long. Compared with the original, the tip deflection of the shorter cantilever is:',
    choices: [
      { id: 'c1', text: 'one-half as large' },
      { id: 'c2', text: 'one-quarter as large' },
      { id: 'c3', text: 'one-eighth as large' },
      { id: 'c4', text: 'one-sixteenth as large' }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The tip deflection of a cantilever with an end load is $\\delta = PL^3/(3EI)$, proportional to $L^3$. Halving the length scales the deflection by $(1/2)^3 = 1/8$. The "one-half" choice counts only $L$ to the first power. The "one-quarter" choice treats it as $L^2$. The "one-sixteenth" choice uses the UDL fourth-power dependence ($\\delta = wL^4/(8EI)$), but this is a point load, so the exponent is 3, not 4.',
    hint: 'The cantilever tip deflection for an end point load goes as $L^3$. What is $(1/2)^3$?',
    steps: [
      {
        text: 'Cantilever tip deflection (end point load):',
        latex: '\\delta = \\frac{PL^3}{3EI} \\propto L^3'
      },
      {
        text: 'Halving the length:',
        latex: '\\frac{\\delta_{short}}{\\delta_{long}} = \\left(\\frac{1}{2}\\right)^3 = \\frac{1}{8}'
      }
    ],
    handbookPage: 'p. 141',
    handbookFormula: '\\delta = \\frac{PL^3}{3EI}',
    videoUrl: null,
    traps: [
      'Confusing the $L^3$ point-load dependence with the $L^4$ UDL dependence',
      'Scaling deflection linearly with length instead of with the cube'
    ],
    diagram: null,
    lessonId: 'beam-deflections',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-csm-cp1',
    type: 'computational',
    statement: 'A stress element has $\\sigma_x = 40\\,\\text{MPa}$, $\\sigma_y = 0$, and $\\tau_{xy} = 30\\,\\text{MPa}$. What is the orientation angle $\\theta_p$ (measured counterclockwise from the x-axis) to the plane of the maximum principal stress?',
    choices: [
      { id: 'c1', text: '$56.3\\degree$' },
      { id: 'c2', text: '$14.1\\degree$' },
      { id: 'c3', text: '$28.2\\degree$' },
      { id: 'c4', text: '$33.7\\degree$' }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The principal angle satisfies $\\tan(2\\theta_p) = 2\\tau_{xy}/(\\sigma_x - \\sigma_y) = 2(30)/(40 - 0) = 60/40 = 1.5$. So $2\\theta_p = \\arctan(1.5) = 56.3\\degree$, and $\\theta_p = 28.2\\degree$. The 56.3 choice reports $2\\theta_p$ without halving it. The 14.1 choice halves twice (divides $2\\theta_p$ by 4). The 33.7 choice forgets the factor of 2 on $\\tau_{xy}$, using $\\tan(2\\theta_p) = \\tau_{xy}/(\\sigma_x - \\sigma_y) = 0.75$.',
    hint: 'Use $\\tan(2\\theta_p) = 2\\tau_{xy}/(\\sigma_x - \\sigma_y)$, then remember to divide the result by 2.',
    steps: [
      {
        text: 'Apply the principal-angle formula:',
        latex: '\\tan(2\\theta_p) = \\frac{2\\tau_{xy}}{\\sigma_x - \\sigma_y} = \\frac{2(30)}{40 - 0} = 1.5'
      },
      {
        text: 'Take the inverse tangent:',
        latex: '2\\theta_p = \\arctan(1.5) = 56.3\\degree'
      },
      {
        text: 'Halve to get the physical angle:',
        latex: '\\theta_p = 28.2\\degree'
      }
    ],
    handbookPage: 'p. 131',
    handbookFormula: '\\tan(2\\theta_p) = \\frac{2\\tau_{xy}}{\\sigma_x - \\sigma_y}',
    videoUrl: null,
    traps: [
      'Reporting $2\\theta_p$ instead of $\\theta_p$ -- forgetting to divide by 2',
      'Omitting the factor of 2 on the shear stress in the numerator'
    ],
    diagram: {
      component: 'StressElement',
      props: {
        sigmaX: 40,
        sigmaY: 0,
        tauXY: 30
      }
    },
    lessonId: 'combined-stresses-mohrs-circle',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-csm-cp2',
    type: 'computational',
    statement: 'A thin-walled cylindrical pressure vessel has an internal pressure $p = 2\\,\\text{MPa}$, an inner diameter $d = 1.5\\,\\text{m}$, and a wall thickness $t = 10\\,\\text{mm}$. What is the hoop (circumferential) stress in the wall?',
    choices: [
      { id: 'c1', text: '$75\\,\\text{MPa}$' },
      { id: 'c2', text: '$300\\,\\text{MPa}$' },
      { id: 'c3', text: '$37.5\\,\\text{MPa}$' },
      { id: 'c4', text: '$150\\,\\text{MPa}$' }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'For a thin-walled cylinder, the hoop stress is $\\sigma_h = pd/(2t)$, where $d$ is the inner diameter. $\\sigma_h = 2 \\times 1{,}500/(2 \\times 10) = 3{,}000/20 = 150$ MPa. The 75 MPa option is the longitudinal (axial) stress $pd/(4t)$ -- half the hoop stress, but the question asks for hoop. The 300 MPa option forgets the 2 in the denominator, using $pd/t$. The 37.5 MPa option uses $pd/(8t)$ from a coefficient slip.',
    hint: 'Hoop stress in a thin cylinder is $\\sigma_h = pd/(2t)$; the longitudinal stress is half of that.',
    steps: [
      {
        text: 'Convert diameter: $d = 1.5\\,\\text{m} = 1{,}500\\,\\text{mm}$.',
        latex: null
      },
      {
        text: 'Hoop stress:',
        latex: '\\sigma_h = \\frac{pd}{2t} = \\frac{2 \\times 1{,}500}{2 \\times 10} = 150\\,\\text{MPa}'
      }
    ],
    handbookPage: 'p. 131',
    handbookFormula: '\\sigma_h = \\frac{pd}{2t}',
    videoUrl: null,
    traps: [
      'Reporting the longitudinal stress $pd/(4t)$ instead of the hoop stress',
      'Dropping the factor of 2 in the denominator and using $pd/t$'
    ],
    diagram: null,
    lessonId: 'combined-stresses-mohrs-circle',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-cb-cp1',
    type: 'computational',
    statement: 'A pinned-pinned steel column ($E = 200\\,\\text{GPa}$, $K = 1.0$) is $5\\,\\text{m}$ long and must support a critical buckling load of at least $P_{cr} = 400\\,\\text{kN}$. What is the minimum required moment of inertia $I$?',
    choices: [
      { id: 'c1', text: '$2.53 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c2', text: '$5.07 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c3', text: '$20.3 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c4', text: '$1.01 \\times 10^6\\,\\text{mm}^4$' }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Rearrange Euler\'s formula $P_{cr} = \\pi^2 EI/(KL)^2$ to solve for $I$: $I = P_{cr}(KL)^2/(\\pi^2 E)$. With $KL = 1.0 \\times 5{,}000 = 5{,}000$ mm, $P_{cr} = 400{,}000$ N, $E = 200{,}000$ MPa: $I = 400{,}000 \\times 5{,}000^2/(\\pi^2 \\times 200{,}000) = 1.0 \\times 10^{13}/1.974 \\times 10^6 = 5.07 \\times 10^6$ mm$^4$. The $2.53 \\times 10^6$ choice halves the result by using $K = 0.5$ in error. The $20.3 \\times 10^6$ choice uses $K = 2.0$, quadrupling the result. The $1.01 \\times 10^6$ choice underestimates by mishandling the squared effective length.',
    hint: 'Rearrange $P_{cr} = \\pi^2 EI/(KL)^2$ to solve for $I = P_{cr}(KL)^2/(\\pi^2 E)$.',
    steps: [
      {
        text: 'Effective length: $KL = 1.0 \\times 5{,}000 = 5{,}000$ mm.',
        latex: null
      },
      {
        text: 'Solve Euler\'s formula for $I$:',
        latex: 'I = \\frac{P_{cr}(KL)^2}{\\pi^2 E} = \\frac{400{,}000 \\times (5{,}000)^2}{\\pi^2 \\times 200{,}000}'
      },
      {
        text: 'Evaluate:',
        latex: 'I = \\frac{1.0 \\times 10^{13}}{1.974 \\times 10^6} = 5.07 \\times 10^6\\,\\text{mm}^4'
      }
    ],
    handbookPage: 'p. 136',
    handbookFormula: 'P_{cr} = \\frac{\\pi^2 EI}{(KL)^2}',
    videoUrl: null,
    traps: [
      'Forgetting the $\\pi^2$ term in the denominator',
      'Not squaring the effective length $KL$'
    ],
    diagram: { component: 'ColumnSupports', props: { length: 5, topCondition: 'pin', bottomCondition: 'pin' } },
    lessonId: 'column-buckling',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-cb-cp2',
    type: 'computational',
    statement: 'A column has a minimum moment of inertia $I_{min} = 8 \\times 10^6\\,\\text{mm}^4$ and a cross-sectional area $A = 3{,}200\\,\\text{mm}^2$. What is the minimum radius of gyration?',
    choices: [
      { id: 'c1', text: '$2{,}500\\,\\text{mm}$' },
      { id: 'c2', text: '$25\\,\\text{mm}$' },
      { id: 'c3', text: '$70.7\\,\\text{mm}$' },
      { id: 'c4', text: '$50\\,\\text{mm}$' }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'The radius of gyration is $r = \\sqrt{I/A} = \\sqrt{8 \\times 10^6 / 3{,}200} = \\sqrt{2{,}500} = 50$ mm. The 2,500 mm choice reports $I/A$ without taking the square root. The 25 mm choice takes the square root but then halves it. The 70.7 mm choice uses $\\sqrt{2 I/A}$, slipping in an extra factor of 2.',
    hint: 'The radius of gyration is $r = \\sqrt{I/A}$.',
    steps: [
      {
        text: 'Apply the definition:',
        latex: 'r = \\sqrt{\\frac{I}{A}} = \\sqrt{\\frac{8 \\times 10^6}{3{,}200}} = \\sqrt{2{,}500} = 50\\,\\text{mm}'
      }
    ],
    handbookPage: 'p. 136',
    handbookFormula: 'r = \\sqrt{\\frac{I}{A}}',
    videoUrl: null,
    traps: [
      'Reporting $I/A$ without taking the square root',
      'Confusing the radius of gyration with the actual cross-section radius'
    ],
    diagram: null,
    lessonId: 'column-buckling',
    chapterId: 'mechanics-materials'
  },
  {
    id: 'mom-tsp-cp1',
    type: 'computational',
    statement: 'A beam cross section has plastic section modulus $Z = 120\\text{ in}^3$ and elastic section modulus $S = 100\\text{ in}^3$. What is its shape factor?',
    choices: [
      { id: 'c1', text: '$1.20$' },
      { id: 'c2', text: '$0.83$' },
      { id: 'c3', text: '$20$' },
      { id: 'c4', text: '$1.00$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Shape factor = Z/S = 120/100 = 1.20 — the reserve strength between first yield and full plastic moment. The 0.83 choice inverts the ratio (S/Z). The 20 choice is the difference (Z - S). The 1.00 choice would mean no plastic reserve.',
    hint: 'Shape factor = plastic section modulus / elastic section modulus = Z/S.',
    steps: [
      { text: 'Shape factor:', latex: '\\frac{Z}{S} = \\frac{120}{100} = 1.20' },
    ],
    handbookPage: 'p. 281',
    handbookFormula: 'SF = Z/S',
    videoUrl: null,
    traps: ['Inverting to S/Z', 'Confusing the shape factor with the section modulus itself'],
    diagram: null,
    lessonId: 'transformed-sections-plastic',
    chapterId: 'mechanics-materials'
  }
];

export default PROBLEMS;
