export default {
  id: 'benefit-cost-decision-trees',
  name: 'Benefit-Cost Analysis & Decision Trees',
  subtopicId: 'cost-and-economic-analysis',
  application:
    'Public-sector projects live or die by the benefit-cost ratio. When a DOT evaluates a highway interchange, a flood control levee, or a new transit line, the deciding metric is whether public benefits outweigh government costs. The FE tests two skills: computing the conventional B/C ratio and using incremental analysis to choose between mutually exclusive alternatives (you cannot simply pick the highest individual B/C). Decision trees add probability to the picture \u2014 you compute expected values at chance nodes and pick the best path at decision nodes. Civil engineers at agencies like USACE, FHWA, and municipal public works use B/C analysis on nearly every capital project, and decision trees show up whenever outcomes depend on uncertain factors like traffic growth, flood frequency, or construction delays.',
  content: [
    {
      type: 'text',
      body: 'The benefit-cost ratio and decision tree analysis are the primary FE tools for public-sector project evaluation and decision-making under uncertainty.',
    },
    { type: 'heading', body: 'Benefit-Cost Ratio' },
    {
      type: 'formula',
      latex: 'B/C = \\frac{B}{C}',
      label: 'Conventional Benefit-Cost Ratio',
    },
    {
      type: 'text',
      body: '$B$ is the present worth (or annual worth) of benefits to the public, and $C$ is the present worth (or annual worth) of costs to the government including initial construction and O&M. If $B/C \\geq 1$, the project is economically justified.',
    },
    {
      type: 'text',
      body: 'When disbenefits exist (negative effects on the public, like increased noise or displacement), subtract them from benefits in the numerator.',
    },
    {
      type: 'formula',
      latex: 'B/C = \\frac{B - D}{C}',
      label: 'B/C Ratio with Disbenefits',
    },
    { type: 'heading', body: 'Incremental B/C Analysis' },
    {
      type: 'text',
      body: 'When comparing mutually exclusive alternatives, you cannot simply pick the one with the highest individual B/C ratio. Instead, rank alternatives by increasing cost and compare them in pairs using incremental analysis.',
    },
    {
      type: 'formula',
      latex: '\\Delta B/C = \\frac{B_2 - B_1}{C_2 - C_1}',
      label: 'Incremental B/C Ratio',
    },
    {
      type: 'text',
      body: 'If the incremental $\\Delta B/C \\geq 1$, choose the higher-cost alternative. If less than 1, keep the lower-cost option. Continue comparing the winner against the next alternative until all are evaluated.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The FE specifically tests whether you know that you must use incremental analysis for mutually exclusive alternatives. Picking the project with the highest individual B/C ratio is wrong \u2014 it ignores the scale of investment.',
    },
    { type: 'heading', body: 'Decision Trees' },
    {
      type: 'text',
      body: 'A decision tree models problems with uncertain outcomes. It uses three node types: decision nodes (squares \u2014 you choose a path), chance nodes (circles \u2014 probability determines the outcome), and outcome nodes (triangles or endpoints \u2014 the final payoff or cost).',
    },
    {
      type: 'formula',
      latex: 'EV = C_1 \\cdot p_1 + C_2 \\cdot p_2 + \\cdots + C_n \\cdot p_n',
      label: 'Expected Value at a Chance Node',
    },
    {
      type: 'text',
      body: 'Solve by working backward from the outcomes. At each chance node, compute the expected value. At each decision node, pick the path with the best expected value (highest for profits, lowest for costs). This backward pass is called "rolling back" the tree.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'FE decision tree problems are usually 2\u20133 branches deep. Draw the tree, label every probability and payoff, then work backward from the endpoints. The expected value at the root is your answer.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'Probabilities at each chance node must sum to 1.0. If the problem gives you three outcomes with probabilities 0.3, 0.5, and one unlabeled, the third probability is 0.2. Missing this means every expected value downstream is wrong.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'econ-bcd-q1',
      statement:
        'A flood control project costs 4.5 million dollars to build and has annual O&M costs of 60,000 dollars. The annual benefits from prevented flood damage are estimated at 420,000 dollars. The project has a 30-year life and MARR = 6%. What is the benefit-cost ratio?',
      choices: [
        { id: 'c1', text: '1.09' },
        { id: 'c2', text: '0.93' },
        { id: 'c3', text: '7.00' },
        { id: 'c4', text: '1.29' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'Divide annual benefits by annual costs \u2014 but annual costs include both the annualized construction cost and the yearly O&M. Use $(A/P)$ to spread the 4.5 million over 30 years at 6%, then add the 60,000 dollars of O&M. That gives you 386,700 dollars per year in costs against 420,000 dollars in benefits, so B/C = 1.09. The 0.93 choice inverts the ratio (costs/benefits instead of benefits/costs). The 7.00 choice divides benefits by O&M alone, forgetting the construction cost entirely. The 1.29 choice leaves out the O&M and only annualizes the construction cost.',
      hint: 'Annual cost has two components: the annualized initial cost using $(A/P)$ plus the yearly O&M.',
      steps: [
        {
          text: 'Use annual worth for both sides. Annual benefit = 420,000 dollars.',
          latex: null,
        },
        {
          text: 'Annualize the initial cost using $(A/P, 6\\%, 30)$:',
          latex: '4{,}500{,}000 \\times 0.0726 = 326{,}700',
        },
        {
          text: 'Total annual cost:',
          latex: 'C = 326{,}700 + 60{,}000 = 386{,}700',
        },
        {
          text: 'Compute the B/C ratio:',
          latex: 'B/C = \\frac{420{,}000}{386{,}700} = 1.09',
        },
        {
          text: 'Since B/C = 1.09 > 1, the project is economically justified.',
          latex: null,
        },
      ],
      handbookPage: 'p. 231, Benefit-Cost Analysis; p. 234, Factor Table i = 6%',
      handbookFormula: 'B/C = \\frac{B}{C} \\geq 1',
      videoUrl: null,
      traps: [
        'Forgetting to include O&M in the denominator \u2014 it is a cost to the government',
        'Computing costs/benefits instead of benefits/costs (getting the inverse ratio)',
      ],
      diagram: null,
    },
    {
      id: 'econ-bcd-q2',
      statement:
        'A city is evaluating three mutually exclusive drainage improvement projects, all with 20-year lives at MARR = 8%. Project A has PW of costs = 800,000 dollars and PW of benefits = 1,040,000 dollars. Project B has PW of costs = 1,200,000 dollars and PW of benefits = 1,440,000 dollars. Project C has PW of costs = 1,800,000 dollars and PW of benefits = 2,070,000 dollars. Using incremental B/C analysis, which project should the city select?',
      choices: [
        { id: 'c1', text: 'Project A \u2014 it has the highest B/C ratio (1.30)' },
        { id: 'c2', text: 'Project B \u2014 the middle option balances cost and benefit' },
        { id: 'c3', text: 'Project C \u2014 incremental analysis justifies each step up in cost' },
        { id: 'c4', text: 'All are equally acceptable since all have B/C > 1' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'medium',
      eli5: 'You might think Project A is best because its B/C ratio (1.30) is the highest \u2014 but that reasoning is wrong for mutually exclusive alternatives. The question isn\'t "which project returns the most per dollar?" but "is the extra investment in a bigger project justified?" Each time you step up in cost, the additional benefits exceed the additional costs (incremental B/C \u2265 1), so the city should go all the way to Project C. The "highest B/C ratio" choice (Project A) is the classic trap \u2014 picking by individual B/C ratio ignores the scale of the investment.',
      hint: 'Rank the alternatives by cost, then check whether each step up in cost is justified by comparing the change in benefits to the change in costs.',
      steps: [
        {
          text: 'First verify all individual B/C ratios exceed 1:',
          latex: 'A: \\frac{1{,}040{,}000}{800{,}000} = 1.30 \\quad B: \\frac{1{,}440{,}000}{1{,}200{,}000} = 1.20 \\quad C: \\frac{2{,}070{,}000}{1{,}800{,}000} = 1.15',
        },
        {
          text: 'All pass. Rank by cost: A (lowest), B, C (highest).',
          latex: null,
        },
        {
          text: 'Compare B to A:',
          latex: '\\Delta B/C = \\frac{1{,}440{,}000 - 1{,}040{,}000}{1{,}200{,}000 - 800{,}000} = \\frac{400{,}000}{400{,}000} = 1.00',
        },
        {
          text: 'Since 1.00 \u2265 1, select B over A.',
          latex: null,
        },
        {
          text: 'Compare C to B:',
          latex: '\\Delta B/C = \\frac{2{,}070{,}000 - 1{,}440{,}000}{1{,}800{,}000 - 1{,}200{,}000} = \\frac{630{,}000}{600{,}000} = 1.05',
        },
        {
          text: 'Since 1.05 \u2265 1, select C over B. Project C is the winner.',
          latex: null,
        },
      ],
      handbookPage: 'p. 231, Benefit-Cost Analysis',
      handbookFormula: '\\Delta B/C = \\frac{B_2 - B_1}{C_2 - C_1} \\geq 1',
      videoUrl: null,
      traps: [
        'Selecting the alternative with the highest individual B/C ratio \u2014 this is only correct for independent (not mutually exclusive) projects',
        'Forgetting to verify that each individual alternative has B/C \u2265 1 before doing incremental analysis',
      ],
      diagram: null,
    },
    {
      id: 'econ-bcd-q3',
      statement:
        'A county must choose between two approaches for a congested corridor. Option 1 (bypass road) has a certain cost of 12 million dollars. Option 2 (widen existing road) costs 5 million dollars now, but engineers estimate a 40% probability of high traffic growth requiring a second-phase expansion at an additional present worth cost of 5 million dollars, and a 60% probability of moderate growth needing no further investment. Using expected value analysis, what is the expected cost of the widening option, and which approach minimizes expected cost?',
      choices: [
        { id: 'c1', text: 'Widening; expected cost of 5 million dollars' },
        { id: 'c2', text: 'Widening; expected cost of 7 million dollars' },
        { id: 'c3', text: 'Widening; expected cost of 10 million dollars' },
        { id: 'c4', text: 'Bypass; expected cost of 12 million dollars \u2014 certainty is worth paying for' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: 'The bypass is a sure thing at 12 million dollars \u2014 no uncertainty. Widening is cheaper upfront (5 million) but has a 40% chance of needing another 5 million. To compare, compute the expected cost of widening: there\'s a 40% chance you pay 10 million total and a 60% chance you pay only 5 million. The weighted average is 7 million dollars, which is well below the 12 million dollar bypass. The "5 million" choice only counts the initial cost and ignores the probability of expansion. The "10 million" choice assumes high growth is certain (100% instead of 40%). The bypass choice treats certainty as inherently valuable, but expected value analysis does not add a premium for certainty.',
      hint: 'At the chance node, multiply each outcome\'s total cost by its probability and sum them. Then compare to the certain cost of the bypass.',
      steps: [
        {
          text: 'Draw the decision tree. At the decision node: Bypass (certain 12 million dollars) and Widening (leads to a chance node).',
          latex: null,
        },
        {
          text: 'At the chance node for widening:',
          latex: '\\text{High growth (p = 0.40):}\\; 5{,}000{,}000 + 5{,}000{,}000 = 10{,}000{,}000',
        },
        {
          text: 'Moderate growth outcome:',
          latex: '\\text{Moderate growth (p = 0.60):}\\; 5{,}000{,}000',
        },
        {
          text: 'Expected value at the chance node:',
          latex: 'EV = 0.40 \\times 10{,}000{,}000 + 0.60 \\times 5{,}000{,}000 = 4{,}000{,}000 + 3{,}000{,}000 = 7{,}000{,}000',
        },
        {
          text: 'Compare: Widening EV = 7 million dollars vs. Bypass = 12 million dollars. Widening minimizes expected cost.',
          latex: null,
        },
      ],
      handbookPage: 'p. 231, Economic Decision Trees; Expected Value',
      handbookFormula: 'EV = C_1 \\cdot p_1 + C_2 \\cdot p_2 + \\cdots + C_n \\cdot p_n',
      videoUrl: null,
      traps: [
        'Using only the initial widening cost (5 million dollars) without accounting for the probabilistic expansion',
        'Assuming the worst case is certain \u2014 the 40% probability of high growth does not mean it will definitely happen',
      ],
      diagram: null,
    },
  ],
};
