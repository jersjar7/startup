// Plain-language guide to the formulas on the FE Civil Materials page,
// in the same order as chapters/materials.js. Symbols checked against the FE
// Reference Handbook 10.5. The aggregate, asphalt and wood entries are not in
// the handbook; they follow the standard ASTM/AASHTO definitions.
export default [
  {
    label: 'Engineering Stress',
    aliases: ['engineering stress', 'tensile test', 'original area', 'f over a0'],
    use: 'Stress from a tension test, using the specimen area before it was loaded.',
    symbols: [
      { tex: '\\sigma', means: 'engineering stress', units: 'psi or ksi, MPa' },
      { tex: 'F', means: 'applied force', units: 'lb or kips, N or kN' },
      { tex: 'A_0', means: 'original (initial) cross-sectional area of the specimen', units: 'in² or mm²' },
    ],
    trap: 'Use the original area; dividing by the shrunken (necked) area gives true stress, which is larger.',
  },
  {
    label: "Hooke's Law",
    aliases: ['hookes law', 'modulus of elasticity', 'youngs modulus', 'stress strain'],
    use: 'Link stress and strain while the material is still elastic (below the proportional limit).',
    symbols: [
      { tex: '\\sigma', means: 'normal stress', units: 'psi or ksi, MPa' },
      { tex: 'E', means: "modulus of elasticity (Young's modulus), the slope of the straight part of the stress-strain curve", units: 'psi or ksi, MPa or GPa' },
      { tex: '\\varepsilon', means: 'normal strain, change in length divided by original length', units: 'unitless (in./in. or mm/mm)' },
    ],
    trap: 'Strain is often given in percent or microstrain; convert to a plain decimal before multiplying by E.',
  },
  {
    label: 'BHN–Tensile Strength',
    aliases: ['brinell hardness', 'bhn', 'hardness to tensile strength', 'tensile strength estimate'],
    use: 'Quick estimate of the tensile strength of a plain carbon steel from its Brinell hardness number.',
    symbols: [
      { tex: 'TS', means: 'ultimate tensile strength of the steel', units: 'MPa (the US form is TS in psi ≈ 500 × BHN)' },
      { tex: 'BHN', means: 'Brinell hardness number from the indentation test', units: 'unitless (a hardness index)' },
    ],
    trap: 'The factor near 3.5 gives MPa; for psi the handbook uses 500 × BHN, and both apply to plain carbon steels only.',
  },
  {
    label: 'Fracture Toughness',
    aliases: ['fracture toughness', 'stress intensity', 'kic', 'crack length'],
    use: 'Check whether a crack of a given size will run (fast fracture) at a given applied stress in a brittle material.',
    symbols: [
      { tex: 'K_{IC}', means: 'fracture toughness, the critical stress intensity at which the crack propagates', units: 'MPa·√m or ksi·√in.' },
      { tex: 'Y', means: 'geometry factor (1.1 for an exterior edge crack, 1.0 for an interior crack)', units: 'unitless' },
      { tex: '\\sigma', means: 'applied engineering stress', units: 'MPa or ksi' },
      { tex: 'a', means: 'crack length for an edge crack, or half the total length for an interior crack', units: 'm or in.' },
    ],
    trap: 'An interior crack of total length 2a uses only a, and a must be in meters (or inches) to match the units of K.',
  },
  {
    label: 'Thermal Expansion',
    aliases: ['thermal expansion', 'thermal strain', 'coefficient of thermal expansion', 'temperature change'],
    use: 'Change in length of a member that is free to move when its temperature changes.',
    symbols: [
      { tex: '\\Delta L', means: 'change in length', units: 'in. or mm' },
      { tex: '\\alpha', means: 'coefficient of thermal expansion', units: '1/°F or 1/°C' },
      { tex: 'L', means: 'original length', units: 'in. or mm' },
      { tex: '\\Delta T', means: 'change in temperature (final minus initial)', units: '°F or °C' },
    ],
    trap: 'Match α to the temperature unit: a value per °C used with a change in °F is off by a factor of 1.8.',
  },
  {
    label: 'Water-Cement Ratio',
    aliases: ['water cement ratio', 'w/c', 'concrete strength', 'mix design'],
    use: 'The main factor that controls concrete strength: lower W/C gives stronger, more durable concrete.',
    symbols: [
      { tex: 'W/C', means: 'weight of mixing water divided by weight of cement in the same batch', units: 'unitless' },
    ],
    trap: 'It is a ratio by weight, not volume; adding water without adding cement raises W/C and lowers strength.',
  },
  {
    label: 'Rule of Mixtures (Modulus)',
    aliases: ['rule of mixtures', 'composite modulus', 'fiber composite', 'volume fraction'],
    use: 'Stiffness of a fiber composite loaded parallel to long, aligned fibers.',
    symbols: [
      { tex: 'E_c', means: "Young's modulus of the composite", units: 'psi or ksi, GPa' },
      { tex: 'f_1', means: 'volume fraction of material 1', units: 'unitless (0 to 1)' },
      { tex: 'E_1', means: "Young's modulus of material 1", units: 'psi or ksi, GPa' },
      { tex: 'f_2', means: 'volume fraction of material 2 (f₁ + f₂ = 1)', units: 'unitless (0 to 1)' },
      { tex: 'E_2', means: "Young's modulus of material 2", units: 'psi or ksi, GPa' },
    ],
    trap: 'Use volume fractions, not weight fractions; this is the upper bound, and loading across the fibers uses the inverse rule (1/E_c = Σ f/E).',
  },
  {
    label: 'Aggregate Bulk Specific Gravity',
    aliases: ['bulk specific gravity', 'gsb', 'aggregate specific gravity', 'oven dry'],
    use: 'Bulk (oven-dry) specific gravity of coarse aggregate from the soaking test (ASTM C127), used in concrete and asphalt mix design.',
    symbols: [
      { tex: 'G_{sb}', means: 'bulk specific gravity of the aggregate on an oven-dry basis', units: 'unitless' },
      { tex: 'A', means: 'mass of the oven-dry sample in air', units: 'g or lb' },
      { tex: 'B', means: 'mass of the saturated surface-dry (SSD) sample in air', units: 'g or lb' },
      { tex: 'C', means: 'mass of the saturated sample weighed submerged in water', units: 'g or lb' },
    ],
    trap: 'Putting B on top gives the SSD specific gravity and A/(A minus C) gives the apparent one, so check which numerator the question wants.',
  },
  {
    label: 'Aggregate Absorption (%)',
    aliases: ['absorption', 'aggregate absorption', 'ssd', 'saturated surface dry'],
    use: 'How much water an aggregate soaks into its pores, used to correct mix water in concrete.',
    symbols: [
      { tex: '\\text{Absorption}', means: 'water held in the pores at SSD, as a percent of the dry mass', units: 'percent' },
      { tex: 'W_{SSD}', means: 'weight of the sample in the saturated surface-dry condition', units: 'g or lb' },
      { tex: 'W_{OD}', means: 'weight of the oven-dry sample', units: 'g or lb' },
    ],
    trap: 'Divide by the oven-dry weight, not the SSD weight.',
  },
  {
    label: 'Asphalt Air Voids (VTM)',
    aliases: ['air voids', 'vtm', 'gmm', 'gmb', 'asphalt mix design'],
    use: 'Percent of a compacted asphalt mix volume that is air, the main Superpave design check (target about 4%).',
    symbols: [
      { tex: 'V_a', means: 'air voids in the compacted mix (voids in total mix)', units: 'percent' },
      { tex: 'G_{mm}', means: 'theoretical maximum specific gravity of the loose mix with no air (Rice value)', units: 'unitless' },
      { tex: 'G_{mb}', means: 'bulk specific gravity of the compacted mix specimen', units: 'unitless' },
    ],
    trap: 'G_mm is always the larger number; swapping the two gives a negative air void value.',
  },
  {
    label: 'Voids Filled with Asphalt',
    aliases: ['vfa', 'voids filled with asphalt', 'vma', 'asphalt volumetrics'],
    use: 'Percent of the space between aggregate particles (VMA) that is filled with asphalt binder rather than air.',
    symbols: [
      { tex: 'VFA', means: 'voids filled with asphalt', units: 'percent' },
      { tex: 'VMA', means: 'voids in the mineral aggregate, the space between aggregate particles (air plus effective binder)', units: 'percent of total mix volume' },
      { tex: 'V_a', means: 'air voids in the compacted mix', units: 'percent of total mix volume' },
    ],
    trap: 'Enter VMA and V_a as percents (16, not 0.16) so the factor of 100 gives a percent.',
  },
  {
    label: 'Wood Moisture Content',
    aliases: ['moisture content', 'wood moisture', 'oven dry weight', 'mc'],
    use: 'Water in a piece of wood as a percent of its oven-dry weight, which controls its strength and shrinkage.',
    symbols: [
      { tex: 'MC\\%', means: 'moisture content on an oven-dry basis', units: 'percent' },
      { tex: 'W_{wet}', means: 'weight of the wood as tested, with its moisture', units: 'g or lb' },
      { tex: 'W_{OD}', means: 'weight of the same wood after oven drying', units: 'g or lb' },
    ],
    trap: 'Divide by the oven-dry weight, so green wood can show a moisture content above 100%.',
  },
];
