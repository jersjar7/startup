export default {
  context: 'This chapter tests your ability to evaluate the economic viability of engineering projects using time-value-of-money principles.',
  subtopics: [
    { id: 'time-value',      name: 'Time Value of Money' },
    { id: 'equivalence',     name: 'Equivalence & Cash Flow Diagrams' },
    { id: 'cost-analysis',   name: 'Cost Analysis' },
    { id: 'economic-analysis', name: 'Economic Analyses (Break-Even, B/C, Life-Cycle)' },
    { id: 'depreciation',    name: 'Depreciation Methods' },
    { id: 'inflation',       name: 'Inflation & Discount Rates' },
    { id: 'sustainability',  name: 'Sustainability & Renewable Energy Economics' },
  ],
  formulas: [
    { latex: 'F = P(1+i)^n', label: 'Future Worth', page: 'p. 111' },
    { latex: 'P = F(1+i)^{-n}', label: 'Present Worth', page: 'p. 111' },
    { latex: 'A = P\\frac{i(1+i)^n}{(1+i)^n - 1}', label: 'Capital Recovery', page: 'p. 111' },
    { latex: 'B/C = \\frac{\\text{Benefits}}{\\text{Costs}}', label: 'Benefit-Cost Ratio', page: 'p. 113' },
    { latex: 'D_t = \\frac{\\text{Cost} - \\text{Salvage}}{n}', label: 'Straight-Line Depreciation', page: 'p. 114' },
  ],
  traps: [
    'Forgetting to draw the cash flow diagram — most errors come from misplacing payments in time.',
    'Using the wrong interest factor table (P/A vs A/P, F/A vs A/F) — always double-check which conversion you need.',
    'Including sunk costs in economic analysis — sunk costs are irrelevant to future decisions.',
    'Confusing MARR (minimum attractive rate of return) with the actual rate of return.',
    'Not converting between nominal and effective interest rates when compounding periods differ.',
  ],
};
