export default {
  context: 'This chapter covers mechanical properties of materials, material testing methods, thermal and processing effects, concrete mix design and curing, composite materials, and corrosion — the core materials science topics tested on the FE Civil exam.',
  subtopics: [
    { id: 'mechanical-properties', name: 'Mechanical Properties & Testing',
      application: 'As a civil engineer, you interpret tensile test results to verify that steel meets specifications, check Brinell hardness to estimate tensile strength in the field, review Charpy impact data to ensure bridge steel won\'t become brittle in cold climates, and evaluate fracture toughness to assess crack tolerance. Understanding stress-strain behavior, thermal processing, and phase diagrams lets you predict how materials perform under real-world loading and environmental conditions.' },
    { id: 'concrete-technology', name: 'Concrete Technology',
      application: 'As a civil engineer, you specify and approve concrete mixes on nearly every project — setting the water-cement ratio for target strength, specifying air entrainment for freeze-thaw durability, evaluating 7-day and 28-day cylinder break results, and writing curing specifications. Getting these right is the difference between a durable structure and one that cracks, spalls, or fails to meet design strength.' },
    { id: 'composites-selection', name: 'Composites & Material Selection',
      application: 'As a civil engineer, you encounter composites in FRP bridge decks, carbon fiber wraps for column strengthening, and fiber-reinforced concrete. You also manage corrosion on every project with exposed metals — selecting coatings, specifying cathodic protection, and avoiding galvanic couples between dissimilar metals. The rule of mixtures lets you estimate composite properties, while the galvanic series guides material compatibility decisions.' },
  ],
  formulas: [
    { latex: '\\sigma = \\frac{F}{A_0}', label: 'Engineering Stress', page: 'p. 121' },
    { latex: '\\sigma = E\\varepsilon', label: 'Hooke\'s Law', page: 'p. 121' },
    { latex: 'TS \\text{ (MPa)} \\approx 3.45 \\times BHN', label: 'BHN\u2013Tensile Strength', page: 'p. 122' },
    { latex: 'K_{IC} = Y\\sigma\\sqrt{\\pi a}', label: 'Fracture Toughness', page: 'p. 122' },
    { latex: '\\Delta L = \\alpha L \\Delta T', label: 'Thermal Expansion', page: 'p. 126' },
    { latex: 'W/C = \\frac{\\text{weight of water}}{\\text{weight of cement}}', label: 'Water-Cement Ratio', page: 'p. 125' },
    { latex: 'E_c = f_1 E_1 + f_2 E_2', label: 'Rule of Mixtures (Modulus)', page: 'p. 123' },
  ],
  traps: [
    'Lower water-cement ratio means HIGHER strength \u2014 students often get this backwards.',
    'Confusing elastic modulus (stiffness) with strength (stress capacity) \u2014 they are independent properties.',
    'Forgetting that concrete is strong in compression but weak in tension \u2014 that\'s why we reinforce it.',
    'Using Y = 1.0 for edge cracks instead of Y = 1.1 in fracture toughness problems.',
    'Forgetting to convert crack length from mm to m in K_IC calculations \u2014 off by orders of magnitude.',
    'Swapping lever arms in the lever rule \u2014 the fraction of a phase uses the OPPOSITE arm.',
    'Confusing quenching (rapid cooling \u2192 martensite) with slow cooling (\u2192 ferrite + cementite).',
  ],
};
