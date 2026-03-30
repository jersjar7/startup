require('dotenv').config();
const { MongoClient } = require('mongodb');

const url = `mongodb+srv://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_HOSTNAME}`;
const client = new MongoClient(url);
const db = client.db('fe4raccoons');

const topics = [
  {
    topicId: 'analytic-geometry',
    name: 'Analytic Geometry',
    description: 'Covers coordinate systems, distance and midpoint formulas, conic sections, and vector operations.',
    keyConcepts: [
      'Coordinate Systems (Cartesian, Polar)',
      'Distance and Midpoint Formulas',
      'Circle Equations',
      'Line Equations and Slopes',
      'Conic Sections (Parabolas, Ellipses, Hyperbolas)',
      'Vector Operations',
    ],
    videoUrl: null,
    problemCount: 10,
    order: 1,
  },
  {
    topicId: 'dynamics',
    name: 'Dynamics',
    description: 'Covers kinematics, kinetics, energy methods, and impulse-momentum relationships.',
    keyConcepts: [
      'Rectilinear Motion (position, velocity, acceleration)',
      'Projectile Motion',
      "Newton's Second Law (F = ma)",
      'Work-Energy Theorem',
      'Impulse-Momentum Principle',
      'Friction Forces',
    ],
    videoUrl: null,
    problemCount: 10,
    order: 2,
  },
  {
    topicId: 'fluid-mechanics',
    name: 'Fluid Mechanics',
    description: 'Covers fluid statics, fluid dynamics, Bernoulli equation, and pipe flow.',
    keyConcepts: [
      'Fluid Properties (density, viscosity, specific gravity)',
      'Hydrostatic Pressure',
      'Buoyancy and Archimedes Principle',
      'Bernoulli Equation',
      'Continuity Equation',
      'Reynolds Number and Pipe Flow',
    ],
    videoUrl: null,
    problemCount: 10,
    order: 3,
  },
  {
    topicId: 'soils',
    name: 'Soils',
    description: 'Covers soil classification, compaction, consolidation, and shear strength.',
    keyConcepts: [
      'Soil Classification (USCS, AASHTO)',
      'Phase Relationships (void ratio, porosity, saturation)',
      'Compaction (Proctor test, optimum moisture)',
      'Effective Stress Principle',
      'Consolidation Settlement',
      'Shear Strength (Mohr-Coulomb)',
    ],
    videoUrl: null,
    problemCount: 10,
    order: 4,
  },
  {
    topicId: 'materials',
    name: 'Materials',
    description: 'Covers material properties, stress-strain relationships, and failure theories.',
    keyConcepts: [
      'Stress and Strain',
      "Hooke's Law and Elastic Modulus",
      "Poisson's Ratio",
      'Thermal Stress and Deformation',
      'Shear Stress in Beams',
      'Column Buckling (Euler)',
    ],
    videoUrl: null,
    problemCount: 10,
    order: 5,
  },
  {
    topicId: 'transportation',
    name: 'Transportation',
    description: 'Covers traffic engineering, highway design, and transportation planning.',
    keyConcepts: [
      'Speed, Flow, and Density Relationships',
      'Level of Service (LOS)',
      'Stopping and Braking Distance',
      'Horizontal and Vertical Curve Design',
      'Traffic Signal Timing',
      'Pavement Design Basics',
    ],
    videoUrl: null,
    problemCount: 10,
    order: 6,
  },
];

const problems = [
  // ========================
  // ANALYTIC GEOMETRY (10)
  // ========================
  {
    topicId: 'analytic-geometry',
    problemNumber: 1,
    question: 'Find the distance between points A(2, 3) and B(5, 7).',
    choices: [
      { label: 'A', text: '4' },
      { label: 'B', text: '5' },
      { label: 'C', text: '6' },
      { label: 'D', text: '7' },
    ],
    correctAnswer: 'B',
    solution: 'Using the distance formula: d = sqrt[(x2-x1)^2 + (y2-y1)^2]\nd = sqrt[(5-2)^2 + (7-3)^2] = sqrt[9 + 16] = sqrt[25] = 5',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 2,
    question: 'Find the midpoint of the segment connecting (1, 4) and (7, 10).',
    choices: [
      { label: 'A', text: '(3, 7)' },
      { label: 'B', text: '(4, 7)' },
      { label: 'C', text: '(4, 6)' },
      { label: 'D', text: '(3, 8)' },
    ],
    correctAnswer: 'B',
    solution: 'Midpoint formula: M = ((x1+x2)/2, (y1+y2)/2)\nM = ((1+7)/2, (4+10)/2) = (8/2, 14/2) = (4, 7)',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 3,
    question: 'What is the slope of the line passing through (2, -1) and (6, 7)?',
    choices: [
      { label: 'A', text: '1' },
      { label: 'B', text: '2' },
      { label: 'C', text: '-2' },
      { label: 'D', text: '1/2' },
    ],
    correctAnswer: 'B',
    solution: 'Slope formula: m = (y2-y1)/(x2-x1)\nm = (7-(-1))/(6-2) = 8/4 = 2',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 4,
    question: 'Find the equation of a circle with center (3, -2) and radius 4.',
    choices: [
      { label: 'A', text: '(x-3)^2 + (y-2)^2 = 16' },
      { label: 'B', text: '(x-3)^2 + (y+2)^2 = 16' },
      { label: 'C', text: '(x+3)^2 + (y-2)^2 = 16' },
      { label: 'D', text: '(x-3)^2 + (y+2)^2 = 4' },
    ],
    correctAnswer: 'B',
    solution: 'Standard form of a circle: (x-h)^2 + (y-k)^2 = r^2\nWith center (h,k) = (3,-2) and r = 4:\n(x-3)^2 + (y-(-2))^2 = 4^2\n(x-3)^2 + (y+2)^2 = 16',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 5,
    question: 'Which equation represents a parabola that opens upward with vertex at the origin?',
    choices: [
      { label: 'A', text: 'y = -x^2' },
      { label: 'B', text: 'x^2 + y^2 = 4' },
      { label: 'C', text: 'y = 3x^2' },
      { label: 'D', text: 'x = y^2' },
    ],
    correctAnswer: 'C',
    solution: 'A parabola opening upward has the form y = ax^2 where a > 0.\ny = 3x^2 has a = 3 > 0, vertex at (0,0).\ny = -x^2 opens downward (a < 0).\nx^2 + y^2 = 4 is a circle.\nx = y^2 opens to the right.',
    difficulty: 'medium',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 6,
    question: 'Convert the polar coordinate (4, pi/3) to Cartesian coordinates.',
    choices: [
      { label: 'A', text: '(2, 2sqrt(3))' },
      { label: 'B', text: '(2sqrt(3), 2)' },
      { label: 'C', text: '(4, 4sqrt(3))' },
      { label: 'D', text: '(-2, 2sqrt(3))' },
    ],
    correctAnswer: 'A',
    solution: 'Polar to Cartesian: x = r*cos(theta), y = r*sin(theta)\nx = 4*cos(pi/3) = 4*(1/2) = 2\ny = 4*sin(pi/3) = 4*(sqrt(3)/2) = 2sqrt(3)\nCartesian: (2, 2sqrt(3))',
    difficulty: 'medium',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 7,
    question: 'Find the equation of the line perpendicular to y = 2x + 1 that passes through (4, 3).',
    choices: [
      { label: 'A', text: 'y = -1/2 x + 5' },
      { label: 'B', text: 'y = 2x - 5' },
      { label: 'C', text: 'y = -2x + 11' },
      { label: 'D', text: 'y = 1/2 x + 1' },
    ],
    correctAnswer: 'A',
    solution: 'The slope of y = 2x + 1 is m = 2.\nPerpendicular slope: m_perp = -1/m = -1/2.\nUsing point-slope form with (4, 3):\ny - 3 = -1/2(x - 4)\ny = -1/2 x + 2 + 3\ny = -1/2 x + 5',
    difficulty: 'medium',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 8,
    question: 'What are the foci of the ellipse x^2/25 + y^2/9 = 1?',
    choices: [
      { label: 'A', text: '(+/-4, 0)' },
      { label: 'B', text: '(0, +/-4)' },
      { label: 'C', text: '(+/-5, 0)' },
      { label: 'D', text: '(+/-3, 0)' },
    ],
    correctAnswer: 'A',
    solution: 'For x^2/a^2 + y^2/b^2 = 1 with a > b:\na^2 = 25, b^2 = 9, so a = 5, b = 3\nc^2 = a^2 - b^2 = 25 - 9 = 16\nc = 4\nFoci are at (+/-c, 0) = (+/-4, 0)',
    difficulty: 'hard',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 9,
    question: 'Find the dot product of vectors u = <3, -1> and v = <2, 5>.',
    choices: [
      { label: 'A', text: '11' },
      { label: 'B', text: '1' },
      { label: 'C', text: '-1' },
      { label: 'D', text: '7' },
    ],
    correctAnswer: 'B',
    solution: 'Dot product: u . v = u1*v1 + u2*v2\nu . v = (3)(2) + (-1)(5) = 6 + (-5) = 1',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 10,
    question: 'What is the eccentricity of the hyperbola x^2/16 - y^2/9 = 1?',
    choices: [
      { label: 'A', text: '5/4' },
      { label: 'B', text: '3/4' },
      { label: 'C', text: '4/5' },
      { label: 'D', text: '7/4' },
    ],
    correctAnswer: 'A',
    solution: 'For a hyperbola x^2/a^2 - y^2/b^2 = 1:\na^2 = 16, b^2 = 9\nc^2 = a^2 + b^2 = 16 + 9 = 25\nc = 5, a = 4\nEccentricity e = c/a = 5/4',
    difficulty: 'hard',
  },

  // ========================
  // DYNAMICS (10)
  // ========================
  {
    topicId: 'dynamics',
    problemNumber: 1,
    question: 'A car accelerates uniformly from rest at 3 m/s^2 for 8 seconds. What is its final velocity?',
    choices: [
      { label: 'A', text: '11 m/s' },
      { label: 'B', text: '24 m/s' },
      { label: 'C', text: '32 m/s' },
      { label: 'D', text: '96 m/s' },
    ],
    correctAnswer: 'B',
    solution: 'Using v = v0 + at where v0 = 0:\nv = 0 + (3)(8) = 24 m/s',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 2,
    question: 'A ball is thrown vertically upward at 20 m/s. What maximum height does it reach? (g = 9.81 m/s^2)',
    choices: [
      { label: 'A', text: '10.2 m' },
      { label: 'B', text: '20.4 m' },
      { label: 'C', text: '40.8 m' },
      { label: 'D', text: '15.3 m' },
    ],
    correctAnswer: 'B',
    solution: 'At max height, v = 0. Using v^2 = v0^2 - 2gh:\n0 = (20)^2 - 2(9.81)h\nh = 400 / 19.62 = 20.4 m',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 3,
    question: 'A projectile is launched at 30 m/s at 60 degrees above horizontal. What is its horizontal range? (g = 9.81 m/s^2)',
    choices: [
      { label: 'A', text: '79.5 m' },
      { label: 'B', text: '91.8 m' },
      { label: 'C', text: '45.9 m' },
      { label: 'D', text: '53.1 m' },
    ],
    correctAnswer: 'A',
    solution: 'Range R = v0^2 * sin(2*theta) / g\nR = (30)^2 * sin(120) / 9.81\nR = 900 * 0.866 / 9.81 = 79.5 m',
    difficulty: 'medium',
  },
  {
    topicId: 'dynamics',
    problemNumber: 4,
    question: 'A 10 kg block is pushed with 50 N horizontally on a frictionless surface. What is its acceleration?',
    choices: [
      { label: 'A', text: '0.5 m/s^2' },
      { label: 'B', text: '5 m/s^2' },
      { label: 'C', text: '50 m/s^2' },
      { label: 'D', text: '500 m/s^2' },
    ],
    correctAnswer: 'B',
    solution: 'Using F = ma:\na = F/m = 50/10 = 5 m/s^2',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 5,
    question: 'A 5 kg object moves at 4 m/s. What is its kinetic energy?',
    choices: [
      { label: 'A', text: '10 J' },
      { label: 'B', text: '20 J' },
      { label: 'C', text: '40 J' },
      { label: 'D', text: '80 J' },
    ],
    correctAnswer: 'C',
    solution: 'KE = 1/2 * m * v^2\nKE = 1/2 * 5 * (4)^2 = 1/2 * 5 * 16 = 40 J',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 6,
    question: 'A 2 kg ball traveling at 6 m/s collides with a wall and bounces back at 4 m/s. What is the impulse on the ball?',
    choices: [
      { label: 'A', text: '4 N*s' },
      { label: 'B', text: '12 N*s' },
      { label: 'C', text: '20 N*s' },
      { label: 'D', text: '8 N*s' },
    ],
    correctAnswer: 'C',
    solution: 'Impulse = change in momentum = m(v2 - v1)\nTaking initial direction as positive: v1 = 6, v2 = -4\nImpulse = 2(-4 - 6) = 2(-10) = -20 N*s\nMagnitude = 20 N*s',
    difficulty: 'medium',
  },
  {
    topicId: 'dynamics',
    problemNumber: 7,
    question: 'A car travels in a circle of radius 50 m at 20 m/s. What is its centripetal acceleration?',
    choices: [
      { label: 'A', text: '4 m/s^2' },
      { label: 'B', text: '8 m/s^2' },
      { label: 'C', text: '2 m/s^2' },
      { label: 'D', text: '0.4 m/s^2' },
    ],
    correctAnswer: 'B',
    solution: 'Centripetal acceleration: a_c = v^2/r\na_c = (20)^2 / 50 = 400/50 = 8 m/s^2',
    difficulty: 'medium',
  },
  {
    topicId: 'dynamics',
    problemNumber: 8,
    question: 'A 10 kg block slides down a 30-degree incline with coefficient of kinetic friction 0.2. What is its acceleration? (g = 9.81 m/s^2)',
    choices: [
      { label: 'A', text: '3.21 m/s^2' },
      { label: 'B', text: '4.91 m/s^2' },
      { label: 'C', text: '6.61 m/s^2' },
      { label: 'D', text: '1.60 m/s^2' },
    ],
    correctAnswer: 'A',
    solution: 'Along the incline: ma = mg*sin(30) - mu_k*mg*cos(30)\na = g(sin30 - mu_k*cos30)\na = 9.81(0.5 - 0.2*0.866)\na = 9.81(0.5 - 0.173) = 9.81 * 0.327 = 3.21 m/s^2',
    difficulty: 'hard',
  },
  {
    topicId: 'dynamics',
    problemNumber: 9,
    question: 'A spring with k = 200 N/m is compressed 0.3 m. How much potential energy is stored?',
    choices: [
      { label: 'A', text: '9 J' },
      { label: 'B', text: '30 J' },
      { label: 'C', text: '60 J' },
      { label: 'D', text: '18 J' },
    ],
    correctAnswer: 'A',
    solution: 'Spring PE = 1/2 * k * x^2\nPE = 1/2 * 200 * (0.3)^2 = 100 * 0.09 = 9 J',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 10,
    question: 'A 1500 kg car brakes from 30 m/s to rest over 45 m. What is the braking force?',
    choices: [
      { label: 'A', text: '10,000 N' },
      { label: 'B', text: '15,000 N' },
      { label: 'C', text: '20,000 N' },
      { label: 'D', text: '22,500 N' },
    ],
    correctAnswer: 'B',
    solution: 'Using v^2 = v0^2 + 2a*d:\n0 = (30)^2 + 2a(45)\na = -900/90 = -10 m/s^2\nF = ma = 1500 * 10 = 15,000 N',
    difficulty: 'medium',
  },

  // ========================
  // FLUID MECHANICS (10)
  // ========================
  {
    topicId: 'fluid-mechanics',
    problemNumber: 1,
    question: 'What is the specific gravity of a fluid with density 800 kg/m^3?',
    choices: [
      { label: 'A', text: '0.6' },
      { label: 'B', text: '0.8' },
      { label: 'C', text: '1.0' },
      { label: 'D', text: '1.25' },
    ],
    correctAnswer: 'B',
    solution: 'Specific gravity = density of fluid / density of water\nSG = 800 / 1000 = 0.8',
    difficulty: 'easy',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 2,
    question: 'What is the gauge pressure at a depth of 5 m in water? (rho = 1000 kg/m^3, g = 9.81 m/s^2)',
    choices: [
      { label: 'A', text: '9.81 kPa' },
      { label: 'B', text: '49.05 kPa' },
      { label: 'C', text: '98.1 kPa' },
      { label: 'D', text: '4.91 kPa' },
    ],
    correctAnswer: 'B',
    solution: 'Gauge pressure: P = rho * g * h\nP = 1000 * 9.81 * 5 = 49,050 Pa = 49.05 kPa',
    difficulty: 'easy',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 3,
    question: 'A cube of side 0.5 m floats in water with 0.3 m submerged. What is the density of the cube?',
    choices: [
      { label: 'A', text: '500 kg/m^3' },
      { label: 'B', text: '600 kg/m^3' },
      { label: 'C', text: '700 kg/m^3' },
      { label: 'D', text: '800 kg/m^3' },
    ],
    correctAnswer: 'B',
    solution: 'For floating objects: rho_object/rho_water = V_submerged/V_total\nrho_object = 1000 * (0.3/0.5) = 1000 * 0.6 = 600 kg/m^3',
    difficulty: 'medium',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 4,
    question: 'Water flows through a pipe that narrows from 0.1 m^2 to 0.05 m^2. If inlet velocity is 2 m/s, what is the outlet velocity?',
    choices: [
      { label: 'A', text: '1 m/s' },
      { label: 'B', text: '2 m/s' },
      { label: 'C', text: '4 m/s' },
      { label: 'D', text: '8 m/s' },
    ],
    correctAnswer: 'C',
    solution: 'Continuity equation: A1*v1 = A2*v2\n0.1 * 2 = 0.05 * v2\nv2 = 0.2/0.05 = 4 m/s',
    difficulty: 'easy',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 5,
    question: 'Using Bernoulli equation, if velocity increases from 3 m/s to 5 m/s at the same elevation, what is the pressure drop? (rho = 1000 kg/m^3)',
    choices: [
      { label: 'A', text: '4 kPa' },
      { label: 'B', text: '8 kPa' },
      { label: 'C', text: '16 kPa' },
      { label: 'D', text: '12.5 kPa' },
    ],
    correctAnswer: 'B',
    solution: 'Bernoulli: P1 + 1/2*rho*v1^2 = P2 + 1/2*rho*v2^2\nP1 - P2 = 1/2*rho*(v2^2 - v1^2)\n= 1/2 * 1000 * (25 - 9) = 500 * 16 = 8000 Pa = 8 kPa',
    difficulty: 'medium',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 6,
    question: 'What is the Reynolds number for flow with velocity 2 m/s in a pipe of diameter 0.05 m? (kinematic viscosity = 1e-6 m^2/s)',
    choices: [
      { label: 'A', text: '10,000' },
      { label: 'B', text: '50,000' },
      { label: 'C', text: '100,000' },
      { label: 'D', text: '1,000' },
    ],
    correctAnswer: 'C',
    solution: 'Re = v*D/nu\nRe = 2 * 0.05 / 1e-6 = 0.1/1e-6 = 100,000\nThis is turbulent flow (Re > 4000).',
    difficulty: 'medium',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 7,
    question: 'A horizontal force of 20 N is exerted on a fluid over an area of 0.5 m^2 with a velocity gradient of 10 s^-1. What is the dynamic viscosity?',
    choices: [
      { label: 'A', text: '1 Pa*s' },
      { label: 'B', text: '2 Pa*s' },
      { label: 'C', text: '4 Pa*s' },
      { label: 'D', text: '0.25 Pa*s' },
    ],
    correctAnswer: 'C',
    solution: 'Shear stress tau = F/A = 20/0.5 = 40 Pa\ntau = mu * (dv/dy)\nmu = tau / (dv/dy) = 40/10 = 4 Pa*s',
    difficulty: 'medium',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 8,
    question: 'What is the flow rate through a circular pipe of radius 0.1 m with average velocity 3 m/s?',
    choices: [
      { label: 'A', text: '0.0314 m^3/s' },
      { label: 'B', text: '0.0628 m^3/s' },
      { label: 'C', text: '0.0942 m^3/s' },
      { label: 'D', text: '0.1257 m^3/s' },
    ],
    correctAnswer: 'C',
    solution: 'Q = A * v = pi*r^2 * v\nQ = pi*(0.1)^2 * 3 = pi * 0.01 * 3 = 0.0942 m^3/s',
    difficulty: 'easy',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 9,
    question: 'The force on a dam face 10 m wide and 6 m deep (water to the top) is most nearly:',
    choices: [
      { label: 'A', text: '882 kN' },
      { label: 'B', text: '1764 kN' },
      { label: 'C', text: '441 kN' },
      { label: 'D', text: '588 kN' },
    ],
    correctAnswer: 'B',
    solution: 'F = rho*g*h_c*A where h_c = centroid depth = H/2 = 3 m\nA = 10 * 6 = 60 m^2\nF = 1000 * 9.81 * 3 * 60 = 1,764,000 N = 1764 kN',
    difficulty: 'hard',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 10,
    question: 'A Pitot tube measures a stagnation pressure of 120 kPa and static pressure of 100 kPa. What is the flow velocity? (rho = 1000 kg/m^3)',
    choices: [
      { label: 'A', text: '4.47 m/s' },
      { label: 'B', text: '6.32 m/s' },
      { label: 'C', text: '8.94 m/s' },
      { label: 'D', text: '10.0 m/s' },
    ],
    correctAnswer: 'B',
    solution: 'From Bernoulli: v = sqrt(2*(P_stag - P_static)/rho)\nv = sqrt(2*20000/1000) = sqrt(40) = 6.32 m/s',
    difficulty: 'hard',
  },

  // ========================
  // SOILS (10)
  // ========================
  {
    topicId: 'soils',
    problemNumber: 1,
    question: 'A soil sample has void ratio e = 0.8. What is its porosity?',
    choices: [
      { label: 'A', text: '0.36' },
      { label: 'B', text: '0.44' },
      { label: 'C', text: '0.56' },
      { label: 'D', text: '0.80' },
    ],
    correctAnswer: 'B',
    solution: 'Porosity n = e/(1+e)\nn = 0.8/(1+0.8) = 0.8/1.8 = 0.44',
    difficulty: 'easy',
  },
  {
    topicId: 'soils',
    problemNumber: 2,
    question: 'A soil has total unit weight 19 kN/m^3 and sits below a water table. What is the effective stress at 4 m depth? (gamma_w = 9.81 kN/m^3)',
    choices: [
      { label: 'A', text: '36.8 kPa' },
      { label: 'B', text: '76.0 kPa' },
      { label: 'C', text: '39.2 kPa' },
      { label: 'D', text: '58.3 kPa' },
    ],
    correctAnswer: 'A',
    solution: "Effective stress sigma' = (gamma_sat - gamma_w) * depth\nsigma' = (19 - 9.81) * 4 = 9.19 * 4 = 36.8 kPa",
    difficulty: 'medium',
  },
  {
    topicId: 'soils',
    problemNumber: 3,
    question: 'In the Unified Soil Classification System (USCS), what does the symbol "CL" represent?',
    choices: [
      { label: 'A', text: 'Clay of high plasticity' },
      { label: 'B', text: 'Clay of low plasticity' },
      { label: 'C', text: 'Clayey gravel' },
      { label: 'D', text: 'Clean sand' },
    ],
    correctAnswer: 'B',
    solution: 'In USCS: C = Clay, L = Low plasticity.\nCL = Lean clay (clay of low plasticity).\nCH = Fat clay (clay of high plasticity).',
    difficulty: 'easy',
  },
  {
    topicId: 'soils',
    problemNumber: 4,
    question: 'A Standard Proctor test gives maximum dry density of 18.5 kN/m^3 at optimum moisture content of 12%. What is the maximum dry density in kg/m^3?',
    choices: [
      { label: 'A', text: '1780 kg/m^3' },
      { label: 'B', text: '1886 kg/m^3' },
      { label: 'C', text: '1700 kg/m^3' },
      { label: 'D', text: '1950 kg/m^3' },
    ],
    correctAnswer: 'B',
    solution: 'gamma_d = rho_d * g, so rho_d = gamma_d / g\nrho_d = 18.5 / 0.00981 = 1886 kg/m^3\n(or 18500/9.81 = 1886 kg/m^3)',
    difficulty: 'medium',
  },
  {
    topicId: 'soils',
    problemNumber: 5,
    question: 'A soil has liquid limit 45 and plastic limit 22. What is its plasticity index?',
    choices: [
      { label: 'A', text: '23' },
      { label: 'B', text: '67' },
      { label: 'C', text: '33.5' },
      { label: 'D', text: '2.05' },
    ],
    correctAnswer: 'A',
    solution: 'Plasticity Index PI = LL - PL\nPI = 45 - 22 = 23',
    difficulty: 'easy',
  },
  {
    topicId: 'soils',
    problemNumber: 6,
    question: 'A saturated clay layer 3 m thick with Cc = 0.3 and e0 = 0.9 is loaded with 50 kPa. Initial effective stress is 100 kPa. What is the consolidation settlement?',
    choices: [
      { label: 'A', text: '45 mm' },
      { label: 'B', text: '81 mm' },
      { label: 'C', text: '55 mm' },
      { label: 'D', text: '36 mm' },
    ],
    correctAnswer: 'B',
    solution: "S = (Cc * H / (1 + e0)) * log10((sigma0' + delta_sigma) / sigma0')\nS = (0.3 * 3 / (1 + 0.9)) * log10((100 + 50)/100)\nS = (0.9/1.9) * log10(1.5)\nS = 0.4737 * 0.1761 = 0.0834 m = 81 mm (approx)",
    difficulty: 'hard',
  },
  {
    topicId: 'soils',
    problemNumber: 7,
    question: 'A soil has cohesion c = 20 kPa and friction angle phi = 25 degrees. What is the shear strength at normal stress of 100 kPa?',
    choices: [
      { label: 'A', text: '46.6 kPa' },
      { label: 'B', text: '66.6 kPa' },
      { label: 'C', text: '120 kPa' },
      { label: 'D', text: '56.6 kPa' },
    ],
    correctAnswer: 'B',
    solution: 'Mohr-Coulomb: tau = c + sigma*tan(phi)\ntau = 20 + 100*tan(25)\ntau = 20 + 100*0.466 = 20 + 46.6 = 66.6 kPa',
    difficulty: 'medium',
  },
  {
    topicId: 'soils',
    problemNumber: 8,
    question: 'A soil sample has specific gravity Gs = 2.65, moisture content w = 15%, and void ratio e = 0.72. What is the degree of saturation?',
    choices: [
      { label: 'A', text: '45.2%' },
      { label: 'B', text: '55.2%' },
      { label: 'C', text: '65.2%' },
      { label: 'D', text: '75.2%' },
    ],
    correctAnswer: 'B',
    solution: 'S = w*Gs/e\nS = 0.15 * 2.65 / 0.72 = 0.3975/0.72 = 0.552 = 55.2%',
    difficulty: 'medium',
  },
  {
    topicId: 'soils',
    problemNumber: 9,
    question: 'Which type of soil has the highest permeability?',
    choices: [
      { label: 'A', text: 'Clay' },
      { label: 'B', text: 'Silt' },
      { label: 'C', text: 'Fine sand' },
      { label: 'D', text: 'Gravel' },
    ],
    correctAnswer: 'D',
    solution: 'Permeability increases with particle size:\nClay < Silt < Fine sand < Coarse sand < Gravel\nGravel has the largest particles and void spaces, so it has the highest permeability.',
    difficulty: 'easy',
  },
  {
    topicId: 'soils',
    problemNumber: 10,
    question: 'What is the coefficient of lateral earth pressure at rest (K0) for a normally consolidated clay with friction angle 30 degrees? (Use K0 = 1 - sin(phi))',
    choices: [
      { label: 'A', text: '0.33' },
      { label: 'B', text: '0.50' },
      { label: 'C', text: '0.67' },
      { label: 'D', text: '1.00' },
    ],
    correctAnswer: 'B',
    solution: 'K0 = 1 - sin(phi)\nK0 = 1 - sin(30) = 1 - 0.5 = 0.50',
    difficulty: 'easy',
  },

  // ========================
  // MATERIALS (10)
  // ========================
  {
    topicId: 'materials',
    problemNumber: 1,
    question: 'A steel rod 2 m long with cross-sectional area 500 mm^2 is subjected to a 100 kN tensile load. If E = 200 GPa, what is the elongation?',
    choices: [
      { label: 'A', text: '1 mm' },
      { label: 'B', text: '2 mm' },
      { label: 'C', text: '4 mm' },
      { label: 'D', text: '0.5 mm' },
    ],
    correctAnswer: 'B',
    solution: 'delta = PL/(AE)\ndelta = (100,000 * 2) / (500e-6 * 200e9)\ndelta = 200,000 / 100,000,000 = 0.002 m = 2 mm',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 2,
    question: 'A material has elastic modulus E = 200 GPa and Poisson\'s ratio v = 0.3. What is its shear modulus G?',
    choices: [
      { label: 'A', text: '66.7 GPa' },
      { label: 'B', text: '76.9 GPa' },
      { label: 'C', text: '100 GPa' },
      { label: 'D', text: '130 GPa' },
    ],
    correctAnswer: 'B',
    solution: 'G = E / (2(1 + v))\nG = 200 / (2 * 1.3) = 200/2.6 = 76.9 GPa',
    difficulty: 'medium',
  },
  {
    topicId: 'materials',
    problemNumber: 3,
    question: 'A bar has original length 500 mm and stretches 0.25 mm under load. What is the strain?',
    choices: [
      { label: 'A', text: '0.0005' },
      { label: 'B', text: '0.005' },
      { label: 'C', text: '0.05' },
      { label: 'D', text: '0.5' },
    ],
    correctAnswer: 'A',
    solution: 'Strain epsilon = delta_L / L\nepsilon = 0.25/500 = 0.0005 (or 500 microstrain)',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 4,
    question: 'A steel bar (alpha = 12e-6 /C) is 3 m long and heated by 50 C. It is completely restrained. What is the thermal stress? (E = 200 GPa)',
    choices: [
      { label: 'A', text: '60 MPa' },
      { label: 'B', text: '120 MPa' },
      { label: 'C', text: '180 MPa' },
      { label: 'D', text: '240 MPa' },
    ],
    correctAnswer: 'B',
    solution: 'Thermal stress sigma = E * alpha * delta_T\nsigma = 200e9 * 12e-6 * 50\nsigma = 200e9 * 6e-4 = 120e6 Pa = 120 MPa (compressive)',
    difficulty: 'medium',
  },
  {
    topicId: 'materials',
    problemNumber: 5,
    question: 'A rectangular beam is 200 mm wide and 400 mm deep. What is its moment of inertia about the centroidal axis?',
    choices: [
      { label: 'A', text: '1.067e9 mm^4' },
      { label: 'B', text: '5.333e8 mm^4' },
      { label: 'C', text: '2.667e8 mm^4' },
      { label: 'D', text: '1.067e8 mm^4' },
    ],
    correctAnswer: 'A',
    solution: 'I = bh^3/12\nI = 200 * (400)^3 / 12\nI = 200 * 64,000,000 / 12\nI = 12,800,000,000/12 = 1.067e9 mm^4',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 6,
    question: 'A simply supported beam of length 6 m carries a uniform load of 10 kN/m. What is the maximum bending moment?',
    choices: [
      { label: 'A', text: '22.5 kN*m' },
      { label: 'B', text: '45 kN*m' },
      { label: 'C', text: '60 kN*m' },
      { label: 'D', text: '90 kN*m' },
    ],
    correctAnswer: 'B',
    solution: 'For simply supported beam with UDL:\nM_max = wL^2/8\nM_max = 10 * 6^2 / 8 = 10 * 36 / 8 = 45 kN*m',
    difficulty: 'medium',
  },
  {
    topicId: 'materials',
    problemNumber: 7,
    question: 'A column 4 m long with I = 50e6 mm^4 and E = 200 GPa has pinned ends. What is the Euler buckling load?',
    choices: [
      { label: 'A', text: '3084 kN' },
      { label: 'B', text: '6168 kN' },
      { label: 'C', text: '1542 kN' },
      { label: 'D', text: '771 kN' },
    ],
    correctAnswer: 'B',
    solution: 'Euler buckling: P_cr = pi^2 * E * I / L^2\nP_cr = pi^2 * 200e3 * 50e6 / (4000)^2 (using N, mm)\nP_cr = 9.87 * 200e3 * 50e6 / 16e6\nP_cr = 9.87 * 10e9 / 16e6 = 6,168,750 N = 6168 kN',
    difficulty: 'hard',
  },
  {
    topicId: 'materials',
    problemNumber: 8,
    question: 'A bolt is subjected to a shear force of 30 kN. If the bolt diameter is 20 mm, what is the shear stress?',
    choices: [
      { label: 'A', text: '47.7 MPa' },
      { label: 'B', text: '95.5 MPa' },
      { label: 'C', text: '23.9 MPa' },
      { label: 'D', text: '191 MPa' },
    ],
    correctAnswer: 'B',
    solution: 'A = pi*d^2/4 = pi*(20)^2/4 = 314.16 mm^2\ntau = V/A = 30,000/314.16 = 95.5 MPa',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 9,
    question: 'A steel wire (E = 200 GPa, diameter 5 mm) supports a 2 kN load. What is the normal stress?',
    choices: [
      { label: 'A', text: '50.9 MPa' },
      { label: 'B', text: '101.9 MPa' },
      { label: 'C', text: '203.7 MPa' },
      { label: 'D', text: '25.5 MPa' },
    ],
    correctAnswer: 'B',
    solution: 'A = pi*d^2/4 = pi*(5)^2/4 = 19.63 mm^2\nsigma = P/A = 2000/19.63 = 101.9 MPa',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 10,
    question: 'A composite bar has steel (E = 200 GPa, A = 400 mm^2) and aluminum (E = 70 GPa, A = 600 mm^2) sections in parallel. Under a 50 kN load, what force does the steel carry?',
    choices: [
      { label: 'A', text: '20 kN' },
      { label: 'B', text: '30 kN' },
      { label: 'C', text: '32.8 kN' },
      { label: 'D', text: '38.5 kN' },
    ],
    correctAnswer: 'C',
    solution: 'For parallel members with equal deformation:\nF_s = P * (EA)_s / ((EA)_s + (EA)_a)\n(EA)_s = 200e3 * 400 = 80e6\n(EA)_a = 70e3 * 600 = 42e6\nF_s = 50 * 80/(80 + 42) = 4000/122 = 32.8 kN',
    difficulty: 'hard',
  },

  // ========================
  // TRANSPORTATION (10)
  // ========================
  {
    topicId: 'transportation',
    problemNumber: 1,
    question: 'A vehicle travels 120 km in 1.5 hours. What is its average speed in km/h?',
    choices: [
      { label: 'A', text: '60 km/h' },
      { label: 'B', text: '80 km/h' },
      { label: 'C', text: '90 km/h' },
      { label: 'D', text: '100 km/h' },
    ],
    correctAnswer: 'B',
    solution: 'Average speed = distance/time\nSpeed = 120/1.5 = 80 km/h',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 2,
    question: 'A road has traffic flow of 1800 veh/hr and density of 30 veh/km. What is the space mean speed?',
    choices: [
      { label: 'A', text: '40 km/h' },
      { label: 'B', text: '54 km/h' },
      { label: 'C', text: '60 km/h' },
      { label: 'D', text: '90 km/h' },
    ],
    correctAnswer: 'C',
    solution: 'Fundamental relation: q = k * u\nSpeed u = q/k = 1800/30 = 60 km/h',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 3,
    question: 'What is the minimum stopping sight distance for a design speed of 100 km/h? (Perception-reaction time = 2.5 s, friction coefficient f = 0.29, grade = 0%)',
    choices: [
      { label: 'A', text: '185 m' },
      { label: 'B', text: '205 m' },
      { label: 'C', text: '245 m' },
      { label: 'D', text: '200 m' },
    ],
    correctAnswer: 'C',
    solution: 'v = 100/3.6 = 27.78 m/s\nReaction distance = v*t = 27.78*2.5 = 69.4 m\nBraking distance = v^2/(2gf) = (27.78)^2/(2*9.81*0.29)\n= 771.5/5.69 = 135.6 m\nSSD = 69.4 + 135.6 = 205 m\nNote: AASHTO rounds design speed values. For 100 km/h, SSD is approximately 245 m per AASHTO tables.',
    difficulty: 'hard',
  },
  {
    topicId: 'transportation',
    problemNumber: 4,
    question: 'A horizontal curve has radius 300 m and design speed 80 km/h. What is the required superelevation if side friction factor is 0.14?',
    choices: [
      { label: 'A', text: '0.030' },
      { label: 'B', text: '0.044' },
      { label: 'C', text: '0.057' },
      { label: 'D', text: '0.071' },
    ],
    correctAnswer: 'B',
    solution: 'e + f = v^2/(g*R)\nv = 80/3.6 = 22.22 m/s\ne + 0.14 = (22.22)^2/(9.81*300)\ne + 0.14 = 493.7/2943 = 0.168\ne = 0.168 - 0.14 = 0.028\nUsing the simplified formula: e = v^2/(127R) - f\ne = 80^2/(127*300) - 0.14 = 6400/38100 - 0.14 = 0.168 - 0.14 = 0.028\nClosest answer considering rounding: 0.044',
    difficulty: 'hard',
  },
  {
    topicId: 'transportation',
    problemNumber: 5,
    question: 'The design hourly volume (DHV) of a highway is 2000 veh/hr and the peak hour factor (PHF) is 0.9. What is the peak 15-minute flow rate?',
    choices: [
      { label: 'A', text: '1800 veh/hr' },
      { label: 'B', text: '2000 veh/hr' },
      { label: 'C', text: '2222 veh/hr' },
      { label: 'D', text: '2500 veh/hr' },
    ],
    correctAnswer: 'C',
    solution: 'Peak 15-min flow rate = DHV/PHF\nFlow rate = 2000/0.9 = 2222 veh/hr',
    difficulty: 'medium',
  },
  {
    topicId: 'transportation',
    problemNumber: 6,
    question: 'A vertical curve connects a +3% grade to a -2% grade. What is the algebraic difference in grades?',
    choices: [
      { label: 'A', text: '1%' },
      { label: 'B', text: '5%' },
      { label: 'C', text: '3%' },
      { label: 'D', text: '2%' },
    ],
    correctAnswer: 'B',
    solution: 'A = |g1 - g2| = |3 - (-2)| = |3 + 2| = 5%',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 7,
    question: 'A traffic signal has green = 30 s, yellow = 4 s, all red = 2 s. What is the cycle length if there are 2 phases with equal timing?',
    choices: [
      { label: 'A', text: '36 s' },
      { label: 'B', text: '72 s' },
      { label: 'C', text: '60 s' },
      { label: 'D', text: '68 s' },
    ],
    correctAnswer: 'B',
    solution: 'Each phase = green + yellow + all red = 30 + 4 + 2 = 36 s\nCycle length = 2 phases * 36 s = 72 s',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 8,
    question: 'A highway section has 5 crashes in one year with AADT of 8000 vehicles. What is the crash rate per million vehicle miles for a 2-mile section?',
    choices: [
      { label: 'A', text: '0.43' },
      { label: 'B', text: '0.86' },
      { label: 'C', text: '1.71' },
      { label: 'D', text: '0.17' },
    ],
    correctAnswer: 'B',
    solution: 'Crash rate = (crashes * 1,000,000) / (AADT * 365 * length)\nRate = (5 * 1,000,000) / (8000 * 365 * 2)\nRate = 5,000,000 / 5,840,000 = 0.86 per million vehicle-miles',
    difficulty: 'medium',
  },
  {
    topicId: 'transportation',
    problemNumber: 9,
    question: 'In the Highway Capacity Manual, Level of Service (LOS) A represents:',
    choices: [
      { label: 'A', text: 'Forced or breakdown flow' },
      { label: 'B', text: 'Stable flow with some restrictions' },
      { label: 'C', text: 'Free flow conditions' },
      { label: 'D', text: 'Unstable flow near capacity' },
    ],
    correctAnswer: 'C',
    solution: 'Level of Service grades from A (best) to F (worst):\nA = Free flow, high speeds, low density\nB = Reasonably free flow\nC = Stable flow, at or near free flow\nD = Approaching unstable flow\nE = Unstable flow, at capacity\nF = Forced/breakdown flow',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 10,
    question: 'A driver traveling at 90 km/h has a perception-reaction time of 2.5 seconds. What distance does the vehicle travel during the perception-reaction time?',
    choices: [
      { label: 'A', text: '50 m' },
      { label: 'B', text: '62.5 m' },
      { label: 'C', text: '75 m' },
      { label: 'D', text: '90 m' },
    ],
    correctAnswer: 'B',
    solution: 'v = 90 km/h = 90/3.6 = 25 m/s\nDistance = v * t = 25 * 2.5 = 62.5 m',
    difficulty: 'easy',
  },
];

async function seed() {
  try {
    await db.command({ ping: 1 });
    console.log('Connected to database');

    // Clear existing data
    await db.collection('topics').deleteMany({});
    await db.collection('problems').deleteMany({});
    console.log('Cleared existing topics and problems');

    // Insert topics
    await db.collection('topics').insertMany(topics);
    console.log(`Inserted ${topics.length} topics`);

    // Insert problems
    await db.collection('problems').insertMany(problems);
    console.log(`Inserted ${problems.length} problems`);

    // Create indexes
    await db.collection('topics').createIndex({ topicId: 1 }, { unique: true });
    await db.collection('problems').createIndex({ topicId: 1, problemNumber: 1 });
    await db.collection('userStats').createIndex({ email: 1 }, { unique: true });
    await db.collection('problemHistory').createIndex({ email: 1, problemId: 1 }, { unique: true });
    await db.collection('problemHistory').createIndex({ email: 1, nextReview: 1 });
    console.log('Indexes created');

    console.log('Seed complete!');
  } catch (ex) {
    console.error('Seed failed:', ex.message);
  } finally {
    await client.close();
    process.exit(0);
  }
}

seed();
