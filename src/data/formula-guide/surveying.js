// Plain-language guide to the formulas on the FE Civil Surveying page,
// in the same order as chapters/surveying.js. Symbols checked against the FE
// Reference Handbook 10.5. The inverse computation is not printed in the
// handbook; it is standard coordinate geometry.
export default [
  {
    label: 'Traverse Lat/Dep',
    aliases: ['latitude', 'departure', 'traverse', 'lat dep'],
    use: 'Break a traverse course into its north-south (latitude) and east-west (departure) components.',
    symbols: [
      { tex: '\\text{Lat}', means: 'latitude, the north-south component of the course (north positive)', units: 'ft or m' },
      { tex: '\\text{Dep}', means: 'departure, the east-west component of the course (east positive)', units: 'ft or m' },
      { tex: 'L', means: 'horizontal length of the course', units: 'ft or m' },
      { tex: '\\theta', means: 'direction of the course measured from north (bearing angle or azimuth)', units: 'degrees' },
    ],
    trap: 'The angle is measured from north, so latitude uses cosine; with bearings, set the signs from the quadrant (S is negative latitude, W is negative departure).',
  },
  {
    label: 'Coordinate Area',
    aliases: ['area by coordinates', 'coordinate method', 'shoelace', 'traverse area'],
    use: 'Area enclosed by a closed traverse when you know the coordinates of every corner.',
    symbols: [
      { tex: 'A', means: 'area enclosed by the polygon', units: 'ft² or m²' },
      { tex: 'x_i', means: 'x coordinate (easting) of corner i', units: 'ft or m' },
      { tex: 'y_i', means: 'y coordinate (northing) of corner i', units: 'ft or m' },
      { tex: 'x_{i+1}', means: 'x coordinate of the next corner around the polygon', units: 'ft or m' },
      { tex: 'y_{i+1}', means: 'y coordinate of the next corner around the polygon', units: 'ft or m' },
    ],
    trap: 'List the corners in order around the shape and close back to the first one; divide square feet by 43,560 for acres.',
  },
  {
    label: 'Average End Area',
    aliases: ['average end area', 'earthwork volume', 'cut and fill', 'end area'],
    use: 'Earthwork volume between two cross sections a known distance apart.',
    symbols: [
      { tex: 'V', means: 'volume of earth between the two sections', units: 'ft³ or m³' },
      { tex: 'L', means: 'distance between the two cross sections', units: 'ft or m' },
      { tex: 'A_1', means: 'cross-sectional area at the first station', units: 'ft² or m²' },
      { tex: 'A_2', means: 'cross-sectional area at the second station', units: 'ft² or m²' },
    ],
    trap: 'Earthwork answers are usually in cubic yards, so divide cubic feet by 27.',
  },
  {
    label: 'Prismoidal Formula',
    aliases: ['prismoidal formula', 'prismoidal', 'earthwork volume', 'mid section area'],
    use: 'More accurate earthwork volume between two cross sections when the area at the midpoint is also known.',
    symbols: [
      { tex: 'V', means: 'volume of earth between the two end sections', units: 'ft³ or m³' },
      { tex: 'L', means: 'distance between the two end sections', units: 'ft or m' },
      { tex: 'A_1', means: 'cross-sectional area at the first end', units: 'ft² or m²' },
      { tex: 'A_m', means: 'cross-sectional area at the mid-section, halfway between the ends', units: 'ft² or m²' },
      { tex: 'A_2', means: 'cross-sectional area at the second end', units: 'ft² or m²' },
    ],
    trap: 'A_m is the area of the actual middle section (from averaged dimensions), not the average of A_1 and A_2.',
  },
  {
    label: 'Horizontal Curve Tangent',
    aliases: ['tangent length', 'horizontal curve', 'pc to pi', 'circular curve'],
    use: 'Distance from the PC (or PT) to the PI of a simple circular horizontal curve.',
    symbols: [
      { tex: 'T', means: 'tangent distance, from the PC or PT to the PI', units: 'ft or m' },
      { tex: 'R', means: 'radius of the curve', units: 'ft or m' },
      { tex: 'I', means: 'intersection (deflection) angle between the two tangents, also written Δ', units: 'degrees' },
    ],
    trap: 'Use half the intersection angle; stationing to the PT runs along the curve (PC plus L), not along the tangents.',
  },
  {
    label: 'Degree of Curve',
    aliases: ['degree of curve', 'arc definition', '5729.58', 'curve radius'],
    use: 'Convert between curve radius and degree of curve (arc definition) in US highway work.',
    symbols: [
      { tex: 'D', means: 'degree of curve, the central angle that subtends a 100 ft arc', units: 'degrees' },
      { tex: 'R', means: 'radius of the curve', units: 'ft' },
    ],
    trap: 'The constant 5,729.58 only works with R in feet and a 100 ft arc; it does not apply in meters.',
  },
  {
    label: 'Vertical Curve Elevation',
    aliases: ['vertical curve', 'curve elevation', 'pvc', 'parabolic curve'],
    use: 'Elevation of any point on a parabolic vertical curve at a horizontal distance x from the PVC.',
    symbols: [
      { tex: 'Y', means: 'elevation of the curve at distance x', units: 'ft or m' },
      { tex: 'Y_{PVC}', means: 'elevation of the PVC, the start of the curve', units: 'ft or m' },
      { tex: 'g_1', means: 'grade of the back (entering) tangent, percent divided by 100', units: 'ft/ft (decimal)' },
      { tex: 'g_2', means: 'grade of the forward (leaving) tangent, percent divided by 100', units: 'ft/ft (decimal)' },
      { tex: 'L', means: 'horizontal length of the curve, PVC to PVT', units: 'ft or m' },
      { tex: 'x', means: 'horizontal distance from the PVC to the point', units: 'ft or m' },
    ],
    trap: 'Grades as decimals need L and x in feet; if you keep grades in percent, L and x must be in stations (100 ft).',
  },
  {
    label: 'Inverse Computation (distance & azimuth)',
    aliases: ['inverse', 'azimuth', 'distance between points', 'coordinates to bearing'],
    use: 'Distance and direction between two points when you know their coordinates.',
    symbols: [
      { tex: 'L', means: 'horizontal distance between the two points', units: 'ft or m' },
      { tex: '\\Delta E', means: 'change in easting, second point minus first', units: 'ft or m' },
      { tex: '\\Delta N', means: 'change in northing, second point minus first', units: 'ft or m' },
      { tex: 'Az', means: 'azimuth from the first point to the second, clockwise from north', units: 'degrees (0 to 360)' },
    ],
    trap: 'A calculator arctangent only returns -90° to 90°; use the signs of ΔE and ΔN to put the azimuth in the right quadrant.',
  },
];
