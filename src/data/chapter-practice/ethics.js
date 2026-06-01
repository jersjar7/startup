// Chapter practice: Ethics (10 questions, 2 per lesson)

const PROBLEMS = [
  {
    id: 'eth-otp-cp1',
    type: 'conceptual',
    statement:
      'A municipal engineer reviews a developer\'s submittal for a new apartment complex and notices that the proposed fire-access road has a turning radius too tight for the city\'s ladder trucks, violating the fire code. The developer\'s engineer of record insists the layout "has always been approved before" and threatens to complain to the city manager, who is eager to see the project move forward. The municipal engineer is told informally that approving the plan would "make everyone\'s life easier." What should the municipal engineer do?',
    choices: [
      {
        id: 'c1',
        text: 'Withhold approval and require the access road to be corrected to meet the fire code, documenting the deficiency regardless of political pressure'
      },
      {
        id: 'c2',
        text: 'Approve the plan to avoid conflict, since similar layouts were approved in the past'
      },
      {
        id: 'c3',
        text: 'Approve the plan but attach a memo noting the engineer\'s personal disagreement'
      },
      {
        id: 'c4',
        text: 'Resign from the review to avoid being associated with the decision'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Rule A.1 makes public safety paramount, and a fire-access road that ladder trucks cannot navigate is a direct life-safety problem. Past approvals and political convenience do not override a current code violation. Choice B lets precedent and pressure trump safety, which is exactly what A.1 forbids. Choice C is a half-measure: approving the plan still endangers the public even with a memo attached. Choice D abandons the public the engineer is sworn to protect, leaving the unsafe plan to be approved by someone else. The correct action is to withhold approval, require the fix, and document the deficiency.',
    hint: 'When political pressure and prior precedent conflict with a current life-safety code requirement, which obligation controls under Rule A.1?',
    steps: [
      {
        text: 'Identify the conflict: the access road violates the fire code, but the developer and city manager are pressuring for approval.',
        latex: null
      },
      {
        text: 'Apply Rule A.1: the engineer\'s first and foremost responsibility is to safeguard public health, safety, and welfare. Emergency-vehicle access is a life-safety issue.',
        latex: null
      },
      {
        text: 'Prior approvals do not legalize a current code violation, and political convenience is not a basis to waive safety requirements.',
        latex: null
      },
      {
        text: 'The engineer must withhold approval, require the design be corrected to meet code, and document the deficiency in the official record.',
        latex: null
      }
    ],
    handbookPage: 'p. 4, Model Rules §240.15 A.1',
    handbookFormula:
      '\\text{A.1: First and foremost responsibility is to safeguard the health, safety, and welfare of the public.}',
    videoUrl: null,
    traps: [
      'Treating prior approvals as justification to repeat a code violation',
      'Believing a memo of disagreement neutralizes the safety risk of an approved unsafe plan'
    ],
    diagram: null,
    lessonId: 'obligations-to-the-public',
    chapterId: 'ethics'
  },
  {
    id: 'eth-otp-cp2',
    type: 'conceptual',
    statement:
      'An engineer is asked by a community advocacy group to speak at a public hearing in favor of a transit project. The group offers to pay the engineer an undisclosed "appearance fee" and asks the engineer to present the project as having "no significant environmental impact," even though the engineer\'s own analysis identified moderate wetland impacts that can be mitigated but not eliminated. Under the Model Rules, what is the engineer\'s obligation regarding the public statement?',
    choices: [
      {
        id: 'c1',
        text: 'Present the project as having no significant impact, since the impacts can be mitigated'
      },
      {
        id: 'c2',
        text: 'Make the statement only after disclosing the paid interest and presenting the wetland impacts truthfully, including the mitigation limitations'
      },
      {
        id: 'c3',
        text: 'Accept the fee privately but keep the presentation general to avoid the wetland topic'
      },
      {
        id: 'c4',
        text: 'Decline to disclose the fee because appearance fees are customary for expert testimony'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Two rules apply at once. Rule A.5 requires public statements to be objective, truthful, and founded on adequate knowledge; the engineer cannot claim "no significant impact" when the analysis shows moderate, only-partly-mitigable wetland impacts. Rule A.6 requires disclosing any interested party on whose behalf a public statement is made, including who is paying. Choice A misstates the engineer\'s own findings, violating A.5. Choice C hides the truth by omission and conceals the payment. Choice D wrongly assumes a customary fee removes the duty to disclose; the rule requires revealing the paid relationship regardless of custom. The engineer must both disclose the payment and present the impacts honestly.',
    hint: 'Rule A.5 governs truthfulness; Rule A.6 governs disclosing who is paying for a public statement. Both apply here.',
    steps: [
      {
        text: 'Identify the two issues: a request to misstate environmental findings, and an undisclosed payment for the public appearance.',
        latex: null
      },
      {
        text: 'Apply Rule A.5: public statements must be objective, truthful, and founded on adequate knowledge. Claiming "no significant impact" contradicts the engineer\'s own analysis.',
        latex: null
      },
      {
        text: 'Apply Rule A.6: when issuing public statements, the licensee must disclose the identity of any party on whose behalf the statement is made, including a paying interest.',
        latex: null
      },
      {
        text: 'The engineer may speak only after disclosing the paid interest and presenting the wetland impacts and mitigation limits truthfully.',
        latex: null
      }
    ],
    handbookPage: 'p. 4, Model Rules §240.15 A.5, A.6',
    handbookFormula:
      '\\text{A.6: Disclose the identity of any party on whose behalf a public statement is issued.}',
    videoUrl: null,
    traps: [
      'Calling mitigable impacts "no significant impact," which misrepresents the actual findings',
      'Assuming a customary appearance fee does not need to be disclosed'
    ],
    diagram: null,
    lessonId: 'obligations-to-the-public',
    chapterId: 'ethics'
  },
  {
    id: 'eth-oec-cp1',
    type: 'conceptual',
    statement:
      'An engineer at a design-build firm is offered a 10,000 dollar gift card by a precast-concrete supplier shortly after the engineer specified that supplier\'s product on a large parking-structure project. The supplier frames it as a "thank-you for the partnership" and notes that the client and the engineer\'s employer are unaware of the gift. Under the Model Rules, what should the engineer do?',
    choices: [
      {
        id: 'c1',
        text: 'Accept the gift, since the specification decision was already made on technical merit'
      },
      {
        id: 'c2',
        text: 'Accept the gift but disclose it to the supplier\'s sales manager'
      },
      {
        id: 'c3',
        text: 'Decline the gift, because accepting a valuable consideration from a party connected to the work compromises the engineer\'s independent judgment'
      },
      {
        id: 'c4',
        text: 'Accept the gift and donate it to charity to avoid personal benefit'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'Rule B.7 prohibits soliciting or accepting valuable consideration, directly or indirectly, from outside parties in connection with work for which the engineer is responsible. A 10,000 dollar gift card from a supplier whose product the engineer just specified is exactly that. Choice A is wrong because the timing and source create a conflict regardless of how the decision was made. Choice B discloses to the wrong party, the supplier, not the client or employer, and still keeps the gift. Choice D still involves accepting consideration tied to the work; redirecting it to charity does not cure the violation. The clean answer is to decline.',
    hint: 'Rule B.7 addresses accepting valuable consideration from parties connected to the engineer\'s work. What does it require?',
    steps: [
      {
        text: 'Identify the issue: a supplier offers a large gift to the engineer who just specified that supplier\'s product.',
        latex: null
      },
      {
        text: 'Apply Rule B.7: licensees shall not solicit or accept, directly or indirectly, any valuable consideration from outside parties in connection with work for which they are responsible.',
        latex: null
      },
      {
        text: 'The gift is valuable consideration tied directly to the engineer\'s specification decision, so it is prohibited.',
        latex: null
      },
      {
        text: 'The engineer must decline the gift; donating it or disclosing only to the supplier does not remove the conflict.',
        latex: null
      }
    ],
    handbookPage: 'p. 5, Model Rules §240.15 B.7',
    handbookFormula:
      '\\text{B.7: Shall not accept valuable consideration from outside parties in connection with the work.}',
    videoUrl: null,
    traps: [
      'Assuming a gift is acceptable if the specification decision was technically justified',
      'Believing that donating the gift to charity cures the conflict of interest'
    ],
    diagram: null,
    lessonId: 'obligations-employers-clients-peers',
    chapterId: 'ethics'
  },
  {
    id: 'eth-oec-cp2',
    type: 'conceptual',
    statement:
      'A junior engineer notices that a senior colleague on the same project has made a calculation error in a retaining-wall design that underestimates the required reinforcement. The junior engineer is uncertain whether to raise it because the senior colleague has more experience and reacts poorly to criticism. The drawings have not yet been issued for construction. Under the Model Rules, what is the most appropriate action?',
    choices: [
      {
        id: 'c1',
        text: 'Say nothing, since the senior colleague is more experienced and likely correct'
      },
      {
        id: 'c2',
        text: 'Raise the concern professionally and constructively with the colleague, and escalate to the supervisor if it is not resolved before the drawings are issued'
      },
      {
        id: 'c3',
        text: 'Quietly correct the calculation without telling anyone, to avoid a confrontation'
      },
      {
        id: 'c4',
        text: 'Report the senior colleague directly to the state licensing board for incompetence'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Engineers owe a duty to their employer and to the public to address errors that affect safety, and the Model Rules call for treating colleagues with professionalism while not ignoring deficient work. An underestimated retaining-wall reinforcement is a real safety issue, but the drawings are not yet issued, so the internal channel is the right first step. Choice A defers to seniority and ignores a safety-relevant error. Choice C makes a unilateral, undocumented change to another engineer\'s work, which is improper and could introduce new errors. Choice D leaps to the licensing board over a correctable internal mistake before any internal attempt to resolve it. The right move is to raise it constructively, then escalate to the supervisor if unresolved.',
    hint: 'For a correctable error caught before issuance, what is the proper order of action under the obligations to peers and employer?',
    steps: [
      {
        text: 'Identify the issue: a safety-relevant calculation error exists, but the drawings have not yet been issued for construction.',
        latex: null
      },
      {
        text: 'Apply the duty to the employer and public: errors affecting safety must be addressed, and colleagues should be treated professionally.',
        latex: null
      },
      {
        text: 'Because the error is correctable and not yet released, the first step is to raise the concern directly and constructively with the colleague.',
        latex: null
      },
      {
        text: 'If the colleague does not resolve it before the drawings are issued, escalate to the supervisor. Going straight to the board or silently editing the work is premature and improper.',
        latex: null
      }
    ],
    handbookPage: 'p. 5, Model Rules §240.15 B.3',
    handbookFormula:
      '\\text{B.3: Act as a faithful agent for the employer and address deficiencies affecting safety.}',
    videoUrl: null,
    traps: [
      'Deferring to seniority and staying silent on a safety-relevant error',
      'Skipping internal resolution and reporting straight to the licensing board for a correctable mistake'
    ],
    diagram: null,
    lessonId: 'obligations-employers-clients-peers',
    chapterId: 'ethics'
  },
  {
    id: 'eth-dpe-cp1',
    type: 'conceptual',
    statement:
      'A company markets prefabricated steel storage racks for industrial warehouses. An employee with a mechanical engineering degree but no PE license performs the structural design of the racks, including seismic load calculations, and the company sells them across multiple states. The company argues that because the racks are a manufactured "product" sold off the shelf, no engineering license is needed. Under the Model Law, which statement is most accurate?',
    choices: [
      {
        id: 'c1',
        text: 'No license is needed because mass-produced manufactured products are always exempt from licensure'
      },
      {
        id: 'c2',
        text: 'No license is needed as long as the racks are sold in more than one state'
      },
      {
        id: 'c3',
        text: 'A license is never required for any work performed by a salaried employee of a company'
      },
      {
        id: 'c4',
        text: 'Structural and seismic design of the racks is the practice of engineering, but it may fall under the industrial exemption only if the statutory conditions are met; otherwise a licensed PE is required'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'Performing structural and seismic load calculations is squarely the practice of engineering under §110.20 A.3, because it requires engineering education and affects public safety. The Model Law does include an industrial exemption that can allow employees of certain manufacturers to perform engineering for their employer\'s products without individual licensure, but it applies only when the statutory conditions are satisfied; it is not automatic. Choice A treats "manufactured product" as a blanket exemption, which is wrong. Choice B invents a multistate rule that does not exist. Choice C wrongly claims all salaried-employee work is exempt. The accurate answer recognizes the work as engineering and conditions any exemption on meeting the statute.',
    hint: 'Is structural/seismic design "practice of engineering"? And is the industrial/manufacturing exemption automatic or conditional?',
    steps: [
      {
        text: 'Apply §110.20 A.3: structural and seismic load design requires engineering education and training and affects public safety, so it is the practice of engineering.',
        latex: null
      },
      {
        text: 'Recognize the industrial/manufacturing exemption: the Model Law may exempt employees performing engineering on their employer\'s products, but only when specific statutory conditions are met.',
        latex: null
      },
      {
        text: 'The exemption is conditional, not a blanket pass for any manufactured product, and it is unrelated to how many states the product is sold in.',
        latex: null
      },
      {
        text: 'If the exemption conditions are not met, the structural design must be performed by or under the responsible charge of a licensed PE.',
        latex: null
      }
    ],
    handbookPage: 'p. 6, Model Law §110.20 A.3',
    handbookFormula:
      '\\text{§110.20 A.3: Practice of engineering is any service requiring engineering education affecting public safety.}',
    videoUrl: null,
    traps: [
      'Treating "manufactured product" as an automatic exemption from licensure',
      'Inventing a multistate-sales rule that has no basis in the Model Law'
    ],
    diagram: null,
    lessonId: 'definitions-practice-of-engineering',
    chapterId: 'ethics'
  },
  {
    id: 'eth-dpe-cp2',
    type: 'conceptual',
    statement:
      'An Engineer Intern (EI) prepares the complete structural calculations and drawings for a small commercial building under the direct supervision of a licensed PE who reviews the work, directs revisions throughout the design, and exercises responsible charge. When the documents are finalized, who is authorized to sign and seal them, and whose seal is applied?',
    choices: [
      {
        id: 'c1',
        text: 'The EI may sign and seal because the EI prepared the documents'
      },
      {
        id: 'c2',
        text: 'The supervising PE signs and seals the documents, because the work was prepared under the PE\'s responsible charge'
      },
      {
        id: 'c3',
        text: 'Both the EI and the PE must sign and seal jointly'
      },
      {
        id: 'c4',
        text: 'No seal is required because the building is small and commercial'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Only a licensed PE may sign and seal engineering documents, and under Rule B.2 a PE may seal only work prepared under that PE\'s responsible charge. Here the supervising PE exercised responsible charge by directing the work throughout, so the PE signs and seals; the EI, who is not yet licensed, cannot seal. Choice A is wrong because preparing the work does not authorize an unlicensed EI to seal. Choice C invents a joint-sealing requirement that the Model Law does not have. Choice D is wrong because a small commercial building is not exempt from sealing. The supervising PE applies the seal.',
    hint: 'Who is allowed to apply a seal, and what does Rule B.2 require about responsible charge?',
    steps: [
      {
        text: 'Identify the roles: an unlicensed EI prepared the work; a licensed PE supervised and exercised responsible charge.',
        latex: null
      },
      {
        text: 'Apply the licensure requirement: only a licensed PE may sign and seal engineering documents.',
        latex: null
      },
      {
        text: 'Apply Rule B.2: a PE may seal documents only when the work was prepared under that PE\'s responsible charge, which is satisfied here.',
        latex: null
      },
      {
        text: 'The supervising PE signs and seals the documents. The EI cannot seal, and no joint seal is required.',
        latex: null
      }
    ],
    handbookPage: 'p. 5, Model Rules §240.15 B.2',
    handbookFormula:
      '\\text{B.2: Only a PE may seal, and only work prepared under the PE\'s responsible charge.}',
    videoUrl: null,
    traps: [
      'Assuming the person who prepared the documents may seal them regardless of licensure',
      'Inventing a joint-seal requirement for supervised work'
    ],
    diagram: null,
    lessonId: 'definitions-practice-of-engineering',
    chapterId: 'ethics'
  },
  {
    id: 'eth-lpd-cp1',
    type: 'computational',
    statement:
      'Under the typical Model Law experience schedule, a bachelor\'s degree from an EAC/ABET-accredited program requires four years of qualifying experience for PE licensure, a master\'s reduces the requirement to three years, and a doctorate (with the FE passed) reduces it to two years. An engineer earns an accredited bachelor\'s degree, works for one year, then completes a master\'s degree, and afterward continues working. The one year worked before the master\'s does not count toward the post-degree requirement. How many more years of qualifying experience after completing the master\'s does the engineer need?',
    choices: [
      { id: 'c1', text: '$2$ years' },
      { id: 'c2', text: '$1$ year' },
      { id: 'c3', text: '$3$ years' },
      { id: 'c4', text: '$4$ years' }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'A master\'s degree sets the qualifying-experience requirement at three years. The one year the engineer worked before earning the master\'s does not count toward that three-year post-degree requirement, so the full three years still must be completed after the master\'s. Choice A (2 years) uses the doctorate reduction by mistake. Choice B (1 year) wrongly credits the pre-master\'s year against the requirement. Choice D (4 years) uses the bachelor\'s requirement and ignores the master\'s reduction entirely. The answer is three years.',
    hint: 'Which degree governs the requirement, and does pre-degree experience count toward the post-degree requirement?',
    steps: [
      {
        text: 'The highest qualifying degree is the master\'s, which sets the experience requirement at three years.',
        latex: 'T_{req} = 3\\ \\text{years (master\'s)}'
      },
      {
        text: 'The one year worked before the master\'s does not count toward the post-degree requirement, so it contributes zero.',
        latex: 'T_{credit,\\,pre} = 0'
      },
      {
        text: 'The remaining required experience equals the full three-year post-master\'s requirement.',
        latex: 'T_{remaining} = 3 - 0 = 3\\ \\text{years}'
      }
    ],
    handbookPage: 'p. 8-9, Model Law §130.10 B.2.a',
    handbookFormula:
      '\\text{§130.10: Bachelor\'s = 4 yr; Master\'s = 3 yr; Doctorate + FE = 2 yr experience.}',
    videoUrl: null,
    traps: [
      'Using the doctorate reduction (2 years) instead of the master\'s reduction (3 years)',
      'Crediting pre-degree experience against a post-degree experience requirement'
    ],
    diagram: null,
    lessonId: 'licensure-path-disciplinary-action',
    chapterId: 'ethics'
  },
  {
    id: 'eth-lpd-cp2',
    type: 'conceptual',
    statement:
      'A licensed PE moves to a new state and applies for licensure by comity (reciprocity), holding a current license in good standing obtained originally by examination in another state. The new state\'s board reviews the application. Under the Model Law, which statement best describes how comity works?',
    choices: [
      {
        id: 'c1',
        text: 'Comity automatically grants a license in any state the moment the applicant moves, with no board review'
      },
      {
        id: 'c2',
        text: 'Comity allows the applicant to practice nationwide on the original license without applying in any other state'
      },
      {
        id: 'c3',
        text: 'Comity requires the applicant to retake both the FE and PE examinations in the new state'
      },
      {
        id: 'c4',
        text: 'The new state\'s board may grant a license by comity if the applicant\'s original licensure requirements were substantially equivalent to the new state\'s, subject to board review and any state-specific requirements'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Comity (also called reciprocity) lets a board issue a license to an engineer already licensed elsewhere when the original requirements were substantially equivalent to the new state\'s, but it is still an application the board reviews and may add state-specific requirements, such as a state ethics or laws exam. Choice A is wrong because comity is never automatic; it requires application and board review. Choice B is wrong because a single license does not authorize nationwide practice; licensure is jurisdiction-specific. Choice C is wrong because comity\'s whole purpose is to avoid re-examination when requirements are equivalent. The accurate description is board review for substantial equivalence.',
    hint: 'Is comity automatic and nationwide, or is it a board-reviewed application based on substantially equivalent requirements?',
    steps: [
      {
        text: 'Define comity: a board may license an engineer already licensed in another jurisdiction without full re-examination.',
        latex: null
      },
      {
        text: 'Apply the substantial-equivalence standard: the original licensure requirements must be substantially equivalent to the new state\'s requirements.',
        latex: null
      },
      {
        text: 'Recognize it is still an application subject to board review and possible state-specific requirements (for example, a state laws or ethics exam).',
        latex: null
      },
      {
        text: 'Licensure remains jurisdiction-specific, so the engineer must obtain the new state\'s license and is not authorized to practice nationwide on one license.',
        latex: null
      }
    ],
    handbookPage: 'p. 8-9, Model Law §130.10',
    handbookFormula:
      '\\text{Comity: license granted when prior requirements are substantially equivalent, subject to board review.}',
    videoUrl: null,
    traps: [
      'Believing comity is automatic or grants nationwide practice on a single license',
      'Assuming comity requires retaking the FE and PE exams in the new state'
    ],
    diagram: null,
    lessonId: 'licensure-path-disciplinary-action',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ips-cp1',
    type: 'computational',
    statement:
      'A civil engineering firm files a U.S. utility patent application for a new bridge-bearing design on March 1, 2020, and the patent is granted on June 1, 2023. A utility patent grants exclusive rights for 20 years measured from the filing date. In what year does the patent term expire, and for approximately how many years after the grant date does the firm hold enforceable exclusive rights?',
    choices: [
      { id: 'c1', text: 'Expires 2040; about 17 years of exclusivity after the grant date' },
      { id: 'c2', text: 'Expires 2043; about 20 years of exclusivity after the grant date' },
      { id: 'c3', text: 'Expires 2040; about 20 years of exclusivity after the grant date' },
      { id: 'c4', text: 'Expires 2038; about 15 years of exclusivity after the grant date' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'A utility patent term runs 20 years from the filing date, not the grant date. Filing was 2020, so the term expires in 2040 (2020 + 20). Because the patent was not granted until 2023, the firm can only enforce exclusivity from 2023 to 2040, which is about 17 years. Choice B wrongly measures 20 years from the grant date, giving 2043. Choice C correctly lands on 2040 but wrongly claims a full 20 years of post-grant exclusivity, double-counting the pendency. Choice D measures the term from the grant date and miscounts. The answer is expires 2040 with about 17 years of post-grant exclusivity.',
    hint: 'The 20-year term is measured from the filing date. Subtract the pendency (grant minus filing) to get post-grant exclusivity.',
    steps: [
      {
        text: 'Compute the expiration: 20 years from the filing date of 2020.',
        latex: '2020 + 20 = 2040'
      },
      {
        text: 'Compute the pendency from filing to grant.',
        latex: '2023 - 2020 = 3\\ \\text{years}'
      },
      {
        text: 'Compute post-grant exclusivity as the remaining term after the grant date.',
        latex: '20 - 3 = 17\\ \\text{years}'
      }
    ],
    handbookPage: 'p. 12, Intellectual Property — Patents',
    handbookFormula:
      '\\text{Patent: exclusive right to make, use, sell an invention for 20 years from filing date.}',
    videoUrl: null,
    traps: [
      'Measuring the 20-year term from the grant date instead of the filing date',
      'Ignoring the patent pendency when computing post-grant exclusivity'
    ],
    diagram: null,
    lessonId: 'intellectual-property-sustainability',
    chapterId: 'ethics'
  },
  {
    id: 'eth-ips-cp2',
    type: 'conceptual',
    statement:
      'A firm has been protecting a proprietary concrete-curing process as a trade secret. After a competitor begins reverse-engineering similar results, the firm considers filing a patent on the process to obtain stronger, enforceable protection. The firm\'s attorney explains the key trade-off. Which statement best describes the consequence of choosing patent protection over trade-secret protection for the same process?',
    choices: [
      {
        id: 'c1',
        text: 'Patenting lets the firm keep the process secret indefinitely while also barring competitors for 20 years'
      },
      {
        id: 'c2',
        text: 'A trade secret and a patent can both fully protect the same process at the same time with no downside'
      },
      {
        id: 'c3',
        text: 'Patenting requires public disclosure of the process, ending its trade-secret status, in exchange for a time-limited exclusive right of about 20 years'
      },
      {
        id: 'c4',
        text: 'Patenting provides no protection against reverse engineering, just like a trade secret'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'A patent and a trade secret are mutually exclusive for the same information. A patent requires you to publicly disclose how the invention works, which destroys any trade-secret status, and in return you get an exclusive right for a limited time, about 20 years from filing. A trade secret can last indefinitely but offers no protection against independent discovery or reverse engineering. Choice A wrongly claims you can have secrecy and a patent at once. Choice B says both fully protect the same process simultaneously, which contradicts the disclosure requirement. Choice D wrongly claims a patent does not protect against reverse engineering, but a patent does bar others from making or using the invention regardless of how they discovered it. The correct answer captures the disclosure-for-exclusivity trade-off.',
    hint: 'Can the same process be both a patent and a trade secret? What does a patent require you to give up?',
    steps: [
      {
        text: 'Recall trade-secret protection: potentially indefinite, but no protection against independent discovery or reverse engineering, and it depends on maintaining secrecy.',
        latex: null
      },
      {
        text: 'Recall patent protection: an exclusive right to make, use, and sell for about 20 years from filing, enforceable even against independent inventors and reverse engineers.',
        latex: null
      },
      {
        text: 'Recognize the trade-off: obtaining a patent requires public disclosure of the invention, which ends trade-secret status for that process.',
        latex: null
      },
      {
        text: 'Therefore the firm exchanges indefinite secrecy for a time-limited but publicly disclosed exclusive right; it cannot hold both for the same process.',
        latex: null
      }
    ],
    handbookPage: 'p. 12, Intellectual Property — Patents',
    handbookFormula:
      '\\text{Patent requires public disclosure; trade secret requires maintained secrecy. The two are mutually exclusive.}',
    videoUrl: null,
    traps: [
      'Believing a process can be simultaneously patented and kept as a trade secret',
      'Assuming a patent fails to protect against reverse engineering, which is actually a trade-secret weakness'
    ],
    diagram: null,
    lessonId: 'intellectual-property-sustainability',
    chapterId: 'ethics'
  }
];

export default PROBLEMS;
