export default {
  "id": "deflection-virtual-work",
  "name": "Deflection of Determinate Structures",
  "subtopicId": "analysis-loads",
  "application": "The FE asks you to find how far a determinate beam, truss, or frame moves under load — for serviceability checks and to set up indeterminate analysis. The unit-load (virtual work) method is the general tool, and for common beams you simply look up a deflection formula. Both show up on the exam.",
  "content": [
    {
      "type": "text",
      "body": "To find the deflection (or rotation) at a point, apply a VIRTUAL unit load there in the direction you want, then integrate the product of the real and virtual internal forces. This 'unit-load method' works for any determinate structure."
    },
    {
      "type": "heading",
      "body": "Trusses — Unit-Load Method"
    },
    {
      "type": "formula",
      "latex": "\\delta = \\sum \\frac{n\\,N\\,L}{A\\,E}",
      "label": "N = real member force, n = force from a unit load at the point"
    },
    {
      "type": "text",
      "body": "For each member, multiply the real axial force $N$ by the force $n$ produced by a unit load at the joint of interest, times $L/AE$, and sum over all members."
    },
    {
      "type": "heading",
      "body": "Beams & Frames — Unit-Load Method"
    },
    {
      "type": "formula",
      "latex": "\\delta = \\int \\frac{m\\,M}{E\\,I}\\,dx",
      "label": "M = real moment diagram, m = moment from the virtual unit load"
    },
    {
      "type": "heading",
      "body": "Standard Beam Deflections (lookups)"
    },
    {
      "type": "formula",
      "latex": "\\delta_{\\max} = \\frac{PL^3}{48EI} \\;\\text{(simple, central } P)\\quad \\delta_{\\max} = \\frac{5wL^4}{384EI}\\;\\text{(simple, UDL)}"
    },
    {
      "type": "formula",
      "latex": "\\delta_{\\text{tip}} = \\frac{PL^3}{3EI}\\;\\text{(cantilever, end } P)\\quad \\delta_{\\text{tip}} = \\frac{wL^4}{8EI}\\;\\text{(cantilever, UDL)}"
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "On the exam, first check whether the beam/loading matches a standard case in the handbook deflection table — if so, just plug into the formula. Reserve the full unit-load integral for non-standard cases or truss/frame deflections."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "Watch the powers of L: a point load gives $L^3$, a distributed load gives $L^4$. And keep units consistent — mixing kN·m² with N·mm² is the #1 numerical error."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "str-dvw-q1",
      "statement": "Using the unit-load method for a truss, $\\delta = \\sum nNL/AE$. For one member, the real force is $N = 50\\text{ kN}$, the virtual (unit-load) force is $n = 0.5$, the length is $L = 4\\text{ m}$, and $AE = 200{,}000\\text{ kN}$. What is this member's contribution to the joint deflection?",
      "choices": [
        { "id": "c1", "text": "$0.5\\text{ mm}$" },
        { "id": "c2", "text": "$1.0\\text{ mm}$" },
        { "id": "c3", "text": "$5.0\\text{ mm}$" },
        { "id": "c4", "text": "$0.05\\text{ mm}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Plug into $nNL/AE = (0.5)(50)(4)/200{,}000 = 100/200{,}000 = 0.0005\\text{ m} = 0.5\\text{ mm}$. The trap is units: $0.0005\\text{ m}$ is $0.5\\text{ mm}$, not $5\\text{ mm}$ (Choice C) or $0.05\\text{ mm}$ (Choice D).",
      "hint": "Compute nNL then divide by AE; convert meters to millimeters carefully.",
      "steps": [
        { "text": "Numerator: $nNL = 0.5 \\times 50 \\times 4 = 100\\text{ kN·m}$.", "latex": null },
        { "text": "Divide by AE:", "latex": "\\delta = \\frac{100}{200{,}000} = 5\\times 10^{-4}\\text{ m}" },
        { "text": "Convert: $5\\times 10^{-4}\\text{ m} = 0.5\\text{ mm}$.", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": "\\delta = \\sum \\frac{nNL}{AE}",
      "videoUrl": null,
      "traps": [
        "Unit slip: writing 5 mm or 0.05 mm instead of 0.5 mm",
        "Forgetting to multiply by the virtual force n"
      ],
      "diagram": null
    },
    {
      "id": "str-dvw-q2",
      "statement": "A simply supported beam of length $L = 6\\text{ m}$ carries a central point load $P = 20\\text{ kN}$. The flexural rigidity is $EI = 40{,}000\\text{ kN·m}^2$. What is the maximum deflection?",
      "choices": [
        { "id": "c1", "text": "$2.25\\text{ mm}$" },
        { "id": "c2", "text": "$1.13\\text{ mm}$" },
        { "id": "c3", "text": "$9.0\\text{ mm}$" },
        { "id": "c4", "text": "$0.45\\text{ mm}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Central point load on a simple span uses $\\delta = PL^3/48EI = 20(6^3)/(48 \\times 40{,}000) = 4320/1{,}920{,}000 = 0.00225\\text{ m} = 2.25\\text{ mm}$. Choice C (9 mm) uses $PL^3/12EI$ by mistake; Choice B halves the answer.",
      "hint": "Central point load, simple span → $PL^3/48EI$.",
      "steps": [
        { "text": "Identify the standard case: simple span, central P.", "latex": null },
        { "text": "Apply the formula:", "latex": "\\delta = \\frac{PL^3}{48EI} = \\frac{20(6)^3}{48(40{,}000)}" },
        { "text": "Compute:", "latex": "\\delta = \\frac{4320}{1{,}920{,}000} = 0.00225\\text{ m} = 2.25\\text{ mm}" }
      ],
      "handbookPage": null,
      "handbookFormula": "\\delta_{\\max} = \\frac{PL^3}{48EI}",
      "videoUrl": null,
      "traps": [
        "Using the wrong constant (e.g. 12EI) in the denominator",
        "Mixing the point-load (L³) and UDL (L⁴) formulas"
      ],
      "diagram": null
    },
    {
      "id": "str-dvw-q3",
      "statement": "A cantilever beam of length $L = 3\\text{ m}$ carries a point load $P = 10\\text{ kN}$ at its free end. With $EI = 20{,}000\\text{ kN·m}^2$, what is the tip deflection?",
      "choices": [
        { "id": "c1", "text": "$4.5\\text{ mm}$" },
        { "id": "c2", "text": "$1.1\\text{ mm}$" },
        { "id": "c3", "text": "$13.5\\text{ mm}$" },
        { "id": "c4", "text": "$2.25\\text{ mm}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "End-loaded cantilever: $\\delta = PL^3/3EI = 10(27)/(3 \\times 20{,}000) = 270/60{,}000 = 0.0045\\text{ m} = 4.5\\text{ mm}$. Choice D (2.25) wrongly uses the simple-span $48EI$ constant; Choice C uses $EI$ alone in the denominator.",
      "hint": "End-loaded cantilever → $PL^3/3EI$.",
      "steps": [
        { "text": "Standard case: cantilever, end point load.", "latex": null },
        { "text": "Apply the formula:", "latex": "\\delta = \\frac{PL^3}{3EI} = \\frac{10(3)^3}{3(20{,}000)}" },
        { "text": "Compute:", "latex": "\\delta = \\frac{270}{60{,}000} = 0.0045\\text{ m} = 4.5\\text{ mm}" }
      ],
      "handbookPage": null,
      "handbookFormula": "\\delta_{\\text{tip}} = \\frac{PL^3}{3EI}",
      "videoUrl": null,
      "traps": [
        "Using a simple-span constant (48EI) for a cantilever",
        "Dropping the factor of 3 in the denominator"
      ],
      "diagram": null
    }
  ]
};
