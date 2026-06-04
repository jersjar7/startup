// Exam bank: economics
// Auto-extracted from lesson files — 21 questions

const PROBLEMS = [
  {
    id: 'econ-eif-ex1',
    type: 'computational',
    statement: 'A civil engineering firm sets aside 15,000 dollars in a reserve account earning 8% annual interest. If the money is left untouched, what will it be worth in 5 years?',
    choices: [
      {
        id: 'c1',
        text: '21,000 dollars'
      },
      {
        id: 'c2',
        text: '22,040 dollars'
      },
      {
        id: 'c3',
        text: '19,800 dollars'
      },
      {
        id: 'c4',
        text: '23,400 dollars'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'This is the most basic time-value-of-money problem: you have money now ($P$) and want to know what it grows to ($F$). Use the compound amount factor $(F/P)$. Multiply $15{,}000 \\times (1.08)^5 = 15{,}000 \\times 1.4693 = 22{,}040$. The 21,000 dollars choice comes from using simple interest ($15{,}000 \\times 0.08 \\times 5 = 6{,}000$, then adding to 15,000 = 21,000). The 19,800 dollars choice uses the wrong number of years or the wrong rate. The 23,400 dollars choice overshoots, possibly by applying the rate twice somewhere.',
    hint: 'You have P and need F — use the single payment compound amount factor $(F/P, i\\%, n)$.',
    steps: [
      {
        text: 'Identify: $P = 15{,}000$, $i = 8\\%$, $n = 5$ years. Find $F$.',
        latex: null
      },
      {
        text: 'Apply the compound amount factor:',
        latex: 'F = P(1+i)^n = 15{,}000 \\times (1.08)^5'
      },
      {
        text: 'Compute:',
        latex: '(1.08)^5 = 1.4693'
      },
      {
        text: 'Result:',
        latex: 'F = 15{,}000 \\times 1.4693 = 22{,}040'
      }
    ],
    handbookPage: 'p. 229, Single Payment Compound Amount',
    handbookFormula: 'F = P(1+i)^n',
    videoUrl: null,
    traps: [
      'Using simple interest (P + P times i times n) instead of compound interest — always compound on the FE unless told otherwise'
    ],
    diagram: null,
    lessonId: 'equivalence-interest-factors',
    chapterId: 'economics'
  },
  {
    id: 'econ-eif-ex2',
    type: 'computational',
    statement: 'A public works department takes out a loan of 200,000 dollars for a new dump truck at 10% annual interest. The loan will be repaid in 8 equal annual payments at the end of each year. What is the annual payment amount?',
    choices: [
      {
        id: 'c1',
        text: '25,000 dollars'
      },
      {
        id: 'c2',
        text: '37,490 dollars'
      },
      {
        id: 'c3',
        text: '29,440 dollars'
      },
      {
        id: 'c4',
        text: '43,200 dollars'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'You have a present amount (the loan) and need to find equal annual payments that pay it off. This is the capital recovery factor $(A/P)$. Look up $(A/P,\\, 10\\%,\\, 8) = 0.18744$ in the 10% table and multiply by 200,000. The 25,000 dollars choice divides 200,000 by 8 and ignores interest entirely. The 29,440 dollars choice might use $(A/F)$ instead of $(A/P)$ — that is for a sinking fund, not a loan. The 43,200 dollars choice uses the wrong factor or adds interest on top of the payment.',
    hint: 'You know the present loan amount and need equal annual payments — which factor converts P to A?',
    steps: [
      {
        text: 'Identify: $P = 200{,}000$, $i = 10\\%$, $n = 8$ years. Find $A$.',
        latex: null
      },
      {
        text: 'Use the capital recovery factor $(A/P, 10\\%, 8)$:',
        latex: '(A/P,\\, 10\\%,\\, 8) = \\frac{0.10(1.10)^8}{(1.10)^8 - 1} = 0.18744'
      },
      {
        text: 'Calculate:',
        latex: 'A = 200{,}000 \\times 0.18744 = 37{,}490'
      }
    ],
    handbookPage: 'p. 229, Capital Recovery; p. 236, Factor Table i = 10%',
    handbookFormula: 'A = P \\cdot \\frac{i(1+i)^n}{(1+i)^n - 1}',
    videoUrl: null,
    traps: [
      'Dividing the loan by the number of years (ignoring interest completely)',
      'Using the sinking fund factor (A/F) instead of capital recovery (A/P) — A/F is for building up to a future amount, not paying down a present amount'
    ],
    diagram: null,
    lessonId: 'equivalence-interest-factors',
    chapterId: 'economics'
  },
  {
    id: 'econ-eif-ex3',
    type: 'conceptual',
    statement: 'An engineer needs to find the equivalent annual cost of a one-time expenditure that will occur 15 years from now. Which sequence of interest factors could be used?',
    choices: [
      {
        id: 'c1',
        text: '$(P/F)$ to bring the future cost to the present, then $(A/P)$ to spread it over the period'
      },
      {
        id: 'c2',
        text: '$(F/P)$ to compound the future cost forward, then $(A/F)$ to annualize'
      },
      {
        id: 'c3',
        text: '$(A/F)$ applied directly to the future amount'
      },
      {
        id: 'c4',
        text: 'Both A and C would give the correct answer'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'There are usually multiple valid paths through the factor tables. You can go future to present with $(P/F)$, then present to annual with $(A/P)$ — two steps. Or you can go directly from future to annual with $(A/F)$ — one step. Both give the same answer because the factors are mathematically consistent. The path that starts with $(F/P)$ is wrong because $(F/P)$ compounds forward in time, but the cost is already in the future — compounding it further moves it to the wrong point. The key insight is that the factor tables are all interconnected, and any valid path through them gives the same result.',
    hint: 'Think about which factor converts a future amount directly to an annual series, and whether a two-step path through P would also work.',
    steps: [
      {
        text: 'Path 1: Use $(A/F,\\, i\\%,\\, n)$ directly. This converts a future amount to an equivalent annual series in one step.',
        latex: null
      },
      {
        text: 'Path 2: First use $(P/F,\\, i\\%,\\, n)$ to bring the future cost to the present, then use $(A/P,\\, i\\%,\\, n)$ to spread the present amount into annual payments.',
        latex: null
      },
      {
        text: 'Both paths are mathematically equivalent:',
        latex: '(A/F) = (A/P) \\times (P/F)'
      },
      {
        text: 'The $(F/P)$-then-$(A/F)$ path fails because $(F/P)$ moves money further into the future, not back to the present or to an annual series.',
        latex: null
      }
    ],
    handbookPage: 'p. 229, Interest Factor Table',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking there is only one valid path through the factor tables — multiple equivalent paths exist',
      'Confusing (F/P) with (P/F) — the letter before the slash is what you are solving for'
    ],
    diagram: null,
    lessonId: 'equivalence-interest-factors',
    chapterId: 'economics'
  },
  {
    id: 'econ-eif-ex4',
    type: 'computational',
    statement: 'A contractor deposits 5,000 dollars at the end of every quarter into an account earning a nominal annual interest rate of 8% compounded quarterly. After 3 years, what is the total accumulated amount in the account?',
    choices: [
      {
        id: 'c1',
        text: '60,000 dollars'
      },
      {
        id: 'c2',
        text: '63,410 dollars'
      },
      {
        id: 'c3',
        text: '67,060 dollars'
      },
      {
        id: 'c4',
        text: '70,120 dollars'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'When deposits and compounding happen quarterly, work in quarters — not years. The periodic rate is $8\\% / 4 = 2\\%$ per quarter, and the number of periods is $3 \\times 4 = 12$ quarters. Use the compound amount factor for a uniform series: $(F/A,\\, 2\\%,\\, 12)$. That equals $[(1.02)^{12} - 1] / 0.02 = 13.412$. Multiply by 5,000 and you get 67,060. The 60,000 dollars choice just adds up 12 deposits of 5,000 without any interest. The 63,410 dollars choice uses the effective annual rate but only 3 periods, mixing quarterly deposits with annual compounding. The 70,120 dollars choice overshoots, likely using the wrong rate or period count.',
    hint: 'When deposits match the compounding period (quarterly), use the periodic rate and the total number of periods directly in the $(F/A)$ factor.',
    steps: [
      {
        text: 'Convert to periodic values: $i_{\\text{per}} = r/m = 0.08/4 = 0.02 = 2\\%$ per quarter.',
        latex: null
      },
      {
        text: 'Number of periods: $n = 3 \\times 4 = 12$ quarters.',
        latex: null
      },
      {
        text: 'Apply the compound amount factor for a uniform series:',
        latex: '(F/A,\\, 2\\%,\\, 12) = \\frac{(1.02)^{12} - 1}{0.02}'
      },
      {
        text: 'Compute:',
        latex: '(1.02)^{12} = 1.2682 \\quad \\Rightarrow \\quad (F/A) = \\frac{1.2682 - 1}{0.02} = 13.412'
      },
      {
        text: 'Result:',
        latex: 'F = 5{,}000 \\times 13.412 = 67{,}060'
      }
    ],
    handbookPage: 'p. 229, Uniform Series Compound Amount; p. 230, Non-Annual Compounding',
    handbookFormula: 'F = A \\cdot \\frac{(1+i)^n - 1}{i}',
    videoUrl: null,
    traps: [
      'Using the annual rate (8%) with 3 periods instead of the quarterly rate (2%) with 12 periods',
      'Summing deposits without interest (5,000 times 12 = 60,000) — this ignores compounding entirely'
    ],
    diagram: null,
    lessonId: 'equivalence-interest-factors',
    chapterId: 'economics'
  },
  {
    id: 'econ-pfa-ex1',
    type: 'computational',
    statement: 'A city is considering purchasing an automated traffic signal controller for 45,000 dollars. It will reduce manual labor costs by 8,000 dollars per year for 10 years and has a salvage value of 5,000 dollars at the end of its life. At MARR = 6%, what is the present worth of this investment?',
    choices: [
      {
        id: 'c1',
        text: '16,700 dollars'
      },
      {
        id: 'c2',
        text: '38,900 dollars'
      },
      {
        id: 'c3',
        text: '-2,300 dollars'
      },
      {
        id: 'c4',
        text: '13,900 dollars'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Present worth is the value of the investment in today\'s money. Take the PW of annual savings using $(P/A)$, add the PW of the salvage using $(P/F)$, and subtract the initial cost. PW of savings $= 8{,}000 \\times 7.3601 = 58{,}881$. PW of salvage $= 5{,}000 \\times 0.5584 = 2{,}792$. Total $PW = -45{,}000 + 58{,}881 + 2{,}792 = 16{,}673$, or about 16,700. Since PW is positive, the investment earns more than the 6% MARR. The 38,900 dollars distractor leaves out the initial cost (or mishandles a factor). The -2,300 dollars distractor subtracts the salvage instead of adding it. The 13,900 dollars distractor forgets the salvage value entirely.',
    hint: 'PW = negative initial cost + PW of annual savings + PW of salvage value. Use $(P/A)$ for the annual savings and $(P/F)$ for the salvage.',
    steps: [
      {
        text: 'Set up the present worth equation:',
        latex: 'PW = -45{,}000 + 8{,}000(P/A,\\, 6\\%,\\, 10) + 5{,}000(P/F,\\, 6\\%,\\, 10)'
      },
      {
        text: 'From the 6% factor table at $n = 10$:',
        latex: '(P/A,\\, 6\\%,\\, 10) = 7.3601 \\quad (P/F,\\, 6\\%,\\, 10) = 0.5584'
      },
      {
        text: 'Calculate each component:',
        latex: 'PW = -45{,}000 + 8{,}000 \\times 7.3601 + 5{,}000 \\times 0.5584'
      },
      {
        text: 'Result:',
        latex: 'PW = -45{,}000 + 58{,}881 + 2{,}792 = 16{,}673 \\approx 16{,}700'
      }
    ],
    handbookPage: 'p. 229, Uniform Series Present Worth; Single Payment Present Worth',
    handbookFormula: 'PW = -C_0 + A(P/A,\\, i\\%,\\, n) + S_n(P/F,\\, i\\%,\\, n)',
    videoUrl: null,
    traps: [
      'Forgetting the salvage value — it reduces the net cost of the investment',
      'Treating the initial cost as positive (benefits) instead of negative (cost)'
    ],
    diagram: null,
    lessonId: 'pw-fw-aw-analysis',
    chapterId: 'economics'
  },
  {
    id: 'econ-pfa-ex2',
    type: 'computational',
    statement: 'A county invests 100,000 dollars in a stormwater management system that generates 15,000 dollars in annual savings for 12 years. There is no salvage value. At MARR = 8%, what is the future worth of this investment at the end of year 12?',
    choices: [
      {
        id: 'c1',
        text: '-251,800 dollars'
      },
      {
        id: 'c2',
        text: '80,000 dollars'
      },
      {
        id: 'c3',
        text: '32,800 dollars'
      },
      {
        id: 'c4',
        text: '284,700 dollars'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Future worth pushes everything to the end of the study period. Compound the initial cost forward using $(F/P)$: $100{,}000 \\times (1.08)^{12} = 251{,}817$. Compound the annual savings forward using $(F/A)$: $15{,}000 \\times 18.977 = 284{,}657$. $FW = -251{,}817 + 284{,}657 = 32{,}840$, approximately 32,800. Since $FW > 0$, the project exceeds the 8% MARR. The 80,000 dollars choice just adds up $15{,}000 \\times 12$ and subtracts 100,000 without compounding. The -251,800 dollars choice only compounds the cost forward and forgets the savings. The 284,700 dollars choice only computes the FW of savings and leaves out the cost.',
    hint: 'Compound the initial cost forward with $(F/P)$ and the annual savings forward with $(F/A)$, then combine.',
    steps: [
      {
        text: 'Set up the future worth equation:',
        latex: 'FW = -100{,}000(F/P,\\, 8\\%,\\, 12) + 15{,}000(F/A,\\, 8\\%,\\, 12)'
      },
      {
        text: 'From the 8% factor table at $n = 12$:',
        latex: '(F/P,\\, 8\\%,\\, 12) = (1.08)^{12} = 2.5182 \\quad (F/A,\\, 8\\%,\\, 12) = 18.977'
      },
      {
        text: 'Calculate:',
        latex: 'FW = -100{,}000 \\times 2.5182 + 15{,}000 \\times 18.977'
      },
      {
        text: 'Result:',
        latex: 'FW = -251{,}820 + 284{,}655 = 32{,}835 \\approx 32{,}800'
      }
    ],
    handbookPage: 'p. 229, Single Payment Compound Amount; Uniform Series Compound Amount',
    handbookFormula: 'FW = -C_0(F/P,\\, i\\%,\\, n) + A(F/A,\\, i\\%,\\, n)',
    videoUrl: null,
    traps: [
      'Forgetting to compound the initial cost forward — it must grow at the interest rate just like the savings do',
      'Adding nominal cash flows without compounding (15,000 times 12 minus 100,000 = 80,000) — this ignores the time value of money'
    ],
    diagram: null,
    lessonId: 'pw-fw-aw-analysis',
    chapterId: 'economics'
  },
  {
    id: 'econ-pfa-ex3',
    type: 'conceptual',
    statement: 'A DOT is comparing two pavement strategies. Strategy A has a 15-year life and Strategy B has a 20-year life. An engineer proposes using present worth analysis over a 20-year study period, replacing Strategy A once at year 15. What is the fundamental problem with this approach?',
    choices: [
      {
        id: 'c1',
        text: 'Present worth cannot be used when alternatives have salvage values'
      },
      {
        id: 'c2',
        text: 'The study period must equal the least common multiple of the service lives, which is 60 years — not 20'
      },
      {
        id: 'c3',
        text: 'Present worth analysis is invalid for public-sector projects'
      },
      {
        id: 'c4',
        text: 'Annual worth analysis should be used instead, since it handles unequal lives directly without matching study periods'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'When you use present worth to compare alternatives with different lives, you must compare over the same time horizon. The correct horizon is the least common multiple (LCM) of the lives — for 15 and 20 years, that is 60 years. A 20-year window does not give Strategy A a full second cycle (it would only run 5 years of its second 15-year life). The annual worth choice describes a valid alternative approach (annual worth does handle unequal lives automatically), but the question asks what is wrong with the proposed PW approach, not what method to use instead. The specific flaw is the wrong study period length.',
    hint: 'For PW analysis with unequal lives, the study period must allow each alternative to complete full cycles. What is the LCM of 15 and 20?',
    steps: [
      {
        text: 'Present worth analysis requires equal study periods for a fair comparison.',
        latex: null
      },
      {
        text: 'The LCM of 15 and 20 is 60 years. Over 60 years, Strategy A repeats 4 times and Strategy B repeats 3 times.',
        latex: null
      },
      {
        text: 'A 20-year study period cuts Strategy A short in its second cycle — only 5 of 15 years — making the comparison unfair.',
        latex: null
      },
      {
        text: 'Alternative: use annual worth analysis, which inherently handles unequal lives without needing the LCM.',
        latex: null
      }
    ],
    handbookPage: 'p. 229, Engineering Economics',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking you can just use the longer life as the study period — the LCM ensures both alternatives complete full cycles',
      'Confusing the LCM requirement with the individual service life of the longer alternative'
    ],
    diagram: null,
    lessonId: 'pw-fw-aw-analysis',
    chapterId: 'economics'
  },
  {
    id: 'econ-pfa-ex4',
    type: 'computational',
    statement: 'A contractor is choosing between two air compressors. Compressor A costs 60,000 dollars, has annual operating costs of 12,000 dollars, a salvage value of 8,000 dollars, and a 4-year life. Compressor B costs 90,000 dollars, has annual operating costs of 8,000 dollars, a salvage value of 12,000 dollars, and an 8-year life. At MARR = 10%, which compressor has the lower annual worth of costs?',
    choices: [
      {
        id: 'c1',
        text: 'Compressor A, AW = 29,200 dollars'
      },
      {
        id: 'c2',
        text: 'Compressor A, AW = 27,000 dollars'
      },
      {
        id: 'c3',
        text: 'Compressor B, AW = 23,800 dollars'
      },
      {
        id: 'c4',
        text: 'Compressor B, AW = 19,300 dollars'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'With different service lives (4 vs. 8 years), annual worth is the smart choice — it handles unequal lives automatically. For each compressor, annualize the initial cost using $(A/P)$, add yearly operating costs, and subtract the annual equivalent of salvage using $(A/F)$. Compressor A: $60{,}000 \\times 0.31547 + 12{,}000 - 8{,}000 \\times 0.21547 = 18{,}928 + 12{,}000 - 1{,}724 = 29{,}204$. Compressor B: $90{,}000 \\times 0.18744 + 8{,}000 - 12{,}000 \\times 0.08744 = 16{,}870 + 8{,}000 - 1{,}049 = 23{,}821$. Compressor B wins at about 23,800. The "Compressor A, AW = 27,000" distractor mis-annualizes Compressor A\'s cash flows, and the "Compressor B, AW = 19,300" distractor mishandles Compressor B\'s salvage credit; both still come out higher than the correct Compressor B value of about 23,800.',
    hint: 'Use annual worth to compare directly without matching lifespans. AW = initial cost times $(A/P)$ + annual operating cost - salvage times $(A/F)$.',
    steps: [
      {
        text: 'Compressor A ($n = 4$ years):',
        latex: 'AW_A = 60{,}000(A/P,\\, 10\\%,\\, 4) + 12{,}000 - 8{,}000(A/F,\\, 10\\%,\\, 4)'
      },
      {
        text: 'From the 10% table:',
        latex: '(A/P,\\, 10\\%,\\, 4) = 0.31547 \\quad (A/F,\\, 10\\%,\\, 4) = 0.21547'
      },
      {
        text: 'Calculate:',
        latex: 'AW_A = 18{,}928 + 12{,}000 - 1{,}724 = 29{,}204 \\approx 29{,}200'
      },
      {
        text: 'Compressor B ($n = 8$ years):',
        latex: 'AW_B = 90{,}000(A/P,\\, 10\\%,\\, 8) + 8{,}000 - 12{,}000(A/F,\\, 10\\%,\\, 8)'
      },
      {
        text: 'From the 10% table:',
        latex: '(A/P,\\, 10\\%,\\, 8) = 0.18744 \\quad (A/F,\\, 10\\%,\\, 8) = 0.08744'
      },
      {
        text: 'Calculate:',
        latex: 'AW_B = 16{,}870 + 8{,}000 - 1{,}049 = 23{,}821 \\approx 23{,}800'
      },
      {
        text: 'Compressor B has the lower annual cost (23,800 vs. 29,200). Select Compressor B.',
        latex: null
      }
    ],
    handbookPage: 'p. 229, Capital Recovery (A/P) + Sinking Fund (A/F); p. 236, Factor Table i = 10%',
    handbookFormula: 'AW = C_0(A/P,\\, i\\%,\\, n) + A_{\\text{oper}} - S_n(A/F,\\, i\\%,\\, n)',
    videoUrl: null,
    traps: [
      'Trying to compare present worth directly with different service lives — PW requires matching the study period to the LCM (8 years here, which happens to work, but AW is safer)',
      'Forgetting to subtract the salvage value credit — it reduces the annual cost'
    ],
    diagram: { component: 'AnnualWorthComparison', props: { costX: 60000, omX: 12000, salvX: 8000, nX: 4, labelX: 'Compressor A', costY: 90000, omY: 8000, salvY: 12000, nY: 8, labelY: 'Compressor B', rate: 10 } },
    lessonId: 'pw-fw-aw-analysis',
    chapterId: 'economics'
  },
  {
    id: 'econ-ctb-ex1',
    type: 'computational',
    statement: 'A paving contractor can produce asphalt using two methods. Method A (on-site plant): fixed cost of 8,000 dollars per day plus 5 dollars per ton. Method B (purchased from supplier): fixed cost of 3,000 dollars per day plus 10 dollars per ton. At what daily tonnage do the two methods break even?',
    choices: [
      {
        id: 'c1',
        text: '1,000 tons'
      },
      {
        id: 'c2',
        text: '800 tons'
      },
      {
        id: 'c3',
        text: '1,600 tons'
      },
      {
        id: 'c4',
        text: '500 tons'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Set the two total-cost equations equal and solve for $Q$. Method A: $TC = 8{,}000 + 5Q$. Method B: $TC = 3{,}000 + 10Q$. Setting them equal: $8{,}000 + 5Q = 3{,}000 + 10Q$, so $5{,}000 = 5Q$, and $Q^* = 1{,}000$ tons. Below 1,000 tons/day, Method B (lower fixed cost) is cheaper. Above 1,000 tons/day, Method A (lower variable cost) wins. The 800-ton option likely comes from a subtraction error. The 1,600-ton option doubles the break-even from an algebra slip. The 500-ton option divides 5,000 by 10 instead of 5.',
    hint: 'Write TC = FC + VC times Q for each method, set them equal, and solve for Q.',
    steps: [
      {
        text: 'Write the total cost equations:',
        latex: 'TC_A = 8{,}000 + 5Q \\quad \\text{and} \\quad TC_B = 3{,}000 + 10Q'
      },
      {
        text: 'Set them equal:',
        latex: '8{,}000 + 5Q = 3{,}000 + 10Q'
      },
      {
        text: 'Solve for Q:',
        latex: '8{,}000 - 3{,}000 = 10Q - 5Q \\;\\Rightarrow\\; 5{,}000 = 5Q'
      },
      {
        text: 'Divide:',
        latex: 'Q^* = \\frac{5{,}000}{5} = 1{,}000 \\text{ tons}'
      }
    ],
    handbookPage: 'p. 230, Cost Estimation and Break-Even Analysis',
    handbookFormula: 'Q^* = \\frac{FC_A - FC_B}{VC_B - VC_A}',
    videoUrl: null,
    traps: [
      'Subtracting variable costs in the wrong order and getting a negative quantity',
      'Dividing the fixed-cost difference by just one variable cost instead of the difference'
    ],
    diagram: null,
    lessonId: 'cost-types-breakeven',
    chapterId: 'economics'
  },
  {
    id: 'econ-ctb-ex2',
    type: 'computational',
    statement: 'A city installs energy-efficient LED street lighting at a cost of 250,000 dollars. The new lights save 65,000 dollars per year in electricity but require 15,000 dollars per year in additional maintenance. Using simple payback analysis, what is the payback period?',
    choices: [
      {
        id: 'c1',
        text: '16.7 years'
      },
      {
        id: 'c2',
        text: '3.8 years'
      },
      {
        id: 'c3',
        text: '5.0 years'
      },
      {
        id: 'c4',
        text: '3.1 years'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Simple payback = initial investment divided by net annual savings. The gross savings are 65,000/year, but you have to subtract the new 15,000/year maintenance cost to get the net savings of 50,000/year. Then: $250{,}000 / 50{,}000 = 5.0$ years. The 3.8 years option divides by the gross savings ($250{,}000 / 65{,}000 = 3.85$), ignoring the maintenance cost. The 16.7 years option divides by only the maintenance cost ($250{,}000 / 15{,}000$). The 3.1 years option divides by the sum of savings and maintenance ($65{,}000 + 15{,}000 = 80{,}000$) instead of the difference.',
    hint: 'Net annual savings = gross savings minus new annual costs. Do not use gross savings alone.',
    steps: [
      {
        text: 'Identify the initial investment:',
        latex: 'I = 250{,}000'
      },
      {
        text: 'Calculate net annual savings:',
        latex: 'A_{\\text{net}} = 65{,}000 - 15{,}000 = 50{,}000'
      },
      {
        text: 'Apply the simple payback formula:',
        latex: '\\text{Payback} = \\frac{250{,}000}{50{,}000} = 5.0 \\text{ years}'
      }
    ],
    handbookPage: 'p. 230, Cost Estimation and Payback Analysis',
    handbookFormula: '\\text{Payback Period} = \\frac{\\text{Initial Investment}}{\\text{Annual Net Savings}}',
    videoUrl: null,
    traps: [
      'Using gross savings (65,000) instead of net savings (50,000)',
      'Adding the maintenance cost to the savings instead of subtracting it'
    ],
    diagram: null,
    lessonId: 'cost-types-breakeven',
    chapterId: 'economics'
  },
  {
    id: 'econ-ctb-ex3',
    type: 'computational',
    statement: 'A contractor evaluates two concrete placement methods for a large pour. Method A has a fixed cost of 12,000 dollars per day and a variable cost of 8.50 dollars per cubic yard. Method B has a fixed cost of 20,000 dollars per day and a variable cost of 4.50 dollars per cubic yard. For a day requiring 2,500 cubic yards, what is the total cost of the cheaper method?',
    choices: [
      {
        id: 'c1',
        text: '33,250 dollars'
      },
      {
        id: 'c2',
        text: '32,000 dollars'
      },
      {
        id: 'c3',
        text: '31,250 dollars'
      },
      {
        id: 'c4',
        text: '20,000 dollars'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Compute the total cost for each method at $Q = 2{,}500$ and pick the lower one. Method A: $12{,}000 + 8.50(2{,}500) = 12{,}000 + 21{,}250 = 33{,}250$. Method B: $20{,}000 + 4.50(2{,}500) = 20{,}000 + 11{,}250 = 31{,}250$. Method B is cheaper at 31,250. The break-even quantity is $(20{,}000 - 12{,}000)/(8.50 - 4.50) = 8{,}000/4 = 2{,}000$ cy. Since 2,500 > 2,000, the method with the higher fixed cost but lower variable cost (Method B) wins. The 33,250 option is Method A\'s total cost — not wrong to compute, but it is the more expensive option. The 32,000 option is a rounding error or arithmetic slip. The 20,000 option uses only Method B\'s fixed cost without adding the variable portion.',
    hint: 'Compute TC = FC + VC times Q for both methods at Q = 2,500 and compare.',
    steps: [
      {
        text: 'Total cost for Method A:',
        latex: 'TC_A = 12{,}000 + 8.50(2{,}500) = 12{,}000 + 21{,}250 = 33{,}250'
      },
      {
        text: 'Total cost for Method B:',
        latex: 'TC_B = 20{,}000 + 4.50(2{,}500) = 20{,}000 + 11{,}250 = 31{,}250'
      },
      {
        text: 'Compare: Method B is cheaper at 31,250.',
        latex: null
      },
      {
        text: 'Verify with break-even:',
        latex: 'Q^* = \\frac{20{,}000 - 12{,}000}{8.50 - 4.50} = \\frac{8{,}000}{4.00} = 2{,}000 \\text{ cy}'
      },
      {
        text: 'Since 2,500 > 2,000 the higher-fixed-cost, lower-variable-cost method (B) is cheaper.',
        latex: null
      }
    ],
    handbookPage: 'p. 230, Cost Estimation and Break-Even Analysis',
    handbookFormula: 'TC = FC + VC \\cdot Q',
    videoUrl: null,
    traps: [
      'Selecting Method A because it has the lower fixed cost without computing total cost at the given volume',
      'Forgetting to add the variable cost portion and reporting only the fixed cost'
    ],
    diagram: null,
    lessonId: 'cost-types-breakeven',
    chapterId: 'economics'
  },
  {
    id: 'econ-ctb-ex4',
    type: 'conceptual',
    statement: 'A state DOT spent 1.5 million dollars on geotechnical investigations for a proposed highway interchange. After the investigation, soil conditions prove much worse than expected, increasing estimated construction cost from 20 million dollars to 35 million dollars. A neighboring site with better soil would cost 22 million dollars to build but would require a new 2 million dollar environmental study. In deciding whether to proceed at the original site or move to the neighboring site, how should the 1.5 million dollar geotechnical investigation be treated?',
    choices: [
      {
        id: 'c1',
        text: 'It should be added to the original site cost since the investigation was performed there'
      },
      {
        id: 'c2',
        text: 'It should be subtracted from the new site cost as a credit for work already completed'
      },
      {
        id: 'c3',
        text: 'It should be split proportionally between both options based on their construction costs'
      },
      {
        id: 'c4',
        text: 'It is a sunk cost and should be excluded from the comparison entirely'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'The 1.5 million is already spent and cannot be recovered regardless of which site the DOT chooses. That is the textbook definition of a sunk cost. The correct comparison is: original site at 35 million versus new site at $22{,}000{,}000 + 2{,}000{,}000 = 24{,}000{,}000$. The 1.5 million does not appear in either equation. The "add it to the original site cost" option is the most tempting trap because the investigation "belongs" to the original site physically — but the money is gone either way. The "subtract it as a credit on the new site" option invents a credit mechanism that makes no economic sense. The "split it proportionally between both options" option creates an allocation method that sounds fair but violates the sunk-cost principle. The FE loves to test whether you fall for the emotional pull of wanting to "count" money already spent.',
    hint: 'Can the DOT recover the 1.5 million by choosing one option over the other? If the answer is no, what type of cost is it?',
    steps: [
      {
        text: 'The 1.5 million geotechnical investigation is already completed and paid for. It cannot be recovered regardless of which site is selected.',
        latex: null
      },
      {
        text: 'By definition, a sunk cost is any past expenditure that is irrelevant to future decisions.',
        latex: null
      },
      {
        text: 'The correct forward-looking comparison:',
        latex: '\\text{Original site: } 35{,}000{,}000 \\quad \\text{vs.} \\quad \\text{New site: } 22{,}000{,}000 + 2{,}000{,}000 = 24{,}000{,}000'
      },
      {
        text: 'The 1.5 million does not appear in either option because it is sunk.',
        latex: null
      }
    ],
    handbookPage: 'p. 229, Engineering Economics — Sunk Costs',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Allocating the sunk cost to the original site because the investigation was physically performed there',
      'Feeling that the money should "count" somewhere because it was a large expenditure'
    ],
    diagram: null,
    lessonId: 'cost-types-breakeven',
    chapterId: 'economics'
  },
  {
    id: 'econ-bcd-ex1',
    type: 'computational',
    statement: 'A highway improvement project costs 2,000,000 dollars and provides annual benefits of 350,000 dollars for 10 years. The discount rate is 6%. What is the benefit-cost ratio (B/C)?',
    choices: [
      {
        id: 'c1',
        text: '0.95'
      },
      {
        id: 'c2',
        text: '1.75'
      },
      {
        id: 'c3',
        text: '2.58'
      },
      {
        id: 'c4',
        text: '1.29'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'You need to find the present worth of the annual benefits using the uniform series present worth factor, then divide by the cost. PW of benefits $= 350{,}000 \\times (P/A,\\, 6\\%,\\, 10) = 350{,}000 \\times 7.3601 = 2{,}576{,}035$. $B/C = 2{,}576{,}035 / 2{,}000{,}000 = 1.29$. Common mistake is using the raw total ($350{,}000 \\times 10 = 3{,}500{,}000$) without discounting.',
    hint: 'First convert the annual benefits to a present worth, then divide by the cost.',
    steps: [
      {
        text: 'Find the uniform series present worth factor $(P/A, 6\\%, 10)$:',
        latex: '(P/A, 6\\%, 10) = \\frac{(1.06)^{10} - 1}{0.06(1.06)^{10}} = 7.3601'
      },
      {
        text: 'Present worth of benefits:',
        latex: 'PW_B = 350{,}000 \\times 7.3601 = 2{,}576{,}035'
      },
      {
        text: 'Benefit-cost ratio:',
        latex: 'B/C = \\frac{2{,}576{,}035}{2{,}000{,}000} = 1.29'
      }
    ],
    handbookPage: 'p. 229',
    handbookFormula: 'B/C = \\frac{PW_{\\text{benefits}}}{PW_{\\text{costs}}}',
    videoUrl: null,
    traps: [
      'Using undiscounted total benefits (3,500,000) instead of present worth',
      'Using the wrong interest factor table'
    ],
    diagram: null,
    lessonId: 'benefit-cost-decision-trees',
    chapterId: 'economics'
  },
  {
    id: 'econ-bcd-ex2',
    type: 'conceptual',
    statement: 'A project has a benefit-cost ratio of 0.85. What does this indicate?',
    choices: [
      {
        id: 'c1',
        text: 'The project is economically justified'
      },
      {
        id: 'c2',
        text: 'The project costs exceed the present worth of benefits'
      },
      {
        id: 'c3',
        text: 'The project has a positive net present value'
      },
      {
        id: 'c4',
        text: 'More information is needed to determine feasibility'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'A $B/C$ ratio less than 1.0 means the costs outweigh the benefits. The project is NOT economically justified. A $B/C \\geq 1.0$ means benefits meet or exceed costs. This is the single most important threshold in benefit-cost analysis.',
    hint: 'What does a B/C ratio less than 1.0 mean?',
    steps: [
      {
        text: 'B/C ratio = Present Worth of Benefits / Present Worth of Costs.',
        latex: null
      },
      {
        text: 'B/C = 0.85 means benefits are only 85% of costs.',
        latex: null
      },
      {
        text: 'Since B/C < 1.0, the project is NOT economically justified.',
        latex: null
      }
    ],
    handbookPage: 'p. 229',
    handbookFormula: null,
    videoUrl: null,
    traps: ['Thinking any positive B/C means the project is justified — it must be >= 1.0'],
    diagram: null,
    lessonId: 'benefit-cost-decision-trees',
    chapterId: 'economics'
  },
  {
    id: 'econ-bcd-ex3',
    type: 'computational',
    statement: 'A state DOT is comparing two mutually exclusive interchange projects. Project X has PW of costs = 3,000,000 dollars and PW of benefits = 4,200,000 dollars. Project Y has PW of costs = 5,000,000 dollars and PW of benefits = 6,500,000 dollars. Both have B/C ratios above 1.0. Using incremental B/C analysis, which project should be selected?',
    choices: [
      {
        id: 'c1',
        text: 'Project X — it has the higher B/C ratio (1.40 vs. 1.30)'
      },
      {
        id: 'c2',
        text: 'Either project — both have B/C above 1.0'
      },
      {
        id: 'c3',
        text: 'Project Y — the incremental B/C of moving from X to Y is 1.15'
      },
      {
        id: 'c4',
        text: 'Neither project — incremental analysis is only for independent projects'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Both projects pass on their own ($B/C > 1$), so the question is whether spending the extra 2,000,000 on Project Y is justified. The incremental benefit is $6{,}500{,}000 - 4{,}200{,}000 = 2{,}300{,}000$, and the incremental cost is $5{,}000{,}000 - 3{,}000{,}000 = 2{,}000{,}000$. The incremental $\\Delta B/C = 2{,}300{,}000 / 2{,}000{,}000 = 1.15$, which exceeds 1.0, so the extra investment is worth it. The "Project X \u2014 higher B/C ratio" choice picks Project X because its individual $B/C$ is higher, but that ignores the scale of the investment. The "Either project" choice treats both as equally acceptable, which only works for independent projects.',
    hint: 'Rank alternatives by cost, then check whether the extra investment from X to Y is justified by computing the incremental B/C ratio.',
    steps: [
      {
        text: 'Verify individual B/C ratios:',
        latex: 'B/C_X = \\frac{4{,}200{,}000}{3{,}000{,}000} = 1.40 \\quad B/C_Y = \\frac{6{,}500{,}000}{5{,}000{,}000} = 1.30'
      },
      {
        text: 'Both exceed 1.0, so both are individually justified. Rank by cost: X (lower), Y (higher).',
        latex: null
      },
      {
        text: 'Compute incremental B/C from X to Y:',
        latex: '\\Delta B/C = \\frac{6{,}500{,}000 - 4{,}200{,}000}{5{,}000{,}000 - 3{,}000{,}000} = \\frac{2{,}300{,}000}{2{,}000{,}000} = 1.15'
      },
      {
        text: 'Since 1.15 > 1.0, the additional investment in Project Y is justified. Select Project Y.',
        latex: null
      }
    ],
    handbookPage: 'p. 229, Benefit-Cost Analysis',
    handbookFormula: '\\Delta B/C = \\frac{B_2 - B_1}{C_2 - C_1} \\geq 1',
    videoUrl: null,
    traps: [
      'Selecting the project with the highest individual B/C ratio — incremental analysis is required for mutually exclusive alternatives',
      'Treating mutually exclusive alternatives as independent and accepting both'
    ],
    diagram: null,
    lessonId: 'benefit-cost-decision-trees',
    chapterId: 'economics'
  },
  {
    id: 'econ-bcd-ex4',
    type: 'computational',
    statement: 'A city must decide between repairing or replacing a deteriorating bridge. Repair costs 800,000 dollars now, but there is a 35% probability of needing major rehabilitation costing 1,200,000 dollars in year 10, and a 65% probability of needing only minor work costing 200,000 dollars in year 10. Replacement costs 1,500,000 dollars now with no future costs. Using a discount rate of 6%, what is the expected present worth of costs for the repair option, and which alternative should the city choose?',
    choices: [
      {
        id: 'c1',
        text: 'Repair; expected PW = 1,107,000 dollars'
      },
      {
        id: 'c2',
        text: 'Repair; expected PW = 1,000,000 dollars'
      },
      {
        id: 'c3',
        text: 'Replace; expected PW = 1,500,000 dollars — certainty is preferable'
      },
      {
        id: 'c4',
        text: 'Repair; expected PW = 1,470,000 dollars'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'This is a decision tree problem where the repair path leads to a chance node with two outcomes. You need to discount each future cost back to the present, compute the total PW for each branch, then weight by probability. The major-rehab branch costs $800{,}000 + PW(1{,}200{,}000) = 800{,}000 + 670{,}000 = 1{,}470{,}000$. The minor branch costs $800{,}000 + 112{,}000 = 912{,}000$. The expected PW $= 0.35 \\times 1{,}470{,}000 + 0.65 \\times 912{,}000 = 1{,}107{,}000$, which beats the certain 1,500,000 for replacement. The 1,000,000 dollar option forgets to include the initial 800,000 in the expected value calculation. The Replace option ignores probability and just picks the certain option. The 1,470,000 dollar option uses only the worst-case scenario (100% major rehab) instead of weighting by probability.',
    hint: 'Discount each future cost to the present using $(P/F, 6\\%, 10)$, then weight each repair scenario by its probability to get the expected PW.',
    steps: [
      {
        text: 'Discount future costs to present using $(P/F, 6\\%, 10)$:',
        latex: '(P/F,\\, 6\\%,\\, 10) = (1.06)^{-10} = 0.5584'
      },
      {
        text: 'Repair — major rehab branch (p = 0.35):',
        latex: 'PW = 800{,}000 + 1{,}200{,}000 \\times 0.5584 = 800{,}000 + 670{,}100 = 1{,}470{,}100'
      },
      {
        text: 'Repair — minor work branch (p = 0.65):',
        latex: 'PW = 800{,}000 + 200{,}000 \\times 0.5584 = 800{,}000 + 111{,}700 = 911{,}700'
      },
      {
        text: 'Expected PW of repair:',
        latex: 'E[PW] = 0.35 \\times 1{,}470{,}100 + 0.65 \\times 911{,}700 = 514{,}535 + 592{,}605 = 1{,}107{,}140'
      },
      {
        text: 'Compare: Repair expected PW = 1,107,000 vs. Replacement PW = 1,500,000. Repair minimizes expected cost.',
        latex: null
      }
    ],
    handbookPage: 'p. 229, Single Payment Present Worth; p. 230, Expected Value',
    handbookFormula: 'EV = C_1 \\cdot p_1 + C_2 \\cdot p_2',
    videoUrl: null,
    traps: [
      'Using the worst-case cost (1,470,000) as the expected cost without weighting by probability',
      'Forgetting to discount the year-10 costs back to present before computing the expected value'
    ],
    diagram: null,
    lessonId: 'benefit-cost-decision-trees',
    chapterId: 'economics'
  },
  {
    id: 'econ-dti-ex1',
    type: 'computational',
    statement: 'A construction firm buys a dump truck for 120,000 dollars with an estimated salvage value of 20,000 dollars after 10 years. Using straight-line depreciation, what is the annual depreciation deduction?',
    choices: [
      {
        id: 'c1',
        text: '10,000 dollars per year'
      },
      {
        id: 'c2',
        text: '12,000 dollars per year'
      },
      {
        id: 'c3',
        text: '2,000 dollars per year'
      },
      {
        id: 'c4',
        text: '14,000 dollars per year'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Straight-line depreciation spreads the depreciable amount evenly across the useful life. The depreciable amount is $C - S = 120{,}000 - 20{,}000 = 100{,}000$. Divide by 10 years: $100{,}000/10 = 10{,}000$ per year. The 12,000 option divides the full cost by 10 without subtracting the salvage value — that is the most common trap. The 2,000 option divides only the salvage value by 10. The 14,000 option adds the salvage value to the cost before dividing, which makes no sense.',
    hint: 'Straight-line depreciation subtracts salvage value from the initial cost before dividing by the useful life.',
    steps: [
      {
        text: 'Identify the values: $C = 120{,}000$, $S_n = 20{,}000$, $n = 10$ years.',
        latex: null
      },
      {
        text: 'Apply the straight-line formula:',
        latex: 'D = \\frac{C - S_n}{n} = \\frac{120{,}000 - 20{,}000}{10} = \\frac{100{,}000}{10} = 10{,}000'
      }
    ],
    handbookPage: 'p. 231, Depreciation',
    handbookFormula: 'D_j = \\frac{C - S_n}{n}',
    videoUrl: null,
    traps: [
      'Forgetting to subtract salvage value before dividing (gives 12,000)',
      'Confusing straight-line with MACRS and looking up a table factor'
    ],
    diagram: null,
    lessonId: 'depreciation-taxation-inflation',
    chapterId: 'economics'
  },
  {
    id: 'econ-dti-ex2',
    type: 'computational',
    statement: 'A consulting firm has annual revenue of 500,000 dollars, operating expenses of 350,000 dollars, and a depreciation deduction of 40,000 dollars. If the firm\'s tax rate is 25%, what is the annual income tax owed?',
    choices: [
      {
        id: 'c1',
        text: '37,500 dollars'
      },
      {
        id: 'c2',
        text: '125,000 dollars'
      },
      {
        id: 'c3',
        text: '27,500 dollars'
      },
      {
        id: 'c4',
        text: '10,000 dollars'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Taxable income is revenue minus expenses minus depreciation: $500{,}000 - 350{,}000 - 40{,}000 = 110{,}000$. Then multiply by the tax rate: $0.25 \\times 110{,}000 = 27{,}500$. The 37,500 option ignores the depreciation deduction, computing $0.25 \\times (500{,}000 - 350{,}000) = 0.25 \\times 150{,}000 = 37{,}500$. That is the whole point of depreciation — it reduces taxable income. The 125,000 option applies the tax rate to the full revenue. The 10,000 option computes only the tax shield from depreciation ($0.25 \\times 40{,}000$), which is useful information but not the total tax owed.',
    hint: 'Taxable income = Revenue minus Expenses minus Depreciation. Then multiply by the tax rate.',
    steps: [
      {
        text: 'Calculate taxable income:',
        latex: '\\text{Taxable Income} = 500{,}000 - 350{,}000 - 40{,}000 = 110{,}000'
      },
      {
        text: 'Apply the tax rate:',
        latex: '\\text{Tax} = 0.25 \\times 110{,}000 = 27{,}500'
      },
      {
        text: 'Note: the depreciation saves $t \\times D = 0.25 \\times 40{,}000 = 10{,}000$ in taxes compared to having no depreciation deduction.',
        latex: null
      }
    ],
    handbookPage: 'p. 231, Taxation',
    handbookFormula: '\\text{Tax} = t \\times (\\text{Revenue} - \\text{Expenses} - D)',
    videoUrl: null,
    traps: [
      'Forgetting to subtract depreciation from taxable income (gives 37,500)',
      'Confusing the tax shield (10,000) with the total tax owed (27,500)'
    ],
    diagram: null,
    lessonId: 'depreciation-taxation-inflation',
    chapterId: 'economics'
  },
  {
    id: 'econ-dti-ex3',
    type: 'computational',
    statement: 'An engineer analyzes a 5-year project with cash flows stated in actual (nominal) dollars. The real interest rate is 5% and the general inflation rate is 4%. What is the correct inflation-adjusted discount rate, and what is the single-payment present worth factor $(P/F)$ for year 5 at that rate?',
    choices: [
      {
        id: 'c1',
        text: '9.2% and $(P/F) = 0.567$'
      },
      {
        id: 'c2',
        text: '9.0% and $(P/F) = 0.650$'
      },
      {
        id: 'c3',
        text: '9.2% and $(P/F) = 0.644$'
      },
      {
        id: 'c4',
        text: '5.0% and $(P/F) = 0.784$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Since the cash flows are in actual (nominal) dollars, you must discount at the combined rate $d$, not the real rate. The formula is $d = i + f + if = 0.05 + 0.04 + (0.05)(0.04) = 0.092 = 9.2\\%$. Then $(P/F,\\, 9.2\\%,\\, 5) = (1.092)^{-5}$. Computing: $(1.092)^5 \\approx 1.553$, so $(P/F) = 1/1.553 \\approx 0.644$. The 9.0% choice simply adds $i + f$ without the cross-term. The 9.2%/0.567 choice gets the rate right but computes $(P/F)$ at the wrong $n$ or makes a calculator error. The 5.0% choice uses only the real rate, which would be correct only if cash flows were in constant (real) dollars.',
    hint: 'Actual (nominal) dollars need the combined rate. Do not forget the cross-term $i \\times f$ in the formula.',
    steps: [
      {
        text: 'Since cash flows are in actual (nominal) dollars, use the inflation-adjusted rate.',
        latex: null
      },
      {
        text: 'Apply the combined-rate formula:',
        latex: 'd = i + f + (i \\times f) = 0.05 + 0.04 + (0.05)(0.04) = 0.092 = 9.2\\%'
      },
      {
        text: 'Compute the present worth factor:',
        latex: '(P/F,\\, 9.2\\%,\\, 5) = (1.092)^{-5}'
      },
      {
        text: 'Calculate:',
        latex: '(1.092)^5 \\approx 1.553 \\quad \\Rightarrow \\quad (P/F) = \\frac{1}{1.553} \\approx 0.644'
      },
      {
        text: '5. The 9.0% choice drops the cross-term: $0.05 + 0.04 = 0.09 = 9.0\\%$. The cross-term (0.002) is small but enough to shift the answer.',
        latex: null
      }
    ],
    handbookPage: 'p. 230, Inflation',
    handbookFormula: 'd = i + f + (i \\times f)',
    videoUrl: null,
    traps: [
      'Simply adding the real rate and inflation rate without the cross-term (gives 9.0%)',
      'Using the real interest rate for nominal cash flows (gives 5.0%)'
    ],
    diagram: null,
    lessonId: 'depreciation-taxation-inflation',
    chapterId: 'economics'
  },
  {
    id: 'econ-dti-ex4',
    type: 'conceptual',
    statement: 'A contractor is comparing straight-line depreciation to MACRS depreciation for a new excavator. Which of the following statements correctly describes a key difference between the two methods?',
    choices: [
      {
        id: 'c1',
        text: 'Straight-line depreciation results in higher total depreciation over the asset\'s life than MACRS'
      },
      {
        id: 'c2',
        text: 'MACRS spreads depreciation evenly across all years, while straight-line front-loads it'
      },
      {
        id: 'c3',
        text: 'MACRS applies only to assets with a useful life of 20 years or more'
      },
      {
        id: 'c4',
        text: 'MACRS ignores salvage value and depreciates the full initial cost, while straight-line subtracts salvage value before computing the annual deduction'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'This tests whether you understand the structural differences between the two methods. MACRS uses IRS-defined percentages applied to the full purchase price — salvage value is completely ignored. Straight-line subtracts salvage first and then divides the remainder evenly. The option saying straight-line depreciates more is wrong because total depreciation over the full life is often similar (and MACRS may actually depreciate more since it ignores salvage). The option calling MACRS the even method gets it exactly backwards — MACRS front-loads depreciation into early years, while straight-line is the even method. The option restricting MACRS to 20-year assets is fabricated — MACRS covers 3-, 5-, 7-, 10-, 15-, and 20-year properties.',
    hint: 'Think about how each method handles salvage value and the timing of deductions across the asset life.',
    steps: [
      {
        text: 'Straight-line: $D = (C - S_n)/n$. Salvage value is subtracted. Each year gets the same deduction.',
        latex: null
      },
      {
        text: 'MACRS: $D_j = d_j \\times C$. Salvage value is ignored. Early years get larger deductions (front-loaded).',
        latex: null
      },
      {
        text: 'Choice A is incorrect because MACRS depreciates the full cost (no salvage subtraction), so total MACRS depreciation often equals or exceeds total straight-line depreciation.',
        latex: null
      },
      {
        text: 'Choice B reverses the two methods — MACRS front-loads, straight-line is uniform.',
        latex: null
      },
      {
        text: 'Choice C is fabricated — the MACRS table on p. 231 covers 3-, 5-, 7-, and 10-year recovery periods (among others).',
        latex: null
      }
    ],
    handbookPage: 'p. 231, MACRS and Straight-Line Depreciation',
    handbookFormula: 'D_j = d_j \\times C \\quad \\text{(MACRS)} \\qquad D_j = \\frac{C - S_n}{n} \\quad \\text{(SL)}',
    videoUrl: null,
    traps: [
      'Thinking MACRS also subtracts salvage value — it does not',
      'Confusing which method front-loads depreciation and which one is uniform'
    ],
    diagram: null,
    lessonId: 'depreciation-taxation-inflation',
    chapterId: 'economics'
  },
  {
    id: 'econ-ror-ex1',
    type: 'computational',
    statement: 'An investment of 5,000 dollars today returns a single payment of 5,600 dollars one year later. What is the internal rate of return?',
    choices: [
      { id: 'c1', text: '$12\\%$' },
      { id: 'c2', text: '$10.7\\%$' },
      { id: 'c3', text: '$11.2\\%$' },
      { id: 'c4', text: '$6\\%$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Set PW to zero: 5,000 = 5,600/(1 + i), so 1 + i = 5,600/5,000 = 1.12 and i = 12%. The 10.7% choice divides the 600 gain by 5,600 (future value). The 11.2% choice divides 600 by an averaged base. The 6% choice halves the correct rate.',
    hint: 'Set 5,000 = 5,600/(1 + i) and solve for i.',
    steps: [
      { text: 'Break-even:', latex: '5{,}000 = \\frac{5{,}600}{1+i}' },
      { text: 'Solve:', latex: '1+i = 1.12 \\Rightarrow i = 12\\%' },
    ],
    handbookPage: 'p. 229',
    handbookFormula: 'P = F/(1+i)^n',
    videoUrl: null,
    traps: ['Dividing the gain by the future value', 'Forgetting IRR is the rate making NPW = 0'],
    diagram: { component: 'CashFlowIRR', props: {} },
    lessonId: 'rate-of-return',
    chapterId: 'economics'
  },
];

export default PROBLEMS;
