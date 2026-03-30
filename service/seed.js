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
    keyConcepts: [],
    videoUrl: null,
    problemCount: 0,
    order: 2,
  },
  {
    topicId: 'fluid-mechanics',
    name: 'Fluid Mechanics',
    description: 'Covers fluid statics, fluid dynamics, Bernoulli equation, and pipe flow.',
    keyConcepts: [],
    videoUrl: null,
    problemCount: 0,
    order: 3,
  },
  {
    topicId: 'soils',
    name: 'Soils',
    description: 'Covers soil classification, compaction, consolidation, and shear strength.',
    keyConcepts: [],
    videoUrl: null,
    problemCount: 0,
    order: 4,
  },
  {
    topicId: 'materials',
    name: 'Materials',
    description: 'Covers material properties, stress-strain relationships, and failure theories.',
    keyConcepts: [],
    videoUrl: null,
    problemCount: 0,
    order: 5,
  },
  {
    topicId: 'transportation',
    name: 'Transportation',
    description: 'Covers traffic engineering, highway design, and transportation planning.',
    keyConcepts: [],
    videoUrl: null,
    problemCount: 0,
    order: 6,
  },
];

const problems = [
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
