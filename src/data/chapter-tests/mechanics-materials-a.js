// Chapter test bank: mechanics-materials, version A. See docs/CHAPTER-TESTS.md.

const SM = 'Shear and moment diagrams';
const ST = 'Stresses (axial, torsion, bending, transverse shear, thermal, thin-walled vessels)';
const DF = 'Deformations (axial, torsional twist, beam deflection, thermal)';
const CB = "Combined stresses, principal stresses, Mohr's circle";

const PROBLEMS = [
  {
    id: 'ct-mechanics-materials-a-01',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: SM,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'The shear diagram shown belongs to a beam with a pin at A, a roller at B, and an overhang ending at the free end C. The bending moment at support B (kip-ft) is most nearly:',
    choices: [
      { id: 'c1', text: '$-57$' },
      { id: 'c2', text: '$-24$' },
      { id: 'c3', text: '$33$' },
      { id: 'c4', text: '$90$' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'Takes only the area of the negative segment between the load point and B and forgets the positive area from A.',
      'Correct: M at A is zero (pin), and adding the signed shear areas from A to B gives 33 - 57 = -24 kip-ft.',
      'Stops at the first segment: 33 kip-ft is the moment under the point where the shear changes sign, not at B.',
      'Adds the two areas as positive numbers, ignoring that the second one is negative.',
    ],
    eli5:
      'The moment at any point equals the moment at the start plus the area under the shear diagram up to that point. At the pin A the moment is zero. From A the shear is +5.5 kips for 6 ft (area +33), then -9.5 kips for 6 ft (area -57). So at B the moment is 0 + 33 - 57 = -24 kip-ft. The overhang lets you check: the last 4 ft has area +24, which brings the moment back to zero at the free end C.',
    hint: 'Start at A with M = 0 and add the shear areas, keeping their signs.',
    steps: [
      { text: 'At the pin A the bending moment is zero.', latex: 'M_A = 0' },
      { text: 'Area under the shear diagram from A to the load point (6 ft at +5.5 kips).', latex: 'A_1 = (5.5)(6) = +33\\ \\text{kip-ft}' },
      { text: 'Area from the load point to B (6 ft at -9.5 kips).', latex: 'A_2 = (-9.5)(6) = -57\\ \\text{kip-ft}' },
      { text: 'Moment at B is the running sum.', latex: 'M_B = 0 + 33 - 57 = -24\\ \\text{kip-ft}' },
      { text: 'Check from the free end: the overhang area is (6.0)(4) = +24, and M_C must be zero.', latex: 'M_C = -24 + 24 = 0\\ \\checkmark' },
    ],
    handbookPage: 'p. 134',
    handbookFormula: 'M_2 - M_1 = \\int_{x_1}^{x_2} V(x)\\,dx',
    traps: [
      'Adding shear areas without their signs.',
      'Reporting the largest positive moment (under the load) when the question asks for the moment at the support.',
      'Forgetting that the moment at a pin at the end of a beam is zero, so the running sum starts at zero.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsAOverhangShear',
      props: { segments: [6, 6, 4], shears: [5.5, -9.5, 6.0], unit: 'kips' },
    },
  },
  {
    id: 'ct-mechanics-materials-a-02',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: SM,
    type: 'conceptual',
    difficulty: 'easy',
    statement:
      'A simply supported beam carries only a clockwise concentrated couple $M_0$ applied one third of the span from the left support, as shown. With positive moment (concave up) drawn above the axis, which bending moment diagram is correct?',
    choices: [
      { id: 'c1', text: 'Diagram I' },
      { id: 'c2', text: 'Diagram II' },
      { id: 'c3', text: 'Diagram III' },
      { id: 'c4', text: 'Diagram IV' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'A triangle with a peak and no jump is the shape for a concentrated force, not a couple.',
      'Has the jump, but in the wrong direction: a clockwise couple makes the moment jump up (in the positive direction) moving left to right.',
      'Shows a constant moment after the couple, which would need zero shear; here the reactions form a couple, so the shear is a nonzero constant and the moment must slope.',
      'Correct: the reactions are equal and opposite, so the shear is constant (-M0/L) and both segments have the same slope; the moment falls to -M0/3, jumps up by M0 to +2M0/3, and returns to zero at B.',
    ],
    eli5:
      'A couple twists the beam without pushing it up or down. To keep the beam still, the supports push one up and one down by the same amount, M0/L. So the shear is the same everywhere, which means the moment diagram is made of straight lines with the same slope. Where the couple sits, the moment jumps by exactly M0. A clockwise couple makes it jump up as you move right. Diagram IV is the only one with parallel slopes and an upward jump.',
    hint: 'Equal and opposite reactions mean constant shear. What does constant shear do to the slope of the moment diagram?',
    steps: [
      { text: 'Sum moments about A: the reactions form a couple that balances M0.', latex: 'R_B = \\frac{M_0}{L}\\ (\\text{up}),\\qquad R_A = \\frac{M_0}{L}\\ (\\text{down})' },
      { text: 'The shear is constant over the whole span, so the moment diagram has one constant slope.', latex: 'V = -\\frac{M_0}{L},\\qquad \\frac{dM}{dx} = V' },
      { text: 'Just left of the couple, at x = L/3:', latex: 'M = -\\frac{M_0}{L}\\cdot\\frac{L}{3} = -\\frac{M_0}{3}' },
      { text: 'A clockwise applied couple makes the moment jump by +M0, and the line returns to zero at B.', latex: 'M = -\\frac{M_0}{3} + M_0 = +\\frac{2M_0}{3}' },
    ],
    handbookPage: 'p. 134',
    handbookFormula: 'V = \\frac{dM(x)}{dx}',
    traps: [
      'Treating a couple like a point force and drawing a peak.',
      'Getting the direction of the jump backwards.',
      'Assuming the shear is zero because no vertical load is applied: the reactions still create shear.',
    ],
    diagram: { component: 'CtMechanicsMaterialsACoupleDiagrams', props: { aFrac: 1 / 3 } },
  },
  {
    id: 'ct-mechanics-materials-a-03',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: SM,
    type: 'computational',
    difficulty: 'easy',
    statement:
      'The stem of a cantilever retaining wall is 10 ft tall. A 1-ft-wide strip of the stem is treated as a vertical cantilever fixed at the footing, loaded by lateral earth pressure that rises linearly from zero at the top to $0.60$ kip/ft at the base, as shown. The bending moment at the base of the strip (kip-ft) is most nearly:',
    choices: [
      { id: 'c1', text: '$3.0$' },
      { id: 'c2', text: '$10$' },
      { id: 'c3', text: '$20$' },
      { id: 'c4', text: '$30$' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'This is the shear at the base (the resultant, w0 L / 2), not the moment.',
      'Correct: resultant 3.0 kips acting at one third of the height above the base, so M = 3.0 x 10/3 = 10 kip-ft (w0 L^2 / 6).',
      'Places the resultant at two thirds of the height above the base (the centroid measured from the wrong end).',
      'Treats the load as uniform at 0.60 kip/ft over the full height (w L^2 / 2).',
    ],
    eli5:
      'The soil pushes harder the deeper you go, so the load is a triangle. Replace the triangle by one force: its size is the triangle area, half of 0.60 times 10, which is 3 kips. That force acts at the centroid of the triangle, one third of the way up from the base, 3.33 ft. The moment at the base is 3 kips times 3.33 ft, 10 kip-ft.',
    hint: 'Replace the triangular load by its resultant and find where it acts.',
    steps: [
      { text: 'Resultant of the triangular load (area of the triangle).', latex: 'F = \\tfrac{1}{2}(0.60)(10) = 3.0\\ \\text{kips}' },
      { text: 'It acts at the centroid, one third of the height above the base.', latex: '\\bar{y} = \\frac{10}{3} = 3.33\\ \\text{ft}' },
      { text: 'Moment at the fixed base.', latex: 'M = (3.0)(3.33) = 10\\ \\text{kip-ft}\\quad \\left(=\\tfrac{w_0 L^2}{6}\\right)' },
    ],
    handbookPage: 'p. 140',
    handbookFormula: 'M_{max} = \\frac{w_0 L^2}{6}\\ \\text{at the fixed end}',
    traps: [
      'Using w L^2/2 as if the load were uniform.',
      'Putting the triangle resultant at 2L/3 from the base instead of L/3.',
      'Giving the shear (resultant force) instead of the moment.',
    ],
    diagram: { component: 'CtMechanicsMaterialsAWallStem', props: { height: 10, w0: 0.6 } },
  },
  {
    id: 'ct-mechanics-materials-a-04',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: ST,
    type: 'computational',
    difficulty: 'easy',
    statement:
      'Two steel plates are joined end to end by a butt splice with a splice plate on each face, as shown. There is one $3/4$-in.-diameter bolt on each side of the joint, and the plates carry a tension of 18 kips. The average shear stress in a bolt (ksi) is most nearly:',
    choices: [
      { id: 'c1', text: '$5.1$' },
      { id: 'c2', text: '$10.2$' },
      { id: 'c3', text: '$20.4$' },
      { id: 'c4', text: '$40.7$' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Uses pi d^2 for the area (the diameter plugged into pi r^2), four times too much area.',
      'Splits the load between both bolts as well as the two shear planes. Each bolt on its own side of the joint carries the full 18 kips.',
      'Correct: each bolt is in double shear, so tau = P / (2A) = 18 / (2 x 0.442) = 20.4 ksi.',
      'Treats the bolt as single shear, using one area.',
    ],
    eli5:
      'All 18 kips must pass from the left plate into the splice plates through the one bolt on the left side. That bolt is pinched by two splice plates, one above and one below, so it would have to be cut in two places to fail. Two cut faces share the 18 kips, 9 kips each. Divide by the bolt area, 0.442 square inches, and you get about 20.4 ksi.',
    hint: 'Count the planes the bolt would have to shear through, and how many bolts carry the load on one side of the joint.',
    steps: [
      { text: 'Bolt area.', latex: 'A = \\frac{\\pi d^2}{4} = \\frac{\\pi (0.75)^2}{4} = 0.442\\ \\text{in}^2' },
      { text: 'One bolt per side carries the full load through two shear planes (double shear).', latex: 'V_{plane} = \\frac{18}{2} = 9.0\\ \\text{kips}' },
      { text: 'Average shear stress.', latex: '\\tau = \\frac{P}{2A} = \\frac{18}{2(0.442)} = 20.4\\ \\text{ksi}' },
    ],
    handbookPage: 'p. 130',
    handbookFormula: '\\tau_{avg} = \\frac{P}{nA}\\ (n = \\text{number of shear planes, from } \\sigma = P/A)',
    traps: [
      'Single shear instead of double shear.',
      'Dividing the load by both bolts when each one sits on its own side of the joint.',
      'Using the diameter in place of the radius in pi r^2.',
    ],
    diagram: { component: 'CtMechanicsMaterialsAButtSplice', props: { P: 18, bolt: '3/4 in.' } },
  },
  {
    id: 'ct-mechanics-materials-a-05',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: ST,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'An open-top steel water standpipe has a diameter of 30 ft and holds water 80 ft deep. The wall plate at the base is 0.50 in. thick. Using thin-wall theory, the hoop stress in the wall at the base (ksi) is most nearly:',
    choices: [
      { id: 'c1', text: '$1.04$' },
      { id: 'c2', text: '$6.24$' },
      { id: 'c3', text: '$12.5$' },
      { id: 'c4', text: '$25.0$' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Leaves the diameter in feet while the pressure is in psi and the thickness in inches.',
      'This is pr/(2t), the longitudinal stress of a capped vessel. An open-top standpipe has no pressure-driven longitudinal stress, and in any case the hoop stress governs.',
      'Correct: p = 62.4 x 80 / 144 = 34.7 psi; sigma = p r / t = 34.7 x 180 / 0.50 = 12,480 psi = 12.5 ksi.',
      'Uses the diameter in place of the radius in p r / t.',
    ],
    eli5:
      'Water pushes out on the wall, harder at the bottom. At 80 ft deep the pressure is about 35 psi. That pressure tries to split the tank along a vertical line, and the wall resists with hoop stress, pressure times radius divided by thickness. The radius is 15 ft, or 180 in., so 34.7 times 180 divided by 0.5 is about 12,500 psi.',
    hint: 'Get the pressure at the base in psi first, then use the hoop stress formula with the radius in inches.',
    steps: [
      { text: 'Water pressure at the base, converted to psi.', latex: 'p = \\gamma h = \\frac{(62.4)(80)}{144} = 34.7\\ \\text{psi}' },
      { text: 'Radius in inches.', latex: 'r = \\frac{30(12)}{2} = 180\\ \\text{in.}' },
      { text: 'Thin-wall hoop stress (t/r = 0.003, well under 0.1).', latex: '\\sigma_t = \\frac{p r}{t} = \\frac{(34.7)(180)}{0.50} = 12{,}480\\ \\text{psi} \\approx 12.5\\ \\text{ksi}' },
    ],
    handbookPage: 'p. 131',
    handbookFormula: '\\sigma_t = \\frac{P_i r}{t}',
    traps: [
      'Using the diameter instead of the radius.',
      'Mixing feet and inches in p r / t.',
      'Reporting the longitudinal stress (half the hoop stress).',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsAStandpipe',
      props: { diameter: 30, depth: 80, height: 86, t: '0.50 in.' },
    },
  },
  {
    id: 'ct-mechanics-materials-a-06',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: ST,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'A highway sign is mounted on a single steel pipe post fixed at the ground. The pipe has an outside diameter of 6.625 in. and a wall thickness of 0.280 in. The wind resultant on the sign is 0.80 kip acting 10 ft above the base, as shown. The maximum bending stress in the post at the base (ksi) is most nearly:',
    choices: [
      { id: 'c1', text: '$0.94$' },
      { id: 'c2', text: '$3.4$' },
      { id: 'c3', text: '$11.3$' },
      { id: 'c4', text: '$22.6$' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Leaves the moment in kip-ft (8.0) while I and c are in inches.',
      'Uses the moment of inertia of a solid 6.625-in. bar, ignoring the hole.',
      'Correct: I = (pi/64)(6.625^4 - 6.065^4) = 28.1 in^4; M = 0.80 x 120 = 96 kip-in; sigma = M c / I = 96 x 3.3125 / 28.1 = 11.3 ksi.',
      'Uses the full outside diameter as c instead of half of it.',
    ],
    eli5:
      'The wind pushes the sign sideways, and the post acts like a diving board standing on end. The bending moment at the ground is the force times its height: 0.8 kip times 10 ft is 8 kip-ft, or 96 kip-in. The pipe resists with its moment of inertia, which for a tube is the outer circle minus the hole. The outermost fiber is half the outside diameter from the center. Moment times that distance, divided by I, gives about 11.3 ksi.',
    hint: 'Moment in kip-in, I of a hollow circle, c = outside radius.',
    steps: [
      { text: 'Inside diameter.', latex: 'd_i = 6.625 - 2(0.280) = 6.065\\ \\text{in.}' },
      { text: 'Moment of inertia of the tube.', latex: 'I = \\frac{\\pi}{64}\\left(6.625^4 - 6.065^4\\right) = 28.1\\ \\text{in}^4' },
      { text: 'Moment at the base, in kip-in.', latex: 'M = (0.80)(10)(12) = 96\\ \\text{kip-in.}' },
      { text: 'Maximum bending stress, c = outside radius.', latex: '\\sigma = \\frac{Mc}{I} = \\frac{(96)(3.3125)}{28.1} = 11.3\\ \\text{ksi}' },
    ],
    handbookPage: 'p. 135',
    handbookFormula: '\\sigma_x = \\pm \\frac{Mc}{I}',
    traps: [
      'Using the solid-section I for a hollow pipe.',
      'Using the diameter instead of the radius for c.',
      'Leaving the moment in kip-ft.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsASignPost',
      props: { F: 0.8, h: 10, postHeight: 12.5, od: 6.625, t: 0.28 },
    },
  },
  {
    id: 'ct-mechanics-materials-a-07',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: ST,
    type: 'computational',
    difficulty: 'hard',
    statement:
      'A timber T-beam is built from an 8 in. by 2 in. flange plank nailed to a 2 in. by 10 in. web plank, as shown (actual dimensions). One row of nails joins them, each nail good for 250 lb in shear. For a vertical shear of 600 lb, the maximum nail spacing along the beam (in.) is most nearly:',
    choices: [
      { id: 'c1', text: '$1.92$' },
      { id: 'c2', text: '$3.08$' },
      { id: 'c3', text: '$3.49$' },
      { id: 'c4', text: '$3.84$' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'Divides the nail capacity by two, as if each nail had two shear planes to share.',
      'Puts the neutral axis at mid-depth (6 in.) instead of at the centroid of the T.',
      'Uses Q for everything above the neutral axis (flange plus part of the web). The nails only transfer the flange\'s share.',
      'Correct: neutral axis 7.67 in. above the bottom, I = 492 in^4, Q of the flange = 16 x 3.33 = 53.3 in^3, q = 600 x 53.3 / 492 = 65.0 lb/in., s = 250 / 65.0 = 3.84 in.',
    ],
    eli5:
      'When the beam bends, the flange wants to slide along the top of the web, and the nails stop it. The sliding force per inch of beam is the shear flow, V Q over I, where Q is the first moment of just the piece the nails hold on: the flange. Find the neutral axis of the T, then I, then Q of the flange about that axis. The shear flow comes out to 65 lb per inch, and a 250-lb nail can handle 250/65 = 3.8 in. of beam.',
    hint: 'The nails carry the shear flow at the flange-web joint, so Q is the flange area times its distance to the neutral axis.',
    steps: [
      { text: 'Neutral axis from the bottom of the web (flange centroid at 11 in., web centroid at 5 in.).', latex: '\\bar{y} = \\frac{16(11) + 20(5)}{16 + 20} = 7.67\\ \\text{in.}' },
      { text: 'Moment of inertia about the neutral axis (parallel-axis theorem).', latex: 'I = \\frac{8(2)^3}{12} + 16(3.33)^2 + \\frac{2(10)^3}{12} + 20(2.67)^2 = 492\\ \\text{in}^4' },
      { text: 'First moment of the flange about the neutral axis.', latex: 'Q = 16(11 - 7.67) = 53.3\\ \\text{in}^3' },
      { text: 'Shear flow at the joint.', latex: 'q = \\frac{VQ}{I} = \\frac{600(53.3)}{492} = 65.0\\ \\text{lb/in.}' },
      { text: 'Nail spacing.', latex: 's = \\frac{F_{nail}}{q} = \\frac{250}{65.0} = 3.84\\ \\text{in.}' },
    ],
    handbookPage: 'p. 135',
    handbookFormula: 'q = \\frac{VQ}{I}',
    traps: [
      'Taking Q at the neutral axis instead of at the joint.',
      'Assuming the neutral axis is at mid-depth of an unsymmetric section.',
      'Treating the nail as if it were in double shear.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsANailedTee',
      props: { bf: 8, tf: 2, tw: 2, hw: 10 },
    },
  },
  {
    id: 'ct-mechanics-materials-a-08',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: DF,
    type: 'computational',
    difficulty: 'hard',
    statement:
      'A 25-ft steel rod ($E = 29{,}000$ ksi, $\\alpha = 6.5 \\times 10^{-6}$/°F) is anchored to a rigid wall at one end. At installation there is a 0.040-in. gap between its other end and a rigid abutment, as shown. If the rod temperature then rises 90°F, the axial stress in the rod (ksi) is most nearly:',
    choices: [
      { id: 'c1', text: '$13.1$' },
      { id: 'c2', text: '$17.0$' },
      { id: 'c3', text: '$20.8$' },
      { id: 'c4', text: '$157$' },
    ],
    correctAnswerId: 'c1',
    choiceNotes: [
      'Correct: free expansion 6.5e-6 x 90 x 300 = 0.1755 in.; the gap absorbs 0.040 in.; the abutment prevents the other 0.1355 in., so sigma = E (0.1355 / 300) = 13.1 ksi (compression).',
      'Ignores the gap and treats the rod as fully restrained (E alpha delta T).',
      'Adds the gap to the free expansion instead of subtracting it.',
      'Divides the prevented elongation in inches by the length in feet.',
    ],
    eli5:
      'If nothing stopped it, the warm rod would grow 0.1755 in. The first 0.040 in. of growth is free, because it just closes the gap. After that the abutment stops the rod, so the wall has to push back hard enough to squeeze out the remaining 0.1355 in. Squeezing 0.1355 in. out of 300 in. of steel takes E times 0.1355/300, about 13.1 ksi.',
    hint: 'Only the expansion left over after the gap closes is resisted.',
    steps: [
      { text: 'Free thermal expansion over 300 in.', latex: '\\delta_T = \\alpha L \\Delta T = (6.5\\times10^{-6})(300)(90) = 0.1755\\ \\text{in.}' },
      { text: 'The gap takes 0.040 in.; the rest is prevented by the abutment.', latex: '\\delta_{prevented} = 0.1755 - 0.040 = 0.1355\\ \\text{in.}' },
      { text: 'Compatibility: the wall force must shorten the rod by that amount, PL/AE = 0.1355.', latex: '\\sigma = \\frac{P}{A} = \\frac{E\\,\\delta_{prevented}}{L} = \\frac{29{,}000(0.1355)}{300} = 13.1\\ \\text{ksi (compression)}' },
    ],
    handbookPage: 'p. 130',
    handbookFormula: '\\delta_t = \\alpha L (T - T_o),\\qquad \\delta = \\frac{PL}{AE}',
    traps: [
      'Ignoring the gap.',
      'Adding the gap instead of subtracting it.',
      'Mixing feet and inches in the strain.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsAGapRod',
      props: { length: 25, gap: '0.040 in.', dT: 90 },
    },
  },
  {
    id: 'ct-mechanics-materials-a-09',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: DF,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'A solid 50-mm steel shaft ($G = 80$ GPa) is fixed at A and carries the two torques shown, applied in opposite directions at B and at the free end C. The magnitude of the angle of twist at C relative to A (degrees) is most nearly:',
    choices: [
      { id: 'c1', text: '$0.70$' },
      { id: 'c2', text: '$1.40$' },
      { id: 'c3', text: '$2.10$' },
      { id: 'c4', text: '$3.50$' },
    ],
    correctAnswerId: 'c1',
    choiceNotes: [
      'Correct: T_BC = 1.2 kN m, T_AB = 1.2 - 3.0 = -1.8 kN m; phi = (-1.8 x 0.6 + 1.2 x 0.4) / (G J) = -0.60 / 49,090 rad = 0.70 degrees.',
      'Uses the moment of inertia I = pi d^4 / 64 instead of the polar moment J, which doubles the answer.',
      'Applies the net 1.8 kN m over the whole 1.0 m, ignoring that segment BC carries a different torque.',
      'Adds the two torques as if they acted in the same direction, so segment AB carries 4.2 kN m.',
    ],
    eli5:
      'Each piece of the shaft twists by its own torque times its length over G J. Cut through BC and the only torque on the free piece is 1.2 kN m. Cut through AB and you get 1.2 minus 3.0, so 1.8 kN m the other way. The long piece twists one way, the short piece the other way, and they partly cancel: the net twist is 0.60 kN m^2 divided by G J, about 0.0122 rad, or 0.70 degrees.',
    hint: 'Find the internal torque in each segment, with signs, and add the twists.',
    steps: [
      { text: 'Polar moment of inertia.', latex: 'J = \\frac{\\pi d^4}{32} = \\frac{\\pi (0.050)^4}{32} = 6.14\\times10^{-7}\\ \\text{m}^4' },
      { text: 'Internal torques (cutting from the free end C).', latex: 'T_{BC} = +1.2\\ \\text{kN·m},\\qquad T_{AB} = 1.2 - 3.0 = -1.8\\ \\text{kN·m}' },
      { text: 'Sum the segment twists.', latex: '\\phi_{C/A} = \\frac{(-1.8)(0.6) + (1.2)(0.4)}{GJ}\\times 10^3 = \\frac{-600}{(80\\times10^9)(6.14\\times10^{-7})} = -0.0122\\ \\text{rad}' },
      { text: 'Convert to degrees.', latex: '|\\phi_C| = 0.0122 \\times \\frac{180}{\\pi} = 0.70^{\\circ}' },
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\phi = \\frac{TL}{GJ}',
    traps: [
      'Using I instead of J.',
      'Using one torque over the whole length instead of segment by segment.',
      'Losing the sign of the torques so the twists add instead of partly cancelling.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsATwistShaft',
      props: { lAB: 600, lBC: 400, d: 50, TB: 3.0, TC: 1.2 },
    },
  },
  {
    id: 'ct-mechanics-materials-a-10',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: DF,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'Floor joists of Douglas fir ($E = 1{,}600$ ksi) are spaced 16 in. on center and span 15 ft, simply supported. Each joist has $I = 98.9\\ \\text{in}^4$, and the floor live load is 40 psf. The midspan live-load deflection of a joist (in.) is most nearly:',
    choices: [
      { id: 'c1', text: '$0.288$' },
      { id: 'c2', text: '$0.384$' },
      { id: 'c3', text: '$0.614$' },
      { id: 'c4', text: '$4.61$' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'Takes the joist load as 40 lb/ft, ignoring that each joist carries a 16-in. (1.33-ft) tributary width.',
      'Correct: w = 40 x 16/12 = 53.3 lb/ft = 4.44 lb/in.; delta = 5 w L^4 / (384 E I) = 5 x 4.44 x 180^4 / (384 x 1.6e6 x 98.9) = 0.384 in.',
      'Uses the point-load coefficient 1/48 with the total load wL instead of 5/384 for a uniform load.',
      'Keeps w in lb/ft while L is in inches, which makes the answer 12 times too large.',
    ],
    eli5:
      'Each joist holds up a strip of floor 16 in. wide, so it carries 40 psf times 1.33 ft, about 53 lb per foot of joist. For a simply supported beam with a uniform load, the middle sags 5 w L^4 over 384 E I. Put every number in pounds and inches (w = 4.44 lb/in., L = 180 in., E = 1,600,000 psi) and the sag is about 0.38 in.',
    hint: 'Turn the floor load into a load per inch of joist using the spacing, and keep all units in pounds and inches.',
    steps: [
      { text: 'Load per joist from the tributary width.', latex: 'w = (40)\\left(\\frac{16}{12}\\right) = 53.3\\ \\text{lb/ft} = 4.44\\ \\text{lb/in.}' },
      { text: 'Span in inches and E in psi.', latex: 'L = 180\\ \\text{in.},\\qquad E = 1.6\\times10^6\\ \\text{psi}' },
      { text: 'Midspan deflection for a uniform load.', latex: '\\delta = \\frac{5wL^4}{384EI} = \\frac{5(4.44)(180)^4}{384(1.6\\times10^6)(98.9)} = 0.384\\ \\text{in.}' },
    ],
    handbookPage: 'p. 139',
    handbookFormula: 'v_{max} = \\frac{5wL^4}{384EI}',
    traps: [
      'Forgetting the tributary width (spacing) of the joist.',
      'Leaving w in lb/ft with L in inches.',
      'Using the point-load formula for a distributed load.',
    ],
    diagram: null,
  },
  {
    id: 'ct-mechanics-materials-a-11',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: CB,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'A short concrete pedestal 16 in. by 24 in. in plan carries a compressive load of 120 kips applied 4 in. off center along the 24-in. direction, as shown. The maximum compressive stress on the base of the pedestal (psi) is most nearly:',
    choices: [
      { id: 'c1', text: '$0$' },
      { id: 'c2', text: '$313$' },
      { id: 'c3', text: '$625$' },
      { id: 'c4', text: '$938$' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'This is the stress on the opposite edge: the load sits at the edge of the kern (e = h/6), so the minimum stress is exactly zero.',
      'This is P/A alone; it leaves out the bending from the eccentricity.',
      'Correct: P/A = 120,000 / 384 = 312.5 psi; M/S = (120,000 x 4) / (16 x 24^2 / 6) = 480,000 / 1,536 = 312.5 psi; maximum = 625 psi.',
      'Uses the full 24-in. depth as c instead of half of it, doubling the bending part.',
    ],
    eli5:
      'An off-center load does two things at once: it squeezes the whole base evenly (P/A), and it tips the pedestal toward the load side, adding squeeze on that side and taking it away on the other (M/S). Here both parts happen to be 312.5 psi. On the side nearer the load they add to 625 psi; on the far side they cancel to zero.',
    hint: 'Add the uniform part P/A and the bending part Mc/I, with M = P e and bending about the axis parallel to the 16-in. side.',
    steps: [
      { text: 'Area and the section modulus about the axis parallel to the 16-in. side (depth 24 in. in the direction of e).', latex: 'A = 16(24) = 384\\ \\text{in}^2,\\qquad S = \\frac{b h^2}{6} = \\frac{16(24)^2}{6} = 1{,}536\\ \\text{in}^3' },
      { text: 'Moment from the eccentricity.', latex: 'M = Pe = (120{,}000)(4) = 480{,}000\\ \\text{lb-in.}' },
      { text: 'Combine axial and bending stress on the face nearer the load.', latex: '\\sigma_{max} = \\frac{P}{A} + \\frac{M}{S} = 312.5 + 312.5 = 625\\ \\text{psi}' },
    ],
    handbookPage: 'p. 135',
    handbookFormula: '\\sigma = \\frac{P}{A} \\pm \\frac{Mc}{I}',
    traps: [
      'Forgetting the bending part of an eccentric load.',
      'Bending about the wrong axis (using 24 x 16^2 / 6).',
      'Using the full depth instead of c = h/2.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsAEccentricPier',
      props: { b: 24, d: 16, e: 4, P: 120 },
    },
  },
  {
    id: 'ct-mechanics-materials-a-12',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: CB,
    type: 'computational',
    difficulty: 'easy',
    statement:
      'The plane stress element shown is taken from the web of a loaded steel girder. The maximum in-plane shear stress at this point (MPa) is most nearly:',
    choices: [
      { id: 'c1', text: '$15$' },
      { id: 'c2', text: '$35$' },
      { id: 'c3', text: '$60$' },
      { id: 'c4', text: '$68$' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'This is the center of Mohr\'s circle, (sigma_x + sigma_y)/2, the average normal stress.',
      'Drops the minus sign on the compressive sigma_x: (45 - 75)/2 = -15, so R = sqrt(15^2 + 32^2) = 35 MPa.',
      'Uses (sigma_x - sigma_y)/2 and leaves out the shear stress term.',
      'Correct: R = sqrt(((-45 - 75)/2)^2 + 32^2) = sqrt(3,600 + 1,024) = 68 MPa.',
    ],
    eli5:
      'Draw Mohr\'s circle. The two faces give the points (-45, 32) and (75, -32). The center is halfway between them, at 15 MPa. The radius is the distance from the center to either point: 60 across and 32 up, so the square root of 60^2 + 32^2, which is 68. The biggest in-plane shear stress is always the radius.',
    hint: 'The maximum in-plane shear stress is the radius of Mohr\'s circle. Watch the sign of the compressive stress.',
    steps: [
      { text: 'Read the element: sigma_x is compressive, sigma_y tensile.', latex: '\\sigma_x = -45,\\quad \\sigma_y = 75,\\quad |\\tau_{xy}| = 32\\ \\text{MPa}' },
      { text: 'Half the difference of the normal stresses.', latex: '\\frac{\\sigma_x - \\sigma_y}{2} = \\frac{-45 - 75}{2} = -60\\ \\text{MPa}' },
      { text: 'Radius of Mohr\'s circle = maximum in-plane shear stress.', latex: '\\tau_{max,in} = R = \\sqrt{60^2 + 32^2} = 68\\ \\text{MPa}' },
    ],
    handbookPage: 'p. 132-133',
    handbookFormula: 'R = \\sqrt{\\left(\\frac{\\sigma_x - \\sigma_y}{2}\\right)^2 + \\tau_{xy}^2},\\qquad \\tau_{in} = R',
    traps: [
      'Dropping the minus sign on the compressive stress, which gives (45 - 75)/2 = -15 and R = 35.',
      'Leaving out the shear term.',
      'Reporting a principal stress instead of the radius.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsAStressElement',
      props: { sx: -45, sy: 75, txy: 32, unit: 'MPa' },
    },
  },
  {
    id: 'ct-mechanics-materials-a-13',
    chapterId: 'mechanics-materials',
    version: 'A',
    topic: CB,
    type: 'computational',
    difficulty: 'hard',
    statement:
      'A closed-end steel pipe with a mean diameter of 600 mm and a wall thickness of 8 mm carries an internal pressure of 1.6 MPa and, at the same time, a torque of 60 kN·m, as shown. The maximum principal stress in the wall, away from the ends (MPa), is most nearly:',
    choices: [
      { id: 'c1', text: '$60.0$' },
      { id: 'c2', text: '$65.0$' },
      { id: 'c3', text: '$73.3$' },
      { id: 'c4', text: '$123$' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'This is the hoop stress alone; it ignores the axial stress and the torsional shear.',
      'Correct: hoop 60 MPa, axial 30 MPa, torsional shear 13.3 MPa; sigma_1 = 45 + sqrt(15^2 + 13.3^2) = 65.0 MPa.',
      'Adds the shear stress straight onto the hoop stress (60 + 13.3) instead of combining them on Mohr\'s circle.',
      'Uses the 600-mm diameter as the radius, doubling both pressure stresses.',
    ],
    eli5:
      'The pressure makes two stresses in the wall: around the pipe (hoop), 60 MPa, and along it (axial), half that, 30 MPa. The torque adds a shear stress of 13.3 MPa on the same element. Put those three on Mohr\'s circle: center 45, radius the square root of 15^2 + 13.3^2, which is 20. The largest normal stress is center plus radius, 65 MPa.',
    hint: 'Find the hoop, axial and torsional shear stresses on one wall element, then combine them with Mohr\'s circle.',
    steps: [
      { text: 'Hoop and axial stress, thin wall (r = 300 mm).', latex: '\\sigma_t = \\frac{pr}{t} = \\frac{1.6(300)}{8} = 60\\ \\text{MPa},\\qquad \\sigma_a = \\frac{pr}{2t} = 30\\ \\text{MPa}' },
      { text: 'Torsional shear in a thin-walled tube, A_m = pi r^2.', latex: '\\tau = \\frac{T}{2A_m t} = \\frac{60\\times10^6}{2\\pi(300)^2(8)} = 13.3\\ \\text{MPa}' },
      { text: 'Mohr\'s circle center and radius.', latex: 'C = \\frac{60 + 30}{2} = 45,\\qquad R = \\sqrt{15^2 + 13.3^2} = 20.0\\ \\text{MPa}' },
      { text: 'Maximum principal stress.', latex: '\\sigma_1 = C + R = 45 + 20.0 = 65.0\\ \\text{MPa}' },
    ],
    handbookPage: 'p. 131-134',
    handbookFormula: '\\sigma_t = \\frac{Pr}{t},\\ \\sigma_a = \\frac{Pr}{2t},\\ \\tau = \\frac{T}{2A_m t},\\ \\sigma_{1} = C + R',
    traps: [
      'Ignoring the axial stress from the end caps.',
      'Adding shear and normal stress directly.',
      'Using the diameter in place of the radius.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsAPressurizedPipe',
      props: { D: 600, t: 8, p: 1.6, T: 60 },
    },
  },
];

export default PROBLEMS;
