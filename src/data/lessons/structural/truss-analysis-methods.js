export default {
  "id": "truss-analysis-methods",
  "name": "Truss Analysis: Joints & Sections",
  "subtopicId": "analysis-loads",
  "application": "Finding member forces in a determinate truss is a bread-and-butter FE structural-analysis skill. The method of joints gets you forces at a connection; the method of sections cuts straight to one member without solving the whole truss. Knowing when to use each — and spotting zero-force members instantly — saves real time on the exam.",
  "content": [
    {
      "type": "text",
      "body": "A truss carries load through axial forces only — every member is in pure tension or compression. Sign convention: treat unknown forces as TENSION (arrow pulling away from the joint). A negative answer then means the member is in compression."
    },
    {
      "type": "heading",
      "body": "Method of Joints"
    },
    {
      "type": "text",
      "body": "Isolate one joint and apply the two equilibrium equations $\\sum F_x = 0$ and $\\sum F_y = 0$. Because a joint gives only two equations, start at a joint with at most two unknown members. Resolve each inclined member into components using its geometry (rise/run)."
    },
    {
      "type": "formula",
      "latex": "\\sum F_x = 0, \\qquad \\sum F_y = 0 \\quad \\text{(at each joint)}"
    },
    {
      "type": "heading",
      "body": "Method of Sections"
    },
    {
      "type": "text",
      "body": "To find one specific member force without marching through every joint, cut an imaginary section through the truss (through at most three members whose forces are unknown) and treat one side as a rigid body. Take moments about the point where the other two cut members intersect — that isolates the force you want in a single equation."
    },
    {
      "type": "formula",
      "latex": "\\sum M_{\\text{point}} = 0 \\;\\Rightarrow\\; \\text{one unknown member force}",
      "label": "Pick the moment center to eliminate the other two cut members"
    },
    {
      "type": "heading",
      "body": "Zero-Force Members"
    },
    {
      "type": "text",
      "body": "Two quick rules: (1) at an unloaded joint with only two non-collinear members, both are zero-force; (2) at an unloaded joint with three members where two are collinear, the third (non-collinear) member is zero-force. Identifying these first removes members from the problem."
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "Use the method of sections when the problem asks for ONE member force (especially a chord member mid-truss). Use the method of joints when you need several forces or you're near a support. Always find the support reactions first."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "A negative member force is not an error — it means your tension assumption was wrong and the member is in compression. Report the magnitude with the correct sense (T or C)."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "str-tam-q1",
      "statement": "At joint A, a $500\\text{ lb}$ vertical (downward) load is carried by two members: a horizontal member AB and a diagonal member AC oriented at $45^\\circ$ above the horizontal. Using the method of joints, what is the force in diagonal AC?",
      "choices": [
        { "id": "c1", "text": "$707\\text{ lb}$" },
        { "id": "c2", "text": "$500\\text{ lb}$" },
        { "id": "c3", "text": "$1000\\text{ lb}$" },
        { "id": "c4", "text": "$354\\text{ lb}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Only the diagonal can resist the vertical load — the horizontal member has no vertical component. So $\\sum F_y = 0$ gives $F_{AC}\\sin 45^\\circ = 500$, hence $F_{AC} = 500/0.707 = 707$ lb. The 500 lb choice forgets to divide by $\\sin 45^\\circ$. The 354 lb choice multiplies by $\\sin 45^\\circ$ instead of dividing.",
      "hint": "Only the diagonal has a vertical component — use $\\sum F_y = 0$ at joint A.",
      "steps": [
        { "text": "Horizontal member AB carries no vertical force, so the diagonal must balance the load.", "latex": null },
        { "text": "$\\sum F_y = 0$:", "latex": "F_{AC}\\sin 45^\\circ = 500" },
        { "text": "Solve:", "latex": "F_{AC} = \\frac{500}{\\sin 45^\\circ} = \\frac{500}{0.707} = 707\\text{ lb}" }
      ],
      "handbookPage": null,
      "handbookFormula": "\\sum F_y = 0",
      "videoUrl": null,
      "traps": [
        "Forgetting to divide by sin 45° and reporting 500 lb",
        "Multiplying by sin 45° (354) instead of dividing"
      ],
      "diagram": { "component": "TrussJointFBD", "props": {"load":500,"angle":45,"unit":"lb"} }
    },
    {
      "id": "str-tam-q2",
      "statement": "A parallel-chord truss has panel length $4\\text{ m}$ and height $3\\text{ m}$. The left support reaction is $30\\text{ kN}$ (upward) and there are no loads within the first panel. Taking a vertical section through the first panel and summing moments about the top-chord joint at the far end of the panel, what is the force in the bottom chord?",
      "choices": [
        { "id": "c1", "text": "$40\\text{ kN (tension)}$" },
        { "id": "c2", "text": "$30\\text{ kN (tension)}$" },
        { "id": "c3", "text": "$22.5\\text{ kN}$" },
        { "id": "c4", "text": "$120\\text{ kN}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "hard",
      "eli5": "Summing moments about the top joint kills the diagonal and the top chord (they pass through or are arms about that point), leaving only the bottom chord. The reaction acts $4\\text{ m}$ horizontally from the moment center; the bottom chord acts at the $3\\text{ m}$ height. So $30(4) = F_{BC}(3)$, giving $F_{BC} = 120/3 = 40\\text{ kN}$ tension. The 120 kN option forgets to divide by the 3 m height.",
      "hint": "Take moments about the top joint so only the bottom chord remains: reaction × panel length = force × height.",
      "steps": [
        { "text": "Moment center at the top joint eliminates the top chord and diagonal.", "latex": null },
        { "text": "$\\sum M = 0$: reaction times its horizontal arm equals bottom-chord force times the height.", "latex": "30\\,(4) = F_{BC}\\,(3)" },
        { "text": "Solve:", "latex": "F_{BC} = \\frac{120}{3} = 40\\text{ kN (tension)}" }
      ],
      "handbookPage": null,
      "handbookFormula": "\\sum M_{\\text{point}} = 0",
      "videoUrl": null,
      "traps": [
        "Forgetting to divide by the truss height (reporting 120 kN)",
        "Using the height as the reaction's moment arm instead of the panel length"
      ],
      "diagram": null
    },
    {
      "id": "str-tam-q3",
      "statement": "At an unloaded joint, three members meet: two are collinear (in a straight line through the joint) and the third comes in at an angle. No external load or reaction acts at this joint. What is the force in the angled (third) member?",
      "choices": [
        { "id": "c1", "text": "Zero" },
        { "id": "c2", "text": "Equal to the force in the collinear members" },
        { "id": "c3", "text": "Half the collinear force" },
        { "id": "c4", "text": "Cannot be determined" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "Set up equilibrium perpendicular to the two collinear members. The two collinear members have no component in that perpendicular direction, and there's no external load — so the only force with a component there is the angled member, which must therefore be zero. This is the classic zero-force-member rule.",
      "hint": "Sum forces perpendicular to the two collinear members.",
      "steps": [
        { "text": "The two collinear members act along one line; resolve forces perpendicular to that line.", "latex": null },
        { "text": "Only the angled member has a perpendicular component, and there is no external load to balance it.", "latex": null },
        { "text": "Therefore the angled member carries zero force (zero-force member).", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": null,
      "videoUrl": null,
      "traps": [
        "Assuming every member carries load — zero-force members are common at unloaded joints",
        "Confusing this with the two-member unloaded-joint rule"
      ],
      "diagram": { "component": "ZeroForceJoint", "props": {} }
    }
  ]
};
