// Plain-language guide to the formulas on the FE Civil Statics page,
// in the same order as chapters/statics.js. Symbols checked against the FE
// Reference Handbook 10.5.
export default [
  {
    label: 'Equilibrium Equations',
    aliases: ['equilibrium', 'sum of forces', 'sum of moments', 'free body diagram', 'reactions'],
    use: 'Find unknown forces and support reactions on a body that is not moving.',
    symbols: [
      { tex: 'F_x', means: 'each force component in the x (horizontal) direction', units: 'lbf, kips, N or kN' },
      { tex: 'F_y', means: 'each force component in the y (vertical) direction', units: 'lbf, kips, N or kN' },
      { tex: 'M', means: 'each moment about a point you choose, including couples', units: 'ft·lbf, ft·kips, N·m or kN·m' },
    ],
    trap: 'Take moments about a point where unknown forces act so they drop out, and keep one sign convention for every term.',
  },
  {
    label: 'Composite Centroid',
    aliases: ['centroid', 'composite area', 'center of area', 'x bar'],
    use: 'Find the centroid of a shape built from simple pieces like rectangles, triangles and circles.',
    symbols: [
      { tex: '\\bar{x}', means: 'x location of the centroid of the whole shape, from your reference axis', units: 'in, ft, mm or m' },
      { tex: 'A_i', means: 'area of each simple piece', units: 'in², ft², mm² or m²' },
      { tex: 'x_i', means: 'x distance from the reference axis to the centroid of each piece', units: 'in, ft, mm or m' },
    ],
    trap: 'Treat holes and cut-outs as negative areas, and measure every x_i from the same reference axis.',
  },
  {
    label: 'Parallel Axis Theorem',
    aliases: ['parallel axis', 'moment of inertia', 'transfer formula', 'ad squared'],
    use: 'Move a moment of inertia from a centroidal axis to any parallel axis, usually to build up a composite section.',
    symbols: [
      { tex: 'I_x', means: 'moment of inertia about the new (parallel) axis', units: 'in⁴, ft⁴, mm⁴ or m⁴' },
      { tex: '\\bar{I}_x', means: 'moment of inertia about the axis through the shape\'s own centroid', units: 'in⁴, ft⁴, mm⁴ or m⁴' },
      { tex: 'A', means: 'area of the shape', units: 'in², ft², mm² or m²' },
      { tex: 'd', means: 'perpendicular distance between the centroidal axis and the new axis', units: 'in, ft, mm or m' },
    ],
    trap: 'You can only transfer from the centroidal axis; to go between two non-centroidal axes, first come back to the centroid.',
  },
  {
    label: 'Static Friction',
    aliases: ['friction', 'static friction', 'coefficient of friction', 'impending motion', 'slip'],
    use: 'Check whether a body will slide, or find the force that starts it sliding.',
    symbols: [
      { tex: 'F', means: 'friction force along the contact surface', units: 'lbf or N' },
      { tex: '\\mu_s', means: 'coefficient of static friction', units: 'unitless' },
      { tex: 'N', means: 'normal force, pressing the two surfaces together, perpendicular to the contact', units: 'lbf or N' },
    ],
    trap: 'F equals μs·N only when slip is about to happen; on a slope N is W cos θ, not the full weight W.',
  },
  {
    label: 'Moment of a Force',
    aliases: ['moment', 'torque', 'r cross f', 'moment arm'],
    use: 'Find the turning effect of a force about a point.',
    symbols: [
      { tex: 'M', means: 'moment of the force about the point', units: 'ft·lbf, ft·kips, N·m or kN·m' },
      { tex: 'r', means: 'position vector from the point to any point on the force\'s line of action', units: 'ft, in, m or mm' },
      { tex: 'F', means: 'the force', units: 'lbf, kips, N or kN' },
    ],
    trap: 'In the scalar form M = F·d, d is the perpendicular distance to the line of action, not the straight distance to where the force is applied.',
  },
  {
    label: 'Lever / Machine (mechanical advantage)',
    aliases: ['lever', 'mechanical advantage', 'machine', 'pivot', 'fulcrum'],
    use: 'Find the force a lever or simple machine delivers, from moment balance about the pivot.',
    symbols: [
      { tex: 'F_{out}', means: 'force the lever delivers (output, or load)', units: 'lbf or N' },
      { tex: 'F_{in}', means: 'force applied to the lever (input, or effort)', units: 'lbf or N' },
      { tex: 'a_{in}', means: 'moment arm of the input force, perpendicular distance from the pivot', units: 'in, ft, mm or m' },
      { tex: 'a_{out}', means: 'moment arm of the output force, perpendicular distance from the pivot', units: 'in, ft, mm or m' },
    ],
    trap: 'A longer input arm gives a bigger output force; flipping the ratio is the usual slip.',
  },
];
