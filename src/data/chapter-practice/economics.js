// Chapter practice: Engineering Economics (10 questions, 2 per lesson)

const PROBLEMS = [
  {
    id: 'econ-eif-cp1',
    type: 'computational',
    statement:
      'A municipality signs a 6-year equipment lease that requires a payment of 18,000 dollars at the end of each year. At an interest rate of 8%, what is the present worth of all the lease payments?',
    choices: [
      { id: 'c1', text: '108,000 dollars' },
      { id: 'c2', text: '88,500 dollars' },
      { id: 'c3', text: '83,200 dollars' },
      { id: 'c4', text: '11,300 dollars' },
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5:
      'You have a series of equal annual payments ($A$) and you want their value today ($P$), so the factor is the uniform series present worth $(P/A)$. Look up $(P/A,\\, 8\\%,\\, 6) = 4.6229$ and multiply by 18,000 to get about 83,200. Choice A (108,000) just adds up the six payments ($18{,}000 \\times 6$) with no discounting, ignoring the time value of money. Choice B (88,500) uses the wrong interest rate, applying $(P/A,\\, 6\\%,\\, 6) = 4.9173$ instead of the 8% factor. Choice D (11,300) treats the whole stream as a single future lump sum and discounts it with $(P/F)$ instead of $(P/A)$.',
    hint: 'Equal end-of-year payments converted to a value today means the uniform series present worth factor $(P/A)$.',
    steps: [
      {
        text: 'Identify: $A = 18{,}000$, $i = 8\\%$, $n = 6$ years. Find $P$.',
        latex: null,
      },
      {
        text: 'Use the uniform series present worth factor:',
        latex: '(P/A,\\, 8\\%,\\, 6) = \\frac{(1.08)^6 - 1}{0.08(1.08)^6}',
      },
      {
        text: 'Compute the factor:',
        latex: '(1.08)^6 = 1.58687 \\;\\Rightarrow\\; (P/A) = \\frac{0.58687}{0.12695} = 4.6229',
      },
      {
        text: 'Calculate the present worth:',
        latex: 'P = 18{,}000 \\times 4.6229 = 83{,}212 \\approx 83{,}200',
      },
    ],
    handbookPage: 'p. 229, Uniform Series Present Worth; p. 235, Factor Table i = 8%',
    handbookFormula: 'P = A \\cdot \\frac{(1+i)^n - 1}{i(1+i)^n}',
    videoUrl: null,
    traps: [
      'Summing the payments without discounting (18,000 times 6 = 108,000) — this ignores the time value of money',
      'Reading the factor from the wrong interest rate table (6% instead of 8%)',
    ],
    diagram: null,
    lessonId: 'equivalence-interest-factors',
    chapterId: 'economics',
  },
  {
    id: 'econ-eif-cp2',
    type: 'computational',
    statement:
      'Maintenance on a pump station is 5,000 dollars in year 1 and increases by 1,000 dollars each year thereafter (6,000 in year 2, 7,000 in year 3, and so on) for a total of 8 years. At an interest rate of 10%, what equivalent uniform annual cost represents this rising expense?',
    choices: [
      { id: 'c1', text: '12,000 dollars' },
      { id: 'c2', text: '8,000 dollars' },
      { id: 'c3', text: '8,500 dollars' },
      { id: 'c4', text: '3,000 dollars' },
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5:
      'The cash flow is a flat base of 5,000 dollars per year plus a uniform gradient $G = 1{,}000$ that starts in year 2. Convert the gradient to an equivalent annual amount with the gradient-to-uniform factor $(A/G,\\, 10\\%,\\, 8) = 3.0045$, then add it to the base: $A = 5{,}000 + 1{,}000 \\times 3.0045 = 8{,}004 \\approx 8{,}000$. Choice C (8,500) uses the simple arithmetic average of the gradient ($1{,}000 \\times 7/2 = 3{,}500$ added to 5,000), which ignores the time value of money. Choice D (3,000) reports only the gradient component and forgets to add the 5,000 base. Choice A (12,000) is the final-year cost ($5{,}000 + 1{,}000 \\times 7$), not the annual equivalent.',
    hint: 'Split the rising cost into a flat base plus a uniform gradient, then convert the gradient to an annual amount with $(A/G)$ and add the base.',
    steps: [
      {
        text: 'Identify the structure: base annuity $A_{\\text{base}} = 5{,}000$ plus uniform gradient $G = 1{,}000$, with $i = 10\\%$ and $n = 8$.',
        latex: null,
      },
      {
        text: 'Gradient-to-uniform factor:',
        latex: '(A/G,\\, 10\\%,\\, 8) = \\frac{1}{i} - \\frac{n}{(1+i)^n - 1} = \\frac{1}{0.10} - \\frac{8}{(1.10)^8 - 1}',
      },
      {
        text: 'Compute:',
        latex: '(1.10)^8 = 2.14359 \\;\\Rightarrow\\; (A/G) = 10 - \\frac{8}{1.14359} = 10 - 6.9955 = 3.0045',
      },
      {
        text: 'Equivalent uniform annual cost:',
        latex: 'A = 5{,}000 + 1{,}000 \\times 3.0045 = 8{,}004 \\approx 8{,}000',
      },
    ],
    handbookPage: 'p. 229, Uniform Gradient (A/G); p. 235, Factor Table i = 10%',
    handbookFormula: 'A = A_{\\text{base}} + G(A/G,\\, i\\%,\\, n)',
    videoUrl: null,
    traps: [
      'Taking the simple arithmetic average of the increments instead of using the (A/G) factor',
      'Reporting only the gradient component and forgetting to add the base annuity',
    ],
    diagram: null,
    lessonId: 'equivalence-interest-factors',
    chapterId: 'economics',
  },
  {
    id: 'econ-pfa-cp1',
    type: 'computational',
    statement:
      'A city plans to build a pedestrian bridge for 2,000,000 dollars that will require perpetual maintenance of 40,000 dollars per year forever. At an interest rate of 5%, what is the capitalized cost of the bridge?',
    choices: [
      { id: 'c1', text: '2,040,000 dollars' },
      { id: 'c2', text: '2,002,000 dollars' },
      { id: 'c3', text: '800,000 dollars' },
      { id: 'c4', text: '2,800,000 dollars' },
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5:
      'Capitalized cost is the present worth of a project that lasts forever. For a perpetual uniform cost, the present worth of the annual maintenance is simply $A/i$, so $40{,}000 / 0.05 = 800{,}000$. Add the one-time construction cost: $2{,}000{,}000 + 800{,}000 = 2{,}800{,}000$. Choice A (2,040,000) adds only one year of maintenance instead of capitalizing it over an infinite horizon. Choice B (2,002,000) multiplies the maintenance by the rate ($40{,}000 \\times 0.05$) instead of dividing. Choice C (800,000) gives only the capitalized maintenance and forgets the initial construction cost.',
    hint: 'For a cost that repeats forever, the present worth of the annual amount is $A/i$. Add the one-time initial cost.',
    steps: [
      {
        text: 'Capitalized cost = initial cost + present worth of perpetual annual cost.',
        latex: null,
      },
      {
        text: 'Present worth of a perpetual uniform series:',
        latex: 'P_{\\text{perp}} = \\frac{A}{i} = \\frac{40{,}000}{0.05} = 800{,}000',
      },
      {
        text: 'Add the initial construction cost:',
        latex: 'CC = 2{,}000{,}000 + 800{,}000 = 2{,}800{,}000',
      },
    ],
    handbookPage: 'p. 229, Capitalized Cost',
    handbookFormula: 'CC = C_0 + \\frac{A}{i}',
    videoUrl: null,
    traps: [
      'Adding only one year of maintenance instead of capitalizing it as A/i over an infinite horizon',
      'Multiplying the annual cost by the rate instead of dividing (A times i rather than A divided by i)',
    ],
    diagram: null,
    lessonId: 'pw-fw-aw-analysis',
    chapterId: 'economics',
  },
  {
    id: 'econ-pfa-cp2',
    type: 'computational',
    statement:
      'A contractor compares two compactors. Compactor M costs 40,000 dollars, has annual operating costs of 10,000 dollars, no salvage value, and a 3-year life. Compactor N costs 60,000 dollars, has annual operating costs of 7,000 dollars, no salvage value, and a 6-year life. Using present worth analysis over the least common multiple of lives at MARR = 10%, which compactor is cheaper and what is its present worth of costs?',
    choices: [
      { id: 'c1', text: 'Compactor M, PW = 64,900 dollars' },
      { id: 'c2', text: 'Compactor N, PW = 90,500 dollars' },
      { id: 'c3', text: 'Compactor M, PW = 113,600 dollars' },
      { id: 'c4', text: 'Compactor N, PW = 102,000 dollars' },
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5:
      'The lives are 3 and 6 years, so present worth must be compared over the least common multiple, 6 years. Compactor M must be purchased again at the start of year 4 (end of year 3). Its PW is $40{,}000 + 40{,}000(P/F,\\, 10\\%,\\, 3) + 10{,}000(P/A,\\, 10\\%,\\, 6) = 40{,}000 + 30{,}053 + 43{,}553 = 113{,}606$. Compactor N runs the full 6 years with no repeat: $60{,}000 + 7{,}000(P/A,\\, 10\\%,\\, 6) = 60{,}000 + 30{,}487 = 90{,}487 \\approx 90{,}500$. N is cheaper. Choice A (64,900) compares only one 3-year cycle of M against nothing, an invalid unequal-life comparison. Choice C (113,600) is M\'s correct PW but M is the more expensive option. Choice D (102,000) forgets to discount M\'s replacement or mis-adds N.',
    hint: 'Lives of 3 and 6 give an LCM of 6 years. Repeat the 3-year machine once and discount the replacement back with $(P/F)$.',
    steps: [
      {
        text: 'LCM of 3 and 6 is 6 years. Compactor M repeats once (replaced at end of year 3); Compactor N runs the full 6 years.',
        latex: null,
      },
      {
        text: 'Factors at 10%:',
        latex: '(P/F,\\, 10\\%,\\, 3) = 0.7513 \\quad (P/A,\\, 10\\%,\\, 6) = 4.3553',
      },
      {
        text: 'Compactor M present worth of costs:',
        latex: 'PW_M = 40{,}000 + 40{,}000(0.7513) + 10{,}000(4.3553) = 40{,}000 + 30{,}053 + 43{,}553 = 113{,}606',
      },
      {
        text: 'Compactor N present worth of costs:',
        latex: 'PW_N = 60{,}000 + 7{,}000(4.3553) = 60{,}000 + 30{,}487 = 90{,}487 \\approx 90{,}500',
      },
      {
        text: 'Compactor N has the lower present worth of costs. Select Compactor N.',
        latex: null,
      },
    ],
    handbookPage: 'p. 229, Single Payment Present Worth + Uniform Series Present Worth; p. 235, Factor Table i = 10%',
    handbookFormula: 'PW = C_0 + C_0(P/F,\\, i\\%,\\, n_1) + A_{\\text{oper}}(P/A,\\, i\\%,\\, N)',
    videoUrl: null,
    traps: [
      'Comparing present worth over unequal lives without extending to the least common multiple',
      'Forgetting to discount the replacement purchase of the shorter-life machine back to the present',
    ],
    diagram: null,
    lessonId: 'pw-fw-aw-analysis',
    chapterId: 'economics',
  },
  {
    id: 'econ-ctb-cp1',
    type: 'computational',
    statement:
      'A precast concrete plant sells wall panels for 450 dollars each. Its fixed costs are 90,000 dollars per month, and the variable cost to produce each panel is 270 dollars. How many panels must the plant sell per month to break even?',
    choices: [
      { id: 'c1', text: '500 panels' },
      { id: 'c2', text: '200 panels' },
      { id: 'c3', text: '333 panels' },
      { id: 'c4', text: '125 panels' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5:
      'At break-even, total revenue equals total cost, so the contribution margin per panel (selling price minus variable cost) must cover the fixed cost. The margin is $450 - 270 = 180$ dollars per panel, and $90{,}000 / 180 = 500$ panels. Choice B (200) divides the fixed cost by the selling price alone and ignores the variable cost. Choice C (333) divides by the variable cost instead of the contribution margin. Choice D (125) divides by the sum of price and variable cost ($450 + 270 = 720$) instead of their difference.',
    hint: 'Break-even units = fixed cost divided by the contribution margin (price minus variable cost per unit).',
    steps: [
      {
        text: 'Contribution margin per panel:',
        latex: 'p - v = 450 - 270 = 180',
      },
      {
        text: 'Set revenue equal to total cost: $450Q = 90{,}000 + 270Q$, which gives $180Q = 90{,}000$.',
        latex: null,
      },
      {
        text: 'Solve for the break-even quantity:',
        latex: 'Q^* = \\frac{90{,}000}{180} = 500 \\text{ panels}',
      },
    ],
    handbookPage: 'p. 230, Cost Estimation and Break-Even Analysis',
    handbookFormula: 'Q^* = \\frac{FC}{p - v}',
    videoUrl: null,
    traps: [
      'Dividing fixed cost by the selling price alone, ignoring the variable cost',
      'Dividing by the variable cost instead of the contribution margin (price minus variable cost)',
    ],
    diagram: null,
    lessonId: 'cost-types-breakeven',
    chapterId: 'economics',
  },
  {
    id: 'econ-ctb-cp2',
    type: 'conceptual',
    statement:
      'A construction firm owns a vacant lot it could lease to a neighboring business for 30,000 dollars per year. Instead, the firm decides to use the lot as an equipment staging yard for its own projects. In an economic analysis of using the lot for staging, how should the 30,000 dollars per year of forgone lease income be classified?',
    choices: [
      { id: 'c1', text: 'A sunk cost, since the firm already owns the lot' },
      { id: 'c2', text: 'A fixed cost of operating the staging yard' },
      { id: 'c3', text: 'An opportunity cost that should be charged against the staging-yard option' },
      { id: 'c4', text: 'A marginal cost of staging one additional piece of equipment' },
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5:
      'By choosing to stage equipment on the lot, the firm gives up the 30,000 dollars per year it could have earned by leasing it out. The value of the best forgone alternative is the definition of an opportunity cost, and it must be counted as a cost of the staging decision even though no cash actually changes hands. Choice A confuses ownership with sunk cost — the lease income is a future, recoverable alternative, not money already spent and lost. Choice B is wrong because the forgone income does not arise from operating the yard; it exists regardless of activity level. Choice D misapplies marginal cost, which is the cost of one more unit of output, not a forgone alternative use of an asset.',
    hint: 'What term describes the value of the best alternative you give up by choosing a particular option?',
    steps: [
      {
        text: 'Using the lot for staging means the firm cannot lease it out, so it forgoes 30,000 dollars per year of income.',
        latex: null,
      },
      {
        text: 'Opportunity cost is the value of the best alternative given up when a choice is made.',
        latex: null,
      },
      {
        text: 'The forgone lease income is therefore an opportunity cost and should be charged against the staging-yard option.',
        latex: null,
      },
      {
        text: 'It is not a sunk cost (the income is a future alternative, not a past irrecoverable expense) and not a fixed or marginal cost of operating the yard.',
        latex: null,
      },
    ],
    handbookPage: 'p. 230, Cost Estimation; p. 229, Engineering Economics concepts',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Calling forgone income a sunk cost because the asset is already owned — sunk costs are past and irrecoverable, not forgone future alternatives',
      'Treating the forgone income as a fixed operating cost of the chosen option',
    ],
    diagram: null,
    lessonId: 'cost-types-breakeven',
    chapterId: 'economics',
  },
  {
    id: 'econ-bcd-cp1',
    type: 'computational',
    statement:
      'A proposed highway widening has a present worth of user benefits of 8,000,000 dollars, a present worth of disbenefits (added noise and property impacts on adjacent residents) of 1,200,000 dollars, and a present worth of agency costs of 5,500,000 dollars. Using the conventional benefit-cost ratio with disbenefits subtracted from benefits, what is the B/C ratio?',
    choices: [
      { id: 'c1', text: '1.45' },
      { id: 'c2', text: '1.24' },
      { id: 'c3', text: '1.19' },
      { id: 'c4', text: '1.86' },
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5:
      'Disbenefits are negative effects on the public, so they are subtracted from the benefits in the numerator: $B/C = (B - D)/C = (8{,}000{,}000 - 1{,}200{,}000)/5{,}500{,}000 = 6{,}800{,}000/5{,}500{,}000 = 1.24$. Choice A (1.45) ignores the disbenefits entirely ($8{,}000{,}000/5{,}500{,}000$). Choice C (1.19) incorrectly adds the disbenefits to the cost denominator ($8{,}000{,}000/6{,}700{,}000$). Choice D (1.86) incorrectly subtracts the disbenefits from the cost denominator ($8{,}000{,}000/4{,}300{,}000$) instead of from the benefits.',
    hint: 'Disbenefits are public losses — subtract them from benefits in the numerator, not from the cost in the denominator.',
    steps: [
      {
        text: 'Subtract disbenefits from benefits in the numerator:',
        latex: 'B - D = 8{,}000{,}000 - 1{,}200{,}000 = 6{,}800{,}000',
      },
      {
        text: 'Divide by the present worth of agency costs:',
        latex: 'B/C = \\frac{6{,}800{,}000}{5{,}500{,}000} = 1.24',
      },
      {
        text: 'Since B/C = 1.24 > 1, the project is economically justified.',
        latex: null,
      },
    ],
    handbookPage: 'p. 231, Benefit-Cost Analysis',
    handbookFormula: 'B/C = \\frac{B - D}{C}',
    videoUrl: null,
    traps: [
      'Ignoring the disbenefits and dividing gross benefits by cost (gives 1.45)',
      'Placing the disbenefits in the denominator with the costs instead of subtracting them from benefits',
    ],
    diagram: null,
    lessonId: 'benefit-cost-decision-trees',
    chapterId: 'economics',
  },
  {
    id: 'econ-bcd-cp2',
    type: 'computational',
    statement:
      'A developer must decide whether to build a mixed-use project now. Demand is uncertain: there is a 50% chance of high demand giving a net present value of +500,000 dollars, a 30% chance of medium demand giving +200,000 dollars, and a 20% chance of low demand giving -100,000 dollars. What is the expected net present value of building now?',
    choices: [
      { id: 'c1', text: '200,000 dollars' },
      { id: 'c2', text: '310,000 dollars' },
      { id: 'c3', text: '330,000 dollars' },
      { id: 'c4', text: '290,000 dollars' },
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5:
      'At a chance node you weight each outcome by its probability and sum: $EV = 0.50(500{,}000) + 0.30(200{,}000) + 0.20(-100{,}000) = 250{,}000 + 60{,}000 - 20{,}000 = 290{,}000$. Choice A (200,000) takes the plain arithmetic average of the three outcomes ($(500{,}000 + 200{,}000 - 100{,}000)/3$) and ignores the probabilities. Choice C (330,000) treats the low-demand outcome as a gain instead of a loss (adds 20,000 instead of subtracting). Choice B (310,000) drops the unprofitable low-demand branch entirely and sums only the first two terms.',
    hint: 'Multiply each NPV by its probability and add — remember the low-demand outcome is negative.',
    steps: [
      {
        text: 'Confirm probabilities sum to 1.0: $0.50 + 0.30 + 0.20 = 1.00$.',
        latex: null,
      },
      {
        text: 'Apply the expected value formula at the chance node:',
        latex: 'EV = 0.50(500{,}000) + 0.30(200{,}000) + 0.20(-100{,}000)',
      },
      {
        text: 'Compute each term:',
        latex: 'EV = 250{,}000 + 60{,}000 - 20{,}000',
      },
      {
        text: 'Sum:',
        latex: 'EV = 290{,}000',
      },
    ],
    handbookPage: 'p. 231, Economic Decision Trees; Expected Value',
    handbookFormula: 'EV = C_1 \\cdot p_1 + C_2 \\cdot p_2 + \\cdots + C_n \\cdot p_n',
    videoUrl: null,
    traps: [
      'Averaging the outcomes equally instead of weighting by probability',
      'Treating the negative low-demand outcome as a positive value',
    ],
    diagram: null,
    lessonId: 'benefit-cost-decision-trees',
    chapterId: 'economics',
  },
  {
    id: 'econ-dti-cp1',
    type: 'computational',
    statement:
      'A contractor buys a backhoe for 150,000 dollars with an estimated salvage value of 30,000 dollars after an 8-year life. Using straight-line depreciation, what is the book value of the backhoe at the end of year 5?',
    choices: [
      { id: 'c1', text: '75,000 dollars' },
      { id: 'c2', text: '56,250 dollars' },
      { id: 'c3', text: '45,000 dollars' },
      { id: 'c4', text: '30,000 dollars' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5:
      'Straight-line depreciation is constant each year: $D = (C - S_n)/n = (150{,}000 - 30{,}000)/8 = 15{,}000$ per year. After 5 years the accumulated depreciation is $5 \\times 15{,}000 = 75{,}000$, so the book value is $150{,}000 - 75{,}000 = 75{,}000$. Choice B (56,250) forgets to subtract salvage when computing the annual depreciation ($150{,}000/8 = 18{,}750$ per year, then $150{,}000 - 93{,}750$). Choice C (45,000) wrongly subtracts the accumulated depreciation from the depreciable base ($120{,}000 - 75{,}000$) instead of from the full cost. Choice D (30,000) assumes the asset is already at salvage value, which only happens at the end of its full 8-year life.',
    hint: 'Find the constant annual straight-line depreciation, multiply by the number of years elapsed, then subtract from the initial cost.',
    steps: [
      {
        text: 'Annual straight-line depreciation:',
        latex: 'D = \\frac{C - S_n}{n} = \\frac{150{,}000 - 30{,}000}{8} = 15{,}000',
      },
      {
        text: 'Accumulated depreciation through year 5:',
        latex: '\\sum_{k=1}^{5} D_k = 5 \\times 15{,}000 = 75{,}000',
      },
      {
        text: 'Book value at end of year 5:',
        latex: 'BV_5 = 150{,}000 - 75{,}000 = 75{,}000',
      },
    ],
    handbookPage: 'p. 231, Depreciation; Book Value',
    handbookFormula: 'BV_j = C - j \\cdot \\frac{C - S_n}{n}',
    videoUrl: null,
    traps: [
      'Forgetting to subtract salvage value when computing the annual straight-line depreciation',
      'Subtracting accumulated depreciation from the depreciable base instead of from the full initial cost',
    ],
    diagram: null,
    lessonId: 'depreciation-taxation-inflation',
    chapterId: 'economics',
  },
  {
    id: 'econ-dti-cp2',
    type: 'computational',
    statement:
      'A culvert replacement is estimated to cost 50,000 dollars in actual (then-current) dollars 10 years from now. The general inflation rate is 3% per year. Expressed in today\'s constant (real) purchasing-power dollars, what is the equivalent cost?',
    choices: [
      { id: 'c1', text: '37,200 dollars' },
      { id: 'c2', text: '67,200 dollars' },
      { id: 'c3', text: '35,000 dollars' },
      { id: 'c4', text: '38,500 dollars' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5:
      'Converting an actual (inflated) future amount into today\'s purchasing power means dividing by the inflation index $(1 + f)^n$, not discounting at any interest rate: $50{,}000 / (1.03)^{10} = 50{,}000 / 1.3439 = 37{,}205 \\approx 37{,}200$. Choice B (67,200) multiplies by the inflation factor ($50{,}000 \\times 1.3439$), moving in the wrong direction. Choice C (35,000) applies a simple, non-compounded 30% reduction ($50{,}000 \\times (1 - 0.30)$). Choice D (38,500) divides by a simple factor of 1.30 instead of the compounded $(1.03)^{10}$.',
    hint: 'To strip inflation out of an actual-dollar future amount, divide by $(1 + f)^n$. Do not use any interest rate here.',
    steps: [
      {
        text: 'Identify: actual-dollar future cost $= 50{,}000$, inflation $f = 3\\%$, $n = 10$ years.',
        latex: null,
      },
      {
        text: 'Deflate by the inflation index to reach constant (real) dollars:',
        latex: '\\text{Real} = \\frac{50{,}000}{(1 + f)^n} = \\frac{50{,}000}{(1.03)^{10}}',
      },
      {
        text: 'Compute the index:',
        latex: '(1.03)^{10} = 1.34392',
      },
      {
        text: 'Result:',
        latex: '\\text{Real} = \\frac{50{,}000}{1.34392} = 37{,}205 \\approx 37{,}200',
      },
    ],
    handbookPage: 'p. 230, Inflation',
    handbookFormula: '\\text{Constant dollars} = \\frac{\\text{Actual dollars}}{(1 + f)^n}',
    videoUrl: null,
    traps: [
      'Multiplying by the inflation factor instead of dividing (inflating forward rather than deflating back)',
      'Applying a simple 30% reduction instead of compounding the 3% rate over 10 years',
    ],
    diagram: null,
    lessonId: 'depreciation-taxation-inflation',
    chapterId: 'economics',
  },
];

export default PROBLEMS;
