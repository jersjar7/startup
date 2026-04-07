export default {
  id: 'obligations-to-the-public',
  name: 'Obligations to the Public',
  subtopicId: 'professional-conduct',
  application:
    'Every section of the NCEES Model Rules starts with one idea: public safety comes first. On the FE, ethics questions test whether you can identify which obligation takes priority when two rules collide — and the answer is almost always "protect the public." Civil engineers sign and seal plans for bridges, buildings, and water systems that directly affect human life, so the exam checks that you know the ten rules in Section A cold, especially the hierarchy: public safety > employer loyalty > personal interest.',
  content: [
    {
      type: 'text',
      body: 'The NCEES Model Rules §240.15 Section A lists ten obligations every licensee owes to the public. You don\'t need to memorize them word-for-word — the exam tests whether you can apply the right rule to a scenario. Here\'s the framework.',
    },
    { type: 'heading', body: 'The Cardinal Rule — Safety First' },
    {
      type: 'text',
      body: 'Rule A.1 is the foundation of everything: your $\\textit{first and foremost}$ responsibility is to safeguard the health, safety, and welfare of the public. When any other obligation conflicts with this one, A.1 wins. Period.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'If a question ever asks "what should the engineer do first?" and one answer involves protecting the public, that\'s almost certainly correct. The exam loves testing whether you\'ll prioritize public safety over client deadlines, employer pressure, or personal gain.',
    },
    { type: 'heading', body: 'Seal Only What You Can Stand Behind' },
    {
      type: 'text',
      body: 'Rule A.2 says you only sign and seal documents that conform to accepted standards and safeguard public welfare. If your boss hands you plans that cut corners on a retaining wall design, you don\'t seal them — even if they\'re technically your project.',
    },
    { type: 'heading', body: 'Blow the Whistle When It Matters' },
    {
      type: 'text',
      body: 'Rule A.3 is the whistleblower rule. If your professional judgment is overruled and public safety is at risk, you must notify your employer and the appropriate authority. Staying quiet to keep the peace is a violation.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'Common exam trap: a question where the engineer disagrees with the client but public safety isn\'t actually at risk. In that case, A.3 doesn\'t apply — you don\'t blow the whistle over a design preference. The trigger is specifically "health, safety, or welfare of the public is endangered."',
    },
    { type: 'heading', body: 'Honesty and Competence' },
    {
      type: 'text',
      body: 'Rules A.4 and A.5 cover truthfulness. All professional documents must include relevant information presented objectively and truthfully (A.4). Public opinions must be founded on adequate knowledge and competent evaluation (A.5). In short: don\'t guess, don\'t spin, and don\'t speak outside your expertise.',
    },
    { type: 'heading', body: 'Disclosure, Fraud & Reporting' },
    {
      type: 'text',
      body: 'Rules A.6 through A.8 deal with transparency. If someone is paying you to say something publicly, disclose it (A.6). Don\'t partner with anyone engaged in fraud (A.7). And if you know another licensee is violating the rules, you must report it to the board (A.8).',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'Decision tree for "what should the engineer do?" questions: (1) Is public safety at risk? → Notify employer + authorities (A.3). (2) Is another licensee violating rules? → Report to the board (A.8). (3) Is the engineer being asked to act outside their competence? → Decline the work. (4) None of the above? → Look at Sections B or C.',
    },
    { type: 'heading', body: 'Licensure Integrity' },
    {
      type: 'text',
      body: 'Rules A.9 and A.10 close out the section. Don\'t lie on behalf of an applicant seeking licensure (A.9), and comply with the licensing laws of every jurisdiction where you practice (A.10). These show up less often on the exam but are straightforward.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The exam typically gives you 2-3 ethics questions. They\'re fast points if you know the hierarchy: (1) public safety is paramount, (2) honesty and truthfulness always, (3) report violations to the board. Most wrong answers try to tempt you with "tell your supervisor and do nothing else" — that\'s almost never sufficient when safety is at stake.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'eth-otp-q1',
      statement:
        'A structural engineer discovers that the concrete mix specified by the client for a parking garage does not meet the minimum compressive strength required by the building code. The client insists on using the cheaper mix to stay within budget. What should the engineer do?',
      choices: [
        {
          id: 'c1',
          text: 'Use the client\'s specified mix and note the deviation in the project file',
        },
        {
          id: 'c2',
          text: 'Reduce the number of parking levels to compensate for the weaker concrete',
        },
        {
          id: 'c3',
          text: 'Seal the plans but add a disclaimer limiting the engineer\'s liability',
        },
        {
          id: 'c4',
          text: 'Refuse to seal the plans and notify the client that the design must meet code requirements',
        },
      ],
      correctAnswerId: 'c4',
      difficulty: 'easy',
      eli5: "This one is textbook Rule A.1 + A.2. The client wants to cut corners on concrete strength, but the building code exists to protect people. You can't seal plans that don't meet code — full stop. Choice A is wrong because just noting it in a file doesn't fix the safety issue. Choice C is wrong because a disclaimer doesn't magically make unsafe concrete safe. Choice B is creative but you can't just redesign around a code violation without the client's mix actually meeting requirements. The right move is to refuse to seal until the design is code-compliant.",
      hint: 'Which obligation always takes priority when client requests conflict with public safety?',
      steps: [
        {
          text: "Identify the core issue: the client wants to use a concrete mix that violates building code, which directly affects public safety.",
          latex: null,
        },
        {
          text: "Apply Rule A.1: the engineer's first and foremost responsibility is to safeguard the health, safety, and welfare of the public.",
          latex: null,
        },
        {
          text: 'Apply Rule A.2: licensees shall only sign and seal documents that conform to accepted standards and safeguard public welfare.',
          latex: null,
        },
        {
          text: 'The engineer cannot seal plans that violate the building code regardless of client pressure. The correct action is to refuse to seal and require code-compliant design.',
          latex: null,
        },
      ],
      handbookPage: 'p. 4, Model Rules §240.15 A.1–A.2',
      handbookFormula:
        '\\text{A.1: First and foremost responsibility is to safeguard the health, safety, and welfare of the public.}',
      videoUrl: null,
      traps: [
        "Thinking that documenting the deviation protects the engineer — it doesn't satisfy A.2",
        'Believing a disclaimer shifts liability and makes sealing acceptable',
      ],
      diagram: null,
    },
    {
      id: 'eth-otp-q2',
      statement:
        "A geotechnical engineer working for a consulting firm learns that a colleague at the same firm made a significant error in a soil bearing capacity report for a school building project. The colleague has already submitted the report to the client. The engineer raises the concern to the colleague, who dismisses it. What is the engineer's most appropriate next step?",
      choices: [
        {
          id: 'c1',
          text: "Notify the firm's management and, if the issue is not resolved, report to the licensing board",
        },
        {
          id: 'c2',
          text: 'Contact the school district directly to warn them about the error',
        },
        {
          id: 'c3',
          text: 'Do nothing further since the colleague is responsible for their own work',
        },
        {
          id: 'c4',
          text: 'Anonymously post a warning on a public engineering forum',
        },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: "This is the classic \"escalation ladder\" question. You already tried step one — talking to the colleague — and got shut down. The next step isn't to go rogue and call the client directly (B) or post online (D), and it definitely isn't to shrug and walk away (C). You escalate through proper channels: tell management, and if they don't fix it, report to the licensing board. The exam tests whether you know the correct order of escalation. It's always: direct conversation → management → board. Jumping straight to the board or the public is only correct when there's imminent danger and no time for the chain.",
      hint: 'Think about the proper order of escalation when a colleague\'s error puts public safety at risk.',
      steps: [
        {
          text: 'Identify the issue: a material error in a bearing capacity report for a school — public safety is clearly at risk (Rule A.1).',
          latex: null,
        },
        {
          text: 'The engineer already tried informal resolution by talking to the colleague (consistent with Rule C.4 — make a reasonable effort to inform another licensee of a material error).',
          latex: null,
        },
        {
          text: 'Since the colleague dismissed the concern, the engineer must escalate. Rule A.3 requires notifying the employer and appropriate authority when public safety is endangered.',
          latex: null,
        },
        {
          text: 'Rule A.8 requires reporting violations to the board if the issue is not resolved through the chain of command.',
          latex: null,
        },
        {
          text: 'The proper sequence is: colleague → management → board. Skipping management to go directly to the client or public is premature.',
          latex: null,
        },
      ],
      handbookPage: 'p. 4–5, Model Rules §240.15 A.3, A.8',
      handbookFormula:
        '\\text{A.3: Notify employer and appropriate authority when public safety is endangered.}',
      videoUrl: null,
      traps: [
        "Going directly to the client before exhausting internal channels — the firm should have the opportunity to correct the error first",
        'Assuming "the colleague is responsible for their own work" releases you from reporting obligations under A.8',
      ],
      diagram: null,
    },
    {
      id: 'eth-otp-q3',
      statement:
        "A civil engineer employed by a state transportation department is also a member of the department's consultant selection committee. A close friend who owns an engineering firm asks the engineer to recommend their firm for an upcoming highway bridge project. The friend's firm is technically qualified. Which action most closely aligns with the NCEES Model Rules?",
      choices: [
        {
          id: 'c1',
          text: "Recommend the friend's firm since they are technically qualified and public safety is not at risk",
        },
        {
          id: 'c2',
          text: 'Recuse from the selection process for this project and disclose the personal relationship to the committee',
        },
        {
          id: 'c3',
          text: 'Evaluate all firms objectively and vote for whichever is most qualified, regardless of the personal relationship',
        },
        {
          id: 'c4',
          text: 'Resign from the selection committee entirely to avoid any future conflicts of interest',
        },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: "This question is sneaky because it mixes Section A (public obligations) with Section B (employer/client obligations). The friend's firm being qualified is a red herring — the issue isn't competence, it's conflict of interest. Rule B.8 is very specific: if you serve on a government body, you can't participate in decisions about contracts involving people you have a relationship with. Option C sounds reasonable (\"just be objective!\"), but the rules say the appearance of bias is enough to require action. And D is overkill — you don't need to quit the whole committee, just sit out this one decision. The right answer is always disclose + recuse.",
      hint: "Focus on what the rules say about conflicts of interest when serving on a government selection body — is objectivity alone sufficient?",
      steps: [
        {
          text: 'Identify the issue: the engineer has a personal relationship with a firm competing for a government contract — this is a conflict of interest.',
          latex: null,
        },
        {
          text: 'Apply Rule B.6: licensees shall disclose all known or potential conflicts of interest that could influence or appear to influence their judgment.',
          latex: null,
        },
        {
          text: 'Apply Rule B.8: licensees serving as members of a government body shall not participate in decisions with respect to professional services offered by a concern where they have a personal interest.',
          latex: null,
        },
        {
          text: "Even though the friend's firm is qualified, the engineer's participation in the selection creates an appearance of bias. Disclosure alone (answer C) isn't enough — the engineer must also step back from this decision.",
          latex: null,
        },
        {
          text: "Answer D is excessive — recusal from this specific project is sufficient; permanent resignation isn't required.",
          latex: null,
        },
      ],
      handbookPage: 'p. 5, Model Rules §240.15 B.6, B.8',
      handbookFormula:
        '\\text{B.8: Licensees serving on a government body shall not participate in decisions involving firms where they have a personal interest.}',
      videoUrl: null,
      traps: [
        "Believing that technical qualification of the friend's firm eliminates the conflict — the rules address appearance of influence, not just actual bias",
        'Choosing "evaluate objectively" (C) because it sounds ethical — but the Model Rules require recusal, not just good intentions',
      ],
      diagram: null,
    },
  ],
  examProblems: [
    {
      id: 'eth-op-ex1',
      type: 'conceptual',
      statement: 'A civil engineer working for a state highway department notices that a recently completed overpass shows hairline cracks in the abutment walls during a routine inspection. The cracks are within the tolerance allowed by the construction specifications, but the engineer believes the crack pattern suggests a deeper foundation settlement issue. The engineer\'s supervisor reviews the photos and says, "It meets spec — close the inspection report." What should the engineer do?',
      choices: [
        { id: 'c1', text: 'Close the inspection report as directed since the cracks are within specification tolerances' },
        { id: 'c2', text: 'Add a note to the report documenting personal concerns but sign off on the inspection as passing' },
        { id: 'c3', text: 'Refuse to close the report and recommend further investigation, escalating to higher management if the supervisor insists' },
        { id: 'c4', text: 'Anonymously contact a local news reporter to draw public attention to the issue' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'easy',
      eli5: 'This is a classic Rule A.1 and A.3 scenario. The engineer has professional judgment that something may be wrong, even though the specs are technically met. Specifications are minimum standards — they do not override engineering judgment when safety is at risk. Answer A is wrong because "meets spec" does not mean "safe" when professional judgment says otherwise. Answer B is a half-measure that still signs off on the inspection. Answer D skips the entire chain of command and goes public, which is premature. The right move is to push for further investigation and escalate internally if needed.',
      hint: 'When professional judgment conflicts with specification compliance, which takes priority under Rule A.1?',
      steps: [
        { text: 'Identify the conflict: the cracks meet specifications, but the engineer\'s professional judgment identifies a potential safety risk from foundation settlement.', latex: null },
        { text: 'Apply Rule A.1: the engineer\'s first and foremost responsibility is to safeguard the health, safety, and welfare of the public. Specification compliance does not override this obligation.', latex: null },
        { text: 'Apply Rule A.3: if the engineer\'s professional judgment is overruled and public safety is at risk, the engineer must notify the employer and appropriate authority.', latex: null },
        { text: 'The proper sequence is to refuse to close the report, recommend further investigation, and escalate to higher management if the supervisor insists on closing it without investigation.', latex: null },
      ],
      handbookPage: 'p. 4, Model Rules §240.15 A.1, A.3',
      handbookFormula: '\\text{A.1: First and foremost responsibility is to safeguard the health, safety, and welfare of the public.}',
      videoUrl: null,
      traps: ['Equating specification compliance with safety — specs are minimum standards, not guarantees', 'Thinking that documenting concerns in the report is sufficient action when safety may be at risk'],
      diagram: null,
    },
    {
      id: 'eth-op-ex2',
      type: 'conceptual',
      statement: 'A consulting engineer is hired by a real estate developer to prepare a flood risk assessment for a proposed residential subdivision. The developer asks the engineer to use an outdated FEMA flood map that shows the site outside the 100-year floodplain, rather than the current map that places 40% of the lots within it. The developer argues that the old map was "official at the time the project was conceived." What should the engineer do?',
      choices: [
        { id: 'c1', text: 'Refuse to use the outdated map and prepare the assessment using current data, informing the developer that professional documents must be objective and truthful' },
        { id: 'c2', text: 'Use the outdated map but add a footnote disclosing that a newer map exists' },
        { id: 'c3', text: 'Use the outdated map as the developer requests since it was an official FEMA product' },
        { id: 'c4', text: 'Withdraw from the project entirely since the developer has demonstrated unethical intent' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'Rule A.4 requires that professional reports include all relevant information and be presented objectively and truthfully. Using an outdated flood map when a current one exists is not objective — it is cherry-picking data to favor the client. The engineer knows the current map puts 40% of the lots in the floodplain, and omitting that information puts future homeowners at risk. Choice C is wrong because using outdated data when better data exists is not truthful practice. Choice B is a half-measure — a footnote does not make a misleading analysis acceptable. Choice D might feel right, but the Model Rules do not require you to quit; they require you to do the work correctly and honestly.',
      hint: 'What does Rule A.4 require about the information included in professional engineering reports?',
      steps: [
        { text: 'Identify the core issue: the developer wants the engineer to use outdated data that misrepresents flood risk to future homeowners.', latex: null },
        { text: 'Apply Rule A.4: licensees shall be objective and truthful in professional reports, statements, or testimony, and shall include all relevant and pertinent information.', latex: null },
        { text: 'Apply Rule A.1: public safety is paramount. Homeowners buying lots in an actual floodplain based on a misleading assessment face real safety and financial risk.', latex: null },
        { text: 'The engineer must use the most current and accurate data available. Informing the developer of this obligation is the professional response.', latex: null },
      ],
      handbookPage: 'p. 4, Model Rules §240.15 A.1, A.4',
      handbookFormula: '\\text{A.4: Be objective and truthful in professional reports and include all relevant and pertinent information.}',
      videoUrl: null,
      traps: ['Believing that using an "official" map from any era satisfies the truthfulness requirement — the obligation is to use the best available data', 'Thinking a footnote disclosure is sufficient when the entire analysis is based on misleading data'],
      diagram: null,
    },
    {
      id: 'eth-op-ex3',
      type: 'conceptual',
      statement: 'A PE is invited to give testimony at a city council meeting regarding a proposed zoning change that would allow a chemical storage facility near a residential neighborhood. The PE has experience in site development and grading but no background in chemical storage facility design, hazardous materials containment, or environmental risk assessment. The PE personally opposes the zoning change. Under the Model Rules, which action is most appropriate?',
      choices: [
        { id: 'c1', text: 'Testify against the zoning change since the PE has a professional obligation to protect the public' },
        { id: 'c2', text: 'Testify but limit comments to site development and grading issues within the PE\'s area of competence' },
        { id: 'c3', text: 'Decline to testify because the PE opposes the project and therefore cannot be objective' },
        { id: 'c4', text: 'Testify against the zoning change and cite general safety concerns, since any licensed PE is qualified to speak on public safety matters' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'Rule A.5 says that public statements must be founded on adequate knowledge and honest conviction. The PE knows site development, so speaking to grading, drainage, and access issues is fair game. But opining on chemical containment or hazardous materials risk without that expertise violates A.5 — you cannot speak authoritatively on subjects outside your competence, even if your heart is in the right place. Answer A is wrong because personal opposition is not the same as professional expertise. Answer C is too cautious — the PE can contribute within their lane. Answer D is wrong because a PE license is not a universal expert card; competence is discipline-specific.',
      hint: 'Rule A.5 requires that public opinions be founded on what two things?',
      steps: [
        { text: 'Identify the issue: the PE has relevant expertise in some aspects (site development) but not others (chemical storage, hazardous materials).', latex: null },
        { text: 'Apply Rule A.5: licensees shall express a professional opinion publicly only when it is founded on adequate knowledge of the facts and competence in the subject matter.', latex: null },
        { text: 'The PE can appropriately testify on site grading, drainage, and access — topics within their area of competence.', latex: null },
        { text: 'The PE should not offer opinions on chemical containment, environmental risk, or hazardous materials because these fall outside their expertise, regardless of personal beliefs about the project.', latex: null },
      ],
      handbookPage: 'p. 4, Model Rules §240.15 A.5',
      handbookFormula: '\\text{A.5: Express professional opinions publicly only when founded on adequate knowledge and competent evaluation.}',
      videoUrl: null,
      traps: ['Assuming a PE license authorizes public testimony on any safety topic — competence is discipline-specific', 'Conflating personal opposition with professional obligation to protect the public'],
      diagram: null,
    },
    {
      id: 'eth-op-ex4',
      type: 'conceptual',
      statement: 'A senior engineer at a consulting firm discovers that a junior engineer in the firm has been falsifying field compaction test results on a highway embankment project. The junior engineer changed failing density readings to passing values before submitting them to the state DOT. The senior engineer reports the issue to the firm owner, who says, "Fix the data quietly and re-run the tests. I do not want the DOT pulling our prequalification." Three weeks pass and the firm owner has taken no corrective action. What is the senior engineer\'s obligation under the Model Rules?',
      choices: [
        { id: 'c1', text: 'The senior engineer has fulfilled their obligation by reporting to the firm owner and can take no further action' },
        { id: 'c2', text: 'The senior engineer should give the firm owner more time to address the issue before escalating' },
        { id: 'c3', text: 'The senior engineer must report the falsification to the state licensing board and the DOT, since internal reporting failed to resolve the issue' },
        { id: 'c4', text: 'The senior engineer should confront the junior engineer directly and demand the original test data be resubmitted' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'hard',
      eli5: 'This stacks Rules A.3, A.7, and A.8 on top of each other. Falsifying compaction data on a highway project is a direct public safety issue — bad compaction leads to settlement, cracking, and potential road failure. The senior engineer tried the internal route and got shut down. Three weeks is more than reasonable wait time. At this point, A.3 requires notifying the appropriate authority (the DOT) because public safety is endangered. A.8 requires reporting the junior engineer\'s violation to the licensing board. And A.7 prohibits associating with anyone engaged in fraudulent practice — by staying silent, the senior engineer becomes complicit. Answer A is wrong because internal reporting is only the first step, not the last. Answer B is wrong because three weeks with falsified data in the field is already too long. Answer D addresses only the junior engineer and ignores the firm owner\'s cover-up and the need for board notification.',
      hint: 'When internal reporting fails to resolve a safety issue involving fraud, what do Rules A.3 and A.8 require as the next step?',
      steps: [
        { text: 'Identify the violations: the junior engineer falsified test data (fraud), and the firm owner is attempting to cover it up rather than correct it.', latex: null },
        { text: 'Apply Rule A.3: when professional judgment is overruled and public safety is endangered, the engineer must notify the employer (done) and the appropriate authority (DOT).', latex: null },
        { text: 'Apply Rule A.8: a licensee who has knowledge of a violation of the Model Rules shall report it to the board. The falsification is a clear violation.', latex: null },
        { text: 'Apply Rule A.7: do not associate with enterprises engaged in fraud. Continued silence makes the senior engineer complicit in the cover-up.', latex: null },
        { text: 'Three weeks have passed without corrective action. The obligation to protect the public now requires external reporting to both the licensing board and the state DOT.', latex: null },
      ],
      handbookPage: 'p. 4-5, Model Rules §240.15 A.3, A.7, A.8',
      handbookFormula: '\\text{A.8: Report knowledge of any violation of Model Rules to the appropriate authority.}',
      videoUrl: null,
      traps: ['Believing that reporting to management is the final step — it is the first step, and external reporting is required when internal channels fail', 'Thinking that confronting the junior engineer alone resolves the issue — the firm owner is also complicit, and the board must be notified'],
      diagram: null,
    },
  ],
};
