// Exam bank: construction
// Auto-extracted from lesson files — 28 questions

const PROBLEMS = [
  {
    id: 'con-cf-ex1',
    type: 'conceptual',
    statement: 'In a CPM network using Activity-on-Node (AON) notation, what do the arrows between boxes represent?',
    choices: [
      {
        id: 'c1',
        text: 'Activities (work items)'
      },
      {
        id: 'c2',
        text: 'Dependency relationships between activities'
      },
      {
        id: 'c3',
        text: 'Resource assignments'
      },
      {
        id: 'c4',
        text: 'Time duration of each task'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'In AON notation, the boxes (nodes) represent activities. The arrows between boxes show logical dependencies — which activity must come before another. This is the opposite of Activity-on-Arrow (AOA), where the arrows represent the activities themselves. Resource assignments and durations are shown inside the nodes, not on the arrows.',
    hint: 'In AON, nodes are activities. What role do the connecting arrows serve?',
    steps: [
      {
        text: 'AON = Activity-on-Node. Nodes (boxes) = activities.',
        latex: null
      },
      {
        text: 'Arrows connect nodes and represent dependency (precedence) relationships.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing AON with AOA — in AOA the arrows ARE the activities, but in AON the arrows are dependencies'
    ],
    diagram: null,
    lessonId: 'cpm-fundamentals',
    chapterId: 'construction'
  },
  {
    id: 'con-cf-ex2',
    type: 'conceptual',
    statement: 'Activity B has a Start-to-Start (SS) relationship with Activity A. Activity A starts on day 4. Activity B has a duration of 6 days. Which statement is correct?',
    choices: [
      {
        id: 'c1',
        text: 'B can start no earlier than day 4 (when A starts)'
      },
      {
        id: 'c2',
        text: 'B can start only after A finishes'
      },
      {
        id: 'c3',
        text: 'B must finish at the same time as A'
      },
      {
        id: 'c4',
        text: 'B and A must have the same duration'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Start-to-Start means B cannot start until A starts. Since A starts on day 4, B can start no earlier than day 4. SS does not mean they finish together (that would be Finish-to-Finish). It does not mean B waits for A to finish (that would be Finish-to-Start). And SS has nothing to do with matching durations — B can be longer or shorter than A.',
    hint: 'SS means the successor cannot start until the predecessor starts. It does not constrain the finish.',
    steps: [
      {
        text: 'Start-to-Start (SS): B cannot begin until A begins.',
        latex: null
      },
      {
        text: 'A starts day 4, so B can start on day 4 or later.',
        latex: null
      },
      {
        text: 'SS does not require matching finish times or durations.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing SS with FS — FS requires the predecessor to finish, SS only requires it to start',
      'Assuming SS means both activities finish together'
    ],
    diagram: null,
    lessonId: 'cpm-fundamentals',
    chapterId: 'construction'
  },
  {
    id: 'con-cf-ex3',
    type: 'computational',
    statement: 'A project has three independent paths from start to finish. Path X: A (5 days) then B (7 days). Path Y: C (4 days) then D (6 days) then E (3 days). Path Z: F (8 days) then G (2 days). What is the minimum project duration?',
    choices: [
      {
        id: 'c1',
        text: '$10$ days'
      },
      {
        id: 'c2',
        text: '$12$ days'
      },
      {
        id: 'c3',
        text: '$13$ days'
      },
      {
        id: 'c4',
        text: '$35$ days'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The project duration equals the longest path. Path X = 5 + 7 = 12 days. Path Y = 4 + 6 + 3 = 13 days. Path Z = 8 + 2 = 10 days. The longest is Path Y at 13 days, so the project takes at least 13 days. The 12-day choice used Path X. The 10-day choice used Path Z. The 35-day choice added all three paths, but independent paths run in parallel.',
    hint: 'Independent paths run simultaneously. The project finishes when the longest path finishes.',
    steps: [
      {
        text: 'Path X: $5 + 7 = 12$ days',
        latex: null
      },
      {
        text: 'Path Y: $4 + 6 + 3 = 13$ days',
        latex: null
      },
      {
        text: 'Path Z: $8 + 2 = 10$ days',
        latex: null
      },
      {
        text: 'Project duration = longest path:',
        latex: '\\max(12, 13, 10) = 13 \\text{ days}'
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'EF = ES + D',
    videoUrl: null,
    traps: [
      'Summing all paths (35 days) instead of taking the longest — parallel paths overlap',
      'Choosing the shortest path instead of the longest'
    ],
    diagram: null,
    lessonId: 'cpm-fundamentals',
    chapterId: 'construction'
  },
  {
    id: 'con-cf-ex4',
    type: 'conceptual',
    statement: 'A CPM schedule shows that Activity H has three predecessors with a Finish-to-Start relationship. Predecessor P1 finishes on day 10, P2 finishes on day 14, and P3 finishes on day 8. The scheduler incorrectly sets the early start of H to day 10. What error did the scheduler make?',
    choices: [
      {
        id: 'c1',
        text: 'Used the first predecessor to finish instead of the last'
      },
      {
        id: 'c2',
        text: 'Used the average of the three predecessor finish times'
      },
      {
        id: 'c3',
        text: 'Ignored the Finish-to-Start constraint entirely'
      },
      {
        id: 'c4',
        text: 'Used the correct forward pass logic'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'With multiple FS predecessors, the early start of the successor is the MAXIMUM of all predecessor early finishes. H should start at max(10, 14, 8) = day 14. The scheduler used day 10 (P1\'s finish), which means they picked one predecessor instead of taking the maximum. H cannot start until ALL predecessors finish, so it must wait for the last one (P2 at day 14). The \'average of the three predecessor finish times\' choice would give day 10.67. The \'ignored the Finish-to-Start constraint\' choice would mean ignoring dependencies entirely. The \'correct forward pass logic\' choice is wrong because day 10 is incorrect.',
    hint: 'Forward pass rule: ES = max(EF of all predecessors). Which predecessor finishes last?',
    steps: [
      {
        text: 'Predecessor EFs: P1 = 10, P2 = 14, P3 = 8.',
        latex: null
      },
      {
        text: 'Correct ES for H:',
        latex: 'ES_H = \\max(10, 14, 8) = 14'
      },
      {
        text: 'Scheduler used day 10, ignoring that P2 finishes later. H cannot start until ALL predecessors are done.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'ES = \\text{max}(EF_{\\text{pred}})',
    videoUrl: null,
    traps: [
      'Taking the minimum or first predecessor EF instead of the maximum',
      'Averaging predecessor finish dates — the forward pass uses MAX, not average'
    ],
    diagram: null,
    lessonId: 'cpm-fundamentals',
    chapterId: 'construction'
  },
  {
    id: 'con-fbp-ex1',
    type: 'conceptual',
    statement: 'During the backward pass of a CPM network, an activity feeds two successors with late starts of day 12 and day 9. What is the late finish of the activity?',
    choices: [
      {
        id: 'c1',
        text: 'Day $9$'
      },
      {
        id: 'c2',
        text: 'Day $12$'
      },
      {
        id: 'c3',
        text: 'Day $10.5$'
      },
      {
        id: 'c4',
        text: 'Day $21$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'The backward pass uses MIN of successor late starts. The activity must finish in time for the tightest (earliest) successor. $\\min(12, 9) = 9$. The Day 12 option used MAX instead of MIN, which would allow the activity to miss the day-9 successor deadline. The Day 10.5 option averaged the two values. The Day 21 option summed them.',
    hint: 'Backward pass rule: LF = MIN of all successor late starts.',
    steps: [
      {
        text: 'Activity feeds two successors: $LS_1 = 12$, $LS_2 = 9$.',
        latex: null
      },
      {
        text: 'Late finish:',
        latex: 'LF = \\min(LS_1, LS_2) = \\min(12, 9) = 9'
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'LF = \\min(LS \\text{ of all successors})',
    videoUrl: null,
    traps: [
      'Using MAX instead of MIN on the backward pass — the activity must finish before its tightest successor'
    ],
    diagram: null,
    lessonId: 'forward-backward-pass',
    chapterId: 'construction'
  },
  {
    id: 'con-fbp-ex2',
    type: 'conceptual',
    statement: 'An engineer completes the forward pass on a 20-day project. Activity J has $ES = 8$ and $EF = 13$. After the backward pass, $LS = 8$ and $LF = 13$. Which statement is correct about Activity J?',
    choices: [
      {
        id: 'c1',
        text: 'Activity J has 5 days of total float'
      },
      {
        id: 'c2',
        text: 'Activity J is on the critical path'
      },
      {
        id: 'c3',
        text: 'Activity J can be delayed without affecting the project'
      },
      {
        id: 'c4',
        text: 'Activity J has free float but no total float'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Total float $= LS - ES = 8 - 8 = 0$. An activity with zero total float is on the critical path. Any delay to J will push the project end date. The "5 days of total float" choice is wrong because 5 is the duration ($EF - ES = 13 - 8 = 5$), not the float. The "can be delayed without affecting the project" choice is wrong because zero float means NO room for delay. The "free float but no total float" choice is contradictory — free float cannot exceed total float, and if $TF = 0$ then $FF = 0$ too.',
    hint: 'Compare ES to LS (or EF to LF). If they are equal, what does that tell you about float?',
    steps: [
      {
        text: 'Total float:',
        latex: 'TF = LS - ES = 8 - 8 = 0'
      },
      {
        text: 'TF = 0 means Activity J is on the critical path.',
        latex: null
      },
      {
        text: 'Any delay to J directly delays the project completion date.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: '\\text{Float} = LS - ES = LF - EF',
    videoUrl: null,
    traps: [
      'Confusing duration (EF - ES = 5) with float (LS - ES = 0)',
      'Thinking an activity can be delayed when its total float is zero'
    ],
    diagram: null,
    lessonId: 'forward-backward-pass',
    chapterId: 'construction'
  },
  {
    id: 'con-fbp-ex3',
    type: 'computational',
    statement: 'Network: A (duration 4, no predecessors), B (duration 3, predecessor A), C (duration 5, predecessor A), D (duration 2, predecessors B and C). The project duration is $11$ days. What is the late start of Activity B?',
    choices: [
      {
        id: 'c1',
        text: 'Day $7$'
      },
      {
        id: 'c2',
        text: 'Day $4$'
      },
      {
        id: 'c3',
        text: 'Day $6$'
      },
      {
        id: 'c4',
        text: 'Day $9$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Forward pass: A(0,4), B(4,7), C(4,9), D(9,11). Backward pass from $LF = 11$: D(9,11), then B and C feed D so their $LF = LS_D = 9$. For B: $LF_B = 9$, $LS_B = 9 - 3 = 6$. For C: $LF_C = 9$, $LS_C = 9 - 5 = 4$. Day 4 is the $ES$ of B (or the $LS$ of C), not the $LS$ of B. Day 7 is the $EF$ of B. Day 9 is the $LF$ of B, not $LS$.',
    hint: 'Run the backward pass: start at the project end, work right to left. LS = LF - Duration.',
    steps: [
      {
        text: 'Forward pass: A(0,4), B(4,7), C(4,9), D(9,11).',
        latex: null
      },
      {
        text: 'Backward pass: $LF_D = 11$, $LS_D = 9$.',
        latex: null
      },
      {
        text: 'B feeds only D: $LF_B = LS_D = 9$.',
        latex: null
      },
      {
        text: 'Late start of B:',
        latex: 'LS_B = LF_B - D_B = 9 - 3 = 6'
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'LS = LF - D',
    videoUrl: null,
    traps: [
      'Reporting ES (4) instead of LS (6) — the question asks for the backward pass value',
      'Reporting LF (9) instead of LS (6) — do not forget to subtract the duration'
    ],
    diagram: {
      component: 'CpmNetwork',
      props: {
        variant: 'diamond4',
        durations: {
          A: 4,
          B: 3,
          C: 5,
          D: 2
        }
      }
    },
    lessonId: 'forward-backward-pass',
    chapterId: 'construction'
  },
  {
    id: 'con-fbp-ex4',
    type: 'conceptual',
    statement: 'A junior engineer runs the backward pass using MAX of successor late starts instead of MIN. Compared to the correct backward pass, what effect does this error have on the computed total float values?',
    choices: [
      {
        id: 'c1',
        text: 'Total float will be overstated for non-critical activities'
      },
      {
        id: 'c2',
        text: 'Total float will be understated for non-critical activities'
      },
      {
        id: 'c3',
        text: 'Total float will be correct because the error cancels out'
      },
      {
        id: 'c4',
        text: 'Only free float is affected; total float is unchanged'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Using MAX instead of MIN on the backward pass gives each activity a LATER late finish than it should have. A later $LF$ means a later $LS$, which inflates $TF = LS - ES$. The engineer would conclude that activities have more slack than they actually do. This is dangerous because delaying an activity within its "computed" float could actually push the project end date. The correct backward pass uses MIN to find the tightest successor constraint.',
    hint: 'If LF is too large (from using MAX instead of MIN), what happens to LS and therefore to total float?',
    steps: [
      {
        text: 'Correct: $LF = \\min(LS_{\\text{successors}})$.',
        latex: null
      },
      {
        text: 'Error: $LF = \\max(LS_{\\text{successors}})$, which gives a later LF.',
        latex: null
      },
      {
        text: 'Later LF leads to later LS.',
        latex: null
      },
      {
        text: 'TF = LS - ES becomes larger than the true value, overstating float.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'LF = \\min(LS \\text{ of all successors})',
    videoUrl: null,
    traps: [
      'Thinking the error understates float — using MAX gives a later deadline, which INCREASES apparent slack',
      'Assuming errors in the backward pass do not affect total float calculations'
    ],
    diagram: null,
    lessonId: 'forward-backward-pass',
    chapterId: 'construction'
  },
  {
    id: 'con-fcp-ex1',
    type: 'conceptual',
    statement: 'An activity has a total float of 4 days and a free float of 0 days. If the activity is delayed by 2 days, which statement is correct?',
    choices: [
      {
        id: 'c1',
        text: 'The project end date is unaffected, but at least one successor\'s early start will be delayed'
      },
      {
        id: 'c2',
        text: 'Both the project end date and all successor early starts are unaffected'
      },
      {
        id: 'c3',
        text: 'The project end date will be pushed back by 2 days'
      },
      {
        id: 'c4',
        text: 'The delay has no effect because the activity is not on the critical path'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Total float of 4 means the activity can slip 4 days without delaying the project. A 2-day delay is within that limit, so the project end date is safe. However, free float of 0 means ANY delay pushes at least one immediate successor. So the successor\'s early start shifts by 2 days, even though the project finish does not. The option saying both end date and successor early starts are unaffected ignores free float = 0. The option saying the project end date is pushed back by 2 days is wrong because the delay is within total float. The option saying the delay has no effect because the activity is not on the critical path oversimplifies — non-critical does not mean no consequences.',
    hint: 'Total float protects the project end. Free float protects the successor. What happens when FF = 0?',
    steps: [
      {
        text: 'Delay = 2 days, TF = 4 days. Since 2 < 4, the project end date is not affected.',
        latex: null
      },
      {
        text: 'FF = 0 days. Any delay (even 1 day) will push the immediate successor\'s early start.',
        latex: null
      },
      {
        text: 'Result: project safe, but successor delayed by 2 days.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: '\\text{Float} = LS - ES = LF - EF',
    videoUrl: null,
    traps: [
      'Assuming non-critical activities can be freely delayed without any consequence — free float determines successor impact'
    ],
    diagram: null,
    lessonId: 'float-critical-path',
    chapterId: 'construction'
  },
  {
    id: 'con-fcp-ex2',
    type: 'computational',
    statement: 'A project network has three paths: Path 1 = 22 days, Path 2 = 18 days, Path 3 = 22 days. How many critical paths does the project have, and what is the total float of activities exclusively on Path 2?',
    choices: [
      {
        id: 'c1',
        text: 'One critical path; activities only on Path 2 have 4 days of total float'
      },
      {
        id: 'c2',
        text: 'Two critical paths; activities only on Path 2 have 4 days of total float'
      },
      {
        id: 'c3',
        text: 'Three critical paths; all activities have 0 total float'
      },
      {
        id: 'c4',
        text: 'Two critical paths; activities only on Path 2 have 0 total float'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The critical path is the longest path through the network. Both Path 1 and Path 3 are 22 days, so there are TWO critical paths. A project can have more than one critical path when paths tie for the longest duration. Activities only on Path 2 (18 days) have total float $= 22 - 18 = 4$ days. The "one critical path" choice misses the tie. The "three critical paths" choice is wrong because Path 2 is shorter. The "two critical paths with zero float on Path 2" choice is wrong because Path 2 activities do have float.',
    hint: 'Can a project have more than one critical path? What happens when two paths tie?',
    steps: [
      {
        text: 'Longest path duration: $\\max(22, 18, 22) = 22$ days.',
        latex: null
      },
      {
        text: 'Path 1 and Path 3 are both 22 days — two critical paths.',
        latex: null
      },
      {
        text: 'Path 2 total float:',
        latex: '22 - 18 = 4 \\text{ days}'
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: '\\text{Float} = LS - ES = LF - EF',
    videoUrl: null,
    traps: [
      'Assuming only one critical path can exist — tied paths are all critical',
      'Giving Path 2 activities zero float even though their path is 4 days shorter'
    ],
    diagram: null,
    lessonId: 'float-critical-path',
    chapterId: 'construction'
  },
  {
    id: 'con-fcp-ex3',
    type: 'conceptual',
    statement: 'A project manager wants to shorten the overall schedule by 3 days. The critical path is A-B-D-F (24 days), and the near-critical path is A-C-E-F (22 days). If the manager reduces Activity D by 3 days, what is the new project duration?',
    choices: [
      {
        id: 'c1',
        text: '24 days'
      },
      {
        id: 'c2',
        text: '21 days'
      },
      {
        id: 'c3',
        text: '22 days'
      },
      {
        id: 'c4',
        text: '23 days'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Reducing D by 3 days shortens the critical path from 24 to 21 days. But the near-critical path A-C-E-F is 22 days and was not changed. The project duration is the LONGEST path, so the new duration $= \\max(21, 22) = 22$ days. The near-critical path becomes the new critical path. You cannot crash below the next-longest path without also shortening it. The 21-days choice forgot the near-critical path. The 24-days choice ignored the crash entirely. The 23-days choice subtracted only 1 day.',
    hint: 'After crashing the critical path, check whether another path has become the new bottleneck.',
    steps: [
      {
        text: 'Original critical path A-B-D-F: 24 days. Reduce D by 3: 24 - 3 = 21 days.',
        latex: null
      },
      {
        text: 'Near-critical path A-C-E-F: 22 days (unchanged).',
        latex: null
      },
      {
        text: 'New project duration:',
        latex: '\\max(21, 22) = 22 \\text{ days}'
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Only checking the crashed path and ignoring near-critical paths',
      'Assuming the full 3-day reduction applies to the project — it is limited by the next-longest path'
    ],
    diagram: null,
    lessonId: 'float-critical-path',
    chapterId: 'construction'
  },
  {
    id: 'con-fcp-ex4',
    type: 'conceptual',
    statement: 'Activity M has $ES = 5$, $EF = 9$, $LS = 5$, $LF = 9$. Activity N has $ES = 5$, $EF = 8$, $LS = 6$, $LF = 9$. Both feed Activity P. What is the free float of Activity N?',
    choices: [
      {
        id: 'c1',
        text: '1 day'
      },
      {
        id: 'c2',
        text: '0 days'
      },
      {
        id: 'c3',
        text: '4 days'
      },
      {
        id: 'c4',
        text: '3 days'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Free float = $\\min(ES_{\\text{successors}}) - EF$ of the activity. Both M and N feed P. First find ES of P: since M and N both feed P (FS), $ES_P = \\max(EF_M, EF_N) = \\max(9, 8) = 9$. Free float of N $= ES_P - EF_N = 9 - 8 = 1$ day. N can slip 1 day without pushing P. Total float of N $= LS - ES = 6 - 5 = 1$ day. Here $FF = TF = 1$. The "0 days" option would be N\'s free float if M did not control P\'s start. The "4 days" option does not correspond to any quantity here. The "3 days" option is $EF_N - ES_N$ (N\'s duration), not a float formula.',
    hint: 'Free float = (earliest successor ES) - (your EF). First determine what controls the successor\'s ES.',
    steps: [
      {
        text: 'M and N both feed P. $EF_M = 9$, $EF_N = 8$.',
        latex: null
      },
      {
        text: 'ES of P:',
        latex: 'ES_P = \\max(9, 8) = 9'
      },
      {
        text: 'Free float of N:',
        latex: 'FF_N = ES_P - EF_N = 9 - 8 = 1 \\text{ day}'
      },
      {
        text: 'Verify: $FF_N = 1 \\leq TF_N = 1$ \\checkmark',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'FF = \\min(ES_j) - EF_i',
    videoUrl: null,
    traps: [
      'Forgetting to compute ES of the successor from ALL predecessors before finding free float',
      'Confusing total float with free float — they can differ when multiple predecessors feed the same successor'
    ],
    diagram: null,
    lessonId: 'float-critical-path',
    chapterId: 'construction'
  },
  {
    id: 'con-eva-ex1',
    type: 'conceptual',
    statement: 'A project reports $BCWP > BCWS$ and $BCWP > ACWP$. Which statement best describes the project status?',
    choices: [
      {
        id: 'c1',
        text: 'Ahead of schedule and under budget'
      },
      {
        id: 'c2',
        text: 'Behind schedule and over budget'
      },
      {
        id: 'c3',
        text: 'Ahead of schedule and over budget'
      },
      {
        id: 'c4',
        text: 'Behind schedule and under budget'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$SV = BCWP - BCWS$. If $BCWP > BCWS$ then $SV > 0$, meaning ahead of schedule. $CV = BCWP - ACWP$. If $BCWP > ACWP$ then $CV > 0$, meaning under budget. The project has earned more value than planned (ahead) and spent less than that value (under budget). This is the best possible scenario. The "behind schedule and over budget" choice has both signs reversed. The other two distractors each get one measure wrong.',
    hint: 'Positive SV = ahead of schedule. Positive CV = under budget. Check which values BCWP exceeds.',
    steps: [
      {
        text: '$BCWP > BCWS \\Rightarrow SV = BCWP - BCWS > 0$ (ahead of schedule).',
        latex: null
      },
      {
        text: '$BCWP > ACWP \\Rightarrow CV = BCWP - ACWP > 0$ (under budget).',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'CV = BCWP - ACWP,\\quad SV = BCWP - BCWS',
    videoUrl: null,
    traps: [
      'Reversing the sign interpretation — positive variance is favorable in earned value analysis'
    ],
    diagram: null,
    lessonId: 'earned-value-analysis',
    chapterId: 'construction'
  },
  {
    id: 'con-eva-ex2',
    type: 'computational',
    statement: 'At month 4 of a highway project: planned value (BCWS) = 800,000, earned value (BCWP) = 720,000, actual cost (ACWP) = 760,000. What are the cost variance and schedule variance?',
    choices: [
      {
        id: 'c1',
        text: '$CV = -80{,}000$; $SV = -40{,}000$'
      },
      {
        id: 'c2',
        text: '$CV = -40{,}000$; $SV = -80{,}000$'
      },
      {
        id: 'c3',
        text: '$CV = +40{,}000$; $SV = +80{,}000$'
      },
      {
        id: 'c4',
        text: '$CV = -40{,}000$; $SV = +80{,}000$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$CV = BCWP - ACWP = 720{,}000 - 760{,}000 = -40{,}000$ (over budget). $SV = BCWP - BCWS = 720{,}000 - 800{,}000 = -80{,}000$ (behind schedule). Both are negative, meaning the project is both over budget and behind schedule. The choice with CV = -80,000; SV = -40,000 swaps the two variance values. The choice with CV = +40,000; SV = +80,000 flips both signs. The choice with CV = -40,000; SV = +80,000 gets CV right but SV wrong.',
    hint: 'CV = Earned - Actual. SV = Earned - Planned. BCWP appears in both formulas.',
    steps: [
      {
        text: 'Cost variance:',
        latex: 'CV = BCWP - ACWP = 720{,}000 - 760{,}000 = -40{,}000'
      },
      {
        text: 'Schedule variance:',
        latex: 'SV = BCWP - BCWS = 720{,}000 - 800{,}000 = -80{,}000'
      },
      {
        text: 'Both negative: over budget and behind schedule.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'CV = BCWP - ACWP,\\quad SV = BCWP - BCWS',
    videoUrl: null,
    traps: [
      'Swapping the CV and SV formulas — CV uses ACWP, SV uses BCWS',
      'Subtracting in the wrong order (ACWP - BCWP)'
    ],
    diagram: null,
    lessonId: 'earned-value-analysis',
    chapterId: 'construction'
  },
  {
    id: 'con-eva-ex3',
    type: 'conceptual',
    statement: 'Schedule variance (SV) in earned value analysis is measured in which unit?',
    choices: [
      {
        id: 'c1',
        text: 'Percent complete'
      },
      {
        id: 'c2',
        text: 'Days'
      },
      {
        id: 'c3',
        text: 'Dollars (or the project currency)'
      },
      {
        id: 'c4',
        text: 'Work hours'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Even though it is called "schedule" variance, SV = BCWP - BCWS. Both BCWP and BCWS are dollar amounts (budgeted costs), so SV is in dollars. It tells you how much value you are ahead or behind, not how many days. A negative SV means you earned less dollar-value of work than planned. To express schedule performance in time units, you would need a separate time-based analysis. This is a classic FE trick question.',
    hint: 'Look at the formula: SV = BCWP - BCWS. What units are BCWP and BCWS measured in?',
    steps: [
      {
        text: 'SV = BCWP - BCWS. Both are budgeted costs measured in dollars.',
        latex: null
      },
      {
        text: 'Therefore SV is also in dollars, despite the name "schedule" variance.',
        latex: null
      },
      {
        text: 'SV does not directly give days behind or ahead.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'SV = BCWP - BCWS',
    videoUrl: null,
    traps: [
      'Assuming schedule variance is in days because it has "schedule" in the name',
      'Confusing SV (dollars) with schedule delay analysis (days)'
    ],
    diagram: null,
    lessonId: 'earned-value-analysis',
    chapterId: 'construction'
  },
  {
    id: 'con-eva-ex4',
    type: 'conceptual',
    statement: 'A project has $BCWS = 500{,}000$, $BCWP = 500{,}000$, and $ACWP = 600{,}000$. The project manager claims the project is on track because the schedule variance is zero. What is the flaw in this assessment?',
    choices: [
      {
        id: 'c1',
        text: 'SV = 0 only means the project is on schedule; the project is 100,000 over budget (CV = -100,000)'
      },
      {
        id: 'c2',
        text: 'SV = 0 means the project is both on schedule and on budget'
      },
      {
        id: 'c3',
        text: 'The project is ahead of schedule because ACWP exceeds BCWS'
      },
      {
        id: 'c4',
        text: 'SV cannot be zero unless CV is also zero'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: '$SV = BCWP - BCWS = 500{,}000 - 500{,}000 = 0$, so the project IS on schedule. But $CV = BCWP - ACWP = 500{,}000 - 600{,}000 = -100{,}000$, meaning the project is 100,000 over budget. The PM only checked schedule and ignored cost. SV and CV are independent measures — one can be favorable while the other is unfavorable. The choice claiming SV = 0 means on schedule and on budget is wrong because it assumes SV = 0 means everything is fine. The choice claiming the project is ahead of schedule misuses ACWP for schedule assessment. The choice claiming SV cannot be zero unless CV is also zero is wrong because SV and CV are independent.',
    hint: 'SV and CV are independent. Can a project be on schedule but over budget?',
    steps: [
      {
        text: 'Schedule:',
        latex: 'SV = BCWP - BCWS = 500{,}000 - 500{,}000 = 0 \\text{ (on schedule)}'
      },
      {
        text: 'Cost:',
        latex: 'CV = BCWP - ACWP = 500{,}000 - 600{,}000 = -100{,}000 \\text{ (over budget)}'
      },
      {
        text: 'The PM\'s flaw: ignoring the cost dimension. SV = 0 does not mean the project is healthy overall.',
        latex: null
      }
    ],
    handbookPage: 'p. 310',
    handbookFormula: 'CV = BCWP - ACWP,\\quad SV = BCWP - BCWS',
    videoUrl: null,
    traps: [
      'Assuming SV = 0 means the entire project is on track — cost and schedule are independent',
      'Using ACWP to assess schedule performance — ACWP is only used for cost variance'
    ],
    diagram: null,
    lessonId: 'earned-value-analysis',
    chapterId: 'construction'
  },
  {
    id: 'con-pf-ex1',
    type: 'conceptual',
    statement: 'A project has a Cost Performance Index (CPI) of 1.12. Which interpretation is correct?',
    choices: [
      {
        id: 'c1',
        text: 'The project is under budget — for every dollar spent, 1.12 of value is earned'
      },
      {
        id: 'c2',
        text: 'The project is over budget by 12 percent'
      },
      {
        id: 'c3',
        text: 'The project is 12 percent behind schedule'
      },
      {
        id: 'c4',
        text: 'The project will finish 1.12 times over the original budget'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$CPI = BCWP / ACWP$. A CPI of 1.12 means for every dollar of actual cost, the project earns 1.12 of budgeted value. $CPI > 1.0$ = under budget (getting more value per dollar spent). The "over budget by 12 percent" choice reverses the interpretation — over budget would be $CPI < 1.0$. The "behind schedule" choice confuses CPI (cost) with SPI (schedule). The "1.12 times over the original budget" choice misinterprets the index as a multiplier on total cost.',
    hint: 'CPI > 1.0 means you earn more than you spend. Is that good or bad for the budget?',
    steps: [
      {
        text: 'CPI = 1.12 > 1.0.',
        latex: null
      },
      {
        text: 'CPI > 1.0 means earned value exceeds actual cost — the project is under budget.',
        latex: null
      },
      {
        text: 'Each dollar spent produces 1.12 worth of budgeted work.',
        latex: null
      }
    ],
    handbookPage: 'p. 311',
    handbookFormula: 'CPI = \\frac{BCWP}{ACWP}',
    videoUrl: null,
    traps: ['Reversing the CPI interpretation — CPI > 1.0 is under budget, not over budget'],
    diagram: null,
    lessonId: 'project-forecasting',
    chapterId: 'construction'
  },
  {
    id: 'con-pf-ex2',
    type: 'computational',
    statement: 'A project has $BAC = 1{,}500{,}000$, $BCWP = 900{,}000$, $ACWP = 1{,}000{,}000$. Assuming the current cost performance trend continues, what is the Estimate at Completion (EAC)?',
    choices: [
      {
        id: 'c1',
        text: '1,600,000'
      },
      {
        id: 'c2',
        text: '1,666,667'
      },
      {
        id: 'c3',
        text: '1,500,000'
      },
      {
        id: 'c4',
        text: '2,000,000'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'First find $CPI = BCWP / ACWP = 900{,}000 / 1{,}000{,}000 = 0.90$. Then $ETC = (BAC - BCWP) / CPI = (1{,}500{,}000 - 900{,}000) / 0.90 = 600{,}000 / 0.90 = 666{,}667$. Finally $EAC = ACWP + ETC = 1{,}000{,}000 + 666{,}667 = 1{,}666{,}667$. The 1,600,000 choice added ETC without dividing by CPI ($600{,}000 + 1{,}000{,}000 = 1{,}600{,}000$). The 1,500,000 choice is just BAC with no adjustment. The 2,000,000 choice over-corrects. As a check, the shortcut $EAC = BAC / CPI = 1{,}500{,}000 / 0.90 = 1{,}666{,}667$ gives the same result, so 1,666,667 is correct either way.',
    hint: 'EAC = ACWP + (BAC - BCWP) / CPI. Or equivalently, EAC = BAC / CPI.',
    steps: [
      {
        text: 'Cost Performance Index:',
        latex: 'CPI = \\frac{900{,}000}{1{,}000{,}000} = 0.90'
      },
      {
        text: 'Estimate to complete:',
        latex: 'ETC = \\frac{BAC - BCWP}{CPI} = \\frac{600{,}000}{0.90} = 666{,}667'
      },
      {
        text: 'Estimate at completion:',
        latex: 'EAC = ACWP + ETC = 1{,}000{,}000 + 666{,}667 = 1{,}666{,}667'
      }
    ],
    handbookPage: 'p. 311',
    handbookFormula: 'EAC = ACWP + \\frac{BAC - BCWP}{CPI}',
    videoUrl: null,
    traps: [
      'Forgetting to divide by CPI when computing ETC — this assumes perfect cost performance going forward',
      'Using BAC as EAC without adjusting for the overrun trend'
    ],
    diagram: null,
    lessonId: 'project-forecasting',
    chapterId: 'construction'
  },
  {
    id: 'con-pf-ex3',
    type: 'conceptual',
    statement: 'Two projects report at the same milestone. Project Alpha has $CPI = 0.85$ and $SPI = 1.05$. Project Beta has $CPI = 1.10$ and $SPI = 0.88$. Which comparison is accurate?',
    choices: [
      {
        id: 'c1',
        text: 'Both projects are over budget'
      },
      {
        id: 'c2',
        text: 'Alpha is under budget and ahead of schedule; Beta is over budget and behind schedule'
      },
      {
        id: 'c3',
        text: 'Alpha is over budget but ahead of schedule; Beta is under budget but behind schedule'
      },
      {
        id: 'c4',
        text: 'Both projects are behind schedule'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'For Alpha: $CPI = 0.85 < 1.0$, so over budget. $SPI = 1.05 > 1.0$, so ahead of schedule. For Beta: $CPI = 1.10 > 1.0$, so under budget. $SPI = 0.88 < 1.0$, so behind schedule. The threshold is 1.0 for both indices — above is favorable, below is unfavorable. The choice claiming Alpha is under budget/ahead and Beta over budget/behind reverses both interpretations. The choice saying both projects are over budget ignores that Beta $CPI > 1.0$. The choice saying both are behind schedule ignores that Alpha $SPI > 1.0$.',
    hint: 'Index > 1.0 = favorable. Index < 1.0 = unfavorable. CPI for cost, SPI for schedule.',
    steps: [
      {
        text: 'Alpha: $CPI = 0.85 < 1.0$ (over budget), $SPI = 1.05 > 1.0$ (ahead of schedule).',
        latex: null
      },
      {
        text: 'Beta: $CPI = 1.10 > 1.0$ (under budget), $SPI = 0.88 < 1.0$ (behind schedule).',
        latex: null
      }
    ],
    handbookPage: 'p. 311',
    handbookFormula: 'CPI = \\frac{BCWP}{ACWP},\\quad SPI = \\frac{BCWP}{BCWS}',
    videoUrl: null,
    traps: [
      'Confusing CPI with SPI — CPI measures cost efficiency, SPI measures schedule efficiency',
      'Reversing the interpretation: values less than 1.0 are unfavorable, not favorable'
    ],
    diagram: null,
    lessonId: 'project-forecasting',
    chapterId: 'construction'
  },
  {
    id: 'con-pf-ex4',
    type: 'conceptual',
    statement: 'A project manager computes $ETC = \\frac{BAC - BCWP}{CPI}$ and gets a value LESS than $(BAC - ACWP)$. What does this imply about the project\'s cost performance?',
    choices: [
      {
        id: 'c1',
        text: 'CPI > 1.0, so the project is under budget and the remaining work will cost less than the remaining budget'
      },
      {
        id: 'c2',
        text: 'CPI < 1.0, so the remaining work will cost more than originally budgeted'
      },
      {
        id: 'c3',
        text: 'The project is exactly on budget'
      },
      {
        id: 'c4',
        text: 'The formula was applied incorrectly — ETC can never be less than remaining budget'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'ETC = (BAC - BCWP) / CPI. The remaining budget = BAC - ACWP. If ETC < (BAC - ACWP), it means the forecasted remaining cost is less than the money left. This happens when CPI > 1.0 (under budget) — dividing by a number greater than 1 shrinks the numerator. The project is performing efficiently, so remaining work costs less per dollar of value. The CPI < 1.0 choice describes the opposite case, which would make ETC LARGER than remaining budget. The on-budget choice would mean CPI = 1.0 exactly. The choice claiming the formula was misapplied is wrong — ETC can absolutely be less than remaining budget when the project is efficient.',
    hint: 'When CPI > 1.0, dividing by CPI makes ETC smaller. What does that say about the budget?',
    steps: [
      {
        text: 'ETC = (BAC - BCWP) / CPI. Remaining budget = BAC - ACWP.',
        latex: null
      },
      {
        text: 'If CPI > 1.0, dividing by CPI reduces the numerator, so ETC < (BAC - BCWP).',
        latex: null
      },
      {
        text: 'Since the project is under budget (ACWP < BCWP), (BAC - ACWP) > (BAC - BCWP) > ETC.',
        latex: null
      },
      {
        text: 'The remaining work will cost less than the remaining budget — project finishes under budget.',
        latex: null
      }
    ],
    handbookPage: 'p. 311',
    handbookFormula: 'ETC = \\frac{BAC - BCWP}{CPI}',
    videoUrl: null,
    traps: [
      'Confusing remaining work (BAC - BCWP) with remaining budget (BAC - ACWP)',
      'Assuming ETC must always exceed remaining budget — that is only true when CPI < 1.0'
    ],
    diagram: null,
    lessonId: 'project-forecasting',
    chapterId: 'construction'
  },
  {
    id: 'con-dm-ex1',
    type: 'conceptual',
    statement: 'In a Design-Build project, the owner discovers a design error during construction. Who bears primary responsibility for correcting the error?',
    choices: [
      {
        id: 'c1',
        text: 'The design-build entity, since it holds both design and construction responsibility'
      },
      {
        id: 'c2',
        text: 'The owner, since they approved the design'
      },
      {
        id: 'c3',
        text: 'A separate design consultant hired by the owner'
      },
      {
        id: 'c4',
        text: 'The surety company that bonded the project'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'In Design-Build, one entity is responsible for both design and construction under a single contract. If a design error surfaces, the DB entity owns it because they produced the design. The owner does not bear design liability just because they accepted submittals. A separate consultant is not part of DB. The surety backs the contract but does not take over design responsibility.',
    hint: 'Think about who holds the design contract in a DB arrangement.',
    steps: [
      {
        text: 'Design-Build places both design and construction under one contract.',
        latex: null
      },
      {
        text: 'The DB entity produced the design, so design errors are their responsibility.',
        latex: null
      }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking the owner assumes design risk by approving submittals — approval does not transfer liability'
    ],
    diagram: null,
    lessonId: 'delivery-methods',
    chapterId: 'construction'
  },
  {
    id: 'con-dm-ex2',
    type: 'conceptual',
    statement: 'Which delivery method is MOST likely to result in costly change orders if the scope is poorly defined at the time of bidding?',
    choices: [
      {
        id: 'c1',
        text: 'Design-Build'
      },
      {
        id: 'c2',
        text: 'Design-Bid-Build'
      },
      {
        id: 'c3',
        text: 'CM-at-Risk'
      },
      {
        id: 'c4',
        text: 'Integrated Project Delivery'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'In DBB, the contractor bids on a fixed set of plans. If those plans are incomplete or the scope is poorly defined, the contractor prices only what is shown. Anything not in the documents becomes a change order, and the contractor has leverage because they are already on site. DB and CMAR involve the builder earlier, so scope gaps are caught before a hard bid. IPD shares risk collaboratively, reducing change-order disputes.',
    hint: 'Which method gives the contractor zero input on the design before they bid?',
    steps: [
      {
        text: 'DBB requires complete plans before bidding — contractor bids only on what is shown.',
        latex: null
      },
      {
        text: 'Poorly defined scope means many items are missing from the bid documents.',
        latex: null
      },
      {
        text: 'Missing items surface during construction as change orders at the contractor\'s pricing.',
        latex: null
      }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Assuming DB has more change orders — DB actually reduces them because the same entity controls design and construction'
    ],
    diagram: null,
    lessonId: 'delivery-methods',
    chapterId: 'construction'
  },
  {
    id: 'con-dm-ex3',
    type: 'conceptual',
    statement: 'A city wants to build a new water treatment plant. The project is complex, the city wants early contractor input on constructability, and it requires a Guaranteed Maximum Price before construction begins. The city also wants to retain its own design engineer. Which delivery method best fits these requirements?',
    choices: [
      {
        id: 'c1',
        text: 'Design-Build'
      },
      {
        id: 'c2',
        text: 'Design-Bid-Build'
      },
      {
        id: 'c3',
        text: 'CM-at-Risk'
      },
      {
        id: 'c4',
        text: 'Job Order Contracting'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Three clues point to CMAR: (1) early contractor input on constructability, (2) a Guaranteed Maximum Price, and (3) the city retains its own separate design engineer. DB would combine design and construction under one entity, eliminating the separate designer. DBB would not allow contractor involvement during design. Job Order Contracting is for small, repetitive maintenance tasks, not complex new facilities.',
    hint: 'Separate designer + early contractor input + GMP — which method checks all three boxes?',
    steps: [
      {
        text: 'Early contractor input during design rules out DBB.',
        latex: null
      },
      {
        text: 'Retaining a separate design engineer rules out DB.',
        latex: null
      },
      {
        text: 'GMP before construction is a hallmark of CMAR.',
        latex: null
      }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Selecting DB when the owner explicitly wants a separate designer — DB merges design and construction',
      'Confusing GMP with a lump-sum bid in DBB'
    ],
    diagram: null,
    lessonId: 'delivery-methods',
    chapterId: 'construction'
  },
  {
    id: 'con-dm-ex4',
    type: 'computational',
    statement: 'A Design-Bid-Build project received four bids: 2,450,000 dollars from Contractor A, 2,380,000 dollars from Contractor B, 2,510,000 dollars from Contractor C, and 2,395,000 dollars from Contractor D. Contractor B is deemed non-responsible due to insufficient bonding capacity. Which bid should the owner accept under standard DBB procurement?',
    choices: [
      {
        id: 'c1',
        text: '2,395,000 dollars (Contractor D)'
      },
      {
        id: 'c2',
        text: '2,380,000 dollars (Contractor B)'
      },
      {
        id: 'c3',
        text: '2,450,000 dollars (Contractor A)'
      },
      {
        id: 'c4',
        text: '2,510,000 dollars (Contractor C)'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'DBB awards to the lowest RESPONSIBLE bidder. Contractor B submitted the lowest bid (2,380,000) but is non-responsible because they lack bonding capacity. You skip B and move to the next lowest bid among responsible bidders. Contractor D at 2,395,000 is the lowest responsible bid. Picking B ignores the responsibility requirement. A and C are higher than D.',
    hint: 'DBB awards to the lowest responsible bidder — not just the lowest number.',
    steps: [
      {
        text: 'Rank bids: B (2,380,000), D (2,395,000), A (2,450,000), C (2,510,000).',
        latex: null
      },
      {
        text: 'B is non-responsible (insufficient bonding) — disqualified.',
        latex: null
      },
      {
        text: 'Next lowest responsible bid: D at 2,395,000.',
        latex: null
      }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Awarding to the lowest numerical bid without checking responsibility — B is disqualified',
      'Confusing "responsive" (bid meets requirements) with "responsible" (bidder is qualified)'
    ],
    diagram: null,
    lessonId: 'delivery-methods',
    chapterId: 'construction'
  },
  {
    id: 'con-cs-ex1',
    type: 'conceptual',
    statement: 'On a construction site, OSHA requires a "competent person" to inspect excavations daily and after rainstorms. Which of the following best describes a competent person under OSHA?',
    choices: [
      {
        id: 'c1',
        text: 'Any worker with at least 5 years of excavation experience'
      },
      {
        id: 'c2',
        text: 'A person capable of identifying hazards and authorized to take corrective measures'
      },
      {
        id: 'c3',
        text: 'A registered professional engineer specializing in geotechnical design'
      },
      {
        id: 'c4',
        text: 'The project manager or superintendent listed on the contract'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'OSHA defines a competent person as someone who can identify existing and predictable hazards in the surroundings or working conditions AND who has the authority to take prompt corrective measures to eliminate them. It is not a years-of-experience requirement (the 5-years-of-experience option), not necessarily a PE (the registered geotechnical engineer option), and not automatically the PM or superintendent (the contract-listed manager option). The key phrase is "identify hazards AND authorized to correct them."',
    hint: 'The OSHA definition has two parts: the ability to identify hazards and the authority to correct them.',
    steps: [
      {
        text: 'OSHA defines a competent person as one who can identify existing and predictable hazards in the surroundings or working conditions.',
        latex: null
      },
      {
        text: 'The person must also have the authority to take prompt corrective measures to eliminate those hazards.',
        latex: null
      },
      {
        text: 'This is not tied to a license, title, or minimum years of experience.',
        latex: null
      }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking a PE is required — a competent person does not need to be an engineer',
      'Assuming experience alone qualifies someone — they must also have authority to act'
    ],
    diagram: null,
    lessonId: 'construction-safety',
    chapterId: 'construction'
  },
  {
    id: 'con-cs-ex2',
    type: 'conceptual',
    statement: 'Under OSHA regulations, at what height must fall protection be provided for workers in general construction?',
    choices: [
      {
        id: 'c1',
        text: '4 feet'
      },
      {
        id: 'c2',
        text: '6 feet'
      },
      {
        id: 'c3',
        text: '10 feet'
      },
      {
        id: 'c4',
        text: '15 feet'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'OSHA 29 CFR 1926.501 requires fall protection at 6 feet in general construction. This is one of the most commonly tested OSHA facts. Note: the threshold is 4 feet for general industry (not construction), 10 feet for scaffolds, and 15 feet for steel erection. The FE will try to trick you with these different thresholds.',
    hint: 'Recall the OSHA general construction fall protection trigger height.',
    steps: [
      {
        text: 'OSHA 29 CFR 1926.501 sets the trigger height for fall protection.',
        latex: null
      },
      {
        text: 'In general construction, fall protection is required at 6 feet or more.',
        latex: null
      },
      {
        text: '4 feet is for general industry; 10 feet is for scaffolds, and 15 feet is for steel erection specifically.',
        latex: null
      }
    ],
    handbookPage: 'p. 14',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing the 6-foot construction threshold with the 4-foot general industry threshold',
      'Using the 10-foot steel erection exception as the general rule'
    ],
    diagram: null,
    lessonId: 'construction-safety',
    chapterId: 'construction'
  },
  {
    id: 'con-cs-ex3',
    type: 'conceptual',
    statement: 'A contractor enters a below-grade utility vault with limited entry/exit points and the potential for a hazardous atmosphere. Before any worker enters, OSHA requires all of the following EXCEPT:',
    choices: [
      {
        id: 'c1',
        text: 'Atmospheric testing before entry'
      },
      {
        id: 'c2',
        text: 'A written entry permit and rescue plan'
      },
      {
        id: 'c3',
        text: 'An attendant stationed at the entry point'
      },
      {
        id: 'c4',
        text: 'A registered professional engineer on site during entry'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'A permit-required confined space needs atmospheric testing, a written permit with a rescue plan, and an attendant at the entry. There is no OSHA requirement for a PE to be physically present during confined space entry. A competent person (not necessarily a PE) oversees the work. Atmospheric testing, the written entry permit with rescue plan, and the attendant at the entry are all legitimate OSHA requirements for permit-required confined spaces.',
    hint: 'Think about the four requirements for permit-required confined spaces. One of these choices describes a different OSHA rule entirely.',
    steps: [
      {
        text: 'Permit-required confined space requirements: atmospheric testing, entry permit, rescue plan, attendant.',
        latex: null
      },
      {
        text: 'A PE on site is required for excavations deeper than 20 ft, not for confined space entry.',
        latex: null
      },
      {
        text: 'The question asks for the exception, so the answer is the item NOT required.',
        latex: null
      }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing confined space rules with deep excavation rules (PE required for excavations > 20 ft)',
      'Assuming a PE must be present for all hazardous operations'
    ],
    diagram: null,
    lessonId: 'construction-safety',
    chapterId: 'construction'
  },
  {
    id: 'con-cs-ex4',
    type: 'conceptual',
    statement: 'A trench is 12 ft deep in Type C soil (the weakest classification). The contractor wants to use open-cut sloping instead of shoring. What is the required slope ratio for Type C soil?',
    choices: [
      {
        id: 'c1',
        text: '$1.5H : 1V$ (or flatter)'
      },
      {
        id: 'c2',
        text: '$1H : 1V$'
      },
      {
        id: 'c3',
        text: '$0.75H : 1V$'
      },
      {
        id: 'c4',
        text: '$0.5H : 1V$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Type C soil is the weakest OSHA soil classification and requires the flattest (most gradual) slope at 1.5H:1V (about 34 degrees from horizontal). Type B soil uses 1H:1V, and Type A uses 0.75H:1V. Weaker soil needs a wider excavation to prevent collapse. The 1H:1V choice is for Type B soil, the 0.75H:1V choice is for Type A soil, and the 0.5H:1V choice is steeper than any OSHA-permitted slope for open cut.',
    hint: 'Weaker soil = flatter required slope. Type C is the weakest. Which ratio gives the flattest angle?',
    steps: [
      {
        text: 'OSHA slope requirements by soil type:',
        latex: null
      },
      {
        text: 'Type A (strongest): $0.75H : 1V$',
        latex: null
      },
      {
        text: 'Type B (moderate): $1H : 1V$',
        latex: null
      },
      {
        text: 'Type C (weakest): $1.5H : 1V$',
        latex: null
      },
      {
        text: 'Type C at 12 ft deep requires 1.5H:1V, meaning 18 ft of horizontal distance per side.',
        latex: null
      }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Mixing up slope ratios between soil types — Type C is the flattest, not the steepest',
      'Forgetting that a larger H:V ratio means a flatter (safer) slope'
    ],
    diagram: null,
    lessonId: 'construction-safety',
    chapterId: 'construction'
  },
];

export default PROBLEMS;
