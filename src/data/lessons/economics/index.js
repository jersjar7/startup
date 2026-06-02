import equivalenceInterestFactors from './equivalence-interest-factors';
import pwFwAwAnalysis from './pw-fw-aw-analysis';
import costTypesBreakeven from './cost-types-breakeven';
import benefitCostDecisionTrees from './benefit-cost-decision-trees';
import depreciationTaxationInflation from './depreciation-taxation-inflation';
import rateOfReturn from './rate-of-return';

export default [
  { subtopicId: 'time-value-of-money', lessons: [equivalenceInterestFactors, pwFwAwAnalysis] },
  { subtopicId: 'cost-and-economic-analysis', lessons: [costTypesBreakeven, benefitCostDecisionTrees, rateOfReturn] },
  { subtopicId: 'depreciation-and-finance', lessons: [depreciationTaxationInflation] },
];
