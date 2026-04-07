export default {
  id: 'definitions-practice-of-engineering',
  name: 'Definitions & Practice of Engineering',
  subtopicId: 'licensure-and-law',
  application:
    'The Model Law definitions tell you who counts as an engineer, what counts as engineering, and what "responsible charge" actually means. On the FE, these definitions show up as boundary questions — is this person allowed to do this work? Does this activity require a license? Civil engineers deal with these boundaries constantly: when a technician prepares drawings under your supervision, when you coordinate with surveyors, or when someone without a license calls themselves an "engineer." The exam tests whether you know exactly where the legal lines are drawn.',
  content: [
    {
      type: 'text',
      body: "Model Law §110.20 defines the key terms that control who can practice engineering and what activities require licensure. The exam doesn't ask you to recite definitions — it gives you a scenario and tests whether you can figure out if a license is required or if someone is crossing a legal boundary.",
    },
    { type: 'heading', body: 'Professional Engineer vs. Engineer Intern' },
    {
      type: 'text',
      body: "A Professional Engineer (PE) is someone qualified by education, training, experience, and examination — and duly licensed by the board. An Engineer Intern (EI) has passed the FE exam and been certified by the board, but hasn't completed the experience requirements for full licensure yet. A PE can also be designated as licensed in a specific discipline based on additional education and examination.",
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The exam may test the difference between "certified" (EI status after passing the FE) and "licensed" (PE status after passing both FE and PE exams plus meeting experience requirements). These are not interchangeable terms.',
    },
    { type: 'heading', body: 'What Is "Practice of Engineering"?' },
    {
      type: 'text',
      body: 'The Model Law defines it broadly: any service or creative work requiring engineering education, training, and experience that potentially impacts the health, safety, and welfare of the public. This includes design, planning, studies, drawings, specifications, and reviewing construction for compliance. It also includes teaching engineering design courses.',
    },
    {
      type: 'text',
      body: "You're construed to be practicing engineering if you do any of these: (a) practice any discipline of engineering or hold yourself out as able to, (b) represent yourself as a PE by any means — verbal, sign, letterhead, card, advertisement, or (c) use a title that implies you're a PE.",
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'The "holding out" clause is a common exam trap. You don\'t have to actually do engineering work to violate the law — just representing yourself as a PE when you\'re not licensed is enough. This includes business cards, LinkedIn titles, and verbal claims.',
    },
    { type: 'heading', body: 'Responsible Charge' },
    {
      type: 'text',
      body: '"Responsible charge" means direct control and personal supervision of engineering work. This is the standard for who can sign and seal documents. If you didn\'t personally prepare the work or directly supervise the person who did, you can\'t put your seal on it — even if you reviewed it thoroughly after the fact.',
    },
    { type: 'heading', body: 'Other Key Definitions' },
    {
      type: 'text',
      body: 'A few more definitions show up on the exam. "Firm" means any business entity other than a sole proprietorship. "Signature" means a name, mark, or writing made with the intent to verify or authenticate — including electronic or digital signatures. "Disciplinary action" covers everything from reprimands and fines to suspension and revocation of a license.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'When the exam asks whether someone needs a license, use this checklist: (1) Does the activity impact public health, safety, or welfare? (2) Does it require engineering education and judgment? (3) Is the person holding themselves out as an engineer? If yes to any of these, a license is required.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: "The Exemption Clause (§170.20) is worth knowing: employees working under a licensed PE's responsible charge don't need their own license, as long as the PE verifies the work and the employee isn't making final design decisions.",
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'eth-dpe-q1',
      statement:
        'A recent engineering graduate has passed the FE exam and been certified as an Engineer Intern. The graduate\'s employer asks them to sign and seal a set of drainage plans for a residential subdivision. What should the graduate do?',
      choices: [
        {
          id: 'c1',
          text: 'Decline to sign and seal because an Engineer Intern is not a licensed Professional Engineer',
        },
        {
          id: 'c2',
          text: 'Sign and seal the plans but note "Engineer Intern" next to the signature',
        },
        {
          id: 'c3',
          text: 'Sign and seal the plans since passing the FE exam demonstrates competence',
        },
        {
          id: 'c4',
          text: 'Sign and seal the plans if a licensed PE in the firm reviews them first',
        },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: "This is the certified vs. licensed distinction. Passing the FE gets you \"certified\" as an Engineer Intern — it's a milestone, not a license. You can't sign and seal anything as an EI, period. Choice C is wrong because the FE exam proves foundational knowledge, not authority to practice. Choice B is wrong because adding \"Engineer Intern\" doesn't magically grant sealing authority. Choice D is tempting but backwards — the PE who supervised the work should be the one sealing, not the EI with a PE looking over their shoulder.",
      hint: "What's the difference between being certified as an Engineer Intern and being licensed as a Professional Engineer?",
      steps: [
        {
          text: 'Identify the key distinction: the graduate is a certified Engineer Intern (EI), not a licensed Professional Engineer (PE).',
          latex: null,
        },
        {
          text: 'Under §110.20, certification as an EI means passing the FE exam — it does not grant licensure to practice independently.',
          latex: null,
        },
        {
          text: 'Only a licensed PE can sign and seal engineering documents. An EI lacks the authority regardless of competence or supervision.',
          latex: null,
        },
        {
          text: 'Even if a PE reviews the plans afterward, the EI cannot be the one to sign and seal — the PE who exercised responsible charge must seal the documents.',
          latex: null,
        },
      ],
      handbookPage: 'p. 6, Model Law §110.20 A.2 (Engineer Intern), §110.20 A (Professional Engineer)',
      handbookFormula:
        '\\text{Engineer Intern: certified by the board. Professional Engineer: licensed by the board.}',
      videoUrl: null,
      traps: [
        'Confusing EI certification with PE licensure — passing the FE is necessary but not sufficient for signing and sealing authority',
        "Thinking that PE review of an EI's sealed documents makes the seal valid — only the PE can seal",
      ],
      diagram: null,
    },
    {
      id: 'eth-dpe-q2',
      statement:
        "A construction company hires a project manager with a degree in construction management but no engineering license. The project manager reviews structural shop drawings submitted by a steel fabricator, compares them to the engineer-of-record's design drawings, and flags discrepancies for the engineer to resolve. Is the project manager practicing engineering under the Model Law?",
      choices: [
        {
          id: 'c1',
          text: 'Yes — reviewing structural drawings requires engineering judgment and therefore requires a license',
        },
        {
          id: 'c2',
          text: 'Yes — the project manager is holding themselves out as able to practice engineering by reviewing technical documents',
        },
        {
          id: 'c3',
          text: 'No — the project manager is comparing documents for compliance, not making final engineering design decisions, and works under an exemption',
        },
        {
          id: 'c4',
          text: 'No — construction management is a separate profession and is never considered engineering',
        },
      ],
      correctAnswerId: 'c3',
      difficulty: 'medium',
      eli5: "This question tests whether you know the boundary between engineering and non-engineering work. The PM is doing a comparison task — lining up shop drawings against the engineer's design and saying \"these don't match here.\" That's a compliance check, not a design decision. The Exemption Clause (§170.20 C) specifically allows unlicensed employees to do this kind of work under a PE's responsible charge, as long as they're not making final design decisions. Answer A is wrong because comparing documents isn't the same as exercising engineering judgment. Answer B is wrong because the PM isn't claiming to be an engineer. Answer D goes too far — it's not that construction management is never engineering, it's that this specific activity falls under the exemption.",
      hint: "Does the project manager's task involve final engineering design decisions, or is it a compliance comparison under someone else's responsible charge?",
      steps: [
        {
          text: 'Apply the definition of "practice of engineering" from §110.20 A.3: services requiring engineering education, training, and experience that impact public health, safety, and welfare.',
          latex: null,
        },
        {
          text: 'The project manager is comparing shop drawings to design drawings and flagging discrepancies — this is a compliance check, not a design decision.',
          latex: null,
        },
        {
          text: "Apply the Exemption Clause §170.20 C: employees working under the responsible charge of a licensed PE can perform work that doesn't include final engineering designs or decisions.",
          latex: null,
        },
        {
          text: 'The engineer-of-record makes the final design decisions when resolving the flagged discrepancies. The PM is functioning as a subordinate under the PE\'s responsible charge.',
          latex: null,
        },
        {
          text: "Answer D is too broad — some construction management activities could cross into engineering. The correct reasoning is the specific exemption, not a blanket exclusion.",
          latex: null,
        },
      ],
      handbookPage: 'p. 6, Model Law §110.20 A.3 (Practice of Engineering); p. 11, §170.20 C (Exemption Clause)',
      handbookFormula:
        '\\text{§170.20 C: Work of a subordinate under responsible charge that does not include final engineering designs or decisions.}',
      videoUrl: null,
      traps: [
        'Assuming that any review of structural documents automatically constitutes "practice of engineering" — the key is whether final design decisions are being made',
        'Choosing D based on the job title rather than analyzing the specific activity against the Model Law definition',
      ],
      diagram: null,
    },
    {
      id: 'eth-dpe-q3',
      statement:
        'A software developer creates a mobile app that calculates beam deflections and recommends steel member sizes for residential deck construction. The app is marketed to homeowners as a "DIY structural design tool." The developer has no engineering license and the app does not involve any licensed engineer in its operation. Under the Model Law, which of the following best describes the developer\'s situation?',
      choices: [
        {
          id: 'c1',
          text: 'The developer is not practicing engineering because software development is not an engineering discipline',
        },
        {
          id: 'c2',
          text: 'The developer is not practicing engineering because the app is a tool and the homeowner makes the final decision',
        },
        {
          id: 'c3',
          text: 'The developer is practicing engineering because the app provides structural design services that impact public safety, and the developer holds themselves out as able to provide engineering services',
        },
        {
          id: 'c4',
          text: 'The developer is only violating trademark law by implying engineering services, not the Model Law',
        },
      ],
      correctAnswerId: 'c3',
      difficulty: 'hard',
      eli5: "This is a modern twist on an old rule. The Model Law doesn't care whether you deliver engineering through paper drawings or a mobile app — if you're creating a tool that performs structural design calculations and marketing it to the public, you're practicing engineering. The app recommends steel member sizes for structures people will stand on. That impacts public safety. And by marketing it as a \"structural design tool,\" the developer is holding themselves out as providing engineering services (§110.20 A.3(a)). Answer A is wrong because the issue isn't the developer's profession — it's the nature of the service the app provides. Answer B is wrong because the \"final decision\" excuse doesn't apply when the app is doing the engineering judgment. Answer D is too narrow — this goes beyond trademark issues into unlicensed practice.",
      hint: "Focus on what the app does (structural design calculations) and how it's marketed (as a design tool) — does the Model Law care about the medium of delivery?",
      steps: [
        {
          text: 'Apply the definition of "practice of engineering" from §110.20 A.3: any service or creative work requiring engineering education, training, and experience that potentially impacts the health, safety, and welfare of the public.',
          latex: null,
        },
        {
          text: 'The app performs structural design calculations (beam deflection, member sizing) for construction — this directly impacts public safety and requires engineering judgment to create correctly.',
          latex: null,
        },
        {
          text: 'Apply §110.20 A.3(a): an individual is construed to practice engineering if they practice any discipline of engineering or hold themselves out as able to do so.',
          latex: null,
        },
        {
          text: 'Marketing a "structural design tool" to the public constitutes holding oneself out as able to provide engineering services — the developer is offering engineering judgment embedded in software.',
          latex: null,
        },
        {
          text: "The fact that the developer writes code rather than stamped drawings doesn't matter. The output is structural design recommendations that affect public safety. The medium doesn't change the nature of the service.",
          latex: null,
        },
      ],
      handbookPage: 'p. 6, Model Law §110.20 A.3 (Practice of Engineering), §110.20 A.3(a)–(c) (construed to practice)',
      handbookFormula:
        '\\text{§110.20 A.3(a): Practices any discipline of engineering or holds themselves out as able and entitled to practice.}',
      videoUrl: null,
      traps: [
        'Assuming that software development can never be "practice of engineering" — the Model Law focuses on the nature of the output, not the medium',
        "Believing that shifting the final decision to the homeowner absolves the developer — the engineering judgment is embedded in the app's calculations",
      ],
      diagram: null,
    },
  ],
  examProblems: [
    {
      id: 'eth-dp-ex1',
      type: 'conceptual',
      statement: 'An engineer discovers that a contractor has substituted lower-grade steel in a bridge project to cut costs. The substitution does not meet the design specifications. What is the engineer\'s primary obligation?',
      choices: [
        { id: 'c1', text: 'Report the issue to the contractor\'s supervisor' },
        { id: 'c2', text: 'Consult with the client before taking any action' },
        { id: 'c3', text: 'Allow the substitution if the bridge can still carry the design load' },
        { id: 'c4', text: 'Hold the public safety paramount and report to the appropriate authority' },
      ],
      correctAnswerId: 'c4',
      difficulty: 'easy',
      eli5: 'The NCEES Model Rules make it crystal clear: the engineer\'s paramount obligation is to protect public health, safety, and welfare. When safety is at stake, you report to the appropriate authority. You do not negotiate, wait, or let cost considerations override safety.',
      hint: 'Think about the engineer\'s paramount obligation under the Model Rules.',
      steps: [
        { text: 'The fundamental canon: Engineers shall hold paramount the safety, health, and welfare of the public.', latex: null },
        { text: 'The steel substitution does not meet design specifications, creating a safety risk.', latex: null },
        { text: 'The engineer must report to the appropriate authority to protect the public.', latex: null },
      ],
      handbookPage: 'p. 4',
      handbookFormula: null,
      videoUrl: null,
      traps: ['Thinking the contractor\'s supervisor is sufficient — safety issues go to authorities', 'Believing structural adequacy overrides specification compliance'],
      diagram: null,
    },
    {
      id: 'eth-dp-ex2',
      type: 'conceptual',
      statement: 'Under the NCEES Model Rules, which of the following is considered "practice of engineering"?',
      choices: [
        { id: 'c1', text: 'Operating construction equipment on a job site' },
        { id: 'c2', text: 'Performing engineering analysis and design that affects public safety' },
        { id: 'c3', text: 'Selling engineering software to firms' },
        { id: 'c4', text: 'Teaching engineering courses at a university' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: 'The practice of engineering specifically involves applying engineering principles in analysis, design, or consultation that affects public safety. Operating equipment, selling software, and teaching are not "practice of engineering" as defined by the Model Rules, even though they are related to the field.',
      hint: 'The definition focuses on analysis and design that affects public safety.',
      steps: [
        { text: 'The Model Rules define "practice of engineering" as any service requiring engineering education and training.', latex: null },
        { text: 'It specifically involves analysis, design, or consultation where public safety is affected.', latex: null },
        { text: 'Operating equipment, selling products, and teaching do not meet this definition.', latex: null },
      ],
      handbookPage: 'p. 4',
      handbookFormula: null,
      videoUrl: null,
      traps: ['Confusing engineering-adjacent activities with the legal definition of practice'],
      diagram: null,
    },
    {
      id: 'eth-dp-ex3',
      type: 'conceptual',
      statement: 'A mechanical engineering graduate working at a civil engineering firm updates her LinkedIn profile to read "Engineer at XYZ Engineering Consultants." She has not passed the FE exam and holds no engineering certification or license. A potential client sees the profile and contacts the firm requesting her specifically for a dam inspection. Under the Model Law, which statement is most accurate?',
      choices: [
        { id: 'c1', text: 'No violation has occurred because "Engineer" is a common job title and does not imply licensure' },
        { id: 'c2', text: 'The graduate is construed to be practicing engineering by using a title that implies she is a Professional Engineer' },
        { id: 'c3', text: 'The firm is solely responsible because they allowed her to use the title on company-related platforms' },
        { id: 'c4', text: 'A violation only occurs if the graduate actually performs the dam inspection' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'The "holding out" clause in the Model Law is broader than most people expect. Under section 110.20 A.3(c), you are construed to be practicing engineering if you use any title that could imply you are a licensed PE. Even though "Engineer" is used casually in many industries, in a professional context on LinkedIn — attached to an engineering firm — it creates the impression of licensure. The key is that the violation happens at the point of representation, not at the point of doing work. Answer A is wrong because context matters; attached to an engineering firm, the title implies licensure. Answer C is wrong because both the individual and the firm can be liable, but the individual bears personal responsibility for their own representations. Answer D is wrong because the violation is the representation itself, not the subsequent work.',
      hint: 'Does the Model Law require someone to actually perform engineering work to violate the "holding out" provisions, or is the representation itself enough?',
      steps: [
        { text: 'Identify the key issue: an unlicensed individual is using the title "Engineer" in a professional context associated with an engineering firm.', latex: null },
        { text: 'Apply §110.20 A.3(c): a person is construed to practice engineering if they use any title that implies they are a Professional Engineer.', latex: null },
        { text: 'The LinkedIn profile, combined with the firm name, creates the impression that the graduate is a licensed engineer — this constitutes "holding out."', latex: null },
        { text: 'The violation occurs at the point of representation, not when engineering work is actually performed. The fact that a client sought her out based on the title reinforces the misleading nature of the representation.', latex: null },
      ],
      handbookPage: 'p. 6, Model Law §110.20 A.3(c)',
      handbookFormula: '\\text{§110.20 A.3(c): Uses any title that implies the individual is a Professional Engineer.}',
      videoUrl: null,
      traps: ['Assuming that "Engineer" as a job title is always harmless — context and the Model Law definition matter', 'Believing a violation requires actual engineering work rather than just the representation'],
      diagram: null,
    },
    {
      id: 'eth-dp-ex4',
      type: 'conceptual',
      statement: 'A licensed PE retires and lets her license lapse. Two years later, a former client asks her to review a set of structural calculations prepared by another firm and provide a written opinion on their adequacy. The retired PE would review the calculations at home, write an opinion letter, and sign it with her name followed by "PE (Retired)." She would not stamp or seal the document. Under the Model Law, which of the following best describes this situation?',
      choices: [
        { id: 'c1', text: 'This violates the Model Law because providing engineering opinions for compensation with a lapsed license constitutes unauthorized practice, and using "PE (Retired)" implies current licensure' },
        { id: 'c2', text: 'This is acceptable because reviewing another firm\'s work is not "practice of engineering"' },
        { id: 'c3', text: 'This is acceptable because she is not stamping or sealing the document' },
        { id: 'c4', text: 'This is acceptable as long as she discloses that her license is no longer active in the opinion letter' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: 'This one layers multiple violations. First, reviewing structural calculations and writing a professional opinion on their adequacy is absolutely "practice of engineering" under §110.20 A.3 — it requires engineering judgment and affects public safety. Second, her license is lapsed, which means she is not currently licensed. Third, signing as "PE (Retired)" uses a title derived from "Professional Engineer," which constitutes holding herself out as a PE under §110.20 A.3(c). It does not matter that she once held the license or that she is not using a stamp. The Model Law does not have a "retired PE" designation that allows continued practice. Choice C is wrong because the seal is not the only trigger — the engineering opinion itself is practice. Choice B is wrong because reviewing calculations for adequacy requires engineering judgment. Choice D is wrong because a disclosure does not cure unauthorized practice.',
      hint: 'Consider two separate issues: whether the activity constitutes practice of engineering, and whether a lapsed licensee can use any form of the PE title.',
      steps: [
        { text: 'Determine whether the activity is "practice of engineering": reviewing structural calculations and opining on their adequacy requires engineering education, training, and judgment, and impacts public safety. This is practice of engineering under §110.20 A.3.', latex: null },
        { text: 'Determine the licensee\'s status: the PE license has lapsed. A lapsed license is not an active license — the individual is not currently authorized to practice.', latex: null },
        { text: 'Apply §150.30: practicing engineering without a current, valid license is unauthorized practice.', latex: null },
        { text: 'Apply §110.20 A.3(c): signing as "PE (Retired)" uses a derivative of the Professional Engineer title, which constitutes holding oneself out as a PE. The Model Law does not recognize "PE (Retired)" as a protected or authorized designation.', latex: null },
        { text: 'A disclosure does not cure the violation — the activity itself is unauthorized, regardless of how transparently it is described.', latex: null },
      ],
      handbookPage: 'p. 6, Model Law §110.20 A.3; p. 10, §150.30',
      handbookFormula: '\\text{§150.30: Unlicensed individuals shall not practice or offer to practice engineering.}',
      videoUrl: null,
      traps: ['Focusing on the absence of a stamp/seal while ignoring that the opinion letter itself constitutes practice of engineering', 'Assuming "PE (Retired)" is a recognized designation that allows limited practice — the Model Law has no such provision'],
      diagram: null,
    },
  ],
};
