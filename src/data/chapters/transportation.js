export default {
  context: 'This chapter covers highway geometric design, traffic engineering, pavement design, and earthwork calculations.',
  subtopics: [
    { id: 'geometric-design', name: 'Geometric Design',
      application: 'As a civil engineer, you design roads that let drivers see far enough to stop safely, transition smoothly between grades on vertical curves, and navigate horizontal curves at the design speed with proper superelevation. These geometric elements control safety, cost, and right-of-way requirements.' },
    { id: 'traffic-engineering', name: 'Traffic Engineering',
      application: 'As a civil engineer, you time traffic signals to balance safety and efficiency, analyze traffic flow using the Greenshields model, evaluate freeway capacity and level of service, and measure crash rates to compare safety performance across locations.' },
    { id: 'pavement-earthwork', name: 'Pavement Design & Earthwork',
      application: 'As a civil engineer, you design flexible pavement sections using the AASHTO structural number equation, convert mixed axle loads to ESALs, and compute earthwork volumes between cross sections to estimate cut-and-fill quantities for highway construction.' },
  ],
  formulas: [
    { latex: 'SSD = 1.47 V t + \\frac{V^2}{30\\left(\\frac{a}{32.2} \\pm G\\right)}', label: 'Stopping Sight Distance', page: 'p. 300' },
    { latex: 'L = \\frac{A S^2}{2{,}158}', label: 'Crest Vertical Curve (S \u2264 L)', page: 'p. 302' },
    { latex: 'R = \\frac{5{,}729.58}{D}', label: 'Horizontal Curve Radius', page: 'p. 302' },
    { latex: 'y = t + \\frac{v}{2a \\pm 64.4G}', label: 'Yellow Signal Interval', page: 'p. 300' },
    { latex: 'V_m = \\frac{D_j S_f}{4}', label: 'Maximum Flow (Greenshields)', page: 'p. 306' },
    { latex: 'v_p = \\frac{V}{PHF \\times N \\times f_{HV}}', label: 'Demand Flow Rate', page: 'p. 305' },
    { latex: 'SN = a_1 D_1 + a_2 D_2 m_2 + a_3 D_3 m_3', label: 'AASHTO Structural Number', page: 'p. 308' },
    { latex: 'V = \\frac{L(A_1 + A_2)}{2}', label: 'Average End Area Volume', page: 'p. 309' },
  ],
  traps: [
    'SSD grade sign: uphill (+G) = shorter SSD, downhill (\u2212G) = longer SSD. Students often reverse this.',
    'Crest vs. sag vertical curve formulas have different denominators \u2014 2,158 for crest, (400 + 3.5S) for sag.',
    'Yellow interval uses v in ft/sec, not mph \u2014 multiply mph by 1.467 to convert.',
    'LOS is determined by DENSITY, not by volume or speed. Compute D = vp/S first.',
    'Average end area always overestimates compared to prismoidal \u2014 don\'t confuse the two.',
  ],
};
