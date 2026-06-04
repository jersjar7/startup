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
          text: 'The application will be denied — the individual needs at least four years of progressive experience after the qualifying degree',
        },
        {
          id: 'c2',
          text: 'The application will be approved — two years of experience is sufficient after passing the FE',
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
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: "The licensure path is rigid on experience: four years after your bachelor's, three with a master's, two with a doctorate (if you passed the FE). This person has a bachelor's and two years — they're only halfway there. The \"two years is sufficient\" choice is wrong because two years is the doctoral track, not the bachelor's track. The \"must pass the PE first\" choice gets the order wrong — you can gain experience before passing the PE exam; in fact, that's the normal sequence. The \"recommendation letter approves it\" choice confuses references with the experience requirement. You need five references, but they don't let you skip years.",
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
      eli5: "This trips up a lot of people because tax fraud has nothing to do with engineering. But §150.10 A.3 is crystal clear: any felony conviction is grounds for discipline, \"whether or not related to the practice of engineering.\" The logic is that a felony reflects on the licensee's character and trustworthiness. The \"only related to engineering practice\" option is wrong because the statute explicitly covers non-engineering felonies. The \"clean record protects them\" option is wrong because a clean record affects the punishment severity, not whether the board can act. The \"only if they fail to self-report\" option adds a condition that doesn't exist in the Model Law — the conviction itself is the trigger, not whether you reported it.",
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
      eli5: "This is a layered question. The individual got their license revoked, so they're trying to stay in the engineering business by hiring licensed PEs and only managing the company. Sounds clever, but the Model Law blocks it from multiple angles. First, §150.30 says unlicensed individuals can't use \"engineering\" in their firm name — and a revoked licensee is unlicensed. Second, §160.10 requires a certificate of authorization from the board for any firm with \"engineering\" in its name. Third, if the revocation order imposed restrictions, running an engineering firm could violate those terms (§150.10 A.9). The choice that calls the arrangement acceptable because licensed PEs do all the work ignores the firm-level requirements entirely. The choice limiting violations to personal signing and sealing is too narrow — the violations go beyond that. The choice that says obtaining a certificate of authorization makes it acceptable is theoretically possible but practically impossible with a revoked license.",
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
};
