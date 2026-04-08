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
};
