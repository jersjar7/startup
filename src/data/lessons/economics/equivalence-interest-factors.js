export default {
  id: 'equivalence-interest-factors',
  name: 'Equivalence & Interest Factors',
  subtopicId: 'time-value-of-money',
  application:
    "Every engineering economics problem on the FE boils down to moving money through time. You'll convert a lump sum today into its future equivalent, spread a present cost into equal annual payments, or discount a series of future cash flows back to the present. The nine standard interest factors are the tools \u2014 and the factor tables in the handbook (pp. 232\u2013236) are your shortcut. Civil engineers use these constantly: sizing a sinking fund for bridge replacement, calculating loan payments on equipment, or comparing the annual cost of two pavement alternatives. If you can read a cash flow diagram and pick the right factor, these are fast points.",
  content: [
    {
      type: 'text',
      body: 'Engineering economics has nine standard conversion factors. Each one moves money between three forms: a single payment ($P$ or $F$), a uniform series ($A$), or a uniform gradient ($G$). The key is knowing which factor converts what you have into what you need.',
    },
    { type: 'heading', body: 'Single Payment Factors' },
    {
      type: 'formula',
      latex: 'F = P(1+i)^n',
      label: 'Future Worth given P \u2014 (F/P, i%, n)',
    },
    {
      type: 'formula',
      latex: 'P = F(1+i)^{-n}',
      label: 'Present Worth given F \u2014 (P/F, i%, n)',
    },
    {
      type: 'text',
      body: 'These two are inverses. $(F/P)$ compounds a present amount forward; $(P/F)$ discounts a future amount back. Every other factor is built from these.',
    },
    { type: 'heading', body: 'Uniform Series Factors' },
    {
      type: 'formula',
      latex: 'A = F \\cdot \\frac{i}{(1+i)^n - 1}',
      label: 'Sinking Fund \u2014 (A/F, i%, n)',
    },
    {
      type: 'formula',
      latex: 'A = P \\cdot \\frac{i(1+i)^n}{(1+i)^n - 1}',
      label: 'Capital Recovery \u2014 (A/P, i%, n)',
    },
    {
      type: 'formula',
      latex: 'F = A \\cdot \\frac{(1+i)^n - 1}{i}',
      label: 'Compound Amount \u2014 (F/A, i%, n)',
    },
    {
      type: 'formula',
      latex: 'P = A \\cdot \\frac{(1+i)^n - 1}{i(1+i)^n}',
      label: 'Present Worth of Annuity \u2014 (P/A, i%, n)',
    },
    {
      type: 'text',
      body: 'These four handle equal payments. $(A/P)$ is what you use for loan payments. $(P/A)$ is what you use to find the present value of a stream of equal costs. $(A/F)$ sets up a sinking fund. $(F/A)$ finds what a savings plan grows to.',
    },
    { type: 'heading', body: 'Gradient Factors' },
    {
      type: 'formula',
      latex: '(P/G,\\, i\\%,\\, n) = \\frac{(1+i)^n - 1}{i^2(1+i)^n} - \\frac{n}{i(1+i)^n}',
      label: 'Gradient Present Worth',
    },
    {
      type: 'formula',
      latex: '(A/G,\\, i\\%,\\, n) = \\frac{1}{i} - \\frac{n}{(1+i)^n - 1}',
      label: 'Gradient to Uniform Series',
    },
    {
      type: 'text',
      body: 'Gradient factors handle cash flows that increase by a constant amount $G$ each period (e.g., maintenance costs that rise by 500 dollars per year). The gradient starts at zero in period 1 and increases by $G$ each period after that. Convert to $P$ or $A$ first, then combine with any base annuity.',
    },
    { type: 'heading', body: 'Cash Flow Diagrams' },
    {
      type: 'text',
      body: 'Every problem should start with a cash flow diagram. Draw a horizontal timeline, mark periods 0 through $n$, and place arrows up (income) or down (costs) at the correct time. The most common mistake on the FE is putting a payment at the wrong period \u2014 especially confusing "beginning of year" with "end of year."',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'Convention: unless stated otherwise, all payments occur at the end of the period. Period 0 is "now." A payment "at the beginning of year 3" is the same as "at the end of year 2." Getting this wrong shifts your entire answer by one factor.',
    },
    { type: 'heading', body: 'Non-Annual Compounding' },
    {
      type: 'formula',
      latex: 'i_e = \\left(1 + \\frac{r}{m}\\right)^m - 1',
      label: 'Effective Annual Rate',
    },
    {
      type: 'text',
      body: 'When compounding happens more often than annually (monthly, quarterly), convert the nominal rate $r$ to an effective annual rate $i_e$ before using the factor tables. $m$ is the number of compounding periods per year.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'Factor notation cheat sheet: the letter before the slash is what you\'re solving for, the letter after is what you already have. $(P/A)$ = "find P, given A." $(A/F)$ = "find A, given F." Read it like a fraction: result/input.',
    },
    {
      type: 'callout',
      variant: 'calculator',
      body: 'TI-36X Pro: for $(1+i)^n$, type the base, press $x^y$, then $n$. For factor table lookups, the handbook provides tables at 0.5%, 1%, 1.5%, 2%, 4%, 6%, 8%, 10%, 12%, and 18%. If the problem uses one of these rates, read the factor directly \u2014 don\'t compute it by hand.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'econ-eif-q1',
      statement:
        'A city plans to replace a water main in 10 years at an estimated cost of 500,000 dollars. The city can invest in a sinking fund that earns 6% annual interest. What uniform annual deposit must the city make at the end of each year to accumulate the required amount?',
      choices: [
        { id: 'c1', text: '37,990 dollars' },
        { id: 'c2', text: '50,000 dollars' },
        { id: 'c3', text: '67,950 dollars' },
        { id: 'c4', text: '41,240 dollars' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: "This is a straight sinking fund problem \u2014 you need equal annual deposits that grow to 500K in 10 years at 6%. The factor you want is $(A/F)$ because you're finding $A$ given $F$. Look up $(A/F, 6\\%, 10)$ in the 6% table, multiply by 500,000, done. The 50,000 dollars choice is the trap for people who just divide 500K by 10 years and ignore interest entirely. The 67,950 dollars choice uses the wrong factor \u2014 that's $(A/P)$, which is for loan payments on a present amount, not a future target. The 41,240 dollars choice is a computation error.",
      hint: 'You know the future amount needed and want to find the annual deposit \u2014 which factor converts F to A?',
      steps: [
        {
          text: 'Identify the variables: $F = 500{,}000$, $i = 6\\%$, $n = 10$ years. We need to find $A$.',
          latex: null,
        },
        {
          text: 'This is a "find A given F" problem \u2014 use the Sinking Fund factor $(A/F, 6\\%, 10)$.',
          latex: null,
        },
        {
          text: 'From the 6% factor table at $n = 10$:',
          latex: '(A/F,\\, 6\\%,\\, 10) = 0.0759',
        },
        {
          text: 'Calculate:',
          latex: 'A = 500{,}000 \\times 0.0759 = 37{,}950',
        },
        {
          text: 'The closest answer is 37,990 dollars (slight rounding between table precision and computed value).',
          latex: null,
        },
        {
          text: 'TI-36X Pro: $500{,}000 \\times 0.0759$, or compute the factor directly: $0.06 \\div [(1.06)^{10} - 1]$.',
          latex: null,
        },
      ],
      handbookPage: 'p. 229, Uniform Series Sinking Fund; p. 234, Factor Table i = 6%',
      handbookFormula: 'A = F \\cdot \\frac{i}{(1+i)^n - 1}',
      videoUrl: null,
      traps: [
        'Dividing 500K by 10 years (ignoring the time value of money entirely)',
        'Using (A/P) instead of (A/F) \u2014 capital recovery vs. sinking fund',
      ],
      diagram: { component: 'SinkingFundCFD', props: { n: 10, F: 500000, rate: 6 } },
    },
    {
      id: 'econ-eif-q2',
      statement:
        'An engineer borrows 25,000 dollars for equipment at a nominal annual interest rate of 12%, compounded monthly. The loan term is 5 years with equal monthly payments. What is the effective annual interest rate?',
      choices: [
        { id: 'c1', text: '12.00%' },
        { id: 'c2', text: '12.36%' },
        { id: 'c3', text: '12.68%' },
        { id: 'c4', text: '12.55%' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'medium',
      eli5: "When a rate is \"compounded monthly,\" the 12% isn't really 12% \u2014 it's 1% per month, and that compounds. So you earn interest on your interest 12 times a year, which pushes the effective rate above 12%. The formula is $(1 + r/m)^m - 1$. Plug in $r = 0.12$ and $m = 12$, and you get $(1.01)^{12} - 1 = 12.68\\%$. The 12.00% choice is the nominal rate \u2014 that's the one they gave you, not the effective rate. The 12.36% and 12.55% choices come from using the wrong compounding frequency (semiannual gives (1.06)^2 - 1 = 12.36%, quarterly gives (1.03)^4 - 1 = 12.55%).",
      hint: 'The nominal rate is 12% but compounding happens monthly \u2014 use the effective annual rate formula to find what 12 months of monthly compounding actually produces.',
      steps: [
        {
          text: 'Identify the variables: $r = 12\\%$ nominal annual rate, $m = 12$ compounding periods per year.',
          latex: null,
        },
        {
          text: 'Apply the effective annual rate formula:',
          latex: 'i_e = \\left(1 + \\frac{r}{m}\\right)^m - 1',
        },
        {
          text: 'Substitute:',
          latex: 'i_e = \\left(1 + \\frac{0.12}{12}\\right)^{12} - 1 = (1.01)^{12} - 1',
        },
        {
          text: 'Compute:',
          latex: '(1.01)^{12} = 1.1268',
        },
        {
          text: 'Therefore:',
          latex: 'i_e = 1.1268 - 1 = 0.1268 = 12.68\\%',
        },
        {
          text: 'TI-36X Pro: $1.01$, press $x^y$, $12$, $=$ gives $1.12682...$, subtract 1, multiply by 100.',
          latex: null,
        },
      ],
      handbookPage: 'p. 230, Non-Annual Compounding',
      handbookFormula: 'i_e = \\left(1 + \\frac{r}{m}\\right)^m - 1',
      videoUrl: null,
      traps: [
        'Reporting the nominal rate (12%) as the answer \u2014 the question asks for the effective rate',
        'Dividing the nominal rate by 12 and stopping there (1% per month is the periodic rate, not the effective annual rate)',
      ],
      diagram: null,
    },
    {
      id: 'econ-eif-q3',
      statement:
        'Annual maintenance costs for a highway bridge are 10,000 dollars in year 1, increasing by 2,000 dollars each year thereafter (i.e., 12,000 in year 2, 14,000 in year 3, etc.). The bridge has a remaining life of 10 years. At an interest rate of 8%, what is the present worth of all maintenance costs?',
      choices: [
        { id: 'c1', text: '119,100 dollars' },
        { id: 'c2', text: '100,000 dollars' },
        { id: 'c3', text: '67,100 dollars' },
        { id: 'c4', text: '134,200 dollars' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: "This problem combines two patterns: a flat 10K/year annuity and a 2K/year increasing gradient. You can't just add up the raw numbers because money in later years is worth less today. Split it into two pieces: the base annuity (use $(P/A)$) and the gradient on top (use $(P/G)$). Look up both factors in the 8% table, multiply each by its amount, and add. The 67,100 dollars option only accounts for the base annuity and forgets the gradient entirely. The 100,000 dollars option is just the sum of raw costs without discounting. The 134,200 dollars option uses the wrong gradient amount or mixes up factors.",
      hint: 'Split the increasing cash flow into a base uniform series (A) plus a uniform gradient (G), then find the present worth of each separately.',
      steps: [
        {
          text: 'Identify the cash flow structure: a base annuity of $A = 10{,}000$ plus a uniform gradient of $G = 2{,}000$ starting in year 2. With $i = 8\\%$ and $n = 10$.',
          latex: null,
        },
        {
          text: 'The present worth has two components:',
          latex: 'P = A(P/A,\\, 8\\%,\\, 10) + G(P/G,\\, 8\\%,\\, 10)',
        },
        {
          text: 'From the 8% factor table at $n = 10$:',
          latex: '(P/A,\\, 8\\%,\\, 10) = 6.7101 \\quad \\text{and} \\quad (P/G,\\, 8\\%,\\, 10) = 25.9768',
        },
        {
          text: 'Calculate the base annuity present worth:',
          latex: 'P_A = 10{,}000 \\times 6.7101 = 67{,}101',
        },
        {
          text: 'Calculate the gradient present worth:',
          latex: 'P_G = 2{,}000 \\times 25.9768 = 51{,}954',
        },
        {
          text: 'Total present worth:',
          latex: 'P = 67{,}101 + 51{,}954 = 119{,}055 \\approx 119{,}100',
        },
      ],
      handbookPage: 'p. 229, Uniform Series Present Worth + Uniform Gradient Present Worth; p. 235, Factor Table i = 8%',
      handbookFormula: 'P = A(P/A,\\, i\\%,\\, n) + G(P/G,\\, i\\%,\\, n)',
      videoUrl: null,
      traps: [
        'Forgetting the gradient component and only computing the present worth of the base annuity',
        'Adding up nominal cash flows without discounting (10K + 12K + ... + 28K = 190K ignores the time value of money)',
      ],
      diagram: { component: 'GradientCashFlow', props: { base: 10000, gradient: 2000, n: 10, rate: 8 } },
    },
  ],
};
