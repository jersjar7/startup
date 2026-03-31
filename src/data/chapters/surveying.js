export default {
  context: 'This chapter tests measurement, leveling, area/volume computation, coordinate systems, and curve design.',
  subtopics: [
    { id: 'angles-distances',  name: 'Angles & Distances' },
    { id: 'leveling',          name: 'Leveling' },
    { id: 'area-computations', name: 'Area Computations' },
    { id: 'earthwork-volumes', name: 'Earthwork & Volume Computations' },
    { id: 'coordinate-systems', name: 'Coordinate Systems' },
    { id: 'curves',            name: 'Horizontal & Vertical Curves' },
    { id: 'traverse',          name: 'Traverse Computations' },
  ],
  formulas: [
    { latex: 'A = \\frac{1}{2}|\\sum(x_i y_{i+1} - x_{i+1} y_i)|', label: 'Coordinate Area (Shoelace)', page: 'p. 159' },
    { latex: 'V = \\frac{L}{2}(A_1 + A_2)', label: 'Average End Area', page: 'p. 160' },
    { latex: 'L = \\frac{100 \\cdot I}{D}', label: 'Horizontal Curve Length', page: 'p. 161' },
    { latex: 'E = \\frac{A(L)}{800}', label: 'Vertical Curve Offset', page: 'p. 162' },
    { latex: '\\text{Lat} = L\\cos\\theta,\\quad \\text{Dep} = L\\sin\\theta', label: 'Traverse Lat/Dep', page: 'p. 159' },
  ],
  traps: [
    'Mixing up backsight and foresight in differential leveling — BS is added, FS is subtracted from the HI.',
    'Forgetting to close the traverse — always check that latitudes and departures sum to zero (or near zero).',
    'Using the wrong formula for curve length — horizontal curves use arc definition, vertical curves use station difference.',
    'Confusing azimuth (from north, clockwise) with bearing (from N or S, toward E or W).',
  ],
};
