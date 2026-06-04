export default {
  id: 'cost-types-breakeven',
  name: 'Cost Types & Break-Even Analysis',
  subtopicId: 'cost-and-economic-analysis',
  application:
    'Before you can compare alternatives or run an economic analysis, you need to classify costs correctly. The FE tests whether you can separate fixed from variable costs, recognize sunk costs (and ignore them in decisions), and find the break-even point where two alternatives switch from one being cheaper to the other. Civil engineers use break-even analysis constantly \u2014 deciding when to buy vs. rent equipment, choosing between two construction methods at different volumes, or determining whether a capital investment pays for itself within the project timeline. Expect at least one cost-classification or break-even problem on the exam.',
  content: [
    {
      type: 'text',
      body: 'Engineering economics problems start with sorting costs into the right buckets. Get the classification wrong, and you will set up the entire problem incorrectly.',
    },
    { type: 'heading', body: 'Fixed vs. Variable Costs' },
    {
      type: 'text',
      body: 'Fixed costs do not change with the level of output \u2014 rent, insurance, loan payments. Variable costs scale directly with production volume \u2014 materials, fuel, labor hours. Total cost is the sum of both.',
    },
    {
      type: 'formula',
      latex: 'TC = FC + VC \\cdot Q',
      label: 'Total Cost (linear model)',
    },
    {
      type: 'text',
      body: '$FC$ is fixed cost, $VC$ is the variable cost per unit, and $Q$ is the quantity produced or the volume of work.',
    },
    { type: 'heading', body: 'Sunk Costs' },
    {
      type: 'text',
      body: 'A sunk cost is money already spent that cannot be recovered regardless of what you decide next. The golden rule: sunk costs are irrelevant to future decisions. If a city has already spent 2 million dollars on a feasibility study for a bridge, that 2 million should not factor into whether to proceed with construction.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The FE loves to test whether you include a sunk cost in your analysis. If you see a cost described as "already spent," "previously invested," or "non-recoverable," exclude it from your economic comparison. Including it is the most common trap.',
    },
    { type: 'heading', body: 'Other Cost Categories' },
    {
      type: 'text',
      body: 'Opportunity cost is the value of the best alternative you give up by choosing a particular option. Marginal cost is the cost of producing one additional unit. Incremental cost is the difference in total cost between two alternatives. The FE may use any of these terms, so know the definitions.',
    },
    { type: 'heading', body: 'Break-Even Analysis' },
    {
      type: 'text',
      body: 'Break-even analysis finds the quantity (or time, or utilization rate) at which two alternatives cost the same. Below that point one option is cheaper; above it the other wins.',
    },
    {
      type: 'formula',
      latex: 'FC_A + VC_A \\cdot Q = FC_B + VC_B \\cdot Q',
      label: 'Break-Even Condition (two alternatives)',
    },
    {
      type: 'formula',
      latex: 'Q^* = \\frac{FC_A - FC_B}{VC_B - VC_A}',
      label: 'Break-Even Quantity',
    },
    {
      type: 'text',
      body: 'Set the total cost equations equal and solve for $Q^*$. The alternative with the higher fixed cost but lower variable cost becomes cheaper above the break-even point.',
    },
    { type: 'heading', body: 'Payback Period' },
    {
      type: 'text',
      body: 'The payback period is the time it takes for an investment to recoup its initial cost from net annual savings or revenue. Simple payback ignores the time value of money \u2014 it just divides the initial cost by annual net benefit.',
    },
    {
      type: 'formula',
      latex: '\\text{Payback Period} = \\frac{\\text{Initial Investment}}{\\text{Annual Net Savings}}',
      label: 'Simple Payback Period',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'Simple payback does not account for the time value of money and ignores cash flows after the payback point. It is a screening tool, not a replacement for PW or AW analysis. The FE may ask you to compute it, but don\'t confuse it with a full economic analysis.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'When a break-even problem gives you two cost equations, set them equal and solve for the unknown. If the variable costs are equal, the alternatives never cross \u2014 the one with the lower fixed cost always wins.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'econ-ctb-q1',
      statement:
        'A county water treatment plant was built 5 years ago for 3.2 million dollars. The county is now evaluating whether to expand the plant (Option A, costing 1.8 million dollars) or build a new satellite plant (Option B, costing 2.5 million dollars). In comparing these two options, how should the original 3.2 million dollar construction cost be treated?',
      choices: [
        { id: 'c1', text: 'It is a sunk cost and should be excluded from the comparison' },
        { id: 'c2', text: 'It should be added to Option A since the expansion builds on the existing plant' },
        { id: 'c3', text: 'It should be split equally between both options' },
        { id: 'c4', text: 'It should be depreciated over the remaining plant life and included in both options' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'The 3.2 million dollars was spent 5 years ago and is gone no matter what the county decides next. That makes it a textbook sunk cost. The decision right now is only between the 1.8 million dollar expansion and the 2.5 million dollar new plant \u2014 the past expenditure does not change the future costs of either option. The option that adds the cost to Option A is the most tempting trap because the expansion physically connects to the existing plant, but the original cost is still irrecoverable. The choices to split the cost equally or depreciate it over the remaining plant life invent allocation methods that sound reasonable but violate the sunk cost principle.',
      hint: 'Ask yourself: can the county recover any of the original 3.2 million by choosing one option over the other? If not, what kind of cost is it?',
      steps: [
        {
          text: 'The original 3.2 million dollars was spent 5 years ago. Regardless of whether the county expands or builds new, that money is gone.',
          latex: null,
        },
        {
          text: 'A sunk cost is any cost that has already been incurred and cannot be recovered. It should never influence a forward-looking economic decision.',
          latex: null,
        },
        {
          text: 'The correct comparison is Option A (1.8 million dollars) vs. Option B (2.5 million dollars), ignoring the 3.2 million entirely.',
          latex: null,
        },
        {
          text: 'The choice to add the cost to Option A is wrong because even though the expansion builds on the existing plant, the original cost is still irrecoverable \u2014 it does not change the incremental cost of the expansion.',
          latex: null,
        },
      ],
      handbookPage: 'p. 230, Cost Estimation; p. 229, Engineering Economics concepts',
      handbookFormula: null,
      videoUrl: null,
      traps: [
        'Adding the sunk cost to one alternative because it "belongs" to that option physically',
        'Trying to depreciate or allocate the sunk cost \u2014 sunk means sunk, regardless of accounting treatment',
      ],
      diagram: null,
    },
    {
      id: 'econ-ctb-q2',
      statement:
        'A contractor can haul excavated material using either method. Method A (owned trucks): fixed cost of 4,200 dollars per day plus 3 dollars per cubic yard. Method B (rented fleet): fixed cost of 1,200 dollars per day plus 7.30 dollars per cubic yard. At what daily volume of material does the cost of the two methods break even?',
      choices: [
        { id: 'c1', text: '500 cubic yards' },
        { id: 'c2', text: '698 cubic yards' },
        { id: 'c3', text: '1,000 cubic yards' },
        { id: 'c4', text: '1,400 cubic yards' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'Method A costs more up front (owned trucks = higher fixed cost) but less per cubic yard to operate. Method B is cheap to start each day (low rental fee) but charges more per yard. At some volume they cost the same \u2014 set the two total cost equations equal and solve for Q. Below that volume, use Method B (lower fixed cost dominates). Above it, use Method A (lower variable cost dominates). The 500 cy/day choice comes from a rounding or setup error. The 1,400 cy/day choice roughly doubles the correct answer (or divides 3,000 by ~2.1 instead of 4.30). The 1,000 cy/day choice comes from mis-setting the variable-cost difference.',
      hint: 'Write a total cost equation for each method in the form TC = FC + VC \u00d7 Q, set them equal, and solve for Q.',
      steps: [
        {
          text: 'Write the total cost equations:',
          latex: 'TC_A = 4{,}200 + 3Q \\quad \\text{and} \\quad TC_B = 1{,}200 + 7.30Q',
        },
        {
          text: 'Set them equal:',
          latex: '4{,}200 + 3Q = 1{,}200 + 7.30Q',
        },
        {
          text: 'Solve for Q:',
          latex: '4{,}200 - 1{,}200 = 7.30Q - 3Q',
        },
        {
          text: 'Simplify:',
          latex: '3{,}000 = 4.30Q',
        },
        {
          text: 'Divide:',
          latex: 'Q^* = \\frac{3{,}000}{4.30} = 697.7 \\approx 698 \\text{ cubic yards}',
        },
        {
          text: 'Below 698 cy/day, Method B (rented) is cheaper. Above 698 cy/day, Method A (owned) is cheaper.',
          latex: null,
        },
      ],
      handbookPage: 'p. 230, Cost Estimation and Break-Even Analysis',
      handbookFormula: 'Q^* = \\frac{FC_A - FC_B}{VC_B - VC_A}',
      videoUrl: null,
      traps: [
        'Subtracting variable costs in the wrong order \u2014 the denominator must be (higher VC \u2212 lower VC) to get a positive Q',
        'Forgetting to include fixed costs and only comparing variable costs per unit',
      ],
      diagram: null,
    },
    {
      id: 'econ-ctb-q3',
      statement:
        'A state DOT is considering installing an automated toll collection system at a cost of 1.4 million dollars. The system will eliminate 6 toll collector positions, saving 280,000 dollars per year in labor. However, the system has annual maintenance costs of 80,000 dollars. Using simple payback analysis, what is the payback period?',
      choices: [
        { id: 'c1', text: '5.0 years' },
        { id: 'c2', text: '7.0 years' },
        { id: 'c3', text: '3.5 years' },
        { id: 'c4', text: '2.3 years' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: 'Simple payback = initial cost divided by net annual savings. The tricky part is getting the net savings right. You save 280,000 dollars in labor but spend 80,000 dollars on maintenance, so the net savings are only 200,000 dollars per year. Divide 1.4 million by 200,000 and you get 7 years. The 5.0 years choice divides by the gross savings (280,000) without subtracting maintenance \u2014 that is the most common trap. The 3.5 years choice might come from using only half the initial cost. The 2.3 years choice could result from dividing maintenance cost by savings or another setup error.',
      hint: 'Net annual savings = gross savings minus new annual costs. Payback = initial investment divided by net annual savings.',
      steps: [
        {
          text: 'Identify the initial investment:',
          latex: 'I = 1{,}400{,}000',
        },
        {
          text: 'Calculate net annual savings: labor savings minus maintenance costs.',
          latex: 'A_{\\text{net}} = 280{,}000 - 80{,}000 = 200{,}000',
        },
        {
          text: 'Apply the simple payback formula:',
          latex: '\\text{Payback} = \\frac{I}{A_{\\text{net}}} = \\frac{1{,}400{,}000}{200{,}000} = 7.0 \\text{ years}',
        },
        {
          text: 'The 5.0 years choice forgets to subtract the 80,000 dollar maintenance cost from the savings: 1,400,000 \u00f7 280,000 = 5.0.',
          latex: null,
        },
      ],
      handbookPage: 'p. 230, Cost Estimation and Payback Analysis',
      handbookFormula: '\\text{Payback Period} = \\frac{\\text{Initial Investment}}{\\text{Annual Net Savings}}',
      videoUrl: null,
      traps: [
        'Using gross savings (280,000 dollars) instead of net savings (200,000 dollars) \u2014 always subtract new annual costs from annual benefits',
        'Confusing simple payback with discounted payback \u2014 simple payback ignores the time value of money entirely',
      ],
      diagram: null,
    },
  ],
};
