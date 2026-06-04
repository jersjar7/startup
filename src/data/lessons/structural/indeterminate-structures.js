export default {
  "id": "indeterminate-structures",
  "name": "Elementary Indeterminate Structures",
  "subtopicId": "analysis-loads",
  "application": "Real structures are usually statically indeterminate — continuous beams, fixed-end members, propped cantilevers. The FE keeps this elementary: count the degree of indeterminacy, then handle a single redundant with the force method (consistent deformations) or recall standard results like the propped-cantilever reaction and fixed-end moments.",
  "content": [
    {
      "type": "text",
      "body": "A structure is statically indeterminate when it has more reaction/internal unknowns than equilibrium equations. The degree of static indeterminacy (DSI) is how many extra unknowns there are — the number of redundants you must release to make it determinate."
    },
    {
      "type": "heading",
      "body": "Degree of Indeterminacy"
    },
    {
      "type": "formula",
      "latex": "\\text{Beam/frame: } DSI = (3m + r) - (3n + c)\\qquad \\text{Truss: } DSI = (m + r) - 2j",
      "label": "m = members, r = reactions, n = joints (frames), c = condition eqns, j = joints (truss)"
    },
    {
      "type": "text",
      "body": "Quick beam check: a beam with $r$ reaction components and no internal hinges is indeterminate to degree $r - 3$. A propped cantilever (fixed + roller) has $3 + 1 = 4$ reactions, so $DSI = 4 - 3 = 1$."
    },
    {
      "type": "heading",
      "body": "Force Method (Consistent Deformations)"
    },
    {
      "type": "text",
      "body": "For one redundant: remove it to get a determinate 'primary' structure. Find the deflection at the released point due to the loads ($\\delta_{10}$) and due to a unit value of the redundant ($\\delta_{11}$). Compatibility requires the real deflection there to be zero, so the redundant is $R = -\\delta_{10}/\\delta_{11}$."
    },
    {
      "type": "heading",
      "body": "Standard Results Worth Memorizing"
    },
    {
      "type": "formula",
      "latex": "R_{\\text{prop}} = \\frac{3wL}{8}\\;\\text{(propped cantilever, UDL)}\\qquad M_{FE} = \\frac{wL^2}{12}\\;\\text{(fixed-fixed, UDL)}"
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "On the FE, recognizing the standard case usually beats setting up the full force method. Memorize the propped-cantilever prop reaction (3wL/8) and the fixed-end moments (wL²/12 for UDL, PL/8 for a central point load)."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "Don't confuse fixed-end moment wL²/12 with the simple-span maximum moment wL²/8 — the fixed ends pull the moment down at midspan and create end moments instead."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "str-ind-q1",
      "statement": "A propped cantilever beam is fixed at one end and supported on a roller at the other. What is its degree of static indeterminacy?",
      "choices": [
        { "id": "c1", "text": "1" },
        { "id": "c2", "text": "0" },
        { "id": "c3", "text": "2" },
        { "id": "c4", "text": "3" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "Count reactions: the fixed end provides 3 (horizontal, vertical, moment) and the roller provides 1 (vertical), giving 4. A planar beam has 3 equilibrium equations, so $DSI = 4 - 3 = 1$ — indeterminate to the first degree. The \"0\" option would be a determinate beam (e.g., simply supported).",
      "hint": "Count reaction components, subtract the 3 equilibrium equations.",
      "steps": [
        { "text": "Fixed end = 3 reactions; roller = 1 reaction; total $r = 4$.", "latex": null },
        { "text": "Planar equilibrium provides 3 equations.", "latex": null },
        { "text": "$DSI = r - 3 = 4 - 3 = 1$.", "latex": null }
      ],
      "handbookPage": null,
      "handbookFormula": "DSI = r - 3",
      "videoUrl": null,
      "traps": [
        "Counting the fixed end as 2 reactions (it provides 3, including the moment)",
        "Treating the propped cantilever as determinate (DSI = 0)"
      ],
      "diagram": { "component": "ProppedCantilever", "props": {"length":6,"w":0} }
    },
    {
      "id": "str-ind-q2",
      "statement": "A propped cantilever (fixed at one end, roller at the other) of length $L = 8\\text{ m}$ carries a uniformly distributed load $w = 12\\text{ kN/m}$. What is the reaction at the propped (roller) end?",
      "choices": [
        { "id": "c1", "text": "$36\\text{ kN}$" },
        { "id": "c2", "text": "$48\\text{ kN}$" },
        { "id": "c3", "text": "$60\\text{ kN}$" },
        { "id": "c4", "text": "$24\\text{ kN}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "The standard propped-cantilever result for a UDL gives the prop (roller) reaction $R = 3wL/8 = 3(12)(8)/8 = 36\\text{ kN}$. The 48 kN choice is the simple-span half-load $wL/2$, ignoring that the fixed end takes more (it carries 60 kN). The 24 kN choice uses $wL/4$.",
      "hint": "Propped cantilever under UDL: prop reaction = 3wL/8.",
      "steps": [
        { "text": "Total load $= wL = 12 \\times 8 = 96\\text{ kN}$.", "latex": null },
        { "text": "Prop reaction (standard result):", "latex": "R = \\frac{3wL}{8} = \\frac{3(12)(8)}{8}" },
        { "text": "Compute:", "latex": "R = 3 \\times 12 = 36\\text{ kN}" }
      ],
      "handbookPage": null,
      "handbookFormula": "R = \\frac{3wL}{8}",
      "videoUrl": null,
      "traps": [
        "Using wL/2 = 48 kN (the simple-span reaction) instead of 3wL/8",
        "Splitting the load evenly between supports"
      ],
      "diagram": { "component": "ProppedCantilever", "props": {"length":8,"w":12,"unit":"kN/m"} }
    },
    {
      "id": "str-ind-q3",
      "statement": "A beam fixed at both ends spans $L = 6\\text{ m}$ and carries a uniformly distributed load $w = 10\\text{ kN/m}$. What is the magnitude of the fixed-end moment at each support?",
      "choices": [
        { "id": "c1", "text": "$30\\text{ kN·m}$" },
        { "id": "c2", "text": "$45\\text{ kN·m}$" },
        { "id": "c3", "text": "$20\\text{ kN·m}$" },
        { "id": "c4", "text": "$15\\text{ kN·m}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Fixed-fixed beam under UDL: the fixed-end moment is $wL^2/12 = 10(6^2)/12 = 360/12 = 30\\text{ kN·m}$. The 45 kN\u00b7m choice uses the simple-span midspan moment $wL^2/8$ by mistake — that's the wrong formula for a fixed end.",
      "hint": "Fixed-fixed beam, UDL → fixed-end moment = wL²/12.",
      "steps": [
        { "text": "Standard result for a fixed-fixed beam under UDL.", "latex": null },
        { "text": "Apply the formula:", "latex": "M_{FE} = \\frac{wL^2}{12} = \\frac{10(6)^2}{12}" },
        { "text": "Compute:", "latex": "M_{FE} = \\frac{360}{12} = 30\\text{ kN·m}" }
      ],
      "handbookPage": null,
      "handbookFormula": "M_{FE} = \\frac{wL^2}{12}",
      "videoUrl": null,
      "traps": [
        "Using wL²/8 = 45 kN·m (the simple-span moment) for the fixed end",
        "Confusing the end moment with the reduced midspan moment (wL²/24)"
      ],
      "diagram": { "component": "FixedFixedBeam", "props": {"span":6,"w":10,"unit":"kN/m"} }
    }
  ]
};
