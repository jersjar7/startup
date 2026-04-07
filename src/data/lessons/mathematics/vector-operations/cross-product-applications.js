export default {
  "id": "cross-product-applications",
  "name": "Cross Product & Applications",
  "subtopicId": "vector-operations",
  "application": "The cross product gives civil engineers a vector perpendicular to two other vectors — and its magnitude equals the area of the parallelogram they form. In practice, you use it to compute the moment of a force about a point ($\\vec{M} = \\vec{r} \\times \\vec{F}$), find the area of a triangular region defined by two edge vectors, and determine the direction of a normal to a surface. On the FE, cross product questions appear in statics (moment calculations) and occasionally in surveying (area from coordinates). Know the determinant formula and the right-hand rule.",
  "content": [
    { "type": "text", "body": "The cross product takes two vectors and returns a new vector that is perpendicular to both. Its magnitude equals $|\\vec{A}||\\vec{B}|\\sin\\theta$." },
    { "type": "heading", "body": "Cross Product (Determinant Form)" },
    { "type": "formula", "latex": "\\vec{A} \\times \\vec{B} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ A_x & A_y & A_z \\\\ B_x & B_y & B_z \\end{vmatrix}" },
    { "type": "text", "body": "Expand using cofactors: $\\vec{A} \\times \\vec{B} = (A_yB_z - A_zB_y)\\hat{i} - (A_xB_z - A_zB_x)\\hat{j} + (A_xB_y - A_yB_x)\\hat{k}$." },
    { "type": "heading", "body": "Magnitude of the Cross Product" },
    { "type": "formula", "latex": "|\\vec{A} \\times \\vec{B}| = |\\vec{A}||\\vec{B}|\\sin\\theta" },
    { "type": "text", "body": "This equals the area of the parallelogram formed by the two vectors. Half of it gives the area of the triangle." },
    { "type": "heading", "body": "Moment of a Force" },
    { "type": "formula", "latex": "\\vec{M}_O = \\vec{r} \\times \\vec{F}" },
    { "type": "text", "body": "Where $\\vec{r}$ is the position vector from point $O$ to the point where $\\vec{F}$ is applied. The result is a moment vector — its magnitude is the torque, its direction is the axis of rotation." },
    { "type": "heading", "body": "Key Properties" },
    { "type": "text", "body": "$\\vec{A} \\times \\vec{B} = -(\\vec{B} \\times \\vec{A})$ — order matters. Reversing the order flips the sign. Also, $\\vec{A} \\times \\vec{A} = \\vec{0}$ — a vector crossed with itself is zero." },
    { "type": "callout", "variant": "tip", "body": "For the $\\hat{j}$ component, the sign is NEGATIVE in the cofactor expansion. A common mnemonic: \"+, −, +\" for $\\hat{i}$, $\\hat{j}$, $\\hat{k}$ cofactors." },
    { "type": "callout", "variant": "exam", "body": "The cross product returns a vector, not a scalar. If the problem asks for the magnitude of the moment, compute the cross product first, then take its magnitude." }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-cpa-q1",
      "statement": "Compute $\\vec{A} \\times \\vec{B}$ where $\\vec{A} = 1\\hat{i} + 0\\hat{j} + 0\\hat{k}$ and $\\vec{B} = 0\\hat{i} + 1\\hat{j} + 0\\hat{k}$.",
      "choices": [
        { "id": "c1", "text": "$1\\hat{k}$" },
        { "id": "c2", "text": "$-1\\hat{k}$" },
        { "id": "c3", "text": "$0$" },
        { "id": "c4", "text": "$1\\hat{i} + 1\\hat{j}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "i × j = k — this is the right-hand rule in action. Point your fingers along x, curl them toward y, and your thumb points along z. This is one of those \"just know it\" results that saves time. Choice B has the wrong sign — that would be j × i, the reversed order.",
      "hint": "Use the determinant formula, or recall that i × j = k.",
      "steps": [
        { "text": "Set up the determinant:", "latex": "\\hat{i}(0 \\cdot 0 - 0 \\cdot 1) - \\hat{j}(1 \\cdot 0 - 0 \\cdot 0) + \\hat{k}(1 \\cdot 1 - 0 \\cdot 0)" },
        { "text": "Simplify:", "latex": "\\hat{i}(0) - \\hat{j}(0) + \\hat{k}(1) = 1\\hat{k}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "\\vec{A} \\times \\vec{B} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ A_x & A_y & A_z \\\\ B_x & B_y & B_z \\end{vmatrix}",
      "videoUrl": null,
      "traps": [
        "Reversing the order: B × A = -k, not +k",
        "Thinking the cross product of perpendicular unit vectors is zero — that's the dot product (i · j = 0)"
      ],
      "diagram": null
    },
    {
      "id": "math-cpa-q2",
      "statement": "A force $\\vec{F} = 0\\hat{i} + 0\\hat{j} - 50\\hat{k}$ N (downward) is applied at point $P$. The position vector from the pivot $O$ to $P$ is $\\vec{r} = 3\\hat{i} + 4\\hat{j} + 0\\hat{k}$ m. What is the moment $\\vec{M}_O = \\vec{r} \\times \\vec{F}$?",
      "choices": [
        { "id": "c1", "text": "$0\\hat{i} + 0\\hat{j} - 350\\hat{k}$ N·m" },
        { "id": "c2", "text": "$200\\hat{i} - 150\\hat{j} + 0\\hat{k}$ N·m" },
        { "id": "c3", "text": "$-200\\hat{i} + 150\\hat{j} + 0\\hat{k}$ N·m" },
        { "id": "c4", "text": "$150\\hat{i} + 200\\hat{j} + 0\\hat{k}$ N·m" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "medium",
      "eli5": "Moment = r × F. Set up the 3×3 determinant and expand carefully. The j component has the MINUS sign in front of the cofactor — so you get -(3·(-50) - 0) = -(-150) = +150. That negative-of-a-negative is where most people mess up. Choice B flips all the signs — that is F × r (wrong order).",
      "hint": "Set up the determinant with r in the second row and F in the third row. Watch the sign on the j cofactor.",
      "steps": [
        { "text": "Set up:", "latex": "\\vec{r} \\times \\vec{F} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ 3 & 4 & 0 \\\\ 0 & 0 & -50 \\end{vmatrix}" },
        { "text": "$\\hat{i}$ component:", "latex": "(4)(-50) - (0)(0) = -200" },
        { "text": "$\\hat{j}$ component:", "latex": "-[(3)(-50) - (0)(0)] = -(-150) = 150" },
        { "text": "$\\hat{k}$ component:", "latex": "(3)(0) - (4)(0) = 0" },
        { "text": "Result:", "latex": "\\vec{M}_O = -200\\hat{i} + 150\\hat{j} + 0\\hat{k} \\text{ N·m}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "\\vec{M}_O = \\vec{r} \\times \\vec{F}",
      "videoUrl": null,
      "traps": [
        "Forgetting the negative sign on the j cofactor — the pattern is +, −, + across the three components",
        "Reversing r and F — moment is r × F, not F × r"
      ],
      "diagram": { "component": "MomentVector3D", "props": { "rx": 3, "ry": 4, "fz": -50 } }
    },
    {
      "id": "math-cpa-q3",
      "statement": "Two edges of a triangular plot are defined by $\\vec{u} = 4\\hat{i} + 0\\hat{j} + 0\\hat{k}$ m and $\\vec{v} = 2\\hat{i} + 3\\hat{j} + 0\\hat{k}$ m. What is the area of the triangle?",
      "choices": [
        { "id": "c1", "text": "$12$ m²" },
        { "id": "c2", "text": "$6$ m²" },
        { "id": "c3", "text": "$5$ m²" },
        { "id": "c4", "text": "$8$ m²" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "hard",
      "eli5": "The cross product magnitude gives the parallelogram area. A triangle is half the parallelogram. So: compute the cross product, take the magnitude, divide by 2. Choice A (12) is the parallelogram area without halving — the most common mistake. Since both vectors lie in the xy-plane, the cross product points purely in the k direction, which makes the magnitude easy.",
      "hint": "Triangle area = ½|u × v|. Compute the cross product first, then take half its magnitude.",
      "steps": [
        { "text": "Cross product:", "latex": "\\vec{u} \\times \\vec{v} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ 4 & 0 & 0 \\\\ 2 & 3 & 0 \\end{vmatrix}" },
        { "text": "$\\hat{i}$: $(0)(0) - (0)(3) = 0$; $\\hat{j}$: $-[(4)(0) - (0)(2)] = 0$; $\\hat{k}$: $(4)(3) - (0)(2) = 12$", "latex": "\\vec{u} \\times \\vec{v} = 12\\hat{k}" },
        { "text": "Parallelogram area:", "latex": "|\\vec{u} \\times \\vec{v}| = 12 \\text{ m}^2" },
        { "text": "Triangle area:", "latex": "\\frac{12}{2} = 6 \\text{ m}^2" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "|\\vec{A} \\times \\vec{B}| = |\\vec{A}||\\vec{B}|\\sin\\theta",
      "videoUrl": null,
      "traps": [
        "Forgetting to divide by 2 — the cross product magnitude gives the parallelogram area, not the triangle area",
        "Using the dot product instead of the cross product — the dot product gives a scalar related to $\\cos\\theta$, not an area"
      ],
      "diagram": { "component": "TrianglePlotVectors", "props": { "ux": 4, "uy": 0, "vx": 2, "vy": 3 } }
    }
  ],
  "examProblems": [
    {
      "id": "math-cpa-ex1",
      "type": "computational",
      "statement": "Compute $\\vec{A} \\times \\vec{B}$ where $\\vec{A} = 2\\hat{i} + 3\\hat{j} + 0\\hat{k}$ and $\\vec{B} = 0\\hat{i} + 0\\hat{j} + 4\\hat{k}$.",
      "choices": [
        { "id": "c1", "text": "$12\\hat{i} - 8\\hat{j} + 0\\hat{k}$" },
        { "id": "c2", "text": "$-12\\hat{i} + 8\\hat{j} + 0\\hat{k}$" },
        { "id": "c3", "text": "$0\\hat{i} + 0\\hat{j} + 8\\hat{k}$" },
        { "id": "c4", "text": "$12\\hat{i} + 8\\hat{j} + 0\\hat{k}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "Set up the 3x3 determinant with $\\hat{i}, \\hat{j}, \\hat{k}$ in the top row. The $\\hat{i}$ component: $(3)(4) - (0)(0) = 12$. The $\\hat{j}$ component: $-[(2)(4) - (0)(0)] = -8$. The $\\hat{k}$ component: $(2)(0) - (3)(0) = 0$. So the result is $12\\hat{i} - 8\\hat{j}$. Choice B has the signs flipped — that's $\\vec{B} \\times \\vec{A}$. Remember the sign pattern: $+, -, +$ for $\\hat{i}, \\hat{j}, \\hat{k}$.",
      "hint": "Use the determinant formula. Watch the negative sign on the $\\hat{j}$ cofactor.",
      "steps": [
        { "text": "Set up the determinant:", "latex": "\\vec{A} \\times \\vec{B} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ 2 & 3 & 0 \\\\ 0 & 0 & 4 \\end{vmatrix}" },
        { "text": "$\\hat{i}$: $(3)(4) - (0)(0) = 12$", "latex": null },
        { "text": "$\\hat{j}$: $-[(2)(4) - (0)(0)] = -8$", "latex": null },
        { "text": "$\\hat{k}$: $(2)(0) - (3)(0) = 0$", "latex": null },
        { "text": "Result:", "latex": "\\vec{A} \\times \\vec{B} = 12\\hat{i} - 8\\hat{j} + 0\\hat{k}" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "\\vec{A} \\times \\vec{B} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ A_x & A_y & A_z \\\\ B_x & B_y & B_z \\end{vmatrix}",
      "videoUrl": null,
      "traps": [
        "Forgetting the negative sign on the j cofactor",
        "Reversing the order and getting B x A (which flips all signs)"
      ],
      "diagram": null
    },
    {
      "id": "math-cpa-ex2",
      "type": "computational",
      "statement": "A 100 N downward force ($\\vec{F} = 0\\hat{i} + 0\\hat{j} - 100\\hat{k}$ N) is applied at a point with position vector $\\vec{r} = 5\\hat{i} + 0\\hat{j} + 0\\hat{k}$ m from a pivot. What is the magnitude of the moment about the pivot?",
      "choices": [
        { "id": "c1", "text": "$0$ N$\\cdot$m" },
        { "id": "c2", "text": "$100$ N$\\cdot$m" },
        { "id": "c3", "text": "$250$ N$\\cdot$m" },
        { "id": "c4", "text": "$500$ N$\\cdot$m" }
      ],
      "correctAnswerId": "c4",
      "difficulty": "medium",
      "eli5": "Moment = $\\vec{r} \\times \\vec{F}$. Set up the determinant: $\\hat{i}(0 \\cdot(-100) - 0 \\cdot 0) - \\hat{j}(5 \\cdot(-100) - 0 \\cdot 0) + \\hat{k}(5 \\cdot 0 - 0 \\cdot 0) = 0\\hat{i} + 500\\hat{j} + 0\\hat{k}$. The magnitude is 500 N$\\cdot$m. You can also reason geometrically: force and position vector are perpendicular, so $M = rF\\sin 90° = 5 \\times 100 = 500$.",
      "hint": "Compute $\\vec{r} \\times \\vec{F}$ using the determinant, then take the magnitude.",
      "steps": [
        { "text": "Set up the determinant:", "latex": "\\vec{r} \\times \\vec{F} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ 5 & 0 & 0 \\\\ 0 & 0 & -100 \\end{vmatrix}" },
        { "text": "$\\hat{i}$: $(0)(-100) - (0)(0) = 0$", "latex": null },
        { "text": "$\\hat{j}$: $-[(5)(-100) - (0)(0)] = -(-500) = 500$", "latex": null },
        { "text": "$\\hat{k}$: $(5)(0) - (0)(0) = 0$", "latex": null },
        { "text": "Magnitude:", "latex": "|\\vec{M}| = \\sqrt{0^2 + 500^2 + 0^2} = 500 \\text{ N·m}" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "\\vec{M}_O = \\vec{r} \\times \\vec{F}",
      "videoUrl": null,
      "traps": [
        "Sign error on the j cofactor — the pattern is +, -, +",
        "Computing F x r instead of r x F (wrong order reverses the moment direction)"
      ],
      "diagram": null
    },
    {
      "id": "math-cpa-ex3",
      "type": "computational",
      "statement": "Two edge vectors of a triangular surveying plot are $\\vec{u} = 3\\hat{i} + 1\\hat{j} + 0\\hat{k}$ m and $\\vec{v} = -1\\hat{i} + 4\\hat{j} + 0\\hat{k}$ m. What is the area of the triangle?",
      "choices": [
        { "id": "c1", "text": "$11$ m$^2$" },
        { "id": "c2", "text": "$13$ m$^2$" },
        { "id": "c3", "text": "$6.5$ m$^2$" },
        { "id": "c4", "text": "$5$ m$^2$" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "medium",
      "eli5": "The cross product magnitude gives the parallelogram area, so divide by 2 for the triangle. Both vectors are in the $xy$-plane, so only the $\\hat{k}$ component survives: $(3)(4) - (1)(-1) = 12 + 1 = 13$. The cross product is $13\\hat{k}$, magnitude is 13. Triangle area = $13/2 = 6.5$ m$^2$. Choice B (13) is the parallelogram area — forgetting to halve is the most common mistake.",
      "hint": "Triangle area = $\\frac{1}{2}|\\vec{u} \\times \\vec{v}|$. Don't forget the $\\frac{1}{2}$.",
      "steps": [
        { "text": "Cross product (both vectors in $xy$-plane, only $\\hat{k}$ survives):", "latex": "\\vec{u} \\times \\vec{v} = [(3)(4) - (1)(-1)]\\hat{k} = 13\\hat{k}" },
        { "text": "Parallelogram area:", "latex": "|\\vec{u} \\times \\vec{v}| = 13 \\text{ m}^2" },
        { "text": "Triangle area:", "latex": "\\frac{13}{2} = 6.5 \\text{ m}^2" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "|\\vec{A} \\times \\vec{B}| = |\\vec{A}||\\vec{B}|\\sin\\theta",
      "videoUrl": null,
      "traps": [
        "Forgetting to divide by 2 — the cross product gives parallelogram area, not triangle area",
        "Sign error in the $\\hat{k}$ component: $(3)(4) - (1)(-1) = 13$, not 11"
      ],
      "diagram": null
    },
    {
      "id": "math-cpa-ex4",
      "type": "conceptual",
      "statement": "If $\\vec{A} \\times \\vec{B} = \\vec{0}$ and neither vector is the zero vector, what can you conclude about $\\vec{A}$ and $\\vec{B}$?",
      "choices": [
        { "id": "c1", "text": "The vectors are perpendicular" },
        { "id": "c2", "text": "The vectors are parallel (or anti-parallel)" },
        { "id": "c3", "text": "The vectors have equal magnitude" },
        { "id": "c4", "text": "The dot product is also zero" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "hard",
      "eli5": "The cross product magnitude is $|A||B|\\sin\\theta$. For this to be zero with nonzero vectors, $\\sin\\theta$ must be zero, which happens at $\\theta = 0°$ (parallel) or $\\theta = 180°$ (anti-parallel). This is the opposite of the dot product test: dot product zero means perpendicular (cos = 0), cross product zero means parallel (sin = 0). Don't mix them up. Choice A is the dot product test, not the cross product test.",
      "hint": "The magnitude formula uses $\\sin\\theta$. When is sine zero?",
      "steps": [
        { "text": "From the magnitude formula:", "latex": "|\\vec{A} \\times \\vec{B}| = |\\vec{A}||\\vec{B}|\\sin\\theta = 0" },
        { "text": "Since $|\\vec{A}| \\neq 0$ and $|\\vec{B}| \\neq 0$, we need $\\sin\\theta = 0$.", "latex": null },
        { "text": "$\\sin\\theta = 0$ when $\\theta = 0°$ (parallel) or $\\theta = 180°$ (anti-parallel).", "latex": null }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "|\\vec{A} \\times \\vec{B}| = |\\vec{A}||\\vec{B}|\\sin\\theta",
      "videoUrl": null,
      "traps": [
        "Confusing cross product = 0 (parallel) with dot product = 0 (perpendicular)",
        "Forgetting that anti-parallel (180°) also gives a zero cross product"
      ],
      "diagram": null
    }
  ]
};
