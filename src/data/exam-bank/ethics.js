// Exam bank: ethics
// Auto-extracted from lesson files — 24 questions

const PROBLEMS = [
  {
    id: 'eth-op-ex1',
    type: 'conceptual',
    statement: 'A civil engineer working for a state highway department notices that a recently completed overpass shows hairline cracks in the abutment walls during a routine inspection. The cracks are within the tolerance allowed by the construction specifications, but the engineer believes the crack pattern suggests a deeper foundation settlement issue. The engineer\'s supervisor reviews the photos and says, "It meets spec — close the inspection report." What should the engineer do?',
    choices: [
      {
        id: 'c1',
        text: 'Close the inspection report as directed since the cracks are within specification tolerances'
      },
      {
        id: 'c2',
        text: 'Add a note to the report documenting personal concerns but sign off on the inspection as passing'
      },
      {
        id: 'c3',
        text: 'Refuse to close the report and recommend further investigation, escalating to higher management if the supervisor insists'
      },
      {
        id: 'c4',
        text: 'Anonymously contact a local news reporter to draw public attention to the issue'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'This is a classic Rule A.1 and A.3 scenario. The engineer has professional judgment that something may be wrong, even though the specs are technically met. Specifications are minimum standards — they do not override engineering judgment when safety is at risk. Closing the report as directed is wrong because "meets spec" does not mean "safe" when professional judgment says otherwise. Adding a note but signing off as passing is a half-measure that still approves the inspection. Anonymously contacting a news reporter skips the entire chain of command and goes public, which is premature. The right move is to push for further investigation and escalate internally if needed.',
    hint: 'When professional judgment conflicts with specification compliance, which takes priority under Rule A.1?',
    steps: [
      {
        text: 'Identify the conflict: the cracks meet specifications, but the engineer\'s professional judgment identifies a potential safety risk from foundation settlement.',
        latex: null
      },
      {
        text: 'Apply Rule A.1: the engineer\'s first and foremost responsibility is to safeguard the health, safety, and welfare of the public. Specification compliance does not override this obligation.',
        latex: null
      },
      {
        text: 'Apply Rule A.3: if the engineer\'s professional judgment is overruled and public safety is at risk, the engineer must notify the employer and appropriate authority.',
        latex: null
      },
      {
        text: 'The proper sequence is to refuse to close the report, recommend further investigation, and escalate to higher management if the supervisor insists on closing it without investigation.',
        latex: null
      }
    ],
    handbookPage: 'p. 4, Model Rules §240.15 A.1, A.3',
    handbookFormula: '\\text{A.1: First and foremost responsibility is to safeguard the health, safety, and welfare of the public.}',
    videoUrl: null,
    traps: [
      'Equating specification compliance with safety — specs are minimum standards, not guarantees',
      'Thinking that documenting concerns in the report is sufficient action when safety may be at risk'
    ],
    diagram: null,
    lessonId: 'obligations-to-the-public',
    chapterId: 'ethics'
  },
  {
    id: 'eth-op-ex2',
    type: 'conceptual',
    statement: 'A consulting engineer is hired by a real estate developer to prepare a flood risk assessment for a proposed residential subdivision. The developer asks the engineer to use an outdated FEMA flood map that shows the site outside the 100-year floodplain, rather than the current map that places 40% of the lots within it. The developer argues that the old map was "official at the time the project was conceived." What should the engineer do?',
    choices: [
      {
        id: 'c1',
        text: 'Refuse to use the outdated map and prepare the assessment using current data, informing the developer that professional documents must be objective and truthful'
      },
      {
        id: 'c2',
        text: 'Use the outdated map but add a footnote disclosing that a newer map exists'
      },
      {
        id: 'c3',
        text: 'Use the outdated map as the developer requests since it was an official FEMA product'
      },
      {
        id: 'c4',
        text: 'Withdraw from the project entirely since the developer has demonstrated unethical intent'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Rule A.4 requires that professional reports include all relevant information and be presented objectively and truthfully. Using an outdated flood map when a current one exists is not objective — it is cherry-picking data to favor the client. The engineer knows the current map puts 40% of the lots in the floodplain, and omitting that information puts future homeowners at risk. Using the outdated map as the developer requests is wrong because relying on outdated data when better data exists is not truthful practice. Adding only a footnote is a half-measure — a footnote does not make a misleading analysis acceptable. Withdrawing entirely might feel right, but the Model Rules do not require you to quit; they require you to do the work correctly and honestly.',
    hint: 'What does Rule A.4 require about the information included in professional engineering reports?',
    steps: [
      {
        text: 'Identify the core issue: the developer wants the engineer to use outdated data that misrepresents flood risk to future homeowners.',
        latex: null
      },
      {
        text: 'Apply Rule A.4: licensees shall be objective and truthful in professional reports, statements, or testimony, and shall include all relevant and pertinent information.',
        latex: null
      },
      {
        text: 'Apply Rule A.1: public safety is paramount. Homeowners buying lots in an actual floodplain based on a misleading assessment face real safety and financial risk.',
        latex: null
      },
      {
        text: 'The engineer must use the most current and accurate data available. Informing the developer of this obligation is the professional response.',
        latex: null
      }
    ],
    handbookPage: 'p. 4, Model Rules §240.15 A.1, A.4',
    handbookFormula: '\\text{A.4: Be objective and truthful in professional reports and include all relevant and pertinent information.}',
    videoUrl: null,
    traps: [
      'Believing that using an "official" map from any era satisfies the truthfulness requirement — the obligation is to use the best available data',
      'Thinking a footnote disclosure is sufficient when the entire analysis is based on misleading data'
    ],
    diagram: null,
    lessonId: 'obligations-to-the-public',
    chapterId: 'ethics'
  },
  {
    id: 'eth-op-ex3',
    type: 'conceptual',
    statement: 'A PE is invited to give testimony at a city council meeting regarding a proposed zoning change that would allow a chemical storage facility near a residential neighborhood. The PE has experience in site development and grading but no background in chemical storage facility design, hazardous materials containment, or environmental risk assessment. The PE personally opposes the zoning change. Under the Model Rules, which action is most appropriate?',
    choices: [
      {
        id: 'c1',
        text: 'Testify against the zoning change since the PE has a professional obligation to protect the public'
      },
      {
        id: 'c2',
        text: 'Testify but limit comments to site development and grading issues within the PE\'s area of competence'
      },
      {
        id: 'c3',
        text: 'Decline to testify because the PE opposes the project and therefore cannot be objective'
      },
      {
        id: 'c4',
        text: 'Testify against the zoning change and cite general safety concerns, since any licensed PE is qualified to speak on public safety matters'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Rule A.5 says that public statements must be founded on adequate knowledge and honest conviction. The PE knows site development, so speaking to grading, drainage, and access issues is fair game. But opining on chemical containment or hazardous materials risk without that expertise violates A.5 — you cannot speak authoritatively on subjects outside your competence, even if your heart is in the right place. The option to testify against the change to protect the public is wrong because personal opposition is not the same as professional expertise. Declining to testify entirely is too cautious — the PE can contribute within their lane. Citing general safety concerns because any PE can speak on public safety is wrong because a PE license is not a universal expert card; competence is discipline-specific.',
    hint: 'Rule A.5 requires that public opinions be founded on what two things?',
    steps: [
      {
        text: 'Identify the issue: the PE has relevant expertise in some aspects (site development) but not others (chemical storage, hazardous materials).',
        latex: null
      },
      {
        text: 'Apply Rule A.5: licensees shall express a professional opinion publicly only when it is founded on adequate knowledge of the facts and competence in the subject matter.',
        latex: null
      },
      {
        text: 'The PE can appropriately testify on site grading, drainage, and access — topics within their area of competence.',
        latex: null
      },
      {
        text: 'The PE should not offer opinions on chemical containment, environmental risk, or hazardous materials because these fall outside their expertise, regardless of personal beliefs about the project.',
        latex: null
      }
    ],
    handbookPage: 'p. 4, Model Rules §240.15 A.5',
    handbookFormula: '\\text{A.5: Express professional opinions publicly only when founded on adequate knowledge and competent evaluation.}',
    videoUrl: null,
    traps: [
      'Assuming a PE license authorizes public testimony on any safety topic — competence is discipline-specific',
      'Conflating personal opposition with professional obligation to protect the public'
    ],
    diagram: null,
    lessonId: 'obligations-to-the-public',
    chapterId: 'ethics'
  },
  {
    id: 'eth-op-ex4',
    type: 'conceptual',
    statement: 'A senior engineer at a consulting firm discovers that a junior engineer in the firm has been falsifying field compaction test results on a highway embankment project. The junior engineer changed failing density readings to passing values before submitting them to the state DOT. The senior engineer reports the issue to the firm owner, who says, "Fix the data quietly and re-run the tests. I do not want the DOT pulling our prequalification." Three weeks pass and the firm owner has taken no corrective action. What is the senior engineer\'s obligation under the Model Rules?',
    choices: [
      {
        id: 'c1',
        text: 'The senior engineer has fulfilled their obligation by reporting to the firm owner and can take no further action'
      },
      {
        id: 'c2',
        text: 'The senior engineer should give the firm owner more time to address the issue before escalating'
      },
      {
        id: 'c3',
        text: 'The senior engineer must report the falsification to the state licensing board and the DOT, since internal reporting failed to resolve the issue'
      },
      {
        id: 'c4',
        text: 'The senior engineer should confront the junior engineer directly and demand the original test data be resubmitted'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'This stacks Rules A.3, A.7, and A.8 on top of each other. Falsifying compaction data on a highway project is a direct public safety issue — bad compaction leads to settlement, cracking, and potential road failure. The senior engineer tried the internal route and got shut down. Three weeks is more than reasonable wait time. At this point, A.3 requires notifying the appropriate authority (the DOT) because public safety is endangered. A.8 requires reporting the junior engineer\'s violation to the licensing board. And A.7 prohibits associating with anyone engaged in fraudulent practice — by staying silent, the senior engineer becomes complicit. The choice that says reporting to the firm owner fulfills the obligation is wrong because internal reporting is only the first step, not the last. The choice that says to give the owner more time is wrong because three weeks with falsified data in the field is already too long. The choice that says to confront the junior engineer directly addresses only the junior engineer and ignores the firm owner\'s cover-up and the need for board notification.',
    hint: 'When internal reporting fails to resolve a safety issue involving fraud, what do Rules A.3 and A.8 require as the next step?',
    steps: [
      {
        text: 'Identify the violations: the junior engineer falsified test data (fraud), and the firm owner is attempting to cover it up rather than correct it.',
        latex: null
      },
      {
        text: 'Apply Rule A.3: when professional judgment is overruled and public safety is endangered, the engineer must notify the employer (done) and the appropriate authority (DOT).',
        latex: null
      },
      {
        text: 'Apply Rule A.8: a licensee who has knowledge of a violation of the Model Rules shall report it to the board. The falsification is a clear violation.',
        latex: null
      },
      {
        text: 'Apply Rule A.7: do not associate with enterprises engaged in fraud. Continued silence makes the senior engineer complicit in the cover-up.',
        latex: null
      },
      {
        text: 'Three weeks have passed without corrective action. The obligation to protect the public now requires external reporting to both the licensing board and the state DOT.',
        latex: null
      }
    ],
    handbookPage: 'p. 4-5, Model Rules §240.15 A.3, A.7, A.8',
    handbookFormula: '\\text{A.8: Report knowledge of any violation of Model Rules to the appropriate authority.}',
    videoUrl: null,
    traps: [
      'Believing that reporting to management is the final step — it is the first step, and external reporting is required when internal channels fail',
      'Thinking that confronting the junior engineer alone resolves the issue — the firm owner is also complicit, and the board must be notified'
    ],
    diagram: null,
    lessonId: 'obligations-to-the-public',
    chapterId: 'ethics'
  },
  {
    id: 'eth-oep-ex1',
    type: 'conceptual',
    statement: 'A structural engineer at a consulting firm is asked by the firm\'s principal to seal a set of retaining wall calculations prepared by a recently hired EIT. The principal says, "You are the most senior structural engineer here — just review them and put your seal on it." The structural engineer did not supervise the EIT during the design process, was not consulted on the design approach, and only received the completed calculations for a final review. Under the Model Rules, what should the structural engineer do?',
    choices: [
      {
        id: 'c1',
        text: 'Seal the documents after a thorough review since a detailed check is equivalent to responsible charge'
      },
      {
        id: 'c2',
        text: 'Seal the documents because the principal, as firm owner, has authority to assign sealing responsibilities'
      },
      {
        id: 'c3',
        text: 'Seal the documents but add a note stating the work was prepared by the EIT'
      },
      {
        id: 'c4',
        text: 'Decline to seal the documents because the engineer did not exercise responsible charge over the work'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Rule B.2 is very specific: you cannot sign or seal documents that were not prepared under your responsible charge. "Responsible charge" means direct control and personal supervision during the work — not just a final review after the fact. The structural engineer was not involved in the design process at all. Even a thorough after-the-fact review does not satisfy the responsible charge requirement. The "seal after a thorough review" option is wrong because review is not supervision. The "the principal has authority to assign sealing" option is wrong because the principal cannot override the Model Rules. The "seal but add a note that the EIT prepared it" option is wrong because disclosing who prepared the work does not change the fact that the signer lacked responsible charge.',
    hint: 'What does "responsible charge" require — a final review, or direct control and personal supervision during the work?',
    steps: [
      {
        text: 'Identify the issue: the structural engineer is asked to seal work that was prepared without their involvement or supervision.',
        latex: null
      },
      {
        text: 'Apply Rule B.2: licensees shall not sign or seal documents unless the work was prepared under their responsible charge.',
        latex: null
      },
      {
        text: '"Responsible charge" means direct control and personal supervision. A post-completion review, no matter how thorough, does not satisfy this requirement.',
        latex: null
      },
      {
        text: 'The engineer must decline to seal. The proper solution is for the work to be redone under the supervision of a licensed PE, or for the supervising PE to seal it.',
        latex: null
      }
    ],
    handbookPage: 'p. 5, Model Rules §240.15 B.2',
    handbookFormula: '\\text{B.2: Shall not sign or seal documents not prepared under the licensee\'s responsible charge.}',
    videoUrl: null,
    traps: [
      'Equating a thorough after-the-fact review with responsible charge — the supervision must occur during the work, not after',
      'Assuming the firm principal can override sealing requirements through managerial authority'
    ],
    diagram: null,
    lessonId: 'obligations-employers-clients-peers',
    chapterId: 'ethics'
  },
  {
    id: 'eth-oep-ex2',
    type: 'conceptual',
    statement: 'A geotechnical engineer leaves Firm A to join Firm B. At Firm B, the engineer is assigned to a landfill liner design project for a county that is also a client of Firm A. While at Firm A, the engineer worked on a different project for the same county and learned confidential information about the county\'s subsurface conditions and groundwater contamination issues at the landfill site. Firm B is not aware of this prior involvement. What should the engineer do?',
    choices: [
      {
        id: 'c1',
        text: 'Disclose the conflict to Firm B and the county, and recuse from the project unless all parties provide written consent'
      },
      {
        id: 'c2',
        text: 'Use the confidential information to benefit Firm B since it will produce a better design'
      },
      {
        id: 'c3',
        text: 'Proceed with the assignment since the prior project at Firm A had a different scope'
      },
      {
        id: 'c4',
        text: 'Proceed with the assignment but avoid using any information gained at Firm A'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'This hits Rules B.4 and B.6 at the same time. The engineer has confidential information about the landfill site from prior work at Firm A. Rule B.4 says you cannot reveal facts obtained in a professional capacity without consent. Rule B.6 says you must disclose all known or potential conflicts of interest. The "proceed since the prior project had a different scope" option ignores the conflict entirely. The "use the confidential information to benefit Firm B" option is a direct violation of confidentiality. The "proceed but avoid using any Firm A information" option sounds reasonable but is impractical — the engineer cannot "unknow" what they learned, and the appearance of a conflict still exists. The only proper path is full disclosure and recusal unless everyone agrees in writing.',
    hint: 'When you carry confidential information from a prior engagement into a new assignment, which two rules are triggered?',
    steps: [
      {
        text: 'Identify the issue: the engineer possesses confidential information from Firm A that is directly relevant to the current assignment at Firm B.',
        latex: null
      },
      {
        text: 'Apply Rule B.4: licensees shall not reveal facts, data, or information obtained in a professional capacity without prior consent of the client or employer.',
        latex: null
      },
      {
        text: 'Apply Rule B.6: licensees shall disclose all known or potential conflicts of interest that could influence or appear to influence their judgment or quality of service.',
        latex: null
      },
      {
        text: 'The engineer must disclose the prior involvement and the conflict to both Firm B and the county. Recusal is required unless all parties provide informed written consent.',
        latex: null
      }
    ],
    handbookPage: 'p. 5, Model Rules §240.15 B.4, B.6',
    handbookFormula: '\\text{B.4: Shall not reveal facts obtained in professional capacity without prior consent.}',
    videoUrl: null,
    traps: [
      'Thinking that different project scopes eliminate the conflict — the issue is the confidential information, not the project boundaries',
      'Believing you can simply avoid using prior knowledge — you cannot "unknow" information, and the conflict of interest persists regardless'
    ],
    diagram: null,
    lessonId: 'obligations-employers-clients-peers',
    chapterId: 'ethics'
  },
  {
    id: 'eth-oep-ex3',
    type: 'conceptual',
    statement: 'An engineer submits a proposal to a municipality for a water treatment plant upgrade. In the proposal, the engineer lists a completed 50 MGD water treatment plant as a past project, describing herself as the "lead design engineer." In reality, she was a junior member of a 12-person team and was responsible only for the chemical feed system design. She did not lead the overall project. A competing firm discovers the discrepancy and files a complaint with the licensing board. Under the Model Rules, has the engineer violated any provision?',
    choices: [
      {
        id: 'c1',
        text: 'No — "lead design engineer" is a subjective title and the engineer did perform design work on the project'
      },
      {
        id: 'c2',
        text: 'Yes — the engineer misrepresented her degree of responsibility in a prior assignment in a presentation incidental to soliciting employment'
      },
      {
        id: 'c3',
        text: 'No — marketing materials are not held to the same standard as engineering documents'
      },
      {
        id: 'c4',
        text: 'Yes — but only because a competitor filed a complaint; the claim would otherwise be acceptable'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Rule C.1 is specific about this: licensees shall not misrepresent or exaggerate their degree of responsibility in prior assignments, and "presentations incidental to the solicitation of employment shall not misrepresent pertinent facts." A proposal to a municipality is exactly that — a solicitation of employment. Calling yourself "lead design engineer" when you designed only the chemical feed system on a 12-person team is a clear exaggeration of responsibility. The "No \u2014 subjective title" choice is wrong because "lead design engineer" is not subjective when it claims overall project leadership. The "marketing materials" choice is wrong because proposals are specifically covered by C.1. The "only because a competitor complained" choice is wrong because the violation exists independently of who reports it.',
    hint: 'Does Rule C.1 apply to project proposals submitted to potential clients?',
    steps: [
      {
        text: 'Identify the issue: the engineer described herself as "lead design engineer" on a project where she was a junior team member responsible for one subsystem.',
        latex: null
      },
      {
        text: 'Apply Rule C.1: licensees shall not misrepresent or exaggerate their degree of responsibility in prior assignments. Presentations incidental to the solicitation of employment shall not misrepresent pertinent facts.',
        latex: null
      },
      {
        text: 'A proposal to a municipality is a "presentation incidental to the solicitation of employment" — C.1 applies directly.',
        latex: null
      },
      {
        text: 'Claiming "lead design engineer" on a 50 MGD facility when the actual role was designing the chemical feed system as a junior team member is a clear exaggeration of responsibility.',
        latex: null
      }
    ],
    handbookPage: 'p. 5, Model Rules §240.15 C.1',
    handbookFormula: '\\text{C.1: Shall not misrepresent or exaggerate degree of responsibility in prior assignments.}',
    videoUrl: null,
    traps: [
      'Assuming that having any involvement in a project justifies claiming a leadership role',
      'Believing that proposals and marketing materials are exempt from Model Rules — C.1 specifically covers solicitation presentations'
    ],
    diagram: null,
    lessonId: 'obligations-employers-clients-peers',
    chapterId: 'ethics'
  },
  {
    id: 'eth-oep-ex4',
    type: 'conceptual',
    statement: 'A civil engineer serves on the board of directors of a regional water authority. The engineer\'s private consulting firm is not involved in any water authority projects. A different engineering firm submits a proposal to the water authority for a 15 million pipeline replacement project. The proposing firm\'s principal is the civil engineer\'s college roommate, and they still socialize regularly. The engineer does not have a financial interest in the proposing firm. During the board meeting to evaluate proposals, what should the engineer do?',
    choices: [
      {
        id: 'c1',
        text: 'Evaluate the proposal objectively since the engineer has no financial interest in the proposing firm'
      },
      {
        id: 'c2',
        text: 'Vote in favor of the proposal if the firm is genuinely the most qualified'
      },
      {
        id: 'c3',
        text: 'Disclose the personal relationship to the board and recuse from the evaluation and vote on this proposal'
      },
      {
        id: 'c4',
        text: 'Disclose the relationship but continue to participate in the evaluation since recusal is only required for financial conflicts'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'Rule B.8 is not limited to financial conflicts. It says that licensees serving on government bodies shall not participate in decisions with respect to professional services offered by a concern where the licensee has a "financial or personal interest." A close personal friendship with the firm principal is a personal interest — the engineer regularly socializes with this person. Even without a financial stake, the relationship creates an appearance of bias that B.8 is designed to prevent. The "evaluate objectively since there is no financial interest" choice is wrong because personal interest is not limited to money. The "vote in favor if the firm is most qualified" choice is wrong for the same reason — objective evaluation is not sufficient when a personal interest exists. The "disclose but keep participating since recusal is only for financial conflicts" choice incorrectly narrows B.8 to financial conflicts only, which contradicts the rule\'s language.',
    hint: 'Does Rule B.8 limit conflicts of interest to financial interests, or does it also cover personal interests?',
    steps: [
      {
        text: 'Identify the relationship: the engineer has a close personal friendship with the principal of the proposing firm, including regular social contact.',
        latex: null
      },
      {
        text: 'Apply Rule B.8: licensees serving as members of a government body shall not participate in decisions with respect to professional services offered by a concern where there is a financial or personal interest.',
        latex: null
      },
      {
        text: 'A close, ongoing personal friendship constitutes a "personal interest" under B.8, even without any financial connection.',
        latex: null
      },
      {
        text: 'Apply Rule B.6: all known or potential conflicts of interest must be disclosed. The personal relationship must be disclosed to the board.',
        latex: null
      },
      {
        text: 'The engineer must both disclose the relationship and recuse from the evaluation and vote. Objectivity alone does not satisfy B.8 when a personal interest exists.',
        latex: null
      }
    ],
    handbookPage: 'p. 5, Model Rules §240.15 B.6, B.8',
    handbookFormula: '\\text{B.8: Shall not participate in decisions involving firms where there is a financial or personal interest.}',
    videoUrl: null,
    traps: [
      'Reading "conflict of interest" as purely financial — B.8 explicitly includes personal interest',
      'Believing that objective evaluation is sufficient to satisfy B.8 — the rule requires recusal, not just good intentions'
    ],
    diagram: null,
    lessonId: 'obligations-employers-clients-peers',
    chapterId: 'ethics'
  },
  {
    id: 'eth-dp-ex1',
    type: 'conceptual',
    statement: 'An engineer discovers that a contractor has substituted lower-grade steel in a bridge project to cut costs. The substitution does not meet the design specifications. What is the engineer\'s primary obligation?',
    choices: [
      {
        id: 'c1',
        text: 'Report the issue to the contractor\'s supervisor'
      },
      {
        id: 'c2',
        text: 'Consult with the client before taking any action'
      },
      {
        id: 'c3',
        text: 'Allow the substitution if the bridge can still carry the design load'
      },
      {
        id: 'c4',
        text: 'Hold the public safety paramount and report to the appropriate authority'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'The NCEES Model Rules make it crystal clear: the engineer\'s paramount obligation is to protect public health, safety, and welfare. When safety is at stake, you report to the appropriate authority. You do not negotiate, wait, or let cost considerations override safety.',
    hint: 'Think about the engineer\'s paramount obligation under the Model Rules.',
    steps: [
      {
        text: 'The fundamental canon: Engineers shall hold paramount the safety, health, and welfare of the public.',
        latex: null
      },
      {
        text: 'The steel substitution does not meet design specifications, creating a safety risk.',
        latex: null
      },
      {
        text: 'The engineer must report to the appropriate authority to protect the public.',
        latex: null
      }
    ],
    handbookPage: 'p. 4',
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Thinking the contractor\'s supervisor is sufficient — safety issues go to authorities',
      'Believing structural adequacy overrides specification compliance'
    ],
    diagram: null,
    lessonId: 'definitions-practice-of-engineering',
    chapterId: 'ethics'
  },
  {
    id: 'eth-dp-ex2',
    type: 'conceptual',
    statement: 'Under the NCEES Model Rules, which of the following is considered "practice of engineering"?',
    choices: [
      {
        id: 'c1',
        text: 'Operating construction equipment on a job site'
      },
      {
        id: 'c2',
        text: 'Performing engineering analysis and design that affects public safety'
      },
      {
        id: 'c3',
        text: 'Selling engineering software to firms'
      },
      {
        id: 'c4',
        text: 'Teaching engineering courses at a university'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The practice of engineering specifically involves applying engineering principles in analysis, design, or consultation that affects public safety. Operating equipment, selling software, and teaching are not "practice of engineering" as defined by the Model Rules, even though they are related to the field.',
    hint: 'The definition focuses on analysis and design that affects public safety.',
    steps: [
      {
        text: 'The Model Rules define "practice of engineering" as any service requiring engineering education and training.',
        latex: null
      },
      {
        text: 'It specifically involves analysis, design, or consultation where public safety is affected.',
        latex: null
      },
      {
        text: 'Operating equipment, selling products, and teaching do not meet this definition.',
        latex: null
      }
    ],
    handbookPage: 'p. 4',
    handbookFormula: null,
    videoUrl: null,
    traps: ['Confusing engineering-adjacent activities with the legal definition of practice'],
    diagram: null,
    lessonId: 'definitions-practice-of-engineering',
    chapterId: 'ethics'
  },
  {
    id: 'eth-dp-ex3',
    type: 'conceptual',
    statement: 'A mechanical engineering graduate working at a civil engineering firm updates her LinkedIn profile to read "Engineer at XYZ Engineering Consultants." She has not passed the FE exam and holds no engineering certification or license. A potential client sees the profile and contacts the firm requesting her specifically for a dam inspection. Under the Model Law, which statement is most accurate?',
    choices: [
      {
        id: 'c1',
        text: 'No violation has occurred because "Engineer" is a common job title and does not imply licensure'
      },
      {
        id: 'c2',
        text: 'The graduate is construed to be practicing engineering by using a title that implies she is a Professional Engineer'
      },
      {
        id: 'c3',
        text: 'The firm is solely responsible because they allowed her to use the title on company-related platforms'
      },
      {
        id: 'c4',
        text: 'A violation only occurs if the graduate actually performs the dam inspection'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The "holding out" clause in the Model Law is broader than most people expect. Under section 110.20 A.3(c), you are construed to be practicing engineering if you use any title that could imply you are a licensed PE. Even though "Engineer" is used casually in many industries, in a professional context on LinkedIn — attached to an engineering firm — it creates the impression of licensure. The key is that the violation happens at the point of representation, not at the point of doing work. The "no violation, Engineer is a common title" choice is wrong because context matters; attached to an engineering firm, the title implies licensure. The "firm is solely responsible" choice is wrong because both the individual and the firm can be liable, but the individual bears personal responsibility for their own representations. The "violation only if she performs the inspection" choice is wrong because the violation is the representation itself, not the subsequent work.',
    hint: 'Does the Model Law require someone to actually perform engineering work to violate the "holding out" provisions, or is the representation itself enough?',
    steps: [
      {
        text: 'Identify the key issue: an unlicensed individual is using the title "Engineer" in a professional context associated with an engineering firm.',
        latex: null
      },
      {
        text: 'Apply §110.20 A.3(c): a person is construed to practice engineering if they use any title that implies they are a Professional Engineer.',
        latex: null
      },
      {
        text: 'The LinkedIn profile, combined with the firm name, creates the impression that the graduate is a licensed engineer — this constitutes "holding out."',
        latex: null
      },
      {
        text: 'The violation occurs at the point of representation, not when engineering work is actually performed. The fact that a client sought her out based on the title reinforces the misleading nature of the representation.',
        latex: null
      }
    ],
    handbookPage: 'p. 6, Model Law §110.20 A.3(c)',
    handbookFormula: '\\text{§110.20 A.3(c): Uses any title that implies the individual is a Professional Engineer.}',
    videoUrl: null,
    traps: [
      'Assuming that "Engineer" as a job title is always harmless — context and the Model Law definition matter',
      'Believing a violation requires actual engineering work rather than just the representation'
    ],
    diagram: null,
    lessonId: 'definitions-practice-of-engineering',
    chapterId: 'ethics'
  },
  {
    id: 'eth-dp-ex4',
    type: 'conceptual',
    statement: 'A licensed PE retires and lets her license lapse. Two years later, a former client asks her to review a set of structural calculations prepared by another firm and provide a written opinion on their adequacy. The retired PE would review the calculations at home, write an opinion letter, and sign it with her name followed by "PE (Retired)." She would not stamp or seal the document. Under the Model Law, which of the following best describes this situation?',
    choices: [
      {
        id: 'c1',
        text: 'This violates the Model Law because providing engineering opinions for compensation with a lapsed license constitutes unauthorized practice, and using "PE (Retired)" implies current licensure'
      },
      {
        id: 'c2',
        text: 'This is acceptable because reviewing another firm\'s work is not "practice of engineering"'
      },
      {
        id: 'c3',
        text: 'This is acceptable because she is not stamping or sealing the document'
      },
      {
        id: 'c4',
        text: 'This is acceptable as long as she discloses that her license is no longer active in the opinion letter'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'This one layers multiple violations. First, reviewing structural calculations and writing a professional opinion on their adequacy is absolutely "practice of engineering" under §110.20 A.3 — it requires engineering judgment and affects public safety. Second, her license is lapsed, which means she is not currently licensed. Third, signing as "PE (Retired)" uses a title derived from "Professional Engineer," which constitutes holding herself out as a PE under §110.20 A.3(c). It does not matter that she once held the license or that she is not using a stamp. The Model Law does not have a "retired PE" designation that allows continued practice. The "not stamping or sealing" choice is wrong because the seal is not the only trigger — the engineering opinion itself is practice. The "reviewing another firm\'s work is not practice" choice is wrong because reviewing calculations for adequacy requires engineering judgment. The "acceptable if she discloses her license is inactive" choice is wrong because a disclosure does not cure unauthorized practice.',
    hint: 'Consider two separate issues: whether the activity constitutes practice of engineering, and whether a lapsed licensee can use any form of the PE title.',
    steps: [
      {
        text: 'Determine whether the activity is "practice of engineering": reviewing structural calculations and opining on their adequacy requires engineering education, training, and judgment, and impacts public safety. This is practice of engineering under §110.20 A.3.',
        latex: null
      },
      {
        text: 'Determine the licensee\'s status: the PE license has lapsed. A lapsed license is not an active license — the individual is not currently authorized to practice.',
        latex: null
      },
      {
        text: 'Apply §150.30: practicing engineering without a current, valid license is unauthorized practice.',
        latex: null
      },
      {
        text: 'Apply §110.20 A.3(c): signing as "PE (Retired)" uses a derivative of the Professional Engineer title, which constitutes holding oneself out as a PE. The Model Law does not recognize "PE (Retired)" as a protected or authorized designation.',
        latex: null
      },
      {
        text: 'A disclosure does not cure the violation — the activity itself is unauthorized, regardless of how transparently it is described.',
        latex: null
      }
    ],
    handbookPage: 'p. 6, Model Law §110.20 A.3; p. 10, §150.30',
    handbookFormula: '\\text{§150.30: Unlicensed individuals shall not practice or offer to practice engineering.}',
    videoUrl: null,
    traps: [
      'Focusing on the absence of a stamp/seal while ignoring that the opinion letter itself constitutes practice of engineering',
      'Assuming "PE (Retired)" is a recognized designation that allows limited practice — the Model Law has no such provision'
    ],
    diagram: null,
    lessonId: 'definitions-practice-of-engineering',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ld-ex1',
    type: 'conceptual',
    statement: 'An engineer graduated with a bachelor\'s degree from an EAC/ABET-accredited program, passed the FE exam, and then completed a master\'s degree in structural engineering. The engineer has been working under a licensed PE for two and a half years since completing the master\'s degree. Is the engineer eligible to apply for PE licensure?',
    choices: [
      {
        id: 'c1',
        text: 'No — the engineer needs four years of experience regardless of the master\'s degree'
      },
      {
        id: 'c2',
        text: 'No — the engineer needs at least three years of experience after the master\'s degree'
      },
      {
        id: 'c3',
        text: 'Yes — a master\'s degree reduces the experience requirement to two years'
      },
      {
        id: 'c4',
        text: 'Yes — the combined education (bachelor\'s plus master\'s) waives the experience requirement entirely'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The Model Law has a clear experience reduction schedule for advanced degrees. A bachelor\'s requires four years. A master\'s reduces it to three years. A doctorate (with FE passed) reduces it to two years. This engineer has a master\'s and two and a half years of experience — close, but still half a year short of the three-year requirement. The "four years regardless of the master\'s" choice is wrong because the master\'s does reduce the requirement, just not to two years. The "master\'s reduces the requirement to two years" choice confuses the master\'s reduction (three years) with the doctorate reduction (two years). The "combined education waives the experience requirement entirely" choice is completely wrong — no amount of education waives the experience requirement.',
    hint: 'How many years of experience does the Model Law require after a master\'s degree?',
    steps: [
      {
        text: 'Review §130.10 B.2: PE licensure requires passing the FE and PE exams plus completing progressive engineering experience after the qualifying degree.',
        latex: null
      },
      {
        text: 'Experience requirements by degree level: bachelor\'s = 4 years, master\'s = 3 years, doctorate (with FE) = 2 years.',
        latex: null
      },
      {
        text: 'The engineer has a master\'s degree, which reduces the requirement to 3 years. With 2.5 years of experience, the engineer is not yet eligible.',
        latex: null
      },
      {
        text: 'Note: the degree used to meet education requirements cannot also count as experience credit — no double-dipping (§130.10 B.2.d).',
        latex: null
      }
    ],
    handbookPage: 'p. 8-9, Model Law §130.10 B.2.a',
    handbookFormula: '\\text{§130.10: Bachelor\'s = 4 yr; Master\'s = 3 yr; Doctorate + FE = 2 yr experience.}',
    videoUrl: null,
    traps: [
      'Confusing the master\'s reduction (3 years) with the doctorate reduction (2 years)',
      'Assuming that any advanced degree cuts the requirement in half'
    ],
    diagram: null,
    lessonId: 'licensure-path-disciplinary-action',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ld-ex2',
    type: 'conceptual',
    statement: 'A licensed PE is found guilty of a misdemeanor charge of shoplifting. The offense is completely unrelated to the engineer\'s professional practice, and the engineer has no prior disciplinary history. Can the state licensing board take action against the engineer\'s license based on this conviction?',
    choices: [
      {
        id: 'c1',
        text: 'Yes — any criminal conviction is grounds for disciplinary action under the Model Law'
      },
      {
        id: 'c2',
        text: 'No — only felony convictions trigger disciplinary action under the Model Law'
      },
      {
        id: 'c3',
        text: 'No — misdemeanors are not grounds for discipline unless they are directly related to engineering practice'
      },
      {
        id: 'c4',
        text: 'Yes — shoplifting is a crime of dishonesty, and dishonesty-related misdemeanors are grounds for discipline'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'The Model Law draws a clear line between felonies and misdemeanors. For felonies, any conviction triggers discipline — does not matter if it is related to engineering. For misdemeanors, the standard is narrower: only those that reflect on the licensee\'s ability to practice with good character, or that involve dishonesty or moral turpitude. Shoplifting is a crime of dishonesty — taking something that is not yours through deception. So even though it has nothing to do with engineering, it qualifies. The "any criminal conviction is grounds" option is too broad — not every misdemeanor qualifies, only dishonesty-related ones. The "misdemeanors are not grounds unless directly related to engineering" option is wrong because the dishonesty exception exists. The "only felony convictions trigger discipline" option is wrong because it ignores the misdemeanor provision entirely.',
    hint: 'The Model Law treats felonies and misdemeanors differently. For misdemeanors, what specific characteristic makes them grounds for discipline?',
    steps: [
      {
        text: 'Apply §150.10 A.3: felony convictions of any kind are grounds for discipline, whether or not related to engineering.',
        latex: null
      },
      {
        text: 'Apply §150.10 A.4: misdemeanor convictions are grounds for discipline only if they are related to engineering practice OR reflect dishonesty, fraud, deceit, or misrepresentation.',
        latex: null
      },
      {
        text: 'Shoplifting is a crime involving dishonesty (taking property through deception). It falls under the dishonesty-related misdemeanor provision.',
        latex: null
      },
      {
        text: 'The board can take disciplinary action even though the offense is unrelated to engineering, because the dishonesty element independently qualifies.',
        latex: null
      }
    ],
    handbookPage: 'p. 9, Model Law §150.10 A.3-A.4',
    handbookFormula: '\\text{§150.10 A.4: Misdemeanors involving dishonesty, fraud, deceit, or misrepresentation are grounds for discipline.}',
    videoUrl: null,
    traps: [
      'Applying the felony rule (any conviction) to misdemeanors — misdemeanors have a narrower standard',
      'Assuming that only engineering-related offenses can trigger discipline — dishonesty-related misdemeanors also qualify'
    ],
    diagram: null,
    lessonId: 'licensure-path-disciplinary-action',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ld-ex3',
    type: 'conceptual',
    statement: 'An engineer licensed in State A accepts a project in State B, where she is not licensed. The project involves designing a stormwater management system for a commercial development. The engineer plans to complete the design in State A and have a PE licensed in State B review and seal the documents. Under the Model Law, which statement is most accurate?',
    choices: [
      {
        id: 'c1',
        text: 'This arrangement is acceptable because the State B PE will exercise responsible charge by reviewing and sealing the documents'
      },
      {
        id: 'c2',
        text: 'This arrangement is acceptable because the engineer holds a valid license in State A, which authorizes nationwide practice'
      },
      {
        id: 'c3',
        text: 'This arrangement violates the Model Law because the engineer is practicing in State B without a license, and the State B PE cannot seal work not prepared under their responsible charge'
      },
      {
        id: 'c4',
        text: 'This arrangement is acceptable as long as the engineer obtains a temporary practice permit from State B'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'This scenario has two separate violations stacked on each other. First, the State A engineer is performing engineering services for a project in State B without holding a State B license — that is practicing without a license in that jurisdiction (Rule A.10 requires compliance with the laws of every jurisdiction where you practice). Second, the State B PE is being asked to seal documents they did not prepare under their responsible charge — they would just be reviewing someone else\'s completed work, which violates B.2. The "State B PE exercises responsible charge by reviewing and sealing" choice is wrong because a review is not responsible charge. The "State A license authorizes nationwide practice" choice is wrong because PE licensure is jurisdiction-specific, not nationwide. The "temporary practice permit" choice might be possible in some states, but the question asks about the described arrangement, which involves neither a temporary permit nor responsible charge.',
    hint: 'Consider two separate issues: the State A engineer practicing in State B, and the State B PE sealing work not prepared under their supervision.',
    steps: [
      {
        text: 'Apply Rule A.10: licensees shall comply with the licensing laws of all jurisdictions where they practice. The State A engineer is offering engineering services in State B without a State B license.',
        latex: null
      },
      {
        text: 'Apply Rule B.2: the State B PE cannot sign and seal documents that were not prepared under their responsible charge. A post-completion review does not constitute responsible charge.',
        latex: null
      },
      {
        text: 'PE licensure is jurisdiction-specific. A license in State A does not authorize practice in State B unless the engineer obtains a State B license (by examination or comity) or a temporary practice permit if available.',
        latex: null
      },
      {
        text: 'Both the unlicensed practice and the improper sealing arrangement violate the Model Law independently.',
        latex: null
      }
    ],
    handbookPage: 'p. 5, Model Rules §240.15 A.10, B.2; p. 9, §130.10 (comity provisions)',
    handbookFormula: '\\text{A.10: Comply with licensing laws of every jurisdiction where you practice.}',
    videoUrl: null,
    traps: [
      'Assuming that a license in one state authorizes practice in another — PE licensure is jurisdiction-specific',
      'Believing that a local PE reviewing and sealing the work cures the responsible charge problem — review is not supervision'
    ],
    diagram: null,
    lessonId: 'licensure-path-disciplinary-action',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ld-ex4',
    type: 'conceptual',
    statement: 'A licensing board suspends a PE\'s license for two years due to negligence on a bridge inspection. During the suspension period, the engineer continues to work at the same firm as a "project coordinator." In this role, the engineer reviews incoming project proposals, assigns tasks to licensed PEs, sets project schedules, attends client meetings to discuss design progress, and provides technical guidance to junior engineers on structural detailing. The engineer does not sign or seal any documents. Has the engineer violated the terms of the suspension?',
    choices: [
      {
        id: 'c1',
        text: 'Yes — providing technical guidance on structural detailing and discussing design progress with clients constitutes practice of engineering, regardless of the job title or whether documents are sealed'
      },
      {
        id: 'c2',
        text: 'No — the role is purely managerial and does not constitute engineering practice'
      },
      {
        id: 'c3',
        text: 'No — the engineer is not signing or sealing documents and therefore is not practicing engineering'
      },
      {
        id: 'c4',
        text: 'It depends on whether the firm\'s other PEs are supervising the engineer\'s work'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Job titles do not determine whether someone is practicing engineering — the nature of the work does. Some of the coordinator\'s tasks are genuinely managerial: setting schedules and assigning tasks to PEs. But two activities cross the line. First, providing technical guidance on structural detailing requires engineering judgment and education — that is practice of engineering under §110.20 A.3. Second, discussing design progress with clients constitutes offering engineering services. The fact that no documents are signed or sealed is irrelevant — the Model Law defines practice broadly, and the seal is only one trigger. Under §150.10 A.9, practicing while suspended is a separate violation that can lead to permanent revocation. The "not signing or sealing documents" choice focuses too narrowly on sealing. The "purely managerial" choice ignores the technical guidance component. The "depends on whether other PEs are supervising" choice is wrong because supervised practice by a suspended licensee is still unauthorized practice.',
    hint: 'Does the Model Law definition of "practice of engineering" require signing and sealing documents, or does it cover any service requiring engineering judgment?',
    steps: [
      {
        text: 'Apply §110.20 A.3: practice of engineering includes any service requiring engineering education, training, and experience that impacts public health, safety, and welfare.',
        latex: null
      },
      {
        text: 'Review the engineer\'s activities: setting schedules and assigning tasks are managerial. But providing structural detailing guidance and discussing design with clients requires engineering judgment.',
        latex: null
      },
      {
        text: 'The definition of practice is not limited to signing and sealing. Technical guidance on structural detailing is a service that requires engineering education and directly impacts structural safety.',
        latex: null
      },
      {
        text: 'Apply §150.10 A.9: violating any term of a board order (here, the suspension) is independent grounds for further discipline, potentially including permanent revocation.',
        latex: null
      },
      {
        text: 'The job title "project coordinator" does not change the nature of the work. The Model Law looks at the activity, not the title.',
        latex: null
      }
    ],
    handbookPage: 'p. 6, Model Law §110.20 A.3; p. 9, §150.10 A.9',
    handbookFormula: '\\text{§150.10 A.9: Violation of any term of a board order is grounds for further discipline.}',
    videoUrl: null,
    traps: [
      'Equating "not sealing documents" with "not practicing engineering" — the Model Law definition is much broader than the seal',
      'Assuming a managerial job title insulates the engineer from practicing engineering — the nature of the activities determines whether practice occurs'
    ],
    diagram: null,
    lessonId: 'licensure-path-disciplinary-action',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ips-ex1',
    type: 'conceptual',
    statement: 'A structural engineering firm creates a new type of seismic base-isolation bearing and files a utility patent for the design. A competing firm independently develops a functionally identical bearing two years later without any knowledge of the first firm\'s work. Under U.S. patent law, which of the following is correct?',
    choices: [
      {
        id: 'c1',
        text: 'The competing firm infringes on the patent regardless of independent development'
      },
      {
        id: 'c2',
        text: 'Independent development is a valid defense against patent infringement'
      },
      {
        id: 'c3',
        text: 'The patent is invalid because two firms arrived at the same design'
      },
      {
        id: 'c4',
        text: 'Both firms share equal rights to the patent since the invention was obvious'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Patents give the holder exclusive rights to the invention for 20 years, regardless of whether someone else independently comes up with the same thing. That is the core trade-off of the patent system: you publicly disclose your invention, and in return, nobody else can make, use, or sell it without your permission. Independent development is NOT a defense for patents — that defense only works for trade secrets. The "independent development is a valid defense" choice confuses the patent rule with the trade-secret rule. The "patent is invalid" choice is wrong because two people arriving at the same design does not invalidate a patent. The "both firms share equal rights" choice invents a sharing concept that does not exist in patent law.',
    hint: 'Think about what distinguishes a patent from a trade secret. Which one protects against independent discovery?',
    steps: [
      {
        text: 'A utility patent grants exclusive rights to make, use, and sell an invention for 20 years from the filing date.',
        latex: null
      },
      {
        text: 'Patent rights are absolute — independent development by a competitor is NOT a defense against infringement.',
        latex: null
      },
      {
        text: 'This is the key difference from trade secrets: if someone independently discovers a trade secret, the original holder has no legal recourse. Patents are the opposite.',
        latex: null
      },
      {
        text: 'The choice "Independent development is a valid defense against patent infringement" describes the trade-secret rule, not the patent rule. The choices claiming the patent is invalid or that both firms share equal rights misunderstand how patent validity works.',
        latex: null
      }
    ],
    handbookPage: 'p. 12, Intellectual Property — Patents',
    handbookFormula: '\\text{Patent: exclusive right to make, use, sell an invention for 20 years from filing date.}',
    videoUrl: null,
    traps: [
      'Confusing the patent rule with the trade-secret rule — independent discovery is only a defense for trade secrets',
      'Assuming that identical independent invention invalidates a patent'
    ],
    diagram: null,
    lessonId: 'intellectual-property-sustainability',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ips-ex2',
    type: 'conceptual',
    statement: 'A municipality hires an engineering firm to design a pedestrian bridge. The firm produces detailed CAD drawings, structural calculations, and a final design report. The contract is silent on intellectual property ownership. Under standard copyright principles, who owns the copyright to the design documents?',
    choices: [
      {
        id: 'c1',
        text: 'The municipality, because they paid for the work'
      },
      {
        id: 'c2',
        text: 'The engineering firm, because the engineers are the authors of the original works'
      },
      {
        id: 'c3',
        text: 'Both parties share ownership equally by default'
      },
      {
        id: 'c4',
        text: 'No one — engineering drawings cannot be copyrighted'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Copyright belongs to the creator of the original work unless there is a written agreement transferring ownership, or the work qualifies as "work for hire" under specific conditions. When a firm is an independent contractor (not an employee of the municipality), the default is that the firm retains copyright to its own documents. The municipality paid for the service, not the IP rights. The "municipality, because they paid for the work" option is the most common misconception — paying for work does not automatically transfer copyright. The "share ownership equally" option invents a default sharing arrangement that does not exist. The "cannot be copyrighted" option is flat wrong — engineering drawings, reports, and calculations are copyrightable works of authorship.',
    hint: 'Copyright belongs to the author by default. Paying someone to create a work does not automatically transfer the copyright unless the contract says so.',
    steps: [
      {
        text: 'Copyright automatically vests in the author (creator) of an original work at the moment of creation.',
        latex: null
      },
      {
        text: 'When a firm is hired as an independent contractor, the firm is the author of its deliverables unless the contract includes a written IP assignment.',
        latex: null
      },
      {
        text: 'The contract is silent on IP, so the default rule applies: the engineering firm owns the copyright.',
        latex: null
      },
      {
        text: 'The municipality has an implied license to use the documents for the project, but ownership remains with the firm.',
        latex: null
      }
    ],
    handbookPage: 'p. 12, Intellectual Property — Copyrights',
    handbookFormula: '\\text{Copyright: exclusive rights to reproduce, distribute, perform, and display original works of authorship.}',
    videoUrl: null,
    traps: [
      'Assuming the client owns the copyright because they paid for the work',
      'Believing engineering drawings cannot be copyrighted'
    ],
    diagram: null,
    lessonId: 'intellectual-property-sustainability',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ips-ex3',
    type: 'conceptual',
    statement: 'A city council asks an engineering team to recommend a stormwater management approach for a new development. The team evaluates three options: (A) conventional concrete pipes with lowest upfront cost, (B) bioswales and rain gardens with moderate cost but reduced downstream flooding and improved water quality, and (C) an underground cistern system with the highest cost and best flood control. Which option best reflects the principles of sustainable engineering as defined in the FE Handbook?',
    choices: [
      {
        id: 'c1',
        text: 'Option A, because minimizing cost is the primary engineering obligation'
      },
      {
        id: 'c2',
        text: 'Option B, because it balances economic feasibility with environmental and social benefits across the project lifecycle'
      },
      {
        id: 'c3',
        text: 'Option C, because the most expensive option always provides the most sustainable outcome'
      },
      {
        id: 'c4',
        text: 'All three options are equally sustainable since they all manage stormwater'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Sustainable engineering is about the triple bottom line: economic viability, environmental protection, and social benefit. Option B hits all three — it is affordable (not the cheapest, but feasible), reduces downstream flooding (social benefit), and improves water quality (environmental benefit). Option A only optimizes for cost, ignoring environmental and social impact. Option C sounds good, but "most expensive = most sustainable" is not a valid principle — sustainability requires economic feasibility too. The "all three are equally sustainable" option dodges the question entirely; simply managing stormwater is not the same as doing it sustainably.',
    hint: 'Sustainable engineering balances three pillars: economic, environmental, and social. Which option addresses all three without ignoring any?',
    steps: [
      {
        text: 'Recall the triple bottom line: people (social), planet (environmental), profit (economic). Sustainable engineering requires balance among all three.',
        latex: null
      },
      {
        text: 'Option A minimizes cost but ignores environmental and social considerations — that is cost optimization, not sustainable design.',
        latex: null
      },
      {
        text: 'Option B has moderate cost (economically feasible), reduces flooding (social), and improves water quality (environmental) — it balances all three pillars.',
        latex: null
      },
      {
        text: 'Option C assumes highest cost equals best sustainability, but the FE Handbook requires economic feasibility as a pillar. Overspending without proportional benefit is not sustainable.',
        latex: null
      }
    ],
    handbookPage: 'p. 13, Societal Considerations — Sustainability',
    handbookFormula: '\\text{Sustainable = technically viable + economically feasible + environmentally and socially responsible.}',
    videoUrl: null,
    traps: [
      'Equating lowest cost with best engineering practice',
      'Assuming the most expensive option is automatically the most sustainable'
    ],
    diagram: null,
    lessonId: 'intellectual-property-sustainability',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ips-ex4',
    type: 'conceptual',
    statement: 'A geotechnical engineering firm develops a proprietary soil stabilization technique that gives them a major competitive advantage. An engineer who helped develop the technique leaves the firm (without a non-compete agreement) and begins using the same technique at a new employer. The original firm sues for trade-secret misappropriation. Which factor is MOST critical to the original firm\'s case?',
    choices: [
      {
        id: 'c1',
        text: 'Whether the departing engineer signed a confidentiality or non-disclosure agreement'
      },
      {
        id: 'c2',
        text: 'Whether the original firm filed a patent for the technique'
      },
      {
        id: 'c3',
        text: 'Whether the departing engineer was the sole inventor of the technique'
      },
      {
        id: 'c4',
        text: 'Whether the new employer is in the same geographic market'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Trade-secret protection hinges on the owner taking reasonable steps to keep the information confidential. The single most critical piece of evidence is a written confidentiality or non-disclosure agreement (NDA). Without an NDA, the firm has a much weaker case because they failed to demonstrate that they treated the technique as a secret. The FE Handbook specifically states that trade secrets "require a written agreement between parties" for protection. The patent-filing choice is wrong because filing a patent would mean publicly disclosing the technique — you cannot have both a patent and a trade secret for the same thing. The sole-inventor choice is irrelevant because trade-secret rights belong to the firm, not individual inventors. The geographic-market choice is not a factor in trade-secret law.',
    hint: 'Trade secrets require the owner to take reasonable measures to maintain secrecy. What is the most concrete evidence of that effort?',
    steps: [
      {
        text: 'Trade-secret protection requires: (1) the information provides competitive advantage, (2) the owner took reasonable steps to maintain its secrecy, and (3) the secrecy obligation is documented, most directly via a written confidentiality/non-disclosure agreement.',
        latex: null
      },
      {
        text: 'A confidentiality or non-disclosure agreement is the most direct evidence that the firm treated the technique as confidential and that the engineer understood the obligation.',
        latex: null
      },
      {
        text: 'Without a written agreement, the firm\'s claim is significantly weakened — the handbook emphasizes that trade secrets offer "little protection without" such an agreement.',
        latex: null
      },
      {
        text: 'The patent-filing choice is a contradiction: filing a patent means publicly disclosing the technique, which destroys trade-secret status.',
        latex: null
      },
      {
        text: 'The sole-inventor choice misplaces ownership. In employment contexts, the firm typically owns trade secrets developed on the job, not the individual engineer.',
        latex: null
      }
    ],
    handbookPage: 'p. 12, Intellectual Property — Trade Secrets',
    handbookFormula: '\\text{Trade secret: requires written agreement between parties; little protection without one.}',
    videoUrl: null,
    traps: [
      'Thinking a patent application strengthens a trade-secret claim — patents require disclosure, which destroys the secret',
      'Focusing on who invented the technique rather than whether confidentiality measures were in place'
    ],
    diagram: null,
    lessonId: 'intellectual-property-sustainability',
    chapterId: 'ethics'
  },
  {
    id: 'eth-con-ex1',
    type: 'conceptual',
    statement: 'A project owner wants maximum cost certainty for a well-defined scope of work and is willing to pay a premium for it. Which contract type best meets this goal?',
    choices: [
      { id: 'c1', text: 'Lump-sum (fixed-price) contract' },
      { id: 'c2', text: 'Cost-plus-fixed-fee contract' },
      { id: 'c3', text: 'Cost-plus-percentage-of-cost contract' },
      { id: 'c4', text: 'Time-and-materials contract' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'A lump-sum contract fixes the price, giving the owner cost certainty and pushing overrun risk onto the contractor — which is exactly what the owner wants for a well-defined scope. Cost-plus and time-and-materials contracts reimburse actual costs, so the owner bears the overrun risk and has little cost certainty.',
    hint: 'Which contract gives the OWNER a fixed, known price?',
    steps: [
      { text: 'Cost certainty for the owner means a fixed price.', latex: null },
      { text: 'Lump sum fixes the price; cost-plus/T&M reimburse actual cost.', latex: null },
      { text: 'So a lump-sum contract best fits a well-defined scope needing cost certainty.', latex: null },
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing cost-plus (owner risk) with lump sum (contractor risk)',
      'Assuming T&M gives cost certainty — it does not',
    ],
    diagram: null,
    lessonId: 'engineering-contracts',
    chapterId: 'ethics'
  },
  {
    id: 'eth-con-ex2',
    type: 'conceptual',
    statement: 'Two parties sign a written agreement, but only one party promises to perform — the other gives nothing of value in return. Is this a binding contract?',
    choices: [
      { id: 'c1', text: 'No — it lacks consideration, since value must be exchanged by both parties' },
      { id: 'c2', text: 'Yes — a signed written agreement is always binding' },
      { id: 'c3', text: 'Yes — as long as one party performs, the contract is valid' },
      { id: 'c4', text: 'No — because the agreement was not notarized' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Consideration — value exchanged by BOTH sides — is a required element of a contract. A one-sided promise (essentially a gift) is not enforceable as a contract no matter how it is signed. The "a signed written agreement is always binding" option overstates the power of a signature, the "as long as one party performs" option ignores the mutual-exchange requirement, and the "not notarized" option is wrong because notarization is not a formation element.',
    hint: 'Which required element is missing when only one side gives value?',
    steps: [
      { text: 'A valid contract needs consideration from both parties.', latex: null },
      { text: 'Here only one party gives value — no mutual exchange.', latex: null },
      { text: 'Without consideration, it is not a binding contract.', latex: null },
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Assuming a signature alone makes an agreement enforceable',
      'Thinking notarization is required for validity',
    ],
    diagram: null,
    lessonId: 'engineering-contracts',
    chapterId: 'ethics'
  },
  {
    id: 'eth-liab-ex1',
    type: 'conceptual',
    statement: 'A homeowner sues an engineer for negligence after a retaining wall settles. The engineer’s design met the standard of care of competent practitioners at the time. What is the most likely outcome?',
    choices: [
      { id: 'c1', text: 'The engineer is likely not liable, because meeting the standard of care is the legal benchmark — not guaranteeing a perfect result' },
      { id: 'c2', text: 'The engineer is automatically liable because the wall settled' },
      { id: 'c3', text: 'The engineer is liable only if the homeowner can prove intent' },
      { id: 'c4', text: 'The engineer is liable because engineers guarantee their designs' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Engineers are judged against the standard of care, not against perfection. If the design met what a reasonably competent engineer would have done, negligence is generally not established even though a problem later appeared. The "automatically liable because the wall settled" choice assumes any failure equals liability, the "liable only if intent is proven" choice imports intent (not required for negligence), and the "engineers guarantee their designs" choice wrongly treats engineers as guarantors.',
    hint: 'Engineers are not guarantors — what benchmark actually determines negligence?',
    steps: [
      { text: 'Liability for negligence turns on the standard of care.', latex: null },
      { text: 'The design met that standard, so a key element (breach) is absent.', latex: null },
      { text: 'Therefore the engineer is likely not liable.', latex: null },
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Treating any failure as automatic liability',
      'Requiring intent for a negligence claim',
    ],
    diagram: null,
    lessonId: 'professional-liability',
    chapterId: 'ethics'
  },
  {
    id: 'eth-liab-ex2',
    type: 'conceptual',
    statement: 'In a negligence claim against an engineer, the plaintiff proves the engineer owed a duty and breached it, but cannot show that the breach actually caused any measurable harm. Can the negligence claim succeed?',
    choices: [
      { id: 'c1', text: 'No — all four elements (duty, breach, causation, damages) must be proven' },
      { id: 'c2', text: 'Yes — proving duty and breach is sufficient' },
      { id: 'c3', text: 'Yes — causation is not part of a negligence claim' },
      { id: 'c4', text: 'No — but only because intent was not shown' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Negligence requires all four elements: duty, breach, causation, and damages. Without causation linking the breach to actual measurable harm, the claim fails even if duty and breach are clear. The "duty and breach is sufficient" option drops two elements, the "causation is not part of a negligence claim" option wrongly removes causation, and the "only because intent was not shown" option misstates the reason (intent is not a negligence element at all).',
    hint: 'How many elements must a negligence plaintiff prove, and is causation one of them?',
    steps: [
      { text: 'Negligence elements: duty, breach, causation, damages.', latex: null },
      { text: 'Causation and damages are missing here.', latex: null },
      { text: 'Missing any element defeats the claim, so it cannot succeed.', latex: null },
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Believing duty + breach alone establishes negligence',
      'Forgetting causation and damages are required',
    ],
    diagram: null,
    lessonId: 'professional-liability',
    chapterId: 'ethics'
  },
];

export default PROBLEMS;
