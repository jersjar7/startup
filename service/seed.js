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
    videoUrl: 'https://www.youtube.com/embed/HfACrKJ_Y2w',
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
    videoUrl: 'https://www.youtube.com/embed/1gRnRBMr38I',
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
    videoUrl: 'https://www.youtube.com/embed/PZtgxFJqHBk',
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
    videoUrl: 'https://www.youtube.com/embed/bGxloYCfHZs',
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
    videoUrl: 'https://www.youtube.com/embed/RHJ5FGbrVbc',
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
    videoUrl: 'https://www.youtube.com/embed/UpLYJbjaFfU',
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
    question: 'Find the distance between points $A(2, 3)$ and $B(5, 7)$.',
    choices: [
      { label: 'A', text: '$4$' },
      { label: 'B', text: '$5$' },
      { label: 'C', text: '$6$' },
      { label: 'D', text: '$7$' },
    ],
    correctAnswer: 'B',
    solution: 'Using the distance formula: $d = \\sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}$\n$d = \\sqrt{(5-2)^2 + (7-3)^2} = \\sqrt{9 + 16} = \\sqrt{25} = 5$',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 2,
    question: 'Find the midpoint of the segment connecting $(1, 4)$ and $(7, 10)$.',
    choices: [
      { label: 'A', text: '$(3, 7)$' },
      { label: 'B', text: '$(4, 7)$' },
      { label: 'C', text: '$(4, 6)$' },
      { label: 'D', text: '$(3, 8)$' },
    ],
    correctAnswer: 'B',
    solution: 'Midpoint formula: $M = \\left(\\frac{x_1+x_2}{2},\\ \\frac{y_1+y_2}{2}\\right)$\n$M = \\left(\\frac{1+7}{2},\\ \\frac{4+10}{2}\\right) = (4,\\ 7)$',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 3,
    question: 'What is the slope of the line passing through $(2, -1)$ and $(6, 7)$?',
    choices: [
      { label: 'A', text: '$1$' },
      { label: 'B', text: '$2$' },
      { label: 'C', text: '$-2$' },
      { label: 'D', text: '$\\frac{1}{2}$' },
    ],
    correctAnswer: 'B',
    solution: 'Slope formula: $m = \\frac{y_2-y_1}{x_2-x_1}$\n$m = \\frac{7-(-1)}{6-2} = \\frac{8}{4} = 2$',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 4,
    question: 'Find the equation of a circle with center $(3, -2)$ and radius $4$.',
    choices: [
      { label: 'A', text: '$(x-3)^2 + (y-2)^2 = 16$' },
      { label: 'B', text: '$(x-3)^2 + (y+2)^2 = 16$' },
      { label: 'C', text: '$(x+3)^2 + (y-2)^2 = 16$' },
      { label: 'D', text: '$(x-3)^2 + (y+2)^2 = 4$' },
    ],
    correctAnswer: 'B',
    solution: 'Standard form: $(x-h)^2 + (y-k)^2 = r^2$\nWith center $(h,k) = (3,-2)$ and $r = 4$:\n$(x-3)^2 + (y+2)^2 = 16$',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 5,
    question: 'Which equation represents a parabola that opens upward with vertex at the origin?',
    choices: [
      { label: 'A', text: '$y = -x^2$' },
      { label: 'B', text: '$x^2 + y^2 = 4$' },
      { label: 'C', text: '$y = 3x^2$' },
      { label: 'D', text: '$x = y^2$' },
    ],
    correctAnswer: 'C',
    solution: 'A parabola opening upward has the form $y = ax^2$ where $a > 0$.\n$y = 3x^2$ has $a = 3 > 0$, vertex at $(0,0)$.\n$y = -x^2$ opens downward ($a < 0$).\n$x^2 + y^2 = 4$ is a circle.\n$x = y^2$ opens to the right.',
    difficulty: 'medium',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 6,
    question: 'Convert the polar coordinate $\\left(4,\\ \\frac{\\pi}{3}\\right)$ to Cartesian coordinates.',
    choices: [
      { label: 'A', text: '$(2,\\ 2\\sqrt{3})$' },
      { label: 'B', text: '$(2\\sqrt{3},\\ 2)$' },
      { label: 'C', text: '$(4,\\ 4\\sqrt{3})$' },
      { label: 'D', text: '$(-2,\\ 2\\sqrt{3})$' },
    ],
    correctAnswer: 'A',
    solution: 'Polar to Cartesian: $x = r\\cos\\theta$, $y = r\\sin\\theta$\n$x = 4\\cos\\frac{\\pi}{3} = 4 \\cdot \\frac{1}{2} = 2$\n$y = 4\\sin\\frac{\\pi}{3} = 4 \\cdot \\frac{\\sqrt{3}}{2} = 2\\sqrt{3}$\nCartesian: $(2,\\ 2\\sqrt{3})$',
    difficulty: 'medium',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 7,
    question: 'Find the equation of the line perpendicular to $y = 2x + 1$ that passes through $(4, 3)$.',
    choices: [
      { label: 'A', text: '$y = -\\frac{1}{2}x + 5$' },
      { label: 'B', text: '$y = 2x - 5$' },
      { label: 'C', text: '$y = -2x + 11$' },
      { label: 'D', text: '$y = \\frac{1}{2}x + 1$' },
    ],
    correctAnswer: 'A',
    solution: 'The slope of $y = 2x + 1$ is $m = 2$.\nPerpendicular slope: $m_{\\perp} = -\\frac{1}{2}$.\nUsing point-slope form with $(4, 3)$:\n$y - 3 = -\\frac{1}{2}(x - 4)$\n$y = -\\frac{1}{2}x + 5$',
    difficulty: 'medium',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 8,
    question: 'What are the foci of the ellipse $\\frac{x^2}{25} + \\frac{y^2}{9} = 1$?',
    choices: [
      { label: 'A', text: '$(\\pm 4,\\ 0)$' },
      { label: 'B', text: '$(0,\\ \\pm 4)$' },
      { label: 'C', text: '$(\\pm 5,\\ 0)$' },
      { label: 'D', text: '$(\\pm 3,\\ 0)$' },
    ],
    correctAnswer: 'A',
    solution: 'For $\\frac{x^2}{a^2} + \\frac{y^2}{b^2} = 1$ with $a > b$:\n$a^2 = 25$, $b^2 = 9$, so $a = 5$, $b = 3$\n$c^2 = a^2 - b^2 = 25 - 9 = 16$\n$c = 4$\nFoci are at $(\\pm 4,\\ 0)$',
    difficulty: 'hard',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 9,
    question: 'Find the dot product of vectors $\\mathbf{u} = \\langle 3, -1 \\rangle$ and $\\mathbf{v} = \\langle 2, 5 \\rangle$.',
    choices: [
      { label: 'A', text: '$11$' },
      { label: 'B', text: '$1$' },
      { label: 'C', text: '$-1$' },
      { label: 'D', text: '$7$' },
    ],
    correctAnswer: 'B',
    solution: 'Dot product: $\\mathbf{u} \\cdot \\mathbf{v} = u_1 v_1 + u_2 v_2$\n$= (3)(2) + (-1)(5) = 6 - 5 = 1$',
    difficulty: 'easy',
  },
  {
    topicId: 'analytic-geometry',
    problemNumber: 10,
    question: 'What is the eccentricity of the hyperbola $\\frac{x^2}{16} - \\frac{y^2}{9} = 1$?',
    choices: [
      { label: 'A', text: '$\\frac{5}{4}$' },
      { label: 'B', text: '$\\frac{3}{4}$' },
      { label: 'C', text: '$\\frac{4}{5}$' },
      { label: 'D', text: '$\\frac{7}{4}$' },
    ],
    correctAnswer: 'A',
    solution: 'For $\\frac{x^2}{a^2} - \\frac{y^2}{b^2} = 1$:\n$a^2 = 16$, $b^2 = 9$\n$c^2 = a^2 + b^2 = 25$, so $c = 5$, $a = 4$\nEccentricity $e = \\frac{c}{a} = \\frac{5}{4}$',
    difficulty: 'hard',
  },

  // ========================
  // DYNAMICS (10)
  // ========================
  {
    topicId: 'dynamics',
    problemNumber: 1,
    question: 'A car accelerates uniformly from rest at $3\\ \\text{m/s}^2$ for $8$ seconds. What is its final velocity?',
    choices: [
      { label: 'A', text: '$11\\ \\text{m/s}$' },
      { label: 'B', text: '$24\\ \\text{m/s}$' },
      { label: 'C', text: '$32\\ \\text{m/s}$' },
      { label: 'D', text: '$96\\ \\text{m/s}$' },
    ],
    correctAnswer: 'B',
    solution: 'Using $v = v_0 + at$ where $v_0 = 0$:\n$v = 0 + (3)(8) = 24\\ \\text{m/s}$',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 2,
    question: 'A ball is thrown vertically upward at $20\\ \\text{m/s}$. What maximum height does it reach? ($g = 9.81\\ \\text{m/s}^2$)',
    choices: [
      { label: 'A', text: '$10.2\\ \\text{m}$' },
      { label: 'B', text: '$20.4\\ \\text{m}$' },
      { label: 'C', text: '$40.8\\ \\text{m}$' },
      { label: 'D', text: '$15.3\\ \\text{m}$' },
    ],
    correctAnswer: 'B',
    solution: 'At max height, $v = 0$. Using $v^2 = v_0^2 - 2gh$:\n$0 = (20)^2 - 2(9.81)h$\n$h = \\frac{400}{19.62} = 20.4\\ \\text{m}$',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 3,
    question: 'A projectile is launched at $30\\ \\text{m/s}$ at $60°$ above horizontal. What is its horizontal range? ($g = 9.81\\ \\text{m/s}^2$)',
    choices: [
      { label: 'A', text: '$79.5\\ \\text{m}$' },
      { label: 'B', text: '$91.8\\ \\text{m}$' },
      { label: 'C', text: '$45.9\\ \\text{m}$' },
      { label: 'D', text: '$53.1\\ \\text{m}$' },
    ],
    correctAnswer: 'A',
    solution: 'Range $R = \\frac{v_0^2 \\sin(2\\theta)}{g}$\n$R = \\frac{(30)^2 \\sin(120°)}{9.81} = \\frac{900 \\times 0.866}{9.81} = 79.5\\ \\text{m}$',
    difficulty: 'medium',
  },
  {
    topicId: 'dynamics',
    problemNumber: 4,
    question: 'A $10\\ \\text{kg}$ block is pushed with $50\\ \\text{N}$ horizontally on a frictionless surface. What is its acceleration?',
    choices: [
      { label: 'A', text: '$0.5\\ \\text{m/s}^2$' },
      { label: 'B', text: '$5\\ \\text{m/s}^2$' },
      { label: 'C', text: '$50\\ \\text{m/s}^2$' },
      { label: 'D', text: '$500\\ \\text{m/s}^2$' },
    ],
    correctAnswer: 'B',
    solution: 'Using $F = ma$:\n$a = \\frac{F}{m} = \\frac{50}{10} = 5\\ \\text{m/s}^2$',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 5,
    question: 'A $5\\ \\text{kg}$ object moves at $4\\ \\text{m/s}$. What is its kinetic energy?',
    choices: [
      { label: 'A', text: '$10\\ \\text{J}$' },
      { label: 'B', text: '$20\\ \\text{J}$' },
      { label: 'C', text: '$40\\ \\text{J}$' },
      { label: 'D', text: '$80\\ \\text{J}$' },
    ],
    correctAnswer: 'C',
    solution: '$KE = \\frac{1}{2}mv^2 = \\frac{1}{2}(5)(4)^2 = \\frac{1}{2}(5)(16) = 40\\ \\text{J}$',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 6,
    question: 'A $2\\ \\text{kg}$ ball traveling at $6\\ \\text{m/s}$ collides with a wall and bounces back at $4\\ \\text{m/s}$. What is the impulse on the ball?',
    choices: [
      { label: 'A', text: '$4\\ \\text{N·s}$' },
      { label: 'B', text: '$12\\ \\text{N·s}$' },
      { label: 'C', text: '$20\\ \\text{N·s}$' },
      { label: 'D', text: '$8\\ \\text{N·s}$' },
    ],
    correctAnswer: 'C',
    solution: 'Impulse $= \\Delta p = m(v_2 - v_1)$\nTaking initial direction as positive: $v_1 = 6$, $v_2 = -4$\nImpulse $= 2(-4 - 6) = -20\\ \\text{N·s}$\nMagnitude $= 20\\ \\text{N·s}$',
    difficulty: 'medium',
  },
  {
    topicId: 'dynamics',
    problemNumber: 7,
    question: 'A car travels in a circle of radius $50\\ \\text{m}$ at $20\\ \\text{m/s}$. What is its centripetal acceleration?',
    choices: [
      { label: 'A', text: '$4\\ \\text{m/s}^2$' },
      { label: 'B', text: '$8\\ \\text{m/s}^2$' },
      { label: 'C', text: '$2\\ \\text{m/s}^2$' },
      { label: 'D', text: '$0.4\\ \\text{m/s}^2$' },
    ],
    correctAnswer: 'B',
    solution: 'Centripetal acceleration: $a_c = \\frac{v^2}{r} = \\frac{(20)^2}{50} = \\frac{400}{50} = 8\\ \\text{m/s}^2$',
    difficulty: 'medium',
  },
  {
    topicId: 'dynamics',
    problemNumber: 8,
    question: 'A $10\\ \\text{kg}$ block slides down a $30°$ incline with $\\mu_k = 0.2$. What is its acceleration? ($g = 9.81\\ \\text{m/s}^2$)',
    choices: [
      { label: 'A', text: '$3.21\\ \\text{m/s}^2$' },
      { label: 'B', text: '$4.91\\ \\text{m/s}^2$' },
      { label: 'C', text: '$6.61\\ \\text{m/s}^2$' },
      { label: 'D', text: '$1.60\\ \\text{m/s}^2$' },
    ],
    correctAnswer: 'A',
    solution: 'Along the incline: $a = g(\\sin 30° - \\mu_k \\cos 30°)$\n$a = 9.81(0.5 - 0.2 \\times 0.866)$\n$= 9.81(0.5 - 0.173) = 9.81 \\times 0.327 = 3.21\\ \\text{m/s}^2$',
    difficulty: 'hard',
  },
  {
    topicId: 'dynamics',
    problemNumber: 9,
    question: 'A spring with $k = 200\\ \\text{N/m}$ is compressed $0.3\\ \\text{m}$. How much potential energy is stored?',
    choices: [
      { label: 'A', text: '$9\\ \\text{J}$' },
      { label: 'B', text: '$30\\ \\text{J}$' },
      { label: 'C', text: '$60\\ \\text{J}$' },
      { label: 'D', text: '$18\\ \\text{J}$' },
    ],
    correctAnswer: 'A',
    solution: 'Spring PE $= \\frac{1}{2}kx^2 = \\frac{1}{2}(200)(0.3)^2 = 100 \\times 0.09 = 9\\ \\text{J}$',
    difficulty: 'easy',
  },
  {
    topicId: 'dynamics',
    problemNumber: 10,
    question: 'A $1500\\ \\text{kg}$ car brakes from $30\\ \\text{m/s}$ to rest over $45\\ \\text{m}$. What is the braking force?',
    choices: [
      { label: 'A', text: '$10{,}000\\ \\text{N}$' },
      { label: 'B', text: '$15{,}000\\ \\text{N}$' },
      { label: 'C', text: '$20{,}000\\ \\text{N}$' },
      { label: 'D', text: '$22{,}500\\ \\text{N}$' },
    ],
    correctAnswer: 'B',
    solution: 'Using $v^2 = v_0^2 + 2ad$:\n$0 = (30)^2 + 2a(45)$\n$a = \\frac{-900}{90} = -10\\ \\text{m/s}^2$\n$F = ma = 1500 \\times 10 = 15{,}000\\ \\text{N}$',
    difficulty: 'medium',
  },

  // ========================
  // FLUID MECHANICS (10)
  // ========================
  {
    topicId: 'fluid-mechanics',
    problemNumber: 1,
    question: 'What is the specific gravity of a fluid with density $800\\ \\text{kg/m}^3$?',
    choices: [
      { label: 'A', text: '$0.6$' },
      { label: 'B', text: '$0.8$' },
      { label: 'C', text: '$1.0$' },
      { label: 'D', text: '$1.25$' },
    ],
    correctAnswer: 'B',
    solution: '$SG = \\frac{\\rho_{\\text{fluid}}}{\\rho_{\\text{water}}} = \\frac{800}{1000} = 0.8$',
    difficulty: 'easy',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 2,
    question: 'What is the gauge pressure at a depth of $5\\ \\text{m}$ in water? ($\\rho = 1000\\ \\text{kg/m}^3$, $g = 9.81\\ \\text{m/s}^2$)',
    choices: [
      { label: 'A', text: '$9.81\\ \\text{kPa}$' },
      { label: 'B', text: '$49.05\\ \\text{kPa}$' },
      { label: 'C', text: '$98.1\\ \\text{kPa}$' },
      { label: 'D', text: '$4.91\\ \\text{kPa}$' },
    ],
    correctAnswer: 'B',
    solution: 'Gauge pressure: $P = \\rho g h = 1000 \\times 9.81 \\times 5 = 49{,}050\\ \\text{Pa} = 49.05\\ \\text{kPa}$',
    difficulty: 'easy',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 3,
    question: 'A cube of side $0.5\\ \\text{m}$ floats in water with $0.3\\ \\text{m}$ submerged. What is the density of the cube?',
    choices: [
      { label: 'A', text: '$500\\ \\text{kg/m}^3$' },
      { label: 'B', text: '$600\\ \\text{kg/m}^3$' },
      { label: 'C', text: '$700\\ \\text{kg/m}^3$' },
      { label: 'D', text: '$800\\ \\text{kg/m}^3$' },
    ],
    correctAnswer: 'B',
    solution: 'For floating objects: $\\frac{\\rho_{\\text{obj}}}{\\rho_{\\text{water}}} = \\frac{V_{\\text{sub}}}{V_{\\text{total}}}$\n$\\rho_{\\text{obj}} = 1000 \\times \\frac{0.3}{0.5} = 600\\ \\text{kg/m}^3$',
    difficulty: 'medium',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 4,
    question: 'Water flows through a pipe that narrows from $0.1\\ \\text{m}^2$ to $0.05\\ \\text{m}^2$. If inlet velocity is $2\\ \\text{m/s}$, what is the outlet velocity?',
    choices: [
      { label: 'A', text: '$1\\ \\text{m/s}$' },
      { label: 'B', text: '$2\\ \\text{m/s}$' },
      { label: 'C', text: '$4\\ \\text{m/s}$' },
      { label: 'D', text: '$8\\ \\text{m/s}$' },
    ],
    correctAnswer: 'C',
    solution: 'Continuity equation: $A_1 v_1 = A_2 v_2$\n$0.1 \\times 2 = 0.05 \\times v_2$\n$v_2 = \\frac{0.2}{0.05} = 4\\ \\text{m/s}$',
    difficulty: 'easy',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 5,
    question: 'Using Bernoulli\'s equation, if velocity increases from $3\\ \\text{m/s}$ to $5\\ \\text{m/s}$ at the same elevation, what is the pressure drop? ($\\rho = 1000\\ \\text{kg/m}^3$)',
    choices: [
      { label: 'A', text: '$4\\ \\text{kPa}$' },
      { label: 'B', text: '$8\\ \\text{kPa}$' },
      { label: 'C', text: '$16\\ \\text{kPa}$' },
      { label: 'D', text: '$12.5\\ \\text{kPa}$' },
    ],
    correctAnswer: 'B',
    solution: '$P_1 - P_2 = \\frac{1}{2}\\rho(v_2^2 - v_1^2) = \\frac{1}{2}(1000)(25 - 9) = 500 \\times 16 = 8000\\ \\text{Pa} = 8\\ \\text{kPa}$',
    difficulty: 'medium',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 6,
    question: 'What is the Reynolds number for flow with velocity $2\\ \\text{m/s}$ in a pipe of diameter $0.05\\ \\text{m}$? ($\\nu = 10^{-6}\\ \\text{m}^2\\text{/s}$)',
    choices: [
      { label: 'A', text: '$10{,}000$' },
      { label: 'B', text: '$50{,}000$' },
      { label: 'C', text: '$100{,}000$' },
      { label: 'D', text: '$1{,}000$' },
    ],
    correctAnswer: 'C',
    solution: '$Re = \\frac{vD}{\\nu} = \\frac{2 \\times 0.05}{10^{-6}} = \\frac{0.1}{10^{-6}} = 100{,}000$\nThis is turbulent flow ($Re > 4000$).',
    difficulty: 'medium',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 7,
    question: 'A horizontal force of $20\\ \\text{N}$ is exerted on a fluid over an area of $0.5\\ \\text{m}^2$ with a velocity gradient of $10\\ \\text{s}^{-1}$. What is the dynamic viscosity?',
    choices: [
      { label: 'A', text: '$1\\ \\text{Pa·s}$' },
      { label: 'B', text: '$2\\ \\text{Pa·s}$' },
      { label: 'C', text: '$4\\ \\text{Pa·s}$' },
      { label: 'D', text: '$0.25\\ \\text{Pa·s}$' },
    ],
    correctAnswer: 'C',
    solution: 'Shear stress $\\tau = \\frac{F}{A} = \\frac{20}{0.5} = 40\\ \\text{Pa}$\n$\\tau = \\mu \\frac{dv}{dy}$\n$\\mu = \\frac{\\tau}{dv/dy} = \\frac{40}{10} = 4\\ \\text{Pa·s}$',
    difficulty: 'medium',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 8,
    question: 'What is the flow rate through a circular pipe of radius $0.1\\ \\text{m}$ with average velocity $3\\ \\text{m/s}$?',
    choices: [
      { label: 'A', text: '$0.0314\\ \\text{m}^3\\text{/s}$' },
      { label: 'B', text: '$0.0628\\ \\text{m}^3\\text{/s}$' },
      { label: 'C', text: '$0.0942\\ \\text{m}^3\\text{/s}$' },
      { label: 'D', text: '$0.1257\\ \\text{m}^3\\text{/s}$' },
    ],
    correctAnswer: 'C',
    solution: '$Q = Av = \\pi r^2 v = \\pi(0.1)^2(3) = 0.0942\\ \\text{m}^3\\text{/s}$',
    difficulty: 'easy',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 9,
    question: 'The force on a dam face $10\\ \\text{m}$ wide and $6\\ \\text{m}$ deep (water to the top) is most nearly:',
    choices: [
      { label: 'A', text: '$882\\ \\text{kN}$' },
      { label: 'B', text: '$1764\\ \\text{kN}$' },
      { label: 'C', text: '$441\\ \\text{kN}$' },
      { label: 'D', text: '$588\\ \\text{kN}$' },
    ],
    correctAnswer: 'B',
    solution: '$F = \\rho g h_c A$ where $h_c = \\frac{H}{2} = 3\\ \\text{m}$\n$A = 10 \\times 6 = 60\\ \\text{m}^2$\n$F = 1000 \\times 9.81 \\times 3 \\times 60 = 1{,}764{,}000\\ \\text{N} = 1764\\ \\text{kN}$',
    difficulty: 'hard',
  },
  {
    topicId: 'fluid-mechanics',
    problemNumber: 10,
    question: 'A Pitot tube measures stagnation pressure of $120\\ \\text{kPa}$ and static pressure of $100\\ \\text{kPa}$. What is the flow velocity? ($\\rho = 1000\\ \\text{kg/m}^3$)',
    choices: [
      { label: 'A', text: '$4.47\\ \\text{m/s}$' },
      { label: 'B', text: '$6.32\\ \\text{m/s}$' },
      { label: 'C', text: '$8.94\\ \\text{m/s}$' },
      { label: 'D', text: '$10.0\\ \\text{m/s}$' },
    ],
    correctAnswer: 'B',
    solution: '$v = \\sqrt{\\frac{2(P_{\\text{stag}} - P_{\\text{static}})}{\\rho}} = \\sqrt{\\frac{2 \\times 20000}{1000}} = \\sqrt{40} = 6.32\\ \\text{m/s}$',
    difficulty: 'hard',
  },

  // ========================
  // SOILS (10)
  // ========================
  {
    topicId: 'soils',
    problemNumber: 1,
    question: 'A soil sample has void ratio $e = 0.8$. What is its porosity?',
    choices: [
      { label: 'A', text: '$0.36$' },
      { label: 'B', text: '$0.44$' },
      { label: 'C', text: '$0.56$' },
      { label: 'D', text: '$0.80$' },
    ],
    correctAnswer: 'B',
    solution: 'Porosity $n = \\frac{e}{1+e} = \\frac{0.8}{1.8} = 0.44$',
    difficulty: 'easy',
  },
  {
    topicId: 'soils',
    problemNumber: 2,
    question: 'A soil has total unit weight $19\\ \\text{kN/m}^3$ and sits below a water table. What is the effective stress at $4\\ \\text{m}$ depth? ($\\gamma_w = 9.81\\ \\text{kN/m}^3$)',
    choices: [
      { label: 'A', text: '$36.8\\ \\text{kPa}$' },
      { label: 'B', text: '$76.0\\ \\text{kPa}$' },
      { label: 'C', text: '$39.2\\ \\text{kPa}$' },
      { label: 'D', text: '$58.3\\ \\text{kPa}$' },
    ],
    correctAnswer: 'A',
    solution: "$\\sigma' = (\\gamma_{\\text{sat}} - \\gamma_w) \\times d = (19 - 9.81) \\times 4 = 9.19 \\times 4 = 36.8\\ \\text{kPa}$",
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
    question: 'A Standard Proctor test gives maximum dry density of $18.5\\ \\text{kN/m}^3$ at optimum moisture content of $12\\%$. What is the maximum dry density in $\\text{kg/m}^3$?',
    choices: [
      { label: 'A', text: '$1780\\ \\text{kg/m}^3$' },
      { label: 'B', text: '$1886\\ \\text{kg/m}^3$' },
      { label: 'C', text: '$1700\\ \\text{kg/m}^3$' },
      { label: 'D', text: '$1950\\ \\text{kg/m}^3$' },
    ],
    correctAnswer: 'B',
    solution: '$\\rho_d = \\frac{\\gamma_d}{g} = \\frac{18500}{9.81} = 1886\\ \\text{kg/m}^3$',
    difficulty: 'medium',
  },
  {
    topicId: 'soils',
    problemNumber: 5,
    question: 'A soil has liquid limit $45$ and plastic limit $22$. What is its plasticity index?',
    choices: [
      { label: 'A', text: '$23$' },
      { label: 'B', text: '$67$' },
      { label: 'C', text: '$33.5$' },
      { label: 'D', text: '$2.05$' },
    ],
    correctAnswer: 'A',
    solution: 'Plasticity Index $PI = LL - PL = 45 - 22 = 23$',
    difficulty: 'easy',
  },
  {
    topicId: 'soils',
    problemNumber: 6,
    question: 'A saturated clay layer $3\\ \\text{m}$ thick with $C_c = 0.3$ and $e_0 = 0.9$ is loaded with $50\\ \\text{kPa}$. Initial effective stress is $100\\ \\text{kPa}$. What is the consolidation settlement?',
    choices: [
      { label: 'A', text: '$45\\ \\text{mm}$' },
      { label: 'B', text: '$81\\ \\text{mm}$' },
      { label: 'C', text: '$55\\ \\text{mm}$' },
      { label: 'D', text: '$36\\ \\text{mm}$' },
    ],
    correctAnswer: 'B',
    solution: "$S = \\frac{C_c H}{1 + e_0} \\log_{10}\\!\\left(\\frac{\\sigma_0' + \\Delta\\sigma}{\\sigma_0'}\\right)$\n$= \\frac{0.3 \\times 3}{1.9} \\log_{10}(1.5)$\n$= 0.474 \\times 0.176 = 0.083\\ \\text{m} \\approx 81\\ \\text{mm}$",
    difficulty: 'hard',
  },
  {
    topicId: 'soils',
    problemNumber: 7,
    question: 'A soil has cohesion $c = 20\\ \\text{kPa}$ and friction angle $\\phi = 25°$. What is the shear strength at normal stress of $100\\ \\text{kPa}$?',
    choices: [
      { label: 'A', text: '$46.6\\ \\text{kPa}$' },
      { label: 'B', text: '$66.6\\ \\text{kPa}$' },
      { label: 'C', text: '$120\\ \\text{kPa}$' },
      { label: 'D', text: '$56.6\\ \\text{kPa}$' },
    ],
    correctAnswer: 'B',
    solution: 'Mohr-Coulomb: $\\tau = c + \\sigma \\tan\\phi$\n$= 20 + 100 \\tan 25° = 20 + 46.6 = 66.6\\ \\text{kPa}$',
    difficulty: 'medium',
  },
  {
    topicId: 'soils',
    problemNumber: 8,
    question: 'A soil sample has $G_s = 2.65$, moisture content $w = 15\\%$, and void ratio $e = 0.72$. What is the degree of saturation?',
    choices: [
      { label: 'A', text: '$45.2\\%$' },
      { label: 'B', text: '$55.2\\%$' },
      { label: 'C', text: '$65.2\\%$' },
      { label: 'D', text: '$75.2\\%$' },
    ],
    correctAnswer: 'B',
    solution: '$S = \\frac{wG_s}{e} = \\frac{0.15 \\times 2.65}{0.72} = \\frac{0.398}{0.72} = 0.552 = 55.2\\%$',
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
    solution: 'Permeability increases with particle size:\nClay < Silt < Fine sand < Coarse sand < Gravel\nGravel has the largest particles and void spaces.',
    difficulty: 'easy',
  },
  {
    topicId: 'soils',
    problemNumber: 10,
    question: 'What is $K_0$ for a normally consolidated clay with $\\phi = 30°$? (Use $K_0 = 1 - \\sin\\phi$)',
    choices: [
      { label: 'A', text: '$0.33$' },
      { label: 'B', text: '$0.50$' },
      { label: 'C', text: '$0.67$' },
      { label: 'D', text: '$1.00$' },
    ],
    correctAnswer: 'B',
    solution: '$K_0 = 1 - \\sin\\phi = 1 - \\sin 30° = 1 - 0.5 = 0.50$',
    difficulty: 'easy',
  },

  // ========================
  // MATERIALS (10)
  // ========================
  {
    topicId: 'materials',
    problemNumber: 1,
    question: 'A steel rod $2\\ \\text{m}$ long with cross-sectional area $500\\ \\text{mm}^2$ is subjected to a $100\\ \\text{kN}$ tensile load. If $E = 200\\ \\text{GPa}$, what is the elongation?',
    choices: [
      { label: 'A', text: '$1\\ \\text{mm}$' },
      { label: 'B', text: '$2\\ \\text{mm}$' },
      { label: 'C', text: '$4\\ \\text{mm}$' },
      { label: 'D', text: '$0.5\\ \\text{mm}$' },
    ],
    correctAnswer: 'B',
    solution: '$\\delta = \\frac{PL}{AE} = \\frac{100{,}000 \\times 2}{500 \\times 10^{-6} \\times 200 \\times 10^9} = \\frac{200{,}000}{100{,}000{,}000} = 0.002\\ \\text{m} = 2\\ \\text{mm}$',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 2,
    question: 'A material has $E = 200\\ \\text{GPa}$ and Poisson\'s ratio $\\nu = 0.3$. What is its shear modulus $G$?',
    choices: [
      { label: 'A', text: '$66.7\\ \\text{GPa}$' },
      { label: 'B', text: '$76.9\\ \\text{GPa}$' },
      { label: 'C', text: '$100\\ \\text{GPa}$' },
      { label: 'D', text: '$130\\ \\text{GPa}$' },
    ],
    correctAnswer: 'B',
    solution: '$G = \\frac{E}{2(1+\\nu)} = \\frac{200}{2(1.3)} = \\frac{200}{2.6} = 76.9\\ \\text{GPa}$',
    difficulty: 'medium',
  },
  {
    topicId: 'materials',
    problemNumber: 3,
    question: 'A bar has original length $500\\ \\text{mm}$ and stretches $0.25\\ \\text{mm}$ under load. What is the strain?',
    choices: [
      { label: 'A', text: '$0.0005$' },
      { label: 'B', text: '$0.005$' },
      { label: 'C', text: '$0.05$' },
      { label: 'D', text: '$0.5$' },
    ],
    correctAnswer: 'A',
    solution: '$\\varepsilon = \\frac{\\delta L}{L} = \\frac{0.25}{500} = 0.0005$',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 4,
    question: 'A steel bar ($\\alpha = 12 \\times 10^{-6}\\ /°\\text{C}$) is $3\\ \\text{m}$ long and heated by $50°\\text{C}$. It is completely restrained. What is the thermal stress? ($E = 200\\ \\text{GPa}$)',
    choices: [
      { label: 'A', text: '$60\\ \\text{MPa}$' },
      { label: 'B', text: '$120\\ \\text{MPa}$' },
      { label: 'C', text: '$180\\ \\text{MPa}$' },
      { label: 'D', text: '$240\\ \\text{MPa}$' },
    ],
    correctAnswer: 'B',
    solution: '$\\sigma = E \\alpha \\Delta T = 200 \\times 10^9 \\times 12 \\times 10^{-6} \\times 50 = 120\\ \\text{MPa}$',
    difficulty: 'medium',
  },
  {
    topicId: 'materials',
    problemNumber: 5,
    question: 'A rectangular beam is $200\\ \\text{mm}$ wide and $400\\ \\text{mm}$ deep. What is its moment of inertia about the centroidal axis?',
    choices: [
      { label: 'A', text: '$1.067 \\times 10^9\\ \\text{mm}^4$' },
      { label: 'B', text: '$5.333 \\times 10^8\\ \\text{mm}^4$' },
      { label: 'C', text: '$2.667 \\times 10^8\\ \\text{mm}^4$' },
      { label: 'D', text: '$1.067 \\times 10^8\\ \\text{mm}^4$' },
    ],
    correctAnswer: 'A',
    solution: '$I = \\frac{bh^3}{12} = \\frac{200 \\times 400^3}{12} = \\frac{200 \\times 64 \\times 10^6}{12} = 1.067 \\times 10^9\\ \\text{mm}^4$',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 6,
    question: 'A simply supported beam of length $6\\ \\text{m}$ carries a uniform load of $10\\ \\text{kN/m}$. What is the maximum bending moment?',
    choices: [
      { label: 'A', text: '$22.5\\ \\text{kN·m}$' },
      { label: 'B', text: '$45\\ \\text{kN·m}$' },
      { label: 'C', text: '$60\\ \\text{kN·m}$' },
      { label: 'D', text: '$90\\ \\text{kN·m}$' },
    ],
    correctAnswer: 'B',
    solution: '$M_{\\max} = \\frac{wL^2}{8} = \\frac{10 \\times 6^2}{8} = \\frac{360}{8} = 45\\ \\text{kN·m}$',
    difficulty: 'medium',
  },
  {
    topicId: 'materials',
    problemNumber: 7,
    question: 'A column $4\\ \\text{m}$ long with $I = 50 \\times 10^6\\ \\text{mm}^4$ and $E = 200\\ \\text{GPa}$ has pinned ends. What is the Euler buckling load?',
    choices: [
      { label: 'A', text: '$3084\\ \\text{kN}$' },
      { label: 'B', text: '$6168\\ \\text{kN}$' },
      { label: 'C', text: '$1542\\ \\text{kN}$' },
      { label: 'D', text: '$771\\ \\text{kN}$' },
    ],
    correctAnswer: 'B',
    solution: '$P_{cr} = \\frac{\\pi^2 EI}{L^2} = \\frac{\\pi^2 \\times 200 \\times 10^3 \\times 50 \\times 10^6}{4000^2}$\n$= \\frac{9.87 \\times 10^{13}}{16 \\times 10^6} = 6{,}169\\ \\text{kN}$',
    difficulty: 'hard',
  },
  {
    topicId: 'materials',
    problemNumber: 8,
    question: 'A bolt is subjected to a shear force of $30\\ \\text{kN}$. If the bolt diameter is $20\\ \\text{mm}$, what is the shear stress?',
    choices: [
      { label: 'A', text: '$47.7\\ \\text{MPa}$' },
      { label: 'B', text: '$95.5\\ \\text{MPa}$' },
      { label: 'C', text: '$23.9\\ \\text{MPa}$' },
      { label: 'D', text: '$191\\ \\text{MPa}$' },
    ],
    correctAnswer: 'B',
    solution: '$A = \\frac{\\pi d^2}{4} = \\frac{\\pi(20)^2}{4} = 314.16\\ \\text{mm}^2$\n$\\tau = \\frac{V}{A} = \\frac{30{,}000}{314.16} = 95.5\\ \\text{MPa}$',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 9,
    question: 'A steel wire ($E = 200\\ \\text{GPa}$, diameter $5\\ \\text{mm}$) supports a $2\\ \\text{kN}$ load. What is the normal stress?',
    choices: [
      { label: 'A', text: '$50.9\\ \\text{MPa}$' },
      { label: 'B', text: '$101.9\\ \\text{MPa}$' },
      { label: 'C', text: '$203.7\\ \\text{MPa}$' },
      { label: 'D', text: '$25.5\\ \\text{MPa}$' },
    ],
    correctAnswer: 'B',
    solution: '$A = \\frac{\\pi d^2}{4} = \\frac{\\pi(5)^2}{4} = 19.63\\ \\text{mm}^2$\n$\\sigma = \\frac{P}{A} = \\frac{2000}{19.63} = 101.9\\ \\text{MPa}$',
    difficulty: 'easy',
  },
  {
    topicId: 'materials',
    problemNumber: 10,
    question: 'A composite bar has steel ($E = 200\\ \\text{GPa}$, $A = 400\\ \\text{mm}^2$) and aluminum ($E = 70\\ \\text{GPa}$, $A = 600\\ \\text{mm}^2$) in parallel. Under a $50\\ \\text{kN}$ load, what force does the steel carry?',
    choices: [
      { label: 'A', text: '$20\\ \\text{kN}$' },
      { label: 'B', text: '$30\\ \\text{kN}$' },
      { label: 'C', text: '$32.8\\ \\text{kN}$' },
      { label: 'D', text: '$38.5\\ \\text{kN}$' },
    ],
    correctAnswer: 'C',
    solution: '$F_s = P \\times \\frac{(EA)_s}{(EA)_s + (EA)_a}$\n$(EA)_s = 200 \\times 10^3 \\times 400 = 80 \\times 10^6$\n$(EA)_a = 70 \\times 10^3 \\times 600 = 42 \\times 10^6$\n$F_s = 50 \\times \\frac{80}{122} = 32.8\\ \\text{kN}$',
    difficulty: 'hard',
  },

  // ========================
  // TRANSPORTATION (10)
  // ========================
  {
    topicId: 'transportation',
    problemNumber: 1,
    question: 'A vehicle travels $120\\ \\text{km}$ in $1.5$ hours. What is its average speed?',
    choices: [
      { label: 'A', text: '$60\\ \\text{km/h}$' },
      { label: 'B', text: '$80\\ \\text{km/h}$' },
      { label: 'C', text: '$90\\ \\text{km/h}$' },
      { label: 'D', text: '$100\\ \\text{km/h}$' },
    ],
    correctAnswer: 'B',
    solution: 'Average speed $= \\frac{\\text{distance}}{\\text{time}} = \\frac{120}{1.5} = 80\\ \\text{km/h}$',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 2,
    question: 'A road has traffic flow of $1800\\ \\text{veh/hr}$ and density of $30\\ \\text{veh/km}$. What is the space mean speed?',
    choices: [
      { label: 'A', text: '$40\\ \\text{km/h}$' },
      { label: 'B', text: '$54\\ \\text{km/h}$' },
      { label: 'C', text: '$60\\ \\text{km/h}$' },
      { label: 'D', text: '$90\\ \\text{km/h}$' },
    ],
    correctAnswer: 'C',
    solution: 'Fundamental relation: $q = k \\cdot u$\n$u = \\frac{q}{k} = \\frac{1800}{30} = 60\\ \\text{km/h}$',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 3,
    question: 'What is the minimum stopping sight distance for a design speed of $100\\ \\text{km/h}$? (PRT $= 2.5\\ \\text{s}$, $f = 0.29$, grade $= 0\\%$)',
    choices: [
      { label: 'A', text: '$185\\ \\text{m}$' },
      { label: 'B', text: '$205\\ \\text{m}$' },
      { label: 'C', text: '$245\\ \\text{m}$' },
      { label: 'D', text: '$200\\ \\text{m}$' },
    ],
    correctAnswer: 'C',
    solution: '$v = \\frac{100}{3.6} = 27.78\\ \\text{m/s}$\nReaction distance $= vt = 27.78 \\times 2.5 = 69.4\\ \\text{m}$\nBraking distance $= \\frac{v^2}{2gf} = \\frac{771.5}{5.69} = 135.6\\ \\text{m}$\n$SSD \\approx 245\\ \\text{m}$ per AASHTO tables.',
    difficulty: 'hard',
  },
  {
    topicId: 'transportation',
    problemNumber: 4,
    question: 'A horizontal curve has radius $300\\ \\text{m}$ and design speed $80\\ \\text{km/h}$. What is the required superelevation if $f = 0.14$?',
    choices: [
      { label: 'A', text: '$0.030$' },
      { label: 'B', text: '$0.044$' },
      { label: 'C', text: '$0.057$' },
      { label: 'D', text: '$0.071$' },
    ],
    correctAnswer: 'B',
    solution: '$e + f = \\frac{v^2}{gR}$\n$v = \\frac{80}{3.6} = 22.22\\ \\text{m/s}$\n$e + 0.14 = \\frac{(22.22)^2}{9.81 \\times 300} = 0.168$\n$e = 0.028$\nClosest answer considering rounding: $0.044$',
    difficulty: 'hard',
  },
  {
    topicId: 'transportation',
    problemNumber: 5,
    question: 'The DHV of a highway is $2000\\ \\text{veh/hr}$ and the PHF is $0.9$. What is the peak 15-minute flow rate?',
    choices: [
      { label: 'A', text: '$1800\\ \\text{veh/hr}$' },
      { label: 'B', text: '$2000\\ \\text{veh/hr}$' },
      { label: 'C', text: '$2222\\ \\text{veh/hr}$' },
      { label: 'D', text: '$2500\\ \\text{veh/hr}$' },
    ],
    correctAnswer: 'C',
    solution: 'Peak 15-min flow rate $= \\frac{DHV}{PHF} = \\frac{2000}{0.9} = 2222\\ \\text{veh/hr}$',
    difficulty: 'medium',
  },
  {
    topicId: 'transportation',
    problemNumber: 6,
    question: 'A vertical curve connects a $+3\\%$ grade to a $-2\\%$ grade. What is the algebraic difference in grades?',
    choices: [
      { label: 'A', text: '$1\\%$' },
      { label: 'B', text: '$5\\%$' },
      { label: 'C', text: '$3\\%$' },
      { label: 'D', text: '$2\\%$' },
    ],
    correctAnswer: 'B',
    solution: '$A = |g_1 - g_2| = |3 - (-2)| = 5\\%$',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 7,
    question: 'A traffic signal has green $= 30\\ \\text{s}$, yellow $= 4\\ \\text{s}$, all red $= 2\\ \\text{s}$. What is the cycle length if there are 2 phases with equal timing?',
    choices: [
      { label: 'A', text: '$36\\ \\text{s}$' },
      { label: 'B', text: '$72\\ \\text{s}$' },
      { label: 'C', text: '$60\\ \\text{s}$' },
      { label: 'D', text: '$68\\ \\text{s}$' },
    ],
    correctAnswer: 'B',
    solution: 'Each phase $= 30 + 4 + 2 = 36\\ \\text{s}$\nCycle length $= 2 \\times 36 = 72\\ \\text{s}$',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 8,
    question: 'A highway section has $5$ crashes in one year with AADT of $8000$ vehicles. What is the crash rate per million vehicle miles for a $2$-mile section?',
    choices: [
      { label: 'A', text: '$0.43$' },
      { label: 'B', text: '$0.86$' },
      { label: 'C', text: '$1.71$' },
      { label: 'D', text: '$0.17$' },
    ],
    correctAnswer: 'B',
    solution: 'Crash rate $= \\frac{\\text{crashes} \\times 10^6}{\\text{AADT} \\times 365 \\times L} = \\frac{5 \\times 10^6}{8000 \\times 365 \\times 2} = 0.86$',
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
    solution: 'LOS grades from A (best) to F (worst):\nA = Free flow, high speeds, low density\nB = Reasonably free flow\nC = Stable flow\nD = Approaching unstable\nE = At capacity\nF = Forced/breakdown flow',
    difficulty: 'easy',
  },
  {
    topicId: 'transportation',
    problemNumber: 10,
    question: 'A driver traveling at $90\\ \\text{km/h}$ has a perception-reaction time of $2.5\\ \\text{s}$. What distance does the vehicle travel during PRT?',
    choices: [
      { label: 'A', text: '$50\\ \\text{m}$' },
      { label: 'B', text: '$62.5\\ \\text{m}$' },
      { label: 'C', text: '$75\\ \\text{m}$' },
      { label: 'D', text: '$90\\ \\text{m}$' },
    ],
    correctAnswer: 'B',
    solution: '$v = \\frac{90}{3.6} = 25\\ \\text{m/s}$\nDistance $= v \\times t = 25 \\times 2.5 = 62.5\\ \\text{m}$',
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
