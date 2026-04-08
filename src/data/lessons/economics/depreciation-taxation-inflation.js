export default {
  id: 'depreciation-taxation-inflation',
  name: 'Depreciation, Taxation & Inflation',
  subtopicId: 'depreciation-and-finance',
  application:
    'Every capital asset a civil engineering firm owns \u2014 excavators, survey equipment, vehicles, even software \u2014 loses value over time, and the IRS lets you deduct that loss. The FE tests whether you can compute depreciation using straight-line and MACRS methods, calculate book value, and understand how depreciation affects taxable income. Inflation shows up when you need to convert between real and nominal dollars or adjust an interest rate for purchasing power erosion. These topics tie directly to after-tax cash flow analysis and project justification. Expect at least one depreciation or inflation-adjusted problem on exam day, and the MACRS table is provided right in the handbook (p. 231).',
  content: [
    {
      type: 'text',
      body: 'Depreciation, taxation, and inflation are the three adjustments that turn a simple cash flow analysis into a realistic after-tax picture. The FE tests each one separately and occasionally combines them.',
    },
    { type: 'heading', body: 'Straight-Line Depreciation' },
    {
      type: 'formula',
      latex: 'D_j = \\frac{C - S_n}{n}',
      label: 'Annual Straight-Line Depreciation',
    },
    {
      type: 'text',
      body: '$C$ is the initial cost, $S_n$ is the salvage value at end of life, and $n$ is the depreciable life in years. Every year gets the same deduction. This is the simplest method and the one students default to \u2014 but the FE more often tests MACRS.',
    },
    { type: 'heading', body: 'MACRS Depreciation' },
    {
      type: 'text',
      body: 'The Modified Accelerated Cost Recovery System (MACRS) uses IRS-defined percentages that front-load depreciation into the early years. The handbook provides a table of MACRS factors for 3-, 5-, 7-, and 10-year recovery periods (p. 231). Salvage value is ignored \u2014 MACRS depreciates the full initial cost.',
    },
    {
      type: 'formula',
      latex: 'D_j = d_j \\times C',
      label: 'MACRS Depreciation in Year j',
    },
    {
      type: 'text',
      body: '$d_j$ is the MACRS factor (percentage) from the table for year $j$, and $C$ is the initial cost. There is no salvage subtraction \u2014 MACRS always depreciates from the full cost basis.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The MACRS table is on p. 231 of the handbook. You do not need to memorize the percentages \u2014 just know how to read the table. A 5-year MACRS asset actually has 6 years of depreciation (years 1\u20136) because of the half-year convention.',
    },
    { type: 'heading', body: 'Book Value' },
    {
      type: 'formula',
      latex: 'BV_j = C - \\sum_{k=1}^{j} D_k',
      label: 'Book Value after Year j',
    },
    {
      type: 'text',
      body: 'Book value is initial cost minus accumulated depreciation. It represents the undepreciated balance on the books, not market value. If a problem asks for book value at the end of year 3, sum the depreciation from years 1 through 3 and subtract from the initial cost.',
    },
    { type: 'heading', body: 'Taxation' },
    {
      type: 'text',
      body: 'Taxable income equals total revenue minus operating expenses minus depreciation. Capital purchases are not directly expensed \u2014 they are depreciated over their recovery period. The tax owed is the tax rate times taxable income.',
    },
    {
      type: 'formula',
      latex: '\\text{Tax} = t \\times (\\text{Revenue} - \\text{Expenses} - D)',
      label: 'Income Tax Calculation',
    },
    {
      type: 'text',
      body: '$t$ is the tax rate and $D$ is the depreciation deduction for that year. Depreciation reduces taxable income but is not an actual cash outflow \u2014 it is a non-cash deduction that saves you $t \\times D$ in taxes each year.',
    },
    { type: 'heading', body: 'Inflation' },
    {
      type: 'formula',
      latex: 'd = i + f + (i \\times f)',
      label: 'Inflation-Adjusted Interest Rate',
    },
    {
      type: 'text',
      body: 'To account for inflation, use the combined rate $d$ in place of $i$ when computing present worth. Here $i$ is the real interest rate (purchasing power growth) and $f$ is the general inflation rate. If cash flows are in actual (nominal) dollars, discount at $d$. If cash flows are in constant (real) dollars, discount at $i$.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'The FE usually tells you whether cash flows are in "actual dollars" or "constant dollars." If it says actual/nominal, use $d$. If it says constant/real, use $i$. Mixing these up shifts your entire present worth calculation.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'Do not confuse the inflation-adjusted rate formula $d = i + f + if$ with simple addition. At small rates the cross-term $if$ is tiny, but the FE may use rates large enough (like $i = 8\\%$ and $f = 5\\%$) that dropping the cross-term changes the answer.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'econ-dti-q1',
      statement:
        'A civil engineering firm purchases survey equipment for 60,000 dollars. The equipment is classified as a 5-year MACRS property. What is the depreciation deduction in year 2?',
      choices: [
        { id: 'c1', text: '12,000 dollars' },
        { id: 'c2', text: '19,200 dollars' },
        { id: 'c3', text: '10,000 dollars' },
        { id: 'c4', text: '11,520 dollars' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: "MACRS doesn't spread depreciation evenly \u2014 it front-loads it. Year 2 of a 5-year asset gets the biggest chunk (32%). Just look up the percentage in the table and multiply by the full purchase price. No salvage value subtraction with MACRS. Answer A (12,000 dollars) is the straight-line trap \u2014 people divide 60,000 by 5 years, which is a completely different method. Answer C (10,000 dollars) divides by 6 years (the actual number of MACRS depreciation years due to the half-year convention). Answer D grabs the wrong row from the table.",
      hint: 'Look up the MACRS factor for year 2 of a 5-year property in the handbook table, then multiply by the initial cost.',
      steps: [
        {
          text: 'Identify: 5-year MACRS property, initial cost = 60,000 dollars.',
          latex: null,
        },
        {
          text: 'From the MACRS table (p. 231), the year 2 factor for 5-year property is 32.00%.',
          latex: null,
        },
        {
          text: 'Calculate:',
          latex: 'D_2 = 0.3200 \\times 60{,}000 = 19{,}200',
        },
        {
          text: 'Answer A (12,000 dollars) uses straight-line: 60,000 \u00f7 5 = 12,000, ignoring MACRS entirely.',
          latex: null,
        },
      ],
      handbookPage: 'p. 231, MACRS Factors Table',
      handbookFormula: 'D_j = d_j \\times C',
      videoUrl: null,
      traps: [
        'Using straight-line depreciation instead of MACRS \u2014 the problem specifies MACRS',
        'Subtracting salvage value before applying the MACRS factor \u2014 MACRS depreciates the full cost',
      ],
      diagram: null,
    },
    {
      id: 'econ-dti-q2',
      statement:
        'A construction company buys a concrete batch plant for 500,000 dollars. It is a 7-year MACRS property. The MACRS factors for years 1 through 3 are 14.29%, 24.49%, and 17.49%. What is the book value of the plant at the end of year 3?',
      choices: [
        { id: 'c1', text: '218,650 dollars' },
        { id: 'c2', text: '281,350 dollars' },
        { id: 'c3', text: '412,450 dollars' },
        { id: 'c4', text: '87,450 dollars' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: "Book value is what's left after you subtract all the depreciation taken so far. Add up the MACRS percentages for years 1\u20133 (14.29 + 24.49 + 17.49 = 56.27%), multiply by the initial cost to get total depreciation (281,350 dollars), then subtract from 500,000. Answer B (281,350 dollars) is the accumulated depreciation itself \u2014 a common mix-up between \"how much you've depreciated\" and \"how much is left.\" Answer C (412,450 dollars) only subtracts year 3's depreciation instead of all three years. Answer D (87,450 dollars) is just the year 3 depreciation alone.",
      hint: 'Book value = initial cost minus the sum of all depreciation taken through year $j$. Add up the MACRS factors for years 1 through 3 first.',
      steps: [
        {
          text: 'Compute depreciation for each of the first 3 years:',
          latex: 'D_1 = 0.1429 \\times 500{,}000 = 71{,}450',
        },
        {
          text: 'Year 2:',
          latex: 'D_2 = 0.2449 \\times 500{,}000 = 122{,}450',
        },
        {
          text: 'Year 3:',
          latex: 'D_3 = 0.1749 \\times 500{,}000 = 87{,}450',
        },
        {
          text: 'Sum accumulated depreciation:',
          latex: '\\sum D = 71{,}450 + 122{,}450 + 87{,}450 = 281{,}350',
        },
        {
          text: 'Book value:',
          latex: 'BV_3 = 500{,}000 - 281{,}350 = 218{,}650',
        },
      ],
      handbookPage: 'p. 231, Book Value; MACRS Factors Table',
      handbookFormula: 'BV_j = C - \\sum_{k=1}^{j} D_k',
      videoUrl: null,
      traps: [
        'Reporting accumulated depreciation as book value (that is the opposite)',
        'Only subtracting the current year\'s depreciation instead of the cumulative total',
      ],
      diagram: null,
    },
    {
      id: 'econ-dti-q3',
      statement:
        'An engineer is evaluating a 10-year project with cash flows stated in actual (nominal) dollars. The real interest rate is 4% and the general inflation rate is 3%. What inflation-adjusted interest rate should be used to discount the cash flows, and what is the present worth factor $(P/F)$ for year 10 at that rate?',
      choices: [
        { id: 'c1', text: '7.00% and (P/F) = 0.508' },
        { id: 'c2', text: '7.12% and (P/F) = 0.502' },
        { id: 'c3', text: '7.12% and (P/F) = 0.676' },
        { id: 'c4', text: '4.00% and (P/F) = 0.676' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: "When cash flows are in actual (nominal) dollars \u2014 meaning they include inflation \u2014 you need to discount at the combined rate, not just the real rate. The formula is $d = i + f + if$, not just $i + f$. The cross-term (0.04 \u00d7 0.03 = 0.0012) is small but enough to change the answer from 7.00% to 7.12%. Answer A (7.00%) is the trap for students who just add the two rates. Answer C gets the rate right but reads the wrong present worth factor. Answer D uses the real rate (4%) which would only be correct if the cash flows were in constant (real) dollars.",
      hint: 'Actual dollars means you need the inflation-adjusted rate. The formula has three terms, not two \u2014 don\'t forget the cross-term $i \\times f$.',
      steps: [
        {
          text: 'Since cash flows are in actual (nominal) dollars, use the inflation-adjusted rate.',
          latex: null,
        },
        {
          text: 'Apply the formula:',
          latex: 'd = i + f + (i \\times f) = 0.04 + 0.03 + (0.04 \\times 0.03) = 0.0712 = 7.12\\%',
        },
        {
          text: 'Compute the present worth factor at 7.12% for $n = 10$:',
          latex: '(P/F,\\, 7.12\\%,\\, 10) = (1.0712)^{-10}',
        },
        {
          text: 'Calculate:',
          latex: '(1.0712)^{10} \\approx 1.993 \\quad \\Rightarrow \\quad (P/F) = \\frac{1}{1.993} \\approx 0.502',
        },
        {
          text: 'Answer A (7.00%) simply adds the rates without the cross-term. Answer D (4.00%) uses the real rate, which is only valid for constant-dollar cash flows.',
          latex: null,
        },
      ],
      handbookPage: 'p. 230, Inflation',
      handbookFormula: 'd = i + f + (i \\times f)',
      videoUrl: null,
      traps: [
        'Simply adding the real rate and inflation rate (7.00% instead of 7.12%) \u2014 the cross-term matters',
        'Using the real interest rate for nominal cash flows or the combined rate for real cash flows \u2014 match the rate to the dollar type',
      ],
      diagram: null,
    },
  ],
};
