// A small bundled slice of the real classified bank, enough to run the loop.
// In production this is generated from docs/mobile/problem-classification.json.

import type { Chapter } from '@/domain/entities/chapter';
import type { Problem } from '@/domain/entities/problem';
import type { Card } from '@/domain/entities/card';

export const sampleChapters: readonly Chapter[] = [
  { id: 'statics', name: 'Statics', examWeight: 0.08 },
  { id: 'geotechnical', name: 'Geotechnical', examWeight: 0.1 },
  { id: 'ethics', name: 'Ethics', examWeight: 0.07 },
  { id: 'water-resources', name: 'Water Resources', examWeight: 0.1 },
];

export const sampleProblems: readonly Problem[] = [
  {
    id: 'stat-fri-ex1',
    chapterId: 'statics',
    tier: 'concept',
    interaction: 'tapTheTrap',
    statement:
      'A 30 kg block sits on a floor ($\\mu_s = 0.35$). Someone pulls it sideways with $80$ N. What is the friction force?',
    choices: [
      { id: 'c1', text: '$105$ N' },
      { id: 'c2', text: '$80$ N' },
      { id: 'c3', text: '$294$ N' },
      { id: 'c4', text: '$26$ N' },
    ],
    correctChoiceId: 'c2',
    explanation:
      '$\\mu_s \\cdot N$ is the maximum static friction, not the actual. Static friction matches the applied pull up to that ceiling. $80 < 105$, so the block stays put and friction $= 80$ N.',
    handbookRef: 'Statics — friction',
  },
  {
    id: 'geo-sc-q1',
    chapterId: 'geotechnical',
    tier: 'phoneCalc',
    interaction: 'formulaFirst',
    statement: 'A soil has 80% passing the No. 200 sieve, LL = 45, PI = 22. USCS classification?',
    choices: [
      { id: 'c1', text: 'CL' },
      { id: 'c2', text: 'CH' },
      { id: 'c3', text: 'ML' },
      { id: 'c4', text: 'MH' },
    ],
    correctChoiceId: 'c1',
    explanation:
      'Fine-grained (>50% fines). LL = 45 < 50 → low plasticity (L). A-line: PI_A = 0.73(LL−20) = 18.25; PI = 22 > 18.25 plots above → clay (C). So CL.',
    handbookRef: 'Geotech — USCS / Atterberg',
  },
  {
    id: 'eth-otp-q1',
    chapterId: 'ethics',
    tier: 'concept',
    interaction: 'tapTheTrap',
    statement:
      'A client insists on a concrete mix below the code-required strength to save cost. What should the engineer do?',
    choices: [
      { id: 'c1', text: 'Use it and note the deviation in the file' },
      { id: 'c2', text: 'Reduce parking levels to compensate' },
      { id: 'c3', text: 'Seal the plans with a liability disclaimer' },
      { id: 'c4', text: 'Refuse to seal; the design must meet code' },
    ],
    correctChoiceId: 'c4',
    explanation:
      'Rule A.1 — hold paramount public safety. Documenting the deviation or disclaiming liability does not satisfy the duty; the engineer must not seal non-compliant plans.',
    handbookRef: 'NSPE Code — A.1, A.2',
  },
  {
    id: 'geo-bc-q3',
    chapterId: 'geotechnical',
    tier: 'paper',
    interaction: 'setupNotSolve',
    statement:
      'A 2 m square footing sits 1.5 m deep in sand (φ = 32°, γ = 18 kN/m³). Find the ultimate bearing capacity.',
    choices: [],
    correctChoiceId: null,
    explanation:
      'q_ult = c·Nc + q·Nq + ½γB·Nγ. c = 0 in sand; look up Nq, Nγ for φ=32°; q = γ·Df. Multi-term table lookup — solve on paper.',
    handbookRef: 'Geotech — bearing capacity',
  },
  {
    id: 'wr-bod-q2',
    chapterId: 'water-resources',
    tier: 'paper',
    interaction: 'setupNotSolve',
    statement: 'BOD5 = 200 mg/L, k = 0.23/day. Find the ultimate BOD (L0).',
    choices: [],
    correctChoiceId: null,
    explanation:
      'BOD5 = L0(1 − e^(−k·5)). Solve for L0 = BOD5 / (1 − e^(−1.15)). The exponential needs a calculator — paper.',
    handbookRef: 'Water — BOD kinetics',
  },
];

export const sampleCards: readonly Card[] = [
  {
    id: 'stat-fri-ex1:card:0',
    problemId: 'stat-fri-ex1',
    chapterId: 'statics',
    kind: 'tapTheTrap',
    prompt: 'When does friction equal μs·N, versus equalling the applied force?',
    answer:
      'μs·N is only the MAXIMUM. Until the pull exceeds it, static friction equals the applied force.',
  },
  {
    id: 'stat-fri-ex1:card:1',
    problemId: 'stat-fri-ex1',
    chapterId: 'statics',
    kind: 'recallReveal',
    prompt: 'Static friction is reactive: it equals the ___ up to a maximum of μs·N.',
    answer: 'applied force',
  },
  {
    id: 'geo-sc-q1:card:0',
    problemId: 'geo-sc-q1',
    chapterId: 'geotechnical',
    kind: 'formulaFirst',
    prompt: 'What is the A-line equation, and what does plotting above it mean?',
    answer: 'PI_A = 0.73(LL − 20). Above the A-line → clay (C); below → silt (M).',
  },
  {
    id: 'geo-sc-q1:card:1',
    problemId: 'geo-sc-q1',
    chapterId: 'geotechnical',
    kind: 'tapTheTrap',
    prompt: 'Why does LL = 45 mean "L" not "H"?',
    answer: 'LL = 50 is the low/high plasticity divide. 45 < 50 → low (L).',
  },
  {
    id: 'eth-otp-q1:card:0',
    problemId: 'eth-otp-q1',
    chapterId: 'ethics',
    kind: 'recallReveal',
    prompt: "Under the NSPE Code, an engineer's first and foremost duty is to —",
    answer: 'hold paramount the safety, health, and welfare of the public (Rule A.1).',
  },
  {
    id: 'eth-otp-q1:card:1',
    problemId: 'eth-otp-q1',
    chapterId: 'ethics',
    kind: 'tapTheTrap',
    prompt: 'Why does documenting a code violation in the file fail to satisfy the duty?',
    answer: 'A paper trail does not make an unsafe design safe; the engineer still must not seal it.',
  },
];
