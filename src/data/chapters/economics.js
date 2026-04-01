export default {
  context: 'This chapter tests your ability to evaluate the economic viability of engineering projects using time-value-of-money principles, cost analysis, and depreciation methods.',
  subtopics: [
    { id: 'time-value-of-money', name: 'Time Value of Money',
      application: 'Time value of money is the foundation of every infrastructure investment decision. When a city asks whether to replace a bridge now for $8M or do major rehabilitation in 10 years for $12M, you convert both options to present worth at the appropriate discount rate. On the FE, you need the nine standard interest factors and the skill to read factor tables quickly (pp. 229, 232–236).' },
    { id: 'cost-and-economic-analysis', name: 'Cost & Economic Analysis',
      application: 'Civil engineers compare alternatives constantly — asphalt vs. concrete over a 30-year life, pump station upgrade vs. status quo, highway widening vs. new interchange. The FE tests whether you can classify costs correctly, find break-even points, compute benefit-cost ratios, and use decision trees to handle uncertainty (pp. 230–231).' },
    { id: 'depreciation-and-finance', name: 'Depreciation & Finance',
      application: 'Depreciation determines the book value of infrastructure assets like treatment plants, fleet vehicles, and heavy equipment. The FE tests straight-line and MACRS methods, the inflation-adjusted interest rate, and basic bond/capitalized-cost calculations (pp. 230–231).' },
  ],
  formulas: [
    { latex: 'F = P(1+i)^n', label: 'Future Worth (Single Payment)', page: 'p. 229' },
    { latex: 'P = F(1+i)^{-n}', label: 'Present Worth (Single Payment)', page: 'p. 229' },
    { latex: 'A = P\\frac{i(1+i)^n}{(1+i)^n - 1}', label: 'Capital Recovery', page: 'p. 229' },
    { latex: 'B/C \\geq 1', label: 'Benefit-Cost Ratio', page: 'p. 230' },
    { latex: 'D_j = \\frac{\\text{Cost} - \\text{Salvage}}{n}', label: 'Straight-Line Depreciation', page: 'p. 230' },
    { latex: 'd = i + f + (i \\times f)', label: 'Inflation-Adjusted Interest Rate', page: 'p. 230' },
  ],
  traps: [
    'Forgetting to draw the cash flow diagram — most errors come from misplacing payments in time.',
    'Using the wrong interest factor table (P/A vs A/P, F/A vs A/F) — always double-check which conversion you need.',
    'Including sunk costs in economic analysis — sunk costs are irrelevant to future decisions.',
    'Confusing MARR (minimum attractive rate of return) with the actual rate of return.',
    'Not converting between nominal and effective interest rates when compounding periods differ.',
  ],
};
