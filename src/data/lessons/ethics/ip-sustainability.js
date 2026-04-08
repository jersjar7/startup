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
          text: 'Public health — Option B is safer for the workers during construction',
        },
        {
          id: 'c3',
          text: 'Life-cycle analysis — Option B has lower total environmental and economic impact when assessed from construction through end-of-life',
        },
        {
          id: 'c4',
          text: 'Quality of life — Option B causes less noise during construction',
        },
      ],
      correctAnswerId: 'c3',
      difficulty: 'medium',
      eli5: "The firm is recommending the option that costs more upfront but wins when you look at the whole picture — recycled materials, less maintenance, less environmental damage. That's textbook life-cycle analysis: evaluate from cradle to grave, not just day one. Choice A gets the concept of resource allocation backwards — it's about using resources efficiently, not just spending more. Choices B and D cherry-pick small benefits (worker safety, noise) that aren't the main reason for the recommendation. The real argument is that Option B is better across the entire project lifecycle when you factor in environmental, economic, and social costs together.",
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
          text: "Choice A misdefines resource allocation — it's about efficient use of resources, not spending more money.",
          latex: null,
        },
        {
          text: "Choices B and D pick narrow benefits that aren't the primary justification. The recommendation is based on the comprehensive lifecycle assessment.",
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
          text: 'Four — a patent for the membrane, a trademark for the brand name, a copyright for the paper, and a trade secret for the manufacturing process',
        },
        {
          id: 'c4',
          text: 'Three — a patent for the membrane, a trademark for the brand name, and a copyright for the paper',
        },
      ],
      correctAnswerId: 'c3',
      difficulty: 'hard',
      eli5: "This question tests whether you understand that the four IP types protect different things and can all coexist on the same project. The membrane itself is a patentable invention. \"AquaPure\" is a trademark — it's a brand name that identifies the product in the market. The paper is copyrighted the moment the engineer writes it — it's an original work of authorship. And the secret manufacturing process is a trade secret because it's kept confidential and gives a competitive edge. Choice A is wrong because patents don't cover brand names or written works. Choice B misses the trademark and trade secret. Choice D is close but forgets the manufacturing process — since it's not disclosed in the paper, it qualifies as a trade secret. All four types apply to different aspects.",
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
};
