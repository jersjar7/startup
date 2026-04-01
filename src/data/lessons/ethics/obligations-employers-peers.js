export default {
  id: 'obligations-employers-clients-peers',
  name: 'Obligations to Employers, Clients & Other Licensees',
  subtopicId: 'professional-conduct',
  application:
    "Sections B and C of the Model Rules govern how you deal with the people you work for and the people you work alongside. On the FE, these rules show up as conflict-of-interest scenarios, confidentiality dilemmas, and questions about professional competence boundaries. Civil engineers constantly juggle multiple clients, subconsultants, and government agencies — the exam checks that you know where the ethical lines are when money, loyalty, and professional reputation are in play.",
  content: [
    {
      type: 'text',
      body: 'Sections B and C of Model Rules §240.15 cover two relationships: your obligations to employers and clients (B, 9 rules) and your obligations to other licensees (C, 4 rules). The exam tests these less often than Section A, but the questions tend to be trickier because the "right" answer isn\'t always obvious.',
    },
    { type: 'heading', body: 'Stay in Your Lane' },
    {
      type: 'text',
      body: "Rule B.1 is the competence rule: only take on assignments you're qualified for by education or experience. Rule B.2 backs it up — don't sign or seal anything outside your area of competence, or anything not prepared under your responsible charge. The exception is B.3: you can coordinate an entire project if each technical segment is signed by the specialist who prepared it.",
    },
    {
      type: 'callout',
      variant: 'exam',
      body: '"Responsible charge" is a term the exam loves. It means direct control and personal supervision. If you didn\'t prepare the work or directly supervise the person who did, you can\'t seal it — even if you reviewed it and it looks fine.',
    },
    { type: 'heading', body: 'Confidentiality and Conflicts of Interest' },
    {
      type: 'text',
      body: "Rule B.4 protects client information — don't reveal facts obtained in a professional capacity without consent, except when required by law. Rules B.5 through B.7 address money and loyalty: no gratuities from contractors (B.5), disclose all conflicts of interest (B.6), and don't accept payment from multiple parties on the same project without written consent from everyone (B.7).",
    },
    {
      type: 'callout',
      variant: 'warning',
      body: "Conflict-of-interest questions are the most common trap in Sections B and C. The exam tests whether you can spot the conflict — not whether the engineer is actually biased. Under B.6, even the appearance of a conflict requires disclosure.",
    },
    { type: 'heading', body: 'Government Service' },
    {
      type: 'text',
      body: "Rule B.8 is specific to engineers who serve on government bodies. If you sit on a selection committee or advisory board, you cannot participate in decisions about contracts involving your own firm or personal connections. The reverse also applies — your firm can't bid on work from a body where you serve. B.9 rounds out the section: don't use confidential information from your assignments for personal profit.",
    },
    { type: 'heading', body: 'Obligations to Other Licensees' },
    {
      type: 'text',
      body: "Section C has just four rules, all about professional integrity. Don't misrepresent your qualifications or exaggerate your role in past projects (C.1). Don't offer gifts or political contributions to secure work (C.2). Don't trash another licensee's reputation (C.3). And if you believe another licensee's work contains a material error that could affect public safety, make a reasonable effort to inform them (C.4).",
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'Quick mental model for Sections B and C: Section B = "don\'t cheat the people who pay you." Section C = "don\'t cheat the people who do what you do." Both boil down to honesty, competence, and transparency.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: "When a question involves two licensees disagreeing, check whether public safety is at risk. If yes, escalate per A.3/A.8. If no, the answer is usually C.4 — make a reasonable effort to inform the other licensee directly.",
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'eth-oec-q1',
      statement:
        'A transportation engineer is offered a freelance assignment to design a roundabout intersection. The engineer has extensive experience with highway alignment and signalized intersections but has never designed a roundabout. According to the NCEES Model Rules, what should the engineer do?',
      choices: [
        {
          id: 'c1',
          text: 'Accept the assignment and learn roundabout design while working on the project',
        },
        {
          id: 'c2',
          text: 'Accept the assignment since highway intersection experience is close enough',
        },
        {
          id: 'c3',
          text: "Decline the assignment because it falls outside the engineer's specific area of competence",
        },
        {
          id: 'c4',
          text: 'Accept the assignment but have a colleague review the final design',
        },
      ],
      correctAnswerId: 'c3',
      difficulty: 'easy',
      eli5: "Rule B.1 is blunt — you only take on work you're actually qualified for. \"Close enough\" doesn't cut it. Highway intersection design and roundabout design share some fundamentals, but roundabouts have their own geometry, sight-distance criteria, and capacity methods. Answer A is wrong because learning on the job puts the project at risk. Answer B is wrong because adjacent experience isn't the same as specific competence. Answer D sounds safe but a peer review doesn't make you qualified — the person signing and sealing needs to be competent, not just the reviewer.",
      hint: 'What does Rule B.1 say about the relationship between your qualifications and the assignments you accept?',
      steps: [
        {
          text: 'Identify the core issue: the engineer lacks specific experience in roundabout design, which is a distinct specialty within transportation engineering.',
          latex: null,
        },
        {
          text: 'Apply Rule B.1: licensees shall undertake assignments only when qualified by education or experience in the specific technical fields involved.',
          latex: null,
        },
        {
          text: 'General intersection experience does not satisfy the "specific technical fields" requirement for roundabout design — geometry, deflection angles, and capacity analysis differ significantly.',
          latex: null,
        },
        {
          text: 'The engineer should decline unless they first obtain the necessary training or partner with a qualified specialist.',
          latex: null,
        },
      ],
      handbookPage: 'p. 5, Model Rules §240.15 B.1',
      handbookFormula:
        '\\text{B.1: Undertake assignments only when qualified by education or experience in the specific technical fields involved.}',
      videoUrl: null,
      traps: [
        'Assuming that experience in a related subfield (highway intersections) satisfies the "specific technical fields" requirement',
        "Believing that having a colleague review the work compensates for the engineer's own lack of competence",
      ],
      diagram: null,
    },
    {
      id: 'eth-oec-q2',
      statement:
        "A water resources engineer works for a consulting firm and is managing a stormwater design project for City A. A competing municipality, City B, approaches the same firm and asks the engineer to evaluate City A's stormwater system for potential deficiencies as part of a regulatory dispute between the two cities. What should the engineer do?",
      choices: [
        {
          id: 'c1',
          text: 'Accept the City B assignment since the two projects involve different scopes of work',
        },
        {
          id: 'c2',
          text: 'Accept the City B assignment but keep all City A project files confidential',
        },
        {
          id: 'c3',
          text: 'Disclose the conflict to both clients and only proceed if both provide written consent',
        },
        {
          id: 'c4',
          text: 'Decline the City B assignment outright because it creates an unresolvable conflict',
        },
      ],
      correctAnswerId: 'c3',
      difficulty: 'medium',
      eli5: "This one stacks three rules on top of each other. You've got confidential info from City A (B.4), you've got an obvious conflict of interest (B.6), and you'd be getting paid by two parties on related work (B.7). Answer A ignores the conflict entirely. Answer B tries to compartmentalize, but you can't un-know what you know from the City A project — and the rules require disclosure, not just self-discipline. Answer D is too extreme — the Model Rules don't say you can never work for competing parties, they say you need full disclosure and written consent. The exam wants you to pick the answer that involves transparency and consent, not avoidance.",
      hint: "When two clients' interests overlap, what do the Model Rules require before you can serve both?",
      steps: [
        {
          text: "Identify the issue: the engineer has confidential knowledge from City A's project that is directly relevant to City B's request — this is a clear conflict of interest.",
          latex: null,
        },
        {
          text: 'Apply Rule B.4: licensees shall not reveal facts obtained in a professional capacity without prior consent.',
          latex: null,
        },
        {
          text: 'Apply Rule B.6: licensees shall disclose all known or potential conflicts of interest that could influence their judgment or quality of service.',
          latex: null,
        },
        {
          text: 'Apply Rule B.7: licensees shall not accept compensation from more than one party for services pertaining to the same subject matter unless circumstances are fully disclosed and agreed to in writing by all interested parties.',
          latex: null,
        },
        {
          text: 'The correct action is full disclosure to both clients with written consent required before proceeding. Neither silence nor outright refusal is the best answer.',
          latex: null,
        },
      ],
      handbookPage: 'p. 5, Model Rules §240.15 B.4, B.6, B.7',
      handbookFormula:
        '\\text{B.7: Do not accept compensation from more than one party unless fully disclosed and agreed to in writing.}',
      videoUrl: null,
      traps: [
        "Thinking that different scopes of work eliminate the conflict — the engineer's knowledge from City A is the issue, not the project boundaries",
        "Choosing to decline outright when disclosure + consent is the Model Rules' preferred resolution",
      ],
      diagram: null,
    },
    {
      id: 'eth-oec-q3',
      statement:
        "An engineer at a large firm discovers that a senior partner has been listing a major bridge project on the firm's marketing materials as a past accomplishment. The senior partner served as project manager, but the bridge design was actually performed by a subconsultant who is no longer affiliated with the firm. The marketing materials do not mention the subconsultant. A prospective client is evaluating the firm for a similar bridge project based partly on this claimed experience. What is the most appropriate action under the Model Rules?",
      choices: [
        {
          id: 'c1',
          text: "Do nothing — the senior partner managed the project, so claiming it as the firm's work is acceptable",
        },
        {
          id: 'c2',
          text: 'Report the senior partner directly to the licensing board for misrepresentation',
        },
        {
          id: 'c3',
          text: "Inform the senior partner that the marketing materials misrepresent the firm's role and should be corrected",
        },
        {
          id: 'c4',
          text: "Contact the prospective client directly to clarify the firm's actual role on the bridge project",
        },
      ],
      correctAnswerId: 'c3',
      difficulty: 'hard',
      eli5: "This is a C.1 + C.4 combo. The marketing materials exaggerate the firm's role — the partner managed the project but didn't do the bridge design. That's a misrepresentation under C.1, especially since it's being used to win new work (\"presentations incidental to the solicitation of employment\"). But you don't jump straight to the board or the client. Rule C.4 says make a reasonable effort to inform the licensee first. Answer A is wrong because \"project manager\" doesn't equal \"performed the design.\" Answer B skips the direct conversation step. Answer D goes outside the firm before trying to fix it internally. Start with the partner, then escalate if they refuse to correct it.",
      hint: 'Before reporting to the board or contacting the client, what does Rule C.4 require you to do first?',
      steps: [
        {
          text: "Identify the issue: the firm's marketing materials imply the firm performed the bridge design, when in fact a subconsultant did the technical work. This overstates the firm's in-house capability.",
          latex: null,
        },
        {
          text: 'Apply Rule C.1: licensees shall not misrepresent or exaggerate their degree of responsibility in prior assignments. Presentations incidental to the solicitation of employment shall not misrepresent pertinent facts.',
          latex: null,
        },
        {
          text: 'Apply Rule C.4: licensees shall make a reasonable effort to inform another licensee whose conduct contains a material issue. The senior partner should be notified first.',
          latex: null,
        },
        {
          text: 'Going directly to the board (B) skips the "reasonable effort to inform" step required by C.4. Going directly to the client (D) bypasses internal resolution and may violate confidentiality (B.4).',
          latex: null,
        },
        {
          text: 'The correct first step is to inform the senior partner and request a correction. If the partner refuses and a prospective client is being misled, escalation to management and potentially the board may follow.',
          latex: null,
        },
      ],
      handbookPage: 'p. 5, Model Rules §240.15 C.1, C.4',
      handbookFormula:
        '\\text{C.1: Shall not misrepresent or exaggerate degree of responsibility in prior assignments.}',
      videoUrl: null,
      traps: [
        "Assuming that project management equals design responsibility — the materials must accurately reflect who did the technical work",
        'Jumping to the board before making a reasonable effort to inform the senior partner directly (C.4 requires the direct approach first)',
      ],
      diagram: null,
    },
  ],
};
