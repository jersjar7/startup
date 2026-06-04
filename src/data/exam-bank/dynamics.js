// Exam bank: dynamics
// Auto-extracted from lesson files — 24 questions

const PROBLEMS = [
  {
    id: 'dyn-pk-ex1',
    type: 'computational',
    statement: 'A truck accelerates uniformly from $10\\,\\text{m/s}$ to $30\\,\\text{m/s}$ over a distance of $200\\,\\text{m}$. What is the acceleration?',
    choices: [
      {
        id: 'c1',
        text: '$0.10\\,\\text{m/s}^2$'
      },
      {
        id: 'c2',
        text: '$100\\,\\text{m/s}^2$'
      },
      {
        id: 'c3',
        text: '$4.0\\,\\text{m/s}^2$'
      },
      {
        id: 'c4',
        text: '$2.0\\,\\text{m/s}^2$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'You have initial velocity, final velocity, and distance — but no time. That combination screams v-squared equation. Plug in and solve for a. The 0.10 m/s^2 choice comes from dividing the velocity difference by the distance (20/200). The 4.0 m/s^2 choice comes from dropping the factor of 2 and computing (v^2 - v_0^2)/s = 800/200.',
    hint: 'Which kinematic equation connects two velocities and a distance without needing time?',
    steps: [
      {
        text: 'No time given — use the v-squared equation:',
        latex: 'v^2 = v_0^2 + 2a(s - s_0)'
      },
      {
        text: 'Plug in:',
        latex: '30^2 = 10^2 + 2a(200)'
      },
      {
        text: 'Solve:',
        latex: '900 - 100 = 400a \\implies a = \\frac{800}{400} = 2.0\\,\\text{m/s}^2'
      }
    ],
    handbookPage: 'p. 104',
    handbookFormula: 'v^2 = v_0^2 + 2a_0(s - s_0)',
    videoUrl: null,
    traps: [
      'Dividing velocity change by distance instead of using the v-squared equation',
      'Forgetting to square the velocities'
    ],
    diagram: null,
    lessonId: 'particle-kinematics',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-pk-ex2',
    type: 'computational',
    statement: 'A projectile is launched from ground level at $40\\,\\text{m/s}$ at $45\\degree$ above the horizontal. What is the total horizontal range? Use $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$81.5\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$115.3\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$163.1\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$326.1\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'For range, you can either use the range formula $R = v_0^2 \\sin(2\\theta) / g$, or work it from first principles: find time of flight from the vertical equation, then multiply by horizontal velocity. At 45 degrees, $\\sin(90°) = 1$, so $R = v_0^2 / g$. The 115.3 m choice comes from using $v_0 \\sin 45°$ instead of $v_0^2$. The 326.1 m choice comes from doubling the correct answer — maybe computing total distance incorrectly.',
    hint: 'For a symmetric projectile (launched from and landing at the same height), use the range formula or find the total flight time from the vertical motion.',
    steps: [
      {
        text: 'Vertical component:',
        latex: 'v_{0y} = 40\\sin 45\\degree = 28.28\\,\\text{m/s}'
      },
      {
        text: 'Time of flight (returns to ground level):',
        latex: 't = \\frac{2v_{0y}}{g} = \\frac{2(28.28)}{9.81} = 5.77\\,\\text{s}'
      },
      {
        text: 'Horizontal range:',
        latex: 'R = v_{0x} \\cdot t = 40\\cos 45\\degree \\times 5.77 = 28.28 \\times 5.77 = 163.1\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 104',
    handbookFormula: 'x = v_0 \\cos\\theta \\cdot t + x_0',
    videoUrl: null,
    traps: [
      'Using the full velocity (40 m/s) for horizontal distance instead of the horizontal component',
      'Forgetting to double the half-flight time when computing total range'
    ],
    diagram: {
      component: 'ProjectileLaunch',
      props: {
        v0: 40,
        angle: 45
      }
    },
    lessonId: 'particle-kinematics',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-pk-ex3',
    type: 'conceptual',
    statement: 'A particle moves along a curved path at constant speed. Which statement about its acceleration is correct?',
    choices: [
      {
        id: 'c1',
        text: 'The acceleration is normal only, directed toward the center of curvature.'
      },
      {
        id: 'c2',
        text: 'The acceleration is tangential only, directed along the path.'
      },
      {
        id: 'c3',
        text: 'The acceleration is zero because the speed is constant.'
      },
      {
        id: 'c4',
        text: 'The acceleration has both tangential and normal components.'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Constant speed means the tangential acceleration is zero — the particle is not speeding up or slowing down. But velocity is a vector, and on a curved path the direction is always changing. That direction change requires a centripetal (normal) acceleration pointing toward the center of curvature. So the acceleration is purely normal. This is the concept behind uniform circular motion.',
    hint: 'Acceleration is a vector. If speed is constant but direction changes, is there still acceleration?',
    steps: [
      {
        text: 'Tangential acceleration changes the speed: $a_t = dv/dt$. Since speed is constant, $a_t = 0$.',
        latex: null
      },
      {
        text: 'Normal acceleration changes the direction:',
        latex: 'a_n = \\frac{v^2}{\\rho} \\neq 0'
      },
      {
        text: 'Therefore, the total acceleration is purely normal, directed toward the center of curvature.',
        latex: null
      }
    ],
    handbookPage: 'p. 103',
    handbookFormula: 'a_n = \\frac{v^2}{\\rho}',
    videoUrl: null,
    traps: [
      'Confusing speed (scalar) with velocity (vector) — constant speed does not mean zero acceleration',
      'Thinking zero tangential acceleration means zero total acceleration'
    ],
    diagram: null,
    lessonId: 'particle-kinematics',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-pk-ex4',
    type: 'computational',
    statement: 'A ball is thrown horizontally from the top of a $45\\,\\text{m}$ tall building at $12\\,\\text{m/s}$. How far from the base of the building does it land? Use $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$18.2\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$36.3\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$54.5\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$110.5\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'This is a two-step problem. First, find how long it takes to fall 45 m using the vertical equation (no initial vertical velocity since the throw is horizontal). Then multiply that time by the horizontal speed. The horizontal and vertical motions are independent — that is the key concept. The 18.2 m option uses half the correct fall time. The 54.5 m option multiplies the height by the horizontal speed directly.',
    hint: 'The ball has no initial vertical velocity. Find the fall time from the vertical motion, then multiply by the horizontal speed.',
    steps: [
      {
        text: 'Find fall time from vertical motion ($v_{0y} = 0$):',
        latex: 'h = \\frac{1}{2}gt^2 \\implies t = \\sqrt{\\frac{2h}{g}} = \\sqrt{\\frac{2(45)}{9.81}} = \\sqrt{9.174} = 3.03\\,\\text{s}'
      },
      {
        text: 'Horizontal distance (constant velocity, no air resistance):',
        latex: 'x = v_{0x} \\cdot t = 12 \\times 3.03 = 36.3\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 104',
    handbookFormula: 'x = v_0 \\cos\\theta \\cdot t + x_0',
    videoUrl: null,
    traps: [
      'Trying to combine horizontal and vertical into one equation — they must be solved independently',
      'Forgetting that the initial vertical velocity is zero for a horizontal throw'
    ],
    diagram: {
      component: 'HorizontalThrow',
      props: {
        height: 45,
        velocity: 12
      }
    },
    lessonId: 'particle-kinematics',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-rbk-ex1',
    type: 'computational',
    statement: 'A flywheel spinning at $120 \\text{ rpm}$ is brought to rest by a constant braking torque in $10 \\text{ s}$. What is the angular deceleration of the flywheel?',
    choices: [
      {
        id: 'c1',
        text: '$0.40 \\text{ rad/s}^2$'
      },
      {
        id: 'c2',
        text: '$1.26 \\text{ rad/s}^2$'
      },
      {
        id: 'c3',
        text: '$12.0 \\text{ rad/s}^2$'
      },
      {
        id: 'c4',
        text: '$75.4 \\text{ rad/s}^2$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'First convert 120 rpm to rad/s: multiply by $2\\pi/60$ to get 12.57 rad/s. Then use the angular kinematic equation: $\\omega = \\omega_0 + \\alpha t$. The final angular velocity is 0 (brought to rest), so $\\alpha = -12.57/10 = -1.26$ rad/s². The magnitude of deceleration is 1.26. The 12.0 rad/s^2 choice comes from using rpm directly without converting. The 0.40 rad/s^2 choice uses the period formula incorrectly.',
    hint: 'Convert rpm to rad/s first, then use the angular analog of $v = v_0 + at$.',
    steps: [
      {
        text: 'Convert rpm to rad/s:',
        latex: '\\omega_0 = 120 \\times \\frac{2\\pi}{60} = 4\\pi = 12.57 \\text{ rad/s}'
      },
      {
        text: 'Apply angular kinematics ($\\omega = 0$ at rest):',
        latex: '\\omega = \\omega_0 + \\alpha t \\implies 0 = 12.57 + \\alpha(10)'
      },
      {
        text: 'Solve for angular deceleration:',
        latex: '\\alpha = \\frac{-12.57}{10} = -1.26 \\text{ rad/s}^2 \\quad (|\\alpha| = 1.26 \\text{ rad/s}^2)'
      }
    ],
    handbookPage: 'p. 109',
    handbookFormula: '\\omega = \\omega_0 + \\alpha_0 t',
    videoUrl: null,
    traps: [
      'Using rpm directly instead of converting to rad/s, giving 12.0',
      'Forgetting to divide by 60 in the rpm-to-rad/s conversion'
    ],
    diagram: null,
    lessonId: 'rigid-body-kinematics-mass-moi',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-rbk-ex2',
    type: 'computational',
    statement: 'A wheel starts from rest with a constant angular acceleration of $3 \\text{ rad/s}^2$. How many complete revolutions does it make in the first $8 \\text{ s}$?',
    choices: [
      {
        id: 'c1',
        text: '$12$'
      },
      {
        id: 'c2',
        text: '$15.3$'
      },
      {
        id: 'c3',
        text: '$24$'
      },
      {
        id: 'c4',
        text: '$96$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Use the angular displacement equation: $\\theta = \\omega_0 t + \\tfrac{1}{2}\\alpha t^2$. With $\\omega_0 = 0$, that gives $\\theta = 0.5 \\times 3 \\times 64 = 96$ rad. Then convert to revolutions by dividing by $2\\pi$: $96 / (2\\pi) = 15.3$ revolutions. The choice $96$ is the angular displacement in radians, not revolutions. The choice $12$ comes from using $\\alpha t$ instead of $\\tfrac{1}{2}\\alpha t^2$.',
    hint: 'Compute the angular displacement in radians first, then divide by $2\\pi$ to convert to revolutions.',
    steps: [
      {
        text: 'Angular displacement from rest ($\\omega_0 = 0$):',
        latex: '\\theta = \\frac{1}{2}\\alpha t^2 = \\frac{1}{2}(3)(8^2) = \\frac{1}{2}(3)(64) = 96 \\text{ rad}'
      },
      {
        text: 'Convert radians to revolutions:',
        latex: 'N = \\frac{\\theta}{2\\pi} = \\frac{96}{2\\pi} = 15.3 \\text{ rev}'
      }
    ],
    handbookPage: 'p. 109',
    handbookFormula: '\\theta = \\theta_0 + \\omega_0 t + \\tfrac{1}{2}\\alpha_0 t^2',
    videoUrl: null,
    traps: [
      'Reporting the answer in radians (96) instead of revolutions',
      'Using $\\alpha t$ instead of $\\tfrac{1}{2}\\alpha t^2$ for displacement'
    ],
    diagram: null,
    lessonId: 'rigid-body-kinematics-mass-moi',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-rbk-ex3',
    type: 'computational',
    statement: 'A thin uniform rod has mass $8 \\text{ kg}$ and length $1.2 \\text{ m}$. The mass moment of inertia about its centroidal axis perpendicular to the rod is $I_c = \\frac{1}{12}mL^2$. What is the mass moment of inertia about an axis at one end of the rod?',
    choices: [
      {
        id: 'c1',
        text: '$0.96 \\text{ kg}{\\cdot}\\text{m}^2$'
      },
      {
        id: 'c2',
        text: '$1.92 \\text{ kg}{\\cdot}\\text{m}^2$'
      },
      {
        id: 'c3',
        text: '$3.84 \\text{ kg}{\\cdot}\\text{m}^2$'
      },
      {
        id: 'c4',
        text: '$0.48 \\text{ kg}{\\cdot}\\text{m}^2$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Two steps: compute the centroidal MOI, then use the parallel-axis theorem to transfer to the end. The centroidal MOI is $\\tfrac{1}{12}(8)(1.2^2) = 0.96$ kg·m². The distance from the centroid to the end is $L/2 = 0.6$ m. The transfer term is $md^2 = 8(0.6^2) = 2.88$. Add them: $0.96 + 2.88 = 3.84$ kg·m². Notice that $\\tfrac{1}{12}mL^2 + m(L/2)^2 = \\tfrac{1}{3}mL^2$, which is the standard end-of-rod formula. The choice 0.96 kg\u00b7m\u00b2 is just the centroidal term without the transfer.',
    hint: 'The distance from the centroid to the end of a uniform rod is $L/2$. Apply $I = I_c + md^2$.',
    steps: [
      {
        text: 'Centroidal MOI:',
        latex: 'I_c = \\frac{1}{12}mL^2 = \\frac{1}{12}(8)(1.2^2) = \\frac{1}{12}(8)(1.44) = 0.96 \\text{ kg}{\\cdot}\\text{m}^2'
      },
      {
        text: 'Distance from centroid to end:',
        latex: 'd = \\frac{L}{2} = \\frac{1.2}{2} = 0.6 \\text{ m}'
      },
      {
        text: 'Parallel-axis theorem:',
        latex: 'I_{end} = I_c + md^2 = 0.96 + 8(0.6^2) = 0.96 + 2.88 = 3.84 \\text{ kg}{\\cdot}\\text{m}^2'
      }
    ],
    handbookPage: 'p. 109',
    handbookFormula: 'I = I_c + md^2',
    videoUrl: null,
    traps: [
      'Reporting only $I_c = 0.96$ and forgetting the parallel-axis transfer',
      'Using $d = L$ instead of $d = L/2$ for the distance from centroid to end'
    ],
    diagram: null,
    lessonId: 'rigid-body-kinematics-mass-moi',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-rbk-ex4',
    type: 'conceptual',
    statement: 'The parallel-axis theorem states $I = I_c + md^2$, where $d$ is the distance between two parallel axes. Which of the following conditions must be true for this formula to apply directly?',
    choices: [
      {
        id: 'c1',
        text: 'One of the two axes must pass through the centroid.'
      },
      {
        id: 'c2',
        text: 'Both axes must pass through the centroid.'
      },
      {
        id: 'c3',
        text: 'The axes must be perpendicular to each other.'
      },
      {
        id: 'c4',
        text: 'The body must have uniform density.'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'The parallel-axis theorem transfers the moment of inertia FROM the centroidal axis TO any parallel axis. One of the two axes must be the centroidal axis. You cannot transfer directly between two arbitrary non-centroidal axes. If you need to go from axis A to axis B and neither passes through the centroid, you must first go back to the centroid (subtract $md_A^2$), then forward to axis B (add $md_B^2$). The axes must be parallel, not perpendicular. And the formula works for any mass distribution, not just uniform density.',
    hint: 'Think about which axis the I_c term refers to. Can you go directly between any two parallel axes?',
    steps: [
      {
        text: '$I_c$ is specifically the moment of inertia about the centroidal axis. The $md^2$ term transfers it to a parallel axis at distance $d$.',
        latex: null
      },
      {
        text: 'To go between two non-centroidal axes A and B:',
        latex: 'I_B = (I_A - md_A^2) + md_B^2'
      },
      {
        text: 'The axes must be parallel (not perpendicular). The formula applies regardless of density distribution.',
        latex: null
      }
    ],
    handbookPage: 'p. 109',
    handbookFormula: 'I = I_c + md^2',
    videoUrl: null,
    traps: [
      'Thinking you can transfer directly between two arbitrary parallel axes without going through the centroid first'
    ],
    diagram: null,
    lessonId: 'rigid-body-kinematics-mass-moi',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-fa-ex1',
    type: 'computational',
    statement: 'A 1500 kg car accelerates from rest to $25\\,\\text{m/s}$ in 8 seconds on a level road. What is the net force acting on the car?',
    choices: [
      {
        id: 'c1',
        text: '3125 N'
      },
      {
        id: 'c2',
        text: '4688 N'
      },
      {
        id: 'c3',
        text: '6250 N'
      },
      {
        id: 'c4',
        text: '37500 N'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'First find acceleration: $a = (25 - 0)/8 = 3.125$ m/s². Then $F = ma = 1500 \\times 3.125 = 4687.5$ N which rounds to 4688 N. The trap is using weight ($mg$) instead of mass, or confusing the final velocity with acceleration.',
    hint: 'Find the acceleration first using kinematics, then apply Newton\'s second law.',
    steps: [
      {
        text: 'Find acceleration:',
        latex: 'a = \\frac{v - v_0}{t} = \\frac{25 - 0}{8} = 3.125\\,\\text{m/s}^2'
      },
      {
        text: 'Apply Newton\'s second law:',
        latex: 'F = ma = 1500 \\times 3.125 = 4688\\,\\text{N}'
      }
    ],
    handbookPage: 'p. 101',
    handbookFormula: 'F = ma',
    videoUrl: null,
    traps: [
      'Using weight ($mg = 14715$ N) instead of applying $F = ma$',
      'Forgetting to calculate acceleration first'
    ],
    diagram: null,
    lessonId: 'force-and-acceleration',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-fa-ex2',
    type: 'conceptual',
    statement: 'A box sits on a truck that is accelerating forward. The friction between the box and the truck bed is what keeps the box from sliding backward. In which direction does the friction force act on the box?',
    choices: [
      {
        id: 'c1',
        text: 'Backward (opposing the truck\'s motion)'
      },
      {
        id: 'c2',
        text: 'Forward (in the direction of acceleration)'
      },
      {
        id: 'c3',
        text: 'Downward (toward the truck bed)'
      },
      {
        id: 'c4',
        text: 'There is no friction force if the box is not sliding'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The friction acts FORWARD on the box — it is the only horizontal force on the box, and it must act in the direction of the box\'s acceleration (forward with the truck). Many students think friction always opposes motion, but friction opposes RELATIVE motion. Without friction, the box would slide backward relative to the truck, so friction acts forward to prevent that.',
    hint: 'Think about what would happen without friction — which way would the box slide relative to the truck?',
    steps: [
      {
        text: 'Without friction, the box would stay at rest while the truck moves forward — the box slides backward relative to the truck.',
        latex: null
      },
      {
        text: 'Friction opposes relative motion, so it acts forward on the box.',
        latex: null
      },
      {
        text: 'This forward friction is the net force causing the box to accelerate with the truck: $F_{\\text{friction}} = ma$.',
        latex: null
      }
    ],
    handbookPage: 'p. 101',
    handbookFormula: 'F = ma',
    videoUrl: null,
    traps: [
      'Thinking friction always opposes the direction of motion — it opposes RELATIVE motion',
      'Forgetting that static friction is what accelerates objects'
    ],
    diagram: null,
    lessonId: 'force-and-acceleration',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-fa-ex3',
    type: 'computational',
    statement: 'A $60\\,\\text{kg}$ crate is pulled across a horizontal floor by a cable angled $30\\degree$ above the horizontal with a tension of $400\\,\\text{N}$. The coefficient of kinetic friction between the crate and floor is $\\mu_k = 0.25$. What is the acceleration of the crate? Use $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$4.15\\,\\text{m/s}^2$'
      },
      {
        id: 'c2',
        text: '$3.32\\,\\text{m/s}^2$'
      },
      {
        id: 'c3',
        text: '$5.77\\,\\text{m/s}^2$'
      },
      {
        id: 'c4',
        text: '$6.67\\,\\text{m/s}^2$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The angled cable does two things: it pulls horizontally ($T \\cos 30°$) and it lifts vertically ($T \\sin 30°$), which reduces the normal force. A lower normal force means less friction. You need to solve the y-direction first to get the normal force, then use it for friction in the x-direction. The $3.32\\,\\text{m/s}^2$ distractor comes from using $N = mg$ without subtracting the vertical cable component. The $5.77\\,\\text{m/s}^2$ distractor is $T \\cos 30° / m$, ignoring friction entirely.',
    hint: 'The cable angle reduces the normal force. Solve the vertical equilibrium first to find N, then use it to compute friction.',
    steps: [
      {
        text: 'Horizontal component of tension:',
        latex: 'T\\cos 30\\degree = 400(0.866) = 346.4\\,\\text{N}'
      },
      {
        text: 'Vertical equilibrium (no vertical acceleration):',
        latex: 'N = mg - T\\sin 30\\degree = 60(9.81) - 400(0.5) = 588.6 - 200 = 388.6\\,\\text{N}'
      },
      {
        text: 'Friction force:',
        latex: 'f = \\mu_k N = 0.25(388.6) = 97.1\\,\\text{N}'
      },
      {
        text: 'Apply Newton\'s second law in x:',
        latex: 'a = \\frac{T\\cos 30\\degree - f}{m} = \\frac{346.4 - 97.1}{60} = \\frac{249.3}{60} = 4.15\\,\\text{m/s}^2'
      }
    ],
    handbookPage: 'p. 105',
    handbookFormula: '\\sum F = ma',
    videoUrl: null,
    traps: [
      'Forgetting that the vertical component of tension reduces the normal force',
      'Using mg as the normal force directly — only valid when the pull is perfectly horizontal'
    ],
    diagram: {
      component: 'CrateCablePull',
      props: {
        mass: 60,
        tension: 400,
        angle: 30
      }
    },
    lessonId: 'force-and-acceleration',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-fa-ex4',
    type: 'computational',
    statement: 'A $4\\,\\text{kg}$ block sits on top of a $12\\,\\text{kg}$ block, which rests on a frictionless surface. The coefficient of static friction between the two blocks is $\\mu_s = 0.40$. What is the maximum horizontal force that can be applied to the lower block without the upper block sliding off? Use $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$15.7\\,\\text{N}$'
      },
      {
        id: 'c2',
        text: '$47.1\\,\\text{N}$'
      },
      {
        id: 'c3',
        text: '$62.8\\,\\text{N}$'
      },
      {
        id: 'c4',
        text: '$188\\,\\text{N}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The key insight is that both blocks must accelerate together at the same rate. The only force accelerating the top block is static friction, so the max acceleration is limited by friction on the top block: $a_{max} = \\mu_s g$. Then apply $F = (m_1 + m_2) a_{max}$ to the whole system. If you only multiply by the top block mass, you get the friction force alone, not the applied force needed for the whole system.',
    hint: 'For the blocks to move together, the upper block\'s acceleration is limited by the maximum static friction. Find that acceleration, then apply it to the entire system.',
    steps: [
      {
        text: 'Maximum friction on the upper block:',
        latex: 'f_{max} = \\mu_s m_{top} g = 0.40(4)(9.81) = 15.70\\,\\text{N}'
      },
      {
        text: 'Maximum acceleration of the upper block (and thus the system):',
        latex: 'a_{max} = \\frac{f_{max}}{m_{top}} = \\frac{15.70}{4} = 3.924\\,\\text{m/s}^2'
      },
      {
        text: 'Note this simplifies to $a_{max} = \\mu_s g = 0.40(9.81) = 3.924\\,\\text{m/s}^2$.',
        latex: null
      },
      {
        text: 'Force on the entire system for this acceleration:',
        latex: 'F = (m_{top} + m_{bottom})a_{max} = (4 + 12)(3.924) = 62.8\\,\\text{N}'
      }
    ],
    handbookPage: 'p. 105',
    handbookFormula: '\\sum F = ma',
    videoUrl: null,
    traps: [
      'Reporting the friction force (15.7 N) instead of the total applied force needed',
      'Applying F = ma to only the bottom block mass instead of both blocks together'
    ],
    diagram: {
      component: 'StackedBlocks',
      props: {
        massTop: 4,
        massBot: 12
      }
    },
    lessonId: 'force-and-acceleration',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-wep-ex1',
    type: 'computational',
    statement: 'A $2\\,\\text{kg}$ ball is dropped from a height of $20\\,\\text{m}$ above the ground. What is its speed just before hitting the ground? Ignore air resistance. Use $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$14.0\\,\\text{m/s}$'
      },
      {
        id: 'c2',
        text: '$19.8\\,\\text{m/s}$'
      },
      {
        id: 'c3',
        text: '$196.2\\,\\text{m/s}$'
      },
      {
        id: 'c4',
        text: '$392.4\\,\\text{m/s}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'All potential energy converts to kinetic energy: $mgh = \\tfrac{1}{2}mv^2$. Mass cancels, so $v = \\sqrt{2gh}$. The answer does not depend on the mass at all. The 196.2 option is $gh$ (forgetting the factor of 2). The 392.4 option is $2gh$, which equals $v^2$ — taking the square root gives the correct answer, so it is $v^2$ reported instead of $v$.',
    hint: 'With no air resistance, all potential energy converts to kinetic energy. Mass cancels out.',
    steps: [
      {
        text: 'Conservation of energy (no friction):',
        latex: 'mgh = \\frac{1}{2}mv^2'
      },
      {
        text: 'Mass cancels:',
        latex: 'v = \\sqrt{2gh} = \\sqrt{2(9.81)(20)} = \\sqrt{392.4} = 19.8\\,\\text{m/s}'
      }
    ],
    handbookPage: 'p. 106',
    handbookFormula: 'T_1 + V_1 = T_2 + V_2',
    videoUrl: null,
    traps: [
      'Reporting $2gh$ as the speed instead of taking the square root',
      'Thinking mass affects the answer — it cancels in frictionless free fall'
    ],
    diagram: null,
    lessonId: 'work-energy-power',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-wep-ex2',
    type: 'computational',
    statement: 'A car with a mass of $1{,}200\\,\\text{kg}$ travels at a constant speed of $25\\,\\text{m/s}$ up a $6\\%$ grade (slope). What power must the engine deliver just to overcome gravity? Use $g = 9.81\\,\\text{m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$1.77\\,\\text{kW}$'
      },
      {
        id: 'c2',
        text: '$17.7\\,\\text{kW}$'
      },
      {
        id: 'c3',
        text: '$29.4\\,\\text{kW}$'
      },
      {
        id: 'c4',
        text: '$294\\,\\text{kW}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'A 6% grade means the road rises 0.06 m for every 1 m of horizontal distance, so $\\sin\\theta \\approx 0.06$ for small angles. The component of weight along the slope is $mg\\sin\\theta$, and power = force times velocity. The $294\\,\\text{kW}$ choice uses $\\sin\\theta = 1$ (as if it were a vertical wall: $mgv$). The $1.77\\,\\text{kW}$ choice forgets to multiply by $g$ somewhere in the chain.',
    hint: 'On a grade, the gravity component along the slope is mg times the grade (for small angles, grade approximates sin theta). Power = F times v.',
    steps: [
      {
        text: 'Gravity component along the slope (6% grade means $\\sin\\theta \\approx 0.06$):',
        latex: 'F_g = mg\\sin\\theta = 1{,}200(9.81)(0.06) = 706.3\\,\\text{N}'
      },
      {
        text: 'Power to overcome gravity at constant speed:',
        latex: 'P = F_g \\cdot v = 706.3 \\times 25 = 17{,}658\\,\\text{W} \\approx 17.7\\,\\text{kW}'
      }
    ],
    handbookPage: 'p. 107',
    handbookFormula: 'P = F \\cdot v',
    videoUrl: null,
    traps: [
      'Forgetting that a 6% grade means $\\sin\\theta = 0.06$, not $\\theta = 6°$',
      'Computing force but forgetting to multiply by velocity to get power'
    ],
    diagram: null,
    lessonId: 'work-energy-power',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-wep-ex3',
    type: 'conceptual',
    statement: 'Two blocks of different mass are released from rest at the same height on identical frictionless ramps. Which statement is correct about their speeds at the bottom?',
    choices: [
      {
        id: 'c1',
        text: 'Both blocks reach the same speed because mass cancels in the energy equation.'
      },
      {
        id: 'c2',
        text: 'The lighter block is faster because it has less inertia.'
      },
      {
        id: 'c3',
        text: 'The heavier block is faster because it has more potential energy.'
      },
      {
        id: 'c4',
        text: 'It depends on the angle of the ramp.'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'From $mgh = \\tfrac{1}{2}mv^2$, mass appears on both sides and cancels. So $v = \\sqrt{2gh}$ regardless of mass. The heavier block does have more PE and more KE at the bottom, but since it also has more mass, the speed works out the same. This is the same reason Galileo showed all objects fall at the same rate in a vacuum.',
    hint: 'Write out the conservation of energy equation and see what cancels.',
    steps: [
      {
        text: 'Conservation of energy for each block:',
        latex: 'mgh = \\frac{1}{2}mv^2'
      },
      {
        text: 'Mass cancels on both sides:',
        latex: 'v = \\sqrt{2gh}'
      },
      {
        text: 'Speed depends only on height, not on mass or ramp angle.',
        latex: null
      }
    ],
    handbookPage: 'p. 106',
    handbookFormula: 'T_1 + V_1 = T_2 + V_2',
    videoUrl: null,
    traps: [
      'Thinking more potential energy means more speed — it does not, because more mass also means more inertia',
      'Confusing the total kinetic energy (which IS different) with speed (which is the same)'
    ],
    diagram: null,
    lessonId: 'work-energy-power',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-wep-ex4',
    type: 'computational',
    statement: 'A $4\\,\\text{kg}$ block moving at $6\\,\\text{m/s}$ on a smooth surface compresses a spring with stiffness $k = 800\\,\\text{N/m}$. What is the maximum compression of the spring?',
    choices: [
      {
        id: 'c1',
        text: '$0.030\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$0.090\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$0.30\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$0.42\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'At maximum compression, the block has stopped momentarily ($v = 0$), so all kinetic energy has been stored as elastic potential energy in the spring. Set $\\tfrac{1}{2}mv^2 = \\tfrac{1}{2}kx^2$ and solve for $x$. The masses and stiffness must use consistent units (SI). The 0.30 m choice comes from using $k = 1{,}600$ instead of $k = 800$ (squaring the wrong thing). The 0.090 m choice is a unit/arithmetic slip; forgetting the square root would give $mv^2/k = 0.18\\,\\text{m}$, which is not offered. The 0.30 m choice comes from using $k = 1{,}600$ instead of $k = 800$ (squaring the wrong thing).',
    hint: 'At maximum compression the block is momentarily at rest. Where did all the kinetic energy go?',
    steps: [
      {
        text: 'All kinetic energy converts to spring potential energy:',
        latex: '\\frac{1}{2}mv^2 = \\frac{1}{2}kx^2'
      },
      {
        text: 'Solve for maximum compression:',
        latex: 'x = v\\sqrt{\\frac{m}{k}} = 6\\sqrt{\\frac{4}{800}} = 6\\sqrt{0.005} = 6(0.0707) = 0.424\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 106',
    handbookFormula: 'V_e = \\frac{1}{2}ks^2',
    videoUrl: null,
    traps: [
      'Forgetting to take the square root when solving for x',
      'Using the wrong energy equation — this is elastic PE, not gravitational PE'
    ],
    diagram: {
      component: 'BlockSpringCompress',
      props: {
        mass: 4,
        velocity: 6,
        stiffness: 800
      }
    },
    lessonId: 'work-energy-power',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-iam-ex1',
    type: 'computational',
    statement: 'A $5 \\text{ kg}$ block sliding on a frictionless surface at $6 \\text{ m/s}$ is struck by a constant horizontal force of $40 \\text{ N}$ in the direction of motion for $0.5 \\text{ s}$. What is the block\'s velocity after the impulse?',
    choices: [
      {
        id: 'c1',
        text: '$10.0 \\text{ m/s}$'
      },
      {
        id: 'c2',
        text: '$4.0 \\text{ m/s}$'
      },
      {
        id: 'c3',
        text: '$2.0 \\text{ m/s}$'
      },
      {
        id: 'c4',
        text: '$20.0 \\text{ m/s}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'This is a direct application of the impulse-momentum theorem. The impulse (force times time) equals the change in momentum. Compute the impulse: $40 \\times 0.5 = 20$ N·s. Then set that equal to $m(v_2 - v_1)$ and solve for $v_2$. The 20 m/s choice comes from misreporting the impulse value (20 N\u00b7s) as a velocity instead of dividing by mass. The 4.0 m/s choice comes from dividing impulse by mass but forgetting to add the initial velocity.',
    hint: 'Impulse = $F \\Delta t$. Set that equal to the change in momentum and solve for the final velocity.',
    steps: [
      {
        text: 'Compute the impulse:',
        latex: 'J = F \\Delta t = 40 \\times 0.5 = 20 \\text{ N}{\\cdot}\\text{s}'
      },
      {
        text: 'Apply impulse-momentum theorem:',
        latex: 'J = m(v_2 - v_1)'
      },
      {
        text: 'Solve for final velocity:',
        latex: 'v_2 = v_1 + \\frac{J}{m} = 6 + \\frac{20}{5} = 6 + 4 = 10.0 \\text{ m/s}'
      }
    ],
    handbookPage: 'p. 107',
    handbookFormula: 'm v_1 + \\int F \\, dt = m v_2',
    videoUrl: null,
    traps: [
      'Forgetting to add the initial velocity to the velocity change',
      'Dividing impulse by time instead of by mass'
    ],
    diagram: null,
    lessonId: 'impulse-and-momentum',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-iam-ex2',
    type: 'computational',
    statement: 'A $3 \\text{ kg}$ ball moving at $10 \\text{ m/s}$ to the right collides head-on with a $5 \\text{ kg}$ ball moving at $4 \\text{ m/s}$ to the left. The coefficient of restitution is $e = 0.6$. What is the velocity of the $3 \\text{ kg}$ ball after impact?',
    choices: [
      {
        id: 'c1',
        text: '$4.0 \\text{ m/s to the left}$'
      },
      {
        id: 'c2',
        text: '$2.75 \\text{ m/s to the right}$'
      },
      {
        id: 'c3',
        text: '$1.25 \\text{ m/s to the right}$'
      },
      {
        id: 'c4',
        text: '$5.25 \\text{ m/s to the left}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'You need two equations: conservation of momentum and the restitution equation. Take rightward as positive, so the 5 kg ball has velocity $-4$ m/s. Momentum conservation gives $3v_1\' + 5v_2\' = 10$. The restitution equation gives $v_2\' - v_1\' = 0.6(10 - (-4)) = 8.4$. Solving simultaneously: $v_1\' = -4.0$ m/s (the negative means leftward). The 3 kg ball bounces back. The 2.75 m/s to the right distractor comes from mishandling the sign on the second ball\'s initial velocity.',
    hint: 'Pick a positive direction first. Both momentum conservation and the restitution equation use signed velocities.',
    steps: [
      {
        text: 'Define rightward as positive. Initial velocities: $v_1 = +10$, $v_2 = -4$.',
        latex: null
      },
      {
        text: 'Conservation of momentum:',
        latex: '3(10) + 5(-4) = 3v_1\' + 5v_2\' \\implies 3v_1\' + 5v_2\' = 10'
      },
      {
        text: 'Restitution equation:',
        latex: 'e = \\frac{v_2\' - v_1\'}{v_1 - v_2} \\implies 0.6 = \\frac{v_2\' - v_1\'}{10 - (-4)} \\implies v_2\' - v_1\' = 8.4'
      },
      {
        text: 'From the restitution equation: $v_2\' = v_1\' + 8.4$. Substitute:',
        latex: '3v_1\' + 5(v_1\' + 8.4) = 10 \\implies 8v_1\' = -32 \\implies v_1\' = -4.0 \\text{ m/s}'
      },
      {
        text: 'Negative sign means the 3 kg ball moves to the left after impact.',
        latex: null
      }
    ],
    handbookPage: 'p. 108',
    handbookFormula: 'e = \\frac{(v_2\')_n - (v_1\')_n}{(v_1)_n - (v_2)_n}',
    videoUrl: null,
    traps: [
      'Using the wrong sign for the second ball\'s initial velocity',
      'Flipping the numerator and denominator in the restitution formula'
    ],
    diagram: {
      component: 'CollisionDiagram',
      props: {
        massA: 3,
        massB: 5,
        velA: 10,
        velB: -4
      }
    },
    lessonId: 'impulse-and-momentum',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-iam-ex3',
    type: 'computational',
    statement: 'A $4{,}000 \\text{ kg}$ truck traveling at $12 \\text{ m/s}$ collides with a $1{,}000 \\text{ kg}$ car traveling in the same direction at $3 \\text{ m/s}$. After the collision, the car moves at $15 \\text{ m/s}$. What is the coefficient of restitution $e$?',
    choices: [
      {
        id: 'c1',
        text: '$0.33$'
      },
      {
        id: 'c2',
        text: '$0.50$'
      },
      {
        id: 'c3',
        text: '$0.67$'
      },
      {
        id: 'c4',
        text: '$1.00$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'First find the truck\'s post-collision velocity from momentum conservation: $4000(12) + 1000(3) = 4000 v_1\' + 1000(15)$, which gives $v_1\' = 9$ m/s. Then plug into the restitution formula: $e = (15 - 9)/(12 - 3) = 6/9 = 0.67$. The 0.33 distractor comes from flipping the fraction. The 1.0 distractor would mean perfectly elastic, but kinetic energy isn\'t conserved here.',
    hint: 'Use momentum conservation to find the truck\'s final velocity first, then plug both final velocities into the restitution formula.',
    steps: [
      {
        text: 'Conservation of momentum (both moving in same direction):',
        latex: '4{,}000(12) + 1{,}000(3) = 4{,}000 v_1\' + 1{,}000(15)'
      },
      {
        text: 'Solve for truck\'s final velocity:',
        latex: '48{,}000 + 3{,}000 = 4{,}000 v_1\' + 15{,}000 \\implies v_1\' = \\frac{36{,}000}{4{,}000} = 9 \\text{ m/s}'
      },
      {
        text: 'Apply restitution formula:',
        latex: 'e = \\frac{v_2\' - v_1\'}{v_1 - v_2} = \\frac{15 - 9}{12 - 3} = \\frac{6}{9} = 0.67'
      }
    ],
    handbookPage: 'p. 108',
    handbookFormula: 'e = \\frac{(v_2\')_n - (v_1\')_n}{(v_1)_n - (v_2)_n}',
    videoUrl: null,
    traps: [
      'Flipping the restitution fraction (denominator over numerator) giving 0.33',
      'Subtracting velocities in the wrong order in either numerator or denominator'
    ],
    diagram: {
      component: 'CollisionDiagram',
      props: {
        massA: 4000,
        massB: 1000,
        velA: 12,
        velB: 3,
        labelA: 'Truck',
        labelB: 'Car'
      }
    },
    lessonId: 'impulse-and-momentum',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-iam-ex4',
    type: 'conceptual',
    statement: 'Two objects undergo a direct central impact. Which of the following statements is ALWAYS true during the collision?',
    choices: [
      {
        id: 'c1',
        text: 'Kinetic energy is conserved.'
      },
      {
        id: 'c2',
        text: 'Linear momentum of the system is conserved.'
      },
      {
        id: 'c3',
        text: 'Both objects must be moving before impact.'
      },
      {
        id: 'c4',
        text: 'The lighter object always rebounds.'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'Momentum conservation is the bedrock principle for ALL collisions when no external forces act during impact. Kinetic energy is only conserved for perfectly elastic collisions (e = 1), which is rare in practice. One object can absolutely be at rest before impact (think billiards). And whether the lighter object rebounds depends on the mass ratio and coefficient of restitution, not a universal rule. The FE loves testing whether you know the difference between what\'s always true vs. sometimes true.',
    hint: 'Think about what must hold for every collision type: perfectly elastic, partially inelastic, and perfectly plastic.',
    steps: [
      {
        text: 'Momentum conservation applies to all collision types (elastic, inelastic, plastic) as long as external impulses are negligible during the impact.',
        latex: null
      },
      {
        text: 'Kinetic energy conservation only applies when $e = 1$ (perfectly elastic). For any other $e$, KE is lost.',
        latex: null
      },
      {
        text: 'One object can be stationary before impact (e.g., a ball striking a wall). Both objects moving is not required.',
        latex: null
      },
      {
        text: 'Whether the lighter object rebounds depends on $e$ and the mass ratio, not a universal rule.',
        latex: null
      }
    ],
    handbookPage: 'p. 108',
    handbookFormula: 'm_1 v_1 + m_2 v_2 = m_1 v_1\' + m_2 v_2\'',
    videoUrl: null,
    traps: [
      'Confusing momentum conservation (always true) with energy conservation (only for e = 1)'
    ],
    diagram: null,
    lessonId: 'impulse-and-momentum',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-vnf-ex1',
    type: 'computational',
    statement: 'A $25 \\text{ kg}$ mass hangs from a spring and stretches it $0.05 \\text{ m}$ under static equilibrium. What is the natural period of vertical oscillation? Use $g = 9.81 \\text{ m/s}^2$.',
    choices: [
      {
        id: 'c1',
        text: '$0.22 \\text{ s}$'
      },
      {
        id: 'c2',
        text: '$0.45 \\text{ s}$'
      },
      {
        id: 'c3',
        text: '$2.22 \\text{ rad/s}$'
      },
      {
        id: 'c4',
        text: '$14.0 \\text{ s}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The trick is that the spring stiffness isn\'t given directly. You find $k$ from the static deflection: at equilibrium, the spring force equals the weight, so $k = mg/\\delta = 25(9.81)/0.05 = 4905$ N/m. Then compute $\\omega_n = \\sqrt{k/m} = \\sqrt{4905/25} = 14.0$ rad/s. The period is $T = 2\\pi/\\omega_n = 0.449$ s, which rounds to 0.45 s. The 2.22 choice is $\\omega_n$ divided by $2\\pi$ (that\'s the frequency in Hz, not the period). The 0.22 s choice is just half the period ($T/2$).',
    hint: 'Find the spring stiffness from the static deflection first: k = weight / deflection.',
    steps: [
      {
        text: 'Find spring stiffness from static equilibrium:',
        latex: 'k = \\frac{mg}{\\delta} = \\frac{25 \\times 9.81}{0.05} = 4{,}905 \\text{ N/m}'
      },
      {
        text: 'Natural circular frequency:',
        latex: '\\omega_n = \\sqrt{\\frac{k}{m}} = \\sqrt{\\frac{4{,}905}{25}} = \\sqrt{196.2} = 14.0 \\text{ rad/s}'
      },
      {
        text: 'Natural period:',
        latex: 'T_n = \\frac{2\\pi}{\\omega_n} = \\frac{2\\pi}{14.0} = 0.449 \\approx 0.45 \\text{ s}'
      }
    ],
    handbookPage: 'p. 112',
    handbookFormula: '\\omega_n = \\sqrt{k/m}',
    videoUrl: null,
    traps: [
      'Reporting $\\omega_n$ or $f_n$ when the problem asks for period $T$',
      'Using the static deflection as the amplitude instead of using it to find $k$'
    ],
    diagram: null,
    lessonId: 'vibrations-natural-frequency',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-vnf-ex2',
    type: 'computational',
    statement: 'Two springs with stiffnesses $k_1 = 3{,}000 \\text{ N/m}$ and $k_2 = 6{,}000 \\text{ N/m}$ are connected in parallel and support a $10 \\text{ kg}$ mass. What is the natural frequency of the system?',
    choices: [
      {
        id: 'c1',
        text: '$4.77 \\text{ Hz}$'
      },
      {
        id: 'c2',
        text: '$2.25 \\text{ Hz}$'
      },
      {
        id: 'c3',
        text: '$30 \\text{ rad/s}$'
      },
      {
        id: 'c4',
        text: '$3.47 \\text{ Hz}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Springs in parallel add directly: $k_{eq} = k_1 + k_2 = 3000 + 6000 = 9000$ N/m. Then $\\omega_n = \\sqrt{9000/10} = 30$ rad/s. Convert to Hz: $f_n = 30/(2\\pi) = 4.77$ Hz. The 2.25 Hz option comes from using the series combination $(1/k_1 + 1/k_2)^{-1} = 2000$ N/m instead of parallel ($\\omega_n=\\sqrt{2000/10}=14.14$ rad/s, $f_n=2.25$ Hz). The 30 option is $\\omega_n$ in rad/s, not Hz. The 3.47 Hz option is a plausible-looking distractor with no clean derivation.',
    hint: 'Springs in parallel share the same displacement. How do you combine their stiffnesses?',
    steps: [
      {
        text: 'Equivalent stiffness for parallel springs:',
        latex: 'k_{eq} = k_1 + k_2 = 3{,}000 + 6{,}000 = 9{,}000 \\text{ N/m}'
      },
      {
        text: 'Natural circular frequency:',
        latex: '\\omega_n = \\sqrt{\\frac{k_{eq}}{m}} = \\sqrt{\\frac{9{,}000}{10}} = \\sqrt{900} = 30 \\text{ rad/s}'
      },
      {
        text: 'Convert to Hz:',
        latex: 'f_n = \\frac{30}{2\\pi} = 4.77 \\text{ Hz}'
      }
    ],
    handbookPage: 'p. 112',
    handbookFormula: '\\omega_n = \\sqrt{k/m}',
    videoUrl: null,
    traps: [
      'Using the series formula $(1/k_1 + 1/k_2)^{-1}$ instead of parallel ($k_1 + k_2$)',
      'Reporting $\\omega_n$ in rad/s instead of converting to Hz'
    ],
    diagram: null,
    lessonId: 'vibrations-natural-frequency',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-vnf-ex3',
    type: 'computational',
    statement: 'A spring-mass system has a natural frequency of $5 \\text{ Hz}$ and a damping coefficient $c = 40 \\text{ N}{\\cdot}\\text{s/m}$. The mass is $2 \\text{ kg}$. What is the damping ratio $\\zeta$?',
    choices: [
      {
        id: 'c1',
        text: '$1.00$'
      },
      {
        id: 'c2',
        text: '$0.64$'
      },
      {
        id: 'c3',
        text: '$0.32$'
      },
      {
        id: 'c4',
        text: '$2.00$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'First convert $f_n = 5$ Hz to $\\omega_n = 2\\pi(5) = 31.42$ rad/s. Then find $k$ from $\\omega_n = \\sqrt{k/m}$: $k = m \\omega_n^2 = 2(31.42^2) = 1975$ N/m. The critical damping coefficient is $c_c = 2\\sqrt{km} = 2\\sqrt{1975 \\times 2} = 2(62.85) = 125.7$ N·s/m. Finally, $\\zeta = c/c_c = 40/125.7 = 0.318$, approximately 0.32. The 0.64 distractor doubles the correct answer. The 1.0 distractor would be critically damped.',
    hint: 'Convert Hz to rad/s, then find $k$. The critical damping coefficient is $c_c = 2\\sqrt{km}$.',
    steps: [
      {
        text: 'Convert frequency to rad/s:',
        latex: '\\omega_n = 2\\pi f_n = 2\\pi(5) = 31.42 \\text{ rad/s}'
      },
      {
        text: 'Find spring stiffness:',
        latex: 'k = m\\omega_n^2 = 2(31.42)^2 = 1{,}975 \\text{ N/m}'
      },
      {
        text: 'Critical damping coefficient:',
        latex: 'c_c = 2\\sqrt{km} = 2\\sqrt{1{,}975 \\times 2} = 2(62.85) = 125.7 \\text{ N}{\\cdot}\\text{s/m}'
      },
      {
        text: 'Damping ratio:',
        latex: '\\zeta = \\frac{c}{c_c} = \\frac{40}{125.7} = 0.318 \\approx 0.32'
      }
    ],
    handbookPage: 'p. 112',
    handbookFormula: '\\zeta = \\frac{c}{2\\sqrt{km}}',
    videoUrl: null,
    traps: [
      'Forgetting to convert Hz to rad/s before computing $k$',
      'Using $c_c = \\sqrt{km}$ instead of $2\\sqrt{km}$, doubling the damping ratio'
    ],
    diagram: null,
    lessonId: 'vibrations-natural-frequency',
    chapterId: 'dynamics'
  },
  {
    id: 'dyn-vnf-ex4',
    type: 'conceptual',
    statement: 'A damped spring-mass system has a damping ratio $\\zeta = 1.2$. Which of the following best describes the system\'s free response after an initial displacement?',
    choices: [
      {
        id: 'c1',
        text: 'The system oscillates with constant amplitude.'
      },
      {
        id: 'c2',
        text: 'The system oscillates with exponentially decaying amplitude.'
      },
      {
        id: 'c3',
        text: 'The system returns to equilibrium without oscillating, but slower than critically damped.'
      },
      {
        id: 'c4',
        text: 'The system returns to equilibrium in the shortest possible time without oscillating.'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'When $\\zeta > 1$, the system is overdamped. It returns to equilibrium without oscillating, but it does so slower than the critically damped case ($\\zeta = 1$). The "oscillates with constant amplitude" choice describes an undamped system ($\\zeta = 0$). The "exponentially decaying amplitude" choice describes underdamped ($\\zeta < 1$). The "shortest possible time without oscillating" choice describes critically damped ($\\zeta = 1$ exactly). The key insight is that critical damping is the fastest non-oscillatory return. Adding more damping beyond that actually slows the response down, which is counterintuitive.',
    hint: 'What are the three damping regimes, and which one does $\\zeta = 1.2$ fall into?',
    steps: [
      {
        text: '$\\zeta < 1$: underdamped (oscillates with decaying amplitude).',
        latex: null
      },
      {
        text: '$\\zeta = 1$: critically damped (fastest non-oscillatory return to equilibrium).',
        latex: null
      },
      {
        text: '$\\zeta > 1$: overdamped (returns to equilibrium without oscillating, but slower than critical damping).',
        latex: null
      },
      {
        text: 'Since $\\zeta = 1.2 > 1$, the system is overdamped. It creeps back to equilibrium without any oscillation, taking longer than the critically damped case.',
        latex: null
      }
    ],
    handbookPage: 'p. 112',
    handbookFormula: '\\zeta = \\frac{c}{2\\sqrt{km}}',
    videoUrl: null,
    traps: [
      'Thinking more damping always means faster return to equilibrium (critically damped is actually the fastest non-oscillatory case)'
    ],
    diagram: null,
    lessonId: 'vibrations-natural-frequency',
    chapterId: 'dynamics'
  },
];

export default PROBLEMS;
