export default {
  id: 'licensure-path-disciplinary-action',
  name: 'Licensure Path & Disciplinary Action',
  subtopicId: 'licensure-and-law',
  application:
    "The licensure path is the roadmap every engineer follows from student to PE — and the FE exam you're studying for is one of the checkpoints on it. The exam tests whether you know the sequence (education → FE → experience → PE) and the requirements at each stage. It also tests the flip side: what gets your license taken away. Civil engineers work on public infrastructure where mistakes can be catastrophic, so the board has broad power to discipline licensees for fraud, incompetence, misconduct, and even felony convictions unrelated to engineering. Knowing these grounds helps you spot the violation in scenario questions.",
  content: [
    {
      type: 'text',
      body: 'Model Law §130.10 lays out the requirements for licensure, and §§150.10/150.30 list the grounds for disciplinary action. Together they form a complete picture: how you get your license and how you lose it.',
    },
    { type: 'heading', body: 'The Licensure Ladder' },
    {
      type: 'text',
      body: 'Five general requirements apply to everyone seeking licensure: (1) good character and reputation, (2) meeting education criteria set by the board, (3) meeting experience criteria, (4) passing the required examinations, and (5) submitting five references acceptable to the board.',
    },
    { type: 'heading', body: 'Engineer Intern → Professional Engineer' },
    {
      type: 'text',
      body: 'The path has two stages. First, become an Engineer Intern by graduating from an EAC/ABET-accredited program (or meeting the NCEES Engineering Education Standard) and passing the FE exam. Second, become a PE by passing the PE exam and completing four years of progressive engineering experience after your qualifying degree.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: "Experience credit for graduate degrees: a master's reduces the requirement to three years, a doctoral degree (with FE passed) to two years. But a degree used to satisfy education requirements can't also count as experience — no double-dipping. And graduate degree credit can't overlap with work experience credit.",
    },
    { type: 'heading', body: 'Comity (Reciprocal Licensure)' },
    {
      type: 'text',
      body: "Already licensed in another state? You can get licensed by comity if your credentials meet the new jurisdiction's standards. An active NCEES Council Record makes this straightforward — it's a pre-verified portfolio that most boards accept. Either way, you may still need to pass a jurisdiction-specific exam on local statutes and rules.",
    },
    { type: 'heading', body: 'Grounds for Discipline — Licensees' },
    {
      type: 'text',
      body: 'Section 150.10 gives the board power to suspend, revoke, fine, or reprimand any licensee found guilty of a long list of offenses. The big categories: fraud or deceit in obtaining licensure, negligence or incompetence, felony conviction (even if unrelated to engineering), dishonesty-related misdemeanors, failure to comply with board rules, and practicing outside your area of competence.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'The felony clause catches students off guard. A felony conviction of any kind — even one completely unrelated to engineering — is grounds for discipline. For misdemeanors, only those involving dishonesty or directly related to engineering practice qualify.',
    },
    { type: 'heading', body: 'Grounds for Discipline — Unlicensed Individuals' },
    {
      type: 'text',
      body: 'Section 150.30 targets people who aren\'t licensed at all. The board can fine anyone who practices engineering without a license, uses the title "professional engineer" without authorization, presents someone else\'s license or seal, or uses an expired, suspended, or revoked license. Each day of continued violation counts as a separate offense.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'For exam questions about discipline, ask two questions: (1) Is the person licensed? If yes, §150.10 applies. If no, §150.30 applies. (2) What did they do? Match it to the specific ground — fraud, incompetence, felony, unauthorized practice, or seal misuse. The answer usually maps cleanly to one provision.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: "The board considers several factors when setting fines: whether the amount is a deterrent, the severity and circumstances of the violation, the risk to the public, the economic benefit the violator gained, and consistency with past fines. The exam occasionally tests whether you know that fines scale with these factors.",
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'eth-lpd-q1',
      statement:
        'An individual graduated from an EAC/ABET-accredited engineering program, passed the FE exam, and has been working as an Engineer Intern for two years under a licensed PE. The individual wants to apply for PE licensure. What is the most likely outcome?',
      choices: [
        {
          id: 'c1',
          text: 'The application will be approved — two years of experience is sufficient after passing the FE',
        },
        {
          id: 'c2',
          text: 'The application will be denied — the individual needs at least four years of progressive experience after the qualifying degree',
        },
        {
          id: 'c3',
          text: 'The application will be denied — the individual must pass the PE exam before gaining experience',
        },
        {
          id: 'c4',
          text: 'The application will be approved if the supervising PE writes a recommendation letter',
        },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: "The licensure path is rigid on experience: four years after your bachelor's, three with a master's, two with a doctorate (if you passed the FE). This person has a bachelor's and two years — they're only halfway there. Answer A is wrong because two years is the doctoral track, not the bachelor's track. Answer C gets the order wrong — you can gain experience before passing the PE exam; in fact, that's the normal sequence. Answer D confuses references with the experience requirement. You need five references, but they don't let you skip years.",
      hint: "How many years of experience does the Model Law require after a bachelor's degree for PE licensure?",
      steps: [
        {
          text: "Review the licensure requirements under §130.10 B.2.a: a PE candidate must pass both the FE and PE exams and complete four years of progressive engineering experience after the qualifying degree.",
          latex: null,
        },
        {
          text: "The individual has only two years of experience, which falls short of the four-year requirement for a bachelor's degree holder.",
          latex: null,
        },
        {
          text: "Experience reductions apply for advanced degrees: master's = 3 years, doctorate with FE = 2 years. But the problem states only a bachelor's degree, so four years is required.",
          latex: null,
        },
        {
          text: "A recommendation letter is not a substitute for the experience requirement — five references are required, but they don't override the time threshold.",
          latex: null,
        },
      ],
      handbookPage: "p. 8–9, Model Law §130.10 B.2.a(3)",
      handbookFormula:
        "\\text{§130.10: Bachelor's = 4 years experience; Master's = 3 years; Doctorate + FE = 2 years.}",
      videoUrl: null,
      traps: [
        "Confusing the experience requirement for a bachelor's (4 years) with the reduced requirement for a doctorate (2 years)",
        "Thinking that a supervisor's recommendation can substitute for the minimum experience threshold",
      ],
      diagram: null,
    },
    {
      id: 'eth-lpd-q2',
      statement:
        "A licensed PE is convicted of tax fraud, a felony completely unrelated to engineering practice. The engineer has an excellent professional record with no prior complaints or violations. Can the state licensing board take disciplinary action against the engineer's PE license?",
      choices: [
        {
          id: 'c1',
          text: 'No — the board can only discipline for violations directly related to engineering practice',
        },
        {
          id: 'c2',
          text: "No — the engineer's clean professional record protects them from discipline for non-engineering offenses",
        },
        {
          id: 'c3',
          text: 'Yes — felony conviction of any kind is grounds for disciplinary action, regardless of whether it relates to engineering',
        },
        {
          id: 'c4',
          text: 'Yes — but only if the engineer fails to self-report the conviction to the board',
        },
      ],
      correctAnswerId: 'c3',
      difficulty: 'medium',
      eli5: "This trips up a lot of people because tax fraud has nothing to do with engineering. But §150.10 A.3 is crystal clear: any felony conviction is grounds for discipline, \"whether or not related to the practice of engineering.\" The logic is that a felony reflects on the licensee's character and trustworthiness. Answer A is wrong because the statute explicitly covers non-engineering felonies. Answer B is wrong because a clean record affects the punishment severity, not whether the board can act. Answer D adds a condition that doesn't exist in the Model Law — the conviction itself is the trigger, not whether you reported it.",
      hint: 'Read §150.10 A.3 carefully — does it limit disciplinary grounds to engineering-related offenses?',
      steps: [
        {
          text: 'Apply §150.10 A.3: the board can discipline a licensee for conviction of any crime that is a felony, whether or not related to the practice of engineering.',
          latex: null,
        },
        {
          text: 'Tax fraud is a felony. The "whether or not related" language explicitly covers non-engineering felonies.',
          latex: null,
        },
        {
          text: "The engineer's clean professional record may influence the severity of the sanction but does not prevent the board from taking action.",
          latex: null,
        },
        {
          text: "Self-reporting requirements may exist in some jurisdictions, but §150.10 A.3 doesn't condition discipline on failure to report — the felony conviction itself is sufficient grounds.",
          latex: null,
        },
      ],
      handbookPage: 'p. 9, Model Law §150.10 A.3',
      handbookFormula:
        '\\text{§150.10 A.3: Conviction of any felony, whether or not related to engineering practice.}',
      videoUrl: null,
      traps: [
        'Assuming disciplinary action requires a connection to engineering practice — the felony clause has no such limitation',
        'Confusing the felony rule (any felony) with the misdemeanor rule (only dishonesty-related or engineering-related misdemeanors)',
      ],
      diagram: null,
    },
    {
      id: 'eth-lpd-q3',
      statement:
        'An individual whose PE license was revoked three years ago for professional misconduct starts a consulting company called "Advanced Engineering Solutions LLC." The individual does not personally perform engineering work — instead, the company hires licensed PEs as employees who sign and seal all documents. The individual serves only as the business manager. Which of the following statements is most accurate under the Model Law?',
      choices: [
        {
          id: 'c1',
          text: 'This arrangement is acceptable because licensed PEs are performing and sealing all engineering work',
        },
        {
          id: 'c2',
          text: 'The individual is violating §150.30 by using the word "Engineering" in a firm name without a valid certificate of authorization, and may be violating §150.10 A.9 if operating under board restrictions',
        },
        {
          id: 'c3',
          text: 'The individual is only violating the Model Law if they personally sign or seal engineering documents',
        },
        {
          id: 'c4',
          text: 'The arrangement is acceptable as long as the company obtains a certificate of authorization from the board',
        },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: "This is a layered question. The individual got their license revoked, so they're trying to stay in the engineering business by hiring licensed PEs and only managing the company. Sounds clever, but the Model Law blocks it from multiple angles. First, §150.30 says unlicensed individuals can't use \"engineering\" in their firm name — and a revoked licensee is unlicensed. Second, §160.10 requires a certificate of authorization from the board for any firm with \"engineering\" in its name. Third, if the revocation order imposed restrictions, running an engineering firm could violate those terms (§150.10 A.9). Answer A ignores the firm-level requirements entirely. Answer C is too narrow — the violations go beyond personal signing and sealing. Answer D is theoretically possible but practically impossible with a revoked license.",
      hint: 'Consider both the individual-level restrictions on an unlicensed person and the firm-level requirements for using "engineering" in a company name.',
      steps: [
        {
          text: 'Apply §160.10 A: a firm that practices or offers to practice engineering must obtain a certificate of authorization from the board.',
          latex: null,
        },
        {
          text: 'Apply §160.10 C: the secretary of state cannot issue incorporation documents to any firm that includes "engineer" or "engineering" in its name unless the board has issued a certificate of authorization.',
          latex: null,
        },
        {
          text: 'Apply §150.30 A.2: unlicensed individuals cannot use the words "professional engineer," "engineering," or any derivative in their business activity except as provided by the Act.',
          latex: null,
        },
        {
          text: "The individual's license was revoked — they are effectively unlicensed. Operating a company with \"Engineering\" in the name without board authorization violates §150.30.",
          latex: null,
        },
        {
          text: 'Additionally, §150.10 A.9 states that violating any terms of a board order or practicing while a license is revoked is separate grounds for discipline. If the revocation order included restrictions on engineering-related business activities, this arrangement may violate those terms as well.',
          latex: null,
        },
      ],
      handbookPage: 'p. 10, Model Law §150.30 A.2; p. 10, §160.10 A, C; p. 9, §150.10 A.9',
      handbookFormula:
        '\\text{§150.30 A.2: Unlicensed individuals shall not use "engineering" in their name or form of business activity.}',
      videoUrl: null,
      traps: [
        'Focusing only on who signs and seals, while ignoring the firm-name and certificate-of-authorization requirements',
        'Assuming that hiring licensed PEs insulates the business owner from Model Law violations — the restrictions apply to the individual and the firm independently',
      ],
      diagram: null,
    },
  ],
  examProblems: [
    {
      id: 'eth-ld-ex1',
      type: 'conceptual',
      statement: 'An engineer graduated with a bachelor\'s degree from an EAC/ABET-accredited program, passed the FE exam, and then completed a master\'s degree in structural engineering. The engineer has been working under a licensed PE for two and a half years since completing the master\'s degree. Is the engineer eligible to apply for PE licensure?',
      choices: [
        { id: 'c1', text: 'No — the engineer needs four years of experience regardless of the master\'s degree' },
        { id: 'c2', text: 'No — the engineer needs at least three years of experience after the master\'s degree' },
        { id: 'c3', text: 'Yes — a master\'s degree reduces the experience requirement to two years' },
        { id: 'c4', text: 'Yes — the combined education (bachelor\'s plus master\'s) waives the experience requirement entirely' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: 'The Model Law has a clear experience reduction schedule for advanced degrees. A bachelor\'s requires four years. A master\'s reduces it to three years. A doctorate (with FE passed) reduces it to two years. This engineer has a master\'s and two and a half years of experience — close, but still half a year short of the three-year requirement. Answer A is wrong because the master\'s does reduce the requirement, just not to two years. Answer C confuses the master\'s reduction (three years) with the doctorate reduction (two years). Answer D is completely wrong — no amount of education waives the experience requirement.',
      hint: 'How many years of experience does the Model Law require after a master\'s degree?',
      steps: [
        { text: 'Review §130.10 B.2: PE licensure requires passing the FE and PE exams plus completing progressive engineering experience after the qualifying degree.', latex: null },
        { text: 'Experience requirements by degree level: bachelor\'s = 4 years, master\'s = 3 years, doctorate (with FE) = 2 years.', latex: null },
        { text: 'The engineer has a master\'s degree, which reduces the requirement to 3 years. With 2.5 years of experience, the engineer is not yet eligible.', latex: null },
        { text: 'Note: the degree used to meet education requirements cannot also count as experience credit — no double-dipping (§130.10 B.2.d).', latex: null },
      ],
      handbookPage: 'p. 8-9, Model Law §130.10 B.2.a',
      handbookFormula: '\\text{§130.10: Bachelor\'s = 4 yr; Master\'s = 3 yr; Doctorate + FE = 2 yr experience.}',
      videoUrl: null,
      traps: ['Confusing the master\'s reduction (3 years) with the doctorate reduction (2 years)', 'Assuming that any advanced degree cuts the requirement in half'],
      diagram: null,
    },
    {
      id: 'eth-ld-ex2',
      type: 'conceptual',
      statement: 'A licensed PE is found guilty of a misdemeanor charge of shoplifting. The offense is completely unrelated to the engineer\'s professional practice, and the engineer has no prior disciplinary history. Can the state licensing board take action against the engineer\'s license based on this conviction?',
      choices: [
        { id: 'c1', text: 'Yes — any criminal conviction is grounds for disciplinary action under the Model Law' },
        { id: 'c2', text: 'Yes — shoplifting is a crime of dishonesty, and dishonesty-related misdemeanors are grounds for discipline' },
        { id: 'c3', text: 'No — misdemeanors are not grounds for discipline unless they are directly related to engineering practice' },
        { id: 'c4', text: 'No — only felony convictions trigger disciplinary action under the Model Law' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'The Model Law draws a clear line between felonies and misdemeanors. For felonies, any conviction triggers discipline — does not matter if it is related to engineering. For misdemeanors, the standard is narrower: only those that reflect on the licensee\'s ability to practice with good character, or that involve dishonesty or moral turpitude. Shoplifting is a crime of dishonesty — taking something that is not yours through deception. So even though it has nothing to do with engineering, it qualifies. Answer A is too broad — not every misdemeanor qualifies, only dishonesty-related ones. Answer C is wrong because the dishonesty exception exists. Answer D is wrong because it ignores the misdemeanor provision entirely.',
      hint: 'The Model Law treats felonies and misdemeanors differently. For misdemeanors, what specific characteristic makes them grounds for discipline?',
      steps: [
        { text: 'Apply §150.10 A.3: felony convictions of any kind are grounds for discipline, whether or not related to engineering.', latex: null },
        { text: 'Apply §150.10 A.4: misdemeanor convictions are grounds for discipline only if they are related to engineering practice OR reflect dishonesty, fraud, deceit, or misrepresentation.', latex: null },
        { text: 'Shoplifting is a crime involving dishonesty (taking property through deception). It falls under the dishonesty-related misdemeanor provision.', latex: null },
        { text: 'The board can take disciplinary action even though the offense is unrelated to engineering, because the dishonesty element independently qualifies.', latex: null },
      ],
      handbookPage: 'p. 9, Model Law §150.10 A.3-A.4',
      handbookFormula: '\\text{§150.10 A.4: Misdemeanors involving dishonesty, fraud, deceit, or misrepresentation are grounds for discipline.}',
      videoUrl: null,
      traps: ['Applying the felony rule (any conviction) to misdemeanors — misdemeanors have a narrower standard', 'Assuming that only engineering-related offenses can trigger discipline — dishonesty-related misdemeanors also qualify'],
      diagram: null,
    },
    {
      id: 'eth-ld-ex3',
      type: 'conceptual',
      statement: 'An engineer licensed in State A accepts a project in State B, where she is not licensed. The project involves designing a stormwater management system for a commercial development. The engineer plans to complete the design in State A and have a PE licensed in State B review and seal the documents. Under the Model Law, which statement is most accurate?',
      choices: [
        { id: 'c1', text: 'This arrangement is acceptable because the State B PE will exercise responsible charge by reviewing and sealing the documents' },
        { id: 'c2', text: 'This arrangement is acceptable because the engineer holds a valid license in State A, which authorizes nationwide practice' },
        { id: 'c3', text: 'This arrangement violates the Model Law because the engineer is practicing in State B without a license, and the State B PE cannot seal work not prepared under their responsible charge' },
        { id: 'c4', text: 'This arrangement is acceptable as long as the engineer obtains a temporary practice permit from State B' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'medium',
      eli5: 'This scenario has two separate violations stacked on each other. First, the State A engineer is performing engineering services for a project in State B without holding a State B license — that is practicing without a license in that jurisdiction (Rule A.10 requires compliance with the laws of every jurisdiction where you practice). Second, the State B PE is being asked to seal documents they did not prepare under their responsible charge — they would just be reviewing someone else\'s completed work, which violates B.2. Answer A is wrong because a review is not responsible charge. Answer B is wrong because PE licensure is jurisdiction-specific, not nationwide. Answer D might be possible in some states, but the question asks about the described arrangement, which involves neither a temporary permit nor responsible charge.',
      hint: 'Consider two separate issues: the State A engineer practicing in State B, and the State B PE sealing work not prepared under their supervision.',
      steps: [
        { text: 'Apply Rule A.10: licensees shall comply with the licensing laws of all jurisdictions where they practice. The State A engineer is offering engineering services in State B without a State B license.', latex: null },
        { text: 'Apply Rule B.2: the State B PE cannot sign and seal documents that were not prepared under their responsible charge. A post-completion review does not constitute responsible charge.', latex: null },
        { text: 'PE licensure is jurisdiction-specific. A license in State A does not authorize practice in State B unless the engineer obtains a State B license (by examination or comity) or a temporary practice permit if available.', latex: null },
        { text: 'Both the unlicensed practice and the improper sealing arrangement violate the Model Law independently.', latex: null },
      ],
      handbookPage: 'p. 5, Model Rules §240.15 A.10, B.2; p. 9, §130.10 (comity provisions)',
      handbookFormula: '\\text{A.10: Comply with licensing laws of every jurisdiction where you practice.}',
      videoUrl: null,
      traps: ['Assuming that a license in one state authorizes practice in another — PE licensure is jurisdiction-specific', 'Believing that a local PE reviewing and sealing the work cures the responsible charge problem — review is not supervision'],
      diagram: null,
    },
    {
      id: 'eth-ld-ex4',
      type: 'conceptual',
      statement: 'A licensing board suspends a PE\'s license for two years due to negligence on a bridge inspection. During the suspension period, the engineer continues to work at the same firm as a "project coordinator." In this role, the engineer reviews incoming project proposals, assigns tasks to licensed PEs, sets project schedules, attends client meetings to discuss design progress, and provides technical guidance to junior engineers on structural detailing. The engineer does not sign or seal any documents. Has the engineer violated the terms of the suspension?',
      choices: [
        { id: 'c1', text: 'No — the engineer is not signing or sealing documents and therefore is not practicing engineering' },
        { id: 'c2', text: 'No — the role is purely managerial and does not constitute engineering practice' },
        { id: 'c3', text: 'Yes — providing technical guidance on structural detailing and discussing design progress with clients constitutes practice of engineering, regardless of the job title or whether documents are sealed' },
        { id: 'c4', text: 'It depends on whether the firm\'s other PEs are supervising the engineer\'s work' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'hard',
      eli5: 'Job titles do not determine whether someone is practicing engineering — the nature of the work does. Some of the coordinator\'s tasks are genuinely managerial: setting schedules and assigning tasks to PEs. But two activities cross the line. First, providing technical guidance on structural detailing requires engineering judgment and education — that is practice of engineering under §110.20 A.3. Second, discussing design progress with clients constitutes offering engineering services. The fact that no documents are signed or sealed is irrelevant — the Model Law defines practice broadly, and the seal is only one trigger. Under §150.10 A.9, practicing while suspended is a separate violation that can lead to permanent revocation. Answer A focuses too narrowly on sealing. Answer B ignores the technical guidance component. Answer D is wrong because supervised practice by a suspended licensee is still unauthorized practice.',
      hint: 'Does the Model Law definition of "practice of engineering" require signing and sealing documents, or does it cover any service requiring engineering judgment?',
      steps: [
        { text: 'Apply §110.20 A.3: practice of engineering includes any service requiring engineering education, training, and experience that impacts public health, safety, and welfare.', latex: null },
        { text: 'Review the engineer\'s activities: setting schedules and assigning tasks are managerial. But providing structural detailing guidance and discussing design with clients requires engineering judgment.', latex: null },
        { text: 'The definition of practice is not limited to signing and sealing. Technical guidance on structural detailing is a service that requires engineering education and directly impacts structural safety.', latex: null },
        { text: 'Apply §150.10 A.9: violating any term of a board order (here, the suspension) is independent grounds for further discipline, potentially including permanent revocation.', latex: null },
        { text: 'The job title "project coordinator" does not change the nature of the work. The Model Law looks at the activity, not the title.', latex: null },
      ],
      handbookPage: 'p. 6, Model Law §110.20 A.3; p. 9, §150.10 A.9',
      handbookFormula: '\\text{§150.10 A.9: Violation of any term of a board order is grounds for further discipline.}',
      videoUrl: null,
      traps: ['Equating "not sealing documents" with "not practicing engineering" — the Model Law definition is much broader than the seal', 'Assuming a managerial job title insulates the engineer from practicing engineering — the nature of the activities determines whether practice occurs'],
      diagram: null,
    },
  ],
};
