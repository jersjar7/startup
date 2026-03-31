export default {
  context: 'This chapter covers project delivery, scheduling (CPM), estimating, safety, and construction operations.',
  subtopics: [
    { id: 'documents',            name: 'Construction Documents' },
    { id: 'procurement',          name: 'Procurement & Delivery Methods' },
    { id: 'operations',           name: 'Construction Operations & Methods' },
    { id: 'cpm-scheduling',       name: 'Critical Path Method (CPM)' },
    { id: 'network-analysis',     name: 'Network Analysis & Float' },
    { id: 'project-management',   name: 'Project Management' },
    { id: 'estimating',           name: 'Construction Estimating' },
    { id: 'safety',               name: 'Construction Safety (OSHA)' },
    { id: 'quality-control',      name: 'Quality Control & Assurance' },
  ],
  formulas: [
    { latex: 'TF = LS - ES = LF - EF', label: 'Total Float', page: 'p. 127' },
    { latex: 'FF = ES_j - EF_i', label: 'Free Float', page: 'p. 127' },
    { latex: '\\text{Duration} = \\frac{\\text{Quantity}}{\\text{Production Rate}}', label: 'Activity Duration', page: 'p. 128' },
    { latex: 'ES \\to EF \\text{ (forward)},\\quad LF \\to LS \\text{ (backward)}', label: 'CPM Pass Direction', page: 'p. 127' },
  ],
  traps: [
    'Critical path has ZERO total float — if you calculate negative float, your backward pass has an error.',
    'Free float ≤ total float — always. If your free float exceeds total float, recheck the calculation.',
    'Design-bid-build vs. design-build: in DBB the owner holds separate contracts; in DB one entity does both.',
    'OSHA excavation safety: trenches > 5 ft deep require protective systems (sloping, shoring, or shielding).',
    'Confusing the forward pass (ES→EF, use MAX of predecessors) with backward pass (LF→LS, use MIN of successors).',
  ],
};
