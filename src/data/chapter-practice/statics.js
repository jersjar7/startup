// Chapter practice: Statics (12 questions, 2 per lesson)

const PROBLEMS = [
  {
    id: 'stat-fsr-cp1',
    type: 'computational',
    statement:
      'Three concurrent forces act at a connection: $120$ N directed along the positive x-axis, $120$ N directed along the positive y-axis, and $30$ N directed along the negative x-axis. What is the magnitude and direction of the resultant?',
    choices: [
      { id: 'c1', text: '$270$ N at $45\\degree$ from the horizontal' },
      { id: 'c2', text: '$150$ N at $53.1\\degree$ from the horizontal' },
      { id: 'c3', text: '$150$ N at $36.9\\degree$ from the horizontal' },
      { id: 'c4', text: '$90$ N at $53.1\\degree$ from the horizontal' },
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5:
      'Sum the components by axis. Along x: $120 - 30 = 90$ N. Along y: $120$ N. The resultant is $R = \\sqrt{90^2 + 120^2} = 150$ N (a 3-4-5 triple scaled by 30), and the angle from the horizontal is $\\arctan(120/90) = 53.1\\degree$. Choice A adds all three magnitudes ($120 + 120 + 30 = 270$), which is invalid for non-collinear forces. Choice C has the correct magnitude but uses $\\arctan(90/120) = 36.9\\degree$, the angle from the vertical. Choice D forgets to subtract the $30$ N opposing force, using $R_x = 120$ alone is not the slip here — it instead reports only the corrected $R_x$ as the magnitude.',
    hint: 'Add components by axis first ($R_x = \\sum F_x$, $R_y = \\sum F_y$), then combine with the Pythagorean theorem.',
    steps: [
      {
        text: 'Sum the x-components (the negative-x force subtracts):',
        latex: 'R_x = 120 - 30 = 90\\,\\text{N}',
      },
      {
        text: 'Sum the y-components:',
        latex: 'R_y = 120\\,\\text{N}',
      },
      {
        text: 'Resultant magnitude:',
        latex: 'R = \\sqrt{90^2 + 120^2} = \\sqrt{8{,}100 + 14{,}400} = \\sqrt{22{,}500} = 150\\,\\text{N}',
      },
      {
        text: 'Direction from the horizontal:',
        latex: '\\theta = \\arctan\\!\\left(\\frac{120}{90}\\right) = 53.1\\degree',
      },
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'R = \\sqrt{R_x^2 + R_y^2}',
    videoUrl: null,
    traps: [
      'Adding force magnitudes directly instead of summing components by axis',
      'Forgetting that the negative-x force subtracts from the positive-x force',
    ],
    diagram: null,
    lessonId: 'force-systems-resultants',
    chapterId: 'statics',
  },
  {
    id: 'stat-fsr-cp2',
    type: 'computational',
    statement:
      'A $200$ N force is applied at point P located at coordinates $(4, 3)$ m relative to origin O. The force is directed $30\\degree$ above the positive x-axis. What is the moment of this force about point O?',
    choices: [
      { id: 'c1', text: '$400$ N$\\cdot$m counterclockwise' },
      { id: 'c2', text: '$519.6$ N$\\cdot$m clockwise' },
      { id: 'c3', text: '$119.6$ N$\\cdot$m clockwise' },
      { id: 'c4', text: '$392.8$ N$\\cdot$m counterclockwise' },
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5:
      'The fastest route is the scalar cross product $M_z = x F_y - y F_x$. Resolve the force: $F_x = 200\\cos 30\\degree = 173.2$ N, $F_y = 200\\sin 30\\degree = 100$ N. Then $M_z = (4)(100) - (3)(173.2) = 400 - 519.6 = -119.6$ N$\\cdot$m, where the negative sign means clockwise. Choice A keeps only the $x F_y$ term ($400$) and drops $y F_x$. Choice B keeps only the $y F_x$ term ($519.6$). Choice D swaps the trig functions, using $F_x = 100$ and $F_y = 173.2$ to get $(4)(173.2) - (3)(100) = 392.8$.',
    hint: 'Use $M_z = x F_y - y F_x$. Resolve the force into components first, then apply both terms.',
    steps: [
      {
        text: 'Resolve the force into components:',
        latex: 'F_x = 200\\cos 30\\degree = 173.2\\,\\text{N}, \\quad F_y = 200\\sin 30\\degree = 100\\,\\text{N}',
      },
      {
        text: 'Apply the 2D cross product about O:',
        latex: 'M_z = x F_y - y F_x = (4)(100) - (3)(173.2)',
      },
      {
        text: 'Evaluate:',
        latex: 'M_z = 400 - 519.6 = -119.6\\,\\text{N}\\cdot\\text{m}',
      },
      {
        text: 'The negative result indicates a clockwise moment of $119.6$ N$\\cdot$m.',
        latex: null,
      },
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'M_z = x F_y - y F_x',
    videoUrl: null,
    traps: [
      'Keeping only one of the two terms in $x F_y - y F_x$',
      'Swapping sine and cosine when resolving the force components',
    ],
    diagram: null,
    lessonId: 'force-systems-resultants',
    chapterId: 'statics',
  },
  {
    id: 'stat-efb-cp1',
    type: 'computational',
    statement:
      'A beam has a pin at A (left end) and a roller at B located $8$ m to the right of A. The beam extends $2$ m past B as an overhang, and a single $10$ kN downward load is applied at the free tip of the overhang ($10$ m from A). What is the vertical reaction at A?',
    choices: [
      { id: 'c1', text: '$12.5$ kN upward' },
      { id: 'c2', text: '$5.0$ kN upward' },
      { id: 'c3', text: '$2.5$ kN upward' },
      { id: 'c4', text: '$2.5$ kN downward' },
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5:
      'Sum moments about B to find the other reaction, then use vertical equilibrium. Taking moments about A: $B_y(8) - 10(10) = 0$, so $B_y = 12.5$ kN. Then $\\sum F_y = 0$: $A_y + 12.5 - 10 = 0$, giving $A_y = -2.5$ kN, i.e. $2.5$ kN downward. The overhang load actually pulls the pin down (it acts as a tie-down). Choice A reports $B_y$ instead of $A_y$. Choice B splits the load evenly, valid only for a midspan load between the supports. Choice C has the right magnitude but the wrong direction — the sign matters here because an overhang can reverse the reaction.',
    hint: 'Sum moments about B to get $B_y$, then apply $\\sum F_y = 0$. Watch the sign — an overhang load can produce a downward reaction.',
    steps: [
      {
        text: 'Sum moments about A (CCW positive), load is $10$ m from A, $B_y$ is $8$ m from A:',
        latex: 'B_y(8) - 10(10) = 0 \\quad \\Rightarrow \\quad B_y = 12.5\\,\\text{kN}',
      },
      {
        text: 'Apply vertical equilibrium:',
        latex: 'A_y + B_y - 10 = 0 \\quad \\Rightarrow \\quad A_y = 10 - 12.5 = -2.5\\,\\text{kN}',
      },
      {
        text: 'The negative sign means $A_y$ acts downward — the pin holds the beam down against the overhang load:',
        latex: 'A_y = 2.5\\,\\text{kN (downward)}',
      },
    ],
    handbookPage: 'p. 94, Equilibrium Requirements',
    handbookFormula: '\\sum F_n = 0 \\quad \\sum M_n = 0',
    videoUrl: null,
    traps: [
      'Reporting the reaction at B instead of A',
      'Ignoring the sign — an overhang load can reverse the near-support reaction to downward',
    ],
    diagram: null,
    lessonId: 'equilibrium-free-body-diagrams',
    chapterId: 'statics',
  },
  {
    id: 'stat-efb-cp2',
    type: 'computational',
    statement:
      'A horizontal bar is hinged to a wall at A and extends $2$ m to its free end, where a $600$ N weight hangs vertically. A cable runs from the free end back up to the wall, making a $30\\degree$ angle above the horizontal bar. What is the tension in the cable?',
    choices: [
      { id: 'c1', text: '$300$ N' },
      { id: 'c2', text: '$1{,}200$ N' },
      { id: 'c3', text: '$692.8$ N' },
      { id: 'c4', text: '$519.6$ N' },
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5:
      'Sum moments about the hinge A so the pin reactions drop out. The weight acts at the $2$ m tip (clockwise), and the cable tension provides a counterclockwise moment through its vertical component $T\\sin 30\\degree$ acting at the $2$ m tip. The horizontal component of the cable passes along the bar through... it acts at the tip too, but its line of action is horizontal through A-level, so its moment arm about A is zero (the bar is horizontal). So $T\\sin 30\\degree (2) = 600(2)$, giving $T = 600/\\sin 30\\degree = 1{,}200$ N. Choice C uses $\\cos 30\\degree$ instead of $\\sin 30\\degree$ ($600/\\cos 30\\degree = 692.8$). Choice A applies $\\sin 30\\degree$ to the weight ($600 \\times 0.5$) instead of the tension. Choice D is $600/\\tan 30\\degree$ confusion.',
    hint: 'Sum moments about the hinge. Only the vertical component of the cable tension provides a moment arm on the horizontal bar.',
    steps: [
      {
        text: 'Sum moments about A (the weight and the cable both act at the $2$ m tip):',
        latex: '\\sum M_A = 0: \\quad T\\sin 30\\degree\\,(2) - 600(2) = 0',
      },
      {
        text: 'The $2$ m arm cancels:',
        latex: 'T\\sin 30\\degree = 600',
      },
      {
        text: 'Solve for the tension:',
        latex: 'T = \\frac{600}{\\sin 30\\degree} = \\frac{600}{0.5} = 1{,}200\\,\\text{N}',
      },
    ],
    handbookPage: 'p. 94, Equilibrium Requirements',
    handbookFormula: '\\sum M_n = 0',
    videoUrl: null,
    traps: [
      'Using $\\cos 30\\degree$ instead of $\\sin 30\\degree$ for the cable vertical component',
      'Applying the trig factor to the weight rather than to the cable tension',
    ],
    diagram: null,
    lessonId: 'equilibrium-free-body-diagrams',
    chapterId: 'statics',
  },
  {
    id: 'stat-tjs-cp1',
    type: 'computational',
    statement:
      'A truss is pinned at A$(0,0)$ and roller-supported at C$(9,0)$ m along the bottom chord, with a top joint E at $(3,4)$ m. Diagonal AE connects A to E, and bottom-chord member AB runs from A to joint B$(3,0)$ directly below E. A single $30$ kN downward load is applied at the bottom-chord joint B. Using the method of joints at A, what is the force in diagonal member AE?',
    choices: [
      { id: 'c1', text: '$25.0$ kN, compression' },
      { id: 'c2', text: '$20.0$ kN, compression' },
      { id: 'c3', text: '$15.0$ kN, tension' },
      { id: 'c4', text: '$33.3$ kN, compression' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5:
      'The load is off-center, so the reactions are unequal — find them first. Taking moments about A: $30(3) - C_y(9) = 0$, so $C_y = 10$ kN and $A_y = 30 - 10 = 20$ kN. At joint A the only members are diagonal AE and bottom chord AB. Diagonal AE runs from A$(0,0)$ to E$(3,4)$, length $5$ (a 3-4-5 triangle), direction cosines $(0.6, 0.8)$. Vertical equilibrium at A: $20 + F_{AE}(0.8) = 0$, so $F_{AE} = -25$ kN — the negative sign means compression. Choice B is the reaction $A_y$, not the member force. Choice C is the bottom-chord force AB ($-F_{AE}(0.6) = 15$ kN tension), the other member at the joint. Choice D swaps the direction cosines, dividing the reaction by $0.6$ instead of $0.8$.',
    hint: 'The load is off-center, so reactions are unequal — take moments about A to get $A_y$. Then at joint A only AE has a vertical component; use $\\sum F_y = 0$.',
    steps: [
      {
        text: 'Reactions (load is off midspan). Sum moments about A:',
        latex: '30(3) - C_y(9) = 0 \\quad \\Rightarrow \\quad C_y = 10\\,\\text{kN}, \\quad A_y = 20\\,\\text{kN}',
      },
      {
        text: 'Diagonal AE: A$(0,0)$ to E$(3,4)$, length $= 5$, direction cosines $(0.6, 0.8)$. At joint A, $\\sum F_y = 0$ (tension assumed):',
        latex: '20 + F_{AE}(0.8) = 0 \\quad \\Rightarrow \\quad F_{AE} = -25\\,\\text{kN (compression)}',
      },
      {
        text: 'Check via horizontal equilibrium (gives the bottom chord, a different member):',
        latex: 'F_{AB} + F_{AE}(0.6) = 0 \\quad \\Rightarrow \\quad F_{AB} = 15.0\\,\\text{kN (tension)}',
      },
    ],
    handbookPage: 'p. 97, Plane Truss: Method of Joints',
    handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0',
    videoUrl: null,
    traps: [
      'Assuming equal reactions when the load is off-center — take moments to get the unequal $A_y$',
      'Reporting the reaction ($20$ kN) or the bottom-chord force ($15$ kN) instead of the diagonal AE',
    ],
    diagram: null,
    lessonId: 'trusses-joints-sections',
    chapterId: 'statics',
  },
  {
    id: 'stat-tjs-cp2',
    type: 'conceptual',
    statement:
      'At joint K of a loaded truss, three members meet: two collinear horizontal top-chord members and one vertical web member. A downward external load $P$ is applied directly at joint K. What is the force in the vertical member?',
    choices: [
      { id: 'c1', text: 'It carries a force equal to $P$ (it is not a zero-force member)' },
      { id: 'c2', text: 'It is a zero-force member' },
      { id: 'c3', text: 'It carries $P/2$, split between the two top-chord members' },
      { id: 'c4', text: 'It carries $2P$ because two members are collinear' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5:
      'The zero-force rule (Rule 2) says that when three members meet at an unloaded joint and two are collinear, the third (non-collinear) member is zero-force. The critical word is unloaded. Here a load $P$ is applied at the joint, so the rule does not apply. Summing vertical forces at K: the two horizontal top-chord members have no vertical component, so the vertical member alone must balance the load — $F_{vert} = P$. Choice B is the trap: applying the zero-force rule without checking for the applied load. Choice C wrongly splits the load into the collinear members, which carry only horizontal force. Choice D has no physical basis.',
    hint: 'Check the zero-force rule carefully — it requires an unloaded joint. What balances the vertical load here?',
    steps: [
      {
        text: 'Rule 2 (zero-force) applies only when the joint is unloaded. Here a load $P$ acts at the joint, so the rule is void.',
        latex: null,
      },
      {
        text: 'The two collinear top-chord members are horizontal and contribute no vertical force component.',
        latex: null,
      },
      {
        text: 'Vertical equilibrium at K:',
        latex: '\\sum F_y = 0: \\quad F_{vert} - P = 0 \\quad \\Rightarrow \\quad F_{vert} = P',
      },
    ],
    handbookPage: 'p. 97, Plane Truss: Method of Joints',
    handbookFormula: '\\sum F_V = 0',
    videoUrl: null,
    traps: [
      'Applying the zero-force rule without verifying the joint is unloaded',
      'Assuming collinear horizontal members can carry vertical load',
    ],
    diagram: null,
    lessonId: 'trusses-joints-sections',
    chapterId: 'statics',
  },
  {
    id: 'stat-fri-cp1',
    type: 'computational',
    statement:
      'A $400$ N block rests on a $20\\degree$ incline with a coefficient of static friction of $0.40$. No external force is applied. What is the friction force acting on the block?',
    choices: [
      { id: 'c1', text: '$150.4$ N' },
      { id: 'c2', text: '$160.0$ N' },
      { id: 'c3', text: '$136.8$ N' },
      { id: 'c4', text: '$375.9$ N' },
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5:
      'First check whether the block slides. The driving force down the incline is $W\\sin\\theta = 400\\sin 20\\degree = 136.8$ N. The maximum available friction is $\\mu_s N = 0.40(400\\cos 20\\degree) = 0.40(375.9) = 150.4$ N. Since $136.8 < 150.4$, the block does not slide, so friction only develops as much as it needs to: it equals the down-slope component, $136.8$ N. Choice A is the maximum possible friction, but friction does not reach its cap unless motion impends. Choice B uses $\\mu_s W$ ($0.40 \\times 400$) forgetting the $\\cos\\theta$ in the normal force. Choice D is the normal force itself.',
    hint: 'Compare the down-slope gravity component to the maximum friction $\\mu_s N$. If it does not slide, friction equals the demand, not the cap.',
    steps: [
      {
        text: 'Down-slope gravity component (the friction demand):',
        latex: 'W\\sin\\theta = 400\\sin 20\\degree = 136.8\\,\\text{N}',
      },
      {
        text: 'Maximum available friction:',
        latex: 'F_{\\max} = \\mu_s N = 0.40(400\\cos 20\\degree) = 0.40(375.9) = 150.4\\,\\text{N}',
      },
      {
        text: 'Since $136.8 < 150.4$, the block is static and friction equals the demand:',
        latex: 'F = 136.8\\,\\text{N}',
      },
    ],
    handbookPage: 'p. 96, Friction',
    handbookFormula: 'F \\leq \\mu_s N',
    videoUrl: null,
    traps: [
      'Reporting $\\mu_s N$ when the block is not on the verge of sliding',
      'Using $\\mu_s W$ instead of $\\mu_s W\\cos\\theta$ for the maximum friction',
    ],
    diagram: null,
    lessonId: 'friction',
    chapterId: 'statics',
  },
  {
    id: 'stat-fri-cp2',
    type: 'computational',
    statement:
      'An $800$ N block rests on a $30\\degree$ incline with a coefficient of static friction of $0.25$. A horizontal force $P$ is applied (pushing toward the incline). What minimum $P$ is needed to keep the block from sliding down?',
    choices: [
      { id: 'c1', text: '$461.9$ N' },
      { id: 'c2', text: '$228.9$ N' },
      { id: 'c3', text: '$261.9$ N' },
      { id: 'c4', text: '$773.5$ N' },
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5:
      'The block tends to slide down, so friction acts up the incline at its maximum. A horizontal $P$ increases the normal force because part of $P$ presses into the surface: $N = W\\cos\\theta + P\\sin\\theta$. At impending downward motion, the up-slope resistances (the up-slope component of $P$ plus friction) balance the down-slope weight component: $W\\sin\\theta = P\\cos\\theta + \\mu_s N$. Substituting $N$ and solving gives $P = W(\\sin\\theta - \\mu_s\\cos\\theta)/(\\cos\\theta + \\mu_s\\sin\\theta) = 228.9$ N. Choice A ignores friction entirely ($P = W\\tan\\theta = 461.9$). Choice C uses $N = W\\cos\\theta$ only, forgetting that $P$ also adds to the normal force. Choice D points friction the wrong way (down-slope): using $W\\sin\\theta = P\\cos\\theta - \\mu_s N$ gives $P = W(\\sin\\theta + \\mu_s\\cos\\theta)/(\\cos\\theta - \\mu_s\\sin\\theta) = 773.5$ N — but with the block on the verge of sliding down, friction must resist that motion by acting up-slope.',
    hint: 'Friction acts up-slope at its max. Remember the horizontal $P$ also increases the normal force: $N = W\\cos\\theta + P\\sin\\theta$.',
    steps: [
      {
        text: 'Normal force includes the inward component of $P$:',
        latex: 'N = W\\cos\\theta + P\\sin\\theta',
      },
      {
        text: 'Impending sliding down — balance along the incline ($P$ up-slope component plus friction resist the weight):',
        latex: 'W\\sin\\theta = P\\cos\\theta + \\mu_s(W\\cos\\theta + P\\sin\\theta)',
      },
      {
        text: 'Solve for $P$:',
        latex: 'P = \\frac{W(\\sin\\theta - \\mu_s\\cos\\theta)}{\\cos\\theta + \\mu_s\\sin\\theta} = \\frac{800(0.5 - 0.25 \\times 0.866)}{0.866 + 0.25 \\times 0.5}',
      },
      {
        text: 'Evaluate:',
        latex: 'P = \\frac{800(0.2835)}{0.991} = \\frac{226.8}{0.991} = 228.9\\,\\text{N}',
      },
    ],
    handbookPage: 'p. 96, Friction',
    handbookFormula: 'F \\leq \\mu_s N',
    videoUrl: null,
    traps: [
      'Ignoring friction and using $P = W\\tan\\theta$',
      'Pointing friction down-slope instead of up-slope when the block is about to slide down',
    ],
    diagram: null,
    lessonId: 'friction',
    chapterId: 'statics',
  },
  {
    id: 'stat-ccs-cp1',
    type: 'computational',
    statement:
      'A solid rectangle is $100$ mm wide and $120$ mm tall. A $40$ mm wide by $40$ mm tall rectangular notch is removed from the top, centered horizontally, with its top edge flush with the top of the rectangle. What is the distance from the bottom of the section to the centroid ($\\bar{y}$)?',
    choices: [
      { id: 'c1', text: '$60.0$ mm' },
      { id: 'c2', text: '$53.8$ mm' },
      { id: 'c3', text: '$50.0$ mm' },
      { id: 'c4', text: '$46.2$ mm' },
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5:
      'Treat the notch as negative area. The full rectangle has $A_1 = 100 \\times 120 = 12{,}000$ mm$^2$ with centroid at $y_1 = 60$ mm. The removed notch has $A_2 = 40 \\times 40 = 1{,}600$ mm$^2$ with its centroid at $y_2 = 120 - 20 = 100$ mm. Using subtraction: $\\bar{y} = (12{,}000(60) - 1{,}600(100))/(12{,}000 - 1{,}600) = 560{,}000/10{,}400 = 53.8$ mm. Removing material from the top pulls the centroid down below mid-height. Choice A ignores the notch ($60$ mm). Choice C is the geometric mid-height. Choice D over-corrects, as if material were added at the top instead of removed.',
    hint: 'Treat the removed notch as a negative area; subtract its $A y$ from the numerator and its $A$ from the denominator.',
    steps: [
      {
        text: 'Full rectangle:',
        latex: 'A_1 = 100 \\times 120 = 12{,}000\\,\\text{mm}^2, \\quad y_1 = 60\\,\\text{mm}',
      },
      {
        text: 'Removed notch (centroid $20$ mm below the top):',
        latex: 'A_2 = 40 \\times 40 = 1{,}600\\,\\text{mm}^2, \\quad y_2 = 100\\,\\text{mm}',
      },
      {
        text: 'Composite centroid (subtract the hole):',
        latex: '\\bar{y} = \\frac{12{,}000(60) - 1{,}600(100)}{12{,}000 - 1{,}600} = \\frac{720{,}000 - 160{,}000}{10{,}400} = \\frac{560{,}000}{10{,}400} = 53.8\\,\\text{mm}',
      },
    ],
    handbookPage: 'p. 95, Centroid of Area',
    handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
    videoUrl: null,
    traps: [
      'Forgetting to subtract the notch area from the denominator as well as the numerator',
      'Adding the notch contribution instead of subtracting it',
    ],
    diagram: null,
    lessonId: 'centroids-composite-shapes',
    chapterId: 'statics',
  },
  {
    id: 'stat-ccs-cp2',
    type: 'computational',
    statement:
      'A composite section consists of a rectangle $60$ mm wide and $40$ mm tall, with a triangle mounted on top of it. The triangle has a $60$ mm base (matching the rectangle width) and a $30$ mm height, with its apex pointing up. What is the distance from the bottom of the section to the centroid ($\\bar{y}$)?',
    choices: [
      { id: 'c1', text: '$35.0$ mm' },
      { id: 'c2', text: '$29.5$ mm' },
      { id: 'c3', text: '$25.0$ mm' },
      { id: 'c4', text: '$28.2$ mm' },
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5:
      'Split into a rectangle and a triangle. Rectangle: $A_1 = 60 \\times 40 = 2{,}400$ mm$^2$, centroid at $y_1 = 20$ mm. Triangle: $A_2 = \\frac{1}{2}(60)(30) = 900$ mm$^2$; its centroid sits one-third of its height above its base, so $y_2 = 40 + 30/3 = 50$ mm. Then $\\bar{y} = (2{,}400(20) + 900(50))/(2{,}400 + 900) = 93{,}000/3{,}300 = 28.2$ mm. Choice B uses the triangle midpoint ($40 + 15 = 55$) instead of the one-third point. Choice A is the simple average of $20$ and $50$, ignoring the area weighting. Choice C underweights the triangle.',
    hint: 'The centroid of a triangle is one-third of its height above its base, then add the rectangle height to reference from the bottom.',
    steps: [
      {
        text: 'Rectangle:',
        latex: 'A_1 = 60 \\times 40 = 2{,}400\\,\\text{mm}^2, \\quad y_1 = 20\\,\\text{mm}',
      },
      {
        text: 'Triangle (centroid one-third of height above its base at $40$ mm):',
        latex: 'A_2 = \\tfrac{1}{2}(60)(30) = 900\\,\\text{mm}^2, \\quad y_2 = 40 + \\frac{30}{3} = 50\\,\\text{mm}',
      },
      {
        text: 'Composite centroid:',
        latex: '\\bar{y} = \\frac{2{,}400(20) + 900(50)}{2{,}400 + 900} = \\frac{48{,}000 + 45{,}000}{3{,}300} = \\frac{93{,}000}{3{,}300} = 28.2\\,\\text{mm}',
      },
    ],
    handbookPage: 'p. 95, Centroid of Area',
    handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
    videoUrl: null,
    traps: [
      'Using the triangle midpoint instead of the one-third-height centroid',
      'Taking a simple average of the two centroids without area weighting',
    ],
    diagram: null,
    lessonId: 'centroids-composite-shapes',
    chapterId: 'statics',
  },
  {
    id: 'stat-ami-cp1',
    type: 'computational',
    statement:
      'A hollow rectangular (box) cross section has outer dimensions $100$ mm wide by $150$ mm tall. A concentric rectangular void $60$ mm wide by $110$ mm tall is removed. What is the moment of inertia about the centroidal horizontal axis?',
    choices: [
      { id: 'c1', text: '$21.5 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c2', text: '$28.1 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c3', text: '$6.7 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c4', text: '$34.8 \\times 10^6\\,\\text{mm}^4$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5:
      'Because the void is concentric, both rectangles share the same centroidal axis, so you simply subtract: $I = \\frac{b_o h_o^3 - b_i h_i^3}{12}$. Outer: $100(150)^3 = 337.5 \\times 10^6$. Inner: $60(110)^3 = 79.86 \\times 10^6$. Difference $= 257.64 \\times 10^6$, divided by $12 = 21.5 \\times 10^6$ mm$^4$. Choice B is the solid outer rectangle alone ($337.5/12 = 28.1$). Choice C subtracts areas, not the cubed-height terms. Choice D mistakenly subtracts $b_i h_i^3$ before cubing or mixes the dimensions.',
    hint: 'For a concentric void, the axes coincide: $I = (b_o h_o^3 - b_i h_i^3)/12$. No parallel-axis transfer is needed.',
    steps: [
      {
        text: 'Outer rectangle contribution:',
        latex: '\\frac{b_o h_o^3}{12} = \\frac{100 \\times 150^3}{12} = \\frac{337.5 \\times 10^6}{12} = 28.125 \\times 10^6\\,\\text{mm}^4',
      },
      {
        text: 'Inner void contribution (same centroidal axis):',
        latex: '\\frac{b_i h_i^3}{12} = \\frac{60 \\times 110^3}{12} = \\frac{79.86 \\times 10^6}{12} = 6.655 \\times 10^6\\,\\text{mm}^4',
      },
      {
        text: 'Subtract:',
        latex: 'I = 28.125 \\times 10^6 - 6.655 \\times 10^6 = 21.5 \\times 10^6\\,\\text{mm}^4',
      },
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'I_x = \\frac{b_o h_o^3 - b_i h_i^3}{12}',
    videoUrl: null,
    traps: [
      'Using only the outer rectangle and forgetting to subtract the void',
      'Subtracting areas instead of the $bh^3$ terms',
    ],
    diagram: null,
    lessonId: 'area-moments-of-inertia',
    chapterId: 'statics',
  },
  {
    id: 'stat-ami-cp2',
    type: 'computational',
    statement:
      'A solid circular cross section has a diameter of $100$ mm. Using the parallel axis theorem, what is the moment of inertia about an axis tangent to the edge of the circle (in its own plane)?',
    choices: [
      { id: 'c1', text: '$4.9 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c2', text: '$19.6 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c3', text: '$24.5 \\times 10^6\\,\\text{mm}^4$' },
      { id: 'c4', text: '$83.4 \\times 10^6\\,\\text{mm}^4$' },
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5:
      'A tangent axis is offset from the centroid by one radius, $d = r = 50$ mm. The centroidal moment is $\\bar{I} = \\pi r^4/4 = \\pi(50)^4/4 = 4.91 \\times 10^6$ mm$^4$. The transfer term is $A d^2 = \\pi(50)^2(50)^2 = \\pi(2{,}500)(2{,}500) = 19.63 \\times 10^6$. Adding: $I = 4.91 + 19.63 = 24.5 \\times 10^6$ mm$^4$. Choice A forgets the transfer term and reports $\\bar{I}$ only. Choice B reports the transfer term only. Choice D uses $d = $ diameter $= 100$ mm instead of the radius in $Ad^2$.',
    hint: 'A tangent axis is one radius away from the centroid. Apply $I = \\bar{I} + Ad^2$ with $d = r$.',
    steps: [
      {
        text: 'Centroidal moment of inertia for a circle:',
        latex: '\\bar{I} = \\frac{\\pi r^4}{4} = \\frac{\\pi (50)^4}{4} = 4.91 \\times 10^6\\,\\text{mm}^4',
      },
      {
        text: 'Transfer distance equals the radius ($d = 50$ mm):',
        latex: 'A d^2 = \\pi (50)^2 (50)^2 = \\pi (2{,}500)(2{,}500) = 19.63 \\times 10^6\\,\\text{mm}^4',
      },
      {
        text: 'Parallel axis theorem:',
        latex: 'I = \\bar{I} + A d^2 = 4.91 \\times 10^6 + 19.63 \\times 10^6 = 24.5 \\times 10^6\\,\\text{mm}^4',
      },
    ],
    handbookPage: 'pp. 98–100',
    handbookFormula: 'I = \\bar{I} + Ad^2',
    videoUrl: null,
    traps: [
      'Forgetting the $Ad^2$ transfer term and reporting only the centroidal value',
      'Using the diameter instead of the radius for the transfer distance $d$',
    ],
    diagram: null,
    lessonId: 'area-moments-of-inertia',
    chapterId: 'statics',
  },
];

export default PROBLEMS;
