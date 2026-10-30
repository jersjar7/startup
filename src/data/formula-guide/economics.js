// Plain-language guide to the formulas on the FE Civil Engineering Economics
// page, in the same order as chapters/economics.js. Symbols checked against the
// FE Reference Handbook 10.5.
export default [
  {
    label: 'Future Worth (Single Payment)',
    aliases: ['future worth', 'compound amount', 'f given p', 'compound interest'],
    use: 'Find what one amount of money today grows to after n periods at interest rate i.',
    symbols: [
      { tex: 'F', means: 'future worth, the amount at the end of period n', units: 'dollars' },
      { tex: 'P', means: 'present worth, the amount today (time zero)', units: 'dollars' },
      { tex: 'i', means: 'interest rate per period, as a decimal', units: 'unitless (per period)' },
      { tex: 'n', means: 'number of compounding periods', units: 'periods (years, months)' },
    ],
    trap: 'i and n must use the same period, so a monthly rate goes with a number of months.',
  },
  {
    label: 'Present Worth (Single Payment)',
    aliases: ['present worth', 'present value', 'p given f', 'discount'],
    use: 'Find what one amount received in the future is worth today.',
    symbols: [
      { tex: 'P', means: 'present worth, the value today (time zero)', units: 'dollars' },
      { tex: 'F', means: 'future amount, received at the end of period n', units: 'dollars' },
      { tex: 'i', means: 'interest rate per period, as a decimal', units: 'unitless (per period)' },
      { tex: 'n', means: 'number of compounding periods', units: 'periods (years, months)' },
    ],
    trap: 'i and n must use the same period, so a monthly rate goes with a number of months.',
  },
  {
    label: 'Capital Recovery',
    aliases: ['capital recovery', 'a given p', 'loan payment', 'annual worth'],
    use: 'Turn an amount today into equal payments at the end of each period, like a loan payment.',
    symbols: [
      { tex: 'A', means: 'uniform amount paid at the end of each period', units: 'dollars per period' },
      { tex: 'P', means: 'present worth, the amount at time zero', units: 'dollars' },
      { tex: 'i', means: 'interest rate per period, as a decimal', units: 'unitless (per period)' },
      { tex: 'n', means: 'number of periods (payments)', units: 'periods (years, months)' },
    ],
    trap: 'The first payment A comes one period after P, not at time zero.',
  },
  {
    label: 'Benefit-Cost Ratio',
    aliases: ['benefit cost', 'b/c ratio', 'bc ratio', 'public project'],
    use: 'Decide whether a project is worth doing: it is justified when benefits are at least equal to costs.',
    symbols: [
      { tex: 'B', means: 'benefits of the project', units: 'dollars (present or annual worth)' },
      { tex: 'C', means: 'costs of the project', units: 'dollars (present or annual worth)' },
    ],
    trap: 'B and C must be on the same basis (both present worth or both annual worth), and to choose between projects compare them incrementally, not by the biggest ratio.',
  },
  {
    label: 'Straight-Line Depreciation',
    aliases: ['straight line', 'depreciation', 'book value', 'salvage'],
    use: 'Spread the loss in value of an asset evenly over its life.',
    symbols: [
      { tex: 'D_j', means: 'depreciation in year j, the same every year', units: 'dollars per year' },
      { tex: '\\text{Cost}', means: 'initial cost of the asset', units: 'dollars' },
      { tex: '\\text{Salvage}', means: 'expected salvage value at the end of its life', units: 'dollars' },
      { tex: 'n', means: 'depreciable life of the asset', units: 'years' },
    ],
    trap: 'Subtract the salvage value before dividing; book value in a later year is cost minus all depreciation taken so far.',
  },
  {
    label: 'Inflation-Adjusted Interest Rate',
    aliases: ['inflation', 'inflation adjusted rate', 'market rate', 'real interest'],
    use: 'Combine the interest rate and the inflation rate into one rate for finding present worth of inflated cash flows.',
    symbols: [
      { tex: 'd', means: 'inflation-adjusted interest rate per period', units: 'unitless (per period)' },
      { tex: 'i', means: 'interest rate per period, without inflation', units: 'unitless (per period)' },
      { tex: 'f', means: 'general inflation rate per period', units: 'unitless (per period)' },
    ],
    trap: 'Multiply the decimals, not the percents: i = 5% and f = 3% give d = 0.05 + 0.03 + 0.0015 = 8.15%, not just 8%.',
  },
  {
    label: 'Internal Rate of Return (IRR)',
    aliases: ['irr', 'rate of return', 'internal rate of return', 'marr'],
    use: 'Find the interest rate at which a project just breaks even, then compare it with the minimum acceptable rate (MARR).',
    symbols: [
      { tex: 'PW_{benefits}', means: 'present worth of all benefits (income) at the trial interest rate', units: 'dollars' },
      { tex: 'PW_{costs}', means: 'present worth of all costs at the trial interest rate', units: 'dollars' },
    ],
    trap: 'The unknown is the interest rate, so you solve by trying rates (or reading the factor tables) until the two sides match; accept the project when that rate is at least the MARR.',
  },
];
