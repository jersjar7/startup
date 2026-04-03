export default {
  id: 'intellectual-property-sustainability',
  name: 'Intellectual Property, Sustainability & Societal Considerations',
  subtopicId: 'broader-responsibilities',
  application:
    'Engineers create valuable designs, methods, and innovations — and need to know how to protect them. The FE tests whether you can distinguish between patents, trademarks, copyrights, and trade secrets, and pick the right protection for a given scenario. It also tests sustainability principles: life-cycle analysis, resource conservation, and the "triple bottom line" of economic, environmental, and social impact. Civil engineers make decisions every day that affect ecosystems, public health, and long-term resource use — from choosing materials for a highway to designing a stormwater system that minimizes pollution.',
  content: [
    {
      type: 'text',
      body: "The FE Handbook devotes about two pages to intellectual property and sustainability. These aren't deep technical topics — the exam tests whether you can match the right IP protection to a scenario and whether you understand the principles behind sustainable engineering.",
    },
    { type: 'heading', body: 'Four Types of Intellectual Property Protection' },
    {
      type: 'text',
      body: 'Patents protect inventions. There are three types: utility patents (new processes, machines, or compositions of matter), design patents (ornamental designs for manufactured articles), and plant patents (new plant varieties reproduced asexually). A patent lasts 20 years from the filing date and is only effective within the U.S. and its territories.',
    },
    {
      type: 'text',
      body: 'Trademarks protect words, names, symbols, or devices used in trade to identify the source of goods. A trademark prevents others from using a confusingly similar mark — but it does not prevent others from making or selling the same goods under a different mark.',
    },
    {
      type: 'text',
      body: 'Copyrights protect original works of authorship — literary, dramatic, musical, artistic, and other intellectual works. The owner gets exclusive rights to reproduce, distribute, perform, and display the work. Think: documents, drawings, reports, and software code.',
    },
    {
      type: 'text',
      body: 'Trade secrets protect formulas, patterns, methods, techniques, or processes that give a business a competitive advantage. Unlike patents, trade secrets have no registration or time limit — but they require a written agreement between parties and offer little protection without one.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: "Quick decision tree: Is it an invention or process? → Patent. Is it a brand identifier (name, logo, symbol)? → Trademark. Is it a creative work (writing, art, code, drawings)? → Copyright. Is it a secret method that gives you a competitive edge? → Trade secret.",
    },
    {
      type: 'callout',
      variant: 'warning',
      body: "Common exam trap: confusing patents and trade secrets. A patent requires public disclosure of the invention in exchange for 20 years of protection. A trade secret stays secret indefinitely but has no legal protection if someone independently discovers it. You can't have both for the same thing.",
    },
    { type: 'heading', body: 'Sustainability Principles' },
    {
      type: 'text',
      body: 'Sustainable engineering means delivering solutions that are technically viable, economically feasible, and environmentally and socially sustainable. The handbook lists six core considerations: safety, public health, quality of life, resource allocation, non-renewable resources, and life-cycle analysis.',
    },
    { type: 'heading', body: 'Life-Cycle Analysis' },
    {
      type: 'text',
      body: 'Life-cycle analysis (LCA) — also called "cradle to grave" — assesses the environmental impact of a project or product from design through disposal. Engineers must address landscape aesthetics, ecosystem protection, resource conservation, air and water pollution, atmospheric emissions, and waste collection and processing.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The exam usually frames sustainability as a "which of the following is NOT a principle of sustainable engineering?" question. Know the six considerations from the handbook and the LCA factors. If an answer choice focuses only on cost savings without mentioning environmental or social impact, it\'s probably wrong.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'Remember the triple bottom line: people (social), planet (environmental), profit (economic). Sustainable engineering requires all three — optimizing cost alone is not sustainable design.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'eth-ips-q1',
      statement:
        "A civil engineering firm develops a unique proprietary software algorithm that optimizes concrete mix designs for specific climate conditions. The firm wants to protect this algorithm but does not want to publicly disclose how it works. Which form of intellectual property protection is most appropriate?",
      choices: [
        {
          id: 'c1',
          text: 'Utility patent',
        },
        {
          id: 'c2',
          text: 'Copyright',
        },
        {
          id: 'c3',
          text: 'Trademark',
        },
        {
          id: 'c4',
          text: 'Trade secret',
        },
      ],
      correctAnswerId: 'c4',
      difficulty: 'easy',
      eli5: "The key word here is \"does not want to publicly disclose.\" That eliminates patents immediately — the whole deal with a patent is you reveal how it works in exchange for 20 years of legal protection. The firm wants secrecy, not disclosure. Copyright protects the actual code (the written expression) but not the algorithm behind it — someone could write different code that does the same thing and copyright wouldn't help. Trademark is for brand names and logos, not methods. Trade secret is the only option that protects a method while keeping it confidential.",
      hint: 'Which IP protection lets you keep your method confidential instead of disclosing it publicly?',
      steps: [
        {
          text: "Identify what's being protected: a proprietary algorithm (a method/process) that the firm wants to keep confidential.",
          latex: null,
        },
        {
          text: 'A utility patent would protect the algorithm, but it requires public disclosure of how it works — the firm explicitly wants to avoid this.',
          latex: null,
        },
        {
          text: 'A copyright protects the expression of ideas (the source code) but not the underlying algorithm or method itself.',
          latex: null,
        },
        {
          text: 'A trademark protects brand identifiers (names, logos) — not applicable to an algorithm.',
          latex: null,
        },
        {
          text: "A trade secret protects formulas, methods, techniques, or processes that give a competitive advantage and are kept confidential. This matches the firm's needs perfectly.",
          latex: null,
        },
      ],
      handbookPage: 'p. 12, Intellectual Property — Trade Secrets',
      handbookFormula:
        '\\text{Trade secret: formula, pattern, method, technique, or process used in business for competitive advantage.}',
      videoUrl: null,
      traps: [
        'Choosing patent because algorithms are "inventions" — true, but patents require public disclosure, which the firm wants to avoid',
        'Choosing copyright because software is involved — copyright protects the code expression, not the underlying algorithm',
      ],
      diagram: null,
    },
    {
      id: 'eth-ips-q2',
      statement:
        'A county government asks an engineering firm to evaluate three options for replacing an aging bridge. The firm recommends Option B, which has a higher initial construction cost than Option A but uses recycled steel, reduces long-term maintenance, and minimizes disruption to the adjacent wetland ecosystem. Which principle of sustainable engineering best supports the firm\'s recommendation?',
      choices: [
        {
          id: 'c1',
          text: 'Resource allocation — Option B costs more upfront, which means more resources are allocated to the project',
        },
        {
          id: 'c2',
          text: 'Life-cycle analysis — Option B has lower total environmental and economic impact when assessed from construction through end-of-life',
        },
        {
          id: 'c3',
          text: 'Public health — Option B is safer for the workers during construction',
        },
        {
          id: 'c4',
          text: 'Quality of life — Option B causes less noise during construction',
        },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: "The firm is recommending the option that costs more upfront but wins when you look at the whole picture — recycled materials, less maintenance, less environmental damage. That's textbook life-cycle analysis: evaluate from cradle to grave, not just day one. Answer A gets the concept of resource allocation backwards — it's about using resources efficiently, not just spending more. Answers C and D cherry-pick small benefits (worker safety, noise) that aren't the main reason for the recommendation. The real argument is that Option B is better across the entire project lifecycle when you factor in environmental, economic, and social costs together.",
      hint: 'Which sustainability principle requires evaluating a project from design and construction all the way through end-of-life?',
      steps: [
        {
          text: 'Identify the factors in the recommendation: recycled materials (resource conservation), lower long-term maintenance (economic sustainability over time), and minimal wetland disruption (ecosystem protection).',
          latex: null,
        },
        {
          text: 'These factors span the full project lifecycle — from material sourcing and construction through operation and maintenance.',
          latex: null,
        },
        {
          text: "Life-cycle analysis (cradle to grave) assesses environmental consequences from design through disposal. Option B's advantages only become clear when you look at the full lifecycle, not just initial cost.",
          latex: null,
        },
        {
          text: "Answer A misdefines resource allocation — it's about efficient use of resources, not spending more money.",
          latex: null,
        },
        {
          text: "Answers C and D pick narrow benefits that aren't the primary justification. The recommendation is based on the comprehensive lifecycle assessment.",
          latex: null,
        },
      ],
      handbookPage: 'p. 13, Societal Considerations — Life-cycle analysis',
      handbookFormula:
        '\\text{Life-cycle analysis (cradle to grave): assessing environmental consequences from design through disposal.}',
      videoUrl: null,
      traps: [
        'Confusing "resource allocation" with "spending more money" — resource allocation is about efficient distribution, not higher budgets',
        'Picking a narrow benefit (safety, noise) instead of the comprehensive lifecycle assessment that actually drives the recommendation',
      ],
      diagram: null,
    },
    {
      id: 'eth-ips-q3',
      statement:
        'An environmental engineer develops a new water filtration membrane, brands it "AquaPure," writes a detailed technical paper describing the membrane\'s design, and uses a proprietary manufacturing process that is not disclosed in the paper. How many distinct types of intellectual property protection could potentially apply to different aspects of this work?',
      choices: [
        {
          id: 'c1',
          text: 'One — a patent covers the membrane, the brand, and the paper',
        },
        {
          id: 'c2',
          text: 'Two — a patent for the membrane and a copyright for the paper',
        },
        {
          id: 'c3',
          text: 'Three — a patent for the membrane, a trademark for the brand name, and a copyright for the paper',
        },
        {
          id: 'c4',
          text: 'Four — a patent for the membrane, a trademark for the brand name, a copyright for the paper, and a trade secret for the manufacturing process',
        },
      ],
      correctAnswerId: 'c4',
      difficulty: 'hard',
      eli5: "This question tests whether you understand that the four IP types protect different things and can all coexist on the same project. The membrane itself is a patentable invention. \"AquaPure\" is a trademark — it's a brand name that identifies the product in the market. The paper is copyrighted the moment the engineer writes it — it's an original work of authorship. And the secret manufacturing process is a trade secret because it's kept confidential and gives a competitive edge. Answer A is wrong because patents don't cover brand names or written works. Answer B misses the trademark and trade secret. Answer C is close but forgets the manufacturing process — since it's not disclosed in the paper, it qualifies as a trade secret. All four types apply to different aspects.",
      hint: "Consider each element separately — the physical invention, the brand name, the written paper, and the undisclosed process. Does each one map to a different type of IP protection?",
      steps: [
        {
          text: 'Identify the distinct intellectual property elements in the scenario.',
          latex: null,
        },
        {
          text: 'The water filtration membrane is a new invention (a physical product/composition of matter) → utility patent.',
          latex: null,
        },
        {
          text: '"AquaPure" is a brand name used in trade to identify the source of goods → trademark.',
          latex: null,
        },
        {
          text: 'The technical paper is an original work of authorship → copyright.',
          latex: null,
        },
        {
          text: 'The proprietary manufacturing process is not disclosed in the paper and gives a competitive advantage → trade secret.',
          latex: null,
        },
        {
          text: 'Each type of IP protection applies to a different aspect of the work. They are not mutually exclusive — a single project can involve all four types simultaneously.',
          latex: null,
        },
      ],
      handbookPage: 'p. 12, Intellectual Property — Patents, Trademarks, Copyrights, Trade Secrets',
      handbookFormula:
        '\\text{Patent = invention; Trademark = brand identifier; Copyright = authorship; Trade secret = confidential method.}',
      videoUrl: null,
      traps: [
        "Assuming that a patent covers everything related to the invention — it only covers the invention itself, not the brand name, written description, or secret processes",
        "Missing the trade secret because the manufacturing process isn't the focus of the scenario — but it's explicitly described as proprietary and undisclosed",
      ],
      diagram: null,
    },
  ],
  examProblems: [
    {
      id: 'eth-ips-ex1',
      type: 'conceptual',
      statement: 'A structural engineering firm creates a new type of seismic base-isolation bearing and files a utility patent for the design. A competing firm independently develops a functionally identical bearing two years later without any knowledge of the first firm\'s work. Under U.S. patent law, which of the following is correct?',
      choices: [
        { id: 'c1', text: 'The competing firm infringes on the patent regardless of independent development' },
        { id: 'c2', text: 'Independent development is a valid defense against patent infringement' },
        { id: 'c3', text: 'The patent is invalid because two firms arrived at the same design' },
        { id: 'c4', text: 'Both firms share equal rights to the patent since the invention was obvious' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'Patents give the holder exclusive rights to the invention for 20 years, regardless of whether someone else independently comes up with the same thing. That is the core trade-off of the patent system: you publicly disclose your invention, and in return, nobody else can make, use, or sell it without your permission. Independent development is NOT a defense for patents \u2014 that defense only works for trade secrets. Choice B confuses the patent rule with the trade-secret rule. Choice C is wrong because two people arriving at the same design does not invalidate a patent. Choice D invents a sharing concept that does not exist in patent law.',
      hint: 'Think about what distinguishes a patent from a trade secret. Which one protects against independent discovery?',
      steps: [
        { text: 'A utility patent grants exclusive rights to make, use, and sell an invention for 20 years from the filing date.', latex: null },
        { text: 'Patent rights are absolute \u2014 independent development by a competitor is NOT a defense against infringement.', latex: null },
        { text: 'This is the key difference from trade secrets: if someone independently discovers a trade secret, the original holder has no legal recourse. Patents are the opposite.', latex: null },
        { text: 'Choice B describes the trade-secret rule, not the patent rule. Choice C and D misunderstand how patent validity works.', latex: null },
      ],
      handbookPage: 'p. 12, Intellectual Property \u2014 Patents',
      handbookFormula: '\\text{Patent: exclusive right to make, use, sell an invention for 20 years from filing date.}',
      videoUrl: null,
      traps: ['Confusing the patent rule with the trade-secret rule \u2014 independent discovery is only a defense for trade secrets', 'Assuming that identical independent invention invalidates a patent'],
      diagram: null,
    },
    {
      id: 'eth-ips-ex2',
      type: 'conceptual',
      statement: 'A municipality hires an engineering firm to design a pedestrian bridge. The firm produces detailed CAD drawings, structural calculations, and a final design report. The contract is silent on intellectual property ownership. Under standard copyright principles, who owns the copyright to the design documents?',
      choices: [
        { id: 'c1', text: 'The municipality, because they paid for the work' },
        { id: 'c2', text: 'The engineering firm, because the engineers are the authors of the original works' },
        { id: 'c3', text: 'Both parties share ownership equally by default' },
        { id: 'c4', text: 'No one \u2014 engineering drawings cannot be copyrighted' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'Copyright belongs to the creator of the original work unless there is a written agreement transferring ownership, or the work qualifies as "work for hire" under specific conditions. When a firm is an independent contractor (not an employee of the municipality), the default is that the firm retains copyright to its own documents. The municipality paid for the service, not the IP rights. Choice A is the most common misconception \u2014 paying for work does not automatically transfer copyright. Choice C invents a default sharing arrangement that does not exist. Choice D is flat wrong \u2014 engineering drawings, reports, and calculations are copyrightable works of authorship.',
      hint: 'Copyright belongs to the author by default. Paying someone to create a work does not automatically transfer the copyright unless the contract says so.',
      steps: [
        { text: 'Copyright automatically vests in the author (creator) of an original work at the moment of creation.', latex: null },
        { text: 'When a firm is hired as an independent contractor, the firm is the author of its deliverables unless the contract includes a written IP assignment.', latex: null },
        { text: 'The contract is silent on IP, so the default rule applies: the engineering firm owns the copyright.', latex: null },
        { text: 'The municipality has an implied license to use the documents for the project, but ownership remains with the firm.', latex: null },
      ],
      handbookPage: 'p. 12, Intellectual Property \u2014 Copyrights',
      handbookFormula: '\\text{Copyright: exclusive rights to reproduce, distribute, perform, and display original works of authorship.}',
      videoUrl: null,
      traps: ['Assuming the client owns the copyright because they paid for the work', 'Believing engineering drawings cannot be copyrighted'],
      diagram: null,
    },
    {
      id: 'eth-ips-ex3',
      type: 'conceptual',
      statement: 'A city council asks an engineering team to recommend a stormwater management approach for a new development. The team evaluates three options: (A) conventional concrete pipes with lowest upfront cost, (B) bioswales and rain gardens with moderate cost but reduced downstream flooding and improved water quality, and (C) an underground cistern system with the highest cost and best flood control. Which option best reflects the principles of sustainable engineering as defined in the FE Handbook?',
      choices: [
        { id: 'c1', text: 'Option A, because minimizing cost is the primary engineering obligation' },
        { id: 'c2', text: 'Option B, because it balances economic feasibility with environmental and social benefits across the project lifecycle' },
        { id: 'c3', text: 'Option C, because the most expensive option always provides the most sustainable outcome' },
        { id: 'c4', text: 'All three options are equally sustainable since they all manage stormwater' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'Sustainable engineering is about the triple bottom line: economic viability, environmental protection, and social benefit. Option B hits all three \u2014 it is affordable (not the cheapest, but feasible), reduces downstream flooding (social benefit), and improves water quality (environmental benefit). Option A only optimizes for cost, ignoring environmental and social impact. Option C sounds good, but "most expensive = most sustainable" is not a valid principle \u2014 sustainability requires economic feasibility too. Choice D dodges the question entirely; simply managing stormwater is not the same as doing it sustainably.',
      hint: 'Sustainable engineering balances three pillars: economic, environmental, and social. Which option addresses all three without ignoring any?',
      steps: [
        { text: 'Recall the triple bottom line: people (social), planet (environmental), profit (economic). Sustainable engineering requires balance among all three.', latex: null },
        { text: 'Option A minimizes cost but ignores environmental and social considerations \u2014 that is cost optimization, not sustainable design.', latex: null },
        { text: 'Option B has moderate cost (economically feasible), reduces flooding (social), and improves water quality (environmental) \u2014 it balances all three pillars.', latex: null },
        { text: 'Option C assumes highest cost equals best sustainability, but the FE Handbook requires economic feasibility as a pillar. Overspending without proportional benefit is not sustainable.', latex: null },
      ],
      handbookPage: 'p. 13, Societal Considerations \u2014 Sustainability',
      handbookFormula: '\\text{Sustainable = technically viable + economically feasible + environmentally and socially responsible.}',
      videoUrl: null,
      traps: ['Equating lowest cost with best engineering practice', 'Assuming the most expensive option is automatically the most sustainable'],
      diagram: null,
    },
    {
      id: 'eth-ips-ex4',
      type: 'conceptual',
      statement: 'A geotechnical engineering firm develops a proprietary soil stabilization technique that gives them a major competitive advantage. An engineer who helped develop the technique leaves the firm (without a non-compete agreement) and begins using the same technique at a new employer. The original firm sues for trade-secret misappropriation. Which factor is MOST critical to the original firm\'s case?',
      choices: [
        { id: 'c1', text: 'Whether the departing engineer signed a confidentiality or non-disclosure agreement' },
        { id: 'c2', text: 'Whether the original firm filed a patent for the technique' },
        { id: 'c3', text: 'Whether the departing engineer was the sole inventor of the technique' },
        { id: 'c4', text: 'Whether the new employer is in the same geographic market' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: 'Trade-secret protection hinges on the owner taking reasonable steps to keep the information confidential. The single most critical piece of evidence is a written confidentiality or non-disclosure agreement (NDA). Without an NDA, the firm has a much weaker case because they failed to demonstrate that they treated the technique as a secret. The FE Handbook specifically states that trade secrets "require a written agreement between parties" for protection. Choice B is wrong because filing a patent would mean publicly disclosing the technique \u2014 you cannot have both a patent and a trade secret for the same thing. Choice C is irrelevant because trade-secret rights belong to the firm, not individual inventors. Choice D (geographic market) is not a factor in trade-secret law.',
      hint: 'Trade secrets require the owner to take reasonable measures to maintain secrecy. What is the most concrete evidence of that effort?',
      steps: [
        { text: 'Trade-secret protection requires: (1) the information provides competitive advantage, (2) the owner took reasonable steps to maintain its secrecy, and (3) a written agreement exists between the parties.', latex: null },
        { text: 'A confidentiality or non-disclosure agreement is the most direct evidence that the firm treated the technique as confidential and that the engineer understood the obligation.', latex: null },
        { text: 'Without a written agreement, the firm\'s claim is significantly weakened \u2014 the handbook emphasizes that trade secrets offer "little protection without" such an agreement.', latex: null },
        { text: 'Choice B is a contradiction: filing a patent means publicly disclosing the technique, which destroys trade-secret status.', latex: null },
        { text: 'Choice C misplaces ownership. In employment contexts, the firm typically owns trade secrets developed on the job, not the individual engineer.', latex: null },
      ],
      handbookPage: 'p. 12, Intellectual Property \u2014 Trade Secrets',
      handbookFormula: '\\text{Trade secret: requires written agreement between parties; little protection without one.}',
      videoUrl: null,
      traps: ['Thinking a patent application strengthens a trade-secret claim \u2014 patents require disclosure, which destroys the secret', 'Focusing on who invented the technique rather than whether confidentiality measures were in place'],
      diagram: null,
    },
  ],
};
