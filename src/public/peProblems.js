// The three sample problems on /pe-civil-water-resources: a taste of the PE
// Civil Water Resources prep we are building (owner 2026-10-31). One per
// question format the computer-based exam uses (multiple choice, fill in the
// blank, select all that apply), each multi-step, with a figure to read.
//
// Every answer and every wrong choice was computed, and each wrong choice is
// a real mistake. The figures live in PeWaitlist.jsx. The handbook lines name
// the section, never a page: the PE Civil Reference Handbook is NCEES's, and
// its page numbers change between editions.

export const PE_PROBLEMS = [
  {
    id: 'runoff',
    topic: 'Hydrology',
    name: 'NRCS runoff volume',
    format: 'Multiple choice',
    kind: 'one',
    figure: 'watershed',
    stem: 'A 150-acre watershed drains to one outlet (figure). Both subareas are hydrologic soil group C. For a 24-hour rainfall of 4.5 in, the runoff volume from the watershed using the NRCS (SCS) curve number method is most nearly:',
    choices: [
      ['A', '27.1 ac-ft'],
      ['B', '28.5 ac-ft'],
      ['C', '34.1 ac-ft'],
      ['D', '34.4 ac-ft'],
    ],
    answer: ['B'],
    answerLabel: 'B, 28.5 ac-ft',
    steps: [
      ['Look up the curve numbers for soil group C', 'Residential 1/4 ac: CN = 83. Woods, good: CN = 70'],
      ['Weight them by area, not a plain average', 'CN = (90 × 83 + 60 × 70) / 150 = 77.8'],
      ['Potential retention and initial abstraction', 'S = 1000/77.8 − 10 = 2.85 in. Ia = 0.2S = 0.57 in'],
      ['Runoff depth', 'Q = (4.5 − 0.57)² / (4.5 + 0.8 × 2.85) = 2.28 in'],
      ['Runoff volume', '2.28 in ÷ 12 × 150 ac = 28.5 ac-ft'],
    ],
    handbook: 'Hydrology: the NRCS (SCS) rainfall-runoff method and its runoff curve number table.',
    traps: [
      ['A, 27.1', 'averages the two curve numbers without weighting by area.'],
      ['C, 34.1', 'uses only the residential curve number.'],
      ['D, 34.4', 'drops the initial abstraction and uses P²/(P + S).'],
    ],
  },
  {
    id: 'normal-depth',
    topic: 'Hydraulics, open channel',
    name: 'Normal depth',
    format: 'Fill in the blank',
    kind: 'number',
    figure: 'trapezoid',
    stem: 'A trapezoidal earth channel (n = 0.025) carries 250 cfs on a slope of 0.0015 ft/ft. The bottom is 8 ft wide and the side slopes are 2H:1V. Enter the normal depth, in feet, to two decimals.',
    unit: 'ft',
    // The exact answer is 3.851 ft. A small band, as a numeric item allows
    // for rounding in the trial depths.
    range: [3.82, 3.88],
    answerLabel: '3.85 ft',
    steps: [
      ['Write Manning\'s equation in US units, and what it asks for', 'A·R^(2/3) = Q·n / (1.49·√S) = 250 × 0.025 / (1.49 × √0.0015) = 108.3'],
      ['Area and wetted perimeter of the trapezoid', 'A = (8 + 2y)·y. P = 8 + 2y·√(1 + 2²) = 8 + 4.47y'],
      ['Try a depth', 'y = 3.5 ft: A = 52.5, P = 23.65, R = 2.22, A·R^(2/3) = 89.3. Too small'],
      ['Try again, closer', 'y = 3.85 ft: A = 60.4, P = 25.21, R = 2.40, A·R^(2/3) = 108.2. Matches'],
      ['Check the flow', 'V = 250 / 60.5 = 4.13 ft/s. Froude number 0.45, so the flow is subcritical'],
    ],
    handbook: 'Hydraulics: Manning\'s equation and the open-channel section properties for a trapezoid.',
    traps: [
      ['4.68 ft', 'uses the SI constant 1.0 in Manning\'s equation instead of 1.49.'],
      ['2.51 ft', 'is the critical depth, not the normal depth.'],
      ['3.50 ft', 'stops at the first trial depth. Keep going until A·R^(2/3) matches.'],
    ],
  },
  {
    id: 'clarifier',
    topic: 'Wastewater treatment',
    name: 'Clarifier design check',
    format: 'Select all that apply',
    kind: 'many',
    figure: 'clarifiers',
    stem: 'Two primary clarifiers (figure) treat an average flow of 5.0 MGD and a peak hourly flow of 12.5 MGD, split evenly. Each has a peripheral weir around its full 60 ft diameter. Which of the plant\'s design criteria are met? Select all that apply.',
    choices: [
      ['A', 'Overflow rate at average flow, 1,000 gpd/ft² or less'],
      ['B', 'Overflow rate at peak flow, 2,500 gpd/ft² or less'],
      ['C', 'Detention time at average flow, 2.0 h or more'],
      ['D', 'Weir loading at peak flow, 30,000 gpd/ft or less'],
      ['E', 'Detention time at peak flow, 1.5 h or more'],
    ],
    answer: ['A', 'B', 'C'],
    answerLabel: 'A, B and C',
    steps: [
      ['Surface area of both clarifiers', 'A = 2 × π × 30² = 5,655 ft²'],
      ['Overflow rate', 'Average: 5,000,000 / 5,655 = 884 gpd/ft² (A met). Peak: 12,500,000 / 5,655 = 2,210 gpd/ft² (B met)'],
      ['Volume of both tanks', 'V = 5,655 × 12 ft × 7.48 gal/ft³ = 507,600 gal'],
      ['Detention time', 'Average: 507,600 / 5,000,000 × 24 = 2.44 h (C met). Peak: 0.97 h (E not met)'],
      ['Weir loading', 'Weir length = 2 × π × 60 = 377 ft. Peak: 12,500,000 / 377 = 33,160 gpd/ft (D not met)'],
    ],
    handbook: 'Wastewater treatment: clarifier overflow rate, hydraulic residence time and weir loading.',
    traps: [
      ['D', 'passes only at average flow (13,260 gpd/ft). The criterion is at peak.'],
      ['E', 'passes only at average flow. At peak the water spends under an hour in the tank.'],
      ['One clarifier', 'Using one tank\'s area with the whole flow doubles every loading. The flow is split evenly.'],
    ],
  },
];

/** True when the answer given is right. `given` is a letter list or a typed number. */
export function isRight(problem, given) {
  if (problem.kind === 'number') {
    const v = Number(String(given ?? '').replace(',', '.').trim());
    return Number.isFinite(v) && v >= problem.range[0] && v <= problem.range[1];
  }
  const g = [...(given || [])].sort().join();
  return g === [...problem.answer].sort().join();
}
