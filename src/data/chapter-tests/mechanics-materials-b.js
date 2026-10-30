// Chapter test bank: mechanics-materials, version B. See docs/CHAPTER-TESTS.md.

const SM = 'Shear and moment diagrams';
const ST = 'Stresses (axial, torsion, bending, transverse shear, thermal, thin-walled vessels)';
const DF = 'Deformations (axial, torsional twist, beam deflection, thermal)';
const CB = "Combined stresses, principal stresses, Mohr's circle";

const PROBLEMS = [
  {
    id: 'ct-mechanics-materials-b-01',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: SM,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'A 20-ft simply supported floor beam carries a 10-kip concentrated load 5 ft from support A and a uniform load of 4 kip/ft over the right half of the span, as shown. Neglect the beam weight. The maximum bending moment in the beam (kip-ft) is most nearly:',
    choices: [
      { id: 'c1', text: '$87.5$' },
      { id: 'c2', text: '$112.5$' },
      { id: 'c3', text: '$125$' },
      { id: 'c4', text: '$132$' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'Assumes the maximum moment is under the concentrated load. The shear is still positive there, so the moment keeps rising.',
      'Takes the moment at the centroid of the uniform load (15 ft from A) instead of where the shear is zero.',
      'Takes the moment at midspan, where the uniform load starts. The shear is still +7.5 kips there, so the moment has not peaked yet.',
      'Correct: the shear reaches zero 11.875 ft from A, and the moment there is 132 kip-ft.',
    ],
    eli5:
      'The biggest bending moment sits where the shear crosses zero. Find the left reaction first: 17.5 kips. Walking right, the shear is 17.5 kips, drops to 7.5 kips at the point load, and starts falling by 4 kips per foot once the uniform load begins at midspan. It reaches zero 7.5/4 = 1.875 ft past midspan. Add up the shear areas to that point and you get 132 kip-ft.',
    hint: 'Find where the shear diagram crosses zero; that is where the moment peaks.',
    steps: [
      { text: 'Sum moments about B to get the left reaction. The uniform load resultant is 40 kips acting 5 ft from B.', latex: 'R_A = \\dfrac{10(15) + 40(5)}{20} = 17.5\\ \\text{kips}' },
      { text: 'Shear just right of the point load, and where it goes to zero inside the uniform load (which starts at x = 10 ft).', latex: 'V = 17.5 - 10 = 7.5\\ \\text{kips},\\quad x_0 = 10 + \\dfrac{7.5}{4} = 11.875\\ \\text{ft}' },
      { text: 'Moment at midspan from the shear areas.', latex: 'M_{10} = 17.5(5) + 7.5(5) = 125\\ \\text{kip-ft}' },
      { text: 'Add the triangle of shear from midspan to the zero-shear point.', latex: 'M_{max} = 125 + \\tfrac{1}{2}(7.5)(1.875) = 132.0\\ \\text{kip-ft}' },
      { text: 'Check from the right: R_B = 32.5 kips, and the zero-shear point is 8.125 ft from B.', latex: '32.5(8.125) - \\tfrac{4(8.125)^2}{2} = 132.0\\ \\checkmark' },
    ],
    handbookPage: 'p. 134',
    handbookFormula: 'M_2 - M_1 = \\int_{x_1}^{x_2} V(x)\\,dx',
    traps: [
      'Stopping at the concentrated load or at midspan: the moment peaks where the shear changes sign, not at a load point here.',
      'Placing the uniform load resultant at midspan instead of at the middle of the loaded half.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsBPartialUdlBeam',
      props: { L: 20, a: 5, P: 10, wLen: 10, w: 4 },
    },
  },
  {
    id: 'ct-mechanics-materials-b-02',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: SM,
    type: 'computational',
    difficulty: 'easy',
    statement:
      'The shear diagram shown is for a simply supported beam with a pin at A and a roller at C. The loads are not drawn. The concentrated load acting on the beam at point B (kips) is most nearly:',
    choices: [
      { id: 'c1', text: '$4$' },
      { id: 'c2', text: '$12$' },
      { id: 'c3', text: '$16$' },
      { id: 'c4', text: '$20$' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'Reads the shear value just to the right of B instead of the size of the jump.',
      'Correct: the shear jumps from +16 to +4 kips at B, a sudden drop of 12 kips, so a 12-kip downward load acts there.',
      'Reads the shear just to the left of B, which is the left reaction, not the load at B.',
      'Adds the two shear values at B (16 + 4) instead of taking their difference.',
    ],
    eli5:
      'A concentrated load makes the shear diagram jump straight up or down by the size of the load. At B the diagram drops from +16 to +4 kips. The drop is 12 kips, so there is a 12-kip load pushing down at B. The sloped line after B is the uniform load, a separate thing.',
    hint: 'A vertical step in the shear diagram equals the concentrated load at that point.',
    steps: [
      { text: 'Read the shear just left and just right of B.', latex: 'V_{B^-} = +16\\ \\text{kips},\\quad V_{B^+} = +4\\ \\text{kips}' },
      { text: 'The jump equals the concentrated load; a drop means the load acts downward.', latex: 'P_B = V_{B^-} - V_{B^+} = 16 - 4 = 12\\ \\text{kips}' },
      { text: 'Check: the slope from B to C is (4 + 20)/12 = 2 kip/ft, a 24-kip uniform load. Total load 12 + 24 = 36 kips equals the reactions 16 + 20.', latex: '12 + 24 = 16 + 20 = 36\\ \\checkmark' },
    ],
    handbookPage: 'p. 134',
    handbookFormula: 'V_2 - V_1 = -\\int_{x_1}^{x_2} w(x)\\,dx',
    traps: [
      'Reading a single shear value instead of the size of the step.',
      'Confusing the sloped part of the diagram (a distributed load) with a concentrated load.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsBShearDiagram',
      props: { segs: [6, 12], v: [16, 4, -20], unit: 'kips' },
    },
  },
  {
    id: 'ct-mechanics-materials-b-03',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: ST,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'A continuous welded steel rail ($E = 29{,}000$ ksi, $\\alpha = 6.5 \\times 10^{-6}$/°F, cross-sectional area $13.0\\ \\text{in}^2$) is anchored so it cannot change length. It is stress-free at 85°F. On a winter night the rail temperature drops to -5°F. The axial force in the rail (kips) is most nearly:',
    choices: [
      { id: 'c1', text: '$17.0$' },
      { id: 'c2', text: '$196$' },
      { id: 'c3', text: '$221$' },
      { id: 'c4', text: '$397$' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Stops at the stress (17.0 ksi) and never multiplies by the rail area.',
      'Uses a temperature change of 80°F by mishandling the negative final temperature (85 - 5 instead of 85 - (-5)).',
      'Correct: a 90°F drop gives a thermal stress of 17.0 ksi in tension, and 17.0 times 13.0 square inches is about 221 kips.',
      'Uses the SI coefficient (11.7 per million per °C) with a temperature change in °F.',
    ],
    eli5:
      'Cooling steel wants to shrink. The anchors hold the rail at its original length, so the rail ends up stretched by exactly the amount it wanted to shrink. That pull is a stress of E times alpha times the temperature change, and the force is that stress times the area. The drop from 85°F to -5°F is 90°F, not 80°F.',
    hint: 'Fully restrained member: stress equals E times alpha times delta T. Then force equals stress times area.',
    steps: [
      { text: 'Temperature change.', latex: '\\Delta T = 85 - (-5) = 90^{\\circ}\\text{F}' },
      { text: 'Free thermal strain the anchors prevent.', latex: '\\varepsilon_t = \\alpha\\,\\Delta T = (6.5\\times10^{-6})(90) = 5.85\\times10^{-4}' },
      { text: 'Stress needed to cancel it (tension, since the rail wants to shorten).', latex: '\\sigma = E\\,\\varepsilon_t = 29{,}000(5.85\\times10^{-4}) = 16.97\\ \\text{ksi}' },
      { text: 'Axial force in the rail.', latex: 'F = \\sigma A = 16.97(13.0) = 221\\ \\text{kips}' },
    ],
    handbookPage: 'p. 130',
    handbookFormula: '\\delta_t = \\alpha L (T - T_o),\\quad \\sigma = E\\,\\varepsilon',
    traps: [
      'Subtracting a negative temperature wrongly: from 85°F to -5°F is a 90°F change.',
      'Mixing the °C and °F values of the expansion coefficient.',
      'Answering with a stress when the question asks for a force.',
    ],
    diagram: null,
  },
  {
    id: 'ct-mechanics-materials-b-04',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: ST,
    type: 'computational',
    difficulty: 'easy',
    statement:
      'A closed cylindrical compressed-air receiver at a construction yard has a mean diameter of 1.5 m and a wall thickness of 12 mm. The internal pressure is 1.2 MPa. Using thin-wall theory, the longitudinal (axial) stress in the shell away from the heads (MPa) is most nearly:',
    choices: [
      { id: 'c1', text: '$18.8$' },
      { id: 'c2', text: '$37.5$' },
      { id: 'c3', text: '$75.0$' },
      { id: 'c4', text: '$150$' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'Divides by 4t while also using the radius, a mix of the pd/4t and pr/2t forms that halves the answer.',
      'Correct: axial stress is pr/(2t) = 1.2(750)/(2 x 12) = 37.5 MPa.',
      'Gives the hoop stress pr/t, or uses the diameter in pr/2t. Either error doubles the answer.',
      'Uses the diameter in the hoop formula, pd/t, which is four times the axial stress.',
    ],
    eli5:
      'Pressure pushes the two end caps apart, and the whole ring of steel around the tank resists that push. The steel ring is long (the circumference) and the pushed area is the circle, which works out to a stress of pressure times radius over twice the thickness. The hoop stress, which tries to split the tank along its length, is twice as large.',
    hint: 'For a thin cylinder, axial stress is half the hoop stress: pr over 2t.',
    steps: [
      { text: 'Mean radius in millimetres.', latex: 'r = \\dfrac{1500}{2} = 750\\ \\text{mm}' },
      { text: 'Thin-wall check: t/r = 12/750 = 0.016, well under 0.1.', latex: 't/r = 0.016 < 0.1' },
      { text: 'Axial stress from the handbook thin-wall formula.', latex: '\\sigma_a = \\dfrac{p\\,r}{2t} = \\dfrac{1.2(750)}{2(12)} = 37.5\\ \\text{MPa}' },
    ],
    handbookPage: 'p. 131',
    handbookFormula: '\\sigma_t = \\dfrac{P_i r}{t},\\quad \\sigma_a = \\dfrac{P_i r}{2t}',
    traps: [
      'Reporting the hoop stress (twice as large) when the question asks for the axial stress.',
      'Using the diameter where the formula has the radius.',
    ],
    diagram: null,
  },
  {
    id: 'ct-mechanics-materials-b-05',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: ST,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'A hollow steel shaft that drives a sluice gate hoist has an outside diameter of 3.0 in. and an inside diameter of 2.0 in. It carries a torque of 30 kip-in., as shown. The shear stress at the inside surface of the shaft (ksi) is most nearly:',
    choices: [
      { id: 'c1', text: '$4.70$' },
      { id: 'c2', text: '$7.05$' },
      { id: 'c3', text: '$9.40$' },
      { id: 'c4', text: '$14.1$' },
    ],
    correctAnswerId: 'c1',
    choiceNotes: [
      'Correct: J = 6.38 in.^4 for the hollow section, and at the inside surface r = 1.0 in., so the stress is 30(1.0)/6.38 = 4.70 ksi.',
      'Uses the outside radius (1.5 in.), which gives the maximum stress at the outer surface, not the stress at the inside surface.',
      'Uses the inside diameter (2.0 in.) as the radius.',
      'Uses the outside diameter (3.0 in.) as the radius.',
    ],
    eli5:
      'In a twisted shaft the shear stress grows in a straight line from zero at the center to its largest value at the outer skin. The inside surface of a hollow shaft is closer to the center, so its stress is smaller: 1.0/1.5 of the outer value. Use the hollow polar moment of inertia and the inside radius.',
    hint: 'Shear stress is Tr/J, where r is the radius to the point you care about.',
    steps: [
      { text: 'Polar moment of inertia of the hollow section.', latex: 'J = \\dfrac{\\pi}{32}(d_o^4 - d_i^4) = \\dfrac{\\pi}{32}(3.0^4 - 2.0^4) = 6.38\\ \\text{in}^4' },
      { text: 'Radius to the inside surface.', latex: 'r_i = \\dfrac{2.0}{2} = 1.0\\ \\text{in.}' },
      { text: 'Shear stress at that radius.', latex: '\\tau_i = \\dfrac{T\\,r_i}{J} = \\dfrac{30(1.0)}{6.38} = 4.70\\ \\text{ksi}' },
      { text: 'For comparison, the outer surface carries 30(1.5)/6.38 = 7.05 ksi.', latex: '\\tau_o = 7.05\\ \\text{ksi}' },
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\tau = \\dfrac{T r}{J}',
    traps: [
      'Using the outer radius out of habit when the question asks about the inside surface.',
      'Putting a diameter where the formula wants a radius.',
      'Using the solid-shaft J when the shaft is hollow.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsBHollowShaft',
      props: { od: 3.0, id: 2.0, T: 30, unit: 'kip-in.' },
    },
  },
  {
    id: 'ct-mechanics-materials-b-06',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: ST,
    type: 'computational',
    difficulty: 'hard',
    statement:
      'A steel bracket is welded from two plates into an inverted tee (a 6 in. by 1 in. flange at the bottom and a 1 in. by 8 in. stem on top, total depth 9 in.) and cantilevers 4 ft from a wall. It carries a 5-kip load at its free end, as shown. Neglect the bracket weight. The maximum tensile bending stress in the bracket (ksi) is most nearly:',
    choices: [
      { id: 'c1', text: '$6.55$' },
      { id: 'c2', text: '$9.59$' },
      { id: 'c3', text: '$12.6$' },
      { id: 'c4', text: '$33.0$' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Uses the distance from the neutral axis to the bottom of the flange (3.07 in.). That gives the compressive stress at the bottom, not the tension at the top.',
      'Uses c = 9/2 = 4.5 in. as if the section were symmetric.',
      'Correct: the neutral axis is 3.07 in. above the bottom, I = 112.6 in.^4, and the top of the stem (5.93 in. above the neutral axis) is in tension: 240(5.93)/112.6 = 12.6 ksi.',
      'Adds the two plates\' own moments of inertia but forgets the parallel-axis terms, so I is far too small.',
    ],
    eli5:
      'A cantilever with a load at its tip bends downward, which stretches the top of the beam and squeezes the bottom. The biggest moment is at the wall: 5 kips times 4 ft. For an unsymmetric shape, first find the neutral axis (it sits low, near the heavy flange), then the moment of inertia about it. The top of the stem is far from the neutral axis and on the stretched side, so that is where tension is largest.',
    hint: 'A cantilever puts the top fibers in tension. Locate the centroid of the tee before using Mc/I.',
    steps: [
      { text: 'Maximum moment at the wall.', latex: 'M = P L = 5(4)(12) = 240\\ \\text{kip-in.}' },
      { text: 'Centroid measured up from the bottom of the flange.', latex: '\\bar y = \\dfrac{6(0.5) + 8(5.0)}{6 + 8} = 3.07\\ \\text{in.}' },
      { text: 'Moment of inertia about the centroid (parallel-axis theorem).', latex: 'I = \\tfrac{6(1)^3}{12} + 6(2.57)^2 + \\tfrac{1(8)^3}{12} + 8(1.93)^2 = 112.6\\ \\text{in}^4' },
      { text: 'The tension side is the top of the stem, at the distance from the neutral axis below.', latex: 'c_t = 9 - 3.07 = 5.93\\ \\text{in.}' },
      { text: 'Maximum tensile stress.', latex: '\\sigma_t = \\dfrac{M c_t}{I} = \\dfrac{240(5.93)}{112.6} = 12.6\\ \\text{ksi}' },
    ],
    handbookPage: 'p. 134',
    handbookFormula: '\\sigma_x = -\\dfrac{M y}{I}',
    traps: [
      'Using half the depth for c on an unsymmetric section.',
      'Using the distance to the wrong face: under negative moment the top is in tension.',
      'Forgetting the A d^2 terms when building I.',
      'Leaving the span in feet while the section is in inches.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsBTeeBracket',
      props: { L: 4, P: 5, bf: 6, tf: 1, hs: 8, ts: 1 },
    },
  },
  {
    id: 'ct-mechanics-materials-b-07',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: DF,
    type: 'conceptual',
    difficulty: 'easy',
    statement:
      'A simply supported rectangular timber floor joist is replaced by one of the same species, the same width and the same span, but twice the depth. The floor load is unchanged; neglect the joist self-weight. The midspan deflection of the new joist, as a fraction of the old one, is most nearly:',
    choices: [
      { id: 'c1', text: '$1/8$' },
      { id: 'c2', text: '$1/4$' },
      { id: 'c3', text: '$1/2$' },
      { id: 'c4', text: '$1$' },
    ],
    correctAnswerId: 'c1',
    choiceNotes: [
      'Correct: deflection is inversely proportional to I = bh^3/12, and doubling h multiplies I by 8.',
      'Treats the stiffness as growing with h^2, which is how the section modulus (and so the bending stress) changes, not the deflection.',
      'Treats the stiffness as growing in direct proportion to depth.',
      'Assumes deflection depends only on the load and span, so it does not change.',
    ],
    eli5:
      'How much a beam sags depends on its moment of inertia, and for a rectangle that grows with the depth cubed. Twice as deep means 2 x 2 x 2 = 8 times stiffer, so it sags one eighth as much. Depth is the cheapest way to make a floor stiffer.',
    hint: 'Deflection is proportional to 1/(EI), and I for a rectangle is bh^3/12.',
    steps: [
      { text: 'Midspan deflection of a simply supported beam under uniform load.', latex: '\\delta = \\dfrac{5wL^4}{384EI}' },
      { text: 'Only I changes; for a rectangle I grows with the cube of depth.', latex: '\\dfrac{I_2}{I_1} = \\dfrac{b(2h)^3/12}{b h^3/12} = 8' },
      { text: 'Deflection ratio.', latex: '\\dfrac{\\delta_2}{\\delta_1} = \\dfrac{I_1}{I_2} = \\dfrac{1}{8}' },
    ],
    handbookPage: 'p. 139',
    handbookFormula: 'v_{max} = -\\dfrac{5wL^4}{384EI}',
    traps: [
      'Mixing up how stress changes with depth (1/h^2) and how deflection changes (1/h^3).',
      'Assuming that doubling a dimension simply halves the deflection.',
    ],
    diagram: null,
  },
  {
    id: 'ct-mechanics-materials-b-08',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: DF,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'A short square reinforced concrete pier, 16 in. by 16 in., is 12 ft tall and reinforced with eight #9 bars (total steel area $8.00\\ \\text{in}^2$), as shown. Take $E_c = 3{,}600$ ksi and $E_s = 29{,}000$ ksi. Both materials stay elastic and are perfectly bonded. Under an axial load of 500 kips, the shortening of the pier (in.) is most nearly:',
    choices: [
      { id: 'c1', text: '$0.0053$' },
      { id: 'c2', text: '$0.0097$' },
      { id: 'c3', text: '$0.0640$' },
      { id: 'c4', text: '$0.0781$' },
    ],
    correctAnswerId: 'c3',
    choiceNotes: [
      'Leaves the height in feet (12 instead of 144 in.).',
      'Treats the whole 256-square-inch section as steel.',
      'Correct: the concrete and steel shorten together, so the axial stiffness is E_c A_c + E_s A_s = 1,124,800 kips, and 500(144)/1,124,800 = 0.0640 in.',
      'Ignores the bars and uses the gross concrete area alone.',
    ],
    eli5:
      'The concrete and the steel bars are glued together, so they squeeze by the same amount. Together they act like two springs side by side: their stiffnesses add. Steel is about eight times stiffer than concrete, so the bars help more than their small area suggests. Add E times A for each material, then use the usual PL over AE.',
    hint: 'Equal shortening means the axial stiffnesses add: use E_c A_c + E_s A_s in place of AE.',
    steps: [
      { text: 'Net concrete area (gross area minus the bars).', latex: 'A_c = 16(16) - 8.00 = 248\\ \\text{in}^2' },
      { text: 'Combined axial stiffness of the two materials in parallel.', latex: 'E_cA_c + E_sA_s = 3600(248) + 29{,}000(8.00) = 1{,}124{,}800\\ \\text{kips}' },
      { text: 'Height in inches.', latex: 'L = 12(12) = 144\\ \\text{in.}' },
      { text: 'Shortening.', latex: '\\delta = \\dfrac{PL}{E_cA_c + E_sA_s} = \\dfrac{500(144)}{1{,}124{,}800} = 0.0640\\ \\text{in.}' },
    ],
    handbookPage: 'p. 130',
    handbookFormula: '\\delta = \\dfrac{PL}{AE}',
    traps: [
      'Ignoring the reinforcement: the bars carry a real share of the load.',
      'Leaving the length in feet while the stiffness is in kips and inches.',
      'Counting the bar area twice by not subtracting it from the gross concrete area (a small error here, but a habit to avoid).',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsBPierSection',
      props: { b: 16, bars: '8 #9 bars', cover: 2.5 },
    },
  },
  {
    id: 'ct-mechanics-materials-b-09',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: DF,
    type: 'computational',
    difficulty: 'hard',
    statement:
      'A steel balcony beam ($E = 29{,}000$ ksi, $I = 110\\ \\text{in}^4$) cantilevers 8 ft from a building wall. It carries a uniform load of 0.5 kip/ft over its full length and a 2-kip railing load at its free end, as shown. The deflection at the free end (in.) is most nearly:',
    choices: [
      { id: 'c1', text: '$0.139$' },
      { id: 'c2', text: '$0.185$' },
      { id: 'c3', text: '$0.199$' },
      { id: 'c4', text: '$0.324$' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'Counts only the uniform load and forgets the railing load.',
      'Counts only the railing load and forgets the uniform load.',
      'Uses the simply supported formula 5wL^4/384EI for the uniform load instead of the cantilever formula wL^4/8EI.',
      'Correct: superpose the two cantilever cases, 0.139 in. from the uniform load plus 0.185 in. from the tip load = 0.324 in.',
    ],
    eli5:
      'When two loads act on the same elastic beam, the sag from each can be found on its own and then added. The handbook gives the tip deflection of a cantilever for a uniform load (wL^4/8EI) and for a tip load (PL^3/3EI). Put everything in kips and inches first: 0.5 kip/ft is 0.0417 kip/in., and 8 ft is 96 in.',
    hint: 'Superposition: add the cantilever tip deflection for the uniform load to the one for the end load, all in kip and inch units.',
    steps: [
      { text: 'Convert to kip and inch units.', latex: 'w = \\dfrac{0.5}{12} = 0.04167\\ \\text{kip/in.},\\quad L = 96\\ \\text{in.}' },
      { text: 'Tip deflection from the uniform load.', latex: '\\delta_w = \\dfrac{wL^4}{8EI} = \\dfrac{0.04167(96)^4}{8(29{,}000)(110)} = 0.139\\ \\text{in.}' },
      { text: 'Tip deflection from the end load.', latex: '\\delta_P = \\dfrac{PL^3}{3EI} = \\dfrac{2(96)^3}{3(29{,}000)(110)} = 0.185\\ \\text{in.}' },
      { text: 'Superpose.', latex: '\\delta = 0.139 + 0.185 = 0.324\\ \\text{in.}' },
    ],
    handbookPage: 'p. 140',
    handbookFormula: 'v_{max} = -\\dfrac{wL^4}{8EI},\\quad v_{max} = -\\dfrac{Pa^2}{6EI}(3L - a)\\ \\text{with}\\ a = L',
    traps: [
      'Leaving w in kip/ft while L is in inches, which inflates the uniform-load part twelvefold.',
      'Taking a formula from the simply supported table instead of the cantilever table.',
      'Answering with only one of the two loads.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsBBalcony',
      props: { L: 8, w: 0.5, P: 2 },
    },
  },
  {
    id: 'ct-mechanics-materials-b-10',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: DF,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'The extension stem of a buried water valve is a solid steel rod ($G = 11{,}500$ ksi) 1.5 in. in diameter and 6 ft long. Turning the valve requires a torque of 8 kip-in. at the bottom of the stem. The angle of twist of the stem between the operating nut and the valve (degrees) is most nearly:',
    choices: [
      { id: 'c1', text: '$0.10$' },
      { id: 'c2', text: '$0.48$' },
      { id: 'c3', text: '$2.29$' },
      { id: 'c4', text: '$5.77$' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'Gets the angle in radians (0.101) and reports it as degrees.',
      'Leaves the length in feet (6 instead of 72 in.).',
      'Uses the modulus of elasticity E = 29,000 ksi instead of the shear modulus G.',
      'Correct: J = 0.497 in.^4, the twist is 8(72)/(11,500 x 0.497) = 0.101 rad, which is 5.77 degrees.',
    ],
    eli5:
      'A long thin rod twists like a spring when you turn one end. The twist is torque times length divided by G times J. With the length in inches, the formula gives radians; multiply by 180/pi to get degrees. Here the stem twists almost 6 degrees before the valve starts to turn.',
    hint: 'phi = TL/(GJ) gives radians. Use G (not E), inches, and convert at the end.',
    steps: [
      { text: 'Polar moment of inertia of the solid rod.', latex: 'J = \\dfrac{\\pi d^4}{32} = \\dfrac{\\pi(1.5)^4}{32} = 0.497\\ \\text{in}^4' },
      { text: 'Length in inches.', latex: 'L = 6(12) = 72\\ \\text{in.}' },
      { text: 'Angle of twist in radians.', latex: '\\phi = \\dfrac{TL}{GJ} = \\dfrac{8(72)}{11{,}500(0.497)} = 0.101\\ \\text{rad}' },
      { text: 'Convert to degrees.', latex: '\\phi = 0.101\\left(\\dfrac{180}{\\pi}\\right) = 5.77^{\\circ}' },
    ],
    handbookPage: 'p. 133',
    handbookFormula: '\\phi = \\dfrac{TL}{GJ}',
    traps: [
      'Using E where the formula needs the shear modulus G.',
      'Forgetting that TL/GJ is in radians.',
      'Using I = pi d^4/64 instead of J = pi d^4/32.',
    ],
    diagram: null,
  },
  {
    id: 'ct-mechanics-materials-b-11',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: CB,
    type: 'computational',
    difficulty: 'medium',
    statement:
      'The plane stress element shown is taken from a gusset plate of a steel truss. The algebraically smallest (most compressive) principal stress in the plane of the element (MPa) is most nearly:',
    choices: [
      { id: 'c1', text: '$-45$' },
      { id: 'c2', text: '$-30$' },
      { id: 'c3', text: '$-15$' },
      { id: 'c4', text: '$105$' },
    ],
    correctAnswerId: 'c1',
    choiceNotes: [
      'Correct: the Mohr circle center is 30 MPa and its radius is 75 MPa, so the smaller principal stress is 30 - 75 = -45 MPa.',
      'Reads the y-face stress as if it were already principal, ignoring the shear.',
      'Uses (sigma_x - sigma_y)/2 = 60 as the center instead of (sigma_x + sigma_y)/2 = 30.',
      'This is the larger principal stress, 30 + 75 = 105 MPa.',
    ],
    eli5:
      'The figure shows 90 MPa pulling on the x faces, 30 MPa pushing on the y faces, and 45 MPa of shear. Mohr\'s circle turns that into the extreme normal stresses. Its center is the average normal stress, (90 - 30)/2 = 30 MPa, and its radius is the hypotenuse of 60 and 45, which is 75 MPa. The two principal stresses are center plus and minus radius: 105 and -45 MPa.',
    hint: 'Center C = (sigma_x + sigma_y)/2, radius R from half the difference and the shear; the smaller principal stress is C - R.',
    steps: [
      { text: 'Read the element: tension on the x faces, compression on the y faces.', latex: '\\sigma_x = 90,\\ \\sigma_y = -30,\\ \\tau_{xy} = 45\\ \\text{MPa}' },
      { text: 'Center of Mohr\'s circle.', latex: 'C = \\dfrac{90 + (-30)}{2} = 30\\ \\text{MPa}' },
      { text: 'Radius.', latex: 'R = \\sqrt{\\left(\\dfrac{90 - (-30)}{2}\\right)^2 + 45^2} = \\sqrt{60^2 + 45^2} = 75\\ \\text{MPa}' },
      { text: 'Smaller principal stress.', latex: '\\sigma_b = C - R = 30 - 75 = -45\\ \\text{MPa}' },
    ],
    handbookPage: 'p. 132',
    handbookFormula: 'C = \\dfrac{\\sigma_x + \\sigma_y}{2},\\ R = \\sqrt{\\left(\\dfrac{\\sigma_x - \\sigma_y}{2}\\right)^2 + \\tau_{xy}^2},\\ \\sigma_b = C - R',
    traps: [
      'Dropping the minus sign on the compressive stress when computing the center.',
      'Swapping the sum and difference of the normal stresses between the center and the radius.',
      'Reporting the larger principal stress when the question asks for the smaller one.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsBStressElement',
      props: { sx: 90, sy: -30, txy: 45, unit: 'MPa' },
    },
  },
  {
    id: 'ct-mechanics-materials-b-12',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: CB,
    type: 'computational',
    difficulty: 'hard',
    statement:
      'At one section of a simply supported glulam beam with the solid 6 in. by 12 in. rectangular section shown, the internal shear is 9 kips and the internal bending moment is 7.5 kip-ft (positive, sagging). Point a is 3 in. below the neutral axis. The maximum principal stress at point a (psi) is most nearly:',
    choices: [
      { id: 'c1', text: '$313$' },
      { id: 'c2', text: '$366$' },
      { id: 'c3', text: '$400$' },
      { id: 'c4', text: '$499$' },
    ],
    correctAnswerId: 'c2',
    choiceNotes: [
      'Gives only the bending stress at a and ignores the shear stress.',
      'Correct: the bending stress is 312.5 psi (tension) and the shear stress is 140.6 psi, so the larger principal stress is 156.3 + 210.2 = 366 psi.',
      'Uses Q for the whole half section (108 in.^3), which is the shear at the neutral axis, not at point a.',
      'Uses the full bending stress instead of half of it inside the square root.',
    ],
    eli5:
      'Point a feels two things at once: a pull along the beam from bending, and a sliding shear from the vertical shear force. The bending part is My/I. The shear part is VQ/(Ib), where Q is for the area below point a only. Mohr\'s circle combines them: half the normal stress, plus the radius made from half the normal stress and the shear.',
    hint: 'Find sigma = My/I and tau = VQ/(Ib) at point a, then sigma_1 = sigma/2 + sqrt((sigma/2)^2 + tau^2).',
    steps: [
      { text: 'Section properties.', latex: 'I = \\dfrac{6(12)^3}{12} = 864\\ \\text{in}^4' },
      { text: 'Bending stress at a (tension, below the neutral axis under positive moment). M = 90 kip-in.', latex: '\\sigma = \\dfrac{M y}{I} = \\dfrac{90{,}000(3)}{864} = 312.5\\ \\text{psi}' },
      { text: 'First moment of the area below point a (6 in. by 3 in., centroid 4.5 in. from the neutral axis).', latex: 'Q = 6(3)(4.5) = 81\\ \\text{in}^3' },
      { text: 'Transverse shear stress at a.', latex: '\\tau = \\dfrac{VQ}{Ib} = \\dfrac{9000(81)}{864(6)} = 140.6\\ \\text{psi}' },
      { text: 'Maximum principal stress (sigma_y = 0).', latex: '\\sigma_1 = \\dfrac{312.5}{2} + \\sqrt{\\left(\\dfrac{312.5}{2}\\right)^2 + 140.6^2} = 156.3 + 210.2 = 366\\ \\text{psi}' },
    ],
    handbookPage: 'p. 135',
    handbookFormula: '\\sigma_x = -\\dfrac{My}{I},\\quad \\tau_{xy} = \\dfrac{VQ}{Ib}',
    traps: [
      'Using Q for the full half section: that gives the shear stress at the neutral axis, not at point a.',
      'Forgetting to halve the normal stress inside the Mohr radius.',
      'Leaving the moment in kip-ft while the section is in inches.',
    ],
    diagram: {
      component: 'CtMechanicsMaterialsBRectSection',
      props: { b: 6, h: 12, ya: 3 },
    },
  },
  {
    id: 'ct-mechanics-materials-b-13',
    chapterId: 'mechanics-materials',
    version: 'B',
    topic: CB,
    type: 'conceptual',
    difficulty: 'easy',
    statement:
      'A solid circular shaft carries only a torque, and the shear stress at its outer surface is 9 ksi. The maximum tensile normal stress at the outer surface, and the planes on which it acts, are:',
    choices: [
      { id: 'c1', text: '0 ksi, since a shaft in pure torsion has no normal stress' },
      { id: 'c2', text: '4.5 ksi, on planes at 45° to the shaft axis' },
      { id: 'c3', text: '9 ksi, on planes perpendicular to the shaft axis' },
      { id: 'c4', text: '9 ksi, on planes at 45° to the shaft axis' },
    ],
    correctAnswerId: 'c4',
    choiceNotes: [
      'True only for planes perpendicular and parallel to the axis. On inclined planes, pure shear produces normal stress.',
      'Halves the shear stress as if the Mohr radius were tau/2. For pure shear the radius is tau itself.',
      'Right size, wrong planes: on the cross-section (perpendicular to the axis) the stress is pure shear, with no normal stress.',
      'Correct: pure shear gives a Mohr circle centered at the origin with radius 9 ksi, so the principal stresses are +9 and -9 ksi, on planes at 45° to the axis.',
    ],
    eli5:
      'Twist a piece of chalk and it snaps along a spiral at 45°. That is because pure shear is the same as equal tension and compression on planes turned 45°. The tension there is as big as the shear, 9 ksi. Brittle materials fail in tension, so they break on that 45° helix.',
    hint: 'Draw Mohr\'s circle for pure shear: center at zero, radius equal to tau.',
    steps: [
      { text: 'On the shaft surface the element is in pure shear.', latex: '\\sigma_x = \\sigma_y = 0,\\ \\tau_{xy} = 9\\ \\text{ksi}' },
      { text: 'Mohr\'s circle center and radius.', latex: 'C = 0,\\quad R = \\sqrt{0^2 + 9^2} = 9\\ \\text{ksi}' },
      { text: 'Principal stresses.', latex: '\\sigma_{a,b} = C \\pm R = \\pm 9\\ \\text{ksi}' },
      { text: 'On Mohr\'s circle the principal points are 90° from the shear points, so on the element they are 45° from the shaft axis.', latex: '2\\theta_p = 90^{\\circ} \\Rightarrow \\theta_p = 45^{\\circ}' },
    ],
    handbookPage: 'p. 132',
    handbookFormula: 'C = \\dfrac{\\sigma_x + \\sigma_y}{2},\\quad R = \\sqrt{\\left(\\dfrac{\\sigma_x - \\sigma_y}{2}\\right)^2 + \\tau_{xy}^2}',
    traps: [
      'Thinking that no normal stress on the cross-section means no normal stress anywhere.',
      'Forgetting that angles on Mohr\'s circle are double the angles on the element.',
    ],
    diagram: null,
  },
];

export default PROBLEMS;
