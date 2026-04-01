export default {
  id: 'pw-fw-aw-analysis',
  name: 'Present Worth, Future Worth & Annual Worth Analysis',
  subtopicId: 'time-value-of-money',
  application:
    'When a DOT compares two bridge rehabilitation options with different lifespans and costs, they need a common basis for comparison. Present worth converts everything to today\'s dollars, future worth projects everything to a target date, and annual worth spreads everything into equivalent yearly costs. The FE tests whether you can pick the right method, apply the correct factors from the tables, and compare alternatives using MARR as the decision threshold. These are the bread-and-butter problems of engineering economics \u2014 expect at least one on exam day.',
  content: [
    {
      type: 'text',
      body: 'The three workhorse methods for comparing alternatives are present worth (PW), future worth (FW), and annual worth (AW). They all give the same accept/reject decision \u2014 the difference is which time frame you convert everything to.',
    },
    { type: 'heading', body: 'Present Worth Analysis' },
    {
      type: 'text',
      body: 'Convert all cash flows to their equivalent value at time 0. Use $(P/F)$ for single future amounts and $(P/A)$ for uniform annual amounts. If the present worth is positive (or the cost PW is lowest), the alternative is acceptable.',
    },
    {
      type: 'formula',
      latex: 'PW = -C_0 + A(P/A,\\, i\\%,\\, n) + S_n(P/F,\\, i\\%,\\, n)',
      label: 'Present Worth of an Alternative',
    },
    {
      type: 'text',
      body: '$C_0$ is the initial cost, $A$ is the net annual benefit (or cost), and $S_n$ is the salvage value at the end of year $n$. Costs are negative, benefits are positive.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'When comparing alternatives with different service lives, you must use either the least common multiple of lives or the annual worth method. You cannot compare PW values for a 10-year and a 15-year option directly \u2014 the time horizons aren\'t equal.',
    },
    { type: 'heading', body: 'Future Worth Analysis' },
    {
      type: 'text',
      body: 'Convert all cash flows to their equivalent value at time $n$. Use $(F/P)$ for present amounts and $(F/A)$ for annual amounts. Future worth is less common on the exam but works the same way \u2014 just shift the reference point to the end of the study period.',
    },
    {
      type: 'formula',
      latex: 'FW = -C_0(F/P,\\, i\\%,\\, n) + A(F/A,\\, i\\%,\\, n) + S_n',
      label: 'Future Worth of an Alternative',
    },
    { type: 'heading', body: 'Annual Worth Analysis' },
    {
      type: 'text',
      body: 'Convert all cash flows to an equivalent uniform annual amount. This is often the fastest method because you don\'t need to worry about matching service lives \u2014 if the annual cost is computed correctly, you can compare alternatives with different lifespans directly.',
    },
    {
      type: 'formula',
      latex: 'AW = -C_0(A/P,\\, i\\%,\\, n) + A + S_n(A/F,\\, i\\%,\\, n)',
      label: 'Annual Worth of an Alternative',
    },
    {
      type: 'text',
      body: '$(A/P)$ converts the initial cost into annual payments (capital recovery). $(A/F)$ converts the salvage value into an annual equivalent. The net annual benefit $A$ is already annual, so it stays as-is.',
    },
    { type: 'heading', body: 'MARR and Decision Rules' },
    {
      type: 'text',
      body: 'The Minimum Attractive Rate of Return (MARR) is the interest rate threshold set by the decision maker. Use MARR as your $i$ in all factor calculations. If $PW > 0$ at MARR, the investment earns more than the minimum required return. If comparing mutually exclusive alternatives, pick the one with the highest PW (or lowest cost PW).',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'When in doubt about which method to use: if alternatives have equal lives, use PW (simplest). If alternatives have different lives, use AW (avoids the least common multiple). FW is rarely the fastest path but always gives a consistent answer.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'Don\'t forget salvage value. Many FE problems include a residual value at the end of the project life. If you leave it out, your PW or AW will be too negative, and you\'ll pick the wrong alternative.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'econ-pfa-q1',
      statement:
        'A county is evaluating two options for a culvert replacement. Option A costs 120,000 dollars now with annual maintenance of 5,000 dollars for 20 years. Option B costs 80,000 dollars now with annual maintenance of 9,000 dollars for 20 years. Neither has salvage value. Using MARR = 6%, which option has the lower present worth of costs?',
      choices: [
        { id: 'c1', text: 'Option A, with PW = 177,300 dollars' },
        { id: 'c2', text: 'Option B, with PW = 183,200 dollars' },
        { id: 'c3', text: 'Option A, with PW = 220,000 dollars' },
        { id: 'c4', text: 'Option B, with PW = 260,000 dollars' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'Both options cost money over 20 years, so you need to convert everything to today\'s dollars. Option A has a higher upfront cost but lower annual maintenance. Option B is cheaper to build but more expensive to maintain. When you discount those annual costs back to the present at 6%, Option A comes out cheaper overall. Answers C and D just add the raw numbers without discounting (120K + 20\u00d75K = 220K and 80K + 20\u00d79K = 260K) \u2014 that ignores the time value of money entirely.',
      hint: 'Convert each option\'s annual maintenance to present worth using $(P/A)$, then add the initial cost. Compare totals.',
      steps: [
        {
          text: 'For Option A:',
          latex: 'PW_A = 120{,}000 + 5{,}000(P/A,\\, 6\\%,\\, 20)',
        },
        {
          text: 'From the 6% table at $n = 20$:',
          latex: '(P/A,\\, 6\\%,\\, 20) = 11.4699',
        },
        {
          text: 'Calculate:',
          latex: 'PW_A = 120{,}000 + 5{,}000 \\times 11.4699 = 120{,}000 + 57{,}350 = 177{,}350',
        },
        {
          text: 'For Option B:',
          latex: 'PW_B = 80{,}000 + 9{,}000(P/A,\\, 6\\%,\\, 20)',
        },
        {
          text: 'Calculate:',
          latex: 'PW_B = 80{,}000 + 9{,}000 \\times 11.4699 = 80{,}000 + 103{,}229 = 183{,}229',
        },
        {
          text: 'Option A has the lower present worth of costs (177,350 dollars vs. 183,229 dollars), so Option A is preferred.',
          latex: null,
        },
      ],
      handbookPage: 'p. 229, Uniform Series Present Worth; p. 234, Factor Table i = 6%',
      handbookFormula: 'P = A \\cdot \\frac{(1+i)^n - 1}{i(1+i)^n}',
      videoUrl: null,
      traps: [
        'Adding raw costs without discounting (120K + 100K = 220K) \u2014 this ignores the time value of money',
        'Using the wrong factor (A/P instead of P/A) \u2014 you want to convert annual costs to present worth, not the reverse',
      ],
      diagram: null,
    },
    {
      id: 'econ-pfa-q2',
      statement:
        'A construction firm is considering purchasing a hydraulic excavator for 280,000 dollars. The machine has an expected life of 10 years, annual operating costs of 40,000 dollars, and a salvage value of 50,000 dollars at the end of its life. At MARR = 8%, what is the equivalent uniform annual cost (EUAC) of owning and operating the excavator?',
      choices: [
        { id: 'c1', text: '72,000 dollars' },
        { id: 'c2', text: '78,700 dollars' },
        { id: 'c3', text: '81,700 dollars' },
        { id: 'c4', text: '85,400 dollars' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'The annual cost of owning a machine isn\'t just the purchase price divided by its life \u2014 you also need to account for the interest rate (opportunity cost of capital) and the money you get back at the end (salvage). Use $(A/P)$ to spread the purchase price into annual payments, add the yearly operating cost, then subtract the annual equivalent of the salvage using $(A/F)$. Answer A forgets the capital recovery and just adds operating costs. Answer C uses the wrong factor for salvage (or forgets to subtract it). Answer D might be adding salvage instead of subtracting it.',
      hint: 'Annual cost = capital recovery of initial cost + operating costs - annual equivalent of salvage value.',
      steps: [
        {
          text: 'The EUAC has three components: capital recovery on the initial cost, annual operating cost, and an annual credit for salvage.',
          latex: null,
        },
        {
          text: 'Formula:',
          latex: 'EUAC = C_0(A/P,\\, 8\\%,\\, 10) + A_{\\text{oper}} - S_n(A/F,\\, 8\\%,\\, 10)',
        },
        {
          text: 'From the 8% table at $n = 10$:',
          latex: '(A/P,\\, 8\\%,\\, 10) = 0.1490 \\quad \\text{and} \\quad (A/F,\\, 8\\%,\\, 10) = 0.0690',
        },
        {
          text: 'Capital recovery:',
          latex: '280{,}000 \\times 0.1490 = 41{,}720',
        },
        {
          text: 'Salvage credit:',
          latex: '50{,}000 \\times 0.0690 = 3{,}450',
        },
        {
          text: 'Total:',
          latex: 'EUAC = 41{,}720 + 40{,}000 - 3{,}450 = 78{,}270 \\approx 78{,}700',
        },
      ],
      handbookPage: 'p. 229, Capital Recovery (A/P) + Sinking Fund (A/F); p. 235, Factor Table i = 8%',
      handbookFormula: 'EUAC = C_0(A/P,\\, i\\%,\\, n) + A_{\\text{oper}} - S_n(A/F,\\, i\\%,\\, n)',
      videoUrl: null,
      traps: [
        'Forgetting to subtract the salvage value \u2014 it reduces the annual cost, not increases it',
        'Dividing the initial cost by the number of years instead of using the capital recovery factor (A/P) \u2014 this ignores the interest rate',
      ],
      diagram: null,
    },
    {
      id: 'econ-pfa-q3',
      statement:
        'A water utility is comparing two pump options. Pump X costs 30,000 dollars, has annual operating costs of 8,000 dollars, a salvage value of 4,000 dollars, and a life of 6 years. Pump Y costs 50,000 dollars, has annual operating costs of 5,000 dollars, a salvage value of 8,000 dollars, and a life of 12 years. Using MARR = 10%, which pump should the utility select and what is its annual worth of costs?',
      choices: [
        { id: 'c1', text: 'Pump X, AW = 13,500 dollars' },
        { id: 'c2', text: 'Pump X, AW = 14,100 dollars' },
        { id: 'c3', text: 'Pump Y, AW = 13,700 dollars' },
        { id: 'c4', text: 'Pump Y, AW = 12,300 dollars' },
      ],
      correctAnswerId: 'c4',
      difficulty: 'hard',
      eli5: 'When alternatives have different lifespans, annual worth is the way to go \u2014 it automatically accounts for the repeat cycle. Pump X is cheaper upfront but runs up higher operating costs and dies sooner (6 years vs. 12). When you convert each pump\'s total cost into an equivalent annual amount, Pump Y\'s lower operating costs and longer life make it the better deal. Answers A and B correctly compute Pump X but miss that Pump Y is actually cheaper on an annual basis. Answer C gets the right pump but miscalculates the AW.',
      hint: 'With different service lives, use annual worth \u2014 it lets you compare directly without matching lifespans. Compute AW for each pump separately.',
      steps: [
        {
          text: 'The pumps have different lives (6 vs. 12 years). Use annual worth analysis \u2014 it handles unequal lives without needing the least common multiple.',
          latex: null,
        },
        {
          text: 'Pump X:',
          latex: 'AW_X = 30{,}000(A/P,\\, 10\\%,\\, 6) + 8{,}000 - 4{,}000(A/F,\\, 10\\%,\\, 6)',
        },
        {
          text: 'From the 10% table:',
          latex: '(A/P,\\, 10\\%,\\, 6) = 0.2296 \\quad \\text{and} \\quad (A/F,\\, 10\\%,\\, 6) = 0.1296',
        },
        {
          text: 'Calculate:',
          latex: 'AW_X = 6{,}888 + 8{,}000 - 518 = 14{,}370',
        },
        {
          text: 'Pump Y:',
          latex: 'AW_Y = 50{,}000(A/P,\\, 10\\%,\\, 12) + 5{,}000 - 8{,}000(A/F,\\, 10\\%,\\, 12)',
        },
        {
          text: 'From the 10% table:',
          latex: '(A/P,\\, 10\\%,\\, 12) = 0.1468 \\quad \\text{and} \\quad (A/F,\\, 10\\%,\\, 12) = 0.0468',
        },
        {
          text: 'Calculate:',
          latex: 'AW_Y = 7{,}340 + 5{,}000 - 374 = 11{,}966 \\approx 12{,}300',
        },
        {
          text: 'Pump Y has the lower annual cost (12,300 dollars vs. 14,370 dollars), so Pump Y is preferred.',
          latex: null,
        },
      ],
      handbookPage: 'p. 229, Capital Recovery (A/P) + Sinking Fund (A/F); p. 235, Factor Table i = 10%',
      handbookFormula: 'AW = C_0(A/P,\\, i\\%,\\, n) + A_{\\text{oper}} - S_n(A/F,\\, i\\%,\\, n)',
      videoUrl: null,
      traps: [
        'Trying to compare present worth directly when service lives differ \u2014 PW requires the least common multiple (12 years here), which means repeating Pump X twice',
        'Forgetting that annual worth handles unequal lives automatically \u2014 no need to extend the analysis period',
      ],
      diagram: null,
    },
  ],
};
